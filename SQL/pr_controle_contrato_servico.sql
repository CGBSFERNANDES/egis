IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_controle_contrato_servico' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_controle_contrato_servico
GO

---------------------------------------------------------------------------------------------------------------------------------------
--pr_controle_contrato_servico
------------------------------------------------------------------------------------------------------------------------------------
--GBS - Global Business Solution Ltda                           2004
------------------------------------------------------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)		: Daniel C. Neto.
--Banco de Dados	: EGISSQL
--Objetivo		: Controlar Contratos de Serviço no Período.
--Data			: 07/04/2004
--Atualização           : 27/12/2004 - Acerto do Cabeçalho - Sérgio Cardoso
-- 19.05.2011 - ajustes diversos - carlos fernandes
-- 17.05.2013 - Ajustes Diversos - Carlos Fernandes
-- 23.06.2013 - Nova Lei de Tributos IBPT - Carlos Fernandes
-- 04.07.2013 - Cálculo do ir - Carlos Fernandes
-- 19.07.2013 - Ajustes Diversos - Carlos Fernandes
-- 02.09.2013 - Cálculo do IR - Carlos Fernandes
-- 11.09.2013 - Verificação Geral das Consultas - Fagner/Carlos
-- 20.09.2013 - Contato/Ajustes  - Carlos Fernandes
-- 30.09.2013 - Ajuste para Gerar ND também para NF de Serviço - Carlos Fernandes
-- 31.01.2015 - Ajuste do filtro de contrato para não mostrar 
-- 19.01.2017 - Não mostrar cliente Inativo - Carlos Fernandes
-- 02.11.2017 - Faturamento do Período - Carlos Fenrandes
-- 10.01.2018 - novos cmapos - Carlos Fernandes 
-- 17.01.2018 - novos campos para o módulo de gestão de empreeendimentos - carlos fernandes
-- 05.03.2018 - acerto do flag para diferenciar a navegação grid - Carlos Fernandes
-- 23.01.2019 - busca pelo número do contrato/referencia separados - pedro jardim/carlos fernandes
-- 03.03.2019 - ajuste do flag de status do contrato - Carlos Fernandes
-- 23.02.2021 - Geração da Numeração da Nota Fiscal - Carlos Fernandes
-- 26.06.2023 - Ajustes - Carlos/Karen 
--
-------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE pr_controle_contrato_servico

@ic_parametro         int         = 0, 
@cd_referencia        varchar(20) = '',
@dt_inicial           datetime    = '',
@dt_final             datetime    = '',
@cd_contrato_servico  int         = 0,
@dt_base              datetime    = ''

AS

set dateformat mdy

declare @dt_hoje datetime
declare @dt_ini  datetime
declare @dt_fim  datetime
declare @cd_ano  int
declare @cd_mes  int

set @dt_hoje    = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)  
  
  
set @cd_ano = year(@dt_hoje)  
set @cd_mes = month(@dt_hoje)  
  
set @dt_ini = dbo.fn_data_inicial(@cd_mes,@cd_ano)  
set @dt_fim = dbo.fn_data_final(@cd_mes,@cd_ano)  

if @cd_contrato_servico is null
   set @cd_contrato_servico = 0



-------------------------------------------------------------------------
if @ic_parametro = 1 -- Seleção de Contratos de Serviço no Período.
-------------------------------------------------------------------------
begin

