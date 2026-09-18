import 'dart:io';

import 'package:ecosafra/features/weather/presentation/weather_animation.dart';
import 'package:ecosafra/features/weather/presentation/weather_condition.dart';
import 'package:ecosafra/features/weather/presentation/widgets/weather_animation_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

/// Bundle que falha em qualquer leitura: simula asset ausente/corrompido.
class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) =>
      Future.error(FlutterError('asset indisponível: $key'));
}

void main() {
  // O `lottie` guarda a composição carregada num cache global, com o
  // provider como chave. Sem limpar, um teste herdaria o resultado de outro.
  setUp(() => Lottie.cache.clear());

  Widget host(
    int weatherCode, {
    bool disableAnimations = false,
    AssetBundle? bundle,
  }) {
    Widget child = WeatherAnimationView(weatherCode: weatherCode);
    if (bundle != null) {
      child = DefaultAssetBundle(bundle: bundle, child: child);
    }
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  LottieBuilder lottieIn(WidgetTester tester) =>
      tester.widget<LottieBuilder>(find.byType(LottieBuilder));

  String assetOf(LottieBuilder builder) =>
      (builder.lottie as AssetLottie).assetName;

  group('WLOT-05: asset da animação mapeada', () {
    for (final (code, expected) in [
      (0, WeatherAnimation.sunny),
      (3, WeatherAnimation.cloudy),
      (63, WeatherAnimation.rainy),
    ]) {
      testWidgets('código $code renderiza ${expected.assetPath}', (
        tester,
      ) async {
        await tester.pumpWidget(host(code));
        expect(assetOf(lottieIn(tester)), expected.assetPath);
      });
    }

    // Os JSONs vieram de fora (LottieFiles): garante que o parser do
    // pacote entende os três e que nenhum deles é uma animação vazia.
    for (final animation in WeatherAnimation.values) {
      test('${animation.assetPath} é um Lottie válido', () async {
        final bytes = File(animation.assetPath).readAsBytesSync();
        final composition = await LottieComposition.fromBytes(bytes);
        expect(composition.duration, greaterThan(Duration.zero));
      });
    }
  });

  testWidgets('WLOT-06: toca em loop quando o sistema permite animação', (
    tester,
  ) async {
    await tester.pumpWidget(host(0));
    final builder = lottieIn(tester);
    expect(builder.animate, isTrue);
    expect(builder.repeat, isTrue);
  });

  testWidgets('WLOT-07: fica parada com "remover animações" ativo', (
    tester,
  ) async {
    await tester.pumpWidget(host(0, disableAnimations: true));
    expect(lottieIn(tester).animate, isFalse);
  });

  testWidgets('WLOT-08: asset com erro cai no ícone estático do código', (
    tester,
  ) async {
    await tester.pumpWidget(host(61, bundle: _FailingAssetBundle()));
    await tester.pump();

    expect(find.byIcon(WeatherCondition.iconFor(61)), findsOneWidget);
  });

  testWidgets('WLOT-09: a animação não expõe nada ao leitor de tela', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(0));

    // O rótulo ("Céu limpo") é lido do Text que o card já mostra; a
    // animação é decorativa e não pode gerar um segundo anúncio.
    final node = tester.getSemantics(find.byType(WeatherAnimationView));
    expect(node.label, isEmpty);
    semantics.dispose();
  });

  group('troca de clima', () {
    testWidgets('WLOT-10: cross-fade quando a animação muda', (tester) async {
      await tester.pumpWidget(host(0));
      await tester.pumpWidget(host(61));
      await tester.pump(const Duration(milliseconds: 100));

      // No meio da transição as duas coexistem, cada uma num FadeTransition.
      final assets = tester
          .widgetList<LottieBuilder>(find.byType(LottieBuilder))
          .map(assetOf);
      expect(
        assets,
        unorderedEquals([
          WeatherAnimation.sunny.assetPath,
          WeatherAnimation.rainy.assetPath,
        ]),
      );
      expect(
        find.ancestor(
          of: find.byType(LottieBuilder),
          matching: find.byType(FadeTransition),
        ),
        findsWidgets,
      );

      // Não dá pra usar pumpAndSettle: a animação nova está em loop e
      // nunca "assenta". Avança o tempo além da duração do switch.
      await tester.pump(const Duration(seconds: 1));
      expect(
        assetOf(lottieIn(tester)),
        WeatherAnimation.rainy.assetPath,
      );
    });

    testWidgets('WLOT-11: mesma animação não reinicia', (tester) async {
      await tester.pumpWidget(host(61));
      final before = tester.state(find.byType(LottieBuilder));

      await tester.pumpWidget(host(63));
      await tester.pump(const Duration(milliseconds: 100));

      // Mesmo State = o Flutter atualizou o widget existente em vez de
      // descartar e criar outro (o que reiniciaria a animação do zero).
      expect(find.byType(LottieBuilder), findsOneWidget);
      expect(tester.state(find.byType(LottieBuilder)), same(before));
    });
  });
}
