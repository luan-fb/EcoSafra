import 'package:ecosafra/features/weather/domain/entities/place.dart';

/// Localização escolhida no lugar do GPS, no máximo uma por conta.
abstract interface class ChosenLocationLocalDataSource {
  /// `null` quando a conta não escolheu nenhuma.
  Future<Place?> get(String userId);

  /// Substitui a escolha anterior da conta, se houver.
  Future<void> save(String userId, Place place);

  /// Não faz nada se a conta não tiver escolha salva.
  Future<void> clear(String userId);
}
