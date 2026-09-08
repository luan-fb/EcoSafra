import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/auth/domain/entities/app_user.dart';
import 'package:fpdart/fpdart.dart';

/// Contrato de autenticação, visto pelo domínio.
///
/// `signInWithGoogle` devolve `Either<Failure, AppUser?>` — o `?` é
/// deliberado: quando o usuário fecha o seletor de conta do Google sem
/// escolher nenhuma, isso não é um erro (não há nada de errado, ele só
/// desistiu), então o caminho de sucesso devolve `null` em vez de forçar um
/// `Failure` artificial que a UI teria que aprender a ignorar.
abstract interface class AuthRepository {
  /// Emite o usuário atual sempre que a sessão muda (login, logout, token
  /// revogado). `null` significa "sem sessão".
  Stream<AppUser?> get authStateChanges;

  /// Snapshot síncrono da sessão atual, sem esperar o stream.
  AppUser? get currentUser;

  Future<Either<Failure, AppUser?>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();
}
