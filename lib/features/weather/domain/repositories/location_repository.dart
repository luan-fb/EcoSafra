import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class LocationRepository {
  /// Coordenadas da localização escolhida pela conta logada; sem escolha,
  /// as do GPS.
  Future<Either<Failure, Coordinates>> getCurrentLocation();

  /// `null` quando a conta logada não escolheu localização.
  Future<Place?> getChosenPlace();

  Future<Either<Failure, void>> choosePlace(Place place);

  /// Volta a conta logada para o GPS.
  Future<Either<Failure, void>> clearChosenPlace();

  Future<LocationDescription> describe(Coordinates coordinates);
}
