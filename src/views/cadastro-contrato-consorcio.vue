<template>
  <div>
    <meta
      name="viewport"
      content="width=device-width,initial-scale=1,user-scalable=no"
    />
    <div class="text-h4 text-bold margin1" v-if="cd_contrato == 0">
      {{ tituloMenu }}
      <b v-if="!nm_cliente == ''">- {{ nm_cliente }}</b>
    </div>

    <div class="row margin1">
      <div class="text-h4 text-bold margin1" v-if="cd_contrato != 0">
        {{ tituloMenu }} - {{ cd_contrato }}
        <b v-if="!nm_cliente == ''">- {{ nm_cliente }}</b>
      </div>
      <div class="col" style="text-align: right" v-if="consulta == 0">
        <q-btn
          v-if="consulta == 0 && prop_form.cd_movimento == undefined"
          rounded
          color="orange-10"
          class="margin1"
          label="Voltar"
          @click="limpaTudo()"
        />
      </div>
    </div>

    <div v-if="consulta == 1" class="margin1">
      <q-btn
        class="margin1"
        label="Novo"
        rounded
        color="orange-10"
        icon="add"
        @click="onInserir()"
      />
      <q-btn
        class="margin1"
        label="Alterar"
        rounded
        color="orange-10"
        icon="reply"
        @click="onAlterar()"
      />
      <q-btn
        class="margin1"
        label="Consultar"
        rounded
        icon="description"
        color="orange-10"
        @click="onConsultar()"
      />
      <!--<q-btn size="sm" class="margin1" color="orange-10" icon="content_paste" @click="AbreListagem()" round>
      <q-tooltip transition-show="scale" transition-hide="scale">
          Imprimir
      </q-tooltip>
    </q-btn>-->
      <grid
        :cd_menuID="7031"
        :cd_apiID="442"
        :cd_parametroID="0"
        :nm_json="{}"
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
                <div style="font-size: 30px">
                  <b>{{ this.msg_aprovacao }}</b>
                </div>
              </q-card-section>
              <q-separator />
              <br />
              <q-btn
                style="margin: 5px"
                rounded
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

    <div v-if="consulta == 0">
      <div class="q-pa-md">
        <q-stepper
          v-model="cd_status_contrato"
          ref="stepper"
          color="orange-9"
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
            <b v-if="data_consulta[0].nm_justificativa_aprovacao != ''">
              {{ data_consulta[0].nm_justificativa_aprovacao }}
            </b>
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
        <div class="row margin1">
          <q-input
            class="col-2 margin1"
            v-model="dt_contrato"
            mask="##/##/####"
            label="Data"
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
            style="max-height: 80px"
            class="col-3 fundo-img items-center self-center"
            v-if="url != ''"
          >
            <img
              class="items-center self-center"
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
            @input="buscaEquipe(1, true)"
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

          <q-input class="col margin1" v-model="cd_id_contrato" label="ID">
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
            @blur="atualizaCotas"
          >
            <template v-slot:prepend>
              <q-icon name="pin" />
            </template>
          </q-input>

          <q-input
            class="col margin1"
            v-model="vl_total_contrato"
            @blur="FormataTotal()"
            label="Valor Total da Venda"
          >
            <template v-slot:prepend>
              <q-icon name="paid" />
            </template>
          </q-input>
        </div>

        <div>
          <q-btn
            v-if="botao_cadastra == true"
            class="margin1"
            label="Gravar"
            rounded
            color="orange-10"
            icon="save"
            @click="onClickGravarFicha()"
          />
          <q-btn
            v-if="botao_cadastra_altera == true"
            class="margin1"
            label="Atualizar"
            rounded
            color="orange-10"
            icon="refresh"
            @click="AlterarFichaVenda()"
          />
        </div>
        <!------------------------------------------------------------->
        <div v-if="cliente_nao_encontrado == true">
          <q-dialog v-model="cliente_nao_encontrado">
            <q-card>
              <q-card-section>
                <div class="q-pa-md">
                  <q-card-section class="q-pt-none">
                    <div class="informativo">
                      {{
                        `Cliente não encontrado, deseja cadastrar um novo cliente ?`
                      }}
                    </div>
                  </q-card-section>
                  <q-separator />
                  <br />
                  <div style="display: flex; justify-content: space-around">
                    <q-btn
                      rounded
                      style="margin: 2.5px"
                      @click="cadastra_cliente()"
                      color="green"
                      icon="check"
                      label="SIM"
                      v-close-popup
                    />
                    <q-btn
                      rounded
                      style="margin: 2.5px"
                      color="red"
                      icon="check"
                      label="NÃO"
                      v-close-popup
                    />
                  </div>
                </div>
              </q-card-section>
            </q-card>
          </q-dialog>
        </div>
        <!------------------------------------------------------------->
      </div>
      <div
        class="margin1 shadow-2"
        style="border-radius: 5px"
        v-if="cd_contrato != 0"
      >
        <q-stepper
          :header-nav="navega_header"
          v-model="step"
          done-icon="done_all"
          active-icon="touch_app"
          ref="stepper"
          color="primary"
          animated
        >
          <q-step :name="1" title="Cliente" icon="settings" :done="step > 1">
            <div class="row" v-if="consulta_contrato_consorcio == 0">
              <q-input
                class="col tipo_pessoa"
                v-model="nm_fantasia"
                label="Cliente"
                @blur="cadastrar()"
              >
                <template v-slot:prepend>
                  <q-icon name="account_circle" />
                </template>
              </q-input>

              <q-btn
                v-if="cadastro == true"
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
            </div>

            <!------------------------------------------------------------->
            <cliente
              v-if="cadastro == false"
              :cd_consulta="true"
              :cd_cliente_c="this.cd_cliente_contrato"
              ref="consulta_cliente"
            >
            </cliente>
            <!------------------------------------------------------------->
            <div v-if="consulta_contrato_consorcio == 0">
              <q-btn
                v-if="bt_esconde_prox == 0"
                class="margin1"
                label="Gravar"
                rounded
                color="orange-10"
                icon="save"
                @click="onGravarCliente()"
              />
            </div>
            <q-expansion-item
              v-if="timelineI.cd_movimento > 0"
              icon="description"
              label="Histórico"
              class="overflow-hidden metade-tela margin1 bg-white shadow-1"
              style="border-radius: 20px; height: auto"
              header-class="bg-orange-9 text-white items-center text-h6"
              expand-icon-class="text-white"
            >
              <timeline
                style="border-radius: 20px; height: auto"
                class="margin1"
                v-if="timelineI.cd_movimento > 0"
                :cd_apiInput="'737/1119'"
                ref="timeline_intermedium"
                :inputID="true"
                :nm_json="timelineI"
                :cd_consulta="2"
                :cd_parametroID="0"
                cd_apiID="728/1101"
              />
            </q-expansion-item>
          </q-step>

          <q-step
            :name="2"
            title="Sócio"
            icon="groups"
            :disable="cadastra_socio"
            :done="step > 2"
          >
            <socio
              :cd_contrato="this.cd_contrato"
              :cd_cliente_socio="this.cd_cliente_contrato"
              :cadastro="false"
              :cd_ficha_vendaID="this.cd_ficha_venda"
              :cd_indicacaoID="0"
              ref="cadastro_socio"
            >
            </socio>

            <q-btn
              v-if="consulta_contrato_consorcio == 0"
              class="margin1"
              label="Gravar"
              rounded
              color="orange-10"
              icon="save"
              @click="onGravarSocio()"
            />
          </q-step>

          <q-step :name="3" title="Cotas" icon="assignment" :done="step > 3">
            <div class="row items-center">
              <div class="col">
                <q-btn
                  v-if="consulta_contrato_consorcio == 0"
                  class="margin1"
                  label="Cadastrar/Alterar"
                  rounded
                  color="orange-10"
                  icon="folder"
                  @click="mostraCotas()"
                />
              </div>
              <div class="col">
                <q-btn
                  class="margin1"
                  style="float: right"
                  flat
                  round
                  color="orange-10"
                  icon="refresh"
                  @click="carregaGrids(1)"
                />
              </div>
            </div>

            <div v-if="this.MostraCotas == true">
              <grid
                :cd_menuID="7093"
                :cd_apiID="492"
                :cd_parametroID="this.cd_contrato"
                ref="grid_cota"
                :nm_json="{}"
              />
            </div>
          </q-step>

          <q-step
            :name="4"
            title="Divisão de venda"
            icon="price_change"
            :done="step > 4"
          >
            <div class="row items-center">
              <div class="col">
                <q-btn
                  v-if="consulta_contrato_consorcio == 0"
                  class="margin1"
                  label="Adicionar Vendedor"
                  rounded
                  color="orange-10"
                  icon="add"
                  @click="adicionarVendedor()"
                />
              </div>
              <div class="col">
                <q-btn
                  class="margin1"
                  style="float: right"
                  flat
                  round
                  color="orange-10"
                  icon="refresh"
                  @click="carregaGrids(2)"
                />
              </div>
            </div>

            <div>
              <grid
                :cd_menuID="7054"
                :cd_apiID="463"
                :cd_parametroID="this.cd_contrato"
                ref="divisaovenda"
                :nm_json="{}"
              />
            </div>
          </q-step>

          <q-step
            :name="5"
            title="Documentos"
            icon="drive_folder_upload"
            :done="step > 5"
          >
            <div
              class="row"
              v-show="lista_documentos.length > 0"
              v-for="(b, index) in lista_documentos"
              :key="index"
            >
              <q-list bordered separator class="col">
                <q-item clickable v-ripple class="row">
                  <q-item-section class="col text-subtitle2">{{
                    b.nm_contrato_documento
                  }}</q-item-section>
                  <q-item-section avatar>
                    <q-icon
                      color="orange-10"
                      size="md"
                      name="cloud_download"
                      href
                      @click="Download(b)"
                    />
                  </q-item-section>
                </q-item>
              </q-list>
            </div>
            <div>
              <q-icon
                size="md"
                name="info"
                class="text-orange-9 cursor-pointer"
              >
                <q-popup-proxy
                  transition-show="jump-up"
                  transition-hide="jump-down"
                >
                  <q-banner class="bg-orange-9 text-white banner">
                    <div class="text-center text-h6">
                      Documentação Pessoa Física
                    </div>

                    <q-icon size="sm" name="arrow_forward" />RG e CPF;
                    <br />
                    <div class="borda-branca padding1">
                      <div class="row text-center text-subtitle2">Zema</div>
                      <q-icon size="sm" name="arrow_forward" />Comprovante de
                      endereço atualizado.
                      <br />
                    </div>

                    <div class="borda-branca padding1">
                      <div class="row text-center text-subtitle2">Caixa</div>
                      <q-icon size="sm" name="arrow_forward" />Comprovante de
                      renda:
                      <br />
                      <q-icon size="sm" name="done" />Pró-labore (necessário ser
                      em formato de holerite e enviar também o Contrato social
                      da empresa e o cartão CNPJ) ou;
                      <br />
                      <q-icon size="sm" name="done" />Holerite com a carteira de
                      trabalho ou;
                      <br />
                      <q-icon size="sm" name="done" />Declaração e Recibo do
                      Imposto de renda completo do ultimo ano
                    </div>

                    <div class="text-center text-h6">
                      Documentação Pessoa Jurídica
                    </div>
                    <q-icon size="sm" name="arrow_forward" />Contrato social;
                    <br />
                    <q-icon size="sm" name="arrow_forward" />Cartão CNPJ
                    (Atualizado);
                    <br />
                    <q-icon size="sm" name="arrow_forward" />Documentos de todos
                    os sócios;
                    <br />
                    <div class="borda-branca padding1">
                      <div class="row text-center text-subtitle2">Zema</div>
                      <q-icon size="sm" name="arrow_forward" />Comprovante de
                      renda (atualizado).
                      <br />
                      <q-icon size="sm" name="arrow_forward" />Comprovante de
                      endereço (atualizado) em nome da empresa.
                      <br />
                    </div>

                    <div class="borda-branca padding1">
                      <div class="row text-center text-subtitle2">Caixa</div>
                      <q-icon size="sm" name="arrow_forward" />Comprovante de
                      renda:
                      <br />
                      <q-icon size="sm" name="done" />Balanço do ano anterior e
                      Balancete do último trimestre ou;
                      <br />
                      <q-icon size="sm" name="done" />Extrato detalhado do
                      último ano do Simples Nacional caso seja optante.
                      <br />
                    </div>

                    <div class="row text-center text-bold">
                      IMPORTANTE QUE TODOS OS ARQUIVOS ESTEJAM LEGIVEIS E EM PDF
                    </div>
                  </q-banner>
                </q-popup-proxy>
              </q-icon>
            </div>

            <div class="row items-center">
              <q-select
                class="col margin1"
                option-value="cd_tipo_documento"
                option-label="nm_tipo_documento"
                v-model="nm_documento"
                :options="lookup_dataset_documento"
                label="Tipo de Documento"
              >
                <template v-slot:prepend>
                  <q-icon name="receipt_long" />
                </template>
              </q-select>

              <q-file
                v-model="getDoc"
                multiple
                label="Arquivos"
                use-chips
                class="col margin1"
              >
                <template v-slot:prepend>
                  <q-icon name="attach_file" />
                </template>
              </q-file>
            </div>

            <div class="row items-center">
              <q-input
                v-model="ds_documento"
                autogrow
                label="Observação"
                class="margin1 col"
              >
                <template v-slot:prepend>
                  <q-icon name="description" />
                </template>
              </q-input>

              <div
                v-if="consulta_contrato_consorcio == 0"
                class="text-h7 text-bold margin1 col"
              >
                <q-checkbox
                  v-model="aceite"
                  label="Aceite: Em caso de o cliente colocar reclamação no Reclame Aqui, será estornado 100% das comissões pagas da primeira venda e da venda repique. Em caso de ajuizamento de ações pelo cliente, o vendedor será responsável pelas custas processuais."
                  class="text-bold check-box-style response"
                  color="blue"
                />
              </div>
            </div>

            <div v-if="consulta_contrato_consorcio == 0" class="col items-end">
              <q-btn
                v-if="consulta_contrato_consorcio == 0"
                class="margin1"
                style="float: right"
                flat
                color="positive"
                rounded
                icon="check"
                label="Solicitar aprovação"
                @click="onSolicitar()"
              />
              {{ "Alo" }}
              <q-btn
                v-if="consulta_contrato_consorcio == 0"
                class="margin1"
                style="float: right"
                flat
                color="orange-10"
                rounded
                icon="send"
                label="Enviar Documentos"
                @click="adicionarDocumento()"
              />
            </div>

            <q-list
              bordered
              separator
              v-for="n in parseInt(this.todosDocumentos.length)"
              v-bind:key="n"
            >
              <div class="row lista">
                <div class="item_lista doc1">
                  <q-item-label>
                    {{ todosDocumentos[n - 1].nm_tipo_documento }}
                    <br />
                    <q-item-label overline>
                      {{ todosDocumentos[n - 1].nm_contrato_documento }}
                    </q-item-label>
                  </q-item-label>
                </div>
                <div class="item_lista doc2">
                  <q-item-label>
                    <q-btn
                      class="gt-xs"
                      size="12px"
                      flat
                      dense
                      round
                      icon="delete"
                      @click="removeDocumento(n)"
                    />
                    <q-btn
                      class="gt-xs"
                      size="12px"
                      flat
                      dense
                      round
                      icon="wysiwyg"
                      @click="abrirDoc(n)"
                    />
                  </q-item-label>
                </div>
              </div>
            </q-list>
          </q-step>

          <template v-slot:navigation>
            <q-stepper-navigation>
              <q-btn
                v-if="bt_esconde_fim == 0"
                class="margin1"
                label="Solicitar Aprovação"
                rounded
                color="orange-10"
                @click="onSolicitar()"
              />
            </q-stepper-navigation>
          </template>
        </q-stepper>
      </div>
    </div>

    <div v-if="cadastrar_divisao == true" class="q-pa-md">
      <q-dialog v-model="cadastrar_divisao">
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <div class="text-h6 items-center">Divisão de Venda</div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>
          <q-space />
          <q-separator />
          <q-card-section>
            <q-input
              class="col"
              v-model="qt_vendedores"
              type="Number"
              @input="formataVendedor()"
              label="Vendedores que participaram do Negócio"
            >
              <template v-slot:prepend>
                <q-icon name="format_list_numbered" />
              </template>
            </q-input>

            <div
              class="row self-center"
              v-for="(v, index) in parseInt(qt_vendedores)"
              v-bind:key="v"
            >
              <q-select
                class="col self-center"
                outlined
                :name="'nome' + v"
                @blur="BuscaEquipeDivisaoVenda($event)"
                v-model="cd_vendedor_divisao[v - 1]"
                :options="lookup_dataset_vendedor"
                label="Vendedor"
                option-value="cd_vendedor"
                option-label="nm_vendedor"
                :option-disable="(item) => cd_vendedor_divisao.includes(item)"
              >
                <q-badge color="red" floating>{{
                  equipe_disisao_venda[index]
                }}</q-badge>
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
              rounded
              text-color="white"
              label="Cadastrar"
              icon="add"
              class="margin1"
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
              >Cotas da Ficha - {{ cd_contrato }}
            </div>
            <q-space />
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>

          <q-separator />
          <div v-for="n in 4" :key="n" class="margin1">
            <!--<div class="text-bold">Cota: {{ n }}</div>-->

            <div class="row justify-around">
              <div class="umSetimoTela margin1">
                <b>Quantidade de Cotas</b>
                <br />
                <input
                  class="formata_input"
                  type="Number"
                  min="0"
                  :name="'qt_cota_contrato' + n"
                />
              </div>

              <div class="umSetimoTela margin1">
                <b>Cota</b>
                <br />
                <input
                  class="formata_input"
                  type="String"
                  :name="'cd_cota' + n"
                />
              </div>

              <div class="umSetimoTela margin1">
                <b>Grupo</b>
                <br />
                <input
                  class="formata_input"
                  type="String"
                  :name="'cd_grupo' + n"
                />
              </div>

              <div class="umSetimoTela margin1">
                <b>Prazo</b>
                <br />
                <input
                  class="formata_input"
                  type="String"
                  :name="'qt_prazo' + n"
                />
              </div>

              <div class="umSetimoTela margin1">
                <b>Tabela</b>
                <br />
                <select
                  class="formata_input"
                  style="width: 90%"
                  :name="'cd_tabela' + n"
                >
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

              <div class="umSetimoTela margin1">
                <b>Valor</b>
                <br />
                <input
                  class="formata_input"
                  type="money"
                  @blur="blurEventHandler($event)"
                  :name="'vl_cota_contrato' + n"
                />
              </div>

              <div class="umSetimoTela margin1">
                <b>Valor Primeira Parcela</b>
                <br />
                <input
                  class="formata_input"
                  type="money"
                  @blur="blurEventHandler($event)"
                  :name="'vl_primeira_parcela' + n"
                />
              </div>
            </div>

            <q-separator class="margin1" />
          </div>
          <q-btn
            class="margin1"
            label="Gravar Cotas"
            rounded
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

    <div v-if="cliente_popup == true" class="q-pa-md">
      <q-dialog full-width v-model="cliente_popup">
        <q-card>
          <q-card-section class="row items-center q-pb-none">
            <q-btn icon="close" flat round dense v-close-popup />
          </q-card-section>
          <q-card-section>
            <cliente
              :cd_cadastro="2"
              :cd_cadastro_c="true"
              ref="cadastro_cliente"
            >
            </cliente>
          </q-card-section>
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
    <q-dialog maximized v-model="carregando" persistent>
      <carregando
        v-if="carregando == true"
        :corID="'orange-9'"
        :mensagemID="'Aguarde...'"
      ></carregando>
    </q-dialog>

    <q-dialog v-model="alertCard">
      <card
        v-if="alertCard"
        :cd_tipo_layout="infoCard.cd_tipo_layout"
        :nm_texto_titulo="infoCard.nm_texto_titulo"
        :nm_descritivo="infoCard.nm_descritivo"
        :nm_icon="infoCard.nm_icon"
        :nm_cor_icon="infoCard.nm_cor_icon"
      />
    </q-dialog>
  </div>
