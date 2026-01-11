IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_geracao_pedido_venda_contrato' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_geracao_pedido_venda_contrato
GO

-------------------------------------------------------------------------------
--sp_helptext pr_geracao_pedido_venda_contrato
-------------------------------------------------------------------------------
--pr_geracao_pedido_venda_contrato
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2009
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000
--Autor(es)        : Carlos Cardoso Fernandes
--Banco de Dados   : Egissql
--Objetivo         : Geração do Pedido de Venda a partir da Ordem de Serviço
--                   GSG2009
--Data             : 16.01.2010
--Alteração        : 20.02.2010 - Ajuste para fechamento com seleção de Pedido
-- 19.04.2010 - Novo atributo - Carlos Fernandes
-- 27.04.2010 - Valor Total do Pedido de Venda - Carlos Fernandes
-- 09.10.2010 - Novos Atributos no Pedido - Carlos Fernandes
-- 02.04.2011 - Movimentação do Estoque - Carlos Fernandes
-- 07.04.2011 - Observação dos Itens colocado o número das OS - Carlos Fernandes
-- 24.04.2011 - Novo Campo do pedido de Venda - vl_desconto_pedido_venda - Carlos Fernandes
-- 06.05.2011 - Novos Campos - Carlos Fernandes
-- 07.05.2011 - Flag do status da Ordem de Serviço - Carlos Fernandes
-- 10.02.2012 - Verificação da Observação do Pedido de Venda - Carlos Fernandes
-- 22.02.2012 - Ajustes da Procedure - Carlos Fernandes
-- 04.09.2012 - Separação de Pedido de Venda de Produto e Serviço - Carlos Fernandes
-- 25.04.2013 - campos do pedido de venda - carlos fernandes
-- 11.09.2013 - Ajuste da Geração do dados do pedido - fagner/carlos fernandes
-- 20.09.2013 - Destinação - Carlos Fernandes
-- 18.08.2014 - Novo atributo na tabela de pedido de venda - carlos fernandes
-- 25.01.2015 - Novo atributo na tabela do Item do Pedido - Carlos Fernandes
-- 21.02.2018 - Novo atributo na tabela do Item do Pedido - Carlos Fernandes 
--------------------------------------------------------------------------------------------
create procedure pr_geracao_pedido_venda_contrato
@cd_contrato_servico      int = 0,
@cd_item_contrato_servico int = 0, 
@dt_pedido_venda          datetime = null,
@cd_usuario               int      = 0

as


if @cd_contrato_servico <> 0 
begin

  --Destinação------------------------------------------------------------
  declare @cd_destinacao_produto int
  set @cd_destinacao_produto = 0

--   select
--     @cd_destinacao_produto = isnull(cd_destinacao_produto,0)
--   from
--     parametro_servico
--   where
--     cd_emrpresa = dbo.fn_empresa
  


  if @dt_pedido_venda is null
  begin
     set @dt_pedido_venda = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
  end

--  select @dt_pedido_venda

  --pedido_venda

  declare @cd_pedido_venda           int
  declare @Tabela		     varchar(80)

  --select @cd_servico,@ic_estoque_fechamento

  -- Nome da Tabela usada na geração e liberação de códigos

  set @Tabela          = cast(DB_NAME()+'.dbo.Pedido_Venda' as varchar(80))
  set @cd_pedido_venda = 0


  exec EgisADMIN.dbo.sp_PegaCodigo @Tabela, 'cd_pedido_venda', @codigo = @cd_pedido_venda output
	
  while exists(Select top 1 'x' from pedido_venda where cd_pedido_venda = @cd_pedido_venda)
  begin
    exec EgisADMIN.dbo.sp_PegaCodigo @Tabela, 'cd_pedido_venda', @codigo = @cd_pedido_venda output
    -- limpeza da tabela de código
    exec EgisADMIN.dbo.sp_LiberaCodigo @Tabela, @cd_pedido_venda, 'D'
  end

  exec EgisADMIN.dbo.sp_LiberaCodigo @Tabela, @cd_pedido_venda, 'D'


