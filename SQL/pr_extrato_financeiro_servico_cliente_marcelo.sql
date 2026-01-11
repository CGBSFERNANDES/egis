IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_extrato_financeiro_servico_cliente' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_extrato_financeiro_servico_cliente

GO

-------------------------------------------------------------------------------
--sp_helptext pr_extrato_financeiro_servico_cliente
-------------------------------------------------------------------------------
--pr_extrato_financeiro_servico_cliente
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2012
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql
--
--Objetivo         : 
--Data             : 06.09.2012
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_extrato_financeiro_servico_cliente
@cd_ordem_servico int      = 0,
@cd_cliente       int      = 0,
@cd_analista      int      = 0,
@dt_inicial       datetime = '',
@dt_final         datetime = ''

as

--select * from cliente
--select * from ordem_servico_analista_item

--tabelas:
--  ordem_servico_analista
--  ordem_servico_analista_item
--  ordem_servico_analista_despesa
-- analista

if exists(select name from sysobjects where name = 'temp_estrutura_os' and xtype = 'U')
  drop table temp_estrutura_os

select
--  identity(int,1,1) as cd_controle,
  '1' as cd_tipo,
  cast('OS'  as varchar(15)) AS nm_Tipo, 
  'S' as ic_explode,    
  os.cd_ordem_servico,
  0   as cd_item_ordem_servico,
  os.dt_lancto_ordem_servico,
  os.nm_ref_ordem_servico,
  os.nm_solicit_ordem_servico,

  --Consultor / Analista----------------------------------------------------------------------

  a.cd_analista,
  a.nm_analista,
  a.nm_fantasia_analista, 


  --cliente------------------------------------------------------------------------------------
  
  c.nm_fantasia_cliente,
  c.nm_razao_social_cliente,


  --Dados das Horas---------------------------------------

  s.nm_servico,
  0                as 'Extra', 
  0                as 'Desloc',
  '00:00:00'       as nm_hora_inicio_ordem,
  '00:00:00'       as nm_hora_fim_ordem,
  0.0              as qt_item_normal_ordem,
  0                as vl_servico_ordem_servico,
  
  round( ( (cast(datepart(hh, cast(os.qt_total_normal_ordem as DATETIME))as float)+(cast(datepart(mi, cast(os.qt_total_normal_ordem as DATETIME)) as float) /60)) +  
           (cast(datepart(hh, cast(os.qt_total_extra_ordem as DATETIME))as float)+(cast(datepart(mi, cast(os.qt_total_extra_ordem as DATETIME)) as float) /60)) 
  ),0) * 
  case when isnull(os.vl_hora_servico_cliente,0)=0 then (isnull(s.vl_servico,a.vl_analista )) else isnull(os.vl_hora_servico_cliente,0) end  as vl_total_servico,
  0 as cd_identificacao_document

  into temp_estrutura_os

from
  Ordem_Servico_Analista os                       with (nolock)
  left outer join cliente c                       on c.cd_cliente       = os.cd_cliente
  left outer join analista a                      on a.cd_analista      = os.cd_analista
--  left outer join Ordem_Servico_Analista_Item i   on i.cd_ordem_servico = os.cd_ordem_servico
  left outer join servico s                       on s.cd_servico = os.cd_servico

where
  os.cd_cliente  = case when @cd_cliente  = 0 then os.cd_cliente  else @cd_cliente  end and
  os.cd_analista = case when @cd_analista = 0 then os.cd_analista else @cd_analista end and
  os.dt_lancto_ordem_servico between @dt_inicial and @dt_final


order by
  os.dt_lancto_ordem_servico


declare @cd_os int 

set @cd_os = 0

while exists(select top 1 ic_explode from temp_estrutura_os where ic_explode = 'S' and cd_tipo = 1)
begin 
  select top 1 @cd_os = cd_ordem_servico 
  from temp_estrutura_os where ic_explode = 'S' and cd_tipo = 1

    insert into temp_estrutura_os (
        cd_tipo,
        nm_Tipo,
        ic_explode,
        cd_ordem_servico,
        cd_item_ordem_servico,
        dt_lancto_ordem_servico,
        nm_ref_ordem_servico,
        nm_solicit_ordem_servico,
        cd_analista,
        nm_analista,
        nm_fantasia_analista,
        nm_fantasia_cliente,
        nm_razao_social_cliente,
        nm_servico,
        Extra,
        Desloc,
        nm_hora_inicio_ordem,
        nm_hora_fim_ordem,
        qt_item_normal_ordem,
        vl_servico_ordem_servico,
        vl_total_servico,
        cd_identificacao_document)  
