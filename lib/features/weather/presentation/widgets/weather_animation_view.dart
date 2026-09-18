import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/features/weather/presentation/weather_condition.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Animação Lottie do clima para um código WMO.
///
/// Como o Lottie anima sozinho: `Lottie.asset` cria internamente um
/// `AnimationController` (o mesmo da SplashPage), com a duração que veio no
/// JSON, e a cada tick redesenha os vetores do quadro atual num
/// `CustomPainter`. Por isso não há controller aqui: só se passa um próprio
/// (`controller:`) quando é preciso comandar a animação (pausar, tocar um
/// trecho, sincronizar com outra coisa).
///
/// Decorativa para o leitor de tela: o rótulo do clima já está no `Text`
/// ao lado, então a animação não anuncia nada.
class WeatherAnimationView extends StatelessWidget {
  const WeatherAnimationView({
    required this.weatherCode,
    this.size = 120,
    super.key,
  });

  final int weatherCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    final animation = WeatherCondition.animationFor(weatherCode);
    // "Remover animações" nas opções de acessibilidade do Android. Ler via
    // `...Of(context)` faz o widget reconstruir se o usuário mudar a opção
    // com o app aberto.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SizedBox.square(
      dimension: size,
      // A chave é o que decide a transição. O painel é cache-first: a
      // previsão da rede pode chegar segundos depois e trocar o código.
      // - Animação diferente (sol → chuva): chave nova, o AnimatedSwitcher
      //   faz fade-out da antiga e fade-in da nova.
      // - Mesma animação (chuva fraca → chuva forte): chave igual, o
      //   Flutter reaproveita o State existente e o loop segue sem reiniciar.
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Lottie.asset(
          animation.assetPath,
          key: ValueKey(animation),
          animate: !reduceMotion,
          repeat: true,
          errorBuilder: (context, error, stackTrace) => Icon(
            WeatherCondition.iconFor(weatherCode),
            size: size / 2,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }
}
