import 'package:ecosafra/core/error/exception_mapper.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecosafra/features/auth/domain/entities/app_user.dart';
import 'package:ecosafra/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:fpdart/fpdart.dart';

/// Fronteira entre "linguagem do Firebase" e "linguagem do domínio".
///
/// Esta é a única classe do app que sabe converter um `firebase.User` em
/// `AppUser` e uma `AppException` em `Failure`. Se soubéssemos migrar de
/// provedor de auth amanhã, só esta classe (e a data source) mudariam.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<AppUser?> get authStateChanges =>
      _remoteDataSource.authStateChanges.map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_remoteDataSource.currentUser);

  @override
  Future<Either<Failure, AppUser?>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      return Right(_toAppUser(user));
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }

  AppUser? _toAppUser(firebase.User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
        );
}
