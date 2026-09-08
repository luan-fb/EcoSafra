import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:go_router_modular/go_router_modular.dart';

/// Tela de login (esqueleto).
///
/// Ainda sem Cubit: a feature `auth` será construída na próxima etapa
/// (domain → data → presentation). O que já existe aqui é o padrão de
/// entrada escalonada dos elementos, usando [FadeSlideIn].
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              FadeSlideIn.staggered(
                index: 0,
                child: Icon(
                  Icons.eco_rounded,
                  size: 64,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeSlideIn.staggered(
                index: 1,
                child: Text(
                  'Bem-vindo ao EcoSafra',
                  textAlign: TextAlign.center,
                  style: context.texts.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FadeSlideIn.staggered(
                index: 2,
                child: Text(
                  'Entre para acompanhar a previsão de chuva da sua área '
                  'e saber a melhor janela para adubar.',
                  textAlign: TextAlign.center,
                  style: context.texts.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              FadeSlideIn.staggered(
                index: 3,
                child: FilledButton.icon(
                  // TODO(auth): disparar AuthCubit.signInWithGoogle().
                  onPressed: () => context.goNamed(AppRoute.dashboard.name),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: const Text('Entrar com Google'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn.staggered(
                index: 4,
                child: Text(
                  'Usamos sua localização apenas para buscar a previsão '
                  'do tempo do seu talhão.',
                  textAlign: TextAlign.center,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
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
