import 'dart:async';

import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Tela de abertura.
///
/// Aqui usamos animação **explícita** (`AnimationController`), o oposto do
/// `FadeSlideIn`. A razão: precisamos de várias animações coreografadas sobre
/// a mesma linha do tempo e de saber exatamente quando ela termina para
/// navegar. Um controller único + vários `Interval` é o padrão para isso —
/// chama-se *staggered animation*.
///
/// `SingleTickerProviderStateMixin` fornece o `vsync`: ele amarra a animação
/// ao ciclo de frames da tela, e pausa quando a rota sai de vista. Sem vsync
/// a animação continuaria rodando em segundo plano gastando bateria.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  // Cada Animation "fatia" o controller com um Interval: a folha anima de 0%
  // a 45% do tempo total, o título de 35% a 70%, e assim por diante.
  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.45, curve: AppMotion.springy),
  );

  late final Animation<double> _logoRotation = Tween<double>(
    begin: -0.35,
    end: 0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
    ),
  );

  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 0.7, curve: AppMotion.decelerate),
  );

  late final Animation<Offset> _titleSlide = Tween<Offset>(
    begin: const Offset(0, 0.6),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75, curve: AppMotion.decelerate),
    ),
  );

  late final Animation<double> _taglineFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    // Esquecer isto é vazamento de memória garantido.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    // TODO(auth): checar o AuthCubit e decidir entre signIn e dashboard.
    if (!mounted) return;
    context.goNamed(AppRoute.signIn.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // AnimatedBuilder reconstrói só esta subárvore a cada frame.
              // O `child` é passado de fora e não é reconstruído — detalhe de
              // performance que vale para toda animação em Flutter.
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.rotate(
                  angle: _logoRotation.value,
                  child: Transform.scale(scale: _logoScale.value, child: child),
                ),
                child: const _SplashLogo(),
              ),

              const SizedBox(height: AppSpacing.xl),

              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Text(
                    'EcoSafra',
                    style: context.texts.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              FadeTransition(
                opacity: _taglineFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Text(
                    'Adube na hora certa. Proteja o rio.',
                    textAlign: TextAlign.center,
                    style: context.texts.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              FadeTransition(
                opacity: _taglineFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  child: TextButton(
                    onPressed: () => unawaited(_goNext()),
                    child: const Text(
                      'Começar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg * 1.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: const Icon(Icons.eco_rounded, size: 72, color: Colors.white),
    );
  }
}
