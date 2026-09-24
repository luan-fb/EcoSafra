import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_note.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:ecosafra/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:ecosafra/features/schedule/presentation/widgets/schedule_date_block.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// O que o formulário devolve ao salvar; `null` quando fechado sem salvar.
typedef ScheduleFormResult = ({DateTime date, String? note});

/// Início da janela em que o bloco de data "surge", em fração da animação
/// de abertura do sheet: os primeiros 30% só sobem o sheet, o bloco entra
/// no resto.
const double _dateBlockRevealStart = 0.3;

/// Formulário de criar e editar um agendamento, aberto como bottom sheet:
/// mesma janela de datas e mesmo limite de observação para os dois casos
/// (AGD-25, SCHEDUI-22). Devolve um [ScheduleFormResult] pelo
/// `Navigator.pop`.
class ScheduleFormSheet extends StatefulWidget {
  const ScheduleFormSheet({required this.window, this.initial, super.key});

  /// Datas aceitas pelo seletor.
  final SchedulingWindow window;

  /// `null` para criar; preenchido para editar. Além da data e da
  /// observação atuais, dá a cor do bloco de data no topo do formulário
  /// (mesmo status do card na lista).
  final ScheduleItem? initial;

  /// Abre o formulário como bottom sheet modal e devolve o resultado do
  /// `Future` (`null` se fechado sem salvar).
  ///
  /// Com redução de movimento, o sheet abre e fecha sem animação
  /// (SCHEDUI-21).
  static Future<ScheduleFormResult?> show(
    BuildContext context, {
    required SchedulingWindow window,
    ScheduleItem? initial,
  }) {
    return showModalBottomSheet<ScheduleFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      sheetAnimationStyle: context.reduceMotion
          ? AnimationStyle.noAnimation
          : null,
      builder: (_) => ScheduleFormSheet(window: window, initial: initial),
    );
  }

  @override
  State<ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<ScheduleFormSheet> {
  late DateTime _date = widget.window.clamp(
    widget.initial?.schedule.scheduledDate ?? widget.window.first,
  );
  late final TextEditingController _noteController = TextEditingController(
    text: widget.initial?.schedule.note ?? '',
  );

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: context.l10n.scheduleFormCancel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (_isEditing) ...[
                    _RevealingDateBlock(date: _date, item: widget.initial!),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      _isEditing
                          ? context.l10n.scheduleFormEditTitle
                          : context.l10n.scheduleFormCreateTitle,
                      style: context.texts.titleLarge,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      onTap: () => _pickDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: context.l10n.scheduleFormDateLabel,
                          suffixIcon: const Icon(Icons.calendar_today_rounded),
                        ),
                        child: Text(DateFormat.yMMMEd('pt_BR').format(_date)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _noteController,
                      maxLength: ScheduleNote.maxLength,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: context.l10n.scheduleFormNoteLabel,
                        hintText: context.l10n.scheduleFormNoteHint,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop<ScheduleFormResult>((
                          date: _date,
                          note: ScheduleNote.normalize(_noteController.text),
                        )),
                    child: Text(context.l10n.scheduleFormSave),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// `initialDate` sempre passa por `clamp`: a data já selecionada normalmente
  /// está na janela, mas numa edição cuja data original ficou pra trás
  /// (AGD-26), o seletor abre em hoje em vez de recusar.
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: widget.window.first,
      lastDate: widget.window.last,
      initialDate: widget.window.clamp(_date),
    );
    if (picked != null) setState(() => _date = picked);
  }
}

/// Bloco de data da edição, do tamanho do card na lista (sem `Hero`: o
/// `HeroController` só anima entre `PageRoute`s, e o sheet é um
/// `PopupRoute`). No lugar disso, "surge" enquanto o sheet sobe: escala e
/// opacidade seguem a animação da rota, no intervalo final
/// (`_dateBlockRevealStart`–1), para o bloco aparecer só depois que o sheet
/// já ganhou espaço.
///
/// Some direto (sem transição) com redução de movimento: a animação da
/// rota já não roda (`AnimationStyle.noAnimation`), então o valor fica
/// sempre no fim.
class _RevealingDateBlock extends StatelessWidget {
  const _RevealingDateBlock({required this.date, required this.item});

  final DateTime date;
  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    // O status (e a cor) é da data salva: numa data nova, ainda sem risco
    // calculado, o bloco fica neutro em vez de sugerir um status que não é
    // dela.
    final palette = DateUtils.isSameDay(date, item.schedule.scheduledDate)
        ? scheduleDateBlockPalette(context, item)
        : (
            background: context.colors.surfaceContainerHigh,
            foreground: context.colors.onSurfaceVariant,
          );
    final block = ScheduleDateBlock(
      date: date,
      background: palette.background,
      foreground: palette.foreground,
    );

    if (context.reduceMotion) return block;

    final routeAnimation = ModalRoute.of(context)?.animation;
    if (routeAnimation == null) return block;

    final reveal = CurvedAnimation(
      parent: routeAnimation,
      curve: const Interval(
        _dateBlockRevealStart,
        1,
        curve: AppMotion.emphasized,
      ),
    );
    return ScaleTransition(
      scale: reveal,
      child: FadeTransition(opacity: reveal, child: block),
    );
  }
}
