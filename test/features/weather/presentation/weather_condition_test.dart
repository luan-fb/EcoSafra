import 'package:ecosafra/features/weather/presentation/weather_condition.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // `labelFor` precisa de um BuildContext com o delegate de l10n montado —
  // por isso os testes rodam dentro de um `MaterialApp` mínimo em vez de
  // chamar a função "a seco". `iconFor` é puro e não precisa disso.
  Future<String> labelFor(WidgetTester tester, int code) async {
    late String label;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            label = WeatherCondition.labelFor(context, code);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return label;
  }

  group('iconFor', () {
    // Tabela: um caso por faixa do switch em weather_condition.dart. Isto é
    // o que garante que mexer num limite (ex.: trocar `<= 57` por `<= 56`)
    // quebra um teste em vez de só mudar o ícone silenciosamente em produção.
    const cases = {
      0: Icons.wb_sunny_rounded,
      1: Icons.wb_cloudy_rounded,
      2: Icons.wb_cloudy_rounded,
      3: Icons.cloud_rounded,
      45: Icons.foggy,
      48: Icons.foggy,
      51: Icons.grain_rounded,
      57: Icons.grain_rounded,
      61: Icons.water_drop_rounded,
      67: Icons.water_drop_rounded,
      71: Icons.ac_unit_rounded,
      77: Icons.ac_unit_rounded,
      80: Icons.umbrella_rounded,
      82: Icons.umbrella_rounded,
      85: Icons.ac_unit_rounded,
      86: Icons.ac_unit_rounded,
      95: Icons.thunderstorm_rounded,
      96: Icons.thunderstorm_rounded,
      99: Icons.thunderstorm_rounded,
      // Código que a Open-Meteo não documenta: cai no fallback, não trava.
      -1: Icons.cloud_queue_rounded,
    };

    for (final MapEntry(key: code, value: expectedIcon) in cases.entries) {
      test('código $code -> $expectedIcon', () {
        expect(WeatherCondition.iconFor(code), expectedIcon);
      });
    }
  });

  group('labelFor', () {
    testWidgets('código conhecido devolve rótulo em português', (
      tester,
    ) async {
      expect(await labelFor(tester, 61), 'Chuva');
    });

    testWidgets('código desconhecido não trava, devolve rótulo de fallback', (
      tester,
    ) async {
      expect(await labelFor(tester, -1), 'Sem dados');
    });
  });
}
