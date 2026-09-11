import 'package:equatable/equatable.dart';

/// Localização do talhão, na precisão que a Open-Meteo aceita.
final class Coordinates extends Equatable {
  const Coordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  /// Chave de cache: arredonda para 2 casas decimais (~1,1 km no equador).
  ///
  /// O GPS nunca devolve o mesmo valor duas vezes, nem parado — variações
  /// de poucos metros são normais. Sem arredondar, cada leitura criaria uma
  /// linha nova no cache em vez de atualizar a previsão do mesmo talhão.
  String get cacheKey =>
      '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [latitude, longitude];
}
