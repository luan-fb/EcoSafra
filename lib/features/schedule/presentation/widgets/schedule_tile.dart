import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _ScheduleTileAction { delete }

/// Um agendamento na lista: data, observação, risco do dia (ou "Data
/// passada"), conclusão e exclusão.
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
    final mutedColor = context.colors.onSurfaceVariant;
    final note = schedule.note;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) => onToggleCompleted(value ?? false),
        ),
        // Concluído é histórico: para mudar, desfaz a conclusão antes (AGD-27).
        onTap: isCompleted ? null : onEdit,
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: context.texts.titleSmall!.copyWith(
            color: isCompleted ? mutedColor : context.colors.onSurface,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
          child: Text(DateFormat.yMMMEd('pt_BR').format(schedule.scheduledDate)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note != null)
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                style: context.texts.bodySmall!.copyWith(
                  color: mutedColor,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
                child: Text(note),
              ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topLeft,
              child: isCompleted
                  ? const SizedBox(width: double.infinity, height: 0)
                  : _StatusLabel(item: item),
            ),
          ],
        ),
        trailing: PopupMenuButton<_ScheduleTileAction>(
          tooltip: context.l10n.scheduleDeleteConfirmConfirm,
          onSelected: (action) {
            if (action == _ScheduleTileAction.delete) onDelete();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _ScheduleTileAction.delete,
              child: Text(context.l10n.scheduleDeleteConfirmConfirm),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.item});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final palette = item.isPastDue
        ? _RiskPalette(
            color: AppColors.caution,
            icon: Icons.event_busy_rounded,
            label: context.l10n.scheduleStatusPastDue,
          )
        : _paletteFor(context, item.risk);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(palette.icon, size: 16, color: palette.color),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: Text(
              palette.label,
              style: context.texts.bodySmall?.copyWith(color: palette.color),
            ),
          ),
        ],
      ),
    );
  }

  _RiskPalette _paletteFor(BuildContext context, ScheduleRiskLevel risk) =>
      switch (risk) {
        ScheduleRiskLevel.ok => _RiskPalette(
          color: AppColors.safe,
          icon: Icons.check_circle_rounded,
          label: context.l10n.scheduleRiskOk,
        ),
        ScheduleRiskLevel.atRisk => _RiskPalette(
          color: AppColors.danger,
          icon: Icons.warning_rounded,
          label: context.l10n.scheduleRiskAtRisk,
        ),
        ScheduleRiskLevel.unknown => _RiskPalette(
          color: context.colors.onSurfaceVariant,
          icon: Icons.help_outline_rounded,
          label: context.l10n.scheduleRiskUnknown,
        ),
      };
}

class _RiskPalette {
  const _RiskPalette({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;
}
