<template>
  <div style="background: white">
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no" />
    <div class="row items-center margin1">
      <div v-if="ic_mostra_titulo">
        <transition name="slide-fade">
          <div class="text-h6 col-8" v-show="!!tituloMenu != false">
            {{ tituloMenu }} {{ hoje }} {{ hora }}
            <q-badge
              v-if="qt_registro > 0"
              align="middle"
              rounded
              color="red"
              :label="qt_registro"
            />
          </div>
        </transition>
      </div>
      <div class="col">
        <transition name="slide-fade">
          <q-btn
            style="float: right"
            round
            flat
            v-if="!ds_menu_descritivo == ''"
            color="black"
            @click="popClick()"
            icon="info"
          />
        </transition>
        <q-btn style="float: right" round flat color="black" @click="popClickData()" icon="event" />
      </div>
    </div>
    <div>
      <form
        class="dx-card wide-card"
        v-if="ic_filtro_pesquisa == 'S'"
        action="your-action"
        @submit="handleSubmit"
      >
        <!--Caso expecifico para Guarufilme, busca ordem de produção pelo número digitado. Confira o localStorage.cd_identificacao-->
        <q-input
          color="orange-9"
          class="margin1"
          v-model="cd_identificacao"
          label="Ordem"
          v-if="cd_menu == 6753"
          @blur="carregaDados()"
        >
          <template v-slot:prepend>
            <q-icon name="search" />
          </template>
        </q-input>
        <!--Select dinamico do admin-->
        <q-select
          v-else
          filled
          clearable
          :option-value="value_lookup"
          :option-label="label_lookup"
          v-model="selecionada_lookup"
          :options="dataset_lookup"
          :label="placeholder_lookup"
          class="margin1"
        />

        <div class="row">
          <q-btn
            class="margin1"
            color="orange-9"
            rounded
            label="Pesquisar"
            @click="onClick($event)"
          />
        </div>
      </form>
    </div>
    <div class="margin1 borda-bloco shadow-2">
      <div class="row">
        <div class="margin1 col" style="font-weight: bold">
          {{ 'Simples' }}
          <q-toggle
            v-model="tipo_pesquisa_produto"
            :false-value="'N'"
            :true-value="'S'"
            color="orange-9"
          />{{ 'Completa' }}
        </div>
      </div>
      <transition name="slide-fade">
        <div v-if="tipo_pesquisa_produto == 'S'" class="col">
          <div class="row margin1">
            <q-select
              dense
              class="umQuartoTela margin1"
              v-model="categoria_pesquisa"
              :options="dataset_lookup_categoria"
              label="Categoria"
              option-value="cd_categoria_produto"
              option-label="nm_categoria_produto"
              @input="SelectParam(1)"
            >
              <template v-slot:prepend>
                <q-icon name="category" />
              </template>
            </q-select>

            <q-select
              dense
              class="umQuartoTela margin1"
              v-model="grupo_pesquisa"
              :options="dataset_lookup_grupo"
              label="Grupo"
              option-value="cd_grupo_produto"
              option-label="nm_grupo_produto"
              @input="SelectParam(2)"
            >
              <template v-slot:prepend>
                <q-icon name="group" />
              </template>
            </q-select>

            <q-select
              dense
              class="umQuartoTela margin1"
              v-model="familia"
              :options="dataset_lookup_familia"
              label="Família"
              option-value="cd_familia_produto"
              option-label="nm_familia_produto"
              @input="SelectParam(3)"
            >
              <template v-slot:prepend>
                <q-icon name="group" />
              </template>
            </q-select>

            <q-select
              dense
              class="umQuartoTela margin1"
              v-model="marca_pesquisa"
              :options="dataset_lookup_marca"
              label="Marca"
              option-value="cd_marca_produto"
              option-label="nm_marca_produto"
              @input="SelectParam(4)"
            >
              <template v-slot:prepend>
                <q-icon name="branding_watermark" />
              </template>
            </q-select>
          </div>

          <div class="row margin1">
            <!-- <q-input
              dense
              color="orange-9"
              class="margin1 umTercoTela"
              v-model="cd_mascara_produto"
              label="Código"
            >
              <template v-slot:prepend>
                <q-icon name="masks" />
              </template>
            </q-input> -->

            <!-- <q-input
              dense
              color="orange-9"
              class="margin1 umTercoTela"
              v-model="nm_fantasia_produto"
              label="Fantasia"
            >
              <template v-slot:prepend>
                <q-icon name="face_retouching_natural" />
              </template>
            </q-input> -->

            <q-input
              dense
              color="orange-9"
              class="margin1 umTercoTela"
              v-model="nm_produto"
              label="Produto"
              debounce="1000"
              @input="SelectParam()"
            >
              <template v-slot:prepend>
                <q-icon name="inventory_2" />
              </template>
              <template v-slot:append>
                <q-btn size="sm" round color="orange-9" icon="search" @click="SelectParam()">
                  <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                    Pesquisar
                  </q-tooltip>
                </q-btn>
              </template>
            </q-input>
          </div>
        </div>
      </transition>
      <div class="row items-center">
        <transition name="slide-fade">
          <q-input
            dense
            :color="color"
            class="margin1 telaInteira"
            v-if="tipo_pesquisa_produto == 'N'"
            v-model="nm_produto"
            autofocus
            label="Produto"
            debounce="1000"
            @input="SelectParam()"
          >
            <template v-slot:prepend>
              <q-icon name="inventory_2" />
            </template>
            <template v-slot:append>
              <q-btn size="sm" round color="orange-9" icon="search" @click="SelectParam()">
                <q-tooltip anchor="bottom middle" self="top middle" :offset="[10, 10]">
                  Pesquisar
                </q-tooltip>
              </q-btn>
            </template>
          </q-input>
        </transition>
      </div>
    </div>
    <transition name="slide-fade">
      <div v-if="dataSourceConfig.length > 0">
        <q-btn
          color="orange-9"
          flat
          rounded
          label="Selecionar"
          class="margin1"
          @click="SelecionaProduto()"
        >
        </q-btn>
        <dx-data-grid
          id="gridPadrao"
          ref="gridPadrao"
          class="dx-card-componente"
          :data-source="dataSourceConfig"
          :columns="columns"
          :summary="total"
          key-expr="cd_controle"
          :show-borders="true"
          :focused-row-enabled="true"
          :column-auto-width="true"
          :column-hiding-enabled="false"
          :remote-operations="false"
          :word-wrap-enabled="false"
          :allow-column-reordering="true"
          :allow-column-resizing="true"
          :row-alternation-enabled="true"
          :repaint-changes-only="true"
          :autoNavigateToFocusedRow="true"
          :focused-row-index="0"
          :cacheEnable="false"
          @exporting="onExporting"
          @initialized="saveGridInstance"
          @focused-row-changed="onFocusedRowChanged"
          @row-dbl-click="SelecionaProduto($emit)"
        >
          <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

          <DxGrouping :auto-expand-all="true" />
          <DxExport :enabled="true" />
          <DxEditing
            :allow-updating="true"
            :allow-adding="false"
            :allow-deleting="false"
            :select-text-on-edit-start="true"
            mode="batch"
          />
          <DxPaging :enable="true" :page-size="10" />

          <DxStateStoring :enabled="false" type="localStorage" storage-key="storage" />
          <DxSelection mode="single" />
          <DxPager
            :show-page-size-selector="true"
            :allowed-page-sizes="pageSizes"
            :show-info="true"
          />
          <DxFilterRow :visible="false" />
          <DxHeaderFilter :visible="true" :allow-search="true" />
          <DxSearchPanel :visible="temPanel" :width="300" placeholder="Procurar..." />
          <DxFilterPanel :visible="true" />
          <DxColumnFixing :enabled="true" />
          <DxColumnChooser :enabled="true" mode="select" />
        </dx-data-grid>
      </div>
    </transition>
    <!-- TABS -->
    <div v-if="ic_cadastro">
      <q-tabs
        v-model="tab"
        class="bg-orange-9 text-white margin1"
        style="border-radius: 20px"
        inline-label
        @click="trocaTab(tab)"
      >
        <q-tab
          v-if="cad_produto === '' || cad_produto === 'dados'"
          name="dados"
          icon="description"
          label="Dados"
        />
        <q-tab
          v-if="cad_produto === '' || cad_produto === 'fiscal'"
          name="fiscal"
          icon="gavel"
          label="Fiscal"
        />
        <q-tab
          v-if="cad_produto === '' || cad_produto === 'fornecedor'"
          name="fornecedor"
          icon="person"
          label="Fornecedor"
        />
      </q-tabs>
      <q-tab-panels
        v-model="tab"
        animated
        swipeable
        vertical
        transition-prev="jump-up"
        transition-next="jump-up"
      >
        <q-tab-panel name="dados">
          <!-- Botões -->
          <div class="row">
            <q-btn
              color="orange-9"
              icon="add"
              class="margin1"
              rounded
              label="Novo"
              @click="NovoProduto()"
            >
              <q-tooltip> Novo Produto </q-tooltip>
            </q-btn>
            <q-btn
              color="orange-9"
              icon="save"
              class="margin1"
              rounded
              label="Salvar"
              :loading="load_salvar"
              @click="SalvaProduto()"
            >
              <q-tooltip> Salva Produto </q-tooltip>
            </q-btn>
            <q-btn
              color="orange-9"
              icon="cleaning_services"
              class="margin1"
              rounded
              flat
              label="Limpar"
              @click="LimpaProduto()"
            >
              <q-tooltip> Cancela Produto </q-tooltip>
            </q-btn>
          </div>
          <!--  -->
          <!-- Cadastro de Produto Simplificado -->
          <div class="row justify-evenly items-center">
            <q-input dense class="umTercoTela margin1" v-model="produto.nm_produto" label="Produto">
              <template v-slot:prepend>
                <q-icon name="store" />
              </template>
            </q-input>
            <q-input
              dense
              class="umTercoTela margin1"
              v-model="produto.cd_serie_produto"
              label="Série"
              type="number"
            >
              <template v-slot:prepend>
                <q-icon name="view_comfy" />
              </template>
            </q-input>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="marca"
              :options="dataset_lookup_marca"
              label="Marca"
              option-value="cd_marca_produto"
              option-label="nm_marca_produto"
              @input="Select(5)"
            >
              <template v-slot:prepend>
                <q-icon name="branding_watermark" />
              </template>
            </q-select>
          </div>
          <div class="row justify-evenly items-center">
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="grupo"
              :options="dataset_lookup_grupo"
              label="Grupo"
              option-value="cd_grupo_produto"
              option-label="nm_grupo_produto"
              @input="Select(1)"
            >
              <template v-slot:prepend>
                <q-icon name="group" />
              </template>
            </q-select>

            <q-input
              dense
              class="umTercoTela margin1"
              v-model="produto.nm_fantasia_produto"
              label="Fantasia"
            >
              <template v-slot:prepend>
                <q-icon name="business" />
              </template>
            </q-input>

            <q-select
              dense
              class="umTercoTela margin1"
              v-model="unidade_medida"
              :options="dataset_lookup_unidade_medida"
              label="Unidade de Medida"
              option-value="cd_unidade_medida"
              option-label="nm_unidade_medida"
              @input="Select(2)"
            >
              <template v-slot:prepend>
                <q-icon name="analytics" />
              </template>
            </q-select>
          </div>
          <div class="row justify-evenly items-center">
            <q-input
              dense
              class="umTercoTela margin1"
              v-model="produto.ds_produto"
              label="Descrição"
              autogrow
            >
              <template v-slot:prepend>
                <q-icon name="description" />
              </template>
            </q-input>

            <q-select
              dense
              class="umTercoTela margin1"
              v-model="status"
              :options="dataset_lookup_status"
              label="Status"
              option-value="cd_status_produto"
              option-label="nm_status_produto"
              @input="Select(3)"
            >
              <template v-slot:prepend>
                <q-icon name="sort" />
              </template>
            </q-select>

            <q-input
              dense
              class="umTercoTela margin1"
              v-model="produto.cd_mascara_produto"
              label="Código"
            >
              <template v-slot:prepend>
                <q-icon name="masks" />
              </template>
            </q-input>
          </div>
          <div class="row justify-evenly items-center">
            <q-input
              dense
              class="umTercoTela margin1"
              v-model="produto.VL_PRODUTO"
              @blur="FormataValor()"
              label="Valor"
            >
              <template v-slot:prepend>
                <q-icon name="attach_money" />
              </template>
            </q-input>

            <q-select
              dense
              class="umTercoTela margin1"
              v-model="categoria"
              :options="dataset_lookup_categoria"
              label="Categoria"
              option-value="cd_categoria_produto"
              option-label="nm_categoria_produto"
              @input="Select(4)"
            >
              <template v-slot:prepend>
                <q-icon name="category" />
              </template>
            </q-select>

            <q-input
              dense
              class="umTercoTela margin1"
              v-model="produto.cd_codigo_barra_produto"
              label="Código de Barra"
            >
              <template v-slot:prepend>
                <q-icon name="qr_code" />
              </template>
            </q-input>
          </div>
          <div class="row justify-evenly items-center">
            <q-input
              dense
              class="umTercoTela margin1"
              v-model="produto.pc_icms_produto"
              mask="##.##"
              label="(%) de ICMS do Produto"
            >
              <template v-slot:prepend>
                <q-icon name="gavel" />
              </template>
            </q-input>

            <q-toggle
              class="umTercoTela margin1"
              v-model="ic_estoque_caixa_produto"
              color="orange-9"
              :false-value="'N'"
              :true-value="'S'"
              label="Movimenta Estoque do Produto"
            />

            <q-toggle
              class="umTercoTela margin1"
              v-model="ic_lista_preco_caixa_produto"
              color="orange-9"
              :false-value="'N'"
              :true-value="'S'"
              label="Apresenta na Lista de Preço"
            />
          </div>
          <div class="row justify-evenly items-center">
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="cor"
              :options="dataset_lookup_cor"
              label="Cor"
              option-value="cd_cor"
              option-label="nm_cor"
              @input="Select(25)"
            >
              <template v-slot:prepend>
                <q-icon name="palette" />
              </template>
            </q-select>
            <!-- <q-select
            dense
            class="umTercoTela margin1"
            v-model="familia"
            :options="dataset_lookup_familia"
            label="Família"
            option-value="cd_familia_produto"
            option-label="nm_familia_produto"
            @input="Select(26)"
          >
            <template v-slot:prepend>
              <q-icon name="inventory_2" />
            </template>
          </q-select> -->
            <q-input
              dense
              class="umTercoTela margin1"
              v-model="produto.nm_observacao_produto"
              label="Observação"
              autogrow
            >
              <template v-slot:prepend>
                <q-icon name="description" />
              </template>
            </q-input>
          </div>
          <!-- Fim Cadastro de Produto Simplificado -->
        </q-tab-panel>
        <q-tab-panel name="fiscal">
          <q-btn
            color="orange-9"
            icon="save"
            class="margin1"
            rounded
            label="Salvar"
            :loading="load_salvar_fiscal"
            @click="SalvaProdutoFiscal()"
          >
            <q-tooltip> Salva Produto </q-tooltip>
          </q-btn>

          <q-bar
            dense
            :class="'bg-' + color + ' text-white text-h5 text-center'"
            style="
              border-radius: 5px;
              width: auto;
              height: auto;
              font-weight: bold;
              font-size: 18px;
            "
          >
            {{ `Saída` }}
          </q-bar>

          <div class="row justify-evenly items-center">
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="classificacao_fiscal_saida"
              :options="dataset_lookup_classificacao_fiscal"
              label="Classificação Fiscal"
              option-value="cd_classificacao_fiscal"
              option-label="nm_classificacao_fiscal"
              @input="Select(6)"
            >
              <template v-slot:prepend>
                <q-icon name="format_list_bulleted" />
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="procedencia_saida"
              :options="dataset_lookup_procedencia"
              label="Procedência"
              option-value="cd_procedencia_produto"
              option-label="nm_procedencia_produto"
              @input="Select(7)"
            >
              <template v-slot:prepend>
                <q-icon name="account_tree" />
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="tipo_produto_saida"
              :options="dataset_lookup_tipo_produto"
              label="Tipo de Produto"
              option-value="cd_tipo_produto"
              option-label="nm_tipo_produto"
              @input="Select(8)"
            >
              <template v-slot:prepend>
                <q-icon name="format_align_justify" />
              </template>
            </q-select>
          </div>
          <div class="row justify-evenly items-center">
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="tributacao_saida"
              :options="dataset_lookup_tributacao"
              label="Tributação"
              option-value="cd_tributacao"
              option-label="nm_tributacao"
              @input="Select(9)"
            >
              <template v-slot:prepend>
                <q-icon name="article" />
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="dispositivo_legal_icms_saida"
              :options="dataset_lookup_dispositivo_legal_icms"
              label="Dispositivo Legal (ICMS)"
              option-value="cd_dispositivo_legal"
              option-label="nm_dispositivo_legal"
              @input="Select(10)"
            >
              <template v-slot:prepend>
                <q-icon name="feed" />
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="dispositivo_legal_ipi_saida"
              :options="dataset_lookup_dispositivo_legal_ipi"
              label="Dispositivo Legal (IPI)"
              option-value="cd_dispositivo_legal"
              option-label="nm_dispositivo_legal"
              @input="Select(11)"
            >
              <template v-slot:prepend>
                <q-icon name="feed" />
              </template>
            </q-select>
          </div>
          <div class="row justify-evenly items-center">
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="destinacao_produto_saida"
              :options="dataset_lookup_destinacao_produto"
              label="Destinação Padrão"
              option-value="cd_destinacao_produto"
              option-label="nm_destinacao_produto"
              @input="Select(12)"
            >
              <template v-slot:prepend>
                <q-icon name="navigation" />
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="tributacao_cupom_fiscal"
              :options="dataset_lookup_tributacao_cupom_fiscal"
              label="Tributação Cupom Fiscal"
              option-value="cd_tributacao"
              option-label="nm_tributacao"
              @input="Select(13)"
            >
              <template v-slot:prepend>
                <q-icon name="confirmation_number" />
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="sped_fiscal"
              :options="dataset_lookup_sped_fiscal"
              label="SPED Fiscal"
              option-value="cd_tipo_item"
              option-label="nm_tipo_item"
              @input="Select(14)"
            >
              <template v-slot:prepend>
                <q-icon name="receipt_long" />
              </template>
            </q-select>
          </div>
          <div class="row justify-evenly items-center">
            <q-input
              dense
              class="margin1 umTercoTela"
              mask="##.##"
              v-model="produto.pc_aliquota_iss_produto_saida"
              label="ISS (%)"
            >
              <template v-slot:prepend>
                <q-icon name="assignment" />
              </template>
            </q-input>
            <q-input
              dense
              class="margin1 umTercoTela"
              mask="##.##"
              v-model="produto.pc_aliquota_icms_produto_saida"
              label="ICMS (%)"
            >
              <template v-slot:prepend>
                <q-icon name="summarize" />
              </template>
            </q-input>
            <q-input
              dense
              class="margin1 umTercoTela"
              mask="##.##"
              v-model="produto.pc_interna_icms_produto_saida"
              label="ICMS (%) Interna"
            >
              <template v-slot:prepend>
                <q-icon name="list_alt" />
              </template>
            </q-input>
          </div>
          <div class="row justify-evenly items-center">
            <q-input
              dense
              class="margin1 umTercoTela"
              v-model="produto.vl_pauta_icms_produto_saida"
              label="Valor da Pauta do ICMS"
            >
              <template v-slot:prepend>
                <q-icon name="toc" />
              </template>
            </q-input>
            <q-input
              dense
              class="margin1 umTercoTela"
              type="number"
              v-model="produto.pc_reducao_piscofins_saida"
              label="Redução de PIS/COFINS"
            >
              <template v-slot:prepend>
                <q-icon name="equalizer" />
              </template>
            </q-input>
            <q-input
              dense
              class="margin1 umTercoTela"
              mask="##.##"
              v-model="produto.pc_iva_icms_produto_saida"
              label="(%) IVA ICMS"
            >
              <template v-slot:prepend>
                <q-icon name="sort" />
              </template>
            </q-input>
          </div>

          <div class="row justify-evenly items-center">
            <q-select
              dense
              class="umQuartoTela margin1"
              v-model="conta_saida"
              :options="dataset_lookup_plano_conta"
              label="Conta Contábil"
              option-value="cd_conta"
              option-label="nm_conta"
              @input="Select(23)"
            >
              <template v-slot:prepend>
                <q-icon name="account_balance" />
              </template>
            </q-select>

            <q-input
              dense
              class="margin1 umQuartoTela"
              v-model="produto.vl_ipi_produto_fiscal_saida"
              label="Valor do IPI"
            >
              <template v-slot:prepend>
                <q-icon name="analytics" />
              </template>
            </q-input>
            <q-toggle
              class="margin1 umQuartoTela"
              v-model="ic_substrib_produto_saida"
              :false-value="'N'"
              :true-value="'S'"
              color="orange-9"
              label="Substituição Tributária"
            />
            <q-toggle
              class="margin1 umQuartoTela"
              v-model="ic_isento_icms_produto_saida"
              :false-value="'N'"
              :true-value="'S'"
              color="orange-9"
              label="ICMS Isento"
            />
          </div>

          <q-bar
            dense
            :class="'bg-' + color + ' text-white text-h5 text-center'"
            style="
              border-radius: 5px;
              width: auto;
              height: auto;
              font-weight: bold;
              font-size: 18px;
            "
          >
            {{ `Entrada` }}
          </q-bar>

          <div class="row">
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="classificacao_fiscal_entrada"
              :options="dataset_lookup_classificacao_fiscal"
              label="Classificação Fiscal"
              option-value="cd_classificacao_fiscal"
              option-label="nm_classificacao_fiscal"
              @input="Select(15)"
            >
              <template v-slot:prepend>
                <q-icon name="format_list_bulleted" />
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="procedencia_entrada"
              :options="dataset_lookup_procedencia"
              label="Procedência"
              option-value="cd_procedencia_produto"
              option-label="nm_procedencia_produto"
              @input="Select(16)"
            >
              <template v-slot:prepend>
                <q-icon name="account_tree" />
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="tipo_produto_entrada"
              :options="dataset_lookup_tipo_produto"
              label="Tipo de Produto"
              option-value="cd_tipo_produto"
              option-label="nm_tipo_produto"
              @input="Select(17)"
            >
              <template v-slot:prepend>
                <q-icon name="format_align_justify" />
              </template>
            </q-select>
          </div>
          <div class="row">
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="tributacao_entrada"
              :options="dataset_lookup_tributacao"
              label="Tributação"
              option-value="cd_tributacao"
              option-label="nm_tributacao"
              @input="Select(18)"
            >
              <template v-slot:prepend>
                <q-icon name="article" />
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="dispositivo_legal_icms_entrada"
              :options="dataset_lookup_dispositivo_legal_icms"
              label="Dispositivo Legal (ICMS)"
              option-value="cd_dispositivo_legal"
              option-label="nm_dispositivo_legal"
              @input="Select(19)"
            >
              <template v-slot:prepend>
                <q-icon name="feed" />
              </template>
            </q-select>
            <q-select
              dense
              class="umTercoTela margin1"
              v-model="dispositivo_legal_ipi_entrada"
              :options="dataset_lookup_dispositivo_legal_ipi"
              label="Dispositivo Legal (IPI)"
              option-value="cd_dispositivo_legal"
              option-label="nm_dispositivo_legal"
              @input="Select(20)"
            >
              <template v-slot:prepend>
                <q-icon name="feed" />
              </template>
            </q-select>
          </div>
          <div class="row">
            <q-select
              dense
              class="metadeTela margin1"
              v-model="destinacao_produto_entrada"
              :options="dataset_lookup_destinacao_produto"
              label="Destinação Padrão"
              option-value="cd_destinacao_produto"
              option-label="nm_destinacao_produto"
              @input="Select(21)"
            >
              <template v-slot:prepend>
                <q-icon name="navigation" />
              </template>
            </q-select>

            <q-select
              dense
              class="metadeTela margin1"
              v-model="sped_fiscal_entrada"
              :options="dataset_lookup_sped_fiscal"
              label="SPED Fiscal"
              option-value="cd_tipo_item"
              option-label="nm_tipo_item"
              @input="Select(22)"
            >
              <template v-slot:prepend>
                <q-icon name="receipt_long" />
              </template>
            </q-select>
          </div>
          <div class="row">
            <q-input
              dense
              class="margin1 umTercoTela"
              mask="##.##"
              v-model="produto.pc_aliquota_iss_produto_entrada"
              label="ISS (%)"
            >
              <template v-slot:prepend>
                <q-icon name="assignment" />
              </template>
            </q-input>
            <q-input
              dense
              class="margin1 umTercoTela"
              mask="##.##"
              v-model="produto.pc_aliquota_icms_produto_entrada"
              label="ICMS (%)"
            >
              <template v-slot:prepend>
                <q-icon name="summarize" />
              </template>
            </q-input>
            <q-input
              dense
              class="margin1 umTercoTela"
              mask="##.##"
              v-model="produto.pc_interna_icms_produto_entrada"
              label="ICMS (%) Interna"
            >
              <template v-slot:prepend>
                <q-icon name="list_alt" />
              </template>
            </q-input>
            <!-- <q-input
              dense
              class="margin1 col"
              mask="##.##"
              v-model="produto.pc_ipi_entrada"
              label="IPI (%)"
            >
              <template v-slot:prepend>
                <q-icon name="text_snippet" />
              </template>
            </q-input> -->
          </div>

          <div class="row">
            <q-select
              dense
              class="umQuartoTela margin1"
              v-model="conta_entrada"
              :options="dataset_lookup_plano_conta"
              label="Conta Contábil"
              option-value="cd_conta"
              option-label="nm_conta"
              @input="Select(24)"
            >
              <template v-slot:prepend>
                <q-icon name="account_balance" />
              </template>
            </q-select>

            <q-input
              dense
              class="margin1 umQuartoTela"
              v-model="produto.vl_ipi_produto_fiscal_entrada"
              label="Valor do IPI"
            >
              <template v-slot:prepend>
                <q-icon name="analytics" />
              </template>
            </q-input>
            <q-toggle
              class="margin1 umQuartoTela"
              v-model="ic_substrib_produto_entrada"
              :false-value="'N'"
              :true-value="'S'"
              color="orange-9"
              label="Substituição Tributária"
            />
            <q-toggle
              class="margin1 umQuartoTela"
              v-model="ic_isento_icms_produto_entrada"
              :false-value="'N'"
              :true-value="'S'"
              color="orange-9"
              label="ICMS Isento"
            />
          </div>
        </q-tab-panel>
        <q-tab-panel name="fornecedor">
          <q-btn
            color="orange-9"
            icon="add"
            class="margin1"
            rounded
            label="Novo"
            :loading="load_novo_fornecedor"
            @click="NovoFornecedor()"
          >
            <q-tooltip> Novo Fornecedor </q-tooltip>
          </q-btn>

          <!-- <q-btn
          color="orange-9"
          icon="save"
          class="margin1"
          rounded
          label="Salvar"
          :loading="load_salvar_fornecedor"
          @click="SalvaProdutoFornecedor()"
        >
          <q-tooltip>
            Salva Fornecedor
          </q-tooltip>
        </q-btn> -->
          <transition name="slide-fade">
            <div v-if="ic_novo_fornecedor">
              <q-btn
                color="orange-9"
                flat
                rounded
                label="Selecionar"
                class="margin1"
                @click="SelecionaFornecedor()"
              >
              </q-btn>
              <dx-data-grid
                class="dx-card-componente"
                :data-source="dataSourceFornecedor"
                :columns="columnsFornecedor"
                :summary="totalFornecedor"
                key-expr="cd_controle"
                :show-borders="true"
                :focused-row-enabled="true"
                :column-auto-width="true"
                :column-hiding-enabled="false"
                :remote-operations="false"
                :word-wrap-enabled="false"
                :allow-column-reordering="true"
                :allow-column-resizing="true"
                :row-alternation-enabled="true"
                :repaint-changes-only="true"
                :autoNavigateToFocusedRow="true"
                :focused-row-index="0"
                :cacheEnable="false"
                @exporting="onExporting"
                @initialized="saveGridInstance"
                @focused-row-changed="RowChangedFornecedor"
                @row-dbl-click="SelecionaFornecedor()"
              >
                <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

                <DxGrouping :auto-expand-all="true" />
                <DxExport :enabled="true" />
                <DxEditing :allow-updating="false" mode="cell" />
                <DxPaging :enable="true" :page-size="10" />

                <DxStateStoring :enabled="false" type="localStorage" storage-key="storage" />
                <DxSelection mode="single" />
                <DxPager
                  :show-page-size-selector="true"
                  :allowed-page-sizes="pageSizes"
                  :show-info="true"
                />
                <DxFilterRow :visible="false" />
                <DxHeaderFilter :visible="true" :allow-search="true" />
                <DxSearchPanel :visible="temPanel" :width="300" placeholder="Procurar..." />
                <DxFilterPanel :visible="true" />
                <DxColumnFixing :enabled="true" />
                <DxColumnChooser :enabled="true" mode="select" />
              </dx-data-grid>
            </div>
          </transition>

          <div v-if="dataSourceFornecedorProduto.length > 0">
            <dx-data-grid
              class="dx-card-componente"
              :data-source="dataSourceFornecedorProduto"
              :columns="columnsFornecedorProduto"
              :summary="totalFornecedorProduto"
              key-expr="cd_controle"
              :show-borders="true"
              :focused-row-enabled="true"
              :column-auto-width="true"
              :column-hiding-enabled="false"
              :remote-operations="false"
              :word-wrap-enabled="false"
              :allow-column-reordering="true"
              :allow-column-resizing="true"
              :row-alternation-enabled="true"
              :repaint-changes-only="true"
              :autoNavigateToFocusedRow="true"
              :focused-row-index="0"
              :cacheEnable="false"
              @exporting="onExporting"
              @initialized="saveGridInstance"
              @row-removing="FornecedorRemovido"
            >
              <DxGroupPanel :visible="true" empty-panel-text="agrupar..." />

              <DxGrouping :auto-expand-all="true" />
              <DxExport :enabled="true" />
              <DxEditing :allow-updating="false" :allow-deleting="true" mode="cell" />
              <DxPaging :enable="true" :page-size="10" />

              <DxStateStoring :enabled="false" type="localStorage" storage-key="storage" />
              <DxSelection mode="single" />
              <DxPager
                :show-page-size-selector="true"
                :allowed-page-sizes="pageSizes"
                :show-info="true"
              />
              <DxFilterRow :visible="false" />
              <DxHeaderFilter :visible="true" :allow-search="true" />
              <DxSearchPanel :visible="temPanel" :width="300" placeholder="Procurar..." />
              <DxFilterPanel :visible="true" />
              <DxColumnFixing :enabled="true" />
              <DxColumnChooser :enabled="true" mode="select" />
            </dx-data-grid>
          </div>
          <div v-else>
            <div class="SemFornecedor">
              {{ `Nenhum fornecedor cadastrado para esse produto` }}
            </div>
          </div>
        </q-tab-panel>
      </q-tab-panels>
    </div>
    <!-- FIM TABS -->

    <div class="task-info" v-if="temD === true">
      <div class="info">
        <div id="taskSubject">{{ taskSubject }}</div>
        <p id="taskDetails" v-html="taskDetails" />
      </div>
    </div>

    <div class="botao-exportar">
      <div>
        <DxButton
          v-if="exportar == true"
          :width="120"
          text="DOWNLOAD"
          type="default"
          styling-mode="contained"
          horizontal-alignment="left"
          @click="onClickExportar()"
        />
      </div>
    </div>

    <DxPopup
      :visible="popupVisible"
      :title="tituloMenu"
      :height="250"
      :show-title="true"
      :close-on-outside-click="true"
      :drag-enabled="false"
      @hiding="onHiding"
    >
      <DxForm> </DxForm>
      <div>
        <b class="info-cor">{{ ds_menu_descritivo }}</b>
      </div>
    </DxPopup>

    <div v-if="ativaPDF" class="q-pa-md q-gutter-sm">
      <q-btn label="Maximized" color="primary" @click="dialog = true" />

      <q-dialog
        v-model="ativaPDF"
        persistent
        :maximized="true"
        transition-show="slide-up"
        transition-hide="slide-down"
      >
        <q-card class="bg-primary text-white">
          <q-bar>
            <div class="div50">
              <label> DOCUMENTO </label>
            </div>
            <div class="div48">
              <q-btn
                dense
                flat
                icon="minimize"
                @click="maximizedToggle = false"
                :disable="!maximizedToggle"
              >
                <q-tooltip v-if="maximizedToggle" content-class="bg-white text-primary"
                  >Minimize</q-tooltip
                >
              </q-btn>
              <q-btn
                dense
                flat
                icon="crop_square"
                @click="maximizedToggle = true"
                :disable="maximizedToggle"
              >
                <q-tooltip v-if="!maximizedToggle" content-class="bg-white text-primary"
                  >Maximize</q-tooltip
                >
              </q-btn>
              <q-btn dense flat icon="close" v-close-popup>
                <q-tooltip content-class="bg-white text-primary">Close</q-tooltip>
              </q-btn>
            </div>
          </q-bar>
          <q-space />

          <embed v-bind:src="onClickArquivo()" v-if="ativaPDF" width="100%" height="100%" />
        </q-card>
      </q-dialog>
    </div>

    <div v-if="popupData == true">
      <q-dialog v-model="popupData">
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <div class="text-h6">Seleção de Data</div>
            <q-space />
            <q-btn icon="close" @click="popClickData()" flat round dense v-close-popup />
          </q-card-section>

          <selecaoData :cd_volta_home="1"> </selecaoData>
        </q-card>
      </q-dialog>
    </div>

    <!----POPUP CONFIRMA PESQUISA DE PRODUTO SEM FILTRO---------------------------------------------------------->
    <q-dialog v-model="popup_pesquisa_filtro" style="max-width: 700px">
      <q-card style="border-radius: 20px">
        <q-card-section>
          <q-bar
            dense
            :class="'bg-' + color + ' text-white text-h5 text-center'"
            style="border-radius: 5px; width: auto; height: auto"
          >
            Deseja realmente pesquisar todos os produtos?
          </q-bar>
          <q-separator class="margin1" />
          <div class="text-center text-subtitle2">Essa pesquisa pode demorar!</div>
          <br />
          <div class="row items-center">
            <q-btn
              rounded
              flat
              class="col margin1"
              icon="check"
              color="positive"
              label="Confirmar"
              @click="onPesquisaProduto"
            >
            </q-btn>
            <q-btn
              rounded
              flat
              class="col margin1"
              icon="close"
              color="negative"
              label="Cancelar"
              v-close-popup
            >
            </q-btn>
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>
    <!--Loading------------------------------------------------------------>
    <q-dialog v-model="load" maximized persistent>
      <carregando :corID="color" :mensagemID="msgDinamica" />
    </q-dialog>
  </div>
