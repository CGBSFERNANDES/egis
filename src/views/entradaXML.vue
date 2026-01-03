<template>
  <div class="q-pa-sm">

    <!-- Topo (identidade) -->
    <div class="row items-center no-wrap toolbar-scroll">
      <h2 class="content-block col-12 row items-center no-wrap">

        <q-btn
          flat
          round
          dense
          icon="arrow_back"
          class="q-mr-sm seta-form"
          aria-label="Voltar"
          @click="onVoltar"
        ></q-btn>

        <span class="text-weight-bold">{{ titleComputed }}</span>

        <q-badge
          v-if="itens.length > 0"
          align="middle"
          rounded
          color="red"
          :label="itens.length"
          class="q-ml-sm bg-form"
        ></q-badge>

        <!-- Origem do XML (NFSE / CTE) -->
        <div class="row items-center q-gutter-sm q-ml-md">

          <q-select
            v-model="tipoDoc"
            dense
            outlined
            emit-value
            map-options
            :options="tipoDocOptions"
            style="min-width: 190px"
            label="Tipo de documento"
          />

          <q-select
            v-model="origemDados"
            dense
            outlined
            emit-value
            map-options
            :options="origemOptions"
            style="min-width: 190px"
            label="Origem dos dados"
          />

          <q-select
            v-if="origemDados === 'XML_EXISTENTE'"
            v-model="xmlSelecionadoId"
            dense
            outlined
            emit-value
            map-options
            :options="listaXml"
            option-value="id"
            option-label="label"
            style="min-width: 260px"
            label="XML"
            @input="carregarXmlSelecionado"
          />

          <q-btn
            v-if="origemDados === 'XML_EXISTENTE'"
            dense
            rounded
            color="deep-purple-7"
            icon="save"
            class="q-ml-xs"
            :disable="!xmlConteudo"
            :loading="loadingSalvarXml"
            @click="salvarXmlEditado"
          >
            <q-tooltip>Salvar XML</q-tooltip>
          </q-btn>

          <q-btn
            v-if="origemDados === 'MANUAL'"
            dense
            rounded
            color="deep-purple-7"
            icon="save_alt"
            class="q-ml-xs"
            :loading="loadingSalvarXml"
            @click="salvarManual"
          >
            <q-tooltip>Salvar (digitação manual)</q-tooltip>
          </q-btn>

        </div>


        <q-space></q-space>

        <q-btn
          dense
          rounded
          color="deep-purple-7"
          icon="upload_file"
          class="q-ml-sm"
          size="lg"
          @click="abrirEntradaXml = true"
        >
          <q-tooltip>Entrada XML</q-tooltip>
        </q-btn>

        <q-btn
          dense
          rounded
          color="deep-purple-7"
          icon="check"
          class="q-ml-sm"
          size="lg"
          :loading="loadingProcessar"
          @click="processarXmlNoBanco"
        >
          <q-tooltip>Processar no banco (procedure)</q-tooltip>
        </q-btn>

        <q-btn
          dense
          rounded
          color="deep-purple-7"
          icon="save"
          class="q-ml-sm"
          size="lg"
          :loading="loadingSalvar"
          @click="salvarEdicao"
        >
          <q-tooltip>Salvar edição (payload)</q-tooltip>
        </q-btn>

        <q-btn
          dense
          rounded
          color="deep-purple-7"
          icon="refresh"
          class="q-ml-sm"
          size="lg"
          @click="limparTudo"
        >
          <q-tooltip>Limpar</q-tooltip>
        </q-btn>

      </h2>
    </div>

    <q-card class="q-pa-md">
      

      <!-- Painel de XML / Digitação Manual (NFSE / CTE) -->
      <q-card-section class="q-pt-none">
        <div v-if="origemDados === 'XML_EXISTENTE'">
          <q-input
            v-model="xmlConteudo"
            type="textarea"
            autogrow
            outlined
            dense
            label="Conteúdo XML"
          />
        </div>

        <div v-else class="row q-col-gutter-sm">
          <div class="col-12 col-md-3">
            <q-input v-model="manual.numero" dense outlined label="Número" />
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="manual.serie" dense outlined label="Série" />
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="manual.dataEmissao" dense outlined label="Emissão (YYYY-MM-DD)" />
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model.number="manual.valor" type="number" dense outlined label="Valor" />
          </div>

          <div class="col-12 col-md-6">
            <q-input v-model="manual.emitenteNome" dense outlined label="Prestador/Emitente" />
          </div>
          <div class="col-12 col-md-6">
            <q-input v-model="manual.destinatarioNome" dense outlined label="Tomador/Destinatário" />
          </div>
        </div>

        <q-separator spaced />
      </q-card-section>

<q-card-section class="row no-wrap items-start q-gutter-md">

        <!-- Identidade visual (estilo modal) -->
        <div class="col-auto flex flex-center bg-deep-purple-1 q-pa-lg" style="border-radius: 80px;">
          <q-icon name="description" size="56px" color="deep-purple-7"></q-icon>
        </div>

        <div class="col">

          <!-- Resumo -->
          <div class="row items-center q-col-gutter-md q-mb-sm">
            <div class="col-12 col-md-6">
              <div class="text-caption text-grey-7">Chave</div>
              <div class="text-subtitle2">{{ nfe.chNFe || '-' }}</div>
            </div>
            <div class="col-6 col-md-2">
              <div class="text-caption text-grey-7">Número</div>
              <div class="text-subtitle2">{{ nfe.nNF || '-' }}</div>
            </div>
            <div class="col-6 col-md-2">
              <div class="text-caption text-grey-7">Série</div>
              <div class="text-subtitle2">{{ nfe.serie || '-' }}</div>
            </div>
            <div class="col-12 col-md-2">
              <div class="text-caption text-grey-7">Valor</div>
              <div class="text-subtitle2">{{ valorNfFormatado }}</div>
            </div>
          </div>

          <q-separator spaced></q-separator>

          <!-- Tabs -->
          <q-tabs v-model="tab" dense active-color="deep-purple-7" indicator-color="deep-purple-7" align="left">
            <q-tab name="nfe" label="NFE"></q-tab>
            <q-tab name="emit" label="Emitente"></q-tab>
            <q-tab name="dest" label="Destinatário"></q-tab>
            <q-tab name="itens" label="Produtos e Serviços"></q-tab>
            <q-tab name="totais" label="Totais"></q-tab>
            <q-tab name="transp" label="Transporte"></q-tab>
            <q-tab name="cobr" label="Cobrança"></q-tab>
            <q-tab name="inf" label="Informações Adicionais"></q-tab>
            <q-tab name="eventos" label="Eventos"></q-tab>

          </q-tabs>

          <q-separator></q-separator>

          <q-tab-panels v-model="tab" animated>

            <q-tab-panel name="nfe">
              <div class="row q-col-gutter-sm">
                <div class="col-12 col-md-6">
                  <q-input v-model="nfe.natOp" dense outlined label="Natureza da Operação"></q-input>
                </div>
                <div class="col-4 col-md-2">
                  <q-input v-model="nfe.mod" dense outlined label="Modelo"></q-input>
                </div>
                <div class="col-4 col-md-2">
                  <q-input v-model="nfe.serie" dense outlined label="Série"></q-input>
                </div>
                <div class="col-4 col-md-2">
                  <q-input v-model="nfe.nNF" dense outlined label="Número NF"></q-input>
                </div>
                <div class="col-12 col-md-4">
                  <q-input v-model="nfe.dhEmi" dense outlined label="Data/Hora Emissão"></q-input>
                </div>
                <div class="col-12 col-md-6">
                   <q-input v-model="nfe.dhSaiEnt" dense outlined label="Data/Hora de Saída ou Entrada"></q-input>
                </div>
                <div class="col-12 col-md-6">
                  <q-input v-model="prot.nProt" dense outlined label="Protocolo de Autorização e Uso"></q-input>
                </div>
                <div class="col-12 col-md-6">
                  <q-input v-model="prot.dhRecbto" dense outlined label="Data/Hora Autorização"></q-input>
                </div>

                <div class="col-12 col-md-4">
                  <q-input v-model="nfe.tpAmb" dense outlined label="Ambiente"></q-input>
                </div>
                <div class="col-12 col-md-4">
                  <q-input v-model="nfe.finNFe" dense outlined label="Finalidade"></q-input>
                </div>
                <!-- Processo / Versão / Tipo Emissão -->
<div class="col-12 col-md-4">
  <q-input v-model="nfe.procEmi" dense outlined label="Processo"></q-input>
</div>
<div class="col-12 col-md-4">
  <q-input v-model="nfe.verProc" dense outlined label="Versão do Processo"></q-input>
</div>
<div class="col-12 col-md-4">
  <q-input v-model="nfe.tpEmis" dense outlined label="Tipo de Emissão (tpEmis)"></q-input>
</div>

<!-- Intermediador / Tipo Operação / Digest -->
<div class="col-12 col-md-4">
  <q-input v-model="nfe.indIntermed" dense outlined label="Intermediador / MarketPlace (indIntermed)"></q-input>
</div>
<div class="col-12 col-md-4">
  <q-input v-model="nfe.tpNF" dense outlined label="Tipo de Operação (tpNF)"></q-input>
</div>
<div class="col-12 col-md-4">
  <q-input v-model="prot.digVal" dense outlined label="Digest Value NF-e (digVal)"></q-input>
</div>

              </div>
            </q-tab-panel>

<q-tab-panel name="emit">

  <div class="text-subtitle2 q-mb-sm">Dados do Emitente</div>

  <div class="row q-col-gutter-sm">
    <div class="col-12 col-md-8">
      <q-input v-model="emit.xNome" dense outlined label="Nome / Razão Social"/>
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="emit.xFant" dense outlined label="Nome Fantasia"/>
    </div>

    <div class="col-12 col-md-4">
      <q-input v-model="emit.CNPJ" dense outlined label="CNPJ"/>
    </div>
    <div class="col-12 col-md-8">
      <q-input v-model="emitEnd.xLgr" dense outlined label="Endereço"/>
    </div>

    <div class="col-12 col-md-4">
      <q-input v-model="emitEnd.xBairro" dense outlined label="Bairro / Distrito"/>
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="emitEnd.CEP" dense outlined label="CEP"/>
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="emitEnd.fone" dense outlined label="Telefone"/>
    </div>

    <div class="col-12 col-md-4">
      <q-input v-model="emitEnd.xMun" dense outlined label="Município"/>
    </div>
    <div class="col-12 col-md-2">
      <q-input v-model="emitEnd.UF" dense outlined label="UF"/>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="emitEnd.cPais" dense outlined label="País"/>
    </div>

    <div class="col-12 col-md-3">
      <q-input v-model="emit.IE" dense outlined label="Inscrição Estadual"/>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="emit.IM" dense outlined label="Inscrição Municipal"/>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="emit.CNAE" dense outlined label="CNAE Fiscal"/>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="emit.CRT" dense outlined label="Código Regime Tributário"/>
    </div>
  </div>

</q-tab-panel>


<q-tab-panel name="dest">

  <div class="text-subtitle2 q-mb-sm">Dados do Destinatário</div>

  <div class="row q-col-gutter-sm">

    <!-- Nome / Razão Social -->
    <div class="col-12">
      <q-input
        v-model="dest.xNome"
        dense
        outlined
        label="Nome / Razão Social"
      />
    </div>

    <!-- CNPJ / Endereço -->
    <div class="col-12 col-md-4">
      <q-input
        v-model="dest.CNPJ"
        dense
        outlined
        label="CNPJ"
      />
    </div>

    <div class="col-12 col-md-8">
      <q-input
        v-model="destEnd.xLgr"
        dense
        outlined
        label="Endereço"
      />
    </div>

    <!-- Bairro / CEP -->
    <div class="col-12 col-md-4">
      <q-input
        v-model="destEnd.xBairro"
        dense
        outlined
        label="Bairro / Distrito"
      />
    </div>

    <div class="col-12 col-md-4">
      <q-input
        v-model="destEnd.CEP"
        dense
        outlined
        label="CEP"
      />
    </div>

    <!-- Município / Telefone -->
    <div class="col-12 col-md-4">
      <q-input
        v-model="destEnd.xMun"
        dense
        outlined
        label="Município"
      />
    </div>

    <div class="col-12 col-md-4">
      <q-input
        v-model="destEnd.fone"
        dense
        outlined
        label="Telefone"
      />
    </div>

    <!-- UF / País -->
    <div class="col-12 col-md-2">
      <q-input
        v-model="destEnd.UF"
        dense
        outlined
        label="UF"
      />
    </div>

    <div class="col-12 col-md-4">
      <q-input
        v-model="destEnd.xPais"
        dense
        outlined
        label="País"
      />
    </div>

    <!-- Indicador IE / Inscrição Estadual / SUFRAMA -->
    <div class="col-12 col-md-4">
      <q-input
        v-model="dest.indIEDest"
        dense
        outlined
        label="Indicador IE"
      />
    </div>

    <div class="col-12 col-md-4">
      <q-input
        v-model="dest.IE"
        dense
        outlined
        label="Inscrição Estadual"
      />
    </div>

    <div class="col-12 col-md-4">
      <q-input
        v-model="dest.SUFRAMA"
        dense
        outlined
        label="Inscrição SUFRAMA"
      />
    </div>

    <!-- IM / Email -->
    <div class="col-12 col-md-4">
      <q-input
        v-model="dest.IM"
        dense
        outlined
        label="Inscrição Municipal"
      />
    </div>

    <div class="col-12 col-md-8">
      <q-input
        v-model="dest.email"
        dense
        outlined
        label="E-mail"
      />
    </div>

  </div>

  <q-separator spaced />

  <!-- Dados da Operação (vem do IDE) -->
  <div class="text-subtitle2 q-mb-sm">Dados da Operação</div>

  <div class="row q-col-gutter-sm">

    <div class="col-12 col-md-4">
      <q-input
        v-model="nfe.idDest"
        dense
        outlined
        label="Destino da Operação"
      />
    </div>

    <div class="col-12 col-md-4">
      <q-input
        v-model="nfe.indFinal"
        dense
        outlined
        label="Consumidor Final"
      />
    </div>

    <div class="col-12 col-md-4">
      <q-input
        v-model="nfe.indPres"
        dense
        outlined
        label="Presença do Consumidor"
      />
    </div>

  </div>

