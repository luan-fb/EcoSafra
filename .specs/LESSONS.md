# LESSONS - auto-maintained by scripts/lessons.py

> Machine-owned. Do NOT hand-edit. Changes are overwritten on the next `lessons.py` write.
> Canonical state lives in `.specs/lessons.json`. Edit lessons only via the script.
> promote_threshold=2 distinct features · window_days=45 · quarantine_threshold=2

## Confirmed (load these at Specify/Design)

Corroborated across multiple features. Safe to apply as guidance.

_none_

## Candidates (under observation - do NOT load as guidance yet)

Seen once or not yet corroborated. Tracked, not trusted.

### L-001 - Para mapeamentos por faixa numérica, testar também valores reais do interior de cada faixa, não só as bordas
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `mapping` · harmful: 0
- features: weather-lottie
- evidence: M11/M12 weather_condition.dart:32-34 (mapping)
- last seen: 2026-09-18T22:29:39Z

### L-002 - Quando um widget novo substitui outro numa página, testar a página e verificar que o widget novo está no lugar do antigo
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `presentation` · harmful: 0
- features: weather-lottie
- evidence: M13 dashboard_page.dart:214 (presentation)
- last seen: 2026-09-18T22:29:39Z

### L-003 - Critérios de acessibilidade que exigem expor um rótulo devem ter asserção por find.bySemanticsLabel na tela real
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `presentation` · harmful: 0
- features: weather-lottie
- evidence: WLOT-09 dashboard_page.dart:219-220 (presentation)
- last seen: 2026-09-18T22:29:39Z

### L-004 - Quando um AC exige que um widget mostre o mesmo valor de outra fonte, testar no nível que liga a fonte ao widget, não só a exibição
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `presentation` · harmful: 0
- features: weather-lottie
- evidence: WLOT-16 dashboard_page.dart:202 (presentation)
- last seen: 2026-09-18T23:37:11Z

### L-005 - Quando um widget recebe onTap por parâmetro, testar também na página hospedeira que o toque abre a rota certa; o teste do widget só prova o callback.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `presentation/pages` · harmful: 0
- features: schedule
- evidence: M9 lib/features/dashboard/presentation/pages/dashboard_page.dart (ScheduleAlertBanner.onTap) (presentation/pages)
- last seen: 2026-09-24T11:52:45Z

### L-006 - Valor derivado do relógio (janela, hoje) deve ser recalculado no momento do uso, não lido de um estado que só muda quando outro stream emite; testar avançando o Clock sem nova emissão.
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `presentation/cubit` · harmful: 0
- features: schedule
- evidence: Edge case 'dia vira com a Agenda aberta' - lib/features/schedule/presentation/pages/schedule_page.dart:72 (presentation/cubit)
- last seen: 2026-09-24T11:52:45Z

### L-007 - Quando a mesma correção entra em mais de um ponto de chamada, cada ponto precisa de um teste em que o valor antigo e o novo sejam diferentes
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `presentation/pages` · harmful: 0
- features: schedule
- evidence: validation.md iteração 2, edge case virada do dia: schedule_page.dart:153 (edição) sem teste que discrimine (presentation/pages)
- last seen: 2026-09-24T11:59:09Z

### L-008 - Animação implícita exigida por um AC precisa de teste que capture um quadro intermediário, não só o estado final
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `presentation` · harmful: 0
- features: schedule-redesign
- evidence: SCHEDUI-03 schedule_tile.dart:190-216 (presentation)
- last seen: 2026-09-24T19:32:51Z

### L-009 - Quando um widget novo substitui outro numa página, testar a página e verificar que o widget novo está no lugar do antigo
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `presentation` · harmful: 0
- features: schedule-redesign
- evidence: SCHEDUI-01 schedule_page.dart:390 (presentation)
- last seen: 2026-09-24T19:32:51Z

### L-010 - Em CustomPainter, testar o que é desenhado (paints ou medida do path), não só o parâmetro recebido pelo painter
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `presentation/widgets` · harmful: 0
- features: schedule-redesign
- evidence: M7 animated_check.dart:140 (presentation/widgets)
- last seen: 2026-09-24T19:32:51Z

### L-011 - Em mapeamentos de status para cor, asserir a cor de cada ramo, inclusive o neutro
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `presentation/widgets` · harmful: 0
- features: schedule-redesign
- evidence: M8 schedule_tile.dart:157-158 (presentation/widgets)
- last seen: 2026-09-24T19:32:51Z

### L-012 - Condição composta do tipo A e não B precisa de um teste com A e B verdadeiros para provar a exclusão
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `presentation/widgets` · harmful: 0
- features: schedule-redesign
- evidence: M6 schedule_tile.dart:79-81 (presentation/widgets)
- last seen: 2026-09-24T19:32:52Z

### L-013 - Semântica binária como checked deve ser asserida nos dois valores
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `presentation/widgets` · harmful: 0
- features: schedule-redesign
- evidence: SCHEDUI-09 animated_check.dart:67 (presentation/widgets)
- last seen: 2026-09-24T19:32:52Z

### L-014 - Quando a spec fixa a duração de uma animação, conferir o estado final exatamente nessa duração, sem pumpAndSettle
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `presentation/widgets` · harmful: 0
- features: schedule-redesign
- evidence: SCHEDUI-19 animated_check.dart:35 (presentation/widgets)
- last seen: 2026-09-24T19:32:52Z

### L-015 - Critério de animação vago como sem pulo brusco deve nomear na spec o efeito observável e a duração esperada
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `spec` · harmful: 0
- features: schedule-redesign
- evidence: SCHEDUI-04 schedule_page.dart:188-192 (spec)
- last seen: 2026-09-24T19:32:52Z

### L-016 - Quando um AC de navegação lista vários estados abertos, testar o voltar em cada estado citado, não só em um deles
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `presentation` · harmful: 0
- features: schedule-redesign
- evidence: M6 schedule_page.dart:113 (SCHEDUI-24) (presentation)
- last seen: 2026-09-24T23:40:03Z

### L-017 - Para duração, duração reversa e curva definidas na spec, afirmar os valores configurados na rota ou no controller, não só que a animação está em andamento
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `presentation` · harmful: 0
- features: schedule-redesign
- evidence: M8 schedule_form_sheet.dart:54 (SCHEDUI-26) (presentation)
- last seen: 2026-09-24T23:40:03Z

### L-018 - Para um estado visual pedido na spec, afirmar o estado no widget renderizado, não o parâmetro repassado ao componente
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `presentation` · harmful: 0
- features: schedule-redesign
- evidence: M5 app_drawer.dart:78 (SCHEDUI-23) (presentation)
- last seen: 2026-09-24T23:40:03Z

## Quarantined (failed when applied - ignore)

A confirmed lesson that recurred alongside failure. Kept for the maintainer to review.

_none_