SELECT 
  cs.cd_contrato_servico,
  cs.cd_ref_contrato_servico, 
  sc.nm_status_contrato, 
  c.nm_fantasia_cliente, 
  cs.dt_contrato_servico, 
  cs.vl_contrato_servico,  
  cs.dt_base_reajuste_contrato, 
  tr.nm_tipo_reajuste, 
  ir.nm_indice_reajuste,
  s.nm_servico,
  cs.cd_cliente,
  cs.dt_ini_contrato_servico,
  cs.dt_final_contrato_servico,
  cs.nm_quadra,
  cs.nm_lote,
  isnull(cs.vl_comissao_contrato, 0) as vl_comissao_contrato,
  v.nm_fantasia_vendedor,
  case when cast(cs.dt_base_reajuste_contrato -  (GetDate()-1) as int) < 0 then
   1 else 0 end as 'ic_atraso',    
  case when cs.dt_cancelamento_contrato is null then 0 else 1 end as 'ic_cancelado',

  case when ( select top 1 'x' 
              from Contrato_Servico_Reajuste x
              where x.cd_contrato_servico = cs.cd_contrato_servico ) is null then
  0 else 1 end as 'ic_reajuste',

  case when ( select top 1 'x' 
              from Contrato_Servico_Composicao csc
              where csc.cd_contrato_servico = cs.cd_contrato_servico and
                    IsNull(csc.cd_pedido_venda,0) <> 0 ) is null then 
  0 else 1 end as 'ic_pedido_venda',

  case when ( select top 1 'x' 
              from Contrato_Servico_Composicao csc
              where csc.cd_contrato_servico = cs.cd_contrato_servico and
                    IsNull(csc.cd_nota_saida,0) <> 0 ) is null then
  0 else 1 end as 'ic_nota_saida',

  case when ( select top 1 'x' 
              from Contrato_Servico_Composicao csc inner join
                   Documento_Receber dr on dr.cd_nota_saida = csc.cd_nota_saida 
              where cast(str(dr.vl_saldo_documento,25,2) as decimal(25,2)) = 0 and 
                    csc.cd_contrato_servico = cs.cd_contrato_servico ) is null then
  0 else 1 end as 'ic_recebido',

  ts.nm_tipo_faturamento,
  --0.00 as vl_faturado,

  isnull(( select sum(isnull(csf.vl_parc_contrato_servico,0) )
    from
      contrato_servico_composicao csf
    where
      csf.cd_contrato_servico =  cs.cd_contrato_servico and
      (isnull(csf.cd_nota_saida,0)<>0 or isnull(csf.cd_nota_debito_despesa,0)<>0)
 ),0 )                                                  as vl_faturado,

  isnull(cs.vl_contrato_servico,0)
  -
  isnull(( select sum(isnull(csf.vl_parc_contrato_servico,0))
    from
      contrato_servico_composicao csf
    where
      csf.cd_contrato_servico =  cs.cd_contrato_servico and
      (isnull(csf.cd_nota_saida,0)<>0 or isnull(csf.cd_nota_debito_despesa,0)<>0 )),0 ) as vl_saldo_contrato,

  --Nota
  isnull(( select top 1 isnull(csf.vl_parc_contrato_servico,0) 
    from
      contrato_servico_composicao csf 
      inner join vw_baixa_documento_receber vw on vw.cd_nota_saida = csf.cd_nota_saida
    where
      csf.cd_contrato_servico =  cs.cd_contrato_servico and
      isnull(csf.cd_nota_saida,0)<>0 ),0 )

  +
  --Nota de Débito
  isnull(( select top 1 isnull(csf.vl_parc_contrato_servico,0) 
    from
      contrato_servico_composicao csf 
      inner join nota_debito_despesa nd        on nd.cd_nota_debito_despesa = csf.cd_nota_debito_despesa
      inner join vw_baixa_documento_receber vw on vw.cd_documento_receber = nd.cd_documento_receber
    where
      csf.cd_contrato_servico =  cs.cd_contrato_servico and
      isnull(csf.cd_nota_debito_despesa,0)<>0 ),0 )

  as vl_recebido_contrato,

  isnull(( select sum(isnull(csf.vl_parc_contrato_servico,0))
    from
      contrato_servico_composicao csf
    where
      csf.cd_contrato_servico =  cs.cd_contrato_servico),0) as qt_parcela,


  stc.ic_operacao_status_cliente,

  case when isnull(cs.vl_parcela_contrato_servico,0) > 0 
  then
     cs.vl_parcela_contrato_servico
  else
     isnull((select sum(vl_parcela) 
          from
           vw_parcela_contrato_servico vwp
          where
            vwp.cd_contrato_servico = cs.cd_contrato_servico and
            vwp.dt_parcela          between @dt_ini and @dt_fim
         group by
             vwp.cd_contrato_servico 
         ),0)                                       
    end                                   as vl_parcela,

    cs.dt_entrada_contrato,
    isnull(cs.vl_entrada_contrato,0)      as vl_entrada_contrato,
    isnull(cs.vl_hora_contrato_servico,0) as vl_hora_contrato_servico,
    isnull(cs.pc_taxa_juros_anual,0)      as pc_taxa_juros_anual,

    case when isnull(cs.ic_escritura,'N') = 'N' then 0
    else
     1
    end                                   ic_escritura,

    case when isnull(cs.ic_scr_contrato,'N') = 'N' then 0
    else
     1
    end                                   ic_scr_contrato,
      
