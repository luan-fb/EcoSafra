import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:ecosafra/app/app_module.dart';
import 'package:ecosafra/app/observers/app_bloc_observer.dart';
import 'package:ecosafra/app/router/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router_modular/go_router_modular.dart';

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

      // TODO(firebase): descomentar depois de rodar `flutterfire configure`.
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );

      // Monta o grafo de rotas + binds do AppModule (e, em cascata, dos
      // módulos de feature). Substitui o antigo `configureDependencies()`:
      // aqui, rotas e injeção de dependência nascem juntas.
      await Modular.configure(
        appModule: AppModule(),
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
