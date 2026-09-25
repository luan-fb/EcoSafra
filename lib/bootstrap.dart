import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:ecosafra/app/app_module.dart';
import 'package:ecosafra/app/observers/app_bloc_observer.dart';
import 'package:ecosafra/app/router/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router_modular/go_router_modular.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Tudo que precisa acontecer **antes** do primeiro frame.
///
/// Separar isto do `main.dart` deixa um único ponto de inicialização que pode
/// ser reaproveitado por outros entrypoints (`main_dev.dart`, testes de
/// integração) sem duplicar código.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // `runZonedGuarded` + estes dois handlers capturam 100% dos erros:
  // o primeiro pega erros do framework (build, layout, paint), o segundo
  // pega erros assíncronos que escapam da árvore de widgets.
  FlutterError.onError = (details) {
    developer.log(
      details.exceptionAsString(),
      name: 'FlutterError',
      stackTrace: details.stack,
    );
    // TODO(observability): FirebaseCrashlytics.instance.recordFlutterError.
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log('Erro fora da árvore', error: error, stackTrace: stack);
    return true;
  };

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Carrega os nomes de mês/dia da semana em português — sem isto,
      // `DateFormat.MMMEd('pt_BR')` (usado no painel) lança em runtime.
      await initializeDateFormatting('pt_BR');

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );

      // Sem `options:` de propósito: sem `firebase_options.dart` (isso só
      // existe depois de rodar `flutterfire configure`), o Firebase lê a
      // config direto do `google-services.json` nativo — funciona no
      // Android, mas ainda não cobre iOS/web/desktop.
      await Firebase.initializeApp();

      // `Modular.configure` registra os binds do AppModule sem esperar, e o
      // `binds` dele é assíncrono (SharedPreferences). No debug o registro
      // termina antes do primeiro frame por acaso; em profile e release o
      // `EcoSafraApp` pedia o `AuthCubit` antes e o app abria numa tela
      // cinza. Registrar aqui, esperando, faz o `configure` encontrar o
      // módulo já pronto.
      final appModule = AppModule();
      await InjectionManager.instance.registerAppModule(appModule);

      // Monta o grafo de rotas + binds do AppModule (e, em cascata, dos
      // módulos de feature). Substitui o antigo `configureDependencies()`:
      // aqui, rotas e injeção de dependência nascem juntas.
      await Modular.configure(
        appModule: appModule,
        initialRoute: AppRoute.splash.path,
        debugLogDiagnostics: kDebugMode,
      );

      if (kDebugMode) Bloc.observer = const AppBlocObserver();

      runApp(await builder());
    },
    (error, stack) => developer.log(
      'Erro não capturado',
      error: error,
      stackTrace: stack,
    ),
  );
}
