import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_state.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Widget raiz.
///
/// `ModularApp.router` é o `MaterialApp.router` do go_router_modular: aceita
/// os mesmos parâmetros de tema/localização e por baixo já aponta para o
/// `GoRouter` montado em `Modular.configure` (chamado no `bootstrap`).
class EcoSafraApp extends StatelessWidget {
  const EcoSafraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // `AuthCubit` é bind de app (ver AppModule) — provê-lo aqui, uma vez, no
    // topo da árvore, é o que deixa `context.read<AuthCubit>()` funcionar em
    // qualquer tela sem cada uma precisar ir buscá-lo no container.
    return BlocProvider.value(
      value: Modular.get<AuthCubit>(),
      child: BlocListener<AuthCubit, AuthState>(
        // Só reage a mudança de *status* — não a cada rebuild com
        // isSigningIn/failure diferentes, que as próprias telas já tratam.
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _onAuthStatusChanged,
        child: ModularApp.router(
          title: 'EcoSafra',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          locale: const Locale('pt'),
          // Deriva da lista de .arb em lib/l10n — cadastrar um novo idioma lá
          // já basta, não precisa lembrar de repetir a lista aqui.
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }

  /// Reage a mudanças de sessão que não vieram de uma navegação explícita —
  /// por exemplo, um logout dado a partir do painel, ou uma sessão revogada
  /// remotamente. A ida da splash pro login/painel na abertura do app **não**
  /// passa por aqui: aquela é a primeira determinação de rota, feita pela
  /// própria `SplashPage`; este listener só cobre transições *depois* disso.
  void _onAuthStatusChanged(BuildContext context, AuthState state) {
    switch (state.status) {
      case AuthStatus.authenticated:
        Modular.routerConfig.goNamed(AppRoute.dashboard.name);
      case AuthStatus.unauthenticated:
        Modular.routerConfig.goNamed(AppRoute.signIn.name);
      case AuthStatus.initial:
        break;
    }
  }
}
