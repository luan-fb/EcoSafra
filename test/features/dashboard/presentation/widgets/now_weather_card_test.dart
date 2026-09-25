import 'package:ecosafra/features/dashboard/presentation/widgets/now_weather_card.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/presentation/weather_condition.dart';
import 'package:ecosafra/features/weather/presentation/widgets/weather_animation_view.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  setUp(() => Lottie.cache.clear());

  final currentHour = HourlyForecastPoint(
    time: DateTime(2026, 9, 18, 10),
    precipitation: 0,
    precipitationProbability: 0,
    temperature: 28,
    relativeHumidity: 60,
    windSpeed: 12,
  );

  Future<void> pumpCard(
    WidgetTester tester, {
    required int weatherCode,
    double rainNext48h = 0,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: NowWeatherCard(
              currentHour: currentHour,
              weatherCode: weatherCode,
              rainNext48h: rainNext48h,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('mostra a animação do código de hoje, sem o ícone', (
    tester,
  ) async {
    await pumpCard(tester, weatherCode: 0);

    final view = tester.widget<WeatherAnimationView>(
      find.byType(WeatherAnimationView),
    );
    expect(view.weatherCode, 0);
    // A animação decide o frio pela mesma temperatura do card.
    expect(view.temperature, currentHour.temperature);
    // O ícone estático de antes (sol) não pode continuar no card.
    expect(find.byIcon(WeatherCondition.iconFor(0)), findsNothing);
  });

  testWidgets('o leitor de tela recebe o rótulo do clima', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpCard(tester, weatherCode: 0);

    // O Card é um "semantic container": junta os textos filhos num nó só
    // ("Agora\n28°\nCéu limpo\n..."), que o TalkBack lê de uma vez. Por
    // isso a busca é pelo rótulo dentro desse nó, não por um nó isolado.
    expect(
      find.bySemanticsLabel(RegExp(r'^Céu limpo$', multiLine: true)),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('a pílula de chuva mostra o valor recebido', (
    tester,
  ) async {
    await pumpCard(tester, weatherCode: 0, rainNext48h: 12.34);
    expect(find.text('12.3 mm'), findsOneWidget);
  });
}
