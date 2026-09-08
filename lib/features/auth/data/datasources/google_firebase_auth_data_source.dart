import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Implementação real: Google Sign-In (seletor de conta) + Firebase Auth
/// (sessão do app).
///
/// O `google_sign_in` 7.x mudou bastante da v6: `signIn()` virou
/// `authenticate()` e agora **lança** `GoogleSignInException` em vez de
/// devolver `null` quando o usuário cancela — por isso tratamos o código
/// `canceled` à parte, convertendo de volta para "sucesso vazio" (`null`),
/// que é como o resto do app espera receber um cancelamento.
class GoogleFirebaseAuthDataSource implements AuthRemoteDataSource {
  GoogleFirebaseAuthDataSource({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  bool _googleSignInReady = false;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        // Não deveria acontecer em uso normal (o Google sempre devolve um
        // idToken num authenticate() bem-sucedido); é rede de segurança.
        throw const AuthException(
          'Não foi possível obter as credenciais do Google.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AuthException(
        'Não foi possível entrar com o Google. Tente novamente.',
        code: e.code.toString(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageForFirebaseCode(e.code), code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    // Sai dos dois lados: só encerrar a sessão do Firebase deixaria o Google
    // Sign-In lembrado, e o seletor de conta nem apareceria na próxima vez.
    await Future.wait([_googleSignIn.signOut(), _firebaseAuth.signOut()]);
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInReady) return;
    // Sem argumentos: cada plataforma lê o client ID do arquivo de config
    // nativo (google-services.json / GoogleService-Info.plist) gerado pelo
    // `flutterfire configure`. Só passaríamos `clientId`/`serverClientId` na
    // mão para a Web, que não tem esse arquivo.
    await _googleSignIn.initialize();
    _googleSignInReady = true;
  }

  String _messageForFirebaseCode(String code) => switch (code) {
        'account-exists-with-different-credential' => 'Já existe uma conta com este e-mail usando outro método de login.',
        'invalid-credential' => 'Credenciais inválidas. Tente novamente.',
        'network-request-failed' => 'Sem conexão com a internet.',
        'user-disabled' => 'Esta conta foi desativada.',
        _ => 'Não foi possível entrar. Tente novamente.',
      };
}
