import 'package:firebase_auth/firebase_auth.dart';

/// Fonte de dados de autenticação, na linguagem do provedor (Firebase User,
/// não `AppUser`). A conversão para o domínio acontece só no repositório.
///
/// É uma interface (e não só a classe concreta) para o `AuthRepositoryImpl`
/// poder ser testado com um fake, sem precisar de um Firebase de verdade.
abstract interface class AuthRemoteDataSource {
  Stream<User?> get authStateChanges;

  User? get currentUser;

  /// Devolve `null` quando o usuário fecha o seletor de conta sem escolher
  /// nenhuma — não é falha, é desistência.
  Future<User?> signInWithGoogle();

  Future<void> signOut();
}
