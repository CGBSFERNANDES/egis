<template>
  <div class="q-pa-md">
    <div
      class="text-h3 text-center"
      v-if="dataSourceConfig.length === 0 && load === false"
    >
      Ordem de Serviço não encontrada
    </div>
    <div
      class="q-pa-sm "
      style="width: 795px; height: auto"
      id="pdfImpressBlock"
      v-if="dataSourceConfig.length > 0"
    >
      <div class="borderBlack" style="height: auto;">
        <div class="row q-pa-sm" style="height: auto">
          <div class="col">
            <img
              :src="imageLogo"
              alt="Logotipo"
              style="width: 220px;height: 100px; margin: 5px;"
            />
          </div>
          <div
            class=" text-italic text-bold text-center "
            style="font-size: 22px;"
          >
            Ordem de Serviço {{ cd_ordem_servico }}
          </div>
          <div
            class="col text-right text-italic"
            style="margin-top:30px;font-size: 18px;"
          >
            <div v-if="!!dataSourceConfig[0] === true">
              {{ dataSourceConfig[0].cd_telefone_empresa }}
            </div>
            <div v-if="!!dataSourceConfig[0] === true">
              {{ dataSourceConfig[0].nm_email_internet }}
            </div>
          </div>
        </div>
      </div>
      <div class="borderBlack " style="height: auto; margin-top: 10px;">
        <div
          class="borderBlack text-bold rotateText text-uppercase text-center "
          style="font-size:18px;height: 50px;margin-top: 200px;margin-bottom: -30px;width: 200px; padding-top:10px"
        >
          Cliente
        </div>
        <div
          style="margin-top: -250px;margin-left: 50px; "
          class="flex row q-pa-sm "
        >
          <div class="col text-left text-bold " style="font-size: 18px;">
            Cliente
          </div>
          <div class="col text-center text-bold  " style="font-size: 18px;">
            Fone
          </div>
          <div class="col text-center text-bold " style="font-size: 18px;">
            Prioridade
          </div>
          <div class="col text-right text-bold " style="font-size: 18px;">
            Data Emissão
          </div>
        </div>
        <div
          style="margin-left: 50px; border-bottom: 1px solid black;"
          class="flex row q-pa-sm"
        >
          <div class="col text-left" style="font-size: 16px;">
            {{ dataSourceConfig[0].nm_fantasia_cliente }}
          </div>
          <div class="col text-center" style="font-size: 16px;">
            {{ dataSourceConfig[0].cd_telefone_contato }}
          </div>
          <div class="col text-center" style="font-size: 16px;">
            {{ dataSourceConfig[0].nm_tipo_prioridade }}
          </div>
          <div class="col text-right" style="font-size: 16px;">
            {{ dataSourceConfig[0].dt_ordem_servico }}
          </div>
        </div>
        <div
          style="margin-left: 50px; border-bottom: 1px solid black;"
          class="flex row"
        >
          <div class="q-pa-sm" style="font-size: 16px;">
            Contato: {{ dataSourceConfig[0].nm_contato }}
          </div>
        </div>
        <div
          style="margin-left: 50px;border-bottom: 1px solid black; "
          class="flex row q-pa-sm"
        >
          <div class="col-11 text-left" style="font-size: 16px;">
            Observação
          </div>
          <div class="col-1 text-right " style="font-size: 16px;">
            Usuário
          </div>
        </div>
        <div
          style="margin-left: 50px; min-height: 46px;"
          class="flex row items-center q-pa-sm "
        >
          <div class="col-10 text-justify ">
            {{ dataSourceConfig[0].nm_obs_ordem_servico }}
          </div>
          <div class="col-2 text-right ">
            {{ dataSourceConfig[0].nm_usuario_impressao }}
          </div>
        </div>
      </div>
      <div style="margin-top: 10px; margin-bottom: 10px;">
        <div
          class="text-italic row items-center text-bold"
          style="font-size: 22px;margin-bottom: 5px;"
        >
          Detalhamento dos Produtos e Serviços
        </div>
        <div class="borderBlack" style="height: auto;">
          <div
            class="row justify-between items-center "
            style="font-size: 14px;padding: 0px 5px;"
          >
            <div class="col-1 text-bold text-center">
              It.
            </div>
            <div class="col-3 text-bold text-center">
              Produto
            </div>
            <div class="text-bold col-3 text-center">
              Arquivo
            </div>
            <div class="text-bold col-1 text-center">
              Forneada
            </div>
            <div class="text-bold col-1 text-center">
              Qtd.
            </div>
            <div class="text-bold col-1 text-center">
              Preço Unitário
            </div>
            <div class="text-bold col-1 text-center">
              Total R$
            </div>
          </div>
        </div>
        <div class="borderBlack" style="height: auto; min-height: 30px;">
          <div
            v-for="(item, index) in dataSourceConfig"
            :key="index"
            class="row justify-between item-center"
            style="font-size: 14px;border-bottom: 1px solid black;"
          >
            <div
              class="col-1 text-center"
              style="border-right: 1px solid black;"
            >
              {{ item.cd_item_ordem_servico }}
            </div>
            <div
              class="col-3 text-center"
              style="border-right: 1px solid black;"
            >
              {{ item.nm_fantasia_produto }}
            </div>
            <div
              class="col-3 text-center"
              style="border-right: 1px solid black;"
            >
              {{ item.nm_produto_ordem }}
            </div>
            <div
              class="col-1 text-center"
              style="border-right: 1px solid black;"
            >
              {{ item.ic_forneada }}
            </div>
            <div
              class="col-1 text-center"
              style="border-right: 1px solid black;"
            >
              {{ item.qt_item_produto }}
            </div>
            <div
              class="col-1 text-center"
              style="border-right: 1px solid black;"
            >
              {{ item.vl_unitario_produto }}
            </div>
            <div class="col-1 text-center">
              {{ item.vl_total_produto }}
            </div>
          </div>
        </div>

        <div
          class="borderBlack text-bold rotateText text-uppercase text-center "
          style="height: 50px;margin-top: 100px;margin-right: 0px;margin-bottom: -30px; padding: 0; width: 100px; margin-left: 0px; font-size: 18px;padding-top: 10px;"
        >
          Obs.
        </div>
        <div
          style="margin-top: -150px;margin-left: 50px;border: 1px solid black; height: 100px;"
          class=" flex row items-center q-pa-sm"
        >
          <div class="col-11" style="font-size: 14px;">
            Declaro que estou de acordo com as formas, informações e lay-out
            existentes na criação do fotolito/CTP entregue pelo Contratado e que
            a produção gráfica é de total responsabilidade do contratante. OBS.
            A nossa empresa não se responsabiliza por hora máquina e nem
            material rodado errado.
          </div>
          <div class="col-1 text-center" style="font-size: 14px;">
            {{ dataSourceConfig[0].vl_ordem_servico }}
          </div>
        </div>
      </div>

      <div class="rodape">
        <div class="row items-center q-pa-sm " style="font-size: 18px;">
          <div class="col text-bold text-left">
            Cliente {{ dataSourceConfig[0].nm_fantasia_cliente }}
          </div>
          <div class="col text-bold text-right">
            Ordem de Serviço
          </div>
        </div>
        <div class="row " style="border: 1px solid black; height: 180px;">
          <div
            class="borderBlack text-bold rotateText text-uppercase text-center "
            style="height: 50px;margin-top: 180px;margin-bottom: -30px; padding-top: 5px; width: 180px; font-size: 18px; "
          >
            Entrega
          </div>

          <div
            class="col text-bold"
            style="margin-left: -120px; font-size: 18px;"
          >
            Local de Entrega
          </div>
        </div>
        <div
          class="row items-center "
          style="margin-left: 50px; margin-top:-160px; border-bottom: 1px solid black;"
        >
          <div class="col  " style="margin-left: 10px; font-size: 16px;">
            {{ dataSourceConfig[0].nm_endereco_cliente }}
          </div>
          <div
            class="col  text-italic text-right"
            style="margin-right: 10px; font-size: 20px;"
          >
            {{ cd_ordem_servico }}
          </div>
        </div>
        <div class="row items-center" style="margin-left: 50px;">
          <div
            class="col text-bold"
            style="margin-left: 10px; font-size: 18px;"
          >
            Complemento
          </div>
        </div>
        <div
          class="row items-center"
          style="margin-left: 50px; border-bottom: 1px solid black;"
        >
          <div
            class="col"
            style="margin-left: 10px; min-height: 40px; height: auto; font-size: 16px;"
          >
            {{ dataSourceConfig[0].nm_obs_ordem_servico_comp }}
          </div>
        </div>
        <div class="row items-center" style="margin-left: 50px; ">
          <div class="col " style="margin-left: 10px; font-size: 18px;">
            Visto
          </div>
        </div>
        <div
          class="row items-center"
          style="margin-left: 50px; margin-top:20px"
        >
          <div class="col" style="margin-left: 10px;">
            ________________________________________________________________
          </div>
        </div>
      </div>
    </div>

    <q-dialog v-model="load" maximized persistent>
      <carregando />
    </q-dialog>
  </div>
