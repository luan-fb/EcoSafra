import 'package:clock/clock.dart';
import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/app/router/page_transitions.dart';
import 'package:ecosafra/features/auth/presentation/guards/auth_guards.dart';
import 'package:ecosafra/features/schedule/domain/usecases/create_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/delete_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_risk.dart';
import 'package:ecosafra/features/schedule/domain/usecases/restore_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/set_schedule_completed.dart';
import 'package:ecosafra/features/schedule/domain/usecases/update_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/watch_schedules.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/pages/schedule_page.dart';
import 'package:ecosafra/features/schedule/schedule_data_module.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:ecosafra/features/weather/weather_module.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Importa o `WeatherModule` para avaliar o risco com a mesma previsão
/// (cache-first) do painel, e o `ScheduleDataModule` para os binds de dados
/// que o painel também usa.
class ScheduleModule extends Module {
  @override
  List<Module> imports() => [WeatherModule(), ScheduleDataModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<ScheduleCubit>(
      (i) => ScheduleCubit(
        watchSchedules: i.get<WatchSchedules>(),
        createSchedule: i.get<CreateSchedule>(),
        updateSchedule: i.get<UpdateSchedule>(),
        setScheduleCompleted: i.get<SetScheduleCompleted>(),
        deleteSchedule: i.get<DeleteSchedule>(),
        restoreSchedule: i.get<RestoreSchedule>(),
        getCurrentLocation: i.get<GetCurrentLocation>(),
        getForecast: i.get<GetForecast>(),
        evaluateScheduleRisk: i.get<EvaluateScheduleRisk>(),
        clock: i.get<Clock>(),
      ),
    );
  }

  @override
  List<ModularRoute> get routes => [
    ChildRoute(
      '/',
      name: AppRoute.schedule.name,
      transition: AppTransitions.slideFromRight,
      guards: const [RequireAuthGuard()],
      child: (context, state) => const SchedulePage(),
    ),
  ];
}
