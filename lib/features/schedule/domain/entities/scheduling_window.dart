import 'package:ecosafra/core/extensions/date_extensions.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:equatable/equatable.dart';

/// A janela de datas em que dá para agendar (ou reagendar) uma aplicação:
/// de hoje até o último dia que a previsão cobre. Centralizada aqui para a
/// Agenda e o seletor de data nunca discordarem sobre o que é válido.
final class SchedulingWindow extends Equatable {
  const SchedulingWindow._({required this.first, required this.last});

  /// Janela que começa no dia de [today] e termina no último dia coberto
  /// pela previsão (`WeatherForecast.coverageDays - 1` dias depois).
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

  /// `true` quando o dia de [date] está entre `first` e `last`, inclusive.
  bool contains(DateTime date) {
    final day = date.dateOnly;
    return !day.isBefore(first) && !day.isAfter(last);
  }

  /// O dia de [date] se estiver na janela; senão, `first` (AGD-26: o
  /// seletor abre em hoje quando a data do agendamento já não é editável).
  DateTime clamp(DateTime date) {
    final day = date.dateOnly;
    return contains(day) ? day : first;
  }

  /// Soma dias de calendário: o construtor normaliza a virada de mês e ano.
  /// `Duration(days: n)` não serve, porque com horário de verão um dia pode
  /// ter 23 ou 25 horas e a soma sairia da meia-noite.
  static DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  @override
  List<Object?> get props => [first, last];
}
