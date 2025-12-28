IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_pesquisa_filtro_selecao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_pesquisa_filtro_selecao

GO
--use egissql_rubio
--go

-------------------------------------------------------------------------------
--sp_helptext pr_egis_pesquisa_filtro_selecao
-------------------------------------------------------------------------------
--pr_egis_pesquisa_filtro_selecao
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Geração dos Parâmetros para edição de uma Tabela
--                   para Pesquisa Dinâmica
--                   Form que será aberto
--                 
--Data             : 20.02.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_pesquisa_filtro_selecao



@json                   nvarchar(max) = ''

as

set dateformat mdy


set @json         = replace(@json,'''','')       --Tratamento das Datas---------------

select                 
identity(int,1,1)                                                 as id,                 
    valores.[key] COLLATE SQL_Latin1_General_CP1_CI_AI            as campo,              
    valores.[value]                                               as valor --COLLATE SQL_Latin1_General_CP1_CI_AI               
into #json                
from                 
   openjson(@json)root                
   cross apply openjson(root.value) as valores 	

--select * from #json

declare @cd_parametro                      int = 0
declare @cd_empresa                        int = 0
declare @cd_usuario                        int = 0
declare @cd_tabela                         int = 0
declare @cd_modulo                         int = 0
declare @dt_inicial                        datetime 
declare @dt_final                          datetime 
declare @cd_menu                           int = 0
declare @cd_parametro_relatorio            int = 0
declare @sjonA                             nvarchar(max) = ''

----------------------------------------------------------------------------------------------------------    
set @cd_empresa = dbo.fn_empresa()
----------------------------------------------------------------------------------------------------------
select @cd_parametro	        = valor from #json  with(nolock) where campo = 'cd_parametro' 
select @cd_usuario   		    = valor from #json  with(nolock) where campo = 'cd_usuario'
select @dt_inicial   		    = valor from #json  with(nolock) where campo = 'dt_inicial'
select @dt_final   		        = valor from #json  with(nolock) where campo = 'dt_final'
select @cd_modulo	            = valor from #json  with(nolock) where campo = 'cd_modulo' 
select @cd_menu	                = valor from #json  with(nolock) where campo = 'cd_menu' 
select @cd_parametro_relatorio  = valor from #json  with(nolock) where campo = 'cd_parametro_relatorio'
select @cd_tabela	            = valor from #json  with(nolock) where campo = 'cd_tabela'
select @sjonA                   = valor from #json  with(nolock) where campo = 'sjonA'

----------------------------------------------------------------------------------------------------------
set @cd_tabela    = ISNULL(@cd_tabela,0)
set @cd_parametro = isnull(@cd_parametro,0)  --1-Edit  / 2-Pesquisa - Resultado

  ----------------------------------------------------------------------------------------------------------           

----Formatar Data
declare @cd_mes int = 0
declare @cd_ano int = 0

set @cd_ano = year(getdate())
set @cd_mes = month(getdate())

  --Início do Período

  if @dt_inicial is null 
    set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)  

	--Final do Periodo
  if @dt_final is null 
	set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano) 

-----------------------------------------------------------------------------------------------------------



--set @cd_usuario = ISNULL(@cd_usuario,0)

declare @sqlcolunas    nvarchar(max) = ''
declare @sqlComando    nvarchar(max) = ''
declare @nm_banco      varchar(200)  = ''
declare @sqlTabelas    nvarchar(max) = ''
declare @ic_chave_grid char(1)       = ''
declare @chave         varchar(60)   = ''

declare @nm_tabela_combo_box       nvarchar(max) = ''
declare @ic_chave_estrangeira      char(1) = ''
declare @ic_aliasadmin_combo_box   char(1) = ''
declare @nm_campo_chave_combo_box  nvarchar(max) = ''
declare @nm_campo_chave_origem     nvarchar(max) = ''
declare @nm_campo_mostra_combo_box nvarchar(max) = ''

declare @tabelas_estrangeiras      nvarchar(max) = ''
declare @nm_alias                  nvarchar(25) = 'EgisAdmin.dbo.' 
declare @ref                       nvarchar(65) = 'A'
declare @i                         int = 65
declare @campos_estrangeiros       nvarchar(max) = ''
declare @sqlwhere                  nvarchar(max) = ''
declare @nm_menu_titulo            varchar(100)  = ''
------------------------------------------------------
select @cd_empresa = dbo.fn_empresa()
------------------------------------------------------


if @cd_menu>0
begin
  select 
    @nm_menu_titulo = isnull(nm_menu_titulo,'')
  from
    egisadmin.dbo.menu 
  where
    cd_menu = @cd_menu

end

  select    
    top 1 
    @nm_banco   = isnull(nm_banco_empresa,'')    
  from    
    egisadmin.dbo.empresa                
   where    
    cd_empresa = @cd_empresa    

----------------------------------------------------

select
  identity(int,1,1)                        as cd_controle,
  tb.cd_tabela,
  tb.nm_tabela,
  isnull(tb.ic_sap_admin,'N') as ic_sap_admin,

  --Atributo--

  a.cd_atributo,
  a.nm_atributo,
  isnull(a.nu_ordem,0)                                   as nu_ordem,

  case when isnull(a.ic_atributo_obrigatorio,'N') = 'S' then
      case when isnull(a.nm_atributo_consulta,'') <>'' then
	    isnull(a.nm_atributo_consulta,'') --+'*' 
      else
	    isnull(a.nm_atributo,'') --+'*'
	  end
   
  else
      case when isnull(a.nm_atributo_consulta,'') <>'' then
	    isnull(a.nm_atributo_consulta,'') 
      else
	    isnull(a.nm_atributo,'') 
	 
      end
  end                                                               as nm_apresenta_atributo,  
    isnull(a.nm_mascara_atributo,'')        as nm_mascara_atributo,  
    isnull(a.ic_total_grid,'N')             as ic_total_grid,  
    isnull(a.ic_atributo_chave,'N')         as ic_chave_grid,  
    isnull(na.nm_natureza_atributo,'')      as nm_natureza_atributo,  
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
 isnull(a.ic_contador_grid,'N')               as ic_contador_grid,  
 'N'                                          as ic_grafico_eixo_x,  
 'N'                                          as ic_grafico_eixo_y,  
 isnull(a.ic_mostra_grid,'S')                 as ic_mostra_grid,  
 cast(0 as int)                               as cd_tipo_consulta,  
 isnull(a.ic_edita_cadastro,'N')              as ic_edita_cadastro,  
 isnull(a.ic_titulo_total_grid,'N')           as ic_titulo_total_grid,  
 isnull(a.ic_chave_estrangeira,'N')           as ic_chave_estrangeira,  
 isnull(a.ic_combo_box,'N')                   as ic_combo_box,  
 isnull(a.ic_boolean,'N')                     as ic_boolean,
 isnull(a.nm_campo_chave_combo_box,'')        as nm_campo_chave_combo_box,  
 isnull(a.nm_campo_mostra_combo_box,'')       as nm_campo_mostra_combo_box,  
 isnull(a.nm_tabela_combo_box,'')             as nm_tabela_combo_box,  
 isnull(a.nm_dado_padrao_atributo,'')         as nm_dado_padrao_atributo,  
 isnull(a.ic_data_padrao,'')                  as ic_data_padrao,  
 isnull(a.ic_aliasadmin_combo_box,'N')        as ic_aliasadmin_combo_box,
 isnull(a.nm_atributo,'')                     as nm_campo_chave_origem,
 cast(0 as int)                               as cd_atributo_banda,  
 cast('' as varchar(60))                      as nm_banda,  
 isnull(a.ic_doc_caminho_atributo,'N')        as ic_doc_caminho_atributo,  
 'N'                                          as ic_card,
 isnull(a.ic_edita_pesquisa_atributo,'N')     as ic_edita_pesquisa_atributo,
 isnull(a.ic_resultado_pesquisa_atributo,'N') as ic_resultado_pesquisa_atributo,
 @nm_menu_titulo                              as nm_menu_titulo

 ----------------------------------------------------------------------------------------------------------------
 

into 
  #AuxForm

from 
  egisadmin.dbo.tabela tb     

  
  left outer join egisadmin.dbo.atributo a                  on  a.cd_tabela     = tb.cd_tabela          
                                                  
												    
  left outer join egisadmin.dbo.natureza_atributo na on na.cd_natureza_atributo = a.cd_natureza_atributo 
  
where
  tb.cd_tabela = @cd_tabela 
  and
  isnull(a.cd_atributo,0)>0
  and
  ISNULL(a.ic_filtro_selecao,'N')='S'

order by
   a.cd_atributo

--Configuração dos Atributos--
--update egisadmin.dbo.atributo set ic_filtro_selecao='S' where cd_tabela = 1367 and cd_atributo = 2
---------------------------


--Apresenta os Atributos para Gerar o Edit Dinâmico------------------------------------------------------------------------

--select * from #AuxForm

---------------------------------------------------
if @cd_parametro=1
begin
  select
    cd_controle, cd_tabela, nm_tabela, nm_apresenta_atributo, cast('' as varchar(100)) as nm_valor_editar,
    nm_atributo, nm_natureza_atributo, nm_datatype, nm_menu_titulo as nm_titulo
  from
    #AuxForm
  order by
    nu_ordem

  return

end

-----------------------------------------------------------------------------------------------------------------------------------------------------


--Receber o Json com os parâmetros Digitados---

if @cd_parametro = 2
begin
   --   select @cd_tipo				        = valor from #json  with(nolock) where campo = 'cd_tipo'
  
   --select * from #json  with(nolock) 

  if (@cd_tabela = 0) or (@cd_tabela is null)    
  begin    
    select 
      1 as cd_usuario, 
      getdate() as dt_usuario, 
      '' as nm_usuario, 
      cast('N' as char(1)) as ic_selecao, 
      0 as cd_controle, 
      0 as cd_documento,
      0 as cd_coluna1,
      '' as nm_coluna2

    return    

  end

	print 'Passou nas váriaveis recebidas'

	--Definir na tabela de Atributo o Tipo de Where
	--like, =, >=, =<, >, <, etcc...

	 

    select
	  id                                                                                  as cd_form_filtro, 
	  ltrim(rtrim(campo)) + ' like ' +''''+'%'+LTRIM(rtrim(valor))+'%'+''''               as nm_where_filtro,  
	  * 
	  into #filtro 
	  from #json
	
	where
	  ISNULL(valor,'')<>''

    order by
	  id

	  --select * from #json
	  --select * from #filtro

	--select * from #filtro

    declare @cd_form_filtro int = 0

    if exists( select top 1 cd_form_filtro from #filtro )
    begin
      
	  set @sqlwhere = ''

      while exists( select top 1 cd_form_filtro from #filtro ) and 1=2
      begin
        select top 1 
   	       @cd_form_filtro = cd_form_filtro,
 	       @sqlwhere       = @sqlwhere + case when @sqlwhere<>'' then ' and ' else '' end
	                       + isnull(cast(nm_where_filtro as nvarchar(max)),'')
        from
	      #filtro


	delete from #filtro
	where
	  cd_form_filtro = @cd_form_filtro

  end

end

 set @sqlwhere = replace(replace(@sqlwhere,'@dt_inicial', ''''+FORMAT(@dt_inicial, 'MM/dd/yyyy')+''''),'@dt_final', ''''+format(@dt_final,'MM/dd/yyyy')+'''')

--select @sqlwhere

--select ic_chave_grid,* from #AuxForm



end


--Gravação da Tabela de Filtro para uso nas procedures-------------------------------------------------

if @cd_parametro = 3
begin

  set @sjonA         = replace(@sjonA,'''','')       --Tratamento das Datas---------------

  select                 
  identity(int,1,1)                                               as id,                 
    valores.[key] COLLATE SQL_Latin1_General_CP1_CI_AI            as campo,              
    valores.[value]                                               as valor --COLLATE SQL_Latin1_General_CP1_CI_AI               
  into #sjonA                
  from                 
   openjson(@sjonA)root                
   cross apply openjson(root.value) as valores 	

   --select * from #sjonA


  --
  --select * from #json

  declare @cd_filtro_selecao int

  select
    @cd_filtro_selecao = MAX(cd_filtro_selecao) 
  from
    Filtro_Selecao

  set @cd_filtro_selecao = ISNULL(@cd_filtro_selecao,0) + 1


  --filtro_selecao

  select 
    @cd_filtro_selecao      as cd_filtro_selecao,
    @cd_tabela              as cd_tabela,
    cast(valor as int )     as cd_chave_filtro,
    @cd_parametro_relatorio as cd_parametro_relatorio,
    @cd_menu                as cd_menu,
    @cd_modulo              as cd_modulo,
    @cd_usuario             as cd_usuario_inclusao,
    getdate()               as dt_usuario_inclusao,
    @cd_usuario             as cd_usuario,
    getdate()               as dt_usuario,
	IDENTITY(int,1,1)       as cd_interface

  into
    #Filtro_Selecao

  from
    #sjonA j
	inner join #AuxForm a on a.cd_tabela = @cd_tabela and campo = a.nm_atributo

  where 
    a.ic_chave_grid = 'S'


  delete from Filtro_Selecao
  where
    cd_usuario = @cd_usuario
	and
	cd_modulo  = @cd_modulo
	and
	cd_menu    = @cd_menu
	and
	cd_parametro_relatorio = @cd_parametro_relatorio

 
  update
    #Filtro_Selecao
  set
    cd_filtro_selecao = cd_filtro_selecao + cd_interface

  insert into Filtro_Selecao
  select * from #Filtro_Selecao
  
  --select * from #Filtro_Selecao
  --select * from Filtro_Selecao

     
  return

end 


-------------------------------------------------------------Apresentação dos Dados------------------------------------------------------------------



declare @cd_controle          int          = 0
declare @nm_atributo          varchar(200) = ''
declare @nm_tabsheet_atributo varchar(200) = ''
declare @ic_sap_admin         char(1)       = 'N'

set @sqlColunas = 'tab.cd_usuario, tab.dt_usuario, usu.nm_usuario, ic_selecao = cast(''N'' as char(1)) '

while exists ( select top 1 cd_controle from #AuxForm )
begin

  select top 1 
    @cd_controle          = cd_controle,
	@nm_atributo          = nm_atributo,

    @nm_tabela_combo_box       = nm_tabela_combo_box,
    @ic_chave_estrangeira      = ic_chave_estrangeira,
    @ic_aliasadmin_combo_box   = ic_aliasadmin_combo_box,
    @nm_campo_chave_combo_box  = nm_campo_chave_combo_box,
    @nm_campo_chave_origem     = nm_campo_chave_origem,
    @nm_campo_mostra_combo_box = nm_campo_mostra_combo_box,

	@sqlTabelas           = nm_tabela+' as tab',
	--@nm_tabsheet_atributo = nm_tabsheet_atributo,
	@ic_chave_grid        = ic_chave_grid,
	@chave                = case when ic_chave_grid = 'S' and @chave = '' then nm_atributo else @chave end,
    @ic_sap_admin         = ic_sap_admin,
	@nm_banco             = case when ic_sap_admin='S' then 'EgisAdmin' else @nm_banco end


  from
    #AuxForm


  order by
    cd_controle


	   set @ref = ' '+ CHAR(@i) 

------------------------------------------

   if @nm_tabela_combo_box<>'' and @ic_chave_estrangeira='S'
   begin

     -- select @nm_tabela_combo_box, @nm_campo_chave_combo_box, @nm_campo_chave_origem


     set @tabelas_estrangeiras = @tabelas_estrangeiras +      
                                'left outer join '     +    

           case when @ic_aliasadmin_combo_box = 'S' then    
              @nm_alias    
                                      else    
              @nm_banco
			  		                                   +
		   '.dbo.'    

           end    
           +    
           @nm_tabela_combo_box     
           +
		   ' '
		   +
           @ref    
           +    
           ' on '+ @ref+'.'+ @nm_campo_chave_combo_box + ' = tab.' + @nm_campo_chave_origem    
           +     
           ' '    

           --select @nm_campo_chave_combo_box
   
          if @nm_campo_mostra_combo_box <>''
		  begin

            set @campos_estrangeiros = @campos_estrangeiros     
                               +    
            ', '    
                               +     
            --@ref+'.'              
            --+    
            --@nm_datafield    
			@ref + '.' +
            @nm_campo_mostra_combo_box 
			--+ ' as '+@ref+'_'+ @nm_campo_mostra_combo_box
		  
		  end

          set @i = @i + 1    

   end

   --select @tabelas_estrangeiras, @campos_estrangeiros
------------------------------------------

  set @sqlColunas = @sqlColunas
                    + case when @sqlColunas <>'' then ', ' else cast('' as char(1)) end
                    +
					'tab.'+isnull(@nm_atributo,'')
					+
					case when @ic_chave_grid='S'
					then
					  ' as '+''''+'cd_controle'+''''
					else
					  CAST('' as char(1)) 
					end --+ ' as '+''''+@nm_tabsheet_atributo+''''
  
  if @ic_chave_grid='S'
  begin
    set @sqlColunas = @sqlColunas
                    + case when @sqlColunas <>'' then ', ' else cast('' as char(1)) end
                    + 
					'tab.'+isnull(@nm_atributo,'')
					+
					case when @ic_chave_grid='S'
					then
					  ' as '+''''+'cd_documento'+''''
					else
					  CAST('' as char(1)) 
					end --+ ' as '+''''+@nm_tabsheet_atributo+''''
	  set @sqlColunas = @sqlColunas
                    + case when @sqlColunas <>'' then ', ' else cast('' as char(1)) end
                    + 
					'tab.'+isnull(@nm_atributo,'')
				

  end

  delete from #AuxForm
  where
    cd_controle = @cd_controle
    
end

set @sqlTabelas = @sqlTabelas + ' left outer join egisadmin.dbo.Usuario usu on usu.cd_usuario = tab.cd_usuario'

--Comando SQL--
set @sqlComando = 'select '+@sqlcolunas+ isnull(@campos_estrangeiros,'') + ' from '+ @nm_banco+'.dbo.' + @sqlTabelas  +' '+ isnull(@tabelas_estrangeiras,'') 
                  +
				  --Filtros--
				  case when ISNULL(@sqlwhere,'')<>'' then 'Where '+@sqlwhere else CAST('' as varchar(1)) end

				  ----------------------------------------------------------------------------------
--select @sqlComando
--select @sqlColunas

------------------------------------------------------------------------------------------------------
EXEC sp_executesql @sqlComando
------------------------------------------------------------------------------------------------------

-- if @ic_tipo_atributo = '9' and @nm_resultado_select <> ''
  -- begin
  --   --set @sqlresultado = @nm_resultado_select
  --    SET @ParamDefinition = N'@sqljsonresultado nvarchar(max) OUTPUT';    
  
  --    EXEC sp_executesql @nm_resultado_select, @ParamDefinition, @sqljsonresultado=@sqljsonresultado OUTPUT    


go

--use EGISADMIN
--select * from atributo where cd_tabela = 148
--1,3,23
--go
--update
--   Atributo
--set
--ic_edita_pesquisa_atributo      = 'S',
--ic_resultado_pesquisa_atributo  = 'S'
--where
--  cd_tabela = 148
--  and
--  cd_atributo in (2, 1,3,23 )
----@cd_modulo              int = 0,
----@cd_menu                int = 0,
----@cd_parametro_relatorio int = 0,
----@cd_tabela              int           = 0,
----@cd_parametro           int           = 0,   --1-Edit  / 2-Pesquisa - Resultado
----@json                   nvarchar(max) = '',
----@dt_inicial             datetime = null,
----@dt_final               datetime = null


--Configuração dos Atributos--
--update egisadmin.dbo.atributo set ic_filtro_selecao='S' where cd_tabela = 1448 and cd_atributo in (1,2)
---------------------------


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------

/*

exec pr_egis_pesquisa_filtro_selecao '[{"cd_tabela":1448,"cd_parametro":1,"cd_usuario":1} ]'
exec pr_egis_pesquisa_filtro_selecao '[{"cd_menu": 8291, "cd_tabela":1448,"cd_parametro":2,"cd_usuario":1} ]'

--Grava a Tabela de Filtro_Selecao

exec pr_egis_pesquisa_filtro_selecao '
[
    {
        "cd_parametro": 3,
        "cd_tabela": 1448,
        "cd_usuario": 113,
        "cd_menu": 8134,
        "cd_modulo": 0,
        "cd_parametro_relatorio": 0,
        "ic_json_parametro": "S",
        "sjonA": [
            {
                "cd_motivo_retirada_caixa": 1
            },
            {
                "cd_motivo_retirada_caixa": 6
            }
        ]
    }
]
'

--delete from filtro_selecao
select * from filtro_selecao


select * from Motivo_Retirada_caixa where cd_motivo_retirada_caixa in ( select cd_chave_filtro from Filtro_selecao where cd_chave_filtro = cd_motivo_retirada_caixa )



*/

--
--Atributos do Select para Seleção do Filtro
--exec pr_egis_pesquisa_filtro_selecao '[{"cd_modulo": 0,"cd_menu": 8134, "cd_parametro_relatorio":0,"cd_tabela":141,"cd_parametro":1,"cd_usuario":1} ]'
--exec pr_egis_pesquisa_filtro_selecao '[{"cd_tabela":141,"cd_parametro":2,"cd_usuario":1} ]'
go

--select * from Filtro_Selecao
--go

--exec pr_egis_pesquisa_filtro_selecao '
--[
--    {
--        "cd_parametro": 3,
--        "cd_tabela": 141,
--        "cd_usuario": 113,
--        "cd_menu": 8134,
--        "cd_modulo": 0,
--        "cd_parametro_relatorio": 0,
--        "ic_json_parametro": "S",
--        "sjonA": [
--            {
--                "cd_vendedor": 5
--            },
--            {
--                "cd_vendedor": 6
--            },
--            {
--                "cd_vendedor": 7
--            },
--            {
--                "cd_vendedor": 8
--            }
--        ]
--    }
--]
--'


--select * from Filtro_Selecao

--@cd_modulo              int = 0,
--@cd_menu                int = 0,
--@cd_parametro_relatorio int = 0,
--@cd_tabela              int           = 0,
--@cd_parametro           int           = 0,   --1-Edit  / 2-Pesquisa - Resultado
--@json                   nvarchar(max) = '',
--@dt_inicial             datetime = null,
--@dt_final               datetime = null,
--@cd_usuario             int      = 0
--0,0,0,141,1,'{}',null,null
------------------------------------------------------------------------------
--Select
--exec pr_egis_pesquisa_filtro_selecao 0,0,0,141,2,'{}',null,null
------------------------------------------------------------------------------
--Grava o Filtro
--Receber o Json os filtros selecionados
--exec pr_egis_pesquisa_filtro_selecao 0,0,0,141,3,'[{"cd_vendedor": "4", "nm_fantasia_vendedor": "HARLEM"},{"cd_vendedor": "10", "nm_fantasia_vendedor": "vanessa"},
--                                                  {"cd_vendedor": "8", "nm_fantasia_vendedor": "Ricardo"}]',null,null, 1
------------------------------------------------------------------------------

--update
--  egisadmin.dbo.atributo
--set
--  ic_filtro_selecao = 'S'
--WHERE
--  cd_tabela = 141

--  and

--  cd_atributo in (1,3)

--select * from Filtro_Selecao


--select * from Vendedor where cd_vendedor in ( select cd_chave_filtro from Filtro_selecao where cd_chave_filtro = cd_vendedor )
