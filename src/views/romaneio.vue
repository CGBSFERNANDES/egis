<template>
  <div style="margin: 0.8%">
    <div class="text-h6 text-bold margin1">Romaneio</div>

    <div>
      <div class="row items-center">
        <q-input
          class="margin1 col response"
          id="input-1"
          name="input-1"
          @blur="PesquisaRomaneio()"
          item-aligned
          color="orange-9"
          v-model="cd_romaneio"
          type="number"
          label="Romaneio"
        >
          <template v-slot:prepend>
            <q-icon name="bookmark" />
          </template>
        </q-input>
        <div
          class="text-center justify-center self-center items-center margin1"
        >
          <q-btn
            class="margin1"
            color="orange-10"
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
          label="Origem"
          class="margin1 col response"
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

      <div class="borda-bloco shadow-2 margin1">
        <div class="row items-center">
          <q-input
            class="margin1 col-3 response"
            item-aligned
            v-model="cliente"
            color="orange-9"
            type="text"
            @blur="PesquisaCliente()"
            label="Cliente"
          >
            <template v-slot:prepend>
              <q-icon name="person" />
            </template>
            <template v-slot:append>
              <div class="button-add">
                <q-btn
                  round
                  size="sm"
                  class="margin1"
                  color="orange-10"
                  icon="add"
                  @click="novoCliente()"
                />
              </div>
            </template>
          </q-input>
          <div
            v-show="cd_cliente != ''"
            style="display: inline-block"
            class="text-subtitle1 text-bold margin1 text-blue-10 col-auto"
          >
            <q-icon
              class="text-orange-10 margin1 cursor-pointer"
              style="font-size: 1.6em"
              name="badge"
            >
              <q-tooltip transition-show="scale" transition-hide="scale">
                Código
              </q-tooltip>
            </q-icon>
            {{ cd_cliente }}
          </div>
          <div
            v-show="nm_vendedor != ''"
            style="display: inline-block"
            class="text-subtitle1 text-bold margin1 text-blue-10 col-auto"
          >
            <q-icon
              class="text-orange-10 margin1 cursor-pointer"
              style="font-size: 1.6em"
              name="supervisor_account "
            >
              <q-tooltip transition-show="scale" transition-hide="scale">
                Vendedor
              </q-tooltip>
            </q-icon>
            {{ nm_vendedor }}
          </div>

          <div
            v-show="razao != ''"
            style="display: inline-block"
            class="text-subtitle1 text-bold margin1 text-blue-10 col-auto"
          >
            <q-icon
              @click="EditaEndereco"
              class="text-orange-10 margin1 cursor-pointer"
              style="font-size: 1.6em"
              name="mode_edit"
            >
              <q-tooltip transition-show="scale" transition-hide="scale">
                Editar Endereço
              </q-tooltip>
            </q-icon>
            {{ razao }}
          </div>
        </div>
        <div
          v-show="razao != ''"
          style="display: inline-block"
          class="text-subtitle1 text-bold margin1"
        >
          <q-icon
            @click="AbreMapaRomaneio"
            class="text-orange-10 margin1 cursor-pointer"
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
      </div>

      <div class="borda-bloco shadow-2 margin1">
        <div class="row">
          <q-input
            color="orange-9"
            v-model="dt_previsao"
            class="margin1 col response"
            mask="##/##/####"
            label="Data Previsão"
          >
            <template v-slot:prepend>
              <q-icon name="today" />
            </template>
            <template v-slot:append>
              <q-btn
                icon="event"
                color="orange-10"
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
                    color="orange-10"
                    id="data-pop"
                    v-model="dt_picker"
                    @input="FormataPicker()"
                    class="qdate"
                  >
                    <div class="row items-center justify-end">
                      <q-btn
                        v-close-popup
                        round
                        color="orange-10"
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
            class="margin1 col response"
          >
            <template v-slot:append>
              <q-btn
                icon="schedule"
                round
                size="sm"
                color="orange-10"
                class="cursor-pointer"
              >
                <q-popup-proxy
                  cover
                  transition-show="scale"
                  transition-hide="scale"
                >
                  <q-time v-model="hr_previsao" color="orange-10">
                    <div class="row items-center justify-end">
                      <q-btn
                        v-close-popup
                        label="fechar"
                        color="orange-10"
                        flat
                      />
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

        <div class="row">
          <q-input
            color="orange-9"
            v-model="dt_entrega_romaneio"
            class="margin1 col response"
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
            class="margin1 col response"
          >
            <template v-slot:prepend>
              <q-icon name="alarm_on" />
            </template>

            <template v-slot:append>
              <q-icon name="map" class="text-orange-10 cursor-pointer">
                <q-popup-proxy
                  v-model="target"
                  transition-show="flip-up"
                  transition-hide="flip-down"
                >
                  <q-banner
                    class="bg-orange-10 text-white"
                    style="max-width: auto"
                  >
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

          <q-input
            color="orange-9"
            v-model="dt_reentrega"
            class="margin1 col response"
            mask="##/##/####"
            label="Data Reentrega"
          >
            <template v-slot:prepend>
              <q-icon name="assignment_turned_in" />
            </template>
          </q-input>
          <q-input
            color="orange-9"
            v-model="hr_reentrega"
            class="margin1 col response"
            mask="##:##"
            label="Hora Reentrega"
          >
            <template v-slot:prepend>
              <q-icon name="alarm_on" />
            </template>
          </q-input>
        </div>
      </div>

      <div class="borda-bloco shadow-2 margin1 paddingF1">
        <div class="row item-center justify-around response">
          <q-select
            label="Entregador"
            class="margin1 umTercoTela response"
            v-model="cd_entregador"
            input-debounce="0"
            color="orange-9"
            :options="this.dataset_entregador"
            option-value="cd_entregador"
            option-label="nm_entregador"
            @input="SelectEntregador(cd_entregador)"
          >
            <template v-slot:prepend>
              <q-icon name="face" />
            </template>
          </q-select>

          <q-select
            label="Veículo"
            v-model="cd_veiculo"
            id="select-menor"
            class="margin1 umTercoTela response"
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
            class="margin1 umTercoTela response"
            autogrow
            item-aligned
            v-model="ocorrencia"
            type="text"
            color="orange-9"
            label="Ocorrência"
          >
            <template v-slot:prepend>
              <q-icon name="priority_high" />
            </template>
          </q-input>
        </div>

        <div
          v-show="this.mostra_menu == true"
          class="margin1 row justify-evenly"
        >
          <q-checkbox
            v-model="prioridade"
            label="Prioridade"
            class="text-bold check-box-style"
            color="orange-9"
          />

          <q-checkbox
            v-model="roteiroV"
            label="Roteiro"
            class="text-bold check-box-style"
            color="orange-9"
          />

          <q-input
            v-model="chegada"
            readonly
            class="tela-quatro margin1 response"
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
            class="tela-quatro margin1 response"
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
            class="tela-quatro margin1 response"
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
            class="tela-quatro margin1 response"
            autogrow
            color="orange-9"
            type="text"
            label="Documento"
          >
            <template v-slot:prepend>
              <q-icon name="contact_mail" />
            </template>
          </q-input>

          <div class="items-center self-center buttons-sm">
            <q-btn
              @click="chamaDoc(true, true)"
              size="sm"
              class="button-popup"
              color="orange-10"
              icon="picture_as_pdf"
              round
            >
              <q-tooltip transition-show="scale" transition-hide="scale">
                Documentos
              </q-tooltip>
            </q-btn>
          </div>

          <div class="items-center self-center buttons-sm">
            <q-btn
              @click="chamaDoc(true, false)"
              size="sm"
              color="orange-10"
              class="button-popup"
              icon="receipt"
              round
            >
              <q-tooltip transition-show="scale" transition-hide="scale">
                Canhoto
              </q-tooltip>
            </q-btn>
          </div>

          <div class="self-center buttons-sm">
            <q-btn
              @click="AbreExtrato()"
              size="sm"
              color="orange-10"
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

      <div class="borda-bloco shadow-2 margin1">
        <div class="margin1 text-bold text-subtitle1">
          Produtos - Total: {{ total_compra }}
        </div>
        <q-input
          class="margin1"
          filled
          @blur="PesquisarProduto()"
          autogrow
          item-aligned
          v-model="produto"
          type="text"
          color="orange-9"
          label="Produto"
        >
          <template v-slot:prepend>
            <q-icon name="sell" />
          </template>
        </q-input>

        <div class="margin1">
          <DxDataGrid
            class="margin1 shadow-2"
            key-expr="cd_controle"
            :data-source="json_local"
            :columns="colunas"
            :show-borders="true"
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
              style="margin: 0; padding: 0"
              :allow-updating="edit_grid"
              :allow-deleting="edit_grid"
              mode="batch"
            />
            <DxColumn :data-field="colunas[0]" alignment="left" />
            <DxColumn :data-field="colunas[1]" alignment="left" />
            <DxColumn :data-field="colunas[2]" alignment="left" />
            <DxColumn :data-field="colunas[3]" alignment="left" />
            <DxColumn :data-field="colunas[4]" alignment="left" />
            <DxPaging :page-size="10" />
          </DxDataGrid>
        </div>
        <div class="col text-right margin1 response">
          <q-btn
            color="orange-10"
            class="margin1"
            style="float: left"
            label="Gravar"
            rounded
            :disable="ready"
            @click="EnviarPedido()"
          >
            <q-tooltip transition-show="scale" transition-hide="scale">
              {{ mensagem }}
            </q-tooltip>
          </q-btn>

          <q-btn
            class="margin1"
            color="orange-10"
            label="Novo"
            rounded
            @click="novoRomaneio()"
          >
            <q-tooltip transition-show="scale" transition-hide="scale">
              Novo Romaneio
            </q-tooltip>
          </q-btn>
        </div>
      </div>
      <!------------------------------------------------------------------->
      <q-dialog v-model="popup_produtos" style="width: 120vw; height: 100vw">
        <q-card style="width: 120vw; height: 100vw; margin: 2px">
          <q-card-section class="text-h6 margin1">
            <div class="margin1">
              Produtos
              <div style="float: right">
                <q-btn
                  icon="close"
                  dense
                  round
                  color="grey-5"
                  clickable
                  v-close-popup
                />
              </div>
            </div>
            <div></div>
          </q-card-section>
          <q-card-section class="margin1">
            <DxDataGrid
              class="margin1"
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
          </q-card-section>
        </q-card>
      </q-dialog>
    </div>

    <!------------------------------------------------------------->
    <q-dialog
      v-model="pop_cli"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-3">
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
          <div class="row">
            <div
              class="text-h6 margin1 text-bold col items-start justify-center response"
            >
              Clientes
            </div>
            <div class="margin1 col justify-center response">
              <q-btn
                color="orange-8"
                icon-right="east"
                label="Selecionar"
                style="float: right"
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
    <!---------------------------------------------------------->
    <q-dialog
      v-model="pop_cadastro_cliente"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card>
        <q-bar class="bg-deep-orange-3 text-white">
          Endereço
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
          <div class="row borda-bloco shadow-2 margin1">
            <q-input
              class="col response margin1"
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
              class="col response margin1"
              readonly
              v-model="prop_cli.nm_fantasia_cliente"
              type="text"
              label="Fantasia"
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-input>
            <q-input
              class="col response margin1"
              readonly
              v-model="prop_cli.nm_tipo_pessoa"
              type="text"
              label="Tipo Pessoa"
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-input>
          </div>
          <div class="row borda-bloco shadow-2 margin1">
            <q-input
              class="col response margin1"
              v-model="prop_cli.cd_cep"
              mask="#####-###"
              type="text"
              label="CEP"
              @blur="onBuscaCep"
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-input>

            <q-input
              class="col response margin1"
              v-model="prop_cli.cd_numero"
              type="text"
              label="Número"
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-input>

            <q-input
              class="col response margin1"
              :loading="load_end"
              v-model="prop_cli.nm_endereco"
              type="text"
              label="Endereço"
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-input>

            <q-input
              class="col response margin1"
              :loading="load_end"
              v-model="prop_cli.nm_bairro"
              type="text"
              label="Bairro"
            >
              <template v-slot:prepend>
                <q-icon name="person" />
              </template>
            </q-input>
          </div>
          <div class="row borda-bloco shadow-2 margin1">
            <q-select
              label="Cidade"
              class="col response margin1"
              v-model="cidade_prop"
              :loading="load_end"
              input-debounce="0"
              :options="this.dataset_cidade"
              option-value="cd_cidade"
              option-label="nm_cidade"
            >
              <template v-slot:prepend>
                <q-icon name="store" />
              </template>
            </q-select>

            <q-select
              label="Estado"
              :loading="load_end"
              class="col response margin1"
              v-model="estado_prop"
              input-debounce="0"
              :options="this.dataset_estado"
              option-value="cd_estado"
              option-label="sg_estado"
            >
              <template v-slot:prepend>
                <q-icon name="store" />
              </template>
            </q-select>
          </div>
          <div class="row items-end justify-end margin1">
            <q-btn
              color="positive"
              @click="AtualizaEndereco"
              icon="check"
              rounded
              style="float: right"
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
        <q-bar class="bg-deep-orange-3 text-white">
          Documentos
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
          <documentos
            v-if="this.cd_romaneio > 0"
            :dados_doc="this.dados_doc"
            :cd_romaneioID="this.icd_romaneio || this.cd_romaneio"
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
        <q-bar class="bg-deep-orange-3 text-white">
          Extrato Entregador
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
        <q-bar class="bg-deep-orange-3">
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
        <q-bar class="bg-deep-orange-3">
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
  </div>
