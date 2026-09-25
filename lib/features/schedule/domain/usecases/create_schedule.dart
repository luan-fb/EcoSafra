import 'package:clock/clock.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/extensions/date_extensions.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_note.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:ecosafra/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

final class CreateScheduleParams extends Equatable {
  const CreateScheduleParams({required this.scheduledDate, this.note});

  final DateTime scheduledDate;
  final String? note;

  @override
  List<Object?> get props => [scheduledDate, note];
}

/// Valida a data e a observação antes de gravar; a UI já impede os dois
/// casos, mas a regra vive aqui para não depender de nenhuma tela.
class CreateSchedule implements UseCase<void, CreateScheduleParams> {
  const CreateSchedule(this._repository, this._clock);

  final ScheduleRepository _repository;
  final Clock _clock;

  @override
  Future<Either<Failure, void>> call(CreateScheduleParams params) async {
    final window = SchedulingWindow.startingAt(_clock.now());
    if (!window.contains(params.scheduledDate)) {
      return const Left(
        ValidationFailure(
          'Escolha uma data entre hoje e os próximos '
          '${WeatherForecast.coverageDays - 1} dias.',
        ),
      );
    }

    final note = ScheduleNote.normalize(params.note);
    if (note != null && note.length > ScheduleNote.maxLength) {
      return const Left(
        ValidationFailure(
          'A observação pode ter até ${ScheduleNote.maxLength} caracteres.',
        ),
      );
    }

    return _repository.createSchedule(
      scheduledDate: params.scheduledDate.dateOnly,
      note: note,
    );
  }
}
