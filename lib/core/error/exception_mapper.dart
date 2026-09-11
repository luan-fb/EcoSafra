import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';

/// Ponte única entre as duas hierarquias de erro do app: toda `AppException`
/// que sobe da camada `data` vira aqui a `Failure` equivalente que o
/// domínio entende. Todo repositório usa esta mesma extensão — nenhum
/// precisa reescrever o switch.
extension AppExceptionToFailure on AppException {
  Failure toFailure() => switch (this) {
        AuthException(:final message) => AuthFailure(message),
        NetworkException(:final message) => NetworkFailure(message),
        ServerException(:final message) => ServerFailure(message),
        CacheException(:final message) => CacheFailure(message),
        LocationException(:final message, :final isPermanentlyDenied) =>
          LocationFailure(message, isPermanentlyDenied: isPermanentlyDenied),
      };
}
