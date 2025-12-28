--BANCO DA EMPRESA DO CLIENTE
--USE EGISSQL_377
--GO
--USE gbs_EGISSQL


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_modal_composicao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_modal_composicao

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_modal_composicao
-------------------------------------------------------------------------------
--pr_egis_modal_composicao
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EGISSQL
--
--Objetivo         : Pesquisa de Registro na Tabela
--
--Data             : 25.04.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_modal_composicao
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
declare @cd_id_registro            int = 0
declare @cd_tabela                 int = 0
declare @nm_tabela                 varchar(80) = ''
declare @nm_atributo_chave         varchar(80) = ''
declare @cd_form                   int = 0
declare @cd_menu                   int = 0
declare @nm_tabela_origem          varchar(80)   = ''
declare @ic_detalhe_menu           char(1)       = 'N'
declare @sqlMenu                   nvarchar(max) = ''
declare @sqlTabsheet               nvarchar(max) = ''
declare @ic_registro_tabela_menu   char(1)       = 'N'
declare @ic_importacao_menu        char(1)       = 'N'
declare @ic_upload_menu            char(1)       = 'N'
declare @ic_relatorio_menu         char(1)       = 'N'
declare @ic_filtro_obrigatorio     char(1)       = 'N'
declare @ic_crud_processo          char(1)       = 'S'
declare @nome_procedure            varchar(100)  = ''
declare @ic_menu_processo          char(1)       = 'N'
declare @nm_menu_titulo            varchar(100)  = ''
declare @ic_dashboard_menu         char(1) = 'N'
declare @cd_tabsheet               int           = 0
declare @cd_menu_processo          int           = 0
declare @ic_item_edicao            char(1)       = 'N'
declare @ic_json_parametro         char(1)       = 'N'
declare @ic_acoes_menu             char(1)       = 'N'
declare @ic_admin                  char(1)       = 'N'
declare @nm_banco_tabela           varchar(80)   = ''
declare @cd_parametro_menu         int           = 0
declare @ic_cliente                char(1)       = 'N'
declare @ic_modal_pesquisa         char(1)       = 'N'
declare @cd_menu_modal             int           = 0
declare @cd_modal                  int           = 0
----------------------------------------------------------------------------------------------------------      

select @cd_parametro       = valor from #json  with(nolock) where campo = 'cd_parametro'   
select @cd_usuario         = valor from #json  with(nolock) where campo = 'cd_usuario'   
select @dt_inicial         = valor from #json  with(nolock) where campo = 'dt_inicial'     
select @dt_final           = valor from #json  with(nolock) where campo = 'dt_final'    
select @cd_form            = valor from #json  with(nolock) where campo = 'cd_form'    
select @nm_tabela_origem   = valor from #json  with(nolock) where campo = 'nm_tabela_origem'    
select @cd_menu            = valor from #json  with(nolock) where campo = 'cd_menu'    
select @cd_tabsheet        = valor from #json  with(nolock) where campo = 'cd_tabsheet'    
select @ic_modal_pesquisa  = valor from #json  with(nolock) where campo = 'ic_modal_pesquisa'
select @cd_menu_modal      = valor from #json  with(nolock) where campo = 'cd_menu_modal'
select @cd_modal           = valor from #json  with(nolock) where campo = 'cd_modal'
----------------------------------------------------------------------------------------------------------      

set @cd_menu           = ISNULL(@cd_menu,0)
set @cd_form           = ISNULL(@cd_form,0)
set @cd_tabsheet       = ISNULL(@cd_tabsheet,0)
set @cd_tabela         = ISNULL(@cd_tabela,0)
set @ic_modal_pesquisa = isnull(@ic_modal_pesquisa,'N')
set @cd_menu_modal     = isnull(@cd_menu_modal,0)
set @cd_modal          = isnull(@cd_modal,0)


----------------------------------------------------------------------------------------------------------      


