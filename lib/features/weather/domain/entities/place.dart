import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:equatable/equatable.dart';

/// Lugar com nome, vindo da busca por cidade ou escolhido pelo produtor.
final class Place extends Equatable {
  const Place({
    required this.name,
    required this.coordinates,
    this.region,
    this.country,
  });

  final String name;

  /// Estado ou província.
  final String? region;
  final String? country;
  final Coordinates coordinates;

  /// "Nome, Região", ou só "Nome" quando o lugar não tem região.
  String get label {
    final region = this.region;
    if (region == null || region.isEmpty) return name;
    return '$name, $region';
  }

  @override
  List<Object?> get props => [name, region, country, coordinates];
}
