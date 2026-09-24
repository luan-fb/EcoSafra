# Caderno de agendamento — Specification

## Problem Statement

O produtor decide hoje se pode adubar, mas não tem onde planejar a próxima aplicação nem é avisado quando a previsão estraga o plano. Aplicar adubo num dia que vira chuva forte perde o insumo e contamina o rio. A feature cria um caderno de agendamento no próprio aparelho (funciona sem internet no talhão, como o resto do app) e usa a previsão para avisar no painel quando um plano entrou em risco ou quando é dia de aplicar.

## Goals

- [ ] O produtor cria, edita, conclui e exclui agendamentos de aplicação, com ou sem internet, sem nenhuma configuração externa.
- [ ] Todo agendamento novo cai numa data que a previsão cobre, então sempre dá para dizer se o dia está em risco.
- [ ] Ao abrir o painel, o produtor vê um alerta quando um plano caiu em dia de chuva forte, e um lembrete quando há aplicação para hoje ou amanhã.

## Out of Scope

| Feature | Reason |
| ------- | ------ |
| Sincronização em nuvem ou entre aparelhos | Decisão do usuário: banco local nesta entrega; a interface de repositório deixa a porta aberta |
| Notificação push ou lembrete com o app fechado | Exigiria agendador do sistema operacional |
| Dispensar ou esconder o aviso do painel | Não pedido |
| Repetir agendamento (recorrência) | Não pedido |
| Vários talhões por agendamento | O app trabalha com a localização atual; não há cadastro de talhões |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --------------------- | -------------- | --------- | ---------- |
| Onde guardar | Nova tabela no `AppDatabase` (drift) que o app já usa | Funciona offline, sem dependência nova de banco; é o equivalente do Room | y |
| Conta | A Agenda exige login e cada linha guarda o `uid` do Firebase Auth; só aparecem os do usuário logado | Decisão do usuário; separa contas no mesmo aparelho | y |
| Firestore | Sai do projeto: dependência `cloud_firestore` e rascunho de regras removidos | Nenhum código commitado usa; manter seria dependência morta | y |
| Aparelhos com o banco atual (v1) | Migração para a v2 cria a tabela e preserva o cache de previsão | O aparelho de teste já tem o banco v1 | y |
| Janela de datas | De hoje até o último dia da previsão: hoje + 6 dias (a previsão pede 7 dias) | Decisão do usuário: não agendar no passado nem além do que se consegue prever | y |
| Janela sem previsão carregada | Mesma janela (hoje + 6), calculada pela constante de dias da previsão, não pela previsão baixada | Offline sem cache o produtor ainda consegue agendar | y |
| Observação | Opcional, até 200 caracteres, espaços nas pontas removidos; vazia vira "sem observação" | Ex.: "talhão 3, ureia" | y |
| Editar | Data e observação de agendamentos não concluídos, com a mesma janela de datas | Concluído é histórico; para mudar, desfaz a conclusão antes | y |
| Concluir | Marca como aplicado com o momento da conclusão; pode ser desfeito | Dá histórico do que foi feito | y |
| Organização da lista | Duas seções: "Próximos" (não concluídos, por data crescente) e "Concluídos" (por data decrescente) | O que falta fazer fica em cima | y |
| Agendamento não concluído com data passada | Fica em "Próximos" com o rótulo "Data passada" no lugar do risco | Só existe se o produtor não marcou; ele decide concluir ou excluir | y |
| O que é "risco" | Agendamento não concluído, de hoje em diante, cujo dia existe na previsão com chuva acima do limiar de perigo do motor de decisão | Mesma regra na Agenda e no painel: as duas telas nunca discordam | y |
| O que é "lembrete" | Agendamento não concluído para hoje ou amanhã (data local do aparelho) que não está em risco | Decisão do usuário: alerta e lembrete do dia | y |
| Risco e lembrete ao mesmo tempo | Só o alerta de risco aparece | Evita dois cards; o risco é o que exige ação | y |
| Previsão do cache (offline) | O aviso usa a mesma previsão exibida no painel, inclusive a do cache | O painel já avisa que o dado é antigo | y |

**Open questions:** none - all resolved or logged above.

---

## User Stories

### P1: Criar e consultar agendamentos ⭐ MVP

**User Story**: Como produtor, quero agendar a próxima aplicação de adubo no celular, mesmo sem internet no talhão, para planejar a semana.

**Why P1**: Sem criar e listar, a feature não existe.

**Acceptance Criteria**:

