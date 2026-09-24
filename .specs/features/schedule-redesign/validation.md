## Validation: schedule-redesign - PASS ✅

**Iteração**: 2 de 3 (re-verificação das lacunas da iteração 1)
**Date**: 2026-09-24
**Spec**: `.specs/features/schedule-redesign/spec.md`
**Diff range**: `35ee4c5..HEAD` (9ae9891) + working tree não commitado (T11/T12 e as correções de teste desta iteração; código de produção igual ao da iteração 1)
**Verifier**: sub-agente independente (autor ≠ verificador)

Escopo desta iteração: só as 7 correções pedidas na iteração 1. As evidências dos 15 requisitos que já batiam (SCHEDUI-02, 04, 05, 07, 08, 10–18, 21, 22) e os mutantes M1–M5 mortos continuam valendo e não foram refeitos (ver o histórico abaixo).

---

### Task Completion

| Task | Status | Notes |
| ---- | ------ | ----- |
| T1–T10 | ✅ Done | Commits (inalterado desde a iteração 1) |
| T11 | ✅ Feito no working tree | Done-when agora pede `animations: ^2.2.0` com o motivo (`tasks.md:357`), igual ao `pubspec.yaml:78-82`; Tech Decisions do `design.md:116` diz 2.x com o mesmo motivo. Caixas `[ ]` serão marcadas no commit (orquestrador) |
| T12 | ✅ Feito no working tree | Idem: marcação no commit |

---

### Spec-Anchored Acceptance Criteria (lacunas da iteração 1)

| Req | Spec-defined outcome | `file:line` + assertion | Result |
| --- | -------------------- | ----------------------- | ------ |
| SCHEDUI-01 | Lista vazia mostra o estado vazio com o componente animado | `test/features/schedule/presentation/pages/schedule_page_test.dart:190` - `expect(find.byType(ScheduleEmptyAnimation), findsOneWidget)` no estado `loaded` vazio, junto do texto (`:183-186`). Animação em si: `schedule_empty_animation_test.dart:24-25` (iteração 1) | ✅ PASS |
| SCHEDUI-03 | Marcar/desmarcar anima a mudança de estilo do card com animações implícitas | `test/features/schedule/presentation/widgets/schedule_tile_test.dart:401-405` - estado inicial `color == onSurface`, sem `lineThrough`; após trocar para concluído e `pump(AppMotion.medium ~/ 2)`: `:420-421` - `midColor` `isNot(onSurface)` e `isNot(onSurfaceVariant)` (quadro intermediário, não troca seca); `:424-425` - final `onSurfaceVariant` e `TextDecoration.lineThrough`. Implementação: `AnimatedDefaultTextStyle` em `lib/features/schedule/presentation/widgets/schedule_tile.dart:190-198`. O caminho inverso (desmarcar) usa o mesmo widget implícito e não tem teste próprio; `AnimatedSize` da linha de status não é asserido | ✅ PASS (resíduo menor anotado) |
| SCHEDUI-06 | Sem previsão: neutro `surfaceContainerHigh` | `schedule_tile_test.dart:170` - `expect(block.background, colors.surfaceContainerHigh)`; `:171` - `expect(block.foreground, colors.onSurfaceVariant)`; `:172` - `pulse` falso. Demais cores já cobertas na iteração 1 (`:94` safe, `:115` danger, caution, concluído `:287,291`). M8 agora morre | ✅ PASS |
| SCHEDUI-09 | Controle exposto como checkbox marcado ou desmarcado | `test/features/schedule/presentation/widgets/animated_check_test.dart:217` - `isChecked == CheckedState.isTrue` com `value: true`; `:226` - `isChecked == CheckedState.isFalse` com `value: false` | ✅ PASS |
| SCHEDUI-19 | Check desenhado progressivamente em `AppMotion.medium`; apagado no mesmo tempo | Traço: `animated_check_test.dart:167-168` - `midPixels > 0` e `midPixels < finalPixels` (pixels na cor `onPrimary` rasterizados do `paint` real aos 150 ms e no fim; helper `:58-75`). Duração: `:184-185` - progresso `< 1` em `AppMotion.medium - 1ms`; `:187-188` - `== 1` exatamente em `AppMotion.medium`. Apagar: `:129-135` (iteração 1) - progresso em `(0,1)` aos 150 ms e 0 no fim; mesmo `AnimationController` com `duration: AppMotion.medium` e sem `reverseDuration` (`lib/features/schedule/presentation/widgets/animated_check.dart:33-35`). M7 agora morre | ✅ PASS |
| SCHEDUI-20 | Pulso só em não concluído em risco | `schedule_tile_test.dart:257-268` - concluído com `ScheduleRiskLevel.atRisk`: `expect(dateBlockOf(tester).pulse, isFalse)`; risco não concluído pulsa `:117` (iteração 1). M6 agora morre | ✅ PASS |

