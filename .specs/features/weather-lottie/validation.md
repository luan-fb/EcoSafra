# weather-lottie Validation (spec v2, iteração 3 de 3)

**Date**: 2026-09-18
**Spec**: `.specs/features/weather-lottie/spec.md` (v2, WLOT-01..17)
**Diff range**: working tree não commitado contra HEAD `71e7675`. Arquivos: `assets/lottie/partly_cloudy.json`, `assets/lottie/cold.json`, `lib/features/weather/presentation/weather_animation.dart`, `lib/features/weather/presentation/weather_condition.dart`, `lib/features/weather/presentation/widgets/weather_animation_view.dart`, `lib/features/dashboard/presentation/widgets/now_weather_card.dart`, `lib/features/dashboard/presentation/pages/dashboard_page.dart`, `test/features/weather/presentation/weather_condition_test.dart`, `test/features/weather/presentation/widgets/weather_animation_view_test.dart`, `test/features/dashboard/presentation/widgets/now_weather_card_test.dart`, e na iteração 3 `lib/features/dashboard/presentation/widgets/forecast_section.dart` (a `_ForecastSection` extraída sem mudar a lógica) e `test/features/dashboard/presentation/widgets/forecast_section_test.dart`. A feature Agendamento ficou fora do escopo.
**Verifier**: sub-agente independente (autor ≠ verificador)

## Validation: weather-lottie - PASS ✅

**Verdict**: PASS ✅. A lacuna da iteração 2 (WLOT-16 no nível da página) foi fechada pela extração da `ForecastSection` e pelo teste dela. As demais evidências da iteração 2 continuam valendo, porque os arquivos delas não mudaram nesta rodada.

---

## Task Completion

Não existe `tasks.md`. A verificação foi ancorada nos ACs do `spec.md` v2.

---

## Spec-Anchored Acceptance Criteria

Abreviações: `TC` = `test/features/weather/presentation/weather_condition_test.dart`, `TV` = `test/features/weather/presentation/widgets/weather_animation_view_test.dart`, `TK` = `test/features/dashboard/presentation/widgets/now_weather_card_test.dart`.