1. WHEN o usuário logado confirma uma data no seletor THEN the system SHALL gravar o agendamento no banco local com o `uid` dele e exibi-lo na lista sem reabrir a tela.
2. The system SHALL oferecer no seletor apenas datas de hoje até hoje + 6 dias, pela data local do aparelho.
3. WHEN o usuário informa uma observação THEN the system SHALL gravá-la sem os espaços das pontas, limitada a 200 caracteres.
4. IF a observação está vazia ou só tem espaços THEN the system SHALL gravar o agendamento sem observação.
5. WHEN o app é fechado e aberto de novo THEN the system SHALL exibir na Agenda os agendamentos gravados antes.
6. WHILE o aparelho está sem internet the system SHALL criar, listar, editar, concluir e excluir agendamentos normalmente.
7. The system SHALL exibir na Agenda apenas os agendamentos cujo `uid` é o do usuário logado.
8. The system SHALL exibir os não concluídos na seção "Próximos", por data crescente, e os concluídos na seção "Concluídos", por data decrescente.
9. The system SHALL exibir em cada agendamento de "Próximos", de hoje em diante, o risco do dia: favorável, risco de chuva forte, ou sem previsão.
10. The system SHALL exibir o rótulo "Data passada" em agendamento não concluído com data anterior a hoje.
11. IF não há usuário logado THEN the system SHALL recusar gravação, edição, conclusão e exclusão com falha de autenticação, sem alterar o banco.
12. IF uma escrita no banco falha THEN the system SHALL mostrar a mensagem de erro e manter a lista como estava.
13. WHEN o app atualiza a partir do banco na versão 1 THEN the system SHALL criar a tabela de agendamentos e manter o cache de previsão existente.
14. The system SHALL funcionar sem o pacote `cloud_firestore` e sem configuração no console do Firebase além do login.

**Independent Test**: Em modo avião, abrir a Agenda, criar um agendamento para daqui a 3 dias com a observação "talhão 3", fechar o app, reabrir e ver o agendamento na lista com a observação.

---

### P1: Aviso no painel ⭐ MVP

**User Story**: Como produtor, quero ser avisado no painel quando um plano ficou arriscado ou quando é hora de aplicar, sem precisar abrir a Agenda.

**Why P1**: É o que o usuário definiu como "completo": o valor do agendamento é o alerta antecipado.

**Acceptance Criteria**:

1. WHEN há pelo menos um agendamento em risco THEN the system SHALL mostrar no painel um alerta de risco com a quantidade de agendamentos em risco.
2. WHEN nenhum agendamento está em risco e há agendamento não concluído para hoje THEN the system SHALL mostrar um lembrete de aplicação para hoje.
3. WHEN nenhum agendamento está em risco, não há para hoje e há agendamento não concluído para amanhã THEN the system SHALL mostrar um lembrete de aplicação para amanhã.
4. WHEN não há agendamento em risco nem não concluído para hoje ou amanhã THEN the system SHALL não mostrar aviso.
5. WHEN o usuário toca no aviso THEN the system SHALL abrir a Agenda.
6. The system SHALL ignorar no aviso os agendamentos concluídos e os com data anterior a hoje.
7. WHEN um agendamento é criado, editado, concluído ou excluído na Agenda THEN the system SHALL atualizar o aviso do painel ao voltar para ele, sem puxar para atualizar.
8. IF a leitura dos agendamentos falha THEN the system SHALL exibir o painel normalmente, sem aviso.
9. The system SHALL obter a data de hoje de um relógio injetável, para decidir "hoje", "amanhã", "data passada" e a janela do seletor.

**Independent Test**: Criar um agendamento para amanhã num dia sem chuva e ver o lembrete no painel; com chuva forte prevista para esse dia, ver o alerta de risco no lugar.

---

### P2: Editar agendamento

**User Story**: Como produtor, quero mudar a data ou a observação de um plano quando a previsão muda, sem apagar e criar de novo.

**Why P2**: Contornável com excluir e criar, mas é o fluxo natural quando o alerta de risco aparece.

**Acceptance Criteria**:

1. WHEN o usuário edita a data ou a observação de um agendamento não concluído THEN the system SHALL gravar a alteração e atualizar a lista e o risco do dia.
2. The system SHALL aplicar na edição a mesma janela de datas e as mesmas regras de observação da criação.
3. IF a data atual do agendamento está fora da janela THEN the system SHALL abrir o seletor em hoje.
4. The system SHALL não oferecer edição para agendamentos concluídos.

**Independent Test**: Editar um agendamento em risco para outro dia sem chuva e ver o rótulo mudar para "Previsão favorável".

---

### P2: Concluir agendamento

**User Story**: Como produtor, quero marcar a aplicação como feita, para guardar o histórico e parar de receber aviso dela.

**Why P2**: Sem isso o plano antigo continua em "Próximos" como "Data passada".

**Acceptance Criteria**:

1. WHEN o usuário marca um agendamento como concluído THEN the system SHALL gravar o momento da conclusão e movê-lo para "Concluídos".
2. WHEN o usuário desfaz a conclusão THEN the system SHALL apagar o momento da conclusão e devolvê-lo para "Próximos".

**Independent Test**: Concluir um agendamento de hoje, ver o lembrete sumir do painel e o item em "Concluídos"; desfazer e ver os dois voltarem.

---

### P1: Excluir agendamento ⭐ MVP

**User Story**: Como produtor, quero apagar um plano que não vou mais fazer.

**Why P1**: Sem excluir, a lista acumula planos desistidos que viram avisos falsos.

