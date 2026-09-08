import 'package:equatable/equatable.dart';

/// Failures vivem na camada de **domain**.
///
/// São o vocabulário de erro que a UI conhece. `sealed` faz o Dart exigir
/// que um `switch` cubra todos os casos — se amanhã criarmos um novo tipo
/// de falha, o compilador aponta cada tela que precisa tratá-la.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Mensagem já pronta para exibir ao usuário, em português.
  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Não conseguimos falar com o serviço de clima.',
  ]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Você está sem internet. Verifique a conexão.',
  ]);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Não há dados salvos no aparelho.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Não foi possível entrar na sua conta.']);
}

final class LocationFailure extends Failure {
  const LocationFailure(
    super.message, {
    this.isPermanentlyDenied = false,
  });

  final bool isPermanentlyDenied;

  @override
  List<Object?> get props => [message, isPermanentlyDenied];
}

/// Rede de segurança: nunca deixe um erro inesperado derrubar o app.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Algo inesperado aconteceu.']);
}
