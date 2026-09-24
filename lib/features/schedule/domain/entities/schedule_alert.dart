import 'package:equatable/equatable.dart';

/// O aviso que o painel mostra sobre a agenda; no máximo um por vez.
sealed class ScheduleAlert extends Equatable {
  const ScheduleAlert();

  @override
  List<Object?> get props => [];
}

final class ScheduleRiskAlert extends ScheduleAlert {
  const ScheduleRiskAlert(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

final class ScheduleTodayReminder extends ScheduleAlert {
  const ScheduleTodayReminder();
}

final class ScheduleTomorrowReminder extends ScheduleAlert {
  const ScheduleTomorrowReminder();
}
