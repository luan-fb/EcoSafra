import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:ecosafra/features/weather/domain/repositories/location_repository.dart';
import 'package:fpdart/fpdart.dart';

class ChoosePlace implements UseCase<void, Place> {
  const ChoosePlace(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, void>> call(Place params) =>
      _repository.choosePlace(params);
}
