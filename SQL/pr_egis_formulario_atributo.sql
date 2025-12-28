USE EGISADMIN
GO

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_formulario_atributo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_formulario_atributo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_formulario_atributo
-------------------------------------------------------------------------------
--pr_egis_formulario_atributo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2021
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Montagem do Formulário de Atributos
--
--Data             : 18.11.2021
--Alteração        : 
--
-- 21.06.2024 - ícones - Carlos/Alexandre
-- 25.06.2024 - novos atributos - Carlos 
-- 26.06.2024 - ajustes diversos - alexandre/Carlos
-- 29.06.2024 - A consulta com os daados da Tabela - Carlos Fernandes
------------------------------------------------------------------------------
create procedure pr_egis_formulario_atributo
 
@json nvarchar(max) = ''  
  
--@cd_empresa        int  = 0,  
--@cd_parametro      int  = 0,  
--@cd_documento      int  = 0,  
--@cd_item_documento int  = 0  
  
--with encryption  
  
  
as  
  
declare @cd_empresa        int  
declare @cd_parametro      int  
declare @cd_documento      int = 0  
declare @cd_item_documento int  
declare @cd_cliente        int  
declare @cd_relatorio      int   
declare @cd_usuario        int   
declare @cd_form           int = 0
declare @cd_menu           int = 0

set @cd_empresa        = 0  
set @cd_menu            = 0
set @cd_parametro      = 0  
set @cd_documento      = 0  
set @cd_relatorio      = 0  
set @cd_item_documento = 0  
set @cd_cliente        = 0  
  
--tabela  
--select ic_sap_admin, * from Tabela where cd_tabela = 5287  
  
select                       
  
 1                                                    as id_registro,  
 IDENTITY(int,1,1)                                    as id,  
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                       
 valores.[value]              as valor                      
                      
 into #json                      
 from                  
   openjson(@json)root                      
   cross apply openjson(root.value) as valores        
  
select @cd_empresa             = valor from #json where campo = 'cd_empresa'               
select @cd_documento           = valor from #json where campo = 'cd_documento'  
select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'  
select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'  
select @cd_parametro           = valor from #json where campo = 'cd_parametro'            
select @cd_cliente             = valor from #json where campo = 'cd_cliente'            
select @cd_usuario             = valor from #json where campo = 'cd_usuario'  
select @cd_menu                = valor from #json where campo = 'cd_menu'  
select @cd_form                = valor from #json where campo = 'cd_form'  

set @cd_documento = ISNULL(@cd_documento,0)  
---------------------------------------------------------------------------------------------------------------  

--select * from #json

  
--select @cd_documento  
  
--select @dt_usuario             = valor from #json where campo = 'dt_usuario'  
  
  
  
--set @cd_empresa        = isnull(@cd_empresa,0)  
--set @cd_parametro      = isnull(@cd_parametro,0)  
--set @cd_documento      = isnull(@cd_documento,0)  
--set @cd_item_documento = isnull(@cd_item_documento,0)  
  
---------------------------------------------------------------------------------------------------  
  
declare @dt_hoje          datetime  
declare @ParamDefinition  nvarchar(100)       
declare @nm_banco         varchar(100)      
  
set @cd_form = isnull(@cd_parametro,0)  
set @dt_hoje            = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)          
  
--select @cd_form  
  
