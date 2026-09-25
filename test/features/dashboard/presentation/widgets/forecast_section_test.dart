import 'package:clock/clock.dart';
import 'package:ecosafra/features/dashboard/presentation/widgets/forecast_section.dart';
import 'package:ecosafra/features/dashboard/presentation/widgets/now_weather_card.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/fertilizer_advice.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lottie/lottie.dart';

void main() {
  // A lista de dias formata datas em pt_BR, como o bootstrap do app.
  setUpAll(() => initializeDateFormatting('pt_BR'));
  setUp(() => Lottie.cache.clear());

  const coordinates = Coordinates(latitude: -23.5, longitude: -46.6);

  HourlyForecastPoint hour(int h, {required double rain}) =>
      HourlyForecastPoint(
        time: DateTime(2026, 9, 18, h),
        precipitation: rain,
        precipitationProbability: 0,
        temperature: 20.0 + h,
        relativeHumidity: 60,
        windSpeed: 10,
      );

  DailyForecastPoint day(int d, {required int weatherCode}) =>
      DailyForecastPoint(
        date: DateTime(2026, 9, d),
        precipitationSum: 0,
        precipitationProbabilityMax: 0,
        temperatureMax: 30,
        temperatureMin: 18,
        windSpeedMax: 10,
        weatherCode: weatherCode,
      );

  // Os valores são diferentes de propósito: cada escolha errada da seção
  // (outra hora, outro dia, a soma local da chuva) aparece no card.
  final forecast = WeatherForecast(
    coordinates: coordinates,
    hourly: [hour(0, rain: 1), hour(1, rain: 2), hour(2, rain: 3)],
    daily: [day(18, weatherCode: 0), day(19, weatherCode: 61)],
    fetchedAt: DateTime(2026, 9, 18),
  );
  const advice = FertilizerAdvice(
    level: AdviceLevel.safe,
    rainNext24h: 4,
    // A soma local da previsão horária seria 6; o card tem que mostrar o
    // número do motor de decisão.
    rainNext48h: 9.5,
  );

  // `now` fixa o relógio do card durante o pump: sem isso, `clock.now()`
  // usaria a hora real, fora do intervalo coberto por `forecast`.
  Future<NowWeatherCard> pumpSection(
    WidgetTester tester, {
    WeatherForecast? withForecast,
    DateTime? now,
  }) async {
    final usedForecast = withForecast ?? forecast;
    return withClock(Clock.fixed(now ?? DateTime(2026, 9, 18)), () async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ForecastSection(forecast: usedForecast, advice: advice),
            ),
          ),
        ),
      );
      // Deixa as entradas escalonadas (FadeSlideIn) terminarem. Não dá para
      // usar pumpAndSettle: a animação do clima está em loop.
      await tester.pump(const Duration(seconds: 2));
      return tester.widget<NowWeatherCard>(find.byType(NowWeatherCard));
    });
  }

  testWidgets('o card recebe a chuva de 48h da decisão', (
    tester,
  ) async {
    final card = await pumpSection(tester);
    expect(card.rainNext48h, advice.rainNext48h);
    expect(find.text('9.5 mm'), findsOneWidget);
  });

  testWidgets(
    'WIN-05/06: o card "Agora" usa o ponto da hora cheia atual e o clima '
    'do dia de hoje, não o primeiro de cada lista',
    (tester) async {
      // A hora atual (15h) não é a primeira do `hourly`, e o dia de hoje
      // (18) não é o primeiro do `daily`: se a seção caísse de volta para
      // `.first`, o teste pegaria a hora ou o código errado.
      final currentHourPoint = hour(15, rain: 9);
      final todaysNotFirst = WeatherForecast(
        coordinates: coordinates,
        hourly: [hour(0, rain: 1), hour(1, rain: 2), currentHourPoint],
        daily: [day(19, weatherCode: 61), day(18, weatherCode: 3)],
        fetchedAt: DateTime(2026, 9, 18),
      );

      final card = await pumpSection(
        tester,
        withForecast: todaysNotFirst,
        now: DateTime(2026, 9, 18, 15),
      );

      expect(card.currentHour, currentHourPoint);
      expect(card.weatherCode, 3);
    },
  );

  testWidgets(
    'WIN-08: hoje fora da previsão diária usa o primeiro dia da previsão',
    (tester) async {
      // Só há um ponto horário, dois dias depois do `daily` mais recente:
      // `dayOf(now)` não encontra nada e o card cai para `daily.first`.
      final farFutureHour = HourlyForecastPoint(
        time: DateTime(2026, 9, 20, 6),
        precipitation: 0,
        precipitationProbability: 0,
        temperature: 22,
        relativeHumidity: 55,
        windSpeed: 5,
      );
      final todayMissingFromDaily = WeatherForecast(
        coordinates: coordinates,
        hourly: [farFutureHour],
        daily: [day(18, weatherCode: 3), day(19, weatherCode: 61)],
        fetchedAt: DateTime(2026, 9, 18),
      );

      final card = await pumpSection(
        tester,
        withForecast: todayMissingFromDaily,
        now: DateTime(2026, 9, 20),
      );

      expect(card.currentHour, farFutureHour);
      expect(card.weatherCode, 3);
    },
  );

  testWidgets('exibe a atribuição da Open-Meteo', (tester) async {
    await pumpSection(tester);
    expect(
      find.text('Dados meteorológicos: Open-Meteo.com (CC BY 4.0)'),
      findsOneWidget,
    );
  });

  testWidgets('exibe o aviso de caráter informativo', (tester) async {
    await pumpSection(tester);
    expect(
      find.text(
        'A recomendação é informativa e não substitui a orientação de um profissional de agronomia.',
      ),
      findsOneWidget,
    );
  });
}
