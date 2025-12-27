<template>
  <div>
    <div class="row text-h5 margin1">
      {{ tituloMenu }}
    </div>
    <div id="mapRomaneio" v-show="false"></div>
    <div class="row justify-around margin1 borda shadow-1">
      <q-input
        class="margin1 metadeTela2"
        @keypress.enter="PesquisaRomaneio()"
        color="orange-9"
        v-model="cd_romaneio"
        type="number"
        label="Romaneio"
      >
        <template v-slot:prepend>
          <q-icon name="bookmark" />
        </template>
      </q-input>
      <div class="row items-center ">
        <q-btn
          class="margin1 button-add"
          color="orange-9"
          icon="add"
          round
          size="sm"
          @click="novoRomaneio()"
        >
          <q-tooltip transition-show="scale" transition-hide="scale">
            Novo Romaneio
          </q-tooltip>
        </q-btn>
      </div>
      <q-select
        label="Transporte"
        class="margin1 metadeTela2"
        v-model="cd_empresa_faturamento"
        input-debounce="0"
        color="orange-9"
        :options="this.dataset_empresa_faturamento"
        option-value="cd_empresa"
        option-label="nm_empresa"
      >
        <template v-slot:prepend>
          <q-icon name="store" />
        </template>
      </q-select>
    </div>
    <div class="row justify-around items-center margin1 borda shadow-1">
      <q-input
        class="margin1 "
        style="width:92%"
        v-model="cliente"
        color="orange-9"
        type="text"
        @keypress.enter="PesquisaCliente()"
        label="Cliente"
      >
        <template v-slot:prepend>
          <q-icon name="person" />
        </template>
      </q-input>
      <q-space />
      <div class="button-add">
        <q-btn
          round
          size="sm"
          class="margin1"
          color="orange-9"
          icon="add"
          @click="novoCliente()"
        />
      </div>
      <transition name="slide-fade">
        <div
          v-show="razao != ''"
          style="display:inline-block"
          class="text-subtitle1 text-bold margin1 text-blue-10 "
        >
          <q-icon
            @click="EditaEndereco"
            class="text-orange-9 margin1 cursor-pointer"
            style="font-size: 1.6em"
            name="mode_edit"
          >
            <q-tooltip transition-show="scale" transition-hide="scale">
              Editar Endereço
            </q-tooltip>
          </q-icon>
          {{ razao }}
        </div>
      </transition>
      <transition name="slide-fade">
        <div
          v-show="razao != ''"
          style="display:inline-block"
          class="text-subtitle1 text-bold margin1 "
        >
          <q-icon
            @click="AbreMapaRomaneio"
            class="text-orange-9 margin1 cursor-pointer"
            style="font-size: 1.6em"
            name="location_on"
          >
            <q-tooltip transition-show="scale" transition-hide="scale">
              Mapa
            </q-tooltip>
          </q-icon>
          Endereço: {{ cep_temp }} - {{ rua_temp }} - {{ bairro_temp }} -
          {{ cidade_temp }} - {{ estado_temp }} - {{ itinerario }}
        </div>
      </transition>
    </div>
    <div
      class="row justify-around items-center margin1 borda shadow-1"
      v-if="!!qt_distancia || !!qt_tempo"
    >
      <div class="meiaTela margin1 text-orange-9 text-h6" v-if="!!qt_distancia">
        <q-icon
          name="sync_alt"
          size="md"
          class="text-orange-9"
          style="margin-right:5px"
        />
        Distância: {{ qt_distancia }}
      </div>
      <div
        class="row items-center meiaTela margin1 text-orange-9 text-h6 justify-around"
        v-if="!!qt_tempo"
      >
        <q-icon
          name="schedule"
          size="md"
          class="text-orange-9"
          style="margin-right:5px"
        />
        Tempo: {{ qt_tempo }}
      </div>
    </div>

    <div class="items-center margin1 borda shadow-1">
      <div class="row items-center justify-around">
        <q-select
          label="Base Retirada"
          class="margin1 metadeTela "
          v-model="base"
          input-debounce="0"
          color="orange-9"
          :options="this.dataset_base"
          option-value="cd_base"
          option-label="nm_base"
          @input="
            CalculaDistancia(
              qt_latitude,
              qt_longitude,
              base.qt_latitude,
              base.qt_longitude
            )
          "
        >
          <template v-slot:prepend>
            <q-icon name="local_shipping" />
          </template>
        </q-select>
        <div class="margin1 metadeTela ">
          <q-checkbox
            v-model="ic_sel_fechamento"
            color="orange-9"
            label="Romaneio Fechado"
          />
        </div>
      </div>

      <div class="row items-center justify-around">
        <q-input
          class="margin1 telaInteira"
          v-model="nm_obs_romaneio"
          autogrow
          color="orange-9"
          type="text"
          label="Observações"
        >
          <template v-slot:prepend>
            <q-icon name="description" />
          </template>
        </q-input>
        <!--
           <q-input
          class="margin1 metadeTela"
          v-model="nm_conferido"
          autogrow
          color="orange-9"
          type="text"
          label="Conferência"
        >
          <template v-slot:prepend>
            <q-icon name="person" />
          </template>
        </q-input>
        -->
      </div>

      <div class="row items-center justify-around">
        <q-select
          label="Motivo de Cancelamento"
          class="margin1 telaInteira "
          v-model="motivo_cancelamento"
          input-debounce="0"
          color="orange-9"
          :options="this.dataset_cancelamento"
          option-value="cd_motivo_cancelamento"
          option-label="nm_motivo_cancelamento"
        >
          <template v-slot:prepend>
            <q-icon name="delete_forever" />
          </template>
          <template v-slot:append>
            <q-btn icon="close" flat round @click="motivo_cancelamento = ''" />
          </template>
        </q-select>
      </div>

      <div class="row items-center justify-around">
        <q-input
          color="orange-9"
          v-model="dt_saida"
          class="margin1 umTercoTela"
          mask="##/##/####"
          label="Data Saída"
        >
          <template v-slot:prepend>
            <q-icon name="today" />
          </template>
          <template v-slot:append>
            <q-btn
              icon="event"
              color="orange-9"
              round
              size="sm"
              class="cursor-pointer"
            >
              <q-popup-proxy
                ref="qDateProxy"
                cover
                transition-show="scale"
                transition-hide="scale"
              >
                <q-date
                  color="orange-9"
                  id="data-pop"
                  v-model="dt_saida"
                  mask="DD/MM/YYYY"
                  class="qdate"
                >
                  <div class="row items-center justify-end">
                    <q-btn
                      v-close-popup
                      round
                      color="orange-9"
                      icon="close"
                      size="sm"
                    />
                  </div>
                </q-date>
              </q-popup-proxy>
            </q-btn>
          </template>
        </q-input>
        <q-input
          v-model="hr_saida"
          color="orange-9"
          mask="##:##"
          label="Hora Saída"
          class="margin1 umTercoTela"
        >
          <template v-slot:append>
            <q-btn
              icon="schedule"
              round
              size="sm"
              color="orange-9"
              class="cursor-pointer"
            >
              <q-popup-proxy
                cover
                transition-show="scale"
                transition-hide="scale"
              >
                <q-time v-model="hr_saida" color="orange-9">
                  <div class="row items-center justify-end">
                    <q-btn v-close-popup label="fechar" color="orange-9" flat />
                  </div>
                </q-time>
              </q-popup-proxy>
            </q-btn>
          </template>
          <template v-slot:prepend>
            <q-icon name="schedule" />
          </template>
        </q-input>
        <q-input
          class="margin1 umTercoTela"
          v-model="qt_km_saida"
          autogrow
          color="orange-9"
          type="number"
          label="KM Saída"
        >
          <template v-slot:prepend>
            <q-icon name="arrow_forward" />
          </template>
        </q-input>
      </div>
      <div class="row items-center justify-around">
        <q-input
          color="orange-9"
          v-model="dt_retorno"
          class="margin1 umTercoTela"
          mask="##/##/####"
          label="Data Retorno"
        >
          <template v-slot:prepend>
            <q-icon name="today" />
          </template>
          <template v-slot:append>
            <q-btn
              icon="event"
              color="orange-9"
              round
              size="sm"
              class="cursor-pointer"
            >
              <q-popup-proxy
                ref="qDateProxy"
                cover
                transition-show="scale"
                transition-hide="scale"
              >
                <q-date
                  color="orange-9"
                  id="data-pop"
                  v-model="dt_retorno"
                  mask="DD/MM/YYYY"
                  class="qdate"
                >
                  <div class="row items-center justify-end">
                    <q-btn
                      v-close-popup
                      round
                      color="orange-9"
                      icon="close"
                      size="sm"
                    />
                  </div>
                </q-date>
              </q-popup-proxy>
            </q-btn>
          </template>
        </q-input>
        <q-input
          v-model="hr_retorno"
          color="orange-9"
          mask="##:##"
          label="Hora Retorno"
          class="margin1 umTercoTela"
        >
          <template v-slot:append>
            <q-btn
              icon="schedule"
              round
              size="sm"
              color="orange-9"
              class="cursor-pointer"
            >
              <q-popup-proxy
                cover
                transition-show="scale"
                transition-hide="scale"
              >
                <q-time v-model="hr_retorno" color="orange-9">
                  <div class="row items-center justify-end">
                    <q-btn v-close-popup label="fechar" color="orange-9" flat />
                  </div>
                </q-time>
              </q-popup-proxy>
            </q-btn>
          </template>
          <template v-slot:prepend>
            <q-icon name="schedule" />
          </template>
        </q-input>
        <q-input
          class="margin1 umTercoTela"
          v-model="qt_km_retorno"
          autogrow
          color="orange-9"
          type="number"
          label="KM Retorno"
        >
          <template v-slot:prepend>
            <q-icon name="arrow_back" />
          </template>
        </q-input>
      </div>
    </div>

    <div class="justify-around items-center margin1 borda shadow-1">
      <div class="row justify-around ">
        <q-input
          color="orange-9"
          v-model="dt_previsao"
          class="margin1 metadeTela"
          mask="##/##/####"
          label="Data Previsão"
        >
          <template v-slot:prepend>
            <q-icon name="today" />
          </template>
          <template v-slot:append>
            <q-btn
              icon="event"
              color="orange-9"
              round
              size="sm"
              class="cursor-pointer"
            >
              <q-popup-proxy
                ref="qDateProxy"
                cover
                transition-show="scale"
                transition-hide="scale"
              >
                <q-date
                  color="orange-9"
                  id="data-pop"
                  v-model="dt_previsao"
                  mask="DD/MM/YYYY"
                  class="qdate"
                >
                  <div class="row items-center justify-end">
                    <q-btn
                      v-close-popup
                      round
                      color="orange-9"
                      icon="close"
                      size="sm"
                    />
                  </div>
                </q-date>
              </q-popup-proxy>
            </q-btn>
          </template>
        </q-input>
        <q-input
          v-model="hr_previsao"
          color="orange-9"
          mask="##:##"
          label="Hora Previsão"
          class="margin1 metadeTela"
        >
          <template v-slot:append>
            <q-btn
              icon="schedule"
              round
              size="sm"
              color="orange-9"
              class="cursor-pointer"
            >
              <q-popup-proxy
                cover
                transition-show="scale"
                transition-hide="scale"
              >
                <q-time v-model="hr_previsao" color="orange-9">
                  <div class="row items-center justify-end">
                    <q-btn v-close-popup label="fechar" color="orange-9" flat />
                  </div>
                </q-time>
              </q-popup-proxy>
            </q-btn>
          </template>
          <template v-slot:prepend>
            <q-icon name="schedule" />
          </template>
        </q-input>
      </div>

      <div class="row justify-around ">
        <q-input
          color="orange-9"
          v-model="dt_entrega_romaneio"
          class="margin1 metadeTela"
          readonly
          mask="##/##/####"
          label="Data Entrega"
        >
          <template v-slot:prepend>
            <q-icon name="assignment_turned_in" />
          </template>
        </q-input>

        <q-input
          color="orange-9"
          v-model="hr_entrega"
          readonly
          mask="##:##"
          label="Hora de entrega"
          class="margin1 metadeTela"
        >
          <template v-slot:prepend>
            <q-icon name="alarm_on" />
          </template>

          <template v-slot:append>
            <q-icon name="map" class="text-orange-9 cursor-pointer">
              <q-popup-proxy
                v-model="target"
                transition-show="flip-up"
                transition-hide="flip-down"
              >
                <q-banner class="bg-orange-9 text-white" style="max-width:auto">
                  <div
                    class="text-bold cursor-pointer text-justify"
                    @click="deletaRoteiro()"
                  >
                    <q-icon
                      class="cursor-pointer"
                      name="delete"
                      size="sm"
                    />Limpar Roteiros
                  </div>
                </q-banner>
              </q-popup-proxy>
            </q-icon>
          </template>
        </q-input>
      </div>
    </div>
    <div class="row justify-around items-center margin1 borda shadow-1">
      <q-select
        label="Motorista"
        class="margin1 umTercoTela "
        v-model="cd_motorista"
        input-debounce="0"
        color="orange-9"
        :options="this.dataset_motorista"
        option-value="cd_motorista"
        option-label="nm_motorista"
        @input="SelectMotorista(cd_motorista)"
      >
        <template v-slot:prepend>
          <q-icon name="face" />
        </template>
      </q-select>
      <q-select
        label="Veículo"
        v-model="cd_veiculo"
        id="select-menor"
        class="margin1 umTercoTela "
        input-debounce="0"
        color="orange-9"
        :options="this.dataset_veiculo"
        option-value="cd_veiculo"
        option-label="nm_veiculo"
      >
        <template v-slot:prepend>
          <q-icon name="two_wheeler" />
        </template>
      </q-select>
      <q-input
        class="margin1 umTercoTela"
        autogrow
        v-model="ocorrencia"
        type="text"
        color="orange-9"
        label="Ocorrência"
      >
        <template v-slot:prepend>
          <q-icon name="priority_high" />
        </template>
      </q-input>
      <div class="row justify-evenly items-center ">
        <q-checkbox
          v-model="prioridade"
          label="Prioridade"
          class="text-bold check-box-style "
          color="orange-9"
        />

        <q-checkbox
          v-model="roteiroV"
          label="Roteiro"
          class="text-bold check-box-style "
          color="orange-9"
        />

        <q-input
          v-model="chegada"
          readonly
          class="tela-quatro margin1"
          :bg-color="bg_input2"
          autogrow
          type="text"
          label="Chegada"
          color="orange-9"
        >
          <template v-slot:prepend>
            <q-icon name="hourglass_bottom" />
          </template>
        </q-input>

        <q-input
          v-model="saida"
          readonly
          class=" tela-quatro margin1 "
          :bg-color="bg_input"
          autogrow
          color="orange-9"
          type="text"
          label="Saída"
        >
          <template v-slot:prepend>
            <q-icon name="event_busy" />
          </template>
        </q-input>
        <q-input
          v-model="nm_responsavel"
          readonly
          class=" tela-quatro margin1 "
          autogrow
          type="text"
          color="orange-9"
          label="Responsável"
        >
          <template v-slot:prepend>
            <q-icon name="face" />
          </template>
        </q-input>
        <q-input
          v-model="nm_documento_responsavel"
          readonly
          class=" tela-quatro margin1 "
          autogrow
          color="orange-9"
          type="text"
          label="Documento"
        >
          <template v-slot:prepend>
            <q-icon name="contact_mail" />
          </template>
        </q-input>

        <div class="items-center self-center buttons-sm ">
          <q-btn
            @click="chamaDoc(true, true)"
            size="sm"
            class="button-popup"
            color="orange-9"
            icon="picture_as_pdf"
            round
          >
            <q-tooltip transition-show="scale" transition-hide="scale">
              Documentos
            </q-tooltip>
          </q-btn>
        </div>
        <div class="items-center self-center buttons-sm ">
          <q-btn
            @click="chamaDoc(true, false)"
            size="sm"
            color="orange-9"
            class="button-popup"
            icon="receipt"
            round
          >
            <q-tooltip transition-show="scale" transition-hide="scale">
              Canhoto
            </q-tooltip>
          </q-btn>
        </div>

        <div class=" self-center buttons-sm ">
          <q-btn
            @click="AbreExtrato()"
            size="sm"
            color="orange-9"
            icon="content_paste"
            class="button-popup"
            round
          >
            <q-tooltip transition-show="scale" transition-hide="scale">
              Extrato
            </q-tooltip>
          </q-btn>
        </div>
      </div>
    </div>
    <div class="justify-around items-center margin1 borda shadow-1">
      <div class="row ">
        <div class="margin1 text-subtitle1 text-bold">
          Itens do Romaneio
        </div>
        <q-space />
        <transition name="slide-fade">
          <div class="margin1 text-subtitle1 text-bold" v-show="!!total_compra">
            Total: {{ total_compra }}
          </div>
        </transition>
        <transition name="slide-fade">
          <div
            class="margin1 text-subtitle1 text-bold"
            v-show="!!qt_total_romaneio"
          >
            Volume: {{ qt_total_romaneio }}
          </div>
        </transition>
      </div>

      <q-input
        class="margin1"
        filled
        @keypress.enter="PesquisarServico()"
        item-aligned
        v-model="produto"
        type="text"
        color="orange-9"
        label="Item"
      >
        <template v-slot:prepend>
          <q-icon name="sell" />
        </template>
      </q-input>
      <DxDataGrid
        class="margin1 shadow-2"
        key-expr="cd_controle"
        :data-source="json_local"
        :columns="colunas"
        :ref="gridRefNameCarrinho"
        :show-borders="false"
        :column-auto-width="true"
        :column-hiding-enabled="true"
        :selection="{ mode: 'single' }"
        :auto-navigate-to-focused-row="true"
        :hover-state-enabled="true"
        @saved="onCalculaTotal"
        @row-updated="AtualizaItem"
        @edit-canceled="onCalculaTotal"
        @row-removed="ExcluirProduto"
        @row-removing="onCalculaTotal"
      >
        <DxEditing
          style="margin:0; padding:0"
          :allow-updating="edit_grid"
          :allow-deleting="edit_grid"
          mode="batch"
        />
        <DxColumn :data-field="colunas[0]" alignment="left" />
        <DxColumn :data-field="colunas[1]" alignment="left" />
        <DxColumn :data-field="colunas[2]" alignment="left" />
        <DxColumn :data-field="colunas[3]" alignment="left" />
        <DxPaging :page-size="10" />
      </DxDataGrid>
    </div>
    <div class="row margin1">
      <q-btn
        class="margin1"
        color="orange-9"
        label="Novo"
        icon="add"
        rounded
        @click="novoRomaneio()"
      >
        <q-tooltip transition-show="scale" transition-hide="scale">
          Novo Romaneio
        </q-tooltip>
      </q-btn>
      <q-space />
      <q-btn
        color="orange-9"
        class="margin1"
        icon="save"
        label="Gravar"
        rounded
        :disable="ready"
        @click="EnviarPedido()"
      >
        <q-tooltip transition-show="scale" transition-hide="scale">
          {{ mensagem }}
        </q-tooltip>
      </q-btn>
    </div>
    <!---------------------------------------------------------->
    <q-dialog
      v-model="pop_cadastro_cliente"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-orange-9 text-white">
          Endereço
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange-9 text-white"
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
            <q-tooltip class="bg-orange-9 text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="q-pt-none">
          <div class="row borda-bloco shadow-2 margin1">
            <q-input
              class=" col response margin1"
              readonly
              v-model="prop_cli.nm_razao_social_cliente"
              type="text"
              label="Razão Social"
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-input>

            <q-input
              class=" col response margin1"
              readonly
              v-model="prop_cli.nm_fantasia_cliente"
              type="text"
              label="Fantasia"
            >
              <template v-slot:prepend>
                <q-icon name="location_on" />
              </template>
            </q-input>
            <q-input
              class=" col response margin1"
              readonly
              v-model="prop_cli.nm_tipo_pessoa"
              type="text"
              label="Tipo Pessoa"
            >
              <template v-slot:prepend>
                <q-icon name="format_list_bulleted" />
              </template>
            </q-input>
          </div>
          <div class="row borda-bloco shadow-2 margin1">
            <q-input
              class=" col response margin1"
              v-model="prop_cli.cd_cep"
              mask="#####-###"
              type="text"
              label="CEP"
              @blur="onBuscaCep"
            >
              <template v-slot:prepend>
                <q-icon name="pin_drop" />
              </template>
            </q-input>

            <q-input
              class=" col response margin1"
              v-model="prop_cli.cd_numero"
              type="text"
              label="Número"
            >
              <template v-slot:prepend>
                <q-icon name="dialpad" />
              </template>
            </q-input>

            <q-input
              class=" col response margin1"
              :loading="load_end"
              v-model="prop_cli.nm_endereco"
              type="text"
              label="Endereço"
            >
              <template v-slot:prepend>
                <q-icon name="home_work" />
              </template>
            </q-input>

            <q-input
              class=" col response margin1"
              :loading="load_end"
              v-model="prop_cli.nm_bairro"
              type="text"
              label="Bairro"
            >
              <template v-slot:prepend>
                <q-icon name="map" />
              </template>
            </q-input>
          </div>
          <div class="row borda-bloco shadow-2 margin1">
            <q-select
              label="Cidade"
              class="  col response margin1"
              v-model="cidade_prop"
              :loading="load_end"
              input-debounce="0"
              :options="this.dataset_cidade"
              option-value="cd_cidade"
              option-label="nm_cidade"
            >
              <template v-slot:prepend>
                <q-icon name="apartment" />
              </template>
            </q-select>

            <q-select
              label="Estado"
              :loading="load_end"
              class="  col response margin1"
              v-model="estado_prop"
              input-debounce="0"
              :options="this.dataset_estado"
              option-value="cd_estado"
              option-label="sg_estado"
            >
              <template v-slot:prepend>
                <q-icon name="public" />
              </template>
            </q-select>
          </div>
          <div class="row items-end justify-end margin1">
            <q-btn
              color="positive"
              @click="AtualizaEndereco"
              icon="check"
              rounded
              style="float:right"
              text-color="white"
              label="Salvar"
            />
          </div>
          <!--<cliente :prop_cli="prop_cli"/>-->
        </q-card-section>
      </q-card>
    </q-dialog>
    <!-------------------------------------->
    <q-dialog maximized v-model="carregando" persistent>
      <carregando
        v-if="carregando == true"
        :corID="'orange-9'"
        :mensagemID="msg"
      ></carregando>
    </q-dialog>

    <!---------------------------------------->
    <q-dialog
      v-model="popup_doc"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-orange-9 text-white">
          Documentos
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange-9 text-white"
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
            <q-tooltip v-if="!maximizedToggle" class="bg-orange-9 text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange-9 text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="q-pt-none">
          <documentos
            v-if="this.cd_romaneio > 0"
            :dados_doc="this.dados_doc"
            :cd_romaneioID="this.icd_romaneio"
            :mostra_canhoto="this.mostra_canhoto"
            :mostra_info="this.mostra_info"
          ></documentos>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!---------------------------------------->
    <q-dialog
      v-model="popup_extrato"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-orange-9 text-white">
          Extrato Motorista
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange-9 text-white"
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
            <q-tooltip v-if="!maximizedToggle" class="bg-orange-9 text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange-9 text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section>
          <extrato :cd_romaneio="cd_romaneio" :cd_parametro="0"></extrato>
        </q-card-section>
      </q-card>
    </q-dialog>

    <!------------------------------------------------->

    <q-dialog
      v-model="pop_roteiro"
      v-show="pop_roteiro"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-orange-9">
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange-9 text-white"
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
            <q-tooltip v-if="!maximizedToggle" class="bg-orange-9 text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange-9 text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="q-pt-none">
          <roteiroEntrega
            :cd_parametroID="2"
            :cd_documentoID="cd_romaneio"
            :cd_tipoRoteiroID="0"
            :romaneioUnico="true"
          />
        </q-card-section>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------------->

    <q-dialog
      v-model="pop_novo_cliente"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-orange-9">
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange-9 text-white"
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
            <q-tooltip v-if="!maximizedToggle" class="bg-orange-9 text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange-9 text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="q-pt-none">
          <cliente
            :cd_cadastro="2"
            :cd_cadastro_c="true"
            ref="cadastro_cliente"
          >
            >
          </cliente>
        </q-card-section>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------->
    <q-dialog
      v-model="pop_cli"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-orange-9">
          <q-space />

          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-orange-9 text-white"
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
            <q-tooltip v-if="!maximizedToggle" class="bg-orange-9 text-white"
              >Maximizar</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-orange-9 text-white">Fechar</q-tooltip>
          </q-btn>
        </q-bar>

        <q-card-section class="q-pt-none">
          <div class="row">
            <div
              class="text-h6 margin1 text-bold col items-start justify-center response"
            >
              Clientes
            </div>
            <div class="margin1 col justify-center response">
              <q-btn
                color="orange-9"
                icon-right="east"
                rounded
                label="Selecionar"
                style="float:right"
                @click="pop_cli = false"
              />
            </div>
          </div>
          <DxDataGrid
            id="grid-padrao"
            class="margin1 borda-bloco"
            key-expr="cd_controle"
            :data-source="grid_cliente"
            :columns="coluna_cli"
            :show-borders="true"
            :column-auto-width="true"
            :column-hiding-enabled="false"
            :selection="{ mode: 'single' }"
            :auto-navigate-to-focused-row="true"
            :hover-state-enabled="true"
            :focused-row-enabled="true"
            :remote-operations="false"
            :word-wrap-enabled="false"
            :allow-column-reordering="true"
            :allow-column-resizing="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            :cacheEnable="false"
            :leftPosition="true"
            @selection-changed="SelecionaCliente"
          >
            <DxColumnChooser :enabled="true" />
            <DxColumnFixing :enabled="true" />
            <DxPaging :page-size="100" />
          </DxDataGrid>
        </q-card-section>
      </q-card>
    </q-dialog>
    <!------------------------------------------------------------------->
    <q-dialog v-model="popup_produtos" style="width:120vw;heigth:100vw">
      <q-card style="width: 700px; max-width: 80vw;border-radius: 20px;">
        <div class="row items-center text-h6 margin1">
          Items
          <q-space />
          <q-btn
            icon="close"
            flat
            round
            color="black"
            clickable
            v-close-popup
          />
        </div>
        <div class="margin1 ">
          <DxDataGrid
            class="margin1 "
            key-expr="cd_controle"
            :data-source="dataSource"
            :columns="coluna_produto"
            :show-borders="true"
            :column-auto-width="true"
            :column-hiding-enabled="false"
            :selection="{ mode: 'single' }"
            :auto-navigate-to-focused-row="true"
            :hover-state-enabled="true"
            :focused-row-enabled="true"
            :remote-operations="false"
            :word-wrap-enabled="false"
            :allow-column-reordering="true"
            :allow-column-resizing="true"
            :row-alternation-enabled="true"
            :repaint-changes-only="true"
            :cacheEnable="false"
            @selection-changed="onSelectionChanged"
          >
            <DxPaging :page-size="10" />
          </DxDataGrid>
        </div>
      </q-card>
    </q-dialog>

    <!-------------------------------------------------------->
    <q-dialog maximized v-model="carregando" persistent>
      <carregando
        v-if="carregando == true"
        :corID="'orange-9'"
        :mensagemID="msg"
      ></carregando>
    </q-dialog>
  </div>
