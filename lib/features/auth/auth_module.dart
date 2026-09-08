import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/app/router/page_transitions.dart';
import 'package:ecosafra/features/auth/presentation/pages/sign_in_page.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Módulo de autenticação.
///
/// TODO(auth): quando a camada domain/data existir, registrar aqui (nesta
/// ordem, de dentro para fora): `GoogleSignInDataSource`, `AuthRepository`,
/// os use cases (`SignInWithGoogle`, `SignOut`, `WatchAuthState`) e por fim
/// o `AuthCubit`. Todos ficam vivos só enquanto o usuário está nesta rota —
/// o go_router_modular descarta o módulo (e chama `dispose()` no Cubit)
/// automaticamente ao navegar para fora daqui.
class AuthModule extends Module {
  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          name: AppRoute.signIn.name,
          transition: AppTransitions.fadeThrough,
          child: (context, state) => const SignInPage(),
        ),
      ];
}
