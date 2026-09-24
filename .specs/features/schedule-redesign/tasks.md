# Redesign da Agenda Tasks

## Execution Protocol (MANDATORY -- do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user - do not proceed without it.**

---

**Design**: `.specs/features/schedule-redesign/spec.md`
**Status**: Draft

---

## Test Coverage Matrix

> Generated from codebase, project guidelines, and spec - confirm before Execute. Guidelines found: none - strong defaults applied.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
| ---------- | ------------------ | -------------------- | ---------------- | ----------- |
| Presentation | unit | All branches; 1:1 to spec ACs; all listed edge cases | `test/features/schedule/presentation/**/*_test.dart` | `flutter test` |
| Entity / Config | none | - (build gate only) | - | build gate only |

## Gate Check Commands

> Generated from codebase - confirm before Execute.

| Gate Level | When to Use | Command |
| ---------- | ----------- | ------- |
| Quick | After tasks with unit tests only | `flutter test` |
| Full | After tasks with e2e/integration tests | `flutter test` |
| Build | After phase completion or config/entity-only tasks | `flutter analyze && flutter test` |

---

## Execution Plan

Phases are ordered and run sequentially - each phase completes before the next begins, and tasks within a phase execute in order.

### Phase 1: Foundation (Componente Animado Nativo)

Tasks that must be done first, in order.

```
T1 → T2
```

### Phase 2: Microinterações (Cards e Listas)

Builds on the foundation.

```
T3 → T4
```

---

## Task Breakdown

### T1: Criar Componente de Animação Nativa do Empty State

**What**: Criar o widget `ScheduleEmptyAnimation` contendo uma animação explícita (`AnimationController`, `AnimatedBuilder`) simulando a agenda (ex: um ícone de calendário com movimento pendular ou de scale loop).
**Where**: `lib/features/schedule/presentation/widgets/schedule_empty_animation.dart`
**Depends on**: None
**Reuses**: Padrões de `SingleTickerProviderStateMixin`.
**Requirement**: SCHEDUI-01

**Tools**:

- MCP: `filesystem`
- Skill: NONE

**Done when**:

- [x] Arquivo `schedule_empty_animation.dart` criado e widget desenhado com animação em loop.
- [x] O componente pausa a animação se `MediaQuery.disableAnimationsOf(context)` for true.
- [x] Gate check passes: `flutter analyze && flutter test`
- [x] Test count: 1 teste de widget para garantir renderização e resposta à acessibilidade de sistema.

**Tests**: unit
**Gate**: Quick

**Commit**: `feat(schedule): cria componente de animação nativa para agenda vazia`

---

### T2: Integrar Animação Nativa no Empty View

**What**: Alterar `_EmptyView` para renderizar o novo componente `ScheduleEmptyAnimation` em vez do ícone estático atual.
**Where**: `lib/features/schedule/presentation/pages/schedule_page.dart`
**Depends on**: T1
**Reuses**: Nenhum
**Requirement**: SCHEDUI-01, SCHEDUI-02

**Tools**:

- MCP: `filesystem`
- Skill: NONE

**Done when**:

- [x] `_EmptyView` exibe `ScheduleEmptyAnimation`.
- [x] Testes de widget do `SchedulePage` continuam passando e atestam que o estado vazio renderiza o novo componente.
- [x] Gate check passes: `flutter test`
- [x] Test count: Ajuste de testes de `ScheduleView` para cobrir os ACs de estado vazio animado.

**Tests**: unit
**Gate**: Quick

**Commit**: `feat(schedule): ilustra a agenda vazia com animação nativa`

---

### T3: Animações de Conclusão no Cartão

**What**: Adicionar microinterações ao concluir um agendamento no `ScheduleTile` usando `AnimatedDefaultTextStyle`, `AnimatedOpacity` e `AnimatedSize` / transição implícita.
**Where**: `lib/features/schedule/presentation/widgets/schedule_tile.dart`
**Depends on**: None
**Reuses**: Flutter implicit animations (`AnimatedTheme`, `AnimatedOpacity`).
**Requirement**: SCHEDUI-03

**Tools**:

- MCP: `filesystem`
- Skill: NONE

**Done when**:

- [x] A mudança de estado (concluído para não concluído) ocorre de forma animada (cross-fade, encolhimento de label).
- [x] Testes de widget garantem que a marcação/desmarcação ainda emite os eventos no `onToggleCompleted` corretamente e reflete a UI.
- [x] Gate check passes: `flutter test`
- [x] Test count: Testes de widget validam que as animações iniciam ou estão presentes na árvore.

**Tests**: unit
**Gate**: Quick

**Commit**: `feat(schedule): anima a conclusão e reabertura dos itens`

---

### T4: Animações de Inserção e Remoção na Lista

**What**: Integrar animação de exclusão nos itens da lista em `_ScheduleSections` para que não sumam bruscamente.
**Where**: `lib/features/schedule/presentation/pages/schedule_page.dart`
**Depends on**: T3
**Reuses**: `AnimatedSize` ou `SliverAnimatedList` se viável, mantendo a responsividade do BlocBuilder.
**Requirement**: SCHEDUI-04

**Tools**:

- MCP: `filesystem`
- Skill: NONE

**Done when**:

- [x] Ao remover um agendamento, ele colapsa suavemente (ou faz fade-out) ao invés de sumir bruscamente.
- [x] A entrada de novos agendamentos faz fade/slide in (pode reutilizar `FadeSlideIn` já existente ou ajustar para listas dinâmicas).
- [x] Testes de widget atestam que itens aparecem/desaparecem corretamente na árvore sem quebrar o layout.
- [x] Gate check passes: `flutter test`
- [x] Test count: Atualização de testes para assegurar integridade da lista.

**Tests**: unit
**Gate**: Quick

**Commit**: `feat(schedule): anima a inserção e remoção de agendamentos na lista`

---

## Phase Execution Map

```
Phase 1 → Phase 2

Phase 1:  T1 ------→ T2
Phase 2:  T3 ------→ T4
```

---

## Task Granularity Check
| Task                            | Scope         | Status       |
| ------------------------------- | ------------- | ------------ |
| T1: Criar Animação Nativa       | 1 widget      | ✅ Granular  |
| T2: Integrar no Empty View      | 1 widget      | ✅ Granular  |
| T3: Animações de Conclusão      | 1 widget      | ✅ Granular  |
| T4: Animações de Lista          | 1 view logic  | ✅ Granular  |

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
| ---- | ---------------------- | ------------- | ------ |
| T1   | None                   | T1            | ✅ Match |
| T2   | T1                     | T1 → T2       | ✅ Match |
| T3   | None                   | T3            | ✅ Match |
| T4   | T3                     | T3 → T4       | ✅ Match |

---

## Test Co-location Validation

| Task | Code Layer Created/Modified | Matrix Requires | Task Says | Status |
| ---- | --------------------------- | --------------- | --------- | ------ |
| T1   | Presentation                | unit            | unit      | ✅ OK  |
| T2   | Presentation                | unit            | unit      | ✅ OK  |
| T3   | Presentation                | unit            | unit      | ✅ OK  |
| T4   | Presentation                | unit            | unit      | ✅ OK  |