</template>

<script>
import {
  DxDataGrid,
  DxFilterRow,
  DxPager,
  DxPaging,
  DxExport,
  DxGroupPanel,
  DxGrouping,
  DxColumnChooser,
  DxColumnFixing,
  DxHeaderFilter,
  DxFilterPanel,
  DxSelection,
  DxStateStoring,
  DxSearchPanel,
  DxEditing,
} from 'devextreme-vue/data-grid'

import { DxForm } from 'devextreme-vue/form'

import DxButton from 'devextreme-vue/button'
import { DxPopup } from 'devextreme-vue/popup'
import { exportDataGrid } from 'devextreme/excel_exporter'
import ExcelJS from 'exceljs'
import saveAs from 'file-saver'
import ptMessages from 'devextreme/localization/messages/pt.json'
import { locale, loadMessages } from 'devextreme/localization'
import config from 'devextreme/core/config'
import notify from 'devextreme/ui/notify'

import selecaoData from '../views/selecao-periodo.vue'

import Procedimento from '../http/procedimento'
import Menu from '../http/menu'
import componente from '../views/display-componente'
import Incluir from '../http/incluir_registro'
import funcao from '../http/funcoes-padroes.js'

import Lookup from '../http/lookup'

import 'whatwg-fetch'

import Docxtemplater from 'docxtemplater'

