<template>
  <div style="margin:0.8%">
    <div class="text-h6 text-bold margin1">
      {{ nm_menu_titulo }}
    </div>

    <div style="display:flex; justify-content:right; align-items:right;">
      <q-btn
        round
        color="orange-9"
        icon="print"
        text-color="white"
        @click="popup_impressao"
      >
        <q-badge color="orange-9" floating>{{
          controle_impressao.length
        }}</q-badge>
        <q-tooltip
          class="bg-indigo"
          :offset="[10, 10]"
          transition-show="flip-right"
          transition-hide="flip-left"
          anchor="center left"
          self="center right"
        >
          <strong>Baixar Laudo</strong>
        </q-tooltip>
      </q-btn>
    </div>

    <div class="row">
      <q-select
        v-model="candidato"
        use-input
        hide-selected
        fill-input
        input-debounce="0"
        :options="opcoes_candidato"
        option-value="cd_candidato"
        option-label="nm_candidato"
        @filter="filterCandidato"
        label="Candidato"
        class="padding1 col response"
        @input="carregaDados()"
      >
        <template v-slot:append>
          <q-icon
            v-if="candidato !== ''"
            name="close"
            @click.stop="candidato = ''"
            class="cursor-pointer"
          ></q-icon>
        </template>
        <template v-slot:prepend>
          <q-icon name="work" />
        </template>
        <template v-slot:no-option>
          <q-item>
            <q-item-section class="text-italic text-grey">
              Nenhuma candidato encontrado.
            </q-item-section>
          </q-item>
        </template>
      </q-select>

      <q-field class="padding1 col response" label="Empresa" stack-label>
        <template v-slot:prepend>
          <q-icon name="domain" />
        </template>
        <template v-slot:control>
          <div class="self-center full-width no-outline" tabindex="0">
            {{ nm_fantasia_empresa }}
          </div>
        </template>
      </q-field>
      <q-field
        class="padding1 col response"
        label="E-mail (Empresa)"
        stack-label
      >
        <template v-slot:prepend>
          <q-icon name="email" />
        </template>
        <template v-slot:control>
          <div class="self-center full-width no-outline" tabindex="0">
            {{ nm_contato_empresa }}
          </div>
        </template>
      </q-field>
    </div>
    <div class="row">
      <q-field class="padding1 col response" label="Cargo" stack-label>
        <template v-slot:prepend>
          <q-icon name="people" />
        </template>
        <template v-slot:control>
          <div class="self-center full-width no-outline" tabindex="0">
            {{ nm_cargo_funcionario }}
          </div>
        </template>
      </q-field>
      <q-field class="padding1 col response" label="Data" stack-label>
        <template v-slot:prepend>
          <q-icon name="today" />
        </template>
        <template v-slot:control>
          <div class="self-center full-width no-outline" tabindex="0">
            {{ dt_avaliacao }}
          </div>
        </template>
      </q-field>
      <q-field class="padding1 col response" label="Horário" stack-label>
        <template v-slot:prepend>
          <q-icon name="schedule" />
        </template>
        <template v-slot:control>
          <div class="self-center full-width no-outline" tabindex="0">
            {{ hr_avaliacao }}
          </div>
        </template>
      </q-field>
      <q-select
        v-if="dataSource.length > 1"
        class="padding1 col response"
        v-model="CVAT_selecionado"
        :options="dataSource"
        option-value="cd_controle"
        option-label="nm_fantasia_empresa"
        label="Vaga"
        @input="SelectCVAT()"
      >
        <template v-slot:prepend>
          <q-icon name="task" />
        </template>
      </q-select>
    </div>

    <div class="borda-bloco shadow-2 margin1">
      <q-expansion-item
        expand-separator
        icon="assignment"
        label="Instruções"
        class="margin1"
      >
        <q-field class="col" stack-label>
          <template v-slot:control>
            <h5 class="self-center full-width no-outline">
              <b>Mapa Geral dos Valores do CVAT SALES: </b>
            </h5>
          </template>
        </q-field>
        <div class="row items-center justify-left">
          <div class="self-center full-width no-outline" tabindex="0">
            <b><u>Entendendo os parâmetros: </u></b>
          </div>
          <ol>
            <li>
              Prospecção: nos mostra qual a inclinação do vendedor a ir atrás de
              novos clientes, via telefone ou visitas.
            </li>
            <li>
              Senso de urgência: nos indica a relação do vendedor com prazos,
              horários e velocidade.
            </li>
            <li>
              Follow Up: nos aponta quanto o vendedor gosta de acompanhar os
              processos e manter a agenda em dia.
            </li>
            <li>
              Capricho e detalhe: indica a preocupação com a qualidade do
              serviço e o nível de capricho e detalhe.
            </li>
            <li>
              Resiliência emocional: nos mostra a relação do vendedor, com
              críticas, negativas e rejeição de clientes.
            </li>
            <li>
              Empatia: nos indica a capacidade do vendedor de se colocar no
              lugar do cliente e entender suas necessidades.
            </li>
            <li>
              Sociabilidade: aponta quão sociável é o vendedor.
            </li>
            <li>
              Cultivo da relação: demonstra o grau de preocupação do vendedor em
              criar vínculos duradouros com clientes.
            </li>
            <li>
              Agressividade: aponta quanto o vendedor pode tentar impor seu
              ponto de vista para fechar um negócio.
            </li>
            <li>
              Imagem: nos mostra o grau de preocupação do vendedor quanto a sua
              imagem no mercado.
            </li>
            <li>
              Persuasão e negociação: indica quanto o vendedor pode estar
              inclinado a negociar e persuadir clientes.
            </li>
            <li>
              Influência: demonstra a intenção em influenciar clientes e
              construir credibilidade.
            </li>
            <li>
              Argumentação: nos mostra a capacidade de debater e argumentar além
              no nível concreto.
            </li>
            <li>
              Planejamento: aponta a inclinação a organização e planejamento de
              suas atividades e processos comerciais.
            </li>
            <li>
              Comunicação e apresentação: nos indica a clareza da mensagem e a
              facilidade em expor ideias e serviços.
            </li>
            <li>
              Adaptabilidade: demonstra a relação do vendedor com diferentes
              cenários, clientes, mudanças e mercados.
            </li>
          </ol>
        </div>
        <div class="self-center full-width no-outline" tabindex="0">
          <b><u>Entendendo o Ponteiro: </u></b>
        </div>
        <div class="self-center full-width no-outline" tabindex="0">
          Os valores do CVAT Sales são dispostos em um gráfico de ponteiro, com
          três divisões.
        </div>
        <ul>
          <li>
            Divisão "baixa", de 0 a 10 pontos: São os itens que não são naturais
            para você. São coisas que você preferiria não ter que fazer. Por
            isso, em todas os itens em que você estiver nesta divisão, aparecerá
            um "atenção" da narrativa, para você se policiar, com dicas para
            você não ser prejudicado por este "ponto fraco".
          </li>
          <li>
            Divisão "média", de 11 a 15 pontos: São os itens onde você não tem
            grande dificuldade, porém não se destaca. É provavelmente sua zona
            de conforto. Um esforço de desenvolvimento alguns destes itens, pode
            lhe gerar bons resultados.
          </li>
          <li>
            Divisão "alta", de 16 a 20 pontos: São os itens onde seu talento
            realmente aparece. Provavelmente você tem resultados acima da média
            geral quando está utilizando estas competências. Porém, também
            incluímos uma "atenção" para você avaliar se o 'overuse' desta
            competência não está sendo um problema para você.
          </li>
        </ul>
      </q-expansion-item>
    </div>

    <div
      class="borda-bloco shadow-2 margin1"
      v-if="resultado_completo.length > 0"
    >
      <q-expansion-item
        expand-separator
        icon="analytics"
        label="Resultado C-VAT Sales"
        default-opened
      >
        <DxPolarChart
          v-if="ativaPolar"
          id="radarChart"
          ref="radarChart"
          :data-source="resultado_chart"
          :size="{
            height: chartHeight,
            width: chartWidth,
          }"
        >
          <DxAnimation :enabled="false" />
          <DxCommonSeriesSettings
            type="area"
            argumentField="nm_argumento"
            value-field="qt_resultado_arg"
            :show-in-legend="false"
          >
          </DxCommonSeriesSettings>

          <DxSeries :type="typePolar" name="Resultado" color="#FC6C13" />
          <DxArgumentAxis
            :first-point-on-start-angle="true"
            discrete-axis-division-mode="crossLabels"
            :start-angle="0"
          >
            <DxLabel>
              <DxFont />
            </DxLabel>
          </DxArgumentAxis>
          <DxValueAxis
            :show-zero="true"
            :allow-decimals="false"
            :axis-division-factor="1"
            :visual-range="[0, 20]"
          ></DxValueAxis>

          <DxTooltip :enabled="true" />
        </DxPolarChart>

        <div class="row margin1">
          <ul
            class="col-6"
            v-for="(n, index) in resultado_completo"
            :key="index"
          >
            <b>{{ n[0].nm_quadrante + ": " + n[0].qt_resultado_quadrante }}</b>
            <li v-for="(y, index) in n" :key="index">
              {{ y.nm_argumento + ": " + y.qt_resultado_arg }}
            </li>
          </ul>
        </div>
      </q-expansion-item>
    </div>
    <!------------------------------------------------------------------->
    <div
      class="borda-bloco shadow-2 margin1 item-align"
      v-for="(n, index) in resultado_completo"
      :key="index"
    >
      <q-expansion-item
        expand-separator
        :icon="n[0].icon"
        :label="
          `Quadrante ${n[0].nm_quadrante}: ${n[0].qt_resultado_quadrante}`
        "
        default-opened
      >
        <div
          class="margin1 self-center response"
          v-for="(y, index) in n.length"
          v-bind:key="index"
        >
          <b>{{ n[y - 1].nm_argumento + ": " + n[y - 1].qt_resultado_arg }}</b
          ><br />
          <label>
            {{ n[y - 1].ds_analise_argumento }}
          </label>
        </div>
      </q-expansion-item>
    </div>
    <!------------------------------------------------------------------->
    <!---CARREGANDO----------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando :mensagemID="textload" :corID="'orange-9'"></carregando>
    </q-dialog>
    <!------------------------------------------------->
  </div>
