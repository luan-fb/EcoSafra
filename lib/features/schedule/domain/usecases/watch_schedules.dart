import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/repositories/schedule_repository.dart';

class WatchSchedules
    implements StreamUseCase<List<FertilizationSchedule>, NoParams> {
  const WatchSchedules(this._repository);

  final ScheduleRepository _repository;

  @override
  Stream<List<FertilizationSchedule>> call(NoParams params) =>
      _repository.watchSchedules();
}
