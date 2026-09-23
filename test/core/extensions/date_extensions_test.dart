import 'package:ecosafra/core/extensions/date_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeX.dateOnly', () {
    test('zera hora, minuto, segundo, milissegundo e microssegundo', () {
      final time = DateTime(2026, 9, 23, 15, 30, 45, 123, 456);
      expect(time.dateOnly, equals(DateTime(2026, 9, 23, 0, 0, 0, 0, 0)));
    });

    test('dia 1 do mês retorna meia-noite do mesmo dia', () {
      final time = DateTime(2026, 9, 1, 14, 20);
      expect(time.dateOnly, equals(DateTime(2026, 9, 1)));
    });

    test('último dia do mês retorna meia-noite do mesmo dia', () {
      final time = DateTime(2026, 9, 30, 23, 59);
      expect(time.dateOnly, equals(DateTime(2026, 9, 30)));
    });

    test('dia com hora zerada já é meia-noite', () {
      final time = DateTime(2026, 9, 23, 0, 0, 0, 0, 0);
      expect(time.dateOnly, equals(time));
    });
  });

  group('DateTimeX.isSameDay', () {
    test('mesmo dia com mesma hora é verdadeiro', () {
      final dateA = DateTime(2026, 9, 23, 15, 30);
      final dateB = DateTime(2026, 9, 23, 15, 30);
      expect(dateA.isSameDay(dateB), isTrue);
    });

    test('mesmo dia com horas diferentes é verdadeiro', () {
      final dateA = DateTime(2026, 9, 23, 9, 0);
      final dateB = DateTime(2026, 9, 23, 15, 30);
      expect(dateA.isSameDay(dateB), isTrue);
    });

    test('mesmo dia com minutos e segundos diferentes é verdadeiro', () {
      final dateA = DateTime(2026, 9, 23, 10, 15, 30);
      final dateB = DateTime(2026, 9, 23, 10, 45, 50);
      expect(dateA.isSameDay(dateB), isTrue);
    });

    test('23:59 de um dia vs 00:00 do dia seguinte é falso', () {
      final dateA = DateTime(2026, 9, 23, 23, 59);
      final dateB = DateTime(2026, 9, 24, 0, 0);
      expect(dateA.isSameDay(dateB), isFalse);
    });

    test('00:00 de um dia vs 23:59 do dia anterior é falso', () {
      final dateA = DateTime(2026, 9, 24, 0, 0);
      final dateB = DateTime(2026, 9, 23, 23, 59);
      expect(dateA.isSameDay(dateB), isFalse);
    });

    test('virada de mês: dia 30 vs dia 1 do mês seguinte é falso', () {
      final dateA = DateTime(2026, 9, 30, 20, 0);
      final dateB = DateTime(2026, 10, 1, 20, 0);
      expect(dateA.isSameDay(dateB), isFalse);
    });

    test('virada de ano: dia 31 de dezembro vs 1 de janeiro é falso', () {
      final dateA = DateTime(2025, 12, 31, 20, 0);
      final dateB = DateTime(2026, 1, 1, 20, 0);
      expect(dateA.isSameDay(dateB), isFalse);
    });

    test('mesmo dia no mesmo mês mas anos diferentes é falso', () {
      final dateA = DateTime(2025, 9, 23, 15, 30);
      final dateB = DateTime(2026, 9, 23, 15, 30);
      expect(dateA.isSameDay(dateB), isFalse);
    });
  });
}
