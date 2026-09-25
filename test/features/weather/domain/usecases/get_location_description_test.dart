import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
import 'package:ecosafra/features/weather/domain/repositories/location_repository.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_location_description.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late _MockLocationRepository repository;
  late GetLocationDescription usecase;

  setUp(() {
    repository = _MockLocationRepository();
    usecase = GetLocationDescription(repository);
  });

  test(
    'describe delega ao repositório e devolve exatamente a descrição da localização',
    () async {
      const coordinates = Coordinates(latitude: -23.5505, longitude: -46.6333);
      const description = LocationDescription(
        label: 'São Paulo, SP',
        source: LocationSource.chosen,
      );

      when(() => repository.describe(coordinates)).thenAnswer(
        (_) async => description,
      );

      final result = await usecase(coordinates);

      expect(result, description);
      verify(() => repository.describe(coordinates)).called(1);
    },
  );

  test('describe com GPS devolve LocalDescription com source device', () async {
    const coordinates = Coordinates(latitude: -15.7942, longitude: -56.0974);
    const description = LocationDescription(
      label: 'Cuiabá, MT',
      source: LocationSource.device,
    );

    when(() => repository.describe(coordinates)).thenAnswer(
      (_) async => description,
    );

    final result = await usecase(coordinates);

    expect(result, description);
    expect(result.source, LocationSource.device);
    verify(() => repository.describe(coordinates)).called(1);
  });
}
