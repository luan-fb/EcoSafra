import 'package:flutter/material.dart';

/// Paleta do EcoSafra.
///
/// Nunca use `Colors.green` direto num widget. Toda cor entra aqui primeiro,
/// e os widgets consomem via `Theme.of(context).colorScheme`. Isso é o que
/// permite trocar tema claro/escuro sem tocar em nenhuma tela.
abstract final class AppColors {
  /// Verde folha: identidade da marca, ações primárias.
  static const Color primary = Color(0xFF2E7D46);
  static const Color primaryLight = Color(0xFF5BAF6F);
  static const Color primaryDark = Color(0xFF1B5E30);

  /// Azul chuva: dados climáticos, precipitação.
  static const Color secondary = Color(0xFF2B6CB0);
  static const Color secondaryLight = Color(0xFF63A4FF);

  /// Terra: fundo de cards de solo/plantio.
  static const Color earth = Color(0xFF8D6E4A);

  // --- Semânticas de alerta (o coração do app) ---
  /// Pode aplicar fertilizante.
  static const Color safe = Color(0xFF2E7D46);

  /// Aplicar com cautela: chuva moderada prevista.
  static const Color caution = Color(0xFFE0A23A);

  /// Não aplicar: risco de escoamento superficial.
  static const Color danger = Color(0xFFC0392B);

  // --- Neutros ---
  static const Color ink = Color(0xFF14201A);
  static const Color inkMuted = Color(0xFF5A6B62);
  static const Color surfaceLight = Color(0xFFFBFDF9);
  static const Color surfaceDark = Color(0xFF101614);
  static const Color outline = Color(0xFFD8E2DA);
}
