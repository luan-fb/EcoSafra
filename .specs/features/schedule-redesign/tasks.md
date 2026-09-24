# Redesign da Agenda — Tasks

## Execution Protocol (MANDATORY -- do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user - do not proceed without it.**

---

**Spec**: `.specs/features/schedule-redesign/spec.md`
**Design**: `.specs/features/schedule-redesign/design.md`
**Status**: Approved
**Branch**: `feat/schedule`

---

## Como retomar (leia antes de qualquer task)

1. Leia `.specs/STATE.md` (decisões e handoff), depois este arquivo.
2. Rode `git log --oneline --grep "Refs: T" main..feat/schedule` e `git status --short`. A evidência do git vence o texto: task com commit `Refs: T<n>` e o escopo `schedule-redesign` no corpo está feita.
3. Pegue a primeira task sem `[x]` em **Status**. Se o Handoff do `STATE.md` diz que ela está **EM ANDAMENTO**, há trabalho parcial dela no working tree: preserve, rode o gate e termine o ciclo.
4. Ao terminar: gate verde → `Status` como `[x] feito` → commit único com código, testes e esta atualização, com o rodapé `Refs: T<n>`. Nunca pule o gate, nunca apague ou enfraqueça teste.

**Regras do projeto para quem executa:** comentários só essenciais (o porquê de decisão não óbvia, restrição), sem analogias didáticas; toda animação respeita `context.reduceMotion`, com durações do `AppMotion`; textos só pelo `.arb`; testes de widget com o `AppTheme` real (`GoogleFonts.config.allowRuntimeFetching = false`), porque bugs de layout do tema só aparecem com ele.

---

## Test Coverage Matrix

> Generated from codebase, project guidelines, and spec - confirm before Execute. Guidelines found: none - strong defaults applied. Estilo amostrado de `test/features/schedule/**` e `test/core/theme/app_theme_test.dart`.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
| ---------- | ------------------ | -------------------- | ---------------- | ----------- |
| Entidades e use cases | unit | 1:1 com os ACs; bordas do dia | `test/features/{weather,schedule}/domain/**` | `flutter test <arquivo>` |
| Repositório | unit (mocktail) | Sucesso com valores exatos gravados, sem login, erro do banco | `test/features/schedule/data/repositories/*_test.dart` | `flutter test <arquivo>` |
| Cubit | unit (`bloc_test`) | Sequência exata de estados por AC, falhas e ordem | `test/features/schedule/presentation/cubit/*_test.dart` | `flutter test <arquivo>` |
| Widgets | widget, com `AppTheme` | Cada estado visual, cada gesto, semântica e redução de movimento | `test/features/schedule/presentation/{widgets,pages}/*_test.dart` | `flutter test <arquivo>` |
| Dependência e DI | none | Build gate | - | Build gate |

## Gate Check Commands

| Gate Level | When to Use | Command |
| ---------- | ----------- | ------- |
| Quick | Task com testes unitários ou de widget | `flutter test <arquivos de teste da task>` |
| Full | Task que mexe em DI ou em mais de uma camada | `flutter test` |
| Build | Fim de fase | `flutter analyze && flutter test` |

Depois de mudar o `.arb`, rode `flutter gen-l10n` antes do gate.

---

## Execution Plan

Fases em sequência; dentro da fase, tasks em ordem. T1–T4 foram entregues antes deste redesenho.

### Phase 1: Estado vazio (entregue)

```
T1 → T2
```

### Phase 2: Transições da lista (entregue)

```
T3 → T4
```

### Phase 3: Dados

```
T5 → T6
```

### Phase 4: Cubit

```
T7
```

### Phase 5: Widgets do card

```
T8 → T9 → T10
```

### Phase 6: Tela

```
T11 → T12
```

---

## Task Breakdown

### T1: Componente de animação do estado vazio

**What**: `ScheduleEmptyAnimation`, animação nativa com `AnimationController`.
**Where**: `lib/features/schedule/presentation/widgets/schedule_empty_animation.dart`
**Depends on**: None
**Reuses**: `context.reduceMotion`
**Requirement**: SCHEDUI-01, SCHEDUI-02
**Complexidade**: Média

