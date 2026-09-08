import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
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
    // TODO(state): quando o AuthCubit existir, prover aqui via
    // BlocProvider.value(value: Modular.get<AuthCubit>(), child: ...) —
    // Cubits de sessão vivem no AppModule; os de tela, no módulo da feature.
    return ModularApp.router(
      title: 'EcoSafra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
