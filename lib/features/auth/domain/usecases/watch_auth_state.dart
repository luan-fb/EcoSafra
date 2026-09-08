import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/auth/domain/entities/app_user.dart';
import 'package:ecosafra/features/auth/domain/repositories/auth_repository.dart';

/// Observa a sessão continuamente. É isto que o `AuthCubit` assina para
/// saber, em tempo real, se o usuário está logado — inclusive quando a
/// sessão cai por um motivo que não foi um clique no botão de sair (token
/// expirado, revogado no console do Firebase, etc.).
class WatchAuthState implements StreamUseCase<AppUser?, NoParams> {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  @override
  Stream<AppUser?> call(NoParams params) => _repository.authStateChanges;
}
