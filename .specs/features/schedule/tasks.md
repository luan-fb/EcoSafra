# Caderno de agendamento — Tasks

## Execution Protocol (MANDATORY -- do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user - do not proceed without it.**

---

**Spec**: `.specs/features/schedule/spec.md`
**Design**: `.specs/features/schedule/design.md`
**Status**: In Progress
**Branch**: `feat/schedule`

---

## Como retomar (leia antes de qualquer task)

Este arquivo é o checkpoint da feature. Qualquer agente, humano ou outra IA continua daqui sem o histórico da conversa:

1. Leia `.specs/STATE.md` (decisões e handoff), depois este arquivo.
2. Rode `git log --oneline --grep "Refs: T" main..feat/schedule` e `git status --short`. A **evidência do git vence** o que estiver escrito: task com commit `Refs: T<n>` na branch está feita, mesmo sem `[x]` aqui.
3. Pegue a primeira task sem `[x]` em **Status**, na ordem das fases. Se o Handoff do `STATE.md` diz que ela está **EM ANDAMENTO**, há trabalho parcial dela no working tree: preserve, rode o gate da task e termine o ciclo, em vez de recomeçar.
4. Ao terminar uma task: gate verde → marque o `Status` como `[x] feito` → commit único com código, testes e esta atualização, com o rodapé `Refs: T<n>`. Nunca pule o gate, nunca apague ou enfraqueça teste.

**Estado do working tree no início**: existe um **rascunho não commitado** da Agenda feito sobre Firestore, que nunca funcionou. Ele é matéria-prima: cada task diz quais arquivos do rascunho **adota** (inclui no seu commit, já ajustados), **reescreve** ou **apaga**.

| Arquivo do rascunho | Destino | Task |
| ------------------- | ------- | ---- |
| `firestore.rules`, `data/datasources/firestore_schedule_data_source.dart`, `data/datasources/schedule_remote_data_source.dart`, `data/models/schedule_model.dart` (+ `.freezed.dart`) | Apagar | T8 |
| `test/features/schedule/data/repositories/schedule_repository_impl_test.dart` | Reescrever | T8 |
| `domain/repositories/schedule_repository.dart`, `data/repositories/schedule_repository_impl.dart` | Reescrever | T8 |
| `domain/usecases/watch_schedules.dart`, `domain/usecases/delete_schedule.dart` | Adotar sem mudança | T8 |
| `domain/usecases/create_schedule.dart` | Reescrever | T9 |
| `domain/entities/schedule_risk_level.dart`, `domain/usecases/evaluate_schedule_risk.dart`, `test/.../evaluate_schedule_risk_test.dart` | Adotar sem mudança | T10 |
| `domain/entities/fertilization_schedule.dart` | Evoluir (`completedAt`) | T5 |
| `presentation/cubit/schedule_cubit.dart`, `schedule_state.dart` | Reescrever | T11 |
| `presentation/widgets/schedule_tile.dart` | Reescrever | T13 |
| `presentation/pages/schedule_page.dart`, `schedule_module.dart`, `lib/app/router/app_routes.dart`, `lib/features/dashboard/presentation/widgets/app_drawer.dart` | Evoluir e adotar | T14 |
| `lib/app/app_module.dart` (linhas do rascunho: import e bind de `FirebaseFirestore`, import e rota do `ScheduleModule`) | Bind do Firestore sai no T2; rota adotada no T14 | T2, T14 |
| `lib/l10n/app_pt.arb` (chaves `schedule*` do rascunho, remoção de `drawerMenuComingSoon`) | Cada task de UI adota as chaves que usa | T12, T13, T14, T16 |

**Commits com o rascunho por perto**: o commit de cada task inclui só os arquivos daquela task. Quando um arquivo tem linhas do rascunho que pertencem a outra task (`app_module.dart`, `app_pt.arb`), fazer stage parcial por hunk, como descreve a skill `commit`. Até o T14, o working tree compila com o rascunho, mas os commits intermediários não contêm a tela; é esperado.

---

## Test Coverage Matrix

