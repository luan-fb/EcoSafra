import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FertilizationSchedule.isCompleted', () {
    test('isCompleted é falso sem completedAt', () {
      final schedule = FertilizationSchedule(
        id: '1',
        scheduledDate: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 23),
      );

      expect(schedule.isCompleted, isFalse);
    });

    test('isCompleted é verdadeiro com completedAt preenchido', () {
      final schedule = FertilizationSchedule(
        id: '1',
        scheduledDate: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 23),
        completedAt: DateTime(2026, 9, 25, 14, 30),
      );

      expect(schedule.isCompleted, isTrue);
    });
  });

  group('FertilizationSchedule.withCompletedAt', () {
    final base = FertilizationSchedule(
      id: '1',
      scheduledDate: DateTime(2026, 9, 25),
      createdAt: DateTime(2026, 9, 23),
      note: 'talhão 3',
    );

    test('conclui mantendo os demais campos', () {
      final completedAt = DateTime(2026, 9, 25, 14);
      final completed = base.withCompletedAt(completedAt);

      expect(completed.completedAt, completedAt);
      expect(completed.withCompletedAt(null), base);
    });
  });

  group('FertilizationSchedule.props', () {
    test('dois agendamentos iguais exceto completedAt NÃO são iguais', () {
      final schedule1 = FertilizationSchedule(
        id: '1',
        scheduledDate: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 23),
        note: 'talhão 3',
      );

      final schedule2 = FertilizationSchedule(
        id: '1',
        scheduledDate: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 23),
        note: 'talhão 3',
        completedAt: DateTime(2026, 9, 25, 14, 30),
      );

      expect(schedule1, isNot(equals(schedule2)));
    });

    test('dois agendamentos iguais em tudo são iguais', () {
      final completedAt = DateTime(2026, 9, 25, 14, 30);

      final schedule1 = FertilizationSchedule(
        id: '1',
        scheduledDate: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 23),
        note: 'talhão 3',
        completedAt: completedAt,
      );

      final schedule2 = FertilizationSchedule(
        id: '1',
        scheduledDate: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 23),
        note: 'talhão 3',
        completedAt: completedAt,
      );

      expect(schedule1, equals(schedule2));
    });
  });
}