</q-tab-panel>


<q-tab-panel name="itens">

  <div class="text-subtitle2 q-mb-sm">Dados dos Produtos e Serviços</div>

  <!-- MASTER: tabela -->
  <q-table
    :rows="itens"
    :columns="colItens"
    row-key="__id"
    dense
    flat
    separator="cell"
    :pagination="{ rowsPerPage: 8 }"
    @row-click="onClickItem"
  ></q-table>

  <q-separator spaced></q-separator>

  <!-- DETAIL -->
  <div v-if="itemSelecionado" class="q-mt-sm">

    <div class="row items-center q-mb-sm">
      <div class="text-subtitle2">
        Item {{ itemSelecionado.nItem }} | {{ itemSelecionado.prod.xProd }}
      </div>
      <q-space></q-space>
      <q-chip dense color="deep-purple-7" text-color="white">
        vProd: {{ itemSelecionado.prod.vProd || '-' }}
      </q-chip>
    </div>


    <!-- SUB-TABS -->
    <q-tabs v-model="tabProd" dense active-color="deep-purple-7" indicator-color="deep-purple-7" align="left">
      <q-tab name="prod" label="Produto"></q-tab>
      <q-tab name="icms" label="ICMS"></q-tab>
      <q-tab name="ipi" label="IPI"></q-tab>
      <q-tab name="pis" label="PIS"></q-tab>
      <q-tab name="cofins" label="COFINS"></q-tab>
      <q-tab name="ibscbs" label="IBS/CBS"></q-tab>
    </q-tabs>

    <q-separator></q-separator>

    <q-tab-panels v-model="tabProd" animated>

      <!-- PROD -->
      <q-tab-panel name="prod">

  <!-- BLOCO 1: Identificação do Produto -->
  <div class="text-subtitle2 q-mb-xs">Identificação do Produto</div>
  <div class="row q-col-gutter-sm q-mb-sm">
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.cProd" dense outlined label="Código do Produto"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.NCM" dense outlined label="Código NCM"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.CEST" dense outlined label="Código CEST"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.cBenef" dense outlined label="Benefício Fiscal (cBenef)"></q-input>
    </div>

    <div class="col-12">
      <q-input v-model="itemSelecionado.prod.xProd" dense outlined label="Descrição"></q-input>
    </div>

    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.cEAN" dense outlined label="EAN Comercial (cEAN)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.cEANTrib" dense outlined label="EAN Tributável (cEANTrib)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.extIPI" dense outlined label="Código EX TIPI (EXTIPI)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.CFOP" dense outlined label="CFOP"></q-input>
    </div>
  </div>

  <q-separator spaced></q-separator>

  <!-- BLOCO 2: Comercial / Tributável -->
  <div class="text-subtitle2 q-mb-xs">Comercial / Tributável</div>
  <div class="row q-col-gutter-sm q-mb-sm">

    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.uCom" dense outlined label="Unidade Comercial (uCom)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.qCom" dense outlined label="Quantidade Comercial (qCom)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.vUnCom" dense outlined label="Valor Unitário (vUnCom)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.vProd" dense outlined label="Valor do Item (vProd)"></q-input>
    </div>

    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.uTrib" dense outlined label="Unidade Tributável (uTrib)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.qTrib" dense outlined label="Quantidade Tributável (qTrib)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.vUnTrib" dense outlined label="Valor Unit. Tributável (vUnTrib)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.vTotTrib" dense outlined label="Valor Aproximado Tributos (vTotTrib)"></q-input>
    </div>
  </div>

  <q-separator spaced></q-separator>

  <!-- BLOCO 3: Valores Acessórios -->
  <div class="text-subtitle2 q-mb-xs">Valores Acessórios</div>
  <div class="row q-col-gutter-sm q-mb-sm">
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.vDesc" dense outlined label="Desconto (vDesc)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.vFrete" dense outlined label="Frete (vFrete)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.vSeg" dense outlined label="Seguro (vSeg)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.vOutro" dense outlined label="Outras Despesas (vOutro)"></q-input>
    </div>
  </div>

  <q-separator spaced></q-separator>

  <!-- BLOCO 4: Origem / Pedido / Fabricante -->
  <div class="text-subtitle2 q-mb-xs">Origem / Pedido / Fabricante</div>
  <div class="row q-col-gutter-sm">
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.indEscala" dense outlined label="Indicador Escala (indEscala)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.CNPJFab" dense outlined label="CNPJ Fabricante (CNPJFab)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.xPed" dense outlined label="Pedido de compra (xPed)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.nItemPed" dense outlined label="Item do pedido (nItemPed)"></q-input>
    </div>

    <div class="col-12 col-md-3">
      <q-input v-model="itemSelecionado.prod.nFCI" dense outlined label="Número FCI (nFCI)"></q-input>
    </div>
  </div>

</q-tab-panel>


      <!-- ICMS -->
      <q-tab-panel name="icms">
        <div class="row q-col-gutter-sm">
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.tipo" dense outlined label="Tipo ICMS (ICMS00/ICMS10/...)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.orig" dense outlined label="Origem (orig)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.CST" dense outlined label="CST/CSOSN"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.modBC" dense outlined label="Modalidade BC (modBC)"></q-input>
          </div>

          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.vBC" dense outlined label="Base de Cálculo (vBC)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.pICMS" dense outlined label="Alíquota (pICMS)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.vICMS" dense outlined label="Valor ICMS (vICMS)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.modBCST" dense outlined label="Modalidade BC ST (modBCST)"></q-input>
          </div>

          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.vBCST" dense outlined label="BC ST (vBCST)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.pICMSST" dense outlined label="Alíquota ST (pICMSST)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.vICMSST" dense outlined label="Valor ST (vICMSST)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.icms.pRedBC" dense outlined label="% Redução BC (pRedBC)"></q-input>
          </div>
        </div>
      </q-tab-panel>

      <!-- IPI -->
      <q-tab-panel name="ipi">
        <div class="row q-col-gutter-sm">
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.ipi.CST" dense outlined label="CST"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.ipi.vBC" dense outlined label="Base de Cálculo (vBC)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.ipi.pIPI" dense outlined label="Alíquota (pIPI)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.ipi.vIPI" dense outlined label="Valor IPI (vIPI)"></q-input>
          </div>
        </div>
      </q-tab-panel>

      <!-- PIS -->
      <q-tab-panel name="pis">
        <div class="row q-col-gutter-sm">
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.pis.CST" dense outlined label="CST"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.pis.vBC" dense outlined label="Base (vBC)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.pis.pPIS" dense outlined label="Alíquota (pPIS)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.pis.vPIS" dense outlined label="Valor (vPIS)"></q-input>
          </div>
        </div>
      </q-tab-panel>

      <!-- COFINS -->
      <q-tab-panel name="cofins">
        <div class="row q-col-gutter-sm">
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.cofins.CST" dense outlined label="CST"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.cofins.vBC" dense outlined label="Base (vBC)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.cofins.pCOFINS" dense outlined label="Alíquota (pCOFINS)"></q-input>
          </div>
          <div class="col-12 col-md-3">
            <q-input v-model="itemSelecionado.imposto.cofins.vCOFINS" dense outlined label="Valor (vCOFINS)"></q-input>
          </div>
        </div>
      </q-tab-panel>

      <!-- IBS/CBS (placeholder para evoluir conforme schema) -->
      <q-tab-panel name="ibscbs">
        <div class="text-caption text-grey-7">
          IBS/CBS: estrutura varia por versão do schema e legislação. Este bloco fica pronto para mapear quando seu XML/tabelas já estiverem gerando estes nós.
        </div>
        <div class="row q-col-gutter-sm q-mt-sm">
          <div class="col-12 col-md-4">
            <q-input v-model="itemSelecionado.imposto.ibs_cbs.tipo" dense outlined label="Tipo"></q-input>
          </div>
          <div class="col-12 col-md-4">
            <q-input v-model="itemSelecionado.imposto.ibs_cbs.vBC" dense outlined label="Base"></q-input>
          </div>
          <div class="col-12 col-md-4">
            <q-input v-model="itemSelecionado.imposto.ibs_cbs.vTrib" dense outlined label="Valor"></q-input>
          </div>
        </div>
      </q-tab-panel>

    </q-tab-panels>

  </div>

  <div v-else class="text-caption text-grey-7">
    Clique em um item na lista para editar os detalhes.
  </div>

</q-tab-panel>

<q-tab-panel name="totais">

  <div class="text-subtitle2 q-mb-sm">Totais</div>

  <div class="text-subtitle2 q-mb-xs">ICMS</div>

  <div class="row q-col-gutter-sm">

    <div class="col-12 col-md-3">
      <q-input v-model="totais.vBC" dense outlined label="Base de Cálculo ICMS"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vICMS" dense outlined label="Valor do ICMS"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vICMSDeson" dense outlined label="Valor do ICMS Desonerado"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vFCP" dense outlined label="Valor Total do FCP"></q-input>
    </div>

    <div class="col-12 col-md-3">
      <q-input v-model="totais.vICMSFCP" dense outlined label="Valor Total ICMS FCP"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vICMSUFDest" dense outlined label="Valor Total ICMS Interestadual UF Destino"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vICMSUFRemet" dense outlined label="Valor Total ICMS Interestadual UF Rem."></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vBCST" dense outlined label="Base de Cálculo ICMS ST"></q-input>
    </div>

    <div class="col-12 col-md-3">
      <q-input v-model="totais.vST" dense outlined label="Valor ICMS Substituição"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vFCPSTRet" dense outlined label="Valor Total do FCP retido por ST"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vFCPSTAnt" dense outlined label="Valor Total do FCP retido anteriormente por ST"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vFCPUFDest" dense outlined label="Valor Total do FCP UF Destino"></q-input>
    </div>

    <div class="col-12 col-md-6">
      <q-input v-model="totais.qBCMono" dense outlined label="Qtd. tributada ICMS monofásico próprio (qBCMono)"></q-input>
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="totais.vICMSMono" dense outlined label="Valor do ICMS monofásico próprio (vICMSMono)"></q-input>
    </div>

    <div class="col-12 col-md-6">
      <q-input v-model="totais.qBCMonoReten" dense outlined label="Qtd. tributada ICMS monofásico sujeito a retenção (qBCMonoReten)"></q-input>
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="totais.vICMSMonoReten" dense outlined label="Valor do ICMS monofásico sujeito a retenção (vICMSMonoReten)"></q-input>
    </div>

    <div class="col-12 col-md-6">
      <q-input v-model="totais.qBCMonoRetAnt" dense outlined label="Qtd. tributada ICMS monofásico retido anteriormente (qBCMonoRetAnt)"></q-input>
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="totais.vICMSMonoRetAnt" dense outlined label="Valor do ICMS monofásico retido anteriormente (vICMSMonoRetAnt)"></q-input>
    </div>

    <q-separator class="col-12 q-my-sm"></q-separator>

    <div class="col-12 col-md-3">
      <q-input v-model="totais.vProd" dense outlined label="Valor Total dos Produtos"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vFrete" dense outlined label="Valor do Frete"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vSeg" dense outlined label="Valor do Seguro"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vDesc" dense outlined label="Valor Total dos Descontos"></q-input>
    </div>

    <div class="col-12 col-md-3">
      <q-input v-model="totais.vII" dense outlined label="Valor Total do II"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vIPI" dense outlined label="Valor Total do IPI"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vIPIDevol" dense outlined label="Valor Total do IPI Devolvido"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vPIS" dense outlined label="Valor do PIS"></q-input>
    </div>

    <div class="col-12 col-md-3">
      <q-input v-model="totais.vCOFINS" dense outlined label="Valor da COFINS"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vOutro" dense outlined label="Outras Despesas Acessórias"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vNF" dense outlined label="Valor Total da NF-e"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="totais.vTotTrib" dense outlined label="Valor Aproximado dos Tributos"></q-input>
    </div>

  </div>

