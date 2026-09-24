# Imagens do README

Capturas em PNG, retrato, tiradas no aparelho (~1080 px de altura). Os nomes abaixo são os
que o [README](../../README.md) já referencia.

| Arquivo | O que mostrar |
| --- | --- |
| `logo.png` | Ícone do app, fundo transparente, 512x512 |
| `hero.png` | Painel com o card de decisão verde e a animação do clima |
| `login.png` | Tela de login com Google |
| `painel.png` | Painel completo: cabeçalho, card de decisão, card "Agora" e próximos dias |
| `painel-offline.png` | Painel em modo avião, com o aviso "Sem internet. Mostrando a última previsão salva" |
| `agenda.png` | Agenda com itens em "Próximos" e "Concluídos" |
| `agendamento.png` | Formulário de novo agendamento com o seletor de data aberto |
| `aviso-risco.png` | Painel com o alerta vermelho de agendamento em dia de chuva forte |
| `tema-escuro.png` | Painel no tema escuro |
| `menu.png` | Menu lateral aberto |
| `demo.gif` (opcional) | Fluxo curto: abrir sem internet, agendar, ver o aviso no painel. Descomente a linha no README |

Para capturar direto do aparelho conectado:

```bash
adb exec-out screencap -p > docs/images/painel.png
```
