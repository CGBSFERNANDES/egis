<template>
  <div>
    <div class="div-iframe" id="divP">
      <div class="div-iframe" id="jitsi-meet-conf-container">
        <!-- <iframe
          allow="geolocation; microphone;camera"
          :src="nm_link_atendimento"
          v-if="!!nm_link_atendimento"
        ></iframe> -->
      </div>
    </div>
  </div>
</template>
<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://meet.jit.si/external_api.js"></script>
<script>
import notify from "devextreme/ui/notify";
//
let api;
export default {
  name: "callJitsi",
  props: {
    nm_link_atendimento: {
      type: String,
      default() {
        return "";
      },
    },
    nm_titulo_atendimento: {
      type: String,
      default() {
        return "Atendimento";
      },
    },
    usuario: {
      type: String,
      default() {
        return localStorage.usuario;
      },
    },
  },
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_modulo: localStorage.cd_modulo,
      counter: null,
      nm_usuario: localStorage.usuario,
    };
  },
  async created() {
    if (!!this.nm_link_atendimento == false) {
      notify("Atendimento não encontrado");
    }
    if (!!this.usuario) {
      this.nm_usuario = this.usuario;
    }
  },
  async mounted() {
    await this.Join();
  },
  destroyed() {
    clearInterval(this.counter);
  },
  methods: {
    async Join() {
      try {
        const altura = window.innerHeight - 100;
        const options = {
          roomName: this.nm_titulo_atendimento,
          width: "100%",
          height: altura,
          parentNode: document.getElementById("jitsi-meet-conf-container"),
          lang: "pt",
          configOverwrite: {
            disableDeepLinking: true,
            toolbarButtons: ["microphone", "camera", "chat"],
          },
          interfaceConfigOverwrite: {},
        };
        api = new JitsiMeetExternalAPI("meet.jit.si", options);
        api.addEventListener("videoConferenceJoined", (item) => {
          api.executeCommand(this.nm_titulo_atendimento, this.nm_usuario);
        });
      } catch (error) {
        console.error("Error: ", error);
      }
    },
  },
};
</script>

<style scoped>
@import url("../views/views.css");
iframe {
  width: 100%;
  height: 100%;
  padding: 0;
  margin: 0;
}
.div-iframe {
  height: calc(100vh - 100px);
  width: 100%;
  margin: 0;
  padding: 0;
}
</style>
