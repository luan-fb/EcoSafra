import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteSchedule implements UseCase<void, String> {
  const DeleteSchedule(this._repository);

  final ScheduleRepository _repository;

  @override
  Future<Either<Failure, void>> call(String scheduleId) =>
      _repository.deleteSchedule(scheduleId);
}
