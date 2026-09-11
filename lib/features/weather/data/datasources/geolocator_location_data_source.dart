import 'dart:async';

import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/features/weather/data/datasources/device_location_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorLocationDataSource implements DeviceLocationDataSource {
  const GeolocatorLocationDataSource();

  /// Sem isto, um GPS que nunca fecha o fix (prédio, rádio de localização
  /// desligado no modo avião) deixa a busca presa pra sempre — nem chega a
  /// dar erro, só fica carregando. Foi assim que este limite entrou aqui:
  /// vendo o painel travado no spinner testando offline de verdade.
  static const _timeLimit = Duration(seconds: 15);

  @override
  Future<Coordinates> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'Ative a localização do aparelho para ver a previsão do seu talhão.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'A permissão de localização foi negada permanentemente. Ative-a '
        'nas configurações do aparelho para ver a previsão do seu talhão.',
        isPermanentlyDenied: true,
      );
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException(
        'Precisamos da sua localização para buscar a previsão do talhão.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: _timeLimit,
        ),
      );
      return Coordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TimeoutException {
      return _lastKnownLocationOrThrow();
    }
  }

  /// O sistema operacional já guarda o último fix de qualquer app que pediu
  /// localização recentemente — é de graça e instantâneo, então é o
  /// primeiro lugar a olhar antes de admitir que não há como saber onde o
  /// talhão está agora.
  Future<Coordinates> _lastKnownLocationOrThrow() async {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown == null) {
      throw const LocationException(
        'Não conseguimos encontrar sua localização. Tente novamente a céu '
        'aberto, longe de paredes e telhados.',
      );
    }
    return Coordinates(
      latitude: lastKnown.latitude,
      longitude: lastKnown.longitude,
    );
  }
}