--
--    isnull(cs.ic_escritura,'N')           as ic_escritura,
    isnull(cc.nm_centro_custo,'')         as nm_centro_custo

    
  --0.00 as vl_recebido_contrato

--select cd_contrato_servico,* from documento_receber
--select * from nota_debito_despesa_composicao

FROM         
  Contrato_Servico cs                                                  left outer join
  Status_Contrato sc                 on cs.cd_status_contrato = sc.cd_status_contrato left outer join
  Cliente c                          on cs.cd_cliente = c.cd_cliente                  left outer join
  Tipo_Reajuste tr                   on tr.cd_tipo_reajuste = cs.cd_tipo_reajuste     left outer join
  Servico s                          on cs.cd_servico         = s.cd_servico          left outer join
  Indice_Reajuste ir                 on ir.cd_indice_reajuste = cs.cd_indice_reajuste left outer join
  Vendedor v                         on v.cd_vendedor         = cs.cd_vendedor        left outer join
  Tipo_Faturamento ts                on ts.cd_tipo_faturamento = cs.cd_tipo_faturamento
  left outer join status_cliente stc on stc.cd_status_cliente = c.cd_status_cliente
  left outer join centro_custo cc    on cc.cd_centro_custo    = cs.cd_centro_custo

where
   isnull(stc.ic_operacao_status_cliente,'N')='S'
   and cs.dt_contrato_servico between @dt_inicial and @dt_final 
	 and cs.cd_ref_contrato_servico like case when @cd_referencia = '#!$' then cs.cd_ref_contrato_servico else @cd_referencia + '%' end
   and isnull(sc.ic_controle_contrato,'S')='S'
   and cs.cd_contrato_servico = case when @cd_contrato_servico = 0 then cs.cd_contrato_servico else @cd_contrato_servico end
-- 
-- and ( cs.dt_contrato_servico between @dt_inicial and @dt_final 
-- 		and @cd_referencia = '#!$' ) or
--    ( cs.cd_ref_contrato_servico like @cd_referencia + '%')
--    and isnull(sc.ic_controle_contrato,'S')='S'
--    and cs.cd_contrato_servico = case when @cd_contrato_servico = 0 then cs.cd_contrato_servico else @cd_contrato_servico end


 
order by
  cs.dt_contrato_servico desc,
  c.nm_fantasia_cliente

end

---------------------------------------------------------
if @ic_parametro = 2 -- Seleção da Composição selecionada.
---------------------------------------------------------
begin

  declare @vl_total float

  set @vl_total = ( select 
                      sum( isnull(vl_parc_contrato_servico,0) ) 
                    from 
                      Contrato_Servico_Composicao with (nolock)
                    where
                      cd_contrato_servico = @cd_contrato_servico)

select
   isnull(cs.ic_sel_parcela,0) as Sel, 

   cs.*,

   @vl_total as 'vl_total',
   ts.nm_tipo_faturamento,

   case when isnull(vw.cd_identificacao_nota_saida,0)>0 then
      vw.cd_identificacao_nota_saida
   else
     ns.cd_identificacao_nota_saida 
   end                                                 as 'cd_identificacao_nota_saida'



from
  Contrato_Servico_Composicao cs                     with (nolock)
  inner join contrato_servico c                      on c.cd_contrato_servico = cs.cd_contrato_servico
  left outer join tipo_faturamento ts with (nolock)  on ts.cd_tipo_faturamento = c.cd_tipo_faturamento
  left outer join nota_saida ns   with (nolock)      on ns.cd_nota_saida       = cs.cd_nota_saida
  left outer join vw_pedido_venda_item_nota_saida vw on vw.cd_pedido_venda     = cs.cd_pedido_venda and
                                                        vw.cd_item_pedido_venda = cs.cd_item_pedido_venda    
  left outer join status_contrato sc                 on sc.cd_status_contrato   = c.cd_status_contrato

