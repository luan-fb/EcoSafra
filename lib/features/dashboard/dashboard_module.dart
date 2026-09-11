import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/app/router/page_transitions.dart';
import 'package:ecosafra/features/auth/presentation/guards/auth_guards.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
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
  List<Module> imports() => [WeatherModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<DashboardCubit>(
      (i) => DashboardCubit(
        getCurrentLocation: i.get<GetCurrentLocation>(),
        getForecast: i.get<GetForecast>(),
        evaluateApplicationSafety: i.get<EvaluateApplicationSafety>(),
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
      ];
}
