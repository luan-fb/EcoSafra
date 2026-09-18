import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:ecosafra/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:ecosafra/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:ecosafra/features/dashboard/presentation/widgets/forecast_section.dart';
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
      // Sem `appBar:` de propósito — o cabeçalho de marca (`DashboardHeader`)
      // faz esse papel, incluindo o botão que abre este `drawer:`.
      drawer: const AppDrawer(),
      body: RefreshIndicator(
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
                  final firstName = user?.displayName?.trim().split(' ').first;
                  return DashboardHeader(
                    userName: (firstName == null || firstName.isEmpty)
                        ? context.l10n.dashboardDefaultUserName
                        : firstName,
                    userPhotoUrl: user?.photoUrl,
                    onMenuTap: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, state) => switch (state.status) {
                    DashboardStatus.initial ||
                    DashboardStatus.loading =>
                      const _LoadingSection(),
                    DashboardStatus.error => _ErrorSection(
                        message: state.failure?.message ??
                            context.l10n.dashboardErrorTitle,
                      ),
                    DashboardStatus.loaded => ForecastSection(
                        forecast: state.forecast!,
                        advice: state.advice!,
                      ),
                  },
                ),
              ),
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