print 'passo'

  --Geração do Pedido de Venda

  --contrato_servico
  --contrato_servico_composicao
  --select * from destinacao_produto

  select
    @cd_pedido_venda                            as cd_pedido_venda,
    @dt_pedido_venda                            as dt_pedido_venda,
    cs.cd_vendedor                              as cd_vendedor_pedido,
    c.cd_vendedor_interno                       as cd_vendedor_interno,
    'N'                                         as ic_emitido_pedido_venda,
    cs.ds_contrato                              as ds_pedido_venda,
    cast('' as varchar)                         as ds_pedido_venda_fatura,
    cast('' as varchar)                         as ds_cancelamento_pedido,
    @cd_usuario                                 as cd_usuario_credito_pedido,
    @dt_pedido_venda                            as dt_credito_pedido_venda,
    'N'                                         as ic_smo_pedido_venda,
    csp.vl_parc_contrato_servico                as vl_total_pedido_venda,
    null                                        as qt_liquido_pedido_venda,
    null                                        as qt_bruto_pedido_venda,
    null                                        as dt_conferido_pedido_venda,
    'N'                                         as ic_pcp_pedido_venda,
    'N'                                         as ic_lista_pcp_pedido_venda,
    'N'                                         as ic_processo_pedido_venda,
    'N'                                         as ic_lista_processo_pedido,
    'N'                                         as ic_imed_pedido_venda,
    'N'                                         as ic_lista_imed_pedido,
    null                                        as nm_alteracao_pedido_venda,
    'N'                                         as ic_consignacao_pedido,
    null                                        as dt_cambio_pedido_venda,
    null                                        as cd_cliente_entrega,
    'N'                                         as ic_op_triang_pedido_venda,
    'N'                                         as ic_nf_op_triang_pedido,
    null                                        as nm_contato_op_triang,
    null                                        as cd_pdcompra_pedido_venda,
    null                                        as cd_processo_exportacao,
    cs.cd_cliente,
    null                                        as cd_tipo_frete,
    null                                        as cd_tipo_restricao_pedido,

    isnull(c.cd_destinacao_produto,2)           as cd_destinacao_produto,

    1                                           as cd_tipo_pedido,
    c.cd_transportadora,
    cs.cd_vendedor, 
    1                                           as cd_tipo_endereco,
    1                                           as cd_moeda,
    cs.cd_contato,  
    @cd_usuario                                 as cd_usuario,
    getdate()                                   as dt_usuario,
    null                                        as dt_cancelamento_pedido,
    case when isnull(cs.cd_condicao_pagamento,0)>0 then
      cs.cd_condicao_pagamento
    else
      case when isnull(c.cd_condicao_pagamento,0)=0 then 1 else c.cd_condicao_pagamento end 
    end                                         as cd_condicao_pagamento,
    1                                           as cd_status_pedido,
    1                                           as cd_tipo_entrega_produto,
    cast(cs.cd_ref_contrato_servico as varchar) as nm_referencia_consulta,
    null                                        as vl_custo_financeiro,
    null                                        as ic_custo_financeiro,
    null                                        as vl_tx_mensal_cust_fin,
    null                                        as cd_tipo_pagamento_frete,
    null                                        as nm_assina_pedido,
    'N'                                         as ic_fax_pedido,
    'N'                                         as ic_mail_pedido,
    isnull(csp.vl_parc_contrato_servico,0)      as vl_total_pedido_ipi,
    0.00                                        as vl_total_ipi,
    cast('' as varchar)                         as ds_observacao_pedido,
    @cd_usuario                                 as cd_usuario_atendente,
    'S'                                         as ic_fechado_pedido,
    'N'                                         as ic_vendedor_interno,
    null                                        as cd_representante,
    'N'                                         as ic_transf_matriz,
    'N'                                         as ic_digitacao,
    'N'                                         as ic_pedido_venda,
    null                                        as hr_inicial_pedido,
    'N'                                         as ic_outro_cliente,
    'S'                                         as ic_fechamento_total,
    'N'                                         as ic_operacao_triangular,
    'N'                                         as ic_fatsmo_pedido,
    cast('' as varchar)                         as ds_ativacao_pedido,
    null                                        as dt_ativacao_pedido,
    cast('' as varchar)                         as ds_obs_fat_pedido,
    'N'                                         as ic_obs_corpo_nf,
    @dt_pedido_venda                            as dt_fechamento_pedido,
    null                                        as cd_cliente_faturar,
    1                                           as cd_tipo_local_entrega,
    'N'                                         as ic_etiq_emb_pedido_venda,
    null                                        as cd_consulta,
    null                                        as dt_alteracao_pedido_venda,
    null                                        as ic_dt_especifica_ped_vend,
    null                                        as ic_dt_especifica_consulta,
    'N'                                         as ic_fat_pedido_venda,
    'N'                                 as ic_fat_total_pedido_venda,
    null                                as qt_volume_pedido_venda,
    null                                as qt_fatpbru_pedido_venda,
    'N'                                 as ic_permite_agrupar_pedido,
    null                                as qt_fatpliq_pedido_venda, --pedido_venda
    null                                as vl_indice_pedido_venda,
    null                                as vl_sedex_pedido_venda,
    null                                as pc_desconto_pedido_venda,
    null                                as pc_comissao_pedido_venda,
    null                                as cd_plano_financeiro,
    cast('' as varchar)                 as ds_multa_pedido_venda,
    null                                as vl_freq_multa_ped_venda,
    null                                as vl_base_multa_ped_venda,
    null                                as pc_limite_multa_ped_venda,
    null                                as pc_multa_pedido_venda,
    null                                as cd_fase_produto_contrato,
    null                                as nm_obs_restricao_pedido,
    null                                as cd_usu_restricao_pedido,
    null                                as dt_lib_restricao_pedido,
    null                                as nm_contato_op_triang_ped,
    'N'                                 as ic_amostra_pedido_venda,
    'N'                                 as ic_alteracao_pedido_venda,
    'N'                                 as ic_calcula_sedex,
    null                                as vl_frete_pedido_venda,
    'N'                                 as ic_calcula_peso,
    'N'                                 as ic_subs_trib_pedido_venda,
    'N'                                 as ic_credito_icms_pedido,
    null                                as cd_usu_lib_fat_min_pedido,
    null                                as dt_lib_fat_min_pedido,
    null                                as cd_identificacao_empresa,
    null                                as pc_comissao_especifico,
    null                                as dt_ativacao_pedido_venda,
    null                                as cd_exportador,
    'N'                                 as ic_atualizar_valor_cambio_fat,
    null                                as cd_tipo_documento,
    null                                as cd_loja,
    null                                as cd_usuario_alteracao,
    'N'                                 as ic_garantia_pedido_venda,
    null                                as cd_aplicacao_produto,
    'S'                                 as ic_comissao_pedido_venda,
    null                                as cd_motivo_liberacao,
    'N'                                 as ic_entrega_futura,
    null                                as modalidade,
    null                                as modalidade1,
    null                                as cd_modalidade,
    null                                as cd_pedido_venda_origem,
    null                                as dt_entrada_pedido,
    null                                as dt_cond_pagto_pedido,
    null                                as cd_usuario_cond_pagto_ped,
    null                                as vl_credito_liberacao,
    null                                as vl_credito_liberado,
    null                                as cd_centro_custo,
    'N'                                 as ic_bloqueio_licenca,
    null                                as cd_licenca_bloqueada,
    null                                as nm_bloqueio_licenca,
    null                                as dt_bloqueio_licenca,
    null                                as cd_usuario_bloqueio_licenca,
    null                                as vl_mp_aplicacada_pedido,
    null                                as vl_mo_aplicada_pedido,
    null                                as cd_usuario_impressao,
    null                                as cd_cliente_origem,
    null                                as cd_situacao_pedido,
    null                                as qt_total_item_pedido,
    'N'                                 as ic_bonificacao_pedido_venda,
    null                                as pc_promocional_pedido,
    null                                as cd_tipo_reajuste,
    null                                as vl_icms_st,
    null                                as cd_tabela_preco,
    null                                as vl_desconto_pedido_venda,
    null                                as cd_fornecedor,
    0.00                                as vl_sinal_pedido_venda,
    null                                as cd_forma_pagamento,
    null                                as cd_motivo_cancel_pedido

   
 
  into
    #Pedido_Venda_a

  from
    contrato_servico cs   with (nolock) 
    inner join contrato_servico_composicao csp on csp.cd_contrato_servico = cs.cd_contrato_servico
    left outer join cliente c                  on c.cd_cliente            = cs.cd_cliente

  where
    cs.cd_contrato_servico          = @cd_contrato_servico   and
    csp.cd_contrato_servico         = @cd_contrato_servico   and
    csp.cd_item_contrato_servico = @cd_item_contrato_servico and
    isnull(csp.cd_pedido_venda,0) = 0


  --select @cd_pedido_venda as cd_pedido_venda


  insert into 
     pedido_venda
  select
    *
  from
    #Pedido_Venda_a

