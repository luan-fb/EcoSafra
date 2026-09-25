import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/core/theme/color_contrast.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/animated_check.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_date_block.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_tile.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // 23/09/2026 é uma quarta-feira.
  final today = DateTime(2026, 9, 23);

  FertilizationSchedule schedule({
    DateTime? scheduledDate,
    String? note,
    bool completed = false,
  }) => FertilizationSchedule(
    id: 's1',
    scheduledDate: scheduledDate ?? today,
    createdAt: today,
    note: note,
    completedAt: completed ? today : null,
  );

  Future<void> pumpTile(
    WidgetTester tester,
    ScheduleItem item, {
    VoidCallback? onEdit,
    ValueChanged<bool>? onToggleCompleted,
    VoidCallback? onDelete,
    ThemeData? theme,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ScheduleTile(
            item: item,
            onEdit: onEdit ?? () {},
            onToggleCompleted: onToggleCompleted ?? (_) {},
            onDelete: onDelete ?? () {},
          ),
        ),
      ),
    );
  }

  ScheduleDateBlock dateBlockOf(WidgetTester tester) =>
      tester.widget<ScheduleDateBlock>(find.byType(ScheduleDateBlock));

  // O estilo é aplicado por um `DefaultTextStyle` interno do
  // `AnimatedDefaultTextStyle`, que envolve só o `Text` do dia da semana: é
  // o ancestral mais próximo desse tipo.
  TextStyle weekdayStyleOf(WidgetTester tester) => tester
      .widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text('Quarta-feira'),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      )
      .style;

  group('rótulos e cores', () {
    testWidgets(
      'previsão favorável usa o verde e o rótulo certo',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(),
            risk: ScheduleRiskLevel.ok,
            isPastDue: false,
          ),
        );

        expect(find.text('Previsão favorável'), findsOneWidget);
        expect(dateBlockOf(tester).background, AppColors.safe);
        expect(dateBlockOf(tester).foreground, Colors.white);
        expect(dateBlockOf(tester).pulse, isFalse);
      },
    );

    testWidgets(
      'risco usa o vermelho, pulsa e mostra a chuva em mm',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(),
            risk: ScheduleRiskLevel.atRisk,
            isPastDue: false,
            expectedRainMm: 12.34,
          ),
        );

        expect(find.text('Risco de chuva forte no dia'), findsOneWidget);
        expect(find.text('12,3 mm previstos'), findsOneWidget);
        expect(dateBlockOf(tester).background, AppColors.danger);
        expect(dateBlockOf(tester).foreground, Colors.white);
        expect(dateBlockOf(tester).pulse, isTrue);
      },
    );

    testWidgets(
      'sem previsão de chuva, o mm não aparece mesmo em risco',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(),
            risk: ScheduleRiskLevel.atRisk,
            isPastDue: false,
          ),
        );

        expect(find.textContaining('mm previstos'), findsNothing);
      },
    );

    testWidgets(
      'sem risco, o mm não aparece mesmo com chuva prevista',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(),
            risk: ScheduleRiskLevel.ok,
            isPastDue: false,
            expectedRainMm: 5,
          ),
        );

        expect(find.textContaining('mm previstos'), findsNothing);
      },
    );

    testWidgets(
      'sem previsão usa o neutro',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(),
            risk: ScheduleRiskLevel.unknown,
            isPastDue: false,
          ),
        );

        expect(find.text('Sem previsão para este dia ainda'), findsOneWidget);
        final block = dateBlockOf(tester);
        final context = tester.element(find.byType(ScheduleTile));
        final colors = Theme.of(context).colorScheme;
        expect(block.background, colors.surfaceContainerHigh);
        expect(block.foreground, colors.onSurfaceVariant);
        expect(block.pulse, isFalse);
      },
    );

    testWidgets(
      'data passada usa o amarelo no lugar do risco',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(
              scheduledDate: today.subtract(const Duration(days: 1)),
            ),
            risk: ScheduleRiskLevel.unknown,
            isPastDue: true,
          ),
        );

        expect(find.text('Data passada'), findsOneWidget);
        expect(find.text('Sem previsão para este dia ainda'), findsNothing);
        expect(dateBlockOf(tester).background, AppColors.caution);
        expect(dateBlockOf(tester).pulse, isFalse);
      },
    );

    testWidgets('observação aparece quando existe', (tester) async {
      await pumpTile(
        tester,
        ScheduleItem(
          schedule: schedule(note: 'talhão 3'),
          risk: ScheduleRiskLevel.ok,
          isPastDue: false,
        ),
      );
      expect(find.text('talhão 3'), findsOneWidget);
    });

    testWidgets('sem observação, nenhuma linha extra aparece', (
      tester,
    ) async {
      await pumpTile(
        tester,
        ScheduleItem(
          schedule: schedule(),
          risk: ScheduleRiskLevel.ok,
          isPastDue: false,
        ),
      );
      expect(find.text('null'), findsNothing);
    });

    testWidgets('dia da semana por extenso maiúsculo', (
      tester,
    ) async {
      await pumpTile(
        tester,
        ScheduleItem(
          schedule: schedule(),
          risk: ScheduleRiskLevel.ok,
          isPastDue: false,
        ),
      );
      expect(find.text('Quarta-feira'), findsOneWidget);
    });
  });

  group('contraste (WCAG AA)', () {
    final pastDue = ScheduleItem(
      schedule: schedule(
        scheduledDate: today.subtract(const Duration(days: 1)),
      ),
      risk: ScheduleRiskLevel.unknown,
      isPastDue: true,
    );

    testWidgets(
      'o bloco de data passada usa texto escuro sobre o âmbar',
      (tester) async {
        await pumpTile(tester, pastDue);

        final block = dateBlockOf(tester);
        expect(block.foreground, AppColors.ink);
        expect(
          contrastRatio(block.foreground, block.background),
          greaterThanOrEqualTo(minTextContrast),
        );
      },
    );

    final statuses = {
      'Data passada': pastDue,
      'Previsão favorável': ScheduleItem(
        schedule: schedule(),
        risk: ScheduleRiskLevel.ok,
        isPastDue: false,
      ),
      'Risco de chuva forte no dia': ScheduleItem(
        schedule: schedule(),
        risk: ScheduleRiskLevel.atRisk,
        isPastDue: false,
      ),
    };
    for (final (themeName, theme) in [
      ('claro', AppTheme.light),
      ('escuro', AppTheme.dark),
    ]) {
      for (final MapEntry(key: label, value: item) in statuses.entries) {
        testWidgets(
          'rótulo "$label" legível sobre o card no tema $themeName',
          (tester) async {
            await pumpTile(tester, item, theme: theme);

            final text = tester.widget<Text>(find.text(label));
            expect(
              contrastRatio(
                text.style!.color!,
                theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLow,
              ),
              greaterThanOrEqualTo(minTextContrast),
            );
          },
        );
      }
    }
  });

  group('concluído', () {
    testWidgets(
      'concluído não mostra rótulo de risco',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(completed: true),
            risk: ScheduleRiskLevel.atRisk,
            isPastDue: false,
          ),
        );
        expect(find.text('Risco de chuva forte no dia'), findsNothing);
        expect(find.text('Data passada'), findsNothing);
        expect(find.textContaining('mm previstos'), findsNothing);
      },
    );

    testWidgets(
      'concluído em risco não pulsa mais (histórico, não alerta)',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(completed: true),
            risk: ScheduleRiskLevel.atRisk,
            isPastDue: false,
          ),
        );
        expect(dateBlockOf(tester).pulse, isFalse);
      },
    );

    testWidgets(
      'concluído usa o bloco neutro e não pulsa',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(completed: true),
            risk: ScheduleRiskLevel.unknown,
            isPastDue: false,
          ),
        );

        final block = dateBlockOf(tester);
        final context = tester.element(find.byType(ScheduleTile));
        expect(
          block.background,
          Theme.of(context).colorScheme.surfaceContainerHigh,
        );
        expect(
          block.foreground,
          Theme.of(context).colorScheme.onSurfaceVariant,
        );
        expect(block.pulse, isFalse);
      },
    );

    testWidgets('concluído mostra o check marcado', (tester) async {
      await pumpTile(
        tester,
        ScheduleItem(
          schedule: schedule(completed: true),
          risk: ScheduleRiskLevel.unknown,
          isPastDue: false,
        ),
      );
      final check = tester.widget<AnimatedCheck>(find.byType(AnimatedCheck));
      expect(check.value, isTrue);
    });

    testWidgets(
      'toque no concluído não chama onEdit',
      (tester) async {
        var edited = false;
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(completed: true),
            risk: ScheduleRiskLevel.unknown,
            isPastDue: false,
          ),
          onEdit: () => edited = true,
        );
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();
        expect(edited, isFalse);
      },
    );
  });

  group('gestos', () {
    testWidgets('toque no não concluído chama onEdit', (tester) async {
      var edited = false;
      await pumpTile(
        tester,
        ScheduleItem(
          schedule: schedule(),
          risk: ScheduleRiskLevel.ok,
          isPastDue: false,
        ),
        onEdit: () => edited = true,
      );
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      expect(edited, isTrue);
    });

    testWidgets(
      'marcar o check chama onToggleCompleted(true)',
      (tester) async {
        bool? toggledTo;
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(),
            risk: ScheduleRiskLevel.ok,
            isPastDue: false,
          ),
          onToggleCompleted: (value) => toggledTo = value,
        );
        await tester.tap(find.byType(AnimatedCheck));
        await tester.pumpAndSettle();
        expect(toggledTo, isTrue);
      },
    );

    testWidgets(
      'desmarcar o check chama onToggleCompleted(false)',
      (tester) async {
        bool? toggledTo;
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(completed: true),
            risk: ScheduleRiskLevel.unknown,
            isPastDue: false,
          ),
          onToggleCompleted: (value) => toggledTo = value,
        );
        await tester.tap(find.byType(AnimatedCheck));
        await tester.pumpAndSettle();
        expect(toggledTo, isFalse);
      },
    );
  });

  group('transições', () {
    testWidgets(
      'concluir anima o estilo do texto com animação implícita',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(),
            risk: ScheduleRiskLevel.ok,
            isPastDue: false,
          ),
        );

        final context = tester.element(find.byType(ScheduleTile));
        final colors = Theme.of(context).colorScheme;
        expect(weekdayStyleOf(tester).color, colors.onSurface);
        expect(
          weekdayStyleOf(tester).decoration,
          isNot(TextDecoration.lineThrough),
        );

        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(completed: true),
            risk: ScheduleRiskLevel.ok,
            isPastDue: false,
          ),
        );
        await tester.pump(AppMotion.medium ~/ 2);

        // Quadro intermediário: nem a cor inicial nem a final ainda, prova
        // que é uma transição e não uma troca seca.
        final midColor = weekdayStyleOf(tester).color;
        expect(midColor, isNot(colors.onSurface));
        expect(midColor, isNot(colors.onSurfaceVariant));

        await tester.pumpAndSettle();
        expect(weekdayStyleOf(tester).color, colors.onSurfaceVariant);
        expect(weekdayStyleOf(tester).decoration, TextDecoration.lineThrough);
      },
    );
  });

  group('semântica', () {
    testWidgets(
      'rótulo traz dia da semana, data, status e observação',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(note: 'talhão 3'),
            risk: ScheduleRiskLevel.ok,
            isPastDue: false,
          ),
        );

        final semantics = tester.getSemantics(find.byType(InkWell));
        expect(semantics.label, contains('Quarta-feira'));
        expect(semantics.label, contains('setembro de 2026'));
        expect(semantics.label, contains('Previsão favorável'));
        expect(semantics.label, contains('talhão 3'));
      },
    );

    testWidgets(
      'o check diz ao leitor de tela de qual aplicação ele é',
      (tester) async {
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(),
            risk: ScheduleRiskLevel.ok,
            isPastDue: false,
          ),
        );

        final semantics = tester.getSemantics(find.byType(AnimatedCheck));
        expect(
          semantics.label,
          'Aplicação de quarta-feira, 23 de setembro feita',
        );
      },
    );

    testWidgets(
      'ação de acessibilidade "Excluir" chama onDelete',
      (tester) async {
        var deleted = false;
        await pumpTile(
          tester,
          ScheduleItem(
            schedule: schedule(),
            risk: ScheduleRiskLevel.ok,
            isPastDue: false,
          ),
          onDelete: () => deleted = true,
        );

        final node = tester.getSemantics(find.byType(InkWell));
        final actionIds = node.getSemanticsData().customSemanticsActionIds!;
        final actionId = actionIds.singleWhere(
          (id) => CustomSemanticsAction.getAction(id)!.label == 'Excluir',
        );
        // Sem substituto direto para acionar uma `CustomSemanticsAction` a
        // partir do teste.
        // ignore: deprecated_member_use
        tester.binding.pipelineOwner.semanticsOwner!.performAction(
          node.id,
          SemanticsAction.customAction,
          actionId,
        );

        expect(deleted, isTrue);
      },
    );
  });
}
