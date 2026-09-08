import 'dart:async';

import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/auth/domain/entities/app_user.dart';
import 'package:ecosafra/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:ecosafra/features/auth/domain/usecases/sign_out.dart';
import 'package:ecosafra/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dono da sessão do app inteiro.
///
/// Vive no `AppModule` (não num módulo de feature): splash, login, painel e
/// os `RouteGuard`s leem o mesmo `AuthCubit`, e ele nunca é descartado
/// enquanto o app está aberto — exatamente o motivo de existir o conceito de
/// bind "de app" separado de bind "de módulo" no go_router_modular.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required WatchAuthState watchAuthState,
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
  })  : _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        super(const AuthState.initial()) {
    // Assina a sessão assim que o Cubit nasce: qualquer mudança (login,
    // logout, token revogado em outro lugar) chega aqui sem precisar de
    // nenhuma tela pedindo.
    _authSubscription = watchAuthState(const NoParams()).listen(
      (user) => emit(
        user == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(user),
      ),
    );
  }

  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  late final StreamSubscription<AppUser?> _authSubscription;

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(isSigningIn: true));

    final result = await _signInWithGoogle(const NoParams());
    // Em caso de sucesso (usuário logou OU só desistiu do seletor), não
    // precisamos emitir nada aqui: a assinatura do stream acima já vai
    // reagir à mudança de sessão. Só tratamos o lado esquerdo (falha real).
    result.match(
      (failure) => emit(
        state.copyWith(isSigningIn: false, failure: failure),
      ),
      (_) => emit(state.copyWith(isSigningIn: false)),
    );
  }

  Future<void> signOut() => _signOut(const NoParams());

  @override
  Future<void> close() {
    unawaited(_authSubscription.cancel());
    return super.close();
  }
}
