import 'package:equatable/equatable.dart';

/// Um plano de adubação: "no dia X, quero aplicar fertilizante".
final class FertilizationSchedule extends Equatable {
  const FertilizationSchedule({
    required this.id,
    required this.scheduledDate,
    required this.createdAt,
    this.note,
    this.completedAt,
  });

  /// Identificador único, gerado no próprio aparelho (UUID v4).
  final String id;

  /// O dia planejado — só a data importa, a hora é ignorada em toda
  /// comparação (ver `EvaluateScheduleRisk`).
  final DateTime scheduledDate;

  final DateTime createdAt;

  final String? note;

  /// O momento em que o produtor marcou a aplicação como feita, ou `null`
  /// se ainda não foi concluída.
  final DateTime? completedAt;

  /// `true` quando o agendamento foi marcado como concluído.
  bool get isCompleted => completedAt != null;

  @override
  List<Object?> get props => [id, scheduledDate, createdAt, note, completedAt];
}
