import 'dart:async';

import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Protege uma rota que exige sessão (o painel). Sem isso, digitar `/painel`
/// na URL (ou reabrir o app com a rota salva) mostraria a tela por um
/// instante mesmo deslogado.
class RequireAuthGuard extends RouteGuard {
  const RequireAuthGuard();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated =
        Modular.get<AuthCubit>().state.status == AuthStatus.authenticated;
    return isAuthenticated ? null : AppRoute.signIn.path;
  }
}

/// Inverso: impede quem já está logado de ver a tela de login de novo (ex.:
/// voltou pro app depois de já ter entrado).
class RedirectIfAuthenticatedGuard extends RouteGuard {
  const RedirectIfAuthenticatedGuard();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated =
        Modular.get<AuthCubit>().state.status == AuthStatus.authenticated;
    return isAuthenticated ? AppRoute.dashboard.path : null;
  }
}
