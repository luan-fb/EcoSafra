import 'package:dio/dio.dart';
import 'package:ecosafra/core/error/exceptions.dart';

/// Traduz erros do Dio em [AppException] antes de chegarem ao data source.
///
/// Sem isso, cada data source repetiria o mesmo `if (e.type == ...)`.
/// Interceptor é o lugar certo: um ponto único, aplicado a toda requisição.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkException('O servidor demorou demais para responder.'),
      DioExceptionType.connectionError =>
        const NetworkException(),
      DioExceptionType.badResponse => ServerException(
          _messageForStatus(err.response?.statusCode),
          statusCode: err.response?.statusCode,
        ),
      DioExceptionType.cancel =>
        const ServerException('Requisição cancelada.'),
      DioExceptionType.badCertificate =>
        const ServerException('Certificado do servidor inválido.'),
      // `_` cobre os tipos restantes (e futuros) do enum do Dio.
      _ => const NetworkException(),
    };

    // Reempacotamos mantendo o DioException original em `error`, para que o
    // stack trace não se perca no caminho.
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        stackTrace: err.stackTrace,
      ),
    );
  }

  String _messageForStatus(int? status) => switch (status) {
        400 => 'Coordenadas inválidas para a consulta.',
        404 => 'Dados climáticos não encontrados para este local.',
        429 => 'Muitas consultas em pouco tempo. Tente de novo em instantes.',
        // Pattern com guarda: só entra aqui se `status` for int e >= 500.
        final int code when code >= 500 => 'O serviço de clima está fora do ar.',
        _ => 'Falha ao consultar a previsão do tempo.',
      };
}
