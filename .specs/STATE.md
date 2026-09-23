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
- **Phase / Task**: Tasks prontas (16 tasks, 6 fases), aguardando aprovação do usuário para o Execute
- **Completed**: Specify, Design, Tasks
- **In-progress** (file:line): none
- **Next step**: Com o ok do usuário, commitar os artefatos de spec e iniciar o Execute pelo grupo 1 (T1–T3, Mecânica)
- **Blockers**: none
- **Uncommitted files**: rascunho da Agenda (ver tabela "Como retomar" em `tasks.md`); `.specs/features/schedule/{spec,design,tasks}.md`; `.specs/STATE.md`
- **Branch**: `feat/schedule`
