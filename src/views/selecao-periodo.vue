<template>
  <div>
    <h2 v-if="cd_volta_home == 0" class="content-block">Seleção de Período</h2>
    <div class="text-start text-subtitle1 q-pa-md">
      <div>
        Data Inicial:
      </div>
      <q-input type="date" filled v-model="data_inicial" class="bold-input">
      </q-input>
      Data Final:
      <q-input type="date" filled v-model="data_final" class="bold-input" />
    </div>
    <div id="form-demo">
      <div class="widget-container">
        <form action="your-action" @submit="handleSubmit">
          <q-date
            color="orange-9"
            text-color="white"
            mask="MM-DD-YYYY"
            v-model="data_final_inicial"
            range
          />
        </form>
        <div class="row justify-evenly">
          <q-btn
            class="q-ma-sm"
            color="orange-9"
            icon="check"
            rounded
            label="Alterar"
            @click="handleSubmit()"
          />
          <q-btn
            class="q-ma-sm"
            color="red-9"
            icon="close"
            rounded
            flat
            label="Cancelar"
            @click="handleClose()"
          />
        </div>
      </div>
    </div>
  </div>
</template>
<script>
  import notify from "devextreme/ui/notify";
  import ptMessages from "devextreme/localization/messages/pt.json";
  import { locale, loadMessages } from "devextreme/localization";
  import config from "devextreme/core/config";

  var datareg = {
    dt_inicial: "",
    dt_final: "",
  };

  export default {
    props: {
      cd_volta_home: { type: Number, default: 0 },
    },
    emits: ["FechaSelecao"],

    data() {
      return {
        datas: {},
        data_final_inicial: { from: "", to: "" },
        cd_usuario: localStorage.cd_usuario,
        cd_empresa: localStorage.cd_empresa,
        cd_modulo: localStorage.cd_modulo,
        data_inicial: "",
        data_final: "",
      };
    },

    async created() {
      config({ defaultCurrency: "BRL" });
      loadMessages(ptMessages);
      locale(navigator.language);

      datareg.dt_inicial = this.data_final_inicial.from;
      datareg.dt_final = this.data_final_inicial.to;

      datareg.dt_inicial = localStorage.dt_inicial;
      datareg.dt_final = localStorage.dt_final;

      this.data_final_inicial.from = localStorage.dt_inicial;
      this.data_final_inicial.to = localStorage.dt_final;

      this.data_inicial = this.formatDateYYYYMMDD(localStorage.dt_inicial);
      this.data_final = this.formatDateYYYYMMDD(localStorage.dt_final);

      this.datas = datareg;
    },
    watch: {
      data_inicial(newVal) {
        this.data_final_inicial = {
          ...this.data_final_inicial,
          from: this.formatDateMMDDYYYY(newVal),
        };
      },
      data_final(newVal) {
        this.data_final_inicial = {
          ...this.data_final_inicial,
          to: this.formatDateMMDDYYYY(newVal),
        };
      },
    },
    methods: {
      async handleSubmit() {
        this.$emit("click");
        if (this.data_final_inicial == null) return;

        //--->>Esta pegando a Data Base = "to" do Objeto <<---\\
        this.dt_base = this.data_final_inicial.to;
        //--->>Esta pegando a Data Inicial e Final do Objeto <<---\\
        localStorage.dt_inicial = this.data_final_inicial.from;
        localStorage.dt_final = this.data_final_inicial.to;

        localStorage.dt_base = this.dt_base;

        //if (this.$refs.modulo._isMounted == true) {
        //  await this.$refs.modulo.pollData();
        //}
        if (this.cd_volta_home != 1) {
          this.$router.push({
            name: "home",
            //query: { redirect: this.$route.path }
          });
        }

        notify(
          {
            message: "Período Selecionado!",
            position: {
              my: "center top",
              at: "center top",
            },
          },
          "success",
          500
        );
        const btn = document.querySelector("#CarregamentoF5");

        btn.click();
        notify("Datas Selecionadas com sucesso");
      },
      handleClose() {
        this.$emit("click");
      },
      formatDateYYYYMMDD(date) {
        const [month, day, year] = date.split("-");
        return `${year}-${month}-${day}`;
      },
      formatDateMMDDYYYY(date) {
        const [year, month, day] = date.split("-");
        return `${month}-${day}-${year}`;
      },
    },
  };
</script>

<style scoped>
  form {
    margin: 10px;
  }

  .bold-input >>> input {
    font-weight: bold;
  }
</style>
