import 'package:drift/drift.dart';

/// Uma linha = a última previsão que deu certo para uma área.
///
/// Comparando com o Room: isto é a `@Entity` da tabela. `locationKey` é a
/// chave primária (coordenadas arredondadas a ~1km — ver
/// `Coordinates.cacheKey`), então buscar de novo perto do mesmo lugar
/// atualiza a mesma linha em vez de acumular lixo.
class CachedForecasts extends Table {
  TextColumn get locationKey => text()();

  /// O `WeatherForecastModel` inteiro, serializado. Guardar o JSON pronto
  /// (em vez de uma coluna por variável meteorológica) é o que deixa este
  /// cache imune a mudanças na Open-Meteo: se amanhã ela adicionar uma
  /// variável nova, não precisamos de migration nenhuma pra continuar
  /// funcionando com o que já temos.
  TextColumn get payloadJson => text()();

  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {locationKey};
}
