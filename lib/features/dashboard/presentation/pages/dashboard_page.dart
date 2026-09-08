import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/core/widgets/fade_slide_in.dart';
import 'package:flutter/material.dart';

/// Painel principal (esqueleto).
///
/// Vai receber, na próxima etapa: card de recomendação (aplicar / aguardar),
/// previsão de 7 dias e o talhão selecionado.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          for (var i = 0; i < 4; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: FadeSlideIn.staggered(
                index: i,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bloco ${i + 1}',
                          style: context.texts.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Espaço reservado para os dados da Open-Meteo.',
                          style: context.texts.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