where
  c.cd_contrato_servico = @cd_contrato_servico
  and
  isnull(sc.ic_controle_contrato,'S')='S'

order by 
  cd_item_contrato_servico


end

----------------------------------------------------------------------------------------------------------
if @ic_parametro = 3 -- Seleção de Contratos de Serviço no Período.
----------------------------------------------------------------------------------------------------------

begin

select
  identity(int,1,1)                  as cd_controle,

  cl.nm_fantasia_cliente,
  c.cd_ref_contrato_servico,

  cs.*,

  isnull(cs.ic_fat_parcela,'S') as ic_faturar_parcela,

--  ns.cd_identificacao_nota_saida,

   case when isnull(vw.cd_identificacao_nota_saida,0)>0 then
      vw.cd_identificacao_nota_saida
   else
     ns.cd_identificacao_nota_saida 
   end                                                 as 'cd_identificacao_nota_saida',

  isnull(c.pc_ir_retencao_contrato,0)  as pc_ir_retencao_contrato,
  isnull(c.pc_iss_retencao_contrato,0) as pc_iss_retencao_contrato,

  case when isnull(c.ic_retencao_ir_contrato,'N') = 'N' then
    0.00
  else
    case when ( isnull(c.pc_ir_retencao_contrato,0) / 100 ) * isnull(cs.vl_parc_contrato_servico,0) >=10 then
      (isnull(c.pc_ir_retencao_contrato,0) / 100 ) * isnull(cs.vl_parc_contrato_servico,0)
    else
      0.00
    end
  end                                                              as vl_retencao_ir,

  case when isnull(c.ic_retencao_iss_contrato,'N') = 'N' then
    0.00
  else
   (isnull(c.pc_iss_retencao_contrato,0) / 100 ) * isnull(cs.vl_parc_contrato_servico,0)
  end                                                              as vl_retencao_iss,

  isnull(s.qt_aliq_nacional,0)                                     as qt_aliq_nacional,
  
  round(isnull(cs.vl_parc_contrato_servico,0)
  -
  --Ir
  (case when isnull(c.ic_retencao_ir_contrato,'N') = 'N' then
    0.00
  else
    case when ( isnull(c.pc_ir_retencao_contrato,0) / 100 ) * isnull(cs.vl_parc_contrato_servico,0) >=10 then
      (isnull(c.pc_ir_retencao_contrato,0) / 100 ) * isnull(cs.vl_parc_contrato_servico,0)
    else
      0.00
    end
  end) 
  -
  --Iss
  (case when isnull(c.ic_retencao_iss_contrato,'N') = 'N' then
    0.00
  else
   (isnull(c.pc_iss_retencao_contrato,0) / 100 ) * isnull(cs.vl_parc_contrato_servico,0)
  end)                                                           
  ,2)                                                               as vl_liquido_parcela,  


  --Imposto---------------------------------------------------------------------------------------------
  round(isnull(cs.vl_parc_contrato_servico,0)

    *
    case when isnull(c.cd_servico,0)<>0 then
      s.qt_aliq_nacional/100
    else
      0.00
    end,2)
                                                                   as vl_imposto,

   --Contato---------------------------------------------------------------------------------------------
   cc.nm_contato_cliente,
   cc.cd_ddd_contato_cliente,
   cc.cd_telefone_contato,
   cc.cd_email_contato_cliente,
   ltrim(rtrim(cc.cd_ddd_contato_cliente))+ ' ' +  cc.cd_telefone_contato as 'fone',


   --Portador
   po.nm_portador,
	 case when c.dt_cancelamento_contrato is null then 0 else 1 end as 'ic_cancelado'


  into #Contrato_Auxiliar

