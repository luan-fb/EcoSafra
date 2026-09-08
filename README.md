# EcoSafra

App de sustentabilidade (ODS da ONU) que ajuda produtores rurais a não
aplicarem fertilizante antes de chuvas fortes, evitando o escoamento
superficial e a contaminação de rios.

100% client-side: sem backend próprio. Clima vem da [Open-Meteo](https://open-meteo.com/)
(pública, sem API key), sessão vem do Firebase Auth (Google Sign-In).

## Stack

- **Estado**: `flutter_bloc` (Cubit) — um Cubit por feature.
- **Rotas + DI**: [`go_router_modular`](https://pub.dev/packages/go_router_modular) —
  cada feature é um `Module` que declara suas próprias rotas (`ChildRoute`) e
  dependências (`binds`), descartadas automaticamente ao sair da rota.
- **Arquitetura**: Clean Architecture por feature (`domain` → `data` → `presentation`).
- **HTTP**: `dio` + `pretty_dio_logger` (debug only).
- **Erros**: `Either<Failure, T>` (`fpdart`) do repositório para cima; `Exception`
  fica restrita à camada `data`.
- **Lints**: `very_good_analysis`, com `strict-casts`/`strict-inference` ligados.

## Estrutura

```
lib/
  app/            # widget raiz, AppModule (binds globais + composição de rotas)
  core/           # theme, erros, rede, use case base, extensions, widgets compartilhados
  features/
    <feature>/
      <feature>_module.dart   # Module: binds + ChildRoute desta feature
      domain/                 # entities, repositories (interface), usecases
      data/                   # models, datasources, repositories (implementação)
      presentation/           # cubit, pages, widgets
```

## Rodando

```bash
flutter pub get
dart run build_runner watch --delete-conflicting-outputs   # freezed/json_serializable
flutter run
```

## Firebase (pendente)

O projeto ainda não tem um app Firebase configurado. Antes de descomentar o
`Firebase.initializeApp` em [`lib/bootstrap.dart`](lib/bootstrap.dart), rode:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Isso gera `lib/firebase_options.dart` e os arquivos nativos
(`google-services.json` / `GoogleService-Info.plist`).
