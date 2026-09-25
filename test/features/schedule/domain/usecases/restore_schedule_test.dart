import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:ecosafra/features/schedule/domain/usecases/restore_schedule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

void main() {
  late MockScheduleRepository repository;
  late RestoreSchedule restoreSchedule;

  setUpAll(() {
    registerFallbackValue(
      FertilizationSchedule(
        id: '',
        scheduledDate: DateTime(2026),
        createdAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    repository = MockScheduleRepository();
    restoreSchedule = RestoreSchedule(repository);
  });

  test('repassa o agendamento exato ao repositório', () async {
    final schedule = FertilizationSchedule(
      id: 's1',
      scheduledDate: DateTime(2026, 9, 25),
      createdAt: DateTime(2026, 9, 23, 8),
      note: 'talhão norte',
      completedAt: DateTime(2026, 9, 25, 16),
    );
    when(
      () => repository.restoreSchedule(any()),
    ).thenAnswer((_) async => const Right(null));

    final result = await restoreSchedule(schedule);

    expect(result, const Right<Failure, void>(null));
    verify(() => repository.restoreSchedule(schedule)).called(1);
  });

  test('falha do repositório é repassada', () async {
    final schedule = FertilizationSchedule(
      id: 's1',
      scheduledDate: DateTime(2026, 9, 25),
      createdAt: DateTime(2026, 9, 23, 8),
    );
    when(
      () => repository.restoreSchedule(any()),
    ).thenAnswer((_) async => const Left(CacheFailure('erro')));

    final result = await restoreSchedule(schedule);

    expect(result, const Left<Failure, void>(CacheFailure('erro')));
  });
}
