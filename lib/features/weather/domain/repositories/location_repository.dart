import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class LocationRepository {
  Future<Either<Failure, Coordinates>> getCurrentLocation();
}
