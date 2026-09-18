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

## Quarantined (failed when applied - ignore)

A confirmed lesson that recurred alongside failure. Kept for the maintainer to review.

_none_
