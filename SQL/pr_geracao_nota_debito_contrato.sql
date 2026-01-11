IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_geracao_nota_debito_contrato' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_geracao_nota_debito_contrato
GO

-------------------------------------------------------------------------------
--sp_helptext pr_geracao_nota_debito_contrato
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2004
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000
--Autor(es)        : Carlos Cardoso Fernandes
--Banco de Dados   : Egissql
--Objetivo         : 
--Data             : 17.12.2005
--Alteração        : 19.12.2005 - Valor Total - Carlos Fernandes 
--                 : 03.01.2006 - Atualização do Número da Nota Débito na OS - Carlos Fernandes
--                 : 06.02.2006 - Forma de geração - Carlos Fernandes.
-- 05.09.2012 - Ajustes Diversos - Carlos Fernandes
-- 12.09.2012 - União de Ordens de Serviço por Cliente - Carlos Fernandes
-- 20.09.2013 - Novo campo - Carlos Fernandes
-- 30.09.2013 - Geração das Notas de Débito para Nota Fiscal - Carlos Fernandes
-- 23.02.2021 - Acerto da Numeração das Notas Fiscais - Carlos Fernandes
-----------------------------------------------------------------------------------------------
create procedure pr_geracao_nota_debito_contrato
@cd_contrato_servico      int      = 0,
@cd_item_contrato_servico int      = 0,
@cd_usuario               int      = 0,
@cd_cliente               int      = 0,
@dt_inicial               datetime = '',
@dt_final                 datetime = '',
@ic_nota_fiscal           char(1)  = 'N'  --Geração também para os Contratos de Nota Fiscal 

as

  declare @cd_tipo_faturamento int
  declare @dt_hoje             datetime

  set @dt_hoje = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)

  set @cd_tipo_faturamento = 2     --Nota Débito

  if @ic_nota_fiscal = 'S'
     set @cd_tipo_faturamento = 1  --Nota Fiscal
  


  declare @Tabela                 varchar(50)
  declare @cd_nota_debito_despesa int
  declare @vl_nota_debito         float
  declare @cd_item_despesa_ordem  int 

  set @cd_nota_debito_despesa = 0

  set @Tabela = cast(DB_NAME()+'.dbo.Nota_Debito_Despesa' as varchar(50))


--select * from ordem_servico_analista
--select * from nota_debito_despesa
--sp_help nota_debito_despesa
--select * from ordem_servico_analista_despesa

if @cd_contrato_servico>0
begin


  --Gera o Código da Nota de Débito de Despesa

  exec EgisADMIN.dbo.sp_PegaCodigo @Tabela, 'cd_nota_debito_despesa', @codigo = @cd_nota_debito_despesa output	     
 
  select
    top 1
    @cd_nota_debito_despesa                        as cd_nota_debito_despesa,
    @dt_hoje                                       as dt_nota_debito_despesa,
    cs.dt_parc_contrato_servico                    as dt_inicio_ref_nota_debito,
    cs.dt_parc_contrato_servico                    as dt_final_ref_nota_debito,
    c.cd_cliente,
    ltrim(rtrim(c.cd_ref_contrato_servico))+' - '+dbo.fn_strzero(month(cs.dt_parc_contrato_servico),2)+'/'+dbo.fn_strzero(year(cs.dt_parc_contrato_servico),4)
                                                   as nm_ref_nota_debito,
    null                                           as nm_obs_ref_nota_debito,
    vl_parc_contrato_servico                       as vl_nota_debito,
    
    c.ds_contrato                                  as ds_nota_debito,
    null                                           as cd_conta_banco,
    null                                           as dt_baixa_nota_debito,
    null                                           as dt_pagto_nota_debito,
    'N'                                            as ic_emitida_nota_debito,
    @cd_usuario                                    as cd_usuario,
    @dt_hoje                                       as dt_usuario,
    null                                           as cd_projeto,
    cs.cd_pedido_venda, 
    c.cd_contato,
    'N'                                            as ic_scr_gerado,

    cs.dt_parc_contrato_servico                    as dt_vencimento_nota_debito,

    c.cd_centro_custo,
    null                                           as cd_analista,
    cast(c.cd_ref_contrato_servico as varchar(15)) as cd_identificacao_cliente,
    null                                           as dt_vencimento_nota,
    null                                           as dt_cliente_nota,
    null                                           as cd_documento_receber,
    cs.cd_nota_saida                               as cd_nota_saida


  into
    #ND

  from
    Contrato_Servico c                         with (nolock)
    inner join Contrato_Servico_Composicao cs  with (nolock) on c.cd_contrato_servico = cs.cd_contrato_servico

  where
    c.cd_contrato_servico                   = @cd_contrato_servico      and
    cs.cd_item_contrato_servico             = @cd_item_contrato_servico and
    isnull(cs.cd_nota_debito_despesa,0)     = 0                         and
    isnull(c.cd_tipo_faturamento,1)         = @cd_tipo_faturamento      --Nota de Débito ou Nota Fiscal
    and isnull(cs.cd_nota_debito_despesa,0) = 0

