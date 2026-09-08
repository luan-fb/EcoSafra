import 'package:bloc_test/bloc_test.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/auth/domain/entities/app_user.dart';
import 'package:ecosafra/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:ecosafra/features/auth/domain/usecases/sign_out.dart';
import 'package:ecosafra/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ecosafra/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

// Mocks dos três use cases: o Cubit só conhece essas interfaces, então o
// teste nunca toca Firebase/Google de verdade — é isso que faz um teste de
// Cubit rodar em milissegundos e não pedir rede nem dispositivo.
class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignOut extends Mock implements SignOut {}

class MockWatchAuthState extends Mock implements WatchAuthState {}

void main() {
  late MockSignInWithGoogle signInWithGoogle;
  late MockSignOut signOut;
  late MockWatchAuthState watchAuthState;

  const user = AppUser(uid: 'u1', displayName: 'Produtor', email: 'p@x.com');
  const failure = AuthFailure('Não foi possível entrar.');

  setUp(() {
    signInWithGoogle = MockSignInWithGoogle();
    signOut = MockSignOut();
    watchAuthState = MockWatchAuthState();
  });

  AuthCubit buildCubit() => AuthCubit(
        watchAuthState: watchAuthState,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
      );

  group('sessão (stream de authStateChanges)', () {
    blocTest<AuthCubit, AuthState>(
      'emite unauthenticated quando o stream emite null',
      setUp: () => when(() => watchAuthState(const NoParams()))
          .thenAnswer((_) => Stream.value(null)),
      build: buildCubit,
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthCubit, AuthState>(
      'emite authenticated quando o stream emite um usuário',
      setUp: () => when(() => watchAuthState(const NoParams()))
          .thenAnswer((_) => Stream.value(user)),
      build: buildCubit,
      expect: () => [const AuthState.authenticated(user)],
    );
  });

  group('signInWithGoogle', () {
    blocTest<AuthCubit, AuthState>(
      'liga isSigningIn e desliga sem erro quando o use case dá certo '
      '(inclusive quando o resultado é null, ou seja, o usuário cancelou)',
      setUp: () {
        when(() => watchAuthState(const NoParams()))
            .thenAnswer((_) => const Stream.empty());
        when(() => signInWithGoogle(const NoParams()))
            .thenAnswer((_) async => const Right(null));
      },
      build: buildCubit,
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        const AuthState.initial().copyWith(isSigningIn: true),
        const AuthState.initial().copyWith(isSigningIn: false),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'liga isSigningIn e expõe o failure quando o use case falha',
      setUp: () {
        when(() => watchAuthState(const NoParams()))
            .thenAnswer((_) => const Stream.empty());
        when(() => signInWithGoogle(const NoParams()))
            .thenAnswer((_) async => const Left(failure));
      },
      build: buildCubit,
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        const AuthState.initial().copyWith(isSigningIn: true),
        const AuthState.initial().copyWith(isSigningIn: false, failure: failure),
      ],
    );
  });

  test('signOut delega para o use case', () async {
    when(() => watchAuthState(const NoParams()))
        .thenAnswer((_) => const Stream.empty());
    when(() => signOut(const NoParams()))
        .thenAnswer((_) async => const Right(null));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.signOut();

    verify(() => signOut(const NoParams())).called(1);
  });
}