> Generated from codebase, project guidelines, and spec - confirm before Execute. Guidelines found: none - strong defaults applied. Estilo amostrado de `test/core/database/app_database_test.dart`, `test/features/weather/**`, `test/features/auth/presentation/cubit/auth_cubit_test.dart`, `test/features/dashboard/presentation/widgets/*`.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
| ---------- | ------------------ | -------------------- | ---------------- | ----------- |
| Extensões e valores de domínio (`date_extensions`, `SchedulingWindow`, `ScheduleNote`) | unit | Todos os ramos e bordas (virada de dia, limite 200, espaços) | `test/core/**`, `test/features/schedule/domain/**` | `flutter test <arquivo>` |
| Use cases | unit (mocktail) | 1:1 com os ACs da spec; todo edge case listado tem teste; caminho de falha sem chamar o repositório | `test/features/schedule/domain/usecases/*_test.dart` | `flutter test <arquivo>` |
| Banco e migração | unit com banco real em memória (`NativeDatabase.memory()`) e teste gerado pelo `make-migrations` | Migração v1 → v2 preservando `cached_forecasts`; schema v2 validado | `test/drift/**`, `test/core/database/**` | `flutter test test/drift` |
| Data source drift | unit com banco real em memória | Todas as consultas: isolamento por usuário, ordenação, cada escrita, id inexistente, id de outro usuário | `test/features/schedule/data/datasources/*_test.dart` | `flutter test <arquivo>` |
| Repositório | unit (mocktail) | Cada método: sucesso, sem login, `AppException` → `Failure`; uso de `Clock` e `Uuid` | `test/features/schedule/data/repositories/*_test.dart` | `flutter test <arquivo>` |
| Cubits | unit (`bloc_test` + mocktail) | Sequência de estados por AC; falha de stream antes e depois de carregar; falha de ação | `test/features/schedule/presentation/**/*_test.dart` | `flutter test <arquivo>` |
| Widgets | widget (`flutter_test`) | Cada estado visual e cada interação exigida pela spec | `test/features/schedule/presentation/**`, `test/features/dashboard/**` | `flutter test <arquivo>` |
| Configuração, DI, dependências | none | Build gate | - | Build gate |

## Gate Check Commands

> Generated from codebase - confirm before Execute. Não há e2e nem CI; `flutter analyze` usa `very_good_analysis`.

| Gate Level | When to Use | Command |
| ---------- | ----------- | ------- |
| Quick | Task com testes unitários/widget | `flutter test <arquivos de teste da task>` |
| Full | Task que mexe em DI, banco ou em mais de uma camada | `flutter test` |
| Build | Fim de fase e tasks só de configuração | `flutter analyze && flutter test` |

Depois de mudar tabela, `@freezed` ou `.arb`: rodar `dart run build_runner build -d` (código gerado) e `flutter gen-l10n` antes do gate.

---

## Execution Plan

Fases em sequência; dentro da fase, tasks em ordem.

### Phase 1: Fundação

```
T1 → T2 → T3
```

### Phase 2: Domínio base

```
T4 → T5
```

### Phase 3: Dados

```
T6 → T7 → T8
```

### Phase 4: Regras de negócio

```
T9 → T10
```

### Phase 5: Tela da Agenda

```
T11 → T12 → T13 → T14
```

### Phase 6: Aviso no painel

```
T15 → T16
```

---

## Task Breakdown

### T1: Salvar o snapshot do schema v1 do banco

**What**: Configurar o `drift_dev` no `build.yaml` e rodar `dart run drift_dev make-migrations` com o banco ainda na v1, gerando o snapshot que a migração v1 → v2 vai usar.
**Where**: `build.yaml`
**Depends on**: None
**Reuses**: `build.yaml` existente (acrescentar o builder `drift_dev` sem mexer no `json_serializable`)
**Requirement**: AGD-13
**Complexidade**: Mecânica

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `build.yaml` tem `drift_dev: options: databases: app_database: lib/core/database/app_database.dart`
- [ ] `dart run drift_dev make-migrations` rodado com `schemaVersion == 1` e **nenhuma tabela alterada**; existe `drift_schemas/app_database/drift_schema_v1.json`
- [ ] Arquivos gerados pelo comando (snapshot, `schema_versions`/steps e teste, se gerados) ficam versionados
- [ ] Gate check passes: `flutter analyze && flutter test`

**Tests**: none
**Gate**: build
**Commit**: `build(database): registra o schema v1 para migrações do drift`
**Status**: [x] feito

---

### T2: Dependências e infraestrutura de app

