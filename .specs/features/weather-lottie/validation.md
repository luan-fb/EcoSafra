# weather-lottie Validation

**Date**: 2026-09-18
**Spec**: `.specs/features/weather-lottie/spec.md`
**Diff range**: uncommitted working tree sobre `7fe379d` (HEAD). Arquivos da feature: `pubspec.yaml`, `pubspec.lock`, `assets/lottie/{sunny,cloudy,rainy}.json`, `lib/features/weather/presentation/weather_animation.dart`, `lib/features/weather/presentation/weather_condition.dart`, `lib/features/weather/presentation/widgets/weather_animation_view.dart`, `lib/features/dashboard/presentation/widgets/now_weather_card.dart`, `lib/features/dashboard/presentation/pages/dashboard_page.dart`, `test/features/weather/presentation/weather_condition_test.dart`, `test/features/weather/presentation/widgets/weather_animation_view_test.dart`, `test/features/dashboard/presentation/widgets/now_weather_card_test.dart`. A feature schedule/Firestore, também não commitada, ficou fora do escopo.
**Verifier**: sub-agente independente (autor ≠ verificador)
**Iteração**: 2 de 3 (re-verificação depois do Fix 1 e do Fix 2 da iteração 1)

**Verdict**: PASS ✅

---

## Task Completion

Não existe `tasks.md`. A verificação foi ancorada nos ACs do `spec.md`. Os fixes da iteração 1 foram aplicados:

| Fix | Status | Notes |
| --- | ------ | ----- |
| Fix 1: interior das faixas (WLOT-03) | ✅ Done | Varredura 0..99 contra as listas da spec, montadas no próprio teste |
| Fix 2: card "Agora" e rótulo (WLOT-05/09) | ✅ Done | Card extraído para `NowWeatherCard`, com teste de widget próprio |

---

## Spec-Anchored Acceptance Criteria

| Criterion | Spec-defined outcome | `file:line` + assertion | Result |
| --------- | -------------------- | ----------------------- | ------ |
| WLOT-01: código 0 → sunny | `WeatherAnimation.sunny` | `test/features/weather/presentation/weather_condition_test.dart:69` + `:101` `expect(WeatherCondition.animationFor(code), expected)`; varredura `:110`, `:126-130` | ✅ PASS |
| WLOT-02: 1, 2, 3, 45, 48, 71–77, 85, 86 → cloudy | `WeatherAnimation.cloudy` | `weather_condition_test.dart:71-79` + `:101`; varredura 0..99 `:119-131` (tudo fora de sunny/rainy → cloudy) | ✅ PASS |
| WLOT-03: 51–57, 61–67, 80–82, 95, 96, 99 → rainy | `WeatherAnimation.rainy` para todo código das faixas | `weather_condition_test.dart:111-118` (conjunto `rainy` montado das faixas da spec) + `:126-130` `expect(WeatherCondition.animationFor(code), expected, reason: 'código $code')` | ✅ PASS (M11 e M12 agora são mortos) |
| WLOT-04: código desconhecido → cloudy | `WeatherAnimation.cloudy` | `weather_condition_test.dart:92-96` (-1, 4, 50, 58, 100) + `:101` | ✅ PASS |
| WLOT-05: card "Agora" renderiza o Lottie do código de hoje, no lugar do ícone | `WeatherAnimationView(weatherCode)` com asset `assets/lottie/<anim>.json`; sem `Icon(iconFor)` | Card: `test/features/dashboard/presentation/widgets/now_weather_card_test.dart:49` `expect(view.weatherCode, 0)`; `:51` `expect(find.byIcon(WeatherCondition.iconFor(0)), findsNothing)`. Asset: `test/features/weather/presentation/widgets/weather_animation_view_test.dart:56` `expect(assetOf(lottieIn(tester)), expected.assetPath)`; JSON válido `:66` | ✅ PASS (veja o risco residual M18) |
| WLOT-06: loop contínuo sem redução de movimento | `animate: true`, `repeat: true` | `weather_animation_view_test.dart:76-77` | ✅ PASS |
| WLOT-07: parada com `disableAnimations` | `animate: false` | `weather_animation_view_test.dart:84` `expect(lottieIn(tester).animate, isFalse)` | ✅ PASS |
| WLOT-08: falha no asset → `iconFor` do mesmo código | `Icon(WeatherCondition.iconFor(61))` | `weather_animation_view_test.dart:93` `expect(find.byIcon(WeatherCondition.iconFor(61)), findsOneWidget)` | ✅ PASS |
| WLOT-09: leitor de tela recebe `labelFor`, não a animação | rótulo "Céu limpo" exposto; animação sem rótulo próprio | Rótulo: `now_weather_card_test.dart:64-65` `find.bySemanticsLabel(RegExp(r'^Céu limpo$', multiLine: true))` `findsOneWidget`. Animação silenciosa: `weather_animation_view_test.dart:105` `expect(node.label, isEmpty)` | ✅ PASS |
| WLOT-10: cross-fade na troca | as duas animações coexistem em `FadeTransition` e depois fica só a nova | `weather_animation_view_test.dart:119-125`, `:126-132`, `:137-140` | ✅ PASS |
| WLOT-11: mesma animação não reinicia | mesmo `State` | `weather_animation_view_test.dart:152-153` `same(before)` | ✅ PASS |

