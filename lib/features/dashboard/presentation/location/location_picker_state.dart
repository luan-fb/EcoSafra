import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:equatable/equatable.dart';

enum LocationPickerStatus { idle, searching, results, empty, failure }

final class LocationPickerState extends Equatable {
  const LocationPickerState._({
    required this.status,
    this.places = const [],
    this.failure,
  });

  /// Busca com menos de 3 caracteres: nada a mostrar além do aparelho.
  const LocationPickerState.idle() : this._(status: LocationPickerStatus.idle);

  const LocationPickerState.searching()
    : this._(status: LocationPickerStatus.searching);

  const LocationPickerState.results(List<Place> places)
    : this._(status: LocationPickerStatus.results, places: places);

  const LocationPickerState.empty()
    : this._(status: LocationPickerStatus.empty);

  /// Falha da busca ou da gravação da escolha.
  const LocationPickerState.failure(Failure failure)
    : this._(status: LocationPickerStatus.failure, failure: failure);

  final LocationPickerStatus status;
  final List<Place> places;
  final Failure? failure;

  @override
  List<Object?> get props => [status, places, failure];
}
