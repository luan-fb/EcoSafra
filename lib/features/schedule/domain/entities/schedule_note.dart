/// Observação de um agendamento de adubação.
///
/// A nota é opcional, e "sem observação" precisa ter uma forma só: `null`.
/// Sem normalizar, um campo digitado só com espaços seria gravado como uma
/// observação "vazia" que a tela exibiria como uma linha em branco.
abstract final class ScheduleNote {
  /// Comprimento máximo de uma observação em caracteres.
  static const maxLength = 200;

  /// Normaliza uma observação: remove espaços das pontas, converte branco
  /// puro em `null`.
  ///
  /// Usado pela UI (com limite de 200 já validado) e pelo use case (onde
  /// texto acima de 200 é erro de validação). O repositório e o banco
  /// recebem `null` quando apropriado.
  ///
  /// Exemplos:
  /// - `normalize('  talhão 3  ')` → `'talhão 3'`
  /// - `normalize('   ')` → `null`
  /// - `normalize('')` → `null`
  /// - `normalize(null)` → `null`
  /// - `normalize('\n adubo\nureia \n')` → `'adubo\nureia'` (quebra do meio
  ///   fica, só as pontas saem)
  static String? normalize(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
