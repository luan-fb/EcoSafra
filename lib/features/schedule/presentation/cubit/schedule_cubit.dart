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
import 'package:ecosafra/features/schedule/domain/usecases/set_schedule_completed.dart';
import 'package:ecosafra/features/schedule/domain/usecases/update_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/watch_schedules.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Combina o stream de agendamentos do banco com a previsão cache-first,
/// buscada uma vez ao abrir a tela. A lista aparece sem esperar a previsão:
/// até ela chegar, o risco fica `unknown`.
///
/// Ações bem-sucedidas não emitem nada: a lista nova chega pelo stream.
class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit({
    required WatchSchedules watchSchedules,
    required CreateSchedule createSchedule,
    required UpdateSchedule updateSchedule,
    required SetScheduleCompleted setScheduleCompleted,
    required DeleteSchedule deleteSchedule,
    required GetCurrentLocation getCurrentLocation,
    required GetForecast getForecast,
    required EvaluateScheduleRisk evaluateScheduleRisk,
    required Clock clock,
  }) : _createSchedule = createSchedule,
       _updateSchedule = updateSchedule,
       _setScheduleCompleted = setScheduleCompleted,
       _deleteSchedule = deleteSchedule,
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

  Future<void> removeSchedule(String id) async {
    final result = await _deleteSchedule(id);
    result.match(_emitActionFailure, (_) {});
  }

  void _onSchedules(List<FertilizationSchedule> schedules) {
    _schedules = schedules;
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

    for (final (index, schedule) in schedules.indexed) {
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
