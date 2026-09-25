import 'package:ecosafra/core/theme/color_contrast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('contrastRatio', () {
    test('preto sobre branco é 21 e a ordem não importa', () {
      expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
      expect(contrastRatio(Colors.white, Colors.black), closeTo(21, 0.01));
    });

    test('uma cor sobre ela mesma é 1', () {
      expect(contrastRatio(Colors.teal, Colors.teal), closeTo(1, 0.001));
    });
  });

  group('readableOn', () {
    test('cor que já passa volta inalterada', () {
      const color = Color(0xFF000000);
      expect(
        readableOn(color, background: Colors.white, ink: Colors.black),
        color,
      );
    });

    test('âmbar sobre fundo claro escurece até passar', () {
      const amber = Color(0xFFE0A23A);
      final readable = readableOn(
        amber,
        background: Colors.white,
        ink: Colors.black,
      );

      expect(contrastRatio(amber, Colors.white), lessThan(minTextContrast));
      expect(
        contrastRatio(readable, Colors.white),
        greaterThanOrEqualTo(minTextContrast),
      );
      expect(readable.computeLuminance(), lessThan(amber.computeLuminance()));
    });

    test('mistura o mínimo necessário, não vai direto para a tinta', () {
      const amber = Color(0xFFE0A23A);
      final readable = readableOn(
        amber,
        background: Colors.white,
        ink: Colors.black,
      );

      expect(readable, isNot(Colors.black));
      // Um passo a menos de mistura ainda não passaria.
      final lessMixed = Color.lerp(readable, amber, 0.2)!;
      expect(contrastRatio(lessMixed, Colors.white), lessThan(minTextContrast));
    });
  });
}
