import 'package:clock/clock.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:ecosafra/features/schedule/domain/usecases/update_schedule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

void main() {
  late MockScheduleRepository repository;
  late UpdateSchedule updateSchedule;

  final now = DateTime(2026, 9, 23, 15, 30);
  final clock = Clock.fixed(now);

  setUp(() {
    repository = MockScheduleRepository();
    updateSchedule = UpdateSchedule(repository, clock);
    when(
      () => repository.updateSchedule(
        id: any(named: 'id'),
        scheduledDate: any(named: 'scheduledDate'),
        note: any(named: 'note'),
      ),
    ).thenAnswer((_) async => const Right(null));
  });

  test('hoje: dentro da janela, repassa id e data sem hora', () async {
    final result = await updateSchedule(
      UpdateScheduleParams(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 23, 8),
      ),
    );

    expect(result, const Right<Failure, void>(null));
    verify(
      () => repository.updateSchedule(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 23),
        note: null,
      ),
    ).called(1);
  });

  test('último dia da janela (29/09): aceita', () async {
    final result = await updateSchedule(
      UpdateScheduleParams(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 29, 23),
      ),
    );

    expect(result, const Right<Failure, void>(null));
    verify(
      () => repository.updateSchedule(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 29),
        note: null,
      ),
    ).called(1);
  });

  test(
    'ontem: fora da janela, ValidationFailure sem chamar o repositório',
    () async {
      final result = await updateSchedule(
        UpdateScheduleParams(id: 's1', scheduledDate: DateTime(2026, 9, 22)),
      );

      expect(
        result,
        const Left<Failure, void>(
          ValidationFailure(
            'Escolha uma data entre hoje e os próximos 6 dias.',
          ),
        ),
      );
      verifyNever(
        () => repository.updateSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          note: any(named: 'note'),
        ),
      );
    },
  );

  test(
    'último dia + 1 (30/09): fora da janela, ValidationFailure sem chamar o repositório',
    () async {
      final result = await updateSchedule(
        UpdateScheduleParams(id: 's1', scheduledDate: DateTime(2026, 9, 30)),
      );

      expect(
        result,
        const Left<Failure, void>(
          ValidationFailure(
            'Escolha uma data entre hoje e os próximos 6 dias.',
          ),
        ),
      );
      verifyNever(
        () => repository.updateSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          note: any(named: 'note'),
        ),
      );
    },
  );

  test('nota com espaços nas pontas chega normalizada', () async {
    await updateSchedule(
      UpdateScheduleParams(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 23),
        note: '  nova nota  ',
      ),
    );

    verify(
      () => repository.updateSchedule(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 23),
        note: 'nova nota',
      ),
    ).called(1);
  });

  test('nota vazia (só espaços) chega null', () async {
    await updateSchedule(
      UpdateScheduleParams(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 23),
        note: '   ',
      ),
    );

    verify(
      () => repository.updateSchedule(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 23),
        note: null,
      ),
    ).called(1);
  });

  test(
    'nota com 201 caracteres: ValidationFailure sem chamar o repositório',
    () async {
      final result = await updateSchedule(
        UpdateScheduleParams(
          id: 's1',
          scheduledDate: DateTime(2026, 9, 23),
          note: 'a' * 201,
        ),
      );

      expect(
        result,
        const Left<Failure, void>(
          ValidationFailure('A observação pode ter até 200 caracteres.'),
        ),
      );
      verifyNever(
        () => repository.updateSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          note: any(named: 'note'),
        ),
      );
    },
  );

  test('falha do repositório é repassada', () async {
    when(
      () => repository.updateSchedule(
        id: any(named: 'id'),
        scheduledDate: any(named: 'scheduledDate'),
        note: any(named: 'note'),
      ),
    ).thenAnswer((_) async => const Left(CacheFailure('erro')));

    final result = await updateSchedule(
      UpdateScheduleParams(id: 's1', scheduledDate: DateTime(2026, 9, 23)),
    );

    expect(result, const Left<Failure, void>(CacheFailure('erro')));
  });
}
