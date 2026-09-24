# Caderno de agendamento — Validation

## Validation: schedule - PASS ✅

**Iteração**: 2 de 3 (re-verificação dos Fix 1 e Fix 2 da iteração 1). Veredito da iteração 1: reprovada (AGD-19 sem evidência, mutante M9 vivo, edge case da virada do dia não atendido). As evidências da iteração 1 dos outros 29 critérios e os 9 mutantes mortos continuam valendo e não foram refeitos.
**Date**: 2026-09-24
**Spec**: `.specs/features/schedule/spec.md`
**Diff range**: `main...feat/schedule` (15 commits, `eab903b..8337a7b`, T1–T14 + docs) **mais** o working tree não commitado do T15/T16 e dos Fix 1/Fix 2 (`lib/features/schedule/presentation/cubit/schedule_cubit.dart`, `lib/features/schedule/presentation/pages/schedule_page.dart`, `pubspec.yaml`/`pubspec.lock` (`go_router` como dev_dependency; o lockfile só reclassifica o pacote de `transitive` para `direct dev`), `test/features/schedule/presentation/cubit/schedule_cubit_test.dart`, `test/features/schedule/presentation/pages/schedule_page_test.dart`, `lib/features/schedule/presentation/alert/**`, `lib/features/dashboard/dashboard_module.dart`, `lib/features/dashboard/presentation/pages/dashboard_page.dart`, `lib/l10n/app_pt.arb`, `test/features/schedule/presentation/alert/**`, `test/features/dashboard/presentation/pages/**`)
**Verifier**: sub-agente independente (autor ≠ verificador), `model: opus`

---

## Task Completion

| Task | Status | Notes |
| ---- | ------ | ----- |
| T1–T14 | ✅ Done | Commits na branch |
| T15 | ⚠️ Feito, não commitado | Working tree; `tasks.md` ainda marca `[ ] pendente` |
| T16 | ⚠️ Feito, não commitado | Working tree; `tasks.md` ainda marca `[ ] pendente` |

---

## Spec-Anchored Acceptance Criteria

Caminhos de teste relativos a `test/features/schedule/` salvo indicação.

