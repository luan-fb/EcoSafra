import 'dart:async';

import 'package:animations/animations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/schedule/presentation/pages/schedule_form_page.dart';
import 'package:ecosafra/features/schedule/presentation/pages/schedule_page.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/animated_check.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_tile.dart';
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
    registerFallbackValue(
      FertilizationSchedule(
        id: 'fallback',
        scheduledDate: DateTime(2026),
        createdAt: DateTime(2026),
      ),
    );
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
    when(() => cubit.restoreSchedule(any())).thenAnswer((_) async {});
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

  Future<void> pumpPage(
    WidgetTester tester, {
    bool disableAnimations = true,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
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
        await tester.tap(find.byIcon(Icons.calendar_today_rounded));
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

        await tester.tap(find.byType(ScheduleTile));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.calendar_today_rounded));
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

        await tester.tap(find.byType(ScheduleTile));
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

  group('container transform', () {
    ScheduleState loadedWith({
      List<ScheduleItem> upcoming = const [],
      List<ScheduleItem> completed = const [],
    }) => ScheduleState.loaded(
      upcoming: upcoming,
      completed: completed,
      window: window,
    );

    testWidgets(
      'SCHEDUI-18: fechar o formulário de criação sem salvar não chama '
      'addSchedule',
      (tester) async {
        stubState(loadedWith());
        await pumpPage(tester);

        await tester.tap(find.text('Agendar'));
        await tester.pumpAndSettle();
        expect(find.byType(ScheduleFormPage), findsOneWidget);

        await tester.tap(find.byTooltip('Cancelar'));
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleFormPage), findsNothing);
        verifyNever(() => cubit.addSchedule(any(), note: any(named: 'note')));
      },
    );

    testWidgets(
      'SCHEDUI-17: salvar a edição com outra observação chama editSchedule',
      (tester) async {
        final target = schedule('s1', window.first, note: 'ureia');
        stubState(loadedWith(upcoming: [upcomingItem(target)]));
        await pumpPage(tester);

        await tester.tap(find.byType(ScheduleTile));
        await tester.pumpAndSettle();

        final form = tester.widget<ScheduleFormPage>(
          find.byType(ScheduleFormPage),
        );
        expect(form.initial, target);
        expect(form.window, window);

        await tester.enterText(find.byType(TextField), 'NPK');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        verify(
          () => cubit.editSchedule('s1', window.first, note: 'NPK'),
        ).called(1);
        verifyNever(() => cubit.addSchedule(any(), note: any(named: 'note')));
      },
    );

    testWidgets(
      'SCHEDUI-17: fechar a edição sem salvar não chama editSchedule',
      (tester) async {
        final target = schedule('s1', window.first, note: 'ureia');
        stubState(loadedWith(upcoming: [upcomingItem(target)]));
        await pumpPage(tester);

        await tester.tap(find.byType(ScheduleTile));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Cancelar'));
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleFormPage), findsNothing);
        verifyNever(
          () => cubit.editSchedule(any(), any(), note: any(named: 'note')),
        );
      },
    );

    testWidgets(
      'tocar no check de um agendamento não concluído conclui sem abrir o '
      'formulário',
      (tester) async {
        stubState(
          loadedWith(upcoming: [upcomingItem(schedule('s1', window.first))]),
        );
        await pumpPage(tester);

        await tester.tap(find.byType(AnimatedCheck));
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleFormPage), findsNothing);
        verify(() => cubit.setCompleted('s1', completed: true)).called(1);
      },
    );

    testWidgets(
      'AGD-27: tocar num agendamento concluído não abre o formulário',
      (tester) async {
        stubState(
          loadedWith(
            completed: [
              completedItem(schedule('s2', today, completed: true)),
            ],
          ),
        );
        await pumpPage(tester);

        await tester.tap(find.byType(ScheduleTile));
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleFormPage), findsNothing);
        expect(find.text('Editar agendamento'), findsNothing);
      },
    );

    testWidgets(
      'SCHEDUI-17: sem redução de movimento, o card se expande em '
      'AppMotion.slow, com quadros intermediários',
      (tester) async {
        final target = schedule('s1', window.first);
        stubState(loadedWith(upcoming: [upcomingItem(target)]));
        await pumpPage(tester, disableAnimations: false);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ScheduleTile));
        await tester.pump();
        await tester.pump(AppMotion.slow ~/ 2);

        final route = ModalRoute.of(
          tester.element(find.byType(ScheduleFormPage)),
        )!;
        final screen =
            Offset.zero &
            tester.view.physicalSize / tester.view.devicePixelRatio;
        expect(route.transitionDuration, AppMotion.slow);
        expect(route.animation!.value, inExclusiveRange(0, 1));
        // O formulário é desenhado escalado dentro do retângulo do card.
        expect(tester.getRect(find.byType(ScheduleFormPage)), isNot(screen));

        await tester.pumpAndSettle();
        expect(route.animation!.status, AnimationStatus.completed);
        expect(tester.getRect(find.byType(ScheduleFormPage)), screen);
      },
    );

    testWidgets(
      'SCHEDUI-18: sem redução de movimento, o botão "Agendar" se expande em '
      'AppMotion.slow',
      (tester) async {
        // Com um item, e não vazia: a animação do estado vazio roda em loop.
        stubState(
          loadedWith(upcoming: [upcomingItem(schedule('s1', window.first))]),
        );
        await pumpPage(tester, disableAnimations: false);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Agendar'));
        await tester.pump();
        await tester.pump(AppMotion.slow ~/ 2);

        final route = ModalRoute.of(
          tester.element(find.byType(ScheduleFormPage)),
        )!;
        expect(route.transitionDuration, AppMotion.slow);
        expect(route.animation!.value, inExclusiveRange(0, 1));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'SCHEDUI-21: com redução de movimento, o formulário abre e fecha sem '
      'quadros intermediários',
      (tester) async {
        final target = schedule('s1', window.first);
        stubState(loadedWith(upcoming: [upcomingItem(target)]));
        await pumpPage(tester);

        final containers = tester.widgetList<OpenContainer<ScheduleFormResult>>(
          find.byType(OpenContainer<ScheduleFormResult>),
        );
        expect(containers, isNotEmpty);
        for (final container in containers) {
          expect(container.transitionDuration, Duration.zero);
        }

        await tester.tap(find.byType(ScheduleTile));
        await tester.pump();

        final route = ModalRoute.of(
          tester.element(find.byType(ScheduleFormPage)),
        )!;
        final screen =
            Offset.zero &
            tester.view.physicalSize / tester.view.devicePixelRatio;
        expect(route.animation!.status, AnimationStatus.completed);
        expect(tester.getRect(find.byType(ScheduleFormPage)), screen);

        await tester.tap(find.byTooltip('Cancelar'));
        await tester.pump();

        expect(route.animation!.status, AnimationStatus.dismissed);
        await tester.pump();
        expect(find.byType(ScheduleFormPage), findsNothing);
      },
    );
  });

  group('excluir com swipe e Desfazer', () {
    final upcomingTarget = schedule('s1', window.first, note: 'ureia');
    final completedTarget = schedule('s2', today, completed: true);

    /// Estado com um próximo e um concluído. `removeSchedule` emite o estado
    /// sem o item, como a remoção otimista do cubit real: o `Dismissible`
    /// exige o item fora da árvore depois de dispensado.
    void stubRemovable() {
      var current = ScheduleState.loaded(
        upcoming: [upcomingItem(upcomingTarget)],
        completed: [completedItem(completedTarget)],
        window: window,
      );
      final states = StreamController<ScheduleState>();
      addTearDown(states.close);
      whenListen(cubit, states.stream, initialState: current);
      when(() => cubit.removeSchedule(any())).thenAnswer((invocation) async {
        final id = invocation.positionalArguments.single as String;
        current = ScheduleState.loaded(
          upcoming: [
            for (final item in current.upcoming)
              if (item.schedule.id != id) item,
          ],
          completed: [
            for (final item in current.completed)
              if (item.schedule.id != id) item,
          ],
          window: window,
        );
        states.add(current);
      });
    }

    Finder cardOf(FertilizationSchedule target) => find.byWidgetPredicate(
      (widget) => widget is ScheduleTile && widget.item.schedule == target,
    );

    Future<void> swipeLeft(WidgetTester tester, Finder card) async {
      await tester.drag(card, const Offset(-600, 0));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'SCHEDUI-10, 11: swipe completo para a esquerda tira o card, chama '
      'removeSchedule e mostra o snackbar com Desfazer',
      (tester) async {
        stubRemovable();
        await pumpPage(tester);

        await swipeLeft(tester, cardOf(upcomingTarget));

        verify(() => cubit.removeSchedule('s1')).called(1);
        expect(cardOf(upcomingTarget), findsNothing);
        expect(find.text('Agendamento excluído'), findsOneWidget);
        expect(find.widgetWithText(SnackBarAction, 'Desfazer'), findsOneWidget);
        verifyNever(() => cubit.restoreSchedule(any()));
      },
    );

    testWidgets(
      'SCHEDUI-10: o fundo do swipe é AppColors.danger com a lixeira',
      (tester) async {
        stubRemovable();
        await pumpPage(tester);

        final dismissible = tester.widget<Dismissible>(
          find.byKey(const ValueKey('s1')),
        );
        expect(dismissible.direction, DismissDirection.endToStart);

        await tester.drag(cardOf(upcomingTarget), const Offset(-80, 0));
        await tester.pump();

        expect(find.byIcon(Icons.delete_rounded), findsOneWidget);
        final background = tester.widget<DecoratedBox>(
          find
              .ancestor(
                of: find.byIcon(Icons.delete_rounded),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        expect(
          (background.decoration as BoxDecoration).color,
          AppColors.danger,
        );
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'SCHEDUI-12: tocar em "Desfazer" chama restoreSchedule com o '
      'agendamento exato',
      (tester) async {
        stubRemovable();
        await pumpPage(tester);

        await swipeLeft(tester, cardOf(upcomingTarget));
        await tester.tap(find.text('Desfazer'));
        await tester.pumpAndSettle();

        final restored =
            verify(() => cubit.restoreSchedule(captureAny())).captured.single
                as FertilizationSchedule;
        expect(restored, same(upcomingTarget));
        expect(restored.note, 'ureia');
        expect(find.text('Agendamento excluído'), findsNothing);
      },
    );

    testWidgets(
      'edge case: swipe num concluído exclui com o mesmo Desfazer',
      (tester) async {
        stubRemovable();
        await pumpPage(tester);

        await swipeLeft(tester, cardOf(completedTarget));

        verify(() => cubit.removeSchedule('s2')).called(1);
        expect(cardOf(completedTarget), findsNothing);
        expect(find.text('Agendamento excluído'), findsOneWidget);

        await tester.tap(find.text('Desfazer'));
        await tester.pumpAndSettle();

        verify(() => cubit.restoreSchedule(completedTarget)).called(1);
      },
    );

    testWidgets(
      'edge case: arrasto abaixo do limiar devolve o card sem excluir',
      (tester) async {
        stubRemovable();
        await pumpPage(tester);

        await tester.drag(cardOf(upcomingTarget), const Offset(-60, 0));
        await tester.pumpAndSettle();

        verifyNever(() => cubit.removeSchedule(any()));
        expect(cardOf(upcomingTarget), findsOneWidget);
        expect(find.text('Agendamento excluído'), findsNothing);
      },
    );

    testWidgets(
      'edge case: arrasto para a direita não exclui',
      (tester) async {
        stubRemovable();
        await pumpPage(tester);

        await tester.drag(cardOf(upcomingTarget), const Offset(600, 0));
        await tester.pumpAndSettle();

        verifyNever(() => cubit.removeSchedule(any()));
        expect(cardOf(upcomingTarget), findsOneWidget);
      },
    );

    testWidgets(
      'SCHEDUI-15: a ação de acessibilidade "Excluir" faz o mesmo fluxo, '
      'sem gesto',
      (tester) async {
        stubRemovable();
        await pumpPage(tester);

        tester.widget<ScheduleTile>(cardOf(upcomingTarget)).onDelete();
        await tester.pumpAndSettle();

        verify(() => cubit.removeSchedule('s1')).called(1);
        expect(cardOf(upcomingTarget), findsNothing);
        expect(find.text('Agendamento excluído'), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);

        await tester.tap(find.text('Desfazer'));
        await tester.pumpAndSettle();

        final restored =
            verify(() => cubit.restoreSchedule(captureAny())).captured.single
                as FertilizationSchedule;
        expect(restored, same(upcomingTarget));
      },
    );

    testWidgets(
      'edge case: duas exclusões seguidas deixam só o snackbar da última',
      (tester) async {
        stubRemovable();
        await pumpPage(tester);

        await swipeLeft(tester, cardOf(upcomingTarget));
        await swipeLeft(tester, cardOf(completedTarget));

        expect(find.text('Agendamento excluído'), findsOneWidget);

        await tester.tap(find.text('Desfazer'));
        await tester.pumpAndSettle();

        verify(() => cubit.restoreSchedule(completedTarget)).called(1);
        verifyNever(() => cubit.restoreSchedule(upcomingTarget));
      },
    );

    testWidgets(
      'SCHEDUI-11: o snackbar some sozinho depois de 4 segundos',
      (tester) async {
        stubRemovable();
        await pumpPage(tester);

        await swipeLeft(tester, cardOf(upcomingTarget));
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.duration, const Duration(seconds: 4));

        await tester.pump(const Duration(seconds: 3));
        expect(find.text('Agendamento excluído'), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(find.text('Agendamento excluído'), findsNothing);
        verifyNever(() => cubit.restoreSchedule(any()));
      },
    );

    Future<void> pumpPageAsRoute(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );
      unawaited(
        Navigator.of(tester.element(find.byType(Scaffold))).push(
          MaterialPageRoute<void>(
            builder: (_) => MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: BlocProvider<ScheduleCubit>.value(
                value: cubit,
                child: const ScheduleView(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'SCHEDUI-16: fechar a tela com o snackbar visível esconde o snackbar',
      (tester) async {
        stubRemovable();
        await pumpPageAsRoute(tester);

        await swipeLeft(tester, cardOf(upcomingTarget));
        expect(find.text('Agendamento excluído'), findsOneWidget);

        Navigator.of(tester.element(find.byType(ScheduleView))).pop();
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleView), findsNothing);
        expect(find.text('Agendamento excluído'), findsNothing);
        expect(find.text('Desfazer'), findsNothing);
      },
    );

    testWidgets(
      'SCHEDUI-16: com navegação acessível (snackbar sem timeout), fechar a '
      'tela também esconde o snackbar',
      (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(accessibleNavigation: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        stubRemovable();
        await pumpPageAsRoute(tester);

        await swipeLeft(tester, cardOf(upcomingTarget));
        expect(find.text('Agendamento excluído'), findsOneWidget);

        Navigator.of(tester.element(find.byType(ScheduleView))).pop();
        await tester.pumpAndSettle();

        expect(find.text('Agendamento excluído'), findsNothing);
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
