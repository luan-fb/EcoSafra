import 'package:bloc_test/bloc_test.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_alert.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_banner.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_state.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockScheduleAlertCubit extends MockCubit<ScheduleAlertState>
    implements ScheduleAlertCubit {}

void main() {
  late MockScheduleAlertCubit cubit;

  setUp(() {
    cubit = MockScheduleAlertCubit();
  });

  void stubState(ScheduleAlertState state) {
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, Stream.value(state), initialState: state);
  }

  /// Liga "Remover animações" do jeito que o sistema faz, como o teste da
  /// animação de clima (`weather_animation_view_test.dart`).
  void disableAnimations(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  Future<void> pumpBanner(WidgetTester tester, {required VoidCallback onTap}) {
    return tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<ScheduleAlertCubit>.value(
            value: cubit,
            child: ScheduleAlertBanner(onTap: onTap),
          ),
        ),
      ),
    );
  }

  testWidgets('AGD-15: risco com contagem 1 usa o singular', (tester) async {
    stubState(const ScheduleAlertState(alert: ScheduleRiskAlert(1)));
    await pumpBanner(tester, onTap: () {});
    await tester.pumpAndSettle();

    expect(
      find.text('1 aplicação planejada em dia de chuva forte'),
      findsOneWidget,
    );
  });

  testWidgets('AGD-15: risco com contagem 3 usa o plural', (tester) async {
    stubState(const ScheduleAlertState(alert: ScheduleRiskAlert(3)));
    await pumpBanner(tester, onTap: () {});
    await tester.pumpAndSettle();

    expect(
      find.text('3 aplicações planejadas em dias de chuva forte'),
      findsOneWidget,
    );
  });

  testWidgets('AGD-16: lembrete de aplicação para hoje', (tester) async {
    stubState(const ScheduleAlertState(alert: ScheduleTodayReminder()));
    await pumpBanner(tester, onTap: () {});
    await tester.pumpAndSettle();

    expect(
      find.text('Aplicação de adubo planejada para hoje'),
      findsOneWidget,
    );
  });

  testWidgets('AGD-17: lembrete de aplicação para amanhã', (tester) async {
    stubState(const ScheduleAlertState(alert: ScheduleTomorrowReminder()));
    await pumpBanner(tester, onTap: () {});
    await tester.pumpAndSettle();

    expect(
      find.text('Aplicação de adubo planejada para amanhã'),
      findsOneWidget,
    );
  });

  testWidgets('AGD-18: sem alerta, o banner não ocupa espaço', (
    tester,
  ) async {
    stubState(const ScheduleAlertState());
    await pumpBanner(tester, onTap: () {});
    await tester.pumpAndSettle();

    expect(find.byType(ScheduleAlertBanner), findsOneWidget);
    expect(tester.getSize(find.byType(ScheduleAlertBanner)).height, 0);
  });

  testWidgets('AGD-19: tocar no aviso chama onTap', (tester) async {
    stubState(const ScheduleAlertState(alert: ScheduleRiskAlert(1)));
    var tapped = false;
    await pumpBanner(tester, onTap: () => tapped = true);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ScheduleAlertBanner));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets(
    'AGD-19: alvo de toque tem ao menos 48 de altura e semântica de botão '
    'com o texto do aviso',
    (tester) async {
      stubState(const ScheduleAlertState(alert: ScheduleTodayReminder()));
      final semantics = tester.ensureSemantics();
      await pumpBanner(tester, onTap: () {});
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(ScheduleAlertBanner)).height,
        greaterThanOrEqualTo(48),
      );

      final node = tester.getSemantics(
        find.bySemanticsLabel('Aplicação de adubo planejada para hoje'),
      );
      expect(node.flagsCollection.isButton, isTrue);

      semantics.dispose();
    },
  );

  testWidgets(
    'com "remover animações" a troca de nada para um aviso acontece sem '
    'animação',
    (tester) async {
      disableAnimations(tester);
      const empty = ScheduleAlertState();
      const withReminder = ScheduleAlertState(alert: ScheduleTodayReminder());
      when(() => cubit.state).thenReturn(empty);
      whenListen(
        cubit,
        Stream.fromIterable([empty, withReminder]),
        initialState: empty,
      );
      await pumpBanner(tester, onTap: () {});

      // Sem `AnimatedSize` no caminho de "remover animações": um único
      // `pump` (sem `pumpAndSettle`) já mostra o aviso, prova de que não há
      // transição em andamento.
      await tester.pump();
      expect(find.byType(AnimatedSize), findsNothing);
      expect(
        find.text('Aplicação de adubo planejada para hoje'),
        findsOneWidget,
      );
    },
  );
}