**Demais requisitos**: SCHEDUI-02, 05, 07, 08, 10–18, 21, 22 ✅ PASS conforme a iteração 1 (evidências abaixo, não refeitas); SCHEDUI-04 ⚠️ spec-precision gap ("sem pulo brusco" não mensurável), aceito como coberto pelo swipe de SCHEDUI-10, como na iteração 1.

**Status**: ✅ 22/22 cobertos · ⚠️ 1 spec-precision gap (SCHEDUI-04), herdado e aceito

---

### Discrimination Sensor

Cópia isolada: `git worktree add --detach` em HEAD dentro do scratchpad da sessão, com os arquivos do working tree copiados (lib e testes de T11/T12, `pubspec.*`, `.arb`); `flutter pub get --offline`. Baseline verde (59 testes de tile, check e page). Só os testes afetados: `schedule_tile_test.dart`, `animated_check_test.dart`, `schedule_page_test.dart`.

| # | File:line | Mutação | Killed? |
| - | --------- | ------- | ------- |
| M6 | `lib/features/schedule/presentation/widgets/schedule_tile.dart:79-81` | Remove `!isCompleted &&` do `pulse` | ✅ Killed (`SCHEDUI-20: concluído em risco não pulsa mais`) |
| M7 | `lib/features/schedule/presentation/widgets/animated_check.dart:140` | `extractPath(0, metric.length)` (ignora o progresso) | ✅ Killed (`SCHEDUI-19: o traço desenhado cresce com o progresso`) |
| M8 | `schedule_tile.dart:157-158` | "Sem previsão" com `AppColors.safe` / `Colors.white` | ✅ Killed (`SCHEDUI-05/06: sem previsão usa o neutro`) |

**Sensor depth**: lightweight (os 3 sobreviventes da iteração 1, orçamento do orquestrador)
**Result**: 3/3 killed nesta iteração; acumulado 8/8 (M1–M5 da iteração 1) - PASS ✅
**Isolamento**: worktree removido e podado; `git status --porcelain` do projeto idêntico ao baseline capturado antes do sensor.

---

### Code Quality (correções)

| Principle | Status |
| --------- | ------ |
| Só testes e docs mudaram; produção intocada | ✅ |
| Nenhuma asserção enfraquecida (o `pulse` falso de "sem previsão" foi mantido em `:172`) | ✅ |
| Spec-anchored outcome check | ✅ valores asseridos batem com a spec (tokens de tema, `AppMotion.medium`, `CheckedState`) |
| Testes mapeiam para requisitos (nomes com o id SCHEDUI) | ✅ |
| Padrões do projeto (`AppTheme.light` real, `FakeAccessibilityFeatures`, acesso ao painter privado via `dynamic` como o `progressOf` já fazia) | ✅ |

---

### Gate Check

