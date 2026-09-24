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

- **Feature**: `.specs/features/schedule-redesign`
- **Phase / Task**: Fase 3 concluída (T5–T6); próxima é a Fase 4, T7
- **Completed**: T1–T6
- **In-progress** (file:line): none
- **Next step**: Executar T7 (remoção otimista, restauração e chuva do dia no cubit, complexidade Alta)
- **Blockers**: none
- **Uncommitted files**: none
- **Branch**: `feat/schedule`
