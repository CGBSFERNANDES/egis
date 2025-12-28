USE EGISADMIN
go
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_gera_menu_filtro' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_gera_menu_filtro

GO

-------------------------------------------------------------------------------
--sp_helptext pr_gera_menu_filtro
-------------------------------------------------------------------------------
--pr_gera_menu_filtro
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EGISADMIN
--
--Objetivo         : Geração de Filtros
--
--Data             : 22.04.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_gera_menu_filtro
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
identity(int,1,1)             as id,                 
    valores.[key]             as campo,                 
    valores.[value]           as valor                
into #json                
from                 
   openjson(@json)root                
   cross apply openjson(root.value) as valores 	

----------------------------------------------------------------------------------------------------------    
declare @cd_parametro              int = 0
declare @cd_usuario                int = 0
declare @cd_menu                   int = 0 
declare @dt_inicial                datetime      
declare @dt_final                  datetime     
declare @nome_procedure            varchar(100) = ''

----------------------------------------------------------------------------------------------------------    
select @cd_parametro			    = valor from #json  with(nolock) where campo = 'cd_parametro' 
select @cd_usuario		   	        = valor from #json  with(nolock) where campo = 'cd_usuario' 
select @dt_inicial					= valor from #json  with(nolock) where campo = 'dt_inicial'   
select @dt_final					= valor from #json  with(nolock) where campo = 'dt_final'  
select @cd_menu    			        = valor from #json  with(nolock) where campo = 'cd_menu' 

----------------------------------------------------------------------------------------------------------    

set @cd_parametro = isnull(@cd_parametro,0)

--------------------------------------------

select
  top 1
  @nome_procedure = isnull(nome_procedure,'')
from
  meta_procedure_colunas mpc
where
  mpc.cd_menu_id = @cd_menu

----------------------------------------------------------------------------------------------------

 
--
--select * from meta_procedure_colunas
--select * from meta_procedure_parametros

--Filtros das Procedures----------------------------------------------------------------------------

if @nome_procedure<>''
begin