**What**: Adicionar `clock` e `uuid` como dependências diretas, bindar `Clock` e `Uuid` no `AppModule`, remover o bind de `FirebaseFirestore`, criar `ValidationFailure` e a constante `WeatherForecast.coverageDays = 7` usada pelo data source da Open-Meteo.
**Where**: `pubspec.yaml`
**Depends on**: T1
**Reuses**: estilo de comentário do `pubspec.yaml` (seções); `lib/app/app_module.dart`; `lib/core/error/failure.dart`; `lib/features/weather/domain/entities/weather_forecast.dart`; `lib/features/weather/data/datasources/open_meteo_remote_data_source.dart:31`
**Requirement**: AGD-02, AGD-23
**Complexidade**: Mecânica

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `pubspec.yaml`: `clock` e `uuid` em `dependencies` (versões compatíveis com o `pubspec.lock` atual: clock 1.1.x, uuid 4.x); `cloud_firestore` **continua** (sai no T8)
- [ ] `AppModule`: `addSingleton<Clock>((i) => const Clock())` e `addSingleton<Uuid>((i) => const Uuid())`; bind e import de `FirebaseFirestore` removidos (o `ScheduleModule` do rascunho só resolve em runtime, então compila)
- [ ] `ValidationFailure(String message)` em `failure.dart`, seguindo o padrão das outras
- [ ] `WeatherForecast.coverageDays` existe e `'forecast_days': WeatherForecast.coverageDays` no data source
- [ ] Gate check passes: `flutter analyze && flutter test`

**Tests**: none
**Gate**: build
**Commit**: `build(core): adiciona relógio e gerador de id injetáveis`
**Status**: [x] feito

---

### T3: Extensões de data

**What**: Criar `DateTime.dateOnly` (meia-noite local do mesmo dia) e `DateTime.isSameDay(DateTime other)`.
**Where**: `lib/core/extensions/date_extensions.dart`
**Depends on**: T2
**Reuses**: estilo de `lib/core/extensions/context_extensions.dart`
**Requirement**: AGD-10, AGD-16, AGD-17
**Complexidade**: Mecânica

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `dateOnly` zera hora, minuto, segundo, milissegundo e microssegundo, mantendo o dia local
- [ ] `isSameDay` compara ano, mês e dia; horas diferentes no mesmo dia → `true`; 23:59 e 00:00 do dia seguinte → `false`
- [ ] Testes em `test/core/extensions/date_extensions_test.dart` cobrem os dois casos e a virada de mês/ano
- [ ] Gate check passes: `flutter test test/core/extensions/date_extensions_test.dart`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(core): adiciona extensões de data sem hora`
**Status**: [x] feito

---

### T4: Janela de agendamento

**What**: Criar o valor de domínio `SchedulingWindow` (`startingAt(today)`, `first`, `last`, `contains`, `clamp`), com a janela de hoje até hoje + `WeatherForecast.coverageDays - 1`.
**Where**: `lib/features/schedule/domain/entities/scheduling_window.dart`
**Depends on**: None (fase anterior concluída)
**Reuses**: `date_extensions.dart` (T3); `Equatable`
**Requirement**: AGD-02, AGD-25, AGD-26
**Complexidade**: Média

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `startingAt(DateTime(2026, 9, 23, 15, 30))` → `first == DateTime(2026, 9, 23)`, `last == DateTime(2026, 9, 29)`
- [ ] `contains`: `first` e `last` → `true`; ontem e `last + 1 dia` → `false`; hora no meio do dia de `last` → `true`
- [ ] `clamp`: data antes de `first` → `first`; depois de `last` → `first` (spec AGD-26: fora da janela abre em hoje); dentro → a própria data sem hora
- [ ] Testes em `test/features/schedule/domain/entities/scheduling_window_test.dart`, incluindo virada de mês
- [ ] Gate check passes: `flutter test test/features/schedule/domain/entities/scheduling_window_test.dart`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(schedule): define a janela de datas agendáveis`
**Status**: [x] feito

---

### T5: Observação e conclusão na entidade

