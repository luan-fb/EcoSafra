import 'dart:async';

import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Orquestra os três use cases da tela: acha o talhão, busca a previsão,
/// decide se pode adubar.
///
/// `GetForecast` é cache-first e pode emitir duas vezes (cache, depois
/// rede) — esta Cubit roda `EvaluateApplicationSafety` a cada emissão e
/// repassa como um novo estado. É por isso que o painel nunca fica preso
/// num spinner esperando a Open-Meteo: se já existe cache, o card de
/// decisão aparece antes mesmo da tentativa de rede terminar — só troca de
/// cor depois, se a previsão fresca mudar o veredito.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required GetCurrentLocation getCurrentLocation,
    required GetForecast getForecast,
    required EvaluateApplicationSafety evaluateApplicationSafety,
  })  : _getCurrentLocation = getCurrentLocation,
        _getForecast = getForecast,
        _evaluateApplicationSafety = evaluateApplicationSafety,
        super(const DashboardState.initial()) {
    unawaited(loadForecast());
  }

  final GetCurrentLocation _getCurrentLocation;
  final GetForecast _getForecast;
  final EvaluateApplicationSafety _evaluateApplicationSafety;

  Future<void> loadForecast() async {
    emit(const DashboardState.loading());

    final locationResult = await _getCurrentLocation(const NoParams());
    await locationResult.match(
      (failure) async => emit(DashboardState.error(failure)),
      (coordinates) async {
        await for (final result in _getForecast(coordinates)) {
          result.match(
            (failure) => emit(DashboardState.error(failure)),
            _emitForecast,
          );
        }
      },
    );
  }

  void _emitForecast(WeatherForecast forecast) {
    _evaluateApplicationSafety(forecast).match(
      (failure) => emit(DashboardState.error(failure)),
      (advice) => emit(DashboardState.loaded(forecast, advice)),
    );
  }
}
