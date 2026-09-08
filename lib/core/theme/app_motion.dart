import 'package:flutter/animation.dart';

/// Vocabulário de movimento do app.
///
/// Toda animação do EcoSafra puxa duração e curva daqui. Isso é o que
/// diferencia "um app com animações" de "um app animado": o movimento é
/// consistente, então o usuário aprende o ritmo da interface.
///
/// Regra prática das guidelines do Material:
/// - entrada de elemento: rápido e desacelerando (`emphasizedDecelerate`);
/// - saída: acelerando e curto;
/// - transformação de algo já visível: `emphasized`.
abstract final class AppMotion {
  // --- Durações ---
  /// Feedback imediato: ripple, mudança de cor, check.
  static const Duration fast = Duration(milliseconds: 150);

  /// Padrão para a maioria das transições dentro da tela.
  static const Duration medium = Duration(milliseconds: 300);

  /// Transição de página, expansão de card.
  static const Duration slow = Duration(milliseconds: 450);

  /// Animações de destaque (splash, celebração, onboarding).
  static const Duration xSlow = Duration(milliseconds: 800);

  // --- Curvas ---
  /// Curva "emphasized" do Material 3. Sai devagar, acelera, chega suave.
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// Elemento entrando na tela.
  static const Curve decelerate = Curves.easeOutCubic;

  /// Elemento saindo da tela.
  static const Curve accelerate = Curves.easeInCubic;

  /// Movimento com leve "overshoot" — bom para ícones e badges.
  static const Curve springy = Curves.easeOutBack;

  /// Atraso entre itens de uma lista em animação escalonada (stagger).
  static const Duration staggerStep = Duration(milliseconds: 70);
}