</template>

<script>
import funcao from "../http/funcoes-padroes";
import Procedimento from "../http/procedimento";
import Menu from "../http/menu";
import config from "devextreme/core/config";
import { loadMessages, locale } from "devextreme/localization";
import DxTextBox from "devextreme-vue/text-box";
import notify from "devextreme/ui/notify";
import ptMessages from "devextreme/localization/messages/pt.json";
import DxButton from "devextreme-vue/button";
import Incluir from "../http/incluir_registro";
import Lookup from "../http/lookup";
import ftp from "../http/ftp.js";
import grid from "../views/grid.vue";
import cliente from "../views/cliente.vue";
import socio from "../views/cadastro-socio-majoritario.vue";
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
      infoCard: {
        nm_icon: "",
        nm_texto_titulo: "",
        nm_descritivo: "",
        cd_tipo_layout: 0,
        nm_cor_icon: "negative",
      },
      alertCard: false,
      lista_documentos: [],
      tituloMenu: "Ficha de Venda",
      dt_inicial: "",
      dt_final: "",
      dataSourceConfig: [],
      cd_empresa: 0,
      cd_menu: 0,
      cd_cliente: 0,
      cd_cliente_contrato: 0,
      cd_api: 0,
      api: 0,
      seguro: false,
      lookup_dataset_administradora: [],
      cd_administradora: 0,
      lookup_dataset_vendedor: [],
      cd_vendedor_divisao: [],
      lookup_dataset_captacao: [],
      lookup_dataset_empresa_faturamento: [],
      cd_empresa_faturamento: 0,
      lookup_dataset_documento: [],
      lookup_dataset_documento_filtrado: [],
      lookup_dataset_tabela: [],
      cd_tabela: [],
      popup_ficha_venda: false,
      vl_contrato: 0.0,
      vl_total_contrato: 0.0,
      nm_tabela: "",
      cd_grupo: [],
      cd_vendedor: "",
      ic_seguro: "N",
      vl_parcela_contrato: 0,
      step: 1,
      bt_esconde_prox: 0,
      nm_cliente: "",
      bt_esconde_fim: 1,
      carregando: false,
      url: "",
      cadastro: null,
      cadastro_socio: false,
      qt_parcelas: 0,
      qt_vendedores: 1,
      nm_fantasia: "",
      cd_contrato: "",
      cd_id_contrato: "",
      dt_contrato: "",
      cd_equipe: "",
      cd_cota_contrato: "",
      cd_cota: [],
      qt_parcela_contrato: "",
      ic_seguro_contrato: "",
      qt_vendedor_contrato: "",
      vl_credito_contrato: "",
      qt_peso_contrato: "",
      cd_modulo: localStorage.cd_modulo,
      nm_obs_contrato: "",
      dt_venda_consorcio: "",
      qt_prazo_contrato: 0,
      data_consulta: [],
      qt_cota_contrato: 0,
      cd_usuario: localStorage.cd_usuario,
      timelineI: {
        ic_parametro: 2,
        cd_form: 3, //Cadastro-contrato-consorcio.vue
        cd_movimento: 0,
        cd_empresa: 0,
        dt_inicial: "",
        dt_final: "",
        cd_usuario: localStorage.cd_usuario,
      },
      vl_cota_contrato: 0,
      pc_cota_contrato: "",
      vl_cota_parcela: "",
      dt_vencimento_cota: "",
      cd_captacao: 0,
      consulta: 1,
      MostraCotas: true,
      MostraVendedor: false,
      json: {},
      getDoc: [],
      alteracao: 0,
      cliente_nao_encontrado: false,
      empresa_faturamento: "",
      administradora: "",
      vendedor: "",
      captacao: "",
      tabela: "",
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
      validado: true,
      todosDocumentos: [],
      aceite: false,
      lookup_dataset_tipo_pedido: [],
      nm_tipo_venda: "",
      parcelas_contrato: "",
      equipe: "",
      equipe_captacao: "",
      cotas: [],
      cadastrar_cota: false,
      status_contrato: "",
      equipe_disisao_venda: [],
      cd_status_contrato: 0,
      cli: false,
      clientes_encontrados: [],
      consulta_contrato_consorcio: 0,
      nm_justificativa: "",
      navega_header: true,
      dif_valor: false,
      nm_dif_valor: false,
      cd_certeza: false,
      cd_tipo_validacao: null,
      cd_ficha_venda: 0,
      ds_documento: "",
    };
  },
  async created() {
    config({ defaultCurrency: "BRL" });
    loadMessages(ptMessages);
    locale(navigator.language);

    this.dt_inicial = new Date(localStorage.dt_inicial).toLocaleDateString();
    this.dt_final = new Date(localStorage.dt_final).toLocaleDateString();
    this.hoje = new Date().toLocaleDateString("pt-br");
    var h = new Date().toLocaleTimeString();
    this.hora = h.substring(0, 5);
    this.cd_empresa = localStorage.cd_empresa;
    var a = [1, 2, 3, 4, 5, 6];

    const lookup_dados_documento = await Lookup.montarSelect(
      this.cd_empresa,
      5263
    );
    this.lookup_dataset_documento = JSON.parse(
      JSON.parse(JSON.stringify(lookup_dados_documento.dataset))
    );

    const lookup_dados_administradora = await Lookup.montarSelect(
      this.cd_empresa,
      5238
    );
    this.lookup_dataset_administradora = JSON.parse(
      JSON.parse(JSON.stringify(lookup_dados_administradora.dataset))
    );

    const dados_lookuup_contato = await Lookup.montarSelect(
      localStorage.cd_empresa,
      111
    );
    this.dataset_lookup_contato = JSON.parse(
      JSON.parse(JSON.stringify(dados_lookuup_contato.dataset))
    );

    const lookup_dados_vendedor = await Lookup.montarSelect(
      this.cd_empresa,
      141
    );
    this.lookup_dataset_vendedor = JSON.parse(
      JSON.parse(JSON.stringify(lookup_dados_vendedor.dataset))
    );

    let ordenado = this.lookup_dataset_vendedor.sort(function (a, b) {
      if (a.nm_vendedor < b.nm_vendedor) return -1;
      return 1;
    });
    this.lookup_dataset_vendedor = ordenado;
    for (var a = 0; a < parseInt(this.lookup_dataset_vendedor.length); a++) {
      if (this.lookup_dataset_vendedor[a].cd_tipo_vendedor == 4) {
        this.lookup_dataset_captacao[this.lookup_dataset_captacao.length] =
          this.lookup_dataset_vendedor[a];
      }
    }

    let vendedor_usuario = await funcao.buscaVendedor(this.cd_usuario);
    vendedor_usuario.cd_vendedor == undefined
      ? (vendedor_usuario.cd_vendedor = null)
      : "";
    this.vendedor = {
      cd_vendedor: vendedor_usuario.cd_vendedor,
      nm_fantasia_vendedor: vendedor_usuario.nm_fantasia_vendedor,
    };

    await this.buscaEquipe(1, true);

    const lookup_dados_empresa_faturamento = await Lookup.montarSelect(
      this.cd_empresa,
      5137
    );

    this.lookup_dataset_empresa_faturamento = JSON.parse(
      JSON.parse(JSON.stringify(lookup_dados_empresa_faturamento.dataset))
    );
    const lookup_dados_tipo_pedido = await Lookup.montarSelect(
      this.cd_empresa,
      202
    );
    this.lookup_dataset_tipo_pedido = JSON.parse(
      JSON.parse(JSON.stringify(lookup_dados_tipo_pedido.dataset))
    );
    if (this.prop_form.cd_movimento != undefined) {
      await this.ContinuaAlteracao();
    } else {
      await this.carregaDados();
    }
    this.tituloMenu = "Ficha de Venda";
  },
  mounted() {
    this.timelineI.cd_empresa = this.cd_empresa;
    this.timelineI.dt_inicial = localStorage.dt_inicial;
    this.timelineI.dt_final = localStorage.dt_final;
  },

  components: {
    DxButton,
    cliente,
    socio,
    DxTextBox,
    grid,
    lookup,
    listagem,
    carregando: () => import("../components/carregando.vue"),
    timeline: () => import("../views/timeline.vue"),
    card: () => import("../components/alertCard.vue"),
  },
  watch: {
    async step(a, b) {
      if (a == 5) {
        this.ConsultaDoc();
      }
      if (a == 3) {
        await this.sleep(2000);
        var tamanho = this.$refs.grid_cota.DataSource();

        if (tamanho == 0) {
          await this.$refs.grid_cota.carregaDados();
        }
      } else if (a == 4) {
        await this.sleep(2000);
        var tamanho = this.$refs.grid_cota.DataSource();
        if (tamanho == 0) {
          await this.$refs.divisaovenda.carregaDados();
        }
      }
    },
  },
  methods: {
    async Download(b) {
      this.carregando = true;

      try {
        let blob = await ftp.Download(this.cd_empresa, b.nm_obs_documento);

        const link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = b.nm_contrato_documento;
        link.click();
        URL.revokeObjectURL(link.href);
        this.carregando = false;
      } catch (error) {
        this.carregando = false;
      }
    },
    async atualizaCotas() {
      if (this.botao_cadastra_altera == false) return;
      let api_i = "456/624"; //pr_cadastra_contrato_consorcio
      let dados = {
        cd_contrato: this.cd_contrato,
        qt_cota_contrato: this.qt_cota_contrato,
        cd_parametro: 10,
      };
      let a = await Incluir.incluirRegistro(api_i, dados);
      notify(a[0].Msg);
    },
    async BuscaEquipeDivisaoVenda(e) {
      this.equipe_disisao_venda = [];
      let i = 1;
      for (let a = 0; a < this.qt_vendedores; a++) {
        let v = document.getElementsByName("nome" + i)[0].value;
        await this.buscaEquipe(2, false, v);
        i++;
      }
    },
    async carregaGrids(index) {
      if (index == 1) {
        await this.$refs.grid_cota.carregaDados();
      } else if (index == 2) {
        await this.$refs.divisaovenda.carregaDados();
      }
    },
    async ConsultaDoc() {
      notify("Carregando documentos...");
      this.lista_documentos = [];
      let c = {
        cd_parametro: 9,
        cd_contrato: this.cd_contrato,
      };

      this.lista_documentos = await Incluir.incluirRegistro("606/844", c);
    },

    async blurEventHandler(e) {
      var value = e.target.value;
      e.target.value = await funcao.FormataValor(value);
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

    async onConsultar() {
      this.consulta_contrato_consorcio = 1;
      this.contrato_aprovacao = false;
      this.MostraCotas = true;
      this.MostraVendedor = true;
      this.alteracao = true;
      this.botao_cadastra_altera = false;
      this.botao_cadastra = false;

      let api = "442/597"; //1323 - pr_consulta_ficha_venda
      let contrato = grid.Selecionada().cd_contrato;
      localStorage.cd_parametro = 1;
      localStorage.cd_identificacao = contrato;
      this.data_consulta = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        "/${cd_empresa}/${cd_parametro}/${cd_usuario}/${cd_identificacao}"
      );
      this.dt_contrato = this.data_consulta[0].dt_contrato;
      this.qt_cota_contrato = this.data_consulta[0].qt_cota_contrato;
      //aqui cd_cliente
      this.nm_cliente = this.data_consulta[0].nm_fantasia_cliente;
      this.cd_status_contrato = this.data_consulta[0].cd_status_contrato;
      if (
        this.cd_status_contrato == 6 ||
        this.cd_status_contrato == 7 ||
        this.cd_status_contrato == 9 ||
        this.cd_status_contrato == 10
      ) {
        this.consulta_contrato_consorcio = 1;
      }

      this.cd_cliente_contrato = this.data_consulta[0].cd_cliente;
      this.cd_tipo_pessoa = this.data_consulta[0].cd_tipo_pessoa;

      if (this.cd_tipo_pessoa == 1) {
        this.cadastra_socio = false;
      } else {
        this.cadastra_socio = true;
      }
      this.consulta = 0;

      this.cd_contrato = this.data_consulta[0].cd_contrato;
      this.timelineI.cd_movimento = this.cd_contrato;
      var a = this.data_consulta[0].cd_indicador;
      if (a != 0) {
        var index = this.lookup_dataset_vendedor.findIndex(
          (obj) => obj.cd_vendedor == a
        );
        this.captacao = {
          cd_vendedor: this.lookup_dataset_vendedor[index].cd_vendedor,
          nm_fantasia_vendedor:
            this.lookup_dataset_vendedor[index].nm_fantasia_vendedor,
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
      this.url =
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
      await this.buscaEquipe(1, true);

      this.equipe_captacao = this.captacao.cd_vendedor;
      await this.buscaEquipeCaptacao();
      await this.buscaTabela();
      this.nm_fantasia = this.data_consulta[0].nm_razao_contrato;
      this.cd_tabela = this.data_consulta[0].cd_tabela;
      this.cd_cota_contrato = this.data_consulta[0].cd_cota_contrato;
      this.qt_parcelas = this.data_consulta[0].qt_parcela_contrato;
      this.cd_id_contrato = this.data_consulta[0].cd_id_contrato;
      this.status_contrato = this.data_consulta[0].nm_status;
      this.cd_ficha_venda = this.data_consulta[0].cd_ficha_contrato;

      if (this.data_consulta[0].ic_seguro_contrato == "S") {
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

      this.cadastro = false;

      this.vl_total_contrato = this.data_consulta[0].vl_total_contrato;
    },

    async adicionarDocumento() {
      this.carregando = true;
      try {
        for (let y = 0; y < this.getDoc.length; y++) {
          const file = this.getDoc[y];

          let envio = await ftp.Upload(file, this.cd_empresa);
          const nameFile = envio.envio.Arquivo;

          let arq = {
            cd_parametro: 7,
            nm_documento: file.name,
            cd_usuario: this.cd_usuario,
            cd_tipo_documento: this.nm_documento.cd_tipo_documento,
            cd_etapa: localStorage.cd_kan,
            cd_modulo: this.cd_modulo,
            cd_ficha_venda: this.cd_contrato,
            nm_observacao: funcao.ValidaString(this.ds_documento),
            nm_documento_interno: nameFile,
            nm_caminho_documento: "EGISNET/" + this.cd_empresa,
          };
          var inclu = await Incluir.incluirRegistro("606/844", arq);
          notify(inclu[0].Msg);
          this.getDoc = [];
          this.nm_documento = "";
          this.ds_documento = "";
          await funcao.sleep(5000);
          this.ConsultaDoc();
        }

        this.carregando = false;
      } catch (error) {
        this.carregando = false;
      }
    },

    sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },

    removeDocumento(n) {
      this.todosDocumentos.splice(n - 1, n);
    },

    abrirDoc() {},

    async mostraCotas() {
      var api_cota = "492/695"; //pr_consulta_cotas_contrato
      var paramApi = "/${cd_empresa}/${cd_parametro}";
      this.cadastrar_cota = true;
      localStorage.cd_parametro = this.cd_contrato;
      var dados_cota = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api_cota,
        paramApi
      );

      if (dados_cota == []) {
        notify("Nenhuma cota cadastrada!");
      } else {
        let index = 1;
        for (let i = 0; i < dados_cota.length; i++) {
          document.getElementsByName("qt_cota_contrato" + index)[0].value =
            dados_cota[i].qt_cota_contrato;
          document.getElementsByName("vl_cota_contrato" + index)[0].value =
            dados_cota[i].vl_cota_contrato;
          document.getElementsByName("cd_cota" + index)[0].value =
            dados_cota[i].nm_ref_cota;
          document.getElementsByName("cd_grupo" + index)[0].value =
            dados_cota[i].cd_grupo_contrato;
          document.getElementsByName("qt_prazo" + index)[0].value =
            dados_cota[i].qt_prazo_contrato;
          if (dados_cota[i].cd_tabela > 0) {
            document.getElementsByName("cd_tabela" + index)[0].value =
              dados_cota[i].cd_tabela;
            this.lookup_dataset_tabela.cd_tabela = dados_cota[i].cd_tabela;
          }
          if (dados_cota[i].vl_primeira_parcela != "") {
            document.getElementsByName("vl_primeira_parcela" + index)[0].value =
              dados_cota[i].vl_primeira_parcela;
          }

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

      var api_i = "456/624"; //1333 - pr_cadastra_contrato_consorcio

      var seguroA = "";
      if (this.seguro == true) {
        seguroA = "S";
      } else {
        seguroA = "N";
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
        ic_parametro: 1,
        cd_parametro: 1, //Cadastra ficha de Venda
        cd_tipo_venda: this.nm_tipo_venda.cd_tipo_pedido,
        dt_contrato: data_contrato,
        qt_cota_contrato: this.qt_cota_contrato,
        cd_administradora: this.administradora.cd_administradora,
        cd_cliente: 0,
        cd_tabela: this.tabela.cd_tabela,
        cd_vendedor: this.vendedor.cd_vendedor,
        vl_contrato: this.vl_total_contrato,
        cd_indicador: this.captacao.cd_vendedor,
        ic_seguro_contrato: seguroA,
        qt_parcela_contrato: this.qt_parcelas,
        qt_prazo_contrato: this.qt_prazo_contrato,
        cd_empresa: this.empresa_faturamento.cd_empresa,
        cd_id_contrato: this.cd_id_contrato,
        cd_usuario: this.cd_usuario,
        cd_usuario_inclusao: this.cd_usuario,
      };
      this.carregando = true;
      let a = await Incluir.incluirRegistro(api_i, dados);
      notify(a[0].Msg);

      this.cd_contrato = a[0].cd_codigo;
      this.cd_id_contrato = dados.cd_id_contrato;
      this.hoje = this.hoje.replace("-", "/");

      this.cd_ficha_venda = a[0].cd_ficha_venda;

      if (a[0].cd_codigo !== undefined) {
        this.botao_cadastra_altera = true;
        this.botao_cadastra = false;
      } else {
        this.botao_cadastra_altera = false;
      }
      this.carregando = false;
      //this.AlterarFichaVenda()
    },

    AbreListagem() {
      //VERIFICA SE TEM FICHA DE VENDA NO ONROWCHANGE
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
      //this.hoje = formataData.formataDataSQL(this.hoje);
      var data_contrato = formataData.formataDataSQL(this.dt_contrato);
      if (data_contrato == "--") {
        data_contrato = formataData.formataDataSQL(this.hoje);
        this.dt_contrato = this.hoje;
      }

      var seguroA = "";
      var api_i = "456/624"; //pr_cadastra_contrato_consorcio
      if (this.seguro == true) {
        seguroA = "S";
      } else {
        seguroA = "N";
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
        cd_contrato: this.cd_contrato,
        ic_parametro: 2,
        cd_tipo_venda: this.nm_tipo_venda.cd_tipo_pedido,
        cd_parametro: 1, //Cadastra ficha de Venda
        dt_contrato: data_contrato,
        cd_administradora: this.administradora.cd_administradora,
        qt_cota_contrato: this.qt_cota_contrato,
        cd_cliente: 0,
        cd_tabela: this.tabela.cd_tabela,
        cd_vendedor: this.vendedor.cd_vendedor,
        vl_contrato: this.vl_total_contrato,
        cd_indicador: this.captacao.cd_vendedor,
        ic_seguro_contrato: seguroA,
        qt_parcela_contrato: this.qt_parcelas,
        qt_prazo_contrato: this.qt_prazo_contrato,
        cd_empresa: this.empresa_faturamento.cd_empresa,
        cd_id_contrato: this.cd_id_contrato,
        cd_usuario: this.cd_usuario,
        cd_usuario_inclusao: this.cd_usuario,
        cd_certeza: this.cd_certeza,
      };
      var a = await Incluir.incluirRegistro(api_i, dados);
      if (a[0].retorno) {
        this.cd_tipo_validacao = 0;
        this.dif_valor = true;
        this.nm_dif_valor =
          "As soma das cotas do contrato estão diferentes do valor do Contrato";
      }
      notify(a[0].Msg);

      var api_consulta = "486/689";
      localStorage.cd_parametro = this.cd_contrato;
      this.parcelas_contrato = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api_consulta,
        "/${cd_empresa}/${cd_parametro}"
      );
      localStorage.cd_parametro = 0;

      this.cd_certeza = false;
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
    },

    async buscaEquipe(index, A, B) {
      var api = "487/690";
      var paramApi = "/${cd_empresa}/${cd_parametro}";

      if (A == true) {
        localStorage.cd_parametro = this.vendedor.cd_vendedor;
      } else {
        localStorage.cd_parametro = B;
      }
      var e = await Procedimento.montarProcedimento(
        localStorage.cd_empresa,
        localStorage.cd_cliente,
        api,
        paramApi
      );
      if (e.length == 0) {
        return;
      }
      if (index == 1) {
        this.equipe = e[0].nm_equipe;
      } else {
        this.equipe_disisao_venda.push(e[0].nm_equipe);
      }
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
        paramApi
      );
      this.equipe_captacao = this.equipe_captacao[0].nm_equipe;
      localStorage.cd_parametro = 0;
    },

    async selecionaCliente(e) {
      this.cadastro = null;
      this.cd_cliente_contrato = e.cd_cliente;
      this.cd_tipo_pessoa = e.cd_tipo_pessoa;
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
    },

    async onSolicitar() {
      if (this.aceite != true) {
        notify("É necessário o aceite dos termos para prosseguir!");
        return;
      }

      var api_s = "456/624"; //1333 - pr_cadastra_contrato_consorcio
      var dados = {
        cd_ficha_venda: this.cd_ficha_venda,
        cd_parametro: 7,
        cd_contrato: this.cd_contrato,
        cd_tipo_aprovacao: 1,
        cd_item_aprovacao: 1,
      };
      //
      this.carregando = true;
      var result = await Incluir.incluirRegistro(api_s, dados);
      this.carregando = false;
      notify(result[0].Msg);
      //if (result[0].Cod == 0) return;
      this.cd_status_contrato = 6;

      this.limpaTudo();
    },

    async gravarCotas() {
      let indexFor = 1;
      let totalCotas = 0;
      let totalVenda = 0;
      let cotas;
      let valorCota;

      for (let i = 0; i < 4; i++) {
        cotas = document.getElementsByName("qt_cota_contrato" + indexFor)[0]
          .value;
        !!cotas == false ? (cotas = 0) : "";
        valorCota = document.getElementsByName("vl_cota_contrato" + indexFor)[0]
          .value;
        valorCota = valorCota
          .replaceAll("R$", "")
          .replaceAll(".", "")
          .replaceAll(",", ".");
        !!valorCota == false ? (valorCota = 0) : "";

        totalVenda =
          parseFloat(totalVenda) + parseInt(cotas) * parseFloat(valorCota);
        indexFor = indexFor + 1;

        totalCotas = parseInt(totalCotas) + parseInt(cotas);
      }

      if (totalCotas == NaN) {
        notify("Digite as cotas!");
        return;
      }

      if (totalCotas != this.qt_cota_contrato) {
        this.infoCard = {
          nm_icon: "warning",
          nm_texto_titulo: "Quantidade de Cotas divergentes!",
          nm_descritivo:
            "O total de cotas da ficha de venda não corresponde com a quantidade digitada!",
          cd_tipo_layout: 0,
          nm_cor_icon: "warning",
        };
        this.alertCard = true;

        return;
      }

      if (
        totalVenda !=
        parseFloat(
          this.vl_total_contrato
            .replaceAll("R$", "")
            .replaceAll(".", "")
            .replaceAll(",", ".")
        )
      ) {
        this.infoCard = {
          nm_icon: "attach_money",
          nm_texto_titulo: "Valores Divergentes",
          nm_descritivo:
            "A soma do valor das cotas deve ser igual ao valor total da venda!",
          cd_tipo_layout: 0,
          nm_cor_icon: "negative",
        };
        this.alertCard = true;

        return;
      }
      //Final de todas a verioficações, onde ele envia pro back-end os dados
      this.MostraCotas = false;
      this.validado = false;

      this.carregando = true;
      const api_c = "456/624"; //1333 - pr_cadastra_contrato_consorcio

      let indexEnvio = 1;
      for (let p = 0; p < 4; p++) {
        const qt_cota_contrato = parseInt(
          document.getElementsByName("qt_cota_contrato" + indexEnvio)[0].value
        );
        const cd_grupo = document.getElementsByName("cd_grupo" + indexEnvio)[0]
          .value;
        const cd_tabela = document.getElementsByName(
          "cd_tabela" + indexEnvio
        )[0].value;
        const qt_prazo_cota = document.getElementsByName(
          "qt_prazo" + indexEnvio
        )[0].value;
        const vl_cota_contrato = document.getElementsByName(
          "vl_cota_contrato" + indexEnvio
        )[0].value;
        const nm_ref_cota = document.getElementsByName(
          "cd_cota" + indexEnvio
        )[0].value;
        const qt_primeira_parcela = document.getElementsByName(
          "vl_primeira_parcela" + indexEnvio
        )[0].value;
        const envio = {
          cd_contrato: this.cd_contrato,
          cd_parametro: 9,
          qt_cota_contrato: qt_cota_contrato,
          //cd_cota: indexEnvio,
          cd_grupo: cd_grupo,
          cd_tabela: cd_tabela,
          qt_prazo_contrato: qt_prazo_cota,
          cd_usuario: this.cd_usuario,
          vl_cota_contrato: vl_cota_contrato,
          nm_ref_cota: funcao.ValidaString(nm_ref_cota),
          cd_cota_contrato: indexEnvio,
          vl_primeira_parcela: qt_primeira_parcela,
        };

        if (envio.qt_cota_contrato != NaN) {
          const retorno = await Incluir.incluirRegistro(api_c, envio); // 1333-pr_cadastra_contrato_consorcio
          notify(retorno[0].Msg);
        }

        indexEnvio = indexEnvio + 1;
        await this.sleep(300);
      }
      this.carregando = false;
      this.cadastrar_cota = false;
      this.MostraCotas = true;
    },

    FormataValor(a, e, r, t) {
      //function moeda(a, e, r, t) {
      let n = "",
        h = (j = 0),
        u = (tamanho2 = 0),
        l = (ajd2 = ""),
        o = window.Event ? t.which : t.keyCode;
      if (13 == o || 8 == o) return !0;
      if (((n = String.fromCharCode(o)), -1 == "0123456789".indexOf(n)))
        return !1;
      for (
        u = a.value.length, h = 0;
        h < u && ("0" == a.value.charAt(h) || a.value.charAt(h) == r);
        h++
      );
      for (l = ""; h < u; h++)
        -1 != "0123456789".indexOf(a.value.charAt(h)) &&
          (l += a.value.charAt(h));
      if (
        ((l += n),
        0 == (u = l.length) && (a.value = ""),
        1 == u && (a.value = "0" + r + "0" + l),
        2 == u && (a.value = "0" + r + l),
        u > 2)
      ) {
        for (ajd2 = "", j = 0, h = u - 3; h >= 0; h--)
          3 == j && ((ajd2 += e), (j = 0)), (ajd2 += l.charAt(h)), j++;
        for (
          a.value = "", tamanho2 = ajd2.length, h = tamanho2 - 1;
          h >= 0;
          h--
        )
          a.value += ajd2.charAt(h);
        a.value += r + l.substr(u - 2, u);
      }
      return !1;
    },

    async onGravaDivisao() {
      let valorTotal = 0;
      let indexConferencia = 1;
      for (let p = 0; p < this.qt_vendedores; p++) {
        let valorPc = document.getElementsByName("pc" + indexConferencia)[0]
          .value;
        valorTotal =
          valorTotal +
          parseFloat(valorPc.replaceAll(",", ".").replaceAll("%", ""));
        indexConferencia = indexConferencia + 1;
      }
      if (valorTotal > 100) {
        notify("O valor deve ser menor que 100%!");
        return;
      }

      const api_c = "456/624";

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
              cd_usuario: this.cd_usuario,
              cd_ficha_venda: this.cd_ficha_venda,
              cd_ordem: i,
              cd_parametro: 5,
              cd_contrato: this.cd_contrato,
              cd_vendedor: a,
              pc_comissao: b,
            };
            let retorno = await Incluir.incluirRegistro(api_c, dados);
            notify(retorno[0].Msg);
            this.$refs.divisaovenda.carregaDados();
          }
        } else {
          let i = 0;
          if (valor == 100) {
            this.carregando = true;
            for (i = 1; i <= this.qt_vendedores; i++) {
              var a = document.getElementsByName("nome" + i)[0].value;
              var b = document.getElementsByName("pc" + i)[0].value;

              const dados = {
                cd_usuario: this.cd_usuario,
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
            this.carregando = false;
          } else {
            notify("Digite uma porcentagem que some 100");
          }
        }
      }
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
        sApi
      );
    },

    async onGravarCliente() {
      var api = "456/624";
      let continua = await this.$refs.consulta_cliente.onGravar();
      if (continua == false) {
        return;
      }

      var dados = {
        cd_ficha_venda: this.cd_ficha_venda,
        ic_parametro: 2,
        cd_parametro: 2,
        cd_contrato: this.cd_contrato,
        cd_usuario: this.cd_usuario,
        cd_usuario_inclusao: this.cd_usuario,
        cd_cliente: this.cd_cliente_contrato,
        cd_item_cadastro: 1,
      };

      var s = await Incluir.incluirRegistro(api, dados);
      notify(s[0].Msg);
      if (this.cd_tipo_pessoa == 1) {
        this.step = 2;
      } else {
        this.step = 3;
      }
    },

    async onGravarSocio() {
      this.validado = false;
      var a = await this.$refs.cadastro_socio.gravaSocio();
      if (a.substring(0, 5) == "Sócio") {
        this.validado = true;
        notify(a);
        this.step = 3;
      } else {
        notify(a);
        this.validado = false;
      }
    },

    cadastra_cliente() {
      this.cliente_popup = true;
    },

    async CarregaCotas() {
      var api = "454/618"; // Procedimento - 1332 pr_consulta_contrato_cotas
      localStorage.cd_parametro = this.cd_contrato;
      var dados_cotas = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        "/${cd_empresa}/${cd_parametro}"
      );

      this.qt_cota_contrato = dados_cotas[0].qt_cota_contrato;
      this.vl_cota_contrato = dados_cotas[0].vl_cota_contrato;
      this.pc_cota_contrato = dados_cotas[0].pc_cota_contrato;
      this.vl_cota_parcela = dados_cotas[0].vl_cota_parcela;
      this.dt_vencimento_cota = formataData.formataDataJS(
        this.dt_vencimento_cota
      );
    },

    async ContinuaAlteracao() {
      let contrato;
      this.contrato_aprovacao = false;
      this.MostraCotas = true;
      this.MostraVendedor = true;
      this.alteracao = true;
      this.botao_cadastra_altera = true;
      this.botao_cadastra = false;
      let api = "442/597"; //pr_consulta_ficha_venda
      if (this.prop_form.cd_movimento != undefined) {
        contrato = this.prop_form.cd_movimento;
        this.cd_ficha_venda = this.prop_form.cd_movimento;
      } else {
        contrato = grid.Selecionada().cd_contrato;
      }
      localStorage.cd_parametro = 1;
      localStorage.cd_identificacao = contrato;
      this.data_consulta = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        api,
        "/${cd_empresa}/${cd_parametro}/${cd_usuario}/${cd_identificacao}"
      );
      if (this.data_consulta[0].cd_status_contrato == 6) {
        this.msg_aprovacao =
          "O Contrato " +
          this.data_consulta[0].cd_contrato +
          " já está em Aprovação. Não é possível alterar um contrato em Aprovação!";
        this.contrato_aprovacao = true;
        return;
      }
      this.dt_contrato = this.data_consulta[0].dt_contrato;

      this.empresa_faturamento = {
        cd_empresa: this.data_consulta[0].cd_empresa,
        nm_fantasia_empresa: this.data_consulta[0].nm_fantasia_empresa,
      };
      this.url =
        "http://www.egisnet.com.br/img/EmpresaFatInter/" +
        this.data_consulta[0].nm_logotipo_empresa;
      this.qt_cota_contrato = this.data_consulta[0].qt_cota_contrato;
      this.vl_total_contrato = this.data_consulta[0].vl_total_contrato;

      this.cd_status_contrato = this.data_consulta[0].cd_status_contrato;
      if (
        this.cd_status_contrato == 6 ||
        this.cd_status_contrato == 7 ||
        this.cd_status_contrato == 9 ||
        this.cd_status_contrato == 10
      ) {
        this.consulta_contrato_consorcio = 1;
      }

      this.cd_cliente_contrato = this.data_consulta[0].cd_cliente;
      this.cd_tipo_pessoa = this.data_consulta[0].cd_tipo_pessoa;

      if (this.cd_tipo_pessoa == 1) {
        this.cadastra_socio = false;
      } else {
        this.cadastra_socio = true;
      }

      this.consulta = 0;
      if (this.prop_form != {}) {
        this.step = this.prop_form.cd_step;
      }

      this.cd_contrato = this.data_consulta[0].cd_contrato; //denovo
      this.timelineI.cd_movimento = this.cd_contrato;

      var a = this.data_consulta[0].cd_indicador;
      if (a != 0) {
        var index = this.lookup_dataset_vendedor.findIndex(
          (obj) => obj.cd_vendedor == a
        );

        this.captacao = {
          cd_vendedor: this.lookup_dataset_vendedor[index].cd_vendedor,
          nm_fantasia_vendedor:
            this.lookup_dataset_vendedor[index].nm_fantasia_vendedor,
        };
      }

      this.administradora = {
        cd_administradora: this.data_consulta[0].cd_administradora,
        nm_administradora: this.data_consulta[0].nm_administradora,
      };
      await this.buscaTabela();
      this.vendedor = {
        cd_vendedor: this.data_consulta[0].cd_vendedor,
        nm_fantasia_vendedor: this.data_consulta[0].nm_vendedor,
      };

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

      this.equipe_captacao = this.captacao.cd_vendedor;

      //this.cd_cliente           = this.data_consulta[0].cd_cliente        ;
      this.nm_fantasia = this.data_consulta[0].nm_razao_contrato;
      this.cd_tabela = this.data_consulta[0].cd_tabela;
      this.cd_cota_contrato = this.data_consulta[0].cd_cota_contrato;
      this.vl_contrato = this.data_consulta[0].vl_contrato;
      this.qt_parcelas = this.data_consulta[0].qt_parcela_contrato;
      this.cd_id_contrato = this.data_consulta[0].cd_id_contrato;
      this.status_contrato = this.data_consulta[0].nm_status;
      this.cd_ficha_venda = this.data_consulta[0].cd_ficha_contrato;
      if (this.data_consulta[0].ic_seguro_contrato == "S") {
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

      this.empresa_faturamento.cd_empresa_faturamento =
        this.data_consulta[0].cd_empresa;
      //this.cadastro = false;
      //this.cadastrar();
      this.cadastro = false;
      this.getDoc = [];
      //this.CarregaCotas();

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
      await this.buscaEquipe(1, true);
      await this.buscaEquipeCaptacao();
      this.step = 1;
      //this.cadastrar();
      this.nm_fantasia = this.data_consulta[0].nm_fantasia_cliente;
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
      this.carregando = true;
      await this.limpaTudo();
      this.dt_contrato = new Date().toLocaleDateString("pt-br");
      this.consulta_contrato_consorcio = 0;
      this.consulta = 0;
      this.cadastro = true;
      this.carregando = false;
      this.botao_cadastra = true;
      this.botao_cadastra_altera = false;
      let vendedor_usuario = await funcao.buscaVendedor(this.cd_usuario);
      this.vendedor = {
        cd_vendedor: vendedor_usuario.cd_vendedor,
        nm_fantasia_vendedor: vendedor_usuario.nm_fantasia_vendedor,
      };
      if (vendedor_usuario.nm_equipe != "") {
        this.equipe = vendedor_usuario.nm_equipe;
      }
    },

    async buscaTabela() {
      localStorage.cd_parametro = this.administradora.cd_administradora;

      this.lookup_dataset_tabela = await Procedimento.montarProcedimento(
        this.cd_empresa,
        this.cd_cliente,
        "458/631",
        "/${cd_empresa}/${cd_parametro}"
      );

      this.lookup_dataset_tabela = JSON.parse(
        JSON.parse(JSON.stringify(this.lookup_dataset_tabela[0].dataset))
      );
    },

    adicionarVendedor() {
      if (this.qt_vendedores == "") {
        this.qt_vendedores = 1;
      }
      this.cadastrar_divisao = true;
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
        localStorage.nm_fantasia = this.nm_fantasia;
        localStorage.nm_razao_social = "null";
        localStorage.cd_parametro = 0;
        var dados = [];
        let api_consulta = "405/542";
        this.carregando = true;
        dados = await Procedimento.montarProcedimento(
          this.cd_empresa,
          this.cd_cliente,
          api_consulta,
          "/${cd_empresa}/${cd_parametro}/${nm_fantasia}/${nm_razao_social}"
        );
        if (dados == "") {
          this.cliente_nao_encontrado = true;
          this.carregando = false;
          return;
        }
        this.carregando = false;
        if (dados[0].status == "false") {
          this.cliente_popup = true;
        } else {
          //this.cliente_popup = false;
          this.cli = true;
          this.clientes_encontrados = dados;
        }
      }
    },
    FormataTotal() {
      if (this.vl_total_contrato == "" || this.vl_total_contrato == "0") return;
      if (
        this.valor_total_contrato == "" ||
        this.valor_total_contrato == "R$ NaN" ||
        this.valor_total_contrato == undefined
      ) {
        this.valor_total_contrato = 0;
      }
      if (this.vl_total_contrato.includes("R$") == false) {
        let valor = this.vl_total_contrato;

        if (valor.includes("R$") == true) {
          valor = valor.replace("R$", " ");
        }

        if (valor.includes(",") == true) {
          valor = valor.replace(",", ".");
        }
        valor = parseFloat(valor);
        this.vl_total_contrato = valor.toLocaleString("pt-BR", {
          style: "currency",
          currency: "BRL",
        });
      }
    },
    limpaTudo() {
      this.cd_ficha_venda = 0;
      this.consulta = 1;
      this.seguro = false;
      this.nm_cliente = "";
      this.cd_tabela = 0;
      this.vl_contrato = "";
      this.nm_tabela = "";
      this.ic_seguro = false;
      this.vl_parcela_contrato = "";
      this.step = 1;
      this.bt_esconde_prox = "";
      this.bt_esconde_fim = 1;
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
      this.prop_form = {};
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
      this.empresa_faturamento = "";
      this.administradora = "";
      this.captacao = "";
      this.tabela = "";
      this.cliente_popup = false;
      this.cd_tipo_pessoa = "";
      this.cadastrar_divisao = false;
      this.nm_documento = "";
      this.documento = "";
      this.validado = "";
      this.todosDocumentos = "";
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

<style scoped>
@import url("./views.css");
.select {
  width: 22%;
  height: 22%;
  font-size: 15px;
  border-radius: 10px;
}
.input_vendedor {
  width: 45%;
  border-radius: 5px;
  margin: 5px;
}
.column {
  height: 20px !important;
}

.botao-gravar-step {
  margin: 5px;
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

.fundo-img {
  background: rgb(211, 211, 211);
  border-radius: 5px;
}
.borda-bloco {
  border: solid 1px rgb(170, 170, 170);
  border-radius: 10px;
}
.banner {
  max-width: 450px;
}
.borda-branca {
  border: white 1px solid;
  border-radius: 5px;
}
.padding1 {
  padding: 2px;
}

.informativo {
  font-weight: 600;
  font-size: 24px;
}
</style>