declare @nm_datafield              varchar(120)   --      
declare @nm_caption                varchar(120)   --      
declare @nm_datatype               varchar(120)  
declare @nm_tamanho                varchar(10)      
declare @nm_alinhamento            varchar(30)      
declare @nm_formato                varchar(30)      
declare @nm_lookup                 nvarchar(max) = ''    
declare @nm_resultado_lookup       nvarchar(max) = ''  
declare @nm_resultado_select       nvarchar(max) = ''  
declare @chave                     varchar(60)   = ''  
declare @resultado                 nvarchar(max)      
declare @labelForm                 nvarchar(max)      
declare @labelFormFiltro           nvarchar(max)      
declare @valoresFiltro             nvarchar(max)      
declare @paramsFiltro              nvarchar(max)      
declare @tituloColuna              nvarchar(max)      
declare @tituloColunaF             nvarchar(max)      
declare @tituloCard                nvarchar(max)      
declare @colunaFiltro              nvarchar(max)      
declare @valorPadrao               nvarchar(max)      
declare @grafico                   nvarchar(max)      
declare @nm_template               varchar(200)      
declare @total_itens               nvarchar(max)      
declare @grupo_itens               nvarchar(max)      
declare @tabsheet                  nvarchar(max)      
declare @ic_total_grid             char(1)      
declare @ic_contador_grid          char(1)      
declare @ic_grafico_eixo_x         char(1)      
declare @ic_grafico_eixo_y         char(1)            
declare @ic_mostra_grid            char(1)      
declare @cd_tipo_consulta          int      
declare @ic_edita_cadastro         char(1)      
declare @ic_titulo_total_grid      char(1)      
declare @nm_apresenta_atributo     varchar(80)      
declare @ic_chave_grid             char(1)      
declare @ic_chave_estrangeira      char(1)      
declare @ic_combo_box              char(1)      
declare @ic_boolean                char(1)      
declare @sqlcombox                 nvarchar(max) = ''      
declare @sqljsoncombox             nvarchar(max) = ''  
declare @sqlresultado              nvarchar(max) = ''  
declare @sqljsonresultado          nvarchar(max) = ''  
declare @nm_campo_chave_combo_box  varchar(120)      
declare @nm_campo_mostra_combo_box varchar(120)      
declare @nm_tabela_combo_box       varchar(120) = ''      
declare @nm_dado_padrao_atributo   varchar(60)      
declare @ic_data_padrao            char(1)      
declare @cd_banda                  int      
declare @nm_banda                  varchar(60)      
declare @cd_banda_atributo         int      
declare @campoDocumento            varchar(80)      
declare @ic_doc_caminho_atributo   char(1)      
declare @ic_card                   char(1)     
declare @ic_lookup                 char(1)  
declare @ic_coluna_fixa            char(1)  
declare @ic_composto_lookup        char(1)  
declare @nm_where_lookup           nvarchar(max) = ''  
declare @ic_tipo_atributo          char(1)       = ''  
declare @ic_sap_admin              char(1)       = 'N'  
declare @ic_lista_valor            char(1)       = 'N'  
declare @cd_natureza_atributo      int  
declare @cd_tabela_pesquisa        int  
--Outros campos do select  
declare @sqlOutrosCampos nvarchar(max) = ''  
declare @sqlOutrosCamposIntermediaria nvarchar(max) = ''  
declare @listaAtributosLookup nvarchar(max) = ''  
declare @nm_dados_info_lookup nvarchar(max) = ''  
  
  
set @ic_doc_caminho_atributo   = 'N'      
set @grupo_itens               = ''      
set @total_itens               = ''        
set @resultado                 = ''      
set @labelForm                 = ''      
set @labelFormFiltro           = ''      
set @valoresFiltro             = ''      
set @paramsFiltro              = ''      
set @valorPadrao               = ''      
set @tabsheet                  = ''      
set @grafico                   = ''      
set @chave                     = ''      
set @ic_total_grid             = 'N'      
set @ic_contador_grid          = 'N'      
set @ic_grafico_eixo_x         = 'N'      
set @ic_grafico_eixo_y         = 'N'      
set @ic_mostra_grid            = 'S'      
set @cd_tipo_consulta          = 0      
set @ic_edita_cadastro         = 'N'      
set @ic_titulo_total_grid      = 'S'      
set @tituloColuna              = ''      
set @tituloColunaF             = ''  
set @tituloCard                = ''      
set @colunaFiltro              = ''      
set @nm_apresenta_atributo     = ''      
set @ic_chave_grid             = ''      
set @ic_chave_estrangeira      = ''      
set @ic_combo_box              = ''      
set @ic_boolean                = 'N'      
set @sqlcombox                 = ''      
set @sqlresultado              = ''  
set @nm_campo_chave_combo_box  = ''      
set @nm_campo_mostra_combo_box = ''      
set @nm_tabela_combo_box       = ''      
set @sqljsoncombox             = ''      
set @sqljsonresultado          = ''  
set @nm_dado_padrao_atributo   = ''      
set @ic_data_padrao            = ''      
set @nm_banda                  = ''      
set @cd_banda                  = 0      
set @campoDocumento            = ''     
set @ic_lookup                 = 'N'  
set @ic_coluna_fixa            = 'N'  
set @ic_composto_lookup        = 'N'      
set @nm_banco                  = ''      
set @nm_where_lookup           = ''  
set @ic_lista_valor            = 'N'  
set @cd_natureza_atributo      = 0  
set @cd_tabela_pesquisa        = 0  
  
---------------------------------------------------------------------------------------------------------------------      
--Banco do Cliente--      
---------------------------------------------------------------------------------------------------------------------      
      
--  declare @nm_banco varchar(100)      
     
  select        
    top 1     
    --@nm_banco   = isnull(nm_banco_empresa,'')        
    @nm_banco = case when isnull(ec.serversql,'') = '' then isnull(e.nm_banco_empresa,'')   
                        else  
           '['+ isnull(ec.serversql,'') + '].' + isnull(e.nm_banco_empresa,'')  
         end  
  from        
    egisadmin.dbo.empresa e  
    left outer join Empresa_Conexao ec on ec.cd_empresa = e.cd_empresa   
   where        
    e.cd_empresa = @cd_empresa           
      
---------------------------------------------------------------------------------------------------------------------      
  
   declare @nm_alias                 varchar(80)      
   declare @ref                      varchar(10)      
   declare @i                        int      
   declare @tabelas_estrangeiras     nvarchar(max) = ''  
   declare @ic_aliasadmin_combo_box  char(1)  
   declare @nm_campo_chave_origem    varchar(50)  
   declare @campos_estrangeiros      nvarchar(max)  
   declare @cWhere                   nvarchar(max)  
   declare @sSQL                     nvarchar(max)  
   declare @sOrderby                 nvarchar(max)  
   declare @sTabela                  nvarchar(max) = ''  
   declare @nm_valor_inicial         nvarchar(max) = ''  
   declare @nm_valor_lookup          nvarchar(max)  
   declare @sqlcampos                nvarchar(max)  
   declare @sqlcampospivot           nvarchar(max)  
   declare @cd_tabela                int  
   declare @cd_atributo              int  
  
   --declare @cWhere                   nvarchar(max)  
  
   set @nm_alias                 = 'EgisAdmin.dbo.'      
   set @i                        = 65      
   set @ref                      = 'A'      
   set @tabelas_estrangeiras     = ''  
   set @ic_aliasadmin_combo_box  = 'N'  
   set @nm_campo_chave_origem    = ''  
   set @campos_estrangeiros      = ''  
   set @cWhere                   = ''  
   set @sSQL                     = ''  
   set @sOrderby                 = ''  
   set @sTabela                  = ''  
   set @nm_valor_inicial         = ''  
   set @nm_valor_lookup          = ''  
   set @sqlcampospivot           = ''  
   set @sqlcampos                = ''  
   set @cd_tabela                = 0  
   set @cd_atributo              = 0  
  
---------------------------------------------------------------------------------------------------------------------      
  
  
--select * from form_tabsheet  
--select * from egissql_340.dbo.pedido_venda where cd_pedido_venda = 80147  
--select * from form where cd_form = @cd_form  
  
--select @nm_alias, @nm_banco  
--return  
  
