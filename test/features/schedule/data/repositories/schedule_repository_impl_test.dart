import 'dart:async';

import 'package:clock/clock.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/auth/domain/entities/app_user.dart';
import 'package:ecosafra/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecosafra/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:ecosafra/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class MockScheduleLocalDataSource extends Mock
    implements ScheduleLocalDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUuid extends Mock implements Uuid {}

const _uid = 'uid-alice';
const _user = AppUser(uid: _uid);
const _signedOut = AuthFailure('É preciso estar logado para usar a agenda.');
const _notFound = CacheException('Agendamento não encontrado.');
final _now = DateTime(2026, 9, 23, 14, 30, 5);

void main() {
  late MockScheduleLocalDataSource local;
  late MockAuthRepository authRepository;
  late MockUuid uuid;
  late ScheduleRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      ScheduleRow(
        id: '',
        userId: '',
        scheduledDate: DateTime(2026),
        createdAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    local = MockScheduleLocalDataSource();
    authRepository = MockAuthRepository();
    uuid = MockUuid();
    repository = ScheduleRepositoryImpl(
      local: local,
      authRepository: authRepository,
      clock: Clock.fixed(_now),
      uuid: uuid,
    );
    when(() => authRepository.currentUser).thenReturn(_user);
  });

  void signOut() => when(() => authRepository.currentUser).thenReturn(null);

  group('watchSchedules', () {
    test('lê as linhas do usuário logado e converte para entidade', () async {
      final row = ScheduleRow(
        id: 's1',
        userId: _uid,
        scheduledDate: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 23, 8),
        note: 'talhão norte',
        completedAt: DateTime(2026, 9, 25, 16),
      );
      when(
        () => local.watchByUser(_uid),
      ).thenAnswer((_) => Stream.value([row]));

      expect(
        await repository.watchSchedules().first,
        [
          FertilizationSchedule(
            id: 's1',
            scheduledDate: DateTime(2026, 9, 25),
            createdAt: DateTime(2026, 9, 23, 8),
            note: 'talhão norte',
            completedAt: DateTime(2026, 9, 25, 16),
          ),
        ],
      );
    });

    test('repassa cada emissão do banco', () {
      final controller = StreamController<List<ScheduleRow>>();
      addTearDown(controller.close);
      when(() => local.watchByUser(_uid)).thenAnswer((_) => controller.stream);
      final row = ScheduleRow(
        id: 's1',
        userId: _uid,
        scheduledDate: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 23, 8),
      );

      expect(
        repository.watchSchedules().map((list) => list.map((s) => s.id)),
        emitsInOrder([
          isEmpty,
          ['s1'],
        ]),
      );
      controller
        ..add(const [])
        ..add([row]);
    });

    test('erro do banco chega como erro do stream', () {
      when(
        () => local.watchByUser(_uid),
      ).thenAnswer((_) => Stream.error(const CacheException()));

      expect(
        repository.watchSchedules(),
        emitsError(isA<CacheException>()),
      );
    });

    test('sem login, emite lista vazia sem consultar o banco', () async {
      signOut();

      expect(await repository.watchSchedules().toList(), [
        isEmpty,
      ]);
      verifyZeroInteractions(local);
    });
  });

  group('createSchedule', () {
    setUp(() => when(() => uuid.v4()).thenReturn('uuid-gerado'));

    test(
      'grava a linha com uuid, uid, data, nota e createdAt do relógio',
      () async {
        when(() => local.insert(any())).thenAnswer((_) async {});

        final result = await repository.createSchedule(
          scheduledDate: DateTime(2026, 9, 25),
          note: 'talhão 3',
        );

        expect(result, const Right<Failure, void>(null));
        verify(
          () => local.insert(
            ScheduleRow(
              id: 'uuid-gerado',
              userId: _uid,
              scheduledDate: DateTime(2026, 9, 25),
              note: 'talhão 3',
              createdAt: _now,
            ),
          ),
        ).called(1);
      },
    );

    test('sem nota, grava note null e completedAt null', () async {
      when(() => local.insert(any())).thenAnswer((_) async {});

      await repository.createSchedule(scheduledDate: DateTime(2026, 9, 25));

      final row =
          verify(() => local.insert(captureAny())).captured.single
              as ScheduleRow;
      expect(row.note, isNull);
      expect(row.completedAt, isNull);
    });

    test('sem login, devolve AuthFailure sem tocar no banco', () async {
      signOut();

      final result = await repository.createSchedule(
        scheduledDate: DateTime(2026, 9, 25),
      );

      expect(result, const Left<Failure, void>(_signedOut));
      verifyZeroInteractions(local);
      verifyZeroInteractions(uuid);
    });

    test('CacheException vira CacheFailure com a mesma mensagem', () async {
      when(() => local.insert(any())).thenThrow(
        const CacheException('Não foi possível salvar o agendamento.'),
      );

      final result = await repository.createSchedule(
        scheduledDate: DateTime(2026, 9, 25),
      );

      expect(
        result,
        const Left<Failure, void>(
          CacheFailure('Não foi possível salvar o agendamento.'),
        ),
      );
    });
  });

  group('updateSchedule', () {
    test('grava data e nota filtrando pelo usuário logado', () async {
      when(
        () => local.updateDateAndNote(
          id: any(named: 'id'),
          userId: any(named: 'userId'),
          scheduledDate: any(named: 'scheduledDate'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateSchedule(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 27),
        note: 'nova nota',
      );

      expect(result, const Right<Failure, void>(null));
      verify(
        () => local.updateDateAndNote(
          id: 's1',
          userId: _uid,
          scheduledDate: DateTime(2026, 9, 27),
          note: 'nova nota',
        ),
      ).called(1);
    });

    test('sem nota, grava note null', () async {
      when(
        () => local.updateDateAndNote(
          id: any(named: 'id'),
          userId: any(named: 'userId'),
          scheduledDate: any(named: 'scheduledDate'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async {});

      await repository.updateSchedule(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 27),
      );

      verify(
        () => local.updateDateAndNote(
          id: 's1',
          userId: _uid,
          scheduledDate: DateTime(2026, 9, 27),
          note: null,
        ),
      ).called(1);
    });

    test('sem login, devolve AuthFailure sem tocar no banco', () async {
      signOut();

      final result = await repository.updateSchedule(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 27),
      );

      expect(result, const Left<Failure, void>(_signedOut));
      verifyZeroInteractions(local);
    });

    test('CacheException vira CacheFailure com a mesma mensagem', () async {
      when(
        () => local.updateDateAndNote(
          id: any(named: 'id'),
          userId: any(named: 'userId'),
          scheduledDate: any(named: 'scheduledDate'),
          note: any(named: 'note'),
        ),
      ).thenThrow(_notFound);

      final result = await repository.updateSchedule(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 27),
      );

      expect(
        result,
        const Left<Failure, void>(CacheFailure('Agendamento não encontrado.')),
      );
    });
  });

  group('setScheduleCompleted', () {
    setUp(() {
      when(
        () => local.setCompletedAt(
          id: any(named: 'id'),
          userId: any(named: 'userId'),
          completedAt: any(named: 'completedAt'),
        ),
      ).thenAnswer((_) async {});
    });

    test('completed true grava a hora do relógio', () async {
      final result = await repository.setScheduleCompleted(
        id: 's1',
        completed: true,
      );

      expect(result, const Right<Failure, void>(null));
      verify(
        () => local.setCompletedAt(id: 's1', userId: _uid, completedAt: _now),
      ).called(1);
    });

    test('completed false grava null', () async {
      final result = await repository.setScheduleCompleted(
        id: 's1',
        completed: false,
      );

      expect(result, const Right<Failure, void>(null));
      verify(
        () => local.setCompletedAt(id: 's1', userId: _uid, completedAt: null),
      ).called(1);
    });

    test('sem login, devolve AuthFailure sem tocar no banco', () async {
      signOut();

      final result = await repository.setScheduleCompleted(
        id: 's1',
        completed: true,
      );

      expect(result, const Left<Failure, void>(_signedOut));
      verifyZeroInteractions(local);
    });

    test('CacheException vira CacheFailure com a mesma mensagem', () async {
      when(
        () => local.setCompletedAt(
          id: any(named: 'id'),
          userId: any(named: 'userId'),
          completedAt: any(named: 'completedAt'),
        ),
      ).thenThrow(_notFound);

      final result = await repository.setScheduleCompleted(
        id: 's1',
        completed: true,
      );

      expect(
        result,
        const Left<Failure, void>(CacheFailure('Agendamento não encontrado.')),
      );
    });
  });

  group('deleteSchedule', () {
    test('apaga filtrando pelo usuário logado', () async {
      when(
        () => local.delete(
          id: any(named: 'id'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.deleteSchedule('s1');

      expect(result, const Right<Failure, void>(null));
      verify(() => local.delete(id: 's1', userId: _uid)).called(1);
    });

    test('sem login, devolve AuthFailure sem tocar no banco', () async {
      signOut();

      final result = await repository.deleteSchedule('s1');

      expect(result, const Left<Failure, void>(_signedOut));
      verifyZeroInteractions(local);
    });

    test('CacheException vira CacheFailure com a mesma mensagem', () async {
      when(
        () => local.delete(
          id: any(named: 'id'),
          userId: any(named: 'userId'),
        ),
      ).thenThrow(_notFound);

      final result = await repository.deleteSchedule('s1');

      expect(
        result,
        const Left<Failure, void>(CacheFailure('Agendamento não encontrado.')),
      );
    });
  });

  group('restoreSchedule', () {
    test(
      'insere a ScheduleRow com id, data, nota, createdAt e completedAt do '
      'agendamento e o uid da conta atual',
      () async {
        when(() => local.insert(any())).thenAnswer((_) async {});
        final schedule = FertilizationSchedule(
          id: 's1',
          scheduledDate: DateTime(2026, 9, 25),
          createdAt: DateTime(2026, 9, 23, 8),
          note: 'talhão norte',
          completedAt: DateTime(2026, 9, 25, 16),
        );

        final result = await repository.restoreSchedule(schedule);

        expect(result, const Right<Failure, void>(null));
        verify(
          () => local.insert(
            ScheduleRow(
              id: 's1',
              userId: _uid,
              scheduledDate: DateTime(2026, 9, 25),
              note: 'talhão norte',
              createdAt: DateTime(2026, 9, 23, 8),
              completedAt: DateTime(2026, 9, 25, 16),
            ),
          ),
        ).called(1);
      },
    );

    test('sem login, devolve AuthFailure sem tocar no banco', () async {
      signOut();
      final schedule = FertilizationSchedule(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 23, 8),
      );

      final result = await repository.restoreSchedule(schedule);

      expect(result, const Left<Failure, void>(_signedOut));
      verifyZeroInteractions(local);
    });

    test('CacheException vira CacheFailure com a mesma mensagem', () async {
      when(() => local.insert(any())).thenThrow(
        const CacheException('Não foi possível salvar o agendamento.'),
      );
      final schedule = FertilizationSchedule(
        id: 's1',
        scheduledDate: DateTime(2026, 9, 25),
        createdAt: DateTime(2026, 9, 23, 8),
      );

      final result = await repository.restoreSchedule(schedule);

      expect(
        result,
        const Left<Failure, void>(
          CacheFailure('Não foi possível salvar o agendamento.'),
        ),
      );
    });
  });

  test(
    'lê o uid a cada chamada: troca de conta vale na escrita seguinte',
    () async {
      when(
        () => local.delete(
          id: any(named: 'id'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async {});

      await repository.deleteSchedule('s1');
      when(
        () => authRepository.currentUser,
      ).thenReturn(const AppUser(uid: 'uid-bob'));
      await repository.deleteSchedule('s2');

      verify(() => local.delete(id: 's1', userId: _uid)).called(1);
      verify(() => local.delete(id: 's2', userId: 'uid-bob')).called(1);
    },
  );
}
