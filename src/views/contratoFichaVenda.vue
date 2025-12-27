<template>
  <div>
    <h2 class="content-block h2">
      Ficha de venda<b v-if="cd_ficha_venda > 0"> - {{ cd_ficha_venda }}</b>
    </h2>

    <div class="row margin1">
      <div class="col" style="text-align: right" v-if="consulta == 0">
        <!--<q-btn v-if="consulta == 0"  rounded color="orange-10" class="margin1" label="Histórico" @click="historico_pop = true"/>-->
        <q-btn
          v-if="consulta == 0"
          rounded
          color="orange-10"
          class="margin1"
          label="Voltar"
          @click="limpaTudo()"
        />
        <!--<q-btn v-if="consulta == 0 && cd_status_contrato == 7" outline rounded color="primary" label="Finalizar Contrato" @click="fecharContrato()"/>-->
      </div>
    </div>

    <div v-if="consulta == 1" class="margin1">
      <q-btn
        class="margin1"
        label="Novo"
        color="orange-10"
        icon="add"
        @click="onInserir()"
      />
      <q-btn
        class="margin1"
        label="Alterar"
        color="orange-10"
        icon="reply"
        @click="onAlterar()"
      />
      <q-btn
        class="margin1"
        label="Consultar"
        icon="description"
        color="orange-10"
        @click="onConsultar()"
      />
      <q-btn
        size="sm"
        class="margin1"
        color="orange-10"
        icon="content_paste"
        @click="AbreListagem()"
        round
      >
        <q-tooltip transition-show="scale" transition-hide="scale">
          Imprimir
        </q-tooltip>
      </q-btn>

      <grid
        :cd_menuID="7372"
        :cd_apiID="706"
        :cd_parametroID="0"
        :cd_consulta="1"
        :nm_json="consulta_ficha"
        ref="grid_c"
      >
      </grid>
    </div>

    <div v-if="contrato_aprovacao == true">
      <q-dialog v-model="contrato_aprovacao">
        <q-card>
          <q-card-section>
            <div class="q-pa-md">
              <q-card-section class="q-pt-none">
                <div style="font-size=30px">
                  <b>{{ this.msg_aprovacao }}</b>
                </div>
              </q-card-section>
              <q-separator />
              <br />
              <q-btn
                style="margin:5px"
                color="primary"
                icon="check"
                label="OK"
                v-close-popup
              />
            </div>
          </q-card-section>
        </q-card>
      </q-dialog>
    </div>

    <div v-if="sem_documento == true">
      <q-dialog v-model="sem_documento">
        <q-card>
          <q-card-section>
            <div class="q-pa-md">
              <q-card-section class="q-pt-none">
                <div style="font-size=30px">
                  <b>{{ this.msg_sem_documento }}</b>
                </div>
              </q-card-section>
              <q-separator />
              <br />
              <q-btn
                style="margin:5px"
                color="primary"
                icon="check"
                label="OK"
                v-close-popup
              />
            </div>
          </q-card-section>
        </q-card>
      </q-dialog>
    </div>

    <!---------------------------------------->
    <q-dialog
      v-model="popup_ficha_venda"
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

        <q-card-section>
          <listagem :cd_ficha_venda="2249" :cd_parametro="1"></listagem>
        </q-card-section>
      </q-card>
    </q-dialog>
    <!------------------------------------------------->

    <q-step :name="0" title="Dados" icon="settings" :done="step > 0"></q-step>

    <div v-if="consulta == 0">
      <div class="q-pa-md">
        <q-stepper
          v-model="cd_status_contrato"
          ref="stepper"
          color="primary"
          animated
          active-icon="danger"
        >
          <q-step
            v-if="this.cd_status_contrato == 5"
            :name="5"
            title=" Aguardando Solicitação"
          >
          </q-step>

          <q-step
            v-if="this.cd_status_contrato == 6"
            :name="6"
            title=" Aguardando Aprovação"
          >
          </q-step>

          <q-step
            v-if="this.cd_status_contrato == 7"
            :name="7"
            title="Contrato Aprovado"
          >
          </q-step>

          <q-step
            v-if="this.cd_status_contrato == 8"
            :name="8"
            title="Declinado"
          >
          </q-step>

          <q-step v-if="this.cd_status_contrato == 9" :name="9" title="Inativo">
          </q-step>

          <q-step
            v-if="this.cd_status_contrato == 10"
            :name="10"
            title="Efetivado"
          >
          </q-step>
        </q-stepper>
      </div>

      <div class="margin1 borda-bloco shadow-2">
        <div class="row margin1 ">
          <q-input
            class="col-2 margin1"
            v-model="dt_contrato"
            mask="##/##/####"
            label="Data de Contrato"
          >
            <template v-slot:prepend>
              <q-icon name="today" />
            </template>
          </q-input>
          <q-select
            class="col margin1"
            @input="select_imagem()"
            type="date"
            filled
            option-value="cd_empresa_faturamento"
            option-label="nm_fantasia_empresa"
            v-model="empresa_faturamento"
            :options="lookup_dataset_empresa_faturamento"
            label="Empresa Faturamento"
          >
            <template v-slot:prepend>
              <q-icon name="cases" />
            </template>
          </q-select>

          <div
            style="max-height: 80px ;"
            class="col-3 fundo-img items-center self-center"
            v-if="url != ''"
          >
            <img
              class=" items-center self-center"
              v-bind:src="url"
              spinner-color="white"
              style="max-height: 80px; width: auto"
            />
          </div>
        </div>

        <div class="row margin1">
          <q-select
            @input="buscaTabela()"
            class="col margin1"
            filled
            option-value="cd_administradora"
            option-label="nm_administradora"
            v-model="administradora"
            :options="lookup_dataset_administradora"
            label="Administradora"
          >
            <template v-slot:prepend>
              <q-icon name="brightness_auto" />
            </template>
          </q-select>

          <q-select
            @input="buscaEquipe()"
            class="col margin1"
            filled
            option-value="cd_vendedor"
            option-label="nm_fantasia_vendedor"
            v-model="vendedor"
            :options="lookup_dataset_vendedor"
            label="Vendedor"
          >
            <template v-slot:prepend>
              <q-icon name="sell" />
            </template>
            <q-badge color="red" floating>{{ this.equipe }}</q-badge>
          </q-select>

          <q-select
            @input="buscaEquipeCaptacao()"
            class="col margin1"
            filled
            option-value="cd_vendedor"
            option-label="nm_fantasia_vendedor"
            v-model="captacao"
            :options="lookup_dataset_captacao"
            label="Captação"
          >
            <template v-slot:prepend>
              <q-icon name="closed_caption_off" />
            </template>
            <q-badge color="red" floating>{{ this.equipe_captacao }}</q-badge>
          </q-select>

          <q-input
            class="col margin1"
            v-model="cd_id_contrato"
            label="ID Ficha"
          >
            <template v-slot:prepend>
              <q-icon name="dialpad" />
            </template>
          </q-input>
        </div>
      </div>
      <div class="margin1 borda-bloco shadow-2">
        <div class="row items-center margin1">
          <q-select
            class="col margin1"
            filled
            option-value="cd_tipo_pedido"
            option-label="nm_tipo_pedido"
            v-model="nm_tipo_venda"
            :options="lookup_dataset_tipo_pedido"
            label="Tipo de Venda"
          >
            <template v-slot:prepend>
              <q-icon name="format_list_numbered" />
            </template>
          </q-select>

          <div class="margin1 col items-center">
            <q-checkbox v-model="seguro" label="Seguro" />
          </div>

          <q-input
            class="col margin1"
            type="Number"
            v-model="qt_cota_contrato"
            label="Cotas"
          >
            <template v-slot:prepend>
              <q-icon name="pin" />
            </template>
          </q-input>

          <q-input
            class="col margin1"
            type="text"
            v-model="vl_total_contrato"
            @blur="FormataValor(vl_total_contrato, 1, false)"
            label="Valor"
          >
            <template v-slot:prepend>
              <q-icon name="paid" />
            </template>
          </q-input>
        </div>

        <div>
          <DxButton
            v-if="botao_cadastra == true"
            class="margin1"
            :width="120"
            text="Gravar"
            icon="save"
            type="default"
            styling-mode="contained"
            horizontal-alignment="left"
            @click="onClickGravarFicha()"
          />

          <DxButton
            v-if="botao_cadastra_altera == true"
            class="margin1"
            :width="140"
            text="Atualizar"
            icon="pulldown"
            type="default"
            styling-mode="contained"
            horizontal-alignment="left"
            @click="AlterarFichaVenda()"
          />

          <!--<q-btn size="sm" class="margin1" color="orange-10" icon="content_paste"  @click="AbreListagem()" round>
      <q-tooltip transition-show="scale" transition-hide="scale">
        Imprimir
      </q-tooltip>
    </q-btn>-->
        </div>

        <div v-if="carrega_load == true">
          <q-dialog v-model="carrega_load">
            <q-card>
              <div class="q-pa-md">
                <div class="q-gutter-md row">
                  <q-spinner
                    color="primary"
                    size="3em"
                    :thickness="10"
                  ></q-spinner>
                </div>
              </div>
            </q-card>
          </q-dialog>
        </div>

        <div v-if="cliente_nao_encontrado == true">
          <q-dialog v-model="cliente_nao_encontrado">
            <q-card>
              <q-card-section>
                <div class="q-pa-md">
                  <q-card-section class="q-pt-none">
                    <div style="font-size=30px">
                      <h5>
                        <b
                          >Cliente não encontrado, deseja cadastrar um novo
                          cliente ?</b
                        >
                      </h5>
                    </div>
                  </q-card-section>
                  <q-separator />
                  <br />
                  <q-btn
                    outline
                    style="margin:5px"
                    @click="cadastra_cliente()"
                    color="green"
                    icon="check"
                    label="SIM"
                    v-close-popup
                  />
                  <q-btn
                    outline
                    style="margin:5px"
                    color="red"
                    icon="check"
                    label="NÃO"
                    v-close-popup
                  />
                </div>
              </q-card-section>
            </q-card>
          </q-dialog>
        </div>
      </div>
      <div
        class="margin1 shadow-2"
        style="border-radius:5px"
        v-if="cd_ficha_venda > 0"
      >
        <q-stepper
          :header-nav="true"
          v-model="step"
          done-icon="done_all"
          active-icon="touch_app"
          ref="stepper"
          color="orange=10"
          animated
        >
          <q-step :name="1" title="Cliente" icon="settings" :done="step > 1">
            <div class="row">
              <q-input
                class="col margin1"
                v-model="nm_fantasia"
                label="Cliente"
                @blur="cadastrar()"
              >
                <template v-slot:prepend>
                  <q-icon name="account_circle" />
                </template>
                <template v-slot:append>
                  <!--<q-btn round dense flat @click="cadastrar()" icon="search">
                <q-tooltip class="bg-indigo" :offset="[10, 10]">
                  Pesquisar Cliente
                </q-tooltip>
              </q-btn>-->
                </template>
              </q-input>

              <!--<q-btn round dense flat @click="limpaCliente()" icon="close">
            <q-tooltip class="bg-indigo" :offset="[10, 10]">
              Limpar
            </q-tooltip>
          </q-btn>-->

              <q-btn
                @click="cadastra_cliente()"
                flat
                rounded
                color="orange-10"
                icon="add"
              >
                <q-tooltip class="bg-indigo" :offset="[10, 10]">
                  Cadastrar cliente
                </q-tooltip>
              </q-btn>
            </div>

            <cliente
              v-if="cadastro == false && mostra_form_cliente == true"
              :cd_consulta="true"
              :cd_cliente_c="this.cd_cliente_contrato"
              ref="consulta_cliente"
            >
            </cliente>

            <div v-if="consulta_contrato_consorcio == 0">
              <DxButton
                v-if="bt_esconde_prox == 0"
                class="botao botao-gravar-step"
                :width="120"
                icon="save"
                text="Gravar"
                type="default"
                styling-mode="contained"
                horizontal-alignment="left"
                @click="onGravarCliente()"
              />
            </div>
          </q-step>

          <q-step
            :name="2"
            title="Sócios"
            icon="groups"
            :disable="cadastra_socio"
            :done="step > 2"
          >
            <socio
              :cd_contrato="0"
              :cd_cliente_socio="this.cd_cliente_contrato"
              :cadastro="false"
              :cd_indicacaoID="0"
              :cd_ficha_vendaID="this.cd_ficha_venda"
              ref="cadastro_socio"
            >
            </socio>

            <DxButton
              class="botao"
              :width="120"
              text="Gravar"
              icon="save"
              type="default"
              styling-mode="contained"
              horizontal-alignment="left"
              @click="onGravarSocio()"
            />
          </q-step>

          <q-step :name="3" title="Cotas" icon="assignment" :done="step > 3">
            <div>
              <DxButton
                v-if="consulta_contrato_consorcio == 0"
                class="botao"
                :width="250"
                text="Cadastrar/Alterar"
                type="default"
                icon="folder"
                styling-mode="contained"
                horizontal-alignment="left"
                @click="mostraCotas()"
              />

              <div v-if="this.MostraCotas == true">
                <grid
                  :cd_menuID="7093"
                  :cd_apiID="492"
                  :cd_consulta="0"
                  :nm_json="{}"
                  :cd_parametroID="this.cd_ficha_venda"
                  ref="grid_cota"
                />
              </div>
            </div>
          </q-step>

          <template v-slot:navigation>
            <q-stepper-navigation>
              <!--<DxButton
          v-if="bt_esconde_ant == 0"
          class="botao buttons-column"
          :width="120"
          text="Anterior"
          type="default"
          styling-mode="contained"
          horizontal-alignment="left"
          @click="onAnteriorTab(step)"
        />
        <DxButton
          v-if="bt_esconde_prox == 0"
          class="botao buttons-column"
          :width="120"
          text="Próxima"
          type="default"
          styling-mode="contained"
          horizontal-alignment="left"
          @click="onProximaTab(step)"
        />-->
              <DxButton
                v-if="bt_esconde_fim == 0"
                class="botao"
                :width="220"
                text="Solicitar Aprovação"
                type="default"
                styling-mode="contained"
                horizontal-alignment="left"
                @click="onSolicitar()"
              />
            </q-stepper-navigation>
          </template>
        </q-stepper>
      </div>
      <!--<div style="width: 100%; float: right; backgound-color: yellow">
        <DxButton
          class="botao buttons-column"
          :width="120"
          text="Voltar"
          type="default"
          styling-mode="contained"
          horizontal-alignment="right"
          @click="limpaTudo()"
        />

  </div>-->
    </div>

    <div v-if="cadastrar_divisao == true" class="q-pa-md">
      <q-dialog v-model="cadastrar_divisao">
        <q-card>
          <q-card-section class="row margin1">
            <div class="text-h6 items-center">
              Divisão de Venda
            </div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>

          <q-separator />

          <q-card-section>
            <q-input
              class="col"
              v-model="qt_vendedores"
              type="Number"
              label="Quantidade de Vendedores"
            >
              <template v-slot:prepend>
                <q-icon name="format_list_numbered" />
              </template>
            </q-input>

            <div
              class="margin1 row "
              v-for="v in parseInt(qt_vendedores)"
              v-bind:key="v"
            >
              <q-select
                class="input_vendedor_select col self-center"
                outlined
                :name="'nome' + v"
                v-model="cd_vendedor_divisao[v - 1]"
                :options="lookup_dataset_vendedor"
                label="Vendedor"
                option-value="cd_vendedor"
                option-label="nm_vendedor"
                :option-disable="(item) => cd_vendedor_divisao.includes(item)"
              >
              </q-select>
              <DxTextBox
                class="input_vendedor col self-center"
                maxLength="8"
                styling-mode="filled"
                type="Number"
                :value="100 / qt_vendedores"
                @input="formataPorcentagem(v)"
                :name="'pc' + v"
                :placeholder="'Porcentagem'"
              />
            </div>

            <q-btn
              color="orange-9"
              text-color="white"
              label="Cadastrar"
              icon="add"
              @click="onGravaDivisao()"
            />
          </q-card-section>
        </q-card>
      </q-dialog>
    </div>

    <div v-if="cadastrar_cota == true" class="margin1">
      <q-dialog full-width v-model="cadastrar_cota">
        <q-card>
          <q-card-section class="row items-center margin1">
            <div class="text-h6">
              <q-badge align="top" rounded color="orange-10">{{
                qt_cota_contrato
              }}</q-badge
              >Cotas da Ficha - {{ cd_ficha_venda }}
            </div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>

          <q-separator />

          <!--<div class="col-3 margin1">
          <q-input label="Grupo" type="String" v-model="cd_grupo_ficha"/>
        </div>-->
          <div
            v-for="n in parseInt(qt_cota_contrato)"
            v-bind:key="n"
            class="margin1"
          >
            <div class="text-bold">Cota: {{ n }}</div>
            <div class="row">
              <div class="col margin1">
                <b>Cota</b>
                <br />
                <input
                  class=" formata_input"
                  type="String"
                  :name="'cd_cota' + n"
                />
              </div>

              <div class="col margin1">
                <b>Grupo</b>
                <br />
                <input
                  class="formata_input"
                  type="String"
                  :name="'cd_grupo' + n"
                />
              </div>

              <div class="col margin1">
                <b>Prazo</b>
                <br />
                <input
                  class="formata_input"
                  type="String"
                  :name="'qt_prazo' + n"
                />
              </div>

              <div class="col margin1">
                <b>Tabela</b>
                <br />
                <select class="formata_input" :name="'cd_tabela' + n">
                  <optgroup label="Selecione uma tabela">
                    <option
                      v-for="lookup_dataset_tabela in lookup_dataset_tabela"
                      v-bind:value="lookup_dataset_tabela.cd_tabela"
                      v-bind:key="lookup_dataset_tabela.cd_tabela"
                    >
                      {{ lookup_dataset_tabela.nm_tabela }}
                    </option>
                  </optgroup>
                </select>
              </div>

              <div class="col margin1 ">
                <b>Valor</b>
                <br />
                <input
                  class="formata_input"
                  type="money"
                  @blur="blurEventHandler($event)"
                  :name="'vl_cota_contrato' + n"
                />
              </div>
            </div>
            <q-separator class="margin1" />
          </div>
          <q-btn
            class="margin1"
            label="Gravar Cotas"
            color="orange-10"
            icon="save"
            @click="gravarCotas()"
          />
        </q-card>
      </q-dialog>
    </div>

    <div class="q-pa-md" v-if="cli == true">
      <q-dialog v-model="cli">
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <div class="text-h6">Seleção de Clientes</div>
            <q-space />
            <q-btn
              @click="cadastra_cliente()"
              flat
              round
              color="orange"
              icon="add"
            >
              <q-tooltip class="bg-indigo" :offset="[10, 10]">
                Cadastrar cliente
              </q-tooltip>
            </q-btn>
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>
          <q-list bordered>
            <q-item
              v-for="clientes_encontrados in clientes_encontrados"
              :key="clientes_encontrados.cd_controle"
              class="q-my-sm"
              clickable
              v-ripple
            >
              <q-item-section avatar>
                <q-avatar color="deep-orange-6" text-color="white">
                  {{ clientes_encontrados.letra }}
                </q-avatar>
              </q-item-section>

              <q-item-section>
                <q-item-label>{{
                  clientes_encontrados.nm_razao_social
                }}</q-item-label>
              </q-item-section>

              <q-item-section>
                <q-item-label caption lines="1">{{
                  clientes_encontrados.nm_cpf
                }}</q-item-label>
              </q-item-section>

              <q-item-section side>
                <q-btn
                  icon="send"
                  color="deep-orange-6"
                  clickable
                  round
                  @click="selecionaCliente(clientes_encontrados)"
                  v-close-popup
                />
              </q-item-section>
            </q-item>
          </q-list>
        </q-card>
      </q-dialog>
    </div>

    <div v-if="cliente_popup == true" class="margin1">
      <q-dialog full-width v-model="cliente_popup">
        <q-card>
          <div class="row items-center justify-end">
            <q-btn class="margin1" v-close-popup round flat icon="close" />
          </div>
          <div class="margin1">
            <cliente
              :cd_cadastro="2"
              :cd_cadastro_c="true"
              ref="cadastro_cliente"
            >
            </cliente>
          </div>
        </q-card>
      </q-dialog>
    </div>

    <div v-if="desativar_contrato == true">
      <q-dialog v-model="desativar_contrato" full-width>
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <div class="text-h6">Ativação / inativação do Contrato</div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>
          <q-separator />
          <q-card-section class="row items-center">
            <q-icon
              name="report_problem"
              style="font-size: 4.4em;"
              color="negative"
              text-color="white"
            />
            <span class="q-ml-sm"
              >Tem certeza que deseja alterar o status este contrato?</span
            >
          </q-card-section>
          <q-card-section>
            <q-input v-model="nm_justificativa" label="Justificativa" />
          </q-card-section>

          <q-card-actions align="right">
            <q-btn flat label="Cancelar" color="primary" v-close-popup />
            <q-btn
              flat
              label="Confirmar"
              v-if="nm_justificativa != ''"
              color="primary"
              @click="ConfirmarDesativaAtiva"
              v-close-popup
            />
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>

    <div>
      <q-dialog v-model="dif_valor">
        <q-card>
          <q-card-section>
            <div class="text-h6">Diferença Identificada</div>
          </q-card-section>

          <q-card-section class="q-pt-none">
            {{ this.nm_dif_valor }}
          </q-card-section>

          <q-card-actions align="right">
            <q-btn
              v-if="cd_tipo_validacao == 0"
              flat
              label="Continuar mesmo assim"
              @click="
                cd_certeza = true;
                AlterarFichaVenda();
              "
              color="primary"
              v-close-popup
            />
            <q-btn
              v-if="cd_tipo_validacao == 0"
              flat
              label="Alterar Valor"
              color="primary"
              @click="step = 3"
              v-close-popup
            />

            <q-btn
              v-if="cd_tipo_validacao == 1"
              flat
              label="Continuar mesmo assim"
              @click="
                cd_certeza = true;
                gravarCotas();
              "
              color="primary"
              v-close-popup
            />
            <q-btn
              v-if="cd_tipo_validacao == 1"
              flat
              label="Alterar Valor"
              color="primary"
              @click="step = 3"
              v-close-popup
            />
          </q-card-actions>
        </q-card>
      </q-dialog>
    </div>

    <div v-if="historico_pop == true">
      <q-dialog v-model="historico_pop" full-width>
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <div class="text-h6">Movimentação do Contrato</div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>
          <q-separator />
          <div style="margin: 10px">
            <timeline
              :cd_apiID="this.api_timeline"
              :cd_consulta="1"
              :cd_parametroID="this.cd_contrato"
            />
          </div>
        </q-card>
      </q-dialog>
    </div>
  </div>
