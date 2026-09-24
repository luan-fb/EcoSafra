# Redesign da Agenda — Specification

## Problem Statement

A Agenda funciona, mas o item da lista ainda é um `ListTile` simples com a data em texto, e excluir exige menu e diálogo. Depois do painel com card de decisão animado e clima em Lottie, a Agenda parece de outro app. O redesign dá ao card uma leitura de relance (dia em destaque, cor pelo risco), torna a exclusão um gesto direto com volta atrás e usa a tela como estudo de animações nativas do Flutter.

## Goals

- [ ] O produtor identifica o dia e o risco de cada agendamento sem ler o texto: bloco de data colorido pelo status.
- [ ] Excluir é um gesto único e reversível: arrastar para a esquerda, com "Desfazer".
- [ ] Três animações nativas de estudo: card que se expande no formulário, check desenhado e alerta pulsando, todas desligadas com "remover animações".
- [ ] Nenhuma regra de negócio da Agenda muda: janela de datas, observação, risco, conclusão e aviso do painel seguem iguais.

## Out of Scope

| Feature | Reason |
| ------- | ------ |
| Lottie na Agenda | O objetivo é estudar animações nativas; o Lottie já está no painel |
| Arrastar para a direita para concluir | Não escolhido; o checkbox continua sendo o jeito de concluir |
| Entrada em cascata dos cards | Não escolhida; a entrada atual (`FadeSlideIn`) permanece |
| Filtros, busca ou visão de calendário | Fora do pedido |
| Mudanças no aviso do painel | Outra tela; nada nela muda |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --------------------- | -------------- | --------- | ---------- |
| Tema da animação do estado vazio | Componente nativo animado com `AnimationController` | Estudo de animação explícita (implementado pelo outro agente) | y |
| Layout do card | **Substitui** a decisão anterior de manter `Card` + `ListTile`: bloco de data à esquerda e conteúdo à direita | Escolha do usuário em 2026-09-24, com o preview "bloco de data à esquerda" | y |
| Cores do bloco de data | Verde (`AppColors.safe`) favorável; vermelho (`AppColors.danger`) risco; amarelo (`AppColors.caution`) data passada; neutro (`surfaceContainerHigh`) sem previsão e concluído | Mesma semântica de cor do card de decisão do painel | y |
| Excluir | Arrastar para a esquerda remove na hora e mostra "Desfazer" por 4 s; o diálogo de confirmação sai | Escolha do usuário; o Desfazer torna a confirmação desnecessária | y |
| Desfazer | Restaura o mesmo agendamento: mesmo id, data, observação, criação e conclusão | O item volta exatamente como estava, na mesma posição da lista | y |
| Exclusão sem gesto | Ação de acessibilidade "Excluir" no card, com o mesmo Desfazer | Leitor de tela não faz swipe num item específico | y |
| Duas exclusões seguidas | O snackbar novo substitui o anterior; a primeira exclusão fica confirmada | Um Desfazer por vez, como no Gmail | y |
| Sair da Agenda com o snackbar aberto | O snackbar some junto com a tela; a exclusão fica confirmada | O Desfazer nunca chama um cubit já fechado | y |
| Formulário | Vira tela cheia, aberta pela transição de container (pacote oficial `animations`) a partir do card ou do botão "Agendar" | A transição expande um elemento até ocupar a tela: não existe container transform para bottom sheet | y |
| Chuva no card | Só nos agendamentos em risco: "X mm previstos", com uma casa decimal, da previsão diária do dia | Explica o porquê do vermelho; nos demais casos o rótulo basta | y |
| Check desenhado | Substitui o `Checkbox` padrão por um componente próprio com `CustomPainter`, mantendo semântica de checkbox e alvo de toque de 48 | Estudo de animação explícita com traçado progressivo | y |

**Open questions:** none - all resolved or logged above.

---

## User Stories

### P1: Estado vazio animado ⭐ MVP (implementado)

**User Story**: Como produtor, quero ver uma ilustração animada quando a agenda estiver vazia, para a tela não parecer quebrada.

**Why P1**: Primeira impressão da tela.

**Acceptance Criteria**:

