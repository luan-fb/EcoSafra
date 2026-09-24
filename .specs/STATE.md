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
- **Phase / Task**: Concluída: T1–T12 commitados e verificação independente PASS (iteração 2, `validation.md`)
- **Completed**: T1–T12, verificação
- **In-progress** (file:line): none
- **Next step**: O usuário vai fazer mudanças próprias; depois: revisar o diff dele, rodar `flutter analyze && flutter test`, commitar, push de `feat/schedule` e PR para a `main` com `flutter-review`
- **Blockers**: none
- **Uncommitted files**: none
- **Branch**: `feat/schedule`
