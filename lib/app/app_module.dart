import 'package:clock/clock.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/core/network/api_constants.dart';
import 'package:ecosafra/core/network/interceptors/error_interceptor.dart';
import 'package:ecosafra/core/network/network_info.dart';
import 'package:ecosafra/features/auth/auth_module.dart';
import 'package:ecosafra/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecosafra/features/auth/data/datasources/google_firebase_auth_data_source.dart';
import 'package:ecosafra/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecosafra/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecosafra/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:ecosafra/features/auth/domain/usecases/sign_out.dart';
import 'package:ecosafra/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecosafra/features/dashboard/dashboard_module.dart';
import 'package:ecosafra/features/splash/splash_module.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router_modular/go_router_modular.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
      // Uma conexão só com o SQLite local pro app inteiro — é o mesmo
      // motivo do Room recomendar um único `RoomDatabase` por processo.
      ..addSingleton<AppDatabase>((i) => AppDatabase())
      ..addSingleton<FirebaseAuth>((i) => FirebaseAuth.instance)
      ..addSingleton<GoogleSignIn>((i) => GoogleSignIn.instance)
      // Relógio e gerador de id injetáveis: em produção, a hora do aparelho
      // e UUID v4; nos testes, `Clock.fixed(...)` e um `Uuid` falso deixam
      // "hoje", "amanhã" e os ids previsíveis.
      ..addSingleton<Clock>((i) => const Clock())
      ..addSingleton<Uuid>((i) => const Uuid())
      ..addSingleton<NetworkInfo>(
        (i) => ConnectivityNetworkInfo(Connectivity()),
      )
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
      )
      // --- Sessão (auth) ---
      // Vive aqui, e não no AuthModule, porque splash, login, painel e os
      // RouteGuards precisam do mesmo AuthCubit — um bind de feature seria
      // descartado ao sair da rota de login, exatamente quando o painel
      // mais precisa dele.
      ..addSingleton<AuthRemoteDataSource>(
        (i) => GoogleFirebaseAuthDataSource(
          firebaseAuth: i.get<FirebaseAuth>(),
          googleSignIn: i.get<GoogleSignIn>(),
        ),
      )
      ..addSingleton<AuthRepository>(
        (i) => AuthRepositoryImpl(i.get<AuthRemoteDataSource>()),
      )
      ..addSingleton<SignInWithGoogle>(
        (i) => SignInWithGoogle(i.get<AuthRepository>()),
      )
      ..addSingleton<SignOut>((i) => SignOut(i.get<AuthRepository>()))
      ..addSingleton<WatchAuthState>(
        (i) => WatchAuthState(i.get<AuthRepository>()),
      )
      ..addSingleton<AuthCubit>(
        (i) => AuthCubit(
          watchAuthState: i.get<WatchAuthState>(),
          signInWithGoogle: i.get<SignInWithGoogle>(),
          signOut: i.get<SignOut>(),
        ),
      );
  }

  @override
  List<ModularRoute> get routes => [
        ModuleRoute(AppRoute.splash.path, module: SplashModule()),
        ModuleRoute(AppRoute.signIn.path, module: AuthModule()),
        ModuleRoute(AppRoute.dashboard.path, module: DashboardModule()),
      ];
}