| AC | Resultado definido na spec | `file:line` + asserção | Result |
| -- | -------------------- | ----------------------- | ------ |
| AGD-01 gravar com uid e exibir sem reabrir | linha com `uid` do logado; lista reemite | `data/repositories/schedule_repository_impl_test.dart:150` - `verify(local.insert(ScheduleRow(id:'uuid-gerado', userId:_uid, ..., createdAt:_now)))`; `data/datasources/drift_schedule_local_data_source_test.dart:113` - `expect((await next()).single.id, 'a1')` (reemissão após insert); `presentation/pages/schedule_page_test.dart:183` - `verify(cubit.addSchedule(window.first, note:'talhão 3'))` | ✅ PASS |
| AGD-02 seletor hoje..hoje+6 | `firstDate == hoje`, `lastDate == hoje+6` | `presentation/widgets/schedule_form_sheet_test.dart:52-53` - `dialog.firstDate == window.first`, `dialog.lastDate == window.last`; `domain/entities/scheduling_window_test.dart:9-10` - `first == 2026-09-23`, `last == 2026-09-29`; bordas `:25,:29,:37,:41` | ✅ PASS |
| AGD-03 trim + limite 200 | `'  talhão 3  '` → `'talhão 3'`; >200 recusado | `domain/entities/schedule_note_test.dart:7`; `domain/usecases/create_schedule_test.dart:113` - `verify(createSchedule(..., note:'talhão 3'))`; `:144-147` - `ValidationFailure('A observação pode ter até 200 caracteres.')`; `presentation/widgets/schedule_form_sheet_test.dart:146` | ✅ PASS |
| AGD-04 vazia → sem observação | `note == null` | `domain/entities/schedule_note_test.dart:11,15,19`; `domain/usecases/create_schedule_test.dart:126` - `note: null`; `presentation/widgets/schedule_form_sheet_test.dart:159` | ✅ PASS |
| AGD-05 persiste entre execuções | dados gravados antes reaparecem | `test/drift/app_database/migration_test.dart:139-142` (instância nova sobre o mesmo banco lê a linha gravada pela anterior); `data/datasources/drift_schedule_local_data_source_test.dart:169-196` (banco em arquivo). Persistência real no aparelho só por UAT | ✅ PASS (indireto; UAT pendente) |
| AGD-06 offline | CRUD sem rede | Caminho de escrita só toca o drift local: `data/repositories/schedule_repository_impl_test.dart:150,222,310,370` (sem dependência de rede); modo avião só por UAT | ✅ PASS (estrutural; UAT pendente) |
| AGD-07 só do usuário | só linhas do `uid` logado | `data/datasources/drift_schedule_local_data_source_test.dart:62-64` - `idsOf(_alice) == ['a1','a2']`, `idsOf(_bob) == ['b1']`; `data/repositories/schedule_repository_impl_test.dart:63-87` (`watchByUser(_uid)`); escrita em linha alheia: `:257-268`, `:326-337`, `:357-365` | ✅ PASS |
| AGD-08 seções e ordem | Próximos crescente; Concluídos decrescente | `presentation/cubit/schedule_cubit_test.dart:169-194` - `upcoming:[past,today,later]`, `completed:[doneFuture,doneRecent,doneOld]`; `data/datasources/drift_schedule_local_data_source_test.dart:81,93,102`; `presentation/pages/schedule_page_test.dart:98-99` | ✅ PASS |
| AGD-09 risco por item | favorável / risco de chuva forte / sem previsão | `presentation/cubit/schedule_cubit_test.dart:260-289` (`atRisk`, `ok`, `unknown` antes da previsão); `presentation/widgets/schedule_tile_test.dart:61,73,85` - textos exatos | ✅ PASS |
| AGD-10 "Data passada" | rótulo em não concluído com data < hoje | `presentation/cubit/schedule_cubit_test.dart:183` - `item(pastDue, isPastDue:true)`; `:291-326` (sem risco mesmo com previsão); `presentation/widgets/schedule_tile_test.dart:99-100` | ✅ PASS |
| AGD-11 sem login recusa | `AuthFailure`, banco intacto | `data/repositories/schedule_repository_impl_test.dart:181-183` - `Left(AuthFailure('É preciso estar logado para usar a agenda.'))` + `verifyZeroInteractions(local)`; idem `:262-263`, `:334-335`, `:379-380` | ✅ PASS |
| AGD-12 falha de escrita | mensagem de erro + lista mantida | `data/datasources/drift_schedule_local_data_source_test.dart:162,187` - `CacheException('Não foi possível salvar o agendamento.')` (memória e background/`DriftRemoteException`); `presentation/cubit/schedule_cubit_test.dart:587-598` - `[loaded, loaded.withActionFailure(writeFailure)]`; `presentation/pages/schedule_page_test.dart:300-304` - snackbar + `Próximos` visível | ✅ PASS |
| AGD-13 migração v1→v2 | cria tabela e preserva cache | `test/drift/app_database/migration_test.dart:102` - `rows == expectedNewCachedForecastsData`; `:147` - `user_version == 2`; `:155-158` - índice `schedules_user_date` presente; `:39` `migrateAndValidate` | ✅ PASS |
| AGD-14 sem `cloud_firestore` | nenhuma referência | Build gate verde; `git grep "cloud_firestore\|Firestore" lib test pubspec.yaml pubspec.lock` vazio; `firestore.rules` removido | ✅ PASS (gate/config) |
| AGD-15 alerta com contagem | `ScheduleRiskAlert(n)` e texto com n | `domain/usecases/evaluate_schedule_alert_test.dart:79` - `ScheduleRiskAlert(2)`; `presentation/alert/schedule_alert_banner_test.dart:56-59` (singular), `:67-70` (plural "3 aplicações...") | ✅ PASS |
| AGD-16 lembrete de hoje | `ScheduleTodayReminder` | `domain/usecases/evaluate_schedule_alert_test.dart:85,109`; `presentation/alert/schedule_alert_banner_test.dart:78-81` | ✅ PASS |
| AGD-17 lembrete de amanhã | `ScheduleTomorrowReminder` | `domain/usecases/evaluate_schedule_alert_test.dart:91,100` (virada de mês); `presentation/alert/schedule_alert_banner_test.dart:89-92` | ✅ PASS |
| AGD-18 sem aviso | `null`, sem espaço ocupado | `domain/usecases/evaluate_schedule_alert_test.dart:115,119`; `presentation/alert/schedule_alert_banner_test.dart:103` - altura `0` | ✅ PASS |
| AGD-19 toque abre a Agenda | navega para `AppRoute.schedule` | **Iteração 2:** `test/features/dashboard/presentation/pages/dashboard_page_test.dart:223` - `expect(find.text('agenda-aberta'), findsOneWidget)` após tocar no banner (`:220`), com `GoRouter` real cuja rota `AppRoute.schedule.path`/`AppRoute.schedule.name` (`:202-204`) mostra o placeholder; o painel chama `context.pushNamed(AppRoute.schedule.name)` (`lib/features/dashboard/presentation/pages/dashboard_page.dart:108`). Callback do banner: `presentation/alert/schedule_alert_banner_test.dart:115`. M9 re-rodado: morto (M13). Iteração 1: ❌ GAP | ✅ PASS |
| AGD-20 ignora concluídos e passados | concluído/ontem não geram aviso | `domain/usecases/evaluate_schedule_alert_test.dart:128,137,146` - `isNull` | ✅ PASS |
| AGD-21 atualiza ao voltar | nova lista recalcula o aviso; previsão repassada | `presentation/alert/schedule_alert_cubit_test.dart:189-198` - `[tomorrowReminder, noAlert]` após concluir; `:200-217`; `test/features/dashboard/presentation/pages/dashboard_page_test.dart:141` - `verify(updateForecast(forecast)).called(1)`, `:154` - `verifyNever` em loading | ✅ PASS |
| AGD-22 falha de leitura | painel normal, sem aviso | `presentation/alert/schedule_alert_cubit_test.dart:220-229` - `[todayReminder, noAlert]`; `:231-242` | ✅ PASS |
| AGD-23 relógio injetável | hoje/amanhã/data passada/janela pelo `Clock` | `presentation/alert/schedule_alert_cubit_test.dart:279-290` (virada muda amanhã → hoje), `:309` - `p.today == [now, 2026-09-25 07:00]`; `presentation/cubit/schedule_cubit_test.dart:446-468`; `domain/usecases/create_schedule_test.dart` com `Clock.fixed` | ✅ PASS |
| AGD-24 editar grava e reavalia | alteração gravada; risco recalculado | `domain/usecases/update_schedule_test.dart:39-46`; `presentation/cubit/schedule_cubit_test.dart:377-404` (`atRisk` → `ok`); `presentation/pages/schedule_page_test.dart:221` - `verify(editSchedule('s1', window.last, note:'ureia'))` | ✅ PASS |
| AGD-25 mesmas regras na edição | mesma janela e nota | `domain/usecases/update_schedule_test.dart:73-80,98-105,125,143,163-166` (mesmas mensagens de `ValidationFailure`) | ✅ PASS |
| AGD-26 data fora da janela → hoje | `initialDate == hoje` | `presentation/widgets/schedule_form_sheet_test.dart:88` - `dialog.initialDate == window.first`; `domain/entities/scheduling_window_test.dart:49,53` | ✅ PASS |
| AGD-27 concluído não edita | toque não chama `onEdit` | `presentation/widgets/schedule_tile_test.dart:175` - `expect(edited, isFalse)` | ✅ PASS |
| AGD-28 concluir | grava o momento; vai para Concluídos | `data/repositories/schedule_repository_impl_test.dart:310` - `completedAt: _now`; `presentation/cubit/schedule_cubit_test.dart:210-237`; `presentation/widgets/schedule_tile_test.dart:212` | ✅ PASS |
| AGD-29 desfazer | `completedAt = null`; volta a Próximos | `data/repositories/schedule_repository_impl_test.dart:322` - `completedAt: null`; `data/datasources/drift_schedule_local_data_source_test.dart:273-292`; `presentation/cubit/schedule_cubit_test.dart:210-237`; `presentation/widgets/schedule_tile_test.dart:231` | ✅ PASS |
| AGD-30 confirmar exclusão | remove do banco e da lista | `presentation/pages/schedule_page_test.dart:275` - `verify(removeSchedule('s1')).called(1)`; `data/datasources/drift_schedule_local_data_source_test.dart:347` - `idsOf == ['a2']` | ✅ PASS |
| AGD-31 cancelar exclusão | mantém | `presentation/pages/schedule_page_test.dart:251` - `verifyNever(removeSchedule(any()))` | ✅ PASS |

