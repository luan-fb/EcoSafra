import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_state.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:ecosafra/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_alert.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_state.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/fertilizer_advice.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

class MockScheduleAlertCubit extends MockCubit<ScheduleAlertState>
    implements ScheduleAlertCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  setUpAll(() {
    // `any()` como argumento de `updateForecast` (no teste "ainda não
    // chama") exige um valor de referência para o tipo, mesmo sem usá-lo.
    registerFallbackValue(
      WeatherForecast(
        coordinates: const Coordinates(latitude: 0, longitude: 0),
        hourly: const [],
        daily: const [],
        fetchedAt: DateTime(2000),
      ),
    );
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockDashboardCubit dashboardCubit;
  late MockScheduleAlertCubit scheduleAlertCubit;
  late MockAuthCubit authCubit;

  // `ForecastSection` lê `hourlyFrom(now).first`/`dayOf(now) ?? daily.first`
  // (sem guarda de lista vazia — fora do escopo desta task): o único teste
  // que chega a `loaded` fixa o relógio na hora deste ponto horário, para o
  // painel não quebrar.
  final forecast = WeatherForecast(
    coordinates: const Coordinates(latitude: -23.5, longitude: -46.6),
    hourly: [
      HourlyForecastPoint(
        time: DateTime(2026, 9, 24, 10),
        precipitation: 0,
        precipitationProbability: 0,
        temperature: 22,
        relativeHumidity: 60,
        windSpeed: 10,
      ),
    ],
    daily: [
      DailyForecastPoint(
        date: DateTime(2026, 9, 24),
        precipitationSum: 0,
        precipitationProbabilityMax: 0,
        temperatureMax: 28,
        temperatureMin: 18,
        windSpeedMax: 10,
        weatherCode: 0,
      ),
    ],
    fetchedAt: DateTime(2026, 9, 24),
  );
  const advice = FertilizerAdvice(
    level: AdviceLevel.safe,
    rainNext24h: 0,
    rainNext48h: 0,
  );

  setUp(() {
    dashboardCubit = MockDashboardCubit();
    scheduleAlertCubit = MockScheduleAlertCubit();
    authCubit = MockAuthCubit();

    // Sem sessão: `DashboardView` cai no nome padrão, sem depender de mais
    // nenhum detalhe de `AppUser` para estes cenários.
    when(() => authCubit.state).thenReturn(const AuthState.unauthenticated());
  });

  void stubDashboard(DashboardState state) {
    when(() => dashboardCubit.state).thenReturn(state);
    whenListen(dashboardCubit, Stream.value(state), initialState: state);
  }

  void stubScheduleAlert(ScheduleAlertState state) {
    when(() => scheduleAlertCubit.state).thenReturn(state);
    whenListen(scheduleAlertCubit, Stream.value(state), initialState: state);
  }

  Future<void> pumpDashboard(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<DashboardCubit>.value(value: dashboardCubit),
            BlocProvider<ScheduleAlertCubit>.value(value: scheduleAlertCubit),
          ],
          child: const DashboardView(),
        ),
      ),
    );
  }

  testWidgets(
    'quando o painel termina de carregar, avisa o '
    'ScheduleAlertCubit com a previsão exata',
    (tester) async {
      stubScheduleAlert(const ScheduleAlertState());
      const loading = DashboardState.loading();
      final loaded = DashboardState.loaded(forecast, advice);
      when(() => dashboardCubit.state).thenReturn(loading);
      whenListen(
        dashboardCubit,
        Stream.fromIterable([loading, loaded]),
        initialState: loading,
      );

      // Relógio fixo na hora do único ponto horário de `forecast`: sem
      // isto, `ForecastSection` buscaria a hora real, fora da cobertura da
      // previsão de teste.
      await withClock(Clock.fixed(DateTime(2026, 9, 24, 10)), () async {
        await pumpDashboard(tester);
        // Um `pump` primeiro entrega a emissão `loaded` do stream e monta
        // `ForecastSection` (é aí que os timers do `FadeSlideIn` nascem);
        // só depois um `pump` com duração deixa esses timers escalonados
        // dispararem — na ordem inversa, o `elapse` aconteceria antes dos
        // timers existirem, e o teste terminaria com timer pendente.
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
      });

      verify(() => scheduleAlertCubit.updateForecast(forecast)).called(1);
    },
  );

  testWidgets(
    'enquanto carrega, ainda não chama updateForecast',
    (tester) async {
      stubDashboard(const DashboardState.loading());
      stubScheduleAlert(const ScheduleAlertState());

      await pumpDashboard(tester);
      await tester.pump();

      verifyNever(() => scheduleAlertCubit.updateForecast(any()));
    },
  );

  testWidgets(
    'Edge case: o aviso aparece com o painel ainda carregando a previsão',
    (tester) async {
      stubDashboard(const DashboardState.loading());
      stubScheduleAlert(
        const ScheduleAlertState(alert: ScheduleTodayReminder()),
      );

      await pumpDashboard(tester);
      await tester.pump();

      expect(
        find.text('Aplicação de adubo planejada para hoje'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'voltar ao app recalcula o aviso da agenda (virada do dia)',
    (tester) async {
      stubDashboard(const DashboardState.loading());
      stubScheduleAlert(const ScheduleAlertState());
      await pumpDashboard(tester);

      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
      verifyNever(() => scheduleAlertCubit.refresh());

      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      verify(() => scheduleAlertCubit.refresh()).called(1);
    },
  );

  testWidgets('tocar no aviso abre a Agenda', (tester) async {
    stubDashboard(const DashboardState.loading());
    stubScheduleAlert(
      const ScheduleAlertState(alert: ScheduleTodayReminder()),
    );
    // Roteador real com a rota da Agenda pelo mesmo nome do app: prova o
    // destino da navegação, e não só que o callback do banner foi chamado.
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>.value(value: authCubit),
              BlocProvider<DashboardCubit>.value(value: dashboardCubit),
              BlocProvider<ScheduleAlertCubit>.value(
                value: scheduleAlertCubit,
              ),
            ],
            child: const DashboardView(),
          ),
        ),
        GoRoute(
          path: AppRoute.schedule.path,
          name: AppRoute.schedule.name,
          builder: (_, _) => const Text('agenda-aberta'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Aplicação de adubo planejada para hoje'));
    await tester.pumpAndSettle();

    expect(find.text('agenda-aberta'), findsOneWidget);
  });

  group('localização no cabeçalho', () {
    const device = LocationDescription(
      label: 'Cuiabá, Mato Grosso',
      source: LocationSource.device,
    );
    const chosen = LocationDescription(
      label: 'Campinas, São Paulo',
      source: LocationSource.chosen,
    );

    /// Hora do único ponto horário de `forecast`: a `ForecastSection`
    /// precisa dela para montar o card "Agora".
    final forecastHour = Clock.fixed(DateTime(2026, 9, 24, 10));

    /// Painel num `GoRouter` real, com a escolha de localização como rota
    /// filha pelo mesmo nome do app. A escolha falsa volta com [pickerResult].
    Future<void> pumpWithRouter(
      WidgetTester tester, {
      bool? pickerResult,
    }) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthCubit>.value(value: authCubit),
                BlocProvider<DashboardCubit>.value(value: dashboardCubit),
                BlocProvider<ScheduleAlertCubit>.value(
                  value: scheduleAlertCubit,
                ),
              ],
              child: const DashboardView(),
            ),
            routes: [
              GoRoute(
                path: AppRoute.location.path.substring(1),
                name: AppRoute.location.name,
                builder: (context, _) => Scaffold(
                  body: TextButton(
                    onPressed: () => context.pop(pickerResult),
                    child: const Text('escolha-aberta'),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.pump();
      // Deixa terminar as entradas escalonadas da `ForecastSection`.
      await tester.pump(const Duration(seconds: 2));
    }

    /// O painel com previsão tem animação de clima em laço: `pumpAndSettle`
    /// nunca terminaria. Um segundo cobre a transição de rota.
    Future<void> settleRoute(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    setUp(() {
      stubScheduleAlert(const ScheduleAlertState());
      when(() => dashboardCubit.loadForecast()).thenAnswer((_) async {});
    });

    testWidgets(
      'LOCV-01/02: localização do GPS mostra o nome com o ícone do aparelho',
      (tester) async {
        stubDashboard(
          DashboardState.loaded(forecast, advice, location: device),
        );

        await withClock(forecastHour, () => pumpWithRouter(tester));

        expect(find.text('Cuiabá, Mato Grosso'), findsOneWidget);
        expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
        expect(find.byIcon(Icons.place_rounded), findsNothing);
      },
    );

    testWidgets(
      'LOCV-04: localização escolhida mostra o nome com o alfinete',
      (tester) async {
        stubDashboard(
          DashboardState.loaded(forecast, advice, location: chosen),
        );

        await withClock(forecastHour, () => pumpWithRouter(tester));

        expect(find.text('Campinas, São Paulo'), findsOneWidget);
        expect(find.byIcon(Icons.place_rounded), findsOneWidget);
        expect(find.byIcon(Icons.my_location_rounded), findsNothing);
      },
    );

    testWidgets('sem o nome do lugar ainda, o cabeçalho não mostra nada', (
      tester,
    ) async {
      stubDashboard(DashboardState.loaded(forecast, advice));

      await withClock(forecastHour, () => pumpWithRouter(tester));

      expect(find.byIcon(Icons.place_rounded), findsNothing);
      expect(find.byIcon(Icons.my_location_rounded), findsNothing);
    });

    testWidgets(
      'LOCV-05/LOCM-02: tocar abre a escolha, e voltar com true recarrega',
      (tester) async {
        stubDashboard(
          DashboardState.loaded(forecast, advice, location: device),
        );

        await withClock(forecastHour, () async {
          await pumpWithRouter(tester, pickerResult: true);

          await tester.tap(find.text('Cuiabá, Mato Grosso'));
          await settleRoute(tester);
          expect(find.text('escolha-aberta'), findsOneWidget);
          verifyNever(() => dashboardCubit.loadForecast());

          await tester.tap(find.text('escolha-aberta'));
          await settleRoute(tester);
        });

        expect(find.text('escolha-aberta'), findsNothing);
        verify(() => dashboardCubit.loadForecast()).called(1);
      },
    );

    testWidgets('voltar da escolha sem gravar não recarrega', (tester) async {
      stubDashboard(DashboardState.loaded(forecast, advice, location: device));

      await withClock(forecastHour, () async {
        await pumpWithRouter(tester);

        await tester.tap(find.text('Cuiabá, Mato Grosso'));
        await settleRoute(tester);
        await tester.tap(find.text('escolha-aberta'));
        await settleRoute(tester);
      });

      verifyNever(() => dashboardCubit.loadForecast());
    });
  });
}
