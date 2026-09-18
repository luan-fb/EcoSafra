import 'package:ecosafra/features/weather/presentation/weather_animation.dart';
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

  group('animationFor', () {
    // Só existem 3 animações; a tabela prova o agrupamento combinado na
    // spec (WLOT-01..04), com as duas bordas de cada faixa.
    const cases = {
      // WLOT-01: céu limpo
      0: WeatherAnimation.sunny,
      // WLOT-02: nuvens, neblina e neve viram nuvem
      1: WeatherAnimation.cloudy,
      2: WeatherAnimation.cloudy,
      3: WeatherAnimation.cloudy,
      45: WeatherAnimation.cloudy,
      48: WeatherAnimation.cloudy,
      71: WeatherAnimation.cloudy,
      77: WeatherAnimation.cloudy,
      85: WeatherAnimation.cloudy,
      86: WeatherAnimation.cloudy,
      // WLOT-03: garoa, chuva, pancadas e tempestade viram chuva
      51: WeatherAnimation.rainy,
      57: WeatherAnimation.rainy,
      61: WeatherAnimation.rainy,
      67: WeatherAnimation.rainy,
      80: WeatherAnimation.rainy,
      82: WeatherAnimation.rainy,
      95: WeatherAnimation.rainy,
      96: WeatherAnimation.rainy,
      99: WeatherAnimation.rainy,
      // WLOT-04 e edge cases: fora de qualquer faixa, inclusive os buracos
      // entre faixas (4, 50, 58) e valores fora de 0..99.
      -1: WeatherAnimation.cloudy,
      4: WeatherAnimation.cloudy,
      50: WeatherAnimation.cloudy,
      58: WeatherAnimation.cloudy,
      100: WeatherAnimation.cloudy,
    };

    for (final MapEntry(key: code, value: expected) in cases.entries) {
      test('código $code -> $expected', () {
        expect(WeatherCondition.animationFor(code), expected);
      });
    }

    // A tabela acima pega as bordas; esta varre 0..99 inteiro contra as
    // listas da spec, montadas aqui de forma independente do `switch`.
    test('todo código de 0 a 99 segue a tabela da spec', () {
      Iterable<int> range(int from, int to) =>
          List.generate(to - from + 1, (i) => from + i);
      final sunny = {0};
      final rainy = {
        ...range(51, 57),
        ...range(61, 67),
        ...range(80, 82),
        95,
        96,
        99,
      };
      for (var code = 0; code <= 99; code++) {
        final expected = sunny.contains(code)
            ? WeatherAnimation.sunny
            : rainy.contains(code)
                ? WeatherAnimation.rainy
                // Nuvem, neblina, neve e os buracos entre as faixas.
                : WeatherAnimation.cloudy;
        expect(
          WeatherCondition.animationFor(code),
          expected,
          reason: 'código $code',
        );
      }
    });

    test('cada animação aponta para um asset em assets/lottie/', () {
      expect(WeatherAnimation.sunny.assetPath, 'assets/lottie/sunny.json');
      expect(WeatherAnimation.cloudy.assetPath, 'assets/lottie/cloudy.json');
      expect(WeatherAnimation.rainy.assetPath, 'assets/lottie/rainy.json');
    });
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
