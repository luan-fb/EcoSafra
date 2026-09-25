import 'dart:async';

import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_risk_level.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Cores do `ScheduleDateBlock` pelo status do agendamento: regra única,
/// usada pelo card da lista (`ScheduleTile`) e pelo bloco de data do
/// formulário de edição, para as duas telas nunca discordarem sobre a cor
/// de um mesmo status.
({Color background, Color foreground}) scheduleDateBlockPalette(
  BuildContext context,
  ScheduleItem item,
) {
  final neutralBackground = context.colors.surfaceContainerHigh;
  final neutralForeground = context.colors.onSurfaceVariant;

  if (item.schedule.isCompleted) {
    return (background: neutralBackground, foreground: neutralForeground);
  }
  if (item.isPastDue) {
    // Âmbar é claro: texto branco teria contraste de 2,2:1.
    return (background: AppColors.caution, foreground: AppColors.ink);
  }
  return switch (item.risk) {
    ScheduleRiskLevel.ok => (
      background: AppColors.safe,
      foreground: Colors.white,
    ),
    ScheduleRiskLevel.atRisk => (
      background: AppColors.danger,
      foreground: Colors.white,
    ),
    ScheduleRiskLevel.unknown => (
      background: neutralBackground,
      foreground: neutralForeground,
    ),
  };
}

/// Bloco de data à esquerda do card da agenda: dia do mês em destaque e mês
/// abreviado, coloridos pelo status do agendamento (SCHEDUI-05, SCHEDUI-06).
///
/// Com `pulse: true` e sem redução de movimento, o bloco respira (escala e
/// brilho) em loop para chamar atenção para um agendamento em risco
/// (SCHEDUI-20).
class ScheduleDateBlock extends StatefulWidget {
  const ScheduleDateBlock({
    required this.date,
    required this.background,
    required this.foreground,
    this.pulse = false,
    super.key,
  });

  final DateTime date;
  final Color background;
  final Color foreground;
  final bool pulse;

  @override
  State<ScheduleDateBlock> createState() => _ScheduleDateBlockState();
}

class _ScheduleDateBlockState extends State<ScheduleDateBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.xSlow,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: 1.06,
  ).chain(CurveTween(curve: AppMotion.emphasized)).animate(_controller);

  // Em `didChangeDependencies`, e não no `initState`: a opção de redução de
  // movimento pode mudar com a tela aberta (mesmo padrão de
  // `ScheduleEmptyAnimation`).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant ScheduleDateBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulse != widget.pulse) _syncAnimation();
  }

  void _syncAnimation() {
    final shouldPulse = widget.pulse && !context.reduceMotion;
    if (shouldPulse) {
      if (!_controller.isAnimating) {
        unawaited(_controller.repeat(reverse: true));
      }
    } else if (_controller.isAnimating || _controller.value != 0) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.date.day.toString();
    final month = DateFormat(
      'MMM',
      'pt_BR',
    ).format(widget.date).toUpperCase().replaceAll('.', '');

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final glow = _controller.value;
          return Transform.scale(
            scale: _scale.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: glow == 0
                    ? null
                    : [
                        BoxShadow(
                          color: widget.background.withValues(
                            alpha: 0.5 * glow,
                          ),
                          blurRadius: 12 * glow,
                          spreadRadius: 2 * glow,
                        ),
                      ],
              ),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                day,
                style: context.texts.titleLarge?.copyWith(
                  color: widget.foreground,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(
                month,
                style: context.texts.labelSmall?.copyWith(
                  color: widget.foreground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
