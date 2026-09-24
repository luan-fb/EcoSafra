import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_date_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final date = DateTime(2026, 9, 23);

  /// Liga "Remover animações" do jeito que o sistema faz, como
  /// `schedule_alert_banner_test.dart`.
  void disableAnimations(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  Future<void> pumpBlock(WidgetTester tester, {bool pulse = false}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ScheduleDateBlock(
            date: date,
            background: AppColors.danger,
            foreground: Colors.white,
            pulse: pulse,
          ),
        ),
      ),
    );
  }

  double scaleOf(WidgetTester tester) => tester
      .widget<Transform>(
        find.descendant(
          of: find.byType(ScheduleDateBlock),
          matching: find.byType(Transform),
        ),
      )
      .transform
      .getMaxScaleOnAxis();

  testWidgets('SCHEDUI-05: mostra dia e mês abreviado maiúsculos sem ponto', (
    tester,
  ) async {
    await pumpBlock(tester);

    expect(find.text('23'), findsOneWidget);
    expect(find.text('SET'), findsOneWidget);
  });

  testWidgets('SCHEDUI-20: pulse true anima a escala em loop', (
    tester,
  ) async {
    await pumpBlock(tester, pulse: true);

    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
    final scale1 = scaleOf(tester);

    await tester.pump(const Duration(milliseconds: 300));
    final scale2 = scaleOf(tester);

    expect(scale1, isNot(equals(scale2)));

    // Destrói a árvore para interromper o loop e terminar o teste limpo.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('SCHEDUI-20: pulse false não anima', (tester) async {
    await pumpBlock(tester);

    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.hasRunningAnimations, isFalse);
    expect(scaleOf(tester), 1.0);
  });

  testWidgets('SCHEDUI-21: redução de movimento desliga o pulso', (
    tester,
  ) async {
    disableAnimations(tester);
    await pumpBlock(tester, pulse: true);

    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.hasRunningAnimations, isFalse);
    expect(scaleOf(tester), 1.0);
  });
}