--  select * from  #Pedido_Venda_a


  --Itens do Pedido de Venda

  --Gravar um tabela temporária e atualizar como Serviço.
  --contrato_servico_composicao

  select
    @cd_pedido_venda                   as cd_pedido_venda,
    1                                  as cd_item_pedido_venda,
    @dt_pedido_venda                   as dt_item_pedido_venda,

    case when isnull(csp.qt_movimento_parcela,0)<>0 then
      csp.qt_movimento_parcela
    else
      1
    end                                as qt_item_pedido_venda,

    case when isnull(csp.qt_movimento_parcela,0)<>0 then
      csp.qt_movimento_parcela
    else
      1
    end                                as qt_saldo_pedido_venda,

    @dt_pedido_venda                   as dt_entrega_vendas_pedido,
    @dt_pedido_venda                   as dt_entrega_fabrica_pedido,

    ltrim(rtrim(cast(cs.ds_contrato as varchar(8000)))) + ' ' +

    cast('Parcela Contrato: ' + cast(isnull(csp.cd_item_contrato_servico,0) as varchar(6)) + ' ' + ltrim(rtrim(isnull(csp.nm_parc_contrato_servico,''))) as varchar(8000))    as ds_produto_pedido_venda,

    case when isnull(csp.qt_movimento_parcela,0)<>0 and isnull(csp.vl_movimento_parcela,0)>0 then
      csp.qt_movimento_parcela * isnull(csp.vl_movimento_parcela,0)
    else
      csp.vl_parc_contrato_servico
    end                                as vl_unitario_item_pedido,

