import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/app/router/page_transitions.dart';
import 'package:ecosafra/features/auth/presentation/guards/auth_guards.dart';
import 'package:ecosafra/features/auth/presentation/pages/sign_in_page.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Módulo de autenticação.
///
/// Sem binds próprios: `AuthCubit` e toda a cadeia de DI da sessão vivem no
/// `AppModule` (ver o comentário lá) — este módulo só declara a tela e o
/// guard que impede quem já está logado de vê-la de novo.
class AuthModule extends Module {
  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          name: AppRoute.signIn.name,
          transition: AppTransitions.fadeThrough,
          guards: const [RedirectIfAuthenticatedGuard()],
          child: (context, state) => const SignInPage(),
        ),
      ];
}
