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

final class UpdateScheduleParams extends Equatable {
  const UpdateScheduleParams({
    required this.id,
    required this.scheduledDate,
    this.note,
  });

  final String id;
  final DateTime scheduledDate;
  final String? note;

  @override
  List<Object?> get props => [id, scheduledDate, note];
}

/// Mesma janela e mesmas regras de observação da criação (AGD-25); só
/// agendamentos não concluídos chegam aqui, a UI que impede editar os
/// concluídos.
class UpdateSchedule implements UseCase<void, UpdateScheduleParams> {
  const UpdateSchedule(this._repository, this._clock);

  final ScheduleRepository _repository;
  final Clock _clock;

  @override
  Future<Either<Failure, void>> call(UpdateScheduleParams params) async {
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

    return _repository.updateSchedule(
      id: params.id,
      scheduledDate: params.scheduledDate.dateOnly,
      note: note,
    );
  }
}
