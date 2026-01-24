<!-- eslint-disable no-console -->
<template>
  <div class="margin1">
    <div class="row no-wrap items-start q-gutter-md">
      <div class="col-auto flex flex-center bg-deep-purple-1 q-pa-md" style="border-radius: 80px;">
        <q-icon name="tune" size="48px" color="deep-purple-7" />
      </div>
      <div class="col">
        <div style="display: flex; align-items: center; justify-content: center">
          <q-btn
            v-if="prop_form.nm_form"
            rounded
            color="orange-9"
            text-color="white"
            size="lg"
            :label="`${prop_form.nm_form}`"
          />
        </div>
        <div class="row justify-end">
          <q-chip
            v-if="cd_relatorioID"
            rounded
            color="deep-purple-7"
            class="q-mt-sm q-ml-sm margin-menu"
            size="16px"
            text-color="white"
            :label="`${cd_relatorioID}`"
          />
        </div>
        <div class="text-h5 text-bold margin1">
          {{ tituloForm }}
          <q-badge v-if="prop_form.cd_movimento" align="top" color="blue">
            {{ prop_form.cd_movimento }}
          </q-badge>
        </div>
      </div>
    </div>
    <!-- Mostra dataSource ou informa que não foi possível carregar -->
    <transition name="slide-fade">
      <div v-if="ic_ds_form" style="display: flex; width: 100%">
        <q-banner
          style="width: 100%"
          rounded
          class="bg-orange-3 text-blue-grey-10 margin1 text-bold"
        >
          {{ `${prop_form.ds_form}` }}
          <template v-slot:action>
            <q-btn
              style="text-transform: none"
              flat
              color="blue-grey-10"
              label="Fechar"
              @click="ic_ds_form = false"
            />
          </template>
        </q-banner>
      </div>
    </transition>
    <div v-if="dataSourceConfig">
      <q-tabs
        v-model="index"
        inline-label
        mobile-arrows
        align="justify"
        style="border-radius: 20px"
        :class="'bg-primary text-white shadow-2 margin1'"
      >
        <q-tab
          v-for="tabs in tabsheets"
          :key="tabs.cd_tabsheet"
          :name="tabs.cd_tabsheet"
          :icon="tabs.ic_icone === 'S' ? tabs.nm_icone_tabsheet : ''"
          :label="tabs.nm_tabsheet"
        />
      </q-tabs>
      <div v-if="ic_ativa_botoes">
        <q-btn
          rounded
          label="Salvar"
          type="submit"
          color="orange-9"
          icon="save"
          @click="onSalvarRegistro"
        />
        <q-btn
          rounded
          label="Limpar"
          type="reset"
          color="orange-9"
          flat
          class="q-ml-sm"
          icon="cleaning_services"
          @click="onLimparRegistro"
        />
        <q-btn
          rounded
          label="Fechar"
          type="reset"
          color="orange-9"
          flat
          class="q-ml-sm"
          icon="close"
          @click="onFechar"
        />
        <q-btn
          v-if="
            prop_form.cd_movimento &&
            dataSourceConfig[0] &&
            dataSourceConfig[0].ic_exclusao_form === 'S'
          "
          rounded
          label="Excluir"
          type="reset"
          color="red"
          class="q-ml-sm"
          icon="delete"
          @click="onExcluir"
        />
        <q-btn
          v-if="this.anexo_down"
          rounded
          label="Baixar"
          type="reset"
          color="primary"
          class="q-ml-sm"
          icon="download"
          @click="onDownloadDoc"
        />
        <q-btn
          v-if="dataSourceConfig[0] && dataSourceConfig[0].ic_relatorio_form === 'S'"
          round
          type="reset"
          color="red"
          class="q-ml-sm float-right"
          icon="picture_as_pdf"
          @click="onRelatorio"
        />
        <q-btn
          v-if="dataSourceConfig[0] && dataSourceConfig[0].ic_email === 'S'"
          round
          type="reset"
          color="orange-9"
          class="q-ml-sm float-right"
          icon="email"
          @click="onEmail"
        />
        <q-btn
          v-if="dataSourceConfig[0] && dataSourceConfig[0].ic_mensagem === 'S'"
          round
          type="reset"
          color="green"
          class="q-ml-sm float-right"
          icon="img:/whatsapp.svg"
          @click="onMensagem"
        />
      </div>
      <div class="margin1 row q-mb-md borda-bloco shadow-2" v-if="ic_info_lookup">
        <div class="margin1 text-bold">
          {{ `${lookup_formEspecial.nm_apresenta_atributo}` }}
        </div>
        <div
          class="margin1 col-2"
          v-for="(valor, chave) in lookup_formEspecial.nm_valor_inicial"
          :key="chave"
        >
          <div v-if="lookup_formEspecial.nm_campo_chave_combo_box !== chave">
            <q-input
              v-model="lookup_formEspecial.nm_valor_inicial[chave]"
              :maxlength="
                JSON.parse(lookup_formEspecial.nm_dados_info_lookup).find(
                  (item) => item.nm_atributo === chave
                ).cd_natureza_atributo === 1
                  ? undefined
                  : JSON.parse(lookup_formEspecial.nm_dados_info_lookup).find(
                      (item) => item.nm_atributo === chave
                    ).qt_tamanho_atributo
              "
              :label="
                JSON.parse(lookup_formEspecial.nm_dados_info_lookup).find(
                  (item) => item.nm_atributo === chave
                ).ds_atributo
              "
              @input="onInputLookup(valor, chave, lookup_formEspecial)"
            />
          </div>
        </div>
      </div>
      <q-tab-panels
        v-model="index"
        animated
        swipeable
        vertical
        transition-prev="jump-up"
        transition-next="jump-up"
      >
        <q-tab-panel
          class="row"
          v-for="tabs in tabsheets"
          :key="tabs.cd_tabsheet"
          :name="tabs.cd_tabsheet"
        >
          <div
            :class="item.ic_tipo_atributo == 7 ? 'col-12' : 'col-3'"
            v-for="(item, indx) in tabs.itens"
            :key="indx"
          >
            <div v-if="item.ic_habilitado_atributo == 'S'">
              <q-input
                v-if="!['0', '3', '5', '8'].find((element) => element == item.ic_tipo_atributo)"
                class="margin1"
                :readonly="['1', '4'].includes(item.ic_tipo_atributo) ? true : false"
                :filled="['1', '4'].includes(item.ic_tipo_atributo) ? true : false"
                :bg-color="['1', '4'].includes(item.ic_tipo_atributo) ? 'light-blue-2' : null"
                v-model="item.nm_valor_inicial"
                :label="item.nm_apresenta_atributo"
                :loading="item.cd_tabela_api > 0 && load_api_input"
                :stack-label="item.nm_datatype === 'date' ? true : false"
                :type="
                  item.ic_tipo_atributo == 7
                    ? 'textarea'
                    : item.ic_tipo_atributo == 'S'
                    ? 'password'
                    : item.ic_tipo_atributo == 4
                    ? 'text'
                    : item.nm_datatype
                "
                :rules="
                  item.ic_atributo_obrigatorio == 'S' && item.ic_chave_grid != 'S'
                    ? [(val) => !!val || 'Campo obrigatório']
                    : []
                "
                :auto-grow="item.ic_tipo_atributo == 7 ? true : false"
                @blur="chamaAPIAtributo(item)"
                @input="onInput(item)"
              >
                <template v-slot:prepend>
                  <q-btn
                    v-if="item.cd_form_especial > 0"
                    round
                    color="orange-9"
                    icon="add"
                    @click.stop="onInputFormEspecial(item)"
                  />
                  <q-btn
                    v-if="item.cd_tabela_pesquisa > 0 && !item.vl_padrao_atributo"
                    round
                    color="orange-9"
                    icon="search"
                    @click.stop="onInputPesquisaPadrao(item)"
                  />
                </template>
                <template v-slot:append>
                  <q-btn
                    v-if="item.cd_filtro_tabela > 0 && item.cd_menu_tabsheet_atributo > 0"
                    dense
                    rounded
                    color="deep-purple-7"
                    :class="['q-mt-sm', 'q-ml-sm']"
                    icon="filter_alt"
                    @click.stop="abrirFiltroSelecao(item)"
                /></template>
              </q-input>
              <q-select
                v-else-if="
                  (item.nm_lookup !== '' &&
                    item.nm_campo_chave_combo_box !== '' &&
                    item.ic_tipo_atributo == '3') ||
                  item.ic_tipo_atributo == '0'
                "
                use-input
                hide-selected
                fill-input
                map-options
                @keydown="onKeydownSelect($event, item)"
                @filter="filterFn"
                @focus="onFocus(JSON.parse(item.nm_lookup), item)"
                @input="onInputSelect(item)"
                @blur="onBlurSelect()"
                class="margin1"
                v-model="item.nm_valor_inicial"
                :label="item.nm_apresenta_atributo"
                :stack-label="item.nm_datatype === 'date' ? true : false"
                :readonly="['1', '4'].includes(item.ic_tipo_atributo) ? true : false"
                :filled="['1', '4'].includes(item.ic_tipo_atributo) ? true : false"
                :bg-color="['1', '4'].includes(item.ic_tipo_atributo) ? 'light-blue-2' : null"
                :option-value="item.nm_campo_chave_combo_box"
                :option-label="item.nm_campo_mostra_combo_box"
                :options="arraySelect"
                :hint="hint_filtro"
              >
                <template v-slot:prepend>
                  <q-btn
                    v-if="item.cd_form_especial > 0"
                    round
                    color="orange-9"
                    icon="add"
                    @click.stop="onInputFormEspecial(item)"
                  />
                  <q-btn
                    v-if="item.cd_tabela_pesquisa > 0 && !item.vl_padrao_atributo"
                    round
                    color="orange-9"
                    icon="search"
                    @click.stop="onInputPesquisaPadrao(item)"
                  />
                </template>
                <template v-slot:append>
                  <q-btn
                    v-if="item.ic_info_lookup == 'S' && item.nm_valor_inicial"
                    round
                    color="orange-9"
                    icon="info"
                    size="sm"
                    @click.stop="onInfoLookup(item)"
                    ><q-tooltip class="bg-orange text-white">Informações</q-tooltip></q-btn
                  >
                  <q-btn
                    v-if="item.cd_filtro_tabela > 0 && item.cd_menu_tabsheet_atributo > 0"
                    dense
                    rounded
                    color="deep-purple-7"
                    :class="['q-mt-sm', 'q-ml-sm']"
                    icon="filter_alt"
                    @click.stop="abrirFiltroSelecao(item, arraySelect)"
                  />
                </template>
              </q-select>
              <q-file
                v-if="item.ic_tipo_atributo == '5'"
                class="margin1"
                v-model="item.nm_valor_inicial"
                :label="item.nm_apresenta_atributo"
                @input="anexo_down = item.nm_valor_inicial"
              >
                <template v-slot:prepend>
                  <q-icon name="attach_file" />
                </template>
                <template v-if="item.nm_valor_inicial" v-slot:append>
                  <q-icon
                    name="close"
                    @click.stop.prevent=";(item.nm_valor_inicial = null), (anexo_down = null)"
                    class="cursor-pointer"
                  />
                  <q-btn
                    v-if="item.cd_filtro_tabela > 0 && item.cd_menu_tabsheet_atributo > 0"
                    dense
                    rounded
                    color="deep-purple-7"
                    :class="['q-mt-sm', 'q-ml-sm']"
                    icon="filter_alt"
                    @click.stop="abrirFiltroSelecao(item)"
                  />
                </template>
              </q-file>
              <div v-if="item.ic_tipo_atributo == '8'" class="margin1">
                <q-toggle
                  class="margin1"
                  v-model="item.nm_valor_inicial"
                  :label="item.nm_apresenta_atributo"
                  false-value="N"
                  true-value="S"
                  color="orange-9"
                />
                <q-btn
                  v-if="item.cd_filtro_tabela > 0 && item.cd_menu_tabsheet_atributo > 0"
                  dense
                  rounded
                  color="deep-purple-7"
                  :class="['q-mt-sm', 'q-ml-sm']"
                  icon="filter_alt"
                  @click="abrirFiltroSelecao(item)"
                />
              </div>
            </div>
            <filtroComponente
              v-model="dialogFiltroSelecao"
              :cd-menu="Number(item.cd_menu_tabsheet_atributo || cd_menu || 0)"
              :cd-tabela="Number(item.cd_filtro_tabela || 0)"
              :cd-usuario="Number(cd_usuario || 0)"
              :cd_parametro_relatorio="cd_relatorioID"
              @aplicou="onAplicouFiltroSelecao"
            />
          </div>
        </q-tab-panel>
      </q-tab-panels>
      <div>
        <svg id="barcode"></svg>
      </div>
      <div v-if="ic_ativa_botoes">
        <q-btn
          rounded
          label="Salvar"
          type="submit"
          color="orange-9"
          icon="save"
          @click="onSalvarRegistro"
        />
        <q-btn
          rounded
          label="Limpar"
          type="reset"
          color="orange-9"
          flat
          class="q-ml-sm"
          icon="cleaning_services"
          @click="onLimparRegistro"
        />
        <q-btn
          rounded
          label="Fechar"
          type="reset"
          color="orange-9"
          flat
          class="q-ml-sm"
          icon="close"
          @click="onFechar"
        />
        <q-btn
          v-if="
            prop_form.cd_movimento &&
            dataSourceConfig[0] &&
            dataSourceConfig[0].ic_exclusao_form === 'S'
          "
          rounded
          label="Excluir"
          type="reset"
          color="red"
          class="q-ml-sm"
          icon="delete"
          @click="onExcluir"
        />
        <q-btn
          v-if="this.anexo_down"
          rounded
          label="Baixar"
          type="reset"
          color="primary"
          class="q-ml-sm"
          icon="download"
          @click="onDownloadDoc"
        />
        <q-btn
          v-if="dataSourceConfig[0] && dataSourceConfig[0].ic_relatorio_form === 'S'"
          round
          type="reset"
          color="red"
          class="q-ml-sm float-right"
          icon="picture_as_pdf"
          @click="onRelatorio"
        />
        <q-btn
          v-if="dataSourceConfig[0] && dataSourceConfig[0].ic_email === 'S'"
          round
          type="reset"
          color="orange-9"
          class="q-ml-sm float-right"
          icon="email"
          @click="onEmail"
        />
        <q-btn
          v-if="dataSourceConfig[0] && dataSourceConfig[0].ic_mensagem === 'S'"
          round
          type="reset"
          color="green"
          class="q-ml-sm float-right"
          icon="img:/whatsapp.svg"
          @click="onMensagem"
        />
      </div>
      <div v-if="dataSourceConfig[0] && dataSourceConfig[0].ic_grid_form === 'S'" class="margin1">
        <div class="row" v-if="dataSourceGrid">
          <div class="col-3" v-for="(item, indx) in dataSourceGrid" :key="indx">
            <div v-if="item.ic_habilitado_atributo == 'S'">
              <q-input
                v-if="!['3', '5', '8'].find((element) => element == item.ic_tipo_atributo)"
                class="margin1"
                :readonly="['1', '4'].includes(item.ic_tipo_atributo) ? true : false"
                :filled="['1', '4'].includes(item.ic_tipo_atributo) ? true : false"
                :bg-color="['1', '4'].includes(item.ic_tipo_atributo) ? 'light-blue-2' : null"
                v-model="item.nm_valor_inicial"
                :label="item.nm_apresenta_atributo"
                :stack-label="item.nm_datatype === 'date' ? true : false"
                :type="
                  item.ic_tipo_atributo == 7
                    ? 'textarea'
                    : item.ic_tipo_atributo == 'S'
                    ? isPwd
                      ? 'password'
                      : 'text'
                    : item.nm_datatype
                "
                :auto-grow="item.ic_tipo_atributo == 7 ? true : false"
                @blur="chamaAPIAtributo(item)"
                @input="InputAtributo(item)"
              >
                <template v-if="item.ic_tipo_atributo == 'S'" v-slot:append>
                  <q-btn
                    round
                    flat
                    color="black"
                    @click="isPwd = !isPwd"
                    :icon="isPwd ? 'visibility_off' : 'visibility'"
                  />
                </template>
                <template v-slot:prepend>
                  <q-btn
                    v-if="item.cd_form_especial > 0"
                    round
                    color="orange-9"
                    icon="add"
                    @click.stop="onInputFormEspecial(item, 'grid')"
                  />
                  <q-btn
                    v-if="item.cd_tabela_pesquisa > 0 && !item.vl_padrao_atributo"
                    round
                    color="orange-9"
                    icon="search"
                    @click.stop="onInputPesquisaPadrao(item, 'grid')"
                  />
                </template>
              </q-input>
              <!-- aqui -->
              <q-select
                v-else-if="
                  (item.nm_lookup !== '' &&
                    item.nm_campo_chave_combo_box !== '' &&
                    item.ic_tipo_atributo == '3') ||
                  item.ic_tipo_atributo == '0'
                "
                class="margin1"
                v-model="item.nm_valor_inicial"
                :label="item.nm_apresenta_atributo"
                :stack-label="item.nm_datatype === 'date' ? true : false"
                :readonly="['1', '4'].includes(item.ic_tipo_atributo) ? true : false"
                :filled="['1', '4'].includes(item.ic_tipo_atributo) ? true : false"
                :bg-color="['1', '4'].includes(item.ic_tipo_atributo) ? 'light-blue-2' : null"
                :type="item.nm_datatype"
                :option-value="item.nm_campo_chave_combo_box"
                :option-label="item.nm_campo_mostra_combo_box"
                :options="JSON.parse(item.nm_lookup)"
                @blur="chamaAPIAtributo(item)"
                @input="InputAtributo(item)"
              >
                <template v-slot:prepend>
                  <q-btn
                    v-if="item.cd_form_especial > 0"
                    round
                    color="orange-9"
                    icon="add"
                    @click.stop="onInputFormEspecial(item, 'grid')"
                  />
                  <q-btn
                    v-if="item.cd_tabela_pesquisa > 0 && !item.vl_padrao_atributo"
                    round
                    color="orange-9"
                    icon="search"
                    @click.stop="onInputPesquisaPadrao(item, 'grid')"
                  />
                </template>
              </q-select>
              <q-file
                v-if="item.ic_tipo_atributo == '5'"
                class="margin1"
                v-model="item.nm_valor_inicial"
                :label="item.nm_apresenta_atributo"
                @input="anexo_down = item.nm_valor_inicial"
              >
                <template v-slot:prepend> <q-icon name="attach_file" /> </template
              ></q-file>
              <div v-if="item.ic_tipo_atributo == '8'" class="margin1">
                <q-toggle
                  class="margin1"
                  v-model="item.nm_valor_inicial"
                  :label="item.nm_apresenta_atributo"
                  false-value="N"
                  true-value="S"
                  color="orange-9"
                  @input="InputAtributo(item)"
                />
              </div>
            </div>
          </div>
        </div>
        <div v-if="dataSourceGrid && jsonObjGrid.cd_documento > 0" class="margin1">
          <q-btn
            class="margin1"
            rounded
            label="Novo Item"
            type="submit"
            color="primary"
            icon="add"
            @click="onNovoRegistro"
          />
          <q-btn
            class="margin1"
            rounded
            label="Salvar Item"
            type="submit"
            color="primary"
            icon="save"
            :loading="reload_grid"
            @click="onSalvarItemGrid"
          />
          <q-btn
            class="margin1"
            rounded
            label="Excluir Item"
            type="submit"
            color="red"
            icon="delete"
            :loading="reload_grid"
            @click="onExcluirItemGrid"
          />
        </div>
        <grid
          v-if="!reload_grid && jsonObjGrid.cd_documento > 0"
          class="margin1"
          :cd_menuID="
            prop_form.cd_menu || dataSourceConfig[0].cd_menu_grid || dataSourceConfig[0].cd_menu
          "
          :cd_apiID="936"
          :cd_identificacaoID="0"
          :cd_parametroID="prop_form.cd_etapa"
          :cd_tipo_consultaID="prop_form.cd_menu || dataSourceConfig[0].cd_menu_grid"
          :cd_usuarioID="0"
          :cd_consulta="0"
          :nm_json="jsonObjGrid"
          @linha="linhaSelecionada($event)"
          @emit-click="DoubleClickLine($event)"
          ref="grid_c"
        >
        </grid>
      </div>
    </div>
    <div v-else>
      <h6>Não foi possível carregar os campos!</h6>
    </div>
    <!--------CARREGANDO---------------------------------------------------------------------------->
    <q-dialog v-model="load" maximized persistent>
      <carregando mensagemID="carregando..."></carregando>
    </q-dialog>
    <!------------------------------------------------------------------------------------>
    <!--------Sem plano FTP---------------------------------------------------------------------------->
    <q-dialog v-model="load_ftp" transition-show="flip-down" transition-hide="flip-up">
      <q-card>
        <q-card-section>
          <div class="text-h6"><q-icon name="warning" />Plano não contratado!</div>
        </q-card-section>
        <q-space />
        <q-card-section class="q-pt-none">
          {{ `Atenção, Plano de Armazenamento de Arquivos não Contratado!.` }}
        </q-card-section>
        <q-card-section> {{ `Faça seu Plano!` }}</q-card-section>
        <q-card-section>
          {{
            `Para maiores informações entre em contato com o nosso setor de comercial.`
          }}</q-card-section
        >

        <q-card-actions align="right">
          <q-btn rounded label="OK" color="primary" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------------------------>
    <!-- Chamando Form Especial no Atributo -->
    <q-dialog
      v-model="pop_atributo"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-9 text-white">
          {{ `${prop_form.nm_form} - ${atributo_formEspecial.nm_apresenta_atributo}` }}
          <q-space />
          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white">Minimizar</q-tooltip>
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white">Maximizar</q-tooltip>
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section class="q-pt-none">
          <auto-form
            v-if="this.atributo_formEspecial.cd_form_especial"
            :cd_formID="this.atributo_formEspecial.cd_form_especial"
            :cd_apiID="parseInt(this.atributo_formEspecial.cd_api)"
            :cd_menuID="parseInt(this.atributo_formEspecial.cd_menu)"
            :cd_documentoID="this.atributo_formEspecial.cd_documento"
            @click="fechaPopup($event)"
          />
          <grid-formulario
            v-else
            ref="grid_form_atributo"
            id="grid_form_atributo"
            :cd_menuID="parseInt(this.atributo_formEspecial.cd_menu)"
          />
        </q-card-section>
      </q-card>
    </q-dialog>
    <!-- Popup Pesquisa Padrão -->
    <q-dialog
      v-model="pop_pesquisa"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-9 text-white">
          {{ `Pesquisa - ${prop_form.nm_form} - ${atributo_formEspecial.nm_apresenta_atributo}` }}
          <q-space />
          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white">Minimizar</q-tooltip>
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white">Maximizar</q-tooltip>
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section class="q-pt-none">
          <pesquisa-padrao
            :dataSourcePesquisa="atributo_formEspecial"
            @dadosSelecionados="linhaPesquisada($event)"
          />
        </q-card-section>
      </q-card>
    </q-dialog>
    <!-- Chamando Grid Formulário no Item da Grid -->
    <!-- <q-dialog
      v-model="pop_grid_item"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-9 text-white">
          {{
            `${prop_form.nm_form}`
          }}
          <q-space />
          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange text-white"
              >Minimizar</q-tooltip
            >
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-orange text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>
        <q-card-section class="q-pt-none">
          <grid-formulario
            ref="grid_form_item_grid"
            id="grid_form_item_grid"
            v-if="this.dataSourceGrid[0].cd_menu"
            :cd_menuID="parseInt(this.dataSourceGrid[0].cd_menu)"
          />
        </q-card-section>
      </q-card>
    </q-dialog> -->
    <!------------------------------------------------------------------------------------>
  </div>
