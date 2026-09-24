import 'package:ecosafra/features/schedule/presentation/widgets/schedule_empty_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp({required bool disableAnimations}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const Scaffold(
          body: ScheduleEmptyAnimation(),
        ),
      ),
    );
  }

  group('ScheduleEmptyAnimation', () {
    testWidgets('SCHEDUI-01: Anima continuamente quando animações estão ativadas', (tester) async {
      await tester.pumpWidget(buildApp(disableAnimations: false));

      expect(find.byType(ScheduleEmptyAnimation), findsOneWidget);

      // Avança um pouco no tempo para pegar a animação rodando.
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.hasRunningAnimations, isTrue, reason: 'O controller deve estar em loop.');

      // Destrói a árvore para interromper o loop e finalizar o teste de forma limpa.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('SCHEDUI-01: Renderiza ícone sem loop de animação quando disableAnimations é true', (tester) async {
      await tester.pumpWidget(buildApp(disableAnimations: true));

      expect(find.byType(ScheduleEmptyAnimation), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse, reason: 'O controller deve pausar em disableAnimations.');
    });
  });
}
