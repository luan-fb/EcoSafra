import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/weather/domain/repositories/location_repository.dart';
import 'package:fpdart/fpdart.dart';

class UseDeviceLocation implements UseCase<void, NoParams> {
  const UseDeviceLocation(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      _repository.clearChosenPlace();
}
