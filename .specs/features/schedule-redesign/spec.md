# Redesign da Agenda Specification

## Problem Statement

O layout atual do caderno de agendamentos é muito básico (ícones estáticos, cards simples). Para entregar uma experiência visual à altura da tela de previsão do tempo e servir como caso de estudo prático, o usuário deseja modernizar a agenda construindo animações nativas do Flutter (explícitas e implícitas). Isso aumenta o engajamento e permite aprendizado avançado de UI no Flutter, sem quebrar as regras de negócio existentes.

## Goals

- [ ] Melhorar a aparência do Empty State construindo uma animação nativa explícita (usando `AnimationController`, `AnimatedBuilder` ou `TweenAnimationBuilder`).
- [ ] Aplicar microinterações nativas na transição de estados dos cards (ex: transição ao marcar como concluído, entrada/saída de cards).
- [ ] Modernizar a UI dos cartões de agendamento (badges de status, layout de textos).
- [ ] Preservar 100% da lógica e integração com o backend/cubit.

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature     | Reason         |
| ----------- | -------------- |
| Alterações na lógica de agendamento | O objetivo é 100% apresentação (UI/UX), sem tocar no `ScheduleCubit` ou banco de dados. |
| Novas funcionalidades na agenda | Adição de novos filtros, campos de formulário ou views de calendário estão fora do escopo. |
| Uso de Lottie na agenda | O objetivo atual é o aprendizado prático de animações 100% nativas em Flutter. |

---

## Assumptions & Open Questions

Every ambiguity is resolved or recorded here - nothing is left silently unclear.

| Assumption / decision | Chosen default  | Rationale | Confirmed? |
| --------------------- | --------------- | --------- | ---------- |
| Tema da Animação do Empty State | Um componente animado representando a agenda (um ícone animado com "pulsar", balanço ou *staggered animation*) | Aproveita a base nativa, ensina como coreografar animações com `AnimationController` e `Interval`. | y |
| Layout base do cartão | O design base (Card + ListTile) será mantido, apenas receberá os wrappers de animação nativa. | Foco na fluidez (microinterações de conclusão e exclusão), evitando trabalho extra de redesign onde a funcionalidade já atende bem. | y |
| Transição ao concluir | Faremos uma animação implícita (AnimatedDefaultTextStyle e AnimatedOpacity) ao concluir | É suave e nativo do Flutter, reduzindo a carga cognitiva e aproveitando os widgets padrão. | y |
| Acessibilidade das animações Nativas | As animações em loop pararão se o sistema estiver com "Reduzir Movimento" ativo | Respeita a regra de acessibilidade já testada e validada em `WeatherAnimationView`. | y |

**Open questions:** none - all resolved or logged above (required before the spec is confirmed).

---

## User Stories

### P1: Empty State Moderno com Animação Nativa ⭐ MVP

**User Story**: As a produtor, I want ver um Empty State ilustrado com uma animação nativa do Flutter so that eu tenha uma recepção visual agradável e possa estudar o código da animação.

**Why P1**: É a primeira impressão quando a agenda está vazia e serve como o principal componente de estudo de animação explícita.

**Acceptance Criteria** (each line is one EARS pattern):

1. WHERE [a lista de upcoming e completed estiver vazia] the system SHALL [exibir a tela vazia com o componente animado nativamente]
2. IF [o sistema operacional estiver com redução de animações habilitado] THEN the system SHALL [exibir o componente de forma estática, sem loop de animação]

**Independent Test**: Abrir a agenda vazia, verificar se a animação nativa é renderizada fluidamente, e testar alterando a opção de acessibilidade do OS para garantir que ela pare.

---

### P1: Transições Nativas na Lista de Agendamentos ⭐ MVP

**User Story**: As a produtor, I want ver os itens entrarem e mudarem de estado (concluído/pendente) com fluidez so that eu tenha feedback claro e imediato da minha ação.

**Why P1**: Feedback visual melhora a experiência e reduz erros.

**Acceptance Criteria**:

1. WHEN [o usuário interage com o Checkbox de conclusão] THEN the system SHALL [animar o risco do texto, a opacidade e ocultar o status usando animações implícitas do Flutter]
2. WHEN [um item é adicionado ou removido da lista] THEN the system SHALL [animar a entrada/saída do cartão para que a lista se ajuste sem pulos bruscos]

**Independent Test**: Marcar e desmarcar um item para ver o cross-fade e a mudança de estilo; adicionar/excluir item observando o comportamento da SliverList.

---

## Requirement Traceability

Each requirement gets a unique ID for tracking across design, tasks, and validation.

| Requirement ID | Story       | Phase  | Status  |
| -------------- | ----------- | ------ | ------- |
| SCHEDUI-01     | P1: Empty State Moderno com Lottie | Design | Pending |
| SCHEDUI-02     | P1: Empty State Moderno com Lottie | Design | Pending |
| SCHEDUI-03     | P1: Transições Nativas na Lista de Agendamentos | Design | Pending |
| SCHEDUI-04     | P1: Transições Nativas na Lista de Agendamentos | Design | Pending |

**ID format:** `[CATEGORY]-[NUMBER]` (e.g., `AUTH-01`, `CART-03`, `NOTIF-02`)

**Status values:** Pending → In Design → In Tasks → Implementing → Verified

**Coverage:** 4 total, 0 mapped to tasks, 4 unmapped ⚠️

---

## Success Criteria

How we know the feature is successful:

- [ ] [A tela exibe a animação Lottie corretamente quando não há dados]
- [ ] [Os cartões animam as mudanças de estado (concluído/não concluído) de forma nativa e visível]
- [ ] [Nenhum teste de regressão de regras de negócio (bloc, datas, estados) falha]
