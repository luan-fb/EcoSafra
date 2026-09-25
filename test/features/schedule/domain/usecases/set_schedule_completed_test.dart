import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:ecosafra/features/schedule/domain/usecases/set_schedule_completed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

void main() {
  late MockScheduleRepository repository;
  late SetScheduleCompleted setScheduleCompleted;

  setUp(() {
    repository = MockScheduleRepository();
    setScheduleCompleted = SetScheduleCompleted(repository);
  });

  test('repassa id e completed true ao repositório', () async {
    when(
      () => repository.setScheduleCompleted(
        id: any(named: 'id'),
        completed: any(named: 'completed'),
      ),
    ).thenAnswer((_) async => const Right(null));

    final result = await setScheduleCompleted(
      const SetScheduleCompletedParams(id: 's1', completed: true),
    );

    expect(result, const Right<Failure, void>(null));
    verify(
      () => repository.setScheduleCompleted(id: 's1', completed: true),
    ).called(1);
  });

  test('repassa id e completed false ao repositório', () async {
    when(
      () => repository.setScheduleCompleted(
        id: any(named: 'id'),
        completed: any(named: 'completed'),
      ),
    ).thenAnswer((_) async => const Right(null));

    final result = await setScheduleCompleted(
      const SetScheduleCompletedParams(id: 's1', completed: false),
    );

    expect(result, const Right<Failure, void>(null));
    verify(
      () => repository.setScheduleCompleted(id: 's1', completed: false),
    ).called(1);
  });

  test('falha do repositório é repassada', () async {
    when(
      () => repository.setScheduleCompleted(
        id: any(named: 'id'),
        completed: any(named: 'completed'),
      ),
    ).thenAnswer((_) async => const Left(CacheFailure('erro')));

    final result = await setScheduleCompleted(
      const SetScheduleCompletedParams(id: 's1', completed: true),
    );

    expect(result, const Left<Failure, void>(CacheFailure('erro')));
  });
}
