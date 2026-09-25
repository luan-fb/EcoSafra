import 'package:ecosafra/features/schedule/domain/entities/schedule_alert.dart';
import 'package:equatable/equatable.dart';

final class ScheduleAlertState extends Equatable {
  const ScheduleAlertState({this.alert});

  final ScheduleAlert? alert;

  @override
  List<Object?> get props => [alert];
}