- **Gate command**: `flutter analyze && flutter test`
- **Result**: analyze "No issues found!"; 382 passed, 0 failed, 0 skipped (exit 0)
- **Test count iteração 1**: 377 casos executados
- **Test count iteração 2**: 382 casos executados
- **Delta**: +5 (SCHEDUI-03 transição, SCHEDUI-20 concluído em risco, SCHEDUI-19 traço, SCHEDUI-19 duração, SCHEDUI-09 desmarcado); SCHEDUI-01 e SCHEDUI-06 reforçaram testes existentes
- **Skipped tests**: nenhum
- **Failures**: nenhuma

---

### Requirement Traceability Update

Aplicado ao `spec.md`: SCHEDUI-01 a SCHEDUI-22 → `✅ Verified` (SCHEDUI-04 com o spec-precision gap anotado aqui).

---

### Summary

**Overall**: ✅ Ready

**Spec-anchored check**: 22/22 casados com o resultado da spec; 1 spec-precision gap herdado (SCHEDUI-04)
**Sensor**: 3/3 mortos nesta iteração (8/8 acumulado)
**Gate**: 382 passed, analyze limpo

**Resíduos menores (não bloqueiam)**: SCHEDUI-03 sem teste do caminho inverso (desmarcar) nem do `AnimatedSize`; SCHEDUI-04 depende do `resizeDuration` padrão do `Dismissible`, sem asserção; caixas de T11/T12 no `tasks.md` só serão marcadas no commit.

---

## Iteração 1 (histórico) - FAIL ❌, superada pela iteração 2

**Date**: 2026-09-24
**Spec**: `.specs/features/schedule-redesign/spec.md`
**Diff range**: `35ee4c5..HEAD` (9ae9891) + working tree não commitado (T11 e T12: `schedule_form_page.dart` e teste, remoção de `schedule_form_sheet.dart` e teste, `schedule_page.dart`, `schedule_page_test.dart`, `app_pt.arb`, `pubspec.yaml`/`pubspec.lock`)
**Verifier**: sub-agente independente (autor ≠ verificador)

---

### Task Completion

| Task | Status | Notes |
| ---- | ------ | ----- |
| T1–T4 | ✅ Done | Commits b46700f, a126503, f1b0106, 54b7c48 (outro agente); T4 substituído pelo swipe |
| T5–T10 | ✅ Done | Commits 4fe0e54..9ae9891 |
| T11 | ⚠️ Feito no working tree | `tasks.md` ainda marca `[ ] pendente`; Done-when pede `animations: ^3.0.0`, o `pubspec.yaml:78-82` usa `^2.2.0` com justificativa (3.x depende do `material_ui`); `design.md` (Tech Decisions) ainda diz 3.x. Lockfile só acrescenta `animations 2.2.0` |
| T12 | ⚠️ Feito no working tree | `tasks.md` ainda marca `[ ] pendente` |

---

### Spec-Anchored Acceptance Criteria

