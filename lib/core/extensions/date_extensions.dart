/// Operações de data que ignoram a hora. Onde só o dia importa
/// (agendamento, "é hoje?"), a convenção do app é a meia-noite local.
extension DateTimeX on DateTime {
  /// Meia-noite local do mesmo dia.
  DateTime get dateOnly => DateTime(year, month, day);

  /// `true` se `this` e [other] caem no mesmo dia de calendário.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
