import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

/// Cabeçalho de marca do painel: gradiente verde, cantos arredondados só
/// embaixo, saudação que muda com a hora do dia.
///
/// É um `Container` comum, não precisa de `AppBar` — o botão de menu aqui
/// dentro é quem abre o `Drawer` (via [onMenuTap]), então o `Scaffold` que
/// usa isto não declara `appBar:` nenhum.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    required this.userName,
    required this.userPhotoUrl,
    required this.onMenuTap,
    super.key,
  });

  final String userName;
  final String? userPhotoUrl;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusLg * 1.5),
          bottomRight: Radius.circular(AppSpacing.radiusLg * 1.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onMenuTap,
                    icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  UserAvatar(
                    photoUrl: userPhotoUrl,
                    radius: 20,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    iconColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting(context)}, $userName',
                      style: context.texts.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      context.l10n.dashboardHeaderSubtitle,
                      style: context.texts.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    return switch (hour) {
      < 12 => context.l10n.dashboardGreetingMorning,
      < 18 => context.l10n.dashboardGreetingAfternoon,
      _ => context.l10n.dashboardGreetingEvening,
    };
  }
}