**Status**: ✅ 31/31 com evidência que bate com a spec (AGD-19 fechado na iteração 2). AGD-05 e AGD-06 têm evidência indireta ou estrutural: confirmar no UAT em modo avião.

---

## Edge Cases

- [x] Hoje em risco → só risco: `domain/usecases/evaluate_schedule_alert_test.dart:155` - `ScheduleRiskAlert(1)`
- [x] 1 em risco + 1 amanhã sem risco → risco com 1: `:164`
- [x] Dois no mesmo dia são distintos: `:173` - `ScheduleRiskAlert(2)`; `data/datasources/drift_schedule_local_data_source_test.dart:102` (ordem estável por id)
- [x] Sem previsão (carregando/erro) → sem risco, lembrete vale: `domain/usecases/evaluate_schedule_alert_test.dart:179`; `test/features/dashboard/presentation/pages/dashboard_page_test.dart:169-173` (lembrete com o painel carregando)
- [x] **Dia vira com a Agenda aberta → nova data no próximo seletor: atendido na iteração 2.** `ScheduleCubit.currentWindow()` calcula `SchedulingWindow.startingAt(_clock.now())` na hora da chamada (`lib/features/schedule/presentation/cubit/schedule_cubit.dart:78`), e a página usa `cubit.currentWindow()` ao criar (`lib/features/schedule/presentation/pages/schedule_page.dart:72`) e ao editar (`:153`). Evidência: `presentation/cubit/schedule_cubit_test.dart:483-484` - relógio avançado para 2026-09-24 00:05 **sem** nova emissão → `currentWindow() == SchedulingWindow.startingAt(2026-09-24)` (primeiro dia 24/09, último 30/09, como a spec pede), e `:487` - `state.window` ainda é a de 23/09; `presentation/pages/schedule_page_test.dart:214-215` - com `state.window` de ontem (`:194-201`), o seletor aberto por "Agendar" tem `firstDate == window.first` e `lastDate == window.last` da janela atual. Mutantes M11 e M12: mortos. **Lacuna menor (não bloqueia):** o caminho de **edição** (`schedule_page.dart:153`) não tem teste que discrimine: no teste de edição (`presentation/pages/schedule_page_test.dart:232-252`) `state.window` e o stub de `currentWindow()` (`:39`) são a mesma janela, então voltar só essa linha para `state.window` passaria na suíte (conclusão estática, não rodado por limite de orçamento de mutantes). O código está correto nos dois pontos.
- Registro da iteração 1 (superado): **Dia vira com a Agenda aberta → nova data no próximo seletor: NÃO atendido.** `ScheduleView` passa `cubit.state.window` ao `ScheduleFormSheet` (`lib/features/schedule/presentation/pages/schedule_page.dart:72` e `:153`), e o `ScheduleCubit` só recalcula `window` quando o stream ou a previsão emitem (`lib/features/schedule/presentation/cubit/schedule_cubit.dart:177`). Sonda em cópia isolada: relógio avançado para 24/09 sem nova emissão → `state.window` continua `(2026-09-23, 2026-09-29)`. Com a tela aberta depois da meia-noite, o seletor oferece ontem e o use case recusa com `ValidationFailure`. O teste `presentation/cubit/schedule_cubit_test.dart:446-468` só cobre a virada **com** nova emissão.
- [x] Observação > 200 bloqueada na digitação: `presentation/widgets/schedule_form_sheet_test.dart:120,129` - `maxLength == 200`, `text.length == 200` após digitar 250

