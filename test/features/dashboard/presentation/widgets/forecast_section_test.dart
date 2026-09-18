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

  HourlyForecastPoint hour(int h, {required double rain}) => HourlyForecastPoint(
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
    coordinates: const Coordinates(latitude: -23.5, longitude: -46.6),
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

  Future<NowWeatherCard> pumpSection(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ForecastSection(forecast: forecast, advice: advice),
          ),
        ),
      ),
    );
    // Deixa as entradas escalonadas (FadeSlideIn) terminarem. Não dá para
    // usar pumpAndSettle: a animação do clima está em loop.
    await tester.pump(const Duration(seconds: 2));
    return tester.widget<NowWeatherCard>(find.byType(NowWeatherCard));
  }

  testWidgets('WLOT-16: o card recebe a chuva de 48h da decisão', (
    tester,
  ) async {
    final card = await pumpSection(tester);
    expect(card.rainNext48h, advice.rainNext48h);
    expect(find.text('9.5 mm'), findsOneWidget);
  });

  testWidgets('WLOT-05: o card recebe o código de hoje e a hora atual', (
    tester,
  ) async {
    final card = await pumpSection(tester);
    expect(card.weatherCode, forecast.daily.first.weatherCode);
    expect(card.currentHour, forecast.hourly.first);
  });
}
