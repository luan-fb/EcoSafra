import 'package:ecosafra/features/weather/data/datasources/geocoding_place_name_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';

const _coordinates = Coordinates(latitude: -15.59611, longitude: -56.09667);

void main() {
  group('GeocodingPlaceNameDataSource', () {
    test('monta "Cidade, Estado" com locality e administrativeArea', () async {
      final dataSource = GeocodingPlaceNameDataSource(
        placemarkLookup: (latitude, longitude) async => const [
          Placemark(locality: 'Cuiabá', administrativeArea: 'Mato Grosso'),
        ],
      );

      expect(await dataSource.describe(_coordinates), 'Cuiabá, Mato Grosso');
    });

    test('usa subAdministrativeArea quando locality vem vazia', () async {
      final dataSource = GeocodingPlaceNameDataSource(
        placemarkLookup: (latitude, longitude) async => const [
          Placemark(
            locality: '',
            subAdministrativeArea: 'Sorriso',
            administrativeArea: 'Mato Grosso',
          ),
        ],
      );

      expect(await dataSource.describe(_coordinates), 'Sorriso, Mato Grosso');
    });

    test('sem estado devolve só a cidade', () async {
      final dataSource = GeocodingPlaceNameDataSource(
        placemarkLookup: (latitude, longitude) async => const [
          Placemark(locality: 'Cuiabá'),
        ],
      );

      expect(await dataSource.describe(_coordinates), 'Cuiabá');
    });

    test('sem cidade devolve null', () async {
      final dataSource = GeocodingPlaceNameDataSource(
        placemarkLookup: (latitude, longitude) async => const [
          Placemark(administrativeArea: 'Mato Grosso'),
        ],
      );

      expect(await dataSource.describe(_coordinates), isNull);
    });

    test('lista vazia devolve null', () async {
      final dataSource = GeocodingPlaceNameDataSource(
        placemarkLookup: (latitude, longitude) async => const [],
      );

      expect(await dataSource.describe(_coordinates), isNull);
    });

    test('exceção do geocodificador devolve null', () async {
      final dataSource = GeocodingPlaceNameDataSource(
        placemarkLookup: (latitude, longitude) async =>
            throw Exception('sem geocodificador disponível'),
      );

      expect(await dataSource.describe(_coordinates), isNull);
    });
  });
}
