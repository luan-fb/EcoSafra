import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/user_avatar.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
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
    this.location,
    this.onLocationTap,
    super.key,
  });

  final String userName;
  final String? userPhotoUrl;
  final VoidCallback onMenuTap;

  /// Lugar da previsão exibida; `null` enquanto não há previsão ou nome.
  final LocationDescription? location;
  final VoidCallback? onLocationTap;

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
                    if (location case final location?)
                      _LocationChip(location: location, onTap: onLocationTap),
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

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.location, required this.onTap});

  final LocationDescription location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: 0.85);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: ConstrainedBox(
          // Alvo de toque mínimo de 48 dp.
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                switch (location.source) {
                  LocationSource.device => Icons.my_location_rounded,
                  LocationSource.chosen => Icons.place_rounded,
                },
                size: 18,
                color: color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  location.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