**Done when**:

- [x] Entregue no commit b46700f (histórico)

**Tests**: widget
**Gate**: quick
**Status**: [x] feito

---

### T2: Estado vazio usa a animação

**What**: A view vazia da Agenda usa o `ScheduleEmptyAnimation`.
**Where**: `lib/features/schedule/presentation/pages/schedule_page.dart`
**Depends on**: T1
**Reuses**: T1
**Requirement**: SCHEDUI-01
**Complexidade**: Mecânica

**Done when**:

- [x] Entregue no commit b46700f (histórico)

**Tests**: widget
**Gate**: quick
**Status**: [x] feito

---

### T3: Transição ao concluir

**What**: Estilo do texto e rótulo animados ao concluir.
**Where**: `lib/features/schedule/presentation/widgets/schedule_tile.dart`
**Depends on**: None (fase anterior concluída)
**Reuses**: animações implícitas
**Requirement**: SCHEDUI-03
**Complexidade**: Média

**Done when**:

- [x] Entregue no commit f1b0106 (histórico)

**Tests**: widget
**Gate**: quick
**Status**: [x] feito

---

### T4: Saída animada de itens

**What**: Saída animada ao excluir (substituída pelo swipe no T12).
**Where**: `lib/features/schedule/presentation/pages/schedule_page.dart`
**Depends on**: T3
**Reuses**: `AnimatedSize`
**Requirement**: SCHEDUI-04
**Complexidade**: Média

**Done when**:

- [x] Entregue no commit 54b7c48 (histórico)

**Tests**: widget
**Gate**: quick
**Status**: [x] feito

---

### T5: Dia da previsão por data

**What**: Criar `DailyForecastPoint? WeatherForecast.dayOf(DateTime date)`, comparando só o dia, e fazer o `EvaluateScheduleRisk` usá-lo no lugar do `_findDay` privado.
**Where**: `lib/features/weather/domain/entities/weather_forecast.dart`
**Depends on**: None (fase anterior concluída)
**Reuses**: `EvaluateScheduleRisk._findDay`, `DateTime.isSameDay` (`lib/core/extensions/date_extensions.dart`)
**Requirement**: SCHEDUI-07
**Complexidade**: Mecânica

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `dayOf` devolve o ponto do mesmo dia, ignorando a hora, e `null` fora da previsão
- [ ] `EvaluateScheduleRisk` usa `dayOf`; os testes dele passam sem alteração
- [ ] Testes em `test/features/weather/domain/entities/weather_forecast_test.dart`: dia presente com hora diferente, dia ausente, lista vazia
- [ ] Gate check passes: `flutter test test/features/weather test/features/schedule/domain`

**Tests**: unit
**Gate**: quick
**Status**: [ ] pendente

---

### T6: Restaurar agendamento

**What**: `ScheduleRepository.restoreSchedule(FertilizationSchedule)`, implementação no `ScheduleRepositoryImpl`, use case `RestoreSchedule` e bind no `ScheduleDataModule`.
**Where**: `lib/features/schedule/domain/usecases/restore_schedule.dart`
**Depends on**: T5
**Reuses**: `ScheduleRepositoryImpl._write`, `ScheduleLocalDataSource.insert`, `delete_schedule.dart` (molde de use case)
**Requirement**: SCHEDUI-12, SCHEDUI-14
**Complexidade**: Média

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `restoreSchedule` insere uma `ScheduleRow` com `id`, `scheduledDate`, `note`, `createdAt` e `completedAt` do agendamento recebido e o `userId` da conta atual
- [ ] Sem login → `AuthFailure('É preciso estar logado para usar a agenda.')` sem chamar o data source; `CacheException` → `CacheFailure`
- [ ] Testes no `schedule_repository_impl_test.dart` (linha inserida conferida campo a campo, inclusive `completedAt` preenchido), teste do `RestoreSchedule` e o bind registrado
- [ ] Gate check passes: `flutter analyze && flutter test`

