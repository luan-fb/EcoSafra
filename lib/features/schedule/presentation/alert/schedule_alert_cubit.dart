import 'dart:async';

import 'package:clock/clock.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_alert.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_alert.dart';
import 'package:ecosafra/features/schedule/domain/usecases/watch_schedules.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_state.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Não busca previsão: recebe a que o painel já carregou, por
/// [updateForecast].
class ScheduleAlertCubit extends Cubit<ScheduleAlertState> {
  ScheduleAlertCubit({
    required WatchSchedules watchSchedules,
    required EvaluateScheduleAlert evaluateScheduleAlert,
    required Clock clock,
  }) : _evaluateScheduleAlert = evaluateScheduleAlert,
       _clock = clock,
       super(const ScheduleAlertState()) {
    _schedulesSubscription = watchSchedules(
      const NoParams(),
    ).listen(_onSchedules, onError: _onSchedulesError);
  }

  final EvaluateScheduleAlert _evaluateScheduleAlert;
  final Clock _clock;

  late final StreamSubscription<List<FertilizationSchedule>>
  _schedulesSubscription;

  /// `null` até a primeira lista e depois de um erro do stream: a previsão
  /// sozinha não pode gerar aviso sobre uma lista que não se sabe válida.
  List<FertilizationSchedule>? _schedules;
  WeatherForecast? _forecast;

  void updateForecast(WeatherForecast? forecast) {
    if (isClosed) return;
    _forecast = forecast;
    _evaluate();
  }

  void _onSchedules(List<FertilizationSchedule> schedules) {
    _schedules = schedules;
    _evaluate();
  }

  void _onSchedulesError(Object _) {
    _schedules = null;
    _emitAlert(null);
  }

  void _evaluate() {
    final schedules = _schedules;
    if (schedules == null) return;

    final result = _evaluateScheduleAlert(
      EvaluateScheduleAlertParams(
        schedules: schedules,
        forecast: _forecast,
        today: _clock.now(),
      ),
    );
    _emitAlert(result.getOrElse((_) => null));
  }

  /// O `Cubit` só descarta estado repetido a partir da segunda emissão; sem
  /// esta guarda, a primeira lista sem aviso reemitiria o estado inicial.
  void _emitAlert(ScheduleAlert? alert) {
    final next = ScheduleAlertState(alert: alert);
    if (next != state) emit(next);
  }

  @override
  Future<void> close() async {
    await _schedulesSubscription.cancel();
    return super.close();
  }
}
