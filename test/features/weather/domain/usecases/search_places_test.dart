import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:ecosafra/features/weather/domain/repositories/place_search_repository.dart';
import 'package:ecosafra/features/weather/domain/usecases/search_places.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlaceSearchRepository extends Mock
    implements PlaceSearchRepository {}

void main() {
  late _MockPlaceSearchRepository repository;
  late SearchPlaces usecase;

  setUp(() {
    repository = _MockPlaceSearchRepository();
    usecase = SearchPlaces(repository);
  });

  test(
    'search delega ao repositório e devolve exatamente o resultado',
    () async {
      const query = 'São Paulo';
      final places = [
        const Place(
          name: 'São Paulo',
          region: 'SP',
          country: 'Brasil',
          coordinates: Coordinates(latitude: -23.5505, longitude: -46.6333),
        ),
      ];

      when(() => repository.search(query)).thenAnswer(
        (_) async => Right<Failure, List<Place>>(places),
      );

      final result = await usecase(query);

      expect(result, Right<Failure, List<Place>>(places));
      verify(() => repository.search(query)).called(1);
    },
  );

  test('search propaga falha do repositório', () async {
    const query = 'Cuiabá';
    const failure = NetworkFailure('Sem internet');

    when(() => repository.search(query)).thenAnswer(
      (_) async => const Left<Failure, List<Place>>(failure),
    );

    final result = await usecase(query);

    expect(result, const Left<Failure, List<Place>>(failure));
    verify(() => repository.search(query)).called(1);
  });
}