--select * from menu_filtro
--select * from meta_procedure_parametros

  select 
    --m.cd_menu,
	m.nm_menu_titulo,
	m.nm_menu,	
    mf.ordem_parametro                        as cd_filtro,
    mf.titulo_parametro                       as nm_filtro,
    na.ic_tipo_filtro,
    replace(mf.nome_parametro,'@','')         as nm_campo,
    cast('' as varchar)                       as nm_campo_descricao_lookup,
    cast('' as varchar)                       as nm_campo_chave_lookup,
    cast('' as varchar)                       as nm_tabela_lookup,
    cast('' as varchar)                       as nm_instrucao_sql,
    '='                                       as ic_tipo_operador,
    'S'                                       as ic_filtro_obrigatorio,
    @cd_usuario                               as cd_usuario,
    getdate()                                 as dt_usuario,
    na.cd_natureza_atributo,
    cast('' as varchar)                       as nm_parametro,
    cast('' as varchar)                       as nm_chave_lookup,
	case when editavel = 1 then 'S' 
	else 'N'
	end                                       as ic_editavel,
    mf.titulo_parametro                       as nm_edit_label,
    cast('' as varchar)                       as nm_mascara_atributo,
    cast('' as varchar)                       as cd_tipo_parametro,
    cast('0' as varchar)                      as cd_tipo_valor_padrao,
    case when valor_padrao = 'null' then
    cast('' as varchar(100))
    else
      isnull(valor_padrao,'')  
    end                                       as nm_valor_padrao,
    @cd_usuario                               as cd_usuario_inclusao,
    getdate()                                 as dt_usuario_inclusao,
    cast(0 as int )                           as cd_tabela,
    'N'                                       as ic_like,
    mf.ordem_parametro                        as cd_atributo,
        --mf.*,					             
	-------------------------------------------------------------------------------------------------
	replace(mf.nome_parametro,'@','')         as nm_atributo,

	na.nm_natureza_atributo,
    case when isnull(mf.valor_padrao,'')='null' then
    cast('' as varchar(500))
    else
	cast(isnull(mf.valor_padrao,'') as varchar(500))
    end                                      as nm_valor_editar,
    isnull(na.nm_datatype,'')                as nm_datatype,  
    isnull(na.nm_formato,'')                 as nm_formato,  
  
    case when na.cd_tipo_alinhamento = 1 then  
       'left'  
    else  
      case when na.cd_tipo_alinhamento = 2 then  
    'center'  
   else  
    'right'  
   end   
 end                                          as nm_tipo_alinhamento,

 nm_lookup_tabela = cast('' as varchar(1))

 --case when isnull(mf.nm_campo_chave_lookup,'')<>'' 
 --then
 --'Select ' + 
 -- mf.nm_campo_chave_lookup + ' as '+mf.nm_campo_chave_lookup +
 --  ', ' + 
 -- mf.nm_campo +' as ' +
 -- mf.nm_campo_descricao_lookup + ' from '+ mf.nm_tabela_lookup +' order by ' + mf.nm_campo
 -- else
 --   cast('' as varchar(10)) 
 -- end
  into
    #MenuFiltroProcedure

  from
    menu m
	inner join meta_procedure_parametros mf on mf.nome_procedure       = @nome_procedure
	left outer join natureza_atributo na    on na.nm_natureza_atributo = mf.tipo_parametro

  where
    m.cd_menu = @cd_menu
	and
	replace(mf.nome_parametro,'@','') <>'json'

	--select * from natureza_atributo

  order by
    mf.ordem_parametro

  if exists( select top 1 * from  #MenuFiltroProcedure )
  begin
    select * from  #MenuFiltroProcedure order by cd_atributo
	return
  end

	--
	--select * from meta_procedure_colunas
    --select * from meta_procedure_parametros
    --menu_filtro

   --return

end

-------------------------------------------------------------------------------------------------------------------

if @nome_procedure<>''
begin

  select
  
    --m.cd_menu,
	m.nm_menu_titulo,
	m.nm_menu,
    mf.*,
	-------------------------------------------------------------------------------------------------
	mf.nm_campo                             as nm_atributo,
	na.nm_natureza_atributo,
	cast('' as varchar(500))                as nm_valor_editar,
    isnull(na.nm_datatype,'')               as nm_datatype,  
    isnull(na.nm_formato,'')                as nm_formato,  
  
    case when na.cd_tipo_alinhamento = 1 then  
       'left'  
    else  
      case when na.cd_tipo_alinhamento = 2 then  
    'center'  
   else  
    'right'  
   end   
 end                                          as nm_tipo_alinhamento,
 nm_lookup_tabela = 
 case when isnull(mf.nm_campo_chave_lookup,'')<>'' 
 then
 'Select ' + 
  mf.nm_campo_chave_lookup + ' as '+mf.nm_campo_chave_lookup +
   ', ' + 
  mf.nm_campo +' as ' +
  mf.nm_campo_descricao_lookup + ' from '+ mf.nm_tabela_lookup +' order by ' + mf.nm_campo
  else
    cast('' as varchar(10)) 
  end

  --isnull(mf.ic_visivel_filtro,'S') AS ic_visivel_filtro

  --isnull(mf.ic_fixo_filtro,'N') as ic_fixo_filtro

  from
    menu m
    inner join menu_filtro mf       on mf.cd_menu              = m.cd_menu
	inner join natureza_atributo na on na.cd_natureza_atributo = mf.cd_natureza_atributo

  where
    m.cd_menu = @cd_menu

  order by
    mf.cd_filtro

  return

end


--Menu Filtro-----------------------------------------------------------------------------

if (@cd_parametro = 1 or @cd_parametro = 0) and isnull(@nome_procedure,'') = ''
begin

  select 
    --m.cd_menu,
	m.nm_menu_titulo,
	m.nm_menu,
    mf.*,
	-------------------------------------------------------------------------------------------------
	mf.nm_campo                             as nm_atributo,
	na.nm_natureza_atributo,
	cast('' as varchar(500))                as nm_valor_editar,
    isnull(na.nm_datatype,'')               as nm_datatype,  
    isnull(na.nm_formato,'')                as nm_formato,  
  
    case when na.cd_tipo_alinhamento = 1 then  
       'left'  
    else  
      case when na.cd_tipo_alinhamento = 2 then  
    'center'  
   else  
    'right'  
   end   
 end                                          as nm_tipo_alinhamento,
 nm_lookup_tabela = 
 case when isnull(mf.nm_campo_chave_lookup,'')<>'' 
 then
 'Select ' + 
  mf.nm_campo_chave_lookup + ' as '+mf.nm_campo_chave_lookup +
   ', ' + 
  mf.nm_campo +' as ' +
  mf.nm_campo_descricao_lookup + ' from '+ mf.nm_tabela_lookup +' order by ' + mf.nm_campo
  else
    cast('' as varchar(10)) 
  end


  --isnull(mf.ic_fixo_filtro,'N') as ic_fixo_filtro

  from
    menu m
    inner join menu_filtro mf       on mf.cd_menu              = m.cd_menu
	inner join natureza_atributo na on na.cd_natureza_atributo = mf.cd_natureza_atributo

  where
    m.cd_menu = @cd_menu

  order by
    mf.cd_filtro

end


go

--select *from atributo where cd_tabela = 492

--atributo--
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_gera_menu_filtro 
------------------------------------------------------------------------------
--exec pr_gera_menu_filtro '[{
--    "cd_parametro": 1,
--	"cd_menu": "6437",
--	"cd_usuario": 1,
--	"dt_inicial"  : "01/01/2025",
--	"dt_final"    : "12/31/2025"
--}]'

GO

--Select cd_estado as cd_estado, sg_estado as Estado from Estado order by sg_estado

--exec pr_gera_menu_filtro '[{
--	"cd_menu": "8292",
--	"cd_usuario": 1
--}]'

--go

--Lookup--
  --> Select nm_campo_chave_lookup, nm_campo as 'nm_campo_descricao_lookup' from nm_tabela_lookup order by nm_campo


--Tela

  