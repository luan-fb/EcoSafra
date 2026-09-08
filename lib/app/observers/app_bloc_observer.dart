import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Enxerga todas as transições de estado do app em um só lugar.
///
/// Em debug, imprime cada mudança de Cubit — ótimo para entender o fluxo
/// quando se está aprendendo bloc. Em produção, é o gancho natural para
/// mandar erros ao Crashlytics.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      developer.log(
        '${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
        name: bloc.runtimeType.toString(),
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    developer.log(
      'Erro não tratado',
      name: bloc.runtimeType.toString(),
      error: error,
      stackTrace: stackTrace,
    );
    // TODO(observability): FirebaseCrashlytics.instance.recordError(...)
    super.onError(bloc, error, stackTrace);
  }
}
