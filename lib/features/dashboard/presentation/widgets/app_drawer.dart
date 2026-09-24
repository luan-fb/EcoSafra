import 'dart:async';

import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/user_avatar.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// `hide BindContextExtension`: mesmo motivo do painel — o go_router_modular
// também define `context.read<T>()`, que colide com o do flutter_bloc.
import 'package:go_router_modular/go_router_modular.dart'
    hide BindContextExtension;

/// Menu lateral do app: Painel e Agenda (caderno de agendamento), com o
/// item atual destacado.
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
              leading: const Icon(Icons.event_note_rounded),
              title: Text(context.l10n.drawerMenuSchedule),
              onTap: () {
                Navigator.of(context).pop();
                unawaited(context.pushNamed(AppRoute.schedule.name));
              },
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
