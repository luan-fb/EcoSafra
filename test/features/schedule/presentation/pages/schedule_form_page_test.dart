import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_note.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:ecosafra/features/schedule/presentation/pages/schedule_form_page.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    // Tema real do app: o bug de largura infinita dos botões só aparecia
    // com ele.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final today = DateTime(2026, 9, 23);
  final window = SchedulingWindow.startingAt(today);

  /// Monta o app, abre o formulário como rota e devolve o `Future` (ainda
  /// pendente) do resultado: o teste interage com a tela e só então aguarda
  /// por ele.
  Future<Future<ScheduleFormResult?>> pumpAndOpen(
    WidgetTester tester, {
    FertilizationSchedule? initial,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
    final context = tester.element(find.byType(Scaffold));
    final future = Navigator.of(context).push<ScheduleFormResult>(
      MaterialPageRoute(
        builder: (_) => ScheduleFormPage(window: window, initial: initial),
      ),
    );
    await tester.pumpAndSettle();
    return future;
  }

  group('seletor de data', () {
    testWidgets(
      'AGD-03: firstDate e lastDate são os limites da janela',
      (tester) async {
        await pumpAndOpen(tester);

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
        await pumpAndOpen(tester);

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
        await pumpAndOpen(tester, initial: outOfWindow);

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
        await pumpAndOpen(tester, initial: inWindow);

        await tester.tap(find.byIcon(Icons.calendar_today_rounded));
        await tester.pumpAndSettle();

        final dialog = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        expect(dialog.initialDate, window.last);
      },
    );

    testWidgets(
      'data escolhida no seletor é a devolvida ao salvar',
      (tester) async {
        final future = await pumpAndOpen(tester);
        final target = window.first.add(const Duration(days: 2));

        await tester.tap(find.byIcon(Icons.calendar_today_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.text('${target.day}'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        final result = await future;
        expect(result!.date, target);
      },
    );
  });

  group('observação', () {
    testWidgets(
      'Edge case: TextField com maxLength impede digitar acima de 200',
      (tester) async {
        await pumpAndOpen(tester);

        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.maxLength, ScheduleNote.maxLength);

        await tester.enterText(find.byType(TextField), 'a' * 250);
        await tester.pump();

        final controller = field.controller!;
        expect(controller.text.length, ScheduleNote.maxLength);
      },
    );
  });

  group('salvar e cancelar', () {
    testWidgets(
      'AGD-01, AGD-03: salvar devolve a data e a observação normalizada',
      (tester) async {
        final future = await pumpAndOpen(tester);
        await tester.enterText(find.byType(TextField), '  talhão 3  ');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        final result = await future;
        expect(result, isNotNull);
        expect(result!.date, window.first);
        expect(result.note, 'talhão 3');
      },
    );

    testWidgets('AGD-04: observação em branco vira null', (tester) async {
      final future = await pumpAndOpen(tester);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      final result = await future;
      expect(result!.note, isNull);
    });

    testWidgets('fechar pelo botão "Cancelar" devolve null', (tester) async {
      final future = await pumpAndOpen(tester);
      await tester.enterText(find.byType(TextField), 'não salvar');
      await tester.tap(find.byTooltip('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(ScheduleFormPage), findsNothing);
      expect(await future, isNull);
    });

    testWidgets('voltar do sistema devolve null', (tester) async {
      final future = await pumpAndOpen(tester);
      await tester.enterText(find.byType(TextField), 'não salvar');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(ScheduleFormPage), findsNothing);
      expect(await future, isNull);
    });

    testWidgets(
      'criação mostra o título "Novo agendamento" e o campo vazio',
      (tester) async {
        await pumpAndOpen(tester);

        expect(find.text('Novo agendamento'), findsOneWidget);
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller!.text, isEmpty);
      },
    );

    testWidgets(
      'modo edição vem preenchido com a data e a observação atuais',
      (tester) async {
        final scheduled = FertilizationSchedule(
          id: 's1',
          scheduledDate: window.last,
          createdAt: today,
          note: 'ureia',
        );
        final future = await pumpAndOpen(tester, initial: scheduled);

        expect(find.text('Editar agendamento'), findsOneWidget);
        expect(find.text('ureia'), findsOneWidget);

        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        final result = await future;
        expect(result!.date, window.last);
        expect(result.note, 'ureia');
      },
    );
  });
}
