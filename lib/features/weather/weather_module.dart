import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/core/network/api_constants.dart';
import 'package:ecosafra/core/network/network_info.dart';
import 'package:ecosafra/features/weather/data/datasources/device_location_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/drift_weather_local_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/geolocator_location_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/open_meteo_remote_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:ecosafra/features/weather/data/repositories/location_repository_impl.dart';
import 'package:ecosafra/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:ecosafra/features/weather/domain/repositories/location_repository.dart';
import 'package:ecosafra/features/weather/domain/repositories/weather_repository.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Módulo "de serviço": só binds, sem rotas. Nenhuma tela é dele — quem tem
/// tela é o painel, que faz `imports => [WeatherModule()]` pra reusar esses
/// use cases sem duplicar a fiação de Dio/banco local.
///
/// `Dio` e `AppDatabase` (bindados no AppModule) são resolvidos aqui, não
/// recriados: é o mesmo cliente HTTP e a mesma conexão de banco do resto
/// do app.
class WeatherModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<WeatherRemoteDataSource>(
        (i) => OpenMeteoRemoteDataSource(
          i.get<Dio>(key: ApiConstants.openMeteoDioKey),
        ),
      )
      ..addSingleton<WeatherLocalDataSource>(
        (i) => DriftWeatherLocalDataSource(i.get<AppDatabase>()),
      )
      ..addSingleton<WeatherRepository>(
        (i) => WeatherRepositoryImpl(
          remote: i.get<WeatherRemoteDataSource>(),
          local: i.get<WeatherLocalDataSource>(),
          networkInfo: i.get<NetworkInfo>(),
        ),
      )
      ..addSingleton<GetForecast>(
        (i) => GetForecast(i.get<WeatherRepository>()),
      )
      ..addSingleton<EvaluateApplicationSafety>(
        (i) => EvaluateApplicationSafety(clock: i.get<Clock>()),
      )
      ..addSingleton<DeviceLocationDataSource>(
        (i) => const GeolocatorLocationDataSource(),
      )
      ..addSingleton<LocationRepository>(
        (i) => LocationRepositoryImpl(i.get<DeviceLocationDataSource>()),
      )
      ..addSingleton<GetCurrentLocation>(
        (i) => GetCurrentLocation(i.get<LocationRepository>()),
      );
  }
}