| Req | Spec-defined outcome | `file:line` + assertion | Result |
| --- | -------------------- | ----------------------- | ------ |
| SCHEDUI-01 | Lista vazia mostra o estado vazio **com o componente animado** | Componente: `test/features/schedule/presentation/widgets/schedule_empty_animation_test.dart:24-25` - `expect(tester.hasRunningAnimations, isTrue)`. Página: `test/features/schedule/presentation/pages/schedule_page_test.dart:169-190` só confere o texto; nenhum teste procura `ScheduleEmptyAnimation` na página (implementação em `lib/features/schedule/presentation/pages/schedule_page.dart:390`) | ❌ GAP (integração sem evidência) |
| SCHEDUI-02 | Redução de movimento → componente parado | `schedule_empty_animation_test.dart:31-36` - `expect(tester.hasRunningAnimations, isFalse)` | ✅ PASS |
| SCHEDUI-03 | Marcar/desmarcar anima o estilo do card com animações implícitas | Nenhuma asserção. f1b0106 não trouxe teste; `schedule_tile_test.dart` não verifica `AnimatedDefaultTextStyle`/`AnimatedSize` nem quadro intermediário (implementação em `lib/features/schedule/presentation/widgets/schedule_tile.dart:190-216`) | ❌ GAP (zero evidência) |
| SCHEDUI-04 | Saída sem pulo brusco (substituído pelo swipe) | `schedule_page_test.dart:564-579` - `expect(cardOf(upcomingTarget), findsNothing)` após o swipe; o colapso vem do `resizeDuration` padrão do `Dismissible` (`schedule_page.dart:188-192`), não asserido. Pela ação de acessibilidade o item some sem animação | ⚠️ Spec-precision gap ("sem pulo brusco" não mensurável); aceito como coberto pelo swipe conforme o orquestrador |
| SCHEDUI-05 | Bloco com "23" e "SET"; dia da semana por extenso; observação; rótulo | `schedule_date_block_test.dart:56-57` - `find.text('23')`, `find.text('SET')`; `schedule_tile_test.dart:214` - `find.text('Quarta-feira')`; `:186` - `find.text('talhão 3')`; `:78` - `find.text('Previsão favorável')` | ✅ PASS |
| SCHEDUI-06 | Favorável `safe`, risco `danger`, passada `caution`, sem previsão e concluído `surfaceContainerHigh` | `schedule_tile_test.dart:79` `AppColors.safe`; `:100` `AppColors.danger`; `:172` `AppColors.caution`; `:250-253` concluído `surfaceContainerHigh`. **Sem previsão**: `:139-154` só confere rótulo e `pulse`, não a cor (mutante M8 sobreviveu) | ❌ GAP parcial (cor de "sem previsão") |
| SCHEDUI-07 | Em risco não concluído: "X,X mm previstos" | `schedule_tile_test.dart:99` - `find.text('12,3 mm previstos')` (12.34); `:118`, `:135`, `:232` ausente sem chuva, sem risco e concluído; cubit `schedule_cubit_test.dart:759-843` (`rainMm` do dia, nulo para concluído/passado/fora); `weather_forecast_test.dart:34-35,61,74` (`dayOf`) | ✅ PASS |
| SCHEDUI-08 | Controle à direita, alvo ≥ 48 x 48 | `animated_check_test.dart:131-132` - `greaterThanOrEqualTo(48)`; toque `schedule_tile_test.dart:327,346` - `toggledTo` true/false | ✅ PASS |
| SCHEDUI-09 | Card com dia da semana, data, status e observação; controle como checkbox marcado **ou desmarcado** | `schedule_tile_test.dart:365-368` - label contém 'Quarta-feira', 'setembro de 2026', 'Previsão favorável', 'talhão 3'; `animated_check_test.dart:122` - `isChecked == CheckedState.isTrue`. Estado desmarcado (`CheckedState.isFalse`) não asserido | ❌ GAP parcial (desmarcado) |
| SCHEDUI-10 | Swipe à esquerda além do limiar tira o card na hora e exclui | `schedule_page_test.dart:573-574` - `verify(removeSchedule('s1')).called(1)`, card `findsNothing`; `:590` `DismissDirection.endToStart`; `:604-607` fundo `AppColors.danger`; `schedule_cubit_test.dart:890-894` - `expect: [both, onlyLater]`, `stateWhenDeleteCalled == onlyLater` (emite antes do use case) | ✅ PASS |
| SCHEDUI-11 | Snackbar "Agendamento excluído" + "Desfazer" por 4 s | `schedule_page_test.dart:575-576` textos; `:732` - `snackBar.duration == Duration(seconds: 4)`; `:734-739` visível aos 3 s e some aos 4 s | ✅ PASS |
| SCHEDUI-12 | Desfazer restaura o mesmo id, data, observação, criação e conclusão | `schedule_page_test.dart:626` - `expect(restored, same(upcomingTarget))`; `:647` concluído por igualdade; `schedule_cubit_test.dart:1100` - `verify(restoreSchedule(deleted))` com `completedAt`; `schedule_repository_impl_test.dart:416-428` - `local.insert(ScheduleRow(id, userId, scheduledDate, note, createdAt, completedAt))` | ✅ PASS |
| SCHEDUI-13 | Falha ao excluir devolve o card e mostra o erro | `schedule_cubit_test.dart:966-971` - `[both, onlyLater, both, both.withActionFailure(writeFailure)]`; `schedule_page_test.dart:831-834` - snackbar da falha | ✅ PASS |
| SCHEDUI-14 | Falha ao restaurar mostra o erro | `schedule_cubit_test.dart:1113` - `[loaded, loaded.withActionFailure(writeFailure)]`; repositório `:440-443` `AuthFailure`, `:456+` `CacheFailure` | ✅ PASS |
| SCHEDUI-15 | Ação de acessibilidade "Excluir" com o mesmo snackbar e Desfazer | `schedule_tile_test.dart:387-400` - `CustomSemanticsAction` 'Excluir' → `deleted == true`; `schedule_page_test.dart:690-701` - `removeSchedule('s1')`, snackbar, sem `AlertDialog`, `same(upcomingTarget)` | ✅ PASS |
| SCHEDUI-16 | Fechar a Agenda esconde o snackbar | `schedule_page_test.dart:782-784` e `:806` - 'Agendamento excluído' e 'Desfazer' `findsNothing` após o `pop` (inclusive com navegação acessível) | ✅ PASS |
| SCHEDUI-17 | Card não concluído expande em tela cheia e fecha no caminho inverso | `schedule_page_test.dart:449-456` - `transitionDuration == AppMotion.slow`, animação em `(0,1)`, rect ≠ tela e depois = tela; `:305-313`, `:360-369` edição preenchida chama `editSchedule`; `:425` concluído não abre. Fechamento reverso é do próprio `OpenContainer` (não asserido à parte) | ✅ PASS |
| SCHEDUI-18 | "Agendar" abre criação com a mesma transição | `schedule_page_test.dart:478-479` - `transitionDuration == AppMotion.slow`, animação em `(0,1)`; `:214-216` `addSchedule(window.first, note: 'talhão 3')`; `:342-343` fechar sem salvar não cria | ✅ PASS |
| SCHEDUI-19 | Check desenhado progressivamente em `AppMotion.medium`; apagado no mesmo tempo | `animated_check_test.dart:66-71` e `:89-94` - progresso em `(0,1)` aos 150 ms e 1/0 no fim. Só o campo `progress` do painter é lido: o traço real (`extractPath`) não é verificado (M7 sobreviveu) e a duração `AppMotion.medium` não é fixada (uma duração maior também passaria) | ❌ GAP parcial |
| SCHEDUI-20 | Pulso em loop só em não concluído em risco | `schedule_date_block_test.dart:66-72` escala muda entre quadros; `:82-83` sem pulso; `schedule_tile_test.dart:102` `pulse` true em risco. Concluído **em risco** não confere `pulse` (`:219-234`); M6 sobreviveu | ❌ GAP parcial |
| SCHEDUI-21 | Redução de movimento: check completo sem traçado, bloco sem pulso, formulário sem transição | `animated_check_test.dart:111-112` - progresso 1 e sem animação; `schedule_date_block_test.dart:93-94`; `schedule_page_test.dart:497` - `transitionDuration == Duration.zero`, `:509-517` rota `completed` no primeiro quadro e `dismissed` ao fechar | ✅ PASS |
| SCHEDUI-22 | Mesmas regras: janela, observação ≤ 200, preenchimento na edição | `schedule_form_page_test.dart:61-62` `firstDate/lastDate == window`; `:148,154` `maxLength == ScheduleNote.maxLength`; `:227-235` edição preenchida; `:182` observação em branco vira `null`; `:191-202` cancelar/voltar devolvem `null` | ✅ PASS |