**Acceptance Criteria**:

1. WHEN o usuário confirma a exclusão no diálogo THEN the system SHALL remover o agendamento do banco e da lista.
2. WHEN o usuário cancela o diálogo THEN the system SHALL manter o agendamento.

**Independent Test**: Excluir um agendamento e reabrir o app: ele não volta.

---

## Edge Cases

- WHEN há um agendamento para hoje e ele está em risco THEN the system SHALL mostrar o alerta de risco, e não o lembrete.
- WHEN há um agendamento em risco e outro para amanhã sem risco THEN the system SHALL mostrar só o alerta de risco, contando 1.
- WHEN há dois agendamentos no mesmo dia THEN the system SHALL tratá-los como distintos na lista e na contagem.
- WHEN o painel ainda não tem previsão (carregando ou erro) THEN the system SHALL não mostrar alerta de risco, e o lembrete de hoje/amanhã SHALL seguir valendo.
- WHEN o dia vira com a Agenda aberta THEN the system SHALL usar a nova data na próxima vez que o seletor abrir.
- IF a observação tem mais de 200 caracteres THEN the system SHALL impedir a digitação além do limite.

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| -------------- | ----- | ----- | ------ |
| AGD-01 | P1 Criar: gravar com uid | T7, T8, T11, T14 | ✅ Verified |
| AGD-02 | P1 Criar: janela de datas | T2, T4, T9, T12 | ✅ Verified |
| AGD-03 | P1 Criar: observação normalizada | T5, T9, T12 | ✅ Verified |
| AGD-04 | P1 Criar: observação vazia | T5, T9 | ✅ Verified |
| AGD-05 | P1 Criar: persistir entre execuções | T6, T7 | ✅ Verified |
| AGD-06 | P1 Criar: offline | T8 | ✅ Verified |
| AGD-07 | P1 Criar: só do usuário | T7, T8 | ✅ Verified |
| AGD-08 | P1 Criar: seções e ordem | T7, T11, T14 | ✅ Verified |
| AGD-09 | P1 Criar: risco por item | T11, T13 | ✅ Verified |
| AGD-10 | P1 Criar: data passada | T3, T11, T13 | ✅ Verified |
| AGD-11 | P1 Criar: sem login recusa | T8 | ✅ Verified |
| AGD-12 | P1 Criar: falha de escrita | T7, T8, T11, T14 | ✅ Verified |
| AGD-13 | P1 Criar: migração v1 → v2 | T1, T6 | ✅ Verified |
| AGD-14 | P1 Criar: sem Firestore | T8 | ✅ Verified |
| AGD-15 | P1 Aviso: alerta de risco com contagem | T10, T15, T16 | ✅ Verified |
| AGD-16 | P1 Aviso: lembrete de hoje | T3, T10, T16 | ✅ Verified |
| AGD-17 | P1 Aviso: lembrete de amanhã | T3, T10, T16 | ✅ Verified |
| AGD-18 | P1 Aviso: sem aviso | T10, T16 | ✅ Verified |
| AGD-19 | P1 Aviso: toque abre a Agenda | T16 | ✅ Verified |
| AGD-20 | P1 Aviso: ignora concluídos e passados | T10 | ✅ Verified |
| AGD-21 | P1 Aviso: atualiza ao voltar | T15, T16 | ✅ Verified |
| AGD-22 | P1 Aviso: falha não quebra o painel | T15 | ✅ Verified |
| AGD-23 | P1 Aviso: relógio injetável | T2, T10, T15 | ✅ Verified |
| AGD-24 | P2 Editar: grava e reavalia | T9, T11, T14 | ✅ Verified |
| AGD-25 | P2 Editar: mesmas regras | T4, T9, T12 | ✅ Verified |
| AGD-26 | P2 Editar: data fora da janela | T4, T12 | ✅ Verified |
| AGD-27 | P2 Editar: concluído não edita | T13 | ✅ Verified |
| AGD-28 | P2 Concluir: marcar | T5, T7, T9, T11, T13 | ✅ Verified |
| AGD-29 | P2 Concluir: desfazer | T7, T9, T11, T13 | ✅ Verified |
| AGD-30 | P1 Excluir: confirmar | T7, T11, T14 | ✅ Verified |
| AGD-31 | P1 Excluir: cancelar | T14 | ✅ Verified |

Mapeamento: AGD-01..14 = ACs 1–14 de "Criar"; AGD-15..23 = ACs 1–9 de "Aviso"; AGD-24..27 = "Editar"; AGD-28..29 = "Concluir"; AGD-30..31 = "Excluir".

**Coverage:** 31 total, 31 mapped to tasks, 0 unmapped

---

## Success Criteria

- [ ] Em modo avião, criar, editar, concluir, fechar, reabrir e excluir um agendamento funciona do começo ao fim no aparelho.
- [ ] O painel mostra o aviso certo nos quatro cenários: risco, hoje, amanhã e nenhum.
- [ ] `flutter analyze` limpo, testes passando e nenhuma referência a `cloud_firestore` no projeto.
