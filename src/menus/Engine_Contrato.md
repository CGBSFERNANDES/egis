# Engine Único – Contrato (unicoFormEspecial.vue)

Este documento define o **contrato oficial** do Engine Único (`unicoFormEspecial.vue`) para criação rápida de novos menus no padrão `my_<ID>.vue`.

> Objetivo: **todo menu novo** deve ser criado como *wrapper* fino (`my_<id>.vue`) que apenas configura `props/overrides/hooks/slots`, sem reimplementar CRUD.

---

## 1) Componente Engine

**Arquivo:** `src/views/unicoFormEspecial.vue`  
**Uso:** `<unico-form-especial ... />`

---

## 2) Props (entrada)

### 2.1 Props já existentes (legado)
> Ajuste os nomes aqui conforme o que você já usa no projeto.

- `cd_menu_entrada: Number` – id do menu
- `cd_acesso_entrada: Number` – id de acesso/perfil do usuário
- `modo_inicial: String` – ex: `"GRID"` | `"EDIT"`
- `embedMode: Boolean` – modo embutido (quando usado dentro de modal/aba)
- `registro_pai: Object` – contexto/pai (quando é “filho”)
- `cd_chave_registro: Number` – chave do registro a abrir direto

### 2.2 Props novas (padrão do Engine Único)

#### `overrides: Object`
Configurações por menu, sem alterar o Engine.

Exemplos suportados/recomendados:

- `title: String` – título exibido no topo
- `gridPageSize: Number` – tamanho da página do grid
- `defaultFilters: Object` – filtros default aplicados antes da primeira consulta
- `forceMode: String` – força modo `"GRID"` ou `"EDIT"` ao abrir
- `hideButtons: Object` – controla exibição de botões padrão

Exemplo:
```js
overrides: {
  title: "Cadastro de Clientes",
  gridPageSize: 200,
  defaultFilters: { status: "ATIVO" },
  hideButtons: { excel: false, pdf: true, filtro: false, novo: false }
}
```

#### `hooks: Object`
Callbacks para customizações por menu, sem `if (cd_menu...)` no Engine.

> Cada hook recebe um `ctx` (contexto) e pode retornar algo (quando aplicável).

Hooks mínimos (MVP):

- `beforeLoadMeta(ctx)`
- `afterLoadMeta(ctx)`
- `beforeFetchRows(ctx)`
- `afterFetchRows(ctx)`
- `beforeOpenEdit(ctx)`
- `mapPayload(ctx) -> payload` *(opcional)*
- `beforeSave(ctx)`
- `afterSave(ctx)`
- `beforeDelete(ctx)`
- `afterDelete(ctx)`
- `onError(ctx)`

**Formato do ctx (mínimo recomendado):**
- `cd_menu`
- `modo`
- `registro`
- `payload`
- `filtros`
- `meta`
- `rows`
- `response`
- `engine` (referência ao componente)

Exemplo:
```js
hooks: {
  beforeFetchRows: async ({ filtros }) => {
    if (filtros.status == null) filtros.status = "ATIVO"
  },
  mapPayload: async ({ payload }) => ({ ...payload, cd_empresa: 1 }),
  onError: async ({ err, hook }) => console.error(hook, err),
}
```

#### `services: Object`
Injeção de dependências (opcional), para desacoplar e facilitar testes/automação.
Exemplos:
- `api` (cliente HTTP)
- `notify` (toast/alert)
- `confirm` (dialog)
- `formatters`

---

## 3) Slots (extensão visual)

Slots suportados (MVP):

- `toolbar-left`
- `toolbar-right`
- `form-custom`
- `form-footer`

Cada slot recebe `:engine="this"` para o wrapper conseguir acessar estado, rows, seleção etc.

Exemplo:
```vue
<template #toolbar-right="{ engine }">
  <q-btn icon="bolt" @click="acao(engine)" />
</template>
```

---

## 4) Eventos emitidos pelo Engine

Eventos recomendados/legado (mantidos):

- `@selecionou="(registro) => {}"`
- `@voltar="() => {}"`
- `@fechar="() => {}"`

> Se existirem outros `emit`, documente aqui.

---

## 5) Regras do projeto (importante)

1. **Todo menu novo** deve ser um wrapper `my_<id>.vue`.
2. O wrapper **não deve** reimplementar CRUD (apenas configurar o Engine).
3. Tela “especial” só quando não cabe no padrão (wizard, dashboard custom, fluxo multi-etapas).
4. Personalizações por menu devem preferir `overrides`, `hooks` e `slots`.

---

## 6) Checklist do menu (tarefa mínima)

Para cada menu novo:

1. Criar `my_<id>.vue` usando `_template_my.vue`
2. Registrar rota/menu
3. Backend:
   - procedure de listagem
   - procedure de salvar (I/U)
   - procedure de excluir (se aplicável)
4. Metadados do menu (campos, tipos, lookup, obrigatórios, máscaras)
5. Teste:
   - listar → filtrar → incluir → editar → excluir
