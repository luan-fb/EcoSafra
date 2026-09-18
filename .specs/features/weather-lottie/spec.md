# Animações Lottie de clima no painel — Specification

## Problem Statement

O card "Agora" do painel mostra o clima com um ícone Material estático, o que deixa a tela com cara de protótipo. O produtor bate o olho no painel várias vezes por dia: uma animação que representa o clima (sol, sol com nuvem, nuvem, chuva, frio) comunica a condição mais rápido e dá o visual moderno que o app busca.

## Goals

- [ ] O card "Agora" mostra uma animação Lottie correspondente ao clima do dia em 100% dos códigos WMO e temperaturas (sem card "vazio").
- [ ] Nenhuma animação roda quando o sistema pede redução de movimento, e o card continua mostrando um desenho visível.

## Out of Scope

| Feature | Reason |
| ------- | ------ |
| Animação na lista "Próximos dias" | Decisão do usuário: 7 loops simultâneos poluem a tela e custam bateria; a lista continua com ícone estático |
| Animações próprias para neblina e tempestade | Não há arquivo; neblina usa a nuvem e tempestade usa a chuva |
| Variante noturna (lua) | Exigiria o campo `is_day` da Open-Meteo, que o app não busca hoje |
| Lottie em outras telas (agenda, splash) | Fora do pedido |
| Card "Agora" usar a hora atual em vez da primeira hora da resposta | Bug pré-existente (`hourly.first` é meia-noite); vai para uma tarefa própria |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --------------------- | -------------- | --------- | ---------- |
| Quais telas animam | Só o card "Agora" | Destaque único; lista estática evita ruído e custo | y |
| Climas sem animação própria | Neblina → nuvem; garoa/chuva/pancadas/tempestade → chuva | Sempre há animação; o rótulo em texto segue dizendo o clima exato | y |
| Comportamento da animação | Loop contínuo; quadro parado quando `MediaQuery.disableAnimations` é true | Padrão de ícone de clima, com respeito à acessibilidade | y |
| Código usado no card "Agora" | O `weatherCode` diário de hoje | A previsão horária do app não traz código de clima | y |
| Código WMO fora da tabela | Animação de nuvem | Mesmo fallback neutro que o ícone já usa | y |
| Falha ao carregar o arquivo Lottie | Ícone Material estático do mesmo código, e o erro é reportado ao `FlutterError` | O card nunca fica vazio e a falha não passa despercebida | y |
| Regra do frio | Temperatura arredondada ≤ 16 °C troca sol, sol com nuvem e nuvem pelo frio; chuva vence o frio | Chuva é a informação que importa para adubar | y |
| Temperatura usada no frio | A mesma exibida no card (`round()`) | Coerência: se o card mostra 16°, mostra o frio; 16,5° vira 17° e não é frio | y |
| Sol com nuvem | Códigos 1 e 2 | "Principalmente limpo" e "parcialmente nublado" | y |
| Nuvem do código 3 some no fim de cada ciclo | Aceito | Escolha do usuário pelo efeito visual do arquivo | y |
| Nome dos assets | `assets/lottie/sunny.json`, `partly_cloudy.json`, `cloudy.json`, `rainy.json`, `cold.json` | Nomes curtos, sem espaço | y |

**Open questions:** none - all resolved or logged above.

---

## User Stories

### P1: Animação de clima no card "Agora" ⭐ MVP

**User Story**: Como produtor, quero ver uma animação do clima no card "Agora" para entender a condição do dia de relance.

**Why P1**: É o pedido central da feature.

**Acceptance Criteria**:

1. WHEN o código WMO é 0 e a temperatura arredondada é maior que 16 THEN the system SHALL mapear para a animação `sunny`.
2. WHEN o código WMO é 3, 45 ou 48 e a temperatura arredondada é maior que 16 THEN the system SHALL mapear para a animação `cloudy`.
3. WHEN o código WMO é 51–57, 61–67, 80–82, 95, 96 ou 99 THEN the system SHALL mapear para a animação `rainy`, qualquer que seja a temperatura.
4. IF o código WMO não pertence a nenhuma faixa conhecida e a temperatura arredondada é maior que 16 THEN the system SHALL mapear para a animação `cloudy`.
5. WHEN o painel exibe a previsão THEN the system SHALL renderizar no card "Agora" o asset Lottie da animação mapeada, no lugar do ícone estático.
6. WHILE `MediaQuery.disableAnimations` é false the system SHALL tocar a animação em loop contínuo.
7. WHILE `MediaQuery.disableAnimations` é true the system SHALL exibir um quadro parado em que pelo menos 10% da área da animação está desenhada.
8. IF o asset Lottie falha ao carregar THEN the system SHALL exibir o ícone Material de `WeatherCondition.iconFor` para o mesmo código e reportar o erro ao `FlutterError`.
9. The system SHALL expor ao leitor de tela o rótulo do clima (`WeatherCondition.labelFor`) e nenhum rótulo vindo da animação.
10. WHEN o código WMO é 1 ou 2 e a temperatura arredondada é maior que 16 THEN the system SHALL mapear para a animação `partlyCloudy`.
11. WHEN o código WMO é 71–77, 85 ou 86 THEN the system SHALL mapear para a animação `cold`.
12. WHEN a temperatura arredondada é menor ou igual a 16 e o código mapearia para `sunny`, `partlyCloudy` ou `cloudy` THEN the system SHALL mapear para a animação `cold`.
13. The system SHALL limitar a animação a no máximo 30 quadros por segundo.
14. The system SHALL exibir na pílula de chuva do card o mesmo `rainNext48h` que a decisão de adubação usou.