**Tests**: unit
**Gate**: full
**Status**: [ ] pendente

---

### T7: Remoção otimista, restauração e chuva do dia no cubit

**What**: `ScheduleItem.expectedRainMm`; `removeSchedule` otimista com conjunto de ids ocultos; `restoreSchedule(FertilizationSchedule)`; bind do `RestoreSchedule` no cubit.
**Where**: `lib/features/schedule/presentation/cubit/schedule_cubit.dart`
**Depends on**: None (fase anterior concluída)
**Reuses**: `WeatherForecast.dayOf` (T5), `RestoreSchedule` (T6), `schedule_cubit_test.dart`
**Requirement**: SCHEDUI-07, SCHEDUI-10, SCHEDUI-12, SCHEDUI-13, SCHEDUI-14
**Complexidade**: Alta

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `expectedRainMm` = `precipitationSum` do dia para não concluído e não passado com o dia na previsão; senão `null`
- [ ] `removeSchedule` emite a lista sem o item **antes** de chamar o use case; falha → item de volta + `withActionFailure`; o id oculto é esquecido quando o stream deixa de trazê-lo e não esconde um item restaurado depois
- [ ] `restoreSchedule` chama `RestoreSchedule` com o agendamento exato; falha → `withActionFailure`
- [ ] `ScheduleModule` passa o `RestoreSchedule` ao cubit
- [ ] Testes `bloc_test` com a sequência exata de estados para cada item, incluindo excluir e restaurar o mesmo item em seguida
- [ ] Gate check passes: `flutter analyze && flutter test`

**Tests**: unit
**Gate**: full
**Status**: [ ] pendente

---

### T8: Bloco de data

**What**: `ScheduleDateBlock` com dia, mês abreviado, cor por status e pulso opcional.
**Where**: `lib/features/schedule/presentation/widgets/schedule_date_block.dart`
**Depends on**: None (fase anterior concluída)
**Reuses**: `AppColors`, `AppMotion`, `context.reduceMotion`
**Requirement**: SCHEDUI-05, SCHEDUI-06, SCHEDUI-20, SCHEDUI-21
**Complexidade**: Média

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] Mostra "23" e "SET" para 23/09 (mês em maiúsculas, sem ponto)
- [ ] Recebe a cor de fundo e a do texto; o pulso (escala e brilho em loop) só roda com `pulse: true` e sem redução de movimento; o controller é descartado ao trocar `pulse` para `false` e no `dispose`
- [ ] `RepaintBoundary` em volta da parte animada
- [ ] Widget tests: textos, pulso ativo (valor muda entre frames), pulso parado com `pulse: false` e com redução de movimento
- [ ] Gate check passes: `flutter test test/features/schedule/presentation/widgets/schedule_date_block_test.dart`

**Tests**: widget
**Gate**: quick
**Status**: [ ] pendente

---

### T9: Check desenhado

**What**: `AnimatedCheck` com `CustomPainter` e `PathMetric`.
**Where**: `lib/features/schedule/presentation/widgets/animated_check.dart`
**Depends on**: T8
**Reuses**: `AppMotion.medium`, `context.reduceMotion`
**Requirement**: SCHEDUI-08, SCHEDUI-09, SCHEDUI-19, SCHEDUI-21
**Complexidade**: Média

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] Marcar anima o progresso de 0 a 1 em `AppMotion.medium`; desmarcar de 1 a 0; com redução de movimento, o valor vai direto
- [ ] O traço do check é extraído com `PathMetric.extractPath(0, length * progress)`
- [ ] Alvo de toque de 48 x 48; `Semantics` com `checked` e ação de toque; `onChanged(bool)` chamado no toque
- [ ] Widget tests: progresso no meio da animação, estado final, redução de movimento, semântica, tamanho do alvo
- [ ] Gate check passes: `flutter test test/features/schedule/presentation/widgets/animated_check_test.dart`

**Tests**: widget
**Gate**: quick
**Status**: [ ] pendente

