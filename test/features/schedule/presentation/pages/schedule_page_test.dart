import 'package:bloc_test/bloc_test.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/schedule/presentation/pages/schedule_page.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockScheduleCubit extends MockCubit<ScheduleState>
    implements ScheduleCubit {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    // Tema real do app: o bug de largura infinita dos botões só aparecia
    // com ele.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final today = DateTime(2026, 9, 23);
  final window = SchedulingWindow.startingAt(today);

  late MockScheduleCubit cubit;

  setUp(() {
    cubit = MockScheduleCubit();
    when(
      () => cubit.addSchedule(any(), note: any(named: 'note')),
    ).thenAnswer((_) async {});
    when(
      () => cubit.editSchedule(any(), any(), note: any(named: 'note')),
    ).thenAnswer((_) async {});
    when(
      () => cubit.setCompleted(any(), completed: any(named: 'completed')),
    ).thenAnswer((_) async {});
    when(() => cubit.removeSchedule(any())).thenAnswer((_) async {});
    when(() => cubit.currentWindow()).thenReturn(window);
  });

  FertilizationSchedule schedule(
    String id,
    DateTime date, {
    String? note,
    bool completed = false,
  }) => FertilizationSchedule(
    id: id,
    scheduledDate: date,
    createdAt: today,
    note: note,
    completedAt: completed ? today : null,
  );

  ScheduleItem upcomingItem(FertilizationSchedule schedule) => ScheduleItem(
    schedule: schedule,
    risk: ScheduleRiskLevel.ok,
    isPastDue: false,
  );

  ScheduleItem completedItem(FertilizationSchedule schedule) => ScheduleItem(
    schedule: schedule,
    risk: ScheduleRiskLevel.unknown,
    isPastDue: false,
  );

  void stubState(ScheduleState state) {
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, Stream.value(state), initialState: state);
  }

  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: BlocProvider<ScheduleCubit>.value(
            value: cubit,
            child: const ScheduleView(),
          ),
        ),
      ),
    );
  }

  group('seções', () {
    testWidgets(
      'AGD-08: mostra "Próximos" e "Concluídos" quando há dos dois',
      (tester) async {
        stubState(
          ScheduleState.loaded(
            upcoming: [upcomingItem(schedule('s1', today))],
            completed: [completedItem(schedule('s2', today, completed: true))],
            window: window,
          ),
        );
        await pumpPage(tester);

        expect(find.text('Próximos'), findsOneWidget);
        expect(find.text('Concluídos'), findsOneWidget);
      },
    );

    testWidgets(
      'seção vazia não aparece: só "Próximos" quando não há concluídos',
      (tester) async {
        stubState(
          ScheduleState.loaded(
            upcoming: [upcomingItem(schedule('s1', today))],
            completed: const [],
            window: window,
          ),
        );
        await pumpPage(tester);

        expect(find.text('Próximos'), findsOneWidget);
        expect(find.text('Concluídos'), findsNothing);
      },
    );

    testWidgets(
      'seção vazia não aparece: só "Concluídos" quando não há próximos',
      (tester) async {
        stubState(
          ScheduleState.loaded(
            upcoming: const [],
            completed: [completedItem(schedule('s2', today, completed: true))],
            window: window,
          ),
        );
        await pumpPage(tester);

        expect(find.text('Próximos'), findsNothing);
        expect(find.text('Concluídos'), findsOneWidget);
      },
    );
  });

  testWidgets(
    'estado vazio geral: sem nenhum agendamento',
    (tester) async {
      stubState(
        ScheduleState.loaded(
          upcoming: const [],
          completed: const [],
          window: window,
        ),
      );
      await pumpPage(tester);

      expect(
        find.text(
          'Nenhum agendamento ainda. Toque em "Agendar" para planejar sua próxima aplicação.',
        ),
        findsOneWidget,
      );
      expect(find.text('Próximos'), findsNothing);
      expect(find.text('Concluídos'), findsNothing);
    },
  );

  group('FAB', () {
    testWidgets(
      'AGD-01: toque no FAB abre o formulário e confirmar chama addSchedule',
      (tester) async {
        stubState(
          ScheduleState.loaded(
            upcoming: const [],
            completed: const [],
            window: window,
          ),
        );
        await pumpPage(tester);

        await tester.tap(find.text('Agendar'));
        await tester.pumpAndSettle();

        expect(find.text('Novo agendamento'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'talhão 3');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        verify(
          () => cubit.addSchedule(window.first, note: 'talhão 3'),
        ).called(1);
      },
    );

    testWidgets(
      'edge case: virada do dia com a tela aberta, o seletor usa a janela '
      'atual e não a do estado',
      (tester) async {
        final yesterdayWindow = SchedulingWindow.startingAt(
          today.subtract(const Duration(days: 1)),
        );
        stubState(
          ScheduleState.loaded(
            upcoming: const [],
            completed: const [],
            window: yesterdayWindow,
          ),
        );
        await pumpPage(tester);

        await tester.tap(find.text('Agendar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Data da aplicação'));
        await tester.pumpAndSettle();

        final picker = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        expect(picker.firstDate, window.first);
        expect(picker.lastDate, window.last);
      },
    );

    testWidgets('FAB ausente em erro', (tester) async {
      stubState(ScheduleState.error(const CacheFailure('falhou'), window));
      await pumpPage(tester);

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Agendar'), findsNothing);
    });
  });

  group('editar', () {
    testWidgets(
      'edge case: virada do dia com a tela aberta, a edição também usa a '
      'janela atual e não a do estado',
      (tester) async {
        final yesterdayWindow = SchedulingWindow.startingAt(
          today.subtract(const Duration(days: 1)),
        );
        final target = schedule('s1', window.first);
        stubState(
          ScheduleState.loaded(
            upcoming: [upcomingItem(target)],
            completed: const [],
            window: yesterdayWindow,
          ),
        );
        await pumpPage(tester);

        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Data da aplicação'));
        await tester.pumpAndSettle();

        final picker = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        expect(picker.firstDate, window.first);
        expect(picker.lastDate, window.last);
      },
    );

    testWidgets(
      'AGD-24: tocar num agendamento não concluído abre o formulário preenchido',
      (tester) async {
        final target = schedule('s1', window.last, note: 'ureia');
        stubState(
          ScheduleState.loaded(
            upcoming: [upcomingItem(target)],
            completed: const [],
            window: window,
          ),
        );
        await pumpPage(tester);

        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        expect(find.text('Editar agendamento'), findsOneWidget);
        expect(find.text('ureia'), findsWidgets);

        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        verify(
          () => cubit.editSchedule('s1', window.last, note: 'ureia'),
        ).called(1);
      },
    );
  });

  group('excluir', () {
    testWidgets(
      'AGD-31: cancelar o diálogo de exclusão mantém o agendamento',
      (tester) async {
        stubState(
          ScheduleState.loaded(
            upcoming: [upcomingItem(schedule('s1', today))],
            completed: const [],
            window: window,
          ),
        );
        await pumpPage(tester);

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();

        expect(find.text('Excluir agendamento?'), findsOneWidget);

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        verifyNever(() => cubit.removeSchedule(any()));
      },
    );

    testWidgets(
      'AGD-30: confirmar o diálogo de exclusão chama removeSchedule',
      (tester) async {
        stubState(
          ScheduleState.loaded(
            upcoming: [upcomingItem(schedule('s1', today))],
            completed: const [],
            window: window,
          ),
        );
        await pumpPage(tester);

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Excluir').last);
        await tester.pumpAndSettle();

        verify(() => cubit.removeSchedule('s1')).called(1);
      },
    );
  });

  testWidgets(
    'AGD-12: falha de ação mostra snackbar e mantém a lista',
    (tester) async {
      final loaded = ScheduleState.loaded(
        upcoming: [upcomingItem(schedule('s1', today))],
        completed: const [],
        window: window,
      );
      final withFailure = loaded.withActionFailure(
        const CacheFailure('Não foi possível salvar o agendamento.'),
      );
      when(() => cubit.state).thenReturn(loaded);
      whenListen(
        cubit,
        Stream.fromIterable([loaded, withFailure]),
        initialState: loaded,
      );
      await pumpPage(tester);
      await tester.pump();

      expect(
        find.text('Não foi possível salvar o agendamento.'),
        findsOneWidget,
      );
      expect(find.text('Próximos'), findsOneWidget);
    },
  );
}