--    csp.vl_parc_contrato_servico       as vl_lista_item_pedido,

    case when isnull(csp.qt_movimento_parcela,0)<>0 and isnull(csp.vl_movimento_parcela,0)>0 then
      csp.qt_movimento_parcela * isnull(csp.vl_movimento_parcela,0)
    else
      csp.vl_parc_contrato_servico
    end                                as vl_lista_item_pedido,

    null                               as pc_desconto_item_pedido,
    null                               as dt_cancelamento_item,
    null                               as dt_estoque_item_pedido,
    null                               as cd_pdcompra_item_pedido,
    null                               as dt_reprog_item_pedido,
    null                               as qt_liquido_item_pedido,
    null                               as qt_bruto_item_pedido,
    null                               as ic_fatura_item_pedido,
    null                               as ic_reserva_item_pedido,
    null                               as ic_tipo_montagem_item,
    null                               as ic_montagem_g_item_pedido,
    'N'                                as ic_subs_tributaria_item,
    null                               as cd_posicao_item_pedido,
    null                               as cd_os_tipo_pedido_venda,
    null                               as ic_desconto_item_pedido,
    null                               as dt_desconto_item_pedido,
    null                               as vl_indice_item_pedido,
    s.cd_grupo_produto,
    null                               as cd_produto,
    null                               as cd_grupo_categoria,
    s.cd_categoria_produto,
    null                               as cd_pedido_rep_pedido,
    null                               as cd_item_pedidorep_pedido,
    null                               as cd_ocorrencia,
    null                               as cd_consulta,
    @cd_usuario                        as cd_usuario,
    getdate()                          as dt_usuario,
    null                               as nm_mot_canc_item_pedido,
    null                               as nm_obs_restricao_pedido,
    null                               as cd_item_consulta,
    null                               as ic_etiqueta_emb_pedido,
    null                               as pc_ipi_item,
    null                               as pc_icms_item,
    null                               as pc_reducao_base_item,
    null                               as dt_necessidade_cliente,
    null                               as qt_dia_entrega_cliente,
    null                               as dt_entrega_cliente,
    null                               as ic_smo_item_pedido_venda,
    null                               as cd_om,
    null                               as ic_controle_pcp_pedido,
    null                               as nm_mat_canc_item_pedido,
    cs.cd_servico                      as cd_servico,
    'N'                                as ic_produto_especial,
    null                               as cd_produto_concorrente,
    null                               as ic_orcamento_pedido_venda,
   cast('' as varchar)                 as ds_produto_pedido,
   s.nm_servico                        as nm_produto_pedido,
    null                               as cd_serie_produto,
    null                               as pc_ipi,
    null                               as pc_icms,
    null                               as qt_dia_entrega_pedido,
    'S'                                as ic_sel_fechamento,
    null                               as dt_ativacao_item,
    null                               as nm_mot_ativ_item_pedido,
    null                               as nm_fantasia_produto,
    null                               as ic_etiqueta_emb_ped_venda,
    @dt_pedido_venda                   as dt_fechamento_pedido,
   cast('' as varchar)                 as ds_progfat_pedido_venda,
   'S'                                 as ic_pedido_venda_item,
    null                               as ic_ordsep_pedido_venda,
    null                               as ic_progfat_item_pedido,
    null                               as qt_progfat_item_pedido,
    null                               as cd_referencia_produto,
    null                               as ic_libpcp_item_pedido,
    cast('' as varchar)                as ds_observacao_fabrica,
    null                               as nm_observacao_fabrica1,
    null                               as nm_observacao_fabrica2,
    s.cd_unidade_servico               as cd_unidade_medida,
    null                               as pc_reducao_icms,
    null                               as pc_desconto_sobre_desc,
    null                               as nm_desconto_item_pedido,
    null                               as cd_item_contrato,
    null                               as cd_contrato_fornecimento,
    null                               as nm_kardex_item_ped_venda,
    null                               as ic_gprgcnc_pedido_venda,
    null                               as cd_pedido_importacao,
    null                               as cd_item_pedido_importacao,
    null                               as dt_progfat_item_pedido,
    null                               as qt_cancelado_item_pedido,
    null                               as qt_ativado_pedido_venda,
    null                               as cd_mes,
    null                               as cd_ano,
    null                               as ic_mp66_item_pedido,
    null                               as ic_montagem_item_pedido,
    null                               as ic_reserva_estrutura_item,
    null                               as ic_estrutura_item_pedido,
    null                               as vl_frete_item_pedido,
    null                               as cd_usuario_lib_desconto,
    null                               as dt_moeda_cotacao,
    null                               as vl_moeda_cotacao,
    null                               as cd_moeda_cotacao,
    null                               as dt_zera_saldo_pedido_item,
    null                               as cd_lote_produto,
    null                               as cd_num_serie_item_pedido,
    null                               as cd_lote_item_pedido,
    'S'                                as ic_controle_mapa_pedido,
    null                               as cd_tipo_embalagem,
    null                               as dt_validade_item_pedido,
    null                               as cd_movimento_caixa,
    null                               as vl_custo_financ_item,
    null                               as qt_garantia_item_pedido,
    null                               as cd_tipo_montagem,
    null                               as cd_montagem,
    null                               as cd_usuario_ordsep,
    null                               as ic_kit_grupo_produto,
    null                               as cd_sub_produto_especial,
    null                               as cd_plano_financeiro,
    null                               as dt_fluxo_caixa,
    null                               as ic_fluxo_caixa,
    cast('' as varchar)                as ds_servico_item_pedido,
    null                               as dt_reservado_montagem,
    null                               as cd_usuario_montagem,
    null                               as ic_imediato_produto,
    null                               as cd_mascara_classificacao,
    null                               as cd_desenho_item_pedido,
    null                               as cd_rev_des_item_pedido,
    null                               as cd_centro_custo,
    null                               as qt_area_produto,
    null                               as cd_produto_estampo,
    null                               as vl_digitado_item_desconto,
    null                               as cd_lote_Item_anterior,
    null                               as cd_programacao_entrega,
    null                               as ic_estoque_fatura,
    null                               as ic_estoque_venda,
    null                               as ic_manut_mapa_producao,
    null                               as pc_comissao_item_pedido,
    null                               as cd_produto_servico,
    null                               as ic_baixa_composicao_item,
    null                               as vl_unitario_ipi_produto,
    null                               as ic_desc_prom_item_pedido,
    null                               as cd_tabela_preco,
    null                               as cd_motivo_reprogramacao,
    null                               as qt_estoque,
    null                               as dt_estoque,
    null                               as dt_atendimento,
    null                               as qt_atendimento,
    null                               as nm_forma,
    null                               as cd_documento,
    null                               as cd_item_documento,
    null                               as nm_obs_atendimento,
    null                               as qt_atendimento_1,
    null                               as qt_atendimento_2,
    null                               as qt_atendimento_3,
    null                               as vl_bc_icms_st,
    null                               as vl_item_icms_st,
    'N'                                as ic_sel_mrp_item_pedido,
