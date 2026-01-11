IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_copia_contrato_servico' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_copia_contrato_servico
GO

-------------------------------------------------------------------------------
--sp_helptext pr_copia_contrato_servico
------------------------------------------------------------------------------
--pr_copia_contrato_servico
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2009
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000
--Autor(es)        : Carlos Cardoso Fernandes
--Banco de Dados   : Egissql
--Objetivo         : Cópia do Contrato de Serviço
--                   
--Data             : 09.12.2013
--Alteração        : 31.08.2023 - Inclusão de campos novos no insert - Denis Rabello
--                 : 11.09.2023 - Ajustes no insert - Denis Rabello
-----------------------------------------------------------------------------------------
create procedure pr_copia_contrato_servico
@cd_aux_contrato_servico  int      = 0,
@cd_usuario               int      = 0
as

--select * from contrato_servico

  declare @cd_contrato_servico int

  set @cd_contrato_servico = 0


if @cd_aux_contrato_servico > 0
begin

  declare @dt_hoje             datetime

  set @dt_hoje = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)


  select
    @cd_contrato_servico = isnull( max( cd_contrato_servico ),0) 
  from
    contrato_servico

  if @cd_contrato_servico is null or @cd_contrato_servico = 0
     set @cd_contrato_servico = 0
    
  set @cd_contrato_servico = @cd_contrato_servico + 1

  select
    @cd_contrato_servico                      as cd_contrato_servico,
    @dt_hoje                                  as dt_contrato_servico,
    cast(@cd_contrato_servico as varchar(20)) as cd_ref_contrato_servico,
    cd_cliente,
    ds_contrato,
    cd_vendedor,
    cd_condicao_pagamento,
    dt_ini_contrato_servico,
    dt_final_contrato_servico,
    cd_servico,
    qt_parc_contrato_servico,
    dt_vct1p_contrato_servico,
    qt_iparc_contrato_servico,
    1                             as cd_status_contrato, --Aberto
    @cd_usuario                   as cd_usuario,
    getdate()                     as dt_usuario,
    vl_contrato_servico,
    cd_tipo_contrato,
    cd_indice_reajuste,
    dt_base_reajuste_contrato,
    dt_cancelamento_contrato,
    nm_motivo_canc_contrato,
    cd_tipo_reajuste,
    qt_hora_contrato_servico,
    ic_fixa_dia_vencimento,
    vl_parcela_contrato_servico,
    vl_hora_contrato_servico,
    nm_evento_contrato,
    dt_inicio_evento,
    dt_fim_evento,
    dt_entrega_contrato,
    dt_retirada_contrato,
    ds_instrucao_cliente,
    dt_previsao_servico,
    dt_fim_contrato,
    cd_bem,
    cd_consulta,
    cd_tipo_faturamento,
    ic_nota_debito,
    cd_contato,
    cd_centro_custo,
    cd_tipo_despesa,
    ic_retencao_ir_contrato,
    pc_ir_retencao_contrato,
    ic_variacao_contrato,
    ic_retencao_iss_contrato,
    pc_iss_retencao_contrato,
    cast(null as datetime)            as dt_baixa_contrato,
    vl_entrada_contrato,
    dt_entrada_contrato,
    pc_taxa_juros_anual,
    ic_escritura,
    cd_plano_financeiro,
    ic_scr_contrato,
    nm_quadra,
    nm_lote,
    vl_comissao_contrato
    cd_empreendimento,
    cd_unidade,
    nm_caminho_proposta,
    nm_caminho_contrato,
    cd_usuario_inclusao,
    dt_usuario_inclusao	


  into 
    #contrato_servico
  from
    contrato_servico 
  where
    cd_contrato_servico = @cd_aux_contrato_servico

  insert into contrato_servico (
    cd_contrato_servico, 
    dt_contrato_servico,
    cd_ref_contrato_servico,
    cd_cliente,
    ds_contrato,
    cd_vendedor,
    cd_condicao_pagamento,
    dt_ini_contrato_servico,
    dt_final_contrato_servico,
    cd_servico,
    qt_parc_contrato_servico,
    dt_vct1p_contrato_servico,
    qt_iparc_contrato_servico,
    cd_status_contrato,
    cd_usuario,
    dt_usuario,
    vl_contrato_servico,
    cd_tipo_contrato,
    cd_indice_reajuste,
    dt_base_reajuste_contrato,
    dt_cancelamento_contrato,
    nm_motivo_canc_contrato,
    cd_tipo_reajuste,
    qt_hora_contrato_servico,
    ic_fixa_dia_vencimento,
    vl_parcela_contrato_servico,
    vl_hora_contrato_servico,
    nm_evento_contrato,
    dt_inicio_evento,
    dt_fim_evento,
    dt_entrega_contrato,
    dt_retirada_contrato,
    ds_instrucao_cliente,
    dt_previsao_servico,
    dt_fim_contrato,
    cd_bem,
    cd_consulta,
    cd_tipo_faturamento,
    ic_nota_debito,
    cd_contato,
    cd_centro_custo,
    cd_tipo_despesa,
    ic_retencao_ir_contrato,
    pc_ir_retencao_contrato,
    ic_variacao_contrato,
    ic_retencao_iss_contrato,
    pc_iss_retencao_contrato,
    dt_baixa_contrato,
    vl_entrada_contrato,
    dt_entrada_contrato,
    pc_taxa_juros_anual,
    ic_escritura,
    cd_plano_financeiro,
    ic_scr_contrato,
    nm_quadra,
    nm_lote,
    vl_comissao_contrato,
    cd_empreendimento,
    cd_unidade,
    nm_caminho_proposta,
    nm_caminho_contrato,
    cd_usuario_inclusao,
    dt_usuario_inclusao )
    
  select
    cd_contrato_servico,
    dt_contrato_servico,
    cd_ref_contrato_servico,
    cd_cliente,
    ds_contrato,
    cd_vendedor,
    cd_condicao_pagamento,
    dt_ini_contrato_servico,
    dt_final_contrato_servico,
    cd_servico,
    qt_parc_contrato_servico,
    dt_vct1p_contrato_servico,
    qt_iparc_contrato_servico,
    cd_status_contrato,
    cd_usuario,
    dt_usuario,
    vl_contrato_servico,
    cd_tipo_contrato,
    cd_indice_reajuste,
    dt_base_reajuste_contrato,
    dt_cancelamento_contrato,
    nm_motivo_canc_contrato,
    cd_tipo_reajuste,
    qt_hora_contrato_servico,
    ic_fixa_dia_vencimento,
    vl_parcela_contrato_servico,
    vl_hora_contrato_servico,
    nm_evento_contrato,
    dt_inicio_evento,
    dt_fim_evento,
    dt_entrega_contrato,
    dt_retirada_contrato,
    ds_instrucao_cliente,
    dt_previsao_servico,
    dt_fim_contrato,
    cd_bem,
    cd_consulta,
    cd_tipo_faturamento,
    ic_nota_debito,
    cd_contato,
    cd_centro_custo,
    cd_tipo_despesa,
    ic_retencao_ir_contrato,
    pc_ir_retencao_contrato,
    ic_variacao_contrato,
    ic_retencao_iss_contrato,
    pc_iss_retencao_contrato,
    dt_baixa_contrato,
    vl_entrada_contrato,
    dt_entrada_contrato,
    pc_taxa_juros_anual,
    ic_escritura,
    cd_plano_financeiro,
    ic_scr_contrato,
    nm_quadra,
    nm_lote,
    vl_comissao_contrato,
    cd_empreendimento,
    cd_unidade,
    nm_caminho_proposta,
    nm_caminho_contrato,
    cd_usuario_inclusao,
    dt_usuario_inclusao
  
 from
    #contrato_servico

  drop table #contrato_servico

  

end  

select @cd_contrato_servico as cd_contrato_servico

go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_copia_contrato_servico 159
------------------------------------------------------------------------------