**What**: Criar `ScheduleNote` (`maxLength = 200`, `normalize`) e adicionar `completedAt` + `isCompleted` à entidade `FertilizationSchedule` (adota o arquivo do rascunho).
**Where**: `lib/features/schedule/domain/entities/schedule_note.dart`
**Depends on**: T4
**Reuses**: `lib/features/schedule/domain/entities/fertilization_schedule.dart` (rascunho)
**Requirement**: AGD-03, AGD-04, AGD-28
**Complexidade**: Mecânica

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `normalize('  talhão 3  ') == 'talhão 3'`; `normalize('   ')`, `normalize('')` e `normalize(null)` → `null`; texto com 200 caracteres passa inalterado
- [ ] `FertilizationSchedule` com `completedAt` opcional nos `props`; `isCompleted` true só com `completedAt` preenchido
- [ ] Testes em `test/features/schedule/domain/entities/schedule_note_test.dart` e `fertilization_schedule_test.dart`
- [ ] Gate check passes: `flutter test test/features/schedule/domain/entities`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(schedule): adiciona observação e conclusão ao agendamento`
**Status**: [x] feito

---

### T6: Tabela de agendamentos e migração v1 → v2

**What**: Criar a tabela `FertilizationSchedules` (`@DataClassName('ScheduleRow')`, índice por usuário e data), subir o `AppDatabase` para `schemaVersion 2` com `stepByStep(from1To2: createTable + createIndex)`, rodar `make-migrations` de novo e completar o teste de migração gerado.
**Where**: `lib/core/database/tables/fertilization_schedules_table.dart`
**Depends on**: None (fase anterior concluída)
**Reuses**: `lib/core/database/tables/cached_forecasts_table.dart` (estilo); `app_database.dart`; snapshot v1 do T1
**Requirement**: AGD-13, AGD-05
**Complexidade**: Muito alta

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] Colunas exatamente como no `design.md` (Data Models); PK `id`; índice `schedules_user_date`
- [ ] `AppDatabase`: `tables: [CachedForecasts, FertilizationSchedules]`, `schemaVersion => 2`, `MigrationStrategy(onUpgrade: stepByStep(...))` usando o arquivo de steps gerado; o passo `from1To2` cria a tabela **e** o índice
- [ ] `dart run build_runner build -d` e `dart run drift_dev make-migrations` rodados; existe `drift_schemas/app_database/drift_schema_v2.json`
- [ ] Teste de migração (gerado + adaptado): v1 → v2 passa na verificação de schema **e** uma linha de `cached_forecasts` inserida na v1 continua igual na v2
- [ ] `test/core/database/app_database_test.dart` continua passando
- [ ] Gate check passes: `flutter analyze && flutter test`

**Tests**: unit
**Gate**: full
**Commit**: `feat(database): cria a tabela de agendamentos com migração para a v2`
**Status**: [x] feito

---

### T7: Data source drift da Agenda

**What**: Criar `ScheduleLocalDataSource` (interface), `DriftScheduleLocalDataSource` e o mapper `ScheduleRow.toEntity()`, com a API do `design.md`.
**Where**: `lib/features/schedule/data/datasources/drift_schedule_local_data_source.dart`
**Depends on**: T6
**Reuses**: `lib/features/weather/data/datasources/drift_weather_local_data_source.dart`; `CacheException`; `SqliteException` de `package:drift/native.dart`
**Requirement**: AGD-01, AGD-05, AGD-07, AGD-08, AGD-12, AGD-28, AGD-29, AGD-30
**Complexidade**: Alta

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] Interface em `schedule_local_data_source.dart`; mapper em `data/models/schedule_row_mapper.dart`
- [ ] `watchByUser` só devolve linhas do usuário, ordenadas por `scheduledDate` e depois `createdAt`, e reemite após cada escrita
- [ ] `updateDateAndNote`, `setCompletedAt` e `delete` filtram por `id` **e** `userId`; zero linhas afetadas → `CacheException('Agendamento não encontrado.')`
- [ ] `SqliteException` na escrita → `CacheException('Não foi possível salvar o agendamento.')` (testar com `id` duplicado no `insert`)
- [ ] Testes em `test/features/schedule/data/datasources/drift_schedule_local_data_source_test.dart` com `AppDatabase.withExecutor(NativeDatabase.memory())`, cobrindo: isolamento entre dois usuários, ordenação, cada escrita, id inexistente, id de outro usuário, reemissão do stream, mapper
- [ ] Gate check passes: `flutter test test/features/schedule/data/datasources`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(schedule): grava agendamentos no banco local`
**Status**: [ ] pendente

---

### T8: Repositório local e remoção do Firestore

**What**: Reescrever o contrato `ScheduleRepository` (5 métodos do design) e o `ScheduleRepositoryImpl` sobre o data source local, criar o `ScheduleDataModule`, ligar o `ScheduleModule` do rascunho a ele e remover tudo de Firestore.
**Where**: `lib/features/schedule/data/repositories/schedule_repository_impl.dart`
**Depends on**: T7
**Reuses**: `AuthRepository.currentUser`; `AppExceptionToFailure.toFailure()`; `lib/features/weather/weather_module.dart` (molde do módulo de serviço)
**Requirement**: AGD-01, AGD-06, AGD-07, AGD-11, AGD-12, AGD-14
**Complexidade**: Alta

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `ScheduleRepositoryImpl(local, authRepository, clock, uuid)` conforme o design: sem login → `Left(AuthFailure('É preciso estar logado para usar a agenda.'))` sem chamar o data source; `watchSchedules()` sem login → lista vazia; `createSchedule` usa `uuid.v4()` e `clock.now()`; `setScheduleCompleted(true)` grava `clock.now()`, `false` grava `null`; `AppException` → `toFailure()`
- [ ] `lib/features/schedule/schedule_data_module.dart` registra data source, repositório, `WatchSchedules`, `CreateSchedule`, `DeleteSchedule`, `EvaluateScheduleRisk`; o `ScheduleModule` do rascunho importa `ScheduleDataModule` e deixa de registrar esses binds
- [ ] Apagados: `firestore.rules`, `firestore_schedule_data_source.dart`, `schedule_remote_data_source.dart`, `schedule_model.dart`, `schedule_model.freezed.dart`; `cloud_firestore` fora do `pubspec.yaml`; `git grep -n "cloud_firestore\|Firestore" lib test pubspec.yaml` vazio
- [ ] Commit adota `watch_schedules.dart` e `delete_schedule.dart` do rascunho
- [ ] `test/features/schedule/data/repositories/schedule_repository_impl_test.dart` reescrito: cada método com sucesso, sem login e `CacheException` → `CacheFailure`; `Clock.fixed` e `Uuid` mockado para asserir id e datas gravados
- [ ] Gate check passes: `flutter analyze && flutter test`

