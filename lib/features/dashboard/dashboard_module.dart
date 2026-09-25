import 'package:clock/clock.dart';
import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/app/router/page_transitions.dart';
import 'package:ecosafra/features/auth/presentation/guards/auth_guards.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/location/location_picker_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/location/location_picker_page.dart';
import 'package:ecosafra/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_alert.dart';
import 'package:ecosafra/features/schedule/domain/usecases/watch_schedules.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_cubit.dart';
import 'package:ecosafra/features/schedule/schedule_data_module.dart';
import 'package:ecosafra/features/weather/domain/usecases/choose_place.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_location_description.dart';
import 'package:ecosafra/features/weather/domain/usecases/search_places.dart';
import 'package:ecosafra/features/weather/domain/usecases/use_device_location.dart';
import 'package:ecosafra/features/weather/weather_module.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Módulo do painel principal.
///
/// `imports` traz os binds do `WeatherModule` (use cases de clima e
/// localização) pra dentro deste escopo, sem duplicar a fiação de
/// Dio/banco local que já vive lá. `DashboardCubit` é bind DESTE módulo —
/// diferente do `AuthCubit`, não precisa sobreviver a navegar pra fora
/// daqui, então é descartado junto com a rota, e a próxima visita ao
/// painel busca a previsão de novo.
class DashboardModule extends Module {
  @override
  List<Module> imports() => [WeatherModule(), ScheduleDataModule()];

  @override
  void binds(Injector i) {
    i
      ..addSingleton<DashboardCubit>(
        (i) => DashboardCubit(
          getCurrentLocation: i.get<GetCurrentLocation>(),
          getForecast: i.get<GetForecast>(),
          evaluateApplicationSafety: i.get<EvaluateApplicationSafety>(),
          getLocationDescription: i.get<GetLocationDescription>(),
        ),
      )
      // Dependências resolvidas aqui, na criação: o `ScheduleDataModule`
      // também é importado pela Agenda, e o cubit não pode depender de um
      // `get` tardio depois que a Agenda for descartada.
      ..addSingleton<ScheduleAlertCubit>(
        (i) => ScheduleAlertCubit(
          watchSchedules: i.get<WatchSchedules>(),
          evaluateScheduleAlert: i.get<EvaluateScheduleAlert>(),
          clock: i.get<Clock>(),
        ),
      )
      // Fábrica: a tela de escolha fecha o cubit ao sair, e o módulo do
      // painel continua vivo para a próxima visita.
      ..addFactory<LocationPickerCubit>(
        (i) => LocationPickerCubit(
          searchPlaces: i.get<SearchPlaces>(),
          choosePlace: i.get<ChoosePlace>(),
          useDeviceLocation: i.get<UseDeviceLocation>(),
        ),
      );
  }

  @override
  List<ModularRoute> get routes => [
    ChildRoute(
      '/',
      name: AppRoute.dashboard.name,
      transition: AppTransitions.fadeThrough,
      guards: const [RequireAuthGuard()],
      child: (context, state) => const DashboardPage(),
    ),
    ChildRoute(
      AppRoute.location.path,
      name: AppRoute.location.name,
      transition: AppTransitions.slideFromRight,
      guards: const [RequireAuthGuard()],
      child: (context, state) => const LocationPickerPage(),
    ),
  ];
}
