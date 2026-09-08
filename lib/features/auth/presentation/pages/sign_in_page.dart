import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/fade_slide_in.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela de login.
///
/// Não navega sozinha: ao logar com sucesso, é o `BlocListener` global em
/// `EcoSafraApp` (que assiste o mesmo `AuthCubit`) quem manda para o painel.
/// Esta tela só dispara a ação e reage ao estado (carregando/erro).
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
                  context.l10n.signInWelcomeTitle,
                  textAlign: TextAlign.center,
                  style: context.texts.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FadeSlideIn.staggered(
                index: 2,
                child: Text(
                  context.l10n.signInWelcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: context.texts.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              FadeSlideIn.staggered(
                index: 3,
                child: BlocConsumer<AuthCubit, AuthState>(
                  listenWhen: (previous, current) =>
                      previous.failure != current.failure &&
                      current.failure != null,
                  listener: (context, state) =>
                      context.showSnack(state.failure!.message, isError: true),
                  builder: (context, state) => FilledButton.icon(
                    onPressed: state.isSigningIn
                        ? null
                        : () => context.read<AuthCubit>().signInWithGoogle(),
                    icon: state.isSigningIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.g_mobiledata_rounded, size: 28),
                    label: Text(
                      state.isSigningIn
                          ? context.l10n.signInGoogleButtonLoading
                          : context.l10n.signInGoogleButton,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn.staggered(
                index: 4,
                child: Text(
                  context.l10n.signInLocationDisclaimer,
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