import PizZip from 'pizzip'
import PizZipUtils from 'pizzip/utils/index.js'

function loadFile(url, callback) {
  PizZipUtils.getBinaryContent(url, callback)
}

var filename = 'DataGrid.xlsx'
var filenametxt = 'Arquivo.txt'
var filenamedoc = 'Arquivo.docx'
var filenamexml = 'Arquivo.xml'

var dados = []

export default {
  props: {
    cad_produto: { type: String, default: '' },
    ic_cadastro: { type: Boolean, default: true },
    ic_mostra_titulo: { type: Boolean, default: true },
    ic_comprado: { type: Boolean, default: false },
  },
  watch: {
    ic_estoque_caixa_produto(a) {
      if (a == 'S') {
        this.produto.ic_estoque_caixa_produto = 'S'
      } else if (a == 'N') {
        this.produto.ic_estoque_caixa_produto = 'N'
      }
    },
    ic_lista_preco_caixa_produto(a) {
      if (a == 'S') {
        this.produto.ic_lista_preco_caixa_produto = 'S'
      } else if (a == 'N') {
        this.produto.ic_lista_preco_caixa_produto = 'N'
      }
    },
    ic_substrib_produto_saida(a) {
      if (a == 'S') {
        this.produto.ic_substrib_produto_saida = 'S'
      } else if (a == 'N') {
        this.produto.ic_substrib_produto_saida = 'N'
      }
    },
    ic_substrib_produto_entrada(a) {
      if (a == 'S') {
        this.produto.ic_substrib_produto_entrada = 'S'
      } else if (a == 'N') {
        this.produto.ic_substrib_produto_entrada = 'N'
      }
    },
    ic_isento_icms_produto_saida(a) {
      if (a == 'S') {
        this.produto.ic_isento_icms_produto_saida = 'S'
      } else if (a == 'N') {
        this.produto.ic_isento_icms_produto_saida = 'N'
      }
    },
    ic_isento_icms_produto_entrada(a) {
      if (a == 'S') {
        this.produto.ic_isento_icms_produto_entrada = 'S'
      } else if (a == 'N') {
        this.produto.ic_isento_icms_produto_entrada = 'N'
      }
    },
  },
  data() {
    return {
      tituloMenu: '',
      produto: {},
      tipo_pesquisa_produto: 'N',
      codigo: false,
      load: false,
      color: 'primary',
      msgDinamica: '',
      linhaProduto: '',
      fornecedor: [],
      ic_novo_fornecedor: false,
      dataSourceFornecedor: [],
      columnsFornecedor: '',
      totalFornecedor: '',
      resultado_pesquisa: [],
      grupo: [],
      dataset_lookup_grupo: [],
      nm_fantasia_produto: '',
      unidade_medida: '',
      dataset_lookup_unidade_medida: [],
      ds_produto: '',
      status: [],
      dataset_lookup_status: [],
      marca: '',
      dataset_lookup_marca: [],
      familia: '',
      dataset_lookup_familia: [],
      nm_mascara_produto: '',
      categoria: [],
      dataset_lookup_categoria: [],
      classificacao_fiscal_saida: '',
      classificacao_fiscal_entrada: '',
      dataset_lookup_classificacao_fiscal: [],
      procedencia_saida: '',
      procedencia_entrada: '',
      dataset_lookup_procedencia: [],
      tipo_produto_saida: '',
      tipo_produto_entrada: '',
      dataset_lookup_tipo_produto: [],
      tributacao_saida: '',
      tributacao_entrada: '',
      dataset_lookup_tributacao: [],
      dataset_lookup_tributacao_cupom_fiscal: [],
      tributacao_cupom_fiscal: '',
      dataset_lookup_dispositivo_legal_ipi: [],
      dispositivo_legal_ipi_saida: '',
      dispositivo_legal_ipi_entrada: '',
      dataset_lookup_dispositivo_legal_icms: [],
      dispositivo_legal_icms_saida: '',
      dispositivo_legal_icms_entrada: '',
      dataset_lookup_destinacao_produto: [],
      destinacao_produto_saida: '',
      destinacao_produto_entrada: '',
      dataset_lookup_sped_fiscal: [],
      sped_fiscal: '',
      dataset_lookup_cor: [],
      cor: '',
      sped_fiscal_entrada: '',
      dataset_lookup_plano_conta: [],
      conta_entrada: '',
      conta_saida: '',
      cd_codigo_barra_produto: '',
      pc_icms_produto: '',
      ic_estoque_caixa_produto: 'N',
      ic_lista_preco_caixa_produto: 'N',
      categoria_pesquisa: '',
      cd_usuario: localStorage.cd_usuario,
      grupo_pesquisa: '',
      marca_pesquisa: '',
      cd_mascara_produto: '',
      nm_produto: '',
      popup_pesquisa_filtro: false,
      load_salvar: false,
      load_salvar_fiscal: false,
      load_salvar_fornecedor: false,
      load_novo_fornecedor: false,
      tab: this.cad_produto === '' ? 'dados' : this.cad_produto,
      ic_substrib_produto_saida: 'N',
      ic_substrib_produto_entrada: 'N',
      ic_isento_icms_produto_saida: 'N',
      ic_isento_icms_produto_entrada: 'N',
      menu: '',
      dt_inicial: '',
      dt_final: '',
      dt_base: '',
      pageSizes: [10, 20, 50, 100],
      dataSourceFornecedorProduto: [],
      columnsFornecedorProduto: '',
      totalFornecedorProduto: '',
      dataSourceConfig: [],
      columns: [],
      total: {},
      dataGridInstance: null,
      taskSubject: 'Descritivo',
      taskDetails: '',
      temD: false,
      temPanel: false,
      qt_tabsheet: 0,
      tabs: [],
      selectedIndex: 0,
      cd_menu_destino: 0,
      cd_api_destino: 0,
      cd_tipo_consulta: 0,
      ic_filtro_pesquisa: 'N',
      qt_tempo: 0,
      filtro: [],
      polling: null,
      exportar: false,
      arquivo_abrir: false,
      ativaPDF: false,
      cd_empresa: localStorage.cd_empresa,
      cd_menu: localStorage.cd_menu,
      cd_cliente: 0,
      cd_api: 0,
      api: 0,
      ds_arquivo: '',
      nm_documento: '',
      ds_menu_descritivo: '',
      popupVisible: false,
      popupData: false,
      periodoVisible: false,
      ic_form_menu: 'N',
      ic_tipo_data_menu: '0',
      hoje: '',
      hora: '',
      formData: {},
      items: [],
      cd_tipo_email: 0,
      cd_relatorio: 1,
      qt_registro: 0,
      cd_detalhe: 0,
      cd_menu_detalhe: 0,
      cd_api_detalhe: 0,
      cd_identificacao: '',
      text: '',

      dados_lookup: [],
      dataset_lookup: [],
      value_lookup: '',
      label_lookup: '',
      placeholder_lookup: '',
      selecionada_lookup: [],

      periodo: '',
    }
  },
  computed: {
    gridPadrao() {
      return this.$refs['gridPadrao'].instance
    },
  },

  async created() {
    //locale(navigator.language);
    config({ defaultCurrency: 'BRL' })
    loadMessages(ptMessages)
    locale(navigator.language)

    localStorage.cd_filtro = 0
    localStorage.cd_parametro = 0
    localStorage.cd_tipo_consulta = 0
    localStorage.cd_tipo_filtro = 0
    localStorage.cd_documento = 0

    this.dt_inicial = localStorage.dt_inicial
    this.dt_final = localStorage.dt_final
    this.dt_base = localStorage.dt_base
    this.periodoVisible = false

    this.hoje = ''
    this.hora = ''

    if (!this.qt_tempo == 0) {
      this.pollData()
      localStorage.polling = 1
    }
    try {
      //Parâmetros Produtos Gráfica
      let parametro_grafica_tab = await Lookup.montarSelect(this.cd_empresa, 3150)
      let [parametro_grafica] = JSON.parse(
        JSON.parse(JSON.stringify(parametro_grafica_tab.dataset))
      )
      this.$emit('ParametroGrafica', parametro_grafica)
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(error)
    }
    const dados_lookup_grupo = await Lookup.montarSelect(this.cd_empresa, 159)
    this.dataset_lookup_grupo = JSON.parse(JSON.parse(JSON.stringify(dados_lookup_grupo.dataset)))

    const dados_lookup_status = await Lookup.montarSelect(this.cd_empresa, 183)
    this.dataset_lookup_status = JSON.parse(JSON.parse(JSON.stringify(dados_lookup_status.dataset)))

    const dados_lookup_categoria = await Lookup.montarSelect(this.cd_empresa, 261)
    this.dataset_lookup_categoria = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_categoria.dataset))
    )
    /////////////////////////////////////////////
    const dados_lookup_cor = await Lookup.montarSelect(this.cd_empresa, 912)
    this.dataset_lookup_cor = JSON.parse(JSON.parse(JSON.stringify(dados_lookup_cor.dataset)))

    const dados_lookup_familia = await Lookup.montarSelect(this.cd_empresa, 3020)
    this.dataset_lookup_familia = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_familia.dataset))
    )
    //////////////////////////////////////////////
    const dados_lookup_unidade_medida = await Lookup.montarSelect(this.cd_empresa, 138)
    this.dataset_lookup_unidade_medida = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_unidade_medida.dataset))
    )

    const dados_lookup_marca = await Lookup.montarSelect(this.cd_empresa, 2406)
    this.dataset_lookup_marca = JSON.parse(JSON.parse(JSON.stringify(dados_lookup_marca.dataset)))

    const dados_lookup_classificacao_fiscal = await Lookup.montarSelect(this.cd_empresa, 172)
    this.dataset_lookup_classificacao_fiscal = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_classificacao_fiscal.dataset))
    )
    const dados_lookup_procedencia = await Lookup.montarSelect(this.cd_empresa, 226)
    this.dataset_lookup_procedencia = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_procedencia.dataset))
    )
    const dados_lookup_tipo_produto = await Lookup.montarSelect(this.cd_empresa, 268)
    this.dataset_lookup_tipo_produto = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_tipo_produto.dataset))
    )
    const dados_lookup_tributacao = await Lookup.montarSelect(this.cd_empresa, 205)
    this.dataset_lookup_tributacao = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_tributacao.dataset))
    )
    const dados_lookup_tributacao_cupom_fiscal = await Lookup.montarSelect(this.cd_empresa, 2264)
    this.dataset_lookup_tributacao_cupom_fiscal = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_tributacao_cupom_fiscal.dataset))
    )
    const dados_lookup_dispositivo_legal = await Lookup.montarSelect(this.cd_empresa, 203)
    let dataset_lookup_dispositivo_legal = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_dispositivo_legal.dataset))
    )
    this.dataset_lookup_dispositivo_legal_ipi = dataset_lookup_dispositivo_legal.filter((e) => {
      return e.cd_imposto == 2
    })
    this.dataset_lookup_dispositivo_legal_icms = dataset_lookup_dispositivo_legal.filter((e) => {
      return e.cd_imposto == 1
    })

    const dados_lookup_destinacao_produto = await Lookup.montarSelect(this.cd_empresa, 227)
    this.dataset_lookup_destinacao_produto = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_destinacao_produto.dataset))
    )

    const dados_lookup_sped_fiscal = await Lookup.montarSelect(this.cd_empresa, 2913)
    this.dataset_lookup_sped_fiscal = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_sped_fiscal.dataset))
    )

    const dados_lookup_plano_conta = await Lookup.montarSelect(this.cd_empresa, 10)
    this.dataset_lookup_plano_conta = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookup_plano_conta.dataset))
    )
    this.dataset_lookup_plano_conta.map((e) => {
      e.nm_conta = e.cd_mascara_conta + ' | ' + e.nm_conta
    })
  },

  async mounted() {
    localStorage.cd_filtro = 0
    localStorage.cd_parametro = 0
    localStorage.cd_tipo_consulta = 0
    localStorage.cd_tipo_filtro = 0
    localStorage.cd_documento = 0
    this.load = true
    this.color = 'orange-9'
    this.msgDinamica = 'Carregando a tela de Produtos...'
    await this.carregaDados()
    this.load = false
  },

  components: {
    DxDataGrid,
    DxFilterRow,
    DxPager,
    DxPaging,
    DxExport,
    DxGroupPanel,
    DxGrouping,
    DxColumnChooser,
    DxColumnFixing,
    DxHeaderFilter,
    DxFilterPanel,
    DxSelection,
    DxStateStoring,
    DxSearchPanel,
    DxForm,
    DxButton,
    DxPopup,
    DxEditing,
    selecaoData,
    carregando: () => import('../components/carregando.vue'),
  },

  methods: {
    async FormataValor() {
      this.produto.VL_PRODUTO = await funcao.FormataValor(this.produto.VL_PRODUTO)
    },
    popClick() {
      this.popupVisible = true
    },

    popClickData() {
      if (this.popupData == false) {
        this.popupData = true
      } else {
        this.popupData = false
        if (this.qt_tabsheet == 0) {
          this.carregaDados()
        } else {
          this.$refs.componentetabsheet.carregaDados()
        }
      }
    },

    onHiding() {
      this.popupVisible = false // Handler of the 'hiding' event
    },

    async SelecionaProduto() {
      await this.$refs.gridPadrao.instance.saveEditData()
      await funcao.sleep(1)
      const itemsSelecionados = this.dataSourceConfig.filter((e) => {
        if (e.qt_digitacao > 0) {
          return e
        }
      })
      this.dataSourceConfig = []
      this.nm_produto = ''
      this.$emit(
        'SelectProduto',
        itemsSelecionados.length > 0 ? itemsSelecionados : this.linhaProduto
      )
    },

    NovoProduto() {
      this.produto = {
        cd_produto: 0,
      }
      this.grupo = []
      this.marca = ''
      this.unidade_medida = []
      this.status = []
      this.categoria = []
      this.classificacao_fiscal_saida = []
      this.classificacao_fiscal_entrada = []
      this.procedencia_saida = []
      this.procedencia_entrada = []
      this.tipo_produto_saida = []
      this.tipo_produto_entrada = []
      this.tributacao_saida = []
      this.tributacao_entrada = []
      this.dispositivo_legal_ipi_saida = []
      this.dispositivo_legal_ipi_entrada = []
      this.dispositivo_legal_icms_saida = []
      this.dispositivo_legal_icms_entrada = []
      this.destinacao_produto_saida = []
      this.destinacao_produto_entrada = []
      this.tributacao_cupom_fiscal = []
      this.sped_fiscal = []
      this.sped_fiscal_entrada = []
      this.conta_entrada = []
      this.conta_saida = []
      this.cor = []
      this.familia = []
      this.ic_substrib_produto_saida = 'N'
      this.ic_substrib_produto_entrada = 'N'
      this.ic_isento_icms_produto_saida = 'N'
      this.ic_isento_icms_produto_entrada = 'N'
      this.ic_estoque_caixa_produto = 'N'
      this.ic_lista_preco_caixa_produto = 'N'
    },

    async trocaTab(e) {
      if (e == 'fornecedor') {
        if (!!this.produto.cd_produto == false) {
          this.tab = 'fiscal'
          return notify('Por favor,selecione um produto!')
        }
        await this.carregaFornecedor()
      }
    },

    async SalvaProdutoFiscal() {
      if (this.produto.cd_produto == undefined) {
        return notify('Por favor, selecione um produto!')
      }
      let JSON_Produto_Fiscal = {
        cd_parametro: 4,
        cd_produto: this.produto.cd_produto,
        cd_classificacao_fiscal_saida: this.produto.cd_classificacao_fiscal_saida,
        cd_procedencia_produto_saida: this.produto.cd_procedencia_produto_saida,
        cd_tipo_produto_saida: this.produto.cd_tipo_produto_saida,
        cd_tributacao_saida: this.produto.cd_tributacao_saida,
        cd_dispositivo_legal_icms_saida: this.produto.cd_dispositivo_legal_icms_saida,
        cd_dispositivo_legal_ipi_saida: this.produto.cd_dispositivo_legal_ipi_saida,
        cd_destinacao_produto_saida: this.produto.cd_destinacao_produto_saida,
        cd_tributacao_cupom_fiscal: this.produto.cd_tributacao_cupom_fiscal,
        cd_tipo_item_saida: this.produto.cd_tipo_item_saida,
        ic_substrib_produto_saida: this.produto.ic_substrib_produto_saida,
        ic_isento_icms_produto_saida: this.produto.ic_isento_icms_produto_saida,
        pc_aliquota_iss_produto_saida: this.produto.pc_aliquota_iss_produto_saida,
        pc_aliquota_icms_produto_saida: this.produto.pc_aliquota_icms_produto_saida,
        pc_interna_icms_produto_saida: this.produto.pc_interna_icms_produto_saida,
        vl_pauta_icms_produto_saida: this.produto.vl_pauta_icms_produto_saida,
        pc_reducao_piscofins_saida: this.produto.pc_reducao_piscofins_saida,
        pc_iva_icms_produto_saida: this.produto.pc_iva_icms_produto_saida,
        cd_conta_saida: this.produto.cd_conta_saida,
        nm_conta_saida: this.produto.nm_conta_saida,
        vl_ipi_produto_fiscal_saida: this.produto.vl_ipi_produto_fiscal_saida,
        //Entrada
        ic_substrib_produto_entrada: this.produto.ic_substrib_produto_entrada,
        ic_isento_icms_produto_entrada: this.produto.ic_isento_icms_produto_entrada,
        cd_classificacao_fiscal_entrada: this.produto.cd_classificacao_fiscal_entrada,
        cd_procedencia_produto_entrada: this.produto.cd_procedencia_produto_entrada,
        cd_tipo_produto_entrada: this.produto.cd_tipo_produto_entrada,
        cd_tributacao_entrada: this.produto.cd_tributacao_entrada,
        cd_dispositivo_legal_icms_entrada: this.produto.cd_dispositivo_legal_icms_entrada,
        cd_dispositivo_legal_ipi_entrada: this.produto.cd_dispositivo_legal_ipi_entrada,
        cd_destinacao_produto_entrada: this.produto.cd_destinacao_produto_entrada,
        cd_tipo_item_entrada: this.produto.cd_tipo_item_entrada,
        pc_aliquota_iss_produto_entrada: this.produto.pc_aliquota_iss_produto_entrada,
        pc_aliquota_icms_produto_entrada: this.produto.pc_aliquota_icms_produto_entrada,
        pc_interna_icms_produto_entrada: this.produto.pc_interna_icms_produto_entrada,
        vl_pauta_icms_produto_entrada: this.produto.vl_pauta_icms_produto_entrada,
        pc_reducao_piscofins_entrada: this.produto.pc_reducao_piscofins_entrada,
        pc_iva_icms_produto_entrada: this.produto.pc_iva_icms_produto_entrada,
        cd_conta_entrada: this.produto.cd_conta_entrada,
        nm_conta_entrada: this.produto.nm_conta_entrada,
        vl_ipi_produto_fiscal_entrada: this.produto.vl_ipi_produto_fiscal_entrada,
      }
      this.load_salvar_fiscal = true
      let resultado_salvar_fiscal = await Incluir.incluirRegistro(this.api, JSON_Produto_Fiscal)
      this.load_salvar_fiscal = false
      notify(resultado_salvar_fiscal[0].Msg)
    },

    async NovoFornecedor() {
      this.load_novo_fornecedor = true
      let menu_fornecedor = await Menu.montarMenu(this.cd_empresa, 7495, 771)
      let api = menu_fornecedor.nm_identificacao_api
      let sParametroApi = menu_fornecedor.nm_api_parametro
      //dados da coluna
      this.columnsFornecedor = JSON.parse(JSON.parse(JSON.stringify(menu_fornecedor.coluna)))

      //dados do total
      this.totalFornecedor = JSON.parse(JSON.parse(JSON.stringify(menu_fornecedor.coluna_total)))
      //
      localStorage.cd_parametro = 0
      localStorage.cd_tipo_consulta = 0
      this.dataSourceFornecedor = await Procedimento.montarProcedimento(
        this.cd_empresa,
        localStorage.cd_cliente,
        api,
        sParametroApi
      )

      this.ic_novo_fornecedor = !this.ic_novo_fornecedor
      this.load_novo_fornecedor = false
    },

    async SelecionaFornecedor() {
      let JSON_Fornecedor = {
        cd_parametro: 5,
        cd_produto: this.produto.cd_produto,
        cd_fornecedor: this.fornecedor.cd_fornecedor,
      }
      let resultado_fornecedor = await Incluir.incluirRegistro(this.api, JSON_Fornecedor)
      notify(resultado_fornecedor[0].Msg)
      await this.carregaFornecedor()
      this.ic_novo_fornecedor = false
    },

    async SalvaProduto() {
      try {
        this.produto.nm_produto = !this.produto.nm_produto
          ? this.nm_produto
          : this.produto.nm_produto
        if (!this.produto.nm_produto && !this.produto.Produto) {
          return notify('Informe o nome do Produto')
        }
        let JSON_Salvar = {
          cd_parametro: 0,
          cd_produto: this.produto.cd_produto,
          cd_mascara_produto: this.produto.cd_mascara_produto,
          nm_produto: !this.produto.nm_produto ? this.produto.Produto : this.produto.nm_produto,
          nm_fantasia_produto: this.produto.nm_fantasia_produto,
          nm_marca_produto: this.produto.nm_marca_produto,
          ds_produto: this.produto.ds_produto,
          cd_grupo_produto: this.produto.cd_grupo_produto,
          cd_status_produto: this.produto.cd_status_produto,
          cd_unidade_medida: this.produto.cd_unidade_medida,
          cd_categoria_produto: this.produto.cd_categoria_produto,
          vl_produto: this.produto.VL_PRODUTO,
          cd_usuario: this.cd_usuario,
          cd_codigo_barra_produto: this.produto.cd_codigo_barra_produto,
          cd_serie_produto: this.produto.cd_serie_produto,
          pc_icms_produto: this.produto.pc_icms_produto,
          cd_marca_produto: this.produto.cd_marca_produto,
          ic_estoque_caixa_produto: this.produto.ic_estoque_caixa_produto,
          ic_lista_preco_caixa_produto: this.produto.ic_lista_preco_caixa_produto,
          cd_familia_produto: this.produto.cd_familia_produto,
          cd_cor: this.produto.cd_cor,
          nm_observacao_produto: this.produto.nm_observacao_produto,
        }
        if (this.produto.cd_produto) {
          //Update
          JSON_Salvar.cd_parametro = 2
        } else {
          //Insert
          JSON_Salvar.cd_parametro = 1
        }
        this.load_salvar = true
        const resultado_salvar = await Incluir.incluirRegistro(this.api, JSON_Salvar)
        notify(resultado_salvar[0].Msg)
        await this.onPesquisaProduto()
        this.load_salvar = false
      } catch (error) {
        this.load_salvar = false
      }
    },

    LimpaProduto() {
      this.produto = {}
      this.grupo = []
      this.unidade_medida = []
      this.status = []
      this.categoria = []
    },

    async onVerificaPesquisaProduto() {
      if (
        this.categoria_pesquisa.cd_categoria_produto == undefined &&
        this.grupo_pesquisa.cd_grupo_produto == undefined &&
        this.marca_pesquisa.cd_marca_produto == undefined &&
        this.cd_mascara_produto == '' &&
        this.nm_fantasia_produto == '' &&
        this.nm_produto == ''
      ) {
        this.popup_pesquisa_filtro = true
      } else {
        await this.onPesquisaProduto()
      }
    },

    async onPesquisaProduto() {
      if (this.ic_comprado) {
        let menu_produto = await Menu.montarMenu(this.cd_empresa, 7721, 869)
        let api = menu_produto.nm_identificacao_api
        let sParametroApi = menu_produto.nm_api_parametro
        //dados da coluna
        this.colunas = JSON.parse(JSON.parse(JSON.stringify(menu_produto.coluna)))

        //dados do total
        this.total = JSON.parse(JSON.parse(JSON.stringify(menu_produto.coluna_total)))
        //
        //localStorage.cd_parametro = 0;
        //localStorage.cd_tipo_consulta = 0;
        this.dataSourceConfig = await Procedimento.montarProcedimento(
          this.cd_empresa,
          localStorage.cd_cliente,
          api,
          sParametroApi
        )
      } else {
        //Pesquisa Padrão de Produtos
        this.dataSourceConfig = []
        this.popup_pesquisa_filtro = false
        let JSON_Pesquisa = []
        if (this.tipo_pesquisa_produto == 'S') {
          JSON_Pesquisa = {
            cd_parametro: 10,
            cd_usuario: this.cd_usuario,
            cd_categoria_produto: this.categoria_pesquisa.cd_categoria_produto,
            cd_grupo_produto: this.grupo_pesquisa.cd_grupo_produto,
            cd_marca_produto: this.marca_pesquisa.cd_marca_produto,
            cd_mascara_produto: this.cd_mascara_produto,
            nm_fantasia_produto: this.nm_fantasia_produto,
            nm_produto: this.nm_produto,
          }
        } else if (this.tipo_pesquisa_produto == 'N') {
          JSON_Pesquisa = {
            cd_parametro: 12,
            cd_usuario: this.cd_usuario,
            nm_produto: this.nm_produto,
          }
        }
        this.dataSourceConfig = await Incluir.incluirRegistro(
          '562/781', //this.api, //// pr_egisnet_elabora_proposta
          JSON_Pesquisa
        )
        let menu_pesquisa = await Menu.montarMenu(this.cd_empresa, 7441, 562)
        this.colunas = JSON.parse(JSON.parse(JSON.stringify(menu_pesquisa.coluna)))

        if (this.dataSourceConfig[0].Cod === 0) {
          notify('Nenhum produto encontrado!')
          return
        }
      }
    },

    async showMenu() {
      this.cd_cliente = localStorage.cd_cliente
      this.cd_api = localStorage.cd_api
      this.api = localStorage.nm_identificacao_api // pr_egisnet_controle_produtos
      this.cd_menu_destino = 0
      this.cd_api_destino = 0
      localStorage.cd_parametro = 0

      var dataI = new Date(localStorage.dt_inicial)
      var diaI = dataI.getDate().toString()
      var mesI = (dataI.getMonth() + 1).toString()
      var anoI = dataI.getFullYear()
      localStorage.dt_inicial = mesI + '-' + diaI + '-' + anoI

      var dataF = new Date(localStorage.dt_final)
      var diaF = dataF.getDate().toString()
      var mesF = (dataF.getMonth() + 1).toString()
      var anoF = dataF.getFullYear()
      localStorage.dt_final = mesF + '-' + diaF + '-' + anoF

      var dataB = new Date(localStorage.dt_base)
      var diaB = dataB.getDate().toString()
      var mesB = (dataB.getMonth() + 1).toString()
      var anoB = dataB.getFullYear()

      localStorage.dt_base = mesB + '-' + diaB + '-' + anoB

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api) //'titulo';
      //this.sParametroApi       = dados.nm_api_parametro;

      if (!dados.nm_identificacao_api == '' && !dados.nm_identificacao_api == this.api) {
        this.api = dados.nm_identificacao_api
      }

      this.qt_tabsheet = dados.qt_tabsheet
      this.ic_filtro_pesquisa = dados.ic_filtro_pesquisa
      this.exportar = false
      this.arquivo_abrir = false
      this.ativaPDF = false
      this.qt_tempo = dados.qt_tempo_menu
      this.ds_menu_descritivo = dados.ds_menu_descritivo
      this.ic_form_menu = dados.ic_form_menu
      this.ic_tipo_data_menu = dados.ic_tipo_data_menu
      this.cd_tipo_email = dados.cd_tipo_email
      this.cd_detalhe = dados.cd_detalhe
      this.cd_menu_detalhe = dados.cd_menu_detalhe
      this.cd_api_detalhe = dados.cd_api_detalhe

      //this.cd_relatorio       = dados.cd_relatorio;

      if (this.ic_tipo_data_menu == '1') {
        this.hoje = ' - ' + new Date().toLocaleDateString()
      }
      if (this.ic_tipo_data_menu == '2' || this.ic_tipo_data_menu == '3') {
        this.hora = new Date().toLocaleTimeString().substring(0, 5)
      }

      if (dados.ic_exportacao == 'S') {
        this.exportar = true
      }

      localStorage.cd_tipo_consulta = 0

      if (!dados.cd_tipo_consulta == 0) {
        localStorage.cd_tipo_consulta = dados.cd_tipo_consulta
      }

      this.tituloMenu = dados.nm_menu_titulo //await Menu.montarMenu(cd_empresa, cd_menu); //'titulo';
      this.menu = dados.nm_menu

      filename = this.tituloMenu + '.xlsx'
      filenametxt = this.tituloMenu + '.txt'
      filenamedoc = this.tituloMenu + '.docx'
      filenamexml = this.tituloMenu + '.xml'

      //dados da coluna
      this.columns = JSON.parse(JSON.parse(JSON.stringify(dados.coluna)))
      this.columns.map((e) => {
        if (e.dataField == 'qt_digitacao') {
          e.allowEditing = true
        } else {
          e.allowEditing = false
        }
      })

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(dados.coluna_total)))
      //

      //TabSheet
      this.tabs = []
      //

      if (!this.qt_tabsheet == 0) {
        this.tabs = JSON.parse(JSON.parse(JSON.stringify(dados.TabSheet)))
        this.cd_menu_destino = parseInt(this.cd_menu)
        this.cd_api_destino = parseInt(this.cd_api)
      }
      //Filtros

      this.filtro = []

      if (this.ic_filtro_pesquisa == 'S') {
        this.filtro = await JSON.parse(JSON.parse(JSON.stringify(dados.Filtro)))

        if (!!this.filtro[0].cd_tabela == false) {
          this.dados_lookup = await Lookup.montarSelect(this.cd_empresa, dados.cd_tabela)
        } else {
          this.dados_lookup = await Lookup.montarSelect(this.cd_empresa, this.filtro[0].cd_tabela)
        }
        if (!!this.dados_lookup != false) {
          this.dataset_lookup = JSON.parse(JSON.parse(JSON.stringify(this.dados_lookup.dataset)))
          this.value_lookup = this.filtro[0].nm_campo_chave_lookup
          this.label_lookup = this.filtro[0].nm_campo
          this.placeholder_lookup = this.filtro[0].nm_campo_descricao_lookup
        }
      }

      //trocar para dados.laberFormFiltro
      //
    },

    pollData: function () {
      if (this.qt_tempo > 0) {
        this.polling = setInterval(() => {
          this.carregaDados()
        }, this.qt_tempo)
      }
    },

    Select: function (e) {
      switch (e) {
        case 1: // Grupo
          this.produto.cd_grupo_produto = this.grupo.cd_grupo_produto
          this.produto.nm_grupo_produto = this.grupo.nm_grupo_produto
          break
        case 2: //Unid Medida
          this.produto.cd_unidade_medida = this.unidade_medida.cd_unidade_medida
          this.produto.nm_unidade_medida = this.unidade_medida.nm_unidade_medida
          break
        case 3: //Status
          this.produto.cd_status_produto = this.status.cd_status_produto
          this.produto.nm_status_produto = this.status.nm_status_produto
          break
        case 4: //Categoria
          this.produto.cd_categoria_produto = this.categoria.cd_categoria_produto
          this.produto.nm_categoria_produto = this.categoria.nm_categoria_produto
          break
        case 5: //Marca
          this.produto.cd_marca_produto = this.marca.cd_marca_produto
          this.produto.nm_marca_produto = this.marca.nm_marca_produto
          break
        case 6: //Classificacao Fiscal Saida
          this.produto.cd_classificacao_fiscal_saida =
            this.classificacao_fiscal_saida.cd_classificacao_fiscal
          this.produto.nm_classificacao_fiscal_saida =
            this.classificacao_fiscal_saida.nm_classificacao_fiscal
          break
        case 7: //Procedencia Saida
          this.produto.cd_procedencia_produto_saida = this.procedencia_saida.cd_procedencia_produto
          this.produto.nm_procedencia_produto_saida = this.procedencia_saida.nm_procedencia_produto
          break
        case 8: //Tipo Produto Saida
          this.produto.cd_tipo_produto_saida = this.tipo_produto_saida.cd_tipo_produto
          this.produto.nm_tipo_produto_saida = this.tipo_produto_saida.nm_tipo_produto
          break
        case 9: //Tributacao Saida
          this.produto.cd_tributacao_saida = this.tributacao_saida.cd_tributacao
          this.produto.nm_tributacao_saida = this.tributacao_saida.nm_tributacao
          break
        case 10: //Dispositivo Legal ICMS Saida
          this.produto.cd_dispositivo_legal_icms_saida =
            this.dispositivo_legal_icms_saida.cd_dispositivo_legal
          this.produto.nm_dispositivo_legal_icms_saida =
            this.dispositivo_legal_icms_saida.nm_dispositivo_legal
          break
        case 11: //Dispositivo Legal IPI Saida
          this.produto.cd_dispositivo_legal_ipi_saida =
            this.dispositivo_legal_ipi_saida.cd_dispositivo_legal
          this.produto.cd_dispositivo_legal_ipi_saida =
            this.dispositivo_legal_ipi_saida.cd_dispositivo_legal
          break
        case 12: //Destinacao Produto Saida
          this.produto.cd_destinacao_produto_saida =
            this.destinacao_produto_saida.cd_destinacao_produto
          this.produto.nm_destinacao_produto_saida =
            this.destinacao_produto_saida.nm_destinacao_produto
          break
        case 13: //Tributacao Cupom Fiscal
          this.produto.cd_tributacao_cupom_fiscal = this.tributacao_cupom_fiscal.cd_tributacao
          this.produto.nm_tributacao_cupom_fiscal = this.tributacao_cupom_fiscal.nm_tributacao
          break
        case 14: //Sped Fiscal
          this.produto.cd_tipo_item_saida = this.sped_fiscal.cd_tipo_item
          this.produto.nm_tipo_item_saida = this.sped_fiscal.nm_tipo_item
          break
        case 15: //Classificacao Fiscal Entrada
          this.produto.cd_classificacao_fiscal_entrada =
            this.classificacao_fiscal_entrada.cd_classificacao_fiscal
          this.produto.nm_classificacao_fiscal_entrada =
            this.classificacao_fiscal_entrada.nm_classificacao_fiscal
          break
        case 16: //Procedencia Entrada
          this.produto.cd_procedencia_produto_entrada =
            this.procedencia_entrada.cd_procedencia_produto
          this.produto.nm_procedencia_produto_entrada =
            this.procedencia_entrada.nm_procedencia_produto
          break
        case 17: //Tipo Produto Entrada
          this.produto.cd_tipo_produto_entrada = this.tipo_produto_entrada.cd_tipo_produto
          this.produto.nm_tipo_produto_entrada = this.tipo_produto_entrada.nm_tipo_produto
          break
        case 18: //Tributacao Entrada
          this.produto.cd_tributacao_entrada = this.tributacao_entrada.cd_tributacao
          this.produto.nm_tributacao_entrada = this.tributacao_entrada.nm_tributacao
          break
        case 19: //Dispositivo Legal ICMS Entrada
          this.produto.cd_dispositivo_legal_icms_entrada =
            this.dispositivo_legal_icms_entrada.cd_dispositivo_legal
          this.produto.nm_dispositivo_legal_icms_entrada =
            this.dispositivo_legal_icms_entrada.nm_dispositivo_legal
          break
        case 20: //Dispositivo Legal IPI Entrada
          this.produto.cd_dispositivo_legal_ipi_entrada =
            this.dispositivo_legal_ipi_entrada.cd_dispositivo_legal
          this.produto.nm_dispositivo_legal_ipi_entrada =
            this.dispositivo_legal_ipi_entrada.nm_dispositivo_legal
          break
        case 21: //Destinacao Produto Entrada
          this.produto.cd_destinacao_produto_entrada =
            this.destinacao_produto_entrada.cd_destinacao_produto
          this.produto.nm_destinacao_produto_entrada =
            this.destinacao_produto_entrada.nm_destinacao_produto
          break
        case 22: //Sped Fiscal Entrada
          this.produto.cd_tipo_item_entrada = this.sped_fiscal_entrada.cd_tipo_item
          this.produto.nm_tipo_item_entrada = this.sped_fiscal_entrada.nm_tipo_item
          break
        case 23: //Plano Conta Saida
          this.produto.cd_conta_saida = this.conta_saida.cd_conta
          this.produto.nm_conta_saida = this.conta_saida.nm_conta
          break
        case 24: //Plano Conta Entrada
          this.produto.cd_conta_entrada = this.conta_entrada.cd_conta
          this.produto.nm_conta_entrada = this.conta_entrada.nm_conta
          break
        case 25: //Cor
          this.produto.cd_cor = this.cor.cd_cor
          this.produto.nm_cor = this.cor.nm_cor
          break
        case 26: //Familia de Produto
          this.produto.cd_familia_produto = this.familia.cd_familia_produto
          this.produto.nm_familia_produto = this.familia.nm_familia_produto
          break
      }
    },

    handleSubmit: function (e) {
      notify(
        {
          message: 'Você precisa confirmar os Dados para pesquisa !',
          position: {
            my: 'center top',
            at: 'center top',
          },
        },
        'success',
        1000
      )
      e.preventDefault()
    },

    troca: function () {
      componente.chamaCarrega()
    },

    //
    onFocusedRowChanged: async function (e) {
      this.linhaProduto = e.row && e.row.data
      var data = e.row && e.row.data
      this.produto = data
      this.ic_estoque_caixa_produto =
        !!this.produto.ic_estoque_caixa_produto == false
          ? 'N'
          : this.produto.ic_estoque_caixa_produto
      this.ic_lista_preco_caixa_produto =
        !!this.produto.ic_lista_preco_caixa_produto == false
          ? 'N'
          : this.produto.ic_lista_preco_caixa_produto
      this.grupo = {
        cd_grupo_produto: data.cd_grupo_produto,
        nm_grupo_produto: data.nm_grupo_produto,
      }
      this.unidade_medida = {
        cd_unidade_medida: data.cd_unidade_medida,
        nm_unidade_medida: data.nm_unidade_medida,
      }
      this.status = {
        cd_status_produto: data.cd_status_produto,
        nm_status_produto: data.nm_status_produto,
      }
      this.categoria = {
        cd_categoria_produto: data.cd_categoria_produto,
        nm_categoria_produto: data.nm_categoria_produto,
      }
      this.cor = {
        cd_cor: data.cd_cor,
        nm_cor: data.nm_cor,
      }
      this.familia = {
        cd_familia_produto: data.cd_familia_produto,
        nm_familia_produto: data.nm_familia_produto,
      }
      //Saída
      this.classificacao_fiscal_saida = {
        cd_classificacao_fiscal: data.cd_classificacao_fiscal_saida,
        nm_classificacao_fiscal: data.nm_classificacao_fiscal_saida,
      }
      this.procedencia_saida = {
        cd_procedencia_produto: data.cd_procedencia_produto_saida,
        nm_procedencia_produto: data.nm_procedencia_produto_saida,
      }
      this.tipo_produto_saida = {
        cd_tipo_produto: data.cd_tipo_produto_saida,
        nm_tipo_produto: data.nm_tipo_produto_saida,
      }
      this.tributacao_saida = {
        cd_tributacao: data.cd_tributacao_saida,
        nm_tributacao: data.nm_tributacao_saida,
      }
      this.dispositivo_legal_icms_saida = {
        cd_dispositivo_legal: data.cd_dispositivo_legal_icms_saida,
        nm_dispositivo_legal: data.nm_dispositivo_legal_icms_saida,
      }
      this.dispositivo_legal_ipi_saida = {
        cd_dispositivo_legal: data.cd_dispositivo_legal_ipi_saida,
        nm_dispositivo_legal: data.nm_dispositivo_legal_ipi_saida,
      }
      this.destinacao_produto_saida = {
        cd_destinacao_produto: data.cd_destinacao_produto_saida,
        nm_destinacao_produto: data.nm_destinacao_produto_saida,
      }
      this.tributacao_cupom_fiscal = {
        cd_tributacao: data.cd_tributacao_cupom_fiscal,
        nm_tributacao: data.nm_tributacao_cupom_fiscal,
      }
      this.sped_fiscal = {
        cd_tipo_item: data.cd_tipo_item_saida,
        nm_tipo_item: data.nm_tipo_item_saida,
      }
      this.conta_saida = {
        cd_conta: data.cd_conta_saida,
        nm_conta: data.nm_conta_saida,
      }
      this.ic_substrib_produto_saida = data.ic_substrib_produto_saida
      this.ic_isento_icms_produto_saida = data.ic_isento_icms_produto_saida
      //Entrada
      this.ic_substrib_produto_entrada = data.ic_substrib_produto_entrada
      this.ic_isento_icms_produto_entrada = data.ic_substrib_produto_entrada

      this.classificacao_fiscal_entrada = {
        cd_classificacao_fiscal: data.cd_classificacao_fiscal_entrada,
        nm_classificacao_fiscal: data.nm_classificacao_fiscal_entrada,
      }
      this.procedencia_entrada = {
        cd_procedencia_produto: data.cd_procedencia_produto_entrada,
        nm_procedencia_produto: data.nm_procedencia_produto_entrada,
      }
      this.tipo_produto_entrada = {
        cd_tipo_produto: data.cd_tipo_produto_entrada,
        nm_tipo_produto: data.nm_tipo_produto_entrada,
      }
      this.tributacao_entrada = {
        cd_tributacao: data.cd_tributacao_entrada,
        nm_tributacao: data.nm_tributacao_entrada,
      }
      this.dispositivo_legal_icms_entrada = {
        cd_dispositivo_legal: data.cd_dispositivo_legal_icms_entrada,
        nm_dispositivo_legal: data.nm_dispositivo_legal_icms_entrada,
      }
      this.dispositivo_legal_ipi_entrada = {
        cd_dispositivo_legal: data.cd_dispositivo_legal_ipi_entrada,
        nm_dispositivo_legal: data.nm_dispositivo_legal_ipi_entrada,
      }
      this.destinacao_produto_entrada = {
        cd_destinacao_produto: data.cd_destinacao_produto_entrada,
        nm_destinacao_produto: data.nm_destinacao_produto_entrada,
      }
      this.sped_fiscal_entrada = {
        cd_tipo_item: data.cd_tipo_item_entrada,
        nm_tipo_item: data.nm_tipo_item_entrada,
      }
      this.conta_entrada = {
        cd_conta: data.cd_conta_entrada,
        nm_conta: data.nm_conta_entrada,
      }
      // this.taskSubject = data && data.ds_informativo;
      this.taskDetails = data && data.ds_informativo
      this.ds_arquivo = data && data.ds_arquivo
      this.nm_documento = data && data.nm_documento

      if (!data.ds_informativo == '') {
        this.temD = true
      }
    },

    RowChangedFornecedor: async function (e) {
      var data = e.row && e.row.data
      this.fornecedor = data
    },

    FornecedorRemovido: async function (e) {
      let JSON_Remove_Fornecedor = {
        cd_parametro: 7,
        cd_produto: this.produto.cd_produto,
        cd_fornecedor: e.data.cd_fornecedor,
        cd_fornecedor_produto: e.data.cd_fornecedor_produto,
      }
      let resultado_remove_fornecedor = await Incluir.incluirRegistro(
        this.api,
        JSON_Remove_Fornecedor
      )
      notify(resultado_remove_fornecedor[0].Msg)
      await this.carregaFornecedor()
    },

    async carregaFornecedor() {
      let dados_fornecedor = await Menu.montarMenu(this.cd_empresa, 7505, this.cd_api)
      //dados da coluna
      this.columnsFornecedorProduto = JSON.parse(
        JSON.parse(JSON.stringify(dados_fornecedor.coluna))
      )

      //dados do total
      this.totalFornecedorProduto = JSON.parse(
        JSON.parse(JSON.stringify(dados_fornecedor.coluna_total))
      )
      try {
        let JSON_DataSource = {
          cd_parametro: 6,
          cd_produto: this.produto.cd_produto,
        }
        this.dataSourceFornecedorProduto = await Incluir.incluirRegistro(this.api, JSON_DataSource)
      } catch (error) {
        // eslint-disable-next-line no-console
        console.log(error)
      }
    },

    async carregaDados() {
      localStorage.cd_identificacao = 0
      await this.showMenu()

      this.temPanel = true

      notify('Aguarde... estamos montando a consulta para você, aguarde !')
      if (!this.qt_tabsheet == 0) {
        await this.carregaFornecedor()

        this.qt_registro = this.dataSourceConfig.length
        this.formData = this.dataSourceConfig[0]
        this.items = JSON.parse(dados.labelForm)
      }

      try {
        var TemDocumento = this.dataSourceConfig[0].nm_documento_pdf
        if (TemDocumento != undefined) {
          this.arquivo_abrir = true
        } else {
          this.arquivo_abrir = false
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(error)
      }
    },

    async onClick() {
      this.dataSourceConfig = []
      if (this.selecionada_lookup != null) {
        localStorage.cd_filtro = this.selecionada_lookup[this.filtro[0].nm_campo_chave_lookup]
        await this.carregaDados()
      } else {
        localStorage.cd_filtro = 0
        await this.carregaDados()
      }
    },

    onClickExportar() {
      //   this.ic_filtro_pesquisa = 'N';

      //this.ds_arquivo = '';
      const data = this.ds_arquivo

      if (this.ds_arquivo == null) {
        notify('Arquivo não encontrado ou sem informações!')
        //this.ds_arquivo = 'Arquivo Texto sem informações !'
        //const data = this.ds_arquivo;
        //const blob = new Blob([data], {type: 'text/plain'});
        //const em = document.createEvent('MouseEvents'),
        //a = document.createElement('a');
        //a.download = filenametxt;
        //a.href = window.URL.createObjectURL(blob);
        //a.dataset.downloadurl = ['text/json', a.download, a.href].join(':');
        //em.initEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
        //a.dispatchEvent(em);
      }
      //const data = JSON.stringify(this.arr);
      else if (this.ds_arquivo.includes('<NFe') == true) {
        const blob = new Blob([data], { type: 'text/plain' })
        const em = document.createEvent('MouseEvents'),
          a = document.createElement('a')
        a.download = filenamexml
        a.href = window.URL.createObjectURL(blob)
        a.dataset.downloadurl = ['text/json', a.download, a.href].join(':')
        em.initEvent(
          'click',
          true,
          false,
          window,
          0,
          0,
          0,
          0,
          0,
          false,
          false,
          false,
          false,
          0,
          null
        )
        a.dispatchEvent(em)
      } else {
        const blob = new Blob([data], { type: 'text/plain' })
        const em = document.createEvent('MouseEvents'),
          a = document.createElement('a')
        a.download = filenametxt
        a.href = window.URL.createObjectURL(blob)
        a.dataset.downloadurl = ['text/json', a.download, a.href].join(':')
        em.initEvent(
          'click',
          true,
          false,
          window,
          0,
          0,
          0,
          0,
          0,
          false,
          false,
          false,
          false,
          0,
          null
        )
        a.dispatchEvent(em)
      }
    },

    async SelectParam(e) {
      let menu_produto = await Menu.montarMenu(this.cd_empresa, 7721, 869) //pr_egisnet_selecao_produto_comprado
      let api = menu_produto.nm_identificacao_api
      let sParametroApi = menu_produto.nm_api_parametro
      //dados da coluna
      this.colunas = JSON.parse(JSON.parse(JSON.stringify(menu_produto.coluna)))

      //dados do total
      this.total = JSON.parse(JSON.parse(JSON.stringify(menu_produto.coluna_total)))
      //
      localStorage.cd_parametro = 0
      localStorage.nm_produto = this.nm_produto
      if (e === 1) {
        localStorage.cd_parametro = this.categoria_pesquisa.cd_categoria_produto
      } else if (e === 2) {
        localStorage.cd_parametro = this.grupo_pesquisa.cd_grupo_produto
      } else if (e === 3) {
        localStorage.cd_parametro = this.familia.cd_familia_produto
      } else if (e === 4) {
        localStorage.cd_parametro = this.marca_pesquisa.cd_marca_produto
      }
      localStorage.cd_tipo_consulta = e > 0 ? e : 0
      this.dataSourceConfig = await Procedimento.montarProcedimento(
        this.cd_empresa,
        localStorage.cd_cliente,
        api,
        sParametroApi
      )
    },

    customizeColumns(columns) {
      columns[0].width = 120
    },

    saveGridInstance(e) {
      this.dataGridInstance = e.component
    },

    onExporting(e) {
      const workbook = new ExcelJS.Workbook()
      const worksheet = workbook.addWorksheet('Consulta')

      exportDataGrid({
        component: e.component,
        worksheet: worksheet,
        autoFilterEnabled: true,
      }).then(function () {
        // https://github.com/exceljs/exceljs#writing-xlsx
        workbook.xlsx.writeBuffer().then(function (buffer) {
          saveAs(new Blob([buffer], { type: 'application/octet-stream' }), filename)
        })
      })
      e.cancel = true
    },

    beforeDestroy() {
      clearInterval(this.polling)
    },

    destroyed() {
      this.$destroy()
    },

    renderDoc() {
      //loadFile("http://egisnet.com.br/template/template_GBS.docx", function(
      loadFile(
        '/Template_GBS.docx',
        function (
          //loadFile("https://docxtemplater.com/tag-example.docx", function(
          error,
          content
        ) {
          if (error) {
            alert('não encontrei o template.docx')
            throw error
          }
          var zip = new PizZip(content)
          var doc = new Docxtemplater(zip)

          doc.setData(
            dados

            //{
            //  dt_hoje: '26/04/2021',
            //  nm_menu_titulo: 'tÃ­tulo do menu',
            //  nm_identificacao_api: 'endereÃ§o da api'
            //
            // }
          )

          try {
            // render the document (replace all occurences of {first_name} by John, {last_name} by Doe, ...)
            doc.render()
          } catch (error) {
            // eslint-disable-next-line no-console
            console.error(error)
          }
          var out = doc.getZip().generate({
            type: 'blob',
            mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          })
          //Output the document using Data-URI
          saveAs(out, filenamedoc)
        }
      )
    },
  },
}
</script>
<style>
@import url('./views.css');

