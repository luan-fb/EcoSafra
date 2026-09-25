import 'package:equatable/equatable.dart';

/// De onde vieram as coordenadas usadas na previsão.
enum LocationSource { device, chosen }

/// Nome da localização usada, como o painel mostra no cabeçalho.
final class LocationDescription extends Equatable {
  const LocationDescription({required this.label, required this.source});

  final String label;
  final LocationSource source;

  @override
  List<Object?> get props => [label, source];
}
