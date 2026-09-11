import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/repositories/location_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCurrentLocation implements UseCase<Coordinates, NoParams> {
  const GetCurrentLocation(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, Coordinates>> call(NoParams params) =>
      _repository.getCurrentLocation();
}