--     and  
--     cs.dt_parc_contrato_servico between @dt_inicial and @dt_final

  --select * from #ND

  if exists( select top 1 cd_nota_debito_despesa from #ND ) 
  begin

    --print 'aqui'

    insert into Nota_Debito_Despesa
    select * from #ND

    --montagem da tabela nota_debito_despesa_composicao

    select 
     @cd_nota_debito_despesa                         as cd_nota_debito_despesa,
     1                                               as cd_item_nota_despesa,
     tf.cd_tipo_despesa                              as cd_tipo_despesa,
     1                                               as qt_nota_debito,
     vl_parc_contrato_servico                        as vl_item_nota_debito,
     nm_parc_contrato_servico                        as nm_obs_item_nota_debito,
     @cd_usuario                                     as cd_usuario, 
     @dt_hoje                                        as dt_usuario,
     cs.dt_parc_contrato_servico                     as dt_despesa,
     cast(c.cd_ref_contrato_servico as varchar(15))  as cd_documento_despesa,
     'N'                                             as ic_empresa_despesa,
     'S'                                             as ic_cliente_despesa,
     'N'                                             as ic_consultor_despesa,
      cd_item_contrato_servico,
      identity(int,1,1)                              as cd_aux_item

   into
     #NDC

   from
     Contrato_Servico c                         with (nolock)
     inner join Contrato_Servico_Composicao cs  with (nolock) on c.cd_contrato_servico  = cs.cd_contrato_servico
     inner join tipo_faturamento tf             with (nolock) on tf.cd_tipo_faturamento = c.cd_tipo_faturamento

   where
     c.cd_contrato_servico                   = @cd_contrato_servico      and
     cs.cd_item_contrato_servico             = @cd_item_contrato_servico and
     isnull(cs.cd_nota_debito_despesa,0)     = 0                         and
     isnull(c.cd_tipo_faturamento,1)         = @cd_tipo_faturamento      --Nota de Débito ou Nota Fiscal
     and isnull(cs.cd_nota_debito_despesa,0) = 0

--      and  
--      cs.dt_parc_contrato_servico between @dt_inicial and @dt_final


--    select * from #NDC
    
    insert into nota_debito_despesa_composicao
    select 
      cd_nota_debito_despesa,
      cd_item_nota_despesa,
      cd_tipo_despesa,
      qt_nota_debito,
      vl_item_nota_debito,
      nm_obs_item_nota_debito,
      cd_usuario,
      dt_usuario,
      dt_despesa,
      cd_documento_despesa,
      ic_empresa_despesa,
      ic_cliente_despesa,
      ic_consultor_despesa,
      cd_aux_item

    from #NDC
   	
    --Cálculo do Valor Total
    set @vl_nota_debito = 0

    select
      @vl_nota_debito = sum( isnull(qt_nota_debito,0) * isnull(vl_item_nota_debito,0))
    from
     #NDC

    where
     cd_nota_debito_despesa = @cd_nota_debito_despesa

    --Atualiza o Total da Nota Débito
    --select * from nota_debito_despesa

    update
      Nota_Debito_Despesa
    set
      vl_nota_debito = @vl_nota_debito
    where
       cd_nota_debito_despesa = @cd_nota_debito_despesa

    --Atualiza o flag de Geração na Ordem Serviço
    
    update
      Contrato_Servico 
    set
      ic_nota_debito = 'S'
    where
      cd_contrato_servico = @cd_contrato_servico

     --Atualiza o Número da Nota Débito na Tabela de Ordem de Serviço Gerada
     --select * from #NDC
 
      while exists ( select top 1 cd_nota_debito_despesa from #NDC )
      begin

--        print @cd_nota_debito_despesa

        select 
          top 1
           @cd_nota_debito_despesa = cd_nota_debito_despesa,
           @cd_item_despesa_ordem  = cd_item_contrato_servico
          from
            #NDC
 
        update
          contrato_servico_composicao
        set
          cd_nota_debito_despesa = @cd_nota_debito_despesa
        where
           @cd_contrato_servico    = cd_contrato_servico and
           @cd_item_despesa_ordem  = cd_item_contrato_servico
 
        delete from #NDC 
        where
           @cd_nota_debito_despesa = cd_nota_debito_despesa    and
           @cd_item_despesa_ordem  = cd_item_contrato_servico
 
      end

-- select * from ordem_servico_analista_despesa
     
   end

  -- limpeza da tabela de código
   exec EgisADMIN.dbo.sp_LiberaCodigo @Tabela, @cd_nota_debito_despesa, 'D'

end


     

go

---------------------------------------------------------------------------------------------------------------------------------------------------------
--Testando a Stored Procedure
--------------------------------------------------------------------------------------------------------------------------------------------------------
--analítica
--exec pr_geracao_nota_debito_Contrato 20192,4,0
--------------------------------------------------------------------------------------------------------------------------------------------------------

-- exec dbo.pr_geracao_nota_debito_contrato  @cd_contrato_servico = 32, @cd_item_contrato_servico = 4, @cd_usuario = 4, @cd_cliente = NULL, 
-- @dt_inicial = '08/21/2013', 
-- @dt_final = '08/21/2013'

------------------------------------------------------------------------------

