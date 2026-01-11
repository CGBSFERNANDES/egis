IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_gera_nota_saida_pedido_contrato' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_gera_nota_saida_pedido_contrato
GO

-------------------------------------------------------------------------------
--sp_helptext pr_gera_nota_saida_pedido_contrato
-------------------------------------------------------------------------------
--pr_gera_nota_saida_pedido_contrato
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2009
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000
--Autor(es)        : Carlos Cardoso Fernandes
--Banco de Dados   : Egissql
--Objetivo         : Geração de Nota Fiscal de Saída Automaticamente
--                   a Partir do Pedido de Venda
--Data             : 12.01.2009
--Alteração        : 22.01.2009 - Saldo/Status do Pedido de Venda 
--
-- 30.01.2009 - Ajuste de novos atributos - Carlos Fernandes
-- 01.04.2009 - Verificação do Pedido de Compra - Carlos Fernandes
-- 06.04.2009 - Transportadora - Carlos Fernandes 
-- 07.04.2009 - Data de Saída  da Nota Fiscal - Carlos Fernandes
-- 11.04.2009 - Pedido de Venda de Bonificação - Carlos Fernandes
-- 04.05.2009 - Bloqueia o Faturamento de Nota com Produto sem Estoque - Carlos Fernandes
-- 05.05.2009 - Tirado o Bloqueio de Estoque - Carlos Fernandes
-- 24.05.2013 - Desenvolvimento para Geração de Notas dos Pedidos de Venda de Serviço
-- 11.09.2013 - ajustes diversos - fagner/carlos
-- 20.09.2013 - geração do número de nota - carlos fernandes
-- 23.01.2018 - acerto da busca da última nota - Carlos Fernandes
-- 01.02.2018 - novos campos - Carlos Fernandes
-----------------------------------------------------------------------------------------
create procedure pr_gera_nota_saida_pedido_contrato
@cd_contrato_servico      int      = 0,
@cd_item_contrato_servico int      = 0,
@cd_pedido_venda          int      = 0,
@cd_item_pedido_venda     int      = 0,
@cd_usuario               int      = 0,
@cd_serie_nota            int      = 0,
@dt_nota_saida            datetime = ''

as

--
declare @cd_serie_nota_fiscal int
declare @pc_pis               float
declare @pc_cofins            float

select @pc_pis    = (isnull(pc_imposto,0) / 100) from IMPOSTO_ALIQUOTA where cd_imposto = 5
select @pc_cofins = (isnull(pc_imposto,0) / 100) from IMPOSTO_ALIQUOTA where cd_imposto = 4

if @pc_pis = 0
begin
   set @pc_pis = 1.65/100
end

if @pc_cofins = 0
begin
   set @pc_cofins = 7.60/100
end

declare @dt_saida_nota_saida datetime
declare @cd_operacao_fiscal  int
declare @cd_ultima_nota      int 

set @cd_ultima_nota = 0

select 
  @cd_ultima_nota = isnull(cd_ultima_nota,0) + 1
from
  movimento_contrato mc
where
  isnull(mc.ic_ativo_movimento,'N')='S'

if @cd_ultima_nota = 0
   set @cd_ultima_nota = 1


if @dt_nota_saida is null
begin
   --set @dt_geracao = cast(convert(int,getdate(),103) as datetime)
   set @dt_nota_saida = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
end

if @dt_saida_nota_saida is null
begin
   --set @dt_geracao = cast(convert(int,getdate(),103) as datetime)
   set @dt_saida_nota_saida = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
end

--Série da Nota Fiscal-------------------------------------------------------------------------------------------

if @cd_serie_nota is null or @cd_serie_nota = 0
   set @cd_serie_nota = 1


--Verifica a série do Config-------------------------------------------------------------------------------------

select
  @cd_serie_nota_fiscal = isnull(cd_serie_nota_fiscal,0)
from
  parametro_servico

where
  cd_empresa = dbo.fn_empresa()


if isnull(@cd_serie_nota_fiscal ,0)<>0 
   set @cd_serie_nota = @cd_serie_nota_fiscal

-----------------------------------------------

--declare @cd_operacao_fiscal  int

declare @Tabela		     varchar(80)
declare @cd_nota_saida       int
declare @cd_fase_produto     int

--Fase do Produto------------------------------

select
  @cd_fase_produto = isnull(cd_fase_produto,0)
from
  Parametro_Comercial with (nolock)
where
  cd_empresa = dbo.fn_empresa()

  --declare @cd_pedido_venda     int

  -- Nome da Tabela usada na geração e liberação de códigos

  set @Tabela          = cast(DB_NAME()+'.dbo.Nota_Saida' as varchar(80))
  set @cd_nota_saida = 0


  select
    @cd_nota_saida = max( isnull(cd_nota_saida,0) ) + 1
  from
    nota_saida

--   where
--     cd_serie_nota = @cd_serie_nota


  if @cd_nota_saida = 0 or @cd_nota_saida is null
     set @cd_nota_saida = 1


  if not exists ( select top 1 cd_nota_saida from nota_saida where cd_nota_saida = @cd_nota_saida )
  begin
   delete from nota_saida_item where cd_nota_saida = @cd_nota_saida
  end


--   exec EgisADMIN.dbo.sp_PegaCodigo @Tabela, 'cd_nota_saida', @codigo = @cd_nota_saida output
--   exec EgisADMIN.dbo.sp_LiberaCodigo @Tabela, @cd_nota_saida, 'D'

--   select @cd_nota_saida
--   print @cd_nota_saida

  --select * from nota_saida

--   while exists(Select top 1 'x' from nota_saida 
--                where cd_nota_saida = @cd_nota_saida 
--                order by cd_nota_saida desc )
--   begin
-- --    select @cd_nota_saida
-- 
--     exec EgisADMIN.dbo.sp_PegaCodigo @Tabela, 'cd_nota_saida', @codigo = @cd_nota_saida output
-- 
--     -- limpeza da tabela de código
--     exec EgisADMIN.dbo.sp_LiberaCodigo @Tabela, @cd_nota_saida, 'D'
-- 
--   end


--   select @cd_nota_saida
--   print @cd_nota_saida

  --Geração da Operação Fiscal---------------------------------------------------

  if @cd_operacao_fiscal is null 
  begin
     set @cd_operacao_fiscal = 0
  end

--Verifica se Pedido de Venda já Possui Nota Fiscal de Saída

--Checar se o Pedido está em algum item de Nota Fiscal de Saída
--Nota_Saida_Item

if exists ( select top 1 cd_pedido_venda 
            from
              Nota_Saida_Item with (nolock) 
            where
              cd_pedido_venda = @cd_pedido_venda and
              dt_cancel_item_nota_saida is null )
    
begin
  set @cd_pedido_venda = 0
end
  
--Verificar a Operação Fiscal-------------------------------------------------------------------------------------------------------------------

--Serviço


--Geração da Nota Fiscal------------------------------------------------------------------------------------------------------------------------


