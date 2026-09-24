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
- **Phase / Task**: Fase 5 concluída (T11–T14); próxima é a Fase 6, começando pelo T15
- **Completed**: T1–T14
- **In-progress** (file:line): none
- **Next step**: Executar T15 (cubit do aviso do painel, complexidade Alta)
- **Blockers**: none
- **Uncommitted files**: none (o rascunho da Agenda foi todo adotado)
- **Branch**: `feat/schedule`
