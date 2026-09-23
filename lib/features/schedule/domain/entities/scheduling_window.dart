import 'package:ecosafra/core/extensions/date_extensions.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:equatable/equatable.dart';

/// A janela de datas em que dá para agendar (ou reagendar) uma aplicação:
/// de hoje até o último dia que a previsão cobre.
///
/// É um valor de domínio (sem `id`, comparado pelos campos via `Equatable`,
/// parecido com um `record` do Java): quem precisa da janela chama
/// `SchedulingWindow.startingAt(clock.now())` e usa o resultado, em vez de
/// cada tela recalcular "hoje + 6 dias" por conta própria. Isso mantém a
/// Agenda e o seletor de data sempre de acordo sobre o que é uma data válida.
final class SchedulingWindow extends Equatable {
  const SchedulingWindow._({required this.first, required this.last});

  /// Constrói a janela que começa em [today]: `first` é a meia-noite de hoje
  /// e `last` é o último dia coberto pela previsão
  /// (`WeatherForecast.coverageDays - 1` dias depois de `first`).
  ///
  /// Ex.: `startingAt(DateTime(2026, 9, 23, 15, 30))` → `first` é
  /// `2026-09-23` e `last` é `2026-09-29` (hoje + 6 dias, previsão de 7).
  factory SchedulingWindow.startingAt(DateTime today) {
    final first = today.dateOnly;
    return SchedulingWindow._(
      first: first,
      last: _addDays(first, WeatherForecast.coverageDays - 1),
    );
  }

  /// Primeiro dia agendável (hoje, sem hora).
  final DateTime first;

  /// Último dia agendável (inclusive).
  final DateTime last;

  /// `true` quando [date] cai em algum dia entre `first` e `last`,
  /// inclusive nas duas pontas. Só o dia importa: uma hora qualquer no meio
  /// do dia de `last` ainda conta como dentro da janela.
  bool contains(DateTime date) {
    final day = date.dateOnly;
    return !day.isBefore(first) && !day.isAfter(last);
  }

  /// Devolve uma data dentro da janela para abrir o seletor.
  ///
  /// Se [date] já está dentro da janela, devolve ela mesma sem hora. Se está
  /// fora (antes de `first` ou depois de `last`), devolve `first`: a spec
  /// (AGD-26) manda abrir o seletor em hoje quando a data atual do
  /// agendamento não é mais editável, em vez de cravar em `last` ou recusar.
  DateTime clamp(DateTime date) {
    final day = date.dateOnly;
    return contains(day) ? day : first;
  }

  /// Soma [days] dias no calendário, não em `Duration`.
  ///
  /// `DateTime(ano, mes, dia + n)` deixa o próprio construtor "carregar"
  /// meses e anos quando `dia + n` estoura o mês (ex.: 28/09 + 6 vira
  /// 04/10) — o mesmo truque de normalização que `Calendar.add` faz no
  /// Android. Somar com `Duration(days: n)` seria arriscado: em fusos com
  /// horário de verão um dia pode ter 23h ou 25h, e a soma desliza a hora
  /// em vez de manter meia-noite.
  static DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  @override
  List<Object?> get props => [first, last];
}
