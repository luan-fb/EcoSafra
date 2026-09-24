import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:fpdart/fpdart.dart';

/// Agendamentos do usuário logado. Sem sessão, as escritas devolvem
/// `AuthFailure` e `watchSchedules` emite lista vazia.
///
/// `watchSchedules` é um `Stream` sem `Either`: falha de leitura chega como
/// erro do próprio stream.
abstract interface class ScheduleRepository {
  Stream<List<FertilizationSchedule>> watchSchedules();

  Future<Either<Failure, void>> createSchedule({
    required DateTime scheduledDate,
    String? note,
  });

  Future<Either<Failure, void>> updateSchedule({
    required String id,
    required DateTime scheduledDate,
    String? note,
  });

  Future<Either<Failure, void>> setScheduleCompleted({
    required String id,
    required bool completed,
  });

  Future<Either<Failure, void>> deleteSchedule(String id);
}