---

## Gate Check

- **Gate command**: `flutter analyze && flutter test`
- **Result (iteração 2)**: `flutter analyze` → `No issues found!`; `flutter test` → `+313: All tests passed!` (exit 0), 0 falhas, 0 skips. Iteração 1: 310.
- **Test count before feature** (`main`, contado em worktree isolado): 106
- **Test count after feature**: 313 (iteração 2; +3 dos fixes: cubit `currentWindow`, página virada do dia, painel AGD-19)
- **Delta**: +207; nenhum teste removido ou enfraquecido nos fixes
- **Skipped tests**: nenhum
- **Failures**: nenhuma

---

## Discrimination Sensor

Worktree isolado (`git worktree add --detach` em HEAD + cópia dos arquivos não commitados + `flutter gen-l10n`); só os testes afetados por mutante; cada arquivo restaurado do projeto real entre mutantes; worktree removido; `git status --porcelain` do projeto **idêntico** ao baseline.

| # | File | Mutação | Testes rodados | Killed? |
| - | ---- | ------- | -------------- | ------- |
| M1 | `lib/features/schedule/data/datasources/drift_schedule_local_data_source.dart:75` | `_owned` sem `& t.userId.equals(userId)` | `data/datasources` | ✅ Killed (3: update/setCompletedAt/delete de outro usuário) |
| M2 | `lib/core/database/app_database.dart:44` | remove `m.createIndex(schema.schedulesUserDate)` | `test/drift` | ✅ Killed (3) |
| M3 | `drift_schedule_local_data_source.dart:89` | `remoteCause is SqliteException` → `is StateError` | `data/datasources` | ✅ Killed (banco em background) |
| M4 | `lib/features/schedule/domain/usecases/evaluate_schedule_alert.dart:52` | checa "hoje" antes do risco | alert use case + alert cubit | ✅ Killed (5) |
| M5 | `lib/features/schedule/domain/entities/scheduling_window.dart:41` | `!day.isAfter(last)` → `day.isBefore(last)` | window + use cases | ✅ Killed (4) |
| M6 | `lib/features/schedule/presentation/cubit/schedule_cubit.dart:154` | `isPastDue` por `isBefore(now)` sem `dateOnly` | `presentation/cubit` | ✅ Killed (16) |
| M7 | `lib/features/dashboard/presentation/pages/dashboard_page.dart` (`listenWhen`) | `current.status == loaded` → `true` | dashboard page | ✅ Killed |
| M8 | `lib/features/schedule/presentation/pages/schedule_page.dart:57` | FAB mostrado também em erro | `presentation/pages` | ✅ Killed |
| M9 | `lib/features/dashboard/presentation/pages/dashboard_page.dart` (`ScheduleAlertBanner.onTap`) | `AppRoute.schedule` → `AppRoute.dashboard` | `test/features/dashboard` + `presentation/alert` | ❌ **Survived** |
| M10 | `evaluate_schedule_alert.dart:48` | não descarta datas passadas | alert use case + alert cubit | ✅ Killed |