from

  Contrato_Servico_Composicao cs       with (nolock)
  inner join contrato_servico c        with (nolock) on c.cd_contrato_servico = cs.cd_contrato_servico
  inner join cliente cl                with (nolock) on cl.cd_cliente         = c.cd_cliente

  left outer join cliente_contato cc   with (nolock) on cc.cd_contato          = c.cd_contato and
                                                        cc.cd_cliente          = c.cd_cliente

  left outer join 
     cliente_informacao_credito ci     with (nolock) on ci.cd_cliente          = c.cd_cliente

  left outer join Portador po          with (nolock) on po.cd_portador         = ci.cd_portador
  left outer join tipo_faturamento ts  with (nolock) on ts.cd_tipo_faturamento = c.cd_tipo_faturamento
  left outer join nota_saida ns        with (nolock) on ns.cd_nota_saida       = cs.cd_nota_saida
  left outer join servico s            with (nolock) on s.cd_servico           = c.cd_servico
  left outer join vw_pedido_venda_item_nota_saida vw on vw.cd_pedido_venda     = cs.cd_pedido_venda and
                                                        vw.cd_item_pedido_venda = cs.cd_item_pedido_venda    

  left outer join status_contrato sc   with (nolock) on sc.cd_status_contrato   = c.cd_status_contrato
  left outer join status_cliente stc   with (nolock) on stc.cd_status_cliente   = cl.cd_status_cliente

where
  cs.dt_parc_contrato_servico between @dt_inicial and @dt_final
  and isnull(ts.cd_tipo_faturamento,1) = 1 --Faturamento
  and
  isnull(sc.ic_controle_contrato,'S')='S'
  and isnull(stc.ic_operacao_status_cliente,'N')='S'
  and
 cs.cd_contrato_servico = case when @cd_contrato_servico = 0 then cs.cd_contrato_servico else @cd_contrato_servico end
  
order by 
  cs.cd_item_contrato_servico


select * from #Contrato_Auxiliar
order by
  nm_fantasia_cliente,
  cd_item_contrato_servico

end

----------------------------------------------------------------------------------------------------------
if @ic_parametro = 4 -- Contrato em Aberto
-----------------------------------------------------------------------------------------------------------------------------------

begin
  select
    min(dt_contrato_servico) as dt_inicial,
    max(dt_contrato_servico) as dt_final
  from
    Contrato_Servico_Composicao cs     with (nolock)
    inner join contrato_servico c      with (nolock) on c.cd_contrato_servico = cs.cd_contrato_servico
    inner join cliente cl              with (nolock) on cl.cd_cliente         = c.cd_cliente
    left outer join status_contrato sc with (nolock) on sc.cd_status_contrato = c.cd_status_contrato
    left outer join status_cliente stc   with (nolock) on stc.cd_status_cliente   = cl.cd_status_cliente

  where
    isnull(c.cd_status_contrato,0)= 1 --Aberto
    and isnull(cs.cd_pedido_venda,0)=0 
    and isnull(cs.cd_nota_debito_despesa,0)=0
    and c.dt_baixa_contrato is null
    and
    isnull(sc.ic_controle_contrato,'S')='S'
    and isnull(stc.ic_operacao_status_cliente,'N')='S'

   
end


----------------------------------------------------------------------------------------------------------
if @ic_parametro = 5 -- Notas de Débito
----------------------------------------------------------------------------------------------------------

begin

select
  identity(int,1,1)                  as cd_controle,
  cl.nm_fantasia_cliente,
  c.cd_ref_contrato_servico,
  cs.*,
  isnull(cs.ic_fat_parcela,'S') as ic_faturar_parcela,
   case when isnull(vw.cd_identificacao_nota_saida,0)>0 then
      vw.cd_identificacao_nota_saida
   else
     ns.cd_identificacao_nota_saida 
   end                                                 as cd_identificacao_nota_saida ,
  0.00 as qt_aliq_nacional,
  0.00 as vl_imposto,
  0.00 as vl_retencao_ir,
  0.00 as pc_ir_retencao_contrato,
  0.00 as vl_retencao_iss,
  0.00 as pc_iss_retencao_contrato,
  cs.vl_parc_contrato_servico as vl_liquido_parcela,

   --Contato---------------------------------------------------------------------------------------------
   cc.nm_contato_cliente,
   cc.cd_ddd_contato_cliente,
   cc.cd_telefone_contato,
   cc.cd_email_contato_cliente,
   ltrim(rtrim(cc.cd_ddd_contato_cliente))+ ' ' +  cc.cd_telefone_contato as 'fone',


   --Portador
   po.nm_portador,
	 case when c.dt_cancelamento_contrato is null then 0 else 1 end as 'ic_cancelado'
  
   into #Contrato_ND

