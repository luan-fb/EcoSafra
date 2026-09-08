import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/auth/domain/entities/app_user.dart';
import 'package:ecosafra/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Inicia o fluxo interativo de login com Google.
class SignInWithGoogle implements UseCase<AppUser?, NoParams> {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser?>> call(NoParams params) =>
      _repository.signInWithGoogle();
}