1. WHERE a lista de próximos e concluídos está vazia the system SHALL exibir o estado vazio com o componente animado nativo.
2. IF o sistema está com redução de animações ligada THEN the system SHALL exibir o componente parado.

**Independent Test**: Abrir a agenda vazia e ver a animação; ligar "remover animações" e ver o componente parado.

---

### P1: Transições da lista ⭐ MVP (implementado)

**User Story**: Como produtor, quero ver os itens mudarem de estado com fluidez, para ter retorno claro da minha ação.

**Why P1**: Feedback visual reduz erro.

**Acceptance Criteria**:

1. WHEN o usuário marca ou desmarca a conclusão THEN the system SHALL animar a mudança de estilo do card com animações implícitas.
2. WHEN um item sai da lista THEN the system SHALL animar a saída sem pulo brusco dos itens abaixo.

**Independent Test**: Concluir e desfazer um item; excluir um item e ver a lista se ajustar.

---

### P1: Card com bloco de data ⭐ MVP

**User Story**: Como produtor, quero ver o dia e o risco de cada aplicação de relance, sem ler frases.

**Why P1**: É o pedido central do redesign.

**Acceptance Criteria**:

1. The system SHALL exibir cada agendamento com um bloco à esquerda contendo o dia do mês e o mês abreviado em maiúsculas (ex.: "23" e "SET") e, à direita, o dia da semana por extenso, a observação quando houver e o rótulo de status.
2. The system SHALL colorir o bloco de data conforme a tabela de cores das Assumptions: favorável, risco, data passada, sem previsão e concluído.
3. WHILE o agendamento não concluído está em risco the system SHALL exibir a chuva prevista para o dia no formato "X,X mm previstos".
4. The system SHALL oferecer a conclusão num controle à direita do card, com alvo de toque de pelo menos 48 x 48.
5. The system SHALL expor ao leitor de tela o card como um item com dia da semana, data, status e observação, e o controle de conclusão como checkbox marcado ou desmarcado.

**Independent Test**: Criar um agendamento em dia de chuva forte e ver o bloco vermelho com "X mm previstos"; concluir e ver o bloco neutro.

---

### P1: Excluir com swipe e Desfazer ⭐ MVP

**User Story**: Como produtor, quero apagar um plano arrastando o card, e poder voltar atrás se errar.

**Why P1**: Pedido explícito; substitui menu mais diálogo por um gesto.

**Acceptance Criteria**:

1. WHEN o usuário arrasta um card para a esquerda além do limiar THEN the system SHALL tirar o card da lista na hora e excluir o agendamento do banco.
2. WHEN um agendamento é excluído THEN the system SHALL mostrar o snackbar "Agendamento excluído" com a ação "Desfazer" por 4 segundos.
3. WHEN o usuário toca em "Desfazer" THEN the system SHALL restaurar o agendamento com o mesmo id, data, observação, data de criação e conclusão.
4. IF a exclusão falha no banco THEN the system SHALL devolver o card à lista e mostrar a mensagem de erro.
5. IF a restauração falha no banco THEN the system SHALL mostrar a mensagem de erro.
6. The system SHALL oferecer "Excluir" como ação de acessibilidade do card, com o mesmo snackbar e Desfazer.
7. WHEN a tela da Agenda é fechada com o snackbar visível THEN the system SHALL esconder o snackbar.

**Independent Test**: Arrastar um card, tocar em Desfazer e ver o card voltar igual; arrastar de novo e esperar o snackbar sumir: o item não volta ao reabrir o app.

---

### P2: Animações de destaque

**User Story**: Como produtor, quero transições que mostram de onde veio cada tela e o resultado de cada ação.

**Why P2**: Acabamento visual e estudo de animação; a agenda funciona sem elas.

**Acceptance Criteria**:

