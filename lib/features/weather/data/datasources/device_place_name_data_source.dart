import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';

abstract interface class DevicePlaceNameDataSource {
  /// Nome legível das coordenadas, no formato "Cidade, Estado".
  /// `null` quando o geocodificador não resolve o lugar.
  Future<String?> describe(Coordinates coordinates);
}