#parametro {
  margin-top: 5px;
  padding-top: 5px;
}

form {
  margin-left: 10px;
  margin-right: 10px;
  padding-left: 10px;
  padding-right: 10px;
  margin-top: 5px;
}

.SemFornecedor {
  font-weight: bold;
  display: flex;
  flex-direction: row;
  justify-content: center;
}

.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}

.task-info {
  font-family: Segoe UI;
  min-height: 200px;
  display: flex;
  flex-wrap: nowrap;
  border: 2px solid rgba(0, 0, 0, 0.1);
  padding: 5px;
  box-sizing: border-box;
  align-items: baseline;
  justify-content: space-between;
  margin-left: 10px;
  margin-right: 10px;
}

#taskSubject {
  line-height: 29px;
  font-size: 18px;
  font-weight: bold;
}
#taskDetails {
  line-height: 22px;
  font-size: 14px;
  margin-top: 0;
  margin-bottom: 0;
  padding-left: 10px;
}

.info {
  margin-right: 40px;
}

#taskProgress {
  line-height: 42px;
  font-size: 40px;
  font-weight: bold;
}

.options {
  margin-top: 20px;
  padding: 20px;
  background-color: rgba(191, 191, 191, 0.15);
  position: relative;
}

.caption {
  font-size: 18px;
  font-weight: 500;
}

.option {
  margin-top: 10px;
  margin-right: 40px;
  display: inline-block;
}

.option:last-child {
  margin-right: 0;
}

.option > .dx-numberbox {
  width: 200px;
  display: inline-block;
  vertical-align: middle;
}

.option > span {
  margin-right: 10px;
}

#exportButton {
  margin-bottom: 10px;
}

.botao-exportar {
  margin-top: 10px;
  margin-left: 10px;
}

.botao-arquivo_abrir {
  margin-top: 10px;
  margin-left: 10px;
}

.botao-info {
  float: right;
  right: 10px;
}
.info-periodo {
  margin-top: 10px;
  float: right;
  margin-right: 25px;
  right: 10px;
  font-size: 16px;
}

.info-cor {
  color: #506ad4;
  font-size: 20px;
}
#grid-padrao {
  max-height: 600px !important;
}
.slide-fade-enter-active {
  transition: all 0.3s ease;
}
.slide-fade-leave-active {
  transition: all 0.4s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter, .slide-fade-leave-to
/* .slide-fade-leave-active below version 2.1.8 */ {
  transform: translateX(10px);
  opacity: 0;
}
</style>
