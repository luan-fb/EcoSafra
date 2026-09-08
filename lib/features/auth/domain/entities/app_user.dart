import 'package:equatable/equatable.dart';

/// Usuário autenticado, na linguagem do domínio.
///
/// Nada aqui sabe que existe Firebase — é por isso que `AuthRepositoryImpl`
/// converte o `User` do `firebase_auth` para isto assim que os dados saem da
/// camada `data`. Se um dia trocarmos de provedor de auth, só o `data` muda.
final class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  @override
  List<Object?> get props => [uid, displayName, email, photoUrl];
}
