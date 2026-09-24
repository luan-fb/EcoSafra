import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/animated_check.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_date_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

/// Dia da semana por extenso, com a inicial maiúscula (`DateFormat.EEEE`
/// devolve tudo em minúsculas em pt_BR).
String _capitalizedWeekday(DateTime date) {
  final weekday = DateFormat.EEEE('pt_BR').format(date);
  return weekday.isEmpty
      ? weekday
      : weekday[0].toUpperCase() + weekday.substring(1);
}

/// Um agendamento na lista: bloco de data colorido pelo status à esquerda,
/// dia da semana, observação e rótulo de status ao centro, e o controle de
/// conclusão à direita (SCHEDUI-05..09).
///
/// Concluído: sem toque para editar, sem rótulo de risco, estilo apagado.
class ScheduleTile extends StatelessWidget {
  const ScheduleTile({
    required this.item,
    required this.onEdit,
    required this.onToggleCompleted,
    required this.onDelete,
    super.key,
  });

  final ScheduleItem item;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggleCompleted;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final schedule = item.schedule;
    final isCompleted = schedule.isCompleted;
    final palette = _paletteFor(context, item);
    final canEdit = !isCompleted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Semantics(
                label: _semanticLabel(context, item, palette),
                button: canEdit,
                excludeSemantics: true,
                onTap: canEdit ? onEdit : null,
                customSemanticsActions: {
                  CustomSemanticsAction(
                    label: context.l10n.scheduleTileDeleteAction,
                  ): onDelete,
                },
                child: InkWell(
                  // Concluído é histórico: para mudar, desfaz a conclusão
                  // antes (AGD-27).
                  onTap: canEdit ? onEdit : null,
                  // Mesmo raio do `CardThemeData` (`AppTheme`), para o
                  // ripple não vazar pelo canto arredondado do `Card`.
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ScheduleDateBlock(
                        date: schedule.scheduledDate,
                        background: palette.blockBackground,
                        foreground: palette.blockForeground,
                        pulse:
                            !isCompleted &&
                            item.risk == ScheduleRiskLevel.atRisk,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _Content(
                          item: item,
                          isCompleted: isCompleted,
                          palette: palette,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedCheck(
              value: isCompleted,
              onChanged: onToggleCompleted,
            ),
          ],
        ),
      ),
    );
  }

  String _semanticLabel(
    BuildContext context,
    ScheduleItem item,
    _TilePalette palette,
  ) {
    final schedule = item.schedule;
    final weekday = _capitalizedWeekday(schedule.scheduledDate);
    final date = DateFormat.yMMMMd('pt_BR').format(schedule.scheduledDate);
    final note = schedule.note;

    return [weekday, date, palette.statusLabel, ?note].join(', ');
  }

  _TilePalette _paletteFor(BuildContext context, ScheduleItem item) {
    final neutralBackground = context.colors.surfaceContainerHigh;
    final neutralForeground = context.colors.onSurfaceVariant;

    if (item.schedule.isCompleted) {
      return _TilePalette(
        blockBackground: neutralBackground,
        blockForeground: neutralForeground,
        accentColor: neutralForeground,
        statusIcon: Icons.check_circle_rounded,
        statusLabel: context.l10n.scheduleStatusCompleted,
      );
    }
    if (item.isPastDue) {
      return _TilePalette(
        blockBackground: AppColors.caution,
        blockForeground: Colors.white,
        accentColor: AppColors.caution,
        statusIcon: Icons.event_busy_rounded,
        statusLabel: context.l10n.scheduleStatusPastDue,
      );
    }
    return switch (item.risk) {
      ScheduleRiskLevel.ok => _TilePalette(
        blockBackground: AppColors.safe,
        blockForeground: Colors.white,
        accentColor: AppColors.safe,
        statusIcon: Icons.check_circle_rounded,
        statusLabel: context.l10n.scheduleRiskOk,
      ),
      ScheduleRiskLevel.atRisk => _TilePalette(
        blockBackground: AppColors.danger,
        blockForeground: Colors.white,
        accentColor: AppColors.danger,
        statusIcon: Icons.warning_rounded,
        statusLabel: context.l10n.scheduleRiskAtRisk,
      ),
      ScheduleRiskLevel.unknown => _TilePalette(
        blockBackground: neutralBackground,
        blockForeground: neutralForeground,
        accentColor: neutralForeground,
        statusIcon: Icons.help_outline_rounded,
        statusLabel: context.l10n.scheduleRiskUnknown,
      ),
    };
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.item,
    required this.isCompleted,
    required this.palette,
  });

  final ScheduleItem item;
  final bool isCompleted;
  final _TilePalette palette;

  @override
  Widget build(BuildContext context) {
    final schedule = item.schedule;
    final mutedColor = context.colors.onSurfaceVariant;
    final note = schedule.note;
    final capitalizedWeekday = _capitalizedWeekday(schedule.scheduledDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDefaultTextStyle(
          duration: AppMotion.medium,
          curve: AppMotion.emphasized,
          style: context.texts.titleSmall!.copyWith(
            color: isCompleted ? mutedColor : context.colors.onSurface,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
          child: Text(capitalizedWeekday),
        ),
        if (note != null)
          AnimatedDefaultTextStyle(
            duration: AppMotion.medium,
            curve: AppMotion.emphasized,
            style: context.texts.bodySmall!.copyWith(
              color: mutedColor,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
            child: Text(note),
          ),
        AnimatedSize(
          duration: AppMotion.medium,
          curve: AppMotion.emphasized,
          alignment: Alignment.topLeft,
          child: isCompleted
              ? const SizedBox(width: double.infinity, height: 0)
              : _StatusRow(item: item, palette: palette),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.item, required this.palette});

  final ScheduleItem item;
  final _TilePalette palette;

  @override
  Widget build(BuildContext context) {
    final rainMm = item.expectedRainMm;
    final showRain = item.risk == ScheduleRiskLevel.atRisk && rainMm != null;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(palette.statusIcon, size: 16, color: palette.accentColor),
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  palette.statusLabel,
                  style: context.texts.bodySmall?.copyWith(
                    color: palette.accentColor,
                  ),
                ),
              ),
            ],
          ),
          if (showRain)
            Text(
              context.l10n.scheduleRainExpected(
                NumberFormat.decimalPatternDigits(
                  locale: 'pt_BR',
                  decimalDigits: 1,
                ).format(rainMm),
              ),
              style: context.texts.bodySmall?.copyWith(
                color: palette.accentColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _TilePalette {
  const _TilePalette({
    required this.blockBackground,
    required this.blockForeground,
    required this.accentColor,
    required this.statusIcon,
    required this.statusLabel,
  });

  /// Cor de fundo e de texto do `ScheduleDateBlock`.
  final Color blockBackground;
  final Color blockForeground;

  /// Cor do ícone e do texto do rótulo de status, dentro do card.
  final Color accentColor;
  final IconData statusIcon;
  final String statusLabel;
}
