import 'dart:async';

import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Ícone de calendário que "respira" e balança em loop no estado vazio da
/// agenda. Com "remover animações", fica parado na posição inicial.
class ScheduleEmptyAnimation extends StatefulWidget {
  const ScheduleEmptyAnimation({super.key});

  @override
  State<ScheduleEmptyAnimation> createState() => _ScheduleEmptyAnimationState();
}

class _ScheduleEmptyAnimationState extends State<ScheduleEmptyAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  static final _ease = CurveTween(curve: Curves.easeInOut);

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 1, end: 1.1).chain(_ease),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.1, end: 1).chain(_ease),
      weight: 50,
    ),
  ]).animate(_controller);

  late final Animation<double> _tilt = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 0, end: 0.05).chain(_ease),
      weight: 25,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 0.05, end: -0.05).chain(_ease),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: -0.05, end: 0).chain(_ease),
      weight: 25,
    ),
  ]).animate(_controller);

  // Em `didChangeDependencies`, e não no `initState`: a opção de
  // acessibilidade pode mudar com a tela aberta.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: Transform.rotate(angle: _tilt.value, child: child),
        ),
        child: const Icon(
          Icons.event_available_rounded,
          size: 80,
          color: AppColors.inkMuted,
        ),
      ),
    );
  }
}
