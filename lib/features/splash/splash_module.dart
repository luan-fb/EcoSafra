import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/features/splash/presentation/pages/splash_page.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Módulo da tela de abertura.
///
/// Sem binds próprios ainda: a splash só decide para onde navegar. Quando
/// existir um `AuthCubit` global, ele vai morar no `AppModule` (é estado de
/// sessão, não desta feature) e a splash só vai lê-lo.
class SplashModule extends Module {
  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          name: AppRoute.splash.name,
          child: (context, state) => const SplashPage(),
        ),
      ];
}
