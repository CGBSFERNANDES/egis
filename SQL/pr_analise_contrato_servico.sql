IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_analise_contrato_servico' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_analise_contrato_servico
GO

--------------------------------------------------------------------
--pr_analise_contrato_servico
--------------------------------------------------------------------
--GBS - Global Business Solution Ltda                           2020
--------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)		      : Fabiano Vinco Zanqueta
--Banco de Dados	  : EGISSQL
--Objetivo		      : Controlar Contratos de Serviço na Web/Vue
--Data			        : 03/12/2020
--Atualização       :    
--------------------------------------------------------------------

CREATE PROCEDURE pr_analise_contrato_servico

@cd_parametro         int         = 0, 
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
if @cd_parametro = 0 -- Seleção de Contratos de Serviço no Período.
-------------------------------------------------------------------------
begin

SELECT 
	identity(int,1,1)                                                            as cd_controle,
  c.nm_fantasia_cliente                                                        as Cliente, 
  cs.cd_ref_contrato_servico+'/'+cast(year(cs.dt_contrato_servico) as varchar) as Contrato, 
  cs.dt_contrato_servico                                                       as Emissao,
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
    end                                                                        as Valor_Parcela,
	(select count(csc.cd_item_contrato_servico)
				 from contrato_servico_composicao csc 
				  where csc.cd_contrato_servico = cs.cd_contrato_servico)              as Parcelas,
  cs.vl_contrato_servico                                                       as Total_Contrato,
	(select max(csc.dt_parc_contrato_servico)
	  from contrato_servico_composicao csc
		where csc.cd_contrato_servico = cs.cd_contrato_servico)                    as Vencimento,
	(select count(csc.cd_item_contrato_servico)
				 from contrato_servico_composicao csc 
				  where csc.cd_contrato_servico = cs.cd_contrato_servico
								and csc.dt_parc_contrato_servico > @dt_hoje)                   as Quantidade,	
  isnull(cs.vl_contrato_servico,0)
  -
  isnull(( select sum(isnull(csf.vl_parc_contrato_servico,0))
    from
      contrato_servico_composicao csf
    where
      csf.cd_contrato_servico =  cs.cd_contrato_servico and
      (isnull(csf.cd_nota_saida,0)<>0 or
			  isnull(csf.cd_nota_debito_despesa,0)<>0 )),0 )                         as Saldo,
	case when ts.cd_tipo_faturamento = 1 then 'NF' 
		else case when ts.cd_tipo_faturamento = 2 then 'ND' 
			else '' 
			end
		end                                                                        as Tipo_Faturamento
into
	#ContratoServico

FROM         
  Contrato_Servico cs                                                  
	left outer join Status_Contrato sc  on cs.cd_status_contrato  = sc.cd_status_contrato 
	left outer join Cliente c           on cs.cd_cliente          = c.cd_cliente                  
	left outer join Tipo_Reajuste tr    on tr.cd_tipo_reajuste    = cs.cd_tipo_reajuste     
	left outer join Servico s           on cs.cd_servico          = s.cd_servico          
	left outer join Indice_Reajuste ir  on ir.cd_indice_reajuste  = cs.cd_indice_reajuste 
	left outer join Vendedor v          on v.cd_vendedor          = cs.cd_vendedor        
	left outer join Tipo_Faturamento ts on ts.cd_tipo_faturamento = cs.cd_tipo_faturamento
  left outer join status_cliente stc  on stc.cd_status_cliente  = c.cd_status_cliente
  left outer join centro_custo cc     on cc.cd_centro_custo     = cs.cd_centro_custo

where
  isnull(stc.ic_operacao_status_cliente,'N')='S'
	and
	sc.cd_status_contrato = 1
--   and
-- 	 cs.dt_contrato_servico between @dt_inicial and @dt_final 
-- 	 and
-- 	 cs.cd_ref_contrato_servico like case when @cd_referencia = '#!$' then cs.cd_ref_contrato_servico else @cd_referencia + '%' end
--   and
-- 	 isnull(sc.ic_controle_contrato,'S')='S'
--   and
-- 	 cs.cd_contrato_servico = case when @cd_contrato_servico = 0 then cs.cd_contrato_servico else @cd_contrato_servico end
 
	order by
	  cs.dt_contrato_servico desc,
	  c.nm_fantasia_cliente


select * from #ContratoServico



end

go

/*-----------------------------------------------------------------------------------------------------------------------------------
--Testando a Stored Procedure
-------------------------------------------------------------------------------------------------------------------------------------
exec pr_analise_contrato_servico 0
-----------------------------------------------------------------------------------------------------------------------------------*/