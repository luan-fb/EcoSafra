import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ScheduleItem.withSchedule troca só o agendamento', () {
    final schedule = FertilizationSchedule(
      id: '1',
      scheduledDate: DateTime(2026, 9, 25),
      createdAt: DateTime(2026, 9, 23),
    );
    final item = ScheduleItem(
      schedule: schedule,
      risk: ScheduleRiskLevel.atRisk,
      isPastDue: false,
      expectedRainMm: 42,
    );
    final completed = schedule.withCompletedAt(DateTime(2026, 9, 25, 14));

    expect(
      item.withSchedule(completed),
      ScheduleItem(
        schedule: completed,
        risk: ScheduleRiskLevel.atRisk,
        isPastDue: false,
        expectedRainMm: 42,
      ),
    );
  });
}
