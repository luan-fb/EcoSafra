import 'dart:ui' as ui;
import 'dart:ui' show CheckedState;

import 'package:ecosafra/core/theme/app_motion.dart';
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

  /// Conta, entre os pixels renderizados pelo painter no progresso atual,
  /// quantos batem com [target] (o traço, pintado com `checkColor`). Chama o
  /// `paint` privado direto (mesma técnica de `progressOf`), sem depender do
  /// pipeline de renderização da árvore: só o resultado do desenho importa.
  Future<int> tracedPixelsOf(WidgetTester tester, Color target) async {
    final painter = tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byType(AnimatedCheck),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter;
    const side = AnimatedCheck.targetSize;
    final recorder = ui.PictureRecorder();
    (painter! as dynamic).paint(Canvas(recorder), const Size(side, side));
    final image = await recorder.endRecording().toImage(
      side.toInt(),
      side.toInt(),
    );
    final bytes = (await image.toByteData())!;
    final targetArgb = target.toARGB32();
    final targetR = (targetArgb >> 16) & 0xff;
    final targetG = (targetArgb >> 8) & 0xff;
    final targetB = targetArgb & 0xff;
    var count = 0;
    for (var i = 0; i < bytes.lengthInBytes; i += 4) {
      final r = bytes.getUint8(i);
      final g = bytes.getUint8(i + 1);
      final b = bytes.getUint8(i + 2);
      if ((r - targetR).abs() < 12 &&
          (g - targetG).abs() < 12 &&
          (b - targetB).abs() < 12) {
        count++;
      }
    }
    return count;
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
    'SCHEDUI-19: o traço desenhado cresce com o progresso, não salta pronto',
    (tester) async {
      await pumpCheck(tester, value: false);
      final onPrimary = AppTheme.light.colorScheme.onPrimary;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: AnimatedCheck(value: true, onChanged: (_) {})),
        ),
      );
      await tester.pump(const Duration(milliseconds: 150));

      late final int midPixels;
      await tester.runAsync(() async {
        midPixels = await tracedPixelsOf(tester, onPrimary);
      });

      await tester.pumpAndSettle();

      late final int finalPixels;
      await tester.runAsync(() async {
        finalPixels = await tracedPixelsOf(tester, onPrimary);
      });

      // No meio do traçado já se vê parte do check, mas bem menos do que no
      // final: prova que o desenho depende do progresso (mata o mutante que
      // ignora `progress` e extrai o traço inteiro sempre).
      expect(midPixels, greaterThan(0));
      expect(midPixels, lessThan(finalPixels));
    },
  );

  testWidgets(
    'SCHEDUI-19: a duração do traçado é exatamente AppMotion.medium',
    (tester) async {
      await pumpCheck(tester, value: false);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: AnimatedCheck(value: true, onChanged: (_) {})),
        ),
      );

      await tester.pump(AppMotion.medium - const Duration(milliseconds: 1));
      expect(progressOf(tester), lessThan(1));

      await tester.pump(const Duration(milliseconds: 1));
      expect(progressOf(tester), 1);
    },
  );

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

  testWidgets(
    'SCHEDUI-09: semântica expõe desmarcado quando o valor é falso',
    (tester) async {
      await pumpCheck(tester, value: false);

      final semantics = tester.getSemantics(find.byType(AnimatedCheck));
      expect(semantics.flagsCollection.isChecked, CheckedState.isFalse);
    },
  );

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