</template>

<script>
import DxForm, {
  DxGroupItem,
  DxSimpleItem,
  DxButtonItem,
  DxLabel,
  DxRequiredRule,
} from "devextreme-vue/form";

import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import { DxFileUploader } from "devextreme-vue/file-uploader";

import DxTextBox from "devextreme-vue/text-box";
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import DxButton from "devextreme-vue/button";

import Incluir from "../http/incluir_registro";
import Lookup from "../http/lookup";
import { DxSelectBox } from "devextreme-vue/select-box";

import grid from "../views/grid.vue";
import cliente from "../views/cliente.vue";
import socio from "../views/cadastro-socio-majoritario.vue";
import meucomp from "../views/display-for.vue";
import timeline from "../views/timeline.vue";
import listagem from "../views/listagem.vue";
import lookup from "../views/lookup.vue";

import formataData from "../http/formataData";
var dados = [];
var sParametroApi = "";

export default {
  props: {
    prop_form: { type: Object, default: () => ({}) },
  },
  data() {
    return {
      dataSourceConfig: [],
      api_timeline: "522/728",
      dt_inicial: "",
      dt_final: "",
      cd_empresa: 0,
      cd_menu: 0,
      cd_cliente: 0,
      cd_cliente_contrato: 0,
      cd_api: 0,
      api: 0,
      seguro: false,
      propsX: {},
      lookup_dataset_administradora: [],
      lookup_dados_administradora: [],
      cd_administradora: 0,
      lookup_dataset_vendedor: [],
      lookup_dados_vendedor: [],
      cd_vendedor_divisao: [],
      lookup_dataset_captacao: [],
      lookup_dataset_empresa_faturamento: [],
      lookup_dados_empresa_faturamento: [],
      cd_empresa_faturamento: 0,
      lookup_dataset_documento: [],
      lookup_dados_documento: [],
      cd_documento: [],
      lookup_dataset_documento_filtrado: [],
      lookup_dataset_tabela: [],
      cd_tabela: [],
      popup_ficha_venda: false,
      vl_contrato: 0.0,
      vl_total_contrato: "",
      dt_venda: "",
      nm_captura_cliente: "",
      nm_tabela: "",
      cd_grupo: [],
      cd_vendedor: "",
      dt_prazo: "",
      ic_seguro: "N",
      vl_parcela_contrato: 0,
      step: 1,
      bt_esconde_prox: 0,
      bt_esconde_ant: 1,
      bt_esconde_fim: 1,
      bt_esconde_doc: 1,
      url: "",
      cadastro: null,
      cadastro_socio: false,
      api_ficha: "706/1073", //1539 -  pr_egisnet_cadastra_ficha_venda
      qt_parcelas: 0,
      qt_vendedores: 1,
      nm_fantasia: "",
      cd_contrato: "",
      cd_id_contrato: "",
      dt_contrato: "",
      cd_administradora: "",
      cd_equipe: "",
      cd_cota_contrato: "",
      cd_cota: [],
      qt_parcela_contrato: "",
      ic_seguro_contrato: "",
      qt_vendedor_contrato: "",
      vl_credito_contrato: "",
      qt_peso_contrato: "",
      nm_obs_contrato: "",
      dt_venda_consorcio: "",
      qt_prazo_contrato: 0,
      data_consulta: [],
      alteracaoCotas: false,
      qt_cota_contrato: 0,
      vl_cota_contrato: 0,
      pc_cota_contrato: "",
      vl_cota_parcela: "",
      dt_vencimento_cota: "",
      cd_captacao: 0,
      consulta: 1,
      cd_id_contrato: "",
      MostraCotas: false,
      MostraVendedor: false,
      json: {},
      getDoc: [],
      alteracao: 0,
      carrega_load: false,
      cliente_nao_encontrado: false,
      model: 0,
      empresa_faturamento: "",
      administradora: "",
      vendedor: "",
      captacao: "",
      tabela: "",
      mostra_vendedor: false,
      cd_grupo_ficha: "",
      cadastra_parcela: false,
      qt_valor: 0,
      cliente_popup: false,
      cd_tipo_pessoa: 0,
      cadastra_socio: true,
      cadastrar_divisao: false,
      botao_cadastra_altera: false,
      botao_cadastra: true,
      contrato_aprovacao: false,
      msg_aprovacao: "",
      maximizedToggle: true,
      nm_documento: "",
      documento: "",
      sem_documento: false,
      msg_sem_documento: "",
      base64: "",
      mostra_form_cliente: true,
      validado: true,
      todosDocumentos: [],
      documentos_pos_venda: [],
      documento_pos: [],
      documentos_pagamento_venda: [],
      documento_pagamento: [],
      lookup_dataset_tipo_pedido: [],
      lookup_dados_tipo_pedido: [],
      nm_tipo_venda: "",
      lookup_dataset_tipo_pedido_filtrado: [],
      parcelas_contrato: "",
      equipe: "",
      equipe_captacao: "",
      cotas: [],
      cadastrar_cota: false,
      status_contrato: "",
      cd_status_contrato: 0,
      lookup_dataset_pos_venda: [],
      nm_pos_venda: "",
      lookup_dataset_pag: [],
      nm_pag: "",
      cli: false,
      clientes_encontrados: [],
      consulta_contrato_consorcio: 0,
      desativar_contrato: false,
      nm_justificativa: "",
      historico_pop: false,
      dif_valor: false,
      nm_dif_valor: false,
      cd_certeza: false,
      cd_tipo_validacao: null,
      cd_ficha_venda: 0,
      qt_docs: 0,
      ds_documento: "",
      consulta_ficha: {},
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);
    this.cd_empresa = localStorage.cd_empresa;
    this.lookup_dados_vendedor = await Lookup.montarSelect(
      this.cd_empresa,
      141,
    );
    this.lookup_dataset_vendedor = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_dados_vendedor.dataset)),
    );
    var ordenado = this.lookup_dataset_vendedor.sort(function(a, b) {
      if (a.nm_vendedor < b.nm_vendedor) return -1;
      return 1;
    });
    this.lookup_dataset_vendedor = ordenado;
    for (var a = 0; a < parseInt(this.lookup_dataset_vendedor.length); a++) {
      if (this.lookup_dataset_vendedor[a].cd_tipo_vendedor == 4) {
        this.lookup_dataset_captacao[
          this.lookup_dataset_captacao.length
        ] = this.lookup_dataset_vendedor[a];
      }
    }
    this.consulta_ficha = {
      cd_parametro: 0,
      cd_usuario: localStorage.cd_usuario,
    };
    this.propsX = {};
    this.propsX = this.prop_form;
    var a = [1, 2, 3, 4, 5, 6];
    this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();
    this.dt_final = new Date(localStorage.dt_final).toLocaleDateString();
    this.hoje = new Date().toLocaleDateString("pt-br");
    var h = new Date().toLocaleTimeString();
    this.hora = h.substring(0, 5);
    this.lookup_dados_documento = await Lookup.montarSelect(
      this.cd_empresa,
      5263,
    );
    this.lookup_dataset_documento = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_dados_documento.dataset)),
    );
    this.lookup_dados_administradora = await Lookup.montarSelect(
      this.cd_empresa,
      5238,
    );
    this.lookup_dataset_administradora = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_dados_administradora.dataset)),
    );
    this.dados_lookuup_contato = await Lookup.montarSelect(
      localStorage.cd_empresa,
      111,
    );
    this.dataset_lookup_contato = JSON.parse(
      JSON.parse(JSON.stringify(this.dados_lookuup_contato.dataset)),
    );

    this.lookup_dados_empresa_faturamento = await Lookup.montarSelect(
      this.cd_empresa,
      5137,
    );
    this.lookup_dataset_empresa_faturamento = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_dados_empresa_faturamento.dataset)),
    );
    this.lookup_dados_tipo_pedido = await Lookup.montarSelect(
      this.cd_empresa,
      202,
    );
    this.lookup_dataset_tipo_pedido = JSON.parse(
      JSON.parse(JSON.stringify(this.lookup_dados_tipo_pedido.dataset)),
    );
    var cont_pos_venda = 0;
    for (
      cont_pos_venda = 0;
      cont_pos_venda < this.lookup_dataset_documento.length;
      cont_pos_venda++
    ) {
      var id = parseInt(
        this.lookup_dataset_documento[cont_pos_venda].cd_identificacao,
      );
      if (id == 1) {
        this.lookup_dataset_pos_venda[
          this.lookup_dataset_pos_venda.length
        ] = this.lookup_dataset_documento[cont_pos_venda];
      } else if (id == 2) {
        this.lookup_dataset_pag[
          this.lookup_dataset_pag.length
        ] = this.lookup_dataset_documento[cont_pos_venda];
      }
    }
    if (this.propsX.cd_documento != undefined) {
      this.ContinuaAlteracao();
    } else {
      this.carregaDados();
    }
  },
  beforeDestroy() {
    this.propsX = {};
  },

  components: {
    DxButton,
    DxSimpleItem,
    cliente,
    socio,
    DxTextBox,
    DxFileUploader,
    meucomp,
    grid,
    timeline,
    lookup,
    DxSelectBox,
    listagem,
  },
  watch: {
    async cd_cliente_contrato(A, B) {
      this.cadastro = null;
      this.mostra_form_cliente = null;
      await this.sleep(500);
      this.cadastro = false;
      this.mostra_form_cliente = true;
    },
  },
  methods: {
    async sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },
    blurEventHandler: function(e) {
      var valorT = e.target.value;

      if (valorT == "" || valorT == "0") return;
      if (valorT == "" || valorT == "R$ NaN" || valorT == undefined) {
        valorT = 0;
      }
      let valor = valorT;
      if (valor.includes("R$") == true) {
        valor = valor.replace("R$", " ");
      }
      if (valor.includes(",") == true) {
        valor = valor.replace(",", ".");
      }
      valor = parseFloat(valor);
      valorT = valor.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL",
      });
      e.target.value = valorT;
    },

    formataData(data_enviada) {
      var data = data_enviada;

      var dia = data.substring(0, 2);
      var mes = data.substring(3, 5);
      var ano = data.substring(6, 10);

      return mes + "-" + dia + "-" + ano;
    },

    async onClickGravarFicha() {
      if (this.alteracao == true) {
        this.AlterarFichaVenda();
      } else {
        this.GravarFichaVenda();
      }
    },

    //async fecharContrato(){
    //   var api_d = '456/624'
    //    var dados = {
    //      "cd_parametro"          : 11,
    //      "cd_contrato"           : this.cd_contrato,
    //    }
    //    var a = await Incluir.incluirRegistro(api_d, dados)
    //    notify(a[0].Msg);
    //},

    async onConsultar() {
      this.consulta_contrato_consorcio = 1;
      this.contrato_aprovacao = false;
      this.MostraCotas = true;
      this.MostraVendedor = true;
      this.alteracao = true;
      this.botao_cadastra_altera = false;
      this.botao_cadastra = false;

      let ficha = grid.Selecionada().cd_ficha_venda;
      let r = {
        cd_parametro: 0,
        cd_ficha_venda: ficha,
        cd_usuario: localStorage.cd_usuario,
      };

      this.data_consulta = await Incluir.incluirRegistro(this.api_ficha, r);

      this.dt_contrato = this.data_consulta[0].dt_ficha_venda;
      this.qt_cota_contrato = this.data_consulta[0].qt_cota_contrato;
      this.vl_total_contrato = this.data_consulta[0].vl_contrato;
      this.cd_status_contrato = this.data_consulta[0].cd_status_contrato;
      if (
        this.cd_status_contrato == 6 ||
        this.cd_status_contrato == 7 ||
        this.cd_status_contrato == 9 ||
        this.cd_status_contrato == 10
      ) {
        this.consulta_contrato_consorcio = 1;
      }
      this.qt_valor = this.data_consulta.length;

      if (this.data_consulta[0].cd_cliente != null) {
        this.cd_cliente_contrato = this.data_consulta[0].cd_cliente;
        this.cd_tipo_pessoa = this.data_consulta[0].cd_tipo_pessoa;
        if (this.cd_tipo_pessoa == 1) {
          this.cadastra_socio = false;
        } else {
          this.cadastra_socio = true;
        }
      }

      this.consulta = 0;

      var a = this.data_consulta[0].cd_indicador;
      if (a != 0) {
        var index = this.lookup_dataset_vendedor.findIndex(
          (obj) => obj.cd_vendedor == a,
        );

        this.captacao = {
          cd_vendedor: this.lookup_dataset_vendedor[index].cd_vendedor,
          nm_fantasia_vendedor: this.lookup_dataset_vendedor[index]
            .nm_fantasia_vendedor,
        };
      }

      this.administradora = {
        cd_administradora: this.data_consulta[0].cd_administradora,
        nm_administradora: this.data_consulta[0].nm_administradora,
      };

      this.vendedor = {
        cd_vendedor: this.data_consulta[0].cd_vendedor,
        nm_fantasia_vendedor: this.data_consulta[0].nm_vendedor,
      };
      this.empresa_faturamento = {
        cd_empresa: this.data_consulta[0].cd_empresa,
        nm_fantasia_empresa: this.data_consulta[0].nm_fantasia_empresa,
      };
      this.url = this.url =
        "http://www.egisnet.com.br/img/EmpresaFatInter/" +
        this.data_consulta[0].nm_logotipo_empresa;

      this.tabela = {
        cd_tabela: this.data_consulta[0].cd_tabela,
        nm_tabela: this.data_consulta[0].nm_tabela,
      };
      this.nm_tipo_venda = {
        cd_tipo_pedido: this.data_consulta[0].cd_tipo_venda,
        nm_tipo_pedido: this.data_consulta[0].nm_tipo_pedido,
      };

      this.cd_equipe = this.data_consulta[0].cd_equipe;
      this.equipe = this.data_consulta[0].cd_vendedor;

      await this.buscaEquipe();
      this.equipe_captacao = this.captacao.cd_vendedor;
      await this.buscaEquipeCaptacao();
      await this.buscaTabela();
      this.nm_fantasia = this.data_consulta[0].nm_razao_contrato;
      this.cd_tabela = this.data_consulta[0].cd_tabela;
      this.cd_cota_contrato = this.data_consulta[0].cd_cota_contrato;
      this.qt_parcelas = this.data_consulta[0].qt_parcela_contrato;
      this.seguro = this.data_consulta[0].ic_seguro_contrato;
      this.cd_id_contrato = this.data_consulta[0].cd_id_contrato;
      this.status_contrato = this.data_consulta[0].nm_status;
      this.cd_ficha_venda = this.data_consulta[0].cd_ficha_contrato;
      if (this.seguro == "S") {
        this.seguro = true;
      } else {
        this.seguro = false;
      }
      this.qt_vendedor_contrato = this.data_consulta[0].qt_vendedor_contrato;
      this.vl_credito_contrato = this.data_consulta[0].vl_credito_contrato;
      this.qt_peso_contrato = this.data_consulta[0].qt_peso_contrato;
      this.nm_obs_contrato = this.data_consulta[0].nm_obs_contrato;
      this.dt_venda_consorcio = this.data_consulta[0].dt_venda_consorcio;
      this.qt_prazo_contrato = this.data_consulta[0].qt_prazo_contrato;
      this.cd_captacao = this.data_consulta[0].cd_indicador;

      this.vl_parcela_contrato = this.data_consulta[0].vl_parcela_contrato;

      this.empresa_faturamento.cd_empresa_faturamento = this.data_consulta[0].cd_empresa;
      this.cadastro = false;
      var cont = 0;
      for (cont = 0; cont < this.parcelas_contrato.length; cont++) {
        document.getElementsByName(
          "dt_parcela" + cont,
        ).value = this.parcelas_contrato[cont].dt_parc_contrato;
      }
      this.cd_ficha_venda = this.data_consulta[0].cd_ficha_venda;
    },

    async mostraCotas() {
      this.cadastrar_cota = true;
      this.buscaTabela();
      let s = {
        cd_parametro: 3,
        cd_ficha_venda: this.cd_ficha_venda,
        cd_administradora: this.administradora.cd_administradora,
      };
      var dados_cota = await Incluir.incluirRegistro(this.api_ficha, s);
      if (dados_cota[0].Cod == 0) {
        this.alteracaoCotas = false;
        notify(dados_cota[0].Msg);
      } else {
        this.alteracaoCotas = true;
        this.cd_grupo_ficha = dados_cota[0].cd_grupo_contrato;
        let index = 1;
        for (let c = 0; c < parseInt(this.qt_cota_contrato); c++) {
          document.getElementsByName("cd_cota" + index)[0].value =
            dados_cota[c].cd_cota_ficha_venda;
          document.getElementsByName("vl_cota_contrato" + index)[0].value =
            dados_cota[c].vl_cota_ficha_venda;
          document.getElementsByName("cd_grupo" + index)[0].value =
            dados_cota[c].cd_grupo_cota;
          document.getElementsByName("qt_prazo" + index)[0].value =
            dados_cota[c].qt_prazo_cota;
          document.getElementsByName("cd_tabela" + index)[0].value =
            dados_cota[c].cd_tabela;
          this.lookup_dataset_tabela.cd_tabela = dados_cota[c].cd_tabela;

          index++;
        }
      }

      this.carregaDados();
    },

    async GravarFichaVenda() {
      var data_contrato = formataData.formataDataSQL(this.dt_contrato);

      if (data_contrato == "--") {
        data_contrato = formataData.formataDataSQL(this.hoje);
        this.dt_contrato = this.hoje;
      }
      var seguro = "";
      if (this.seguro == true) {
        seguro = "S";
      } else {
        seguro = "N";
      }
      if (this.empresa_faturamento == "") {
        notify("Selecione uma empresa de faturamento");
        return;
      }
      if (this.administradora == "") {
        notify("Selecione uma administradora");
        return;
      }
      if (this.vendedor == "") {
        notify("Selecione um vendedor");
        return;
      }
      if (this.captacao == "") {
        notify("Selecione uma captação");
        return;
      }
      if (this.nm_tipo_venda == "") {
        notify("Selecione um tipo de venda");
        return;
      }

      if (this.qt_cota_contrato == "") {
        notify("Digite a quantidade de cotas");
        return;
      }
      if (this.vl_total_contrato == "") {
        notify("Digite o valor do contrato");
        return;
      }

      let dados = {
        cd_contrato: this.cd_contrato,
        cd_parametro: 1, //Cadastra ficha de Venda
        cd_tipo_venda: this.nm_tipo_venda.cd_tipo_pedido,
        dt_contrato: data_contrato,
        qt_cota_contrato: this.qt_cota_contrato,
        cd_administradora: this.administradora.cd_administradora,
        cd_tabela: this.tabela.cd_tabela,
        cd_vendedor: this.vendedor.cd_vendedor,
        vl_contrato: this.vl_total_contrato,
        cd_indicador: this.captacao.cd_vendedor,
        ic_seguro_contrato: seguro,
        qt_parcela_contrato: this.qt_parcelas,
        qt_prazo_contrato: this.qt_prazo_contrato,
        cd_empresa_fat: this.empresa_faturamento.cd_empresa,
        cd_id_contrato: this.cd_id_contrato,
        cd_usuario: localStorage.cd_usuario,
      };
      this.carrega_load = true;
      let a = await Incluir.incluirRegistro(this.api_ficha, dados);
      notify(a[0].Msg);
      this.cd_ficha_venda = a[0].cd_ficha_venda;
      this.carrega_load = false;
      this.alteracao = true;
    },

    limpaCliente() {
      this.nm_fantasia = "";
      this.cadastrar();
    },

    AbreListagem() {
      //VERIFICA SE TEM FICHA DE VENDA NO ONROWCHANGE
      //SE ESTIVER DENTRO DO ALTERAR OU NOVO ABRIR O MESMO
      this.cd_ficha_venda = 2249;
      this.popup_ficha_venda = true;

      //  if(this.cd_ficha_venda == ''){
      //     notify('Selecione uma Ficha de venda!');
      // }else{
      //     this.popup_ficha_venda = true;
      // }
    },

    async AlterarFichaVenda() {
      if (this.empresa_faturamento == null) {
        this.empresa_faturamento = "";
      }
      if (this.administradora == null) {
        this.administradora = "";
      }
      if (this.vendedor == null) {
        this.vendedor = "";
      }
      if (this.captacao == null) {
        this.captacao = "";
      }
      if (this.nm_tipo_venda == null) {
        this.nm_tipo_venda = "";
      }
      if (this.qt_prazo_contrato == null || this.qt_prazo_contrato <= 0) {
        this.qt_prazo_contrato = "";
      }
      if (this.qt_cota_contrato == null || this.qt_cota_contrato <= 0) {
        this.qt_cota_contrato = "";
      }
      if (this.vl_total_contrato == null || this.vl_total_contrato <= 0) {
        this.vl_total_contrato = "";
      }
      var data_contrato = formataData.formataDataSQL(this.dt_contrato);
      if (data_contrato == "--") {
        data_contrato = formataData.formataDataSQL(this.hoje);
        this.dt_contrato = this.hoje;
      }

      var seguro = "";
      var api_i = "456/624";
      if (this.seguro == true) {
        seguro = "S";
      } else {
        seguro = "N";
      }

      if (this.empresa_faturamento == "") {
        notify("Selecione uma empresa de faturamento");
        return;
      }
      if (this.administradora == "") {
        notify("Selecione uma administradora");
        return;
      }
      if (this.vendedor == "") {
        notify("Selecione um vendedor");
        return;
      }
      if (this.captacao == "") {
        notify("Selecione uma captação");
        return;
      }
      if (this.nm_tipo_venda == "") {
        notify("Selecione um tipo de venda");
        return;
      }

      if (this.qt_cota_contrato == "") {
        notify("Digite a quantidade de cotas");
        return;
      }
      if (this.vl_total_contrato == "") {
        notify("Digite o valor do contrato");
        return;
      }
      var dados = {
        cd_ficha_venda: this.cd_ficha_venda,
        cd_tipo_venda: this.nm_tipo_venda.cd_tipo_pedido,
        cd_parametro: 7,
        dt_contrato: data_contrato,
        cd_administradora: this.administradora.cd_administradora,
        qt_cota_contrato: this.qt_cota_contrato,
        cd_vendedor: this.vendedor.cd_vendedor,
        vl_contrato: this.vl_total_contrato,
        cd_indicador: this.captacao.cd_vendedor,
        ic_seguro_contrato: seguro,
        qt_parcela_contrato: this.qt_parcelas,
        qt_prazo_contrato: this.qt_prazo_contrato,
        cd_empresa: this.empresa_faturamento.cd_empresa,
        cd_id_contrato: this.cd_id_contrato,
        cd_usuario: localStorage.cd_usuario,
        cd_usuario_inclusao: localStorage.cd_usuario,
      };
      var a = await Incluir.incluirRegistro(this.api_ficha, dados);
      notify(a[0].Msg);
    },
    mostra_vendedores() {
      if (this.mostra_vendedor == true) {
        this.mostra_vendedor = false;
      } else {
        this.mostra_vendedor = true;
      }
    },

    formataPorcentagem(v) {
      var formata = document.getElementsByName("pc" + v)[0].value;
      formata = parseInt(formata.replace(/[\D]+/g, ""));
      if (formata > 10000) {
        formata = 10000;
      }
      formata = formata + "";
      formata = formata.replace(/([0-9]{2})$/g, ",$1");
      formata = formata + "%";
      if (formata == NaN + "%") {
        formata = 0;
      }
      document.getElementsByName("pc" + v)[0].value = formata;
      return formata;

      //let valor = document.getElementsByName('pc'+v)[0].value
      //let ver = valor.includes('%')
      //if(ver == false){
      //  valor = `${document.getElementsByName('pc'+v)[0].value.replace(/\s/g, '').toLowerCase()}%`;
      //  document.getElementsByName('pc'+v)[0].value = valor
      //}
    },

    formatarMoeda(vl_total_contrato) {
      // var elemento = vl.toString();
      var valor = this.vl_total_contrato;
      valor = valor + "";
      valor = parseInt(valor.replace(/[\D]+/g, ""));
      valor = valor + "";
      valor = valor.replace(/([0-9]{2})$/g, ",$1");
      if (valor.length > 6) {
        valor = valor.replace(
          /([0-9]{3}),([0-15]{3}),([0-15]{3}),([0-15]{3}),([0-15]{2}$)/g,
          ".$1,$2",
        );
      }
      if (valor == "NaN") {
        valor = "0";
      }

      this.vl_total_contrato = valor;
      return valor;
    },

    async buscaEquipe() {
      var api = "487/690";
      var paramApi = "/${cd_empresa}/${cd_parametro}";

      localStorage.cd_parametro = this.vendedor.cd_vendedor;
      this.equipe = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api,
        paramApi,
      );
      this.equipe = this.equipe[0].nm_equipe;
      localStorage.cd_parametro = 0;
    },

    async buscaEquipeCaptacao() {
      var api = "487/690";
      var paramApi = "/${cd_empresa}/${cd_parametro}";

      localStorage.cd_parametro = this.captacao.cd_vendedor;
      this.equipe_captacao = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api,
        paramApi,
      );
      this.equipe_captacao = this.equipe_captacao[0].nm_equipe;
      localStorage.cd_parametro = 0;
    },
    async enviar_documentos_pag() {
      var api_d = "456/624";

      var i = 0;
      for (i = 0; this.documentos_pagamento_venda.length > i; i++) {
        var dados = {
          cd_ficha_venda: this.cd_ficha_venda,
          cd_item: i + 1,
          cd_parametro: 8,
          cd_contrato: this.cd_contrato,
          nm_contrato_documento: this.documentos_pagamento_venda[i]
            .nm_contrato_documento,
          cd_tipo_documento: this.documentos_pagamento_venda[i]
            .cd_tipo_documento,
          ic_tipo_documento: 2,
        };
        var a = await Incluir.incluirRegistro(api_d, dados);
        if (a[0].status == "E") {
          notify("Erro ao Salvar Documento");
        }
      }
      notify(a[0].Msg);
    },

    async enviar_documentos_pos() {
      var api_d = "456/624";

      var i = 0;
      for (i = 0; this.documentos_pos_venda.length > i; i++) {
        var dados = {
          cd_ficha_venda: this.cd_ficha_venda,
          cd_item: i + 1,
          cd_parametro: 8,
          cd_contrato: this.cd_contrato,
          nm_contrato_documento: this.documentos_pos_venda[i]
            .nm_contrato_documento,
          cd_tipo_documento: this.documentos_pos_venda[i].cd_tipo_documento,
          ic_tipo_documento: 1,
        };
        var a = await Incluir.incluirRegistro(api_d, dados);
        if (a[0].status == "E") {
          notify("Erro ao Salvar Documento");
        }
      }
      notify(a[0].Msg);
    },

    async enviar_documentos() {
      if (this.todosDocumentos.length == 0) {
        this.msg_sem_documento = "Por favor, adicione os documentos!";
        this.sem_documento = true;
        return;
      }
      var api_i = "456/624";
      var i = 0;
      for (i = 0; this.todosDocumentos.length > i; i++) {
        this.todosDocumentos[i].ds_documento = this.ds_documento;
        var dados = {
          cd_ficha_venda: this.cd_ficha_venda,
          cd_item: i + 1,
          cd_parametro: 8,
          cd_contrato: this.cd_contrato,
          cd_tipo_documento: this.todosDocumentos[i].cd_tipo_documento,
          nm_contrato_documento: this.todosDocumentos[i].nm_contrato_documento,
          ds_documento: this.todosDocumentos[i].ds_documento,
          vb_documento: this.todosDocumentos[i].vb_documento,
          ic_tipo_documento: 0,
        };
        var a = await Incluir.incluirRegistro(api_i, dados);
        if (a[0].status == "E") {
          notify("Erro ao Salvar Documento");
          //return a[0].status
        }
      }
      notify(a[0].Msg);

      this.bt_esconde_fim = 0;
    },

    async selecionaCliente(e) {
      this.mostra_form_cliente = false;
      this.cadastro = null;
      this.cd_cliente_contrato = e.cd_cliente;
      this.cd_tipo_pessoa = e.cd_tipo_pessoa;
      this.nm_fantasia = e.Fantasia;
      this.cd_cliente_;
      if (this.cd_tipo_pessoa == 1) {
        this.cadastra_socio = false;
      } else {
        this.cadastra_socio = true;
      }
      var cont = 0;
      for (cont = 0; cont < this.lookup_dataset_documento.length; cont++) {
        if (
          this.lookup_dataset_documento[cont].cd_tipo_pessoa ==
          this.cd_tipo_pessoa
        ) {
          this.lookup_dataset_documento_filtrado[
            this.lookup_dataset_documento_filtrado.length
          ] = this.lookup_dataset_documento[cont];
        }
      }
      this.cadastro = false;
      this.mostra_form_cliente = true;
    },

    async onSolicitar() {
      //var blob = (window.URL || window.webkitURL ).createObjectURL(this.documento)
      //var reader = new FileReader();
      //reader.onload = async function(file){
      //  var src = file.target.result;
      //  this.base64 = src;
      //var valida = await this.enviar_documentos();
      //if(valida == 'V'){

      var api_s = "456/624";
      var dados = {
        cd_ficha_venda: this.cd_ficha_venda,
        cd_parametro: 7,
        cd_contrato: this.cd_contrato,
        cd_tipo_aprovacao: 1,
        cd_item_aprovacao: 1,
        //vb_imagem: this.base64
      };
      //
      this.carrega_load = true;
      var result = await Incluir.incluirRegistro(api_s, dados);
      notify(result[0].Msg);
      this.cd_status_contrato = 6;
      this.carrega_load = false;
      this.limpaTudo();
      //}
      //reader.readAsDataURL(this.documento)
      //}
      //else{
      //  notify('Erro ao enviar os Arquivos')
      //}
    },

    async onExcluir() {
      var api_i = "456/624";
      var contrato = grid.Selecionada().cd_contrato;
      var dados = {
        cd_parametro: 6,
        cd_contrato: contrato,
      };
      var a = await Incluir.incluirRegistro(api_i, dados);
      //await this.$refs.grid_c.CarregaDados();

      notify(a[0].Msg);
    },

    async gravarCotas() {
      this.MostraCotas = false;
      this.validado = false;

      let total = 0;

      let index = 1;
      for (let a = 0; a < parseInt(this.qt_cota_contrato); a++) {
        let vl_cota = document
          .getElementsByName("vl_cota_contrato" + index)[0]
          .value.replace("R$ ", "");
        total =
          parseFloat(total) +
          parseFloat(
            vl_cota
              .replace(".", "")
              .replace(",", ".")
              .replace("R$", ""),
          );
        index++;
      }
      let vl_total_contrato_formatado = parseFloat(
        this.vl_total_contrato
          .replace(".", "")
          .replace(",", ".")
          .replace("R$", ""),
      );

      if (vl_total_contrato_formatado != total) {
        if (this.cd_certeza == false) {
          this.dif_valor = true;
          this.cd_tipo_validacao = 1;
          this.nm_dif_valor =
            "Uma diferença de valor foi identificada entre a as cotas e a Ficha de Venda";
        }
      } else {
        this.cd_certeza = true;
      }
      if (this.cd_certeza == true) {
        this.carrega_load = true;
        let index = 1;
        for (let c = 0; c < parseInt(this.qt_cota_contrato); c++) {
          let cd_cota = document.getElementsByName("cd_cota" + index)[0].value;
          let cd_tabela = document.getElementsByName("cd_tabela" + index)[0]
            .value;
          let vl_cota_contrato = document
            .getElementsByName("vl_cota_contrato" + index)[0]
            .value.replace("R$ ", "");
          let cd_grupo = document.getElementsByName("cd_grupo" + index)[0]
            .value;
          let qt_prazo_cota = document.getElementsByName("qt_prazo" + index)[0]
            .value;
          let qt_cota_contrato = this.qt_cota_contrato;

          this.json = {
            cd_ficha_venda: this.cd_ficha_venda,
            cd_parametro: 4,
            qt_cota_contrato: qt_cota_contrato,
            cd_cota: cd_cota,
            cd_tabela: cd_tabela,
            cd_usuario: localStorage.cd_usuario,
            vl_cota_contrato: vl_cota_contrato,
            cd_cota_ficha_venda: index,
            qt_prazo_cota: qt_prazo_cota,
            cd_grupo_cota: cd_grupo,
          };

          if (this.alteracaoCotas == false) {
            let retorno = await Incluir.incluirRegistro(
              this.api_ficha,
              this.json,
            );
            notify(retorno[0].Msg);
          } else {
            this.json.cd_parametro = 8;
            let retorno = await Incluir.incluirRegistro(
              this.api_ficha,
              this.json,
            );
            notify(retorno[0].Msg);
          }

          index++;
        }

        this.carrega_load = false;
        this.cadastrar_cota = false;
        this.MostraCotas = true;
      }
    },

    async onGravaDivisao() {
      var api_c = "456/624";

      var valor = 0;
      if (!this.qt_vendedores == 0) {
        var c = 0;
        var b = 0;
        for (c = 1; c <= this.qt_vendedores; c++) {
          b = document.getElementsByName("pc" + c)[0].value;
          valor += parseInt(b);
        }

        if (isNaN(valor)) {
          let i = 0;
          for (i = 1; i <= this.qt_vendedores; i++) {
            var a = document.getElementsByName("nome" + i)[0].value;
            let b = 100 / this.qt_vendedores;

            let dados = {
              cd_usuario: localStorage.cd_usuario,
              cd_ficha_venda: this.cd_ficha_venda,
              cd_ordem: i,
              cd_parametro: 5,
              cd_contrato: this.cd_contrato,
              cd_vendedor: a,
              pc_comissao: b,
            };
            var a = await Incluir.incluirRegistro(api_c, dados);
            notify(a[0].Msg);
            this.$refs.divisaovenda.carregaDados();
          }
        } else {
          let i = 0;
          if (valor == 100) {
            this.carrega_load = true;
            for (i = 1; i <= this.qt_vendedores; i++) {
              var a = document.getElementsByName("nome" + i)[0].value;
              var b = document.getElementsByName("pc" + i)[0].value;

              var dados = {
                cd_usuario: localStorage.cd_usuario,
                cd_ficha_venda: this.cd_ficha_venda,
                cd_ordem: i,
                cd_parametro: 5,
                cd_contrato: this.cd_contrato,
                cd_vendedor: a,
                pc_comissao: b,
              };
              var c = await Incluir.incluirRegistro(api_c, dados);
              notify(c[0].Msg);
              this.MostraVendedor = true;
            }
            this.cadastrar_divisao = false;
            this.$refs.divisaovenda.carregaDados();
            this.carrega_load = false;
          } else {
            notify("Digite uma porcentagem que some 100");
          }
        }
      }
    },

    async onAlteraDivisao() {
      let api_c = "456/624";
      let limpar = {
        ic_parametro: 2,
        cd_parametro: 5,
        cd_contrato: this.cd_contrato,
      };

      let limpa = await Incluir.incluirRegistro(api_c, limpar);

      let i = 0;
      for (i = 1; i <= this.qt_vendedores; i++) {
        var a = document.getElementsByName("nome" + i)[0].value;
        var b = document.getElementsByName("pc" + i)[0].value;
        var dados = {
          ic_parametro: 1,
          cd_parametro: 5,
          cd_contrato: this.cd_contrato,
          cd_vendedor: a,
          pc_comissao: b,
        };
        var a = await Incluir.incluirRegistro(api_c, dados);
      }
      notify(a[0].Msg);
    },

    async altera_cliente() {
      //this.cadastrar();
    },

    async carregaDados() {
      this.cd_empresa = localStorage.cd_empresa;
      this.cd_cliente = localStorage.cd_cliente;
      this.cd_menu = localStorage.cd_menu;
      this.cd_api = localStorage.cd_api;
      this.api = localStorage.nm_identificacao_api;

      dados = await Menu.montarMenu(this.cd_empresa, this.cd_menu, this.cd_api); //'titulo';

      sParametroApi = dados.nm_api_parametro;

      let sApi = sParametroApi;

      this.dataSourceConfig = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        this.api,
        sApi,
      );
    },

    async onGravarCliente() {
      await this.$refs.consulta_cliente.onGravar();
      var dados = {
        cd_ficha_venda: this.cd_ficha_venda,
        cd_parametro: 2,
        cd_contrato: this.cd_contrato,
        cd_usuario: localStorage.cd_usuario,
        cd_usuario_inclusao: localStorage.cd_usuario,
        cd_cliente: this.cd_cliente_contrato,
        cd_item_cadastro: 1,
      };

      var s = await Incluir.incluirRegistro(this.api_ficha, dados);
      notify(s[0].Msg);
      if (this.cd_tipo_pessoa == 1) {
        this.step = 2;
      } else {
        this.step = 3;
      }
      this.alteracao = true;
    },

    async onAlteraCliente() {
      await this.$refs.consulta_cliente.onAlterar();
    },

    async onGravarSocio() {
      this.validado = false;
      var a = await this.$refs.cadastro_socio.gravaSocio();
      this.step = 3;
    },

    async AlteraSocioMajoritario() {
      await this.$refs.cadastro_socio.onAlterarSocio();
    },

    cadastra_cliente() {
      this.cliente_popup = true;
    },

    async CarregaCotas() {
      var api = "454/618";
      localStorage.cd_parametro = this.cd_contrato;
      var dados_cotas = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        "/${cd_empresa}/${cd_parametro}",
      );

      this.qt_cota_contrato = dados_cotas[0].qt_cota_contrato;
      this.vl_cota_contrato = dados_cotas[0].vl_cota_contrato;
      this.pc_cota_contrato = dados_cotas[0].pc_cota_contrato;
      this.vl_cota_parcela = dados_cotas[0].vl_cota_parcela;
      this.dt_vencimento_cota = formataData.formataDataJS(
        this.dt_vencimento_cota,
      );
    },

    async onProximaTab(step) {
      if (step == 1) {
        if (this.cadastro != null) {
          await this.onGravarCliente();
        }
      }

      //SÓCIO MAJORITÁRIO - OK
      if (step == 2 && this.cd_tipo_pessoa == 1) {
        await this.onGravarSocio();
      }

      if (this.step == 5) {
        this.bt_esconde_prox = 1;
        this.bt_esconde_fim = 1;
        this.bt_esconde_doc = 0;
      }

      this.step++;
      this.bt_esconde_ant = 0;
    },
    async ContinuaAlteracao() {
      //aqui
      let ficha;
      this.contrato_aprovacao = false;
      this.MostraCotas = true;
      this.MostraVendedor = true;
      this.alteracao = true;
      this.botao_cadastra_altera = true;
      this.botao_cadastra = false;
      if (this.propsX.cd_documento != undefined) {
        ficha = this.propsX.cd_documento;
        this.cd_ficha_venda = this.propsX.cd_documento;
      } else {
        ficha = grid.Selecionada().cd_ficha_venda;
      }
      let c = {
        cd_parametro: 6,
        cd_ficha_venda: ficha,
        cd_usuario: localStorage.cd_usuario,
      };
      this.data_consulta = await Incluir.incluirRegistro(this.api_ficha, c);

      this.dt_contrato = this.data_consulta[0].dt_ficha_venda;
      this.empresa_faturamento = {
        cd_empresa: this.data_consulta[0].cd_empresa,
        nm_fantasia_empresa: this.data_consulta[0].nm_fantasia_empresa,
      };
      this.url =
        "http://www.egisnet.com.br/img/EmpresaFatInter/" +
        this.data_consulta[0].nm_logotipo_empresa;

      this.administradora = {
        cd_administradora: this.data_consulta[0].cd_administradora,
        nm_administradora: this.data_consulta[0].nm_administradora,
      };
      await this.buscaTabela();
      this.nm_fantasia = this.data_consulta[0].nm_fantasia_cliente;

      this.vendedor = {
        cd_vendedor: this.data_consulta[0].cd_vendedor,
        nm_fantasia_vendedor: this.data_consulta[0].nm_vendedor,
      };
      await this.buscaEquipe();
      var a = this.data_consulta[0].cd_indicador;
      if (a != 0) {
        var index = this.lookup_dataset_vendedor.findIndex(
          (obj) => obj.cd_vendedor == a[0],
        );
        this.captacao = {
          cd_vendedor: this.lookup_dataset_vendedor[index].cd_vendedor,
          nm_fantasia_vendedor: this.lookup_dataset_vendedor[index]
            .nm_fantasia_vendedor,
        };
        await this.buscaEquipeCaptacao();
      }

      this.cd_id_contrato = this.data_consulta[0].cd_id_contrato;
      this.nm_tipo_venda = {
        cd_tipo_pedido: this.data_consulta[0].cd_tipo_venda,
        nm_tipo_pedido: this.data_consulta[0].nm_tipo_pedido,
      };
      this.seguro = this.data_consulta[0].ic_seguro_contrato;
      if (this.seguro == "S") {
        this.seguro = true;
      } else {
        this.seguro = false;
      }
      this.qt_prazo_contrato = this.data_consulta[0].qt_prazo_contrato;
      this.qt_cota_contrato = this.data_consulta[0].qt_cota_contrato;
      this.vl_total_contrato = this.data_consulta[0].vl_total_contrato;
      this.cd_status_contrato = this.data_consulta[0].cd_status_contrato;
      this.cd_ficha_venda = this.data_consulta[0].cd_ficha_venda;
      if (
        this.cd_status_contrato == 6 ||
        this.cd_status_contrato == 7 ||
        this.cd_status_contrato == 9 ||
        this.cd_status_contrato == 10
      ) {
        this.consulta_contrato_consorcio = 1;
      }
      this.qt_valor = this.data_consulta.length;
      this.cd_cliente_contrato = this.data_consulta[0].cd_cliente;
      this.cd_tipo_pessoa = this.data_consulta[0].cd_tipo_pessoa;

      if (this.cd_tipo_pessoa == 1) {
        this.cadastra_socio = false;
      } else {
        this.cadastra_socio = true;
      }

      this.consulta = 0;
      if (this.propsX != {}) {
        this.step = this.propsX.cd_step;
      }

      this.cd_contrato = this.data_consulta[0].cd_contrato; //denovo
      this.tabela = {
        cd_tabela: this.data_consulta[0].cd_tabela,
        nm_tabela: this.data_consulta[0].nm_tabela,
      };

      this.cd_equipe = this.data_consulta[0].cd_equipe;

      //this.cd_cliente           = this.data_consulta[0].cd_cliente        ;
      this.cd_tabela = this.data_consulta[0].cd_tabela;
      this.cd_cota_contrato = this.data_consulta[0].cd_cota_contrato;

      this.qt_parcelas = this.data_consulta[0].qt_parcela_contrato;
      this.status_contrato = this.data_consulta[0].nm_status;

      this.qt_vendedor_contrato = this.data_consulta[0].qt_vendedor_contrato;
      this.vl_credito_contrato = this.data_consulta[0].vl_credito_contrato;
      this.qt_peso_contrato = this.data_consulta[0].qt_peso_contrato;
      this.nm_obs_contrato = this.data_consulta[0].nm_obs_contrato;
      this.dt_venda_consorcio = this.data_consulta[0].dt_venda_consorcio;
      this.cd_captacao = this.data_consulta[0].cd_indicador;

      //this.vl_parcela_contrato  = this.data_consulta[0].vl_parcela_contrato ;

      this.empresa_faturamento.cd_empresa_faturamento = this.data_consulta[0].cd_empresa;

      this.cadastro = false;
      this.getDoc = [];

      for (let cont = 0; cont < this.lookup_dataset_documento.length; cont++) {
        if (
          this.lookup_dataset_documento[cont].cd_tipo_pessoa ==
          this.cd_tipo_pessoa
        ) {
          this.lookup_dataset_documento_filtrado[
            this.lookup_dataset_documento_filtrado.length
          ] = this.lookup_dataset_documento[cont];
        }
      }

      /*--------------------------------------------------------------*/
      //var api_doc = '479/676'
      //localStorage.cd_parametro = this.cd_contrato
      //localStorage.cd_identificacao = 0
      //var retorno_doc = await Procedimento.montarProcedimento(
      //  this.cd_empresa,
      //  this.cd_cliente,
      //  api_doc,
      //  '/${cd_empresa}/${cd_parametro}/${cd_identificacao}'
      //)
      //if(retorno_doc != undefined){
      //  this.todosDocumentos = retorno_doc;
      //}

      /*--------------------------------------------------------------*/

      //localStorage.cd_identificacao = 1
      //var retorno_doc1 = await Procedimento.montarProcedimento(
      //  this.cd_empresa,
      //  this.cd_cliente,
      //  api_doc,
      //  '/${cd_empresa}/${cd_parametro}/${cd_identificacao}'
      //)
      //this.documentos_pos_venda = retorno_doc1;
      //localStorage.cd_identificacao = 0
      /*--------------------------------------------------------------*/

      //localStorage.cd_identificacao = 2
      //var retorno_doc = await Procedimento.montarProcedimento(
      //  this.cd_empresa,
      //  this.cd_cliente,
      //  api_doc,
      //  '/${cd_empresa}/${cd_parametro}/${cd_identificacao}'
      //)
      //this.documentos_pagamento_venda = retorno_doc;
      //localStorage.cd_identificacao = 0
      /*--------------------------------------------------------------*/

      //  var api_consulta = '486/689'
      //  this.parcelas_contrato =  await Procedimento.montarProcedimento(
      //    localStorage.cd_empresa,
      //    localStorage.cd_cliente,
      //    api_consulta,
      //    '/${cd_empresa}/${cd_parametro}'
      //  )
      //  localStorage.cd_parametro = 0
      //
      //  var cont = 0
      //  for(cont = 0; cont < this.parcelas_contrato.length; cont++){
      //    document.getElementsByName('dt_parcela'+cont).value = this.parcelas_contrato[cont].dt_parc_contrato
      //  }
    },

    async onAlterar() {
      if (grid.Selecionada().cd_status_contrato == 6) {
        this.msg_aprovacao =
          "O Contrato " +
          grid.Selecionada().cd_contrato +
          " já está em Aprovação. Não é possível alterar um contrato em Aprovação!";
        this.contrato_aprovacao = true;
      } else {
        this.ContinuaAlteracao();
      }
    },

    async onInserir() {
      this.carrega_load = true;
      await this.limpaTudo();
      this.dt_contrato = new Date().toLocaleDateString("pt-br");
      this.consulta_contrato_consorcio = 0;
      this.consulta = 0;
      this.cadastro = true;

      this.carrega_load = false;
      this.botao_cadastra = true;
      this.botao_cadastra_altera = false;
    },

    async buscaTabela() {
      localStorage.cd_parametro = this.administradora.cd_administradora;

      this.lookup_dataset_tabela = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        "458/631",
        "/${cd_empresa}/${cd_parametro}",
      );

      this.lookup_dataset_tabela = JSON.parse(
        JSON.parse(JSON.stringify(this.lookup_dataset_tabela[0].dataset)),
      );
    },
    adicionarVendedor() {
      if (this.qt_vendedores == "") {
        this.qt_vendedores = 1;
      }
      this.cadastrar_divisao = true;
    },

    async ConfirmarDesativaAtiva() {
      var api = "456/624";
      var contrato = grid.Selecionada();
      var dados = {
        cd_parametro: 10,
        cd_contrato: contrato.cd_contrato,
        nm_justificativa: this.nm_justificativa,
        cd_usuario: localStorage.cd_usuario,
        cd_usuario_inclusao: localStorage.cd_usuario,
      };
      var s = await Incluir.incluirRegistro(api, dados);
      notify(s[0].Msg);
      this.$refs.grid_c.carregaDados();
    },

    select_imagem() {
      this.cd_empresa_faturamento = this.empresa_faturamento.cd_empresa;
      let logo = this.empresa_faturamento.nm_logotipo_empresa;
      //var cd_empresa_f = 0;
      //cd_empresa_f = this.dataSourceConfig.findIndex(obj => obj.cd_empresa == this.cd_empresa_faturamento);
      this.url = "http://www.egisnet.com.br/img/EmpresaFatInter/" + logo;
    },

    async cadastrar() {
      if (this.nm_fantasia == "") {
        this.cadastro = true;
      } else {
        localStorage.nm_fantasia = this.nm_fantasia.trim();
        localStorage.nm_razao_social = "null";
        localStorage.cd_parametro = 0;
        let api_consulta = "405/542"; //1292 - pr_pesquisa_consulta_cliente
        this.carrega_load = true;

        var dados = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api_consulta,
          "/${cd_empresa}/${cd_parametro}/${nm_fantasia}/${nm_razao_social}",
        );

        if (dados.length == 0) {
          this.cliente_nao_encontrado = true;
          this.carrega_load = false;
          return;
        }
        this.carrega_load = false;
        if (dados[0].status == "false") {
          this.cliente_popup = true;
        } else {
          //this.cliente_popup = false;
          this.cli = true;
          this.clientes_encontrados = dados;
        }
        //notify(dados[0].Msg);
      }
    },
    FormataValor(valorT, indice) {
      if (valorT == "" || valorT == "0") return;
      if (valorT == "" || valorT == "R$ NaN" || valorT == undefined) {
        valorT = 0;
      }
      if (valorT.includes("R$") == false) {
        let valor = valorT;

        if (valor.includes("R$") == true) {
          valor = valor.replace("R$", " ");
        }

        if (valor.includes(",") == true) {
          valor = valor.replace(",", ".");
        }
        valor = parseFloat(valor);
        valorT = valor.toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
        if (indice == 1) {
          this.vl_total_contrato = valorT;
        }
        if (indice == 2) {
        }
      }
    },
    limpaTudo() {
      this.cd_ficha_venda = 0;
      this.consulta = 1;
      this.seguro = false;
      this.cd_tabela = 0;
      this.vl_contrato = "";
      this.dt_venda = "";
      this.propsX = {};
      this.nm_captura_cliente = "";
      this.nm_tabela = "";
      //this.cd_grupo = 0
      this.dt_prazo = "";
      this.ic_seguro = false;
      this.vl_parcela_contrato = "";
      this.step = 1;
      this.bt_esconde_prox = "";
      this.bt_esconde_ant = "";
      this.bt_esconde_fim = 1;
      this.bt_esconde_doc = "";
      this.url = "";
      this.cadastro = null;
      this.qt_parcelas = "";
      this.qt_vendedores = "";
      this.nm_fantasia = "";
      this.cd_contrato = "";
      this.dt_contrato = "";
      this.cd_administradora = "";
      this.cd_equipe = "";
      this.cd_vendedor = "";
      this.cd_cota_contrato = "";
      this.qt_parcela_contrato = "";
      this.ic_seguro_contrato = "";
      this.qt_vendedor_contrato = "";
      this.vl_credito_contrato = "";
      this.qt_peso_contrato = "";
      this.nm_obs_contrato = "";
      this.dt_venda_consorcio = "";
      this.qt_prazo_contrato = "";
      this.data_consulta = "";
      this.qt_cota_contrato = "";
      this.vl_cota_contrato = 0;
      this.pc_cota_contrato = "";
      this.vl_cota_parcela = "";
      this.dt_vencimento_cota = "";
      this.cd_captacao = "";
      this.cd_id_contrato = "";
      this.alteracao = "";
      this.model = "";
      this.empresa_faturamento = "";
      this.administradora = "";
      this.vendedor = "";
      this.captacao = "";
      this.tabela = "";
      this.mostra_vendedor = "";
      this.cadastra_parcela = "";
      this.qt_valor = "";
      this.cliente_popup = false;
      this.cd_tipo_pessoa = "";
      this.cadastrar_divisao = false;
      this.nm_documento = "";
      this.documento = "";
      this.base64 = "";
      this.validado = "";
      this.todosDocumentos = "";
      this.documentos_pos_venda = "";
      this.documento_pos = "";
      this.documentos_pagamento_venda = "";
      this.documento_pagamento = "";
      this.nm_tipo_venda = "";
      this.parcelas_contrato = "";
      this.equipe = "";
      this.equipe_captacao = "";
      this.cotas = "";
      this.cadastrar_cota = false;
      this.status_contrato = "";
      this.cd_status_contrato = "";
      this.vl_total_contrato = 0.0;
    },
  },
};
</script>

