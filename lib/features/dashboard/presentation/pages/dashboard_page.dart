import 'dart:async';

import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/app/widgets/app_drawer.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:ecosafra/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:ecosafra/features/dashboard/presentation/widgets/forecast_section.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_banner.dart';
import 'package:ecosafra/features/schedule/presentation/alert/schedule_alert_cubit.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// `hide BindContextExtension`: o go_router_modular também define um
// `context.read<T>()` (atalho pra `Modular.get<T>()`), que colide com o
// `context.read<T>()` do flutter_bloc (leitura reativa via Provider) —
// aqui queremos sempre o do bloc, `Modular.get<T>()` continua disponível.
import 'package:go_router_modular/go_router_modular.dart'
    hide BindContextExtension;

/// Painel principal — o card de decisão (verde/amarelo/vermelho) é o
/// "coração visual" do app: muda de cor de forma animada assim que uma
/// previsão nova chega (ver `DecisionCard`).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => Modular.get<DashboardCubit>()),
        BlocProvider(create: (_) => Modular.get<ScheduleAlertCubit>()),
      ],
      child: const DashboardView(),
    );
  }
}

/// O conteúdo da tela, separado de `DashboardPage` para não depender do
/// `Modular.get` nos testes de widget: providers dos cubits (mockados) já
/// são o suficiente para montar esta árvore, no molde do `ScheduleView`.
@visibleForTesting
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Só lê o usuário atual (sem rebuild reativo): se a sessão cair, quem
    // navega pra fora daqui é o BlocListener global em EcoSafraApp, não esta
    // tela — ela não precisa "saber" disso, só some da árvore.
    final user = context.read<AuthCubit>().state.user;

    return _RefreshAlertOnResume(
      child: Scaffold(
        // Sem `appBar:` de propósito — o cabeçalho de marca (`DashboardHeader`)
        // faz esse papel, incluindo o botão que abre este `drawer:`.
        drawer: const AppDrawer(),
        body: MultiBlocListener(
          listeners: [
            BlocListener<DashboardCubit, DashboardState>(
              // A previsão nova só interessa ao aviso quando o painel terminou
              // de carregar — repassar `loading`/`error` apagaria a previsão
              // anterior do `ScheduleAlertCubit`, que ainda vale enquanto uma
              // nova não chega.
              listenWhen: (previous, current) =>
                  current.status == DashboardStatus.loaded,
              listener: (context, state) => context
                  .read<ScheduleAlertCubit>()
                  .updateForecast(state.forecast),
            ),
            BlocListener<DashboardCubit, DashboardState>(
              listenWhen: (previous, current) =>
                  previous.refreshFailure != current.refreshFailure &&
                  current.refreshFailure != null,
              listener: (context, state) =>
                  _showRefreshFailure(context, state.refreshFailure!),
            ),
          ],
          child: RefreshIndicator(
            onRefresh: context.read<DashboardCubit>().loadForecast,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  // `Builder` dá um `context` que já fica ABAIXO do Scaffold na
                  // árvore — é o que permite `Scaffold.of(context).openDrawer()`
                  // funcionar. O `context` do método `build` acima ainda não
                  // serve: ele existe num ponto anterior à criação do Scaffold.
                  child: Builder(
                    builder: (context) {
                      // `?.split(' ').first` só cai no fallback se o nome for
                      // `null` — uma string vazia (não-nula) passaria direto e
                      // a saudação ficaria "Boa tarde, " sem nome nenhum.
                      final firstName = user?.displayName
                          ?.trim()
                          .split(' ')
                          .first;
                      return BlocSelector<
                        DashboardCubit,
                        DashboardState,
                        LocationDescription?
                      >(
                        selector: (state) => state.location,
                        builder: (context, location) => DashboardHeader(
                          userName: (firstName == null || firstName.isEmpty)
                              ? context.l10n.dashboardDefaultUserName
                              : firstName,
                          userPhotoUrl: user?.photoUrl,
                          onMenuTap: () => Scaffold.of(context).openDrawer(),
                          location: location,
                          onLocationTap: () =>
                              unawaited(_chooseLocation(context)),
                        ),
                      );
                    },
                  ),
                ),
                // Fora da `ForecastSection` de propósito: o aviso da agenda
                // segue valendo com a previsão carregando ou com erro (o
                // lembrete de hoje/amanhã não depende de chuva).
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: ScheduleAlertBanner(
                      onTap: () => context.goNamed(AppRoute.schedule.name),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: BlocBuilder<DashboardCubit, DashboardState>(
                      builder: (context, state) => switch (state.status) {
                        DashboardStatus.initial ||
                        DashboardStatus.loading => const _LoadingSection(),
                        DashboardStatus.error => _ErrorSection(
                          message:
                              state.failure?.message ??
                              context.l10n.dashboardErrorTitle,
                          offerLocationChoice: state.failure is LocationFailure,
                        ),
                        DashboardStatus.loaded => ForecastSection(
                          forecast: state.forecast!,
                          advice: state.advice!,
                        ),
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      final bottom = MediaQuery.paddingOf(context).bottom;
                      return SizedBox(height: bottom + AppSpacing.md);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Abre a escolha de localização e recarrega a previsão se ela mudou.
Future<void> _chooseLocation(BuildContext context) async {
  final cubit = context.read<DashboardCubit>();
  final changed = await context.pushNamed<bool>(AppRoute.location.name);
  if (changed ?? false) await cubit.loadForecast();
}

/// A previsão continua na tela; o snackbar diz o que falhou e leva à escolha
/// de localização.
void _showRefreshFailure(BuildContext context, Failure failure) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(failure.message),
        // Com ação, o `SnackBar` ficaria aberto até ser fechado.
        persist: false,
        action: SnackBarAction(
          label: context.l10n.dashboardChooseLocationButton,
          onPressed: () => unawaited(_chooseLocation(context)),
        ),
      ),
    );
}

/// Recalcula o aviso da agenda quando o app volta ao primeiro plano: é o
/// momento em que um "amanhã" pode ter virado "hoje".
class _RefreshAlertOnResume extends StatefulWidget {
  const _RefreshAlertOnResume({required this.child});

  final Widget child;

  @override
  State<_RefreshAlertOnResume> createState() => _RefreshAlertOnResumeState();
}

class _RefreshAlertOnResumeState extends State<_RefreshAlertOnResume> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => context.read<ScheduleAlertCubit>().refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
  const _ErrorSection({
    required this.message,
    required this.offerLocationChoice,
  });

  final String message;

  /// Falha de localização: além de tentar de novo, o produtor pode escolher
  /// a cidade.
  final bool offerLocationChoice;

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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.read<DashboardCubit>().loadForecast(),
              child: Text(context.l10n.dashboardRetryButton),
            ),
          ),
          if (offerLocationChoice) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => unawaited(_chooseLocation(context)),
                child: Text(context.l10n.dashboardChooseLocationButton),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