----------------------------------------------------------------------------------------------------------      
 --modal_composicao

 SELECT   
    m.cd_modal,
    m.nm_titulo_modal,
    
    --Procedimento de Atualização de Dados
    m.nm_procedimento,
    m.cd_parametro,

    --Procedimento de Carga de Dados
    m.nm_procedimento_dados,
    m.cd_carga_parametro,
    --------------------------------
    isnull(m.ic_arquivo_texto,'N')                             as ic_arquivo_texto,
    
    --Dados dos Atributos------------------------------------------------------------------------
    a.cd_tabela, 
     	t.nm_tabela,
     	isnull(a.cd_atributo,mc.cd_atributo)                    as cd_atributo,
     	isnull(a.ic_numeracao_automatica,'N')                   as ic_numeracao_automatica,
        isnull(a.ic_atributo_chave,'N')                         as ic_atributo_chave,

     	isnull(a.ic_chave_estrangeira,'N')                      as ic_chave_estrangeira,
		
        isnull(a.nu_ordem,mc.qt_ordem_atributo)                 as nu_ordem,
     	isnull(a.nm_atributo,mc.nm_atributo_modal)              as nm_atributo,
     	isnull(a.nm_atributo_consulta, mc.nm_atributo_consulta) as nm_atributo_consulta,
     	isnull(a.ds_atributo, mc.nm_atributo_consulta)          as ds_atributo,		
        
        
        case when isnull(mc.ic_atributo_lookup,'N') = 'S' then
          mc.nm_atributo_modal
        else
          cast('' as varchar(80))
        end
        --isnull(mc.nm_campo_mostra_combo_box,'')
                                                                    as nm_campo_mostra_combo_box,
	    case when ISNULL(mc.nm_atributo_consulta,'')=''
	    then
	      a.nm_atributo_consulta
        else
          mc.nm_atributo_consulta
	    end                                                                        as nm_titulo_menu_atributo,

        case when isnull(mc.ic_atributo_lookup,'N')='S' 
        then
        --'Código '
	 
	    --+

        mc.nm_atributo_lookup
 
        else
          cast('' as char(1))
        end

                                                                                  as nm_atributo_lookup,		 	
		
		
		case when isnull(mc.ic_data_hoje,'N') = 'S' then
          mc.ic_data_hoje
        else
		isnull(a.ic_data_hoje,'N')
        end                                 as ic_data_hoje,
     	isnull(a.ic_mostra_grid,'N')        as ic_mostra_grid,
     	isnull(a.ic_edita_cadastro,'S')     as ic_edita_cadastro,
        isnull(a.ic_mostra_relatorio,'S')   as ic_mostra_relatorio,
        isnull(a.ic_mostra_cadastro,'S')    as ic_mostra_cadastro,
     	isnull(a.ic_contador_grid,'N')      as ic_contador_grid,
     	isnull(a.ic_total_grid,'N')         as ic_total_grid,
     	isnull(a.ic_filtro_atributo,'N')    as ic_filtro,

        case when isnull(mc.nm_valor_padrao,'')<>'' then
          mc.nm_valor_padrao
     	else
          case when isnull(mc.ic_data_hoje,'N') = 'S' then
           dbo.fn_data_string(@dt_hoje)
          else
            case when isnull(a.vl_default,'')='' then
     	      CAST('' as char(1))
            else
              isnull(a.vl_default,'') 
            end
          end
     	end                                 as vl_default,
     	
        case when isnull( cast(mc.ds_atributo_mensagem as nvarchar(max)),'')<> '' then
         mc.ds_atributo_mensagem
        else
        a.ds_campo_help
        end                                 as ds_campo_help,
     
     	--ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,
        case when isnull(m.nm_titulo_modal,'')<>'' then
           m.nm_titulo_modal
        else
	      case when isnull(@nm_menu_titulo,'')='' then
     	    t.nm_tabela     
		  else
		    @nm_menu_titulo
		  end
        end                                 as nm_titulo,
	    case when isnull(@nm_menu_titulo,'')='' then
     	t.nm_tabela 
		else
		@nm_menu_titulo
		end                                    as nm_titulo_form,
        
   	    
     	nm_lookup_tabela = 
         case when isnull(mc.ic_atributo_lookup,'N') = 'S'
         then
         'Select ' + 
           mc.nm_atributo_lookup+ ' as '+mc.nm_atributo_lookup +
        ', ' + 
       isnull(a.nm_atributo,'') +' as Descricao' +
        + ' from '+ case when isnull(t.ic_sap_admin,'N')='S' then 'egisadmin.dbo.' else cast('' as char(1)) end 
		+
		t.nm_tabela +' order by ' + mc.nm_atributo_lookup
       else
         cast('' as varchar(10)) 
       end,
       
       --select * from egisadmin.dbo.natureza_atributo update egisadmin.dbo.natureza_atributo set nm_datatype = 'TextArea' where cd_natureza_atributo = 13


	   case when ISNULL(na.nm_formato,'')<>'' then
	      na.nm_formato
	   else
          isnull(na.nm_datatype,'')                
	   end                                               as nm_datatype,
     
       --Lista de Valores---
       case when isnull(mc.ic_lista_valor,'N')='S' then
         isnull((select  mc.nm_atributo_modal as nm_atributo, mc.nm_atributo_consulta, alv.* from egisadmin.dbo.modal_Lista_Valor alv where alv.cd_modal = m.cd_modal and alv.cd_atributo = mc.cd_atributo FOR JSON AUTO),'N')  
          
       else
          case when isnull(a.ic_lista_valor,'N')='S' then
            isnull((select  a.nm_atributo, a.nm_atributo_consulta, alv.* from egisadmin.dbo.Atributo_Lista_Valor alv where alv.cd_tabela = a.cd_tabela and alv.cd_atributo = a.cd_atributo FOR JSON AUTO),'N')  
          else
            cast('' as char(1))
          end
       end                                          as Lista_Valor,


       @ic_detalhe_menu                             as ic_detalhe_menu,
       @sqlMenu                                     as tab_menu,
     
       isnull(a.ic_grid_agrupado_atributo,'N')      as ic_grid_agrupado_atributo,  		
       isnull(a.ic_listview_cabecalho,'N')          as ic_listview_cabecalho,
       isnull(a.ic_listview_rodape,'N')             as ic_listview_rodape,
       @ic_registro_tabela_menu                     as ic_registro_tabela_menu,
       @ic_importacao_menu                          as ic_importacao_menu,
       @ic_upload_menu                              as ic_upload_menu,
       @ic_relatorio_menu                           as ic_relatorio_menu,
       @ic_filtro_obrigatorio                       as ic_filtro_obrigatorio,
       ISNULL(a.ic_kanban_atributo,'N')             as ic_kanban_atributo,

       case when @cd_tabela>0 then --and m.ic_crud_processo is null then
        @ic_crud_processo
       else
          'N'
       end                                              as ic_crud_processo,
	   	   isnull(a.ic_retorno_atributo,'N')            as ic_retorno_atributo,

	   case when isnull(cast(mc.ds_atributo_validacao as nvarchar(max)),'')<>'' then
	     ltrim(rtrim( isnull(CAST(mc.ds_atributo_validacao as nvarchar(max)),'')))
	   else
	     
		 case when isnull(a.nm_tabela_combo_box,'')<>'' and isnull(a.ic_chave_estrangeira,'N')='S' 
         then
          'Select ' + 
           a.nm_campo_chave_combo_box + ' as '+a.nm_campo_chave_combo_box +
        ', ' + 
       isnull(a.nm_campo_mostra_combo_box,'') +' as Descricao' +
        + ' from '+ a.nm_tabela_combo_box +' where '+ a.nm_campo_chave_combo_box + ' = @'
		+ 
		a.nm_campo_chave_combo_box
		+ ' order by ' 
		+ a.nm_campo_mostra_combo_box
       else
         cast('' as varchar(10)) 
       end	 
		 

	   end                                                                        as ds_atributo_validacao,

	   isnull(mc.qt_ordem_atributo,0)                                             as qt_ordem_atributo,
	   ISNULL(t.ic_sap_admin,'N')                                                 as ic_admin,
       isnull(t.ic_parametro_tabela,'N')                                          as ic_parametro_tabela,
       --isnull(a.ic_doc_caminho_atributo,'N')                                      as ic_doc_caminho_atributo,
       case when isnull(mc.ic_doc_caminho_atributo,'N')<> '' then
          mc.ic_doc_caminho_atributo
       else
          isnull(a.ic_doc_caminho_atributo,'N')
       end                                                                        as ic_doc_caminho_atributo,
       isnull(a.ic_modal_atributo,'N')                                            as ic_modal_atributo,
       isnull(mc.ic_edicao_atributo,'S')                                          as ic_edicao_atributo,
       isnull(mc.cd_menu,0)                                                       as cd_menu,
       isnull(mn.nm_menu_titulo,'')                                               as nm_menu_titulo,
       cast('' as varchar(100))                                                   as cd_chave_retorno,
       isnull(m.ic_grid_modal,'')                                                 as ic_grid_modal,
       isnull(mc.ic_periodo_vigente,'N')                                          as ic_periodo_vigente,
       ic_tipo_arquivo
       
           
       into #Resultado
      --select * from egisadmin.dbo.modal
     
       FROM
        egisadmin.dbo.modal m
        inner join      egisadmin.dbo.modal_composicao mc        on mc.cd_modal = m.cd_modal
        left outer join egisadmin.dbo.menu mn                    on mn.cd_menu  = mc.cd_menu
        left outer join EGISADMIN.DBO.TABELA T                   on t.cd_tabela = mc.cd_tabela 
        LEFT OUTER JOIN EGISADMIN.DBO.ATRIBUTO A                 on A.CD_TABELA              = T.CD_TABELA AND A.NM_ATRIBUTO = mc.nm_atributo_modal
     	left outer join egisadmin.dbo.natureza_atributo na       on na.cd_natureza_atributo  = case when isnull(mc.cd_natureza_atributo,0)>0 then
        mc.cd_natureza_atributo else a.cd_natureza_atributo 
        end --select * from  egisadmin.dbo.natureza_atributo  
     	
       WHERE
         m.cd_modal = @cd_modal

        

       order by
         1,		 
         A.nu_ordem 
     
       --------------------------------------------------------------------------------------------------

       
         select * from #Resultado
         order by
            nu_ordem
       
  --end

  --end


  


go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_modal_composicao 
------------------------------------------------------------------------------
--exec pr_egis_modal_composicao '[{"cd_parametro":1,"cd_modal":"10","cd_usuario":"113","dt_inicial":"2025-05-01 00:00:00","dt_final":"2025-05-31 00:00:00"}]'
------------------------------------------------------------------------------

go

