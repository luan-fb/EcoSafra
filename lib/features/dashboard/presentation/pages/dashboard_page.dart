import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/fade_slide_in.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Painel principal (esqueleto).
///
/// Vai receber, na próxima etapa: o card de decisão verde/vermelho, a
/// previsão de 7 dias e o talhão selecionado.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Só lê o usuário atual (sem rebuild reativo): se a sessão cair, quem
    // navega pra fora daqui é o BlocListener global em EcoSafraApp, não esta
    // tela — ela não precisa "saber" disso, só some da árvore.
    final user = context.read<AuthCubit>().state.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.dashboardTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.dashboardSignOutTooltip,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? const Icon(Icons.person_rounded)
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? context.l10n.dashboardDefaultUserName,
                        style: context.texts.titleMedium,
                      ),
                      if (user?.email != null)
                        Text(
                          user!.email!,
                          style: context.texts.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < 4; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: FadeSlideIn.staggered(
                index: i,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.dashboardPlaceholderBlockTitle(i + 1),
                          style: context.texts.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          context.l10n.dashboardPlaceholderBlockSubtitle,
                          style: context.texts.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
