# Animações Lottie de clima no painel — Specification

## Problem Statement

O card "Agora" do painel mostra o clima com um ícone Material estático, o que deixa a tela com cara de protótipo. O produtor bate o olho no painel várias vezes por dia: uma animação que representa o clima (sol, nuvem, chuva) comunica a condição mais rápido e dá o visual moderno que o app busca.

## Goals

- [ ] O card "Agora" mostra uma animação Lottie correspondente ao clima do dia em 100% dos códigos WMO (sem card "vazio").
- [ ] Nenhuma animação roda quando o sistema pede redução de movimento.

## Out of Scope

| Feature | Reason |
| ------- | ------ |
| Animação na lista "Próximos dias" | Decisão do usuário: 7 loops simultâneos poluem a tela e custam bateria; a lista continua com ícone estático |
| Animações próprias para neblina, neve e tempestade | Só existem 3 arquivos; esses climas são agrupados nos 3 existentes |
| Variante noturna (lua) | Exigiria o campo `is_day` da Open-Meteo, que o app não busca hoje |
| Lottie em outras telas (agenda, splash) | Fora do pedido |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --------------------- | -------------- | --------- | ---------- |
| Quais telas animam | Só o card "Agora" | Destaque único; lista estática evita ruído e custo | y |
| Climas sem animação própria | Agrupar: neblina/neve → nuvem; garoa/chuva/pancadas/tempestade → chuva | Sempre há animação; o rótulo em texto segue dizendo o clima exato | y |
| Comportamento da animação | Loop contínuo; quadro parado quando `MediaQuery.disableAnimations` é true | Padrão de ícone de clima, com respeito à acessibilidade | y |
| Código usado no card "Agora" | O `weatherCode` diário de hoje (o mesmo que o ícone usa hoje) | A previsão horária do app não traz código de clima; não muda a fonte de dados | y |
| Código WMO fora da tabela | Animação de nuvem | Mesmo fallback neutro que o ícone já usa (`cloud_queue`) | y |
| Falha ao carregar o arquivo Lottie | Mostra o ícone Material estático do mesmo código | O card nunca fica vazio | y |
| Nome dos assets | `assets/lottie/sunny.json`, `cloudy.json`, `rainy.json` | Nomes curtos, sem espaço (o original é `rainy icon.json`) | y |

**Open questions:** none - all resolved or logged above.

---

## User Stories

### P1: Animação de clima no card "Agora" ⭐ MVP

**User Story**: Como produtor, quero ver uma animação do clima no card "Agora" para entender a condição do dia de relance.

**Why P1**: É o pedido central da feature.

**Acceptance Criteria**:

1. WHEN o código WMO é 0 THEN the system SHALL mapear para a animação `sunny`.  <!-- event-driven -->
2. WHEN o código WMO é 1, 2, 3, 45, 48, 71–77, 85 ou 86 THEN the system SHALL mapear para a animação `cloudy`.
3. WHEN o código WMO é 51–57, 61–67, 80–82, 95, 96 ou 99 THEN the system SHALL mapear para a animação `rainy`.
4. IF o código WMO não pertence a nenhuma faixa conhecida THEN the system SHALL mapear para a animação `cloudy`.
5. WHEN o painel exibe a previsão THEN the system SHALL renderizar no card "Agora" o asset Lottie da animação mapeada para o `weatherCode` de hoje, no lugar do ícone estático.
6. WHILE `MediaQuery.disableAnimations` é false the system SHALL tocar a animação em loop contínuo.
7. WHILE `MediaQuery.disableAnimations` é true the system SHALL exibir a animação parada (`animate: false`).
8. IF o asset Lottie falha ao carregar THEN the system SHALL exibir o ícone Material de `WeatherCondition.iconFor` para o mesmo código.
9. The system SHALL expor ao leitor de tela o rótulo do clima (`WeatherCondition.labelFor`) e não a animação em si.

**Independent Test**: Abrir o painel com previsão de céu limpo e ver o sol animado no card "Agora"; ligar "Remover animações" no Android e ver o sol parado.

---

### P2: Transição ao trocar de clima

**User Story**: Como produtor, quero que a troca de animação (cache → dado novo da rede) seja suave, para a tela não "piscar".

**Why P2**: O painel é cache-first: a animação pode mudar segundos depois de abrir, quando a previsão da rede chega.

**Acceptance Criteria**:

1. WHEN a animação mapeada muda entre dois builds THEN the system SHALL fazer um cross-fade entre a animação antiga e a nova.
2. WHEN o código muda mas a animação mapeada continua a mesma (ex.: 61 → 63) THEN the system SHALL manter a animação atual sem reiniciá-la.

**Independent Test**: Abrir offline (cache de chuva), reconectar com previsão de sol e ver a troca com fade.

---

## Edge Cases

- IF o código WMO é negativo ou maior que 99 THEN the system SHALL mapear para `cloudy`.
- IF o asset Lottie está corrompido ou ausente THEN the system SHALL exibir o ícone estático (WLOT-08).

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
| -------------- | ----- | ----- | ------ |
| WLOT-01 | P1: mapeamento sunny | Execute | Verified |
| WLOT-02 | P1: mapeamento cloudy | Execute | Verified |
| WLOT-03 | P1: mapeamento rainy | Execute | Verified |
| WLOT-04 | P1: fallback de código desconhecido | Execute | Verified |
| WLOT-05 | P1: Lottie no card "Agora" | Execute | Verified |
| WLOT-06 | P1: loop contínuo | Execute | Verified |
| WLOT-07 | P1: redução de movimento | Execute | Verified |
| WLOT-08 | P1: fallback de asset com erro | Execute | Verified |
| WLOT-09 | P1: semântica para leitor de tela | Execute | Verified |
| WLOT-10 | P2: cross-fade na troca | Execute | Verified |
| WLOT-11 | P2: sem reinício na mesma animação | Execute | Verified |

**Coverage:** 11 total, 11 mapped to Execute, 0 unmapped

---

## Success Criteria

- [ ] Todo código WMO de 0 a 99 resolve para uma das 3 animações (coberto por teste).
- [ ] Com "Remover animações" ativo, nenhuma animação roda no painel.
- [ ] `flutter analyze` limpo e testes passando.
