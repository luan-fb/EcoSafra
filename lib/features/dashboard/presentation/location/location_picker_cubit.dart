import 'dart:async';

import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/dashboard/presentation/location/location_picker_state.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:ecosafra/features/weather/domain/usecases/choose_place.dart';
import 'package:ecosafra/features/weather/domain/usecases/search_places.dart';
import 'package:ecosafra/features/weather/domain/usecases/use_device_location.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

/// Busca lugares enquanto o produtor digita e grava a escolha.
///
/// Só busca 400 ms depois da última tecla, com pelo menos 3 caracteres. Cada
/// busca recebe um número; a resposta de uma busca que já foi substituída
/// por outra é descartada.
class LocationPickerCubit extends Cubit<LocationPickerState> {
  LocationPickerCubit({
    required SearchPlaces searchPlaces,
    required ChoosePlace choosePlace,
    required UseDeviceLocation useDeviceLocation,
  }) : _searchPlaces = searchPlaces,
       _choosePlace = choosePlace,
       _useDeviceLocation = useDeviceLocation,
       super(const LocationPickerState.idle());

  static const debounce = Duration(milliseconds: 400);
  static const minQueryLength = 3;

  final SearchPlaces _searchPlaces;
  final ChoosePlace _choosePlace;
  final UseDeviceLocation _useDeviceLocation;

  Timer? _debounceTimer;
  int _searchId = 0;

  void queryChanged(String query) {
    _cancelPendingSearch();
    final trimmed = query.trim();
    if (trimmed.length < minQueryLength) {
      emit(const LocationPickerState.idle());
      return;
    }
    final searchId = _searchId;
    _debounceTimer = Timer(
      debounce,
      () => unawaited(_search(trimmed, searchId)),
    );
  }

  /// `true` quando a escolha foi gravada.
  Future<bool> choose(Place place) {
    _cancelPendingSearch();
    return _save(_choosePlace(place));
  }

  /// Apaga a escolha e volta ao GPS. `true` quando deu certo.
  Future<bool> useDevice() {
    _cancelPendingSearch();
    return _save(_useDeviceLocation(const NoParams()));
  }

  Future<void> _search(String query, int searchId) async {
    emit(const LocationPickerState.searching());
    final result = await _searchPlaces(query);
    if (isClosed || searchId != _searchId) return;
    emit(
      result.match(
        LocationPickerState.failure,
        (places) => places.isEmpty
            ? const LocationPickerState.empty()
            : LocationPickerState.results(places),
      ),
    );
  }

  Future<bool> _save(Future<Either<Failure, void>> action) async {
    final result = await action;
    return result.match((failure) {
      if (!isClosed) emit(LocationPickerState.failure(failure));
      return false;
    }, (_) => true);
  }

  /// Cancela a busca agendada e invalida a que já está em andamento.
  void _cancelPendingSearch() {
    _debounceTimer?.cancel();
    _searchId++;
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
