import 'package:ecosafra/core/error/exception_mapper.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/data/datasources/device_location_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/repositories/location_repository.dart';
import 'package:fpdart/fpdart.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final DeviceLocationDataSource _dataSource;

  @override
  Future<Either<Failure, Coordinates>> getCurrentLocation() async {
    try {
      return Right(await _dataSource.getCurrentLocation());
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }
}
