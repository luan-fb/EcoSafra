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
- **Phase / Task**: Fase 2 concluída (T4–T5); próxima é a Fase 3, começando pelo T6
- **Completed**: T1, T2, T3, T4, T5
- **In-progress** (file:line): none
- **Next step**: Executar T6 (tabela de agendamentos e migração v1 → v2, complexidade Muito alta)
- **Blockers**: none
- **Uncommitted files**: rascunho da Agenda (ver tabela "Como retomar" em `tasks.md`), incluindo o import e a rota do `ScheduleModule` em `lib/app/app_module.dart`
- **Branch**: `feat/schedule`