--    csp.vl_parc_contrato_servico       as vl_aux_unitario_item_pedido,

    case when isnull(csp.qt_movimento_parcela,0)<>0 and isnull(csp.vl_movimento_parcela,0)>0 then
      csp.qt_movimento_parcela * isnull(csp.vl_movimento_parcela,0)
    else
      csp.vl_parc_contrato_servico
    end                                as vl_aux_unitario_item_pedido,

    null                               as cd_it_ped_compra_cliente,
    null                               as dt_ordsep_pedido_venda,
    null                               as cd_situacao_pedido,
    null                               as ic_venda_saldo_negativo,
    null                               as cd_motivo_cancel_pedido,
    null                               as cd_item_pedido_origem,
    null                               as cd_fase_produto


--select * from servico    

  into
    #Pedido_Venda_item_a

  from
    contrato_servico cs   with (nolock) 
    inner join contrato_servico_composicao csp on csp.cd_contrato_servico = cs.cd_contrato_servico
    left outer join cliente c                  on c.cd_cliente = cs.cd_cliente
    left outer join servico s                  on s.cd_servico = cs.cd_servico

  where
    cs.cd_contrato_servico          = @cd_contrato_servico   and
    csp.cd_contrato_servico         = @cd_contrato_servico   and
    csp.cd_item_contrato_servico    = @cd_item_contrato_servico and
    isnull(csp.cd_pedido_venda,0)   = 0

  --select * from contrato_servico_composicao 

  --select * from  #Pedido_Venda_item_a

  insert into
    pedido_venda_item
  select
    *
  from
    #Pedido_venda_item_a
  
   drop table #pedido_venda_a
   drop table #pedido_venda_item_a

  --Atualiza o Número do Pedido de Venda nas Ordem de Serviços

  update
    contrato_servico_composicao
  set
    cd_pedido_venda      = @cd_pedido_venda,
    cd_item_pedido_venda = 1

  from
    contrato_servico_composicao csp 

  where
    csp.cd_contrato_servico      = @cd_contrato_servico      and
    csp.cd_item_contrato_servico = @cd_item_contrato_servico and
    isnull(csp.cd_pedido_venda,0) = 0


  --Atualiza os Totais do Pedido de Venda--------------------------------------------------------------
 
  declare @vl_total_pedido decimal(25,2)

  set @vl_total_pedido = 0.00

  select
    @vl_total_pedido = sum ( qt_item_pedido_venda * vl_unitario_item_pedido )
  from
    pedido_venda_item
  where
     cd_pedido_venda = @cd_pedido_venda

  
   update
     pedido_venda
   set
     vl_total_pedido_venda = @vl_total_pedido,
     vl_total_pedido_ipi   = @vl_total_pedido 
   from
     pedido_venda
   where
     cd_pedido_venda = @cd_pedido_venda
     
     

end


go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--1--> Individual
--exec pr_geracao_pedido_venda_contrato 87,1,'05/23/2013',4
------------------------------------------------------------------------------
