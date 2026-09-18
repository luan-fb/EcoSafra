import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/fade_slide_in.dart';
import 'package:ecosafra/features/dashboard/presentation/widgets/decision_card.dart';
import 'package:ecosafra/features/dashboard/presentation/widgets/now_weather_card.dart';
import 'package:ecosafra/features/weather/domain/entities/fertilizer_advice.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/presentation/weather_condition.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Conteúdo do painel quando a previsão está carregada: aviso de cache,
/// card de decisão, card "Agora" e a lista dos próximos dias.
///
/// Recebe tudo pelo construtor, sem ler Cubit: é o que permite testar as
/// escolhas de dados (qual hora, qual dia, qual chuva) sem subir o Modular.
class ForecastSection extends StatelessWidget {
  const ForecastSection({
    required this.forecast,
    required this.advice,
    super.key,
  });

  final WeatherForecast forecast;
  final FertilizerAdvice advice;

  @override
  Widget build(BuildContext context) {
    final currentHour = forecast.hourly.first;
    final today = forecast.daily.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (forecast.isStale)
          FadeSlideIn(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.caution.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: AppColors.caution),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      context.l10n.dashboardOfflineBanner(
                        DateFormat.Hm().format(forecast.fetchedAt),
                      ),
                      style: context.texts.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        FadeSlideIn.staggered(
          index: 0,
          child: DecisionCard(advice: advice),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn.staggered(
          index: 1,
          child: NowWeatherCard(
            currentHour: currentHour,
            weatherCode: today.weatherCode,
            // O mesmo número que a decisão usou: se o motor mudar a janela,
            // a pílula e o card de decisão continuam concordando.
            rainNext48h: advice.rainNext48h,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          context.l10n.dashboardDailyForecastTitle,
          style: context.texts.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final (i, day) in forecast.daily.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: FadeSlideIn.staggered(
              index: i + 2,
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  leading: Icon(
                    WeatherCondition.iconFor(day.weatherCode),
                    color: context.colors.primary,
                    size: 28,
                  ),
                  title: Text(DateFormat.MMMEd('pt_BR').format(day.date)),
                  subtitle: Text(
                    '${day.precipitationSum.toStringAsFixed(1)} mm · '
                    '${day.precipitationProbabilityMax}%',
                  ),
                  trailing: Text(
                    '${day.temperatureMax.round()}° / ${day.temperatureMin.round()}°',
                    style: context.texts.titleSmall,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
