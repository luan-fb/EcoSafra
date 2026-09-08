import 'package:ecosafra/app/app.dart';
import 'package:ecosafra/bootstrap.dart';

/// Entrypoint de produção.
///
/// Toda a inicialização está em `bootstrap.dart` — este arquivo só escolhe
/// qual app subir. Um `main_dev.dart` futuro chamaria o mesmo bootstrap com
/// outro ambiente de DI.
void main() => bootstrap(EcoSafraApp.new);
