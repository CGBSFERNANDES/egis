--BANCO DA EMPRESA / CLIENTE
-----------------------------
--USE EGISSQL
--GO

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_usuario_logado' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_usuario_logado

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_usuario_logado
-------------------------------------------------------------------------------
--pr_egis_usuario_logado
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : 
--Data             : 01.01.2020
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_usuario_logado
@json nvarchar(max) = ''


--with encryption


as

declare @dt_hoje datetime    
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)           
    
if @json= ''   
begin    
  select 'Parâmetros inválidos !' as Msg    
  return    
end    
  
set @json = replace(@json,'''','')  
----------------------------------------------------------------------------------------------------------      

select                   
identity(int,1,1)                                                  as id,                   
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI            as campo,                   
    valores.[value]                                                as valor                  
into #json                  
from                   
   openjson(@json)root                  
   cross apply openjson(root.value) as valores    
  
----------------------------------------------------------------------------------------------------------      
declare @cd_parametro              int = 0  
declare @cd_usuario                int = 0  
declare @dt_inicial                datetime        
declare @dt_final                  datetime       
declare @sql                       nvarchar(max) = ''
declare @cd_form                   int = 0
declare @cd_menu                   int = 0
declare @cd_empresa                int = 0
declare @ic_egismob                char(1) = 'N'
declare @ic_parametro              int     = 0
declare @cd_modulo_start           int     = 282
declare @cd_tipo_retorno           int     = 0
----------------------------------------------------------------------------------------------------------      

select @cd_parametro       = valor from #json  with(nolock) where campo = 'cd_parametro'   
select @cd_usuario         = valor from #json  with(nolock) where campo = 'cd_usuario'   
select @dt_inicial         = valor from #json  with(nolock) where campo = 'dt_inicial'     
select @dt_final           = valor from #json  with(nolock) where campo = 'dt_final'    
select @cd_form            = valor from #json  with(nolock) where campo = 'cd_form'    
select @cd_menu            = valor from #json  with(nolock) where campo = 'cd_menu'    

set @cd_parametro = isnull(@cd_parametro,0)
set @cd_empresa   = dbo.fn_empresa()
set @ic_egismob   = ISNULL(@ic_egismob,'N')
set @ic_parametro = isnull(@cd_parametro,0)

----------------------------------------------------------------------------------------------------------      

declare @vl_total   decimal(25,2) = 0.00
declare @qt_total   decimal(25,2) = 0
declare @qt_empresa int           = 0
declare @qt_usuario int           = 0

select
  distinct
  identity(int,1,1)                                                                                      as cd_controle,
  format(
  convert(datetime,left(convert(varchar,l.dt_log_acesso,121),10)+' 00:00:00',121),'dd/MM/yyyy')          as dt_log_acesso,
  max(FORMAT(l.dt_log_acesso, 'HH:mm:ss'))                                                               as hr_log_acesso,
  l.cd_usuario,
  l.cd_modulo,
  sum(case when l.sg_log_acesso = '0' then 1 else 0 end)                                                 as qt_entrada,
  sum(case when l.sg_log_acesso = '1' then 1 else 0 end)                                                 as qt_saida,

  sum(case when l.sg_log_acesso = '0' then 1 else 0 end) 
  -                                              
  sum(case when l.sg_log_acesso = '1' then 1 else 0 end)                                                 as qt_status,
  
  max(upper(u.nm_usuario))                                                                               as nm_usuario,
  max(upper(u.nm_fantasia_usuario))                                                                      as nm_fantasia_usuario,
  ( select top 1 ue.cd_empresa from egisadmin.dbo.Usuario_Empresa ue where ue.cd_usuario = l.cd_usuario )              as cd_empresa_acesso,
  max( isnull(m.nm_modulo,''))                                                                           as nm_modulo,
  max( isnull(m.sg_modulo,''))                                                                           as sg_modulo
  


  into
    #acesso

from
  egisadmin.dbo.LogAcesso l
 
  inner join egisadmin.dbo.usuario u     on u.cd_usuario = l.cd_usuario
  left outer join egisadmin.dbo.modulo m on m.cd_modulo  = case when isnull(l.cd_modulo,0) = 0 then @cd_modulo_start else l.cd_modulo end
  --select top 1000 * from logacesso

where
  --l.cd_modulo = 0
  --and
  l.dt_log_acesso>=@dt_hoje
  and
  isnull(l.cd_usuario,0)>0


group by
  convert(datetime,left(convert(varchar,l.dt_log_acesso,121),10)+' 00:00:00',121),
  l.cd_usuario,
  l.cd_modulo
  

  --select * from logAcesso



--Consulta

if @ic_parametro = 0
begin  
  select 
    a.*,
    ue.cd_empresa,
	e.nm_fantasia_empresa
  from 
    #acesso a

    left outer join egisadmin.dbo.usuario_empresa ue on ue.cd_usuario       = a.cd_usuario and
                                          ue.ic_acesso_padrao = 'S'
    inner join egisadmin.dbo.empresa e               on e.cd_empresa = ue.cd_empresa
  where
    ue.cd_empresa = case when @cd_empresa = 0 then ue.cd_empresa else @cd_empresa end


end


--Empresas

--Empresas Utilizando

if @ic_parametro = 1
begin  

  select 
    
    count(distinct ue.cd_empresa) as qt_empresa

  from 
    #acesso a
    left outer join egisadmin.dbo.usuario_empresa ue on ue.cd_usuario       = a.cd_usuario and
                                        ue.ic_acesso_padrao = 'S'

  where
    ue.cd_empresa = case when @cd_empresa = 0 then ue.cd_empresa else @cd_empresa end
	and
	qt_status>0


end


--Usuários Utilizando
--select dbo.fn_data_string(getdate())

if @ic_parametro = 2
begin  

  select 
    1                                               as cd_controle,
    count(distinct a.cd_usuario)                    as qt_usuario,
	count(distinct ue.cd_empresa)                   as qt_empresa,
	--@dt_hoje                                      as dt_hoje,
	cast(dbo.fn_data_string(getdate()) as char(5))  as dt_hoje,
	cast(dbo.fn_hora_agora(getdate()) as char(5))   as hr_hoje

  from 
    #acesso a
    left outer join egisadmin.dbo.usuario_empresa ue on ue.cd_usuario       = a.cd_usuario and
                                        ue.ic_acesso_padrao = 'S'

  where
    ue.cd_empresa = case when @cd_empresa = 0 then ue.cd_empresa else @cd_empresa end
	and
	qt_status>0


end


--Mostra todas as Empresas que Utilizando o sistema agora------------------------------------------------------

if @ic_parametro = 3
begin  
  select 
    e.cd_empresa,
	e.nm_fantasia_empresa,
    COUNT(distinct a.cd_usuario )            as qt_usuario,
	MAX(a.hr_log_acesso)                     as hr_log_acesso,
	MAX(a.dt_log_acesso)                     as dt_log_acesso,
	MAX(isnull(ec.serversql,'186.202.42.2')) as serversql

	--select * from empresa_conexao

  into #EmpresaAcesso
  
  from 
    #acesso a

    left outer join egisadmin.dbo.usuario_empresa ue on ue.cd_usuario       = a.cd_usuario and ue.ic_acesso_padrao = 'S'

    inner join egisadmin.dbo.empresa e               on e.cd_empresa = ue.cd_empresa
	left outer join egisadmin.dbo.Empresa_Conexao ec on ec.cd_empresa = e.cd_empresa
  where
    ue.cd_empresa = case when @cd_empresa = 0 then ue.cd_empresa else @cd_empresa end
  
  group by
     e.cd_empresa,
	 e.nm_fantasia_empresa


  order by
    e.cd_empresa

  --select * from #EmpresaAcesso

  select
     --@vl_total  = sum(vl_total),
	 @qt_total  = sum(qt_usuario),
	 @qt_empresa = COUNT(distinct cd_empresa )
  from
    #EmpresaAcesso
  

  select
     identity(int,1,1) as cd_controle,
     v.*,	 
	 pc_faturamento = case when @qt_total>0                           then round(v.qt_usuario/@qt_total*100,2)                else 0.00 end
		
  into
    #FinalEmpresaAcesso

  from
    #EmpresaAcesso v
	

   order by
     hr_log_acesso desc   

    if not exists(select * from #FinalEmpresaAcesso)  
    begin  
     select 'S'                                                    as 'MultipleDate'  
    end  
    else   
    begin  
      select   
        cd_controle,  
  
      --'S'                                                             as 'SingleDate',  
   'S'                                                                  as 'MultipleDate', 
   'S'                                                                  as ic_sub_menu,
   cd_empresa                                                           as cd_parametro_menu_detalhe,  
   
   'currency-usd'                                                       as 'iconHeader',     
   CAST(nm_fantasia_empresa as varchar(20))                             as 'caption',
   --cast(qt_nota as varchar)
  CAST(cd_controle as varchar(20))                                      as 'badgeCaption',
  'Usuários : ' + CAST(qt_usuario as varchar(20))                       as 'resultado',  
  hr_log_acesso                                                         as 'resultado1', 
  'Servidor: '+isnull(serversql,'')                                     as 'resultado2',
  dbo.fn_data_string(dt_log_acesso)                                     as 'subcaption1',  

      
   'Empresas : ' + cast(@qt_empresa as varchar(20))                     as 'titleHeader',  
   'Usuários : '+CAST(cast(@qt_total as int ) as varchar(20))           as 'subtitle2Header',
   dbo.fn_formata_valor( pc_faturamento) + ' (%)'                       as 'percentual'  

--'badgeCaption'                                    as 'badgeCaption',  
--'badgeResultadoLeft'                              as 'badgeResultadoLeft',  
--'badgeResultadoRight'                             as 'badgeResultadoRight',  
--'badgeTitle'                                      as 'badgeTitle',  
--'red'                                             as 'iconColorFooter1',  
--'blue'                                            as 'iconColorFooter2',  
--'home'                                            as 'iconFooter1',  
--'home'                                            as 'iconFooter2',  
--'home'                                            as 'iconHeader',  
--'percentual'                                      as 'percentual',  
--'smallCaptionLeft'                                as 'smallCaptionLeft',  
--'smallCaptionRight'                               as 'smallCaptionRight',  
--'subtitle2Header'                                 as 'subtitle2Header',  
--'titleHeader'                                     as 'titleHeader',  
--'resultado2'                                      as 'resultado2',  
--'blue'                                            as 'resultado2Color',  
--'resultado1'                                      as 'resultado1',  
--'subcaption2'                                     as 'subcaption2',  
--‘quantidade'                                      as 'quantidade',  
  
  
      from #FinalEmpresaAcesso b  
      order by          
	    cd_controle
     end  
  
    return  



end

--Usuários por Empresa----

if @ic_parametro = 4
begin  
  select 
    e.cd_empresa,
	e.nm_fantasia_empresa,
	u.cd_usuario,
	upper(u.nm_fantasia_usuario)    as nm_fantasia_usuario,
	max(u.nm_usuario)               as nm_usuario,
	count(a.qt_entrada)             as qt_entrada,
	MAX(a.hr_log_acesso)            as hr_log_acesso,
	MAX(a.dt_log_acesso)            as dt_log_acesso

  into #AcessoUsuario
  
  from 
    #acesso a

    left outer join egisadmin.dbo.usuario_empresa ue on ue.cd_usuario       = a.cd_usuario and
                                          ue.ic_acesso_padrao = 'S'

    inner join egisadmin.dbo.empresa e               on e.cd_empresa = ue.cd_empresa
	inner join egisadmin.dbo.Usuario u               on u.cd_usuario = a.cd_usuario

  where
    ue.cd_empresa = case when @cd_empresa = 0 then ue.cd_empresa else @cd_empresa end
  
  group by
     e.cd_empresa,
	 e.nm_fantasia_empresa,
 	 u.cd_usuario,
	 u.nm_fantasia_usuario



  order by
    e.cd_empresa

  select
     --@vl_total  = sum(vl_total),
	 @qt_total  = count(qt_entrada),
	 @qt_usuario = COUNT(cd_usuario)
  from
    #AcessoUsuario
  

  select
     identity(int,1,1) as cd_controle,
     v.*,	 
	 pc_faturamento = case when @qt_total>0                           then round(v.qt_entrada/@qt_total*100,2)                else 0.00 end
		
  into
    #FinalAcessoUsuario

  from
    #AcessoUsuario v
	

   order by
     nm_fantasia_usuario

    if not exists(select * from #FinalAcessoUsuario)  
    begin  
     select 'S'                                                    as 'MultipleDate'  
    end  
    else   
    begin  
      select   
        cd_controle,  
  
      --'S'                                                             as 'SingleDate',  
   'S'                                                                  as 'MultipleDate', 
   'N'                                                                  as ic_sub_menu,
   --cd_empresa                                                           as cd_parametro_menu_detalhe,  

   
   'currency-usd'                                                       as 'iconHeader',     
   CAST(nm_fantasia_usuario as varchar(20))                             as 'caption',
   --cast(qt_nota as varchar)
  CAST(cd_controle as varchar(20))                                      as 'badgeCaption',
  'Acessos : ' + CAST(qt_entrada as varchar(20))                        as 'resultado',  
  hr_log_acesso                                                         as 'resultado1',  
  nm_usuario                                                            as 'resultado2',
  dbo.fn_data_string(dt_log_acesso)                                     as 'subcaption1',  

      
   'Acessos : ' + cast(cast(@qt_total as int) as varchar(20))           as 'titleHeader',
   'Usuários : '+ CAST(cast(@qt_usuario as int ) as varchar(20))        as 'subtitle2Header',
   dbo.fn_formata_valor( pc_faturamento) + ' (%)'                       as 'percentual'  

--'badgeCaption'                                    as 'badgeCaption',  
--'badgeResultadoLeft'                              as 'badgeResultadoLeft',  
--'badgeResultadoRight'                             as 'badgeResultadoRight',  
--'badgeTitle'                                      as 'badgeTitle',  
--'red'                                             as 'iconColorFooter1',  
--'blue'                                            as 'iconColorFooter2',  
--'home'                                            as 'iconFooter1',  
--'home'                                            as 'iconFooter2',  
--'home'                                            as 'iconHeader',  
--'percentual'                                      as 'percentual',  
--'smallCaptionLeft'                                as 'smallCaptionLeft',  
--'smallCaptionRight'                               as 'smallCaptionRight',  
--'subtitle2Header'                                 as 'subtitle2Header',  
--'titleHeader'                                     as 'titleHeader',  
--'resultado2'                                      as 'resultado2',  
--'blue'                                            as 'resultado2Color',  
--'resultado1'                                      as 'resultado1',  
--'subcaption2'                                     as 'subcaption2',  
--‘quantidade'                                      as 'quantidade',  
  
  
      from #FinalAcessoUsuario b  
      order by          
	    cd_controle
     end  
  
    return  



end

--Empresas Ativas----

if @ic_parametro = 5
begin  
  select 
    e.cd_empresa,
	e.nm_fantasia_empresa,	
	e.nm_banco_empresa,
	e.cd_cgc_empresa,
	max(e.nm_empresa)                    as nm_empresa,
	max(isnull(e.qt_usuario_contrato,0)) as qt_usuario_contrato,
	count( isnull(ue.cd_usuario,0))      as qt_usuario_cadastro,			
	MAX(a.hr_log_acesso)                 as hr_log_acesso,
	MAX(a.dt_log_acesso)                 as dt_log_acesso

  into #Empresa
  
  from 
     egisadmin.dbo.Empresa e
     left outer join #acesso a          on a.cd_empresa_acesso = e.cd_empresa    

     left outer join egisadmin.dbo.usuario_empresa ue on ue.cd_empresa = e.cd_empresa
                                              
    

  where
    e.cd_empresa = case when @cd_empresa = 0 then ue.cd_empresa else @cd_empresa end
    and
	ISNULL(e.ic_ativa_empresa,'N') = 'S'

  group by
     e.cd_empresa,
	 e.nm_fantasia_empresa,
	 e.nm_banco_empresa,
	 e.cd_cgc_empresa
	 	 
  order by
    e.cd_empresa

  --select * from #Empresa


  --Atualiza os usuários Ativos cadastrados---

  select
    e.cd_empresa,
	COUNT(distinct u.cd_usuario) as qt_usuario
  into
    #UsuarioCadastro

  from
    egisadmin.dbo.usuario_empresa ue  
    inner join egisadmin.dbo.Usuario u on u.cd_usuario = ue.cd_usuario
	inner join egisadmin.dbo.Empresa e on e.cd_empresa = ue.cd_empresa
  where
     ISNULL(e.ic_ativa_empresa,'N')='S'
	 and
	  ISNULL(u.ic_ativo,'N')='A'

  group by
    e.cd_empresa 
   

   --select * from Usuario_Empresa


  update
    #Empresa
  set
    qt_usuario_cadastro = u.qt_usuario
  from
    #Empresa e
	inner join #UsuarioCadastro u on u.cd_empresa = e.cd_empresa

	--select * from #UsuarioCadastro

  select
     --@vl_total  = sum(vl_total),
	 @qt_total   = count(cd_empresa),
	 @qt_usuario = sum(qt_usuario_cadastro)
  from
    #Empresa
  

  select
     identity(int,1,1) as cd_controle,
     v.*,	 
	 pc_faturamento = case when @qt_usuario>0  then round(v.qt_usuario_cadastro/@qt_usuario*100,2)                else 0.00 end
		
  into
    #FinalEmpresa

  from
    #Empresa v
	

   order by
     nm_fantasia_empresa

    if not exists(select * from #FinalEmpresa)  
    begin  
     select 'S'                                                    as 'MultipleDate'  
    end  
    else   
    begin  
      select   
        cd_controle,  
  
      --'S'                                                             as 'SingleDate',  
   'S'                                                                  as 'MultipleDate', 
   'N'                                                                  as ic_sub_menu,
   --cd_empresa                                                           as cd_parametro_menu_detalhe,  

   
   'currency-usd'                                                       as 'iconHeader',     
   CAST(nm_fantasia_empresa as varchar(20))
                              as 'caption',
   --cast(qt_nota as varchar)
  CAST(cd_controle as varchar(20))                                      as 'badgeCaption',
  'Contrato : ' + CAST(qt_usuario_contrato as varchar(20))              as 'resultado',  
  hr_log_acesso                                                         as 'resultado1',  
  'Usuários : '+ CAST(qt_usuario_cadastro as varchar(20))               as 'resultado2',
  
   
   ' ('+CAST(cd_empresa as varchar(9)) +') '
   +
   nm_banco_empresa                                                     as 'resultado3',
   '. ' + nm_empresa                                                    as 'resultado4',
  'Acesso: '+dbo.fn_data_string(dt_log_acesso)                          as 'subcaption1',  

      
   'Empresas : ' + cast(cast(@qt_total as int) as varchar(20))          as 'titleHeader',
   'Usuários : '+ CAST(cast(@qt_usuario as int ) as varchar(20))        as 'subtitle2Header',
   dbo.fn_formata_valor( pc_faturamento) + ' (%)'                       as 'percentual'  

--'badgeCaption'                                    as 'badgeCaption',  
--'badgeResultadoLeft'                              as 'badgeResultadoLeft',  
--'badgeResultadoRight'                             as 'badgeResultadoRight',  
--'badgeTitle'                                      as 'badgeTitle',  
--'red'                                             as 'iconColorFooter1',  
--'blue'                                            as 'iconColorFooter2',  
--'home'                                            as 'iconFooter1',  
--'home'                                            as 'iconFooter2',  
--'home'                                            as 'iconHeader',  
--'percentual'                                      as 'percentual',  
--'smallCaptionLeft'                                as 'smallCaptionLeft',  
--'smallCaptionRight'                               as 'smallCaptionRight',  
--'subtitle2Header'                                 as 'subtitle2Header',  
--'titleHeader'                                     as 'titleHeader',  
--'resultado2'                                      as 'resultado2',  
--'blue'                                            as 'resultado2Color',  
--'resultado1'                                      as 'resultado1',  
--'subcaption2'                                     as 'subcaption2',  
--‘quantidade'                                      as 'quantidade',  
  
  
      from #FinalEmpresa b  
      order by          
	    cd_controle
     end  
  
    return  



end




drop table #acesso




go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
go

exec pr_egis_usuario_logado '[{
    "cd_parametro":"0",
	"cd_usuario": 113

}]'
go

exec pr_egis_usuario_logado '[{
    "cd_parametro":"5",
	"cd_usuario": 113

}]'
go


--Mostra todos os acesso hoje
--exec pr_egis_usuario_logado 0,0
------------------------------------------------------------------------------
--Empresas Utilizando
--exec pr_usuario_logado 1,0
------------------------------------------------------------------------------
--Usuárioas utilizando
--exec pr_egis_usuario_logado 2,0

--resumo por empresa
--exec pr_egis_usuario_logado 3,0

--resumo por empresa e usuários
--exec pr_egis_usuario_logado 4,317

--Empresas
--exec pr_egis_usuario_logado 5,0


------------------------------------------------------------------------------
--update Empresa set nm_fantasia_empresa = UPPER(nm_fantasia_empresa)

------------------------------------------------------------------------------
--select * from empresa_conexao
--Servidor: 186.202.42.2
--Servidor: 181.191.209.84