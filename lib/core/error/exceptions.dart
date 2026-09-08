import 'package:flutter/foundation.dart';

/// Exceptions vivem na camada de **data**.
///
/// Regra da Clean Architecture que vale decorar: `Exception` é o que a fonte
/// de dados joga (Dio falhou, Firebase recusou). O repositório captura essa
/// exception e a converte em `Failure`, que é o que o domínio entende.
/// Nenhuma exception deve vazar para a camada de presentation.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      "${objectRuntimeType(this, 'AppException')}($message)";
}

/// Erro vindo do servidor (5xx, 4xx, resposta inválida).
final class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Sem internet ou timeout.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'Sem conexão com a internet.']);
}

/// Erro de cache local (SharedPreferences, banco).
final class CacheException extends AppException {
  const CacheException([super.message = 'Falha ao ler os dados locais.']);
}

/// Falha de autenticação (Firebase Auth, Google Sign-In).
final class AuthException extends AppException {
  const AuthException(super.message, {this.code});

  /// Código original do provedor, ex.: `user-disabled`.
  final String? code;
}

/// Usuário negou permissão ou o serviço está desligado (GPS).
final class LocationException extends AppException {
  const LocationException(super.message, {this.isPermanentlyDenied = false});

  /// `true` quando o usuário marcou "não perguntar novamente":
  /// nesse caso o app precisa mandar ele para as configurações do sistema.
  final bool isPermanentlyDenied;
}
