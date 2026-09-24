import 'dart:async';

import 'package:animations/animations.dart';
import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/fade_slide_in.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/schedule/presentation/pages/schedule_form_page.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_empty_animation.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  static const Duration _undoSnackBarDuration = Duration(seconds: 4);

  // Guardado em `didChangeDependencies` porque o `dispose` não pode mais
  // procurar ancestrais pelo `context`.
  late ScaffoldMessengerState _messenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    // O messenger é do app e sobrevive à tela: um "Desfazer" ainda visível
    // (ou na fila) chamaria um cubit já fechado (SCHEDUI-16). A remoção é
    // imediata, sem a animação de saída em que o botão ainda aceitaria
    // toque. Fica para o fim do quadro porque, durante o `dispose`, a árvore
    // está travada e o messenger não pode se reconstruir; e só se ele ainda
    // existir, pois o app inteiro pode estar sendo desmontado.
    final messenger = _messenger;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!messenger.mounted) return;
      messenger
        ..clearSnackBars()
        ..removeCurrentSnackBar();
    });
    super.dispose();
  }

  /// Mesmo fluxo para o swipe e para a ação de acessibilidade
  /// (SCHEDUI-10, 11, 15): o cubit tira o item da lista antes de ir ao banco,
  /// e o snackbar anterior sai, de modo que só o último Desfazer vale.
  void _delete(ScheduleItem item) {
    final cubit = context.read<ScheduleCubit>();
    final schedule = item.schedule;

    _messenger.hideCurrentSnackBar();
    unawaited(cubit.removeSchedule(schedule.id));
    _messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.scheduleDeletedMessage),
        duration: _undoSnackBarDuration,
        // Com ação, o `SnackBar` fica aberto até ser fechado; a spec pede
        // que suma sozinho em 4 s.
        persist: false,
        action: SnackBarAction(
          label: context.l10n.scheduleDeletedUndo,
          onPressed: () => unawaited(cubit.restoreSchedule(schedule)),
        ),
      ),
    );
  }

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
          ScheduleStatus.loaded => _ScheduleSections(
            state: state,
            onDelete: _delete,
          ),
        },
      ),
      // No estado de erro, a falha de uma ação substituiria a mensagem de
      // erro exibida na tela.
      floatingActionButton: BlocBuilder<ScheduleCubit, ScheduleState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) => state.status == ScheduleStatus.error
            ? const SizedBox.shrink()
            : const _CreateScheduleButton(),
      ),
    );
  }
}

class _ScheduleSections extends StatelessWidget {
  const _ScheduleSections({required this.state, required this.onDelete});

  final ScheduleState state;
  final ValueChanged<ScheduleItem> onDelete;

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
          return Dismissible(
            key: ValueKey(item.schedule.id),
            direction: DismissDirection.endToStart,
            background: const _DeleteBackground(),
            onDismissed: (_) => onDelete(item),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FadeSlideIn.staggered(
                index: index,
                child: _ScheduleCard(
                  item: item,
                  onDelete: () => onDelete(item),
                ),
              ),
            ),
          );
        },
      ),
    ),
  ];
}

/// Fundo revelado pelo arrasto para a esquerda. O espaço entre os cards fica
/// de fora, para o fundo ter o mesmo tamanho do card.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Icon(Icons.delete_rounded, color: context.colors.onError),
          ),
        ),
      ),
    );
  }
}

/// Duração do container transform: `Duration.zero` com redução de movimento
/// faz a rota abrir e fechar sem desenhar quadros intermediários
/// (SCHEDUI-21).
Duration _containerTransitionDuration(BuildContext context) =>
    context.reduceMotion ? Duration.zero : AppMotion.slow;

/// Botão "Agendar" que se expande no formulário de criação (SCHEDUI-18).
class _CreateScheduleButton extends StatelessWidget {
  const _CreateScheduleButton();

  // Elevação de repouso do FAB no Material 3 (nível 3). A sombra fica no
  // `OpenContainer`: o recorte dele cortaria a sombra do próprio botão.
  static const double _restingElevation = 6;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    final colors = context.colors;
    // Forma padrão do FAB no Material 3, repetida no botão e no container
    // para o recorte coincidir com o botão.
    final shape =
        context.theme.floatingActionButtonTheme.shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
        );

    return OpenContainer<ScheduleFormResult>(
      transitionDuration: _containerTransitionDuration(context),
      closedColor: colors.primaryContainer,
      openColor: colors.surface,
      middleColor: colors.surface,
      closedElevation: _restingElevation,
      openElevation: 0,
      closedShape: shape,
      tappable: false,
      closedBuilder: (context, openContainer) => FloatingActionButton.extended(
        onPressed: openContainer,
        shape: shape,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.scheduleAddButton),
      ),
      // A rota nova fica fora do `BlocProvider`: o cubit vem do contexto da
      // lista. A janela é lida ao abrir, e não a do estado, por causa da
      // virada do dia com a tela aberta.
      openBuilder: (context, _) => ScheduleFormPage(
        window: cubit.currentWindow(),
      ),
      onClosed: (result) {
        if (result != null) {
          unawaited(cubit.addSchedule(result.date, note: result.note));
        }
      },
    );
  }
}

/// O card de um agendamento. Não concluído: toque expande o card no
/// formulário de edição (SCHEDUI-17). Concluído: não abre (AGD-27).
class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.item, required this.onDelete});

  final ScheduleItem item;
  final VoidCallback onDelete;

  ValueChanged<bool> _toggleCompleted(ScheduleCubit cubit) =>
      (completed) =>
          unawaited(cubit.setCompleted(item.schedule.id, completed: completed));

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    final schedule = item.schedule;

    if (schedule.isCompleted) {
      return ScheduleTile(
        item: item,
        onEdit: () {},
        onToggleCompleted: _toggleCompleted(cubit),
        onDelete: onDelete,
      );
    }

    return OpenContainer<ScheduleFormResult>(
      transitionDuration: _containerTransitionDuration(context),
      closedColor: context.colors.surfaceContainerLow,
      openColor: context.colors.surface,
      middleColor: context.colors.surface,
      closedElevation: 0,
      openElevation: 0,
      // Mesmo raio do `CardThemeData` (`AppTheme`).
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
      ),
      // O toque vem do `onEdit` do card, para o check à direita não abrir o
      // formulário.
      tappable: false,
      closedBuilder: (context, openContainer) => ScheduleTile(
        item: item,
        onEdit: openContainer,
        onToggleCompleted: _toggleCompleted(cubit),
        onDelete: onDelete,
      ),
      openBuilder: (context, _) => ScheduleFormPage(
        window: cubit.currentWindow(),
        initial: schedule,
      ),
      onClosed: (result) {
        if (result != null) {
          unawaited(
            cubit.editSchedule(schedule.id, result.date, note: result.note),
          );
        }
      },
    );
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
            const ScheduleEmptyAnimation(),
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
