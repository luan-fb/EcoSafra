import 'package:ecosafra/core/theme/app_theme.dart';
import 'package:ecosafra/features/splash/presentation/pages/splash_page.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('o gradiente de fundo cobre a tela inteira', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SplashPage(),
      ),
    );
    await tester.pumpAndSettle();

    final background = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).gradient != null,
    );
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(tester.getSize(background.first), screen);
  });
}