| Criterion | Spec-defined outcome | `file:line` + assertion | Result |
| --------- | -------------------- | ----------------------- | ------ |
| WLOT-01: 0 com mais de 16° → sunny | `sunny` | `test/features/weather/presentation/weather_condition_test.dart:72` + `:101-104` `expect(WeatherCondition.animationFor(code, temperature: warm), expected)`; varredura `TC:169-174` | ✅ PASS |
| WLOT-02: 3, 45, 48 com mais de 16° → cloudy | `cloudy` | `TC:75-77` + `:101-104`; varredura `TC:170-174` | ✅ PASS |
| WLOT-03: faixas de chuva → rainy em qualquer temperatura | `rainy` a 25° e a 10° | `TC:78-90` (bordas a 25°); `TC:118-125` `expect(animationFor(code, temperature: cold), WeatherAnimation.rainy)`; varredura 0..99 a 25° e a 10° `TC:151-180` | ✅ PASS |
| WLOT-04: desconhecido com mais de 16° → cloudy | `cloudy` | `TC:92-96` (-1, 4, 50, 58, 100) + `:101-104` | ✅ PASS |
| WLOT-05: card "Agora" com o Lottie mapeado, sem o ícone | `WeatherAnimationView(código, temperatura do card)` e sem `Icon(iconFor)`; o asset mapeado é renderizado | `test/features/dashboard/presentation/widgets/now_weather_card_test.dart:53` `expect(view.weatherCode, 0)`; `:55` `expect(view.temperature, currentHour.temperature)`; `:57` `findsNothing` no ícone; asset: `TV:89` `expect(assetOf(lottieIn(tester)), expected.assetPath)` para sunny, partlyCloudy, cloudy, rainy e cold; bundle e JSON válidos `TV:100-102` ; wiring da seção: `test/features/dashboard/presentation/widgets/forecast_section_test.dart:84` `expect(card.weatherCode, forecast.daily.first.weatherCode)` (daily = [0, 61]); `:85` `expect(card.currentHour, forecast.hourly.first)` | ✅ PASS (M18 fechado: P2 morto) |
| WLOT-06: loop sem redução de movimento | controller interno, `animate: true`, `repeat: true` | `test/features/weather/presentation/widgets/weather_animation_view_test.dart:113` `controller isNull`; `:114` `animate isTrue`; `:115` `repeat isTrue` | ✅ PASS |
| WLOT-07: quadro parado com ≥ 10% da área desenhada | parado em `stillProgress`; ≥ 0,10 da área com pixel | `TV:124` `isA<AlwaysStoppedAnimation<double>>()`; `:125` `controller!.value == stillProgress`; `:133-136` `drawnFraction(composition, stillProgress) >= 0.10` para as 5 animações. A redução de movimento é ligada pela plataforma (`TV:66-67`) | ✅ PASS |
| WLOT-08: falha → `iconFor` do código e erro reportado ao `FlutterError` | `Icon(iconFor(61))` + `FlutterError` reportado | `TV:147` `findsOneWidget`; `:148` `expect(tester.takeException(), isFlutterError)` | ✅ PASS |
| WLOT-09: leitor de tela recebe `labelFor` e nada da animação | "Céu limpo" exposto; a animação sem rótulo | `TK:69-71` `bySemanticsLabel(RegExp(r'^Céu limpo$', multiLine: true))` `findsOneWidget`; `TV:159` `bySemanticsLabel(RegExp(r'\S'))` `findsNothing` | ✅ PASS |
| WLOT-10: cross-fade | as duas coexistem com opacidade em (0,1) e depois fica só a nova | `TV:179-185` `unorderedEquals([sunny, rainy])`; `:194-195` `hasLength(2)`, `everyElement(inExclusiveRange(0, 1))`; `:200` resta rainy | ✅ PASS |
| WLOT-11: mesma animação não reinicia | mesmo `State` | `TV:212-213` `same(before)` | ✅ PASS |
| WLOT-12: 1, 2 com mais de 16° → partlyCloudy | `partlyCloudy` | `TC:73-74` + `:101-104`; varredura `TC:165` | ✅ PASS |
| WLOT-13: 71–77, 85, 86 → cold | `cold` em qualquer temperatura | `TC:82-87` (a 25°); varredura `TC:159`, `:163` a 25° e a 10° | ✅ PASS |
| WLOT-14: arredondado ≤ 16 troca sunny, partlyCloudy e cloudy por cold | `cold`; 16,4 → cold; 16,5 → sunny | `TC:109-114` (0, 1, 2, 3, 45, -1 a 10°); `TC:130-134` `animationFor(0, temperature: 16.4) == cold`; `TC:137-141` `animationFor(0, temperature: 16.5) == sunny`; temperatura do card repassada `TK:55` | ✅ PASS |
| WLOT-15: no máximo 30 fps | `FrameRate(30)` | `TV:165` `expect(lottieIn(tester).frameRate, const FrameRate(30))` | ✅ PASS |
| WLOT-16: a pílula mostra o **mesmo** `rainNext48h` que a decisão usou | valor da pílula == `advice.rainNext48h` | Só no nível do card: `TK:79-80` `find.text('12.3 mm')` `findsOneWidget`, que prova que o card exibe o valor recebido. A origem (`advice.rainNext48h`, `lib/features/dashboard/presentation/pages/dashboard_page.dart:202`) não tem teste, e nenhum teste referencia `DashboardPage` Iteração 3: `test/features/dashboard/presentation/widgets/forecast_section_test.dart:76` `expect(card.rainNext48h, advice.rainNext48h)` com advice = 9,5 e soma do hourly = 6; `:77` `expect(find.text('9.5 mm'), findsOneWidget)` | ✅ PASS |
| WLOT-17: com redução de movimento, troca sem transição | no primeiro quadro após a troca só resta a nova | `TV:225` `findsOneWidget`; `:226` asset rainy | ✅ PASS |

**Edge cases**
- [x] Código negativo ou > 99 → desconhecido: `TC:92`, `:96` a 25° (cloudy); `TC:109` com -1 a 10° (cold)
- [x] Asset corrompido, ausente ou não declarado: a falha de carga está coberta em `TV:144-148`; a declaração no pubspec é verificada ao carregar pelo `rootBundle` em `TV:100`
- [x] 16,4 → frio; 16,5 → não frio: `TC:130-141`

**Status**: 17/17 ACs com evidência que confere o resultado da spec.

### Pontos já conhecidos pelo coordenador

Os dois pontos conhecidos da iteração 2 estão fechados:
- **M18** (dia de hoje): agora testado em `forecast_section_test.dart:84`, e o mutante P2 foi morto.
- **WLOT-16 na seção** (`forecast_section.dart:73`, `rainNext48h: advice.rainNext48h`): agora testado em `forecast_section_test.dart:76-77`, e o mutante P1 foi morto.

---

## Discrimination Sensor

Scratch: `git worktree add --detach <scratchpad>/wt3 HEAD` + cópia dos 10 arquivos da feature. `flutter pub get`, analyze limpo, 82/82 nos arquivos afetados antes das mutações. Cada mutante rodou **só o arquivo de teste afetado** e foi revertido por backup. Worktree removida com `git worktree remove --force`. `git status --porcelain` real ficou **idêntico** ao baseline. Nada de stash.