</q-tab-panel>




                     <q-tab-panel name="transp">

  <div class="text-subtitle2 q-mb-sm">Dados do Transporte</div>

  <div class="row q-col-gutter-sm">
    <div class="col-12">
      <q-input v-model="transp.modFrete" dense outlined label="Modalidade do Frete (modFrete)"></q-input>
    </div>
  </div>

  <q-separator spaced></q-separator>

  <div class="text-subtitle2 q-mb-sm">Transportador</div>
  <div class="row q-col-gutter-sm">
    <div class="col-12 col-md-4">
      <q-input v-model="transporta.CNPJ" dense outlined label="CNPJ"></q-input>
    </div>
    <div class="col-12 col-md-8">
      <q-input v-model="transporta.xNome" dense outlined label="Razão Social / Nome"></q-input>
    </div>

    <div class="col-12 col-md-4">
      <q-input v-model="transporta.IE" dense outlined label="Inscrição Estadual"></q-input>
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="transporta.xEnder" dense outlined label="Endereço Completo"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="transporta.xMun" dense outlined label="Município"></q-input>
    </div>
    <div class="col-12 col-md-1">
      <q-input v-model="transporta.UF" dense outlined label="UF"></q-input>
    </div>
  </div>

  <q-separator spaced></q-separator>

  <div class="text-subtitle2 q-mb-sm">Veículo</div>
  <div class="row q-col-gutter-sm">
    <div class="col-12 col-md-4">
      <q-input v-model="veicTransp.placa" dense outlined label="Placa"></q-input>
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="veicTransp.UF" dense outlined label="UF"></q-input>
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="veicTransp.RNTC" dense outlined label="RNTC"></q-input>
    </div>
  </div>

  <q-separator spaced></q-separator>

  <div class="text-subtitle2 q-mb-sm">Volumes</div>
  <div class="row q-col-gutter-sm">
    <div class="col-12 col-md-3">
      <q-input v-model="vol.qVol" dense outlined label="Quantidade"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="vol.esp" dense outlined label="Espécie"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="vol.marca" dense outlined label="Marca dos Volumes"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="vol.nVol" dense outlined label="Numeração"></q-input>
    </div>

    <div class="col-12 col-md-6">
      <q-input v-model="vol.pesoL" dense outlined label="Peso Líquido"></q-input>
    </div>
    <div class="col-12 col-md-6">
      <q-input v-model="vol.pesoB" dense outlined label="Peso Bruto"></q-input>
    </div>
  </div>

</q-tab-panel>

<q-tab-panel name="cobr">

  <div class="text-subtitle2 q-mb-sm">Dados de Cobrança</div>

  <div class="text-subtitle2 q-mt-sm q-mb-xs">Fatura</div>
  <div class="row q-col-gutter-sm">
    <div class="col-12 col-md-4">
      <q-input v-model="cobr.nFat" dense outlined label="Número"></q-input>
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="cobr.vOrig" dense outlined label="Valor Original"></q-input>
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="cobr.vDesc" dense outlined label="Valor do Desconto"></q-input>
    </div>
    <div class="col-12 col-md-4">
      <q-input v-model="cobr.vLiq" dense outlined label="Valor Líquido"></q-input>
    </div>
  </div>

  <q-separator spaced></q-separator>

  <div class="row items-center q-mb-sm">
    <div class="text-subtitle2">Parcelas</div>
    <q-space></q-space>
    <q-btn dense color="deep-purple-7" icon="add" label="Adicionar" @click="addDup"></q-btn>
  </div>

  <q-table
    :rows="dups"
    :columns="colDups"
    row-key="__id"
    dense
    flat
    separator="cell"
  >
    <template v-slot:body-cell-actions="props">
      <q-td :props="props" class="text-right">
        <q-btn dense flat round icon="delete" color="red" @click="remDup(props.row)"></q-btn>
      </q-td>
    </template>
  </q-table>

  <q-separator spaced></q-separator>

  <div class="text-subtitle2 q-mb-sm">Formas de Pagamento</div>
  <div class="row q-col-gutter-sm">
    <div class="col-12 col-md-3">
      <q-input v-model="pag.indPag" dense outlined label="Ind. Forma de Pagamento (indPag)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="pag.tPag" dense outlined label="Meio de Pagamento (tPag)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="pag.xPag" dense outlined label="Descrição do Meio (xPag)"></q-input>
    </div>
    <div class="col-12 col-md-3">
      <q-input v-model="pag.vPag" dense outlined label="Valor do Pagamento (vPag)"></q-input>
    </div>

    <div class="col-12 col-md-3">
      <q-input v-model="pag.UF" dense outlined label="UF processamento pagamento (UFPag)"></q-input>
    </div>
  </div>

</q-tab-panel>

         <q-tab-panel name="inf">
  <div class="row q-col-gutter-sm">
    <div class="col-12">
      <q-input v-model="nfe.tpImp" dense outlined label="Formato de Impressão DANFE (tpImp)"></q-input>
    </div>
    <div class="col-12">
      <q-input v-model="infAdic.infCpl" type="textarea" autogrow dense outlined
               label="Informações Complementares (infCpl)"></q-input>
    </div>
  </div>
</q-tab-panel>



                     <q-tab-panel name="eventos">
  <div class="row items-center q-mb-sm">
    <div class="text-subtitle2 text-grey-8">Eventos da NF-e</div>
    <q-badge color="deep-purple-7" class="q-ml-sm">{{ eventos.length }}</q-badge>
    <q-space></q-space>
    <q-btn dense color="deep-purple-7" icon="add" label="Adicionar evento" @click="addEvento"></q-btn>
  </div>

  <q-table
    :rows="eventos"
    :columns="colEventos"
    row-key="__id"
    dense
    flat
    separator="cell"
  >
    <template v-slot:body-cell-actions="props">
      <q-td :props="props" class="text-right">
        <q-btn dense flat round icon="delete" color="red" @click="remEvento(props.row)"></q-btn>
      </q-td>
    </template>
  </q-table>
</q-tab-panel>

          </q-tab-panels>

        </div>
      </q-card-section>
    </q-card>

    <!-- Dialog: Entrada XML (igual conceito do entradaXML.vue: arquivo + colar) -->
    <q-dialog v-model="abrirEntradaXml" persistent>
      <q-card style="min-width: 85vw; max-width: 85vw;">
        <q-card-section class="row items-center">
          <div class="text-h6 text-weight-bold">Entrada XML</div>
          <q-space></q-space>
          <q-btn dense rounded color="deep-purple-7" icon="close" v-close-popup></q-btn>
        </q-card-section>

        <q-separator></q-separator>

        <q-card-section>
          <div class="row q-col-gutter-md">
            <div class="col-12 col-md-4">
              <q-file
                v-model="xmlFile"
                dense
                outlined
                label="Selecionar XML"
                accept=".xml,text/xml"
                @input="onFileSelected"
              ></q-file>

              <q-btn
                class="q-mt-sm full-width"
                color="deep-purple-7"
                icon="check"
                label="Carregar e iniciar edição"
                :loading="loadingParseLocal"
                @click="carregarLocalEIniciar"
              ></q-btn>

              <q-btn
                class="q-mt-sm full-width"
                color="grey-7"
                icon="delete"
                label="Limpar XML"
                @click="limparXml"
              ></q-btn>
            </div>

            <div class="col-12 col-md-8">
              <q-input
                v-model="xmlText"
                type="textarea"
                autogrow
                outlined
                dense
                label="Cole aqui o XML"
              ></q-input>
            </div>
          </div>
        </q-card-section>

        <q-separator></q-separator>

        <q-card-actions align="right">
          <q-btn color="deep-purple-7" flat label="Fechar" v-close-popup></q-btn>
        </q-card-actions>
      </q-card>
    </q-dialog>

    

  </div>
</template>

<script>

import api from "@/boot/axios";
import { getInfoDoMenu, getPayloadTabela } from "@/services";
import { mapColumnsFromDB, fetchMapaAtributo  } from '@/services/mapaAtributo';
import UnicoFormEspecial from '@/views/unicoFormEspecial.vue' // ajuste o caminho se for outro

import {
  DxDataGrid,
  DxColumn,
  DxFilterRow,
  DxHeaderFilter,
  DxGroupPanel,
  DxGrouping,
  DxSearchPanel,
  DxSelection,
  DxPaging,
  DxPager,
  DxScrolling,
} from "devextreme-vue/data-grid";
import ExcelJS from "exceljs";
import { saveAs } from "file-saver";
import { exportDataGrid } from "devextreme/excel_exporter";
import Relatorio from "@/components/Relatorio.vue";

// ==== utils de data ==== //
const pad2 = n => (n < 10 ? '0' + n : '' + n)
function ddmmyyyy(date) {
  if (!date) return null
  const d = new Date(date)
  const dd = pad2(d.getDate())
  const mm = pad2(d.getMonth() + 1)
  const yyyy = d.getFullYear()
  return `${dd}/${mm}/${yyyy}`
}
function yyyymmdd(date) {
  if (!date) return null
  const d = new Date(date)
  const dd = pad2(d.getDate())
  const mm = pad2(d.getMonth() + 1)
  const yyyy = d.getFullYear()
  return `${yyyy}-${mm}-${dd}`
}
function parseDMY(str) {
  if (!str) return null
  const m = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(str)
  if (!m) return null
  const [ , dd, mm, yyyy ] = m
  return new Date(+yyyy, +mm - 1, +dd)
}
function currentMonthRange() {
  const now = new Date()
  const first = new Date(now.getFullYear(), now.getMonth(), 1)
  const last  = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  return { first, last }
}
// ======================== //
const banco = localStorage.nm_banco_empresa;

// normaliza um array de linhas com base num “meta” (tipos vindos do payload)

function normalizarTipos(dados, camposMeta) {
  if (!Array.isArray(dados)) return dados;

  const mapa = {};

  (camposMeta || []).forEach((c) => {
    const key = c.nm_atributo_consulta || c.nm_atributo;

    // determinar tipo
    const tipo = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    mapa[key] = tipo;
    //
  });
  return dados.map((reg) => {
    const out = { ...reg };
    for (const [key, tipo] of Object.entries(mapa)) {
      const v = out[key];
      if (v == null || v === "") continue;
      if (
        [
          "currency",
          "number",
          "fixedpoint",
          "decimal",
          "float",
          "percent",
        ].includes(tipo)
      ) {
        const num = Number(String(v).replace(/\./g, "").replace(",", "."));
        if (!Number.isNaN(num)) out[key] = num;
      } else if (["date", "shortdate", "datetime"].includes(tipo)) {
        const d = new Date(v);
        if (!isNaN(d.getTime())) out[key] = d; // vira Date real
      }
    }
    return out;
  });
}

//Colunas de grid a partir do meta

function buildColumnsFromMeta(camposMeta = []) {
  return (camposMeta || []).map((c) => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const caption = c.nm_edit_label || dataField;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const align = [
      "currency",
      "percent",
      "fixedpoint",
      "number",
      "decimal",
      "float",
    ].includes(tipoFmt)
      ? "right"
      : "left";

    const col = {
      dataField,
      caption,
      visible: c.ic_visivel !== "N",
      width: c.largura || undefined,
      alignment: align,
      allowFiltering: true,
      allowSorting: true,
    };

    // Datas (exibição dd/MM/yyyy, filtro/sort corretos sem "voltar 1 dia")
    if (['date','shortdate','datetime'].includes(tipoFmt) || String(dataField).startsWith('dt_')) {
       col.dataType = 'date';

  // 1) Converte diferentes formatos para Date(UTC) de forma segura
  col.calculateCellValue = (rowData) => {
    const v = rowData?.[dataField];
    return parseToUtcDate(v); // retorna Date ou null
  };

  // 2) Exibe em pt-BR (dd/MM/yyyy), fixando UTC para não deslocar o dia
  col.customizeText = (e) => {
    if (!e.value) return '';
    return new Intl.DateTimeFormat('pt-BR', { timeZone: 'UTC' }).format(e.value);
  };

  // 3) Ordenação consistente mesmo se algum valor ficar string
  col.calculateSortValue = (rowData) => {
    const d = parseToUtcDate(rowData?.[dataField]);
    return d ? d.getTime() : -Infinity;
  };

  // 4) (Opcional) formato no filtro de linha/header filter
  col.filterOperations = ['=', '>', '<', '<=', '>=', 'between'];
}
    

    // Moeda
    if (tipoFmt === "currency" || dataField.startsWith("vl_")) {
      col.customizeText = (e) =>
        e.value == null || e.value === ""
          ? ""
          : Number(e.value).toLocaleString("pt-BR", {
              style: "currency",
              currency: "BRL",
            });
      col.cellTemplate = (container, options) => {
        const val = options.value;
        const span = document.createElement("span");
        if (typeof val === "number" && val < 0) span.style.color = "#c62828";
        span.textContent =
          val == null || val === ""
            ? ""
            : val.toLocaleString("pt-BR", {
                style: "currency",
                currency: "BRL",
              });
        container.append(span);
      };
    }

    // Percentual
    if (tipoFmt === "percent") {
      col.customizeText = (e) =>
        e.value == null || e.value === ""
          ? ""
          : `${(Number(e.value) * 100).toFixed(2)}%`;
    }

    // Números simples
    if (["number", "fixedpoint", "decimal", "float"].includes(tipoFmt)) {
      col.format = { type: "fixedPoint", precision: 2 };
    }

    return col;

  });

}

