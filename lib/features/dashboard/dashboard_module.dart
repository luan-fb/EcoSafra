import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/app/router/page_transitions.dart';
import 'package:ecosafra/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Módulo do painel principal.
///
/// TODO(dashboard): ao integrar a Open-Meteo, este módulo passa a `import`ar
/// o `WeatherModule` (para reusar seus use cases) e registrar seu próprio
/// `DashboardCubit`, que os combina.
class DashboardModule extends Module {
  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          name: AppRoute.dashboard.name,
          transition: AppTransitions.fadeThrough,
          child: (context, state) => const DashboardPage(),
        ),
      ];
}
