---
name: "Microtarefa UI (Vue2 + Quasar + DevExtreme)"
about: "Tarefa pequena e objetiva para alterar 1 componente Vue2 (patch mínimo) com padrão de UX"
title: "[UI][<MÓDULO>] <Componente/Tela> - <ação curta>"
labels: ["ui", "vue2", "quasar", "devextreme"]
---

## Vue 2 component

**Arquivo:** `src/components/<xxxx>.vue`  
*(opcional)* **Service:** `src/services/api/<yyyy>.js`

### Objetivo
- <descreva 1 coisa só, bem específica>
- <regra de fallback, se existir>

### Regras
- Alterar somente este componente (e o service opcional, se listado acima)
- Patch mínimo
- Manter lógica, props, nomes e comportamento existentes
- Não refatorar estrutura nem layout
- Não criar novos componentes
- Não alterar CSS global
- Não alterar endpoints nem contrato de API

### Entrada
- Campos/props/dados já existentes que devem ser usados:
  - <ex.: nm_icone_modulo, cd_modulo, nm_modulo>
- Exemplo de payload/objeto (se ajudar):
  ```json
  { "campo": "valor" }
  ```

### Entrega
- Componente completo atualizado
- Manter toda a lógica existente
- Somente implementar o objetivo acima (sem melhorias extras)

### Critérios de aceite
- [ ] Funciona no cenário principal
- [ ] Mantém comportamento anterior quando a condição não se aplica
- [ ] Sem warnings críticos no console
- [ ] Sem alterar layout geral do módulo

### Como testar
1) <passo 1>  
2) <passo 2>  
3) <resultado esperado>

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
```
