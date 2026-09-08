import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:flutter/widgets.dart';
import 'package:go_transitions/go_transitions.dart';

/// Transições de página do EcoSafra.
///
/// `GoTransition` é a peça de transição do go_router_modular: cada
/// `ChildRoute` recebe uma instância no parâmetro `transition`. Uma instância
/// nasce "sem efeito" (`const GoTransition()`) e ganha comportamento ao
/// encadear modificadores (`withFade`, `withScale`, `withSlide`...) — cada um
/// devolve uma nova instância, então a ordem do encadeamento é a ordem em que
/// os efeitos se compõem visualmente.
abstract final class AppTransitions {
  /// Fade + leve escala. Troca de contexto (login → painel).
  static final GoTransition fadeThrough = const GoTransition()
      .withFade
      .withScale
      .withStyle(curve: AppMotion.emphasized)
      .withSettings(
        duration: AppMotion.slow,
        reverseDuration: AppMotion.medium,
      );

  /// Desliza da direita, para navegação hierárquica (lista → detalhe).
  static final GoTransition slideFromRight = const GoTransition()
      .withSlide
      .withStyle(
        offset: const Offset(1, 0),
        curve: AppMotion.emphasized,
      )
      .withSettings(duration: AppMotion.medium);

  /// Sobe de baixo, estilo bottom sheet. Fluxos modais.
  static final GoTransition slideUp = const GoTransition()
      .withSlide
      .withStyle(
        offset: const Offset(0, 1),
        curve: AppMotion.emphasized,
      )
      .withSettings(duration: AppMotion.slow);
}