if @cd_pedido_venda > 0
begin
  
  -------------------------------------------------------------------------------
  --Nota de Saída
  -------------------------------------------------------------------------------
  --nota_saida
  --select * from Nota_saida
  --select * from Pedido_Venda
  --select * from Cliente
  --select * from operacao_fiscal

  --Operação Fiscal


  -------------------------------------------------------------------------------
  --Buscar o Número do Formulário
  -------------------------------------------------------------------------------

  select
    @cd_nota_saida                               as cd_nota_saida,
--    @cd_nota_saida                               as cd_num_formulario_nota,

    @cd_ultima_nota                              as cd_num_formulario_nota,

    @dt_nota_saida                               as dt_nota_saida,
    null                                         as cd_requisicao_faturamento,

    --Operação Fiscal

    ep.cd_operacao_fiscal_servico                as cd_operacao_fiscal,

    c.nm_fantasia_cliente                        as nm_fantasia_nota_saida,

    case when isnull(pv.cd_transportadora,0)=0 then
     c.cd_transportadora
    else
      pv.cd_transportadora
    end                                          as cd_transportadora,

    pv.cd_destinacao_produto,
    null                                         as cd_obs_padrao_nf,
    pv.cd_tipo_pagamento_frete,
    cast('' as varchar)                          as ds_obs_compl_nota_saida,
    null                                         as qt_peso_liq_nota_saida,
    null                                         as qt_peso_bruto_nota_saida,
    null                                         as qt_volume_nota_saida,
    null                                         as cd_especie_embalagem,
    null                                         as nm_especie_nota_saida,
    null                                         as nm_marca_nota_saida,
    null                                         as cd_placa_nota_saida,
    null                                         as nm_numero_emb_nota_saida,
    'N'                                          as ic_emitida_nota_saida,
    null                                         as nm_mot_cancel_nota_saida,
    null                                         as dt_cancel_nota_saida,
    @dt_saida_nota_saida                         as dt_saida_nota_saida,
    @cd_usuario                                  as cd_usuario,
    getdate()                                    as dt_usuario,
    null                                         as vl_bc_icms,
    null                                         as vl_icms,
    null                                         as vl_bc_subst_icms,
    null                                         as vl_produto,
    null                                         as vl_frete,
    null                                         as vl_seguro,
    null                                         as vl_desp_acess,
    null                                         as vl_total,
    null                                         as vl_icms_subst,
    null                                         as vl_ipi,
    pv.cd_vendedor,
    null                                         as cd_fornecedor,
    pv.cd_cliente, 
    null                                           as cd_itinerario,
    null                                           as nm_obs_entrega_nota_saida,
    null                                           as nm_entregador_nota_saida,
    null                                           as cd_observacao_entrega,
    null                                           as cd_entregador,
    null                                           as ic_entrega_nota_saida,
    null                                           as sg_estado_placa,
    pv.cd_pdcompra_pedido_venda                    as cd_pedido_cliente,
    --null                                       as cd_pedido_cliente,
    1                                              as cd_status_nota,
    null                                           as cd_tipo_calculo,
    null                                           as cd_num_formulario,
    c.cd_cnpj_cliente                              as cd_cnpj_nota_saida,
    c.cd_inscestadual                              as cd_inscest_nota_saida,
    c.cd_inscMunicipal                             as cd_inscmunicipal_nota,
    --Entrega
    c.cd_cep                                       as cd_cep_entrega,
    cast(c.nm_endereco_cliente  as varchar(60))    as nm_endereco_entrega,
    c.cd_numero_endereco                           as cd_numero_endereco_ent,
    cast(c.nm_complemento_endereco as varchar(30)) as nm_complemento_end_ent,
    cast(c.nm_bairro as varchar(25))             as nm_bairro_entrega,
    c.cd_ddd                                     as cd_ddd_nota_saida,
    c.cd_telefone                                as cd_telefone_nota_saida,
    c.cd_fax                                     as cd_fax_nota_saida,
    p.nm_pais                                    as nm_pais_nota_saida,
    e.sg_estado                                  as sg_estado_entrega,
    cast(cid.nm_cidade as varchar(50))           as nm_cidade_entrega,
    null                                         as hr_saida_nota_saida,
    cast(c.nm_endereco_cliente as varchar(60))   as nm_endereco_cobranca,
    cast(c.nm_bairro as varchar(25))             as nm_bairro_cobranca,
    c.cd_cep                                     as cd_cep_cobranca,
    cast(cid.nm_cidade as varchar(50))           as nm_cidade_cobranca,
    e.sg_estado                                  as sg_estado_cobranca,
    c.cd_numero_endereco                         as cd_numero_endereco_cob,
    cast(c.nm_complemento_endereco as varchar(30)) as nm_complemento_end_cob,
    null                                           as qt_item_nota_saida,
    'N'                                            as ic_outras_operacoes,
    @cd_pedido_venda                               as cd_pedido_venda,
    'A'                                            as ic_status_nota_saida,
    cast('' as varchar)                            as ds_descricao_servico,
    null                                           as vl_iss,
    null                                           as vl_servico,
    'N'                                            as ic_minuta_nota_saida,
    @dt_nota_saida + 1                             as dt_entrega_nota_saida,
    e.sg_estado                                    as sg_estado_nota_saida,
    cast(cid.nm_cidade  as varchar(50))            as nm_cidade_nota_saida,
    cast(c.nm_bairro    as varchar(25))            as nm_bairro_nota_saida,
    cast(c.nm_endereco_cliente as varchar(60))     as nm_endereco_nota_saida,
    c.cd_numero_endereco                           as cd_numero_end_nota_saida,
    c.cd_cep                                       as cd_cep_nota_saida,
    cast(c.nm_razao_social_cliente as varchar(60)) as nm_razao_social_nota,
    c.nm_razao_social_cliente_c                    as nm_razao_social_c,
    opf.cd_mascara_operacao                        as cd_mascara_operacao,
    opf.nm_operacao_fiscal                         as nm_operacao_fiscal,
    1                                              as cd_tipo_destinatario,
    null                                           as cd_contrato_servico,
    pv.cd_condicao_pagamento,
    null                                           as vl_irrf_nota_saida,
    null                                           as pc_irrf_serv_empresa,
    c.nm_fantasia_cliente                          as nm_fantasia_destinatario,
    c.nm_complemento_endereco                      as nm_compl_endereco_nota,
    'N'                                            as ic_sedex_nota_saida,
    null                                           as ic_coleta_nota_saida,
    null                                           as dt_coleta_nota_saida,
    null                                           as nm_coleta_nota_saida,
    pv.cd_tipo_local_entrega                       as cd_tipo_local_entrega,
    null                                           as ic_dev_nota_saida,
    null                                           as cd_nota_dev_nota_saida,
    null                                           as dt_nota_dev_nota_saida,
    c.nm_razao_social_cliente,
    c.nm_razao_social_cliente_c,
    gof.cd_tipo_operacao_fiscal,
    null                                           as vl_bc_ipi,
    null                                           as cd_mascara_operacao3,
    null                                           as cd_mascara_operacao2,
    null                                           as cd_operacao_fiscal3,
    null                                           as cd_operacao_fiscal2,
    null                                           as nm_operacao_fiscal2,
    null                                           as nm_operacao_fiscal3,
    null                                           as cd_tipo_operacao_fiscal2,
    null                                           as cd_tipo_operacao_fiscal3,
    null                                           as cd_tipo_operacao3,
    null                                           as cd_tipo_operacao2,
    null                                           as ic_zona_franca,
    null                                           as cd_nota_fiscal_origem,
    'A'                                            as ic_forma_nota_saida,
    @cd_serie_nota                                 as cd_serie_nota,
    pv.cd_vendedor                                 as cd_vendedor_externo,
    null                                           as nm_local_entrega_nota,
    c.cd_cnpj_cliente                              as cd_cnpj_entrega_nota,
    c.cd_inscestadual                              as cd_inscest_entrega_nota,
    null                                           as vl_base_icms_reduzida,
    null                                           as vl_bc_icms_reduzida,
    null                                           as cd_dde_nota_saida,
    null                                           as dt_dde_nota_saida,
    null                                           as nm_fat_com_nota_saida,
    null                                           as vl_icms_isento,
    null                                           as vl_icms_outros,
    null                                           as vl_icms_obs,
    null                                           as vl_ipi_isento,
    null                                           as vl_ipi_outros,
    null                                           as vl_ipi_obs,
    'N'                                            as ic_mp66_item_nota_saida,
    'N'                                            as ic_fiscal_nota_saida,
    c.cd_pais,
    1                                              as cd_moeda,
    null                                           as dt_cambio_nota_saida,
    null                                           as vl_cambio_nota_saida,
    null                                           as qt_desconto_nota_saida,
    null                                           as vl_desconto_nota_saida,
    null                                           as qt_peso_real_nota_saida,
    cast('' as varchar)                            as ds_obs_usuario_nota_saida,
    null                                           as ic_obs_usuario_nota_saida,
    null                                           as cd_requisicao_fat_ant,
    null                                           as qt_ord_entrega_nota_saida,
    'N'                                            as ic_credito_icms_nota,
    null                                           as ic_locacao_cilindro_nota,
    null                                           as ic_smo_nota_saida,
    null                                           as cd_di,
    null                                           as cd_guia_trafego_nota_said,
    null                                           as dt_lancamento_entrega,
    null                                           as vl_iss_retido,
    null                                           as vl_cofins,
    null                                           as vl_pis,
    null                                           as vl_csll,
    null                                           as nm_mot_ativacao_nota_saida,
    null                                           as vl_desp_aduaneira,
    null                                           as ic_di_carregada,
    null                                           as vl_ii,
    null                                           as pc_ii,
    null                                           as ic_cupom_fiscal,
    null                                           as cd_cupom_fiscal,
    null                                           as cd_loja,
    null                                           as vl_simbolico,
