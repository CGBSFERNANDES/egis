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
export default {
  name: 'edicaoNotaFiscal',
  props: {
    title: { type: String, default: '' },
    nm_procedimento: { type: String, default: 'pr_gera_nfe_entrada_xml' },
    cd_parametro_procedimento: { type: [Number, String], default: 0 },
    cdModal: { type: [Number, String], default: 0 },
    headerBanco: { type: String, default: '' }
  },

  data () {
    return {
      tab: 'nfe',

      abrirEntradaXml: false,
      xmlFile: null,
      xmlText: '',
      loadingParseLocal: false,
      loadingProcessar: false,
      loadingSalvar: false,

nfe: {
  chNFe: '',
  natOp: '',
  mod: '',
  serie: '',
  nNF: '',
  dhEmi: '',
  dhSaiEnt: '',
  tpAmb: '',
  finNFe: '',

  // novos
  procEmi: '',       // Processo de emissão
  verProc: '',       // Versão do processo
  tpEmis: '',        // Tipo de emissão
  indIntermed: '',   // Indicador Intermediador/MarketPlace
  tpNF: '',          // Tipo de operação (Entrada/Saída)
  idDest: '',        // Destino da Operação
  indFinal: '',      // Consumidor final
  indPres: '',       // Presença do consumidor
  vNF: ''

},

emit: {
  CNPJ: '',
  xNome: '',
  xFant: '',
  IE: '',
  IM: '',
  CNAE: '',
  CRT: ''
},

emitEnd: {
  xLgr: '',
  nro: '',
  xBairro: '',
  CEP: '',
  xMun: '',
  cMun: '',
  UF: '',
  cPais: '',
  xPais: '',
  fone: ''
},


 //     dest: { CNPJ: '', xNome: '', IE: '', indIEDest: '' },
 dest: {
  CNPJ: '',
  CPF: '',
  xNome: '',
  IE: '',
  indIEDest: '',
  email: ''
},

destEnd: {
  xLgr: '',
  nro: '',
  xBairro: '',
  CEP: '',
  xMun: '',
  cMun: '',
  UF: '',
  cPais: '',
  xPais: '',
  fone: ''
},
  
  totais: {
  // ICMS base
  vBC: '',
  vICMS: '',
  vICMSDeson: '',
  vFCP: '',
  vICMSFCP: '',

  // Partilha / DIFAL (interestadual)
  vICMSUFDest: '',
  vICMSUFRemet: '',
  vFCPUFDest: '',

  // ST / FCP ST
  vBCST: '',
  vST: '',
  vFCPST: '',
  vFCPSTRet: '',
  vFCPSTAnt: '',

  // ICMS monofásico (novos)
  qBCMono: '',
  vICMSMono: '',
  qBCMonoReten: '',
  vICMSMonoReten: '',
  qBCMonoRet: '',
  vICMSMonoRet: '',
  qBCMonoRetAnt: '',
  vICMSMonoRetAnt: '',

  // Totais gerais
  vProd: '',
  vFrete: '',
  vSeg: '',
  vDesc: '',
  vII: '',
  vIPI: '',
  vIPIDevol: '',
  vPIS: '',
  vCOFINS: '',
  vOutro: '',
  vNF: '',
  vTotTrib: ''
},


      
      
      infAdic: { infCpl: '' },
      prot: { nProt: '', dhRecbto: '', digVal: '' },

      item: {
  prod: {},
  icms: {},
  ipi: {},
  pis: {},
  cofins: {},
  ibs: {},

  // UI produtos
tabProd: 'prod',
itemSelecionadoId: null,
},

      itens: [],

      colItens: [
  { name: 'nItem', label: 'Num.', field: row => row.nItem, align: 'left' },
  { name: 'xProd', label: 'Descrição', field: row => row.prod.xProd, align: 'left' },
  { name: 'qCom', label: 'Qtd.', field: row => row.prod.qCom, align: 'right' },
  { name: 'uCom', label: 'Unidade Comercial', field: row => row.prod.uCom, align: 'left' },
  { name: 'vProd', label: 'Valor(R$)', field: row => row.prod.vProd, align: 'right' }
],

      eventos: [],

      colEventos: [
         { name: 'evento', label: 'Evento da NF-e', field: 'evento', align: 'left' },
         { name: 'protocolo', label: 'Protocolo', field: 'protocolo', align: 'left' },
         { name: 'dtAutorizacao', label: 'Data Autorização', field: 'dtAutorizacao', align: 'left' },
         { name: 'dtInclusaoAN', label: 'Data Inclusão AN', field: 'dtInclusaoAN', align: 'left' },
         { name: 'actions', label: '', field: 'actions', align: 'right' }
      ],
       transp: { modFrete: '' },
       transporta: { CNPJ: '', xNome: '', IE: '', xEnder: '', xMun: '', UF: '' },
       veicTransp: { placa: '', UF: '', RNTC: '' },
       vol: { qVol: '', esp: '', marca: '', nVol: '', pesoL: '', pesoB: '' },
       cobr: { nFat: '', vOrig: '', vDesc: '', vLiq: '' },
       dups: [],
       pag: { indPag: '', tPag: '', vPag: '', xPag: '', UF: '' },
       colDups: [
          { name: 'nDup', label: 'Número', field: 'nDup', align: 'left' },
          { name: 'dVenc', label: 'Vencimento', field: 'dVenc', align: 'left' },
          { name: 'vDup', label: 'Valor', field: 'vDup', align: 'left' },
          { name: 'actions', label: '', field: 'actions', align: 'right' }
        ],

        prod: {
  cProd: '', cEAN: '', xProd: '', NCM: '', CEST: '', CFOP: '',
  uCom: '', qCom: '', vUnCom: '', vProd: '',
  vDesc: '', vFrete: '', vSeg: '', vOutro: '', vTotTrib: '',
  cEANTrib: '', uTrib: '', qTrib: '', vUnTrib: '',
  nFCI: '',

  // faltantes comuns da tela fiscal
  indEscala: '',    // Indicador de Escala Relevante
  CNPJFab: '',      // CNPJ do Fabricante
  cBenef: '',       // Código de Benefício Fiscal na UF (alguns layouts usam cBenef)
  cBarra: '',       // (se você usar EAN/GTIN alternativo)
  xPed: '',         // Número do pedido de compra
  nItemPed: '',     // Item do pedido de compra
  extIPI: ''        // Código EX da TIPI
},


// NFSE / CTE (sem XML de entrada)
      tipoDoc: 'NFSE',               // 'NFSE' | 'CTE'
      origemDados: 'XML_EXISTENTE',  // 'XML_EXISTENTE' | 'MANUAL'
      tipoDocOptions: [
        { label: 'NFe-55', value: 'NFE' },
        { label: 'NFS-e (Serviço)', value: 'NFSE' },
        { label: 'CT-e', value: 'CTE' },
        { label: 'NFe-65 (Consumidor)', value: 'NFC' },

      ],
      origemOptions: [
        { label: 'XML existente', value: 'XML_EXISTENTE' },
        { label: 'Digitação manual', value: 'MANUAL' }
      ],
      
      listaXml: [],
      xmlSelecionadoId: null,
      xmlConteudo: '',
      loadingSalvarXml: false,
      // Modelo manual (ajuste conforme necessidade)
      manual: {
        numero: '',
        serie: '',
        dataEmissao: '',
        valor: 0,
        emitenteNome: '',
        destinatarioNome: ''
      },

      // contexto (id da nota/lançamento/etc)
      // ajuste para o que seu projeto já usa:
      idRegistro: null,
      chave: null
    }   

    
  },

   watch: {
    tipoDoc() {
      // ao trocar tipo, recarrega lista se estiver em XML
      if (this.origemDados === 'XML_EXISTENTE') this.carregarListaXml()
      // e limpa seleções
      this.xmlSelecionadoId = null
      this.xmlConteudo = ''
    },
    origemDados() {
      // se alternar para XML, carrega lista; se alternar para manual, limpa
      if (this.origemDados === 'XML_EXISTENTE') {
        this.carregarListaXml()
      } else {
        this.xmlSelecionadoId = null
        this.xmlConteudo = ''
      }
    }
  },

  computed: {
      itemSelecionado () {
    return (this.itens || []).find(i => i.__id === this.itemSelecionadoId) || null
  },
    titleComputed () {
      return localStorage.nm_menu_titulo|| 'Nota Fiscal'
    },

    valorNfFormatado () {
      const v = this.toNumber(this.totais.vNF || this.nfe.vNF)
      if (v === null) return '-'
      return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(v)
    }
  },

   mounted() {
    // pegue id/chave conforme sua rota
    this.idRegistro = this.$route.params.id || null
    this.chave = this.$route.query.chave || null

    if (this.origemDados === 'XML_EXISTENTE') this.carregarListaXml()
  },


  methods: {

    onVoltar () {
      if (this.$router) this.$router.back()
    },


     toNumber (v) {
       if (v === null || v === undefined || v === '') return null
          const s = String(v).replace(/\./g, '').replace(',', '.')
          const n = Number(s)
          return Number.isFinite(n) ? n : null
    },


    limparTudo () {
  // limpa entrada XML (arquivo + texto)
  this.limparXml()

  // aba / navegação
  this.tab = 'nfe'

  // NFE (ide)
  this.nfe = {
    chNFe: '',
    natOp: '',
    mod: '',
    serie: '',
    nNF: '',
    dhEmi: '',
    dhSaiEnt: '',
    tpAmb: '',
    finNFe: '',

    procEmi: '',
    verProc: '',
    tpEmis: '',
    indIntermed: '',
    tpNF: '',
    idDest: '',
    indFinal: '',
    indPres: '',
    tpImp: '',

    vNF: ''
  }

  // Protocolo / validação
  this.prot = {
    nProt: '',
    dhRecbto: '',
    digVal: ''
  }

  // Emitente + Endereço do Emitente
  this.emit = {
    CNPJ: '',
    xNome: '',
    xFant: '',
    IE: '',
    IM: '',
    CNAE: '',
    CRT: ''
  }
  this.emitEnd = {
    xLgr: '',
    nro: '',
    xBairro: '',
    CEP: '',
    xMun: '',
    cMun: '',
    UF: '',
    cPais: '',
    xPais: '',
    fone: ''
  }

  // Destinatário + Endereço do Destinatário
  this.dest = {
    CNPJ: '',
    CPF: '',
    xNome: '',
    IE: '',
    indIEDest: '',
    email: ''
  }
  this.destEnd = {
    xLgr: '',
    nro: '',
    xBairro: '',
    CEP: '',
    xMun: '',
    cMun: '',
    UF: '',
    cPais: '',
    xPais: '',
    fone: ''
  }

  // Totais (ICMSTot completo)

  this.totais = {
    vBC: '',
    vICMS: '',
    vICMSDeson: '',
    vFCP: '',
    vBCST: '',
    vST: '',
    vProd: '',
    vFrete: '',
    vSeg: '',
    vDesc: '',
    vII: '',
    vIPI: '',
    vPIS: '',
    vCOFINS: '',
    vOutro: '',
    vNF: ''
  }

  // Transporte
  this.transp = { modFrete: '' }
  this.transporta = { CNPJ: '', xNome: '', IE: '', xEnder: '', xMun: '', UF: '' }
  this.veicTransp = { placa: '', UF: '', RNTC: '' }
  this.vol = { qVol: '', esp: '', marca: '', nVol: '', pesoL: '', pesoB: '' }

  // Cobrança / Duplicatas
  this.cobr = { nFat: '', vOrig: '', vDesc: '', vLiq: '' }
  this.dups = []

  // Pagamento (detPag)
  this.pag = { indPag: '', tPag: '', vPag: '', xPag: '', UF: '' }

  // Informações adicionais
  this.infAdic = { infCpl: '' }

  // Itens / Produtos
  this.itens = []

  // Eventos (pós-autorização, múltiplos)
  this.eventos = []
},

onClickItem (evt, row) {
  this.itemSelecionadoId = row.__id
  this.tabProd = 'prod'
},


addEvento () {
  this.eventos.push({
    __id: String(Date.now()) + String(Math.random()),
    evento: '',
    protocolo: '',
    dtAutorizacao: '',
    dtInclusaoAN: ''
  })
},
remEvento (row) {
  this.eventos = this.eventos.filter(r => r !== row)
},

novoItemFiscal () {
  return {
    __id: String(Date.now()) + Math.random(),
    nItem: '',

    prod: {
      cProd: '', cEAN: '', xProd: '', NCM: '', CEST: '', CFOP: '',
      uCom: '', qCom: '', vUnCom: '', vProd: '',
      vDesc: '', vFrete: '', vSeg: '', vOutro: '', vTotTrib: '',
      cEANTrib: '', uTrib: '', qTrib: '', vUnTrib: '',
      nFCI: '', indEscala: '', CNPJFab: '', cBenef: '',
      xPed: '', nItemPed: '', extIPI: ''
    },

    imposto: {
      icms: {
        tipo: '',
        orig: '',
        CST: '',
        modBC: '',
        vBC: '',
        pICMS: '',
        vICMS: '',
        pRedBC: '',
        modBCST: '',
        vBCST: '',
        pICMSST: '',
        vICMSST: ''
      },
      ipi: {
        CST: '',
        vBC: '',
        pIPI: '',
        vIPI: ''
      },
      pis: {
        CST: '',
        vBC: '',
        pPIS: '',
        vPIS: ''
      },
      cofins: {
        CST: '',
        vBC: '',
        pCOFINS: '',
        vCOFINS: ''
      },
      ibs_cbs: {
        tipo: '',
        vBC: '',
        vTrib: ''
      }
    }
  }
},


addDup () {
  this.dups.push({ __id: String(Date.now()) + String(Math.random()), nDup: '', dVenc: '', vDup: '' })
},
remDup (row) {
  this.dups = this.dups.filter(r => r !== row)
},



    limparXml () {
      this.xmlFile = null
      this.xmlText = ''
    },

    addItem () {
      const n = this.itens.length + 1
      this.itens.push({
        nItem: String(n),
        cProd: '',
        xProd: '',
        NCM: '',
        CFOP: '',
        uCom: '',
        qCom: '',
        vUnCom: '',
        vProd: ''
      })
    },

    remItem (row) {
      this.itens = this.itens.filter(r => r !== row)
    },

    async onFileSelected () {
      if (!this.xmlFile) return
      const t = await this.readFileAsText(this.xmlFile)
      this.xmlText = t
    },

    readFileAsText (file) {
      return new Promise((resolve, reject) => {
        const fr = new FileReader()
        fr.onload = () => resolve(String(fr.result || ''))
        fr.onerror = reject
        fr.readAsText(file)
      })
    },

    async carregarLocalEIniciar () {
      const xml = (this.xmlText || '').trim()
      if (!xml) {
        this.notify('Cole ou selecione um XML.', 'warning')
        return
      }

      this.loadingParseLocal = true
      try {
        this.parseXmlLocal(xml)
        this.abrirEntradaXml = false
        this.notify('XML carregado. Pode editar nas abas.', 'positive')
      } catch (e) {
        this.notify('Falha ao ler XML: ' + (e.message || e), 'negative')
      } finally {
        this.loadingParseLocal = false
      }
    },

    // Parse local simples (não depende de backend)

    parseXmlLocal (xmlText) {
      const doc = new DOMParser().parseFromString(xmlText, 'text/xml')
      const ns = 'http://www.portalfiscal.inf.br/nfe'

      const first = (parent, tag) => {
        if (!parent) return null
        const list = parent.getElementsByTagNameNS(ns, tag)
        return (list && list[0]) ? list[0] : null
      }
      const text = (parent, tag) => {
        const el = first(parent, tag)
        return el && el.textContent ? el.textContent.trim() : ''
      }

      const nfeNode =
        doc.getElementsByTagNameNS(ns, 'NFe')[0] ||
        doc.getElementsByTagNameNS(ns, 'nfeProc')[0]

      const infNFe = doc.getElementsByTagNameNS(ns, 'infNFe')[0] || null

      const totalNode = infNFe
         ? infNFe.getElementsByTagNameNS(ns, 'total')[0]
         : null

      const icmsTot = totalNode
        ? totalNode.getElementsByTagNameNS(ns, 'ICMSTot')[0]
        : null

      const ide = first(infNFe, 'ide')
      //const emit = first(infNFe, 'emit')
      const dest = first(infNFe, 'dest')
      const total = first(infNFe, 'total')
     
// mantém também nfe.vNF (se você usa no topo)
this.nfe.vNF = this.totais.vNF || this.nfe.vNF

      
      const infAdic = first(infNFe, 'infAdic')

      const idAttr = infNFe ? (infNFe.getAttribute('Id') || '') : ''
      const chFromId = idAttr.indexOf('NFe') === 0 ? idAttr.substring(3) : ''

      this.nfe.chNFe = chFromId
      this.nfe.natOp = text(ide, 'natOp')
      this.nfe.mod = text(ide, 'mod')
      this.nfe.serie = text(ide, 'serie')
      this.nfe.nNF = text(ide, 'nNF')
      this.nfe.dhEmi = text(ide, 'dhEmi')
      this.nfe.tpAmb = text(ide, 'tpAmb')
      this.nfe.finNFe = text(ide, 'finNFe')
      this.nfe.vNF = text(icmsTot, 'vNF')
      this.nfe.dhSaiEnt = text(ide, 'dhSaiEnt') || (text(ide, 'dSaiEnt') + ' ' + text(ide, 'hSaiEnt')).trim()
      this.nfe.idDest = text(ide, 'idDest')
      this.nfe.indFinal = text(ide, 'indFinal')
      this.nfe.indPres = text(ide, 'indPres')
      this.nfe.procEmi = text(ide, 'procEmi')
this.nfe.verProc = text(ide, 'verProc')
this.nfe.tpEmis = text(ide, 'tpEmis')
this.nfe.tpNF = text(ide, 'tpNF')
this.nfe.indIntermed = text(ide, 'indIntermed')
this.nfe.tpImp = text(ide, 'tpImp')
this.prot.digVal = text(infProt, 'digVal')


const emitNode = first(infNFe, 'emit')
const endEmit = emitNode ? first(emitNode, 'enderEmit') : null

this.emit.CNPJ = text(emitNode, 'CNPJ')
this.emit.xNome = text(emitNode, 'xNome')
this.emit.xFant = text(emitNode, 'xFant')
this.emit.IE = text(emitNode, 'IE')
this.emit.IM = text(emitNode, 'IM')
this.emit.CNAE = text(emitNode, 'CNAE')
this.emit.CRT = text(emitNode, 'CRT')

this.emitEnd.xLgr = text(endEmit, 'xLgr')
this.emitEnd.nro = text(endEmit, 'nro')
this.emitEnd.xBairro = text(endEmit, 'xBairro')
this.emitEnd.CEP = text(endEmit, 'CEP')
this.emitEnd.xMun = text(endEmit, 'xMun')
this.emitEnd.cMun = text(endEmit, 'cMun')
this.emitEnd.UF = text(endEmit, 'UF')
this.emitEnd.cPais = text(endEmit, 'cPais')
this.emitEnd.xPais = text(endEmit, 'xPais')
this.emitEnd.fone = text(endEmit, 'fone')


      //Destinatário

      const destNode = first(infNFe, 'dest')
      const endDest = destNode ? first(destNode, 'enderDest') : null

this.dest.CNPJ = text(destNode, 'CNPJ')
this.dest.CPF = text(destNode, 'CPF')
this.dest.xNome = text(destNode, 'xNome')
this.dest.IE = text(destNode, 'IE')
this.dest.indIEDest = text(destNode, 'indIEDest')
this.dest.email = text(destNode, 'email')

this.destEnd.xLgr = text(endDest, 'xLgr')
this.destEnd.xBairro = text(endDest, 'xBairro')
this.destEnd.CEP = text(endDest, 'CEP')
this.destEnd.xMun = text(endDest, 'xMun')
this.destEnd.cMun = text(endDest, 'cMun')
this.destEnd.UF = text(endDest, 'UF')
this.destEnd.cPais = text(endDest, 'cPais')
this.destEnd.xPais = text(endDest, 'xPais')
this.destEnd.fone = text(endDest, 'fone')

      //Totais

      // ICMS base
this.totais.vBC = text(icmsTot, 'vBC')
this.totais.vICMS = text(icmsTot, 'vICMS')
this.totais.vICMSDeson = text(icmsTot, 'vICMSDeson')
this.totais.vFCP = text(icmsTot, 'vFCP')
this.totais.vICMSFCP = text(icmsTot, 'vICMSFCP')

// Partilha / DIFAL
this.totais.vICMSUFDest = text(icmsTot, 'vICMSUFDest')
this.totais.vICMSUFRemet = text(icmsTot, 'vICMSUFRemet')
this.totais.vFCPUFDest = text(icmsTot, 'vFCPUFDest')

// ST / FCP ST
this.totais.vBCST = text(icmsTot, 'vBCST')
this.totais.vST = text(icmsTot, 'vST')
this.totais.vFCPST = text(icmsTot, 'vFCPST')
this.totais.vFCPSTRet = text(icmsTot, 'vFCPSTRet')
this.totais.vFCPSTAnt = text(icmsTot, 'vFCPSTAnt')

// ICMS monofásico
this.totais.qBCMono = text(icmsTot, 'qBCMono')
this.totais.vICMSMono = text(icmsTot, 'vICMSMono')
this.totais.qBCMonoReten = text(icmsTot, 'qBCMonoReten')
this.totais.vICMSMonoReten = text(icmsTot, 'vICMSMonoReten')
this.totais.qBCMonoRet = text(icmsTot, 'qBCMonoRet')
this.totais.vICMSMonoRet = text(icmsTot, 'vICMSMonoRet')
this.totais.qBCMonoRetAnt = text(icmsTot, 'qBCMonoRetAnt')
this.totais.vICMSMonoRetAnt = text(icmsTot, 'vICMSMonoRetAnt')

// Totais gerais
this.totais.vProd = text(icmsTot, 'vProd')
this.totais.vFrete = text(icmsTot, 'vFrete')
this.totais.vSeg = text(icmsTot, 'vSeg')
this.totais.vDesc = text(icmsTot, 'vDesc')
this.totais.vII = text(icmsTot, 'vII')
this.totais.vIPI = text(icmsTot, 'vIPI')
this.totais.vIPIDevol = text(icmsTot, 'vIPIDevol')
this.totais.vPIS = text(icmsTot, 'vPIS')
this.totais.vCOFINS = text(icmsTot, 'vCOFINS')
this.totais.vOutro = text(icmsTot, 'vOutro')
this.totais.vNF = text(icmsTot, 'vNF')
this.totais.vTotTrib = text(icmsTot, 'vTotTrib')


      //
      this.infAdic.infCpl = text(infAdic, 'infCpl')

      const protNFe = doc.getElementsByTagNameNS(ns, 'protNFe')[0] || null
      const infProt = protNFe ? first(protNFe, 'infProt') : null
      this.prot.nProt = text(infProt, 'nProt')
      this.prot.dhRecbto = text(infProt, 'dhRecbto')

const transpNode = first(infNFe, 'transp')
this.transp.modFrete = text(transpNode, 'modFrete')

const transportaNode = transpNode ? first(transpNode, 'transporta') : null
this.transporta.CNPJ = text(transportaNode, 'CNPJ')
this.transporta.xNome = text(transportaNode, 'xNome')
this.transporta.IE = text(transportaNode, 'IE')
this.transporta.xEnder = text(transportaNode, 'xEnder')
this.transporta.xMun = text(transportaNode, 'xMun')
this.transporta.UF = text(transportaNode, 'UF')

const veicNode = transpNode ? first(transpNode, 'veicTransp') : null
this.veicTransp.placa = text(veicNode, 'placa')
this.veicTransp.UF = text(veicNode, 'UF')
this.veicTransp.RNTC = text(veicNode, 'RNTC')

// volumes (pega o primeiro vol)
const volNode = transpNode ? (transpNode.getElementsByTagNameNS(ns, 'vol')[0] || null) : null
this.vol.qVol = text(volNode, 'qVol')
this.vol.esp = text(volNode, 'esp')
this.vol.marca = text(volNode, 'marca')
this.vol.nVol = text(volNode, 'nVol')
this.vol.pesoL = text(volNode, 'pesoL')
this.vol.pesoB = text(volNode, 'pesoB')


const cobrNode = first(infNFe, 'cobr')
const fatNode = cobrNode ? first(cobrNode, 'fat') : null
this.cobr.nFat = text(fatNode, 'nFat')
this.cobr.vOrig = text(fatNode, 'vOrig')
this.cobr.vDesc = text(fatNode, 'vDesc')
this.cobr.vLiq = text(fatNode, 'vLiq')

// duplicatas (dup)
const dupNodes = cobrNode ? Array.prototype.slice.call(cobrNode.getElementsByTagNameNS(ns, 'dup') || []) : []
this.dups = dupNodes.map(d => ({
  __id: String(Date.now()) + String(Math.random()),
  nDup: text(d, 'nDup'),
  dVenc: text(d, 'dVenc'),
  vDup: text(d, 'vDup')
}))

// pagamento (detPag) - pega o primeiro
const pagNode = first(infNFe, 'pag')
const detPag = pagNode ? (pagNode.getElementsByTagNameNS(ns, 'detPag')[0] || null) : null
this.pag.indPag = text(detPag, 'indPag')
this.pag.tPag = text(detPag, 'tPag')
this.pag.vPag = text(detPag, 'vPag')
this.pag.xPag = text(detPag, 'xPag')
this.pag.UF = text(detPag, 'UFPag')

   //itens

   const dets = Array.prototype.slice.call(doc.getElementsByTagNameNS(ns, 'det') || [])

  this.itens = dets.map(det => {
  const prodNode = first(det, 'prod')
  const impNode = first(det, 'imposto')

  const icmsNode = impNode ? first(impNode, 'ICMS') : null
  const ipiNode = impNode ? first(impNode, 'IPI') : null
  const pisNode = impNode ? first(impNode, 'PIS') : null
  const cofinsNode = impNode ? first(impNode, 'COFINS') : null

  return {
    __id: String(Date.now()) + String(Math.random()),
    nItem: det.getAttribute('nItem') || '',

    prod: {
      cProd: text(prodNode, 'cProd'),
      cEAN: text(prodNode, 'cEAN'),
      xProd: text(prodNode, 'xProd'),
      NCM: text(prodNode, 'NCM'),
      CEST: text(prodNode, 'CEST'),
      CFOP: text(prodNode, 'CFOP'),

      uCom: text(prodNode, 'uCom'),
      qCom: text(prodNode, 'qCom'),
      vUnCom: text(prodNode, 'vUnCom'),
      vProd: text(prodNode, 'vProd'),
      vDesc: text(prodNode, 'vDesc'),
      vFrete: text(prodNode, 'vFrete'),
      vSeg: text(prodNode, 'vSeg'),
      vOutro: text(prodNode, 'vOutro'),
      vTotTrib: text(prodNode, 'vTotTrib'),

      cEANTrib: text(prodNode, 'cEANTrib'),
      uTrib: text(prodNode, 'uTrib'),
      qTrib: text(prodNode, 'qTrib'),
      vUnTrib: text(prodNode, 'vUnTrib'),

      nFCI: text(prodNode, 'nFCI'),
      indEscala: text(prodNode, 'indEscala'),
CNPJFab: text(prodNode, 'CNPJFab'),
cBenef: text(prodNode, 'cBenef'),
xPed: text(prodNode, 'xPed'),
nItemPed: text(prodNode, 'nItemPed'),
extIPI: text(prodNode, 'EXTIPI')


      
    },

    imposto: {
      icms: this.parseICMS(icmsNode, ns),
      ipi: this.parseIPI(ipiNode, ns),
      pis: this.parsePIS(pisNode, ns),
      cofins: this.parseCOFINS(cofinsNode, ns),

      // placeholder IBS/CBS
      ibs_cbs: { tipo: '', vBC: '', vTrib: '' }
    }
  }
})

// seleciona o primeiro item automaticamente
if (this.itens.length > 0) {
  this.itemSelecionadoId = this.itens[0].__id
  this.tabProd = 'prod'
}




    },


    parseICMS (icmsNode, ns) {
  const vazio = () => ({
    tipo: '',
    orig: '',
    CST: '',
    modBC: '',
    vBC: '',
    pICMS: '',
    vICMS: '',
    pRedBC: '',
    modBCST: '',
    vBCST: '',
    pICMSST: '',
    vICMSST: ''
  })
  if (!icmsNode) return vazio()

  // ICMS tem um “filho” que muda (ICMS00, ICMS10, ICMS20, ICMS60, ICMS90, ICMSSN102, ...)
  const child = Array.prototype.find.call(icmsNode.childNodes || [], n => n && n.nodeType === 1)
  if (!child) return vazio()

  const get = (tag) => {
    const el = child.getElementsByTagNameNS(ns, tag)[0]
    return el && el.textContent ? el.textContent.trim() : ''
  }

  return {
    tipo: child.localName || '',
    orig: get('orig'),
    CST: get('CST') || get('CSOSN'),
    modBC: get('modBC'),
    vBC: get('vBC'),
    pICMS: get('pICMS'),
    vICMS: get('vICMS'),
    pRedBC: get('pRedBC'),
    modBCST: get('modBCST'),
    vBCST: get('vBCST'),
    pICMSST: get('pICMSST'),
    vICMSST: get('vICMSST')
  }
},

parseIPI (ipiNode, ns) {
  const vazio = () => ({ CST: '', vBC: '', pIPI: '', vIPI: '' })
  if (!ipiNode) return vazio()

  // IPI pode ter IPITrib ou IPINT
  const trib = ipiNode.getElementsByTagNameNS(ns, 'IPITrib')[0] || null
  const src = trib || ipiNode

  const get = (tag) => {
    const el = src.getElementsByTagNameNS(ns, tag)[0]
    return el && el.textContent ? el.textContent.trim() : ''
  }

  return {
    CST: get('CST'),
    vBC: get('vBC'),
    pIPI: get('pIPI'),
    vIPI: get('vIPI')
  }
},

parsePIS (pisNode, ns) {
  const vazio = () => ({ CST: '', vBC: '', pPIS: '', vPIS: '' })
  if (!pisNode) return vazio()

  const child = Array.prototype.find.call(pisNode.childNodes || [], n => n && n.nodeType === 1)
  if (!child) return vazio()

  const get = (tag) => {
    const el = child.getElementsByTagNameNS(ns, tag)[0]
    return el && el.textContent ? el.textContent.trim() : ''
  }

  return {
    CST: get('CST'),
    vBC: get('vBC'),
    pPIS: get('pPIS'),
    vPIS: get('vPIS')
  }
},

parseCOFINS (cofinsNode, ns) {
  const vazio = () => ({ CST: '', vBC: '', pCOFINS: '', vCOFINS: '' })
  if (!cofinsNode) return vazio()

  const child = Array.prototype.find.call(cofinsNode.childNodes || [], n => n && n.nodeType === 1)
  if (!child) return vazio()

  const get = (tag) => {
    const el = child.getElementsByTagNameNS(ns, tag)[0]
    return el && el.textContent ? el.textContent.trim() : ''
  }

  return {
    CST: get('CST'),
    vBC: get('vBC'),
    pCOFINS: get('pCOFINS'),
    vCOFINS: get('vCOFINS')
  }
},

    // 2) Envia XML pro backend -> grava em Nota_XML -> chama pr_gera_nfe_entrada_xml
    async processarXmlNoBanco () {
  const xml = (this.xmlText || '').trim()
  if (!xml) {
    this.notify('Sem XML. Abra "Entrada XML" e carregue/cole.', 'warning')
    return
  }

  this.loadingProcessar = true

  try {
    // ✅ segue padrão do ModalGridComposicao
    const body = [
      {
        ic_json_parametro: 'S',
        cd_parametro: Number(this.cd_parametro_procedimento || 0),
        cd_usuario: Number(localStorage.cd_usuario || 0),
        cd_modal: Number(this.cdModal || 0),

        // ✅ conteúdo do “modal”: manda o XML
        dados_modal: {
          ds_xml: xml
        },

        // ✅ mantém padrão (se não usar, manda array vazio)
        dados_registro: []
      }
    ]

    const cfg = this.headerBanco
      ? { headers: { 'x-banco': this.headerBanco } }
      : undefined

    if (!this.nm_procedimento) {
      throw new Error('nm_procedimento não informado')
    }

    // ✅ exatamente como o modal:
    const resp = await this.$axios.post(`/exec/${this.nm_procedimento}`, body, cfg)
    const data = resp ? resp.data : null

    this.notify('Procedure executada com sucesso.', 'positive')

    // (Opcional) Se o backend devolver algo como cd_xml_nota ou cd_nota, você pode usar:
    // console.log('resp =>', data)

  } catch (e) {
    this.notify('Erro ao processar: ' + this.errMsg(e), 'negative')
  } finally {
    this.loadingProcessar = false
  }
},


    // 3) Salvar edição (payload normalizado) - opcional, você pode manter só o fluxo da procedure
    async salvarEdicao () {
      this.loadingSalvar = true
      try {
        const payload = {
          nfe: this.nfe,
          emit: this.emit,
          dest: this.dest,
          totais: this.totais,
          infAdic: this.infAdic,
          itens: this.itens
        }
        await this.$axios.post('/api/nfe/edicao/salvar', payload)
        this.notify('Edição salva.', 'positive')
      } catch (e) {
        this.notify('Erro ao salvar: ' + this.errMsg(e), 'negative')
      } finally {
        this.loadingSalvar = false
      }
    },

    errMsg (e) {
      return (e && e.response && e.response.data && e.response.data.message) ? e.response.data.message : (e.message || String(e))
    },

    notify (message, type) {
      if (this.$q && this.$q.notify) this.$q.notify({ type: type || 'info', message })
      else console.log(type, message)
    },

    async carregarListaXml() {
      // endpoint sugerido (ajuste pro seu backend)
      const url = this.tipoDoc === 'NFSE'
        ? '/api/nfse/xml/listar'
        : '/api/cte/xml/listar'

      const resp = await this.$http.get(url, {
        params: { idRegistro: this.idRegistro, chave: this.chave }
      })

      // formato: [{ id, label }]
      this.listaXml = resp.data || []
    },


    async carregarXmlSelecionado() {
      if (!this.xmlSelecionadoId) return

      const url = this.tipoDoc === 'NFSE'
        ? '/api/nfse/xml/obter'
        : '/api/cte/xml/obter'

      const resp = await this.$http.get(url, {
        params: { id: this.xmlSelecionadoId }
      })

      this.xmlConteudo = resp.data?.xml || ''
    },

    async salvarXmlEditado() {
      if (!this.xmlConteudo) {
        this.$toast?.error?.('XML vazio.')
        return
      }

      const url = this.tipoDoc === 'NFSE'
        ? '/api/nfse/xml/salvar'
        : '/api/cte/xml/salvar'

      await this.$http.post(url, {
        id: this.xmlSelecionadoId,    // se null, cria novo
        idRegistro: this.idRegistro,
        chave: this.chave,
        xml: this.xmlConteudo
      })

      this.$toast?.success?.('XML salvo!')
      await this.carregarListaXml()
    },

 montarXmlMinimoNFSE() {
      // XML mínimo “placeholder” só pra persistir.
      // Ideal: montar o XML do seu padrão municipal, mas isso já resolve o fluxo.
      return `
<NFSE>
  <Identificacao>
    <Numero>${this.manual.numero}</Numero>
    <Serie>${this.manual.serie}</Serie>
    <DataEmissao>${this.manual.dataEmissao}</DataEmissao>
  </Identificacao>
  <Partes>
    <Emitente>${this.manual.emitenteNome}</Emitente>
    <Destinatario>${this.manual.destinatarioNome}</Destinatario>
  </Partes>
  <Valores>
    <ValorServicos>${Number(this.manual.valor || 0).toFixed(2)}</ValorServicos>
  </Valores>
</NFSE>`.trim()
    },

     montarXmlMinimoCTE() {
      return `
<CTE>
  <Ide>
    <nCT>${this.manual.numero}</nCT>
    <serie>${this.manual.serie}</serie>
    <dhEmi>${this.manual.dataEmissao}</dhEmi>
  </Ide>
  <Partes>
    <Emitente>${this.manual.emitenteNome}</Emitente>
    <Destinatario>${this.manual.destinatarioNome}</Destinatario>
  </Partes>
  <VPrest>
    <vTPrest>${Number(this.manual.valor || 0).toFixed(2)}</vTPrest>
  </VPrest>
</CTE>`.trim()
    },

 async salvarManual() {
      // converte manual → xml e salva na tabela correta
      const xml = this.tipoDoc === 'NFSE'
        ? this.montarXmlMinimoNFSE()
        : this.montarXmlMinimoCTE()

      const url = this.tipoDoc === 'NFSE'
        ? '/api/nfse/xml/salvar'
        : '/api/cte/xml/salvar'

      await this.$http.post(url, {
        id: null,                 // manual geralmente cria registro novo
        idRegistro: this.idRegistro,
        chave: this.chave,
        xml,
        origem: 'MANUAL'
      })

      this.$toast?.success?.('Salvo com digitação manual!')
      // opcional: mudar para XML_EXISTENTE e carregar o novo
      this.origemDados = 'XML_EXISTENTE'
      await this.carregarListaXml()
    }
    
  }
}
</script>

<style scoped>
.toolbar-scroll { padding: 4px 2px; }
.seta-form { color: #512da8; }
.bg-form { font-weight: 700; }
</style>