</template>

<script>
import notify from "devextreme/ui/notify";
import Incluir from "../http/incluir_registro";
import html2pdf from "html2pdf.js";
import funcao from "../http/funcoes-padroes";
import logoNewPrint from "../assets/logoNewPrint.jpg";
import carregando from "../components/carregando.vue";
export default {
  name: "reportPrint",
  props: {
    cd_ordem_servico: { type: Number, default: 0 },
    cd_api: { type: String, default: "" },
  },
  components: { carregando },
  data() {
    return { dataSourceConfig: [], imageLogo: null, load: true };
  },
  methods: {},
  async created() {
    this.load = true;
  },
  async mounted() {
    const toDataUrl = async function(url) {
      //Convert to base64
      return new Promise((resolve, reject) => {
        var xhr = new XMLHttpRequest();
        xhr.onload = function() {
          var reader = new FileReader();
          reader.onloadend = function() {
            resolve(reader.result);
          };
          reader.readAsDataURL(xhr.response);
        };
        xhr.onerror = () => {
          reject({
            status: this.status,
            statusText: xhr.statusText,
          });
        };
        xhr.open("GET", url);
        xhr.responseType = "blob";
        xhr.send();
      });
    };

    try {
      this.load = true;
      this.imageLogo = funcao.viraBase64(logoNewPrint);
      if (!!this.cd_ordem_servico == false || !!this.cd_api == false) {
        notify("Ordem de Serviço não encontrada!");
        this.dataSourceConfig = [];
      } else {
        let json = {
          cd_ordem_servico: this.cd_ordem_servico,
          cd_parametro: 1,
        };
        this.dataSourceConfig = await Incluir.incluirRegistro(
          this.cd_api,
          json
        );
        //https://www.egisnet.com.br/img/NEWPRINT.bmp
        let imagesUrls = [logoNewPrint];
        this.imageLogo = await toDataUrl(imagesUrls);

        notify("Gerando PDF, Aguarde...");

        await funcao.sleep(2500);
        const element = document.getElementById("pdfImpressBlock");
        html2pdf()
          .from(element)
          .toPdf()
          .get("pdf")
          .then((pdf) => {
            window.open(pdf.output("bloburl"));
          });
      }
    } catch (error) {
      this.load = false;
    } finally {
      this.load = false;
    }
  },
};
</script>

<style>
.borderBlack {
  width: 100%;
  height: 100px;
  border: 1px solid black;
}
.texto-direita {
  text-align: right;
}
.rotateText {
  transform: rotate(270deg);
  transform-origin: top left;
}
.rodape {
  bottom: 0px;
  padding-top: 5px;
  width: 780px;
  border-top: 3px solid black;
}
</style>
