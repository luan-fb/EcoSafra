import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/fade_slide_in.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_form_sheet.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Mesmo motivo do painel: `Modular.get<T>()` colide com o `context.read<T>()`
// reativo do flutter_bloc.
import 'package:go_router_modular/go_router_modular.dart'
    hide BindContextExtension;

/// O caderno de agendamento: o produtor escolhe um dia futuro pra adubar,
/// e a tela avisa se a previsão pra aquele dia mudou pro lado ruim.
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<ScheduleCubit>(),
      child: const ScheduleView(),
    );
  }
}

/// O conteúdo da tela, separado de `SchedulePage` para não depender do
/// `Modular.get` nos testes de widget: um `BlocProvider<ScheduleCubit>.value`
/// com um cubit mockado já é o suficiente para montar esta árvore.
@visibleForTesting
class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.scheduleTitle)),
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listenWhen: (previous, current) =>
            previous.failure != current.failure && current.failure != null,
        listener: (context, state) =>
            context.showSnack(state.failure!.message, isError: true),
        builder: (context, state) => switch (state.status) {
          ScheduleStatus.loading => const _LoadingView(),
          ScheduleStatus.error => _ErrorView(
            message: state.failure?.message ?? context.l10n.scheduleErrorTitle,
          ),
          ScheduleStatus.loaded => _ScheduleSections(state: state),
        },
      ),
      // No estado de erro, a falha de uma ação substituiria a mensagem de
      // erro exibida na tela.
      floatingActionButton: BlocBuilder<ScheduleCubit, ScheduleState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) => state.status == ScheduleStatus.error
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed: () => _createSchedule(context),
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.scheduleAddButton),
              ),
      ),
    );
  }

  Future<void> _createSchedule(BuildContext context) async {
    final cubit = context.read<ScheduleCubit>();
    final result = await ScheduleFormSheet.show(
      context,
      window: cubit.currentWindow(),
    );
    if (result != null) {
      await cubit.addSchedule(result.date, note: result.note);
    }
  }
}

class _ScheduleSections extends StatelessWidget {
  const _ScheduleSections({required this.state});

  final ScheduleState state;

  @override
  Widget build(BuildContext context) {
    if (state.upcoming.isEmpty && state.completed.isEmpty) {
      return _EmptyView(message: context.l10n.scheduleEmptyState);
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return CustomScrollView(
      slivers: [
        if (state.upcoming.isNotEmpty)
          ..._section(
            title: context.l10n.scheduleSectionUpcoming,
            items: state.upcoming,
          ),
        if (state.completed.isNotEmpty)
          ..._section(
            title: context.l10n.scheduleSectionCompleted,
            items: state.completed,
          ),
        SliverPadding(
          padding: EdgeInsets.only(bottom: bottomPadding + 88),
        ),
      ],
    );
  }

  List<Widget> _section({
    required String title,
    required List<ScheduleItem> items,
  }) => [
    SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      sliver: SliverToBoxAdapter(child: _SectionHeader(title: title)),
    ),
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Itens saem (excluir) e trocam de seção (concluir): a chave pelo
          // id impede que o estado de um item vá parar no vizinho.
          return Padding(
            key: ValueKey(item.schedule.id),
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: FadeSlideIn.staggered(
              index: index,
              child: ScheduleTile(
                item: item,
                onEdit: () => _editSchedule(context, item),
                onToggleCompleted: (completed) => context
                    .read<ScheduleCubit>()
                    .setCompleted(item.schedule.id, completed: completed),
                onDelete: () => _confirmDelete(context, item.schedule.id),
              ),
            ),
          );
        },
      ),
    ),
  ];

  Future<void> _editSchedule(BuildContext context, ScheduleItem item) async {
    final cubit = context.read<ScheduleCubit>();
    final result = await ScheduleFormSheet.show(
      context,
      window: cubit.currentWindow(),
      initial: item.schedule,
    );
    if (result != null) {
      await cubit.editSchedule(
        item.schedule.id,
        result.date,
        note: result.note,
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, String scheduleId) async {
    final cubit = context.read<ScheduleCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.scheduleDeleteConfirmTitle),
        content: Text(context.l10n.scheduleDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.scheduleDeleteConfirmCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.scheduleDeleteConfirmConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await cubit.removeSchedule(scheduleId);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: context.texts.titleMedium);
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 48,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