---

### T10: Card da agenda

**What**: Reescrever o `ScheduleTile` com o layout de bloco de data, conteúdo e check, a chuva em mm e a ação de acessibilidade "Excluir".
**Where**: `lib/features/schedule/presentation/widgets/schedule_tile.dart`
**Depends on**: T9
**Reuses**: `ScheduleDateBlock` (T8), `AnimatedCheck` (T9), transições implícitas atuais do card, `schedule_tile_test.dart`
**Requirement**: SCHEDUI-05, SCHEDUI-06, SCHEDUI-07, SCHEDUI-08, SCHEDUI-09, SCHEDUI-15
**Complexidade**: Média

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] Layout e cores da spec; dia da semana por extenso com inicial maiúscula; "12,3 mm previstos" só em risco (vírgula decimal pt_BR)
- [ ] Pulso do bloco só em não concluído em risco
- [ ] `Semantics` do card com dia da semana, data, status e observação; `customSemanticsActions` com "Excluir" chamando `onDelete`; sem `PopupMenuButton`
- [ ] Strings novas no `.arb` (chuva em mm com placeholder, rótulo da ação de excluir)
- [ ] Widget tests com `AppTheme`: cada cor de status, mm só em risco, concluído neutro, semântica e ação customizada
- [ ] Gate check passes: `flutter test test/features/schedule/presentation/widgets/schedule_tile_test.dart`

**Tests**: widget
**Gate**: quick
**Status**: [ ] pendente

---

### T11: Formulário em tela cheia com container transform

**What**: Transformar o `ScheduleFormSheet` em `ScheduleFormPage` e abri-lo com `OpenContainer` a partir do card (edição) e do botão "Agendar" (criação); adicionar a dependência `animations`.
**Where**: `lib/features/schedule/presentation/pages/schedule_form_page.dart`
**Depends on**: None (fase anterior concluída)
**Reuses**: `schedule_form_sheet.dart` (estado, validação, seletor), `schedule_form_sheet_test.dart` (cenários), `SchedulePage`
**Requirement**: SCHEDUI-17, SCHEDUI-18, SCHEDUI-21, SCHEDUI-22
**Complexidade**: Alta

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `animations: ^3.0.0` no `pubspec.yaml`; nenhum outro pacote muda de versão no lockfile
- [ ] `ScheduleFormPage` com as mesmas regras (janela da previsão via `currentWindow()`, `maxLength` 200, preenchimento na edição) devolvendo `ScheduleFormResult` pelo `pop`; `ScheduleFormSheet` e seu teste removidos, cenários migrados
- [ ] Card não concluído e FAB abrem o formulário por `OpenContainer`; `onClosed` chama `addSchedule` ou `editSchedule`; concluído não abre
- [ ] `transitionDuration` = `AppMotion.slow`, ou `Duration.zero` com redução de movimento
- [ ] Widget tests com `AppTheme`: cenários migrados do formulário, FAB abre criação, card abre edição preenchida, salvar chama o cubit, concluído não abre, redução de movimento
- [ ] Gate check passes: `flutter analyze && flutter test`

**Tests**: widget
**Gate**: build
**Status**: [ ] pendente

---

### T12: Excluir com swipe e Desfazer

**What**: `Dismissible` para a esquerda nos cards, snackbar com "Desfazer", ação de acessibilidade com o mesmo fluxo, snackbar escondido ao sair; remover o `_AnimatedScheduleTile`, o diálogo e as chaves `scheduleDeleteConfirm*`.
**Where**: `lib/features/schedule/presentation/pages/schedule_page.dart`
**Depends on**: T11
**Reuses**: `removeSchedule` e `restoreSchedule` (T7), `ScheduleTile.onDelete` (T10), `schedule_page_test.dart`
**Requirement**: SCHEDUI-10, SCHEDUI-11, SCHEDUI-12, SCHEDUI-13, SCHEDUI-15, SCHEDUI-16
**Complexidade**: Alta

**Tools**:

- MCP: NONE
- Skill: NONE