</template>

<script>
import {
  DxPolarChart,
  DxAnimation,
  DxArgumentAxis,
  DxValueAxis,
  DxLabel,
  DxFont,
  DxTooltip,
  DxSeries,
  DxCommonSeriesSettings,
} from "devextreme-vue/polar-chart";
import {} from "devextreme-vue/chart";
import notify from "devextreme/ui/notify";
import formataData from "../http/formataData";
import Procedimento from "../http/procedimento";

import Menu from "../http/menu";
import Lookup from "../http/lookup";
import Incluir from "../http/incluir_registro";
import funcao from "../http/funcoes-padroes";
import carregando from "../components/carregando.vue";
import carboneSDK from "carbone-sdk-js";
import funcoesPadroes from "../http/funcoes-padroes";

var dados = [];
var resultado = [];

export default {
  name: "laudo-cvat",
  data() {
    return {
      chartSVG: "",
      CVAT_selecionado: "",
      chartHeight: undefined,
      chartWidth: undefined,
      typePolar: "line",
      textload: "Aguarde...",
      ativaPolar: true,
      getUrl: [],
      cd_candidato: 0,
      candidato: [],
      ic_impressao: false,
      api: "640", //1506 - Procedimento -- pr_laudo_recrutamento_selecao
      nm_menu_titulo: "",
      nm_json: "",
      dataSource: {},
      dataSourceInicial: {},
      nm_fantasia_empresa: "",
      nm_contato_empresa: "",
      nm_candidato: "",
      nm_cargo_funcionario: "",
      resultado_completo: [],
      resultado_impressao: [],
      resultado_chart: [],
      opcoes_candidato: [],
      dt_avaliacao: "",
      hr_avaliacao: "",
      cd_usuario: 0,
      dt_picker: "",
      cd_empresa: 0,
      controle_impressao: [],
      dados_avaliacao: [],
      dataset_avaliacao: [],
      cliente: "",
      load: false,
      nm_template: "",
    };
  },
  async created() {
    this.cd_usuario = localStorage.cd_usuario;
    this.cd_empresa = localStorage.cd_empresa;
    /*---Controle de Impressão-------------------------------------------------------------------------------------------------*/
    await this.ControleImpressao();
    /*---AVALIAÇÃO-------------------------------------------------------------------------------------------------*/
    this.dados_avaliacao = await Lookup.montarSelect(this.cd_empresa, 5269);
    this.dataset_avaliacao = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_avaliacao.dataset)),
    );
    await this.carregaDadosIniciais();
  },

  components: {
    DxPolarChart,
    DxAnimation,
    DxTooltip,
    DxArgumentAxis,
    DxValueAxis,
    DxCommonSeriesSettings,
    DxLabel,
    DxFont,
    DxSeries,
    carregando,
  },

  methods: {
    async carregaDadosIniciais() {
      dados = await Menu.montarMenu(this.cd_empresa, 7301, this.api); //pr_laudo_recrutamento_selecao
      let cd_api = dados.xnm_identificacao_api;
      let sParametroApi = dados.nm_api_parametro;
      this.nm_menu_titulo = dados.nm_menu_titulo;
      this.nm_template = dados.nm_template;
      localStorage.cd_parametro = this.cd_candidato;
      this.load = true;
      this.dataSourceInicial = await Procedimento.montarProcedimento(
        this.cd_empresa,
        0,
        cd_api,
        sParametroApi,
      );
      this.load = false;
    },
    async carregaDados() {
      this.cd_candidato = 0;
      this.dataSource = [];

      this.cd_candidato = this.candidato.cd_candidato;
      dados = await Menu.montarMenu(this.cd_empresa, 7301, this.api); //pr_laudo_recrutamento_selecao
      let cd_api = dados.xnm_identificacao_api;
      let sParametroApi = dados.nm_api_parametro;
      this.nm_menu_titulo = dados.nm_menu_titulo;
      this.nm_template = dados.nm_template;
      localStorage.cd_parametro = this.cd_candidato;
      this.load = true;

      this.dataSource = await Procedimento.montarProcedimento(
        this.cd_empresa,
        0,
        cd_api,
        sParametroApi,
      );
      this.load = false;
      await this.SelectCVAT();
    },

    async ControleImpressao() {
      this.controle_impressao = await Lookup.montarSelect(
        this.cd_empresa,
        5475,
      );
      this.controle_impressao = JSON.parse(
        JSON.parse(JSON.stringify(this.controle_impressao.dataset)),
      );
      //Traz as impressões feitas no mês atual
      this.controle_impressao = this.controle_impressao.filter((e) => {
        let dateDB = new Date(e.dt_controle_impressao); //Data da Impressão
        let dateNow = new Date(); //Data Hoje
        return (
          dateDB.getFullYear() == dateNow.getFullYear() &&
          dateDB.getMonth() == dateNow.getMonth()
        );
      });
      this.controle_impressao == null ? (this.controle_impressao = 0) : "";
      this.controle_impressao = this.controle_impressao.filter((e) => {
        let dataHoje = funcoesPadroes.DataHoje();
        let hoje_split = dataHoje.split("/");
        let data_imp = formataData.formataDataJS(e.dt_controle_impressao);
        let data_split = data_imp.split("/");
        if (
          data_split[1] === hoje_split[1] &&
          data_split[2] === hoje_split[2]
        ) {
          return e;
        }
      });
    },

    async popup_impressao() {
      if (this.candidato == "") {
        return notify("Selecione um candidato!");
      } else {
        try {
          this.chartWidth = 593; //593
          this.chartHeight = 438; // 438
          this.typePolar = "area";
          this.load = true;
          this.textload = "Gerando PDF...";
          this.chartSVG = "";
          await funcao.sleep(3500);
          // return;
          this.chartSVG = this.$refs.radarChart.instance.svg();

          let oMyBlob = {};
          oMyBlob = new File([this.chartSVG], "CVAT", {
            type: "image/svg+xml",
          });

          var reader = new FileReader();
          reader.addEventListener("loadend", async function() {
            localStorage.vb_imagem64_cvat = reader.result;
          });
          if (oMyBlob.type == "text/xml") {
            await reader.readAsText(oMyBlob);
          } else {
            await reader.readAsDataURL(oMyBlob); //readAsDataURL
          }
          this.ativaPolar = false;
          resultado = await Menu.montarMenu(this.cd_empresa, 7253, 599); //pr_calculo_avaliacao_selecao
          let cd_api6 = resultado.xnm_identificacao_api;
          let sParametroApi6 = resultado.nm_api_parametro;
          localStorage.cd_tipo_consulta = this.CVAT_selecionado
            .cd_requisicao_vaga
            ? this.CVAT_selecionado.cd_requisicao_vaga
            : this.dataSource[0].cd_requisicao_vaga; //1;
          localStorage.cd_identificacao = this.cd_candidato;
          localStorage.cd_parametro = 6;
          this.resultado_impressao = [];
          this.resultado_impressao = await Procedimento.montarProcedimento(
            this.cd_empresa,
            0,
            cd_api6,
            sParametroApi6,
          );
          this.textload = "Salvando informações...";
          this.chartHeight = undefined;
          this.chartWidth = undefined;
          this.typePolar = "line";
          this.ativaPolar = true;
          let carboneJS = carboneSDK(
            // "test_eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI1NTExIiwiYXVkIjoiY2FyYm9uZSIsImV4cCI6MjI4MTE4MDA2OCwiZGF0YSI6eyJpZEFjY291bnQiOjU1MTF9fQ.AcwTgwAUASRGq7k40rjjt2naOd2Xuq7rw_po8mAAVonxeZWPI_WAkTicjPBeZHlF1gafbm2TlnhN6JLi1ZDqYmNxACkhlvnt66N9mC5Cyy746wkPehmJWaJJzdcSjiTOJQlYwT9zYNYxqr8tpo4lUxE-AU-f4d2WQgSQpDT9yHiXl9Ye",
            "eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI1NTExIiwiYXVkIjoiY2FyYm9uZSIsImV4cCI6MjMyODAwODkwMywiZGF0YSI6eyJpZEFjY291bnQiOiI1NTExIn19.Ad1-ViqT9OrSG74Br7AOzK0l110Tmdn-Ye8_P9ZHkK18wtXzDfzeKnv7SUG_0P6ThUg-o8z15tp0rKVT1fdyNdLGAZgAloSdNcSQyfJnp0o37IRYTbXc1kBU8Zmp9M4-vg9kjNPHiKGNR3KKYk-as_4I6lkNt3qvKbKmjmZNWL6zTzJn",
          );
          carboneJS.setApiVersion(3);

          const dataCarbone = {
            data: {
              nm_candidato: this.resultado_impressao[0].nm_candidato,
              nm_email_candidato: this.resultado_impressao[0]
                .nm_email_candidato,
              nm_cargo_funcionario: this.resultado_impressao[0]
                .nm_cargo_funcionario,
              nm_fantasia_cliente: this.resultado_impressao[0]
                .nm_fantasia_cliente,
              nm_empresa: this.resultado_impressao[0].nm_empresa,
              dt_avaliacao: this.resultado_impressao[0].dt_avaliacao,

              qt_resultado_quadrante_pensamento: this.resultado_impressao[0]
                .qt_resultado_quadrante_relacoes,
              qt_resultado_quadrante_controle: this.resultado_impressao[0]
                .qt_resultado_quadrante_pensamento,
              qt_resultado_quadrante_trabalho: this.resultado_impressao[0]
                .qt_resultado_quadrante_controle,
              qt_resultado_quadrante_relacoes: this.resultado_impressao[0]
                .qt_resultado_quadrante_trabalho,

              qt_resultado_argumentacao: this.resultado_impressao[0]
                .qt_resultado_argumentacao,
              qt_resultado_planejamento: this.resultado_impressao[0]
                .qt_resultado_planejamento,
              qt_resultado_comunicacao: this.resultado_impressao[0]
                .qt_resultado_comunicacao,
              qt_resultado_adaptabilidade: this.resultado_impressao[0]
                .qt_resultado_adaptabilidade,
              qt_resultado_agressividade: this.resultado_impressao[0]
                .qt_resultado_agressividade,
              qt_resultado_imagem: this.resultado_impressao[0]
                .qt_resultado_imagem,
              qt_resultado_persuasao: this.resultado_impressao[0]
                .qt_resultado_persuasao,
              qt_resultado_influencia: this.resultado_impressao[0]
                .qt_resultado_influencia,
              qt_resultado_prospeccao: this.resultado_impressao[0]
                .qt_resultado_prospeccao,
              qt_resultado_senso_urgencia: this.resultado_impressao[0]
                .qt_resultado_senso_urgencia,
              qt_resultado_follow_up: this.resultado_impressao[0]
                .qt_resultado_follow_up,
              qt_resultado_capricho: this.resultado_impressao[0]
                .qt_resultado_capricho,
              qt_resultado_resiliencia: this.resultado_impressao[0]
                .qt_resultado_resiliencia,
              qt_resultado_empatia: this.resultado_impressao[0]
                .qt_resultado_empatia,
              qt_resultado_sociabilidade: this.resultado_impressao[0]
                .qt_resultado_sociabilidade,
              qt_resultado_cultivo: this.resultado_impressao[0]
                .qt_resultado_cultivo,

              ds_analise_prospeccao: this.resultado_impressao[0]
                .ds_analise_prospeccao,
              ds_analise_senso_urgencia: this.resultado_impressao[0]
                .ds_analise_senso_urgencia,
              ds_analise_follow_up: this.resultado_impressao[0]
                .ds_analise_follow_up,
              ds_analise_capricho: this.resultado_impressao[0]
                .ds_analise_capricho,

              ds_analise_resiliencia: this.resultado_impressao[0]
                .ds_analise_resiliencia,
              ds_analise_empatia: this.resultado_impressao[0]
                .ds_analise_empatia,
              ds_analise_sociabilidade: this.resultado_impressao[0]
                .ds_analise_sociabilidade,
              ds_analise_cultivo: this.resultado_impressao[0]
                .ds_analise_cultivo,

              ds_analise_agressividade: this.resultado_impressao[0]
                .ds_analise_agressividade,
              ds_analise_imagem: this.resultado_impressao[0].ds_analise_imagem,
              ds_analise_persuasao: this.resultado_impressao[0]
                .ds_analise_persuasao,
              ds_analise_influencia: this.resultado_impressao[0]
                .ds_analise_influencia,

              ds_analise_argumentacao: this.resultado_impressao[0]
                .ds_analise_argumentacao,
              ds_analise_planejamento: this.resultado_impressao[0]
                .ds_analise_planejamento,
              ds_analise_comunicacao: this.resultado_impressao[0]
                .ds_analise_comunicacao,
              ds_analise_adaptabilidade: this.resultado_impressao[0]
                .ds_analise_adaptabilidade,

              ds_ponteiro_prospeccao: this.resultado_impressao[0]
                .ds_ponteiro_prospeccao,
              ds_ponteiro_senso_urgencia: this.resultado_impressao[0]
                .ds_ponteiro_senso_urgencia,
              ds_ponteiro_follow_up: this.resultado_impressao[0]
                .ds_ponteiro_follow_up,
              ds_ponteiro_capricho: this.resultado_impressao[0]
                .ds_ponteiro_capricho,
              ds_ponteiro_resiliencia: this.resultado_impressao[0]
                .ds_ponteiro_resiliencia,
              ds_ponteiro_empatia: this.resultado_impressao[0]
                .ds_ponteiro_empatia,
              ds_ponteiro_sociabilidade: this.resultado_impressao[0]
                .ds_ponteiro_sociabilidade,
              ds_ponteiro_cultivo: this.resultado_impressao[0]
                .ds_ponteiro_cultivo,
              ds_ponteiro_agressividade: this.resultado_impressao[0]
                .ds_ponteiro_agressividade,
              ds_ponteiro_imagem: this.resultado_impressao[0]
                .ds_ponteiro_imagem,
              ds_ponteiro_persuasao: this.resultado_impressao[0]
                .ds_ponteiro_persuasao,
              ds_ponteiro_influencia: this.resultado_impressao[0]
                .ds_ponteiro_influencia,
              ds_ponteiro_argumentacao: this.resultado_impressao[0]
                .ds_ponteiro_argumentacao,
              ds_ponteiro_planejamento: this.resultado_impressao[0]
                .ds_ponteiro_planejamento,
              ds_ponteiro_comunicacao: this.resultado_impressao[0]
                .ds_ponteiro_comunicacao,
              ds_ponteiro_adaptabilidade: this.resultado_impressao[0]
                .ds_ponteiro_adaptabilidade,

              imagemGrafico: localStorage.vb_imagem64_cvat,
            },
            convertTo: "pdf",
          };
          await carboneJS
            .render(
              "cc968415b1a45383a586adce76b689fdb085f95a6e2319a114bfe850db9933df",
              dataCarbone,
            )
            .then((renderizou) => {
              this.renderizado = renderizou;
              this.renderizado.name =
                this.resultado_impressao[0].nm_candidato + ".pdf";
            });

          const fileObjectURL = window.URL.createObjectURL(
            this.renderizado.content,
          );
          await window.open(fileObjectURL);
          this.ic_impressao = true;
          ////Controle de Impressão
          var add_impressao = {
            cd_parametro: 13,
            cd_candidato: this.candidato.cd_candidato,
            cd_usuario: this.cd_usuario,
          };
          var impressao1 = await Incluir.incluirRegistro(
            "598/827", // pr_montagem_avaliacao_candidato
            add_impressao,
          );
          notify(impressao1[0].nm_controle_impressao);
          await this.ControleImpressao();
          /////////////////////////////////////////
          this.load = false;
        } catch {
          this.chartHeight = undefined;
          this.chartWidth = undefined;
          this.load = false;
          notify("Não foi possível gerar o laudo!");
        }
      }
    },

    async SelectCVAT() {
      this.CVAT_selecionado.cd_controle
        ? ""
        : (this.CVAT_selecionado = this.dataSource[0]);
      if (this.CVAT_selecionado.cd_controle) {
        this.nm_fantasia_empresa = this.CVAT_selecionado.nm_fantasia_empresa;
        this.nm_contato_empresa = this.CVAT_selecionado.nm_contato_empresa;
        this.nm_candidato = this.CVAT_selecionado.nm_candidato;
        this.nm_cargo_funcionario = this.CVAT_selecionado.nm_cargo_funcionario;
        this.CVAT_selecionado.dt_usuario != undefined
          ? (this.dt_avaliacao = formataData.formataDataJS(
              this.CVAT_selecionado.dt_usuario,
            ))
          : (this.dt_avaliacao = "");
        this.CVAT_selecionado.dt_usuario != undefined
          ? (this.hr_avaliacao = formataData.formataHoraJS(
              this.CVAT_selecionado.dt_usuario,
            ))
          : (this.hr_avaliacao = "");
        this.resultadoCVAT();
      }
    },

    async resultadoCVAT() {
      resultado = await Menu.montarMenu(this.cd_empresa, 7253, 599); //pr_calculo_avaliacao_selecao
      let cd_api2 = resultado.xnm_identificacao_api;
      let sParametroApi2 = resultado.nm_api_parametro;
      localStorage.cd_tipo_consulta = this.CVAT_selecionado.cd_requisicao_vaga
        ? this.CVAT_selecionado.cd_requisicao_vaga
        : this.dataSource[0].cd_requisicao_vaga; //1;
      localStorage.cd_identificacao = this.cd_candidato;

      localStorage.cd_parametro = 5;

      this.resultado_completo = [];
      this.resultado_chart = [];
      this.resultado_completo = await Procedimento.montarProcedimento(
        this.cd_empresa,
        0,
        cd_api2,
        sParametroApi2,
      );
      var array_separado1 = this.resultado_completo.filter(
        (a) => a.cd_quadrante == 1,
      );
      var array_separado2 = this.resultado_completo.filter(
        (a) => a.cd_quadrante == 2,
      );
      var array_separado3 = this.resultado_completo.filter(
        (a) => a.cd_quadrante == 3,
      );
      var array_separado4 = this.resultado_completo.filter(
        (a) => a.cd_quadrante == 4,
      );

      this.resultado_completo.forEach((b) => {
        this.resultado_chart.push({
          qt_resultado_arg: b.qt_resultado_arg,
          nm_argumento: b.nm_argumento,
        });
      });

      this.resultado_completo = [
        array_separado1,
        array_separado2,
        array_separado3,
        array_separado4,
      ];
    },

    filterCandidato(val, update) {
      update(() => {
        const needle = val.toLowerCase();
        this.opcoes_candidato = this.dataSourceInicial.filter(
          (v) => v.nm_candidato.toLowerCase().indexOf(needle) > -1,
        );
        this.opcoes_candidato = this.opcoes_candidato.sort(function(a, b) {
          if (a.nm_candidato < b.nm_candidato) return -1;
          return 1;
        });
      });
    },
  },
};
</script>
<style scoped>
.padding1 {
  padding: 0.3% 0.6%;
}
.margin1 {
  margin: 0.5%;
}
.column {
  height: 20px !important;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}

.alinha-texto {
  margin: auto;
  display: flex;
  flex-flow: row wrap;
  justify-content: space-between;
}

#chart-demo {
  height: 440px;
  width: 80vw;
}

#radarChart {
  height: 450px;
}

#chart-demo > .center {
  text-align: center;
}

#chart-demo > .center > div,
#chart-demo > .center > .dx-widget {
  display: inline-block;
  vertical-align: middle;
}

@media (max-width: 850px) {
  .response {
    width: 100% !important;
  }
}
</style>
