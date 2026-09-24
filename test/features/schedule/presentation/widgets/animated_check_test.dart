import 'dart:ui' show CheckedState;

import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/animated_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Liga "Remover animações" do jeito que o sistema faz, como
  /// `schedule_alert_banner_test.dart`.
  void disableAnimations(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  Future<void> pumpCheck(
    WidgetTester tester, {
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AnimatedCheck(value: value, onChanged: onChanged ?? (_) {}),
        ),
      ),
    );
  }

  /// O traço é desenhado por um `CustomPainter` privado: o campo público
  /// `progress` continua acessível via `dynamic`, mesmo com o tipo do
  /// painter fora do escopo deste arquivo.
  double progressOf(WidgetTester tester) {
    final painter = tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byType(AnimatedCheck),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter;
    return (painter! as dynamic).progress as double;
  }

  testWidgets('SCHEDUI-19: marcar anima o progresso de 0 a 1', (
    tester,
  ) async {
    await pumpCheck(tester, value: false);
    expect(progressOf(tester), 0);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: AnimatedCheck(value: true, onChanged: (_) {})),
      ),
    );

    await tester.pump(const Duration(milliseconds: 150));
    final midProgress = progressOf(tester);
    expect(midProgress, greaterThan(0));
    expect(midProgress, lessThan(1));

    await tester.pumpAndSettle();
    expect(progressOf(tester), 1);
  });

  testWidgets('SCHEDUI-19: desmarcar anima o progresso de volta a 0', (
    tester,
  ) async {
    await pumpCheck(tester, value: true);
    await tester.pumpAndSettle();
    expect(progressOf(tester), 1);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: AnimatedCheck(value: false, onChanged: (_) {})),
      ),
    );

    await tester.pump(const Duration(milliseconds: 150));
    final midProgress = progressOf(tester);
    expect(midProgress, greaterThan(0));
    expect(midProgress, lessThan(1));

    await tester.pumpAndSettle();
    expect(progressOf(tester), 0);
  });

  testWidgets(
    'SCHEDUI-21: com redução de movimento o valor muda direto, sem passo intermediário',
    (tester) async {
      disableAnimations(tester);
      await pumpCheck(tester, value: false);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: AnimatedCheck(value: true, onChanged: (_) {})),
        ),
      );
      await tester.pump();

      expect(progressOf(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    },
  );

  testWidgets('SCHEDUI-09: semântica expõe checked conforme o valor', (
    tester,
  ) async {
    await pumpCheck(tester, value: true);

    final semantics = tester.getSemantics(find.byType(AnimatedCheck));
    expect(semantics.flagsCollection.isChecked, CheckedState.isTrue);
  });

  testWidgets('SCHEDUI-09: alvo de toque tem pelo menos 48 x 48', (
    tester,
  ) async {
    await pumpCheck(tester, value: false);

    final size = tester.getSize(find.byType(AnimatedCheck));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('toque chama onChanged com o valor invertido', (tester) async {
    bool? changedTo;
    await pumpCheck(
      tester,
      value: false,
      onChanged: (value) => changedTo = value,
    );

    await tester.tap(find.byType(AnimatedCheck));
    expect(changedTo, isTrue);
  });

  testWidgets(
    'toque no marcado chama onChanged(false)',
    (tester) async {
      bool? changedTo;
      await pumpCheck(
        tester,
        value: true,
        onChanged: (value) => changedTo = value,
      );

      await tester.tap(find.byType(AnimatedCheck));
      expect(changedTo, isFalse);
    },
  );
}
