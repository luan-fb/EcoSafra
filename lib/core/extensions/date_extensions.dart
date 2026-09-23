/// Atalhos para operações comuns com datas.
///
/// O `DateTime` do Dart sempre carrega hora. Não existe um `LocalDate` como
/// no `java.time`: quando só o dia importa (agendamento, "é hoje?"), a
/// convenção é usar a meia-noite local, que é o que `dateOnly` devolve.
/// `dateA.isSameDay(dateB)` compara só o dia, mês e ano, ignorando hora.
extension DateTimeX on DateTime {
  /// Retorna a meia-noite local (hora 0:00:00) do mesmo dia.
  ///
  /// Útil para agrupar por dia sem se preocupar com hora exata. A data volta
  /// no fuso do aparelho, não em UTC.
  ///
  /// Ex.:
  /// - `DateTime(2026, 9, 23, 15, 30).dateOnly == DateTime(2026, 9, 23)`
  /// - `DateTime(2026, 9, 23, 0, 0, 0, 1, 1).dateOnly == DateTime(2026, 9, 23)`
  DateTime get dateOnly => DateTime(year, month, day);

  /// `true` se `this` e `other` caem no mesmo dia de calendário.
  ///
  /// A hora não importa: `15:30` do mesmo dia é igual a `09:00` do mesmo dia.
  /// Útil pra lógica de "é hoje?", "é amanhã?" sem se preocupar com minutos.
  ///
  /// Ex.:
  /// - `DateTime(2026, 9, 23, 23, 59).isSameDay(DateTime(2026, 9, 23, 0, 0))` → `true`
  /// - `DateTime(2026, 9, 23, 23, 59).isSameDay(DateTime(2026, 9, 24, 0, 0))` → `false`
  /// - `DateTime(2026, 12, 31, 23, 59).isSameDay(DateTime(2027, 1, 1, 0, 0))` → `false`
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