**Status**: ✅ Todos os ACs cobertos com asserção no resultado exigido pela spec

### Avaliação do matcher de WLOT-09

O `Card` é um semantic container, e o Flutter junta os textos filhos num nó só ("Agora\n28°\nCéu limpo\n…"). É esse nó que o TalkBack e o VoiceOver leem. A spec exige que o rótulo seja **exposto** ao leitor de tela, e não que ele seja um nó isolado. `RegExp(r'^Céu limpo$', multiLine: true)` exige a linha inteira exata dentro do nó lido, com âncoras nas duas pontas. Não aceita substring solta nem texto parecido. O matcher **não enfraquece** o teste: os mutantes M14 (texto fixo "Nublado"), M15 (Text removido) e M16 (`labelFor` com código errado) foram todos mortos por ele. Trocar para a string exata testaria uma estrutura de semântica que a spec não pede.

---

## Discrimination Sensor

Scratch: `git worktree add --detach <scratchpad>/wt2 HEAD` com cópia dos arquivos da feature, sem a feature schedule. `flutter pub get`, `flutter analyze` limpo e 84/84 testes verdes antes das mutações. Cada mutante rodou a **suíte completa** e foi revertido por backup. Worktree removida com `git worktree remove --force`. `git status --porcelain` do tree real ficou **idêntico** ao baseline desta iteração.

| # | File:line | Description | Killed? |
| - | --------- | ----------- | ------- |
| M11 | `lib/features/weather/presentation/weather_condition.dart:32` | `(>= 51 && <= 57)` → `51 \|\| 57` | ✅ Killed (varredura 0..99) |
| M12 | `weather_condition.dart:33-34` | `61 \|\| 63 \|\| 67` e `80 \|\| 82` | ✅ Killed (varredura 0..99) |
| M13 | `lib/features/dashboard/presentation/widgets/now_weather_card.dart:40` | `WeatherAnimationView` → `Icon(WeatherCondition.iconFor(weatherCode))` | ✅ Killed (WLOT-05) |
| M14 | `now_weather_card.dart:46` | `labelFor(...)` → texto fixo `'Nublado'` | ✅ Killed (WLOT-09) |
| M15 | `now_weather_card.dart:45-50` | `Text(labelFor)` removido | ✅ Killed (WLOT-09) |
| M16 | `now_weather_card.dart:46` | `labelFor(context, weatherCode)` → `labelFor(context, 3)` | ✅ Killed (WLOT-09) |
| M17 | `now_weather_card.dart:40` | `WeatherAnimationView(weatherCode: 3)` (código fixo) | ✅ Killed (WLOT-05) |
| M18 | `lib/features/dashboard/presentation/pages/dashboard_page.dart:204` | `today.weatherCode` → `forecast.daily.last.weatherCode` | ⚠️ Survived, risco residual fora do escopo (ver abaixo) |

Os mutantes M1 a M10 da iteração 1 miravam `weather_animation_view.dart` e `weather_animation_view_test.dart`, que não mudaram. Os dez foram mortos naquela rodada e o resultado continua valendo.

**M18, avaliação**: a escolha de *qual dia* alimenta o card (`today = forecast.daily.first`, `dashboard_page.dart:160`) já existia antes desta feature. O `Icon(iconFor(today.weatherCode))` antigo usava a mesma fonte, e ela nunca foi testada. A spec registra na Assumption "Código usado no card Agora" que a feature **não muda a fonte de dados**. A linha 204 só repassa o mesmo valor ao widget novo. Testá-la exige um teste do `DashboardPage` com DI do Modular e `AuthCubit`, que é trabalho de cobertura da página e não desta feature. Por isso M18 fica registrado como risco residual e não bloqueia. Veja a recomendação em Fix Plans.