**Status**: ❌ Gaps presentes (SCHEDUI-01, 03, 06, 09, 19, 20) · ⚠️ 1 spec-precision gap (SCHEDUI-04)

---

### Edge Cases

- [x] Swipe num concluído exclui com o mesmo Desfazer - `schedule_page_test.dart:640-647`
- [x] Duas exclusões seguidas: só o snackbar do último; a primeira fica confirmada - `schedule_page_test.dart:714-720` (`restoreSchedule(completedTarget)` 1x, `verifyNever(restoreSchedule(upcomingTarget))`)
- [x] Arrasto abaixo do limiar devolve o card - `schedule_page_test.dart:660-662` (M4 morto)
- [x] Restaurado volta na posição da ordenação - `schedule_cubit_test.dart:1092-1099` (vai para `completed` pela ordenação do stream)

---

### Discrimination Sensor

Cópia isolada: `git worktree add --detach` em HEAD + arquivos do working tree copiados; `flutter pub get --offline` (lockfile idêntico); baseline verde (139 testes afetados). Só os testes afetados por mutante.

| # | File:line | Mutação | Testes | Killed? |
| - | --------- | ------- | ------ | ------- |
| M1 | `lib/features/schedule/presentation/cubit/schedule_cubit.dart:119-122` | Chama `_deleteSchedule` antes de ocultar e emitir | cubit | ✅ Killed (`emite a lista sem o item antes de chamar o use case`) |
| M2 | `schedule_cubit.dart:141` | Desfazer não espera a exclusão pendente | cubit | ✅ Killed (2 testes) |
| M3 | `lib/features/schedule/presentation/pages/schedule_page.dart:96` | Desfazer restaura uma cópia sem `completedAt` | page | ✅ Killed (4 testes) |
| M4 | `schedule_page.dart:190` | `dismissThresholds` 0.05 para `endToStart` | page | ✅ Killed (`arrasto abaixo do limiar`) |
| M5 | `schedule_page.dart:240` | `transitionDuration` = `AppMotion.slow` mesmo com redução de movimento | page | ✅ Killed (`SCHEDUI-21`) |
| M6 | `lib/features/schedule/presentation/widgets/schedule_tile.dart:79-81` | Remove `!isCompleted &&` do `pulse` | tile + page | ❌ Survived |
| M7 | `lib/features/schedule/presentation/widgets/animated_check.dart:140` | `extractPath(0, metric.length)` (ignora o progresso) | check + tile | ❌ Survived |
| M8 | `schedule_tile.dart:157-158` | Bloco de "sem previsão" com `AppColors.safe` | tile + page | ❌ Survived |

