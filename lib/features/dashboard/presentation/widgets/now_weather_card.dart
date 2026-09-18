import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/presentation/weather_condition.dart';
import 'package:ecosafra/features/weather/presentation/widgets/weather_animation_view.dart';
import 'package:flutter/material.dart';

/// Card "Agora" do painel: animação do clima, temperatura, rótulo da
/// condição e os três indicadores (umidade, vento, chuva em 48h).
class NowWeatherCard extends StatelessWidget {
  const NowWeatherCard({
    required this.now,
    required this.weatherCode,
    required this.rainNext48h,
    super.key,
  });

  final HourlyForecastPoint now;

  /// Código WMO do dia: a previsão horária não traz código de clima.
  final int weatherCode;

  /// Chuva acumulada nas próximas 48h, em mm.
  final double rainNext48h;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text(
              context.l10n.dashboardNowCardTitle,
              style: context.texts.labelLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            WeatherAnimationView(weatherCode: weatherCode),
            Text(
              '${now.temperature.round()}°',
              style: context.texts.displayLarge,
            ),
            Text(
              WeatherCondition.labelFor(context, weatherCode),
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _StatPill(
                    icon: Icons.water_drop_outlined,
                    value: '${now.relativeHumidity}%',
                    label: context.l10n.dashboardHumidityLabel,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatPill(
                    icon: Icons.air_rounded,
                    value: '${now.windSpeed.round()} km/h',
                    label: context.l10n.dashboardWindLabel,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatPill(
                    icon: Icons.umbrella_outlined,
                    value: '${rainNext48h.toStringAsFixed(1)} mm',
                    label: context.l10n.dashboardNext48hRainLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pílula de estatística — usada nos três indicadores abaixo do card
/// "Agora" (umidade, vento, chuva). `surfaceContainerHigh` é um tom que o
/// Material 3 já deriva pro modo claro e escuro a partir da cor semente,
/// então o fundo da pílula nunca precisa de um "if isDarkMode" manual.
class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: context.colors.primary),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: context.texts.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.texts.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