--    cast(@cd_nota_saida as varchar)                as cd_identificacao_nota_saida,

    @cd_ultima_nota                                as cd_identificacao_nota_saida,

    null                                           as cd_coleta_nota_saida,
    null                                           as qt_ord_entregador_saida,
    null                                           as vl_inss_nota_saida,
    null                                           as pc_inss_servico,
    @cd_serie_nota                                 as cd_serie_nota_fiscal,
    null                                           as vl_icms_desconto,
    null                                           as ic_etiqueta_nota_saida,
    null                                           as ic_imposto_nota_saida,
    null                                           as qt_cubagem_nota_saida,
    null                                           as ic_peso_recalcular,
    null                                           as qt_formulario_nota_saida,
    null                                           as ic_reprocessar_dados_adic,
    null                                           as vl_mp_aplicada_nota,
    null                                           as vl_mo_aplicada_nota,
    null                                           as ic_reprocessar_parcela,
    null                                           as ic_sel_nota_saida,
    null                                           as cd_ordem_carga,
    pvt.cd_veiculo,
    pvt.cd_motorista,
    ci.cd_forma_pagamento,
   'N'                                             as ic_nfe_nota_saida,
    null                                           as cd_motivo_dev_nota,
    null                                           as ic_nfp_nota_saida,
    null                                           as dt_entrada_nota_saida,
    snf.qt_serie_nota_fiscal                       as qt_serie_nota_fiscal,
    snf.cd_modelo_serie_nota                       as cd_modelo_serie_nota,
    cd_finalidade_nfe,
    null                                           as cd_forma_emissao_nfe,
    null                                           as vl_pis_retencao,
    null                                           as vl_cofins_retencao,
    null                                           as hr_nota_saida,
    null                                           as ic_comissao_nota,
    null                                           as vl_devolucao_nota_saida,
    null                                           as cd_portador_cobranca,
    null                                           as cd_chave_acesso,
    null                                           as vl_icms_desonerado,
    null                                           as vl_total_tributos,
    null                                           as nm_contato,
    null                                           as cd_conta,
    null                                           as vl_vFCPUFDest,
    null                                           as vl_vICMSUFDest,
    null                                           as vl_vICMSUFRemet,
    null                                           as vl_ipi_devolucao,
    null                                           as vl_troco,
    null                                           as vl_vFCP,
    null                                           as vl_vFCPST,
    null                                           as vl_vFCPSTRet,
    null                                           as dt_autorizacao_nfse

 




--select top 1 * from nota_saida
--select * from cliente_informacao_credito

  into
    #Nota_Saida

  from
    Pedido_Venda pv                                with (nolock) 
    inner join Cliente c                           with (nolock) on c.cd_cliente                 = pv.cd_cliente
    left outer join Cliente_Informacao_Credito  ci with (nolock) on ci.cd_cliente                = c.cd_cliente
    left outer join Pedido_Venda_Transporte pvt    with (nolock) on pvt.cd_pedido_venda          = pv.cd_pedido_venda  
    left outer join Pais p                         with (nolock) on p.cd_pais                    = c.cd_pais
    left outer join Estado e                       with (nolock) on e.cd_estado                  = c.cd_estado
    left outer join Cidade cid                     with (nolock) on cid.cd_cidade                = c.cd_cidade
    left outer join Estado_Parametro ep            WITH (NOLOCK) on ep.cd_pais                   = c.cd_pais and
                                                                    ep.cd_estado                 = c.cd_estado



    left outer join Operacao_Fiscal opf            with (nolock) on opf.cd_operacao_fiscal       = case when isnull(@cd_operacao_fiscal,0)>0 then @cd_operacao_fiscal
                                                                    else
                                                                     ep.cd_operacao_fiscal_servico
                                                                    end

    left outer join Grupo_Operacao_Fiscal gof      with (nolock) on gof.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal


    left outer join Serie_nota_fiscal snf          with (Nolock) on snf.cd_serie_nota_fiscal     = @cd_serie_nota

