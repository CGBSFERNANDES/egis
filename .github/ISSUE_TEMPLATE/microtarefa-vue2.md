# Template – Microtarefa UI (Vue 2 + Quasar + DevExtreme)

Use este template para criar Issues pequenas, objetivas e seguras para execução no Vue2.
A regra é: **1 microtarefa = 1 objetivo = 1 arquivo (no máximo 2, se precisar do service de API)**.

## Título (padrão)
```
[UI][<MÓDULO>] <Componente/Tela> - <ação curta>
```

## Descrição (copiar e colar)
```text
Vue 2 component.

Arquivo: src/components/<xxxx>.vue
(opcional) Service: src/services/api/<yyyy>.js

Objetivo:
- <descreva 1 coisa só, bem específica>
- <regra de fallback, se existir>

Regras:
- Alterar somente este componente (e o service opcional, se listado acima)
- Patch mínimo
- Manter lógica, props, nomes e comportamento existentes
- Não refatorar estrutura nem layout
- Não criar novos componentes
- Não alterar CSS global
- Não alterar endpoints nem contrato de API

Entrada:
- Campos/props/dados já existentes que devem ser usados:
  - <ex.: nm_icone_modulo, cd_modulo, nm_modulo>
- Exemplo de payload/objeto (se ajudar):
  { "campo": "valor" }

Entrega:
- Componente completo atualizado
- Manter toda a lógica existente
- Somente implementar o objetivo acima (sem melhorias extras)

Critérios de aceite:
- [ ] Funciona no cenário principal
- [ ] Mantém comportamento anterior quando a condição não se aplica
- [ ] Sem warnings críticos no console
- [ ] Sem alterar layout geral do módulo

Como testar:
1) <passo 1>
2) <passo 2>
3) <resultado esperado>
```

---

## Exemplo preenchido (ícone do módulo)
```text
Vue 2 component.

Arquivo: src/components/moduloComposicao.vue

Objetivo:
- Exibir o ícone do módulo no card quando `nm_icone_modulo` for diferente de ''.
- Quando `nm_icone_modulo` estiver vazio, manter o fallback atual (letra do módulo).

Regras:
- Alterar somente este componente
- Patch mínimo
- Manter lógica, props, nomes e comportamento existentes
- Não refatorar estrutura nem layout
- Não criar novos componentes
- Não alterar CSS global
- Não alterar endpoints nem contrato de API

Entrada:
- Campo já vem da API: `nm_icone_modulo`

Entrega:
- Componente completo atualizado
- Manter toda a lógica existente
- Somente adicionar renderização condicional do ícone

Critérios de aceite:
- [ ] Ícone aparece quando nm_icone_modulo preenchido
- [ ] Fallback por letra continua quando vazio
- [ ] Sem warnings no console
- [ ] Sem impacto em outros cards
```
