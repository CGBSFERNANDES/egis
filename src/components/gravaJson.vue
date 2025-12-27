<template>
  <div>
    gravei json aqui ! .
    <br />
    {{ json }}
  </div>
</template>

<script>
import Incluir from "../http/incluir_registro";
import notify from "devextreme/ui/notify";

export default {
  props: {
    json: { type: Array },
    Parametros: { type: Object },
  },
  //async GravaVM(json,parametros){
  //  if(this.nm_json != null){
  //    this.resultado = await Incluir.incluirRegistro(api,this.nm_json);
  //  }
  //},
  data() {
    return {
      nm_json: {},
      resultado: [],
      sParametros: {},
      cd_usuario: 0,
    };
  },
  created() {
    this.nm_json = this.json;
    this.sParametros = this.Parametros;
    this.cd_usuario = localStorage.cd_usuario;
  },

  async mounted() {
    //let api = '686/1026'; //1519 - pr_api_gera_migracao_tabela
    //if(this.sParametros.)
    this.GravaVM();
  },
  watch: {
    json() {
      this.nm_json = this.json;
    },
    Parametros() {
      this.sParametros = this.Parametros;
    },
  },
  methods: {
    async GravaVM() {
      if (this.nm_json != null) {
        let api = localStorage.apiV;
        let js = JSON.stringify(JSON.parse(JSON.stringify(this.nm_json)));
        //let js =  this.nm_json
        if (js.length > 838239) {
          notify(
            "Arquivo muito grande ou incompat�vel para transforma��o em JSON!"
          );
          return;
        }
        let j = {
          cd_parametro: 8,
          json_vm: js, //JSON.stringify(JSON.parse(this.nm_json)),
          cd_interno: localStorage.cd_retorno,
          ic_grava_json: localStorage.ic_grava,
          cd_usuario: this.cd_usuario,
        };
        this.resultado = await Incluir.incluirRegistro(api, j);
      }
    },
  },
};
</script>

<style></style>