--select * from pedido_venda
   
  where
    pv.cd_pedido_venda = @cd_pedido_venda


--  select * from #Nota_Saida

  insert into
    Nota_Saida
  select
    *
-- cd_nota_saida,
-- cd_num_formulario_nota,
-- dt_nota_saida,
-- cd_requisicao_faturamento,
-- cd_operacao_fiscal,
-- nm_fantasia_nota_saida,
-- cd_transportadora,
-- cd_destinacao_produto,
-- cd_obs_padrao_nf,
-- cd_tipo_pagamento_frete,
-- ds_obs_compl_nota_saida,
-- qt_peso_liq_nota_saida,
-- qt_peso_bruto_nota_saida,
-- qt_volume_nota_saida,
-- cd_especie_embalagem,
-- nm_especie_nota_saida,
-- nm_marca_nota_saida,
-- cd_placa_nota_saida,
-- nm_numero_emb_nota_saida,
-- ic_emitida_nota_saida,
-- nm_mot_cancel_nota_saida,
-- dt_cancel_nota_saida,
-- dt_saida_nota_saida,
-- cd_usuario,
-- dt_usuario,
-- vl_bc_icms,
-- vl_icms,
-- vl_bc_subst_icms,
-- vl_produto,
-- vl_frete,
-- vl_seguro,
-- vl_desp_acess,
-- vl_total,
-- vl_icms_subst,
-- vl_ipi,
-- cd_vendedor,
-- cd_fornecedor,
-- cd_cliente,
-- cd_itinerario,
-- nm_obs_entrega_nota_saida,
-- nm_entregador_nota_saida,
-- cd_observacao_entrega,
-- cd_entregador,
-- ic_entrega_nota_saida,
-- sg_estado_placa,
-- cd_pedido_cliente,
-- cd_status_nota,
-- cd_tipo_calculo,
-- cd_num_formulario,
-- cd_cnpj_nota_saida,
-- cd_inscest_nota_saida,
-- cd_inscmunicipal_nota,
-- cd_cep_entrega,
-- nm_endereco_entrega,
-- cd_numero_endereco_ent,
-- nm_complemento_end_ent,
-- nm_bairro_entrega,
-- cd_ddd_nota_saida,
-- cd_telefone_nota_saida,
-- cd_fax_nota_saida,
-- nm_pais_nota_saida,
-- sg_estado_entrega,
-- nm_cidade_entrega,
-- hr_saida_nota_saida,
-- nm_endereco_cobranca,
-- nm_bairro_cobranca,
-- cd_cep_cobranca,
-- nm_cidade_cobranca,
-- sg_estado_cobranca,
-- cd_numero_endereco_cob,
-- nm_complemento_end_cob,
-- qt_item_nota_saida,
-- ic_outras_operacoes,
-- cd_pedido_venda,
-- ic_status_nota_saida,
-- ds_descricao_servico,
-- vl_iss,
-- vl_servico,
-- ic_minuta_nota_saida,
-- dt_entrega_nota_saida,
-- sg_estado_nota_saida,
-- nm_cidade_nota_saida,
-- nm_bairro_nota_saida,
-- nm_endereco_nota_saida,
-- cd_numero_end_nota_saida,
-- cd_cep_nota_saida,
-- nm_razao_social_nota,
-- nm_razao_social_c,
-- cd_mascara_operacao,
-- nm_operacao_fiscal,
-- cd_tipo_destinatario,
-- cd_contrato_servico,
-- cd_condicao_pagamento,
-- vl_irrf_nota_saida,
-- pc_irrf_serv_empresa,
-- nm_fantasia_destinatario,
-- nm_compl_endereco_nota,
-- ic_sedex_nota_saida,
-- ic_coleta_nota_saida,
-- dt_coleta_nota_saida,
-- nm_coleta_nota_saida,
-- cd_tipo_local_entrega,
-- ic_dev_nota_saida,
-- cd_nota_dev_nota_saida,
-- dt_nota_dev_nota_saida,
-- nm_razao_social_cliente,
-- nm_razao_socila_cliente_c,
-- cd_tipo_operacao_fiscal,
-- vl_bc_ipi,
-- cd_mascara_operacao3,
-- cd_mascara_operacao2,
-- cd_operacao_fiscal3,
-- cd_operacao_fiscal2,
-- nm_operacao_fiscal2,
-- nm_operacao_fiscal3,
-- cd_tipo_operacao_fiscal2,
-- cd_tipo_operacao_fiscal3,
-- cd_tipo_operacao3,
-- cd_tipo_operacao2,
-- ic_zona_franca,
-- cd_nota_fiscal_origem,
-- ic_forma_nota_saida,
-- cd_serie_nota,
-- cd_vendedor_externo,
-- nm_local_entrega_nota,
-- cd_cnpj_entrega_nota,
-- cd_inscest_entrega_nota,
-- vl_base_icms_reduzida,
-- vl_bc_icms_reduzida,
-- cd_dde_nota_saida,
-- dt_dde_nota_saida,
-- nm_fat_com_nota_saida,
-- vl_icms_isento,
-- vl_icms_outros,
-- vl_icms_obs,
-- vl_ipi_isento,
-- vl_ipi_outros,
-- vl_ipi_obs,
-- ic_mp66_item_nota_saida,
-- ic_fiscal_nota_saida,
-- cd_pais,
-- cd_moeda,
-- dt_cambio_nota_saida,
-- vl_cambio_nota_saida,
-- qt_desconto_nota_saida,
-- vl_desconto_nota_saida,
-- qt_peso_real_nota_saida,
-- ds_obs_usuario_nota_saida,
-- ic_obs_usuario_nota_saida,
-- cd_requisicao_fat_ant,
-- qt_ord_entrega_nota_saida,
-- ic_credito_icms_nota,
-- ic_locacao_cilindro_nota,
-- ic_smo_nota_saida,
-- cd_di,
-- cd_guia_trafego_nota_said,
-- dt_lancamento_entrega,
-- vl_iss_retido,
-- vl_cofins,
-- vl_pis,
-- vl_csll,
-- nm_mot_ativacao_nota_saida,
-- vl_desp_aduaneira,
-- ic_di_carregada,
-- vl_ii,
-- pc_ii,
-- ic_cupom_fiscal,
-- cd_cupom_fiscal,
-- cd_loja,
-- vl_simbolico,
-- cd_identificacao_nota_saida,
-- cd_coleta_nota_saida,
-- qt_ord_entregador_saida,
-- vl_inss_nota_saida,
-- pc_inss_servico,
-- cd_serie_nota_fiscal,
-- vl_icms_desconto,
-- ic_etiqueta_nota_saida,
-- ic_imposto_nota_saida,
-- qt_cubagem_nota_saida,
-- ic_peso_recalcular,
-- qt_formulario_nota_saida,
-- ic_reprocessar_dados_adic,
-- vl_mp_aplicada_nota,
-- vl_mo_aplicada_nota,
-- ic_reprocessar_parcela,
-- ic_sel_nota_saida,
-- cd_ordem_carga,
-- cd_veiculo,
-- cd_motorista,
-- cd_forma_pagamento,
-- ic_nfe_nota_saida,
-- cd_motivo_dev_nota,
-- ic_nfp_nota_saida,
-- dt_entrada_nota_saida,
-- qt_serie_nota_fiscal,
-- cd_modelo_serie_nota,
-- cd_finalidade_nfe,
-- cd_forma_emissao_nfe,
-- vl_pis_retencao,
-- vl_cofins_retencao,
-- hr_nota_saida,
-- ic_comissao_nota,
-- vl_devolucao_nota_saida,
-- cd_portador_cobranca,
-- cd_chave_acesso,
-- vl_icms_desonerado,
-- vl_total_tributos,
-- nm_contato,
-- cd_conta,
-- vl_vFCPUFDest,
-- vl_vICMSUFDest,
-- vl_vICMSUFRemet
    
  from
    #Nota_Saida

  -------------------------------------------------------------------------------
  --Itens Nota de Saída
  -------------------------------------------------------------------------------
  --select * from nota_saida_item
  --select * from pedido_venda_item
  --select * from produto_fiscal
  --select * from classificacao_fiscal

  select
    @cd_nota_saida                                   as cd_nota_saida,
    identity(int,1,1)                                as cd_item_nota_saida,
    @cd_nota_saida                                   as cd_num_formulario_nota,
    p.nm_fantasia_produto,
    --
    cast(pvi.ds_produto_pedido_venda as varchar(8000)) as ds_item_nota_saida,

    cast(pvi.cd_pdcompra_item_pedido as varchar(40))   as cd_pd_compra_item_nota,
    pvi.cd_posicao_item_pedido                         as cd_posicao_item_nota,
    pvi.cd_os_tipo_pedido_venda                        as cd_os_item_nota_saida,
    pvi.vl_unitario_item_pedido                        as vl_unitario_item_nota,
    null                                               as dt_restricao_item_nota,
    'A'                                                as ic_status_item_nota_saida,
    cast('' as varchar)                                as nm_motivo_restricao_item,
    null                                               as qt_devolucao_item_nota,
    null                                               as cd_requisicao_faturamento,
    null                                               as cd_item_requisicao,
    pvi.cd_produto,
    pf.cd_procedencia_produto,

    case when isnull(s.cd_tributacao,0)>0
    then 
      s.cd_tributacao
    else
      pf.cd_tributacao
    end                                                as cd_tributacao,

    --Total do Item

    isnull(pvi.qt_item_pedido_venda,0)
    * isnull(pvi.vl_unitario_item_pedido,0)          as vl_total_item,

    --Unidade de Medida-----------------------------------------------------------------------------------

    case when isnull(pvi.cd_unidade_medida,0)>0 then
      pvi.cd_unidade_medida
    else
      case when isnull(pvi.cd_produto,0)>0 then p.cd_unidade_medida 
      else
        case when isnull(pvi.cd_servico,0)>0 then s.cd_unidade_servico
        else
          null
        end
      end
    end                                              as cd_unidade_medida,

    pf.pc_aliquota_icms_produto                      as pc_icms,
    cf.pc_ipi_classificacao                          as pc_ipi,
    cf.vl_ipi_classificacao                          as vl_ipi,
    @cd_usuario                                      as cd_usuario,
    getdate()                                        as dt_usuario,
    pvi.qt_saldo_pedido_venda                        as qt_item_nota_saida,
    pvi.qt_liquido_item_pedido                       as qt_liquido_item_nota,
    pvi.qt_bruto_item_pedido                         as qt_bruto_item_nota_saida,
    pvi.cd_item_pedido_venda,
    pvi.cd_pedido_venda,

    case when isnull(p.cd_categoria_produto,0)>0 then
       p.cd_categoria_produto
    else
       case when isnull(s.cd_servico,0)>0 then
         s.cd_servico
       else
         null
       end
    end                                              as cd_categoria_produto,

    pf.cd_classificacao_fiscal,

    --Situação

    cast(cast(isnull(pp.cd_digito_procedencia,'0') as varchar(1)) + 
        ti.cd_digito_tributacao_icms  as varchar(3)) as cd_situacao_tributaria,

    pvi.vl_frete_item_pedido                     as vl_frete_item,
    null                                         as vl_seguro_item,
    null                                         as vl_desp_acess_item,
    null                                         as pc_icms_desc_item,
    null                                         as dt_cancel_item_nota_saida,
    null                                         as pc_desconto_item,
    null                                         as cd_tipo_calculo,
    null                                         as cd_lote_produto,
    null                                         as cd_numero_serie_produto,
    1                                            as cd_status_nota,
    cast(case when isnull(pvi.cd_produto,0)>0 then
       p.nm_produto
    else
      case when isnull(pvi.cd_servico,0)>0 then
        s.nm_servico
      else
        null
      end
    end  as varchar(100))                        as nm_produto_item_nota,

    null                                         as qt_saldo_atual_produto,
    pvi.cd_servico                               as cd_servico,                     --pedido_venda_item

    case when isnull(pvi.cd_servico,0)>0 then
     cast(s.ds_servico as varchar)
    else
      cast(null as varchar)   
    end                                          as ds_servico,
    isnull(s.pc_iss_servico,0)                   as pc_iss_servico,
    isnull(pvi.vl_unitario_item_pedido,0)        as vl_servico,
    isnull(s.pc_irrf_servico,0)                  as pc_irrf_serv_empresa,
    case when isnull(pvi.cd_servico,0)>0 then
      ( isnull(pvi.qt_item_pedido_venda,0) * isnull(pvi.vl_unitario_item_pedido,0) ) * isnull(s.pc_irrf_servico,0)/100
    else        
      null        
    end                                          as vl_irrf_nota_saida,

    case when isnull(pvi.cd_servico,0)>0 then
      ( isnull(pvi.qt_item_pedido_venda,0) * isnull(pvi.vl_unitario_item_pedido,0) ) * isnull(s.pc_iss_servico,0)/100
    else        
      null        
    end                                          as vl_iss_servico,
    null                                         as pc_reducao_icms,
    null                                         as cd_pdcompra_item_nota,
  --pvi.cd_pdcompra_item_pedido                  as cd_pdcompra_item_nota,
    null                                         as cd_registro_exportacao,