<style>
.div_botao {
  margin: 15px;
  text-align: right;
}

.select {
  width: 22%;
  height: 22%;
  font-size: 15px;
  border-radius: 10px;
}

.select-empresa {
  height: 40px;
  font-size: 15px;
}

.div_endereco {
  width: 100%;
  margin: 10px;
}

.input_endereco_f {
  width: 25%;
}

.label_empresa {
  float: left;
  display: block;
  height: 100%;
  margin-top: 40px;
}

.imagem {
  float: right;
  right: 5%;
}

.valores {
  width: 100%;
  border: solid 1px rgb(160, 160, 160);
  border-radius: 5px;
  margin: 8px;
}

.input_vendedor {
  width: 45%;
  border-radius: 5px;
  margin: 5px;
}

.input_vendedor_select {
  width: 45%;
  font-size: 14px;
  border-radius: 5px;
  margin: 5px;
}

.tipo_venda {
  text-transform: uppercase;
}

.input_canto_dir {
  margin-left: 15px !important;
  margin-right: 35px !important;
  margin-bottom: 15px !important;
  margin-top: 15px !important;
}

.input_canto_esq {
  margin-left: 35px !important;
  margin-right: 15px !important;
  margin-bottom: 15px !important;
  margin-top: 15px !important;
}

.todos_input {
  height: 20px !important;
}
.column {
  height: 20px !important;
}

.botao-gravar-step {
  margin: 5px;
}

.seleciona_doc {
  display: none;
}

.label-docs {
  height: 45px;
  background-color: #3498db;
  border-radius: 5px;
  color: #fff;
  margin: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.label-docs :hover {
  background-color: #2980b9;
}

.lista {
  height: 20%;
}

.item_lista {
  display: flex;
  align-items: center;
  margin: 15px;
}

.lista:hover {
  background-color: #c6c5ff;
}

.doc1 {
  width: 80%;
}

.doc2 {
  text-align: right;
  width: 10%;
}
.margin1 {
  margin: 0.7vw 0.8vw !important;
  padding: 0;
}
.fundo-img {
  background: rgb(211, 211, 211);
  border-radius: 5px;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}
.padding1 {
  padding: 10px;
}
.formata_input {
  border-radius: 5px;
  border: 1px solid rgb(236, 236, 236);
}
</style>
