import 'package:ecosafra/core/error/exception_mapper.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecosafra/features/weather/data/datasources/chosen_location_local_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/device_location_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/device_place_name_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:ecosafra/features/weather/domain/repositories/location_repository.dart';
import 'package:fpdart/fpdart.dart';

/// A localização escolhida pela conta prevalece sobre o GPS. O `uid` é lido
/// a cada chamada: o repositório é singleton e a sessão pode trocar.
class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl({
    required DeviceLocationDataSource device,
    required ChosenLocationLocalDataSource chosen,
    required DevicePlaceNameDataSource placeName,
    required AuthRepository authRepository,
  }) : _device = device,
       _chosen = chosen,
       _placeName = placeName,
       _authRepository = authRepository;

  final DeviceLocationDataSource _device;
  final ChosenLocationLocalDataSource _chosen;
  final DevicePlaceNameDataSource _placeName;
  final AuthRepository _authRepository;

  static const _signedOutMessage =
      'É preciso estar logado para escolher a localização.';
  static const _saveFailedMessage =
      'Não foi possível salvar a localização escolhida.';
  static const _clearFailedMessage =
      'Não foi possível voltar à localização do aparelho.';

  String? get _currentUserId => _authRepository.currentUser?.uid;

  @override
  Future<Either<Failure, Coordinates>> getCurrentLocation() async {
    final chosen = await getChosenPlace();
    if (chosen != null) return Right(chosen.coordinates);

    try {
      return Right(await _device.getCurrentLocation());
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Place?> getChosenPlace() async {
    final userId = _currentUserId;
    if (userId == null) return null;
    try {
      return await _chosen.get(userId);
    } on Exception {
      // Banco ilegível não pode deixar o produtor sem previsão: cai no GPS.
      return null;
    }
  }

  @override
  Future<Either<Failure, void>> choosePlace(Place place) => _write(
    (userId) => _chosen.save(userId, place),
    _saveFailedMessage,
  );

  @override
  Future<Either<Failure, void>> clearChosenPlace() =>
      _write(_chosen.clear, _clearFailedMessage);

  @override
  Future<LocationDescription> describe(Coordinates coordinates) async {
    final chosen = await getChosenPlace();
    if (chosen != null) {
      return LocationDescription(
        label: chosen.label,
        source: LocationSource.chosen,
      );
    }

    final name = await _placeName.describe(coordinates);
    return LocationDescription(
      label: name ?? _formatCoordinates(coordinates),
      source: LocationSource.device,
    );
  }

  Future<Either<Failure, void>> _write(
    Future<void> Function(String userId) action,
    String failureMessage,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return const Left(AuthFailure(_signedOutMessage));
    try {
      await action(userId);
      return const Right(null);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } on Exception {
      return Left(CacheFailure(failureMessage));
    }
  }

  /// "-15,60, -56,10": 2 casas e vírgula decimal, como no português.
  static String _formatCoordinates(Coordinates coordinates) {
    String format(double value) =>
        value.toStringAsFixed(2).replaceAll('.', ',');
    return '${format(coordinates.latitude)}, ${format(coordinates.longitude)}';
  }
}
