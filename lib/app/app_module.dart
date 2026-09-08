import 'package:dio/dio.dart';
import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/core/network/api_constants.dart';
import 'package:ecosafra/core/network/interceptors/error_interceptor.dart';
import 'package:ecosafra/features/auth/auth_module.dart';
import 'package:ecosafra/features/dashboard/dashboard_module.dart';
import 'package:ecosafra/features/splash/splash_module.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router_modular/go_router_modular.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Módulo raiz: composição da árvore de rotas e dos serviços de app inteiro.
///
/// Diferente dos módulos de feature, o `AppModule` nunca é descartado — ele é
/// registrado uma vez em `Modular.configure` e vive o app inteiro. Por isso é
/// o lugar certo para dependências verdadeiramente globais (cliente HTTP,
/// Firebase, preferências locais). Uma feature pega qualquer uma delas com
/// `Modular.get<T>()` sem precisar declará-la de novo.
class AppModule extends Module {
  @override
  Future<void> binds(Injector i) async {
    // `binds` aceita `Future`: o app só termina de configurar depois que o
    // SharedPreferences (que é assíncrono) estiver pronto.
    final sharedPreferences = await SharedPreferences.getInstance();

    i
      ..addSingleton<SharedPreferences>((i) => sharedPreferences)
      ..addSingleton<FirebaseAuth>((i) => FirebaseAuth.instance)
      ..addSingleton<Dio>(
        (i) => Dio(
          BaseOptions(
            baseUrl: ApiConstants.forecastBaseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            responseType: ResponseType.json,
            headers: const {'Accept': 'application/json'},
          ),
        )..interceptors.addAll([
            ErrorInterceptor(),
            // Log verboso só em debug: em release ele vazaria dados e
            // custaria performance.
            if (kDebugMode)
              PrettyDioLogger(
                requestHeader: true,
                requestBody: true,
                compact: true,
              ),
          ]),
        key: ApiConstants.openMeteoDioKey,
      );
  }

  @override
  List<ModularRoute> get routes => [
        ModuleRoute(AppRoute.splash.path, module: SplashModule()),
        ModuleRoute(AppRoute.signIn.path, module: AuthModule()),
        ModuleRoute(AppRoute.dashboard.path, module: DashboardModule()),
      ];
}
