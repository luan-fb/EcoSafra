import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/fade_slide_in.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:ecosafra/features/dashboard/presentation/widgets/decision_card.dart';
import 'package:ecosafra/features/weather/domain/entities/fertilizer_advice.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// `hide BindContextExtension`: o go_router_modular também define um
// `context.read<T>()` (atalho pra `Modular.get<T>()`), que colide com o
// `context.read<T>()` do flutter_bloc (leitura reativa via Provider) —
// aqui queremos sempre o do bloc, `Modular.get<T>()` continua disponível.
import 'package:go_router_modular/go_router_modular.dart'
    hide BindContextExtension;
import 'package:intl/intl.dart';

/// Painel principal — o card de decisão (verde/amarelo/vermelho) é o
/// "coração visual" do app: muda de cor de forma animada assim que uma
/// previsão nova chega (ver `DecisionCard`).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<DashboardCubit>(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

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
      body: RefreshIndicator(
        onRefresh: context.read<DashboardCubit>().loadForecast,
        child: ListView(
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
                          user?.displayName ??
                              context.l10n.dashboardDefaultUserName,
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
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) => switch (state.status) {
                DashboardStatus.initial ||
                DashboardStatus.loading =>
                  const _LoadingSection(),
                DashboardStatus.error => _ErrorSection(
                    message: state.failure?.message ??
                        context.l10n.dashboardErrorTitle,
                  ),
                DashboardStatus.loaded => _ForecastSection(
                    forecast: state.forecast!,
                    advice: state.advice!,
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 40,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.texts.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () => context.read<DashboardCubit>().loadForecast(),
            child: Text(context.l10n.dashboardRetryButton),
          ),
        ],
      ),
    );
  }
}

class _ForecastSection extends StatelessWidget {
  const _ForecastSection({required this.forecast, required this.advice});

  final WeatherForecast forecast;
  final FertilizerAdvice advice;

  @override
  Widget build(BuildContext context) {
    final now = forecast.hourly.first;

    // Soma a chuva das próximas ~48h (a API devolve uma entrada por hora).
    final next48h = forecast.hourly.take(48);
    final rainNext48h =
        next48h.fold<double>(0, (total, point) => total + point.precipitation);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (forecast.isStale)
          FadeSlideIn(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.caution.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: AppColors.caution),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      context.l10n.dashboardOfflineBanner(
                        DateFormat.Hm().format(forecast.fetchedAt),
                      ),
                      style: context.texts.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        FadeSlideIn.staggered(
          index: 0,
          child: DecisionCard(advice: advice),
        ),
        const SizedBox(height: AppSpacing.lg),
        FadeSlideIn.staggered(
          index: 1,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.dashboardNowCardTitle,
                    style: context.texts.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${now.temperature.round()}°C',
                    style: context.texts.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _InfoChip(
                        icon: Icons.water_drop_outlined,
                        label: context.l10n.dashboardHumidityLabel,
                        value: '${now.relativeHumidity}%',
                      ),
                      _InfoChip(
                        icon: Icons.air_rounded,
                        label: context.l10n.dashboardWindLabel,
                        value: '${now.windSpeed.round()} km/h',
                      ),
                      _InfoChip(
                        icon: Icons.umbrella_outlined,
                        label: context.l10n.dashboardNext48hRainLabel,
                        value: '${rainNext48h.toStringAsFixed(1)} mm',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.l10n.dashboardDailyForecastTitle,
          style: context.texts.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final (i, day) in forecast.daily.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: FadeSlideIn.staggered(
              index: i + 2,
              child: Card(
                child: ListTile(
                  title: Text(DateFormat.MMMEd('pt_BR').format(day.date)),
                  subtitle: Text(
                    '${day.precipitationSum.toStringAsFixed(1)} mm · '
                    '${day.precipitationProbabilityMax}%',
                  ),
                  trailing: Text(
                    '${day.temperatureMax.round()}° / ${day.temperatureMin.round()}°',
                    style: context.texts.titleSmall,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: context.colors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$label: $value',
          style: context.texts.bodySmall,
        ),
      ],
    );
  }
}
