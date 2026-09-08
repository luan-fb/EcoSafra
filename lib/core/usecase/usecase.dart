import 'package:ecosafra/core/error/failure.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

/// Contrato de todo caso de uso do app.
///
/// Um use case tem **uma** responsabilidade e é invocado como função:
/// `await getForecast(params)`. Isso vem do `call` operator do Dart.
///
/// O retorno é `Either<Failure, Type>`: à esquerda o erro, à direita o sucesso.
/// Diferente de try/catch, o `Either` obriga quem chama a tratar os dois lados
/// — o erro faz parte da assinatura, não é uma surpresa em runtime.
abstract interface class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

/// Versão síncrona, para casos de uso que só fazem cálculo (ex.: decidir se
/// é seguro aplicar fertilizante a partir de uma previsão já carregada).
abstract interface class SyncUseCase<T, P> {
  Either<Failure, T> call(P params);
}

/// Caso de uso que emite um fluxo contínuo (ex.: estado de autenticação).
abstract interface class StreamUseCase<T, P> {
  Stream<T> call(P params);
}

/// Use quando o caso de uso não recebe parâmetro: `await logout(const NoParams())`.
final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
