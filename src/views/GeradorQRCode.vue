<template>
  <div class="margin1">
    <h2 class="content-block col-8" v-show="!!tituloMenu != false">
      {{ tituloMenu }}
    </h2>
    <div>
      <q-option-group v-model="group" :options="options" color="primary" />
      <!-- QRCode Genérica -->
      <div v-if="group === '1'">
        <q-input v-model="QRCodePayload" label="Dados do QRCode">
          <template v-slot:append>
            <q-icon
              v-if="QRCodePayload"
              name="close"
              @click.stop="QRCodePayload = ''"
              class="cursor-pointer"
            />
          </template>
        </q-input>
        <transition name="slide-fade">
          <div v-if="QRCodePayload">
            <QRCode
              class="margin1"
              :value="QRCodePayload"
              :showContent="true"
              :options="{ width: 300, color: { dark: '#1a1a1a' } }"
            />
          </div>
        </transition>
      </div>
      <!-- PIX QRCode -->
      <div v-else-if="group === '2'">
        <div class="margin1 row">
          <q-input class="margin1 col-2" v-model="chave" label="Chave">
            <template v-slot:append>
              <q-icon
                v-if="chave"
                name="close"
                @click.stop="chave = ''"
                class="cursor-pointer"
              />
            </template>
          </q-input>
          <q-input class="margin1 col-2" v-model="nome" label="Nome">
            <template v-slot:append>
              <q-icon
                v-if="nome"
                name="close"
                @click.stop="nome = ''"
                class="cursor-pointer"
              />
            </template>
          </q-input>
          <q-input class="margin1 col-2" v-model="cidade" label="Cidade">
            <template v-slot:append>
              <q-icon
                v-if="cidade"
                name="close"
                @click.stop="cidade = ''"
                class="cursor-pointer"
              />
            </template>
          </q-input>
          <q-input
            class="margin1 col-2"
            v-model="valor"
            type="number"
            label="Valor"
          >
            <template v-slot:append>
              <q-icon
                v-if="valor"
                name="close"
                @click.stop="valor = ''"
                class="cursor-pointer"
              />
            </template>
          </q-input>
          <q-input class="margin1 col-2" v-model="txid" label="ID">
            <template v-slot:append>
              <q-icon
                v-if="txid"
                name="close"
                @click.stop="txid = ''"
                class="cursor-pointer"
              />
            </template>
          </q-input>
          <q-input class="margin1 col-2" v-model="message" label="Mensagem">
            <template v-slot:append>
              <q-icon
                v-if="message"
                name="close"
                @click.stop="message = ''"
                class="cursor-pointer"
              />
            </template>
          </q-input>
        </div>
        <div>
          <q-btn
            rounded
            class="margin1"
            color="primary"
            label="Gerar QRCode PIX"
            @click="gerarPayload"
          />
        </div>
        <transition name="slide-fade">
          <PIXQRCode
            v-if="ic_gera_pix"
            :chave="chave"
            :nome="nome"
            :cidade="cidade"
            :valor="parseFloat(valor)"
            :txid="txid"
            :message="message"
          />
        </transition>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  components: {
    QRCode: () => import("../components/QRCode.vue"),
    PIXQRCode: () => import("../components/PIXQRCode.vue"),
  },
  data() {
    return {
      tituloMenu: "Gerador de QR Code",
      group: "1",
      options: [
        {
          label: "Genérico",
          value: "1",
        },
        {
          label: "PIX",
          value: "2",
        },
      ],
      ic_gera_pix: false,
      QRCodePayload: "",
      chave: "",
      nome: "",
      cidade: "",
      valor: 0,
      txid: "",
      message: "",
    };
  },
  methods: {
    gerarPayload() {
      if (this.chave && this.nome && this.cidade) {
        this.ic_gera_pix = !this.ic_gera_pix;
      } else {
        this.$q.notify({
          type: "negative",
          message: "Preencha todos os campos obrigatórios.",
        });
      }
    },
  },
};
</script>
