import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_tile.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

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
  }) {
    return tester.pumpWidget(
      MaterialApp(
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

  group('rótulos', () {
    testWidgets('AGD-09: previsão favorável', (tester) async {
      await pumpTile(
        tester,
        ScheduleItem(
          schedule: schedule(),
          risk: ScheduleRiskLevel.ok,
          isPastDue: false,
        ),
      );
      expect(find.text('Previsão favorável'), findsOneWidget);
    });

    testWidgets('AGD-09: risco de chuva forte no dia', (tester) async {
      await pumpTile(
        tester,
        ScheduleItem(
          schedule: schedule(),
          risk: ScheduleRiskLevel.atRisk,
          isPastDue: false,
        ),
      );
      expect(find.text('Risco de chuva forte no dia'), findsOneWidget);
    });

    testWidgets('AGD-09: sem previsão para este dia ainda', (tester) async {
      await pumpTile(
        tester,
        ScheduleItem(
          schedule: schedule(),
          risk: ScheduleRiskLevel.unknown,
          isPastDue: false,
        ),
      );
      expect(find.text('Sem previsão para este dia ainda'), findsOneWidget);
    });

    testWidgets('AGD-10: data passada no lugar do risco', (tester) async {
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
    });

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

    testWidgets('sem observação, nenhuma linha extra aparece', (tester) async {
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
  });

  group('concluído', () {
    testWidgets(
      'AGD-28: concluído não mostra rótulo de risco',
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
      },
    );

    testWidgets('AGD-28: concluído mostra o checkbox marcado', (
      tester,
    ) async {
      await pumpTile(
        tester,
        ScheduleItem(
          schedule: schedule(completed: true),
          risk: ScheduleRiskLevel.unknown,
          isPastDue: false,
        ),
      );
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets(
      'AGD-27: toque no concluído não chama onEdit',
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
        await tester.tap(find.byType(ListTile));
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
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();
      expect(edited, isTrue);
    });

    testWidgets(
      'AGD-28: marcar o checkbox chama onToggleCompleted(true)',
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
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();
        expect(toggledTo, isTrue);
      },
    );

    testWidgets(
      'AGD-29: desmarcar o checkbox chama onToggleCompleted(false)',
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
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();
        expect(toggledTo, isFalse);
      },
    );

    testWidgets(
      'AGD-30: menu "Excluir" chama onDelete',
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
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();
        expect(deleted, isTrue);
      },
    );
  });
}