</template>

<script>
import Incluir from "../http/incluir_registro";
import {
  DxDataGrid,
  DxPaging,
  DxEditing,
  DxColumn,
  DxColumnChooser,
  DxColumnFixing,
} from "devextreme-vue/data-grid";
import notify from "devextreme/ui/notify";
import cliente from "../views/cliente.vue";
import formataData from "../http/formataData";
import grid from "../views/grid";
import Lookup from "../http/lookup";
import Documentos from "../views/romaneiodocumento.vue";
import extrato from "../views/Extrato.vue";
import Procedimento from "../http/procedimento";

export default {
  name: "romaneio",
  components: {
    DxDataGrid,
    DxPaging,
    DxEditing,
    DxColumnChooser,
    DxColumnFixing,
    DxColumn,
    cliente,
    grid,
    Documentos,
    carregando: () => import("../components/carregando.vue"),
    roteiroEntrega: () => import("../views/roteiroEntrega.vue"),
    extrato,
  },
  props: {
    cd_romaneioID: { type: String, default: "" },
    alteraEndereco: { type: Boolean, default: true },
  },
  data() {
    return {
      icd_romaneio: 0,
      cd_romaneio: "",
      produto: "",
      cd_mascara_produto: "",
      api: "612/859", //pr_egisnet_elabora_romaneio
      popup_produtos: false,
      dataSource: {},
      produto_selecionado: {},
      qt_produto: 1,
      prioridade: false,
      hr_pedido: "",
      cd_produto: "",
      vl_produto: "",
      mostra_pedido: false,
      json_local: [],
      target: false,
      colunas: [
        "Código",
        "Descrição",
        "Produto",
        "Quantidade",
        "Preço",
        "Observação",
      ],
      total_compra: 0,
      mostra_menu: true,
      cd_usuario: 0,
      linha: [],
      vl_unit_produto: "",
      pop_cli: false,
      maximizedToggle: true,
      cd_cliente: 0,
      nm_vendedor: "",
      nm_fantasia_cliente: "",
      cep: 0,
      dt_entrega_romaneio: "",
      dt_reentrega: "",
      hr_reentrega: "",
      dt_picker: "",
      dt_faturamento_romaneio: "",
      pop_entregador: false,
      popup_extrato: false,
      cd_entregador: "",
      cd_empresa: 0,
      msg: "Aguarde...",
      cd_veiculo: "",
      dataset_veiculo: [],
      dataset_entregador: [],
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
      coluna_produto: ["Código", "Preço", "Descrição"],
      hora_atual: "",
      pop_cadastro_cliente: false,
      cd_prioridade: 0,
      continua: false,
      roteiroV: false,
      ic_roteiro: "N",
      cd_garantido: 0,
      dataset_empresa_faturamento: [],
      cd_empresa_faturamento: "",
      razao: "",
      prop_cli: "",
      hr_previsao: "",
      dt_previsao: "",
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
    //localStorage.cd_empresa = 194
    var data = new Date();
    var dia = data.getDate();
    var mes = data.getMonth();
    var ano4 = data.getFullYear();
    if (dia < 10) {
      dia = "0" + dia;
    }
    if (mes < 10) {
      mes = mes + 1;
      mes = "0" + mes;
    } else {
      mes + 1;
    }
    this.hoje = dia + "/" + mes + "/" + ano4;
    this.dt_previsao = this.hoje;
    var hora = data.getHours();
    var min = data.getMinutes();
    hora = hora + 2;
    if (hora == 24) {
      hora = "00";
    } else if (hora == 25) {
      hora = "01";
    } else if (hora == 26) {
      hora = "02";
    } else if (hora == "00") {
      hora = "02";
    } else if (min < 10) {
      min = "0" + min;
    }

    if (this.cd_romaneioID != "") {
      this.AlteraProps();
    }
    this.hora_atual = hora + ":" + min;
    this.hr_previsao = this.hora_atual;
    this.cd_usuario = localStorage.cd_usuario;
    this.cd_empresa = localStorage.cd_empresa;
    let dados_cidade = await Lookup.montarSelect(this.cd_empresa, 97);
    this.dataset_cidade = JSON.parse(
      JSON.parse(JSON.stringify(dados_cidade.dataset))
    );
    let dados_estado = await Lookup.montarSelect(this.cd_empresa, 96);
    this.dataset_estado = JSON.parse(
      JSON.parse(JSON.stringify(dados_estado.dataset))
    );

    /*---EMPRESA FATURAMENTO-------------------------------------------------------------------------------------------------*/

    let dados_empresa_faturamento = await Lookup.montarSelect(
      localStorage.cd_empresa,
      5137
    );
    this.dataset_empresa_faturamento = JSON.parse(
      JSON.parse(JSON.stringify(dados_empresa_faturamento.dataset))
    );

    /*---PAGAMENTO-------------------------------------------------------------------------------------------------*/

    let dados_pagamento = await Lookup.montarSelect(this.cd_empresa, 2774);
    this.dataset_pagamento = JSON.parse(
      JSON.parse(JSON.stringify(dados_pagamento.dataset))
    );

    /*---ENTREGADOR-------------------------------------------------------------------------------------------------*/

    let dados_entregador = await Lookup.montarSelect(
      localStorage.cd_empresa,
      240
    );

    /*---VEICULO-------------------------------------------------------------------------------------------------*/

    let dados_veiculo = await Lookup.montarSelect(this.cd_empresa, 1273);
    this.dataset_veiculo = JSON.parse(
      JSON.parse(JSON.stringify(dados_veiculo.dataset))
    );
    //var filtrado_ativo2  = this.dataset_veiculo.filter((value) => {
    //if (value.dt_baixa_veiculo  == null)
    // return value;
    //})[0];
    //this.dataset_veiculo = filtrado_ativo2.sort(function (a,b){
    // if(a.nm_veiculo < b.nm_veiculo) return -1;
    // return 1;
    //});
    this.cd_empresa_faturamento = this.dataset_empresa_faturamento.filter(
      (value) => {
        if (value.ic_padrao_empresa == "S") return value;
      }
    )[0];
    this.dataset_empresa_faturamento = this.dataset_empresa_faturamento.sort(
      function (a, b) {
        if (a.nm_empresa < b.nm_empresa) return -1;
        return 1;
      }
    );

    this.dataset_pagamento = this.dataset_pagamento.sort(function (a, b) {
      if (a.nm_forma_pagamento < b.nm_forma_pagamento) return -1;
      return 1;
    });

    this.dataset_entregador = JSON.parse(
      JSON.parse(JSON.stringify(dados_entregador.dataset))
    );
    var filtrado_ativo = this.dataset_entregador.filter((value) => {
      if (value.ic_ativo_entregador == "S") return value;
    });
    this.dataset_entregador = filtrado_ativo.sort(function (a, b) {
      if (a.nm_entregador < b.nm_entregador) return -1;
      return 1;
    });
  },
  mounted() {},
  async destroyed() {
    this.ExcluiGarantido();
  },

  methods: {
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
    sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },
    AbreConsulta() {
      if (this.consulta_iti[0].Cod == 0 || this.cd_romaneio == "") {
        notify(this.consulta_iti[0].Msg);
        this.target = false;
      }
    },
    async deletaRoteiro() {
      if (this.cd_romaneio == "") {
        notify("Digite o Romaneio");
      }
      let e = {
        cd_parametro: 17,
        cd_romaneio: this.cd_romaneio,
      };
      let exc = await Incluir.incluirRegistro(this.api, e);
      this.target = false;
      this.hr_entrega = "";
      this.dt_entrega_romaneio = "";
      this.dt_previsao = "";
      this.PesquisaRomaneio();
      notify(exc[0].Msg);
    },

    //async FechaConsulta(){
    //    await this.sleep(5000);
    //    this.target = false;
    //},

    async PesquisaRoteiro() {
      if (this.cd_romaneio == "") return;
      let c = {
        cd_parametro: 16,
        cd_romaneio: this.cd_romaneio,
      };
      this.consulta_iti = await Incluir.incluirRegistro(this.api, c);
      if (this.consulta_iti[0].Cod == 0) {
        notify(this.consulta_iti[0].Msg);
        return;
      }
    },
    async PesquisarProduto() {
      if (this.produto == "") {
        return;
      }
      this.carregando = true;
      var pesquisa = {
        cd_parametro: 2,
        nm_produto: this.produto,
        cd_mascara_produto: this.cd_mascara_produto,
      };
      this.dataSource = await Incluir.incluirRegistro(this.api, pesquisa);
      if (this.dataSource[0].Cod == 0) {
        notify("Nenhum produto encontrado...");
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
    },
    onSelectionChanged({ selectedRowsData }) {
      this.carregando = true;
      this.produto_selecionado = selectedRowsData[0];
      this.produto = this.produto_selecionado.Descrição;
      this.cd_mascara_produto = this.produto_selecionado.Codigo;
      this.cd_produto = this.produto_selecionado.cd_controle;
      this.nm_fantasia_cliente = this.produto_selecionado.Endereco_Completo;
      this.vl_unit_produto = this.vl_unit_produto.replace(",", ".");
      var num = parseFloat(this.vl_unit_produto);

      this.vl_unit_produto = num.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
      this.qt_produto = 1;
      this.popup_produtos = false;
      this.onGravaLocal();
      this.carregando = false;
    },
    limpaLabel() {
      this.cliente = "";
      this.cd_entregador = "";
      this.cd_veiculo = "";
      this.produto = "";
      this.cd_mascara_produto = "";
      this.produto_selecionado = "";
      this.qt_produto = 1;
      this.json_local = [];
      this.alteracao = false;
      this.nm_fantasia_cliente = "";
      this.cd_cliente = 0;
      this.nm_vendedor = "";
      this.dt_entrega_romaneio = "";
      this.dt_reentrega = "";
      this.hr_reentrega = "";
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
    },
    onInsereQuantidade() {
      if (this.qt_produto < 1) {
        this.qt_produto = 1;
        notify("A quantidade minima deve ser de 1 unidade...");
      }
    },
    onGravaLocal() {
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
        Quantidade: this.qt_produto,
        cd_controle: this.cd_produto,
      };
      if (this.linha.Preço == "") {
        this.linha.Preço = "0";
      }
      if (this.json_local.length === undefined) {
        this.json_local = [];
      }
      this.json_local.unshift(this.linha);

      this.produto = "";

      this.onCalculaTotal();
      this.vl_produto = "";
      this.linha = {};
      this.cd_produto = "";
    },

    MostraPedido() {
      this.mostra_pedido = true;
    },

    async EnviarPedido() {
      if (this.alteracao == false) {
        if (this.cd_cliente == 0) {
          notify("Indique um cliente!");
          return;
        }
        //else if(this.cd_entregador == ''){
        //    notify('Selecione o entregador!');
        //    return;
        //}else
        //if(this.cd_veiculo == ''){
        //    notify('Selecione o veiculo!');
        //    return;
        //}
        else if (this.json_local.length == 0) {
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
        var c = {
          cd_parametro: 4,
          cd_usuario: this.cd_usuario,
          cd_romaneio: this.cd_romaneio,
          cd_cep: this.cep_temp,
          dt_entrega_romaneio: dt,
          cd_cliente: this.cd_cliente,
          //    "ds_romaneio"             : this.ds_romaneio,
          hr_entrega: this.hr_entrega,
          //    "dt_faturamento_romaneio" : dt_ft,
          cd_entregador: this.cd_entregador.cd_entregador,
          cd_veiculo: this.cd_veiculo.cd_veiculo,
          //    "cd_forma_pagamento"      : this.cd_pagamento.cd_forma_pagamento,
          dt_reentrega: this.dt_reentrega,
          hr_reentrega: this.hr_reentrega,
          cd_empresa: this.cd_empresa,
          cd_prioridade: this.cd_prioridade,
          cd_empresa_faturamento: this.cd_empresa_faturamento.cd_empresa,
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
            qt_produto: this.json_local[f].Quantidade,
            cd_produto: this.json_local[f].cd_controle,
            dt_reentrega: this.dt_reentrega,
            hr_reentrega: this.hr_reentrega,
            //    "hr_pedido"              : this.json_local[f].hr_pedido,
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
      }
      //else if(this.continua == false){
      //    notify('Romaneio inexistente!');
      //    return;
      //}
      else if (this.alteracao == true) {
        // && this.continua == true){
        if (this.cd_cliente == 0) {
          notify("Indique um cliente!");
          return;
        } else if (this.cd_romaneio == "") {
          notify("Indique o romaneio!");
          return;
        }
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
        var c = {
          cd_parametro: 8,
          cd_usuario: this.cd_usuario,
          cd_romaneio: this.cd_romaneio,
          cd_cep: this.cep,
          dt_entrega_romaneio: dt,
          cd_cliente: this.cd_cliente,
          //    "ds_romaneio"             : this.ds_romaneio,
          hr_entrega: this.hr_entrega,
          //     "dt_faturamento_romaneio" : dt_ft,
          cd_entregador: this.cd_entregador.cd_entregador,
          cd_veiculo: this.cd_veiculo.cd_veiculo,
          //    "cd_forma_pagamento"      : this.cd_pagamento.cd_forma_pagamento,
          dt_reentrega: this.dt_reentrega,
          hr_reentrega: this.hr_reentrega,
          cd_empresa: this.cd_empresa,
          cd_prioridade: this.cd_prioridade,
          ic_roteiro: this.ic_roteiro,
          cd_empresa_faturamento: this.cd_empresa_faturamento.cd_empresa,
        };
        var capa = await Incluir.incluirRegistro(this.api, c);
        notify(capa[0].Msg);

        for (let y = 0; y < this.json_local.length; y++) {
          //this.json_local[y].Preço = this.json_local[y].Preço + '';
          if (this.json_local[y].cd_item_romaneio === undefined) {
            this.json_local[y].cd_item_romaneio = 0;
          }
          //if(this.json_local[y].Preço.includes("R$") == true){
          //    this.json_local[y].Preço = this.json_local[y].Preço.replace("R$","")
          //}
          //if(this.json_local[y].Preço.includes(",") == true){
          //    this.json_local[y].Preço = this.json_local[y].Preço.replace(",",".")
          //}
          var ai = {
            cd_parametro: 9,
            cd_romaneio: this.cd_romaneio,
            cd_usuario: this.cd_usuario,
            vl_produto: this.json_local[y].Preço,
            qt_produto: this.json_local[y].Quantidade,
            cd_produto: this.json_local[y].cd_controle,
            cd_item_romaneio: this.json_local[y].cd_item_romaneio,
            vl_total_romaneio: this.total_compra,
            nm_obs_item_romaneio: this.json_local[y].Observação,
          };
          var itens = await Incluir.incluirRegistro(this.api, ai);
          notify(itens[0].Msg);
        }
        this.limpaLabel();
        this.cd_romaneio = "";
        this.total_compra = 0;
        var elemento = document.getElementsByName("input-1");
        elemento[0].focus();
        //document.getElementsByName("input-1").focus()
      }
    },
    onCalculaTotal() {
      this.total_compra = 0;
      //acerta o valor total da compra na label
      for (var a = 0; a < this.json_local.length; a++) {
        let valor = this.json_local[a].Preço + "";

        //if(valor.includes(".") == true){
        //   valor = valor.replace(".","")
        //
        //}
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
        valor = valor * this.json_local[a].Quantidade;
        this.total_compra = this.total_compra + valor;
      }
      this.total_compra = this.total_compra.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
      //tratamento de erro
      if (this.total_compra === NaN) {
        this.total_compra = 0;
      }
      //Acerta Itens da grid

      for (let ac = 0; ac < this.json_local.length; ac++) {
        let vl_p = this.json_local[ac].Preço;
        vl_p = vl_p + "";

        //if(vl_p.includes(".")==true){
        //    vl_p = vl_p.replace(".","")
        //}
        if (vl_p.includes(",") == true) {
          vl_p = vl_p.replace(",", ".");
        }
        if (vl_p.includes("R$") == true) {
          vl_p = vl_p.replace("R$", "");
        }

        vl_p = parseFloat(vl_p);
        this.json_local[ac].Preço = vl_p.toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
      }
    },
    async PesquisaRomaneio() {
      if (this.cd_romaneio == "") {
        return;
      }
      //notify('Aguarde...')
      //this.limpaLabel();
      var pesquisa = {
        cd_parametro: 1,
        cd_romaneio: this.cd_romaneio,
      };
      this.msg = "Carregando romaneio...";
      this.carregando = true;
      try {
        this.pesquisa_c = await Incluir.incluirRegistro(this.api, pesquisa);
      } catch (error) {
        this.carregando = false;
      }
      this.carregando = false;
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
        //this.dt_entrega_romaneio = formataData.formataDataJS(this.pesquisa_c[0].dt_entrega_romaneio);
        this.hr_entrega = this.pesquisa_c[0].hr_entrega;
        // this.dt_faturamento_romaneio = formataData.formataDataJS(this.pesquisa_c[0].dt_faturamento_romaneio);
        //    this.ds_romaneio = this.pesquisa_c[0].ds_romaneio;

        if (
          this.pesquisa_c[0].cd_veiculo &&
          this.pesquisa_c[0].cd_veiculo != 0
        ) {
          const veiculo = this.dataset_veiculo.find(
            (v) => v.cd_veiculo == this.pesquisa_c[0].cd_veiculo
          );
          if (veiculo) {
            this.cd_veiculo = veiculo;
          }
        }
        if (
          this.pesquisa_c[0].cd_empresa &&
          this.pesquisa_c[0].cd_empresa != 0
        ) {
          this.cd_empresa_faturamento = {
            cd_empresa: 0,
            nm_empresa: "",
          };
          this.cd_empresa_faturamento.cd_empresa =
            this.pesquisa_c[0].cd_empresa;
          this.cd_empresa_faturamento.nm_empresa =
            this.pesquisa_c[0].nm_empresa;
        }
        if (
          this.pesquisa_c[0].cd_entregador &&
          this.pesquisa_c[0].cd_entregador != 0
        ) {
          [this.cd_entregador] = this.dataset_entregador.filter((value) => {
            if (value.cd_entregador == this.pesquisa_c[0].cd_entregador)
              return value;
          });
          this.SelectEntregador(this.cd_entregador);
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
        this.saida = this.pesquisa_c[0].saida;
        this.itineario = this.pesquisa_c[0].nm_itinerario;
        this.dados_doc = this.pesquisa_c[0];
        this.nm_responsavel = this.pesquisa_c[0].nm_responsavel;
        this.nm_documento_responsavel =
          this.pesquisa_c[0].nm_documento_responsavel;
        if (this.chegada != " | ") {
          this.bg_input2 = "green-4";
        }
        if (this.saida != " | ") {
          this.bg_input = "green-4";
          this.bg_input2 = "";
        }

        if (
          this.pesquisa_c[0].cd_prioridade &&
          this.pesquisa_c[0].cd_prioridade == 2
        ) {
          this.prioridade = true;
        } else {
          this.prioridade = false;
        }
        if (
          this.pesquisa_c[0].ic_roteiro_romaneio &&
          this.pesquisa_c[0].ic_roteiro_romaneio == "S"
        ) {
          this.roteiroV = true;
        } else {
          this.roteiroV = false;
        }
        this.nm_fantasia_cliente = this.pesquisa_c[0].Endereco_Completo;
        this.cliente = this.pesquisa_c[0].nm_fantasia_cliente;
        this.cd_cliente = this.pesquisa_c[0].cd_cliente;
        this.nm_vendedor = this.pesquisa_c[0].nm_vendedor;
        var pj = {
          cd_parametro: 6,
          cd_romaneio: this.cd_romaneio,
        };
        this.json_local = await Incluir.incluirRegistro(this.api, pj);
        this.onCalculaTotal();
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
        //notify('Pesquisa concluída!');
        //this.PesquisaRoteiro();
      }
      this.carregando = false;
    },

    async ExcluirProduto(e) {
      var cd_item = e.data.cd_item_romaneio;
      if (cd_item === undefined) {
        cd_item = 0;
      }
      if (cd_item != 0) {
        var key_exclusao = e.key;
        var del = {
          cd_parametro: 7,
          cd_romaneio: this.cd_romaneio,
          cd_produto: key_exclusao,
          cd_item_romaneio: cd_item,
        };
        var excluiu = await Incluir.incluirRegistro(this.api, del);
        notify(excluiu[0].Msg);
      } else {
        notify("Produto Excluído");
      }
      this.onCalculaTotal();
    },

    SelecionaCliente({ selectedRowsData }) {
      var selecionado = selectedRowsData[0];
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
    },

    Data(e) {
      var ano = this.dt_picker.substring(0, 4);
      var mes = this.dt_picker.substring(5, 7);
      var dia = this.dt_picker.substring(8, 10);
      e = dia + mes + ano;
      return e;
    },
    FormataPicker() {
      this.dt_previsao = this.Data(this.dt_previsao);
    },
    //FormataFaturamento(){
    //    this.dt_faturamento_romaneio = this.Data(this.dt_faturamento_romaneio)
    //},
    SelecionaEntregador() {
      var line = grid.Selecionada();
      (this.entregador.cd_entregador = line.cd_entregador),
        (this.entregador.nm_entregador = line.nm_entregador),
        (this.pop_entregador = false);
    },
    async AtualizaItem(e) {
      var it = e.data.cd_item_romaneio;
      if (it == undefined) {
        it = 0;
      }
      var valor = e.data.Preço;
      //let ver = valor.includes("R$")
      //if(ver == true){
      //    valor = valor.replace("R$"," ");
      //    valor = valor.replace(",",".")
      //}

      if (it != 0) {
        var i = {
          cd_parametro: 9,
          cd_produto: e.data.cd_controle,
          qt_produto: e.data.Quantidade,
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
      this.onCalculaTotal();

      //notify('Item atualizado')
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
    async novoRomaneio() {
      this.carregando = true;
      this.limpaLabel();
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
      return;
    },
    SelectEntregador(e) {
      var [filtrado] = this.dataset_veiculo.filter((value) => {
        if (value.cd_veiculo == e.cd_veiculo) return value;
      });
      this.cd_veiculo = filtrado;
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
    async ExcluiGarantido() {
      if (this.cd_garantido !== 0) {
        var e = {
          cd_parametro: 12,
          cd_romaneio: this.cd_garantido,
        };
        var excluiu = await Incluir.incluirRegistro(this.api, e);
      }
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
    AbreExtrato() {
      if (this.cd_romaneio == "") {
        notify("Digite o Romaneio!");
      } else {
        this.popup_extrato = true;
      }
    },
    novoCliente() {
      this.pop_novo_cliente = true;
    },
    async AtualizaEndereco() {
      this.prop_cli.cd_estado = this.estado_prop.cd_estado;
      this.prop_cli.cd_cidade = this.cidade_prop.cd_cidade;
      this.prop_cli.nm_razao_social_cliente =
        this.prop_cli.nm_razao_social_cliente.replace("'", "");
      var nv = await Incluir.incluirRegistro(this.api, this.prop_cli);
      notify(nv[0].Msg);

      this.cep_temp = this.prop_cli.cd_cep;
      this.rua_temp = this.prop_cli.nm_endereco;
      this.bairro_temp = this.prop_cli.nm_bairro;
      this.cidade_temp = this.cidade_prop.nm_cidade;
      this.estado_temp = this.estado_prop.sg_estado;
      this.cd_numero_temp = this.prop_cli.cd_numero;

      this.pop_cadastro_cliente = false;
      //this.PesquisaRomaneio();
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
    async onBuscaCep() {
      if (this.prop_cli.cd_cep.includes("-") == true) {
        this.prop_cli.cd_cep = this.prop_cli.cd_cep.replace("-", "");
      }

      localStorage.cd_cep = this.prop_cli.cd_cep;

      this.load_end = true;
      try {
        this.cep_pesquisado = await Procedimento.montarProcedimento(
          localStorage.cd_empresa,
          localStorage.cd_usuario,
          "413/550",
          "/${cd_empresa}/${cd_cep}"
        );
      } catch {}
      if (this.cep_pesquisado != undefined) {
        this.prop_cli.nm_bairro = this.cep_pesquisado[0].bairro;
        this.prop_cli.nm_endereco = this.cep_pesquisado[0].logradouro;

        this.cidade_prop = {
          cd_cidade: this.cep_pesquisado[0].cd_cidade,
          nm_cidade: this.cep_pesquisado[0].localidade,
        };
        this.estado_prop = {
          cd_estado: this.cep_pesquisado[0].cd_estado,
          sg_estado: this.cep_pesquisado[0].uf,
        };
        this.load_end = false;
      } else {
        this.load_end = false;
        notify("CEP não encontrado!");
      }
    },
  },
};
</script>

<style scoped>
.button-add {
  justify-content: center;
  align-items: center;
  width: 10%;
}

.margin1 {
  margin: 0.5vh 0.5vw;
  padding: 0;
}

#grid-padrao {
  max-height: 750px !important;
}

.column {
  height: 20px !important;
}

.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}

.carregando {
  width: 1000px;
  margin: auto;
  overflow: hidden;
}

.retira-scroll {
  width: 400px;
  height: 280px;
  border: none;
  overflow: hidden;
}

.tela-quatro {
  width: 16%;
}

.buttons-sm {
  width: auto;
}

.check-box-style {
  width: auto;
}

.q-menu {
  max-width: none;
}

.button-popup {
  margin: 0 2.5px;
}

@media (max-width: 1145px) {
  .response {
    width: 100% !important;
  }

  .check-box-style {
    width: 48%;
  }

  .button-popup {
    margin: 10px;
  }
}

.no-wrap {
  flex-wrap: wrap !important;
}

#data-pop {
  flex-direction: none !important;
}

.qdate {
  width: 310px;
  overflow-x: hidden;
}

.metadeTela {
  width: 47.5%;
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

@media (max-width: 900px) {
  .button-add {
    justify-content: center;
    align-items: center;
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
</style>