--17.03.2025 ( Carlos & Fabiano )  
--Temos que agora fazer um lógica para se Dinâmico  
--( sql no cadastro do Atributo - a condição de troca )  
--( nvarchar(max), e fazer um json, para fazer o exec...  


--Verifica se o Form está zerado--------------------------------------------------------------

if @cd_form=0 and @cd_menu>0
begin
  select
    top 1
    @cd_form = ISNULL(f.cd_form,0)
  from
    EGISADMIN.dbo.Form f
  where
    f.cd_menu = @cd_menu
end

if @cd_form=0
begin
  select 'Form não localizado !' as msg
  return
end
  
--Perfil de Cliente-------------------------------------------------------------------------  
  
if @cd_form = 155  
begin  
  declare @sqltrocadocumento  nvarchar(max) = ''  
  set @sqltrocadocumento = 'set @jsonr = (select top 1 cd_cliente from '+@nm_banco+'.dbo.'+'Pedido_Venda' +  
                           ' where cd_pedido_venda = '+CAST(@cd_documento as varchar(20))  
         +' )'  
    
  declare @DocResult nvarchar(max) = ''  
  
    exec sp_executesql @sqltrocadocumento, N'@jsonr NVARCHAR(MAX) OUTPUT' , @jsonr=@DocResult OUTPUT;  
  
 --select @sqltrocadocumento, @DocResult  
   
 set @cd_documento = CAST(@DocResult as int )  
  
 --select @cd_documento  
  
  --select  
  --  @cd_documento = ISNULL(cd_cliente,0)  
-- from  
   
    
end  
------------------------------------------------------------------------------------------------------------------------  
  
  
select  
  identity(int,1,1)                        as cd_controle,  
  --------------------------------------------------------  
  f.*,  
  ft.cd_tabsheet,  
  ts.nm_tabsheet,  
  isnull(ft.cd_api,0)         as cd_api_tabsheet,  
  isnull(ft.cd_menu,0)        as cd_menu_tabsheet,  
  tb.cd_tabela,  
  tb.nm_tabela,  
  isnull(tb.ic_sap_admin,'N') as ic_sap_admin,  
  --Tabela do Atributo---  
  
  isnull(fta.cd_tabela,0)     as cd_tabela_atributo,  
  isnull(tfta.nm_tabela,'')   as nm_tabela_atributo,  
  
  
  --Atributo--  
  
  a.cd_atributo,  
  a.nm_atributo,  
  fta.nm_tabsheet_atributo,   
  fta.ic_tipo_atributo,  
  fta.cd_api as cd_api_atributo,  
  ac.nm_api_busca as nm_api_busca,  
  isnull(ap.ic_procedimento_crud,'N') as ic_api_post_atributo,  
  isnull((select cd_item,nm_parametro,cd_natureza_atributo from api_parametros_composicao apc where apc.cd_api = fta.cd_api FOR JSON AUTO),'') as nm_api_parametros,  
  ap.cd_tabela                      as cd_api_tabela_atributo,  
  tabapi.nm_tabela                  as nm_api_tabela,  
  ap.cd_procedimento                as cd_api_procedimento_atributo,  
  papi.nm_sql_procedimento          as nm_api_sql_procedimento,  
  isnull(fta.vl_padrao_atributo,'') as vl_padrao_atributo,  
  fta.nm_icone_atributo,  
  fta.qt_ordem_atributo,  
  --1 consulta/mostra em azul  
  --2 editável  
  --3 editável com Lookup  
  --4  
  
  isnull(fta.ic_pesquisa,'N')            as ic_pesquisa,  
  isnull(fta.ic_cadastro,'N')            as ic_cadastro,  
  isnull(fta.ic_habilitado_atributo,'S') as ic_habilitado_atributo,  
  isnull(fta.ic_composto_lookup,'N')     as ic_composto_lookup,  
  isnull(fta.ic_data_hoje,'N')           as ic_data_hoje,  
  isnull(fta.ic_chave_incremento,'N')    as ic_chave_incremento,  
  isnull(fta.nm_where_lookup,'')         as nm_where_lookup,  
  isnull(fta.nm_resultado_select,'')     as nm_resultado_select,  
  isnull(fta.cd_form_especial,0)         as cd_form_especial,  
  isnull(fta.cd_tipo_codigo,0)           as cd_tipo_codigo,  
  isnull(fta.ic_hora_atributo,'N')       as ic_hora_atributo,  
  isnull(fta.ic_painel_form,'N')         as ic_painel_form,  
  isnull(fta.cd_rota,0)                  as cd_rota_form,  
  isnull(fta.nm_pasta_ftp,'')            as nm_pasta_ftp_atributo,  
  isnull(fta.cd_tabela_pesquisa,0)       as cd_tabela_pesquisa,  
  isnull(fta.ic_info_lookup,'N')         as ic_info_lookup,  
  
  case when isnull(a.ic_atributo_obrigatorio,'N') = 'S' then  
    case when isnull(fta.nm_tabsheet_atributo,'')<>'' and fta.nm_tabsheet_atributo<>a.nm_atributo_consulta then  
      fta.nm_tabsheet_atributo+'*'  
    else  
      case when isnull(a.nm_atributo_consulta,'') <>'' then  
     isnull(a.nm_atributo_consulta,'')+'*'   
      else  
     isnull(a.nm_atributo,'')+'*'  
   end  
    end    
  else  
      case when isnull(fta.nm_tabsheet_atributo,'')<>'' and fta.nm_tabsheet_atributo<>a.nm_atributo_consulta then  
      fta.nm_tabsheet_atributo  
    else  
      case when isnull(a.nm_atributo_consulta,'') <>'' then  
     isnull(a.nm_atributo_consulta,'')   
    else  
   isnull(a.nm_atributo,'')   
 end  
    end end as nm_apresenta_atributo,    
    isnull(a.nm_mascara_atributo,'')        as nm_mascara_atributo,    
    isnull(a.ic_total_grid,'N')             as ic_total_grid,    
    isnull(a.ic_atributo_chave,'N')         as ic_chave_grid,    
 na.cd_natureza_atributo                 as cd_natureza_atributo,  
    isnull(na.nm_natureza_atributo,'')      as nm_natureza_atributo,    
    case when isnull(fta.ic_hora_atributo,'N') = 'S' then 'time' else isnull(na.nm_datatype,'') end as nm_datatype,  
    isnull(na.nm_formato,'')                as nm_formato,    
    
    case when na.cd_tipo_alinhamento = 1 then    
       'left'    
    else    
      case when na.cd_tipo_alinhamento = 2 then    
    'center'    
   else    
    'right'    
   end    
 end                                     as nm_tipo_alinhamento,    
 isnull(a.ic_contador_grid,'N')          as ic_contador_grid,    
 'N'                                     as ic_grafico_eixo_x,    
 'N'                                     as ic_grafico_eixo_y,    
 isnull(a.ic_mostra_grid,'S')            as ic_mostra_grid,    
 cast(0 as int)                          as cd_tipo_consulta,    
 isnull(a.ic_edita_cadastro,'N')         as ic_edita_cadastro,    
 isnull(a.ic_titulo_total_grid,'N')      as ic_titulo_total_grid,    
 isnull(a.ic_chave_estrangeira,'N')      as ic_chave_estrangeira,    
 isnull(a.ic_combo_box,'N')              as ic_combo_box,    
 isnull(a.ic_boolean,'N')                as ic_boolean,  
 case when isnull(a.ic_lista_valor,'N') = 'S' then 'cd_lista_valor' else isnull(a.nm_campo_chave_combo_box,'') end   as nm_campo_chave_combo_box,    
 case when isnull(a.ic_lista_valor,'N') = 'S' then 'nm_lista_valor' else isnull(a.nm_campo_mostra_combo_box,'') end as nm_campo_mostra_combo_box,    
 isnull(a.nm_tabela_combo_box,'')        as nm_tabela_combo_box,    
 isnull(a.nm_dado_padrao_atributo,'')    as nm_dado_padrao_atributo,    
 isnull(a.ic_data_padrao,'')             as ic_data_padrao,    
 isnull(a.ic_aliasadmin_combo_box,'N')   as ic_aliasadmin_combo_box,  
 isnull(a.nm_atributo,'')                as nm_campo_chave_origem,  
 cast(0 as int)                          as cd_atributo_banda,    
 cast('' as varchar(60))                 as nm_banda,    
 isnull(a.ic_doc_caminho_atributo,'N')   as ic_doc_caminho_atributo,    
 isnull(a.ic_lista_valor,'N')            as ic_lista_valor,  
 'N'                                     as ic_card,  
 ----------------------------------------------------------------------------------------------------------------  
   
 cast('' as varchar(500))                as nm_valor_original,  
 cast('' as varchar(500))                as nm_valor_campo,  
  
 cast(  
 case when isnull(a.ic_atributo_chave,'N') ='S' and a.cd_atributo = fta.cd_atributo and @cd_documento>0 then --and isnull(fta.ic_chave_incremento,'N') = 'N' then  
  cast(@cd_documento as varchar(500))  
 else  
   case when isnull(@cd_usuario,0) > 0 and a.nm_atributo = 'cd_usuario' then cast(@cd_usuario as varchar(500))   
   else   
      case when isnull(@cd_relatorio,0) > 0 and a.nm_atributo = 'cd_relatorio'  
      then cast(@cd_relatorio as varchar(500))   
      else  
        case when fta.ic_data_hoje='S' then  
          convert(varchar,@dt_hoje,23)  
        else  
   case when isnull(fta.ic_tipo_atributo,'0') = '8' then --and isnull(@cd_documento,'') = '' then  
   cast('N' as char(1))  
  else  
   case when fta.ic_hora_atributo='S' then  
          cast(FORMAT(GETDATE(), 'HH:mm') as varchar(500))  
        else  
          cast('' as varchar(1))  
    
     end  
    end  
     end  
      end  
    end  
 end as nvarchar(max))                                   as nm_valor_inicial,  
  
 cast('' as nvarchar(max))                               as nm_valor_lookup,  
 cast(0 as int)                  as nm_valor_chave_lookup,  
  
 ----------------------------------------------------------------------------------------------------------------  
 0                                       as cd_tipo_movimento, --0: CONSULTA / 1: I/ 2:A / 3:E  
 cast('' as nvarchar(max))               as nm_lookup,  
 cast('' as nvarchar(max))               as nm_dados_info_lookup,  
 cast('' as nvarchar(max))               as nm_resultado_lookup,  
  
 case when isnull(a.ic_edita_cadastro,'N')='S' then  
    '[{ disabled: false }]'  
 else  
    '[{ disabled: true }]'                 
 end                                     as editorOptions,  
 isnull(ts.ic_icone,'N')                 as ic_icone,  
 isnull(ts.nm_icone_tabsheet,'')         as nm_icone_tabsheet,  
  
 -----Dados de Retorno da API------------------------------------------  
     
 ap.nm_api,  
   
 --Tabela do Atributo---  
  
  isnull(fta.cd_tabela_api,0)      as cd_tabela_api,  
  isnull(tapi.nm_tabela,'')        as nm_tabela_api,  
  
  
  --Atributo--  
  
  aapi.cd_atributo                         as cd_atributo_api,  
  aapi.nm_atributo                         as nm_atributo_api,  
  isnull(a.ic_atributo_obrigatorio,'N') as ic_atributo_obrigatorio,  
  isnull(g.cd_form_grid,0)                 as cd_form_grid,  
  isnull(fg.cd_menu,0)                     as cd_menu_grid,  
  isnull(fg.cd_api,0)                      as cd_api_grid  
  
  --select * from tabsheet  
  --select * from form_tabsheet  
  
into   
  #AuxForm  
  
from   
  form f  
  left outer join form_tabsheet ft             on ft.cd_form      = f.cd_form --select * from form_tabsheet where cd_form = 53  
  
  left outer join tabsheet ts                  on ts.cd_tabsheet  = ft.cd_tabsheet  
  
  left outer join tabela tb                    on tb.cd_tabela    = ft.cd_tabela --select cd_natureza_atributo,* from atributo where cd_tabela = 5806   
  
  left outer join form_tabsheet_atributo fta   on fta.cd_form     = f.cd_form              and --select cd_atributo,* from form_tabsheet_atributo where cd_form = 107   
                                                  fta.cd_tabsheet = ft.cd_tabsheet           
                                                  --and fta.cd_tabela   = ft.cd_tabela   
  
  left outer join atributo a                  on  a.cd_tabela     = fta.cd_tabela          and   
                                                  a.cd_atributo   = fta.cd_atributo  
  
  left outer join Tabela tfta                        on tfta.cd_tabela   = fta.cd_tabela  
  left outer join egisadmin.dbo.natureza_atributo na on na.cd_natureza_atributo = a.cd_natureza_atributo --select * from  egisadmin.dbo.natureza_atributo  
  left outer join Api Ap                             on ap.cd_api               = fta.cd_api  --select * from api_composicao where cd_api = 413  
  left outer join API_Composicao ac                  on ac.cd_api               = ap.cd_api  
  left outer join Tabela tabapi                      on tabapi.cd_tabela        = ap.cd_tabela  
  left outer join Procedimento papi                  on papi.cd_procedimento    = ap.cd_procedimento  
  left outer join Tabela tapi                        on tapi.cd_tabela          = fta.cd_tabela_api  
  left outer join atributo aapi                      on  aapi.cd_tabela         = fta.cd_tabela_api          and  
                                                         aapi.cd_atributo       = fta.cd_atributo_api  
  
  left outer join form_tabsheet_Grid g               on g.cd_form = f.cd_form --select * from form_tabsheet_Grid  
  left outer join form fg                            on fg.cd_form = g.cd_form_grid --select * from form where cd_form = 122  
  
where  
  f.cd_form = @cd_form   
  and  
  isnull(a.cd_atributo,0)>0  
  and  
  ISNULL(fta.ic_habilitado_atributo,'S')='S'  
     
  
   --select * from #AuxForm  
    --  return  
  
 --select cd_tabela_api,ic_atributo_obrigatorio,* from #AuxForm  
  
--select * from #AuxForm where ic_chave_grid = 'S'  
  
--Montagem  
  
select * into #Form          from #AuxForm  
--select * into #AtributoForm  from #AuxForm  
  
declare @cd_controle int  
set @cd_controle = 0  
  
  
DECLARE @registros as table (  
    id    int,  
    Campo varchar(80),  
    Valor nvarchar(max)  
)  
  
  --select * from #AuxForm  
while exists( select top 1 cd_controle from #AuxForm )  
begin  
  
  select      
    top 1       
    @cd_controle               = cd_controle,      
 @cd_atributo               = cd_atributo,  
 @cd_tabela                 = cd_tabela_atributo,  
 @cd_natureza_atributo      = cd_natureza_atributo,  
 @cd_tabela_pesquisa        = cd_tabela_pesquisa,  
    @nm_datafield              = ltrim(rtrim(nm_atributo)),      
    @nm_caption                = ltrim(rtrim(nm_apresenta_atributo)),      
    @nm_datatype               = ltrim(rtrim(nm_datatype)),      
    @nm_alinhamento            = ltrim(rtrim(nm_tipo_alinhamento)),      
    @nm_formato                = ltrim(rtrim(nm_formato)),      
    @chave                     = case when ic_chave_grid = 'S' and @chave = '' then nm_atributo else @chave end ,      
    @ic_total_grid             = ic_total_grid,      
    @ic_contador_grid          = ic_contador_grid,      
    @ic_grafico_eixo_x         = ic_grafico_eixo_x,      
    @ic_grafico_eixo_y         = ic_grafico_eixo_y,      
    @ic_mostra_grid            = ic_mostra_grid,      
    @cd_tipo_consulta          = cd_tipo_consulta,      
    @ic_edita_cadastro         = ic_edita_cadastro,      
    @ic_titulo_total_grid      = ic_titulo_total_grid,      
    @nm_apresenta_atributo     = nm_apresenta_atributo,  --select * from atributo where cd_tabela = 5267      
    @ic_chave_grid             = ic_chave_grid,      
    @ic_chave_estrangeira      = ic_chave_estrangeira,      
    @ic_combo_box              = ic_combo_box,      
    @ic_boolean                = ic_boolean,      
    @nm_campo_chave_combo_box  = nm_campo_chave_combo_box,      
    @nm_campo_mostra_combo_box = nm_campo_mostra_combo_box,       
    @nm_tabela_combo_box       = case when ic_chave_estrangeira = 'S' then nm_tabela_combo_box else cast('' as varchar(60)) end,      
    @nm_dado_padrao_atributo   = nm_dado_padrao_atributo,      
    @ic_data_padrao            = ic_data_padrao,      
    @nm_banda                  = nm_banda,      
    --@cd_banda_atributo         = cd_banda_atributo,      
    @ic_doc_caminho_atributo   = ic_doc_caminho_atributo,      
    @ic_card                   = ic_card,  
    @ic_composto_lookup        = ic_composto_lookup,  
    @ic_aliasadmin_combo_box   = ic_aliasadmin_combo_box,  
    @nm_campo_chave_origem     = nm_campo_chave_origem,  
    @sTabela                   = nm_tabela,                --nm_tabela_atributo, (21/07/2024-ccf comentário da troca)  
 @nm_valor_inicial          = isnull(nm_valor_inicial,''),  
 @nm_valor_lookup           = nm_valor_lookup,  
 @nm_where_lookup           = nm_where_lookup,  
 @nm_resultado_select       = nm_resultado_select,  
 @ic_tipo_atributo          = ic_tipo_atributo,  
 @ic_sap_admin              = ic_sap_admin,  
 @ic_lista_valor            = ic_lista_valor,  
 @nm_banco                  = case when ic_sap_admin='S' then 'EgisAdmin' else @nm_banco end  
  
  
    --@ic_lookup                 = ic_lookup,  
    --@ic_coluna_fixa            = ic_coluna_fixa  
          
   from      
     #AuxForm  
      
   order by      
     cd_controle      
  
  ---------------------------------------------------------------------------------------------  
  INSERT INTO @registros VALUES (@cd_atributo, @nm_datafield, '');  
  
  --Cláusula Where com a Chave e Valor Inicial---  
  
  if @ic_chave_grid = 'S' or @nm_datafield = 'cd_relatorio'  
  begin  
  
    --select @ic_chave_grid, @nm_valor_inicial, @nm_datafield  
 if isnull(@nm_valor_inicial,'')<>''  
 begin  
      set @cWhere = @cWhere      
                   +      
                   case when isnull(@cWhere,'')<>'' then ' and ' else cast('' as varchar(1)) end      
                   +      
                   ' tab.['+cast(isnull(@nm_datafield,'') as nvarchar(max))+']'      
+      
                   ' = '      
                   +      
                   cast(isnull(@nm_valor_inicial,'') as nvarchar(max))  
    end  
 else  
 begin  
   set @cWhere = @cWhere      
                   +      
                   case when isnull(@cWhere,'')<>'' then ' and ' else cast('' as varchar(1)) end      
                   +      
                   ' tab.['+cast(isnull(@nm_datafield,'') as nvarchar(max))+']'      
                   +      
                   ' = '      
                   +      
                   cast(isnull(@cd_documento,'') as nvarchar(max))  
 end  
   
   end  
   --select @cWhere  
  --Campos para pivot table----  
  
      set @sqlcampospivot = @sqlcampospivot  
                  +  
                  case when isnull(@sqlcampos,'')<>'' then ', ' else '' end  
      +  
                  case when isnull(@nm_datafield,'')<>'' then '['+cast(isnull(@nm_datafield,'') as nvarchar(max))+']' else CAST('' as varchar(500)) end  
  
   --select @sqlcampospivot  
  --Campos da Tabela  
   
     
      set @sqlcampos = @sqlcampos  
                  +  
                  case when isnull(@sqlcampos,'')<>'' then ', ' else '' end  
      +  
                  case when isnull(@nm_datafield,'')<>'' and isnull(@nm_datatype,'') = 'number' and isnull(@cd_natureza_atributo,0) <> 6 then 'CONVERT(DECIMAL(10, 0),tab.['+cast(isnull(@nm_datafield,'') as nvarchar(max))+']) as '+
				  '['+cast(isnull(@nm_datafield,'') as nvarchar(max))+']'  
           when isnull(@nm_datafield,'')<>'' and isnull(@nm_datatype,'') = 'number' and isnull(@cd_natureza_atributo,0) =  6 then 'CONVERT(DECIMAL(10, 2),tab.['+cast(isnull(@nm_datafield,'') as nvarchar(max))+']) as '+ '['+cast(isnull(@nm_datafield,'') as
 nvarchar(max))+']'  
      when isnull(@nm_datafield,'')<>'' and isnull(@nm_datatype,'') <> 'number' then 'tab.['+cast(isnull(@nm_datafield,'') as nvarchar(max))+']'   
      else CAST('' as varchar(500)) end  
  
   --Tabelas  
   --select @sqlcampos  
   --select @nm_datafield  
  
   set @ref = ' '+ CHAR(@i)      
  
  
   if isnull(@nm_tabela_combo_box,'')<>'' and isnull(@ic_chave_estrangeira,'N')='S'  
   begin  
  
      --select @nm_tabela_combo_box, @nm_campo_chave_combo_box, @nm_campo_chave_origem  
  
  
     set @tabelas_estrangeiras = @tabelas_estrangeiras +        
                                'left outer join '     +      
  
           case when isnull(@ic_aliasadmin_combo_box,'N') = 'S' then      
              @nm_alias      
                                      else      
              @nm_banco  
                                          +  
     '.dbo.'      
  
           end      
           +      
           cast(@nm_tabela_combo_box as nvarchar(max))       
           +      
           @ref      
           +      
           ' on '+ @ref+'.'+ cast(@nm_campo_chave_combo_box as nvarchar(max)) + ' = tab.' + cast(@nm_campo_chave_origem as nvarchar(max))  
           +       
           ' '      
  
           --select @nm_campo_chave_combo_box  
     
          if isnull(@nm_campo_mostra_combo_box,'') <>'' --and CHARINDEX(@nm_campo_chave_combo_box, @sqlcampos) = 0  
    begin  
  
            set @campos_estrangeiros = @campos_estrangeiros       
                               +      
            ', '      
                               +       
            --@ref+'.'                
            --+      
            --@nm_datafield      
   @ref + '.' +  
            cast(@nm_campo_mostra_combo_box as nvarchar(max))   
   --+ ' as '+@ref+'_'+ @nm_campo_mostra_combo_box  
      
    end  
  
          set @i = @i + 1      
  
   end  
  
   --form_tabsheet_atributo  
  
   --Processo de Buscar o Resultado do Lookup padrao  
  
  -- if @ic_tipo_atributo = '9' and @nm_resultado_select <> ''  
  -- begin  
  --   --set @sqlresultado = @nm_resultado_select  
  --    SET @ParamDefinition = N'@sqljsonresultado nvarchar(max) OUTPUT';      
    
  --    EXEC sp_executesql @nm_resultado_select, @ParamDefinition, @sqljsonresultado=@sqljsonresultado OUTPUT      
  
  --update  
  --  #Form  
  --set  
  --  nm_resultado_lookup = @sqljsonresultado  
  --   where   
  --  cd_controle = @cd_controle  
  
      
   --end  
       
   if isnull(@ic_combo_box,'N') = 'S' and isnull(@cd_controle,0)<10000      
   begin      
      
     --print @nm_datafield      
       
     --select @nm_campo_chave_combo_box  
  
     if isnull(@nm_campo_chave_combo_box,'')<>''  
     begin  
  
  --------------------------Outros campos para o SELECT  
   set @sqlOutrosCamposIntermediaria = 'select @sqlOutrosCampos = (select nm_atributo from egisadmin.dbo.atributo where cd_tabela = '+ cast(@cd_tabela_pesquisa as varchar)+ ' and ic_mostra_grid = ''S'' and ic_mostra_cadastro = ''S'' and ic_filtro_selecao 
= ''S'' FOR JSON AUTO)'  
    EXEC sp_executesql @sqlOutrosCamposIntermediaria, N'@sqlOutrosCampos nvarchar(max) OUTPUT', @sqlOutrosCampos=@sqlOutrosCampos OUTPUT   
  
       if isnull(@sqlOutrosCampos,'') <> ''  
       begin  
           select                       
               1                                                    as id_registro,  
               IDENTITY(int,1,1)                                    as id,  
               valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                       
               valores.[value]                                      as valor                      
                                    
               into #selectJson                      
               from                  
                 openjson(@sqlOutrosCampos)root                      
                 cross apply openjson(root.value) as valores   
  
                  SELECT @listaAtributosLookup = STUFF((  
                      SELECT ', ' + valor    
                      FROM #selectJson    
                      FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')  
       end  
    --Outros dados do Lookup  
    if isnull(@listaAtributosLookup,'') <> ''  
    begin  
       set @sqlOutrosCamposIntermediaria = 'select @sqlOutrosCampos = (select nm_atributo,ds_atributo,isnull(qt_tamanho_atributo,1) as qt_tamanho_atributo,cd_natureza_atributo from egisadmin.dbo.atributo where cd_tabela = '+
	   cast(@cd_tabela_pesquisa as varchar)+ '   
    and ic_mostra_grid = ''S''  
    and ic_mostra_cadastro = ''S''   
    and (ic_filtro_selecao = ''S'' or nm_atributo in ('''+cast(@nm_campo_chave_combo_box as nvarchar(max))+''', '''+cast(@nm_campo_mostra_combo_box as nvarchar(max))+''')) FOR JSON AUTO)'  
    --select @sqlOutrosCamposIntermediaria  
    EXEC sp_executesql @sqlOutrosCamposIntermediaria, N'@sqlOutrosCampos nvarchar(max) OUTPUT', @sqlOutrosCampos=@sqlOutrosCampos OUTPUT   
    -----------------------  
     update  
        #Form  
      set  
        nm_dados_info_lookup = @sqlOutrosCampos  
         where   
        cd_controle = @cd_controle  
    end  
    else  
    begin  
     set @nm_dados_info_lookup = null  
    end  
  ---------------------------------------------------------------  
       set @sqlcombox = 'select @sqljsoncombox = (select ' + cast(@nm_campo_chave_combo_box as nvarchar(max))+', '+cast(@nm_campo_mostra_combo_box as nvarchar(max)) + case when isnull(@listaAtributosLookup,'') <> '' then ', '+cast(@listaAtributosLookup as
 nvarchar(max)) else '' end  
        +      
        ' from '+  
    
  --@nm_banco  
  
           case when isnull(@ic_aliasadmin_combo_box,'N') = 'S' then      
              @nm_alias      
                                      else      
              @nm_banco+'.dbo.'      
  
           end      
                   
     +  
  
  cast(@nm_tabela_combo_box as nvarchar(max))  
    
  --Fixo com o Cliente---  
  
  if isnull(@nm_where_lookup,'')<>''  
      set @sqlcombox = @sqlcombox + ' where ' + cast(@nm_where_lookup as nvarchar(max))   
        else  
  begin  
  
    if isnull(@ic_composto_lookup,'N')='S'  
    begin  
     set @sqlcombox = @sqlcombox + ' where ' + cast(@nm_campo_chave_combo_box as nvarchar(max)) + ' = ' +  
         case when isnull(@nm_campo_chave_combo_box,'') = 'cd_cliente' then cast(@cd_cliente as varchar(15)) else cast('' as varchar(1)) end  
          end  
  end  
  --Traz isnull para o lookup  
  if isnull(@nm_where_lookup,'')='' --Else da condição acima  
  begin  
   set @sqlcombox = @sqlcombox + ' where ' + cast(@nm_campo_chave_combo_box as nvarchar(max)) + ' is not null and '+ cast(@nm_campo_mostra_combo_box as nvarchar(max))+' is not null'  
  end  
  
  set @sqlcombox = @sqlcombox   
    
  +' order by cast('+cast(@nm_campo_mostra_combo_box as nvarchar(max))+' as nvarchar(max)) FOR JSON AUTO )'      
      
   -- select @sqlcombox  
      SET @ParamDefinition = N'@sqljsoncombox nvarchar(max) OUTPUT';    
      
    
      EXEC sp_executesql @sqlcombox, @ParamDefinition, @sqljsoncombox=@sqljsoncombox OUTPUT      
      
   --select @sqlcombox  
  
     end  
     --select @sqljsoncombox, @sqlcombox  
  
  update  
    #Form  
  set  
    nm_lookup           = @sqljsoncombox,  
    nm_resultado_lookup = case when @nm_resultado_select='1' then @sqljsoncombox else '' end  
     where   
    cd_controle = @cd_controle  
  
   end   
  
   set @listaAtributosLookup = null  
   ------Lista de Valores  
  
   if isnull(@ic_lista_valor,'N') = 'S' and isnull(@cd_tabela,0) > 0 and isnull(@cd_atributo,0) > 0  
   begin  
  set @sqljsoncombox = (select alv.* from Atributo_Lista_Valor alv where alv.cd_tabela = @cd_tabela and alv.cd_atributo = @cd_atributo FOR JSON AUTO)  
  --select @sqljsoncombox  
  --select * from Atributo_Lista_Valor alv where alv.cd_tabela = 5837 and alv.cd_atributo = 23   
     update  
    #Form  
  set  
    nm_lookup           = @sqljsoncombox,  
    nm_resultado_lookup = case when @nm_resultado_select='1' then @sqljsoncombox else '' end  
     where   
    cd_controle = @cd_controle  
  
   end  
      
   --select * from atributo where cd_tabela = 1398 and cd_atributo in (6,9)  
      
   ----------------------------------------------------------------------------------------------------------------------      
   --Transformar o resultado do SQL em Json        
   --      
   ----------------------------------------------------------------------------------------------------------------------      
      
         
  delete from #AuxForm  
  where  
    cd_controle = @cd_controle  
  
  
end  
  
--select * from @registros  
  
--select @sqlcampos  
--return  
--select @tabelas_estrangeiras  
--select @campos_estrangeiros   
--------------------------------------------  
--Montagem do Select para consulta dos dados  
--------------------------------------------  
--select @sSQL  
  
         set @sSQL = 'set @jsonr = (select '   
        +   
       --'tab.* '  
     @sqlcampos  
    --' * '  
        +  
     ------------------------------------------------------------------------  
        @campos_estrangeiros   
     ------------------------------------------------------------------------  
     +  
     ' from '+@nm_banco+'.dbo.'+ltrim(rtrim(@sTabela)) + ' tab '      
              +      
                          
              @tabelas_estrangeiras      
                              
              +      
     ' '      
     +      
       case when @cWhere <> '' then 'Where '+@cWhere      else '' end      
       +      
       case when @sOrderby<>'' then 'order by '+@sOrderby else '' end     
      
    -- + ' FOR JSON AUTO)'  
    
  +   
    
  ' FOR JSON PATH )'  
  
  --select @sSQL  
  
  --+ 'declare @json nvarchar(max)  
  
  --select @campos_estrangeiros  
  --select @tabelas_estrangeiras      
  --select @nm_banco  
  --ccf aqui  
  --select @sSQL  
 ------------------------------------------------------------------  
  
  
  --RETURN  
  
  declare @jsonResult nvarchar(max)  
  
    exec sp_executesql @sSQL, N'@jsonr NVARCHAR(MAX) OUTPUT' , @jsonr=@jsonResult OUTPUT;  
      
    --select @sSQL  
    --select @jsonResult  
 --  
   
 --return  
  
     select                       
  
       IDENTITY(int,1,1)                                    as id,  
       valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                       
       valores.[value]                                      as valor                      
                 
       into #jsonResult                      
  
     from                  
        openjson(@jsonResult)root                      
        cross apply openjson(root.value) as valores        
  
     --select * from #jsonResult  
  
  
  declare @id int  
  set @id = 0  
  
  while exists( select top 1 id from #jsonResult )  
  begin  
    select top 1  
      @id               = id,  
   @nm_datafield     = campo,  
   @nm_valor_inicial = valor  
  
    from  
      #jsonResult  
       
     
    --Valor do Atributo---  
    update  
      #Form  
       set  
      nm_valor_inicial = @nm_valor_inicial  
    where  
      nm_atributo = @nm_datafield  
  
  
    delete from #jsonResult  
    where  
      @id = id  
  
  end  
  
  
     drop table #jsonResult  
       
--------------------------------------------  
  
    --select @sSQL  
  
    --EXEC sp_executesql @sSQL  
  
    --select * from @registros order by id  
  
--------------------------------------------  
  
--select @campos_estrangeiros  
  
--select @tabelas_estrangeiras  
  
  
  
--select @sqljsoncombox  
  
--RETURN  
  
--Apresentação dos Dados para o Usuário---------------------------------------------------------------------------------------------------------  
--return  
  
select  
 f.* ,
 nm_lookup_tabela = 
 case when isnull(f.nm_tabela_combo_box,'')<>'' 
 then
 'Select ' + 
  f.nm_campo_chave_combo_box + ' as '+f.nm_campo_chave_combo_box +
   ', ' + 
  f.nm_campo_mostra_combo_box +' as Descricao' +
   + ' from '+ f.nm_tabela_combo_box +' order by ' + f.nm_campo_mostra_combo_box
  else
    cast('' as varchar(10)) 
  end
 
from   
 #Form f  
  
order by  
  f.qt_ordem_atributo,  
  f.cd_form,   
  f.cd_atributo  
  
------------------------------------------------------------------------------  
  
  go

------------------------------------------------------------------------------  
 --FOR JSON AUTO    
------------------------------------------------------------------------------  
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_formulario_atributo 96,42,0,0
------------------------------------------------------------------------------
--exec pr_formulario_atributo 327,5,10,0
------------------------------------------------------------------------------

--este é o comando para liberar o form para teste----
--

--exec pr_egis_formulario_atributo '[{
--    "cd_empresa": "96",
--    "cd_parametro": 42,
--    "cd_documento": 0,
--    "cd_relatorio": 0,
--    "cd_usuario": "113"
--}]'


--exec pr_egis_formulario_atributo '[{"cd_empresa":"96","cd_parametro":"0","cd_form":"42","cd_menu":"6434","cd_documento":"2","cd_usuario":"113"}]'

exec pr_egis_formulario_atributo
'[{
    "cd_empresa": "96",
    "cd_parametro": "0",
    "cd_form": "0",
    "cd_menu": "7979",
    "cd_documento": 1,
    "cd_usuario": "113"
}]'

--select * from menu where cd_menu = 7269
