import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/weather/domain/entities/fertilizer_advice.dart';
import 'package:flutter/material.dart';

/// O card de semáforo: a resposta a "posso adubar agora?" em uma cor só.
///
/// Duas animações diferentes, cada uma pela ferramenta certa:
/// - a cor de fundo é `AnimatedContainer` (implícita) — ela mesma detecta
///   que a `Color` mudou entre um build e outro e interpola sozinha, sem
///   controller nenhum;
/// - ícone e texto usam `AnimatedSwitcher`, porque não dá pra interpolar
///   "Icons.check_circle" até "Icons.warning" — o que a gente quer é um
///   widget desaparecer (fade + leve encolhida) enquanto o outro aparece.
class DecisionCard extends StatelessWidget {
  const DecisionCard({required this.advice, super.key});

  final FertilizerAdvice advice;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(advice.level);
    final headline = _headline(context, advice.level);

    return AnimatedContainer(
      duration: AppMotion.slow,
      curve: AppMotion.emphasized,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.light, palette.dark],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.dark.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: AppMotion.medium,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: Icon(
              palette.icon,
              key: ValueKey(advice.level),
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: AppMotion.medium,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              headline,
              key: ValueKey(advice.level),
              style: context.texts.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.decisionCardRainNext24h(
              advice.rainNext24h.toStringAsFixed(1),
            ),
            style: context.texts.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          // `AnimatedSize` faz o card crescer/encolher suavemente quando o
          // aviso de prejuízo entra ou sai — sem ela, o card "pularia" de
          // altura de um frame pro outro.
          AnimatedSize(
            duration: AppMotion.medium,
            curve: AppMotion.emphasized,
            alignment: Alignment.topCenter,
            child: advice.estimatedLossPercent == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.trending_down_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                context.l10n.decisionCardEstimatedLoss(
                                  advice.estimatedLossPercent!.round(),
                                ),
                                style: context.texts.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  _DecisionPalette _palette(AdviceLevel level) => switch (level) {
        AdviceLevel.safe => const _DecisionPalette(
            light: AppColors.safe,
            dark: AppColors.primaryDark,
            icon: Icons.check_circle_rounded,
          ),
        AdviceLevel.caution => const _DecisionPalette(
            light: Color(0xFFF0B84D),
            dark: AppColors.caution,
            icon: Icons.warning_rounded,
          ),
        AdviceLevel.danger => const _DecisionPalette(
            light: Color(0xFFD9584A),
            dark: AppColors.danger,
            icon: Icons.dangerous_rounded,
          ),
      };

  String _headline(BuildContext context, AdviceLevel level) => switch (level) {
        AdviceLevel.safe => context.l10n.decisionCardSafeHeadline,
        AdviceLevel.caution => context.l10n.decisionCardCautionHeadline,
        AdviceLevel.danger => context.l10n.decisionCardDangerHeadline,
      };
}

class _DecisionPalette {
  const _DecisionPalette({
    required this.light,
    required this.dark,
    required this.icon,
  });

  final Color light;
  final Color dark;
  final IconData icon;
}
