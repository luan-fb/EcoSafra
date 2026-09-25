import 'package:dio/dio.dart';
import 'package:ecosafra/core/error/exceptions.dart';

/// Desembrulha a [AppException] que o `ErrorInterceptor` guardou em
/// [DioException.error], para os data sources relançarem em vez do
/// `DioException` cru.
///
/// Sem isso, cada data source repetiria o mesmo `if (error is AppException)`.
AppException unwrapDioException(DioException error) {
  final appError = error.error;
  return appError is AppException ? appError : const NetworkException();
}