--  @cd_operacao_fiscal                          as cd_operacao_fiscal,
    case when isnull(pvi.cd_servico,0)>0 then
      case when isnull(ep.cd_operacao_fiscal_servico,0)>0 then ep.cd_operacao_fiscal_servico else s.cd_operacao_fiscal end

    else
     (select
       top 1 
       --Consignação
       case when isnull(pv.ic_consignacao_pedido,'N')='S' and isnull(ofi.cd_oper_fiscal_consig,0)>0 then
            isnull(ofi.cd_oper_fiscal_consig,0)
       else      
          --Operação Triangular
          case when isnull(pv.ic_operacao_triangular,'N')='S' and isnull(ofi.cd_oper_fiscal_op_triang,0)>0 then
            isnull(ofi.cd_oper_fiscal_op_triang,0)
          else
            --Substituição Tributária
            case when isnull(ofi.cd_oper_fiscal_subtrib,0)>0 and isnull(pf.ic_substrib_produto,'N')='S' then
                isnull(ofi.cd_oper_fiscal_subtrib,0) 
            else
               --Amostra
               case when isnull(ofi.cd_oper_fiscal_amostra,0)>0 and isnull(pv.ic_amostra_pedido_venda,'N')='S' then
                   isnull(ofi.cd_oper_fiscal_amostra,0)     
               else
                 --Bonificação---
                   case when isnull(ofi.cd_oper_fiscal_bonif,0)>0 and isnull(pv.ic_bonificacao_pedido_venda,'N')='S' then
                      isnull(ofi.cd_oper_fiscal_bonif,0)     
                   else 
                    --Entrega Futura
                     case when isnull(ofi.cd_oper_entrega_futura,0)>0 and isnull(pv.ic_entrega_futura,'N')='S' then
                         isnull(ofi.cd_oper_entrega_futura,0)
                    --Operação Fiscal
                     else
                       isnull(ofi.cd_operacao_fiscal,0) 
                     end
                   end
               end
            end
         end
       end
     from
       Operacao_Fiscal ofi with (nolock) 
     where
       replace(ofi.cd_mascara_operacao,'.','')  =  (cast(case when e.sg_estado = 'EX' then 7 
                                                                                 else ep.cd_digito_fiscal_saida end as char(1)) 
                                                    + 
                                                    
                                                    cast(tp.cd_fiscal_tipo_produto as char(5) ))

                                                                                              and


       ofi.cd_destinacao_produto                = pv.cd_destinacao_produto                    and
       isnull(ofi.ic_zfm_operacao_fiscal,'N')   = isnull(ep.ic_zona_franca,'N')               and
       isnull(ofi.ic_consignacao_op_fiscal,'N') = isnull(pv.ic_consignacao_pedido,'N')        and
       isnull(ofi.ic_entrega_futura,'N')        = isnull(pv.ic_entrega_futura,'N') 

     order by ofi.cd_operacao_fiscal )

    end                                          as cd_operacao_fiscal,

    case when isnull(pvi.cd_servico,0)<>0 then
      'S'
    else
      'P'
    end                                          as ic_tipo_nota_saida_item,

    null                                         as qt_saldo_estoque,
    null                                         as cd_di,
    null                                         as nm_di,
    null                                         as nm_invoice,
    'N'                                          as ic_movimento_estoque,
    null                                         as qt_ant_item_nota_saida,
    null                                         as nm_kardex_item_nota_saida,
    null                                         as ic_dev_nota_saida,
    null                                         as cd_nota_dev_nota_saida,
    null                                         as cd_pedido_importacao,
    null                                         as cd_item_ped_imp,
    null                                         as dt_nota_saida,
    
    pvi.cd_grupo_produto,
    null                                         as vl_icms_item,
    null                                         as vl_base_icms_item,
    null                                         as vl_base_ipi_item,
    null                                         as pc_subs_trib_item,
    null                                         as cd_reg_exportacao_item,
    null                                         as vl_icms_isento_item,
    null                                         as vl_icms_outros_item,
    null                                         as vl_icms_obs_item,
    null                                         as vl_ipi_isento_item,
    null                                         as vl_ipi_outros_item,
    null                                         as vl_ipi_obs_item,
    case when isnull(p.cd_fase_produto_baixa,0)>0
    then
      p.cd_fase_produto_baixa
    else
      @cd_fase_produto
    end                                          as cd_fase_produto,
    'N'                                          as ic_mp66_item_nota_saida,
    p.cd_mascara_produto,
    null                                         as cd_conta,
    null                                         as cd_produto_smo,
    null                                         as cd_grupo_produto_smo,
    null                                         as vl_ipi_corpo_nota_saida,
    null                                         as ic_icms_zerado_item,
    null                                         as ic_ipi_zerado_item,
    null                                         as vl_bc_subst_icms_item,
    null                                         as cd_tributacao_anterior,
    null                                         as cd_di_item,
    null                                         as ic_iss_servico,
    null                                         as vl_cofins,
    null                                         as vl_pis,
    null                                         as vl_csll,
    null                                         as dt_ativacao_nota_saida,
    null                                         as cd_moeda_cotacao,
    null                                         as vl_moeda_cotacao,
    null                                         as dt_moeda_cotacao,
    null                                         as cd_lote_item_nota_saida,
    null                                         as cd_num_serie_item_nota,
    null                                         as vl_ii,
    null                                         as pc_ii,
    null                                         as vl_desp_aduaneira_item,
    @pc_cofins                                   as pc_cofins,
    @pc_pis                                      as pc_pis,
    null                                         as ic_cambio_fixado_pedido_venda,
    null                                         as ic_perda_item_nota_saida,
    null                                         as cd_lote_item_nota,
    null                                         as vl_inss_nota_saida,
    null                                         as pc_inss_servico,
    null                                         as vl_icms_desc_item,
    null                                         as vl_icms_subst_icms_item,
    null                                         as qt_cubagem_item_nota,
    null                                         as cd_rnc,
    null                                         as cd_nota_entrada,
    null                                         as cd_item_nota_entrada,
    null                                         as ic_subst_tributaria_item,
    null                                         as cd_nota_saida_origem,
    null                                         as cd_item_nota_origem,
    null                                         as vl_unitario_ipi_produto,
    null                                         as qt_multiplo_embalagem,
    null                                         as cd_motivo_dev_nota,
    null                                         as pc_reducao_icms_st,
    null                                         as pc_icms_interna_st,
    null                                         as vl_pis_retencao,
    null                                         as vl_cofins_retencao,
    null                                         as pc_icms_original,
    null                                         as cd_ordem_item_nota,
    null                                         as cd_it_ped_compra_cliente,
    null                                         as vl_item_desconto_nota,
    null                                         as ic_alteracao_fatura_pedido,
    null                                         as vl_base_pis_item,
    null                                         as vl_base_cofins_item,
    null                                         as pc_importado_icms_estado,
    null                                         as pc_pis_desc_item,
    null                                         as pc_cofins_desc_item,
    null                                         as cd_digito_modalidade_st,
    null                                         as pc_csll_servico,
    null                                         as vl_icms_desoneracao,
    null                                         as cd_motivo_desoneracao,
    null                                         as cd_codigo_barra_produto,
    null                                         as cd_fci



