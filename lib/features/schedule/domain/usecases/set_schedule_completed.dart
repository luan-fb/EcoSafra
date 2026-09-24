import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

final class SetScheduleCompletedParams extends Equatable {
  const SetScheduleCompletedParams({
    required this.id,
    required this.completed,
  });

  final String id;
  final bool completed;

  @override
  List<Object?> get props => [id, completed];
}

class SetScheduleCompleted
    implements UseCase<void, SetScheduleCompletedParams> {
  const SetScheduleCompleted(this._repository);

  final ScheduleRepository _repository;

  @override
  Future<Either<Failure, void>> call(SetScheduleCompletedParams params) =>
      _repository.setScheduleCompleted(
        id: params.id,
        completed: params.completed,
      );
}