**Sensor depth (iteração 1)**: expandido (10 mutantes, integridade de dados e isolamento por usuário)
Resultado da iteração 1: 9/10 mortos, M9 vivo (reprovado).

### Iteração 2 (re-verificação dos fixes)

Cópia isolada em `mktemp`/scratchpad (`rsync` do projeto sem `.git`, `build`, `.dart_tool` e pastas de plataforma + `flutter pub get --offline` + `flutter gen-l10n`); suíte afetada verde antes das mutações (42 testes); cada arquivo restaurado depois do mutante (`diff -r lib` contra o projeto: igual); cópia removida; `git status --porcelain` do projeto **idêntico** ao baseline; `git worktree list` só com o worktree principal.

| # | File | Mutação | Testes rodados | Killed? |
| - | ---- | ------- | -------------- | ------- |
| M11 | `lib/features/schedule/presentation/pages/schedule_page.dart:72,153` | a página volta a usar `cubit.state.window` | `presentation/pages/schedule_page_test.dart` | ✅ Killed (`edge case: virada do dia...`: Expected 2026-09-23, Actual 2026-09-22) |
| M12 | `lib/features/schedule/presentation/cubit/schedule_cubit.dart:78` | `currentWindow()` devolve `state.window` | `presentation/cubit/schedule_cubit_test.dart` + `presentation/pages/schedule_page_test.dart` | ✅ Killed (`currentWindow acompanha o relógio...`: Expected (24/09, 30/09), Actual (23/09, 29/09)) |
| M13 | `lib/features/dashboard/presentation/pages/dashboard_page.dart:108` | M9 da iteração 1: `AppRoute.schedule` → `AppRoute.dashboard` | `test/features/dashboard/presentation/pages/dashboard_page_test.dart` + `presentation/alert` | ✅ Killed (`AGD-19: tocar no aviso abre a Agenda`: o roteador de teste recusa o nome desconhecido e o placeholder da Agenda não aparece; qualquer destino diferente de `AppRoute.schedule` reprova) |