**Tests**: unit
**Gate**: full
**Commit**: `feat(schedule): troca o rascunho em Firestore pelo repositório local`
**Status**: [ ] pendente

---

### T9: Casos de uso de escrita com validação

**What**: Reescrever `CreateSchedule` e criar `UpdateSchedule` e `SetScheduleCompleted`, com validação de janela e de observação; registrar os dois novos no `ScheduleDataModule`.
**Where**: `lib/features/schedule/domain/usecases/create_schedule.dart`
**Depends on**: None (fase anterior concluída)
**Reuses**: `SchedulingWindow` (T4), `ScheduleNote` (T5), `ValidationFailure` (T2), `UseCase` de `core/usecase`
**Requirement**: AGD-02, AGD-03, AGD-04, AGD-24, AGD-25, AGD-28, AGD-29
**Complexidade**: Média

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `CreateSchedule(repository, clock)` e `UpdateSchedule(repository, clock)`: data fora de `SchedulingWindow.startingAt(clock.now())` → `ValidationFailure('Escolha uma data entre hoje e os próximos 6 dias.')` sem chamar o repositório; nota > 200 → `ValidationFailure('A observação pode ter até 200 caracteres.')`; nota normalizada e data `dateOnly` repassadas ao repositório
- [ ] `SetScheduleCompleted(repository)` repassa `id` e `completed`
- [ ] Testes (mocktail) por use case: hoje, `last`, ontem, `last + 1`, nota com espaços, nota vazia, nota com 201 caracteres, falha do repositório repassada
- [ ] Gate check passes: `flutter test test/features/schedule/domain/usecases`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(schedule): valida data e observação ao criar e editar`
**Status**: [ ] pendente

---

### T10: Regra do aviso do painel

**What**: Criar `ScheduleAlert` (sealed) e `EvaluateScheduleAlert`, e registrar no `ScheduleDataModule`; o commit adota `EvaluateScheduleRisk`, `ScheduleRiskLevel` e o teste deles do rascunho.
**Where**: `lib/features/schedule/domain/usecases/evaluate_schedule_alert.dart`
**Depends on**: T9
**Reuses**: `EvaluateScheduleRisk` (rascunho), `date_extensions` (T3), `SyncUseCase`
**Requirement**: AGD-15, AGD-16, AGD-17, AGD-18, AGD-20, AGD-23
**Complexidade**: Alta

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] Ordem das regras exatamente como no design: descarta concluídos e passados → risco (só com previsão) → hoje → amanhã → `null`
- [ ] Testes em `evaluate_schedule_alert_test.dart`, um por AC e edge case: 2 em risco → `ScheduleRiskAlert(2)`; só hoje → lembrete de hoje; só amanhã → de amanhã; hoje e amanhã → hoje; nada → `null`; concluído em risco ignorado; ontem ignorado; hoje em risco → risco e não lembrete; 1 em risco + 1 amanhã sem risco → `ScheduleRiskAlert(1)`; dois no mesmo dia em risco → contagem 2; sem previsão + amanhã → lembrete de amanhã; fora da janela da previsão → não é risco
- [ ] Gate check passes: `flutter test test/features/schedule/domain/usecases`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(schedule): decide o aviso de risco ou lembrete do painel`
**Status**: [ ] pendente

---

### T11: Cubit e estado da Agenda