function buildSummaryFromMeta(camposMeta = []) {
  const totalizaveis = (camposMeta || []).filter(
    (c) => c.ic_total_grid === "S" || c.ic_contador_grid === "S"
  );

  const totalItems = totalizaveis.map((c) => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const isSum = c.ic_total_grid === "S";
    return {
      column: dataField,
      summaryType: isSum ? "sum" : "count",
      alignByColumn: true,
      displayFormat: isSum ? "Total: {0}" : "{0} registro(s)",
      customizeText: (e) => {
        if (isSum && (tipoFmt === "currency" || dataField.startsWith("vl_"))) {
          return `Total: ${Number(e.value || 0).toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          })}`;
        }
        if (isSum && tipoFmt === "percent") {
          return `Total: ${(Number(e.value || 0) * 100).toFixed(2)}%`;
        }
        return isSum ? `Total: ${e.value}` : `${e.value} registro(s)`;
      },
    };
  });

  const groupItems = totalizaveis.map((c) => {
    const dataField = c.nm_atributo_consulta || c.nm_atributo;
    const tipoFmt = (c.nm_datatype || c.formato_coluna || "").toLowerCase();
    const isSum = c.ic_total_grid === "S";
    return {
      column: dataField,
      summaryType: isSum ? "sum" : "count",
      showInGroupFooter: true,
      alignByColumn: true,
      displayFormat: isSum ? "Subtotal: {0}" : "{0} registro(s)",
      customizeText: (e) => {
        if (isSum && (tipoFmt === "currency" || dataField.startsWith("vl_"))) {
          return `Subtotal: ${Number(e.value || 0).toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL",
          })}`;
        }
        if (isSum && tipoFmt === "percent") {
          return `Subtotal: ${(Number(e.value || 0) * 100).toFixed(2)}%`;
        }
        return isSum ? `Subtotal: ${e.value}` : `${e.value} registro(s)`;
      },
    };
  });

  return {
    totalItems,
    groupItems,
    texts: { sum: "Total: {0}", count: "Registro(s): {0}" },
  };
}  
// ---------------------------------------------------------------
//
export default {
  name: "EntradaXML",
  components: {
    Relatorio,
    DxDataGrid,
    DxColumn,
    DxFilterRow,
    DxHeaderFilter,
    DxGroupPanel,
    DxGrouping,
    DxSearchPanel,
    DxSelection,
    DxPaging,
    DxPager,
    DxScrolling,
    UnicoFormEspecial,
  },
  data() {
    
    const { first, last } = currentMonthRange()

    return {
      cd_empresa: localStorage.cd_empresa || 0,
      tituloMenu: localStorage.nm_menu_titulo || "Entrada de XML",
      iLote : 0,
      importando: false,
      cd_tabela: null,
      loading: false,
      loadingImport: false,
      exporting: false,
      gridHeight: "65vh",
      cd_nota: null,   
      // upload/import
      form: {
        cd_tipo_xml: 55,
        arquivo: null,
        arquivos: [],
        ds_xml: "",
      },

      // filtros
      filtro: {
        cd_tipo_xml: null,
        dt_inicial: ddmmyyyy(localStorage.dt_inicial) || ddmmyyyy(first),
        dt_final: ddmmyyyy(localStorage.dt_final) || ddmmyyyy(last),
      },

      rows: [],
      columns: [],

      opcoesTipoXml: [
        { label: "55 - NFe", value: 55 },
        { label: "65 - NFCe", value: 65 },
        { label: "NFS-e (Serviço - GINFES)", value: 200 },
        { label: "CT-e (Conhecimento Transporte)", value: 300 },
      ],

      usarScrollVirtual: false,

      pageSize: 50,

      pageSizes: [
        { label: '20', value: 20 },
        { label: '50', value: 50 },
        { label: '100', value: 100 },
        { label: '200', value: 200 },
      ],
      qt_registro: null,
      usuario: null,
      headerBanco: null,
      recordCount: null,
      mostrarFormEspecial: false,
      cdMenuForm: null,
      cdMenuModalForm: null,
      cdAcessoEntradaForm: null,
      processingNotas: null,
      icModalPesquisaForm: 'N',

      // info do menu
      cd_menu: localStorage.cd_menu,
      isDialogInfoOpen: false,
      infoTitulo: "",
      infoTexto: "",

      // mapa de atributos
      dlgMapaAtributos: false,
      mapaRows: [],
      mapaColumns: [],

      // TABS do formulário (definidas pelo meta)
      tabsheets: [],        // [{ key, label, cd_tabsheet, fields:[] }]
      activeTabsheet: "dados",

      gridMeta: [],

      showRelatorio: false,
      logo: localStorage.nm_caminho_logo_empresa,
      nm_usuario: localStorage.usuario,

      gridRows: [],
      gridColumns: [],
      gridSummary: null,
      empresa: localStorage.empresa,
      nfseRel: {
        open: false,
        loading: false,
        dados: null
      },
      cteRel: {
        open: false,
        loading: false,
        dados: null
      },
 

    };
  },
  async created () {
    
    // ...restante do seu fluxo (carregar rows, etc.)
    this.bootstrap();
  },

  computed: {
  
  podeVisualizarCTe () {
    const driver = this._tipoDriver(this.form.cd_tipo_xml || this.filtro.cd_tipo_xml);
    if (driver.tipo !== 'CTE') return false;

    const row = this.linhaSelecionada || (this.selectedRows && this.selectedRows[0]);
    return !!(row && row.cd_cte_xml);
  },
  
  podeVisualizarNFSe () {
    const driver = this._tipoDriver(this.form.cd_tipo_xml || this.filtro.cd_tipo_xml);
    if (driver.tipo !== 'NFSE') return false;
    // ajuste aqui conforme seu controle de seleção:
    return this.linhaSelecionada && (this.linhaSelecionada.cd_nfse_xml || this.linhaSelecionada.cd_nfse_xml === 0);
  },


  podeImportar () {
    const temArquivos = Array.isArray(this.form.arquivos) && this.form.arquivos.length > 0
    const temXmlDigitado = !!this.form.ds_xml

    return (
      !!this.form.cd_tipo_xml &&
      (temArquivos || temXmlDigitado) && !this.importando
  )
   },
  },  

  methods: {

    imprimirCTe () {
  window.print();
},

    async visualizarCTe () {
  const row = this.linhaSelecionada || (this.selectedRows && this.selectedRows[0]);
  const id = row && row.cd_cte_xml;

  if (!id) {
    this.$q.notify({ type: 'warning', position: 'center', message: 'Selecione um CT-e.' });
    return;
  }

  this.cteRel.loading = true;

  try {
    const cfg = this.headerBanco ? { headers: { 'x-banco': this.headerBanco } } : undefined;

    // mantenha o mesmo formato que seu /exec já aceita (objeto)
    const body = 
    [{ ic_json_parametro: 'S',
       cd_cte_xml: id }];


    const resp = await api.post('/exec/pr_cte_xml_obter', body, cfg);
    const rows = this.resolveRows(resp && resp.data);
    const dados = Array.isArray(rows) ? rows[0] : null;

    if (!dados) {
      this.$q.notify({ type: 'warning', position: 'center', message: 'CT-e não encontrado.' });
      return;
    }

    this.cteRel.dados = dados;
    this.cteRel.open = true;

  } catch (e) {
    const r = e && e.response;
    const msg =
      (r && r.data && (r.data.Msg || r.data.message || r.data.error)) ||
      e.message ||
      'Erro ao abrir visualização do CT-e.';
    this.$q.notify({ type: 'negative', position: 'center', message: msg });
  } finally {
    this.cteRel.loading = false;
  }
},


    imprimirNFSe () {
  // imprime o modal. Se quiser imprimir só a área nfse-paper,
  // a gente cria CSS @media print mais enxuto.
  window.print();
},

async visualizarNFSe () {
  const row = this.linhaSelecionada; // ajuste conforme seu grid
  const id = row && row.cd_nfse_xml;

  if (!id) {
    this.$q.notify({ type: 'warning', position: 'center', message: 'Selecione uma NFS-e.' });
    return;
  }

  this.nfseRel.loading = true;

  try {
    const cfg = this.headerBanco ? { headers: { 'x-banco': this.headerBanco } } : undefined;

    // IMPORTANTE: manter o mesmo formato de payload que seu /exec já aceita.
    // Seu consultar original funciona com OBJETO. Então aqui também vai como OBJETO.
    const body = [{ 
      ic_json_parametro: 'S',
      cd_nfse_xml: id }];

    const resp = await api.post('/exec/pr_nfse_xml_obter', body, cfg);
    const rows = this.resolveRows(resp && resp.data);
    const dados = Array.isArray(rows) ? rows[0] : null;

    if (!dados) {
      this.$q.notify({ type: 'warning', position: 'center', message: 'NFS-e não encontrada.' });
      return;
    }

    this.nfseRel.dados = dados;
    this.nfseRel.open = true;

  } catch (e) {
    const r = e && e.response;
    const msg =
      (r && r.data && (r.data.Msg || r.data.message || r.data.error)) ||
      e.message ||
      'Erro ao abrir visualização.';
    this.$q.notify({ type: 'negative', position: 'center', message: msg });
  } finally {
    this.nfseRel.loading = false;
  }
},

    
    async loadPayload(cd_menu, cd_usuario) {
      //

      const limparChaves = [
        "payload_padrao_formulario",
        "campos_grid_meta",
        "dados_resultado_consulta",
        "filtros_form_especial",
        "registro_selecionado",
        "mapa_consulta_para_atributo",
        "tab_menu",
        "ic_filtro_obrigatorio",
        "ic_crud_processo",
        "ic_detalhe_menu",
        "nome_procedure",
        "ic_json_parametro",
        "cd_relatorio",
        "cd_relatorio_auto",
      ];

      limparChaves.forEach((k) => sessionStorage.removeItem(k));

      // Remove versões por menu (…_<cd>)
      Object.keys(sessionStorage).forEach((k) => {
        if (
          /(payload_padrao_formulario|campos_grid_meta|dados_resultado_consulta|registro_selecionado|cd_menu_detalhe|payload_padrao_formulario_detalhe|campos_grid_meta_detalhe|id_pai_detalhe)_(\d+)$/.test(
            k
          )
        ) {
          sessionStorage.removeItem(k);
        }
      });

      const payload = {
        cd_parametro: 1,
        cd_form: localStorage.cd_form, //sessionStorage.getItem("cd_form"),
        cd_menu: Number(cd_menu),
        nm_tabela_origem: "",
        cd_usuario: Number(cd_usuario)
        //
      };

      console.log("payload->", payload, banco);

      //const { data } = await axios.post("/api/payload-tabela", payload);

      //
      //const { data } = await api.post("/payload-tabela", payload);
      //

      const data = await getPayloadTabela(payload);

      // { headers: { 'x-banco': banco } })

      //console.log('dados do retorno: ', data);
      //

      this.gridMeta = Array.isArray(data) ? data : [];

      this.cd_parametro_menu = this.gridMeta?.[0]?.cd_parametro_menu || 0;

      const metaProc = (this.gridMeta || []).find(
        r => Number(r.cd_menu_processo || 0) > 0
      );
      // cd_menu_processo (se houver)
      this.cd_menu_processo = metaProc ? Number(metaProc.cd_menu_processo) : 0;
      //  

      // tabsheets (se houver)
      //Tabs Dinâmicas
      this.buildTabsheetsFromMeta(this.gridMeta);

      // mapa de atributos (consulta → atributo)
      this.mapaRows = this._buildMapaRowsFromMeta(this.gridMeta);

      //console.log('grid: ', this.gridMeta, this.cd_parametro_menu  );

      // flag: quando cd_tabela > 0, consulta será direta na tabela
      this.cd_tabela = Number(this.gridMeta?.[0]?.cd_tabela) || 0;
      //
      this.mostrarAcoes = (this.cd_tabela > 0);

      // título da tela

      this.title =
        this.gridMeta?.[0]?.nm_titulo ||
        sessionStorage.getItem("menu_titulo") ||
        "Formulário";

      sessionStorage.setItem(
        "payload_padrao_formulario",
        JSON.stringify(this.gridMeta)
      );
      sessionStorage.setItem(
        `payload_padrao_formulario_${cd_menu}`,
        JSON.stringify(this.gridMeta)
      );
      sessionStorage.setItem("campos_grid_meta", JSON.stringify(this.gridMeta));
      sessionStorage.setItem(
        `campos_grid_meta_${cd_menu}`,
        JSON.stringify(this.gridMeta)
      );

      sessionStorage.setItem("menu_titulo", this.title);

      this.nome_procedure = this.gridMeta?.[0]?.nome_procedure || "*";
      this.ic_json_parametro = this.gridMeta?.[0]?.ic_json_parametro || "N";

      // tab_menu (se houver)
      sessionStorage.setItem("tab_menu", this.gridMeta?.[0]?.tab_menu || "");


      // 1) MONTAR colunas e totalColumns (meta antigo)

      this.columns = this.gridMeta
        .filter((c) => c.ic_mostra_grid === "S")
        .sort((a, b) => (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0))
        .map((c) => ({
          dataField: c.nm_atributo || c.nm_atributo_consulta,
          caption: c.nm_titulo_menu_atributo || c.nm_atributo_consulta,
          format: c.formato_coluna || undefined,
          alignment: ["currency", "number", "percent", "fixedPoint"].includes(
            c.formato_coluna
          )
            ? "right"
            : "left",
          width: c.largura || undefined,
        }));

      // coluna de ações (editar / excluir)

      const colAcoes = {
        type: "buttons",
        caption: "Ações",
        width: 110,
        alignment: "center",
        allowSorting: false,
        allowFiltering: false,
        buttons: [
          {
            hint: "Consultar",
            icon: "search",
            onClick: (e) =>
              this.abrirFormConsulta({ registro: e.row.data }),
          },
          {
            hint: "Editar",
            icon: "edit",
            onClick: (e) =>
              this.abrirFormEspecial({ modo: "A", registro: e.row.data }),
          },
          {
            hint: "Copiar",
            icon: "copy",
            onClick: (e) =>
              this.copiarRegistro(e.row.data),
          },
          {
            hint: "Excluir",
            icon: "trash",
            onClick: (e) => {
              // idem: objeto PLANO
              const plain = JSON.parse(JSON.stringify(e.row.data));
              this.onExcluir(plain);
            },
          },
        ],
      };

      //summary e totalizadores

      //
      this.totalColumns = this.gridMeta
        .filter((c) => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
        .map((c) => ({
          dataField: c.nm_atributo || c.nm_atributo_consulta,
          type: c.ic_total_grid === "S" ? "sum" : "count",
          display: c.ic_total_grid === "S" ? "Total: {0}" : "{0} registro(s)",
        }));

      this.total = { totalItems: this.totalColumns };

      const mapa = {};

      this.gridMeta.forEach((c) => {
        if (c.nm_atributo && c.nm_atributo_consulta) {
          //mapa[c.nm_atributo] = c.nm_atributo_consulta;
          mapa[c.nm_atributo_consulta] = c.nm_atributo;
        }
      });

      sessionStorage.setItem("mapa_consulta_para_atributo", JSON.stringify(mapa));

      // console.log('mapa:', mapa);

      //this.total = { totalItems: this.totalColumns };

      // guarde o meta dos campos (usado na consulta e exportação)
      this.camposMetaGrid = this.gridMeta;
      //

      // 2) NORMALIZAR dados (datas → Date, números → Number, etc.)
      const normalizados = normalizarTipos(data, this.gridMeta);
      //console.log('normalizados:', normalizados);

      // 3) MONTAR colunas e summary
      this.gridColumns = buildColumnsFromMeta(this.gridMeta);
      this.gridSummary = buildSummaryFromMeta(this.gridMeta);

      // 4) ATUALIZAR estado
      this.gridRows = normalizados;
      //this.columns = this.gridColumns;
      this.total = this.gridSummary;

      // põe no início da lista de colunas
      if (this.mostrarAcoes) {
        this.columns = [colAcoes, ...this.gridColumns];
      } else {
        this.columns = [...this.gridColumns];
      }

      //

      // 5) NUNCA popular dados aqui; zera!
      this.rows = [];
      this.gridRows = [];
      this.totalQuantidade = 0;
      this.totalValor = 0;

    },

    async loadFiltros(cd_menu, cd_usuario) {
      //console.log(banco);

      const { data } = await api.post(
        "/menu-filtro",
        {
          cd_menu: Number(cd_menu),
          cd_usuario: Number(cd_usuario),
        },
        { headers: { "x-banco": banco } }
      );

      this.filtros = Array.isArray(data) ? data : [];

      for (const f of this.filtros) {
        if (
          f.nm_valor_padrao != null &&
          this.filtrosValores[f.nm_atributo] == null
        ) {
          const tipo = this.resolvType(f); // <- novo
          const val =
            tipo === "date" // <- novo
              ? this.toYMD(f.nm_valor_padrao) // <- novo (aceita "dd/mm/aaaa" ou Date)
              : f.nm_valor_padrao;
          this.$set(this.filtrosValores, f.nm_atributo, val);
        }

        // -----------------------------------------------------

        if (f.ic_fixo_filtro === "S") {
          sessionStorage.setItem(`fixo_${f.nm_atributo}`, f.nm_valor_padrao);
          continue;
        }

        if (
          f.nm_valor_padrao != null &&
          this.filtrosValores[f.nm_atributo] == null
        ) {
          this.$set(this.filtrosValores, f.nm_atributo, f.nm_valor_padrao);
        }

        console.log('lookup -> ', f.nm_lookup_tabela);
        // lookup de tabela
                if (f.nm_lookup_tabela && f.nm_lookup_tabela.trim()) {
          try {
            // usa o helper do componente
            const rows = await this.postLookup(f.nm_lookup_tabela);

            const opts = Array.isArray(rows)
              ? rows.map((r) => {
                  const vals = Object.values(r || {});
                  const nomeCampo = (f.nm_atributo || "").toLowerCase();

                  // acesso case-insensitive ao campo código
                  const lower = {};
                  Object.entries(r || {}).forEach(([k, v]) => {
                    lower[String(k).toLowerCase()] = v;
                  });

                  const code =
                    lower[nomeCampo] != null ? lower[nomeCampo] : vals[0];

                  const label =
                    lower.descricao != null
                      ? lower.descricao
                      : vals[1] != null
                      ? vals[1]
                      : code;

                  return {
                    value: String(code),
                    label: String(label),
                  };
                })
              : [];

            this.$set(f, "_options", [
              { value: "", label: "Selecione..." },
              ...opts,
            ]);
          } catch (e) {
            console.error("erro lookup filtros", e);
            this.$set(f, "_options", [
              { value: "", label: "Erro ao carregar" },
            ]);
          }
        }


        //
      }

      const salvos = JSON.parse(
        sessionStorage.getItem("filtros_form_especial") || "{}"
      );

      Object.keys(salvos).forEach((k) =>
        this.$set(this.filtrosValores, k, salvos[k])
      );

      // se tiver filtro de data no form, preencha datas do mês atual
      this.$nextTick(() => this.preencherDatasDoMes());
      //
      console.log("filtros carregados:", this.filtros, this.filtrosValores);
      //
    },

    // === Constrói Tabsheets a partir do gridMeta ===
    buildTabsheetsFromMeta(meta) {

      // Garante que sempre vamos trabalhar com um array
      const arr = Array.isArray(meta) ? meta : (meta ? [meta] : [])

      // Se não vier nada do back, zera as tabs

      if (!arr.length) {
        this.tabsheets = [
          {
            key: "dados",
            label: "Dados",
            cd_tabsheet: 1,
            fields: []
          },
          {
            key: "mapa",
            label: "Atributos",
            cd_tabsheet: -1,
            fields: []
          }
        ];

        this.activeTabsheet = "dados";
        return;

      }

      // Agrupa atributos por cd_tabsheet
      const grupos = {};

      arr.forEach(r => {           // <-- AGORA CORRETO
        const cd = Number(r.cd_tabsheet || 0);
        const nm = String(r.nm_tabsheet || "").trim() || "Dados";

        if (!grupos[cd]) {
          grupos[cd] = {
            key: cd === 0 ? "dados" : `tab_${cd}`,
            label: nm,
            cd_tabsheet: cd,
            fields: []
          };
        }

        grupos[cd].fields.push(r);

      });

      // Ordena pelos códigos de aba
      let tabs = Object.values(grupos).sort((a, b) => a.cd_tabsheet - b.cd_tabsheet)

      // Garante que exista uma aba "Dados" (caso tudo venha com cd_tabsheet != 1)

      /*
      if (!tabs.find(t => t.key === 'dados')) {
        const primeira = tabs[0]
        tabs.unshift({
          key: 'dados',
          label: 'Dados',
          cd_tabsheet: primeira ? primeira.cd_tabsheet : 1,
          fields: primeira ? primeira.fields : []
        })
      }
      */

      // Aba extra "Mapa de Atributos" no final
      tabs.push({
        key: "mapa",
        label: "Mapa de Atributos",
        cd_tabsheet: -1,
        fields: []
      });

      this.tabsheets = tabs;

      // Se a aba ativa atual não existir mais, volta pra primeira
      if (!tabs.find(t => t.key === this.activeTabsheet)) {
        this.activeTabsheet = tabs[0].key;
      }
    },
    // Constrói as linhas da Grid "Mapa de Atributos" a partir da gridMeta
    _buildMapaRowsFromMeta(meta) {
      const arr = Array.isArray(meta) ? meta : [];

      const rows = arr.map((r, idx) => {
        // ordem: tenta nu_ordem / qt_ordem_atributo, senão índice
        const ordem = Number(
          r.nu_ordem ||
          r.qt_ordem_atributo ||
          r.qt_ordem ||
          idx + 1
        );

        const codigo = Number(r.cd_atributo || 0);
        const atributo = String(r.nm_atributo || "").trim();

        const descricao = String(
          r.nm_atributo_consulta ||
          r.ds_atributo ||
          r.nm_titulo_menu_atributo ||
          atributo
        ).trim();

        return { ordem, codigo, atributo, descricao };
      });

      // ordena pela ordem (se vier 0, joga lá pro fim)
      rows.sort((a, b) => (a.ordem || 999999) - (b.ordem || 999999));

      return rows;
    },
    async bootstrap() {
      console.log("bootstrap da entrada XML");
      // pega da URL (ex.: ?cd_menu=236&cd_usuario=842) e do localStorage
      const q = new URLSearchParams(window.location.search);
      const cd_menu_q = q.get("cd_menu");
      const cd_usuario_q = q.get("cd_usuario");

      // compat: projetos antigos gravam como propriedades (localStorage.cd_menu),
      // então leio dos DOIS jeitos
      const cd_menu_ls_dot = window.localStorage.cd_menu;
      const cd_usuario_ls_dot = window.localStorage.cd_usuario;
      const cd_menu_ls_get = window.localStorage.getItem("cd_menu");
      const cd_usuario_ls_get = window.localStorage.getItem("cd_usuario");

      const cd_menu = cd_menu_q || cd_menu_ls_dot || cd_menu_ls_get;
      const cd_usuario = cd_usuario_q || cd_usuario_ls_dot || cd_usuario_ls_get;

      this.cd_menu = cd_menu ? String(cd_menu) : null;
      this.cdMenu = this.cd_menu;
      this.temSessao = !!(this.cd_menu && cd_usuario);

       // chave dinâmica que veio do pai (nota / documento / etc)
       this.ncd_acesso_entrada =
       this.ncd_acesso_entrada ||
         window.localStorage.cd_acesso_entrada ||
         window.localStorage.getItem("cd_acesso_entrada") ||
         null


      if (!this.temSessao) {
        console.warn("cd_menu/cd_usuario ausentes na sessão.");
        // limpa qualquer lixo visual e sai sem erro
        this.rows = [];
        this.columns = [];
        this.totalColumns = [];
        this.qt_registro = 0;

        return;

      }

      // Carrega configuração da grid e filtros
      // --> pr_egis_payload_tabela
      //
      await this.loadPayload(cd_menu, cd_usuario);

      // TODO: checar se this.montarAbasDetalhe() é necessário igual no unicoFormEspecial.vue
      // this.montarAbasDetalhe();
      //

      // Carrega os filtros dinâmicos
      console.log("antes de chamar loadFiltros", cd_menu, cd_usuario);
      console.log("cd_menu:", cd_menu); 
      console.log("cd_usuario:", cd_usuario);
      await this.loadFiltros(cd_menu, cd_usuario);
      // Se não houver filtro obrigatório, já faz a consulta

      const filtroObrig = this.gridMeta.some(
        (c) => c.ic_filtro_obrigatorio === "S"
      );
      const registroMenu = this.gridMeta.some(
        (c) => c.ic_registro_tabela_menu === "S"
      );

      if (registroMenu && !filtroObrig && !this.isPesquisa) {
        console.log(
          "antes de chamar this.consultar(); - sem filtro obrigatório e registro tabela menu → consulta automática"
        );
        this.consultar();
      }
    },

    preencherDatasDoMes() {
      if (!this.filtros || !this.filtros.length) return;

      const hoje = new Date();
      const inicio = new Date(hoje.getFullYear(), hoje.getMonth(), 1);
      const fim = new Date(hoje.getFullYear(), hoje.getMonth() + 1, 0);

      // escolhe o formato certo para cada filtro

      const valorPara = (f, data) => {
        const tipo = this.resolvType ? this.resolvType(f) : "text";
        return tipo === "date" ? this.toYMD(data) : this.formatBR(data);
      };

      const setIfEmpty = (key, val) => {
        if (!this.filtrosValores) this.filtrosValores = {};
        const v = this.filtrosValores[key];
        // só preenche se estiver vazio/indefinido
        if (v === undefined || v === null || v === "") {
          this.$set(this.filtrosValores, key, val);
        }
      };

      // tenta “dt_inicial / dt_final”
      const fDtIni = this.filtros.find((f) =>
        /dt_?inicial/i.test(f.nm_atributo || "")
      );
      const fDtFim = this.filtros.find((f) =>
        /dt_?final/i.test(f.nm_atributo || "")
      );

      if (fDtIni) setIfEmpty(fDtIni.nm_atributo, valorPara(fDtIni, inicio));
      if (fDtFim) setIfEmpty(fDtFim.nm_atributo, valorPara(fDtFim, fim));

      // fallback: se não existem campos explícitos inicial/final, aplica no(s) campos de data vazios
      if (!fDtIni && !fDtFim) {
        const datas = this.filtros.filter(this.isDateField);
        if (datas.length) {
          datas.forEach((f, idx) => {
            setIfEmpty(f.nm_atributo, valorPara(f, idx === 0 ? inicio : fim));
          });
        }
      }
    },

    // Botões do topo
    abrirRelatorio() {
      // garanta que gridRows e camposMetaGrid estão prontos aqui
      if (!Array.isArray(this.columns) || this.columns.length === 0) {
        //this.$q.notify({ type:'warning', position:'top-right', message:'Sem dados para o relatório.' })
        this.notifyWarn("Sem dados para o relatório.");
        return;
      }
      // Se já tiver grid pronta no form, passe os dados e meta por props:
      // this.$refs.relComp (opcional) poderá acessar depois
      this.showRelatorio = true;
    },
    async exportarPDF() {
      console.log("chamou exportarPDF");
      try {
        const { default: jsPDF } = await import("jspdf");
        const { default: autoTable } = await import("jspdf-autotable");

        // 1) Pega suas colunas / linhas já mostradas na grid
        const metaCols =
          (this.columns?.length ? this.columns : this.gridColumns) || [];
        const rowsSrc = (this.rows?.length ? this.rows : this.gridRows) || [];

        if (!rowsSrc.length) {
          this.$q?.notify?.({
            type: "warning",
            position: 'center', 
            message: "Sem dados para exportar.",
          });
          return;
        }

        // 2) Mapa de atributo -> atributo_consulta salvo no payload
        let mapa = {};
        try {
          mapa = JSON.parse(
            sessionStorage.getItem("mapa_consulta_para_atributo") || "{}"
          );
        } catch (_) { }

        // 3) Monta colunas exportáveis (ignora coluna de ações)
        const cols = metaCols
          .filter((c) => c.type !== "buttons")
          .map((c) => ({
            label:
              c.caption ||
              c.label ||
              c.nm_titulo_menu_atributo ||
              c.dataField ||
              c.field,
            field: c.dataField || c.field || c.name,
            fmt: c.format || null,
            width: c.width,
          }));

        // 4) Helpers de formatação
        const toBR = (v) => {
          if (v == null || v === "") return "";
          if (v instanceof Date) {
            const dd = String(v.getDate()).padStart(2, "0");
            const mm = String(v.getMonth() + 1).padStart(2, "0");
            const yy = v.getFullYear();
            return `${dd}/${mm}/${yy}`;
          }
          const s = String(v);
          if (/^\d{2}\/\d{2}\/\d{4}$/.test(s)) return s;
          // ISO -> pega só a data
          const m = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
          if (m) return `${m[3]}/${m[2]}/${m[1]}`;
          return s;
        };
        const money = (n) => {
          const x = Number(String(n).replace(",", "."));
          return Number.isFinite(x)
            ? x.toLocaleString("pt-BR", { style: "currency", currency: "BRL" })
            : n ?? "";
        };

        // 5) Resolve valor seguro por coluna e linha
        const safeGet = (row, col) => {
          const tryKeys = [];
          const base = col.field;
          tryKeys.push(base);
          if (mapa[base]) tryKeys.push(mapa[base]); // mapeamento meta->consulta
          // tenta achar por case-insensitive
          const alt = Object.keys(row).find(
            (k) => k.toLowerCase() === base?.toLowerCase()
          );
          if (alt && !tryKeys.includes(alt)) tryKeys.push(alt);

          let val;
          for (const k of tryKeys) {
            if (k in row) {
              val = row[k];
              break;
            }
          }
          // formata
          if (
            col.fmt &&
            ["currency", "fixedPoint", "number", "percent"].includes(col.fmt)
          ) {
            return money(val);
          }
          if (/^(dt_|data|emissao|entrega)/i.test(col.field)) return toBR(val);
          return val == null ? "" : String(val);
        };

        // 6) Cabeçalho/Metadados
        const empresa =
          localStorage.nm_razao_social ||
          sessionStorage.getItem("empresa") ||
          "-";
        const menu =
          this.cd_menu ||
          this.cdMenu ||
          sessionStorage.getItem("cd_menu") ||
          "";
        const usuario =
          localStorage.nm_usuario || sessionStorage.getItem("nm_usuario") || "";
        const getFiltro = (k) =>
          (this.filtrosValores && this.filtrosValores[k]) || "";
        const dtIni =
          getFiltro("dt_inicial") || getFiltro("dtini") || getFiltro("dt_inic");
        const dtFim =
          getFiltro("dt_final") || getFiltro("dtfim") || getFiltro("dt_fim");

        // 7) Prepara head/body para o AutoTable
        const head = [cols.map((c) => c.label)];
        const body = rowsSrc.map((r) => cols.map((c) => safeGet(r, c)));

        // 8) Totais/resumo com base no seu meta de totalização
        const summary = [];
        if (Array.isArray(this.totalColumns) && this.totalColumns.length) {
          const tot = this.totalColumns.map((t) => {
            if (t.type === "count") {
              return {
                label: "registro(s)",
                value: rowsSrc.length,
                isCurrency: false,
              };
            } else {
              const soma = rowsSrc.reduce((acc, rr) => {
                const v = Number(rr[t.dataField]) || 0;
                return acc + v;
              }, 0);
              return {
                label: t.display?.replace("{0}", "Total") || "Total",
                value: soma,
                isCurrency: true,
              };
            }
          });
          summary.push(...tot);
        }

        // 9) Gera o PDF
        const doc = new jsPDF({
          orientation: "landscape",
          unit: "pt",
          format: "a4",
        });
        const margin = 28;
        const pageW = doc.internal.pageSize.getWidth();
        let y = margin;

        // (opcional) logo – precisa ser HTTPS e CORS habilitado

        try {
          const nm_caminho_logo_empresa = localStorage.nm_caminho_logo_empresa || "";
          const logoUrl = `https://egisapp.com.br/img/${nm_caminho_logo_empresa}`;
          const res = await fetch(logoUrl);
          const b = await res.blob();
          const b64 = await new Promise((r) => {
            const fr = new FileReader();
            fr.onload = () => r(fr.result);
            fr.readAsDataURL(b);
          });
          doc.addImage(b64, "PNG", margin, y, 90, 30);
        } catch (_) {
          /* se falhar, segue sem logo */
        }

        // Título
        doc.setFont("helvetica", "bold");
        doc.setFontSize(22);
        doc.text(
          this.title || this.pageTitle || "Entregas por Periodo",
          margin + 120,
          y + 22
        );

        // Meta linha 1
        doc.setFont("helvetica", "normal");
        doc.setFontSize(11);
        y += 46;
        doc.text(
          `Empresa: ${empresa}  •  Menu: ${menu}  •  Data/Hora: ${toBR(
            new Date()
          )} ${new Date().toLocaleTimeString("pt-BR")}`,
          margin,
          y
        );
        // Período
        y += 18;
        doc.text(
          `Data Inicial: ${toBR(dtIni)}   |   Data Final: ${toBR(dtFim)}`,
          margin,
          y
        );

        // Tabela
        const columnStyles = {};
        cols.forEach((c, i) => {
          if (c.width) columnStyles[i] = { cellWidth: c.width };
          if (
            c.fmt &&
            ["currency", "fixedPoint", "number", "percent"].includes(c.fmt)
          ) {
            columnStyles[i] = { ...(columnStyles[i] || {}), halign: "right" };
          }
        });

        autoTable(doc, {
          head,
          body,
          startY: y + 12,
          styles: {
            fontSize: 9,
            lineWidth: 0.1,
            lineColor: 80,
            cellPadding: 4,
            overflow: "linebreak",
          },
          headStyles: {
            fillColor: [220, 220, 220],
            textColor: 20,
            halign: "left",
          }, // mais contraste
          alternateRowStyles: { fillColor: [245, 245, 245] },
          columnStyles,
          theme: "grid",
          didDrawPage: (data) => {
            const pg = `Página ${doc.internal.getNumberOfPages()}`;
            doc.setFontSize(9);
            doc.text(
              pg,
              pageW - margin - doc.getTextWidth(pg),
              doc.internal.pageSize.getHeight() - 10
            );
          },
        });

        // Resumo
        if (summary.length) {
          const lastY = doc.lastAutoTable.finalY || y + 60;
          autoTable(doc, {
            head: [["Resumo", "Valor"]],
            body: summary.map((s) => [
              s.label,
              s.isCurrency
                ? (Number(s.value) || 0).toLocaleString("pt-BR", {
                  style: "currency",
                  currency: "BRL",
                })
                : s.value,
            ]),
            startY: lastY + 12,
            styles: { fontSize: 10, cellPadding: 4 },
            headStyles: { fillColor: [230, 230, 230] },
            columnStyles: { 1: { halign: "right" } },
            theme: "grid",
          });
        }

        // Salva
        const arq = (this.title || this.pageTitle || "relatorio") + ".pdf";
        doc.save(arq);
      } catch (e) {
        console.error("PDF erro", e);
        this.$q?.notify?.({
          type: "negative",
          position: 'center', 
          message: "Falha ao exportar PDF.",
        });
      }
    },
    async onInfoClick() {
      const { titulo, descricao } = await getInfoDoMenu(this.cd_menu, {
        tituloFallback: localStorage.menu_titulo || this.pageTitle // se você tiver um título local
      });
      this.infoTitulo = titulo + " - " + this.cd_menu.toString();
      this.infoTexto = descricao;
      this.infoDialog = true;
    },
    // ======
    onVoltar() {
      if (this.$router) this.$router.back();
      else window.history.back();
    },

    // === ações da grid ===
   onRowDblClick(e){
      if(e && e.data)
      //console.log('dados da grid',e.data);
      //this.abrirDanfe(e.data) },
    this.abrirItensNota(e.data);
    // abre o form especial (itens da nota)

},

abrirFormEspecialNota(row) {

    console.log('abrirFormEspecialNota ->', row);

    // mesma lógica para descobrir a chave da nota
    const cd_nota = row.cd_xml_nota || 0;
    console.log('nota para edição', cd_nota);

    const cd_usuario =
      Number(localStorage.getItem("cd_usuario")) ||
      Number(this.$store?.state?.user?.cd_usuario || 0);

    const cd_menu = 8518; // mesmo menu que você já está usando

    // props que vão para o unicoFormEspecial
    this.cdMenuForm = cd_menu;
    this.cdAcessoEntradaForm = cd_nota || 0;
    this.cdMenuModalForm = cd_menu;
    this.icModalPesquisaForm = 'N';

    // grava no localStorage para o unicoFormEspecial usar no payload
    localStorage.setItem("cd_menu", cd_menu);
    localStorage.setItem("cd_menu_entrada", cd_menu);
    localStorage.setItem("cd_menu_modal", cd_menu);

    localStorage.cd_chave_pesquisa  = cd_nota || 0;
    localStorage.cd_acesso_entrada  = cd_nota || 0;

    // <<< AQUI É O PULO DO GATO: diz pro filho que veio de modal de pesquisa
    //this.icModalPesquisaForm = 'N';

    // abre o diálogo com o único form
    this.mostrarFormEspecial = true;

},


abrirItensNota(row) {
    console.log('abrirItensNota ->', row);
    // aqui você pega o ID da nota
    // ajuste o campo conforme vem do seu back: cd_nota, cd_documento, etc.
    const cd_nota = row.cd_xml_nota || 0;
    console.log('nota', cd_nota);

    // garante cd_usuario (pega de onde você já usa no sistema)
    const cd_usuario =
      Number(localStorage.getItem("cd_usuario")) ||
      Number(this.$store?.state?.user?.cd_usuario || 0);

    // grava o menu e a nota em storage (o unicoFormEspecial já usa isso)
     this.cdMenuForm = 8755   // para esse caso específico (itens nota entrada)
     this.cdAcessoEntradaForm = row.cd_nota || 0 ;
     this.icModalPesquisaForm = 'N';

    localStorage.setItem("cd_menu", 8755);
 
    localStorage.setItem("cd_menu_entrada", 8755);

    // se quiser, mantém a nota também na sessionStorage
    localStorage.cd_chave_pesquisa = cd_nota || 0;
    localStorage.cd_acesso_entrada =  cd_nota || 0;

    this.icModalPesquisaForm = 'N';

    //
        
    // abre o componente filho
    this.mostrarFormEspecial = true
    //
    
  },

  fecharFormEspecial () {
    this.mostrarFormEspecial = false
  },

getBanco(){
    const b = localStorage.nm_banco_empresa;
return b || this.headerBanco || (this.$route && this.$route.query && this.$route.query.banco) || ''
},

getApiBase(){
try { return process.env.VUE_APP_API_BASE || window.location.origin } catch(e){ return window.location.origin }
},

abrirDanfe(row){
  
  // Se o DxDataGrid te entrega { data: { ... } } em alguns templates,
  // garanta o objeto certo:
  const r = row?.data ? row.data : row;

  // 1) SETA a seleção usada pelos relatórios
  this.linhaSelecionada = r;

  // 2) pega o tipo vindo do select (form ou filtro)
  const cdTipo = Number(this.form?.cd_tipo_xml ?? this.filtro?.cd_tipo_xml ?? 0);

  // debug forte
  console.log('PDF -> row:', row);
  console.log('PDF -> cdTipo:', cdTipo, 'typeof:', typeof cdTipo);

  const driver = this._tipoDriver(cdTipo);
  const tipo = (driver?.tipo || '').toUpperCase();

  console.log('PDF -> driver:', driver, 'tipo:', tipo);

   if (tipo === 'NFSE') {
      return this.visualizarNFSe()  // já usa linhaSelecionada
   }

   if (tipo === 'CTE') {
      return this.visualizarCTe()   // já usa linhaSelecionada
   }

   //continua o que está está gerando corretamente

   //console.log('abrir danfe', row);

   const banco = this.getBanco() || localStorage.nm;
   const base = this.getApiBase();
 
 //console.log(banco, base);

 const chave = String(row.cd_chave_acesso || row.chave || row.chave_acesso || '').replace(/\D+/g,'');
 
 //console.log('chave de acesso :', chave);

 if (!chave || chave.length !== 44) {
    this.$q.notify({ type:'warning', position: 'center', message:'Chave inválida.' });
    return;
 }

const appBase = window.location.origin.replace(/\/+$/,''); 
const apiBase = this.getApiBase(); // ex.: https://egiserp.com.br/api

//console.log(appBase);
//console.log(apiBase);

// monta a URL do informativo, repassando api, banco e chave
  const urlInfo = `${appBase}/informativo-danfe.php`
    + `?chave=${encodeURIComponent(chave)}`
    + (banco ? `&banco=${encodeURIComponent(banco)}` : '')
    + `&api=${encodeURIComponent(apiBase)}`
    + `&somente=1`; // <<< isso faz o informativo usar diretamente o nfecon

 // window.open(urlInfo, '_blank');

 if (chave && chave.length === 44){
//const url = `${base}/nfe/nfce/danfe/${encodeURIComponent(chave)}${banco?`?banco=${encodeURIComponent(banco)}`:''}`.replace(/\$/g,'$$');
const url = `${base}/nfe/danfe/por-chave/${encodeURIComponent(chave)}${banco ? `?banco=${encodeURIComponent(banco)}` : ''}`;
// 

window.open(url,'_blank');
return;

}
if (row.cd_nota_saida){
const url = `${base}/api/nfe/nfce/danfe/xml/${encodeURIComponent(row.cd_nota_saida)}${banco?`?banco=${encodeURIComponent(banco)}`:''}`.replace(/\$/g,'$$');
window.open(url,'_blank');
return;
}
this.$q.notify({type:'warning', position: 'center', message:'Linha sem chave de acesso (44 dígitos).'});
},

baixarXml(row){

 const banco = this.getBanco();
const base = this.getApiBase();
const chave = String(row.cd_chave_acesso || row.chave || row.chave_acesso || '').replace(/\D+/g,'');
if (!chave || chave.length !== 44){
this.$q.notify({type:'warning', position: 'center', message:'Esta linha não tem chave de acesso (44 dígitos).'});
return;
}
//const url = `${base}/api/nfe/nfce/xml/${encodeURIComponent(chave)}${banco?`?banco=${encodeURIComponent(banco)}`:''}`.replace(/\$/g,'$$');
//
const url = `${base}/api/nfe/xml/por-chave/${encodeURIComponent(chave)}${banco ? `?banco=${encodeURIComponent(banco)}` : ''}`;
// 
window.open(url,'_blank');
//
},

// === helpers de grid ===

    inferirColunas(linhas) {
      if (!linhas || !linhas.length) return [];
      const sample = linhas[0];
      return Object.keys(sample).map((k) => ({
        dataField: k,
        caption: this.titulo(k),
        dataType: this.tipo(sample[k]),
        format: this.formato(sample[k]),
        width: k === "ds_xml_preview" ? 500 : undefined,
      }));
    },
    titulo(k) {
      return (k || "")
        .replace(/_/g, " ")
        .replace(/\b\w/g, (c) => c.toUpperCase());
    },
    tipo(v) {
      if (v == null) return "string";
      if (typeof v === "number") return "number";
      if (v instanceof Date) return "date";
      if (/^\d{4}-\d{2}-\d{2}T/.test(String(v))) return "datetime";
      return "string";
    },
    formato(v) {
      if (v instanceof Date) return "dd/MM/yyyy";
      if (/^\d{4}-\d{2}-\d{2}T/.test(String(v))) return "dd/MM/yyyy HH:mm";
      return undefined;
    },
    resolveRows(data) {
      if (Array.isArray(data)) return data;
      if (data && data.recordset) return data.recordset;
      if (data && data.rows) return data.rows;
      if (data && data.data) return data.data;
      return [];
    },
    forceGridResize() {
      this.$nextTick(() => {
        try {
          if (this.$refs.gridDados && this.$refs.gridDados.instance) {
            this.$refs.gridDados.instance.updateDimensions();
          }
        } catch (e) {}
      });
    },

    // === upload ===
    onFileChange(val) {
      const file = Array.isArray(val) ? val[0] : val;
      if (!file) {
        this.form.ds_xml = "";
        return;
      }
      const reader = new FileReader();
      reader.onload = (evt) => {
        this.form.ds_xml = evt.target.result;
      };
      reader.onerror = () => {
        this.$q.notify({ type: "negative", position: 'center', message: "Erro ao ler o XML." });
      };
      reader.readAsText(file, "UTF-8");
    },
    
    limparArquivo() {
      this.form.arquivo = null;
      this.form.ds_xml = "";
      this.form.arquivos = [];
    },

    extrairChaveAcesso(xmlString = '', fileName = '') {
    // 1) tenta pelo nome do arquivo (mostra na sua UI)
    const fromName = String(fileName || '').match(/\b\d{44}\b/);
    if (fromName) return fromName[0];

    // 2) tenta pela tag <chNFe>...</chNFe>
    const byTag = String(xmlString || '').match(/<chNFe>\s*(\d{44})\s*<\/chNFe>/i);
    if (byTag) return byTag[1];

    // 3) tenta pelo atributo Id="NFeNNNN..." (ou CFe, por garantia)
    const byIdNFe = String(xmlString || '').match(/<infNFe[^>]*Id=["']NFe(\d{44})["']/i);
    if (byIdNFe) return byIdNFe[1];

    const byIdCFe = String(xmlString || '').match(/<infNFe[^>]*Id=["']CFe(\d{44})["']/i);
    if (byIdCFe) return byIdCFe[1];

    return '';
  },

  // NOVO: ler arquivo como texto
  lerArquivoXml (file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = e => resolve(e.target.result)
      reader.onerror = reject
      reader.readAsText(file)
    })
  },

  onFilesSelected (valOrEvent) {
    // se vier do input nativo
    if (valOrEvent && valOrEvent.target && valOrEvent.target.files) {
      this.form.arquivos = Array.from(valOrEvent.target.files)
    } else {
      // se vier do q-file (array de files já)
      this.form.arquivos = Array.isArray(valOrEvent) ? valOrEvent : (valOrEvent ? [valOrEvent] : [])
    }

    // opcional: se só 1 arquivo, já mostra o XML dele na tela
    if (this.form.arquivos.length === 1) {
      this.lerArquivoXml(this.form.arquivos[0]).then(xml => {
        this.form.ds_xml = xml
      })
    } else {
      this.form.ds_xml = ''
    }

    this.iLote = this.form.arquivos.length; 


  },

    // === exportação ===
    async exportarExcel() {
      if (!this.rows.length) return;
      this.exporting = true;
      try {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet("Notas XML");

        await exportDataGrid({
          component: this.$refs.gridDados.instance,
          worksheet,
          keepColumnWidths: true,
          customizeCell: ({ gridCell, excelCell }) => {
            if (gridCell && gridCell.rowType === 'data') {
              if (gridCell.column && gridCell.column.dataField === 'ds_xml_preview') {
                excelCell.alignment = { wrapText: true, vertical: 'top' };
              }
            }
          }
        });

        const buffer = await workbook.xlsx.writeBuffer();
        const stamp = new Date();
        const nome = `notas_xml_${stamp.getFullYear()}-${pad2(stamp.getMonth()+1)}-${pad2(stamp.getDate())}_${pad2(stamp.getHours())}${pad2(stamp.getMinutes())}.xlsx`;
        saveAs(new Blob([buffer], { type: 'application/octet-stream' }), nome);
        this.$q.notify({ type: 'positive', position: 'center', message: 'Excel gerado com sucesso.' });
      } catch (e) {
        this.$q.notify({ type: 'negative', position: 'center', message: e.message || 'Falha ao exportar Excel.' });
      } finally {
        this.exporting = false;
      }
    },

    
    _tipoDriver (cdTipo) {
      const t = Number(cdTipo || 0)

      // NFe / NFCe (produto)
      if (t === 55 || t === 65) {
        return {
          tipo: 'NFE',
          inserirProc: 'pr_nota_xml_inserir',
          listarProc: 'pr_nota_xml_listar',
          processarProc: 'pr_egis_recebimento_processo_modulo',
          processarParametro: 5
        }
      }

      // NFS-e (serviço - GINFES)
      if (t === 200) {
        return {
          tipo: 'NFSE',
          inserirProc: 'pr_nfse_xml_inserir',
          listarProc: 'pr_nfse_xml_listar',
           obterProc:  'pr_nfse_xml_obter',
          processarProc: 'pr_egis_nota_servico_processo',
          processarParametro: 900
        }
      }

      // CT-e (placeholder)
      if (t === 300) {
        return {
          tipo: 'CTE',
          inserirProc: 'pr_cte_xml_inserir',
          listarProc: 'pr_cte_xml_listar',
          obterProc:  'pr_cte_xml_obter',
          processarProc: 'pr_cte_processo',
          processarParametro: 950,
          disabled: false
        }
      }

      // fallback
      return {
        tipo: 'NFE',
        inserirProc: 'pr_nota_xml_inserir',
        listarProc: 'pr_nota_xml_listar',
        processarProc: 'pr_egis_recebimento_processo_modulo',
        processarParametro: 5
      }
    },


    async enviarOld () {
  if (!this.podeImportar) return;

  this.importando = true;
  const arquivos = Array.isArray(this.form.arquivos) ? this.form.arquivos : [];

  const cfg = this.headerBanco
    ? { headers: { 'x-banco': this.headerBanco } }
    : undefined;

  try {
    // 1) há arquivos selecionados? importa cada um
    if (arquivos.length) {
      for (const file of arquivos) {
        const xml = await this.lerArquivoXml(file);
        const chave = this.extrairChaveAcesso(xml, file.name) || null;

        const body = [{
          ic_json_parametro: 'S',
          cd_tipo_xml: this.form.cd_tipo_xml,
          ds_xml: xml,
          cd_chave_acesso: chave,
          cd_empresa: this.cd_empresa || localStorage.cd_empresa || 0,
          cd_usuario_inclusao: localStorage.cd_usuario || this.usuario?.cd_usuario || null
        }];

        console.log('Importando XML:', file.name, 'chave:', chave, body);

        //
        await api.post('/exec/pr_nota_xml_inserir', body, cfg);
        //

      }

    } else if (this.form.ds_xml) {
      // 2) fallback: sem arquivos, mas XML digitado/colado manualmente
      const chave = this.extrairChaveAcesso(this.form.ds_xml, '') || null;

      const body = [{
        ic_json_parametro: 'S',
        cd_tipo_xml: this.form.cd_tipo_xml,
        ds_xml: this.form.ds_xml,
        cd_chave_acesso: chave,
        cd_usuario_inclusao: this.usuario?.cd_usuario || null
      }];

      console.log('Importando XML único (ds_xml): chave:', chave, body);

      await api.post('/exec/pr_nota_xml_inserir', body, cfg);

    } else {
      console.warn('Nenhum XML selecionado/definido para importar.');
      return;
    }

    // 3) limpar form e recarregar grid

    this.form.arquivos = [];
    this.form.ds_xml = '';

    // ajuste aqui para o método que você usa para listar as notas importadas
    if (typeof this.consultar === 'function') {
      await this.consultar();
    }


  } catch (e) {
    console.error('Erro ao importar XML(s):', e);
    if (this.$q?.notify) {
      this.$q.notify({ type: 'negative', position: 'center', message: 'Erro ao importar XML(s): ' + (e.message || e) });
    } else {
      alert('Erro ao importar XML(s): ' + (e.message || e));
    }
  } finally {
    this.importando = false;
  }
},

//

 async enviar () {

  if (!this.podeImportar) return;

  const driver = this._tipoDriver(this.form.cd_tipo_xml);
  if (driver.disabled) {
    this.$q?.notify?.({ type: 'warning', position: 'center', message: 'Tipo ainda não implantado.' });
    return;
  }

  this.importando = true;
  const arquivos = Array.isArray(this.form.arquivos) ? this.form.arquivos : [];

  const cfg = this.headerBanco
    ? { headers: { 'x-banco': this.headerBanco } }
    : undefined;

  try {
    // 1) há arquivos selecionados? importa cada um
    if (arquivos.length) {
      for (const file of arquivos) {
        const xml = await this.lerArquivoXml(file);
        const chave = this.extrairChaveAcesso(xml, file.name) || null;
        
        let body = '' 

        /*
        const body = driver.tipo === 'NFSE'
          ? [{
              ic_json_parametro: 'S',
              cd_usuario_inclusao: this.usuario?.cd_usuario || null,
              ds_layout: 'GINFES',
              ds_xml: xml
            }]
          : [{
              ic_json_parametro: 'S',
              cd_tipo_xml: this.form.cd_tipo_xml,
              ds_xml: xml,
              cd_chave_acesso: chave,
              cd_usuario_inclusao: this.usuario?.cd_usuario || null
            }];
        */


        if (driver.tipo === 'NFSE') {
  // ✅ NFSe: melhor mandar cd_empresa e manter ic_json_parametro
  body = [{
    ic_json_parametro: 'S',
    cd_empresa: this.cd_empresa || localStorage.cd_empresa || 0,
    cd_usuario_inclusao: localStorage.cd_usuario || this.usuario?.cd_usuario || null,
    ds_layout: 'GINFES',
    ds_xml: xml
  }];

} else if (driver.tipo === 'CTE') {
  // ✅ CT-e (300)
  body = [{
    ic_json_parametro: 'S',
    cd_empresa: this.cd_empresa || localStorage.cd_empresa || 0,
    cd_usuario_inclusao: localStorage.cd_usuario || this.usuario?.cd_usuario || null,
    ds_layout: 'CTE',
    ds_xml: xml
  }];

} else {
  // ✅ NFe/NFCe (como já estava)
  body = [{
    ic_json_parametro: 'S',
    cd_tipo_xml: this.form.cd_tipo_xml,
    ds_xml: xml,
    cd_chave_acesso: chave,
    cd_empresa: this.cd_empresa || localStorage.cd_empresa || 0,
    cd_usuario_inclusao: localStorage.cd_usuario || this.usuario?.cd_usuario || null,

  }];
}

        console.log('Importando XML:', file.name, 'chave:', chave, body);

        //
        await api.post(`/exec/${driver.inserirProc}`, body, cfg);
        //

      }

    } else if (this.form.ds_xml) {
      // 2) fallback: sem arquivos, mas XML digitado/colado manualmente
      const chave = this.extrairChaveAcesso(this.form.ds_xml, '') || null;

      const body = driver.tipo === 'NFSE'
        ? [{
            cd_usuario_inclusao: this.usuario?.cd_usuario || null,
            ds_layout: 'GINFES',
            ds_xml: this.form.ds_xml
          }]
        : [{
            ic_json_parametro: 'S',
            cd_tipo_xml: this.form.cd_tipo_xml,
            ds_xml: this.form.ds_xml,
            cd_chave_acesso: chave,
            cd_usuario_inclusao: this.usuario?.cd_usuario || null
          }];

      console.log('Importando XML único (ds_xml): chave:', chave, body, `${driver.inserirProc}`);

      await api.post(`/exec/${driver.inserirProc}`, body, cfg);

    } else {
      console.warn('Nenhum XML selecionado/definido para importar.');
      return;
    }

    // 3) limpar form e recarregar grid

    this.form.arquivos = [];
    this.form.ds_xml = '';

    // ajuste aqui para o método que você usa para listar as notas importadas
    if (typeof this.consultar === 'function') {
      await this.consultar();
    }


  } catch (e) {
    console.error('Erro ao importar XML(s):', e);
    if (this.$q?.notify) {
      this.$q.notify({ type: 'negative', position: 'center', message: 'Erro ao importar XML(s): ' + (e.message || e) });
    } else {
      alert('Erro ao importar XML(s): ' + (e.message || e));
    }
  } finally {
    this.importando = false;
  }
},



//
    setPeriodoPadrao() {
      if (!this.filtro.dt_inicial || !this.filtro.dt_final) {
        const { first, last } = currentMonthRange();
        if (!this.filtro.dt_inicial) this.filtro.dt_inicial = ddmmyyyy(first);
        if (!this.filtro.dt_final)   this.filtro.dt_final   = ddmmyyyy(last);
      }
    },

    //Processsar a Notas 
    async processarOld() {
      //
      if (!this.rows || !this.rows.length) {
        this.$q.notify({ type: 'warning', position: 'center', message: 'Nenhuma nota para processar.' })
        return
      }

    this.processingNotas = true

    const cfg = this.headerBanco
      ? { headers: { 'x-banco': this.headerBanco } }
      : undefined


       try {
      const cd_usuario =
        Number(localStorage.getItem("cd_usuario")) ||
        Number(this.usuario?.cd_usuario || 1)

      // loop das notas da grid
      for (const row of this.rows) {
        // tenta achar o código da nota de entrada na linha
        const cd_nota_entrada =
          row.cd_identificacao || 0
          ||
          null

        if (!cd_nota_entrada) {
          console.warn('Linha sem cd_nota_entrada válido:', row)
          continue
        }

        const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;

        const body = [{
          // se o seu backend usa isso como nos outros procs, mantém:
          ic_json_parametro: 'S',
          cd_parametro: 5,
          cd_nota_entrada: cd_nota_entrada,
          cd_operacao_fiscal: 0,
          cd_usuario: cd_usuario,
          cd_pedido_compra: 0,
          cd_item_pedido_compra: 0,
          cd_nota_nfe: row.cd_xml_nota || 0,
          cd_empresa_fat: row.cd_empresa_fat || null
        }]

        console.log('payload do processo --> ', body);

        // chamada ao exec da procedure
        await api.post('/exec/pr_egis_recebimento_processo_modulo', body, cfg)

      }

      this.$q.notify({ type: 'positive', 
      position: 'center',
      message: 'Notas processadas com sucesso.' })

    } catch (e) {
      console.error(e)
      this.$q.notify({
        type: 'negative',
        position: 'center',
        message: e?.message || 'Erro ao processar notas.'
      })
    } finally {
      this.processingNotas = false
    }
  
    },


    //Processsar a Notas 
    async processar() {
      const driver = this._tipoDriver(this.form.cd_tipo_xml);
      if (driver.disabled) {
        this.$q?.notify?.({ type: 'warning', position: 'center', message: 'Tipo ainda não implantado.' });
        return;
      }

      //
      if (!this.rows || !this.rows.length) {
        this.$q.notify({ type: 'warning', position: 'center', message: 'Nenhuma nota para processar.' })
        return
      }

    this.processingNotas = true

    const cfg = this.headerBanco
      ? { headers: { 'x-banco': this.headerBanco } }
      : undefined


       try {
      const cd_usuario =
        Number(localStorage.getItem("cd_usuario")) ||
        Number(this.usuario?.cd_usuario || 1)

      // loop das notas da grid
      for (const row of this.rows) {
        // tenta achar o código da nota de entrada na linha
        const idProcesso = driver.tipo === 'NFSE'
          ? (row.cd_nfse_xml || row.cd_identificacao || null)
          : (row.cd_identificacao || null)

        if (!idProcesso) {
          console.warn('Linha sem cd_nota_entrada válido:', row)
          continue
        }

        const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;

        const body = driver.tipo === 'NFSE'
          ? [{
              ic_json_parametro: 'S',
              cd_parametro: driver.processarParametro,
              cd_usuario: cd_usuario,
              dados_registro: JSON.stringify({ cd_nfse_xml: idProcesso })
            }]
          : [{
              // se o seu backend usa isso como nos outros procs, mantém:
              ic_json_parametro: 'S',
              cd_parametro: driver.processarParametro,
              cd_nota_entrada: idProcesso,
              cd_operacao_fiscal: 0,
              cd_usuario: cd_usuario,
              cd_pedido_compra: 0,
              cd_item_pedido_compra: 0,
              cd_nota_nfe: row.cd_xml_nota || 0,
              cd_empresa_fat: row.cd_empresa_fat || null
            }]

        console.log('payload do processo --> ', body);

        // chamada ao exec da procedure
        await api.post(`/exec/${driver.processarProc}`, body, cfg)

      }

      this.$q.notify({ type: 'positive', 
      position: 'center',
      message: 'Notas processadas com sucesso.' })

    } catch (e) {
      console.error(e)
      this.$q.notify({
        type: 'negative',
        position: 'center',
        message: e?.message || 'Erro ao processar notas.'
      })
    } finally {
      this.processingNotas = false
    }
  
    },

async consultar () {
  this.setPeriodoPadrao();
  this.loading = true;

  // escolhe o tipo a partir do filtro (ou do form como fallback)
  const driver = this._tipoDriver(this.filtro.cd_tipo_xml || this.form.cd_tipo_xml);

  if (driver.disabled) {
    this.loading = false;
    this.$q?.notify?.({ type: 'warning', position: 'center', message: 'Tipo ainda não implantado.' });
    return;
  }

  try {
    const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;

    const dtIni = parseDMY(this.filtro.dt_inicial);
    const dtFim = parseDMY(this.filtro.dt_final);

    // monta payload conforme o tipo
    // (mantive o formato OBJETO igual seu consultar original, porque no seu /exec isso funcionou)
    
    const body =
      (driver.tipo === 'NFSE' || driver.tipo === 'CTE')
        ? [{
            ic_json_parametro: 'S',
            cd_empresa: this.cd_empresa || null, // opcional, mas ajuda
            dt_inicial: dtIni ? yyyymmdd(dtIni) : null,
            dt_final: dtFim ? yyyymmdd(dtFim) : null,
          }]
        : {
            ic_json_parametro: 'N',
            cd_tipo_xml: this.filtro.cd_tipo_xml,
            dt_ini: dtIni ? yyyymmdd(dtIni) : null,
            dt_fim: dtFim ? yyyymmdd(dtFim) : null,
          };

    // chama a PR correta
    const resp = await api.post(`/exec/${driver.listarProc}`, body, cfg);

    const rows = this.resolveRows(resp && resp.data);
    this.rows = Array.isArray(rows) ? rows : [];

    console.log('Dados da consulta notas', body, rows);

    this.columns = this.inferirColunas(this.rows);

    try {
      // OBS: no seu código você usa cd_tabela e cdTabela (um com underscore e outro camel)
      // Mantive exatamente seu padrão, só ajuste se sua prop correta for cd_tabela mesmo.
      this.cd_tabela = 0;
      this.columns = await mapColumnsFromDB(this.cd_tabela, this.columns, { cd_parametro: 1, useCache: true });

      const nomes = this.columns.map(c => c.dataField).filter(Boolean);
      const probe = await fetchMapaAtributo(this.cdTabela, nomes, { cd_parametro: 1, useCache: false });
      console.table(nomes);
      console.log('Consultar() - byAtrib:', probe.byAtrib);

    } catch (e) {
      console.warn('Mapa atributo indisponível (segue rótulos padrões):', e);
    }

    this.$q.notify({ type: "positive", position: 'center', message: `${this.rows.length} registro(s).` });
    this.forceGridResize();

  } catch (e) {
    const r = e && e.response;
    const msg =
      (r && r.data && (r.data.Msg || r.data.message || r.data.error)) ||
      e.message ||
      "Erro ao consultar.";
    this.$q.notify({ type: "negative", position: 'center', message: msg });
  } finally {
    this.loading = false;
  }
},

    async consultarOld() {

      this.setPeriodoPadrao();

      this.loading = true;

      try {
        const cfg = this.headerBanco ? { headers: { "x-banco": this.headerBanco } } : undefined;

        const dtIni = parseDMY(this.filtro.dt_inicial);
        const dtFim = parseDMY(this.filtro.dt_final);

        const body = {
          cd_tipo_xml: this.filtro.cd_tipo_xml,
          dt_ini: dtIni ? yyyymmdd(dtIni) : null,
          dt_fim: dtFim ? yyyymmdd(dtFim) : null,
        };

        const resp = await api.post("/exec/pr_nota_xml_listar", body, cfg);

        const rows = this.resolveRows(resp && resp.data);
        this.rows = Array.isArray(rows) ? rows : [];
        
        //console.log('antes: ', this.colums);
        this.columns = this.inferirColunas(this.rows);
        //

        try {
         // cd_parametro: 2  (conforme sua necessidade)
         this.cd_tabela = 0;
         this.columns = await mapColumnsFromDB(this.cd_tabela, this.columns, { cd_parametro: 1, useCache: true })
         //console.log('RETORNO: ',this.columns);

         const nomes = this.columns.map(c => c.dataField).filter(Boolean);
         const probe = await fetchMapaAtributo(this.cdTabela, nomes, { cd_parametro: 1, useCache: false });
         console.table(nomes);
         console.log('byAtrib:', probe.byAtrib);

     
        } catch (e) {
          console.warn('Mapa atributo indisponível (segue rótulos padrões):', e)
        }


        this.$q.notify({ type: "positive", position: 'center', message: `${this.rows.length} registro(s).` });
        
        this.forceGridResize();

      } catch (e) {
        const r = e && e.response;
        const msg =
          (r && r.data && (r.data.Msg || r.data.message || r.data.error)) ||
          e.message ||
          "Erro ao consultar.";
        this.$q.notify({ type: "negative", position: 'center', message: msg });
      } finally {
        this.loading = false;
      }
    },



  },

  
  async mounted() {

    this.cd_empresa = localStorage.cd_empresa || 0;

    await this.consultar();
     this._onResize = () => this.forceGridResize();
     window.addEventListener('resize', this._onResize);
     setTimeout(() => this.forceGridResize(), 150);
  },
  beforeDestroy() {
    if (this._onResize) window.removeEventListener('resize', this._onResize);
  }
};
</script>

<style scoped>
.grid {
  width: 100%;
}  
.datagrid-wrap { width: 100%; }
.datagrid-wrap .dx-datagrid {  
   width: 100%; }
.datagrid-wrap .q-btn { min-width: 0; } /* deixa os botões mais compactos */
.toolbar-entrada {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 16px;
}

/* largura fixa pros selects */
.toolbar-entrada .te-tipo-xml,
.toolbar-entrada .te-filtro-tipo {
  width: 180px;
}

/* arquivo ocupa o máximo possível da linha */
.toolbar-entrada .te-arquivo {
  flex: 1 1 400px;
}

/* grupo de botões encostados um no outro */
.toolbar-entrada .te-botoes {
  white-space: nowrap;
}

.toolbar-entrada .te-botoes .q-btn {
  min-width: 130px;
}

/* RESPONSIVO: em telas menores, quebra para coluna */
@media (max-width: 960px) {
  .toolbar-entrada {
    flex-direction: column;
    align-items: stretch;
  }

  .toolbar-entrada .te-tipo-xml,
  .toolbar-entrada .te-filtro-tipo,
  .toolbar-entrada .te-arquivo,
  .toolbar-entrada .te-botoes {
    width: 100%;
  }

  .toolbar-entrada .te-botoes {
    white-space: normal;
  }

  .toolbar-entrada .te-botoes .q-btn {
    width: 100%;
    margin-bottom: 6px;
  }
}
.topbar {
  padding: 10px;
  display: flex;
  align-items: center;
  width: 100%;
}

.nfse-paper { max-width: 980px; margin: 0 auto; }
.nfse-box { border: 1px solid #ddd; padding: 8px; min-height: 90px; white-space: pre-wrap; }
@media print {
  .q-dialog__backdrop, .q-bar, .q-btn { display: none !important; }
}

.cte-paper {
  max-width: 980px;
  margin: 0 auto;
}

@media print {
  /* some toolbars/buttons */
  .q-dialog__backdrop,
  .q-bar,
  .q-btn {
    display: none !important;
  }

  /* tenta garantir fundo branco */
  body {
    background: #fff !important;
  }
}

</style>
