import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/app/widgets/app_drawer.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_state.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/schedule/presentation/pages/schedule_page.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/animated_check.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_empty_animation.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_form_sheet.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_tile.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockScheduleCubit extends MockCubit<ScheduleState>
    implements ScheduleCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

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
  late MockAuthCubit authCubit;

  setUp(() {
    cubit = MockScheduleCubit();
    authCubit = MockAuthCubit();
    // O `AppDrawer` lê o usuário logado; sem sessão nos testes, cai no
    // nome padrão (mesmo estado usado nos testes do painel).
    when(() => authCubit.state).thenReturn(const AuthState.unauthenticated());
    when(
      () => cubit.addSchedule(any(), note: any(named: 'note')),
    ).thenAnswer((_) async {});
    when(
      () => cubit.editSchedule(any(), any(), note: any(named: 'note')),
    ).thenAnswer((_) async {});
    when(
      () => cubit.setCompleted(any(), completed: any(named: 'completed')),
    ).thenAnswer((_) async => true);
    when(() => cubit.removeSchedule(any())).thenAnswer((_) async {});
    when(() => cubit.retry()).thenAnswer((_) async {});
    when(() => cubit.restoreSchedule(any())).thenAnswer((_) async {});
    when(() => cubit.currentWindow()).thenReturn(window);
    when(() => cubit.isClosed).thenReturn(false);
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
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ScheduleCubit>.value(value: cubit),
              BlocProvider<AuthCubit>.value(value: authCubit),
            ],
            child: const ScheduleView(),
          ),
        ),
      ),
    );
  }

  group('seções', () {
    testWidgets(
      'mostra "Próximos" e "Concluídos" quando há dos dois',
      (tester) async {
        stubState(
          ScheduleState.loaded(
            upcoming: [upcomingItem(schedule('s1', today))],
            completed: [completedItem(schedule('s2', today, completed: true))],
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
        const ScheduleState.loaded(
          upcoming: [],
          completed: [],
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
      expect(find.byType(ScheduleEmptyAnimation), findsOneWidget);
    },
  );

  group('FAB', () {
    testWidgets(
      'toque no FAB abre o formulário e confirmar chama addSchedule',
      (tester) async {
        stubState(
          const ScheduleState.loaded(
            upcoming: [],
            completed: [],
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
      'calculada pelo cubit na hora de abrir',
      (tester) async {
        stubState(
          const ScheduleState.loaded(
            upcoming: [],
            completed: [],
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

    testWidgets('erro oferece "Tentar de novo", que chama retry', (
      tester,
    ) async {
      stubState(const ScheduleState.error(CacheFailure('falhou')));
      await pumpPage(tester);

      await tester.tap(find.text('Tentar de novo'));
      await tester.pump();

      verify(() => cubit.retry()).called(1);
    });

    testWidgets('FAB ausente em erro', (tester) async {
      stubState(const ScheduleState.error(CacheFailure('falhou')));
      await pumpPage(tester);

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Agendar'), findsNothing);
    });
  });

  group('editar', () {
    testWidgets(
      'edge case: virada do dia com a tela aberta, a edição também usa a '
      'janela calculada pelo cubit na hora de abrir',
      (tester) async {
        final target = schedule('s1', window.first);
        stubState(
          ScheduleState.loaded(
            upcoming: [upcomingItem(target)],
            completed: const [],
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
      'tocar num agendamento não concluído abre o formulário preenchido',
      (tester) async {
        final target = schedule('s1', window.last, note: 'ureia');
        stubState(
          ScheduleState.loaded(
            upcoming: [upcomingItem(target)],
            completed: const [],
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

  // A duração e a curva do bottom sheet (`AppMotion.slow`/`noAnimation`) são
  // do `ScheduleFormSheet.show` e ficam testadas junto dele
  // (`schedule_form_sheet_test.dart`); aqui só o fluxo de abrir e salvar.
  group('formulário em bottom sheet', () {
    ScheduleState loadedWith({
      List<ScheduleItem> upcoming = const [],
      List<ScheduleItem> completed = const [],
    }) => ScheduleState.loaded(
      upcoming: upcoming,
      completed: completed,
    );

    testWidgets(
      'fechar o formulário de criação sem salvar não chama '
      'addSchedule',
      (tester) async {
        stubState(loadedWith());
        await pumpPage(tester);

        await tester.tap(find.text('Agendar'));
        await tester.pumpAndSettle();
        expect(find.byType(ScheduleFormSheet), findsOneWidget);
        expect(
          ModalRoute.of(tester.element(find.byType(ScheduleFormSheet))),
          isA<ModalBottomSheetRoute<ScheduleFormResult>>(),
        );

        await tester.tap(find.byTooltip('Cancelar'));
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleFormSheet), findsNothing);
        verifyNever(() => cubit.addSchedule(any(), note: any(named: 'note')));
      },
    );

    testWidgets(
      'salvar a edição com outra observação chama editSchedule',
      (tester) async {
        final target = schedule('s1', window.first, note: 'ureia');
        stubState(loadedWith(upcoming: [upcomingItem(target)]));
        await pumpPage(tester);

        await tester.tap(find.byType(ScheduleTile));
        await tester.pumpAndSettle();

        final form = tester.widget<ScheduleFormSheet>(
          find.byType(ScheduleFormSheet),
        );
        expect(form.initial, upcomingItem(target));
        expect(form.window, window);
        expect(
          ModalRoute.of(tester.element(find.byType(ScheduleFormSheet))),
          isA<ModalBottomSheetRoute<ScheduleFormResult>>(),
        );

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
      'fechar a edição sem salvar não chama editSchedule',
      (tester) async {
        final target = schedule('s1', window.first, note: 'ureia');
        stubState(loadedWith(upcoming: [upcomingItem(target)]));
        await pumpPage(tester);

        await tester.tap(find.byType(ScheduleTile));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Cancelar'));
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleFormSheet), findsNothing);
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

        expect(find.byType(ScheduleFormSheet), findsNothing);
        verify(() => cubit.setCompleted('s1', completed: true)).called(1);
      },
    );

    testWidgets(
      'tocar num agendamento concluído não abre o formulário',
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

        expect(find.byType(ScheduleFormSheet), findsNothing);
        expect(find.text('Editar agendamento'), findsNothing);
      },
    );
  });

  testWidgets(
    'a Agenda mostra o AppDrawer com o item "Agenda" selecionado',
    (tester) async {
      stubState(
        const ScheduleState.loaded(
          upcoming: [],
          completed: [],
        ),
      );
      await pumpPage(tester);

      // Fechado, o `DrawerController` nem constrói o conteúdo do drawer
      // (só a faixa de arrasto da borda): é preciso abri-lo pra achar o
      // `AppDrawer`.
      await tester.tap(find.byType(DrawerButton));
      await tester.pumpAndSettle();

      ListTile tileOf(String label) => tester.widget<ListTile>(
        find.descendant(
          of: find.byType(AppDrawer),
          matching: find.widgetWithText(ListTile, label),
        ),
      );
      expect(tileOf('Agenda').selected, isTrue);
      expect(tileOf('Painel').selected, isFalse);
    },
  );

  group('concluir e desfazer', () {
    // O item troca de seção ao ser concluído; o card segura a conclusão na
    // seção de origem até o check terminar de se desenhar.
    final target = schedule('s1', window.first);

    Future<void> pumpWithUpcoming(
      WidgetTester tester, {
      bool disableAnimations = false,
    }) async {
      stubState(
        ScheduleState.loaded(
          upcoming: [upcomingItem(target)],
          completed: const [],
        ),
      );
      await pumpPage(tester, disableAnimations: disableAnimations);
      await tester.pumpAndSettle();
    }

    AnimatedCheck check(WidgetTester tester) =>
        tester.widget<AnimatedCheck>(find.byType(AnimatedCheck));

    testWidgets(
      'o check se desenha no próprio card e só grava em '
      'AppMotion.medium',
      (tester) async {
        await pumpWithUpcoming(tester);
        final checkState = tester.state(find.byType(AnimatedCheck));

        await tester.tap(find.byType(AnimatedCheck));
        await tester.pump();
        await tester.pump(AppMotion.medium ~/ 2);

        // Mesmo `State`: o check anima de 0 a 1 em vez de nascer marcado.
        expect(tester.state(find.byType(AnimatedCheck)), same(checkState));
        expect(check(tester).value, isTrue);
        verifyNever(
          () => cubit.setCompleted(any(), completed: any(named: 'completed')),
        );

        await tester.pump(AppMotion.medium ~/ 2);
        verify(() => cubit.setCompleted('s1', completed: true)).called(1);
      },
    );

    testWidgets(
      'ao desmarcar um concluído, o card não abre a edição antes de gravar',
      (tester) async {
        stubState(
          ScheduleState.loaded(
            upcoming: const [],
            completed: [completedItem(schedule('s2', today, completed: true))],
          ),
        );
        await pumpPage(tester, disableAnimations: false);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(AnimatedCheck));
        await tester.pump(AppMotion.medium ~/ 3);
        await tester.tap(find.byType(ScheduleTile), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleFormSheet), findsNothing);
        verify(() => cubit.setCompleted('s2', completed: false)).called(1);
      },
    );

    testWidgets(
      'tocar de novo durante a animação desfaz sem gravar',
      (tester) async {
        await pumpWithUpcoming(tester);

        await tester.tap(find.byType(AnimatedCheck));
        await tester.pump(AppMotion.medium ~/ 3);
        await tester.tap(find.byType(AnimatedCheck));
        await tester.pumpAndSettle();

        expect(check(tester).value, isFalse);
        verifyNever(
          () => cubit.setCompleted(any(), completed: any(named: 'completed')),
        );
      },
    );

    testWidgets(
      'com a gravação já enviada, um novo toque é ignorado',
      (tester) async {
        final saving = Completer<bool>();
        when(
          () => cubit.setCompleted(any(), completed: any(named: 'completed')),
        ).thenAnswer((_) => saving.future);
        await pumpWithUpcoming(tester);

        await tester.tap(find.byType(AnimatedCheck));
        await tester.pump();
        await tester.pump(AppMotion.medium);
        verify(() => cubit.setCompleted('s1', completed: true)).called(1);

        await tester.tap(find.byType(AnimatedCheck));
        await tester.pumpAndSettle();

        expect(check(tester).value, isTrue);
        verifyNever(
          () => cubit.setCompleted(any(), completed: any(named: 'completed')),
        );
        saving.complete(true);
      },
    );

    testWidgets(
      'se a gravação falha, o check volta a desmarcado',
      (tester) async {
        when(
          () => cubit.setCompleted(any(), completed: any(named: 'completed')),
        ).thenAnswer((_) async => false);
        await pumpWithUpcoming(tester);

        await tester.tap(find.byType(AnimatedCheck));
        await tester.pumpAndSettle();

        verify(() => cubit.setCompleted('s1', completed: true)).called(1);
        expect(check(tester).value, isFalse);
      },
    );

    testWidgets(
      'com redução de movimento, grava na hora',
      (tester) async {
        await pumpWithUpcoming(tester, disableAnimations: true);

        await tester.tap(find.byType(AnimatedCheck));
        await tester.pump();

        verify(() => cubit.setCompleted('s1', completed: true)).called(1);
      },
    );

    testWidgets(
      'sair da tela no meio da animação grava mesmo assim',
      (tester) async {
        await pumpWithUpcoming(tester);

        await tester.tap(find.byType(AnimatedCheck));
        await tester.pump();
        await tester.pumpWidget(const SizedBox.shrink());

        verify(() => cubit.setCompleted('s1', completed: true)).called(1);
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
      'swipe completo para a esquerda tira o card, chama '
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
      'com a conclusão pendente, o card não aceita o swipe',
      (tester) async {
        stubRemovable();
        await pumpPage(tester, disableAnimations: false);
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: cardOf(upcomingTarget),
            matching: find.byType(AnimatedCheck),
          ),
        );
        await tester.pump();
        // Pela chave: com a conclusão exibida, o item do tile já difere do
        // agendamento original.
        await tester.drag(
          find.byKey(const ValueKey('s1')).first,
          const Offset(-600, 0),
        );
        await tester.pumpAndSettle();

        verifyNever(() => cubit.removeSchedule(any()));
        verify(() => cubit.setCompleted('s1', completed: true)).called(1);
      },
    );

    testWidgets(
      'o fundo do swipe é AppColors.danger com a lixeira',
      (tester) async {
        stubRemovable();
        await pumpPage(tester);

        final dismissible = tester.widget<Dismissible>(
          find.ancestor(
            of: cardOf(upcomingTarget),
            matching: find.byType(Dismissible),
          ),
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
      'tocar em "Desfazer" chama restoreSchedule com o '
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
      'a ação de acessibilidade "Excluir" faz o mesmo fluxo, '
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
      'o snackbar some sozinho depois de 4 segundos',
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
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<ScheduleCubit>.value(value: cubit),
                  BlocProvider<AuthCubit>.value(value: authCubit),
                ],
                child: const ScheduleView(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'fechar a tela com o snackbar visível esconde o snackbar',
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
      'com navegação acessível (snackbar sem timeout), fechar a '
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

  group('voltar do sistema', () {
    // Com `goNamed`, a Agenda é a única rota da pilha: sem o `PopScope`,
    // este voltar fecharia o app em vez de ir ao Painel. Roteador real,
    // como no teste do aviso do painel: prova o destino da navegação.
    Future<void> pumpWithRouter(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: AppRoute.schedule.path,
        routes: [
          GoRoute(
            path: AppRoute.dashboard.path,
            name: AppRoute.dashboard.name,
            builder: (_, _) => const Text('painel-aberto'),
          ),
          GoRoute(
            path: AppRoute.schedule.path,
            name: AppRoute.schedule.name,
            builder: (_, _) => MultiBlocProvider(
              providers: [
                BlocProvider<ScheduleCubit>.value(value: cubit),
                BlocProvider<AuthCubit>.value(value: authCubit),
              ],
              child: const ScheduleView(),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();
    }

    // Com um item, e não vazia: a animação do estado vazio roda em loop e
    // nunca deixaria o `pumpAndSettle` assentar.
    ScheduleState loadedWithOneUpcoming() => ScheduleState.loaded(
      upcoming: [upcomingItem(schedule('s1', window.first))],
      completed: const [],
    );

    testWidgets(
      'o voltar na Agenda (sem sheet) navega para o Painel',
      (tester) async {
        stubState(loadedWithOneUpcoming());
        await pumpWithRouter(tester);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('painel-aberto'), findsOneWidget);
        expect(find.byType(ScheduleView), findsNothing);
      },
    );

    testWidgets(
      'com o sheet aberto, o voltar fecha só o sheet',
      (tester) async {
        stubState(loadedWithOneUpcoming());
        await pumpWithRouter(tester);

        await tester.tap(find.text('Agendar'));
        await tester.pumpAndSettle();
        expect(find.byType(ScheduleFormSheet), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleFormSheet), findsNothing);
        expect(find.byType(ScheduleView), findsOneWidget);
        expect(find.text('painel-aberto'), findsNothing);
      },
    );

    testWidgets(
      'com o menu aberto, o voltar fecha só o menu',
      (tester) async {
        stubState(loadedWithOneUpcoming());
        await pumpWithRouter(tester);

        await tester.tap(find.byType(DrawerButton));
        await tester.pumpAndSettle();
        expect(find.byType(AppDrawer), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.byType(AppDrawer), findsNothing);
        expect(find.byType(ScheduleView), findsOneWidget);
        expect(find.text('painel-aberto'), findsNothing);
      },
    );
  });

  testWidgets(
    'falha de ação mostra snackbar e mantém a lista',
    (tester) async {
      final loaded = ScheduleState.loaded(
        upcoming: [upcomingItem(schedule('s1', today))],
        completed: const [],
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
