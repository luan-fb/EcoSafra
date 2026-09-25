import 'package:drift/drift.dart';

/// Localização escolhida pelo produtor no lugar do GPS: no máximo uma por
/// conta, por isso `userId` é a chave primária.
@DataClassName('ChosenLocationRow')
class ChosenLocations extends Table {
  /// `uid` do Firebase Auth.
  TextColumn get userId => text()();

  TextColumn get name => text()();

  /// Estado (`admin1` da geocodificação), quando o lugar tem.
  TextColumn get region => text().nullable()();

  TextColumn get country => text().nullable()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}
