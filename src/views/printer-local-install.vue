<!-- Exemplo de componente -->
<template>
  <div>
    <button v-if="!alive" @click="baixarInstalador">Instalar impressor local</button>
    <button v-else @click="imprimir">Imprimir DANFE</button>
  </div>
</template>

<script>
import { isAgentAlive, printDanfe } from '@/services/agent';

export default {
  data: () => ({ alive: false, chave:'', banco:'' }),
  async created() { this.alive = await isAgentAlive(); },
  methods: {
    baixarInstalador() {
      // redirecione para a URL do seu .exe (Inno) hospedado
      window.location.href = 'https://egiserp.com.br/downloads/EGIS-Agent-Setup.exe';
    },
    async imprimir() {
      try {
        await printDanfe(this.chave, this.banco);
        this.$toast && this.$toast.success('Impressão enviada ao agente local.');
      } catch {
        this.$toast && this.$toast.error('Falha ao acionar o agente local.');
      }
    }
  }
}
</script>