from

  Contrato_Servico_Composicao cs with (nolock)
  inner join contrato_servico c  with (nolock)      on c.cd_contrato_servico = cs.cd_contrato_servico
  inner join cliente cl          with (nolock)      on cl.cd_cliente         = c.cd_cliente

  left outer join cliente_contato cc   with (nolock) on cc.cd_contato          = c.cd_contato and
                                                        cc.cd_cliente             = c.cd_cliente


  left outer join 
     cliente_informacao_credito ci     with (nolock) on ci.cd_cliente          = c.cd_cliente

  left outer join Portador po          with (nolock) on po.cd_portador         = ci.cd_portador


  left outer join tipo_faturamento ts  with (nolock) on ts.cd_tipo_faturamento = c.cd_tipo_faturamento
 
  left outer join status_contrato sc   with (nolock) on sc.cd_status_contrato  = c.cd_status_contrato
  left outer join status_cliente stc   with (nolock) on stc.cd_status_cliente   = cl.cd_status_cliente
  left outer join nota_saida ns        with (nolock) on ns.cd_nota_saida       = cs.cd_nota_saida
  left outer join vw_pedido_venda_item_nota_saida vw on vw.cd_pedido_venda     = cs.cd_pedido_venda and
                                                        vw.cd_item_pedido_venda = cs.cd_item_pedido_venda 


where
  cs.dt_parc_contrato_servico between @dt_inicial and @dt_final
  and ts.cd_tipo_faturamento = 2 --Nota De Débito
  and
  isnull(sc.ic_controle_contrato,'S')='S'
  and isnull(stc.ic_operacao_status_cliente,'N')='S'
  
order by 
  cs.cd_item_contrato_servico

select * from #Contrato_ND
order by
  nm_fantasia_cliente,
  cd_item_contrato_servico


end


--select * from status_contrato

----------------------------------------------------------------------------------------------------------


go

-----------------------------------------------------------------------------------------------------------------------------------
--Testando a Stored Procedure
-----------------------------------------------------------------------------------------------------------------------------------
--1
--exec pr_controle_contrato_servico
--@ic_parametro         = 1,
--@cd_referencia        = '',
--@dt_inicial           = '07/01/2004',
--@dt_final             = '06/01/2004'

--2



-----------------------------------------------------------------------------------------------------------------------------------
--3 --> Parcelas do Contrato
-----------------------------------------------------------------------------------------------------------------------------------
-- exec pr_controle_contrato_servico
-- @ic_parametro         = 3,
-- @cd_referencia        = '',
-- @dt_inicial           = '06/01/2013',
-- @dt_final             = '06/30/2013'
-----------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------
--4 --> Parcelas em aberto
-----------------------------------------------------------------------------------------------------------------------------------
-- exec pr_controle_contrato_servico 4
-----------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------
--5 --> Notas de Débito
-----------------------------------------------------------------------------------------------------------------------------------
-- exec pr_controle_contrato_servico 4
-----------------------------------------------------------------------------------------------------------------------------------


--select cd_usuario from Requisicao_Compra where cd_requisicao_compra = 301


-- 
-- select top 100 * from requisicao_compra where year(dt_emissao_req_compra ) = 2003
-- select cd_departamento, cd_usuario,* from requisicao_compra where cd_requisicao_compra = 83564
-- 
-- select * from egisadmin..usuario where cd_usuario = 106
--sp_helptext pr_consulta_requisicao_compra



--exec dbo.pr_controle_contrato_servico  @cd_referencia = '#!$', @dt_inicial = '01/01/2015', @dt_final = '12/31/2017', @ic_parametro = 1