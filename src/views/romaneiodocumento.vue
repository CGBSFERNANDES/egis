<template>
  <div id="pai">
    <div class="row items-end" style="height: auto">
      <div class="col">
        <q-btn
          class="margin1"
          color="orange-9"
          icon="print"
          round
          size="md"
          :loading="load"
          @click="PrintOut()"
        >
          <q-tooltip>
            Imprimir
          </q-tooltip>
        </q-btn>
      </div>
    </div>
    <carregando
      v-if="load_carregando == true"
      :corID="'orange-9'"
      :mensagemID="msg"
    ></carregando>

    <!------------------------------------->
    <div id="romaneioDocument" v-else>
      <div
        class="row"
        v-if="!dados[0].cd_nota_saida == 0 && mostra_canhoto == true"
      >
        <div class="canhoto margin1 col">
          <div class="row col text-subtitle2 justify-center margin1">
            <div class="col-10" style="display: block; font-size: 12px">
              RECEBEMOS DE ASSOCIACAO BRASILEIRA DE NORMAS TECNICAS. OS PRODUTOS
              CONSTANTES DA NOTA FISCAL INDICADA AO LADO.
            </div>
            <hr />
            <q-separator vertical color="black" style="margin-right:5px" />

            <div
              class="self-center items-center justify-center"
              style="display: block; font-size: 12px"
            >
              NF-e: {{ dados[0].cd_nota_saida }} - Série:
              {{ dados[0].cd_serie_nota }}
            </div>
          </div>

          <hr />
          <!--<q-separator color="black" />-->

          <div class="row text-subtitle2" style="font-size: 12px">
            <div class="col-2 row margin1">
              DATA DE RECEBIMENTO
              <br />
              {{ dados[0].dt_entrega_romaneio }}
            </div>

            <q-separator vertical color="black" />

            <div class="col margin1 " style="font-size: 12px">
              IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR
              <br />
              {{ dados[0].nm_responsavel }} -
              {{ dados[0].nm_documento_responsavel }}
            </div>
          </div>
        </div>
      </div>

      <div class="borda-bloco shadow-2 margin1" v-if="mostra_info == true">
        <div class="row items-center">
          <div class="col items-center text-subtitle1 margin1">
            <q-icon
              v-if="this.print == true"
              color="orange-10"
              style="font-size: 1.6em"
              name="bookmark"
            /><b> Romaneio:</b> {{ cd_romaneio }}
          </div>
          <div
            class="col text-subtitle1 margin1 "
          >
            <q-icon
              v-if="this.print == true"
              color="orange-10"
              style="font-size: 1.6em"
              name="location_on"
            />
            <b> CEP : </b>{{ dados_doc.cd_cep }}, {{ dados_doc.nm_endereco }} -
            {{ dados_doc.nm_bairro }} - {{ dados_doc.nm_cidade }} -
            {{ dados_doc.sg_estado }}
          </div>
        </div>

        <div class="row  items-center">
          <div class="col text-subtitle1 margin1 items-center">
            <q-icon
              v-if="this.print == true"
              color="orange-10"
              style="font-size: 1.6em"
              name="person"
            /><b> Cliente: </b>{{ cliente }}
          </div>
          <div
            class="col text-subtitle1 margin1"
          >
            <q-icon
              v-if="this.print == true"
              color="orange-10"
              style="font-size: 1.6em"
              name="two_wheeler"
            />
            <b> Entregador: </b>{{ dados_doc.nm_entregador }} -
            {{ dados_doc.nm_veiculo }}
          </div>
        </div>

        <div class="row  items-center">
          <div
            class="col text-subtitle1 margin1 items-center"
            v-show="this.dados[0].nm_obs_entrega !== ''"
          >
            <q-icon
              v-if="this.print == true"
              color="orange-10"
              style="font-size: 1.6em"
              name="wysiwyg"
            /><b> Observação: </b>{{ dados[0].nm_obs_entrega }}
          </div>
          <div
            class="col text-subtitle1 margin1 "
            v-show="this.dados[0].nm_motivo_ocorrencia !== ''"
          >
            <q-icon
              v-if="this.print == true"
              color="orange-10"
              style="font-size: 1.6em"
              name="priority_high"
            />
            <b> Ocorrência: </b>{{ dados[0].nm_motivo_ocorrencia }}
          </div>
        </div>
      </div>

      <div class="borda-bloco shadow-2  margin1">
        <div class="row text-subtitle1 margin1 ">
          <b>Comprovantes de Entrega - Romaneio -</b> {{ cd_romaneio }}
        </div>
        <img
          class="img-extrato"
          :src="pegaImgBase()"
          alt=""
        />
      </div>

      <div class="borda-bloco shadow-2  margin1">
        <div class="row text-subtitle1 margin1">
          <b> Assinatura - </b> {{ cliente }}
        </div>

        <img
          class="img-extrato"
          :src="pegaAssinatura()"
          alt=""
        />
      </div>
      <!----------------------------------------------------------------------------->
    </div>
  </div>