</template>

<script>
import { Loader } from "@googlemaps/js-api-loader";

import Menu from "../http/menu";
import Lookup from "../http/lookup";
import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";
import config from "devextreme/core/config";
import notify from "devextreme/ui/notify";
import Incluir from "../http/incluir_registro";
import funcao from "../http/funcoes-padroes";
import {
  DxDataGrid,
  DxPaging,
  DxEditing,
  DxColumn,
  DxColumnChooser,
  DxColumnFixing,
} from "devextreme-vue/data-grid";
import formataData from "../http/formataData";

export default {
  name: "modelo2Romaneio",
  data() {
    return {
      cd_empresa: localStorage.cd_empresa,
      cd_usuario: localStorage.cd_usuario,
      cd_modulo: localStorage.cd_modulo,
      cd_menu: localStorage.cd_menu,
      cd_api: localStorage.cd_api,
      api: "",
      menu: {},
      tituloMenu: "",
      cd_romaneio: "",
      cd_empresa_faturamento: "",
      target: false,
      cd_motorista: "",
      nm_responsavel: "",
      prioridade: false,
      ocorrencia: "",
      dataset_empresa_faturamento: [],
      hr_entrega: "",
      dt_entrega_romaneio: "",
      cliente: "",
      gridRefNameCarrinho: "grid_carrinho",
      dt_previsao: "",
      nm_documento_responsavel: "",
      chegada: "",
      base: "",
      cd_veiculo: "",
      dataset_veiculo: [],
      hr_previsao: "",
      dataset_motorista: [],
      dataset_base: [],
      dataset_cancelamento: [],
      bg_input2: "",
      bg_input: "",
      roteiroV: false,
      saida: "",
      pesquisa_c: [],
      razao: "",
      cep_temp: "",
      rua_temp: "",
      bairro_temp: "",
      cidade_temp: "",
      estado_temp: "",
      carregando: false,
      msg: "Aguarde...",
      alteracao: false,
      continua: false,
      icd_romaneio: 0,
      produto: "",
      cd_mascara_produto: "",
      popup_produtos: false,
      dataSource: {},
      produto_selecionado: {},
      qt_produto: 1,
      prioridade: false,
      cd_produto: "",
      vl_produto: "",
      mostra_pedido: false,
      motivo_cancelamento: "",
      json_local: [],
      target: false,
      colunas: ["Item", "Descrição", "Volume", "Preço", "Observação"],
      ic_sel_fechamento: false,
      total_compra: 0,
      mostra_menu: true,
      // cd_protocolo: "",
      linha: [],
      vl_unit_produto: "",
      pop_cli: false,
      ic_tipo_item: "",
      Item: "",

      maximizedToggle: true,
      cd_cliente: 0,
      nm_fantasia_cliente: "",
      cep: 0,
      dt_entrega_romaneio: "",
      dt_picker: "",
      dt_faturamento_romaneio: "",
      qt_distancia: "",
      qt_tempo: "",
      pop_motorista: false,
      popup_extrato: false,
      msg: "Aguarde...",
      hr_saida: "",
      dt_saida: "",
      cd_veiculo: "",
      dataset_pagamento: [],
      hr_entrega: "",
      estado_prop: "",
      cidade_prop: "",
      alteracao: false,
      retorno: 0,
      hoje: "",
      cliente: "",
      grid_cliente: {},
      coluna_cli: [
        "Fantasia",
        "Razão_Social",
        "CEP",
        "Endereço",
        "N°",
        "Bairro",
        "Cidade",
        "Estado",
        "País",
        "Estado",
        "Região",
        "Telefone",
        "E-mail",
        "Data Cadastro",
        "CPF/CNPJ",
        "Tipo_Pessoa",
        "Ramo Atividade",
        "Fonte informação",
        "Status",
        "Transportadora",
        "Comunicação",
        "Tipo Mercado",
        "Idioma",
        "Tipo Cliente",
        "Inscestadual",
        "cd_controle",
      ],
      coluna_produto: ["Item", "Código", "Preço", "Descrição"],
      hora_atual: "",
      pop_cadastro_cliente: false,
      cd_prioridade: 0,
      continua: false,
      roteiroV: false,
      ic_roteiro: "N",
      nm_lancamento: "",
      qt_longitude: 0,
      qt_latitude: 0,
      hr_retorno: "",
      dt_retorno: "",

      nm_conferido: "",
      cd_garantido: 0,
      dataset_empresa_faturamento: [],
      cd_empresa_faturamento: "",
      razao: "",
      prop_cli: "",
      carregando: false,
      cep_temp: "",
      rua_temp: "",
      bairro_temp: "",
      cidade_temp: "",
      estado_temp: "",
      cd_tipo_pessoa_temp: 0,
      popup_doc: false,
      pop_roteiro: false,
      ocorrencia: "",
      itinerario: "",
      bg_input: "",
      chegada: "",
      saida: "",
      bg_input2: "",
      ready: false,
      nm_tipo_pessoa_temp: "",
      edit_grid: true,
      mensagem: "Gravar produtos/romaneio",
      dados_doc: {},
      nm_responsavel: "",
      nm_obs_romaneio: "",
      qt_total_romaneio: 0,
      qt_km_saida: 0,
      qt_km_retorno: 0,
      nm_recebido_por: "",
      cd_estado_temp: 0,
      cd_cidade_temp: 0,
      nm_documento_responsavel: "",
      pesquisa_c: {},
      dataset_cidade: [],
      dataset_estado: [],
      cep_pesquisado: [],
      cd_numero_temp: 0,
      load_end: false,
      mostra_canhoto: null,
      mostra_info: null,
      consulta_iti: [],
      pop_novo_cliente: false,
    };
  },
  async created() {
    try {
      this.carregando = true;
      this.menu = await Menu.montarMenu(
        this.cd_empresa,
        this.cd_menu,
        this.cd_api
      ); //'titulo';
      this.tituloMenu = this.menu.nm_menu_titulo;
      this.api = this.menu.nm_identificacao_api;
    } catch (error) {
      this.carregando = false;
    }
    this.carregando = false;
    /*---EMPRESA FATURAMENTO-------------------------------------------------------------------------------------------------*/

    let dados_empresa_faturamento = await Lookup.montarSelect(
      this.cd_empresa,
      5137
    );
    this.dataset_empresa_faturamento = JSON.parse(
      JSON.parse(JSON.stringify(dados_empresa_faturamento.dataset))
    );
    /*---Motorista-------------------------------------------------------------------------------------------------*/
    let dados_motorista = await Lookup.montarSelect(this.cd_empresa, 494);
    this.dataset_motorista = JSON.parse(
      JSON.parse(JSON.stringify(dados_motorista.dataset))
    );
    var filtrado_ativo = this.dataset_motorista.filter((value) => {
      if (value.ic_ativo_motorista == "S") return value;
    });
    this.dataset_motorista = filtrado_ativo.sort(function(a, b) {
      if (a.nm_motorista < b.nm_motorista) return -1;
      return 1;
    });
    /*---Base-------------------------------------------------------------------------------------------------*/

    /*----------------------------------------------------------------------------------------------------*/
    let dados_veiculo = await Lookup.montarSelect(this.cd_empresa, 1273);
    this.dataset_veiculo = JSON.parse(
      JSON.parse(JSON.stringify(dados_veiculo.dataset))
    );
    /*---EMPRESA FATURAMENTO-------------------------------------------------------------------------------------------------*/

    let dados_param = await Lookup.montarSelect(this.cd_empresa, 2369);
    this.parametro_entrega = JSON.parse(
      JSON.parse(JSON.stringify(dados_param.dataset))
    );
    /*---Base-------------------------------------------------------------------------------------------------*/

    let dados_base = await Lookup.montarSelect(this.cd_empresa, 5514);
    this.dataset_base = JSON.parse(
      JSON.parse(JSON.stringify(dados_base.dataset))
    );
    /*---Motivo Cancelamento---------------------------------------------------------------------------------------------*/

    const dados_cancelamento = await Lookup.montarSelect(this.cd_empresa, 5518);
    this.dataset_cancelamento = JSON.parse(
      JSON.parse(JSON.stringify(dados_cancelamento.dataset))
    );
  },
  mounted() {},
  components: {
    carregando: () => import("../components/carregando.vue"),
    cliente: () => import("../views/cliente.vue"),
    documentos: () => import("../views/romaneiodocumento.vue"),
    extrato: () => import("../views/Extrato.vue"),
    roteiroEntrega: () => import("../views/roteiroEntrega.vue"),

    DxDataGrid,
    DxPaging,
    DxEditing,
    DxColumn,
    DxColumnChooser,
    DxColumnFixing,
  },

  computed: {
    grid_carrinho() {
      return this.$refs[this.gridRefNameCarrinho].instance;
    },
  },

  methods: {
    async CalculaDistancia(lat1, lon1, lat2, lon2) {
      if (
        !!lat1 == false ||
        !!lon1 == false ||
        !!lat2 == false ||
        !!lon2 == false
      ) {
        this.qt_distancia = 0;
        this.qt_tempo = 0;
        notify("Distância não encontrada!");
        return;
      }
      this.qt_distancia = 0;
      this.qt_tempo = 0;
      const loader = new Loader({
        apiKey: "AIzaSyDE35BHw4UsWyGAzA4Gimr6pdleTvIbcs8",
        version: "weekly",
      });
      const mapDiv = document.getElementById("mapRomaneio");
      loader.load().then(() => {
        const map = new google.maps.Map(mapDiv, {
          center: { lat: -23.56478844493474, lng: -46.6524688272795 },
          zoom: 8,
        });
        const service = new google.maps.DistanceMatrixService();
        if (
          !!lat1 == false ||
          !!lon1 == false ||
          !!lat2 == false ||
          !!lon2 == false
        ) {
          this.qt_distancia = "";
          this.qt_tempo = "";
          return {
            Cod: 0,
            status: "Localização inválida!",
          };
        } else {
          try {
            const origin = { lat: lat1, lng: lon1 };
            const destination = { lat: lat2, lng: lon2 };
            const request = {
              origins: [origin],
              destinations: [destination],
              travelMode: "DRIVING",
            };
            service.getDistanceMatrix(request).then((response) => {
              if (response.rows[0].elements[0].status == "OK") {
                this.qt_distancia = response.rows[0].elements[0].distance.text;
                this.qt_tempo = response.rows[0].elements[0].duration.text;

                const time = response.rows[0].elements[0].duration.value * 2;

                var hours = Math.floor(time / 3600);
                var minutes = Math.floor((time % 3600) / 60);
                var seconds = time % 60;

                minutes = minutes < 10 ? "0" + minutes : minutes;
                seconds = seconds < 10 ? "0" + seconds : seconds;
                hours = hours < 10 ? "0" + hours : hours;

                if (hours > 0) {
                  this.qt_tempo = hours + " horas e " + minutes + " minutos";
                } else {
                  minutes + " minutos";
                }

                let k = 0;
                const DistanceKm =
                  response.rows[0].elements[0].distance.value * 2;
                if (DistanceKm > 1000) {
                  k = Math.floor(DistanceKm / 1000);
                } else {
                  k = DistanceKm;
                }

                if (DistanceKm > 1000) {
                  this.qt_distancia = k + " Km";
                } else {
                  this.qt_distancia = k + " metros";
                }
              }
            });
          } catch (error) {}
        }
      });
    },

    SelecionaCliente({ selectedRowsData }) {
      const selecionado = selectedRowsData[0];
      this.nm_fantasia_cliente = selecionado.Endereco_Completo;
      this.cep = selecionado.CEP;
      this.cliente = selecionado.Fantasia;
      this.cd_cliente = selecionado.cd_cliente;
      this.razao = selecionado.Razão_Social;
      this.cep_temp = selecionado.CEP;
      this.rua_temp = selecionado.Endereço;
      this.bairro_temp = selecionado.Bairro;
      this.cidade_temp = selecionado.Cidade;
      this.cd_estado_temp = selecionado.cd_estado;
      this.cd_cidade_temp = selecionado.cd_cidade;
      this.estado_temp = selecionado.Estado;
      this.cd_numero_temp = selecionado.Numero;
      this.cd_tipo_pessoa_temp = selecionado.cd_tipo_pessoa;
      this.nm_tipo_pessoa_temp = selecionado.Tipo_Pessoa;
      this.qt_latitude = selecionado.qt_latitude_cliente;
      this.qt_longitude = selecionado.qt_longitude_cliente;
      this.CalculaDistancia(
        this.qt_latitude,
        this.qt_longitude,
        this.base.qt_latitude,
        this.base.qt_longitude
      );
    },
    async ExcluiGarantido() {
      if (this.cd_garantido !== 0) {
        var e = {
          cd_parametro: 12,
          cd_romaneio: this.cd_garantido,
        };
        var excluiu = await Incluir.incluirRegistro(this.api, e);
      }
    },
    async onSelectionChanged({ selectedRowsData }) {
      this.carregando = true;
      this.produto_selecionado = selectedRowsData[0];
      this.produto = this.produto_selecionado.Descrição;
      this.cd_mascara_produto = this.produto_selecionado.Codigo;
      this.cd_produto = this.produto_selecionado.cd_controle;
      this.nm_fantasia_cliente = this.produto_selecionado.Endereco_Completo;
      this.vl_unit_produto = this.vl_unit_produto.replace(",", ".");
      this.ic_tipo_item = this.produto_selecionado.ic_tipo_item;
      this.Item = this.produto_selecionado.Item;

      var num = parseFloat(this.vl_unit_produto);

      this.vl_unit_produto = num.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
      this.qt_produto = 1;
      this.popup_produtos = false;

      await this.onGravaLocal();
      this.carregando = false;
    },
    async EnviarPedido() {
      if (this.alteracao == false) {
        if (this.cd_cliente == 0) {
          notify("Indique um cliente!");
          return;
        } else if (this.json_local.length == 0) {
          notify("Indique ao menos um produto!");
          return;
        } else if (this.cep_temp == "") {
          notify("Endereço de entrega não encontrado!");
          return;
        }

        this.ExcluiGarantido();
        var dt = formataData.formataDataSQL(this.dt_previsao);
        notify("Aguarde...");
        if (this.prioridade == true) {
          this.cd_prioridade = 2;
        } else {
          this.cd_prioridade = 1;
        }
        if (this.cep.includes("-") == true) {
          this.cep = this.cep_temp.replace("-", "");
        }
        const ic_sel_fechamento = "N";

        this.ic_sel_fechamento == true
          ? (ic_sel_fechamento = "S")
          : (ic_sel_fechamento = "N");
        const saida = "";
        if (!!this.dt_saida) {
          saida = formataData.formataDataSQL(this.dt_saida);
        }
        const retorno = "";
        if (!!this.dt_retorno) {
          retorno = formataData.formataDataSQL(this.dt_retorno);
        }
        let c = {
          cd_parametro: 4,
          cd_usuario: this.cd_usuario,
          cd_romaneio: this.cd_romaneio,
          cd_cep: this.cep_temp,
          dt_entrega_romaneio: dt,
          cd_cliente: this.cd_cliente,
          hr_entrega: this.hr_entrega,
          cd_motorista: this.cd_motorista.cd_motorista,
          cd_veiculo: this.cd_veiculo.cd_veiculo,
          cd_empresa: this.cd_empresa,
          cd_prioridade: this.cd_prioridade,
          cd_empresa_faturamento: this.cd_empresa_faturamento.cd_empresa,
          nm_lancamento: this.nm_lancamento,
          nm_obs_romaneio: this.nm_obs_romaneio,
          qt_total_romaneio: this.qt_total_romaneio,
          nm_recebido_por: this.nm_recebido_por,
          nm_conferido: this.nm_conferido,
          cd_motorista: this.cd_motorista.cd_motorista,
          ic_sel_fechamento: ic_sel_fechamento,
          nm_obs_romaneio: this.nm_obs_romaneio,
          cd_motivo_cancelamento: this.motivo_cancelamento
            .cd_motivo_cancelamento,
          dt_saida: saida,
          hr_saida: this.hr_saida,
          qt_km_saida: this.qt_km_saida,
          dt_retorno: retorno,
          hr_retorno: this.hr_retorno,
          cd_base: this.base.cd_base,
          qt_km_retorno: this.qt_km_retorno,
        };
        var capa = await Incluir.incluirRegistro(this.api, c);
        notify(capa[0].Msg);
        this.retorno = capa[0].retorno;
        this.cd_romaneio = this.retorno;
        for (var f = 0; f < this.json_local.length; f++) {
          var g = {
            cd_parametro: 5,
            cd_romaneio: this.retorno,
            cd_item_registro_venda: this.json_local[f].cd_item_registro_venda,
            vl_produto: this.json_local[f].Preço,
            qt_produto: this.json_local[f].Volume,
            cd_produto: this.json_local[f].cd_controle,
            cd_usuario: this.cd_usuario,
            vl_total_romaneio: this.total_compra,
          };
          var insere_itens = await Incluir.incluirRegistro(this.api, g);
          notify(insere_itens[0].Msg);
        }
        this.PesquisaRomaneio();
        this.total_compra = 0;
        var elemento = document.getElementsByName("input-1");
        elemento[0].focus();
      } else if (this.alteracao == true) {
        try {
          // && this.continua == true){
          if (this.cd_cliente == 0) {
            notify("Indique um cliente!");
            return;
          } else if (this.cd_romaneio == "") {
            notify("Indique o romaneio!");
            return;
          }
          this.carregando = true;
          var dt = formataData.formataDataSQL(this.dt_previsao);
          //var dt_ft = formataData.formataDataSQL(this.dt_faturamento_romaneio);
          if (this.prioridade == true) {
            this.cd_prioridade = 2;
          } else {
            this.cd_prioridade = 1;
          }
          if (this.roteiroV == true) {
            this.ic_roteiro = "S";
          } else {
            this.ic_roteiro = "N";
          }
          if (this.cep == 0) {
            this.cep = this.cep_temp.trim();
          }

          if (this.cep.includes("-") == true) {
            this.cep = this.cep.replace("-", "");
          }
          //aqui
          await this.onCalculaTotal();
          let fechamento = "N";
          if (this.ic_sel_fechamento == true) {
            fechamento = "S";
          } else {
            fechamento = "N";
          }

          let saida = "";
          if (!!this.dt_saida) {
            saida = formataData.formataDataSQL(this.dt_saida);
          }
          let retorno = "";
          if (!!this.dt_retorno) {
            retorno = formataData.formataDataSQL(this.dt_retorno);
          }
          var c = {
            cd_parametro: 8,
            cd_usuario: this.cd_usuario,
            cd_romaneio: this.cd_romaneio,
            cd_cep: this.cep,
            dt_entrega_romaneio: dt,
            cd_cliente: this.cd_cliente,
            hr_entrega: this.hr_entrega,
            cd_motorista: this.cd_motorista.cd_motorista,
            cd_veiculo: this.cd_veiculo.cd_veiculo,
            cd_empresa: this.cd_empresa,
            cd_prioridade: this.cd_prioridade,
            ic_roteiro: this.ic_roteiro,
            cd_empresa_faturamento: this.cd_empresa_faturamento.cd_empresa,
            nm_lancamento: this.nm_lancamento,
            nm_obs_romaneio: this.nm_obs_romaneio,
            qt_total_romaneio: this.qt_total_romaneio,
            nm_recebido_por: this.nm_recebido_por,
            nm_conferido: this.nm_conferido,
            hr_previsao: this.hr_previsao,
            cd_motorista: this.cd_motorista.cd_motorista,
            ic_sel_fechamento: fechamento,
            nm_obs_romaneio: this.nm_obs_romaneio,
            cd_motivo_cancelamento: this.motivo_cancelamento
              .cd_motivo_cancelamento,
            dt_saida: saida,
            hr_saida: this.hr_saida,
            qt_km_saida: this.qt_km_saida,
            dt_retorno: retorno,
            hr_retorno: this.hr_retorno,
            qt_km_retorno: this.qt_km_retorno,
            cd_base: this.base.cd_base,
          };

          var capa = await Incluir.incluirRegistro(this.api, c);
          notify(capa[0].Msg);
          await this.grid_carrinho.saveEditData();

          for (let y = 0; y < this.json_local.length; y++) {
            //this.json_local[y].Preço = this.json_local[y].Preço + '';
            if (this.json_local[y].cd_item_romaneio === undefined) {
              this.json_local[y].cd_item_romaneio = 0;
            }

            const ai = {
              cd_parametro: 9,
              cd_romaneio: this.cd_romaneio,
              cd_usuario: this.cd_usuario,
              vl_produto: this.json_local[y].Preço,
              qt_produto: this.json_local[y].Volume,
              cd_produto: this.json_local[y].cd_controle,
              cd_item_romaneio: this.json_local[y].cd_item_romaneio,
              vl_total_romaneio: this.total_compra,
              nm_obs_item_romaneio: this.json_local[y].Observação,
              ic_tipo_item: this.json_local[y].ic_tipo_item,
              Item: this.json_local[y].Item,
            };
            const itens = await Incluir.incluirRegistro(this.api, ai);
            notify(itens[0].Msg);
          }
          await this.limpaLabel();
          this.cd_romaneio = "";
          this.total_compra = 0;
          this.carregando = false;
        } catch (error) {
          this.carregando = false;
        }
      }
    },
    async AbreMapaRomaneio() {
      this.cd_romaneio = parseInt(this.cd_romaneio);
      this.pop_roteiro = true;
    },
    async AlteraProps() {
      this.cd_romaneio = this.cd_romaneioID;
      this.alteracao = true;
      await this.PesquisaRomaneio();

      if (this.alteraEndereco == true) {
        await this.EditaEndereco();
      }
    },
    EditaEndereco() {
      if (this.alteracao == true) {
        this.prop_cli = {
          cd_parametro: 100,
          cd_cep: this.cep_temp,
          cd_cliente: this.cd_cliente,
          cd_numero: this.cd_numero_temp,
          nm_bairro: this.bairro_temp,
          nm_endereco: this.rua_temp,
          nm_fantasia_cliente: this.cliente,
          nm_razao_social_cliente: this.razao,
          cd_tipo_pessoa: this.cd_tipo_pessoa_temp,
          nm_tipo_pessoa: this.nm_tipo_pessoa_temp,
          cd_romaneio: this.cd_romaneio,
        };
        this.estado_prop = {
          cd_estado: this.cd_estado_temp,
          sg_estado: this.estado_temp,
        };
        this.cidade_prop = {
          cd_cidade: this.cd_cidade_temp,
          nm_cidade: this.cidade_temp,
        };
      } else {
      }
      this.pop_cadastro_cliente = true;
    },
    async PesquisaEmpresaFaturamento() {
      var emp = {
        cd_parametro: 15,
      };
      var fat = await Incluir.incluirRegistro(this.api, emp);
      if (fat[0].Cod == 0) {
        return;
      } else {
        this.cd_empresa_faturamento = {
          cd_empresa: fat[0].cd_empresa,
          nm_empresa: fat[0].nm_empresa,
        };
      }
    },
    async limpaLabel() {
      this.dt_saida = "";
      this.dt_retorno = "";
      this.qt_km_retorno = 0;
      this.qt_km_saida = 0;
      this.motivo_cancelamento = "";
      this.hr_retorno = "";
      this.qt_distancia = "";
      this.qt_tempo = "";
      this.hr_saida = "";
      this.qt_latitude = 0;
      this.qt_longitude = 0;
      this.cliente = "";
      this.cd_motorista = "";
      this.cd_veiculo = "";
      this.produto = "";
      this.cd_mascara_produto = "";
      this.produto_selecionado = "";
      this.qt_km_retorno = 0;
      this.qt_km_saida = 0;
      this.qt_produto = 1;
      this.json_local = [];
      this.base = "";
      this.alteracao = false;
      this.hr_previsao = "";
      this.nm_obs_romaneio = "";
      this.nm_fantasia_cliente = "";
      this.cd_cliente = 0;
      this.dt_entrega_romaneio = "";
      this.hr_entrega = "";
      this.prioridade = false;
      this.roteiroV = false;
      this.cd_empresa_faturamento = "";
      this.razao = "";
      this.cep_temp = "";
      this.rua_temp = "";
      this.bairro_temp = "";
      this.cidade_temp = "";
      this.estado_temp = "";
      this.dt_previsao = this.hoje;
      this.qt_total_romaneio = 0;
    },
    async AtualizaEndereco() {
      try {
        this.carregando = true;
        this.prop_cli.cd_estado = this.estado_prop.cd_estado;
        this.prop_cli.cd_cidade = this.cidade_prop.cd_cidade;
        this.prop_cli.nm_razao_social_cliente = this.prop_cli.nm_razao_social_cliente.replace(
          "'",
          ""
        );
        const nv = await Incluir.incluirRegistro(this.api, this.prop_cli);

        this.qt_latitude = nv[0].qt_latitude_cliente;
        this.qt_longitude = nv[0].qt_longitude_cliente;
        this.cep_temp = this.prop_cli.cd_cep;
        this.rua_temp = this.prop_cli.nm_endereco;
        this.bairro_temp = this.prop_cli.nm_bairro;
        this.cidade_temp = this.cidade_prop.nm_cidade;
        this.estado_temp = this.estado_prop.sg_estado;
        this.cd_numero_temp = this.prop_cli.cd_numero;
        this.carregando = false;
        this.pop_cadastro_cliente = false;
        await this.CalculaDistancia(
          this.qt_latitude,
          this.qt_longitude,
          this.base.qt_latitude,
          this.base.qt_longitude
        );
        notify(nv[0].Msg);
      } catch (error) {
        this.carregando = false;
      }
    },
    async onBuscaCep() {
      try {
        this.load_end = true;
        const busca = await funcao.buscaCep(this.prop_cli.cd_cep);
        this.prop_cli.nm_bairro = busca[0].bairro;
        this.prop_cli.nm_endereco = busca[0].logradouro;
        this.cidade_prop = {
          cd_cidade: busca[0].cd_cidade,
          nm_cidade: busca[0].localidade,
        };
        this.estado_prop = {
          cd_estado: busca[0].cd_estado,
          sg_estado: busca[0].uf,
        };
        this.load_end = false;
      } catch (error) {
        this.load_end = false;
      }
    },
    async ExcluirProduto(e) {
      var cd_item = e.data.cd_item_romaneio;
      if (cd_item === undefined) {
        cd_item = 0;
      }
      if (cd_item != 0) {
        var key_exclusao = e.key;
        const del = {
          cd_parametro: 7,
          cd_romaneio: this.cd_romaneio,
          cd_produto: key_exclusao,
          cd_item_romaneio: cd_item,
        };
        var excluiu = await Incluir.incluirRegistro(this.api, del);
        notify(excluiu[0].Msg);
      } else {
        notify("Item não encontrado!");
      }
      await this.onCalculaTotal();
    },
    async AtualizaItem(e) {
      var it = e.data.cd_item_romaneio;
      if (it == undefined) {
        it = 0;
      }
      var valor = e.data.Preço;

      if (it != 0) {
        var i = {
          cd_parametro: 9,
          cd_produto: e.data.cd_controle,
          qt_produto: e.data.Volume,
          vl_produto: valor,
          cd_item_romaneio: e.data.cd_item_romaneio,
          cd_romaneio: this.cd_romaneio,
          cd_usuario: this.cd_usuario,
          nm_obs_item_romaneio: e.data.Observação,
        };
        var atualizado = await Incluir.incluirRegistro(this.api, i);
        //notify(atualizado[0].Msg)

        this.PesquisaRomaneio();
      }
      await this.onCalculaTotal();

      //notify('Item atualizado')
    },
    async PesquisarServico() {
      if (this.produto == "") {
        return;
      }
      try {
        this.carregando = true;
        var pesquisa = {
          cd_parametro: 2,
          nm_produto: this.produto,
          cd_mascara_produto: this.cd_mascara_produto,
        };
        this.dataSource = await Incluir.incluirRegistro(this.api, pesquisa);
        if (this.dataSource[0].Cod == 0) {
          notify(this.dataSource[0].Msg);
          this.carregando = false;
          return;
        } else if (this.dataSource.length == 1) {
          this.produto = this.dataSource[0].Descrição;
          this.cd_mascara_produto = this.dataSource[0].Codigo;
          this.cd_produto = this.dataSource[0].cd_controle;
          this.vl_produto = this.dataSource[0].Preço;
          this.vl_unit_produto = this.dataSource[0].Preço;
          //this.vl_unit_produto = this.vl_unit_produto.replace(",",".")
          var num = parseFloat(this.vl_unit_produto);
          this.vl_unit_produto = num.toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          });
          this.carregando = false;
          this.qt_produto = 1;
          notify("Pesquisa concluída");
          this.onGravaLocal();
          return;
        }

        this.popup_produtos = true;
        this.carregando = false;
      } catch (error) {
        this.carregando = false;
      }
    },
    async onGravaLocal() {
      if (this.cd_produto == "" || this.produto == "") {
        notify("Pesquise e selecione o produto!");
        return;
      } else if (this.linha == {}) {
        notify("Pesquise o produto!");
        return;
      }

      this.linha = {
        Codigo: this.cd_mascara_produto,
        Descrição: this.produto,
        Preço: this.vl_produto,
        Volume: this.qt_produto,
        cd_controle: this.cd_produto,
        ic_tipo_item: this.ic_tipo_item,
        Item: this.Item,
      };
      if (this.linha.Preço == "") {
        this.linha.Preço = "0";
      }
      if (this.json_local.length === undefined) {
        this.json_local = [];
      }
      this.json_local.unshift(this.linha);

      this.produto = "";

      await this.onCalculaTotal();
      this.vl_produto = "";
      this.linha = {};
      this.cd_produto = "";
      this.ic_tipo_item = "";
      this.Item = "";
    },
    SelectMotorista(e) {
      if (!!e.cd_veiculo == false) return;

      var filtrado = this.dataset_veiculo.filter((value) => {
        if (value.cd_veiculo == e.cd_veiculo) return value;
      });
      if (!!filtrado[0].cd_veiculo == false) return;
      this.cd_veiculo = {
        cd_veiculo: filtrado[0].cd_veiculo,
        nm_veiculo: filtrado[0].nm_veiculo,
      };
    },
    async AbreExtrato() {
      if (this.cd_romaneio == "") {
        notify("Digite o Romaneio!");
      } else {
        this.popup_extrato = true;
      }
    },
    async PesquisaRomaneio() {
      if (this.cd_romaneio == "") {
        return;
      }
      await this.limpaLabel();
      var pesquisa = {
        cd_parametro: 1,
        cd_romaneio: this.cd_romaneio,
      };
      this.msg = "Carregando romaneio...";
      this.carregando = true;

      try {
        this.pesquisa_c = await Incluir.incluirRegistro(this.api, pesquisa);
        if (this.pesquisa_c[0].Cod == 0) {
          this.carregando = false;
          notify(this.pesquisa_c[0].Msg);
          await this.limpaLabel();
          return;
        }
      } catch (error) {
        this.carregando = false;
      }

      if (this.pesquisa_c[0].Cod == 0) {
        this.carregando = false;
        notify(this.pesquisa_c[0].Msg);
        this.alteracao = false;
        this.continua = true;
        return;
      } else {
        this.continua = true;
        this.alteracao = true;
        this.dt_entrega_romaneio = this.pesquisa_c[0].dt_entrega_romaneio;
        this.dt_previsao = this.pesquisa_c[0].dt_entrega;
        this.hr_entrega = this.pesquisa_c[0].hr_entrega;

        if (this.pesquisa_c[0].cd_veiculo != 0) {
          this.cd_veiculo = {
            cd_veiculo: this.pesquisa_c[0].cd_veiculo,
            nm_veiculo: this.pesquisa_c[0].nm_veiculo,
            cd_transportadora: this.pesquisa_c[0].cd_transportadora,
          };
        }
        if (this.pesquisa_c[0].cd_empresa != 0) {
          this.cd_empresa_faturamento = {
            cd_empresa: this.pesquisa_c[0].cd_empresa,
            nm_empresa: this.pesquisa_c[0].nm_empresa,
          };
        }
        if (this.pesquisa_c[0].cd_motorista != 0) {
          this.cd_motorista = {
            cd_motorista: this.pesquisa_c[0].cd_motorista,
            nm_motorista: this.pesquisa_c[0].nm_motorista,
          };
        }
        if (!!this.pesquisa_c[0].cd_base) {
          this.base = {
            cd_base: this.pesquisa_c[0].cd_base,
            nm_base: this.pesquisa_c[0].nm_base,
            qt_latitude: this.pesquisa_c[0].qt_latitude_base,
            qt_longitude: this.pesquisa_c[0].qt_longitude_base,
          };
        }
        if (this.pesquisa_c[0].ic_sel_fechamento == "S") {
          this.ic_sel_fechamento = true;
        } else {
          this.ic_sel_fechamento = false;
        }

        if (!!this.pesquisa_c[0].cd_motivo_cancelamento) {
          this.motivo_cancelamento = {
            cd_motivo_cancelamento: this.pesquisa_c[0].cd_motivo_cancelamento,
            nm_motivo_cancelamento: this.pesquisa_c[0].nm_motivo_cancelamento,
          };
        }
        this.icd_romaneio = this.pesquisa_c[0].cd_romaneio;
        this.razao = this.pesquisa_c[0].nm_razao_social_cliente;
        this.cep_temp = this.pesquisa_c[0].cd_cep;
        this.rua_temp = this.pesquisa_c[0].nm_endereco;
        this.bairro_temp = this.pesquisa_c[0].nm_bairro;
        this.cidade_temp = this.pesquisa_c[0].nm_cidade;
        this.estado_temp = this.pesquisa_c[0].sg_estado;
        this.chegada = this.pesquisa_c[0].chegada;
        this.cd_cidade_temp = this.pesquisa_c[0].cd_cidade;
        this.cd_estado_temp = this.pesquisa_c[0].cd_estado;
        this.cd_numero_temp = this.pesquisa_c[0].cd_numero;
        this.qt_longitude = this.pesquisa_c[0].qt_longitude;
        this.qt_latitude = this.pesquisa_c[0].qt_latitude;
        this.saida = this.pesquisa_c[0].saida;
        this.itineario = this.pesquisa_c[0].nm_itinerario;
        this.dt_saida = this.pesquisa_c[0].dt_saida;
        this.hr_saida = this.pesquisa_c[0].hr_saida;
        this.dt_retorno = this.pesquisa_c[0].dt_retorno;
        this.hr_retorno = this.pesquisa_c[0].hr_retorno;
        this.dados_doc = this.pesquisa_c[0];
        this.nm_responsavel = this.pesquisa_c[0].nm_responsavel;
        this.nm_documento_responsavel = this.pesquisa_c[0].nm_documento_responsavel;
        this.hr_previsao = this.pesquisa_c[0].hr_previsao;
        //  this.cd_protocolo = this.pesquisa_c[0].cd_protocolo;
        this.nm_obs_romaneio = this.pesquisa_c[0].nm_obs_romaneio;
        this.qt_total_romaneio = this.pesquisa_c[0].qt_total_romaneio;
        this.hr_entrega = this.pesquisa_c[0].hr_entrega;
        this.qt_km_retorno = this.pesquisa_c[0].qt_km_retorno;
        this.qt_km_saida = this.pesquisa_c[0].qt_km_saida;

        if (this.chegada != " | ") {
          this.bg_input2 = "green-4";
        }
        if (this.saida != " | ") {
          this.bg_input = "green-4";
          this.bg_input2 = "";
        }

        if (this.pesquisa_c[0].cd_prioridade == 2) {
          this.prioridade = true;
        } else {
          this.prioridade = false;
        }
        if (this.pesquisa_c[0].ic_roteiro_romaneio == "S") {
          this.roteiroV = true;
        } else {
          this.roteiroV = false;
        }
        this.nm_fantasia_cliente = this.pesquisa_c[0].Endereco_Completo;
        this.cliente = this.pesquisa_c[0].nm_fantasia_cliente;
        this.cd_cliente = this.pesquisa_c[0].cd_cliente;
        const pj = {
          cd_parametro: 6,
          cd_romaneio: this.cd_romaneio,
        };
        this.json_local = await Incluir.incluirRegistro(this.api, pj);
        //Todos os itens dessa tela são na verdade serviços e são salvos no cd_produto
        this.qt_total_romaneio = this.json_local.length;
        await this.onCalculaTotal();

        await this.CalculaDistancia(
          this.qt_latitude,
          this.qt_longitude,
          this.base.qt_latitude,
          this.base.qt_longitude
        );
        this.PesquisaOcorrencia();
        if (this.pesquisa_c[0].saida != " | ") {
          this.ready = true;
          this.edit_grid = false;
          this.mensagem = "Gravar produtos/romaneio";
        } else {
          this.ready = false;
          this.edit_grid = true;

          this.mensagem = "Romaneio já finalizado!";
        }
        this.carregando = false;
      }
      this.CalculaDistancia(
        this.qt_latitude,
        this.qt_longitude,
        this.base.qt_latitude,
        this.base.qt_longitude
      );
      this.carregando = false;
    },
    async PesquisaOcorrencia() {
      var o = {
        cd_parametro: 14,
        cd_romaneio: this.cd_romaneio,
      };
      var ocorrencia = await Incluir.incluirRegistro(this.api, o);
      if (ocorrencia[0].Cod == 0) {
        this.ocorrencia = "";
        return;
      } else {
        this.ocorrencia = ocorrencia[0].nm_ocorrencia;
      }
    },
    async onCalculaTotal() {
      this.total_compra = 0;
      this.qt_total_romaneio = 0;
      //acerta o valor total da compra na label
      for (var a = 0; a < this.json_local.length; a++) {
        let valor = this.json_local[a].Preço + "";

        if (valor.includes(".") == true) {
          valor = valor.replace(".", "");
        }
        if (valor.includes("R$") == true) {
          valor = valor.replace("R$", " ");
        }
        if (valor.includes(",") == true) {
          valor = valor.replace(",", ".");
        }
        if (valor.includes("R$") == true) {
          valor = valor.replace("R$", "");
        }

        valor = parseFloat(valor);
        valor = valor * this.json_local[a].Volume;
        this.total_compra = this.total_compra + valor;
      }
      if (this.total_compra === NaN) {
        this.total_compra = 0;
      }
      this.total_compra = await funcao.FormataValor(this.total_compra);

      //Acerta Itens da grid

      for (let ac = 0; ac < this.json_local.length; ac++) {
        this.json_local[ac].Preço = await funcao.FormataValor(
          this.json_local[ac].Preço
        );
        //let vl_p = this.json_local[ac].Preço;
        //vl_p = vl_p + "";
        //
        //if (vl_p.includes(",") == true) {
        //  vl_p = vl_p.replace(",", ".");
        //}
        //if (vl_p.includes("R$") == true) {
        //  vl_p = vl_p.replace("R$", "");
        //}
        //
        //vl_p = parseFloat(vl_p);
        //this.json_local[ac].Preço = vl_p.toLocaleString("pt-BR", {
        //  style: "currency",
        //  currency: "BRL",
        //});
        //this.qt_total_romaneio =
        //  parseInt(this.qt_total_romaneio) +
        //  parseInt(this.json_local[ac].Volume);
      }
    },
    async novoRomaneio() {
      try {
        this.carregando = true;
        await this.limpaLabel();
        this.total_compra = 0;
        this.cd_romaneio = "";
        var i = {
          cd_parametro: 11,
          cd_usuario: this.cd_usuario,
        };
        var nv = await Incluir.incluirRegistro(this.api, i);
        this.cd_romaneio = nv[0].cd_romaneio;
        this.cd_garantido = nv[0].cd_romaneio;

        notify(nv[0].Msg);
        this.alteracao = true;
        this.carregando = false;
        this.PesquisaEmpresaFaturamento();
      } catch (error) {
        this.carregando = false;
      }
    },
    async PesquisaCliente() {
      if (this.cliente == "") {
        return;
      }
      this.carregando = true;
      var pesq = {
        cd_parametro: 10,
        nm_fantasia_cliente: this.cliente,
      };

      this.grid_cliente = await Incluir.incluirRegistro(this.api, pesq);
      if (this.grid_cliente[0].Cod == 0) {
        notify(this.grid_cliente[0].Msg);
        this.carregando = false;
        return;
      } else if (this.grid_cliente.length == 1) {
        this.cliente = this.grid_cliente[0].Fantasia;
        this.nm_fantasia_cliente = this.grid_cliente[0].Endereco_Completo;
        this.cd_cliente = this.grid_cliente[0].cd_cliente;
        this.razao = this.grid_cliente[0].Razão_Social;
        this.cep_temp = this.grid_cliente[0].CEP;
        this.rua_temp = this.grid_cliente[0].Endereço;
        this.bairro_temp = this.grid_cliente[0].Bairro;
        this.cidade_temp = this.grid_cliente[0].Cidade;
        this.cd_estado_temp = this.grid_cliente[0].cd_estado;
        this.cd_cidade_temp = this.grid_cliente[0].cd_cidade;
        this.estado_temp = this.grid_cliente[0].Estado;
        this.cd_numero_temp = this.grid_cliente[0].Numero;
        this.cd_tipo_pessoa_temp = this.grid_cliente[0].cd_tipo_pessoa;
        this.nm_tipo_pessoa_temp = this.grid_cliente[0].Tipo_Pessoa;

        this.prop_cli = {
          nm_razao_social_cliente: this.grid_cliente[0].Razão_Social,
          nm_fantasia_cliente: this.grid_cliente[0].Fantasia,
          nm_tipo_pessoa: this.grid_cliente[0].Tipo_Pessoa,
          cd_cep: this.grid_cliente[0].CEP,
          cd_numero: this.grid_cliente[0].Numero,
          nm_endereco: this.grid_cliente[0].Endereço,
          nm_bairro: this.grid_cliente[0].Bairro,
          cd_parametro: 101,
          cd_cliente: this.grid_cliente[0].cd_cliente,
        };

        if (this.grid_cliente[0].CEP == "") {
          notify("Endereço não cadastrado...");
        }

        this.qt_produto = 1;
        this.carregando = false;
        notify("Pesquisa concluída");
        return;
      } else {
        this.carregando = false;
        this.pop_cli = true;
      }
    },
    novoCliente() {
      this.pop_novo_cliente = true;
    },
    chamaDoc(d, i) {
      if (d == true && i == true) {
        this.mostra_canhoto = true;
        this.mostra_info = true;
      } else if (d == true && i == false) {
        this.mostra_info = false;
        this.mostra_canhoto = true;
      }
      this.popup_doc = true;
    },
  },
};
</script>