1. WHEN o usuário toca num agendamento não concluído THEN the system SHALL abrir o formulário de edição em tela cheia com o card se expandindo até ocupar a tela, e fechar fazendo o caminho inverso.
2. WHEN o usuário toca em "Agendar" THEN the system SHALL abrir o formulário de criação com a mesma transição a partir do botão.
3. WHEN o usuário marca um agendamento como concluído THEN the system SHALL desenhar o check progressivamente em `AppMotion.medium`, e WHEN desmarca THEN the system SHALL apagá-lo no mesmo tempo.
4. WHILE um agendamento não concluído está em risco the system SHALL pulsar o bloco de data em loop.
5. WHILE `MediaQuery.disableAnimations` é true the system SHALL mostrar o check completo sem traçado, o bloco de data sem pulso e abrir e fechar o formulário sem transição.
6. The system SHALL manter no formulário em tela cheia as mesmas regras do formulário atual: janela de datas da previsão, observação de até 200 caracteres e preenchimento na edição.

**Independent Test**: Tocar num card e ver a expansão; concluir e ver o check sendo desenhado; ligar "remover animações" e ver tudo trocar sem movimento.

---

## Edge Cases

- WHEN o usuário arrasta um card concluído THEN the system SHALL excluí-lo com o mesmo Desfazer.
- WHEN o usuário exclui dois agendamentos seguidos THEN the system SHALL manter só o snackbar do último, e a primeira exclusão SHALL ficar confirmada.
- IF o arrasto não passa do limiar THEN the system SHALL devolver o card à posição sem excluir.
- WHEN o agendamento restaurado volta THEN the system SHALL colocá-lo na posição que a ordenação da lista define.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| -------------- | ----- | ----- | ------ |
| SCHEDUI-01 | P1: Estado vazio animado | Execute | Implemented (b46700f) |
| SCHEDUI-02 | P1: Estado vazio animado | Execute | Implemented (b46700f) |
| SCHEDUI-03 | P1: Transições da lista | Execute | Implemented (f1b0106) |
| SCHEDUI-04 | P1: Transições da lista | Execute | Implemented (54b7c48); substituído pelo swipe em SCHEDUI-10 |
| SCHEDUI-05 | P1: Card: layout | Tasks | In Tasks |
| SCHEDUI-06 | P1: Card: cores | Tasks | In Tasks |
| SCHEDUI-07 | P1: Card: chuva em mm | Tasks | In Tasks |
| SCHEDUI-08 | P1: Card: controle de conclusão | Tasks | In Tasks |
| SCHEDUI-09 | P1: Card: semântica | Tasks | In Tasks |
| SCHEDUI-10 | P1: Swipe: remove e exclui | Tasks | In Tasks |
| SCHEDUI-11 | P1: Swipe: snackbar Desfazer | Tasks | In Tasks |
| SCHEDUI-12 | P1: Swipe: restaura igual | Tasks | In Tasks |
| SCHEDUI-13 | P1: Swipe: falha ao excluir | Tasks | In Tasks |
| SCHEDUI-14 | P1: Swipe: falha ao restaurar | Tasks | In Tasks |
| SCHEDUI-15 | P1: Swipe: ação de acessibilidade | Tasks | In Tasks |
| SCHEDUI-16 | P1: Swipe: snackbar some ao sair | Tasks | In Tasks |
| SCHEDUI-17 | P2: Container transform no card | Tasks | In Tasks |
| SCHEDUI-18 | P2: Container transform no botão | Tasks | In Tasks |
| SCHEDUI-19 | P2: Check desenhado | Tasks | In Tasks |
| SCHEDUI-20 | P2: Alerta pulsando | Tasks | In Tasks |
| SCHEDUI-21 | P2: Redução de movimento | Tasks | In Tasks |
| SCHEDUI-22 | P2: Regras do formulário mantidas | Tasks | In Tasks |

SCHEDUI-05..09 = ACs 1–5 do card; SCHEDUI-10..16 = ACs 1–7 do swipe; SCHEDUI-17..22 = ACs 1–6 das animações.

**Coverage:** 22 total, 4 implemented, 18 mapped to tasks (T5–T12)

---

## Success Criteria

- [ ] No aparelho, a lista mostra o bloco de data colorido e o swipe com Desfazer restaura o item igual.
- [ ] Com "remover animações", nenhuma das três animações novas se move.
- [ ] Os testes de regra da Agenda (janela, observação, risco, aviso) seguem passando sem alteração.
