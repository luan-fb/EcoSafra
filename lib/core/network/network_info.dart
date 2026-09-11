import 'package:connectivity_plus/connectivity_plus.dart';

/// Responde uma pergunta só: "existe alguma rede ativa agora?"
///
/// Não confirma que a internet realmente responde (dá pra estar preso
/// numa rede wi-fi de hotel sem saída) — só que há uma interface de rede
/// ligada. Para decidir "vale a pena nem tentar chamar a API", isso já
/// basta, e é instantâneo: nenhuma chamada de rede real acontece aqui.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

class ConnectivityNetworkInfo implements NetworkInfo {
  const ConnectivityNetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
