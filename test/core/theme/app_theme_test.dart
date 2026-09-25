import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  // Regressão: com largura mínima infinita no tema, botão dentro de `Row`
  // ou nas ações de um diálogo quebrava o layout (formulário e diálogo de
  // exclusão da Agenda no aparelho).
  for (final (name, theme) in [
    ('claro', AppTheme.light),
    ('escuro', AppTheme.dark),
  ]) {
    testWidgets('tema $name: botões cabem numa Row e num AlertDialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                Row(
                  children: [
                    FilledButton(onPressed: () {}, child: const Text('a')),
                    OutlinedButton(onPressed: () {}, child: const Text('b')),
                  ],
                ),
                AlertDialog(
                  actions: [
                    TextButton(onPressed: () {}, child: const Text('c')),
                    FilledButton(onPressed: () {}, child: const Text('d')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final button = tester.getSize(find.widgetWithText(FilledButton, 'a'));
      expect(button.height, greaterThanOrEqualTo(52));
      expect(button.width, lessThan(400));
    });
  }
}
