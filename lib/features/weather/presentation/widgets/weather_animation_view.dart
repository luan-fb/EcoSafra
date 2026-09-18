import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_motion.dart';
import 'package:ecosafra/features/weather/presentation/weather_condition.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Animação Lottie do clima para um código WMO e uma temperatura.
///
/// Como o Lottie anima sozinho: `Lottie.asset` cria internamente um
/// `AnimationController` (o mesmo tipo da SplashPage), com a duração que
/// veio no JSON, movido por um ticker próprio. A cada quadro, o
/// `RenderLottie` (um `RenderBox`, não um `CustomPainter`) redesenha os
/// vetores daquele progresso, dentro de um `RepaintBoundary` que o próprio
/// pacote já coloca — por isso a repintura não "vaza" para o card.
///
/// Quando se passa um `controller:`, o controller interno para e o
/// desenho segue o progresso desse controller. É o que fazemos com
/// "remover animações": um `AlwaysStoppedAnimation` congela num quadro.
class WeatherAnimationView extends StatelessWidget {
  const WeatherAnimationView({
    required this.weatherCode,
    required this.temperature,
    this.size = 120,
    this.bundle,
    super.key,
  });

  /// Ponto do ciclo (0..1) exibido parado. Não é 0: no quadro inicial a
  /// nuvem ainda não entrou e o card ficaria vazio. Em 0,5 as cinco
  /// animações estão com o desenho completo.
  static const stillProgress = 0.5;

  final int weatherCode;

  /// °C, a mesma exibida no card (decide a animação de frio).
  final double temperature;
  final double size;

  /// De onde carregar o JSON. Nulo usa o `DefaultAssetBundle`, como o
  /// `Image.asset`. Faz parte da chave do cache do Lottie, então bundles
  /// diferentes nunca compartilham resultado.
  final AssetBundle? bundle;

  @override
  Widget build(BuildContext context) {
    final animation = WeatherCondition.animationFor(
      weatherCode,
      temperature: temperature,
    );
    // "Remover animações" nas opções de acessibilidade do Android. A
    // extensão lê via `MediaQuery...Of(context)`, então o widget reconstrói
    // se o usuário mudar a opção com o app aberto.
    final reduceMotion = context.reduceMotion;

    // Decorativa para o leitor de tela: o rótulo do clima já está no Text
    // do card, então nada daqui pode virar um segundo anúncio.
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        // A chave é o que decide a transição. O painel é cache-first: a
        // previsão da rede pode chegar segundos depois e trocar o código.
        // - Animação diferente (sol → chuva): chave nova, o AnimatedSwitcher
        //   faz fade-out da antiga e fade-in da nova.
        // - Mesma animação (chuva fraca → chuva forte): chave igual, o
        //   Flutter reaproveita o State existente e o loop segue sem
        //   reiniciar.
        child: AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : AppMotion.medium,
          child: Lottie.asset(
            animation.assetPath,
            key: ValueKey(animation),
            bundle: bundle,
            animate: !reduceMotion,
            controller: reduceMotion
                ? const AlwaysStoppedAnimation(stillProgress)
                : null,
            repeat: true,
            // Os JSONs são de 60 fps. Num ícone de 120 dp, 30 fps não
            // mudam nada visível e cortam pela metade o trabalho por
            // segundo na tela principal do app.
            frameRate: const FrameRate(30),
            errorBuilder: (context, error, stackTrace) {
              // Sem isso a falha some: o card mostra o ícone e ninguém
              // fica sabendo que a animação não carregou.
              FlutterError.reportError(
                FlutterErrorDetails(
                  exception: error,
                  stack: stackTrace,
                  library: 'weather',
                  context: ErrorDescription('ao carregar ${animation.name}'),
                ),
              );
              return Icon(
                WeatherCondition.iconFor(weatherCode),
                size: size / 2,
                color: context.colors.primary,
              );
            },
          ),
        ),
      ),
    );
  }
}
