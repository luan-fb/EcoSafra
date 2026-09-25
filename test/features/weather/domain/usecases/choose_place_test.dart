import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:ecosafra/features/weather/domain/repositories/location_repository.dart';
import 'package:ecosafra/features/weather/domain/usecases/choose_place.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late _MockLocationRepository repository;
  late ChoosePlace usecase;

  setUp(() {
    repository = _MockLocationRepository();
    usecase = ChoosePlace(repository);
  });

  test(
    'choosePlace delega ao repositório e devolve exatamente o resultado',
    () async {
      const place = Place(
        name: 'São Paulo',
        region: 'SP',
        country: 'Brasil',
        coordinates: Coordinates(latitude: -23.5505, longitude: -46.6333),
      );

      when(() => repository.choosePlace(place)).thenAnswer(
        (_) async => const Right<Failure, void>(null),
      );

      final result = await usecase(place);

      expect(result, const Right<Failure, void>(null));
      verify(() => repository.choosePlace(place)).called(1);
    },
  );

  test('choosePlace propaga falha do repositório', () async {
    const place = Place(
      name: 'Cuiabá',
      region: 'MT',
      country: 'Brasil',
      coordinates: Coordinates(latitude: -15.5942, longitude: -56.0974),
    );
    const failure = AuthFailure('Precisa estar logado');

    when(() => repository.choosePlace(place)).thenAnswer(
      (_) async => const Left<Failure, void>(failure),
    );

    final result = await usecase(place);

    expect(result, const Left<Failure, void>(failure));
    verify(() => repository.choosePlace(place)).called(1);
  });
}
