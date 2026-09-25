import 'package:bloc_test/bloc_test.dart';
import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/features/dashboard/presentation/location/location_picker_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/location/location_picker_page.dart';
import 'package:ecosafra/features/dashboard/presentation/location/location_picker_state.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationPickerCubit extends MockCubit<LocationPickerState>
    implements LocationPickerCubit {}

void main() {
  const cuiaba = Place(
    name: 'Cuiabá',
    region: 'Mato Grosso',
    country: 'Brasil',
    coordinates: Coordinates(latitude: -15.6, longitude: -56.1),
  );
  const semRegiao = Place(
    name: 'Brasília',
    country: 'Brasil',
    coordinates: Coordinates(latitude: -15.78, longitude: -47.93),
  );
  const soNome = Place(
    name: 'Lugarejo',
    coordinates: Coordinates(latitude: -10, longitude: -50),
  );

  setUpAll(() {
    registerFallbackValue(cuiaba);
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockLocationPickerCubit cubit;

  setUp(() {
    cubit = MockLocationPickerCubit();
    when(() => cubit.choose(any())).thenAnswer((_) async => true);
    when(() => cubit.useDevice()).thenAnswer((_) async => true);
  });

  void stubState(LocationPickerState state) {
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, Stream.value(state), initialState: state);
  }

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<LocationPickerCubit>.value(
          value: cubit,
          child: const LocationPickerView(),
        ),
      ),
    );
    await tester.pump();
  }

  /// Painel falso que abre a escolha pelo nome da rota e guarda o que ela
  /// devolveu no `pop`.
  Future<List<Object?>> pumpWithRouter(WidgetTester tester) async {
    final results = <Object?>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () async => results.add(
                await context.pushNamed<bool>(AppRoute.location.name),
              ),
              child: const Text('abrir-escolha'),
            ),
          ),
          routes: [
            GoRoute(
              path: AppRoute.location.path.substring(1),
              name: AppRoute.location.name,
              builder: (_, _) => BlocProvider<LocationPickerCubit>.value(
                value: cubit,
                child: const LocationPickerView(),
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
    await tester.tap(find.text('abrir-escolha'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('mostra título, campo de busca e a opção do aparelho', (
    tester,
  ) async {
    stubState(const LocationPickerState.idle());
    await pumpPage(tester);

    expect(find.text('Localização do talhão'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Buscar cidade'),
      findsOneWidget,
    );
    expect(find.text('Usar a localização do aparelho'), findsOneWidget);
    expect(find.byIcon(Icons.place_rounded), findsNothing);
  });

  testWidgets('digitar repassa o texto ao cubit', (tester) async {
    stubState(const LocationPickerState.idle());
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'Cuiabá');

    verify(() => cubit.queryChanged('Cuiabá')).called(1);
  });

  testWidgets('buscando mostra o indicador de carregamento', (tester) async {
    stubState(const LocationPickerState.searching());
    await pumpPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'LOCM-01: lista os lugares como "Nome, Estado, País", sem as partes '
    'ausentes',
    (tester) async {
      stubState(
        const LocationPickerState.results([cuiaba, semRegiao, soNome]),
      );
      await pumpPage(tester);

      expect(find.text('Cuiabá, Mato Grosso, Brasil'), findsOneWidget);
      expect(find.text('Brasília, Brasil'), findsOneWidget);
      expect(find.text('Lugarejo'), findsOneWidget);
    },
  );

  testWidgets('LOCM-06: sem lugares mostra "Nenhum lugar encontrado."', (
    tester,
  ) async {
    stubState(const LocationPickerState.empty());
    await pumpPage(tester);

    expect(find.text('Nenhum lugar encontrado.'), findsOneWidget);
  });

  testWidgets('LOCM-05: busca sem rede mostra a mensagem da spec', (
    tester,
  ) async {
    stubState(const LocationPickerState.failure(NetworkFailure()));
    await pumpPage(tester);

    expect(
      find.text(
        'Sem internet para buscar lugares. Tente de novo quando tiver sinal.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('outra falha mostra a mensagem da própria falha', (
    tester,
  ) async {
    stubState(const LocationPickerState.failure(ServerFailure()));
    await pumpPage(tester);

    expect(
      find.text('Não conseguimos falar com o serviço de clima.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'LOCM-02: escolher um lugar grava e volta ao painel com true',
    (tester) async {
      stubState(const LocationPickerState.results([cuiaba]));
      final results = await pumpWithRouter(tester);

      await tester.tap(find.text('Cuiabá, Mato Grosso, Brasil'));
      await tester.pumpAndSettle();

      verify(() => cubit.choose(cuiaba)).called(1);
      expect(find.text('abrir-escolha'), findsOneWidget);
      expect(find.text('Localização do talhão'), findsNothing);
      expect(results, [true]);
    },
  );

  testWidgets(
    'LOCM-04: usar a localização do aparelho volta ao painel com true',
    (tester) async {
      stubState(const LocationPickerState.idle());
      final results = await pumpWithRouter(tester);

      await tester.tap(find.text('Usar a localização do aparelho'));
      await tester.pumpAndSettle();

      verify(() => cubit.useDevice()).called(1);
      expect(results, [true]);
    },
  );

  testWidgets('se a escolha não foi gravada, continua na tela', (
    tester,
  ) async {
    when(() => cubit.choose(any())).thenAnswer((_) async => false);
    stubState(const LocationPickerState.results([cuiaba]));
    final results = await pumpWithRouter(tester);

    await tester.tap(find.text('Cuiabá, Mato Grosso, Brasil'));
    await tester.pumpAndSettle();

    expect(find.text('Localização do talhão'), findsOneWidget);
    expect(results, isEmpty);
  });
}
