import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignOut implements UseCase<void, NoParams> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      _repository.signOut();
}
