import 'dart:async';

import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Controle de conclusão do agendamento: substitui o `Checkbox` do Material
/// por um traço desenhado progressivamente com `CustomPainter` e
/// `PathMetric` (SCHEDUI-08, SCHEDUI-19).
///
/// Marcar anima o traço de 0 a 1 em `AppMotion.medium`; desmarcar, de 1 a 0.
/// Com redução de movimento, o valor muda direto, sem passar por estados
/// intermediários. Mantém a semântica de um checkbox e um alvo de toque de
/// 48 x 48 (SCHEDUI-09, SCHEDUI-21).
class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  static const double targetSize = 48;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
    value: widget.value ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant AnimatedCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _syncValue();
  }

  void _syncValue() {
    final target = widget.value ? 1.0 : 0.0;
    if (context.reduceMotion) {
      _controller.value = target;
    } else {
      unawaited(_controller.animateTo(target, curve: AppMotion.emphasized));
    }
  }

  void _handleTap() => widget.onChanged(!widget.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      checked: widget.value,
      onTap: _handleTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: SizedBox(
          width: AnimatedCheck.targetSize,
          height: AnimatedCheck.targetSize,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _CheckPainter(
                  progress: _controller.value,
                  borderColor: colors.outline,
                  fillColor: colors.primary,
                  checkColor: colors.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({
    required this.progress,
    required this.borderColor,
    required this.fillColor,
    required this.checkColor,
  });

  final double progress;
  final Color borderColor;
  final Color fillColor;
  final Color checkColor;

  static const double _boxSize = 24;
  static const double _radius = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: _boxSize,
      height: _boxSize,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_radius));

    canvas
      ..drawRRect(
        rrect,
        Paint()
          ..color = Color.lerp(
            borderColor.withValues(alpha: 0),
            fillColor,
            progress,
          )!
          ..style = PaintingStyle.fill,
      )
      ..drawRRect(
        rrect.deflate(1),
        Paint()
          ..color = Color.lerp(borderColor, fillColor, progress)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

    if (progress > 0) {
      final metric = _checkPath(rect).computeMetrics().first;
      final tracedCheck = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(
        tracedCheck,
        Paint()
          ..color = checkColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  Path _checkPath(Rect rect) => Path()
    ..moveTo(rect.left + rect.width * 0.22, rect.top + rect.height * 0.52)
    ..lineTo(rect.left + rect.width * 0.42, rect.top + rect.height * 0.72)
    ..lineTo(rect.left + rect.width * 0.78, rect.top + rect.height * 0.28);

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.checkColor != checkColor;
}
