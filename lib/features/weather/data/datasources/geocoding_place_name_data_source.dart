import 'package:ecosafra/features/weather/data/datasources/device_place_name_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';

/// Assina a busca reversa do pacote `geocoding`, injetável para testar sem
/// depender da plataforma.
typedef PlacemarkLookup =
    Future<List<Placemark>> Function(
      double latitude,
      double longitude,
    );

class GeocodingPlaceNameDataSource implements DevicePlaceNameDataSource {
  GeocodingPlaceNameDataSource({PlacemarkLookup? placemarkLookup})
    : _placemarkLookup =
          placemarkLookup ??
          Geocoding(locale: const Locale('pt', 'BR')).placemarkFromCoordinates;

  final PlacemarkLookup _placemarkLookup;

  static const _timeout = Duration(seconds: 5);

  @override
  Future<String?> describe(Coordinates coordinates) async {
    try {
      final placemarks = await _placemarkLookup(
        coordinates.latitude,
        coordinates.longitude,
      ).timeout(_timeout);

      if (placemarks.isEmpty) return null;

      final placemark = placemarks.first;
      final locality = placemark.locality;
      final city = (locality != null && locality.isNotEmpty)
          ? locality
          : placemark.subAdministrativeArea;
      if (city == null || city.isEmpty) return null;

      final state = placemark.administrativeArea;
      return (state != null && state.isNotEmpty) ? '$city, $state' : city;
    } on Exception {
      return null;
    }
  }
}
