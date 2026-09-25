import 'package:ecosafra/features/schedule/domain/entities/schedule_note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScheduleNote.normalize', () {
    test('remove espaços das pontas', () {
      expect(ScheduleNote.normalize('  talhão 3  '), equals('talhão 3'));
    });

    test('vazio vira null', () {
      expect(ScheduleNote.normalize(''), isNull);
    });

    test('só espaços vira null', () {
      expect(ScheduleNote.normalize('   '), isNull);
    });

    test('null vira null', () {
      expect(ScheduleNote.normalize(null), isNull);
    });

    test('texto com 200 caracteres passa inalterado', () {
      final text = 'a' * 200;
      expect(ScheduleNote.normalize(text), equals(text));
    });

    test('quebra de linha nas pontas é removida', () {
      expect(ScheduleNote.normalize('\n  texto  \n'), equals('texto'));
    });

    test('quebra de linha no meio é preservada', () {
      expect(
        ScheduleNote.normalize('  linha 1\nlinha 2  '),
        equals('linha 1\nlinha 2'),
      );
    });
  });

  group('ScheduleNote.maxLength', () {
    test('maxLength é 200', () {
      expect(ScheduleNote.maxLength, equals(200));
    });
  });
}
