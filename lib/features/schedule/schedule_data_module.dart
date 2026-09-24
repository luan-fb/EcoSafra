import 'package:clock/clock.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecosafra/features/schedule/data/datasources/drift_schedule_local_data_source.dart';
import 'package:ecosafra/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:ecosafra/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:ecosafra/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:ecosafra/features/schedule/domain/usecases/create_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/delete_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_alert.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_risk.dart';
import 'package:ecosafra/features/schedule/domain/usecases/set_schedule_completed.dart';
import 'package:ecosafra/features/schedule/domain/usecases/update_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/watch_schedules.dart';
import 'package:go_router_modular/go_router_modular.dart';
import 'package:uuid/uuid.dart';

/// Módulo de serviço, sem rotas: a Agenda e o painel importam os mesmos
/// binds de dados da agenda.
class ScheduleDataModule extends Module {
  @override
  void binds(Injector i) {
    i
      ..addSingleton<ScheduleLocalDataSource>(
        (i) => DriftScheduleLocalDataSource(i.get<AppDatabase>()),
      )
      ..addSingleton<ScheduleRepository>(
        (i) => ScheduleRepositoryImpl(
          local: i.get<ScheduleLocalDataSource>(),
          authRepository: i.get<AuthRepository>(),
          clock: i.get<Clock>(),
          uuid: i.get<Uuid>(),
        ),
      )
      ..addSingleton<WatchSchedules>(
        (i) => WatchSchedules(i.get<ScheduleRepository>()),
      )
      ..addSingleton<CreateSchedule>(
        (i) => CreateSchedule(i.get<ScheduleRepository>(), i.get<Clock>()),
      )
      ..addSingleton<UpdateSchedule>(
        (i) => UpdateSchedule(i.get<ScheduleRepository>(), i.get<Clock>()),
      )
      ..addSingleton<SetScheduleCompleted>(
        (i) => SetScheduleCompleted(i.get<ScheduleRepository>()),
      )
      ..addSingleton<DeleteSchedule>(
        (i) => DeleteSchedule(i.get<ScheduleRepository>()),
      )
      ..addSingleton<EvaluateScheduleRisk>(
        (i) => const EvaluateScheduleRisk(),
      )
      ..addSingleton<EvaluateScheduleAlert>(
        (i) => EvaluateScheduleAlert(i.get<EvaluateScheduleRisk>()),
      );
  }
}
