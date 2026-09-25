import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:ecosafra/features/schedule/domain/usecases/create_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/delete_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/evaluate_schedule_risk.dart';
import 'package:ecosafra/features/schedule/domain/usecases/restore_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/set_schedule_completed.dart';
import 'package:ecosafra/features/schedule/domain/usecases/update_schedule.dart';
import 'package:ecosafra/features/schedule/domain/usecases/watch_schedules.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchSchedules extends Mock implements WatchSchedules {}

class MockCreateSchedule extends Mock implements CreateSchedule {}

class MockUpdateSchedule extends Mock implements UpdateSchedule {}

class MockSetScheduleCompleted extends Mock implements SetScheduleCompleted {}

class MockDeleteSchedule extends Mock implements DeleteSchedule {}

class MockRestoreSchedule extends Mock implements RestoreSchedule {}

class MockGetCurrentLocation extends Mock implements GetCurrentLocation {}

class MockGetForecast extends Mock implements GetForecast {}

void main() {
  late MockWatchSchedules watchSchedules;
  late MockCreateSchedule createSchedule;
  late MockUpdateSchedule updateSchedule;
  late MockSetScheduleCompleted setScheduleCompleted;
  late MockDeleteSchedule deleteSchedule;
  late MockRestoreSchedule restoreSchedule;
  late MockGetCurrentLocation getCurrentLocation;
  late MockGetForecast getForecast;
  late StreamController<List<FertilizationSchedule>> schedulesController;
  late StreamController<Either<Failure, WeatherForecast>> forecastController;

  final now = DateTime(2026, 9, 23, 10);
  final fixedClock = Clock.fixed(now);

  const coordinates = Coordinates(latitude: -15.6, longitude: -56.1);
  const heavyRain = EvaluateApplicationSafety.dangerThresholdMm + 5;
  const lightRain = EvaluateApplicationSafety.dangerThresholdMm - 5;
  const writeFailure = CacheFailure('Não foi possível salvar o agendamento.');
  const loadFailure = CacheFailure('Não foi possível carregar a agenda.');

  final yesterday = DateTime(2026, 9, 22);
  final today = DateTime(2026, 9, 23);
  final inThreeDays = DateTime(2026, 9, 26);

  FertilizationSchedule schedule(
    String id,
    DateTime date, {
    bool completed = false,
  }) => FertilizationSchedule(
    id: id,
    scheduledDate: date,
    createdAt: DateTime(2026, 9, 20, 8),
    completedAt: completed ? DateTime(2026, 9, 21, 9) : null,
  );

  /// Previsão de 7 dias a partir de hoje, com chuva forte só em [heavyOn].
  WeatherForecast weekForecast({Set<DateTime> heavyOn = const {}}) =>
      WeatherForecast(
        coordinates: coordinates,
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

  ScheduleItem item(
    FertilizationSchedule schedule, {
    ScheduleRiskLevel risk = ScheduleRiskLevel.unknown,
    bool isPastDue = false,
    double? rainMm,
  }) => ScheduleItem(
    schedule: schedule,
    risk: risk,
    isPastDue: isPastDue,
    expectedRainMm: rainMm,
  );

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  setUpAll(() => registerFallbackValue(coordinates));

  setUp(() {
    watchSchedules = MockWatchSchedules();
    createSchedule = MockCreateSchedule();
    updateSchedule = MockUpdateSchedule();
    setScheduleCompleted = MockSetScheduleCompleted();
    deleteSchedule = MockDeleteSchedule();
    restoreSchedule = MockRestoreSchedule();
    getCurrentLocation = MockGetCurrentLocation();
    getForecast = MockGetForecast();
    schedulesController = StreamController();
    forecastController = StreamController();

    when(
      () => watchSchedules(const NoParams()),
    ).thenAnswer((_) => schedulesController.stream);
    when(
      () => getCurrentLocation(const NoParams()),
    ).thenAnswer((_) async => const Right(coordinates));
    when(
      () => getForecast(coordinates),
    ).thenAnswer((_) => forecastController.stream);
  });

  // Sem `await`: o `done` de um controller que nunca foi assinado não
  // completa.
  tearDown(() {
    unawaited(schedulesController.close());
    unawaited(forecastController.close());
  });

  ScheduleCubit buildCubit({Clock? clock}) => ScheduleCubit(
    watchSchedules: watchSchedules,
    createSchedule: createSchedule,
    updateSchedule: updateSchedule,
    setScheduleCompleted: setScheduleCompleted,
    deleteSchedule: deleteSchedule,
    restoreSchedule: restoreSchedule,
    getCurrentLocation: getCurrentLocation,
    getForecast: getForecast,
    evaluateScheduleRisk: const EvaluateScheduleRisk(),
    clock: clock ?? fixedClock,
  );

  test('começa em loading com a janela a partir do relógio', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state, const ScheduleState.loading());
  });

  group('seções e ordem (AGD-08, AGD-28, AGD-29)', () {
    final pastDue = schedule('past', yesterday);
    final forToday = schedule('today', today);
    final later = schedule('later', inThreeDays);
    final doneOld = schedule(
      'done-old',
      DateTime(2026, 9, 20),
      completed: true,
    );
    final doneRecent = schedule('done-recent', yesterday, completed: true);
    final doneFuture = schedule('done-future', inThreeDays, completed: true);

    blocTest<ScheduleCubit, ScheduleState>(
      'separa não concluídos na ordem do stream e concluídos por data '
      'decrescente',
      build: buildCubit,
      act: (_) => schedulesController.add([
        doneOld,
        pastDue,
        doneRecent,
        forToday,
        later,
        doneFuture,
      ]),
      expect: () => [
        ScheduleState.loaded(
          upcoming: [
            item(pastDue, isPastDue: true),
            item(forToday),
            item(later),
          ],
          completed: [item(doneFuture), item(doneRecent), item(doneOld)],
        ),
      ],
    );

    final doneFirst = schedule('done-a', yesterday, completed: true);
    final doneSecond = schedule('done-b', yesterday, completed: true);

    blocTest<ScheduleCubit, ScheduleState>(
      'concluídos na mesma data saem na ordem inversa do stream',
      build: buildCubit,
      act: (_) => schedulesController.add([doneFirst, doneSecond]),
      expect: () => [
        ScheduleState.loaded(
          upcoming: const [],
          completed: [item(doneSecond), item(doneFirst)],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'concluir e desfazer movem o item entre as seções conforme o stream',
      build: buildCubit,
      act: (_) async {
        schedulesController.add([forToday]);
        await flush();
        schedulesController.add([schedule('today', today, completed: true)]);
        await flush();
        schedulesController.add([forToday]);
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [item(forToday)],
          completed: const [],
        ),
        ScheduleState.loaded(
          upcoming: const [],
          completed: [item(schedule('today', today, completed: true))],
        ),
        ScheduleState.loaded(
          upcoming: [item(forToday)],
          completed: const [],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'lista vazia vira loaded com as duas seções vazias',
      build: buildCubit,
      act: (_) => schedulesController.add(const []),
      expect: () => [
        const ScheduleState.loaded(
          upcoming: [],
          completed: [],
        ),
      ],
    );
  });

  group('risco e data passada (AGD-09, AGD-10, AGD-24)', () {
    final pastDue = schedule('past', yesterday);
    final forToday = schedule('today', today);
    final later = schedule('later', inThreeDays);
    final doneToday = schedule('done', today, completed: true);
    final all = [pastDue, forToday, doneToday, later];

    blocTest<ScheduleCubit, ScheduleState>(
      'mostra a lista com risco unknown antes da previsão e recalcula quando '
      'ela chega, só para não concluídos de hoje em diante',
      build: buildCubit,
      act: (_) async {
        schedulesController.add(all);
        await flush();
        forecastController.add(Right(weekForecast(heavyOn: {today})));
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [
            item(pastDue, isPastDue: true),
            item(forToday),
            item(later),
          ],
          completed: [item(doneToday)],
        ),
        ScheduleState.loaded(
          upcoming: [
            item(pastDue, isPastDue: true),
            item(forToday, risk: ScheduleRiskLevel.atRisk, rainMm: heavyRain),
            item(later, risk: ScheduleRiskLevel.ok, rainMm: lightRain),
          ],
          completed: [item(doneToday)],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'data passada não recebe risco mesmo com o dia na previsão do cache',
      build: buildCubit,
      act: (_) async {
        forecastController.add(
          Right(
            WeatherForecast(
              coordinates: coordinates,
              hourly: const [],
              fetchedAt: DateTime(2026, 9, 22, 6),
              isStale: true,
              daily: [
                DailyForecastPoint(
                  date: yesterday,
                  precipitationSum: heavyRain,
                  precipitationProbabilityMax: 90,
                  temperatureMax: 27,
                  temperatureMin: 19,
                  windSpeedMax: 10,
                  weatherCode: 65,
                ),
              ],
            ),
          ),
        );
        await flush();
        schedulesController.add([pastDue]);
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [item(pastDue, isPastDue: true)],
          completed: const [],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'previsão que chega antes da lista não emite; a lista já sai com risco',
      build: buildCubit,
      act: (_) async {
        forecastController.add(Right(weekForecast(heavyOn: {inThreeDays})));
        await flush();
        schedulesController.add([forToday, later]);
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [
            item(forToday, risk: ScheduleRiskLevel.ok, rainMm: lightRain),
            item(later, risk: ScheduleRiskLevel.atRisk, rainMm: heavyRain),
          ],
          completed: const [],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'previsão do cache e depois a da rede reavaliam o risco duas vezes',
      build: buildCubit,
      act: (_) async {
        schedulesController.add([later]);
        await flush();
        forecastController.add(Right(weekForecast()));
        await flush();
        forecastController.add(Right(weekForecast(heavyOn: {inThreeDays})));
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [item(later)],
          completed: const [],
        ),
        ScheduleState.loaded(
          upcoming: [
            item(later, risk: ScheduleRiskLevel.ok, rainMm: lightRain),
          ],
          completed: const [],
        ),
        ScheduleState.loaded(
          upcoming: [
            item(later, risk: ScheduleRiskLevel.atRisk, rainMm: heavyRain),
          ],
          completed: const [],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'editar a data reavalia o risco com a previsão já carregada',
      build: buildCubit,
      act: (_) async {
        forecastController.add(Right(weekForecast(heavyOn: {inThreeDays})));
        await flush();
        schedulesController.add([later]);
        await flush();
        schedulesController.add([schedule('later', DateTime(2026, 9, 27))]);
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [
            item(later, risk: ScheduleRiskLevel.atRisk, rainMm: heavyRain),
          ],
          completed: const [],
        ),
        ScheduleState.loaded(
          upcoming: [
            item(
              schedule('later', DateTime(2026, 9, 27)),
              risk: ScheduleRiskLevel.ok,
              rainMm: lightRain,
            ),
          ],
          completed: const [],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'falha da previsão mantém o risco unknown sem emitir',
      build: buildCubit,
      act: (_) async {
        schedulesController.add([forToday]);
        await flush();
        forecastController
          ..add(const Left(NetworkFailure()))
          ..addError(Exception('boom'));
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [item(forToday)],
          completed: const [],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'sem localização não busca previsão e a lista aparece com unknown',
      setUp: () => when(
        () => getCurrentLocation(const NoParams()),
      ).thenAnswer((_) async => const Left(LocationFailure('Sem GPS.'))),
      build: buildCubit,
      act: (_) => schedulesController.add([forToday]),
      expect: () => [
        ScheduleState.loaded(
          upcoming: [item(forToday)],
          completed: const [],
        ),
      ],
      verify: (_) => verifyNever(() => getForecast(any())),
    );
  });

  group('janela', () {
    late DateTime current;

    blocTest<ScheduleCubit, ScheduleState>(
      'recalcula a data passada a cada emissão pelo relógio',
      setUp: () => current = now,
      build: () => buildCubit(clock: Clock(() => current)),
      act: (_) async {
        schedulesController.add([schedule('today', today)]);
        await flush();
        current = DateTime(2026, 9, 24, 8);
        schedulesController.add([schedule('today', today)]);
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [item(schedule('today', today))],
          completed: const [],
        ),
        ScheduleState.loaded(
          upcoming: [item(schedule('today', today), isPastDue: true)],
          completed: const [],
        ),
      ],
    );
  });

  test(
    'currentWindow acompanha o relógio mesmo sem nova emissão (virada do dia '
    'com a tela aberta)',
    () async {
      var current = now;
      final cubit = buildCubit(clock: Clock(() => current));
      schedulesController.add([schedule('today', today)]);
      await flush();

      current = DateTime(2026, 9, 24, 0, 5);

      expect(
        cubit.currentWindow(),
        SchedulingWindow.startingAt(DateTime(2026, 9, 24)),
      );
      await cubit.close();
    },
  );

  group('falha do stream', () {
    blocTest<ScheduleCubit, ScheduleState>(
      'antes de carregar vira error, e a previsão depois não inventa lista',
      build: buildCubit,
      act: (_) async {
        schedulesController.addError(Exception('banco'));
        await flush();
        forecastController.add(Right(weekForecast()));
      },
      expect: () => [const ScheduleState.error(loadFailure)],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'depois de carregado mantém a lista',
      build: buildCubit,
      act: (_) async {
        schedulesController.add([schedule('today', today)]);
        await flush();
        schedulesController.addError(Exception('banco'));
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [item(schedule('today', today))],
          completed: const [],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'nova emissão depois do error carrega a lista',
      build: buildCubit,
      act: (_) async {
        schedulesController.addError(Exception('banco'));
        await flush();
        schedulesController.add([schedule('today', today)]);
      },
      expect: () => [
        const ScheduleState.error(loadFailure),
        ScheduleState.loaded(
          upcoming: [item(schedule('today', today))],
          completed: const [],
        ),
      ],
    );
  });

  group('tentar de novo', () {
    late StreamController<List<FertilizationSchedule>> retryController;

    setUp(() {
      retryController = StreamController();
      var calls = 0;
      when(() => watchSchedules(const NoParams())).thenAnswer(
        (_) =>
            calls++ == 0 ? schedulesController.stream : retryController.stream,
      );
    });

    tearDown(() => unawaited(retryController.close()));

    blocTest<ScheduleCubit, ScheduleState>(
      'depois do error, volta a loading e carrega pela assinatura nova',
      build: buildCubit,
      act: (cubit) async {
        schedulesController.addError(Exception('banco'));
        await flush();
        await cubit.retry();
        retryController.add([schedule('today', today)]);
      },
      expect: () => [
        const ScheduleState.error(loadFailure),
        const ScheduleState.loading(),
        ScheduleState.loaded(
          upcoming: [item(schedule('today', today))],
          completed: const [],
        ),
      ],
      verify: (_) => verify(() => watchSchedules(const NoParams())).called(2),
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'fora do error não faz nada',
      build: buildCubit,
      act: (cubit) async {
        schedulesController.add([schedule('today', today)]);
        await flush();
        await cubit.retry();
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [item(schedule('today', today))],
          completed: const [],
        ),
      ],
      verify: (_) => verify(() => watchSchedules(const NoParams())).called(1),
    );
  });

  group('ações (AGD-01, AGD-12, AGD-24, AGD-28, AGD-29, AGD-30)', () {
    final forToday = schedule('today', today);
    final loaded = ScheduleState.loaded(
      upcoming: [item(forToday)],
      completed: const [],
    );
    const removed = ScheduleState.loaded(
      upcoming: [],
      completed: [],
    );
    final createParams = CreateScheduleParams(
      scheduledDate: inThreeDays,
      note: 'talhão 3',
    );
    final updateParams = UpdateScheduleParams(
      id: 'today',
      scheduledDate: inThreeDays,
      note: 'ureia',
    );
    const completeParams = SetScheduleCompletedParams(
      id: 'today',
      completed: true,
    );
    const undoParams = SetScheduleCompletedParams(
      id: 'today',
      completed: false,
    );

    Future<void> loadList() async {
      schedulesController.add([forToday]);
      await flush();
    }

    blocTest<ScheduleCubit, ScheduleState>(
      'sucesso de cada ação não emite estado além da remoção otimista; a '
      'lista vem do stream',
      setUp: () {
        when(
          () => createSchedule(createParams),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => updateSchedule(updateParams),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => setScheduleCompleted(completeParams),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => setScheduleCompleted(undoParams),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => deleteSchedule('today'),
        ).thenAnswer((_) async => const Right(null));
      },
      build: buildCubit,
      act: (cubit) async {
        await loadList();
        await cubit.addSchedule(inThreeDays, note: 'talhão 3');
        await cubit.editSchedule('today', inThreeDays, note: 'ureia');
        await cubit.setCompleted('today', completed: true);
        await cubit.setCompleted('today', completed: false);
        await cubit.removeSchedule('today');
      },
      expect: () => [loaded, removed],
      verify: (_) {
        verify(() => createSchedule(createParams)).called(1);
        verify(() => updateSchedule(updateParams)).called(1);
        verify(() => setScheduleCompleted(completeParams)).called(1);
        verify(() => setScheduleCompleted(undoParams)).called(1);
        verify(() => deleteSchedule('today')).called(1);
      },
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'falha ao criar expõe a falha e mantém a lista',
      setUp: () => when(
        () => createSchedule(createParams),
      ).thenAnswer((_) async => const Left(writeFailure)),
      build: buildCubit,
      act: (cubit) async {
        await loadList();
        await cubit.addSchedule(inThreeDays, note: 'talhão 3');
      },
      expect: () => [loaded, loaded.withActionFailure(writeFailure)],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'falha ao editar expõe a falha e mantém a lista',
      setUp: () => when(
        () => updateSchedule(updateParams),
      ).thenAnswer((_) async => const Left(ValidationFailure('Data inválida'))),
      build: buildCubit,
      act: (cubit) async {
        await loadList();
        await cubit.editSchedule('today', inThreeDays, note: 'ureia');
      },
      expect: () => [
        loaded,
        loaded.withActionFailure(const ValidationFailure('Data inválida')),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'falha ao concluir expõe a falha e mantém a lista',
      setUp: () => when(
        () => setScheduleCompleted(completeParams),
      ).thenAnswer((_) async => const Left(writeFailure)),
      build: buildCubit,
      act: (cubit) async {
        await loadList();
        await cubit.setCompleted('today', completed: true);
      },
      expect: () => [loaded, loaded.withActionFailure(writeFailure)],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'falha ao excluir devolve o item à lista e expõe a falha',
      setUp: () => when(() => deleteSchedule('today')).thenAnswer(
        (_) async => const Left(AuthFailure('É preciso estar logado.')),
      ),
      build: buildCubit,
      act: (cubit) async {
        await loadList();
        await cubit.removeSchedule('today');
      },
      expect: () => [
        loaded,
        removed,
        loaded,
        loaded.withActionFailure(const AuthFailure('É preciso estar logado.')),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'a mesma falha duas vezes limpa antes para o snackbar reaparecer',
      setUp: () => when(
        () => createSchedule(createParams),
      ).thenAnswer((_) async => const Left(writeFailure)),
      build: buildCubit,
      act: (cubit) async {
        await loadList();
        await cubit.addSchedule(inThreeDays, note: 'talhão 3');
        await cubit.addSchedule(inThreeDays, note: 'talhão 3');
      },
      expect: () => [
        loaded,
        loaded.withActionFailure(writeFailure),
        loaded,
        loaded.withActionFailure(writeFailure),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'a mesma falha ao excluir duas vezes expõe a falha nas duas',
      setUp: () => when(
        () => deleteSchedule('today'),
      ).thenAnswer((_) async => const Left(writeFailure)),
      build: buildCubit,
      act: (cubit) async {
        await loadList();
        await cubit.removeSchedule('today');
        await cubit.removeSchedule('today');
      },
      expect: () => [
        loaded,
        removed,
        loaded,
        loaded.withActionFailure(writeFailure),
        removed,
        loaded,
        loaded.withActionFailure(writeFailure),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'a próxima emissão do stream limpa a falha de ação',
      setUp: () => when(
        () => deleteSchedule('today'),
      ).thenAnswer((_) async => const Left(writeFailure)),
      build: buildCubit,
      act: (cubit) async {
        await loadList();
        await cubit.removeSchedule('today');
        schedulesController.add([forToday]);
      },
      expect: () => [
        loaded,
        removed,
        loaded,
        loaded.withActionFailure(writeFailure),
        loaded,
      ],
    );
  });

  group('chuva prevista (SCHEDUI-07)', () {
    final forToday = schedule('today', today);
    final later = schedule('later', inThreeDays);

    blocTest<ScheduleCubit, ScheduleState>(
      'favorável e em risco recebem a chuva do dia',
      build: buildCubit,
      act: (_) async {
        schedulesController.add([forToday, later]);
        await flush();
        forecastController.add(Right(weekForecast(heavyOn: {inThreeDays})));
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [item(forToday), item(later)],
          completed: const [],
        ),
        ScheduleState.loaded(
          upcoming: [
            item(forToday, risk: ScheduleRiskLevel.ok, rainMm: lightRain),
            item(later, risk: ScheduleRiskLevel.atRisk, rainMm: heavyRain),
          ],
          completed: const [],
        ),
      ],
    );

    final pastDue = schedule('past', yesterday);
    final doneToday = schedule('done', today, completed: true);
    final outOfForecast = schedule('out', DateTime(2026, 9, 30));

    DailyForecastPoint day(DateTime date, double rain) => DailyForecastPoint(
      date: date,
      precipitationSum: rain,
      precipitationProbabilityMax: 90,
      temperatureMax: 27,
      temperatureMin: 19,
      windSpeedMax: 10,
      weatherCode: 65,
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'concluído, data passada e dia fora da previsão ficam sem chuva',
      build: buildCubit,
      act: (_) async {
        forecastController.add(
          Right(
            WeatherForecast(
              coordinates: coordinates,
              hourly: const [],
              fetchedAt: DateTime(2026, 9, 22, 6),
              daily: [
                day(yesterday, heavyRain),
                day(today, heavyRain),
                day(inThreeDays, lightRain),
              ],
            ),
          ),
        );
        await flush();
        schedulesController.add([pastDue, doneToday, later, outOfForecast]);
      },
      expect: () => [
        ScheduleState.loaded(
          upcoming: [
            item(pastDue, isPastDue: true),
            item(later, risk: ScheduleRiskLevel.ok, rainMm: lightRain),
            item(outOfForecast),
          ],
          completed: [item(doneToday)],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'antes de a previsão chegar, nenhum item tem chuva',
      build: buildCubit,
      act: (_) => schedulesController.add([forToday, later]),
      expect: () => [
        ScheduleState.loaded(
          upcoming: [item(forToday), item(later)],
          completed: const [],
        ),
      ],
    );
  });

  group('remoção otimista (SCHEDUI-10, SCHEDUI-13)', () {
    final forToday = schedule('today', today);
    final later = schedule('later', inThreeDays);
    final both = ScheduleState.loaded(
      upcoming: [item(forToday), item(later)],
      completed: const [],
    );
    final onlyLater = ScheduleState.loaded(
      upcoming: [item(later)],
      completed: const [],
    );

    Future<void> loadBoth() async {
      schedulesController.add([forToday, later]);
      await flush();
    }

    late ScheduleCubit cubit;
    late Completer<Either<Failure, void>> deleteResult;
    ScheduleState? stateWhenDeleteCalled;
    ScheduleState? stateBeforeDeleteCompleted;

    blocTest<ScheduleCubit, ScheduleState>(
      'emite a lista sem o item antes de chamar o use case',
      setUp: () {
        stateWhenDeleteCalled = null;
        stateBeforeDeleteCompleted = null;
        deleteResult = Completer();
        when(() => deleteSchedule('today')).thenAnswer((_) {
          stateWhenDeleteCalled = cubit.state;
          return deleteResult.future;
        });
      },
      build: () => cubit = buildCubit(),
      act: (cubit) async {
        await loadBoth();
        final pending = cubit.removeSchedule('today');
        await flush();
        stateBeforeDeleteCompleted = cubit.state;
        deleteResult.complete(const Right(null));
        await pending;
      },
      expect: () => [both, onlyLater],
      verify: (_) {
        expect(stateWhenDeleteCalled, onlyLater);
        expect(stateBeforeDeleteCompleted, onlyLater);
        verify(() => deleteSchedule('today')).called(1);
      },
    );

    test(
      'Desfazer durante a exclusão espera ela terminar antes de restaurar',
      () async {
        final deletion = Completer<Either<Failure, void>>();
        when(() => deleteSchedule('today')).thenAnswer((_) => deletion.future);
        when(
          () => restoreSchedule(forToday),
        ).thenAnswer((_) async => const Right(null));
        final cubit = buildCubit();
        await loadBoth();

        final removing = cubit.removeSchedule('today');
        final restoring = cubit.restoreSchedule(forToday);
        await flush();
        verifyNever(() => restoreSchedule(forToday));

        deletion.complete(const Right(null));
        await removing;
        await restoring;
        verify(() => restoreSchedule(forToday)).called(1);
        await cubit.close();
      },
    );

    test(
      'Desfazer depois de uma exclusão que falhou não restaura: o item nem '
      'saiu do banco',
      () async {
        when(
          () => deleteSchedule('today'),
        ).thenAnswer((_) async => const Left(CacheFailure('falhou')));
        final cubit = buildCubit();
        await loadBoth();

        final removing = cubit.removeSchedule('today');
        final restoring = cubit.restoreSchedule(forToday);
        await removing;
        await restoring;

        verifyNever(() => restoreSchedule(forToday));
        await cubit.close();
      },
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'sucesso não emite nada além da remoção, nem quando o stream confirma',
      setUp: () => when(
        () => deleteSchedule('today'),
      ).thenAnswer((_) async => const Right(null)),
      build: buildCubit,
      act: (cubit) async {
        await loadBoth();
        await cubit.removeSchedule('today');
        schedulesController.add([later]);
      },
      expect: () => [both, onlyLater],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'falha devolve o item à lista e expõe a falha',
      setUp: () => when(
        () => deleteSchedule('today'),
      ).thenAnswer((_) async => const Left(writeFailure)),
      build: buildCubit,
      act: (cubit) async {
        await loadBoth();
        await cubit.removeSchedule('today');
      },
      expect: () => [
        both,
        onlyLater,
        both,
        both.withActionFailure(writeFailure),
      ],
    );

    final laterEdited = schedule('later', DateTime(2026, 9, 27));

    blocTest<ScheduleCubit, ScheduleState>(
      'enquanto o stream traz o id, o item segue oculto',
      setUp: () => when(
        () => deleteSchedule('today'),
      ).thenAnswer((_) async => const Right(null)),
      build: buildCubit,
      act: (cubit) async {
        await loadBoth();
        await cubit.removeSchedule('today');
        schedulesController.add([forToday, laterEdited]);
      },
      expect: () => [
        both,
        onlyLater,
        ScheduleState.loaded(
          upcoming: [item(laterEdited)],
          completed: const [],
        ),
      ],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'o id é esquecido quando o stream deixa de trazê-lo',
      setUp: () => when(
        () => deleteSchedule('today'),
      ).thenAnswer((_) async => const Right(null)),
      build: buildCubit,
      act: (cubit) async {
        await loadBoth();
        await cubit.removeSchedule('today');
        schedulesController.add([later]);
        await flush();
        schedulesController.add([forToday, later]);
      },
      expect: () => [both, onlyLater, both],
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'excluir e restaurar o mesmo item em seguida faz ele reaparecer',
      setUp: () {
        when(
          () => deleteSchedule('today'),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => restoreSchedule(forToday),
        ).thenAnswer((_) async => const Right(null));
      },
      build: buildCubit,
      act: (cubit) async {
        await loadBoth();
        await cubit.removeSchedule('today');
        schedulesController.add([later]);
        await flush();
        await cubit.restoreSchedule(forToday);
        schedulesController.add([forToday, later]);
      },
      expect: () => [both, onlyLater, both],
      verify: (_) => verify(() => restoreSchedule(forToday)).called(1),
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'restaurar antes de o stream deixar de trazer o id também faz o item '
      'reaparecer',
      setUp: () {
        when(
          () => deleteSchedule('today'),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => restoreSchedule(forToday),
        ).thenAnswer((_) async => const Right(null));
      },
      build: buildCubit,
      act: (cubit) async {
        await loadBoth();
        await cubit.removeSchedule('today');
        await cubit.restoreSchedule(forToday);
        schedulesController.add([forToday, later]);
      },
      expect: () => [both, onlyLater, both],
    );
  });

  group('restauração (SCHEDUI-12, SCHEDUI-14)', () {
    final later = schedule('later', inThreeDays);
    final loaded = ScheduleState.loaded(
      upcoming: [item(later)],
      completed: const [],
    );
    final deleted = FertilizationSchedule(
      id: 'done',
      scheduledDate: yesterday,
      createdAt: DateTime(2026, 9, 20, 8),
      note: 'ureia no talhão 2',
      completedAt: DateTime(2026, 9, 22, 17),
    );

    Future<void> loadList() async {
      schedulesController.add([later]);
      await flush();
    }

    blocTest<ScheduleCubit, ScheduleState>(
      'chama o use case com o agendamento exato e não emite; o item volta '
      'pelo stream na posição da ordenação',
      setUp: () => when(
        () => restoreSchedule(deleted),
      ).thenAnswer((_) async => const Right(null)),
      build: buildCubit,
      act: (cubit) async {
        await loadList();
        await cubit.restoreSchedule(deleted);
        await flush();
        schedulesController.add([deleted, later]);
      },
      expect: () => [
        loaded,
        ScheduleState.loaded(
          upcoming: [item(later)],
          completed: [item(deleted)],
        ),
      ],
      verify: (_) => verify(() => restoreSchedule(deleted)).called(1),
    );

    blocTest<ScheduleCubit, ScheduleState>(
      'falha expõe a falha e mantém a lista',
      setUp: () => when(
        () => restoreSchedule(deleted),
      ).thenAnswer((_) async => const Left(writeFailure)),
      build: buildCubit,
      act: (cubit) async {
        await loadList();
        await cubit.restoreSchedule(deleted);
      },
      expect: () => [loaded, loaded.withActionFailure(writeFailure)],
    );
  });

  group('close', () {
    test('cancela as assinaturas da lista e da previsão', () async {
      final cubit = buildCubit();
      await flush();
      expect(schedulesController.hasListener, isTrue);
      expect(forecastController.hasListener, isTrue);

      await cubit.close();

      expect(schedulesController.hasListener, isFalse);
      expect(forecastController.hasListener, isFalse);
    });

    test('não busca previsão se fechar antes da localização chegar', () async {
      final location = Completer<Either<Failure, Coordinates>>();
      when(
        () => getCurrentLocation(const NoParams()),
      ).thenAnswer((_) => location.future);
      final cubit = buildCubit();

      await cubit.close();
      location.complete(const Right(coordinates));
      await flush();

      verifyNever(() => getForecast(any()));
    });

    test(
      'não assina a previsão se a localização chega durante o close',
      () async {
        final location = Completer<Either<Failure, Coordinates>>();
        when(
          () => getCurrentLocation(const NoParams()),
        ).thenAnswer((_) => location.future);
        final cubit = buildCubit();
        await flush();

        final closing = cubit.close();
        location.complete(const Right(coordinates));
        await closing;
        await flush();

        verifyNever(() => getForecast(any()));
      },
    );

    test('falha de ação que termina depois do close não emite', () async {
      final result = Completer<Either<Failure, void>>();
      when(() => deleteSchedule('today')).thenAnswer((_) => result.future);
      final cubit = buildCubit();
      final states = <ScheduleState>[];
      final sub = cubit.stream.listen(states.add);
      addTearDown(sub.cancel);

      final pending = cubit.removeSchedule('today');
      await cubit.close();
      result.complete(const Left(writeFailure));

      await expectLater(pending, completes);
      expect(states, isEmpty);
    });
  });
}
