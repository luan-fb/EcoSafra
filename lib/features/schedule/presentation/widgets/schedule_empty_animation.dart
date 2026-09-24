import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Uma animação nativa explícita (Explicit Animation) para o estado vazio da agenda.
/// 
/// O widget usa um [AnimationController] em loop contínuo para criar um
/// efeito de 'pulso/rotação' suave num ícone de calendário. 
/// Respeita a regra de acessibilidade: caso o sistema esteja com "Reduzir Movimento"
/// ativado, a animação não entra em loop.
class ScheduleEmptyAnimation extends StatefulWidget {
  const ScheduleEmptyAnimation({super.key});

  @override
  State<ScheduleEmptyAnimation> createState() => _ScheduleEmptyAnimationState();
}

class _ScheduleEmptyAnimationState extends State<ScheduleEmptyAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Efeito de respiração (aumenta e volta)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(_controller);

    // Balanço suave (tilt)
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.05).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
    ]).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // SCHEDUI-01: Respeita acessibilidade.
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _controller.stop();
      _controller.value = 0.0;
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
      child: const Icon(
        Icons.event_available_rounded,
        size: 80,
        color: AppColors.inkMuted,
      ),
    );
  }
}
