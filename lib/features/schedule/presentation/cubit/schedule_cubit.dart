import 'dart:async';

import 'package:clock/clock.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/extensions/date_extensions.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:ecosafra/features/schedule/domain/usecases/create_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/delete_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_risk.dart';
import 'package:ecosafra/features/schedule/domain/usecases/restore_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/set_schedule_completed.dart';
import 'package:ecosafra/features/schedule/domain/usecases/update_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/watch_schedules.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

/// Combina o stream de agendamentos do banco com a previsão cache-first,
/// buscada uma vez ao abrir a tela. A lista aparece sem esperar a previsão:
/// até ela chegar, o risco fica `unknown`.
///
/// Ações bem-sucedidas não emitem nada: a lista nova chega pelo stream. A
/// exceção é a exclusão, que tira o item da lista antes de chamar o banco.
class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit({
    required WatchSchedules watchSchedules,
    required CreateSchedule createSchedule,
    required UpdateSchedule updateSchedule,
    required SetScheduleCompleted setScheduleCompleted,
    required DeleteSchedule deleteSchedule,
    required RestoreSchedule restoreSchedule,
    required GetCurrentLocation getCurrentLocation,
    required GetForecast getForecast,
    required EvaluateScheduleRisk evaluateScheduleRisk,
    required Clock clock,
  }) : _createSchedule = createSchedule,
       _updateSchedule = updateSchedule,
       _setScheduleCompleted = setScheduleCompleted,
       _deleteSchedule = deleteSchedule,
       _restoreSchedule = restoreSchedule,
       _getCurrentLocation = getCurrentLocation,
       _getForecast = getForecast,
       _evaluateScheduleRisk = evaluateScheduleRisk,
       _clock = clock,
       super(ScheduleState.loading(SchedulingWindow.startingAt(clock.now()))) {
    _schedulesSubscription = watchSchedules(
      const NoParams(),
    ).listen(_onSchedules, onError: _onSchedulesError);
    unawaited(_loadForecast());
  }

  static const _loadFailure = CacheFailure(
    'Não foi possível carregar a agenda.',
  );

  final CreateSchedule _createSchedule;
  final UpdateSchedule _updateSchedule;
  final SetScheduleCompleted _setScheduleCompleted;
  final DeleteSchedule _deleteSchedule;
  final RestoreSchedule _restoreSchedule;
  final GetCurrentLocation _getCurrentLocation;
  final GetForecast _getForecast;
  final EvaluateScheduleRisk _evaluateScheduleRisk;
  final Clock _clock;

  late final StreamSubscription<List<FertilizationSchedule>>
  _schedulesSubscription;
  StreamSubscription<Object?>? _forecastSubscription;

  /// `null` até a primeira emissão do stream: a previsão sozinha não pode
  /// transformar `loading` ou `error` numa lista vazia.
  List<FertilizationSchedule>? _schedules;
  WeatherForecast? _forecast;

  /// Excluídos que o stream ainda traz. Cada id sai daqui quando uma emissão
  /// deixa de trazê-lo, para um item restaurado depois não continuar oculto.
  final Set<String> _hiddenIds = {};

  /// Exclusões ainda em andamento, por id: restaurar antes de a exclusão
  /// terminar tentaria inserir um id que ainda existe no banco.
  final Map<String, Future<Either<Failure, void>>> _pendingDeletes = {};

  /// Janela calculada na hora em que o formulário abre: com a tela aberta
  /// na virada do dia, `state.window` ainda seria a de ontem até a próxima
  /// emissão.
  SchedulingWindow currentWindow() => SchedulingWindow.startingAt(_clock.now());

  Future<void> addSchedule(DateTime date, {String? note}) async {
    final result = await _createSchedule(
      CreateScheduleParams(scheduledDate: date, note: note),
    );
    result.match(_emitActionFailure, (_) {});
  }

  Future<void> editSchedule(String id, DateTime date, {String? note}) async {
    final result = await _updateSchedule(
      UpdateScheduleParams(id: id, scheduledDate: date, note: note),
    );
    result.match(_emitActionFailure, (_) {});
  }

  Future<void> setCompleted(String id, {required bool completed}) async {
    final result = await _setScheduleCompleted(
      SetScheduleCompletedParams(id: id, completed: completed),
    );
    result.match(_emitActionFailure, (_) {});
  }

  /// Emite a lista sem o item antes de chamar o banco: o `Dismissible`
  /// exige o item fora da árvore no frame seguinte ao gesto.
  Future<void> removeSchedule(String id) async {
    if (isClosed) return;
    _hiddenIds.add(id);
    _emitLoaded();

    final deletion = _deleteSchedule(id);
    _pendingDeletes[id] = deletion;
    final result = await deletion;
    unawaited(_pendingDeletes.remove(id));
    result.match((failure) {
      _hiddenIds.remove(id);
      if (isClosed) return;
      _emitLoaded();
      _emitActionFailure(failure);
    }, (_) {});
  }

  /// O item volta pela próxima emissão do stream. O id deixa de ser oculto
  /// já aqui: se o banco juntar exclusão e restauração numa emissão só, o
  /// stream nunca deixaria de trazê-lo.
  Future<void> restoreSchedule(FertilizationSchedule schedule) async {
    _hiddenIds.remove(schedule.id);
    final pending = _pendingDeletes[schedule.id];
    // Exclusão que falhou não tirou o item do banco: não há o que restaurar.
    if (pending != null && (await pending).isLeft()) return;
    final result = await _restoreSchedule(schedule);
    result.match(_emitActionFailure, (_) {});
  }

  void _onSchedules(List<FertilizationSchedule> schedules) {
    _schedules = schedules;
    final ids = {for (final schedule in schedules) schedule.id};
    _hiddenIds.retainAll(ids);
    _emitLoaded();
  }

  /// Depois de carregada, a lista continua na tela: o stream segue ativo e
  /// a próxima emissão a atualiza.
  void _onSchedulesError(Object _) {
    if (state.status == ScheduleStatus.loaded) return;
    emit(
      ScheduleState.error(
        _loadFailure,
        SchedulingWindow.startingAt(_clock.now()),
      ),
    );
  }

  /// Sem localização ou sem previsão, a Agenda funciona com risco `unknown`.
  Future<void> _loadForecast() async {
    final location = await _getCurrentLocation(const NoParams());
    if (isClosed) return;
    location.match((_) {}, (coordinates) {
      _forecastSubscription = _getForecast(coordinates).listen(
        (result) => result.match((_) {}, (forecast) {
          _forecast = forecast;
          _emitLoaded();
        }),
        onError: (Object _) {},
      );
    });
  }

  void _emitLoaded() {
    final schedules = _schedules;
    if (schedules == null) return;

    final now = _clock.now();
    final today = now.dateOnly;
    final upcoming = <ScheduleItem>[];
    final completed = <(int, ScheduleItem)>[];

    final visible = schedules.where((s) => !_hiddenIds.contains(s.id));
    for (final (index, schedule) in visible.indexed) {
      if (schedule.isCompleted) {
        completed.add((
          index,
          ScheduleItem(
            schedule: schedule,
            risk: ScheduleRiskLevel.unknown,
            isPastDue: false,
          ),
        ));
        continue;
      }
      final isPastDue = schedule.scheduledDate.dateOnly.isBefore(today);
      upcoming.add(
        ScheduleItem(
          schedule: schedule,
          risk: isPastDue ? ScheduleRiskLevel.unknown : _riskOf(schedule),
          isPastDue: isPastDue,
          expectedRainMm: isPastDue
              ? null
              : _forecast?.dayOf(schedule.scheduledDate)?.precipitationSum,
        ),
      );
    }

    // `sort` não é estável: o índice no stream desempata datas iguais, na
    // ordem inversa, para os concluídos seguirem decrescentes por inteiro.
    completed.sort((a, b) {
      final byDate = b.$2.schedule.scheduledDate.compareTo(
        a.$2.schedule.scheduledDate,
      );
      return byDate != 0 ? byDate : b.$1.compareTo(a.$1);
    });

    emit(
      ScheduleState.loaded(
        upcoming: upcoming,
        completed: [for (final (_, item) in completed) item],
        window: SchedulingWindow.startingAt(now),
      ),
    );
  }

  ScheduleRiskLevel _riskOf(FertilizationSchedule schedule) {
    final forecast = _forecast;
    if (forecast == null) return ScheduleRiskLevel.unknown;
    return _evaluateScheduleRisk(
      EvaluateScheduleRiskParams(schedule: schedule, forecast: forecast),
    ).getOrElse((_) => ScheduleRiskLevel.unknown);
  }

  /// Limpa a falha anterior quando ela se repete: estados iguais não são
  /// emitidos, e o snackbar da segunda falha não apareceria.
  void _emitActionFailure(Failure failure) {
    if (isClosed) return;
    if (state.failure == failure) emit(state.withActionFailure(null));
    emit(state.withActionFailure(failure));
  }

  @override
  Future<void> close() async {
    await _schedulesSubscription.cancel();
    await _forecastSubscription?.cancel();
    return super.close();
  }
}