**Done when**:

- [ ] `Dismissible` com `direction: endToStart`, fundo `AppColors.danger` com ícone de lixeira e chave pelo id; vale para próximos e concluídos
- [ ] Ao excluir: `hideCurrentSnackBar`, `removeSchedule(id)` e `SnackBar("Agendamento excluído", action: "Desfazer" → restoreSchedule(schedule))` por 4 s
- [ ] Arrasto abaixo do limiar não exclui
- [ ] O snackbar é escondido no `dispose` da página, com o `ScaffoldMessenger` guardado em `didChangeDependencies`
- [ ] Saem `_AnimatedScheduleTile`, `_askDelete` e as chaves `scheduleDeleteConfirm*`; strings novas do snackbar no `.arb`
- [ ] Widget tests com `AppTheme` e cubit mockado: swipe completo chama `removeSchedule` e mostra o snackbar; Desfazer chama `restoreSchedule` com o agendamento exato; arrasto curto não exclui; ação de acessibilidade faz o mesmo fluxo; snackbar some ao sair da tela
- [ ] Gate check passes: `flutter analyze && flutter test`

**Tests**: widget
**Gate**: build
**Status**: [ ] pendente

---

## Phase Execution Map

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6

Phase 1:  T1 ------→ T2        (entregue)
Phase 2:  T3 ------→ T4        (entregue)
Phase 3:  T5 ------→ T6
Phase 4:  T7
Phase 5:  T8 ------→ T9 ------→ T10
Phase 6:  T11 -----→ T12
```

**Agrupamento por esforço** (o orquestrador escolhe o executor de cada nível):

| Grupo | Tasks | Complexidade |
| ----- | ----- | ------------ |
| 1 | T5 | Mecânica |
| 2 | T6 | Média |
| 3 | T7 | Alta |
| 4 | T8, T9, T10 | Média |
| 5 | T11, T12 | Alta |

---

## Task Granularity Check

| Task | Scope | Status |
| ---- | ----- | ------ |
| T5 | 1 método de entidade + troca de uso | ✅ |
| T6 | 1 operação de repositório + use case + bind | ⚠️ coeso: a operação só é testável com o use case |
| T7 | 1 cubit | ✅ |
| T8 | 1 widget | ✅ |
| T9 | 1 widget | ✅ |
| T10 | 1 widget | ✅ |
| T11 | 1 página + integração da transição | ⚠️ coeso: a transição só existe com a página |
| T12 | integração do gesto na página | ✅ |

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
| ---- | ---------------------- | ------------- | ------ |
| T1 | None | início | ✅ Match |
| T2 | T1 | T1 → T2 | ✅ Match |
| T3 | None (fase anterior) | início da Fase 2 | ✅ Match |
| T4 | T3 | T3 → T4 | ✅ Match |
| T5 | None (fase anterior) | início da Fase 3 | ✅ Match |
| T6 | T5 | T5 → T6 | ✅ Match |
| T7 | None (fase anterior) | Fase 4 | ✅ Match |
| T8 | None (fase anterior) | início da Fase 5 | ✅ Match |
| T9 | T8 | T8 → T9 | ✅ Match |
| T10 | T9 | T9 → T10 | ✅ Match |
| T11 | None (fase anterior) | início da Fase 6 | ✅ Match |
| T12 | T11 | T11 → T12 | ✅ Match |

---

## Test Co-location Validation

| Task | Code Layer Created/Modified | Matrix Requires | Task Says | Status |
| ---- | --------------------------- | --------------- | --------- | ------ |
| T5 | Entidade e use case | unit | unit | ✅ OK |
| T6 | Repositório, use case, DI | unit | unit | ✅ OK |
| T7 | Cubit | unit | unit | ✅ OK |
| T8 | Widget | widget | widget | ✅ OK |
| T9 | Widget | widget | widget | ✅ OK |
| T10 | Widget | widget | widget | ✅ OK |
| T11 | Página, dependência | widget | widget | ✅ OK |
| T12 | Página | widget | widget | ✅ OK |
