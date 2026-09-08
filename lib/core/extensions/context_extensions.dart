import 'package:flutter/material.dart';

/// Atalhos para o que se lê de `context` o tempo todo.
///
/// `context.colors.primary` no lugar de
/// `Theme.of(context).colorScheme.primary` — menos ruído nas árvores de widget.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;

  MediaQueryData get media => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get safeArea => MediaQuery.paddingOf(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// `true` em telas largas (tablet, celular deitado).
  bool get isWide => MediaQuery.sizeOf(this).width >= 600;

  /// Respeita "reduzir movimento" nas configurações de acessibilidade do
  /// aparelho. Toda animação decorativa deve checar isto.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.error : null,
        ),
      );
  }
}