**Independent Test**: Abrir o painel com previsão de céu limpo e 25° e ver o sol animado; com 14° ver o frio; ligar "Remover animações" no Android e ver o desenho parado.

---

### P2: Transição ao trocar de clima

**User Story**: Como produtor, quero que a troca de animação (cache → dado novo da rede) seja suave, para a tela não "piscar".

**Why P2**: O painel é cache-first: a animação pode mudar segundos depois de abrir, quando a previsão da rede chega.

**Acceptance Criteria**:

1. WHEN a animação mapeada muda entre dois builds THEN the system SHALL fazer um cross-fade entre a animação antiga e a nova.
2. WHEN o código muda mas a animação mapeada continua a mesma (ex.: 61 → 63) THEN the system SHALL manter a animação atual sem reiniciá-la.
3. WHILE `MediaQuery.disableAnimations` é true the system SHALL trocar a animação sem transição.

**Independent Test**: Abrir offline (cache de chuva), reconectar com previsão de sol e ver a troca com fade.

---

## Edge Cases

- IF o código WMO é negativo ou maior que 99 THEN the system SHALL tratá-lo como desconhecido (WLOT-04, sujeito ao frio de WLOT-14).
- IF o asset Lottie está corrompido, ausente ou não declarado no `pubspec` THEN the system SHALL exibir o ícone estático (WLOT-08).
- WHEN a temperatura é 16,4 °C THEN the system SHALL tratá-la como 16 (frio); WHEN é 16,5 °C THEN the system SHALL tratá-la como 17 (não frio).

---

## Requirement Traceability

Os ACs de P1 10–14 correspondem a WLOT-12 a WLOT-16; o AC 3 de P2 corresponde a WLOT-17.

| Requirement ID | Story | Phase | Status |
| -------------- | ----- | ----- | ------ |
| WLOT-01 | P1: mapeamento sunny | Execute | ✅ Verified |
| WLOT-02 | P1: mapeamento cloudy | Execute | ✅ Verified |
| WLOT-03 | P1: mapeamento rainy | Execute | ✅ Verified |
| WLOT-04 | P1: fallback de código desconhecido | Execute | ✅ Verified |
| WLOT-05 | P1: Lottie no card "Agora" | Execute | ✅ Verified |
| WLOT-06 | P1: loop contínuo | Execute | ✅ Verified |
| WLOT-07 | P1: quadro parado visível com redução de movimento | Execute | ✅ Verified |
| WLOT-08 | P1: fallback e reporte de asset com erro | Execute | ✅ Verified |
| WLOT-09 | P1: semântica para leitor de tela | Execute | ✅ Verified |
| WLOT-10 | P2: cross-fade na troca | Execute | ✅ Verified |
| WLOT-11 | P2: sem reinício na mesma animação | Execute | ✅ Verified |
| WLOT-12 | P1: mapeamento partlyCloudy | Execute | ✅ Verified |
| WLOT-13 | P1: mapeamento cold por código | Execute | ✅ Verified |
| WLOT-14 | P1: frio por temperatura | Execute | ✅ Verified |
| WLOT-15 | P1: limite de 30 fps | Execute | ✅ Verified |
| WLOT-16 | P1: chuva 48h igual à da decisão | Execute | ✅ Verified |
| WLOT-17 | P2: troca sem transição com redução de movimento | Execute | ✅ Verified |

**Coverage:** 17 total, 17 mapped to Execute, 0 unmapped

---

## Success Criteria

- [ ] Todo código WMO de 0 a 99, com temperatura quente e fria, resolve para a animação da tabela (coberto por teste).
- [ ] Com "Remover animações" ativo, nenhuma animação roda e o desenho parado é visível.
- [ ] `flutter analyze` limpo e testes passando.