**What**: Reescrever `ScheduleState` (seções, `ScheduleItem`, `window`) e `ScheduleCubit` (ações de criar, editar, concluir e excluir, com `Clock`), e atualizar o bind no `ScheduleModule`.
**Where**: `lib/features/schedule/presentation/cubit/schedule_cubit.dart`
**Depends on**: None (fase anterior concluída)
**Reuses**: rascunho `schedule_cubit.dart`/`schedule_state.dart`; padrão de `test/features/auth/presentation/cubit/auth_cubit_test.dart`
**Requirement**: AGD-01, AGD-08, AGD-09, AGD-10, AGD-12, AGD-24, AGD-28, AGD-29, AGD-30
**Complexidade**: Alta

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `upcoming`: não concluídos por data crescente; `completed`: concluídos por data decrescente
- [ ] Risco calculado só para não concluídos de hoje em diante; antes da previsão chegar → `unknown`; `isPastDue` para não concluído com data antes de hoje (pelo `Clock`)
- [ ] `window == SchedulingWindow.startingAt(clock.now())`, recalculada a cada emissão
- [ ] Falha de ação → `withActionFailure` (lista intacta); falha do stream antes de carregar → `error`, depois → lista mantida
- [ ] Assinatura cancelada no `close()`
- [ ] Testes `bloc_test` em `test/features/schedule/presentation/cubit/schedule_cubit_test.dart` para cada item acima
- [ ] Gate check passes: `flutter test test/features/schedule/presentation/cubit`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(schedule): organiza a agenda em próximos e concluídos`
**Status**: [ ] pendente

---

### T12: Formulário de agendamento

**What**: Criar o `ScheduleFormSheet` (bottom sheet de criar/editar: campo de data com o seletor limitado à janela e observação com contador de 200 caracteres) e as strings dele no `.arb`.
**Where**: `lib/features/schedule/presentation/widgets/schedule_form_sheet.dart`
**Depends on**: T11
**Reuses**: `SchedulingWindow`, `ScheduleNote.maxLength`, `AppSpacing`, `context.l10n`
**Requirement**: AGD-02, AGD-03, AGD-25, AGD-26
**Complexidade**: Média

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `showDatePicker` recebe `firstDate == window.first`, `lastDate == window.last` e `initialDate == window.clamp(data atual)`
- [ ] `TextField(maxLength: ScheduleNote.maxLength)` impede passar de 200
- [ ] Confirmar devolve `({DateTime date, String? note})`; cancelar devolve `null`; modo edição vem preenchido
- [ ] Strings novas no `app_pt.arb` (título criar/editar, rótulo da data, rótulo e dica da observação, salvar, cancelar), sem texto fixo no widget
- [ ] Widget tests em `test/features/schedule/presentation/widgets/schedule_form_sheet_test.dart` para os quatro itens
- [ ] Gate check passes: `flutter test test/features/schedule/presentation/widgets/schedule_form_sheet_test.dart`

**Tests**: widget
**Gate**: quick
**Commit**: `feat(schedule): adiciona o formulário de criar e editar agendamento`
**Status**: [ ] pendente

---

### T13: Item da lista

**What**: Reescrever o `ScheduleTile`: data, observação, rótulo de risco ou "Data passada", checkbox de concluir, toque para editar só se não concluído, menu com "Excluir", estilo apagado para concluído.
**Where**: `lib/features/schedule/presentation/widgets/schedule_tile.dart`
**Depends on**: T12
**Reuses**: rascunho `schedule_tile.dart` (paleta de risco), `AppColors`
**Requirement**: AGD-09, AGD-10, AGD-27, AGD-28, AGD-29
**Complexidade**: Média

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] Rótulos: "Previsão favorável", "Risco de chuva forte no dia", "Sem previsão para este dia ainda", "Data passada" (chaves no `.arb`, adotando as do rascunho)
- [ ] Concluído: sem ação de editar, checkbox marcado, estilo apagado
- [ ] Callbacks `onEdit`, `onToggleCompleted(bool)` e `onDelete` disparados pelos gestos certos
- [ ] Widget tests em `test/features/schedule/presentation/widgets/schedule_tile_test.dart` para cada rótulo e cada gesto
- [ ] Gate check passes: `flutter test test/features/schedule/presentation/widgets/schedule_tile_test.dart`

**Tests**: widget
**Gate**: quick
**Commit**: `feat(schedule): mostra risco, conclusão e ações em cada agendamento`
**Status**: [ ] pendente

---

### T14: Tela da Agenda e navegação

**What**: Evoluir a `SchedulePage` (seções "Próximos" e "Concluídos", estado vazio, FAB abrindo o formulário, edição, conclusão e exclusão com diálogo) e adotar o módulo, a rota, o item do menu e a rota no `AppModule`.
**Where**: `lib/features/schedule/presentation/pages/schedule_page.dart`
**Depends on**: T13
**Reuses**: rascunho `schedule_page.dart`, `schedule_module.dart`, `app_routes.dart`, `app_drawer.dart`, `app_module.dart` (hunks da rota)
**Requirement**: AGD-01, AGD-08, AGD-12, AGD-24, AGD-30, AGD-31
**Complexidade**: Média

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] Seção vazia não aparece; sem nenhum agendamento → estado vazio
- [ ] Criar e editar passam pelo `ScheduleFormSheet`; excluir mantém o diálogo de confirmação (cancelar mantém o item)
- [ ] Snackbar para falha de ação
- [ ] Commit adota `schedule_module.dart`, a rota `AppRoute.schedule`, o item "Agenda" do menu, os hunks de rota do `app_module.dart` e as chaves restantes do `.arb` (inclui a remoção de `drawerMenuComingSoon`)
- [ ] Widget tests em `test/features/schedule/presentation/pages/schedule_page_test.dart` com `ScheduleCubit` mockado (`MockCubit`): seções, vazio, FAB abre o formulário, cancelar exclusão mantém, confirmar chama `removeSchedule`
- [ ] Gate check passes: `flutter analyze && flutter test`

**Tests**: widget
**Gate**: build
**Commit**: `feat(schedule): liga a tela da agenda ao menu do painel`
**Status**: [ ] pendente

---

### T15: Cubit do aviso

**What**: Criar `ScheduleAlertCubit` e `ScheduleAlertState` e registrar o cubit no `DashboardModule`, que passa a importar o `ScheduleDataModule`.
**Where**: `lib/features/schedule/presentation/alert/schedule_alert_cubit.dart`
**Depends on**: None (fase anterior concluída)
**Reuses**: `EvaluateScheduleAlert` (T10), `WatchSchedules`, `Clock`; padrão de `bloc_test` do projeto
**Requirement**: AGD-15, AGD-21, AGD-22, AGD-23
**Complexidade**: Alta

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] Assina `watchSchedules` na criação; `updateForecast(forecast)` recalcula; nova lista no stream recalcula (AGD-21)
- [ ] Erro no stream → `alert: null` (AGD-22)
- [ ] `today` vem do `Clock` a cada cálculo
- [ ] Assinatura cancelada no `close()`
- [ ] Testes `bloc_test` em `test/features/schedule/presentation/alert/schedule_alert_cubit_test.dart` para cada item
- [ ] Gate check passes: `flutter test test/features/schedule/presentation/alert`

**Tests**: unit
**Gate**: quick
**Commit**: `feat(schedule): acompanha agendamentos e previsão para o aviso`
**Status**: [ ] pendente

---

### T16: Banner do aviso no painel

**What**: Criar o `ScheduleAlertBanner` e embuti-lo na `DashboardPage` (provider do cubit, `BlocListener` passando a previsão, toque abrindo a Agenda), com as strings no `.arb`.
**Where**: `lib/features/schedule/presentation/alert/schedule_alert_banner.dart`
**Depends on**: T15
**Reuses**: `DashboardPage`, `AppColors.danger`, `context.reduceMotion`, `AppMotion`, `AppRoute.schedule`
**Requirement**: AGD-15, AGD-16, AGD-17, AGD-18, AGD-19, AGD-21
**Complexidade**: Média

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] Risco: texto com a contagem (plural pelo ICU do `.arb`: "1 aplicação planejada em dia de chuva forte" / "N aplicações ..."); hoje e amanhã: lembrete com o dia; `null`: nada ocupa espaço
- [ ] `onTap` recebido por parâmetro; na `DashboardPage` abre `AppRoute.schedule`
- [ ] Banner fica fora da `ForecastSection` (aparece com a previsão carregando ou com erro)
- [ ] `BlocListener<DashboardCubit, DashboardState>` chama `updateForecast` quando `status == loaded`
- [ ] Widget tests em `test/features/schedule/presentation/alert/schedule_alert_banner_test.dart`: cada tipo de aviso, contagem singular e plural, nada quando `null`, toque chama `onTap`
- [ ] Gate check passes: `flutter analyze && flutter test`

**Tests**: widget
**Gate**: build
**Commit**: `feat(dashboard): avisa no painel sobre agendamentos em risco ou do dia`
**Status**: [ ] pendente

---

## Phase Execution Map

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6

Phase 1:  T1 ------→ T2 ------→ T3
Phase 2:  T4 ------→ T5
Phase 3:  T6 ------→ T7 ------→ T8
Phase 4:  T9 ------→ T10
Phase 5:  T11 -----→ T12 -----→ T13 -----→ T14
Phase 6:  T15 -----→ T16
```