</template>

<script>
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import notify from "devextreme/ui/notify";
import funcao from "../http/funcoes-padroes";
import carregando from "../components/carregando.vue";

export default {
  props: {
    cd_romaneioID: { type: Number, default: 0 },
    dados_doc: { type: Object, default: Object },
    mostra_canhoto: { type: Boolean, default: false },
    mostra_info: { type: Boolean, default: false },
  },
  data() {
    return {
      load_carregando: true,
      cd_romaneio: 0,
      print: true,
      dados: [],
      cliente: "",
      load: false,
      responsavel: "",
      nm_ftp_empresa: localStorage.nm_ftp_empresa,
      msg: "Carregando documentos...",
    };
  },
  async created() {
    this.cd_romaneio = 0;
    this.responsavel = this.dados_doc.nm_responsavel;
    this.cd_romaneio = this.cd_romaneioID;
    localStorage.cd_parametro = this.cd_romaneio;
    localStorage.cd_cliente = 0;
  },
  async mounted() {
    this.print = false;
    await this.pesquisa();
    this.print = true;
  },

  methods: {
    async PrintOut() {
      try {
      this.load = true;
      this.print = false;
      //Retorna o tamanho da tela
      let tela = await funcao.TamanhoTela();

      let html = document.getElementById("romaneioDocument");

      //Configura o PDF que será baixado.
      let config = {
        orientation: "p",
        unit: "mm",
        format: [tela.largura, tela.largura * 1.2],
        putOnlyUsedFonts: false,
        nm_pdf: "Romaneio - " + this.cd_romaneio,
      };
      //Cria o documento PDF
      await funcao.ExportHTML(html, "B", config);

      await funcao.sleep(3000);
      
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(error)
    } finally {
      this.load = false;
      this.print = true;
      }
    },
    async pesquisa() {
      let apid = "";
      try {
        this.load_carregando = true;
        this.dados = await Menu.montarMenu(localStorage.cd_empresa, 0, 627); //'titulo';
        apid = this.dados.nm_identificacao_api; //627/889 - 1492 pr_consulta_romaneio_documento

        let sParametroApi = this.dados.nm_api_parametro;
        this.dados = await Procedimento.montarProcedimento(
          localStorage.cd_empresa,
          localStorage.cd_cliente,
          apid,
          sParametroApi
        );
      } catch (e) {
        if (this.dados[0].Cod == 0) {
          notify(this.dados[0].Msg);
          return;
        }
      } finally {
        this.load_carregando = false;
      }

      if (this.dados[0].Cod == 0) {
        notify(this.dados[0].Msg);
        return;
      }
      this.cliente = this.dados[0].nm_razao_social_cliente;
      this.pegaImgBase();
      this.pegaAssinatura();
      localStorage.cd_parametro = 0;
    },

    pegaImgBase() {
      var imagem = "";
      if(this.dados[0].vb_base64c) {
        imagem = "data:image/jpeg;base64," + this.dados[0].vb_base64c;
        return imagem;
      }
      if(this.dados[0].nm_ftp_comprovante) {
        imagem = `https://egis-store.com.br/api/download/${this.dados[0].nm_ftp_comprovante}/${this.nm_ftp_empresa}/RomaneioDocumento`;
        return imagem;
      }
    },

    pegaAssinatura() {
      var imagem = "";
      if(this.dados[0].vb_base64a){
        imagem = "data:image/jpeg;base64," + this.dados[0].vb_base64a;
        return imagem;
      }
      if(this.dados[0].nm_ftp_assinatura) {
        imagem = `https://egis-store.com.br/api/download/${this.dados[0].nm_ftp_assinatura}/${this.nm_ftp_empresa}/RomaneioDocumento`;
        return imagem;
      }
    },
  },
  components: {
    carregando,
  },
};
</script>

<style scoped>
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}
.img-extrato {
  max-width: 90vw;
  max-height: 600px;
}

.canhoto {
  border-radius: 10px;
  border: black 2px solid;
}
.margin1 {
  margin: 3px 5px;
}
.carregando {
  width: 100vw;
  margin: auto;
  overflow: hidden;
}
#romaneioDocument {
  width: 100vw * 1.2;
  height: 100vw * 1.2;
}
</style>
