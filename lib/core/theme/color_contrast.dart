import 'dart:ui';

/// Contraste mínimo do WCAG AA para texto de tamanho normal.
const double minTextContrast = 4.5;

/// Razão de contraste do WCAG entre duas cores, de 1 a 21.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (lighter, darker) = la > lb ? (la, lb) : (lb, la);
  return (lighter + 0.05) / (darker + 0.05);
}

/// [color] com o mínimo de mistura em [ink] para chegar a
/// [minTextContrast] sobre [background]: mantém o tom da cor de status,
/// escurecendo no tema claro e clareando no escuro.
Color readableOn(
  Color color, {
  required Color background,
  required Color ink,
}) {
  for (var step = 0; step <= 20; step++) {
    final mixed = Color.lerp(color, ink, step / 20)!;
    if (contrastRatio(mixed, background) >= minTextContrast) return mixed;
  }
  return ink;
}
