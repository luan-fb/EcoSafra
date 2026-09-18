import 'dart:ui' as ui;

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

/// Fração (0..1) da área de 120x120 que tem algum pixel desenhado quando a
/// composição é parada em [progress]. Olha o desenho, não uma flag.
Future<double> drawnFraction(LottieComposition c, double progress) async {
  const side = 120;
  final recorder = ui.PictureRecorder();
  LottieDrawable(c)
    ..setProgress(progress)
    ..draw(
      Canvas(recorder),
      Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble()),
    );
  final image = await recorder.endRecording().toImage(side, side);
  final bytes = (await image.toByteData())!;
  var drawn = 0;
  for (var i = 3; i < bytes.lengthInBytes; i += 4) {
    if (bytes.getUint8(i) > 16) drawn++;
  }
  return drawn / (side * side);
}

void main() {
  // O `lottie` guarda a composição carregada num cache global, com o
  // provider como chave. Sem limpar, um teste herdaria o resultado de outro.
  setUp(() => Lottie.cache.clear());

  const warm = 25.0;

  Widget host(
    int weatherCode, {
    double temperature = warm,
    AssetBundle? bundle,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WeatherAnimationView(
            weatherCode: weatherCode,
            temperature: temperature,
            bundle: bundle,
          ),
        ),
      ),
    );
  }

  /// Liga "Remover animações" do jeito que o sistema faz: pela plataforma,
  /// e não por um MediaQuery montado à mão.
  void disableAnimations(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  LottieBuilder lottieIn(WidgetTester tester) =>
      tester.widget<LottieBuilder>(find.byType(LottieBuilder));

  String assetOf(LottieBuilder builder) =>
      (builder.lottie as AssetLottie).assetName;

  group('WLOT-05: asset da animação mapeada', () {
    for (final (code, temperature, expected) in [
      (0, warm, WeatherAnimation.sunny),
      (2, warm, WeatherAnimation.partlyCloudy),
      (3, warm, WeatherAnimation.cloudy),
      (63, warm, WeatherAnimation.rainy),
      (0, 10.0, WeatherAnimation.cold),
    ]) {
      testWidgets('código $code a $temperature° usa ${expected.assetPath}', (
        tester,
      ) async {
        await tester.pumpWidget(host(code, temperature: temperature));
        expect(assetOf(lottieIn(tester)), expected.assetPath);
      });
    }

    // Carrega pelo bundle, o mesmo caminho do app: pega o asset que existe
    // no disco mas não foi declarado no pubspec, e JSON que o pacote não
    // consegue interpretar.
    for (final animation in WeatherAnimation.values) {
      test(
        '${animation.assetPath} está no bundle e é um Lottie válido',
        () async {
          final data = await rootBundle.load(animation.assetPath);
          final composition = await LottieComposition.fromByteData(data);
          expect(composition.duration, greaterThan(Duration.zero));
        },
      );
    }
  });

  testWidgets('WLOT-06: toca em loop quando o sistema permite animação', (
    tester,
  ) async {
    await tester.pumpWidget(host(0));
    final builder = lottieIn(tester);
    expect(builder.controller, isNull, reason: 'controller próprio do Lottie');
    expect(builder.animate, isTrue);
    expect(builder.repeat, isTrue);
  });

  group('WLOT-07: "remover animações" ativo', () {
    testWidgets('para no quadro fixo', (tester) async {
      disableAnimations(tester);
      await tester.pumpWidget(host(0));

      final controller = lottieIn(tester).controller;
      expect(controller, isA<AlwaysStoppedAnimation<double>>());
      expect(controller!.value, WeatherAnimationView.stillProgress);
    });

    // O quadro 0 da nuvem é vazio: parar lá deixava o card sem desenho.
    for (final animation in WeatherAnimation.values) {
      test('${animation.name} desenha ≥ 10% da área no quadro fixo', () async {
        final data = await rootBundle.load(animation.assetPath);
        final composition = await LottieComposition.fromByteData(data);
        expect(
          await drawnFraction(composition, WeatherAnimationView.stillProgress),
          greaterThanOrEqualTo(0.10),
        );
      });
    }
  });

  testWidgets('WLOT-08: asset com erro cai no ícone estático e é reportado', (
    tester,
  ) async {
    final bundle = _FailingAssetBundle();
    await tester.pumpWidget(host(61, bundle: bundle));
    await tester.pump();
    // Rebuild com a mesma falha (ex.: a previsão da rede chegando depois do
    // cache): não pode gerar um segundo reporte.
    await tester.pumpWidget(host(63, bundle: bundle));
    await tester.pump();

    expect(find.byIcon(WeatherCondition.iconFor(63)), findsOneWidget);
    // Dois reportes viram "Multiple exceptions" e não casam isFlutterError.
    expect(tester.takeException(), isFlutterError);
  });

  testWidgets('WLOT-09: a animação não expõe nada ao leitor de tela', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(0));

    // O rótulo ("Céu limpo") é lido do Text que o card já mostra; a
    // animação é decorativa e não pode gerar nenhum anúncio.
    expect(find.bySemanticsLabel(RegExp(r'\S')), findsNothing);
    semantics.dispose();
  });

  testWidgets('WLOT-15: limita a 30 quadros por segundo', (tester) async {
    await tester.pumpWidget(host(0));
    expect(lottieIn(tester).frameRate, const FrameRate(30));
  });

  group('troca de clima', () {
    testWidgets('WLOT-10: cross-fade quando a animação muda', (tester) async {
      await tester.pumpWidget(host(0));
      await tester.pumpWidget(host(61));
      await tester.pump(const Duration(milliseconds: 100));

      // No meio da transição as duas coexistem, cada uma num FadeTransition
      // do próprio AnimatedSwitcher, com opacidade entre 0 e 1.
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
      final opacities = tester
          .widgetList<FadeTransition>(
            find.descendant(
              of: find.byType(WeatherAnimationView),
              matching: find.byType(FadeTransition),
            ),
          )
          .map((fade) => fade.opacity.value);
      expect(opacities, hasLength(2));
      expect(opacities, everyElement(inExclusiveRange(0, 1)));

      // Não dá pra usar pumpAndSettle: a animação nova está em loop e
      // nunca "assenta". Avança o tempo além da duração do switch.
      await tester.pump(const Duration(seconds: 1));
      expect(assetOf(lottieIn(tester)), WeatherAnimation.rainy.assetPath);
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

    testWidgets('WLOT-17: sem transição com "remover animações"', (
      tester,
    ) async {
      disableAnimations(tester);
      await tester.pumpWidget(host(0));
      await tester.pumpWidget(host(61));
      await tester.pump();

      // Troca seca: no primeiro quadro depois da mudança só resta a nova.
      expect(find.byType(LottieBuilder), findsOneWidget);
      expect(assetOf(lottieIn(tester)), WeatherAnimation.rainy.assetPath);
    });
  });
}
