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
    // Temperaturas de referência: uma quente e uma fria, longe do limite
    // (≤ 16°C arredondado). O limite exato é testado em 16,4 e 16,5.
    const warm = 25.0;
    const cold = 10.0;

    // Tabela de bordas, em dia quente. Cada faixa com as duas pontas.
    const warmCases = {
      0: WeatherAnimation.sunny, // WLOT-01
      1: WeatherAnimation.partlyCloudy, // WLOT-12
      2: WeatherAnimation.partlyCloudy,
      3: WeatherAnimation.cloudy, // WLOT-02
      45: WeatherAnimation.cloudy,
      48: WeatherAnimation.cloudy,
      51: WeatherAnimation.rainy, // WLOT-03
      57: WeatherAnimation.rainy,
      61: WeatherAnimation.rainy,
      67: WeatherAnimation.rainy,
      71: WeatherAnimation.cold, // WLOT-13: neve é frio mesmo em dia quente
      77: WeatherAnimation.cold,
      80: WeatherAnimation.rainy,
      82: WeatherAnimation.rainy,
      85: WeatherAnimation.cold,
      86: WeatherAnimation.cold,
      95: WeatherAnimation.rainy,
      96: WeatherAnimation.rainy,
      99: WeatherAnimation.rainy,
      // WLOT-04 e edge cases: buracos entre faixas e fora de 0..99.
      -1: WeatherAnimation.cloudy,
      4: WeatherAnimation.cloudy,
      50: WeatherAnimation.cloudy,
      58: WeatherAnimation.cloudy,
      100: WeatherAnimation.cloudy,
    };

    for (final MapEntry(key: code, value: expected) in warmCases.entries) {
      test('código $code a 25° -> $expected', () {
        expect(
          WeatherCondition.animationFor(code, temperature: warm),
          expected,
        );
      });
    }

    group('frio (WLOT-14)', () {
      for (final code in [0, 1, 2, 3, 45, -1]) {
        test('código $code a 10° vira frio', () {
          expect(
            WeatherCondition.animationFor(code, temperature: cold),
            WeatherAnimation.cold,
          );
        });
      }

      test('chuva vence o frio (WLOT-03)', () {
        for (final code in [51, 61, 80, 95]) {
          expect(
            WeatherCondition.animationFor(code, temperature: cold),
            WeatherAnimation.rainy,
            reason: 'código $code',
          );
        }
      });

      // Edge case da spec: a regra usa o valor arredondado, o mesmo que o
      // card mostra.
      test('16,4° arredonda para 16 e é frio', () {
        expect(
          WeatherCondition.animationFor(0, temperature: 16.4),
          WeatherAnimation.cold,
        );
      });

      test('16,5° arredonda para 17 e não é frio', () {
        expect(
          WeatherCondition.animationFor(0, temperature: 16.5),
          WeatherAnimation.sunny,
        );
      });
    });

    // A tabela acima pega as bordas; esta varre 0..99 inteiro, em dia
    // quente e frio, contra as listas da spec montadas aqui de forma
    // independente do `switch`.
    test('todo código de 0 a 99 segue a tabela da spec', () {
      Iterable<int> range(int from, int to) =>
          List.generate(to - from + 1, (i) => from + i);
      final rainy = {
        ...range(51, 57),
        ...range(61, 67),
        ...range(80, 82),
        95,
        96,
        99,
      };
      final snow = {...range(71, 77), 85, 86};

      WeatherAnimation expectedFor(int code, {required bool isCold}) {
        if (rainy.contains(code)) return WeatherAnimation.rainy;
        if (snow.contains(code) || isCold) return WeatherAnimation.cold;
        if (code == 0) return WeatherAnimation.sunny;
        if (code == 1 || code == 2) return WeatherAnimation.partlyCloudy;
        return WeatherAnimation.cloudy;
      }

      for (var code = 0; code <= 99; code++) {
        expect(
          WeatherCondition.animationFor(code, temperature: warm),
          expectedFor(code, isCold: false),
          reason: 'código $code a 25°',
        );
        expect(
          WeatherCondition.animationFor(code, temperature: cold),
          expectedFor(code, isCold: true),
          reason: 'código $code a 10°',
        );
      }
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
