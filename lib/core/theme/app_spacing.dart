/// Escala de espaçamento em múltiplos de 4.
///
/// Usar uma escala fixa (em vez de números soltos) é o que faz uma UI parecer
/// desenhada por um time de design e não montada no chute.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Raios de canto.
  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusPill = 999;
}
