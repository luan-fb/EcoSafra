import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SchedulingWindow.startingAt', () {
    test('first é hoje sem hora e last é hoje + 6 dias', () {
      final window = SchedulingWindow.startingAt(DateTime(2026, 9, 23, 15, 30));

      expect(window.first, equals(DateTime(2026, 9, 23)));
      expect(window.last, equals(DateTime(2026, 9, 29)));
    });

    test('virada de mês: começar em 28/09 leva last para 04/10', () {
      final window = SchedulingWindow.startingAt(DateTime(2026, 9, 28));

      expect(window.first, equals(DateTime(2026, 9, 28)));
      expect(window.last, equals(DateTime(2026, 10, 4)));
    });
  });

  group('SchedulingWindow.contains', () {
    final window = SchedulingWindow.startingAt(DateTime(2026, 9, 23, 15, 30));

    test('first está dentro da janela', () {
      expect(window.contains(DateTime(2026, 9, 23)), isTrue);
    });

    test('last está dentro da janela', () {
      expect(window.contains(DateTime(2026, 9, 29)), isTrue);
    });

    test('hora no meio do dia de last ainda conta como dentro', () {
      expect(window.contains(DateTime(2026, 9, 29, 12, 0)), isTrue);
    });

    test('ontem (véspera de first) está fora da janela', () {
      expect(window.contains(DateTime(2026, 9, 22)), isFalse);
    });

    test('last + 1 dia está fora da janela', () {
      expect(window.contains(DateTime(2026, 9, 30)), isFalse);
    });
  });

  group('SchedulingWindow.clamp', () {
    final window = SchedulingWindow.startingAt(DateTime(2026, 9, 23, 15, 30));

    test('data antes de first vira first', () {
      expect(window.clamp(DateTime(2026, 9, 10)), equals(window.first));
    });

    test('data depois de last vira first (spec: abre o seletor em hoje)', () {
      expect(window.clamp(DateTime(2026, 10, 15)), equals(window.first));
    });

    test('data dentro da janela volta sem hora, sem virar first', () {
      final inside = DateTime(2026, 9, 26, 18, 45);
      expect(window.clamp(inside), equals(DateTime(2026, 9, 26)));
    });
  });
}