**Sensor depth**: lightweight ampliado (7 mutações da feature nesta iteração, mais 10 da iteração 1)
**Result**: 7/7 mutações no código da feature mortas; 1 mutante de wiring pré-existente sobreviveu (M18, não bloqueante). PASS ✅

---

## Code Quality

| Principle | Status |
| --------- | ------ |
| Minimum code | ✅ |
| Surgical changes | ✅ A extração do `NowWeatherCard` move o bloco sem mudar o comportamento. Foi o que tornou o card testável sem DI; `_StatPill` foi junto porque só esse card usa |
| No scope creep | ✅ "Próximos dias" continua com ícone estático |
| Matches patterns | ✅ Mesma pasta `dashboard/presentation/widgets/` do `DecisionCard` e do `DashboardHeader` |
| Spec-anchored outcome check | ✅ |
| Per-layer Coverage Expectation | ✅ Mapeamento com cobertura 1:1 e varredura completa; widget e card com asserção de valor |
| Every test maps to a spec requirement | ✅ Todos citam WLOT-xx, edge case ou Assumption (nome dos assets) |
| Documented guidelines followed | ✅ none - strong defaults applied; `flutter analyze` limpo |

---

## Edge Cases

- [x] Código negativo ou > 99 → cloudy: `weather_condition_test.dart:92` (-1) e `:96` (100)
- [x] Asset corrompido ou ausente → ícone estático: `weather_animation_view_test.dart:90-93`

---

## Gate Check

- **Gate command**: `flutter analyze` + `flutter test`
- **Result**: analyze `No issues found!` (exit 0). Testes: 93 passaram, 0 falharam, 0 pulados (exit 0, tree real com a feature schedule)
- **Test count before feature**: 44 (HEAD `7fe379d`)
- **Test count after feature**: 84 só com a feature (medido no scratch); 93 no tree real (+9 da feature schedule, fora do escopo)
- **Delta**: +40 testes da feature; nenhum teste removido ou enfraquecido
- **Skipped tests**: nenhum
- **Failures**: nenhuma

---

## Fix Plans

Nenhum fix bloqueante.

### Recomendação (não bloqueante): teste da página para o wiring do dia

- **Root cause**: M18. Nenhum teste prova que o `DashboardPage` passa o código de **hoje** (`forecast.daily.first`) ao card. É um comportamento anterior a esta feature.
- **Sugestão**: quando existir um teste de widget do `DashboardPage` (com `DashboardCubit` mockado via `mocktail`/`bloc_test`, que já estão nas dev_dependencies), verificar `NowWeatherCard.weatherCode == forecast.daily.first.weatherCode` com um `daily` de códigos diferentes.
- **Priority**: Minor, fora do escopo

---

## Requirement Traceability Update

Proposta para o orquestrador aplicar no `spec.md`. O Verifier não edita o spec.

| Requirement | Previous Status | New Status |
| ----------- | --------------- | ---------- |
| WLOT-01 | Implementing | ✅ Verified |
| WLOT-02 | Implementing | ✅ Verified |
| WLOT-03 | Implementing | ✅ Verified |
| WLOT-04 | Implementing | ✅ Verified |
| WLOT-05 | Implementing | ✅ Verified |
| WLOT-06 | Implementing | ✅ Verified |
| WLOT-07 | Implementing | ✅ Verified |
| WLOT-08 | Implementing | ✅ Verified |
| WLOT-09 | Implementing | ✅ Verified |
| WLOT-10 | Implementing | ✅ Verified |
| WLOT-11 | Implementing | ✅ Verified |

---

## Summary

**Overall**: ✅ Ready

**Spec-anchored check**: 11/11 ACs batem com o resultado da spec; 0 gaps de precisão
**Sensor**: 7/7 mutações da feature mortas nesta iteração (10/10 na anterior); 1 sobrevivente pré-existente e fora do escopo (M18)
**Gate**: 93 passaram, 0 falharam; analyze limpo

**What works**: mapeamento WMO completo (varredura 0..99); card "Agora" com animação no lugar do ícone; rótulo exposto ao leitor de tela e animação silenciosa; loop, redução de movimento, fallback, cross-fade e não-reinício.

**Issues found**: nenhum bloqueante. M18 é risco residual do wiring da página, anterior à feature.

**Next steps**: aplicar a rastreabilidade no `spec.md` e commitar pela skill `commit`, depois do ok do usuário.
