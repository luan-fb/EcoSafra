import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_note.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_form_sheet.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  final today = DateTime(2026, 9, 23);
  final window = SchedulingWindow.startingAt(today);

  /// Monta o app, abre o sheet e devolve o `Future` (ainda pendente) do
  /// resultado: o teste interage com o sheet e só então aguarda por ele.
  Future<Future<ScheduleFormResult?>> pumpAndShow(
    WidgetTester tester, {
    FertilizationSchedule? initial,
  }) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SizedBox.shrink()),
      ),
    );
    final context = tester.element(find.byType(Scaffold));
    final future = ScheduleFormSheet.show(
      context,
      window: window,
      initial: initial,
    );
    await tester.pumpAndSettle();
    return future;
  }

  group('seletor de data', () {
    testWidgets(
      'AGD-03: firstDate e lastDate são os limites da janela',
      (tester) async {
        await pumpAndShow(tester);

        await tester.tap(find.byIcon(Icons.calendar_today_rounded));
        await tester.pumpAndSettle();

        final dialog = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        expect(dialog.firstDate, window.first);
        expect(dialog.lastDate, window.last);
      },
    );

    testWidgets(
      'AGD-01: initialDate é a data atual ao criar (hoje, já na janela)',
      (tester) async {
        await pumpAndShow(tester);

        await tester.tap(find.byIcon(Icons.calendar_today_rounded));
        await tester.pumpAndSettle();

        final dialog = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        expect(dialog.initialDate, window.first);
      },
    );

    testWidgets(
      'AGD-26: data do agendamento fora da janela abre o seletor em hoje',
      (tester) async {
        final outOfWindow = FertilizationSchedule(
          id: 's1',
          scheduledDate: today.subtract(const Duration(days: 10)),
          createdAt: today,
        );
        await pumpAndShow(tester, initial: outOfWindow);

        await tester.tap(find.byIcon(Icons.calendar_today_rounded));
        await tester.pumpAndSettle();

        final dialog = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        expect(dialog.initialDate, window.first);
      },
    );

    testWidgets(
      'edição com data dentro da janela abre o seletor nela',
      (tester) async {
        final inWindow = FertilizationSchedule(
          id: 's1',
          scheduledDate: window.last,
          createdAt: today,
        );
        await pumpAndShow(tester, initial: inWindow);

        await tester.tap(find.byIcon(Icons.calendar_today_rounded));
        await tester.pumpAndSettle();

        final dialog = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        expect(dialog.initialDate, window.last);
      },
    );
  });

  group('observação', () {
    testWidgets(
      'Edge case: TextField com maxLength impede digitar acima de 200',
      (tester) async {
        await pumpAndShow(tester);

        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.maxLength, ScheduleNote.maxLength);

        await tester.enterText(
          find.byType(TextField),
          'a' * 250,
        );
        await tester.pump();

        final controller = field.controller!;
        expect(controller.text.length, ScheduleNote.maxLength);
      },
    );
  });

  group('confirmar e cancelar', () {
    testWidgets(
      'AGD-01, AGD-03: confirmar devolve a data e a observação normalizada',
      (tester) async {
        final future = await pumpAndShow(tester);
        await tester.enterText(find.byType(TextField), '  talhão 3  ');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        final result = await future;
        expect(result, isNotNull);
        expect(result!.date, window.first);
        expect(result.note, 'talhão 3');
      },
    );

    testWidgets(
      'AGD-04: observação em branco vira null',
      (tester) async {
        final future = await pumpAndShow(tester);
        await tester.enterText(find.byType(TextField), '   ');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        final result = await future;
        expect(result!.note, isNull);
      },
    );

    testWidgets('cancelar devolve null', (tester) async {
      final future = await pumpAndShow(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      final result = await future;
      expect(result, isNull);
    });

    testWidgets(
      'modo edição vem preenchido com a data e a observação atuais',
      (tester) async {
        final scheduled = FertilizationSchedule(
          id: 's1',
          scheduledDate: window.last,
          createdAt: today,
          note: 'ureia',
        );
        await pumpAndShow(tester, initial: scheduled);

        expect(find.text('Editar agendamento'), findsOneWidget);
        expect(find.text('ureia'), findsOneWidget);

        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();
      },
    );
  });
}