Execução estritamente sequencial.

**Agrupamento por esforço**: tasks consecutivas do mesmo nível podem ir juntas para o mesmo executor, em ordem. Quem escolhe o executor de cada nível é o orquestrador, não este arquivo.

| Grupo | Tasks | Complexidade |
| ----- | ----- | ------------ |
| 1 | T1, T2, T3 | Mecânica |
| 2 | T4 | Média |
| 3 | T5 | Mecânica |
| 4 | T6 | Muito alta |
| 5 | T7, T8 | Alta |
| 6 | T9 | Média |
| 7 | T10, T11 | Alta |
| 8 | T12, T13, T14 | Média |
| 9 | T15 | Alta |
| 10 | T16 | Média |

Commits: ao fim de cada fase, a sessão principal propõe um commit por task (skill `commit`) e só commita após o ok do usuário. Ao fim do T16, a verificação independente da skill roda automaticamente.

---

## Task Granularity Check

| Task | Scope | Status |
| ---- | ----- | ------ |
| T1 | 1 config + comando | ✅ |
| T2 | dependências e binds de infraestrutura (config) | ⚠️ coeso: nenhum item tem lógica, todos são infraestrutura exigida pelo T3+ |
| T3 | 1 arquivo de extensões | ✅ |
| T4 | 1 valor de domínio | ✅ |
| T5 | 1 valor de domínio + 1 campo na entidade | ⚠️ coeso: primitivas de escrita |
| T6 | 1 tabela + versão do banco | ⚠️ inseparável: a tabela sem a migração quebra o banco instalado |
| T7 | 1 data source (interface + impl + mapper) | ✅ |
| T8 | 1 repositório + módulo + remoção do rascunho | ⚠️ inseparável: o contrato novo e a remoção do Firestore precisam compilar juntos |
| T9 | 3 use cases de escrita | ⚠️ coeso: mesma regra de validação |
| T10 | 1 use case + 1 tipo | ✅ |
| T11 | 1 cubit + estado | ✅ |
| T12 | 1 widget | ✅ |
| T13 | 1 widget | ✅ |
| T14 | 1 página + fiação de navegação | ⚠️ coeso: a fiação só é testável com a página |
| T15 | 1 cubit + estado + bind | ✅ |
| T16 | 1 widget + integração no painel | ⚠️ coeso: integração testada junto |

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
| ---- | ---------------------- | ------------- | ------ |
| T1 | None | início da Fase 1 | ✅ Match |
| T2 | T1 | T1 → T2 | ✅ Match |
| T3 | T2 | T2 → T3 | ✅ Match |
| T4 | None (fase anterior) | Fase 1 → Fase 2 (primeira) | ✅ Match |
| T5 | T4 | T4 → T5 | ✅ Match |
| T6 | None (fase anterior) | Fase 2 → Fase 3 (primeira) | ✅ Match |
| T7 | T6 | T6 → T7 | ✅ Match |
| T8 | T7 | T7 → T8 | ✅ Match |
| T9 | None (fase anterior) | Fase 3 → Fase 4 (primeira) | ✅ Match |
| T10 | T9 | T9 → T10 | ✅ Match |
| T11 | None (fase anterior) | Fase 4 → Fase 5 (primeira) | ✅ Match |
| T12 | T11 | T11 → T12 | ✅ Match |
| T13 | T12 | T12 → T13 | ✅ Match |
| T14 | T13 | T13 → T14 | ✅ Match |
| T15 | None (fase anterior) | Fase 5 → Fase 6 (primeira) | ✅ Match |
| T16 | T15 | T15 → T16 | ✅ Match |

