import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:flutter_test/flutter_test.dart';

const _cuiaba = Coordinates(latitude: -15.6, longitude: -56.1);

void main() {
  group('label', () {
    test('com região, mostra "Nome, Região" sem o país', () {
      const place = Place(
        name: 'Cuiabá',
        region: 'Mato Grosso',
        country: 'Brasil',
        coordinates: _cuiaba,
      );

      expect(place.label, 'Cuiabá, Mato Grosso');
    });

    test('sem região, mostra só o nome', () {
      const place = Place(
        name: 'Cuiabá',
        country: 'Brasil',
        coordinates: _cuiaba,
      );

      expect(place.label, 'Cuiabá');
    });

    test('com região vazia, mostra só o nome', () {
      const place = Place(name: 'Cuiabá', region: '', coordinates: _cuiaba);

      expect(place.label, 'Cuiabá');
    });
  });
}
