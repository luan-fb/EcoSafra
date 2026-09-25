import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/weather/domain/repositories/location_repository.dart';
import 'package:ecosafra/features/weather/domain/usecases/use_device_location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late _MockLocationRepository repository;
  late UseDeviceLocation usecase;

  setUp(() {
    repository = _MockLocationRepository();
    usecase = UseDeviceLocation(repository);
  });

  test(
    'clearChosenPlace delega ao repositório e devolve exatamente o resultado',
    () async {
      when(() => repository.clearChosenPlace()).thenAnswer(
        (_) async => const Right<Failure, void>(null),
      );

      final result = await usecase(const NoParams());

      expect(result, const Right<Failure, void>(null));
      verify(() => repository.clearChosenPlace()).called(1);
    },
  );

  test('clearChosenPlace propaga falha do repositório', () async {
    const failure = CacheFailure('Não foi possível apagar a localização');

    when(() => repository.clearChosenPlace()).thenAnswer(
      (_) async => const Left<Failure, void>(failure),
    );

    final result = await usecase(const NoParams());

    expect(result, const Left<Failure, void>(failure));
    verify(() => repository.clearChosenPlace()).called(1);
  });
}
