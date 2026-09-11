import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';

abstract interface class DeviceLocationDataSource {
  Future<Coordinates> getCurrentLocation();
}
