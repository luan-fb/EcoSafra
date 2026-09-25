import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:fpdart/fpdart.dart';

class RestoreSchedule implements UseCase<void, FertilizationSchedule> {
  const RestoreSchedule(this._repository);

  final ScheduleRepository _repository;

  @override
  Future<Either<Failure, void>> call(FertilizationSchedule schedule) =>
      _repository.restoreSchedule(schedule);
}