| # | File:line | Description | Killed? |
| - | --------- | ----------- | ------- |
| N1 | `lib/features/weather/presentation/weather_condition.dart:55` | limite `<= 16` → `< 16` | ✅ Killed (`TC:130`, 16,4°) |
| N2 | `weather_condition.dart:55` | sem arredondamento: `temperature <= 16` | ✅ Killed (`TC:130`, 16,4°) |
| N3 | `weather_condition.dart:57-59` | `rainy` entra na troca pelo frio (a chuva perde para o frio) | ✅ Killed (`TC:118`, varredura `TC:148`) |
| N4 | `lib/features/weather/presentation/widgets/weather_animation_view.dart:31` | `stillProgress` 0,5 → 0,0 | ✅ Killed (`TV:130`, cloudy < 10%) |
| N5 | `weather_animation_view.dart:81` | `frameRate` removido | ✅ Killed (`TV:163`) |
| N6 | `weather_animation_view.dart:85-92` | `FlutterError.reportError` removido | ✅ Killed (`TV:141`) |
| N7 | `weather_animation_view.dart:68` | duração do switch ignora `reduceMotion` | ✅ Killed (`TV:216`) |
| N8 | `lib/features/dashboard/presentation/widgets/now_weather_card.dart:42` | `temperature: currentHour.windSpeed` | ✅ Killed (`TK:55`) |

Ficaram fora por causa do orçamento de 8 mutantes: partlyCloudy (1/2) e neve → cold. Os dois já estão presos por asserção de valor exato por código (`TC:73-74`, `TC:82-87`) e pela varredura 0..99 a 25° e 10° (`TC:169-180`), que na rodada anterior matou mutantes equivalentes de faixa (M11 e M12).

### Iteração 3 (só `forecast_section.dart`, rodando só `forecast_section_test.dart`)

Scratch `wt4` (worktree em HEAD + arquivos da feature), baseline verde; worktree removida; porcelain real idêntico ao baseline.

| # | File:line | Description | Killed? |
| - | --------- | ----------- | ------- |
| P1 | `lib/features/dashboard/presentation/widgets/forecast_section.dart:73` | `rainNext48h` volta a ser a soma local do `hourly` (6 em vez de 9,5) | ✅ Killed (`forecast_section_test.dart:76`) |
| P2 | `forecast_section.dart:31` | `daily.first` → `daily.last` | ✅ Killed (`forecast_section_test.dart:84`) |
| P3 | `forecast_section.dart:30` | `hourly.first` → `hourly.last` | ✅ Killed (`forecast_section_test.dart:85`) |

**Sensor depth**: lightweight ampliado (8 na iteração 2 + 3 na iteração 3, dentro do orçamento)
**Resultado do sensor**: 11/11 mutantes mortos (8 na iteração 2 + 3 na iteração 3)

---

## Code Quality

| Principle | Status |
| --------- | ------ |
| Minimum code | ✅ Regra do frio num segundo `switch` com guard; `stillProgress` como constante documentada |
| Surgical changes | ✅ A página só troca a origem de `rainNext48h` e renomeia `now` → `currentHour` |
| No scope creep | ✅ O bug de `hourly.first` ficou registrado como fora do escopo e não foi mexido |
| Matches patterns | ✅ Usa `context.reduceMotion` e `AppMotion.medium`, que já existem no projeto |
| Spec-anchored outcome check | ✅ |
| Per-layer Coverage Expectation | ✅ Mapeamento 1:1 com varredura; widget, card e seção com asserção de valor |
| Every test maps to a spec requirement | ✅ Todos citam WLOT-xx ou edge case |
| Documented guidelines followed | ✅ none - strong defaults applied; analyze limpo |

Observação menor (não bloqueia): o parâmetro `bundle` do `WeatherAnimationView` só existe para injetar um bundle nos testes. A produção passa nulo. É aceitável porque imita o `Image.asset`.

---

## Gate Check

- **Gate command**: `flutter analyze` + `flutter test` (tree real, rodado uma vez)
- **Result** (iteração 3): analyze sem issues (exit 0). Testes: 115 passaram, 0 falharam, 0 pulados (exit 0; inclui o Agendamento). Na iteração 2 eram 113; os +2 são do `forecast_section_test.dart`
- **Arquivos de teste da feature**: 82 testes, todos verdes no scratch sem o Agendamento
- **Skipped tests**: nenhum
- **Failures**: nenhuma
- **Integridade**: nenhum teste removido; as asserções ficaram mais fortes que na v1 (opacidade no cross-fade, bundle real, pixels desenhados)

---

## Fix Plans

Nenhum. O Fix 1 da iteração 2 (WLOT-16 e M18 no nível da seção) foi aplicado e verificado.

---

## Requirement Traceability Update

Aplicado no `spec.md` a pedido do orquestrador.

| Requirement | New Status |
| ----------- | ---------- |
| WLOT-01..17 | ✅ Verified (aplicado no `spec.md`) |

---

## Summary

**Overall**: ✅ Ready

**Spec-anchored check**: 17/17 ACs batem com o resultado da spec; 0 gaps de precisão
**Sensor**: 11/11 mutações mortas (8 na iteração 2 + 3 na iteração 3)
**Gate**: 115 passaram, 0 falharam; analyze limpo

**Next steps**: commit pela skill `commit`, depois do ok do usuário.
