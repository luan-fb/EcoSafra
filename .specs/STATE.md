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
- **Phase / Task**: Fase 4 concluída (T9–T10); próxima é a Fase 5, começando pelo T11
- **Completed**: T1–T10
- **In-progress** (file:line): none
- **Next step**: Executar T11 (cubit e estado da Agenda, complexidade Alta)
- **Blockers**: none
- **Uncommitted files**: rascunho que ainda falta adotar (ver tabela "Como retomar" em `tasks.md`): `presentation/**`, `schedule_module.dart` e as linhas de rota/menu/l10n em `app_module.dart`, `app_routes.dart`, `app_drawer.dart`, `app_pt.arb`
- **Branch**: `feat/schedule`
