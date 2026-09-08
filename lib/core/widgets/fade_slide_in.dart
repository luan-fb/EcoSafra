import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Faz o filho aparecer deslizando e desvanecendo — a entrada padrão do app.
///
/// Por que `TweenAnimationBuilder` e não `AnimationController`:
/// ele é uma animação *implícita*, dispara sozinho ao ser montado e se
/// descarta sozinho. Para um efeito "toca uma vez ao aparecer" é a ferramenta
/// certa; `AnimationController` (explícito) só se justifica quando você
/// precisa controlar play/pause/reverse — veja a splash.
///
/// `delay` permite escalonar vários filhos (efeito *stagger*).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.slow,
    this.offset = const Offset(0, 24),
    this.curve = AppMotion.decelerate,
    super.key,
  });

  /// Constrói o item de índice [index] de uma lista já escalonado.
  factory FadeSlideIn.staggered({
    required int index,
    required Widget child,
    Key? key,
  }) =>
      FadeSlideIn(
        key: key,
        delay: AppMotion.staggerStep * index,
        child: child,
      );

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Deslocamento inicial em pixels lógicos.
  final Offset offset;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    // Acessibilidade: quem pediu "reduzir movimento" recebe o conteúdo direto.
    if (context.reduceMotion) return child;

    return _DelayedBuild(
      delay: delay,
      placeholder: Opacity(opacity: 0, child: child),
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: duration,
        curve: curve,
        // `child` fica fora do builder de propósito: ele é construído uma vez
        // só e reaproveitado a cada frame, em vez de re-buildar 60x por segundo.
        child: child,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(offset.dx * (1 - t), offset.dy * (1 - t)),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Só monta [builder] depois de [delay]. Mantém o espaço reservado antes disso
/// para o layout não "pular" quando a animação começar.
class _DelayedBuild extends StatefulWidget {
  const _DelayedBuild({
    required this.delay,
    required this.builder,
    required this.placeholder,
  });

  final Duration delay;
  final WidgetBuilder builder;
  final Widget placeholder;

  @override
  State<_DelayedBuild> createState() => _DelayedBuildState();
}

class _DelayedBuildState extends State<_DelayedBuild> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _ready = true;
      return;
    }
    Future<void>.delayed(widget.delay, () {
      // `mounted` evita setState num widget já removido da árvore — a causa
      // número um de crash em animações com delay.
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) =>
      _ready ? widget.builder(context) : widget.placeholder;
}
