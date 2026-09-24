import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_alert.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Aviso do painel sobre a agenda: risco de chuva forte num agendamento ou
/// lembrete de aplicação para hoje/amanhã (AGD-15..19).
///
/// Sem `alert`, o card some por completo (`SizedBox.shrink`) em vez de só
/// ficar invisível — senão o painel manteria um buraco vazio no lugar.
class ScheduleAlertBanner extends StatelessWidget {
  const ScheduleAlertBanner({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleAlertCubit, ScheduleAlertState>(
      builder: (context, state) {
        final alert = state.alert;
        final child = alert == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _AlertCard(alert: alert, onTap: onTap),
              );

        // Sem animação, e não `AnimatedSize` com duração zero: esse caso
        // marca o layout como sujo de novo durante o próprio layout.
        if (context.reduceMotion) return child;

        return AnimatedSize(
          duration: AppMotion.medium,
          curve: AppMotion.emphasized,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.onTap});

  final ScheduleAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(context, alert);
    final text = _textFor(context, alert);

    return Semantics(
      button: true,
      label: text,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(palette.icon, color: palette.foreground),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      text,
                      style: context.texts.bodyMedium?.copyWith(
                        color: palette.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.foreground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _AlertPalette _paletteFor(BuildContext context, ScheduleAlert alert) =>
      switch (alert) {
        ScheduleRiskAlert() => const _AlertPalette(
          background: AppColors.danger,
          foreground: Colors.white,
          icon: Icons.warning_amber_rounded,
        ),
        ScheduleTodayReminder() || ScheduleTomorrowReminder() => _AlertPalette(
          background: context.colors.primaryContainer,
          foreground: context.colors.onPrimaryContainer,
          icon: Icons.event_available_rounded,
        ),
      };

  String _textFor(BuildContext context, ScheduleAlert alert) => switch (alert) {
    ScheduleRiskAlert(:final count) => context.l10n.scheduleAlertRiskCount(
      count,
    ),
    ScheduleTodayReminder() => context.l10n.scheduleAlertTodayReminder,
    ScheduleTomorrowReminder() => context.l10n.scheduleAlertTomorrowReminder,
  };
}

class _AlertPalette {
  const _AlertPalette({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
}