</template>

<script>
import 'devextreme-vue/text-area'
import ptMessages from 'devextreme/localization/messages/pt.json'
import { locale, loadMessages } from 'devextreme/localization'
import config from 'devextreme/core/config'
import Incluir from '../http/incluir_registro'
import notify from 'devextreme/ui/notify'
import formataData from '../http/formataData'
import Procedimento from '../http/procedimento'
import carregando from '../components/carregando.vue'
import Menu from '../http/menu'
import grid from '../views/grid'
import select from '../http/select'
import axios from 'axios'
import JsBarcode from 'jsbarcode'

export default {
  props: {
    cd_formID: { type: Number, default: 0 },
    cd_documentoID: { type: Number, default: 0 },
    cd_item_documentoID: { type: Number, default: 0 },
    cd_relatorioID: { type: Number, default: 0 },
    prop_form: {
      type: Object,
      default() {
        return {}
      },
    },
  },
  components: {
    carregando,
    grid,
    filtroComponente: () => import('@/components/filtroComponente.vue'),
    gridFormulario: () => import('./gridFormulario.vue'),
    autoForm: () => import('./autoForm'),
    PesquisaPadrao: () => import('../components/pesquisaPadrao.vue'),
  },
  name: 'cadastroFormEspecial',
  data() {
    return {
      tituloForm: '',
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_menu: localStorage.cd_menu,
      chave_novo_registro: 0,
      dialogFiltroSelecao: false,
      dados: [],
      dados_menu: [],
      dados_form: {},
      relatorio: {},
      dataSourceConfig: [],
      tabsheets: [],
      grid_itens_edit: [],
      filtro_selecionado: null,
      array_filtro_selecionado: null,
      hint_filtro: null,
      ic_info_lookup: false,
      ic_ativa_botoes: true,
      pop_atributo: false,
      pop_pesquisa: false,
      pop_grid_item: false,
      maximizedToggle: true,
      isPwd: true,
      atributo_formEspecial: {},
      lookup_formEspecial: {},
      jsonObjGrid: {},
      dataSourceGrid: [],
      obj_item: {},
      ic_ds_form: false,
      anexo_down: '',
      index: 0,
      reload_grid: false,
      load: false,
      load_ftp: false,
      load_api_input: false,
      arraySelectOriginal: [],
      arraySelect: [],
      itemSelect: {},
    }
  },

  async created() {
    config({ defaultCurrency: 'BRL' })
    loadMessages(ptMessages)
    locale(navigator.language)
  },

  async mounted() {
    try {
      this.load = true
      await this.carregaDados()
      this.load = false
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(error)
    } finally {
      this.load = false
    }
  },

  methods: {
    formatDate(value) {
      if (!value) return null

      // Se já estiver no formato ISO, retorna direto
      if (/^\d{4}-\d{2}-\d{2}$/.test(value)) return value

      // Se estiver no formato brasileiro, converte
      const parts = value.split('/')
      if (parts.length === 3) {
        const [day, month, year] = parts
        return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`
      }

      // Se for Date object, converte para ISO
      if (value instanceof Date) {
        return value.toISOString().split('T')[0]
      }

      return value // fallback
    },

    async carregaDados() {
      if (!this.prop_form.cd_movimento) {
        var dados = await Menu.montarMenu(
          localStorage.cd_empresa,
          localStorage.cd_menu,
          localStorage.cd_api
        )
        this.cd_formID = this.cd_formID === 0 ? dados.cd_form : this.cd_formID
      }
      localStorage.cd_api = 585
      localStorage.api = '585/811'
      ///////////////////////////////////////////////////////
      localStorage.cd_parametro = this.cd_formID
      localStorage.cd_documento = this.prop_form.cd_documento || this.cd_documentoID
      localStorage.cd_item_documento = this.prop_form.cd_item_documento
      let carregaDataSouce = {
        cd_empresa: localStorage.cd_empresa,
        cd_parametro: this.cd_formID,
        cd_documento: this.prop_form.cd_documento || this.cd_documentoID,
        cd_item_documento: this.prop_form.cd_item_documento,
        cd_relatorio: this.cd_relatorioID,
        cd_cliente: this.prop_form.nm_campo2,
        cd_usuario: localStorage.cd_usuario,
      }
      this.dataSourceConfig = await Incluir.incluirRegistro(
        localStorage.api,
        carregaDataSouce,
        'admin'
      ) //pr_formulario_atributo (ADMIN)
      this.tituloForm = this.dataSourceConfig[0].nm_titulo_form
      this.prop_form.nm_form = this.dataSourceConfig[0].nm_form
      this.prop_form.ds_form = this.dataSourceConfig[0].ds_form
      if (
        this.prop_form.ds_form &&
        this.prop_form.ds_form.trim() != '' &&
        this.dataSourceConfig[0].ic_alerta_form == 'S'
      ) {
        this.ic_ds_form = true
      }
      ///////////////////////////////////////////////////////
      const tabsheetsItems = this.dataSourceConfig.reduce((acc, item) => {
        if (!acc[item.cd_tabsheet]) {
          acc[item.cd_tabsheet] = []
        }
        acc[item.cd_tabsheet].nm_tabsheet = item.nm_tabsheet
        acc[item.cd_tabsheet].ic_icone = item.ic_icone
        acc[item.cd_tabsheet].nm_icone_tabsheet = item.nm_icone_tabsheet
        acc[item.cd_tabsheet].push(item)
        return acc
      }, {})
      this.tabsheets = Object.entries(tabsheetsItems).map(([cd_tabsheet, itens]) => {
        return {
          cd_tabsheet,
          itens,
          nm_tabsheet: itens.nm_tabsheet,
          ic_icone: itens.ic_icone,
          nm_icone_tabsheet: itens.nm_icone_tabsheet,
        }
      })
      this.index = this.tabsheets[0].cd_tabsheet
      this.tabsheets.map((item) => {
        this.ic_ativa_botoes = item.itens.some((it) => {
          if (it.ic_habilitado_atributo === 'S') {
            return true
          } else {
            return false
          }
        })
      })
      ///////Atualiza os valores iniciais (GET)////////////////////////////////////////////////
      this.dataSourceConfig.map((item) => {
        if (!item.nm_valor_inicial && !item.cd_tabela_pesquisa) {
          item.nm_valor_inicial = item.vl_padrao_atributo
        }
        if (item.nm_lookup && item.nm_valor_inicial && item.ic_tipo_atributo != 8) {
          if (item.ic_tipo_atributo == 4 && typeof item.nm_valor_inicial == 'object') {
            const [first] = JSON.parse(item.nm_lookup).filter((lkp) => {
              return lkp[item.nm_campo_chave_combo_box] == item.nm_valor_inicial
            })
            item.nm_valor_inicial = first[item.nm_campo_mostra_combo_box]
          } else if (item.ic_tipo_atributo == 4 && typeof item.nm_valor_inicial == 'string') {
            // eslint-disable-next-line no-self-assign
            item.nm_valor_inicial = item.nm_valor_inicial
          } else {
            ;[item.nm_valor_inicial] = JSON.parse(item.nm_lookup).filter((lkp) => {
              return lkp[item.nm_campo_chave_combo_box] == item.nm_valor_inicial
            })
            this.onAtributoDependente(item)
          }
        } else if (item.nm_datatype === 'date') {
          item.nm_valor_inicial = item.nm_valor_inicial.substring(0, 10)
        } else if (item.ic_tipo_atributo == '5') {
          //Arquivos (File)
          this.anexo_down = item.nm_valor_inicial
          item.nm_valor_inicial = new File([], item.nm_valor_inicial || '')
        }
      })
      //Se tiver grid com itens
      if (this.dataSourceConfig[0].ic_grid_form === 'S') {
        this.reload_grid = true
        try {
          let processos_json = {
            cd_empresa: '0',
            cd_tabela: 5742,
            order: 'D',
            where: [{ cd_form: this.dataSourceConfig[0].cd_form }],
          }
          var [grid_itens_edit] = await select.montarSelect(
            '0', //this.cd_empresa,
            processos_json
          )
          if (!grid_itens_edit.dataset) {
            throw new Error('Nenhum item na Grid Edit')
          }
          this.grid_itens_edit = JSON.parse(grid_itens_edit.dataset)
          await this.carregaGrid()
        } catch (error) {
          // eslint-disable-next-line no-console
          console.error(error, 'Erro na Grid')
        } finally {
          this.reload_grid = false
          this.jsonObjGrid = {
            cd_form: this.dataSourceGrid[0].cd_form || this.grid_itens_edit[0].cd_form_grid,
            cd_documento: this.prop_form.cd_documento,
            cd_usuario: this.cd_usuario || localStorage.cd_usuario,
          }
        }
      }
    },

    async carregaGrid() {
      try {
        let carregaEditGrid = {
          cd_empresa: localStorage.cd_empresa,
          cd_parametro: this.grid_itens_edit[0].cd_form_grid,
          cd_documento: this.prop_form.cd_documento,
          cd_item_documento: this.prop_form.cd_item_documento,
          cd_cliente: this.prop_form.nm_campo2,
        }
        this.dataSourceGrid = await Incluir.incluirRegistro(
          localStorage.api,
          carregaEditGrid,
          'admin'
        ) //pr_formulario_atributo (ADMIN)
        if (!this.dataSourceGrid || this.dataSourceGrid.length === 0) {
          throw new Error('Nenhum item na Grid')
        }
        this.dataSourceGrid = this.dataSourceGrid.filter((item) => {
          return item.ic_habilitado_atributo === 'S'
        })
        this.prop_form.cd_menu = this.dataSourceGrid[0].cd_menu
        this.prop_form.cd_api = this.dataSourceGrid[0].cd_api
      } catch (error) {
        console.error(error)
      }
    },

    async chamaAPIAtributo(item) {
      if (item.cd_api_atributo > 0 && item.nm_valor_inicial != '') {
        try {
          JSON.parse(item.nm_api_parametros).map((params) => {
            if (params.nm_parametro !== 'cd_empresa') {
              localStorage[params.nm_parametro] = item.nm_valor_inicial.replace(/\D/g, '')
            }
          })
          let parametros = JSON.parse(item.nm_api_parametros).reduce(
            (acc, cur) => (acc += `{${cur.nm_parametro}}/`),
            ''
          )
          //Tabela de Retorno da API
          let processos_json = {
            cd_empresa: localStorage.cd_empresa,
            cd_tabela: item.cd_tabela_api,
            order: 'D',
          }
          let [tabela_retorno_api] = await select.montarSelect(
            localStorage.cd_empresa,
            processos_json
          )
          var filtered
          if (tabela_retorno_api.dataset) {
            let array_tabela_retorno_api = JSON.parse(
              JSON.parse(JSON.stringify(tabela_retorno_api.dataset))
            )
            ;[filtered] = array_tabela_retorno_api.filter(
              (tab) => tab[tabela_retorno_api.display] == item.nm_valor_inicial
            )
            if (filtered) {
              const keysOrder = Object.keys(filtered)
              this.tabsheets[0].itens.map((i) => {
                if (
                  i.cd_tabela_api !== null &&
                  i.cd_tabela_api !== undefined &&
                  i.cd_tabela_api === item.cd_tabela_api
                ) {
                  i.nm_valor_inicial = filtered[keysOrder[i.cd_atributo_api - 1]]
                }
              })
            }
          }
          if (filtered === undefined) {
            try {
              this.load_api_input = true
              if (item.ic_api_post_atributo === 'N') {
                //// Method GET
                let [result_api_get] = await Procedimento.montarProcedimento(
                  localStorage.cd_empresa,
                  localStorage.cd_cliente,
                  item.nm_api_busca,
                  parametros
                )
                const keysOrderGet = Object.keys(result_api_get)
                this.tabsheets[0].itens.map((i) => {
                  if (
                    i.cd_tabela_api !== null &&
                    i.cd_tabela_api !== undefined &&
                    i.cd_tabela_api === item.cd_tabela_api
                  ) {
                    i.nm_valor_inicial = result_api_get[keysOrderGet[i.cd_atributo_api - 1]]
                    this.onAtributoDependente(i)
                  }
                })
              } else {
                // Method POST
                let json_consulta_servico = {
                  cd_menu: localStorage.cd_menu,
                  cd_form: this.tabsheets[0].itens[0].cd_form,
                  cd_documento_form: this.prop_form.cd_documento,
                  cd_item_documento_form: this.prop_form.cd_item_documento,
                  cd_usuario: localStorage.cd_usuario,
                  cd_cliente_form: localStorage.cd_cliente || null,
                  cd_contato_form: localStorage.cd_contato || null,
                  dt_usuario: formataData.AnoMesDia(new Date()),
                  ...this.tabsheets,
                }
                let [result_api_post] = await Incluir.incluirRegistro(
                  item.nm_api_busca,
                  json_consulta_servico
                )
                const keysOrderPost = Object.keys(result_api_post)
                this.tabsheets[0].itens.map((i) => {
                  if (
                    i.cd_tabela_api !== null &&
                    i.cd_tabela_api !== undefined &&
                    i.cd_tabela_api === item.cd_tabela_api
                  ) {
                    i.nm_valor_inicial = result_api_post[keysOrderPost[i.cd_atributo_api - 1]]
                    this.onAtributoDependente(i)
                  }
                })
              }
            } catch (error) {
              // eslint-disable-next-line no-console
              console.error(error)
            } finally {
              this.load_api_input = false
            }
          }
        } catch (error) {
          // eslint-disable-next-line no-console
          console.error(error)
        }
      } else if (
        item.cd_atributo_operacao_result !== 0 &&
        item.nm_operacao_atributo !== '' &&
        item.cd_atributo_operacao !== 0
      ) {
        const resultado = this.tabsheets[0].itens.reduce((acc, op) => {
          const valor = parseFloat(op.nm_valor_inicial) || 0
          if (op.nm_operacao_atributo === '+') return acc + valor
          if (op.nm_operacao_atributo === '-') return acc - valor
          if (op.nm_operacao_atributo === '*') return acc * valor
          if (op.nm_operacao_atributo === '/') return acc / valor
          return acc
        }, 0)

        this.tabsheets[0].itens.map((tab) => {
          if (
            tab.cd_atributo_operacao_result !== 0 &&
            tab.nm_operacao_atributo === '' &&
            tab.cd_atributo_operacao === 0
          ) {
            tab.nm_valor_inicial = resultado
          }
        })
      }
    },

    onInputFormEspecial(item, grid) {
      this.pop_atributo = true
      this.atributo_formEspecial = item
      this.atributo_formEspecial.grid = grid
    },

    onInputPesquisaPadrao(item, grid) {
      this.pop_pesquisa = true
      this.atributo_formEspecial = item
      this.atributo_formEspecial.grid = grid
    },

    onInfoLookup(item) {
      this.ic_info_lookup = !this.ic_info_lookup
      this.lookup_formEspecial = JSON.parse(JSON.stringify(item))
    },

    async fechaPopup(evt) {
      try {
        await this.carregaDados()
        if (this.atributo_formEspecial.grid === 'grid') {
          this.dataSourceGrid.map((item) => {
            if (item.cd_controle === this.atributo_formEspecial.cd_controle) {
              ;[item.nm_valor_inicial] = JSON.parse(item.nm_lookup).filter((filt) =>
                Object.values(evt).includes(filt[item.nm_campo_mostra_combo_box])
              )
            }
          })
        } else {
          this.tabsheets.map((tab) => {
            tab.itens.map((item) => {
              if (item.cd_controle === this.atributo_formEspecial.cd_controle) {
                ;[item.nm_valor_inicial] = JSON.parse(item.nm_lookup).filter((filt) =>
                  Object.values(evt).includes(filt[item.nm_campo_mostra_combo_box])
                )
              }
            })
          })
        }
      } catch (error) {
        console.error(error)
      } finally {
        this.pop_atributo = false
      }
    },

    linhaPesquisada(evt) {
      if (this.atributo_formEspecial.grid === 'grid') {
        this.dataSourceGrid.map((item) => {
          if (item.cd_controle === this.atributo_formEspecial.cd_controle) {
            item.nm_valor_inicial = typeof evt === 'string' ? evt : evt.cd_controle
          }
        })
      } else {
        this.tabsheets.map((tab) => {
          tab.itens.map((item) => {
            if (item.cd_controle === this.atributo_formEspecial.cd_controle) {
              item.nm_valor_inicial = typeof evt === 'string' ? evt : evt.cd_controle
            }
          })
        })
      }
      this.onInputSelect(this.atributo_formEspecial)
      this.pop_pesquisa = false
    },

    onInput(item) {
      if (item.cd_tipo_codigo > 0) {
        if (item.nm_valor_inicial) {
          JsBarcode('#barcode', item.nm_valor_inicial, {
            format: 'CODE128', // Formato do código de barras
            lineColor: '#000',
            width: 2,
            height: 100,
            displayValue: true, // Exibir o valor abaixo do código de barras
          })
        }
      }
    },

    abrirFiltroSelecao(item, arraySelect) {
      this.dialogFiltroSelecao = true
      this.filtro_selecionado = item
      this.array_filtro_selecionado = arraySelect
    },

    onAplicouFiltroSelecao({ keyField, keys }) {
      const fieldTecnico = String(keyField || '').trim()
      const values = Array.isArray(keys) ? keys : []

      // 🔁 traduz campo técnico -> campo da grid
      const fieldGrid = this.traduzCampoFiltroParaGrid(fieldTecnico)

      const result = values
        .map((id) =>
          this.array_filtro_selecionado.find(
            (b) => b[this.filtro_selecionado.nm_campo_chave_combo_box] === id
          )
        )
        .filter(Boolean)
      this.hint_filtro = result
        .map((r) => r[this.filtro_selecionado.nm_campo_mostra_combo_box])
        .join(',')
      // pega FULL do sessionStorage
      const full = this.getRowsFullFromSession()

      // sem filtro → volta tudo
      if (!fieldGrid || values.length === 0) {
        this.rows = Array.isArray(full) ? full : []
        return
      }

      // detecta tipo pelo dado real da grid
      const sample = full?.[0]?.[fieldGrid]

      let normalized = values
      if (typeof sample === 'number') {
        normalized = values.map((v) => Number(v)).filter((v) => !Number.isNaN(v))
      } else {
        normalized = values.map((v) => String(v))
      }

      const set = new Set(normalized)

      this.rows = (Array.isArray(full) ? full : []).filter((r) => {
        const v = r?.[fieldGrid]
        if (typeof sample === 'number') return set.has(Number(v))
        return set.has(String(v))
      })
    },

    traduzCampoFiltroParaGrid(fieldTecnico) {
      if (!fieldTecnico) return fieldTecnico

      const menu = this.cdMenu || this.cd_menu || 0
      const key = `campos_grid_meta_${menu}`

      let meta = []
      try {
        meta = JSON.parse(sessionStorage.getItem(key) || '[]')
      } catch (e) {
        return fieldTecnico
      }

      // procura nm_atributo -> nm_atributo_consulta
      const found = meta.find(
        (m) => String(m.nm_atributo || '').toLowerCase() === String(fieldTecnico).toLowerCase()
      )

      return found?.nm_atributo_consulta || fieldTecnico
    },

    getRowsFullFromSession() {
      // tenta chave específica primeiro
      const k1 = this.ssKey ? this.ssKey('dados_resultado_consulta') : null
      const raw1 = k1 ? sessionStorage.getItem(k1) : null
      if (raw1) {
        try {
          return JSON.parse(raw1)
        } catch (e) {}
      }

      // fallback chave “fixa”
      const raw2 = sessionStorage.getItem('dados_resultado_consulta')
      if (raw2) {
        try {
          return JSON.parse(raw2)
        } catch (e) {}
      }

      return []
    },

    ssKey(base) {
      const m = Number(this.cd_menu || 0)
      return m ? `${base}_${m}` : base
    },

    async onSalvarRegistro() {
      let itensArray = []
      // Validação
      const temErro = this.tabsheets[0].itens.some((item) => {
        if (
          item.ic_atributo_obrigatorio === 'S' &&
          !item.nm_valor_inicial &&
          item.ic_chave_incremento !== 'S'
        ) {
          notify('Preencha os campos obrigatórios')
          return true // Encontrou um erro
        }
        return false
      })

      if (temErro) {
        return // Encerra a função principal
      }
      //////////////////////////////////////////////////////////
      this.tabsheets.map((tab) => {
        tab.itens.map(async (item) => {
          if (item.cd_tabela_pesquisa && item.vl_padrao_atributo) {
            item.nm_valor_inicial = null
          }
          if (
            item.ic_tipo_atributo == '3' ||
            (item.ic_tipo_atributo == '0' && item.nm_campo_chave_combo_box != '')
          ) {
            //Lookup
            item.nm_valor_inicial = item.nm_valor_inicial
              ? item.nm_valor_inicial[item.nm_campo_chave_combo_box]
              : null
          } else if (item.ic_tipo_atributo == '8' && item.nm_valor_inicial != 'S') {
            //Toggle default
            item.nm_valor_inicial = 'N'
          } else if (item.cd_natureza_atributo == '4') {
            //Data Default não editável
            item.nm_valor_inicial = formataData.formataDataSQL(item.nm_valor_inicial)
          } else if (item.ic_tipo_atributo == '5' && item.nm_valor_inicial) {
            //File
            if (localStorage.ic_plano_armazenamento_ftp === 'S') {
              const formData = new FormData()
              formData.append('file', item.nm_valor_inicial)
              formData.append('nm_documento', item.nm_valor_inicial.name)
              formData.append('cd_empresa', localStorage.cd_empresa)
              formData.append('cd_usuario', localStorage.cd_usuario)
              formData.append('cd_cliente', localStorage.cd_cliente)
              formData.append('nm_ftp_empresa', localStorage.nm_ftp_empresa)
              formData.append('nm_pasta_ftp', item.nm_pasta_ftp_atributo)
              const options = {
                method: 'POST',
                url: 'https://egis-store.com.br/api/upload',
                headers: {
                  'Content-Type': 'multipart/form-data', // Define o tipo de conteúdo como multipart/form-data
                },
                data: formData, // Define o corpo da requisição como o objeto FormData
              }
              item.nm_valor_inicial = item.nm_valor_inicial.name
              itensArray.push({
                chave: item.nm_atributo,
                valor: item.nm_valor_inicial,
                cd_tabela_atributo: item.nm_valor_inicial,
                nm_chave_atributo: item.nm_chave_atributo,
              })
              await axios(options)
                .then(async () => {
                  ////Salva o caminho do documento na tabela geral
                  let json_salva_doc = {
                    cd_parametro: 4,
                    cd_empresa: localStorage.cd_empresa,
                    nm_documento: item.nm_valor_inicial,
                    ds_documento: item.nm_valor_inicial,
                    cd_usuario: localStorage.cd_usuario,
                    cd_modulo: localStorage.cd_modulo,
                  }
                  console.log('payload', json_salva_doc)
                  let [doc_inserido] = await Incluir.incluirRegistro(
                    '606/844', //pr_egisnet_crud_documentos
                    json_salva_doc
                  )
                  notify(doc_inserido.Msg)
                })
                .catch((error) => {
                  // eslint-disable-next-line no-console
                  console.error('Erro:', error)
                  notify('Não foi possível salvar o documento')
                })
              //File fim
            } else {
              //Plano FTP PAM nao contratado
              this.load_ftp = true
              item.nm_valor_inicial = ''
              this.anexo_down = ''
              return
            }
          }
          if (!['cd_menu'].includes(item.nm_atributo)) {
            itensArray.push({
              chave: item.nm_atributo,
              valor: item.nm_valor_inicial,
              cd_tabela_atributo: item.nm_valor_inicial,
              nm_chave_atributo: item.nm_chave_atributo,
            })
          }
        })
      })
      if (this.load_ftp === true) {
        return
      }
      let itensObject = {}
      itensArray.map((item) => {
        itensObject[item.chave] = item.valor
      })
      let json_salvar_registro = {
        cd_menu: this.prop_form.cd_menu || localStorage.cd_menu,
        cd_form: this.tabsheets[0].itens[0].cd_form,
        cd_documento_form: this.prop_form.cd_documento,
        cd_item_documento_form: this.prop_form.cd_item_documento,
        cd_parametro_form: this.prop_form.cd_documento ? '2' : '1', //2 - Update | 1 - Insert
        cd_usuario: localStorage.cd_usuario,
        cd_cliente_form: localStorage.cd_cliente || null,
        cd_contato_form: localStorage.cd_contato || null,
        cd_filtro_tabela: this.filtro_selecionado ? this.filtro_selecionado.cd_filtro_tabela : null,
        dt_usuario: formataData.AnoMesDia(new Date()),
        lookup_formEspecial: {
          nm_valor_inicial: this.lookup_formEspecial.nm_valor_inicial,
          cd_tabela_pesquisa: this.lookup_formEspecial.cd_tabela_pesquisa,
          nm_campo_chave_combo_box: this.lookup_formEspecial.nm_campo_chave_combo_box,
          nm_tabela_combo_box: this.lookup_formEspecial.nm_tabela_combo_box,
          cd_controle: this.lookup_formEspecial.cd_controle,
        },
        //itensArray: itensArray, //Traz informações de cada item do form
        ...itensObject,
        detalhe: [],
        lote: [],
      }
      if (localStorage.cd_modulo == 220) {
        //Portal de Clientes
        json_salvar_registro.cd_modulo_form = localStorage.cd_modulo
      } else {
        json_salvar_registro.cd_modulo = localStorage.cd_modulo
      }
      try {
        var result = await Incluir.incluirRegistro('920/1430', json_salvar_registro) //pr_api_dados_form_especial
        this.chave_novo_registro = result[0].chave
        if (this.dataSourceConfig[0].ic_grid_form !== 'S' && this.dataSourceGrid) {
          this.onFechar(json_salvar_registro)
        } else {
          this.reload_grid = true
          this.jsonObjGrid = {
            cd_form:
              this.grid_itens_edit &&
              this.grid_itens_edit.length > 0 &&
              this.grid_itens_edit[0].cd_form_grid
                ? this.grid_itens_edit[0].cd_form_grid
                : undefined,
            cd_documento: result[0].chave,
            cd_usuario: localStorage.cd_usuario,
          }
          await this.carregaGrid()
        }
        if (result[0].Msg !== '') {
          notify(result[0].Msg)
        } else {
          notify('Registro salvo com sucesso')
        }
      } catch (error) {
        if (this.dataSourceConfig[0].ic_grid_form !== 'S' && this.dataSourceGrid) {
          this.onFechar(json_salvar_registro)
        }
        notify('Não foi possivel salvar o registro')
      } finally {
        this.onVoltaLookups()
        this.reload_grid = false
      }
    },
    onInputLookup(valor, chave, lookup_formEspecial) {
      this.$set(
        this.lookup_formEspecial.nm_valor_inicial,
        chave,
        lookup_formEspecial.nm_valor_inicial[chave]
      )
    },
    onVoltaLookups() {
      try {
        this.tabsheets.map((tab) => {
          tab.itens.map(async (item) => {
            if (item.nm_lookup !== '' && item.nm_campo_chave_combo_box !== '') {
              //Lookup
              let [lkpItem] = JSON.parse(item.nm_lookup).filter(
                (lkp) => lkp[item.nm_campo_chave_combo_box] == item.nm_valor_inicial
              )
              item.nm_valor_inicial = lkpItem
            }
          })
        })
      } catch (error) {
        console.error(error)
      }
    },
    onLimparRegistro() {
      this.tabsheets.map((tab) => {
        tab.itens.map((item) => {
          item.nm_valor_inicial = ''
        })
      })
    },
    onFechar(res) {
      this.onLimparRegistro()
      this.$emit('click', res)
      if (localStorage.cd_menu) {
        this.$router.push({ name: 'home' })
      }
    },
    linhaSelecionada(e) {
      this.obj_item = e
      this.prop_form.cd_documento = e.cd_documento
      this.prop_form.cd_item_documento = e.cd_item_documento
      this.dataSourceGrid.map((item) => {
        if (
          item.nm_lookup !== '' &&
          item.nm_campo_chave_combo_box !== '' &&
          item.ic_chave_grid !== 'S' &&
          e[item.nm_campo_chave_combo_box]
        ) {
          let [lkpItem] = JSON.parse(item.nm_lookup).filter(
            (lkp) => lkp[item.nm_campo_chave_combo_box] == e[item.nm_campo_chave_combo_box]
          )
          item.nm_valor_inicial = lkpItem
        } else {
          item.nm_valor_inicial = e[item.nm_atributo]
            ? e[item.nm_atributo][item.nm_campo_chave_combo_box]
            : ''
          item.nm_valor_inicial = e[item.nm_atributo] ? e[item.nm_atributo] : ''
        }
      })
    },
    DoubleClickLine() {
      this.pop_grid_item = true
    },
    onNovoRegistro() {
      this.obj_item = {}
      this.dataSourceGrid.map((item) => {
        item.nm_valor_inicial = ''
      })
    },
    InputAtributo(e) {
      if (e.nm_valor_inicial == null) {
        this.obj_item[e.nm_atributo] = null
        return
      }
      if (
        e.nm_lookup !== '' &&
        e.nm_campo_chave_combo_box !== '' &&
        e.nm_valor_inicial[e.nm_campo_chave_combo_box]
      ) {
        this.obj_item[e.nm_atributo] = e.nm_valor_inicial[e.nm_campo_chave_combo_box]
      } else {
        this.obj_item[e.nm_atributo] = e.nm_valor_inicial
      }
    },
    async onSalvarItemGrid() {
      //Valida campos obrigatórios
      const camposObrigatorios = this.dataSourceGrid.filter((item) => {
        if (item.ic_atributo_obrigatorio === 'S' && item.ic_chave_grid !== 'S') {
          return item
        }
      })
      const temError = camposObrigatorios.some((item) => {
        if (!this.obj_item[item.nm_atributo]) {
          return true
        }
      })
      if (temError) {
        notify('Preencha os campos obrigatórios')
        return
      }
      let json_salvar_registro = {
        cd_modulo: localStorage.cd_modulo,
        cd_menu: localStorage.cd_menu,
        cd_form: this.dataSourceGrid[0].cd_form,
        cd_documento_form: this.prop_form.cd_documento || this.chave_novo_registro,
        cd_item_documento_form: this.prop_form.cd_item_documento,
        cd_parametro_form: this.obj_item.cd_documento ? '2' : '1', //2 - Update | 1 - Insert
        cd_usuario: localStorage.cd_usuario,
        cd_cliente_form: localStorage.cd_cliente || null,
        cd_contato_form: localStorage.cd_contato || null,
        cd_filtro_tabela: this.filtro_selecionado ? this.filtro_selecionado.cd_filtro_tabela : null,
        dt_usuario: formataData.AnoMesDia(new Date()),
        ...this.obj_item,
        detalhe: [],
        lote: [],
      }
      try {
        this.reload_grid = true
        let [result] = await Incluir.incluirRegistro('920/1430', json_salvar_registro) //pr_api_dados_form_especial
        this.onNovoRegistro()
        if (result.Msg !== '') {
          notify(result.Msg)
        } else {
          notify('Item salvo com sucesso')
        }
      } catch (error) {
        notify('Não foi possivel salvar o item')
      } finally {
        this.reload_grid = false
      }
    },
    async onExcluirItemGrid() {
      let json_excluir_registro = {
        cd_modulo: localStorage.cd_modulo,
        cd_menu: localStorage.cd_menu,
        cd_form: this.dataSourceGrid[0].cd_form,
        cd_documento_form: this.obj_item.cd_documento,
        cd_item_documento_form: this.obj_item.cd_item_documento,
        cd_parametro_form: '3', //2 - Update | 1 - Insert
        cd_usuario: localStorage.cd_usuario,
        cd_cliente_form: localStorage.cd_cliente || null,
        cd_contato_form: localStorage.cd_contato || null,
        dt_usuario: formataData.AnoMesDia(new Date()),
        detalhe: [],
        lote: [],
      }
      this.reload_grid = true
      try {
        await Incluir.incluirRegistro('920/1430', json_excluir_registro) //pr_api_dados_form_especial
        notify('Item excluído com sucesso')
      } catch (error) {
        notify('Não foi possivel excluir o item')
      } finally {
        this.reload_grid = false
      }
    },
    async onExcluir() {
      let json_excluir_registro = {
        cd_modulo: localStorage.cd_modulo,
        cd_menu: localStorage.cd_menu,
        cd_form: this.tabsheets[0].itens[0].cd_form,
        cd_documento_form: this.prop_form.cd_documento,
        cd_item_documento_form: this.prop_form.cd_item_documento,
        cd_parametro_form: '3', //2 - Update | 1 - Insert
        cd_usuario: localStorage.cd_usuario,
        cd_cliente_form: localStorage.cd_cliente || null,
        cd_contato_form: localStorage.cd_contato || null,
        dt_usuario: formataData.AnoMesDia(new Date()),
        detalhe: [],
        lote: [],
      }
      try {
        await Incluir.incluirRegistro('920/1430', json_excluir_registro) //pr_api_dados_form_especial
        this.onFechar()
        notify('Registro excluído com sucesso')
      } catch (error) {
        notify('Não foi possivel excluir o registro')
      }
    },
    async onDownloadDoc() {
      const nm_pasta_ftp = this.tabsheets[0].itens.find(
        (item) =>
          item.nm_pasta_ftp_atributo !== undefined &&
          item.nm_pasta_ftp_atributo !== null &&
          item.nm_pasta_ftp_atributo !== ''
      )
      const options = {
        method: 'GET',
        responseType: 'blob',
        url: `https://egis-store.com.br/api/download/${this.anexo_down}/${localStorage.nm_ftp_empresa}/${nm_pasta_ftp.nm_pasta_ftp_atributo}`,
      }
      axios(options)
        .then((response) => {
          const blob = new Blob([response.data], {
            type: 'application/octet-stream',
          })
          const url = window.URL.createObjectURL(blob)
          const link = document.createElement('a')
          link.href = url
          link.download = this.anexo_down
          document.body.appendChild(link)
          link.click()
          window.URL.revokeObjectURL(url)
        })
        .catch((error) => {
          // eslint-disable-next-line no-console
          console.error('Erro:', error)
        })
    },
    async onRelatorio() {
      try {
        this.load = true
        let json_relatorio = {
          cd_consulta: this.prop_form.cd_documento,
          //cd_pedido_venda: this.prop_form.cd_documento,
          cd_menu: 5428,
          cd_parametro: 14,
          cd_usuario: localStorage.cd_usuario,
        }
        ;[this.relatorio] = await Incluir.incluirRegistro('897/1377', json_relatorio) //pr_modulo_processo_egismob_post -> pr_egismob_relatorio_pedido
        let documento = document.getElementById('relatorioHTML')
        documento.innerHTML = this.relatorio.RelatorioHTML
        const blob = new Blob([documento], {
          type: 'text/html',
        })
        const url = URL.createObjectURL(blob)
        window.open(url, '_blank')
        URL.revokeObjectURL(url)
        notify('Relatório gerado com sucesso')
        this.load = false
      } catch (error) {
        this.load = false
        notify('Não foi possivel gerar o relatório')
      }
    },
    async onEmail() {
      //pr_gera_email_modulo_crm //E para os outros módulos ?
    },
    async onMensagem() {
      try {
        var mensagem = await Menu.montarMenu(this.cd_empresa, 0, 865) //pr_gera_mensagem_api_whatsapp
        //localStorage.nm_documento = '119595959599';  //telefone
        //localStorage.ds_parametro = 'Cadastro realizado com sucesso!'; //Mensagem
        //localStorage.cd_mensagem  = 5; //Mensagem (Precisa cadastrar esse parâmetro)

        if (!mensagem.nm_api_parametro == '') {
          let [result_msg] = await Procedimento.montarProcedimento(
            this.cd_empresa,
            localStorage.cd_cliente,
            mensagem.nm_identificacao_api,
            mensagem.nm_api_parametro
          )
          notify(result_msg.Msg)
          notify('Mensagem enviada com sucesso!')
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('Não foi possível enviar a mensagem: ', error)
      }
    },
    onKeydownSelect(event, item) {
      if (event.key === 'Backspace') {
        item.nm_valor_inicial = ''
      }
    },
    filterFn(val, update) {
      if (val === '') {
        update(() => {
          this.arraySelect = this.arraySelectOriginal
        })
        return
      }

      update(() => {
        const needle = val.toLowerCase()
        this.arraySelect = this.arraySelect.filter(
          (v) => v[this.itemSelect.nm_campo_mostra_combo_box].toLowerCase().indexOf(needle) > -1
        )
      })
    },
    onBlurSelect() {
      if (this.arraySelect.length === 0 && this.itemSelect.cd_form_especial > 0) {
        this.arraySelect = this.arraySelectOriginal
        this.onInputFormEspecial(this.itemSelect)
      }
    },
    onFocus(lookup, item) {
      this.arraySelect = lookup
      this.arraySelectOriginal = lookup
      this.itemSelect = item
    },
    async onAtributoDependente(item) {
      if (
        this.tabsheets[0].itens.filter(
          (tabI) => tabI.cd_atributo_dependente === item.qt_ordem_atributo
        ).length > 0
      ) {
        let atributoDependente = this.tabsheets[0].itens.filter(
          (tabI) => tabI.cd_atributo_dependente === item.qt_ordem_atributo
        )
        const where_lookup = atributoDependente[0].nm_where_lookup
          .split(',')
          .map((par) => par.trim())

        const whereDinamico = {}
        for (const cond of where_lookup) {
          const [chave, valorStr] = cond.split('=').map((s) => s.trim())
          const valor = isNaN(Number(valorStr)) ? valorStr : Number(valorStr)
          whereDinamico[chave] = valor
        }

        let processos_json = {
          cd_empresa: localStorage.cd_empresa,
          cd_tabela: atributoDependente[0].cd_tabela_combo_box,
          order: 'D',
          where: [
            {
              ...whereDinamico,
              [item['nm_campo_chave_combo_box']]:
                item.nm_valor_inicial[item['nm_campo_chave_combo_box']],
            },
          ],
        }
        let [lookup_dependente] = await select.montarSelect(
          localStorage.cd_empresa, //this.cd_empresa,
          processos_json
        )
        this.tabsheets[0].itens.map((it) => {
          if (it.cd_atributo_dependente === item.qt_ordem_atributo) {
            it.nm_lookup = lookup_dependente.dataset
            if (it.nm_valor_inicial) {
              ;[it.nm_valor_inicial] = JSON.parse(it.nm_lookup).filter((lkp) => {
                return lkp[it.nm_campo_chave_combo_box] == it.nm_valor_inicial
              })
            }
          }
        })
      }
    },
    async onInputSelect(item) {
      this.onAtributoDependente(item)

      if (item.nm_valor_inicial) {
        this.tabsheets.map((tab) => {
          tab.itens.map((it) => {
            if (
              it.cd_tabela_pesquisa === item.cd_tabela_pesquisa &&
              item.nm_valor_inicial[it.vl_padrao_atributo]
            ) {
              it.nm_valor_inicial = item.nm_valor_inicial[it.vl_padrao_atributo]
            }
          })
        })
      }
    },
  },
}
</script>

<style scoped>
@import url('../views/views.css');
</style>
