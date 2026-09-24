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
- **Phase / Task**: Feature concluída e commitada: T1–T16, correções da verificação e do teste no aparelho; verificação independente PASS (`validation.md`)
- **Completed**: T1–T16, verificação, correção do tema dos botões
- **In-progress** (file:line): none
- **Next step**: O usuário vai fazer alterações simples com outro agente; depois: revisar o diff dele, rodar `flutter analyze && flutter test`, commitar, fazer push de `feat/schedule` e abrir o PR para a `main` com `flutter-review`
- **Blockers**: none
- **Uncommitted files**: none
- **Branch**: `feat/schedule`