--select top 1 * from nota_saida_item

  into
    #Nota_Saida_Item

  from
    Pedido_Venda_Item pvi                   with (nolock) 
    inner join Pedido_Venda pv              with (nolock) on pv.cd_pedido_venda         = pvi.cd_pedido_venda
--  inner join Nota_Saida ns                with (nolock) on ns.cd_nota_saida           = @cd_nota_saida
    left outer join Servico s               with (nolock) on s.cd_servico               = pvi.cd_servico
    left outer join Produto p               with (nolock) on pvi.cd_produto             = p.cd_produto
    left outer join Produto_Fiscal pf       with (nolock) on pf.cd_produto              = p.cd_produto 

    left outer join Cliente c               WITH (NOLOCK) on c.cd_cliente               = pv.cd_cliente         

    left outer join Estado e                with(nolock)  on e.cd_estado                = c.cd_estado and
                                                             e.cd_pais                  = c.cd_pais

    left outer join Estado_Parametro ep     WITH (NOLOCK) on ep.cd_pais                 = c.cd_pais and
                                                             ep.cd_estado               = c.cd_estado

    left outer join Unidade_Medida um       with (nolock) on um.cd_unidade_medida       = pvi.cd_unidade_medida

    left outer join classificacao_fiscal cf with (nolock) on cf.cd_classificacao_fiscal = pf.cd_classificacao_fiscal 

    left outer join Procedencia_Produto  pp with (nolock) on pp.cd_procedencia_produto  = case when isnull(pvi.cd_produto,0)>0 then pf.cd_procedencia_produto
                                                                                          else s.cd_procedencia_produto 
                                                                                          end

    left outer join Tipo_Produto         tp WITH(NOLOCK)  on tp.cd_tipo_produto         = case when isnull(pvi.cd_produto,0)>0 then pf.cd_tipo_produto   
                                                                                          else s.cd_tipo_produto
                                                                                          end

    left outer join tributacao           tr with (nolock) on tr.cd_tributacao           = case when isnull(pvi.cd_produto,0)>0 then pf.cd_tributacao
                                                                                          else
                                                                                            s.cd_tributacao
                                                                                          end

    left outer join Tributacao_ICMS      ti with (nolock) on ti.cd_tributacao_icms      = tr.cd_tributacao_icms


