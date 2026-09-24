# STATE

## Decisions

### AD-001
- **Decision**: Dados criados pelo usuário ficam no banco local drift (`AppDatabase` único), com migrações versionadas pelo `drift_dev make-migrations`; nenhuma feature grava no Firestore.
- **Reason**: O app é offline-first e acadêmico, 100% cliente; banco local funciona no talhão sem sinal e sem configuração externa.
- **Trade-off**: Sem sincronização entre aparelhos nem backup ao reinstalar. Nuvem, se vier, entra atrás das interfaces de repositório.
- **Scope**: Todas as features com dados do usuário (hoje: `schedule`).
- **Date**: 2026-09-23
- **Status**: active

## Handoff

- **Feature**: `.specs/features/schedule`
- **Phase / Task**: Fase 3 concluída (T6–T8); próxima é a Fase 4, começando pelo T9
- **Completed**: T1–T8
- **In-progress** (file:line): none
- **Next step**: Executar T9 (casos de uso de escrita com validação, complexidade Média)
- **Blockers**: none
- **Uncommitted files**: rascunho da Agenda que ainda falta adotar (ver tabela "Como retomar" em `tasks.md`): `create_schedule.dart`, `evaluate_schedule_risk.dart`, `schedule_risk_level.dart` e o teste dele, `presentation/**`, `schedule_module.dart`, os binds de `CreateSchedule` e `EvaluateScheduleRisk` no `schedule_data_module.dart`, e as linhas de rota/menu/l10n em `app_module.dart`, `app_routes.dart`, `app_drawer.dart`, `app_pt.arb`
- **Branch**: `feat/schedule`
