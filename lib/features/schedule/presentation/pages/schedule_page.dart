import 'dart:async';

import 'package:clock/clock.dart';
import 'package:ecosafra/app/router/app_routes.dart';
import 'package:ecosafra/app/widgets/app_drawer.dart';
import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_colors.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/fade_slide_in.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_empty_animation.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_form_sheet.dart';
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

  // Com `goNamed`, a Agenda é a única rota da pilha: sem isto, o voltar do
  // Android fecharia o app em vez de levar ao Painel. `_isDrawerOpen`
  // libera o `canPop` enquanto o drawer está aberto — do contrário o
  // `PopScope` bloquearia até a entrada de histórico local que o fecha
  // (o drawer não é uma rota separada, e `ModalRoute.popDisposition`
  // confere o `PopScope` antes desse histórico).
  bool _isDrawerOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    // O messenger é do app e sobrevive à tela: um "Desfazer" ainda visível
    // (ou na fila) chamaria um cubit já fechado. A remoção é
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

  /// Mesmo fluxo para o swipe e para a ação de acessibilidade: o cubit tira
  /// o item da lista antes de ir ao banco, e o snackbar anterior sai, de
  /// modo que só o último Desfazer vale.
  void _delete(ScheduleItem item) {
    final cubit = context.read<ScheduleCubit>();
    final schedule = item.schedule;

    _messenger.hideCurrentSnackBar();
    unawaited(cubit.removeSchedule(schedule.id));
    _messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.scheduleDeletedMessage),
        duration: _undoSnackBarDuration,
        // Com ação, o `SnackBar` fica aberto até ser fechado; o Desfazer
        // deve sumir sozinho em 4 s.
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
    return PopScope(
      canPop: _isDrawerOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goNamed(AppRoute.dashboard.name);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.scheduleTitle)),
        drawer: const AppDrawer(currentRoute: AppRoute.schedule),
        onDrawerChanged: (isOpen) => setState(() => _isDrawerOpen = isOpen),
        body: BlocConsumer<ScheduleCubit, ScheduleState>(
          listenWhen: (previous, current) =>
              previous.failure != current.failure && current.failure != null,
          listener: (context, state) =>
              context.showSnack(state.failure!.message, isError: true),
          builder: (context, state) => switch (state.status) {
            ScheduleStatus.loading => const _LoadingView(),
            ScheduleStatus.error => _ErrorView(
              message:
                  state.failure?.message ?? context.l10n.scheduleErrorTitle,
              onRetry: () => unawaited(context.read<ScheduleCubit>().retry()),
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
          return _ScheduleCard(
            key: ValueKey(item.schedule.id),
            item: item,
            index: index,
            onDelete: () => onDelete(item),
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

/// Botão "Agendar", que abre o formulário de criação.
class _CreateScheduleButton extends StatelessWidget {
  const _CreateScheduleButton();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();

    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await ScheduleFormSheet.show(
          context,
          window: cubit.currentWindow(),
        );

        if (result != null && context.mounted) {
          unawaited(cubit.addSchedule(result.date, note: result.note));
        }
      },
      icon: const Icon(Icons.add_rounded),
      label: Text(context.l10n.scheduleAddButton),
    );
  }
}

/// O card de um agendamento. Não concluído: o toque abre o formulário de
/// edição. Concluído: não abre.
///
/// Concluir ou desfazer muda o item de seção, e na outra seção o card
/// nasceria de novo, já no estado final. Por isso o card mostra a mudança
/// primeiro, deixa o check se desenhar em `AppMotion.medium` e só então
/// grava; a lista nova, vinda do banco, é que o leva à outra seção.
class _ScheduleCard extends StatefulWidget {
  const _ScheduleCard({
    required this.item,
    required this.index,
    required this.onDelete,
    super.key,
  });

  final ScheduleItem item;

  /// Posição na seção, para o atraso da animação de entrada.
  final int index;
  final VoidCallback onDelete;

  @override
  State<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<_ScheduleCard> {
  // Lido no `initState`: o `dispose` pode precisar gravar e já não tem
  // acesso aos ancestrais.
  late final ScheduleCubit _cubit;

  /// Conclusão já exibida e ainda não gravada.
  bool? _pendingCompleted;
  Timer? _saveTimer;

  /// Gravação enviada: até a lista nova levar o card à outra seção, um
  /// toque no check desfaria a tela sem desfazer o banco. Só volta a
  /// `false` se a gravação falhar.
  bool _saving = false;

  bool get _changePending => _pendingCompleted != null || _saving;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ScheduleCubit>();
  }

  @override
  void dispose() {
    // Saiu da tela (ou da área visível) antes do fim da animação: grava na
    // hora, para o toque não se perder.
    if (_saveTimer?.isActive ?? false) {
      _saveTimer!.cancel();
      unawaited(_save(_pendingCompleted!));
    }
    super.dispose();
  }

  void _toggleCompleted(bool completed) {
    if (_saving) return;
    _saveTimer?.cancel();
    if (completed == widget.item.schedule.isCompleted) {
      // Segundo toque durante a animação: volta atrás sem gravar nada.
      setState(() => _pendingCompleted = null);
      return;
    }
    if (context.reduceMotion) {
      unawaited(_save(completed));
      return;
    }
    setState(() => _pendingCompleted = completed);
    _saveTimer = Timer(AppMotion.medium, () => unawaited(_save(completed)));
  }

  Future<void> _save(bool completed) async {
    _saving = true;
    final saved = await _cubit.setCompleted(
      widget.item.schedule.id,
      completed: completed,
    );
    if (saved || !mounted) return;
    setState(() {
      _saving = false;
      _pendingCompleted = null;
    });
  }

  Future<void> _edit() async {
    // Desmarcar um concluído o mostra editável antes de gravar; editar nesse
    // meio-tempo abriria o formulário para um card prestes a mudar de seção.
    if (_changePending) return;
    final result = await ScheduleFormSheet.show(
      context,
      window: _cubit.currentWindow(),
      initial: widget.item,
    );
    // Sem `mounted`: a gravação não usa o `context`, e o card pode ter sido
    // trocado enquanto o formulário estava aberto.
    if (result != null && !_cubit.isClosed) {
      unawaited(
        _cubit.editSchedule(
          widget.item.schedule.id,
          result.date,
          note: result.note,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.item.schedule;

    return Dismissible(
      key: ValueKey(schedule.id),
      // Com a conclusão pendente, a lista nova tiraria o card daqui antes
      // do fim do arrasto, e a exclusão se perderia sem aviso.
      direction: _changePending
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: const _DeleteBackground(),
      onDismissed: (_) => widget.onDelete(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: FadeSlideIn.staggered(
          index: widget.index,
          // A mesma árvore nos dois estados: mudar o tipo do widget
          // recriaria o check e as animações implícitas do card.
          child: ScheduleTile(
            item: _displayedItem(),
            onEdit: _edit,
            onToggleCompleted: _toggleCompleted,
            onDelete: widget.onDelete,
          ),
        ),
      ),
    );
  }

  ScheduleItem _displayedItem() {
    final pending = _pendingCompleted;
    final item = widget.item;
    final schedule = item.schedule;
    if (pending == null || pending == schedule.isCompleted) return item;

    return ScheduleItem(
      schedule: FertilizationSchedule(
        id: schedule.id,
        scheduledDate: schedule.scheduledDate,
        createdAt: schedule.createdAt,
        note: schedule.note,
        // Só a presença da data importa para a tela; a gravada vem do banco.
        completedAt: pending ? clock.now() : null,
      ),
      risk: item.risk,
      isPastDue: item.isPastDue,
      expectedRainMm: item.expectedRainMm,
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
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.scheduleRetryButton),
            ),
          ],
        ),
      ),
    );
  }
}
