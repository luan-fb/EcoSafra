import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/features/weather/data/datasources/drift_chosen_location_local_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:flutter_test/flutter_test.dart';

const _alice = 'uid-alice';
const _bob = 'uid-bob';

const _cuiaba = Place(
  name: 'Cuiabá',
  region: 'Mato Grosso',
  country: 'Brasil',
  coordinates: Coordinates(latitude: -15.59611, longitude: -56.09667),
);

const _sorriso = Place(
  name: 'Sorriso',
  region: 'Mato Grosso',
  country: 'Brasil',
  coordinates: Coordinates(latitude: -12.54528, longitude: -55.71139),
);

const _semRegiao = Place(
  name: 'Lugar sem estado',
  coordinates: Coordinates(latitude: 1.5, longitude: -2.25),
);

void main() {
  late AppDatabase database;
  late DriftChosenLocationLocalDataSource dataSource;
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 9, 25, 8);
    database = AppDatabase.withExecutor(NativeDatabase.memory());
    dataSource = DriftChosenLocationLocalDataSource(
      database,
      Clock(() => now),
    );
  });

  tearDown(() => database.close());

  Future<List<ChosenLocationRow>> rows() =>
      database.select(database.chosenLocations).get();

  test('sem escolha salva, get devolve null', () async {
    expect(await dataSource.get(_alice), isNull);
  });

  test(
    'save grava o lugar e a hora do relógio; get devolve o mesmo lugar',
    () async {
      await dataSource.save(_alice, _cuiaba);

      expect(await dataSource.get(_alice), _cuiaba);
      expect(await rows(), [
        ChosenLocationRow(
          userId: _alice,
          name: 'Cuiabá',
          region: 'Mato Grosso',
          country: 'Brasil',
          latitude: -15.59611,
          longitude: -56.09667,
          updatedAt: DateTime(2026, 9, 25, 8),
        ),
      ]);
    },
  );

  test('lugar sem região nem país volta com os dois nulos', () async {
    await dataSource.save(_alice, _semRegiao);

    final place = await dataSource.get(_alice);

    expect(place, _semRegiao);
    expect(place!.region, isNull);
    expect(place.country, isNull);
  });

  test('salvar de novo substitui a escolha e atualiza updatedAt', () async {
    await dataSource.save(_alice, _cuiaba);
    now = DateTime(2026, 9, 25, 9, 30);

    await dataSource.save(_alice, _sorriso);

    expect(await dataSource.get(_alice), _sorriso);
    final saved = await rows();
    expect(saved, hasLength(1));
    expect(saved.single.name, 'Sorriso');
    expect(saved.single.updatedAt, DateTime(2026, 9, 25, 9, 30));
  });

  test('substituir por um lugar sem região apaga a região antiga', () async {
    await dataSource.save(_alice, _cuiaba);

    await dataSource.save(_alice, _semRegiao);

    expect(await dataSource.get(_alice), _semRegiao);
  });

  test('clear apaga a escolha e get volta a devolver null', () async {
    await dataSource.save(_alice, _cuiaba);

    await dataSource.clear(_alice);

    expect(await dataSource.get(_alice), isNull);
    expect(await rows(), isEmpty);
  });

  test('clear sem escolha salva não lança', () async {
    await expectLater(dataSource.clear(_alice), completes);
    expect(await rows(), isEmpty);
  });

  group('isolamento entre contas', () {
    test('a escolha da conta A não aparece para a conta B', () async {
      await dataSource.save(_alice, _cuiaba);

      expect(await dataSource.get(_bob), isNull);
    });

    test('cada conta lê a própria escolha', () async {
      await dataSource.save(_alice, _cuiaba);
      await dataSource.save(_bob, _sorriso);

      expect(await dataSource.get(_alice), _cuiaba);
      expect(await dataSource.get(_bob), _sorriso);
    });

    test('a conta B salvar não substitui a escolha da conta A', () async {
      await dataSource.save(_alice, _cuiaba);

      await dataSource.save(_bob, _sorriso);

      expect(await dataSource.get(_alice), _cuiaba);
      expect(await rows(), hasLength(2));
    });

    test('clear da conta A mantém a escolha da conta B', () async {
      await dataSource.save(_alice, _cuiaba);
      await dataSource.save(_bob, _sorriso);

      await dataSource.clear(_alice);

      expect(await dataSource.get(_alice), isNull);
      expect(await dataSource.get(_bob), _sorriso);
    });
  });
}