---

## Test Co-location Validation

| Task | Code Layer Created/Modified | Matrix Requires | Task Says | Status |
| ---- | --------------------------- | --------------- | --------- | ------ |
| T1 | Configuração | none | none | ✅ OK |
| T2 | Configuração, DI, dependências (+ constante e tipo de falha sem lógica) | none | none | ✅ OK |
| T3 | Extensão de domínio | unit | unit | ✅ OK |
| T4 | Valor de domínio | unit | unit | ✅ OK |
| T5 | Valor de domínio, entidade | unit | unit | ✅ OK |
| T6 | Banco e migração | unit (banco em memória) | unit | ✅ OK |
| T7 | Data source drift | unit (banco em memória) | unit | ✅ OK |
| T8 | Repositório, DI | unit | unit | ✅ OK |
| T9 | Use cases | unit | unit | ✅ OK |
| T10 | Use case | unit | unit | ✅ OK |
| T11 | Cubit | unit | unit | ✅ OK |
| T12 | Widget | widget | widget | ✅ OK |
| T13 | Widget | widget | widget | ✅ OK |
| T14 | Página, DI, rotas | widget | widget | ✅ OK |
| T15 | Cubit, DI | unit | unit | ✅ OK |
| T16 | Widget | widget | widget | ✅ OK |