**Sensor depth**: lightweight ampliado (8, orçamento do orquestrador)
**Resultado**: 5/8 killed - FAIL ❌
**Isolamento**: worktree removido; `git status --porcelain` idêntico ao baseline.

---

### Code Quality

| Principle | Status |
| --------- | ------ |
| Minimum code | ✅ |
| Surgical changes | ✅ (`dashboard_page.dart` no diff é do outro agente, fora do escopo auditado) |
| No scope creep | ✅ |
| Matches patterns | ✅ (`context.reduceMotion`, `AppMotion`, textos no `.arb`, `AppTheme` real nos testes de widget) |
| Spec-anchored outcome check | ❌ SCHEDUI-06, 09, 19, 20 asserem só parte do resultado |
| Per-layer Coverage Expectation | ⚠️ Cubit e repositório 1:1; widgets sem cobertura de SCHEDUI-03 e da integração de SCHEDUI-01 |
| Every test maps to a spec requirement | ✅ (testes AGD-* são regras anteriores da Agenda mantidas) |
| Documented guidelines followed | ✅ regras de `tasks.md` (Execution Protocol) |

---

### Gate Check

- **Gate command**: `flutter analyze && flutter test`
- **Result**: analyze "No issues found!"; 377 passed, 0 failed, 0 skipped
- **Test count before feature (35ee4c5)**: 256 declarações de teste (contagem estática) 
- **Test count after feature**: 317 declarações de teste; 377 casos executados
- **Delta**: +61 declarações; `schedule_form_sheet_test.dart` removido com cenários migrados e ampliados em `schedule_form_page_test.dart` (9 → 12 casos)
- **Skipped tests**: nenhum
- **Failures**: nenhuma

