import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_alert.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_alert.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_risk.dart';
import 'package:ecosafra/features/schedule/domain/usecases/watch_schedules.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_state.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchSchedules extends Mock implements WatchSchedules {}

class MockEvaluateScheduleAlert extends Mock implements EvaluateScheduleAlert {}

void main() {
  late MockWatchSchedules watchSchedules;
  late StreamController<List<FertilizationSchedule>> schedulesController;

  final now = DateTime(2026, 9, 23, 10);
  final fixedClock = Clock.fixed(now);
  const evaluateScheduleAlert = EvaluateScheduleAlert(EvaluateScheduleRisk());

  const heavyRain = EvaluateApplicationSafety.dangerThresholdMm + 5;
  const lightRain = EvaluateApplicationSafety.dangerThresholdMm - 5;

  final today = DateTime(2026, 9, 23);
  final tomorrow = DateTime(2026, 9, 24);

  const noAlert = ScheduleAlertState();
  const todayReminder = ScheduleAlertState(alert: ScheduleTodayReminder());
  const tomorrowReminder = ScheduleAlertState(
    alert: ScheduleTomorrowReminder(),
  );

  FertilizationSchedule schedule(
    String id,
    DateTime date, {
    bool completed = false,
  }) => FertilizationSchedule(
    id: id,
    scheduledDate: date,
    createdAt: DateTime(2026, 9, 20, 8),
    completedAt: completed ? DateTime(2026, 9, 23, 9) : null,
  );

  /// Previsão de 7 dias a partir de hoje, com chuva forte só em [heavyOn].
  WeatherForecast weekForecast({Set<DateTime> heavyOn = const {}}) =>
      WeatherForecast(
        coordinates: const Coordinates(latitude: -15.6, longitude: -56.1),
        hourly: const [],
        fetchedAt: DateTime(2026, 9, 23, 6),
        daily: [
          for (var i = 0; i < WeatherForecast.coverageDays; i++)
            DailyForecastPoint(
              date: DateTime(2026, 9, 23 + i),
              precipitationSum: heavyOn.contains(DateTime(2026, 9, 23 + i))
                  ? heavyRain
                  : lightRain,
              precipitationProbabilityMax: 80,
              temperatureMax: 28,
              temperatureMin: 18,
              windSpeedMax: 12,
              weatherCode: 61,
            ),
        ],
      );

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  setUpAll(
    () => registerFallbackValue(
      EvaluateScheduleAlertParams(
        schedules: const [],
        forecast: null,
        today: now,
      ),
    ),
  );

  setUp(() {
    watchSchedules = MockWatchSchedules();
    schedulesController = StreamController();
    when(
      () => watchSchedules(const NoParams()),
    ).thenAnswer((_) => schedulesController.stream);
  });

  // Sem `await`: o `done` de um controller sem ouvinte não completa.
  tearDown(() => unawaited(schedulesController.close()));

  ScheduleAlertCubit buildCubit({
    Clock? clock,
    EvaluateScheduleAlert evaluate = evaluateScheduleAlert,
  }) => ScheduleAlertCubit(
    watchSchedules: watchSchedules,
    evaluateScheduleAlert: evaluate,
    clock: clock ?? fixedClock,
  );

  test('começa sem aviso e assina a lista na criação', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state, noAlert);
    expect(schedulesController.hasListener, isTrue);
  });

  group('antes da primeira lista', () {
    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'previsão com risco não gera aviso sem lista',
      build: buildCubit,
      act: (cubit) => cubit.updateForecast(weekForecast(heavyOn: {today})),
      expect: () => const <ScheduleAlertState>[],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'a lista que chega depois usa a previsão já recebida',
      build: buildCubit,
      act: (cubit) {
        cubit.updateForecast(weekForecast(heavyOn: {today}));
        schedulesController.add([schedule('a', today)]);
      },
      expect: () => const [ScheduleAlertState(alert: ScheduleRiskAlert(1))],
    );
  });

  group('lista e previsão (AGD-15, AGD-21)', () {
    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'lista sem nada para hoje ou amanhã não emite estado repetido',
      build: buildCubit,
      act: (_) => schedulesController.add([
        schedule('a', DateTime(2026, 9, 26)),
        schedule('b', today, completed: true),
      ]),
      expect: () => const <ScheduleAlertState>[],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'lembrete de hoje sem previsão',
      build: buildCubit,
      act: (_) => schedulesController.add([schedule('a', today)]),
      expect: () => const [todayReminder],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'previsão com chuva forte troca o lembrete pelo alerta de risco',
      build: buildCubit,
      act: (cubit) async {
        schedulesController.add([
          schedule('a', today),
          schedule('b', tomorrow),
        ]);
        await flush();
        cubit.updateForecast(weekForecast(heavyOn: {today, tomorrow}));
      },
      expect: () => const [
        todayReminder,
        ScheduleAlertState(alert: ScheduleRiskAlert(2)),
      ],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'previsão que volta a null desfaz o risco e mantém o lembrete',
      build: buildCubit,
      act: (cubit) async {
        schedulesController.add([schedule('a', today)]);
        await flush();
        cubit
          ..updateForecast(weekForecast(heavyOn: {today}))
          ..updateForecast(null);
      },
      expect: () => const [
        todayReminder,
        ScheduleAlertState(alert: ScheduleRiskAlert(1)),
        todayReminder,
      ],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'agendamento concluído na nova lista remove o aviso',
      build: buildCubit,
      act: (_) async {
        schedulesController.add([schedule('a', tomorrow)]);
        await flush();
        schedulesController.add([schedule('a', tomorrow, completed: true)]);
      },
      expect: () => const [tomorrowReminder, noAlert],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'nova lista recalcula o risco com a previsão guardada',
      build: buildCubit,
      act: (cubit) async {
        cubit.updateForecast(weekForecast(heavyOn: {tomorrow}));
        schedulesController.add([schedule('a', today)]);
        await flush();
        schedulesController.add([
          schedule('a', today),
          schedule('b', tomorrow),
        ]);
      },
      expect: () => const [
        todayReminder,
        ScheduleAlertState(alert: ScheduleRiskAlert(1)),
      ],
    );
  });

  group('falha na leitura (AGD-22)', () {
    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'erro no stream zera o aviso',
      build: buildCubit,
      act: (_) async {
        schedulesController.add([schedule('a', today)]);
        await flush();
        schedulesController.addError(Exception('banco'));
      },
      expect: () => const [todayReminder, noAlert],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'depois do erro, a previsão não traz de volta o aviso da lista antiga',
      build: buildCubit,
      act: (cubit) async {
        schedulesController.add([schedule('a', today)]);
        await flush();
        schedulesController.addError(Exception('banco'));
        await flush();
        cubit.updateForecast(weekForecast(heavyOn: {today}));
      },
      expect: () => const [todayReminder, noAlert],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'continua ouvindo o stream e volta a calcular na emissão seguinte',
      build: buildCubit,
      act: (_) async {
        schedulesController.addError(Exception('banco'));
        await flush();
        schedulesController.add([schedule('a', tomorrow)]);
      },
      expect: () => const [tomorrowReminder],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'falha do use case vira ausência de aviso',
      build: () {
        final evaluate = MockEvaluateScheduleAlert();
        var calls = 0;
        when(() => evaluate(any())).thenAnswer(
          (_) => calls++ == 0
              ? const Right(ScheduleTodayReminder())
              : const Left(CacheFailure()),
        );
        return buildCubit(evaluate: evaluate);
      },
      act: (_) async {
        schedulesController.add([schedule('a', today)]);
        await flush();
        schedulesController.add([schedule('a', today)]);
      },
      expect: () => const [todayReminder, noAlert],
    );
  });

  group('relógio (AGD-23)', () {
    late DateTime current;

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'a virada do dia muda o lembrete de amanhã para hoje',
      setUp: () => current = now,
      build: () => buildCubit(clock: Clock(() => current)),
      act: (cubit) async {
        schedulesController.add([schedule('a', tomorrow)]);
        await flush();
        current = DateTime(2026, 9, 24, 0, 5);
        cubit.updateForecast(null);
      },
      expect: () => const [tomorrowReminder, todayReminder],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'refresh vira o dia sem precisar de lista ou previsão nova',
      setUp: () => current = now,
      build: () => buildCubit(clock: Clock(() => current)),
      act: (cubit) async {
        schedulesController.add([schedule('a', tomorrow)]);
        await flush();
        current = DateTime(2026, 9, 24, 0, 5);
        cubit.refresh();
      },
      expect: () => const [tomorrowReminder, todayReminder],
    );

    blocTest<ScheduleAlertCubit, ScheduleAlertState>(
      'refresh antes da primeira lista não inventa aviso',
      build: buildCubit,
      act: (cubit) => cubit.refresh(),
      expect: () => const <ScheduleAlertState>[],
    );

    test('lê o relógio a cada cálculo', () async {
      current = now;
      final evaluate = MockEvaluateScheduleAlert();
      when(() => evaluate(any())).thenReturn(const Right(null));
      final cubit = buildCubit(clock: Clock(() => current), evaluate: evaluate);
      addTearDown(cubit.close);

      schedulesController.add(const []);
      await flush();
      current = DateTime(2026, 9, 25, 7);
      schedulesController.add(const []);
      await flush();

      final params = verify(
        () => evaluate(captureAny()),
      ).captured.cast<EvaluateScheduleAlertParams>();
      expect(params.map((p) => p.today), [now, DateTime(2026, 9, 25, 7)]);
    });
  });

  group('close', () {
    test('cancela a assinatura da lista', () async {
      final cubit = buildCubit();
      expect(schedulesController.hasListener, isTrue);

      await cubit.close();

      expect(schedulesController.hasListener, isFalse);
    });

    test('nada é emitido depois do close', () async {
      final cubit = buildCubit();
      final states = <ScheduleAlertState>[];
      final sub = cubit.stream.listen(states.add);
      addTearDown(sub.cancel);

      await cubit.close();
      schedulesController.add([schedule('a', today)]);
      await flush();

      expect(() => cubit.updateForecast(weekForecast()), returnsNormally);
      expect(states, isEmpty);
      expect(cubit.state, noAlert);
    });
  });
}