<style scoped>
.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}
.metadeTela {
  width: 47.5%;
}
.metadeTela2 {
  width: 45%;
}

.umTercoTela {
  width: 31%;
}

.umQuartoTela {
  width: 22.5%;
}
.telaInteira {
  width: 100%;
}
#data-pop {
  flex-direction: none !important;
  width: 310px;
  overflow-x: hidden;
}
.borda {
  border-radius: 20px;
  border: 1px solid rgb(201, 201, 201);
  background: white;
}
.button-add {
  width: auto;
  align-items: center center;
  justify-content: center;
}
.qdate {
  width: 310px;
  overflow-x: hidden;
}
#data-pop {
  flex-direction: none !important;
}
.tela-quatro {
  width: 16%;
}
.buttons-sm {
  width: auto;
}
.button-popup {
  margin: 0 2.5px;
}
@media (max-width: 800px) {
  .button-popup {
    margin: 10px;
  }
  .metadeTela2 {
    width: 100%;
  }
  .tela-quatro {
    width: 100%;
  }

  .metadeTela {
    width: 100%;
  }

  .umTercoTela {
    width: 100%;
  }

  .umQuartoTela {
    width: 100%;
  }
  #grid-cliente {
    max-height: 100vh;
  }
  .margin1 {
    margin: 1vh 1vw;
  }
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}

/* Enter and leave animations can use different */
/* durations and timing functions.              */
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