-- Comentado 5/5/2009
--     left outer join Produto_Saldo pso        with (nolock) on pso.cd_produto              = p.cd_produto and
--                                                              pso.cd_fase_produto         = 
--                                                              case when isnull(p.cd_fase_produto_baixa,0)>0 then 
--                                                                  p.cd_fase_produto_baixa 
--                                                                else
--                                                                  @cd_fase_produto
--                                                                end
-- 
--     left outer join Produto_Saldo ps        with (nolock) on ps.cd_produto              = p.cd_produto and
--                                                              ps.cd_fase_produto         = 
--                                                              case when isnull(um.cd_fase_produto,0)>0 then
--                                                                um.cd_fase_produto
--                                                              else
--                                                                case when isnull(p.cd_fase_produto_baixa,0)>0 then 
--                                                                  p.cd_fase_produto_baixa 
--                                                                else
--                                                                  @cd_fase_produto
--                                                                end
--                                                              end


--select cd_pais,cd_estado_nota_saida,* from nota_saida
--select * from procedencia_produto
--select * from tributacao_icms

  where
    pvi.cd_pedido_venda      = @cd_pedido_venda      and
    pvi.cd_item_pedido_venda = @cd_item_pedido_venda and

    isnull(pvi.qt_saldo_pedido_venda,0)>0  --Somente os pedidos com Saldo

    --Saldo do Produto
    --(isnull(pso.qt_saldo_atual_produto,0)>=pvi.qt_saldo_pedido_venda or 
    -- isnull(ps.qt_saldo_atual_produto,0)>=pvi.qt_saldo_pedido_venda )


