import 'dart:async';

import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/user_avatar.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Menu lateral do app. Só uma seção de verdade por enquanto (Painel) — o
/// item "Agenda" já aparece desabilitado, com um selo "Em breve": é o
/// lugar reservado pro Caderno de Agendamento (Firestore) que vem a seguir,
/// então o menu não vai precisar de retrabalho quando essa tela existir.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  UserAvatar(photoUrl: user?.photoUrl, radius: 24),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ??
                              context.l10n.dashboardDefaultUserName,
                          style: context.texts.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user?.email != null)
                          Text(
                            user!.email!,
                            style: context.texts.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: Text(context.l10n.drawerMenuDashboard),
              selected: true,
              selectedTileColor: context.colors.primaryContainer,
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              enabled: false,
              leading: const Icon(Icons.event_note_rounded),
              title: Text(context.l10n.drawerMenuSchedule),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  context.l10n.drawerMenuComingSoon,
                  style: context.texts.labelSmall,
                ),
              ),
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: Text(
                context.l10n.drawerMenuSignOut,
                style: const TextStyle(color: AppColors.danger),
              ),
              onTap: () {
                Navigator.of(context).pop();
                unawaited(context.read<AuthCubit>().signOut());
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
