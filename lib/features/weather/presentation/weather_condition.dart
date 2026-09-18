import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/features/weather/presentation/weather_animation.dart';
import 'package:flutter/material.dart';

/// Traduz o código WMO que a Open-Meteo devolve (`weather_code`) para algo
/// que a UI consegue mostrar: um ícone e um rótulo curto.
///
/// A tabela completa tem ~30 códigos; agrupamos em faixas porque a UI não
/// precisa distinguir "chuva fraca" de "chuva moderada" — só precisa de um
/// ícone e uma palavra que o produtor reconheça de relance.
/// Referência: https://open-meteo.com/en/docs (seção WMO Weather interpretation codes)
abstract final class WeatherCondition {
  static IconData iconFor(int code) => switch (code) {
        0 => Icons.wb_sunny_rounded,
        1 || 2 => Icons.wb_cloudy_rounded,
        3 => Icons.cloud_rounded,
        45 || 48 => Icons.foggy,
        >= 51 && <= 57 => Icons.grain_rounded,
        >= 61 && <= 67 => Icons.water_drop_rounded,
        >= 71 && <= 77 => Icons.ac_unit_rounded,
        >= 80 && <= 82 => Icons.umbrella_rounded,
        85 || 86 => Icons.ac_unit_rounded,
        95 || 96 || 99 => Icons.thunderstorm_rounded,
        _ => Icons.cloud_queue_rounded,
      };

  /// A partir desta temperatura (inclusive, já arredondada) o céu sem
  /// chuva vira a animação de frio.
  static const coldThresholdCelsius = 16;

  /// Mais grosso que [iconFor]: só existem 5 animações. Neblina vira
  /// nuvem; garoa, pancadas e tempestade viram chuva. O rótulo de
  /// [labelFor] continua dizendo o clima exato.
  ///
  /// Frio só substitui céu sem chuva: com chuva, a chuva é o que importa
  /// para decidir a adubação. A [temperature] é arredondada igual ao
  /// número que o card mostra, para os dois nunca discordarem.
  static WeatherAnimation animationFor(
    int code, {
    required double temperature,
  }) {
    final byCode = switch (code) {
      0 => WeatherAnimation.sunny,
      1 || 2 => WeatherAnimation.partlyCloudy,
      (>= 51 && <= 57) ||
      (>= 61 && <= 67) ||
      (>= 80 && <= 82) ||
      95 ||
      96 ||
      99 => WeatherAnimation.rainy,
      (>= 71 && <= 77) || 85 || 86 => WeatherAnimation.cold,
      // Encoberto, neblina e qualquer código desconhecido.
      _ => WeatherAnimation.cloudy,
    };
    final isCold = temperature.round() <= coldThresholdCelsius;
    return switch (byCode) {
      WeatherAnimation.sunny ||
      WeatherAnimation.partlyCloudy ||
      WeatherAnimation.cloudy when isCold => WeatherAnimation.cold,
      _ => byCode,
    };
  }

  static String labelFor(BuildContext context, int code) => switch (code) {
        0 => context.l10n.weatherConditionClearSky,
        1 || 2 => context.l10n.weatherConditionPartlyCloudy,
        3 => context.l10n.weatherConditionCloudy,
        45 || 48 => context.l10n.weatherConditionFog,
        >= 51 && <= 57 => context.l10n.weatherConditionDrizzle,
        >= 61 && <= 67 => context.l10n.weatherConditionRain,
        >= 71 && <= 77 => context.l10n.weatherConditionSnow,
        >= 80 && <= 82 => context.l10n.weatherConditionRainShowers,
        85 || 86 => context.l10n.weatherConditionSnowShowers,
        95 || 96 || 99 => context.l10n.weatherConditionThunderstorm,
        _ => context.l10n.weatherConditionUnknown,
      };
}