--select * from #Nota_Saida_Item


  insert into Nota_Saida_Item
    select * from #Nota_Saida_item

  --Verifica se Existe itens na Tabela de Itens ( Se não tiver deleta a Nota e Não ajusta o Pedido de Venda )
  
  if exists ( select top 1 cd_nota_saida
              from
                 nota_saida_item 
              where
                 cd_pedido_venda = @cd_pedido_venda and cd_item_pedido_venda = @cd_item_pedido_venda and
                 dt_cancel_item_nota_saida is null  )
             
  begin

    --Atualiza o Pedido de Venda
    --select * from status_pedido

    update
      pedido_venda
    set
      cd_status_pedido = 2  --Pedido Fechado
    where
      cd_pedido_venda = @cd_pedido_venda


    --Atualiza o Saldo dos Itens do Pedido de Venda

    update
      pedido_venda_item
    set
      qt_saldo_pedido_venda = 0 --Saldo Zerado do Item do Pedido de Venda
    where
      cd_pedido_venda      = @cd_pedido_venda      and
      cd_item_pedido_venda = @cd_item_pedido_venda 

  end

  else
    --Deleta a Nota Fiscal que foi gerada sem Itens
    begin
      delete from nota_saida where cd_nota_saida = @cd_nota_saida
    end

  --select * from status_pedido

  --Atualiza a Situação do Pedido
  
  -------------------------------------------------------------------------------
  --Cálculo da Nota Fiscal de Saída
  --Nota_Saida
  --Valores Totais, Peso e Impostos
  -------------------------------------------------------------------------------

  declare @cd_item_nota_saida   int
  declare @vl_total             decimal(25,2)
  declare @vl_bc_icms           decimal(25,2)
  declare @vl_icms              decimal(25,2)
  declare @vl_bc_subst_icms     decimal(25,2)
  declare @vl_produto           decimal(25,2)
  declare @vl_frete             decimal(25,2)
  declare @vl_seguro            decimal(25,2)
  declare @vl_desp_acess        decimal(25,2)
  declare @vl_icms_subst        decimal(25,2)
  declare @vl_ipi               decimal(25,2)
  declare @vl_iss               decimal(25,2)
  declare @vl_servico           decimal(25,2)
  declare @vl_cofins            decimal(25,2)
  declare @vl_pis               decimal(25,2)
  
  set @vl_total             = 0.00
  set @vl_bc_icms           = 0.00
  set @vl_icms              = 0.00
  set @vl_bc_subst_icms     = 0.00
  set @vl_produto           = 0.00
  set @vl_frete             = 0.00
  set @vl_seguro            = 0.00
  set @vl_desp_acess        = 0.00
  set @vl_icms_subst        = 0.00
  set @vl_ipi               = 0.00
  set @vl_iss               = 0.00
  set @vl_servico           = 0.00
  set @vl_cofins            = 0.00 
  set @vl_pis               = 0.00

  while exists( select top 1 cd_item_nota_saida 
                from #Nota_Saida_Item
                where
                  cd_nota_saida = @cd_nota_saida)
  begin

    --select * from nota_saida_item

    select
      top 1
      @cd_item_nota_saida = isnull(i.cd_item_nota_saida,0),
      @cd_operacao_fiscal = case when isnull(i.cd_operacao_fiscal,0)=0 then @cd_operacao_fiscal else i.cd_operacao_fiscal end,
      @vl_produto         = @vl_produto + case when isnull(i.cd_servico,0)=0 then isnull(i.vl_total_item,0) else 0.00 end,
      @vl_total           = @vl_total   + isnull(i.vl_total_item,0),
      @vl_servico         = @vl_servico + case when isnull(i.cd_servico,0)>0 then isnull(i.vl_total_item,0) else 0.00 end,
      @vl_iss             = @vl_iss     + i.vl_iss_servico,
      @vl_pis             = @vl_pis     + case when tpis.ic_calculo_pis    = 'S' then isnull(i.vl_total_item,0) * @pc_pis    else 0.00 end,
      @vl_cofins          = @vl_cofins  + case when tcof.ic_calculo_cofins = 'S' then isnull(i.vl_total_item,0) * @pc_cofins else 0.00 end

      --retenção---

    from
      #Nota_Saida_item i
      left outer join operacao_fiscal opf on opf.cd_operacao_fiscal = i.cd_operacao_fiscal      
      left outer join tributacao t                      with (nolock) on t.cd_tributacao               = i.cd_tributacao
      left outer join tributacao_icms ti                with (nolock) on ti.cd_tributacao_icms         = t.cd_tributacao_icms
      left outer join tributacao_pis tpis               with (nolock) on tpis.cd_tributacao_pis        = t.cd_tributacao_pis
      left outer join tributacao_cofins tcof            with (nolock) on tcof.cd_tributacao_cofins     = t.cd_tributacao_cofins 

    where
      cd_nota_saida      = @cd_nota_saida      

  
    --Cálculo-----------------------------------------------------------------------------------------------------------------------------

    --Cálculo do Peso / Volumes

    --Atualiza o Item da Nota fiscal

    --Próximo Item / Deleta da Tabela Temporária

    Delete from #Nota_Saida_item
    where
      cd_nota_saida      = @cd_nota_saida          and
      cd_item_nota_saida = @cd_item_nota_saida
    
  end

  --Verifica se a Natureza de Operação
  declare @cd_operacao int

  select 
    top 1
    @cd_operacao = case when isnull(cd_operacao_fiscal,0)=0 then @cd_operacao_fiscal else cd_operacao_fiscal end
  from
    nota_saida_item with (nolock) 
  where
      cd_nota_saida      = @cd_nota_saida       
      ---and
      --cd_item_nota_saida = @cd_item_nota_saida
  order by 
      cd_item_nota_saida

  if @cd_operacao>0 and @cd_operacao_fiscal <> @cd_operacao and @cd_operacao_fiscal>0
     set @cd_operacao_fiscal = @cd_operacao

  --select * from nota_saida_item

  --Atualiza a Nota Fiscal Dados e Cálculo da Nota Fiscal

  update
    Nota_Saida
  set
    cd_operacao_fiscal      = case when ns.cd_operacao_fiscal = 0 then opf.cd_operacao_fiscal else ns.cd_operacao_fiscal end,
    cd_mascara_operacao     = opf.cd_mascara_operacao,
    nm_operacao_fiscal      = opf.nm_operacao_fiscal,
    cd_tipo_operacao_fiscal = gof.cd_tipo_operacao_fiscal,
    vl_total                = @vl_total,
    vl_bc_icms              = @vl_bc_icms,
    vl_icms                 = @vl_icms,
    vl_bc_subst_icms        = @vl_bc_subst_icms,
    vl_produto              = @vl_produto,
    vl_frete                = @vl_frete,
    vl_seguro               = @vl_seguro,
    vl_desp_acess           = @vl_desp_acess,
    vl_icms_subst           = @vl_icms_subst,
    vl_ipi                  = @vl_ipi,
    vl_iss                  = @vl_iss, 
    vl_servico              = @vl_servico,
    vl_pis                  = @vl_pis,
    vl_cofins               = @vl_cofins

  from
    Nota_Saida ns                             
    inner join Operacao_Fiscal opf            on opf.cd_operacao_fiscal       = case when isnull(@cd_operacao_fiscal,0)<>0 and @cd_operacao_fiscal<>ns.cd_operacao_fiscal then @cd_operacao_fiscal else ns.cd_operacao_fiscal end
    left outer join Grupo_Operacao_Fiscal gof on gof.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal

  where
    cd_nota_saida = @cd_nota_saida

--  print 'parcela'  

  -------------------------------------------------------------------------------
  --Parcelas Nota de Saída
  -------------------------------------------------------------------------------
  --Nota_Saida_Parcela

  if @cd_nota_saida > 0 and @vl_total>0 
  begin

     --drop table controle_nota_saida
     --CREATE TABLE controle_nota_saida(cd_nota_saida INT )

     insert into
       controle_nota_saida
     select
       @cd_nota_saida as cd_nota_saida

     --Deleta a Parcela-------------------------------------------------------------------------------------------------------

     delete from nota_saida_parcela 
     where
       cd_nota_saida = @cd_nota_saida

     --Geração da Parcela-----------------------------------------------------------------------------------------------------

     if not exists ( select top 1 cd_nota_saida 
                        from 
                          nota_saida_parcela with (nolock) 
                     where
                        cd_nota_saida = @cd_nota_saida )
     begin

        exec pr_gerar_parcela 3, @cd_nota_saida, @cd_usuario

     end


     --Atualiza a Nota no Contrato
     --Contrato_Servico_Composicao
     update
       contrato_servico_composicao
     set
       cd_nota_saida = @cd_nota_saida
     where
       cd_pedido_venda      = @cd_pedido_venda and
       cd_item_pedido_venda = @cd_item_pedido_venda
   

     update
       movimento_contrato 
     set
       cd_ultima_nota = @cd_ultima_nota

    where
       isnull(ic_ativo_movimento,'N')='S'

  end

--  print 'fim parcela'

  -------------------------------------------------------------------------------

--  exec EgisADMIN.dbo.sp_LiberaCodigo @Tabela, @cd_nota_saida, 'D'
--  exec EgisADMIN.dbo.sp_LiberaCodigo @Tabela, @cd_nota_saida, 'D'

end
  
go

--select * from  nota_saida_parcela where cd_nota_saida = 212302

--select cd_tipo_operacao_fiscal,* from nota_saida where cd_nota_saida = 4365
--select * from nota_saida_item where cd_pedido_venda = 10452
--
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_gera_nota_saida_pedido_contrato 159,3,82020,1,4,3,'09/23/2013'
------------------------------------------------------------------------------
-- @cd_contrato_servico      int      = 0,
-- @cd_item_contrato_servico int      = 0,
-- @cd_pedido_venda          int      = 0,
-- @cd_item_pedido_venda     int      = 0,
-- @cd_usuario               int      = 0,
-- @cd_serie_nota            int      = 0,
-- @dt_nota_saida            datetime = ''

-- exec pr_gerar_parcela 3, 212302, 	4