**Sensor depth (iteração 2)**: focado nos fixes (3 mutantes, limite do orquestrador)
**Result**: 12/13 killed no total; o único vivo (M9) foi refeito como M13 e morreu - PASS ✅

---

## Code Quality

| Principle | Status |
| --------- | ------ |
| Minimum code / no scope creep | ✅ |
| Surgical changes | ✅ (reformatação do `dashboard_module.dart`/`dashboard_page.dart` pelo `dart format`: ruído de diff, sem mudança de comportamento) |
| Matches patterns | ✅ (módulo de dados compartilhado no molde do `WeatherModule`; `View` separada para teste como na `SchedulePage`) |
| Spec-anchored outcome check | ✅ (iteração 2: AGD-19 provado com roteador real; na iteração 1 estava só no nível do callback) |
| Per-layer Coverage Expectation | ✅ (iteração 2: navegação do banner testada na `DashboardPage`); ⚠️ menor: caminho de edição da virada do dia sem teste que discrimine |
| Dependências | ✅ `go_router` só em `dev_dependencies`, na mesma versão já resolvida como transitiva do `go_router_modular` |
| Every test maps to a requirement | ✅ |
| Documented guidelines followed | none - strong defaults applied (conforme `tasks.md`) |

**Observação (não verificada, baixa prioridade):** `ScheduleAlertCubit` é `addSingleton` no `DashboardModule` e entregue por `BlocProvider(create:)`, que fecha o cubit no dispose da página. Se a `DashboardPage` for remontada sem o módulo ser descartado, o singleton volta fechado. É o mesmo padrão pré-existente do `DashboardCubit`; vale confirmar no UAT (logout → login).

**Fora do escopo (registrado, não investigado):** bug pré-existente `hourly.first` = meia-noite no painel; comentários didáticos antigos (limpeza em PR separado).

---

## Fix Plans (iteração 1, aplicados e confirmados na iteração 2)

### Fix 1: Virada do dia com a Agenda aberta (Edge Case 5) - Major

- **Root cause**: a janela do seletor vem de `state.window`, recalculada só quando o stream ou a previsão emitem.
- **Fix task**: calcular a janela na hora de abrir o formulário a partir do `Clock` (ex.: expor `ScheduleCubit.currentWindow()` que devolve `SchedulingWindow.startingAt(_clock.now())`, usado em `_createSchedule` e `_editSchedule` da `SchedulePage`), ou recalcular antes de abrir o sheet.
- **Verify**: teste de cubit/página com `Clock(() => current)`: carrega a lista em 23/09, avança o relógio para 24/09 **sem** nova emissão, abre o seletor → `firstDate == 2026-09-24`, `lastDate == 2026-09-30`.
- **Done when**: o teste acima passa e a sonda do Verifier (janela sem emissão) fica verde.

### Fix 2: Teste de navegação do banner no painel (AGD-19, mutante M9) - Major

