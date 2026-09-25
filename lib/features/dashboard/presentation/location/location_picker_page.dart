import 'dart:async';

import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/extensions/context_extensions.dart';
import 'package:ecosafra/core/theme/app_spacing.dart';
import 'package:ecosafra/features/dashboard/presentation/location/location_picker_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/location/location_picker_state.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Mesmo motivo do painel: `Modular.get<T>()` colide com o `context.read<T>()`
// reativo do flutter_bloc.
import 'package:go_router_modular/go_router_modular.dart'
    hide BindContextExtension;

/// Escolha da localização do talhão. Volta com `true` quando a escolha foi
/// gravada, para o painel recarregar a previsão.
class LocationPickerPage extends StatelessWidget {
  const LocationPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<LocationPickerCubit>(),
      child: const LocationPickerView(),
    );
  }
}

/// O conteúdo da tela, separado de `LocationPickerPage` para os testes de
/// widget montarem a árvore com um cubit mockado.
@visibleForTesting
class LocationPickerView extends StatelessWidget {
  const LocationPickerView({super.key});

  Future<void> _finish(BuildContext context, Future<bool> saving) async {
    final saved = await saving;
    if (saved && context.mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LocationPickerCubit>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.locationPickerTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: cubit.queryChanged,
              decoration: InputDecoration(
                hintText: context.l10n.locationPickerSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.my_location_rounded),
            title: Text(context.l10n.locationPickerUseDevice),
            onTap: () => unawaited(_finish(context, cubit.useDevice())),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<LocationPickerCubit, LocationPickerState>(
              builder: (context, state) => switch (state.status) {
                LocationPickerStatus.idle => const SizedBox.shrink(),
                LocationPickerStatus.searching => const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: CircularProgressIndicator(),
                  ),
                ),
                LocationPickerStatus.results => ListView.builder(
                  itemCount: state.places.length,
                  itemBuilder: (context, index) {
                    final place = state.places[index];
                    return ListTile(
                      leading: const Icon(Icons.place_rounded),
                      title: Text(_describe(place)),
                      onTap: () =>
                          unawaited(_finish(context, cubit.choose(place))),
                    );
                  },
                ),
                LocationPickerStatus.empty => _Message(
                  context.l10n.locationPickerEmpty,
                ),
                LocationPickerStatus.failure => _Message(
                  state.failure is NetworkFailure
                      ? context.l10n.locationPickerNetworkError
                      : state.failure!.message,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  /// "Nome, Estado, País", sem as partes que o lugar não tem.
  static String _describe(Place place) => [
    place.name,
    place.region,
    place.country,
  ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.texts.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