--Itens

    select
            '2',
           'Item',  
           'N',
           @cd_os,
           i.cd_item_ordem_servico,   
           i.dt_item_ordem_servico,
           '' as nm_ref_ordem_servico,
           '' as nm_solicit_ordem_servico,
           0  as cd_analista,
           '' as nm_analista,
           '' as nm_fantasia_analista,
           '' as nm_fantasia_cliente,
           '' as nm_razao_social_cliente,
           s.nm_servico,
           case when IsNull(qt_item_extra1_ordem,0) = 0 and IsNull(qt_item_extra2_ordem,0) = 0 then 0 else 1 end as 'Extra', 
           case when IsNull(qt_item_desloc_ordem,0) = 0 then 0 else 1 end as 'Desloc',
           i.nm_hora_inicio_ordem,
           i.nm_hora_fim_ordem,
           round(i.qt_item_normal_ordem,0),
           i.vl_servico_ordem_servico, 

           round(((cast(datepart(hh, cast(os.qt_total_normal_ordem as DATETIME))as float)+(cast(datepart(mi, cast(os.qt_total_normal_ordem as DATETIME)) as float) /60)) +  
                  (cast(datepart(hh, cast(os.qt_total_extra_ordem as DATETIME))as float)+(cast(datepart(mi, cast(os.qt_total_extra_ordem as DATETIME)) as float) /60)) 
            ),0) * 
           case when isnull(vl_servico_ordem_servico,0)=0 then (isnull(s.vl_servico,a.vl_analista )) else vl_servico_ordem_servico end as vl_total_servico,
           0 as cd_identificacao_document
         from 
           Ordem_Servico_Analista_Item i with (nolock) 
           inner join Ordem_Servico_Analista os on os.cd_ordem_servico = i.cd_ordem_servico
           left outer join servico s on s.cd_servico = i.cd_servico
           left outer join  Analista a ON a.cd_analista = os.cd_analista
         where 
           i.cd_ordem_servico = @cd_os
--Despesas
     union 
        select 
        '3'         as cd_tipo,
        'Despesa'   as nm_Tipo,
        'N'         as ic_explode,
        cd_ordem_servico,
        cd_item_despesa_ordem,
        dt_despesa,
        '' as nm_ref_ordem_servico,
        '' as nm_solicit_ordem_servico,
        0  as cd_analista,
        '' as nm_analista,
        '' as nm_fantasia_analista,
        '' as nm_fantasia_cliente,
        '' as nm_razao_social_cliente,
        '' as nm_servico,
        0  as Extra,
        0  as Desloc,
        '' as nm_hora_inicio_ordem,
        '' as nm_hora_fim_ordem,
        0  as qt_item_normal_ordem,
        0  as vl_servico_ordem_servico,
        0.0 as vl_total_servico,
        dp.cd_identificacao_document
      from ordem_servico_analista_despesa d
      Inner join tipo_despesa tp         with (nolock) on d.cd_tipo_despesa = tp.cd_tipo_despesa
      left outer join documento_pagar dp on d.cd_documento_pagar = dp.cd_documento_pagar     
      where d.cd_ordem_servico = @cd_os




    update temp_estrutura_os set ic_explode = 'N' where  cd_ordem_servico = @cd_os 

  end


select 
  identity(int,1,1) as cd_controle,
  * 
into
  #Extrato_Servico

from
  temp_estrutura_os
order by
  cd_ordem_servico,cd_tipo

--drop table temp_estrutura_os

select * from #Extrato_Servico
order by
  cd_ordem_servico,cd_tipo

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_extrato_financeiro_servico_cliente 0,0,0,'01/01/2012','12/31/2012'
------------------------------------------------------------------------------


--select * from Ordem_Servico_Analista
--select * from ordem_servico_analista_despesa
-- 
-- 