---

### Fix Plans

### Fix 1: SCHEDUI-03 sem teste (Major)
- **Root cause**: f1b0106 adicionou as animações implícitas sem teste; T10 manteve-as sem cobrir.
- **Fix task**: em `schedule_tile_test.dart`, trocar o `item` de não concluído para concluído com `pumpWidget` e, após `pump(AppMotion.medium ~/ 2)`, asserir que a cor/decoração do título ainda está em transição (ou que `AnimatedDefaultTextStyle`/`AnimatedSize` estão na árvore com `AppMotion.medium`) e, após `pumpAndSettle`, `TextDecoration.lineThrough`.
- **Priority**: Major

### Fix 2: SCHEDUI-01 integração na página (Minor)
- **Fix task**: em `schedule_page_test.dart:169-190`, `expect(find.byType(ScheduleEmptyAnimation), findsOneWidget)`.
- **Priority**: Minor

### Fix 3: SCHEDUI-19 traço e duração (Minor)
- **Fix task**: em `animated_check_test.dart`, asserir o comprimento do traço desenhado (ex.: `paints` do `flutter_test` com o path, ou expor o comprimento extraído) proporcional ao progresso; e fixar a duração: aos `AppMotion.medium` o progresso já é 1 sem `pumpAndSettle`.
- **Priority**: Minor

### Fix 4: SCHEDUI-06 cor de "sem previsão" (Minor)
- **Fix task**: em `schedule_tile_test.dart:139-154`, `expect(block.background, colorScheme.surfaceContainerHigh)` e `foreground` `onSurfaceVariant`.
- **Priority**: Minor

### Fix 5: SCHEDUI-20 concluído em risco não pulsa (Minor)
- **Fix task**: em `schedule_tile_test.dart:219-234` (concluído com `atRisk`), `expect(dateBlockOf(tester).pulse, isFalse)`.
- **Priority**: Minor

### Fix 6: SCHEDUI-09 checkbox desmarcado (Minor)
- **Fix task**: em `animated_check_test.dart`, caso com `value: false` e `isChecked == CheckedState.isFalse`.
- **Priority**: Minor

### Fix 7: documentação de T11/T12 (Cosmetic)
- **Fix task**: marcar T11/T12 como feitos no commit; registrar a troca `animations ^3.0.0` → `^2.2.0` no Done-when de T11 e em Tech Decisions do `design.md`.
- **Priority**: Cosmetic

---

### Requirement Traceability Update

Não aplicada ao `spec.md` (veredito FAIL; o orquestrador pediu atualização só em PASS).

| Requirement | Previous Status | Proposed Status |
| ----------- | --------------- | --------------- |
| SCHEDUI-02, 05, 07, 08, 10–18, 21, 22 | Implemented / In Tasks | ✅ Verified (após o re-verify) |
| SCHEDUI-04 | Implemented (substituído) | ✅ Verified via SCHEDUI-10, com spec-precision gap |
| SCHEDUI-01, 03, 06, 09, 19, 20 | Implemented / In Tasks | ❌ Needs Fix (só testes) |

---

### Summary

**Overall**: ❌ Not Ready (comportamento implementado; faltam asserções)

**Spec-anchored check**: 15/22 casados com o resultado da spec; 6 gaps (1 sem evidência, 5 parciais); 1 spec-precision gap
**Sensor**: 5/8 mortos
**Gate**: 377 passed, analyze limpo

**What works**: remoção otimista antes do use case, Desfazer esperando a exclusão pendente, restauração do agendamento exato (página, cubit e repositório), limiar e direção do swipe, snackbar de 4 s e escondido ao sair, container transform com `Duration.zero` em redução de movimento, formulário em tela cheia com as regras antigas.

**Issues found**: todos são testes fracos ou ausentes; nenhum defeito de comportamento observado no código lido.

**Next steps**: Fixes 1–6 (só testes), Fix 7 (docs), depois re-verify.
