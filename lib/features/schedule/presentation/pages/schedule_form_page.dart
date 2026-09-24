import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/schedule/domain/entities/fertilization_schedule.dart';
import 'package:ecosafra/features/schedule/domain/entities/schedule_note.dart';
import 'package:ecosafra/features/schedule/domain/entities/scheduling_window.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// O que o formulário devolve ao salvar; `null` quando fechado sem salvar.
typedef ScheduleFormResult = ({DateTime date, String? note});

/// Formulário em tela cheia de criar e editar um agendamento: mesma janela
/// de datas e mesmo limite de observação para os dois casos (AGD-25,
/// SCHEDUI-22). Devolve um [ScheduleFormResult] pelo `Navigator.pop`.
class ScheduleFormPage extends StatefulWidget {
  const ScheduleFormPage({required this.window, this.initial, super.key});

  /// Datas aceitas pelo seletor.
  final SchedulingWindow window;

  /// `null` para criar; preenchido para editar.
  final FertilizationSchedule? initial;

  @override
  State<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends State<ScheduleFormPage> {
  late DateTime _date = widget.window.clamp(
    widget.initial?.scheduledDate ?? widget.window.first,
  );
  late final TextEditingController _noteController = TextEditingController(
    text: widget.initial?.note ?? '',
  );

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: context.l10n.scheduleFormCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing
              ? context.l10n.scheduleFormEditTitle
              : context.l10n.scheduleFormCreateTitle,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
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
              padding: const EdgeInsets.all(AppSpacing.lg),
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
