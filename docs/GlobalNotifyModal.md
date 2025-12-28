# GlobalNotifyModal – Guia de uso em outros componentes

O `GlobalNotifyModal` (`src/components/GlobalNotifyModal.vue`) é um modal de alerta reutilizável que exibe mensagens com contexto de menu/tarefa e ações customizáveis. Este guia mostra como habilitar o componente em telas existentes, tomando `mostraUsuarioGrupo.vue` como referência.

## Quando usar
- Para padronizar mensagens de erro, aviso ou sucesso com título, sugestão de solução e ações.
- Quando for necessário reforçar o contexto da mensagem (menu e tarefa atual) sem criar banners específicos por tela.

## Propriedades principais
- `v-model` (`modelValue`): controla a visibilidade.
- `type`: `info` (padrão), `positive`, `negative`, `warning`. Define cor/ícone/título padrão.
- `title` e `message`: textos exibidos no cabeçalho e corpo.
- `solution`: dica opcional exibida em banner secundário.
- `menu` e `task`: contexto da navegação atual.
- `actions`: lista de botões. Se não for fornecida, um botão **Fechar** é aplicado automaticamente.
- `persistent`: mantém o modal aberto até que uma ação feche explicitamente.

## Passo a passo de integração
1) **Importe e registre o componente** no `components` da tela alvo.
2) **Crie um estado reativo** para centralizar os dados do modal.
3) **Adicione o modal ao template**, ligando `v-model` e as props mapeadas ao estado.
4) **Crie um helper** (`showNotify`/`showError`) para abrir o modal com mensagens consistentes.
5) **Reaja às ações emitidas** via `@action`, quando precisar (por exemplo, para reprocessar uma chamada).

```vue
<template>
  <div>
    <!-- resto da tela -->
    <global-notify-modal
      v-model="notify.visible"
      :type="notify.type"
      :title="notify.title"
      :message="notify.message"
      :solution="notify.solution"
      :menu="notify.menu"
      :task="notify.task"
      :actions="notify.actions"
      :persistent="notify.persistent"
      @action="handleNotifyAction"
    />
  </div>
</template>

<script>
import GlobalNotifyModal from "@/components/GlobalNotifyModal.vue";

export default {
  components: { GlobalNotifyModal },
  data() {
    return {
      notify: {
        visible: false,
        type: "info",
        title: "",
        message: "",
        solution: "",
        menu: "",
        task: "",
        actions: [],
        persistent: false,
      },
    };
  },
  methods: {
    showError(message, extra = {}) {
      this.notify = {
        ...this.notify,
        ...extra,
        visible: true,
        type: extra.type || "negative",
        title: extra.title || "Algo deu errado",
        message,
        menu: extra.menu || "Menu atual",
        task: extra.task || "Operação executada",
      };
    },
    handleNotifyAction(action) {
      if (action?.action === "retry") {
        // chame a rotina necessária, ex.: this.carregarModulosDoGrupo();
      }
    },
  },
};
</script>
```

## Exemplo aplicado: `mostraUsuarioGrupo.vue`
O componente possui pontos de erro em carregamento de módulos, menus e usuários. Use o helper para converter esses erros em modais consistentes:

```js
methods: {
  async carregarModulosDoGrupo() {
    try {
      // ... lógica existente
    } catch (error) {
      console.error("[mostraUsuarioGrupo] erro ao carregar módulos:", error);
      this.showError("Não foi possível carregar os módulos do grupo.", {
        menu: "Grupos de Usuário",
        task: "Carregar módulos",
        solution: "Confirme o grupo selecionado e tente novamente.",
        actions: [
          { label: "Tentar novamente", icon: "refresh", action: "retry", unelevated: true },
          { label: "Fechar", action: "close", flat: false, unelevated: true },
        ],
      });
    }
  },

  handleNotifyAction(action) {
    if (action?.action === "retry") {
      this.carregarModulosDoGrupo();
    }
  },
}
```

- **Onde colocar o modal:** preferencialmente na raiz do `template` da tela (próximo a outros dialogs) para manter a sobreposição correta.
- **Como inicializar:** reutilize o estado `notify` do exemplo acima e chame `showError`/`showNotify` em todos os `catch` ou pontos de validação onde hoje há `console.error` + `alert`/`notify` específicos.
- **Como customizar ações:** use o array `actions` para expor rotas rápidas (tentar novamente, abrir detalhe, ignorar). Defina `action: "close"` ou `closeOnClick` falso se precisar manter o modal aberto após o clique.

Seguindo o modelo acima, `mostraUsuarioGrupo.vue` e outros componentes passam a compartilhar a mesma experiência de alerta, com título, contexto e ações padronizados.
