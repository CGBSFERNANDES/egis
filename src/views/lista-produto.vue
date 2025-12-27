<template>
  <div>
    <q-btn
      rounded
      color="primary"
      icon="checklist"
      label="Lista Padrão"
      @click="ParametrosObrigatorios()"
    />
    <q-dialog v-model="load" persistent full-width>
      <q-card class="bg-light-blue-1 popup-grid">
        <q-toolbar>
          <q-avatar color="blue-10" text-color="white" icon="checklist">
          </q-avatar>

          <q-toolbar-title
            ><span class="text-weight-bold"
              >Seleção de serviço por Tipo de Equipamento</span
            ></q-toolbar-title
          >

          <q-btn flat round dense icon="close" v-close-popup />
        </q-toolbar>

        <q-card-section>
          <div class="row">
            <q-select
              rounded
              outlined
              bottom-slots
              class="margin1 col-6"
              v-model="lista_material"
              :options="lookup_lista_material"
              option-value="cd_lista"
              option-label="nm_lista_material"
              label="Serviço"
              @input="SelectLista()"
            >
              <template v-slot:prepend>
                <q-icon name="precision_manufacturing"></q-icon>
              </template>
            </q-select>
            <q-checkbox
              v-model="ic_marca_todos"
              label="Marcar/Desmarcar todos"
            />
          </div>
          <div class="row">
            <grid
              :cd_menuID="7789"
              :cd_apiID="916"
              :cd_parametroID="0"
              :nm_json="dataSourceConfig"
              :att_json="attDataSource"
              :multipleSelection="true"
              :selectAll="ic_marca_todos"
              @LinhasSelecionadas="lista_selecionada = $event"
            >
            </grid>
          </div>
        </q-card-section>
        <q-card-actions class="margin1" align="right">
          <q-btn
            class="margin1"
            rounded
            label="Confirmar"
            color="primary"
            icon="check"
            v-close-popup
            @click="onConfirmar()"
          ></q-btn>
          <q-btn
            class="margin1"
            rounded
            label="Cancelar"
            icon="close"
            color="red"
            v-close-popup
          ></q-btn>
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import Lookup from "../http/lookup";
import notify from "devextreme/ui/notify";

export default {
  props: {
    ic_parametro_obrigatorio: { type: Boolean, default: true },
    nm_parametro_obrigatorio: { type: String, default: "" },
  },
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_cliente: localStorage.cd_cliente,
      cd_modulo: localStorage.cd_modulo,
      cd_menu: localStorage.cd_menu,
      cd_api: localStorage.cd_api,
      load: false,
      api: "",
      //////////////////////
      data_hoje: new Date(),
      ic_marca_todos: false,
      lista_selecionada: [],
      lista_material: "",
      lookup_lista_material: [],
      dataSourceConfig: {
        cd_parametro: 0,
        cd_usuario: localStorage.cd_usuario,
      },
      attDataSource: false,
    };
  },
  async created() {
    let lookup_lista = await Lookup.montarSelect(this.cd_empresa, 5230);
    this.lookup_lista_material = JSON.parse(
      JSON.parse(JSON.stringify(lookup_lista.dataset)),
    );
  },
  computed: {},

  watch: {},
  components: {
    grid: () => import("../views/grid"),
  },
  methods: {
    ParametrosObrigatorios() {
      if (!this.ic_parametro_obrigatorio) {
        this.nm_parametro_obrigatorio != ""
          ? notify(`Selecione ${this.nm_parametro_obrigatorio}`)
          : notify(`Faltam informações`);
      } else {
        this.load = true;
      }
    },
    SelectLista() {
      this.dataSourceConfig.cd_lista = this.lista_material.cd_lista;
      this.attDataSource = !this.attDataSource;
    },
    onConfirmar() {
      this.$emit("listaSelecionada", this.lista_selecionada);
    },
  },
};
</script>

<style scoped>
@import url("./views.css");

.popup-grid {
  width: 100%;
  height: 100%;
}
</style>
