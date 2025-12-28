--BANCO DO CLIENTE
--USE EGISSQL_341
--GO
--use egissql_377

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_pesquisa_dados' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_pesquisa_dados

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_pesquisa_dados
-------------------------------------------------------------------------------
--pr_egis_pesquisa_dados
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EGISSQL
--
--Objetivo         : Pesquisa de Dados do Egis 
--
--Data             : 22.04.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_pesquisa_dados
@json nvarchar(max) = ''

--with encryption


as

set @json = ISNULL(@json,'')
set @json = replace(@json,'''','')

declare @dt_hoje datetime  
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)         
  
if @json= '' 
begin  
  select 'Parâmetros inválidos !' as Msg  
  return  
end  

--------------------------------------
set @json = replace(@json,'''','')
----------------------------------------------------------------------------------------------------------    

select                 
identity(int,1,1)             as id,                 
    valores.[key]    COLLATE SQL_Latin1_General_CP1_CI_AI         as campo,                 
    valores.[value]  COLLATE SQL_Latin1_General_CP1_CI_AI         as valor                
into #json                
from                 
   openjson(@json)root                
   cross apply openjson(root.value) as valores 	

--select * from #json

----------------------------------------------------------------------------------------------------------    
declare @cd_parametro              int = 0
declare @cd_usuario                int = 0
declare @cd_menu                   int = 0 
declare @dt_inicial                datetime      
declare @dt_final                  datetime     
declare @cd_cep                    varchar(9)   = ''
declare @nm_endereco_cep           varchar(100) = ''
declare @sg_estado                 varchar(2)   = ''
declare @cd_tabela                 int          = 0
declare @nm_tabela_pai             varchar(80)  = ''
declare @cd_empresa                int          = 0
declare @ic_consulta_fixa          char(1)      = 0
declare @ic_admin                  char(1)      = 'N'
declare @count                     int          = 0
declare @cd_ano                    int          = 0
declare @cd_mes                    int          = 0
declare @nome_procedure            varchar(100) = ''
declare @cd_controle               int          = 0
declare @cd_chave_pesquisa         int          = 0   

----------------------------------------------------------------------------------------------------------    
select @cd_parametro			    = valor from #json  with(nolock) where campo = 'cd_parametro' 
select @cd_usuario		   	        = valor from #json  with(nolock) where campo = 'cd_usuario' 
select @dt_inicial					= valor from #json  with(nolock) where campo = 'dt_inicial'   
select @dt_final					= valor from #json  with(nolock) where campo = 'dt_final'  
select @cd_menu    			        = valor from #json  with(nolock) where campo = 'cd_menu' 
select @cd_cep                      = valor from #json  with(nolock) where campo = 'cd_cep' 
select @nm_endereco_cep             = valor from #json  with(nolock) where campo = 'nm_endereco_cep' 
select @sg_estado                   = valor from #json  with(nolock) where campo = 'sg_estado' 
select @cd_ano                      = valor from #json  with(nolock) where campo = 'cd_ano' 
select @cd_mes                      = valor from #json  with(nolock) where campo = 'cd_mes' 
select @cd_chave_pesquisa           = valor from #json  with(nolock) where campo = 'cd_chave_pesquisa' 

------------------------------------------------------------------------------------------------------------------------------

set @dt_inicial = convert(datetime,left(convert(varchar,@dt_inicial,121),10)+' 00:00:00',121)         
set @dt_final   = convert(datetime,left(convert(varchar,@dt_final,121),10)+' 00:00:00',121)         

------------------------------------------------------------------------------------------------------------------------------

select
  @nome_procedure = isnull(mpc.nome_procedure,'')
from
  egisadmin.dbo.meta_procedure_colunas mpc
where
  mpc.cd_menu_id = @cd_menu


--select @nome_procedure


if @nome_procedure<>''
begin
   select @nome_procedure as msg
   return
end

--select @dt_inicial, @dt_final

set @cd_ano = ISNULL(@cd_ano,0) 
set @cd_mes = ISNULL(@cd_mes,0) 

if @cd_ano = 0
   set @cd_ano = year(getdate())

if @cd_mes = 0
   set @cd_mes = month(getdate())  

----------------------------------------------------------------------------------------------------------

if @dt_inicial = '01/01/1900' or @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end

----------------------------------------------------------------------------------------------------------    
set @cd_empresa = dbo.fn_empresa()

set @cd_cep = replace(@cd_cep,'-','')  

--Dados da Coluna para Retorno da Procedure-----------------------------------------------------------------------------------------
--select * from cep where cd_cep = '09811410'

--Tabela Pai para o SQL-------------------------------------------------------------------------------------------------------------

select
  top 1
  @cd_tabela     = isnull(t.cd_tabela,0),
  @nm_tabela_pai = case when ISNULL(t.ic_sap_admin,'N') = 'S' then 'EgisAdmin.dbo.' else CAST('' as char(1)) end
                   +
				   isnull(t.nm_tabela,0),
  @ic_admin      = ISNULL(t.ic_sap_admin,'N')

from
  egisadmin.dbo.tabela t 
  inner join egisadmin.dbo.menu_tabela mt on mt.cd_tabela = t.cd_tabela

where
  mt.cd_menu = @cd_menu

--select @cd_tabela
--return

------------------------------------------------------------------------
--select * from #json
--Dados recebidos do Front-End - Json
------------------------------------------------------------------------

select
  mf.*,
  j.valor,
  --a.nm_atributo
  case when isnull(mf.nm_campo_chave_lookup,'')<>'' then mf.nm_campo_chave_lookup else a.nm_atributo end as nm_atributo

into
  #FiltroParametro

from
  egisadmin.dbo.menu_filtro mf
  inner join #json j                       on j.campo     = case when isnull(mf.nm_campo_chave_lookup,'')<>'' then mf.nm_campo_chave_lookup else mf.nm_campo end
  left outer join egisadmin.dbo.atributo a on a.cd_tabela = mf.cd_tabela and a.cd_atributo = mf.cd_atributo

where
  mf.cd_menu = @cd_menu
  and
  ISNULL(j.valor,'')<>''

--select * from EGISADMIN.dbo.Menu_Filtro where cd_menu = 8110
--select * from #json
--select * from #FiltroParametro
--return

--select * from #json
--select * from #filtroParametro

----------------------------------------------------------------------

--select @cd_tabela

 select

   --mc.*,

   a.nu_ordem,

   --Menu Coluna--------------------------------------------------------------------
   --select * from egisadmin.dbo.menu_coluna
   ------------------------------------------

   case when isnull(mc.cd_menu_coluna,0)=0            then a.cd_atributo            else mc.cd_menu_coluna          end as cd_menu_coluna,  
   case when isnull(mc.cd_menu,0) = 0                 then @cd_menu                 else mc.cd_menu                 end as cd_menu,
   case when ISNULL(mc.nm_atributo_menu_coluna,'')='' then a.nm_atributo_consulta   else mc.nm_atributo_menu_coluna end as nm_atributo_menu_coluna,
   case when ISNULL(mc.qt_ordem_coluna,0)=0           then a.nu_ordem               else mc.qt_ordem_coluna         end as qt_ordem_coluna,
   case when isnull(mc.ic_contador,'') = ''           then a.ic_contador_grid       else mc.ic_contador             end as ic_contador,
   case when isnull(mc.ic_total,'') = ''              then a.ic_total_grid          else mc.ic_total                end as ic_total,
   case when ISNULL(mc.nm_atributo_chave,'')=''       then case when isnull(a.ic_atributo_chave,'N')='N' 
                                                           then cast('' as char(1)) else a.nm_atributo end
                                                                                    else mc.nm_atributo_chave       end as nm_atributo_chave,
   case when isnull(mc.ic_like,'') = ''               then a.ic_like_atributo       else mc.ic_like                 end as ic_like,           --Admin fazer
   case when isnull(mc.ic_filtro,'') = ''             then a.ic_filtro_atributo     else mc.ic_filtro               end as ic_filtro,         --Admin fazer
   case when ISNULL(mc.qt_ordenacao,0)=0              then 0                        else mc.qt_ordenacao            end as qt_ordenacao,      --Admin fazer
   case when isnull(mc.nm_tipo_ordenacao,'') = ''     then cast('' as char(1))      else mc.nm_tipo_ordenacao       end as nm_tipo_ordenacao, --Admin fazer

   --------------------------------------------------------------------------------------------------------------------------------------------------------
   t.cd_tabela,   
   t.nm_tabela,
   a.cd_atributo,
   a.nm_atributo,
   fp.nm_atributo                                           as nm_filtro_atributo,

   case when ISNULL(mc.nm_atributo_menu_coluna,'')<>'' then
     mc.nm_atributo_menu_coluna
   else
     a.nm_atributo_consulta
   end                                               as nm_atributo_consulta,

   isnull(a.cd_tabela_combo_box,0)                   as cd_tabela_combo_box,

   case when isnull(a.ic_chave_estrangeira,'N')='S' 
   then
     'Código '
	 
	 +

     case when ISNULL(mc.nm_atributo_menu_coluna,'')<>'' then
       mc.nm_atributo_menu_coluna
     else
      a.nm_atributo_consulta
     end                                

   else
     cast('' as char(1))
   end

                                                       as nm_atributo_lookup,
   
   -----------------------------------------------------------------------------------------------------
   'T'+ltrim(rtrim(cast(t.cd_tabela as varchar(80))))  as sg_tabela,

 --   case when isnull(a.ic_chave_estrangeira,'N')='S' and isnull(a.cd_tabela_combo_box,0)>0 then 
 --    'T'+ltrim(rtrim(cast(isnull(a.cd_tabela_combo_box,t.cd_tabela) as varchar(6))))
	--    + ltrim(rtrim(cast(a.cd_atributo as varchar(9))))
	--else
	-- 'T'+ltrim(rtrim(cast(t.cd_tabela as varchar(6)))) 
	 
	--end                                              as sg_tabela,

	-----------------------------------------------------------------------------
   case when @cd_tabela = mc.cd_tabela then
    'S'
   else
     'N'
   end                                               as ic_tabela_pai,

   cast(1 as int)                                    as qt_ordem_lookup,

   ' T'+CAST(a.cd_tabela_combo_box as varchar(6)) + ltrim(rtrim(cast(a.cd_atributo as varchar(9))))
   +
   '.' 
   + a.nm_campo_mostra_combo_box +' as [' +a.nm_atributo_consulta+']' as nm_campo_lookup,

   case when isnull(a.ic_chave_estrangeira,'N') = 'S' and isnull(a.nm_tabela_combo_box,'')<>'' and isnull(a.nm_campo_chave_combo_box,'')<>''
   then
     ' left outer join '+case when isnull(a.ic_aliasadmin_combo_box,'N')='S' then 'egisadmin.dbo.' else CAST('' as char(1)) end
	 +
	 a.nm_tabela_combo_box+ ' T'+CAST(a.cd_tabela_combo_box as varchar(6)) + ltrim(rtrim(cast(a.cd_atributo as varchar(9))))
     + ' on ' 
     + ' T'+CAST(a.cd_tabela_combo_box as varchar(6)) + ltrim(rtrim(cast(a.cd_atributo as varchar(9))))
	 + '.'+a.nm_campo_chave_combo_box + ' = '
     + ' T'+CAST(@cd_tabela as varchar(6))            + '.'
	 + case when a.nm_campo_chave_combo_box<>a.nm_atributo then a.nm_atributo else a.nm_campo_chave_combo_box end


   else

     case when (@cd_tabela <> mc.cd_tabela) or ( t.nm_tabela <> a.nm_tabela_combo_box) then
     ' left outer join '+t.nm_tabela+ ' T'+CAST(t.cd_tabela as varchar(6)) 
   
     + ' on ' 
     + ' T'+CAST(t.cd_tabela as varchar(6)) + '.'+isnull(mc.nm_atributo_chave,a.nm_campo_chave_combo_box) + ' = '
     + ' T'+CAST(@cd_tabela as varchar(6))  + '.'+isnull(mc.nm_atributo_chave,a.nm_campo_chave_combo_box)   
     else
       cast('' as varchar(1)) 
     end
	end as nm_left_outer_join,

   --Where--   
   
   case when ISNULL(a.ic_filtro_atributo,'N') = 'S' and a.nm_atributo = fp.nm_atributo --j.campo
   then
     ' T'+CAST(@cd_tabela as varchar(6)) + '.'+a.nm_atributo
	 +
     case when isnull(a.ic_like_atributo,'N')='S' then ' like '+'''%'''+'+'+''''+j.valor+''''+'+'+'''%''' else ' = ' +''''+j.valor+'''' end
   else
   ' T'+CAST(@cd_tabela as varchar(6)) + '.'+fp.nm_campo 
   +
   case when isnull(fp.ic_like,'N')='S' then ' like '+''''+fp.valor+''''+'+'+'''%''' else ' = ' +''''+fp.valor+'''' end 
   end                                               as nm_where ,
   
   a.cd_natureza_atributo,
   na.nm_natureza_atributo,

   case when isnull(a.ic_filtro_atributo,'N')='S' then
     a.ic_filtro_atributo
   else
     ISNULL(mc.ic_filtro,'N')
   end                                                              	 as ic_filtro_coluna,

   --case when ISNULL(mc.ic_filtro,'N') = 'S' and SUBSTRING(a.nm_atributo,1,2)='dt' then
   case when ISNULL(a.ic_filtro_atributo,'N') = 'S' and SUBSTRING(a.nm_atributo,1,2)='dt' then
      ' T'+CAST(@cd_tabela as varchar(6)) + '.'+a.nm_atributo
      +
	  ' between '+''''+FORMAT(@dt_inicial,'MM/dd/yyyy')+'''' + ' and '+''''+FORMAT(@dt_final,'MM/dd/yyyy')+''''

   else
   CAST('' as char(1))
   end                                                                    as nm_where_data,

   case when ISNULL(mc.qt_ordenacao,0)>0 then
      --a.nm_atributo
	  ' T'+CAST(@cd_tabela as varchar(6)) + '.'+a.nm_atributo + ' '+ISNULL(mc.nm_tipo_ordenacao,'')
   else
      CAST('' as char(1))
   end                                                                         as nm_ordenacao,
   isnull(a.ic_atributo_chave,'N')                                             as ic_atributo_chave,
   a.nm_tabela_combo_box,
   a.nm_campo_mostra_combo_box,
   a.nm_campo_chave_combo_box,
   a.ic_chave_estrangeira
                                                                     
 into  
   #MenuColuna 

 from
   egisadmin.dbo.Tabela t
   inner join egisadmin.dbo.atributo a           on a.cd_tabela             = t.cd_tabela
   left outer join egisadmin.dbo.menu_coluna mc  on mc.cd_tabela            = t.cd_tabela      and mc.cd_atributo = a.cd_atributo   
   inner join egisadmin.dbo.natureza_atributo na on na.cd_natureza_atributo = a.cd_natureza_atributo

   left outer join #FiltroParametro fp           on  fp.cd_menu             = @cd_menu         and
                                                     fp.cd_tabela           = t.cd_tabela      and
													 fp.nm_atributo         = a.nm_atributo

   left outer join #json j                       on j.campo                 = a.nm_atributo

 where
   --mc.cd_menu = @cd_menu
   t.cd_tabela = @cd_tabela
   and
   ISNULL(a.ic_mostra_grid,'N') = 'S'
   and
   ISNULL(a.nm_atributo_consulta,'')<>''

 order by
   a.nu_ordem
   --mc.qt_ordem_coluna

--sequencia de analise de filtro de pesquisa---
--

--select @cd_tabela
--select * from #json
--select * from #FiltroParametro
--select * from #MenuColuna

--

--select * from #MenuColuna


--return

--select * from #FiltroParametro
 
 ---------------------------------------------------------------------------------------------------------------
 
 --Colunas---------------------------------------------
 select * into #AuxColunaTemp from #MenuColuna 
  order by qt_ordem_coluna
 
 --Lookup----------------------------------------------

 select * into #Lookup from #MenuColuna
 where
    ISNULL(nm_campo_lookup,'')<> ''

 update
   #Lookup
 set
   qt_ordem_lookup         = 0,
   nm_atributo_consulta    = nm_atributo_lookup,
   nm_atributo_menu_coluna = nm_atributo_lookup

--select * from #MenuColuna

update
  #AuxColunaTemp
set
  nm_atributo             = nm_campo_mostra_combo_box,
  sg_tabela               = 'T'+ltrim(rtrim(cast(cd_tabela_combo_box as varchar(6))))                               
							 + ltrim(rtrim(cast(cd_atributo as varchar(9)))) 
from
  #AuxColunaTemp

where
  ic_chave_estrangeira='S'
  and
  ISNULL(nm_campo_mostra_combo_box,'')<>''
  and
  qt_ordem_lookup = 1

--------------------------------------------------------------------------------------------------------------------

  --nm_atributo          = nm_campo_mostra_combo_box
  
--select * from #Lookup    order by qt_ordem_coluna

----------------------------------------------------------

 insert into #AuxColunaTemp
 select * from #Lookup
 where
    ISNULL(nm_campo_lookup,'')<> ''
	and
	isnull(nm_atributo_menu_coluna,'')<>''

--select * from #Lookup    order by qt_ordem_coluna

----------------------------------------------------------------------------------------------------

 --select * from #AuxColunaTemp order by qt_ordem_coluna, qt_ordem_lookup

 ---------------------------------------------------------------------------------------------------

 --Tabela Final----

 select 
   cd_controle = IDENTITY(int,1,1), * into #AuxColuna
 from
   #AuxColunaTemp 

 order by 
   qt_ordem_coluna, qt_ordem_lookup
 
----------------------------------------------------------------------------------------------------
 --select * from #json

 --Para visualizar e debugar
 ---
--select * from #AuxColuna order by qt_ordem_coluna, qt_ordem_lookup
 --
 ---

----------------------------------------------------------------------------------------------------


 --return

 declare @cd_menu_coluna int            = 0
 declare @sql            nvarchar(max)  = ''
 declare @sqlColunas     nvarchar(max)  = ''
 declare @sqlLeft        nvarchar(max)  = ''
 declare @sqlLookup      nvarchar(max)  = ''
 declare @sqlWhereFiltro nvarchar(max)  = ''
 declare @sqlOrderBy     nvarchar(max)  = ''
 declare @sg_tabela      varchar(10)    = ''
 declare @nm_atributo    varchar(80)    = ''
 declare @ic_chave       varchar(80) = ''
 declare @nm_apresenta   varchar(80)    = ''
 declare @cd_filtro      int            = 0
 declare @cd_natureza    int            = 0
 declare @sqlPesquisa    nvarchar(max)  = ''

 
 --select * from #FiltroParametro


 while exists ( select top 1 cd_filtro from #FiltroParametro )
 begin

   select top 1
     @cd_filtro = cd_filtro	
   from  
     #FiltroParametro
   order by
     cd_filtro

   delete from #FiltroParametro
   where
     cd_filtro = @cd_filtro

 end

 --select * from #AuxColuna order by qt_ordem_coluna, qt_ordem_lookup


 while exists( select top 1 cd_controle from #AuxColuna )
 begin

   select
     top 1
	 @cd_controle    = cd_controle,
	 @cd_menu_coluna = cd_menu_coluna,
	 @sg_tabela      = sg_tabela,
	 @ic_chave       = ic_atributo_chave,
	 @nm_atributo    = nm_atributo,
	 @nm_apresenta   = case when isnull(nm_atributo_consulta,'')<>'' then nm_atributo_consulta else nm_atributo end,
	 
	 ------------------LEFT-----------------------------------------------------------------------------------------
	 
	 @sqlLeft        = @sqlLeft        + 
	                   case when isnull(qt_ordem_lookup,0) = 0 then ISNULL(nm_left_outer_join,'') else CAST('' as varchar(1)) end,

	 ------------------LOOKUP-----------------------------------------------------------------------------------------

	 @sqlLookup      = @sqlLookup      
	                   +
					   case when isnull(qt_ordem_lookup,0) = 0 then
	                    case when @sqlLookup <> '' and ISNULL(nm_campo_lookup,'') <> '' then ' , ' else cast('' as char(1)) end
	                    +
					    isnull(nm_campo_lookup,'')
					   else
					    CAST('' as varchar(1))
					   end,
	 
	 ------------------FILTRO-----------------------------------------------------------------------------------------

	 @sqlWhereFiltro = @sqlWhereFiltro + 
	                   case when @sqlWhereFiltro <> '' and ISNULL(nm_where,'') <> ''     then ' and ' else cast('' as char(1)) end
					   + ISNULL(nm_where,'')
					   +
					   case when @sqlWhereFiltro <> '' and ISNULL(nm_where_data,'') <> '' then ' and ' else cast('' as char(1)) end
					   + 
					   ISNULL(nm_where_data,''),

	 ------------------ORDER BY-----------------------------------------------------------------------------------------

	 @sqlOrderBy     = @sqlOrderBy     + ISNULL(nm_ordenacao,''),

	 @cd_natureza    = cd_natureza_atributo

  from
    #AuxColuna

  order by
    qt_ordem_coluna, qt_ordem_lookup

--	select @sqlLeft

	--format(T234.[dt_emissao_documento_paga],'dd/mm/yyyy')

  --Adiciona a Chave (id) ----------------------------------------------------------------------------------------------------------
  
  if @ic_chave = 'S'
  begin
   
    if @cd_chave_pesquisa>0 and @sqlPesquisa = ''
	begin
	  set @sqlPesquisa = @sg_tabela + '.['+cast(isnull(@nm_atributo,'') as nvarchar(max))+']' + ' = ' +cast(@cd_chave_pesquisa as varchar(50))
	   --select @ic_chave, @nm_atributo, @sqlPesquisa 
	end

    set @sqlColunas = ltrim(rtrim(@sqlColunas))
                  +
                  case when isnull(@sqlColunas,'')<>'' then ', ' else '' end
				  +
				  @sg_tabela
				  +
				    '.['+cast(isnull(@nm_atributo,'') as nvarchar(max))+']' 

				  + 
				  ' as '
				  +
				  '['+'id'+']'
  
  end

  ------------------------------------------------Colunas-------------------------------------------------------------------------------

  set @sqlColunas = @sqlColunas
                  +
                  case when isnull(@sqlColunas,'')<>'' then ', ' else '' end
				  +
				  case when @cd_natureza = 4 then
	                'format('
				  else
				    CAST('' as char(1)) 
				  end
				  +
				  @sg_tabela
				  +
				  '.['+cast(isnull(@nm_atributo,'') as nvarchar(max))+']'  --
				  +
				  case when @cd_natureza = 4 then
	                ', '+''''+'dd/MM/yyyy'+''''+')'
				  else
				    CAST('' as char(1)) 
				  end

				  + 
				  ' as '
				  +
				  '['+@nm_apresenta+']'
    

  delete from #AuxColuna
  where
    cd_controle = @cd_controle

 end

 --select @sqlLeft

 --	select @sqlLookup
 --select @sqlOrderBy
   --select @sqlWhereFiltro
   --return
 --select @sqlColunas
 ---------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------


--SELECT @cd_cep

----------------------------------------------------------------------------------------------------------    
--DROP TABLE CCF

--select @cd_cep as cd_cep into CCF
--SELECT * FROM CCF

--select @sqlLeft
--select @sqlWhereFiltro

set @ic_consulta_fixa = 'N'

if @cd_menu = 6914 
begin
  exec dbo.pr_venda_anual  @cd_ano='2025',@cd_moeda=1
  return
end

if @cd_menu = 6847 
begin
  
  exec pr_egisnet_consulta_ramal @cd_empresa, 0
  return
end 

if @cd_menu = 6440
begin
  --select @dt_inicial, @dt_final, @cd_usuario
  exec sp_aniversariantes_empresa @cd_usuario,@dt_inicial,@dt_final,1   
--  return
end


--@sqlWhereFiltro
--select @sqlPesquisa, @cd_chave_pesquisa as cd_chave_pesquisa, @sqlWhereFiltro as Filtros
---------------------------------


--select @sqlColunas
--select @nm_tabela_pai, @cd_tabela, @sqlLeft 
--select @sqlWhereFiltro
--Consulta Fixa para todos os Menus------------------------------------------------------------------------


  set @sql = 'Select '
             +
			 @sqlColunas
			 +
			 ' from '
			 +
			 --Tabelas--
			 --(Fazer o nome das Tabelas Dinâmicos ) -- Tabela -- Pai e Tabelas Filhos
             --' cep T143'  			 
			 @nm_tabela_pai + ' T'+cast(@cd_tabela as varchar(6))
			 +' '
			 +
			 +--Left
			 + case when @sqlLeft<>'' then ltrim(rtrim(@sqlLeft)) else CAST('' as varchar(1)) end
			 --+' left outer join pais T492     on T492.cd_pais     = T143.cd_pais  '
             --+' left outer join estado T96    on T96.cd_estado    = T143.cd_estado  '
             --+' left outer join cidade T97    on T97.cd_cidade    = T143.cd_cidade   '
			 +
			 --Where
			 +case when @sqlWhereFiltro<>'' then
			 ' Where ' + ltrim(rtrim(@sqlWhereFiltro))
			 else
			 CAST('' as varchar(100))
			 end

			 +

			 case when ltrim(rtrim(isnull(@SqlPesquisa,'')))<>'' then
			   case when isnull(@sqlWhereFiltro,'')='' then
			      ' Where '
			   else
			      cast('' as varchar(100))
			   end
			   +
			   @SqlPesquisa
             else
			    cast('' as varchar(100))
			 end
			 --+

			 +
			 ' order by '
			 +
			 case when @sqlOrderBy<>'' then ltrim(rtrim(@sqlOrderBy)) else ' 1 desc' end

			 --select @sql
			 
			 --'T143.cd_cep like '+''''+@cd_cep+''''+'+'+'''%'''
			 --SELECT @sql AS [SQL_Gerado]

			 --DECLARE @count INT;

			 --mostra o select para debug-------
			   --> essencial (ccf)

            --select @sql
			    

			------------------------------------------------------------------- 

		      if @sql is not null
			  begin
			     EXEC sp_executesql @sql, N'@count_out INT OUTPUT', @count_out = @count OUTPUT;
              end
			  else
			    select 'Dados não disponíveis para consulta' as msg

			  ------------------------------------------------------------------------------------------------
			  --IF @count = 0
			  --begin
              --   Select 'Atenção, Nenhum dado encontrado para consulta !!!' as Msg
              --end

			  ------------------------------------------------------------------------------------------------

--atributo--
--select nm_atributo_consulta,* from egisadmin.dbo.atributo where nm_atributo = 'cd_cep' and cd_tabela = 143
-----------------------------------------------------------------------------------------------------------------------------------------------
--menu_resultado

go




go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_pesquisa_dados 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_pesquisa_dados 
------------------------------------------------------------------------------27746
--exec pr_egis_pesquisa_dados '[{"cd_parametro":1,"cd_menu":8320,"cd_consulta":27746,"cd_usuario":"113","filtros":[]}]'
go
--exec pr_egis_pesquisa_dados '[{"cd_parametro":1,"cd_menu":8098,"cd_usuario":"113","filtros":[],"cd_consulta":27746}]'
go
--use EGISSQL_319
--go

--exec pr_egis_pesquisa_dados '[
--    {
--        "cd_parametro": 0,
--        "cd_menu": 5944,
--        "cd_usuario": "113",
--        "cd_chave_pesquisa": "0",
--        "ic_modal_pesquisa": "N"
--    }
--]'
--GO



--exec pr_egis_pesquisa_dados '[
--{
--    "cd_parametro": "1",
--    "cd_menu": "8193",
--    "cd_usuario": "963",
--    "dt_inicial": "2025-07-01",
--    "dt_final": "2025-07-31"
--}]
--'
go



--exec pr_egis_pesquisa_dados '
--[
--    {
--        "cd_parametro": 1,
--        "cd_menu": "7183",
--        "cd_usuario": "113",
--        "dt_inicial": "2025-05-01",
--        "dt_final": "2025-05-31"      
        
--    }
--]'
----go
--exec pr_egis_pesquisa_dados '[{"cd_parametro":1,"cd_menu":8708,"dt_inicial": "2025-05-01","dt_final": "2025-05-31","cd_usuario":4721}]'
go
--exec pr_egis_pesquisa_dados '
--[
    
	
--    {
--        "cd_parametro": 1,
--        "cd_menu": "5935",
--        "cd_usuario": "113",
--        "dt_inicial": "2025-05-01",
--        "dt_final": "2025-05-31",
--        "nm_fantasia_cliente": "ind",
--        "nm_razao_social_cliente": ""
--    }


--]'
--go
--use egissql_318
--go

--exec pr_egis_pesquisa_dados '[{
--    "cd_parametro": 1,
--    "cd_menu": 8279,
--    "cd_usuario": 1
   
--}]'

--exec pr_egis_pesquisa_dados '[{
--        "cd_parametro": 0,
--        "cd_menu": 8320,
--        "cd_usuario": 0,
--        "sg_estado": {
--            "value": "5",
--            "label": "BA"
--        }
--    }
--]"'

--select * from transportadora
--
--exec pr_egis_pesquisa_dados '[{"cd_parametro":1,"cd_menu":"8448",
--"nm_estado" : "4",
--"cd_usuario":"1","dt_inicial":"2025-10-01","dt_final":"2025-10-31", "cd_chave_pesquisa": 0}]'


go

--select * from plano_financeiro

--exec pr_egis_pesquisa_dados '[{"cd_parametro":1,"cd_menu":"8820","cd_usuario":"4721","dt_inicial":"2025-06-06","dt_final":"2025-06-06","nm_conta":"x"}]' 

--moeda
--select * from requisicao_interna

--use egissql_decora
--use egissql


--exec pr_egis_pesquisa_dados '[
--    {
--        "cd_parametro": 1,
--        "cd_menu": "6437",
--        "cd_usuario": "113",
--        "dt_inicial": "2025-12-01",
--        "dt_final": "2025-12-31",
--        "cd_cep": "09811",
--        "nm_endereco_cep": "",
--        "sg_estado": ""
--    }
--]'