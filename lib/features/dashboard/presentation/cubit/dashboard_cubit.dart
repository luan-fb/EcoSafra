import 'dart:async';

import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_location_description.dart';
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
///
/// O nome do lugar corre em paralelo e entra no estado quando chegar, sem
/// segurar a previsão.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required GetCurrentLocation getCurrentLocation,
    required GetForecast getForecast,
    required EvaluateApplicationSafety evaluateApplicationSafety,
    required GetLocationDescription getLocationDescription,
  })  : _getCurrentLocation = getCurrentLocation,
        _getForecast = getForecast,
        _evaluateApplicationSafety = evaluateApplicationSafety,
        _getLocationDescription = getLocationDescription,
        super(const DashboardState.initial()) {
    unawaited(loadForecast());
  }

  final GetCurrentLocation _getCurrentLocation;
  final GetForecast _getForecast;
  final EvaluateApplicationSafety _evaluateApplicationSafety;
  final GetLocationDescription _getLocationDescription;

  /// Descrição das últimas coordenadas: ao atualizar no mesmo lugar, o
  /// cabeçalho não some enquanto a nova descrição não chega.
  Coordinates? _describedCoordinates;
  LocationDescription? _location;

  /// Só a descrição do carregamento mais recente entra no estado, e só
  /// depois que a previsão desse carregamento estiver na tela: antes disso,
  /// ela rotularia a previsão do lugar anterior.
  int _loadId = 0;
  int? _shownLoadId;

  Future<void> loadForecast() async {
    final loadId = ++_loadId;
    // Ao puxar para atualizar, a previsão na tela fica até a nova chegar:
    // o `RefreshIndicator` já mostra que está carregando.
    if (state.status != DashboardStatus.loaded) {
      emit(const DashboardState.loading());
    } else if (state.refreshFailure != null) {
      // Limpa a falha anterior: a mesma falha de novo precisa virar um
      // estado novo para o snackbar aparecer outra vez.
      emit(state.withRefreshFailure(null));
    }

    final locationResult = await _getCurrentLocation(const NoParams());
    await locationResult.match(
      (failure) async => emit(
        // Com a previsão na tela, a falha de localização não a apaga.
        state.status == DashboardStatus.loaded
            ? state.withRefreshFailure(failure)
            : DashboardState.error(failure),
      ),
      (coordinates) async {
        if (coordinates != _describedCoordinates) {
          _describedCoordinates = coordinates;
          _location = null;
        }
        unawaited(_describe(coordinates, loadId));
        await for (final result in _getForecast(coordinates)) {
          result.match(
            (failure) => emit(DashboardState.error(failure)),
            (forecast) => _emitForecast(forecast, loadId),
          );
        }
      },
    );
  }

  void _emitForecast(WeatherForecast forecast, int loadId) {
    _evaluateApplicationSafety(forecast).match(
      (failure) => emit(DashboardState.error(failure)),
      (advice) {
        _shownLoadId = loadId;
        emit(DashboardState.loaded(forecast, advice, location: _location));
      },
    );
  }

  Future<void> _describe(Coordinates coordinates, int loadId) async {
    final location = await _getLocationDescription(coordinates);
    if (isClosed || loadId != _loadId) return;
    _location = location;
    if (state.status == DashboardStatus.loaded && _shownLoadId == loadId) {
      emit(state.withLocation(location));
    }
  }
}