- **Root cause**: `dashboard_page_test.dart` não toca no banner; o teste do banner só prova o callback.
- **Fix task**: em `test/features/dashboard/presentation/pages/dashboard_page_test.dart`, montar `DashboardView` com um roteador de teste (ex.: `GoRouter` com as rotas `AppRoute.dashboard` e `AppRoute.schedule` apontando para placeholders) e `ScheduleAlertState(alert: ScheduleTodayReminder())`; tocar no banner e verificar que a rota `AppRoute.schedule` foi aberta (placeholder da Agenda visível).
- **Verify**: re-rodar o M9 (`AppRoute.schedule` → `AppRoute.dashboard`) e confirmar que ele morre.
- **Done when**: novo teste verde e M9 morto.

---

## Fix Plans (iteração 2, opcional, não bloqueia)

### Fix 3: Teste do caminho de edição na virada do dia - Minor

- **Root cause**: o teste de edição da página usa a mesma janela no estado e no stub de `currentWindow()`, então não distingue as duas fontes.
- **Fix task**: em `test/features/schedule/presentation/pages/schedule_page_test.dart`, variante do teste da virada do dia para o fluxo de editar: `state.window` de ontem, `currentWindow()` de hoje, agendamento não concluído na lista; tocar no item, abrir o seletor e conferir `firstDate == window.first` e `lastDate == window.last`.
- **Verify**: `schedule_page.dart:153` de volta para `cubit.state.window` precisa reprovar o teste novo.

---

## Requirement Traceability Update

Iteração 1: FAIL, status do `spec.md` não alterado. Iteração 2: PASS, AGD-01..31 → `✅ Verified` no `spec.md`.

---

## Summary

**Overall (iteração 2)**: ✅ Ready (UAT pendente para AGD-05/AGD-06 em modo avião e para o singleton do `ScheduleAlertCubit` no logout → login)

**Spec-anchored check**: 31/31 ACs batem com a spec; 6/6 edge cases atendidos (1 lacuna menor de teste no caminho de edição)
**Sensor**: 12/13 no total; os 3 mutantes da iteração 2 morreram, incluindo o M9 refeito (M13)
**Gate**: 313 passed, 0 failed; analyze limpo

Histórico da iteração 1: 30/31 ACs, 9/10 mutantes, 310 testes; lacunas AGD-19 e virada do dia, corrigidas pelos Fix 1 e Fix 2.

**What works**: CRUD local com isolamento por usuário, migração v1→v2 com índice, tratamento de `DriftRemoteException`, regra risco → hoje → amanhã, janela de datas, seções e ordem, cubit do aviso e o `listenWhen` do painel, todos com testes que discriminam.

**Issues found**: nenhum bloqueante. Menor: caminho de edição da virada do dia sem teste que discrimine (Fix 3).

**Next steps**: commitar T15/T16 e os fixes (com o ok do usuário), marcar T15/T16 como feitos no `tasks.md`, UAT em modo avião; Fix 3 opcional.

## Após a iteração 2: lacuna menor fechada pelo orquestrador

A lacuna 1 da iteração 2 (caminho de edição sem teste que o distinga do código antigo) foi fechada com o teste "edge case: virada do dia com a tela aberta, a edição também usa a janela atual e não a do estado" em `test/features/schedule/presentation/pages/schedule_page_test.dart`. Mutante conferido: voltar o caminho de edição da `SchedulePage` para `state.window` faz esse teste falhar. Gate após a mudança: `flutter analyze` limpo, `flutter test` com 314 passando.

## Após o teste no aparelho: botões do tema

No aparelho, o formulário da Agenda não abria: `BoxConstraints forces an infinite width`. O tema do app definia `minimumSize: Size.fromHeight(52)` para `FilledButton`/`OutlinedButton`, ou seja, largura mínima infinita, que quebra qualquer botão dentro de `Row` (ações do formulário) ou das ações de um `AlertDialog` (confirmação de exclusão). Os testes não pegavam porque montavam as telas com o tema padrão do Flutter. Correção: `Size(64, 52)` no tema; teste de regressão `test/core/theme/app_theme_test.dart` (claro e escuro); os testes do formulário e da página da Agenda passam a usar o `AppTheme`. Com o tema antigo, 15 testes falham. Gate: `flutter analyze` limpo, `flutter test` com 316 passando.
