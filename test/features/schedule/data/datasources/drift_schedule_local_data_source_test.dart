import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/features/schedule/data/datasources/drift_schedule_local_data_source.dart';
import 'package:ecosafra/features/schedule/data/models/schedule_row_mapper.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

const _alice = 'uid-alice';
const _bob = 'uid-bob';

ScheduleRow _row({
  required String id,
  String userId = _alice,
  DateTime? scheduledDate,
  DateTime? createdAt,
  String? note,
  DateTime? completedAt,
}) => ScheduleRow(
  id: id,
  userId: userId,
  scheduledDate: scheduledDate ?? DateTime(2026, 9, 25),
  createdAt: createdAt ?? DateTime(2026, 9, 23, 8),
  note: note,
  completedAt: completedAt,
);

Matcher _cacheException(String message) =>
    isA<CacheException>().having((e) => e.message, 'message', message);

void main() {
  late AppDatabase database;
  late DriftScheduleLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
    dataSource = DriftScheduleLocalDataSource(database);
  });

  tearDown(() => database.close());

  Future<List<ScheduleRow>> rowsOf(String userId) =>
      dataSource.watchByUser(userId).first;

  Future<List<String>> idsOf(String userId) async =>
      (await rowsOf(userId)).map((row) => row.id).toList();

  group('watchByUser', () {
    test('sem agendamentos, emite lista vazia', () async {
      expect(await rowsOf(_alice), isEmpty);
    });

    test('devolve só as linhas do usuário pedido', () async {
      await dataSource.insert(_row(id: 'a1'));
      await dataSource.insert(_row(id: 'b1', userId: _bob));
      await dataSource.insert(_row(id: 'a2'));

      expect(await idsOf(_alice), ['a1', 'a2']);
      expect(await idsOf(_bob), ['b1']);
      expect(await idsOf('uid-sem-agendamento'), isEmpty);
    });

    test(
      'ordena por scheduledDate crescente, fora da ordem de inserção',
      () async {
        await dataSource.insert(
          _row(id: 'dia-27', scheduledDate: DateTime(2026, 9, 27)),
        );
        await dataSource.insert(
          _row(id: 'dia-23', scheduledDate: DateTime(2026, 9, 23)),
        );
        await dataSource.insert(
          _row(id: 'dia-25', scheduledDate: DateTime(2026, 9, 25)),
        );

        expect(await idsOf(_alice), ['dia-23', 'dia-25', 'dia-27']);
      },
    );

    test('no mesmo dia, desempata por createdAt crescente', () async {
      await dataSource.insert(
        _row(id: 'a-tarde', createdAt: DateTime(2026, 9, 23, 15)),
      );
      await dataSource.insert(
        _row(id: 'z-manha', createdAt: DateTime(2026, 9, 23, 9)),
      );

      // O `id` sozinho daria a ordem inversa: quem decide é o createdAt.
      expect(await idsOf(_alice), ['z-manha', 'a-tarde']);
    });

    test('mesmo dia e mesmo createdAt: a ordem segue o id', () async {
      final sameInstant = DateTime(2026, 9, 23, 10, 30, 15);
      await dataSource.insert(_row(id: 'bbb', createdAt: sameInstant));
      await dataSource.insert(_row(id: 'ccc', createdAt: sameInstant));
      await dataSource.insert(_row(id: 'aaa', createdAt: sameInstant));

      expect(await idsOf(_alice), ['aaa', 'bbb', 'ccc']);
    });

    test('reemite após insert, update, conclusão e delete', () async {
      final emissions = StreamIterator(dataSource.watchByUser(_alice));
      addTearDown(emissions.cancel);

      Future<List<ScheduleRow>> next() async {
        expect(await emissions.moveNext(), isTrue);
        return emissions.current;
      }

      expect(await next(), isEmpty);

      await dataSource.insert(_row(id: 'a1'));
      expect((await next()).single.id, 'a1');

      await dataSource.updateDateAndNote(
        id: 'a1',
        userId: _alice,
        scheduledDate: DateTime(2026, 9, 26),
        note: 'talhão 3',
      );
      final updated = (await next()).single;
      expect(updated.scheduledDate, DateTime(2026, 9, 26));
      expect(updated.note, 'talhão 3');

      await dataSource.setCompletedAt(
        id: 'a1',
        userId: _alice,
        completedAt: DateTime(2026, 9, 26, 7),
      );
      expect((await next()).single.completedAt, DateTime(2026, 9, 26, 7));

      await dataSource.delete(id: 'a1', userId: _alice);
      expect(await next(), isEmpty);
    });
  });

  group('insert', () {
    test('grava todos os campos da linha', () async {
      final row = _row(
        id: 'a1',
        scheduledDate: DateTime(2026, 9, 28),
        createdAt: DateTime(2026, 9, 23, 14, 5, 9),
        note: 'talhão norte',
        completedAt: DateTime(2026, 9, 28, 16),
      );

      await dataSource.insert(row);

      expect(await rowsOf(_alice), [row]);
    });

    test(
      'id duplicado vira CacheException e não altera a linha existente',
      () async {
        await dataSource.insert(_row(id: 'a1', note: 'original'));

        await expectLater(
          dataSource.insert(_row(id: 'a1', note: 'duplicado')),
          throwsA(_cacheException('Não foi possível salvar o agendamento.')),
        );
        expect((await rowsOf(_alice)).single.note, 'original');
      },
    );

    test(
      'id duplicado num banco em background (como no app) também vira '
      'CacheException',
      () async {
        final directory = Directory.systemTemp.createTempSync('schedules_');
        final backgroundDatabase = AppDatabase.withExecutor(
          NativeDatabase.createInBackground(
            File('${directory.path}/schedules.db'),
          ),
        );
        addTearDown(() async {
          await backgroundDatabase.close();
          directory.deleteSync(recursive: true);
        });
        final backgroundDataSource = DriftScheduleLocalDataSource(
          backgroundDatabase,
        );
        await backgroundDataSource.insert(_row(id: 'a1', note: 'original'));

        await expectLater(
          backgroundDataSource.insert(_row(id: 'a1', note: 'duplicado')),
          throwsA(_cacheException('Não foi possível salvar o agendamento.')),
        );
        final rows = await backgroundDataSource.watchByUser(_alice).first;
        expect(rows.single.note, 'original');
      },
    );

    test('id de outro usuário também colide (a PK é global)', () async {
      await dataSource.insert(_row(id: 'mesmo-id', userId: _bob));

      await expectLater(
        dataSource.insert(_row(id: 'mesmo-id')),
        throwsA(_cacheException('Não foi possível salvar o agendamento.')),
      );
      expect(await rowsOf(_alice), isEmpty);
    });
  });

  group('updateDateAndNote', () {
    test('troca data e observação só do agendamento pedido', () async {
      await dataSource.insert(_row(id: 'a1', note: 'antes'));
      await dataSource.insert(_row(id: 'a2', note: 'intocado'));

      await dataSource.updateDateAndNote(
        id: 'a1',
        userId: _alice,
        scheduledDate: DateTime(2026, 9, 29),
        note: 'depois',
      );

      final rows = await rowsOf(_alice);
      expect(rows, [
        _row(id: 'a2', note: 'intocado'),
        _row(id: 'a1', scheduledDate: DateTime(2026, 9, 29), note: 'depois'),
      ]);
    });

    test('observação null apaga a observação anterior', () async {
      await dataSource.insert(_row(id: 'a1', note: 'antes'));

      await dataSource.updateDateAndNote(
        id: 'a1',
        userId: _alice,
        scheduledDate: DateTime(2026, 9, 25),
        note: null,
      );

      expect((await rowsOf(_alice)).single.note, isNull);
    });

    test('id inexistente vira CacheException', () async {
      await expectLater(
        dataSource.updateDateAndNote(
          id: 'nao-existe',
          userId: _alice,
          scheduledDate: DateTime(2026, 9, 25),
          note: null,
        ),
        throwsA(_cacheException('Agendamento não encontrado.')),
      );
    });

    test(
      'id de outro usuário vira CacheException e não altera a linha',
      () async {
        final bobs = _row(id: 'b1', userId: _bob, note: 'do bob');
        await dataSource.insert(bobs);

        await expectLater(
          dataSource.updateDateAndNote(
            id: 'b1',
            userId: _alice,
            scheduledDate: DateTime(2026, 9, 29),
            note: 'invasão',
          ),
          throwsA(_cacheException('Agendamento não encontrado.')),
        );
        expect(await rowsOf(_bob), [bobs]);
      },
    );
  });

  group('setCompletedAt', () {
    test('grava a data de conclusão e depois volta para null', () async {
      await dataSource.insert(_row(id: 'a1'));

      await dataSource.setCompletedAt(
        id: 'a1',
        userId: _alice,
        completedAt: DateTime(2026, 9, 25, 17, 45),
      );
      expect(
        (await rowsOf(_alice)).single.completedAt,
        DateTime(2026, 9, 25, 17, 45),
      );

      await dataSource.setCompletedAt(
        id: 'a1',
        userId: _alice,
        completedAt: null,
      );
      expect((await rowsOf(_alice)).single.completedAt, isNull);
    });

    test('não mexe na data nem na observação', () async {
      final row = _row(id: 'a1', note: 'talhão 3');
      await dataSource.insert(row);

      await dataSource.setCompletedAt(
        id: 'a1',
        userId: _alice,
        completedAt: DateTime(2026, 9, 25, 17),
      );

      expect(
        (await rowsOf(_alice)).single,
        row.copyWith(completedAt: Value(DateTime(2026, 9, 25, 17))),
      );
    });

    test('id inexistente vira CacheException', () async {
      await expectLater(
        dataSource.setCompletedAt(
          id: 'nao-existe',
          userId: _alice,
          completedAt: DateTime(2026, 9, 25),
        ),
        throwsA(_cacheException('Agendamento não encontrado.')),
      );
    });

    test(
      'id de outro usuário vira CacheException e não altera a linha',
      () async {
        final bobs = _row(id: 'b1', userId: _bob);
        await dataSource.insert(bobs);

        await expectLater(
          dataSource.setCompletedAt(
            id: 'b1',
            userId: _alice,
            completedAt: DateTime(2026, 9, 25),
          ),
          throwsA(_cacheException('Agendamento não encontrado.')),
        );
        expect(await rowsOf(_bob), [bobs]);
      },
    );
  });

  group('delete', () {
    test('apaga só o agendamento pedido', () async {
      await dataSource.insert(_row(id: 'a1'));
      await dataSource.insert(_row(id: 'a2'));

      await dataSource.delete(id: 'a1', userId: _alice);

      expect(await idsOf(_alice), ['a2']);
    });

    test('id inexistente vira CacheException', () async {
      await expectLater(
        dataSource.delete(id: 'nao-existe', userId: _alice),
        throwsA(_cacheException('Agendamento não encontrado.')),
      );
    });

    test('id de outro usuário vira CacheException e não apaga', () async {
      await dataSource.insert(_row(id: 'b1', userId: _bob));

      await expectLater(
        dataSource.delete(id: 'b1', userId: _alice),
        throwsA(_cacheException('Agendamento não encontrado.')),
      );
      expect(await idsOf(_bob), ['b1']);
    });
  });

  group('ScheduleRow.toEntity', () {
    test('copia todos os campos, menos o userId', () {
      final row = _row(
        id: 'a1',
        scheduledDate: DateTime(2026, 9, 28),
        createdAt: DateTime(2026, 9, 23, 14),
        note: 'talhão norte',
        completedAt: DateTime(2026, 9, 28, 16),
      );

      expect(
        row.toEntity(),
        FertilizationSchedule(
          id: 'a1',
          scheduledDate: DateTime(2026, 9, 28),
          createdAt: DateTime(2026, 9, 23, 14),
          note: 'talhão norte',
          completedAt: DateTime(2026, 9, 28, 16),
        ),
      );
    });

    test('observação e conclusão ausentes continuam null', () {
      final entity = _row(id: 'a1').toEntity();

      expect(entity.note, isNull);
      expect(entity.completedAt, isNull);
      expect(entity.isCompleted, isFalse);
    });
  });
}
