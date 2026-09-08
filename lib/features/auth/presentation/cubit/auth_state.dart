import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/auth/domain/entities/app_user.dart';
import 'package:equatable/equatable.dart';

/// Onde a sessão está agora.
///
/// `initial` existe separado de `unauthenticated` de propósito: até o
/// primeiro evento do `authStateChanges` chegar, o app não sabe se há uma
/// sessão salva ou não — tratar isso como "deslogado" faria a splash mandar
/// todo mundo pro login por um instante, mesmo quem já estava logado.
enum AuthStatus { initial, authenticated, unauthenticated }

/// Estado do `AuthCubit`.
///
/// Um Cubit, um estado: em vez de uma hierarquia `sealed` com uma classe por
/// situação, aqui cabe tudo numa classe só com um enum de status — é o
/// padrão que a própria documentação do pacote `bloc` usa pro exemplo de
/// login com Firebase, porque "logado" e "carregando" não são mutuamente
/// exclusivos (dá pra estar logado E processando um logout ao mesmo tempo).
final class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user,
    this.isSigningIn = false,
    this.failure,
  });

  const AuthState.initial() : this._(status: AuthStatus.initial);

  const AuthState.authenticated(AppUser user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated({Failure? failure})
      : this._(status: AuthStatus.unauthenticated, failure: failure);

  final AuthStatus status;
  final AppUser? user;

  /// `true` enquanto o botão "Entrar com Google" aguarda o seletor de conta.
  final bool isSigningIn;

  /// Erro do último tentativa de login, para a UI mostrar uma vez só.
  /// `null` quando não há nada a exibir (inclusive num cancelamento — ver
  /// o comentário em `AuthRepository.signInWithGoogle`).
  final Failure? failure;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool? isSigningIn,
    Failure? failure,
  }) =>
      AuthState._(
        status: status ?? this.status,
        user: user ?? this.user,
        isSigningIn: isSigningIn ?? this.isSigningIn,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, user, isSigningIn, failure];
}
