--BANCO DA EMPRESA DO CLIENTE
--USE EGISSQL
--GO
--USE egissql_377


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_payload_tabela' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_payload_tabela

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_payload_tabela
-------------------------------------------------------------------------------
--pr_egis_payload_tabela
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
create procedure pr_egis_payload_tabela
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
declare @ic_selecao_registro       char(1)       = 'N'
declare @cd_form_modal             int           = 0
declare @cd_relatorio              int           = 0 
declare @ic_card_menu              char(1)       = 'N'
declare @ic_treeview_menu          char(1)       = 'N'

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

----------------------------------------------------------------------------------------------------------      

set @cd_menu           = ISNULL(@cd_menu,0)
set @cd_form           = ISNULL(@cd_form,0)
set @cd_tabsheet       = ISNULL(@cd_tabsheet,0)
set @cd_tabela         = ISNULL(@cd_tabela,0)
set @ic_modal_pesquisa = isnull(@ic_modal_pesquisa,'N')
set @cd_menu_modal     = isnull(@cd_menu_modal,0)
set @cd_relatorio      = isnull(@cd_relatorio,0)

----------------------------------------------------------------------------------------------------------      

--Verifica se o Menu é de Composicao para atualizar a Tabsheet

----------------------------------------------------------------------------------------------------------
if @cd_menu>0
begin
  --select * from egisadmin.dbo.Menu_Tabsheet where cd_menu = 8088
  select
     top 1 
     @cd_tabsheet = ISNULL(mt.cd_tabsheet,0)
  from
     EGISADMIN.dbo.Menu_Tabsheet mt
  where
    cd_menu_composicao = @cd_menu
	and
	ISNULL(cd_tabsheet,0)>0
	and
	ISNULL(mt.ic_ativa,'S')='S'


end


--Form

----------------------------------------------------------------------------------------------------------      

--if @cd_form>0
--begin
--  select @cd_tabela = ISNULL(f.cd_tabela,0)  
--  from
--    EGISADMIN.dbo.Form f 
--  where
--    f.cd_form = @cd_form
--end


----------------------------------------------------------------------------------------------------------      

--Menu

----------------------------------------------------------------------------------------------------------      
--select @cd_menu

if @cd_menu>0 and isnull(@nm_tabela_origem,'') = ''
begin
  
  select top 1 
    @cd_tabela        = ISNULL(t.cd_tabela,0),
    @nm_tabela_origem = ISNULL(t.nm_tabela,''),
	@ic_admin         = isnull(t.ic_sap_admin,'N'),
    @cd_menu_modal    = isnull(mm.cd_menu_modal,@cd_menu_modal)
  from
    EGISADMIN.dbo.Tabela t
	inner join egisadmin.dbo.menu_tabela mt      on mt.cd_tabela      = t.cd_tabela and mt.cd_menu = @cd_menu
    left outer join egisadmin.dbo.menu_modal mm  on mm.cd_menu_origem = @cd_menu

end

---------------------------------------------modal-------------------------------------------------------

if @cd_menu>0 and @cd_menu_modal>0 and @cd_menu<>@cd_menu_modal and @ic_modal_pesquisa='S'
begin
  set @cd_menu = @cd_menu_modal
end

--select @cd_menu, @cd_menu_modal

---------------------------------------------------------------------------------------------------------

--select @cd_tabela, @nm_tabela_origem

--Dados do Menu------------------------------------------------------------------------------------------

if @cd_menu>0
begin

  select top 1
     @ic_acoes_menu           = isnull(m.ic_acoes_menu,'S'),
     @ic_json_parametro       = isnull(m.ic_json_parametro,'N'),
     @ic_item_edicao          = isnull(m.ic_item_edicao,'N'),
     @ic_dashboard_menu       = isnull(m.ic_dashboard_menu,'N'),
	 @ic_crud_processo        = isnull(m.ic_crud_processo,'S'),
     @nm_menu_titulo          = m.nm_menu, --m.nm_menu_titulo,
     @ic_registro_tabela_menu = isnull(ic_registro_tabela_menu,'S'),
     @ic_detalhe_menu         = ISNULL(ic_detalhe_menu,'N'),
	 @ic_relatorio_menu       = case when isnull(mt.cd_menu,0) = 0  then 'N'                            else 'S' end,
	 @ic_importacao_menu      = case when isnull(mdc.cd_menu,0) = 0 then ISNULL(m.ic_importacao_menu,'N') else 'S' end,
	 @ic_upload_menu          = ISNULL(ic_upload_menu,'N'),
	 @ic_filtro_obrigatorio   = isnull(m.ic_filtro_obrigatorio,'N'),
	 
     --Definir vou abrir as Tabsheet's dentro do form Especial
	 @sqlMenu                 = isnull((select  m.cd_menu, md.cd_item_detalhe, md.cd_menu_detalhe, mc.nm_menu_titulo, isnull(md.nm_tabsheet_menu,mc.nm_menu_titulo) as nm_tabsheet_menu
	                                    from egisadmin.dbo.Menu_Detalhe md 
								             inner join egisadmin.dbo.menu mc on mc.cd_menu = md.cd_menu_detalhe 
	                                     where
										   md.cd_menu = m.cd_menu  FOR JSON PATH),''),
	
	 ----------Tabela------------------------------------------------------------------------------------------------------------------
     @cd_tabela               = ISNULL((select top 1 mtb.cd_tabela from EGISADMIN.dbo.menu_tabela mtb where mtb.cd_menu = m.cd_menu),0),
	 ----------------------
	 @nome_procedure          = ISNULL((select top 1 np.nome_procedure from egisadmin.dbo.meta_procedure_colunas np where np.cd_menu_id = m.cd_menu ),''),
	 -----------------------------------------------------------------------------------------------------------------------------------------------------
	 @cd_menu_processo          = isnull((select top 1 mp.cd_menu from egisadmin.dbo.menu_processo mp where mp.cd_menu = m.cd_menu order by mp.qt_ordem_menu_processo ),0),
	 --@ic_menu_processo        = ISNULL((select top 1 'S' from egisadmin.dbo.menu_processo mp where mp.cd_menu = m.cd_menu ),'N'),
	 --as Tabsheet's dentro do form Especial
	 @sqlTabsheet             = isnull((select mtab.cd_tabsheet, 
	                                           tab.nm_label_tabsheet as nm_tabsheet, m.cd_menu, mtab.cd_menu_tabsheet,
	                                           isnull(mtab.qt_ordem_tabsheet,0)  as  qt_ordem_tabsheet,
											   isnull(mtab.cd_menu_composicao,0) as cd_menu_composicao,
											   ISNULL(mtab.cd_processo,0)        as cd_processo,
											   ISNULL(mtab.ic_grid_menu,'N')     as ic_grid_menu
	                                    from egisadmin.dbo.Menu_Tabsheet mtab 
										     inner join EGISADMIN.dbo.Tabsheet tab on tab.cd_tabsheet = mtab.cd_tabsheet
								             inner join egisadmin.dbo.menu mc on mc.cd_menu = mtab.cd_menu
	                                     where
										   mtab.cd_menu = m.cd_menu  
										   and
										   ISNULL(mtab.ic_ativa,'S')='S' 

										 order by mtab.qt_ordem_tabsheet FOR JSON PATH),''),


	@cd_parametro_menu   = isnull(m.cd_parametro,0),
    @ic_cliente          = isnull(m.ic_cliente,'N'),
    
    @ic_selecao_registro = case when isnull(m.cd_form_modal,0)>0 
                           then 'S' 
                           else
                             case when @sqlTabsheet<>'' then 'S'
                             else
                               isnull(m.ic_selecao_registro,'N')
                             end
                           end,

    @cd_form_modal       = isnull(m.cd_form_modal,0),
    @cd_relatorio        = isnull(m.cd_relatorio,0),     
    @ic_card_menu        = isnull(m.ic_card_menu,'N'),
    @ic_treeview_menu    = isnull(m.ic_treeview_menu,'N')

	--select * from egisadmin.dbo.menu_tabsheet
	--select * from egisadmin.dbo.tabsheet


  from
     EGISADMIN.dbo.Menu m
	 left outer join EGISADMIN.dbo.modelo_carga_dados mdc on mdc.cd_menu = m.cd_menu
	 left outer join EGISADMIN.dbo.menu_relatorio mt      on mt.cd_menu  = m.cd_menu

  where
    m.cd_menu = @cd_menu

end

------Processo inicial-------------------------------------------------------------------------------------------------

if @cd_menu_processo>0
begin
  set @ic_menu_processo = 'S'
end



  --select * from egisadmin.dbo.menu_detalhe where cd_menu = 6434
  --Dados da Tabela--------------------------------------------------------

  --Menu sem Procedure e com Tabela----------------------------------------------------------------------------------------
  --sp_addlinkedserver 'EGISADMIN'

  if @nome_procedure='' 
  begin
    
    --select * from
	--  INFORMATION_SCHEMA.COLUMNS
    --where
	--  TABLE_NAME = @nm_tabela_origem


    select * into #TabTemp
	from
	  INFORMATION_SCHEMA.COLUMNS
    where
	  TABLE_NAME = @nm_tabela_origem

    --select * from #TabTemp

    --union all

    select distinct nm_tabela, ic_sap_admin into #Tabela from egisadmin.dbo.tabela where nm_tabela = @nm_tabela_origem

      insert into #TabTemp
	  select i.* 
      --into #TabTempAdmin

      from 
        EGISADMIN.INFORMATION_SCHEMA.COLUMNS i
        --inner join egisadmin.dbo.tabela t on t.nm_tabela = @nm_tabela_origem
        inner join #Tabela t on t.nm_tabela = @nm_tabela_origem
	  where
	    i.TABLE_NAME = @nm_tabela_origem
        and
        isnull(t.ic_sap_admin,'N') = 'S' 
        and
        t.nm_tabela not in ( select TABLE_NAME from #TabTemp x where t.nm_tabela = x.TABLE_NAME) 

    --select * from #TabTemp

    ---------------------------------------------------
    --select * from #TabTemp

       SELECT   
         --distinct 
	     @cd_menu                        as cd_menu,
         isnull(mta.cd_ordem_tabsheet,0) as qt_ordem_tabsheet,
		 
		 case when isnull(tab.cd_tabsheet,0)>0 
		 then
		   tab.cd_tabsheet
		 else
		    1
		 end                             as cd_tabsheet,

         case when isnull(tab.nm_tabsheet,'')<>'' then     
            isnull(tab.nm_tabsheet,'Cadastro') 
          else
          'Cadastro'
         end                             as nm_tabsheet,  --select * from egisadmin.dbo.tabela
     	a.cd_tabela, 
     	t.nm_tabela,
     	a.cd_atributo, 
     	a.ic_numeracao_automatica,
         a.ic_atributo_chave,
     	a.ic_chave_estrangeira,
		a.nu_ordem, 
     	a.nm_atributo,
     	a.nm_atributo_consulta, 
     	a.ds_atributo, 		
        isnull(a.nm_campo_mostra_combo_box,'')                                    as nm_campo_mostra_combo_box,
	    case when ISNULL(mtb.nm_titulo_menu_atributo,'')=''
	    then
	      a.nm_atributo_consulta
        else
        mtb.nm_titulo_menu_atributo
	    end                                                                        as nm_titulo_menu_atributo,

        case when isnull(a.ic_chave_estrangeira,'N')='S' 
        then
        'Código '
	 
	    +

        a.nm_atributo_consulta
 
        else
          cast('' as char(1))
        end

                                                                                  as nm_atributo_lookup,		 	
		
				
		isnull(a.ic_data_hoje,'N')          as ic_data_hoje,
     	isnull(a.ic_mostra_grid,'N')        as ic_mostra_grid,
     	a.ic_edita_cadastro,
         a.ic_mostra_relatorio,
         a.ic_mostra_cadastro,
     	isnull(a.ic_contador_grid,'N')      as ic_contador_grid,
     	isnull(a.ic_total_grid,'N')         as ic_total_grid,
     	isnull(a.ic_filtro_atributo,'N')    as ic_filtro,
     	case when isnull(a.vl_default,'')='' then
     	 CAST('' as char(1))
         else
         isnull(a.vl_default,'') 
     	end                                 as vl_default,
     	a.ds_campo_help,
     
     	--ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,
     
	    case when isnull(@nm_menu_titulo,'')='' then
     	t.nm_tabela     
		else
		 @nm_menu_titulo
		end                                 as nm_titulo,
	    case when isnull(@nm_menu_titulo,'')='' then
     	t.nm_tabela 
		else
		@nm_menu_titulo
		end                                    as nm_titulo_form,
        
   	    
     	nm_lookup_tabela = 
         case when isnull(a.nm_tabela_combo_box,'')<>'' and isnull(a.ic_chave_estrangeira,'N')='S'
         then
         'Select ' + 
           a.nm_campo_chave_combo_box + ' as '+a.nm_campo_chave_combo_box +
        ', ' + 
       isnull(a.nm_campo_mostra_combo_box,'') +' as Descricao' +
        + ' from '+ case when isnull(a.ic_aliasadmin_combo_box,'N')='S' then 'egisadmin.dbo.' else cast('' as char(1)) end 
		+
		a.nm_tabela_combo_box +' order by ' + a.nm_campo_mostra_combo_box
       else
         cast('' as varchar(10)) 
       end,
       
	   case when ISNULL(na.nm_formato,'')<>'' then
	      na.nm_formato
	   else
          isnull(na.nm_datatype,'')                
	   end                                               as nm_datatype,
     
        case when ISNULL(na.nm_formato,'')<>'' then
	      na.nm_formato
	   else
          isnull(na.nm_datatype,'')                
	   end                                               as nm_formato,
    
       --Lista de Valores---
       case when isnull(a.ic_lista_valor,'N')='S' then
         isnull((select  a.nm_atributo, a.nm_atributo_consulta, alv.* from egisadmin.dbo.Atributo_Lista_Valor alv where alv.cd_tabela = a.cd_tabela and alv.cd_atributo = a.cd_atributo FOR JSON AUTO),'N')  
       else
         cast('' as char(1))
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
       end                                          as ic_crud_processo,
	   case when ISNULL(@nome_procedure,'')=''
	   then 
	     '*'
	   else
	     @nome_procedure
	   end             	                            as nome_procedure,
   	   --Grafico--
       isnull(ag.tipo_grafico,'')                   as tipo_grafico,
       isnull(ag.agrupador_base,'')                 as agrupador_base,
       isnull(ag.cor,'')                            as Cor,
       isnull(ag.ordem,'')                          as ordem,
	   isnull(a.ic_pesquisa_atributo,'N')           as ic_pesquisa_atributo,
	   @ic_menu_processo                            as ic_menu_processo,
	   @cd_menu_processo                            as cd_menu_processo,
	   isnull(a.ic_retorno_atributo,'N')            as ic_retorno_atributo,
	   @ic_dashboard_menu                           as ic_dashboard_menu,
	   
	   case when ISNULL(a.cd_menu_pesquisa,0)>0 then
	     a.cd_menu_pesquisa
       else
	     isnull(map.cd_menu,0)
	   end                                          as cd_menu_pesquisa,

	   case when isnull(mtb.cd_menu_tabela_atributo,0) = 0 then
	   'N'
	   else
	   'S'
	   end                                                                        as ic_formulario,
   

	   isnull(mtb.ic_item_dinamico,'N')                                           as ic_item_dinamico,
       isnull(mtb.ic_editado,'N')                                                 as ic_editado,
       isnull(mtb.ic_calculado,'N')                                               as ic_calculado,
	   isnull(CAST(mtb.ds_formula as nvarchar(max)),'')                           as ds_formula,
	   case when isnull(cast(mtb.ds_atributo_validacao as nvarchar(max)),'')<>'' then
	     ltrim(rtrim( isnull(CAST(mtb.ds_atributo_validacao as nvarchar(max)),'')))
	   else
	     
		 case when isnull(a.nm_tabela_combo_box,'')<>'' and isnull(a.ic_chave_estrangeira,'N')='S' and  isnull(map.cd_menu,0)>0 
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
	   isnull(mtb.qt_ordem_atributo,0)                                            as qt_ordem_atributo,
	   @sqlTabsheet                                                               as sqlTabs,
	   @ic_item_edicao                                                            as ic_item_edicao,
	   @ic_json_parametro                                                         as ic_json_parametro,
	   @ic_acoes_menu                                                             as ic_acoes_menu,
	   ISNULL(t.ic_sap_admin,'N')                                                 as ic_admin,
       @cd_parametro_menu                                                         as cd_parametro_menu,
       isnull(t.ic_parametro_tabela,'N')                                          as ic_parametro_tabela,
       isnull(@ic_cliente,'N')                                                    as ic_cliente,
       isnull(a.ic_doc_caminho_atributo,'N')                                      as ic_doc_caminho_atributo,
       isnull(a.ic_modal_atributo,'N')                                            as ic_modal_atributo,
       @cd_menu_modal                                                             as cd_menu_modal,
       isnull(@ic_selecao_registro,'N')                                           as ic_selecao_registro,
       isnull(@cd_form_modal,0)                                                   as cd_form_modal,
       isnull(fm.ic_grid_modal,'')                                                as ic_grid_modal,
       isnull(a.ic_data_padrao,'N')                                               as ic_data_padrao,
       @cd_relatorio                                                              as cd_relatorio,
       isnull(a.cd_relatorio,0)                                                   as cd_atributo_relatorio,
       isnull(@ic_card_menu,'N')                                                  as ic_card_menu,
       isnull(@ic_treeview_menu,'N')                                              as ic_treeview_menu,
       isnull(a.ic_atributo_pai,'N')                                              as ic_atributo_pai,
       isnull(a.ic_atributo_filho,'N')                                            as ic_atributo_filho,
       isnull(a.ic_treeview_atributo,'N')                                         as ic_treeview_atributo

            
       into #Resultado
      --select * from egisadmin.dbo.menu_tabsheet
     
       FROM
	    EGISADMIN.DBO.TABELA T 
        left outer join #TabTemp isc                             on isc.TABLE_NAME           = T.NM_TABELA
     	--LEFT OUTER JOIN EGISADMIN.DBO.TABELA T                   on T.NM_TABELA              = TABLE_NAME
     	LEFT OUTER JOIN EGISADMIN.DBO.ATRIBUTO A                 on A.CD_TABELA              = T.CD_TABELA AND A.NM_ATRIBUTO = COLUMN_NAME
     	left outer join egisadmin.dbo.natureza_atributo na       on na.cd_natureza_atributo  = a.cd_natureza_atributo --select * from  egisadmin.dbo.natureza_atributo  
     	left outer join egisadmin.dbo.tabsheet tab               on tab.cd_tabsheet          = case when isnull(a.cd_tabsheet,0)>0 then A.cd_tabsheet else @cd_tabsheet end
     	left outer join EGISADMIN.dbo.Tabela_Tabsheet mta        on mta.cd_tabsheet          = a.cd_tabsheet and mta.cd_tabela = T.cd_tabela
		LEFT outer join egisadmin.dbo.atributo_grafico ag        on ag.cd_menu               = @cd_menu      and ag.nm_atributo = a.nm_atributo
        left outer join EGISADMIN.dbo.menu_atributo_pesquisa map on map.nm_atributo_pesquisa = a.nm_atributo and isnull(a.ic_chave_estrangeira,'N')='S'
		left outer join EGISADMIN.dbo.Menu_Tabela_Atributo mtb   on mtb.cd_menu              = @cd_menu      and
		                                                            mtb.cd_tabela            = T.cd_tabela   and
																	--tmb.cd_atributo          = A.cd_atributo and
																	mtb.nm_menu_atributo     = A.nm_atributo
        left outer join egisadmin.dbo.Modal fm                   on fm.cd_modal              = @cd_form_modal

       WHERE
         --TABLE_NAME = @nm_tabela_origem
		 t.nm_tabela = @nm_tabela_origem
         and
         ISNULL(a.ic_mostra_grid,'N') = 'S'
         and
         ISNULL(a.nm_atributo_consulta,'')<>''

		 --teste ccf
         --and 
		 --ic_formulario = 'S'
		  -- AND isnull(mtb.cd_menu_tabela_atributo,0) > 0

       order by
         1,		 
         A.nu_ordem 
     
       if @ic_modal_pesquisa='S'
       begin
         ------------------------------------------------------
         select * from #Resultado
         where
           (ic_modal_atributo='S' or ic_atributo_chave='S')
         order by
           cd_menu, nu_ordem
         ------------------------------------------------------
       end
       else
       begin
         select * from #Resultado
         order by
           cd_menu, nu_ordem
       end

  end

  --Procedures-------------------------------------------------------------------------------------------------------------
  --select @nome_procedure

  if @nome_procedure<>'' 
  begin
     
       SELECT   
	     m.cd_menu,
         --isnull(mta.cd_ordem_tabsheet,0) as qt_ordem_tabsheet,
		 1                                   as qt_ordem_tabsheet,
		 1                                   as cd_tabsheeet,
		 'Dados'                             as nm_tabsheet,

         --case when isnull(tab.nm_tabsheet,'')<>'' then     
         --   isnull(tab.nm_tabsheet,'Cadastro') 
         -- else
         -- 'Cadastro'
         --end                             as nm_tabsheet,

     	cast(0 as int)                       as cd_tabela, 
     	mpc.nome_procedure                   as nm_tabela,
     	mpc.ordem_coluna                     as cd_atributo, 
     	'N'                                  as ic_numeracao_automatica,
        'N'                                  as ic_atributo_chave,
     	'N'                                  as ic_chave_estrangeira,
     	mpc.nome_coluna                      as nm_atributo,
     	mpc.titulo_exibicao                  as nm_atributo_consulta, 
     	mpc.titulo_exibicao                  as ds_atributo,
		mpc.ordem_coluna                     as nu_ordem, 
     	'N'                                  as ic_data_hoje,
		case when visivel = 1 
		then 'S' else 'N' end                as ic_mostra_grid,     	
     	'N'                                  as ic_edita_cadastro,
         case when visivel = 1 
		 then 'S' else 'N'
		 end                                 as ic_mostra_relatorio,
         case when visivel = 1 
		 then 'S' else 'N'
		 end                                 as ic_mostra_cadastro,
		 case when contagem = 1
		 then 'S' else 'N'
		 end       	                         as ic_contador_grid,
     	 case when soma = 1
		 then 'S' else 'N'
		 end
		                                     as ic_total_grid,

     	 isnull('S','S')                     as ic_filtro,
     	 CAST('' as char(1))                 as vl_default,
		titulo_exibicao                      as ds_campo_help,
     
     	--ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,
     
     	m.nm_menu                            as nm_titulo,
     	m.nm_menu_titulo                     as nm_titulo_form,
     
     	nm_lookup_tabela = cast('' as varchar(1)),
       
	   case when isnull(mpc.formato_coluna,'')<>'' then
	     mpc.formato_coluna
	   else
         isnull(mpc.tipo_coluna,'')   
	   end                                          as nm_datatype, 

       case when isnull(mpc.formato_coluna,'')<>'' then
	     mpc.formato_coluna
	   else
         isnull(mpc.tipo_coluna,'')   
	   end                                          as nm_formato, 
     
       --Lista de Valores---

       cast('' as varchar(1))                       as Lista_Valor,
       @ic_detalhe_menu                             as ic_detalhe_menu,
       @sqlMenu                                     as tab_menu,
     
       isnull('N','N')                              as ic_grid_agrupado_atributo,  		
       isnull('N','N')                              as ic_listview_cabecalho,
       isnull('N','N')                              as ic_listview_rodape,
       @ic_registro_tabela_menu                     as ic_registro_tabela_menu,
       @ic_importacao_menu                          as ic_importacao_menu,
       @ic_upload_menu                              as ic_upload_menu,
       @ic_relatorio_menu                           as ic_relatorio_menu,
       @ic_filtro_obrigatorio                       as ic_filtro_obrigatorio,
       ISNULL('N','N')                              as ic_kanban_atributo,
	   --menu
	   case when ISNULL(m.ic_crud_processo,'N') = 'N' then
	     isnull(m.ic_crud_processo,'N')
       else
         case when @cd_tabela>0 then
          @ic_crud_processo
         else
          'N'
         end
       end                                          as ic_crud_processo,

	   @nome_procedure                              as nome_procedure,

	   --Grafico--
	   case when ISNULL(mpc.tipo_grafico,'')<>'' then
	     mpc.tipo_grafico
	   else
       isnull(ag.tipo_grafico,'')   
	   end                                          as tipo_grafico,
	   case when ISNULL(mpc.agrupador_base,'')<>'' then
	      mpc.agrupador_base
	   else
       isnull(ag.agrupador_base,'')      
	   end                                          as agrupador_base,
	   case when ISNULL(mpc.cor,'')<>'' then
	     mpc.cor
       else
         isnull(ag.cor,'')
	   end       	                                as Cor,
       isnull(ag.ordem,'')                          as ordem,
	   isnull(mpc.ativo,1)                          as ativo,
	   'N'                                          as ic_pesquisa_atributo,
	   @ic_menu_processo                            as ic_menu_processo,
	   @cd_menu_processo                            as cd_menu_processo,
	   isnull(mtb.ic_retorno_atributo,'N')          as ic_retorno_atributo,
	   isnull(m.ic_dashboard_menu,'N')              as ic_dashboard_menu,
	   isnull(map.cd_menu,0)                        as cd_menu_pesquisa,
	   
	   case when isnull(mtb.cd_menu_tabela_atributo,0) = 0 then
	   'N'
	   else
	   'S'
	   end                                           as ic_formulario,

	   case when ISNULL(mtb.nm_titulo_menu_atributo,'')=''
	   then
	    -- mpc.nome_coluna
		mpc.titulo_exibicao 
       else
       mtb.nm_titulo_menu_atributo
	   end                                                                        as nm_titulo_menu_atributo,
       isnull(mtb.ic_item_dinamico,'N')                                           as ic_item_dinamico,
       isnull(mtb.ic_editado,'N')                                                 as ic_editado,
       isnull(mtb.ic_calculado,'N')                                               as ic_calculado,
	   isnull(CAST(mtb.ds_formula as nvarchar(max)),'')                           as ds_formula,
	   ltrim(rtrim( isnull(CAST(mtb.ds_atributo_validacao as nvarchar(max)),''))) as ds_atributo_validacao,
	   isnull(mtb.qt_ordem_atributo,0)                                            as qt_ordem_atributo,
	   @sqlTabsheet                                                               as sqlTabs,
	   @ic_item_edicao                                                            as ic_item_edicao,
       case when m.ic_json_parametro is null then
         'S'
       else
	      isnull(m.ic_json_parametro,'S')  
       end                                                                        as ic_json_parametro,
	   ISNULL(mtb.ic_filtro_dinamico,'N')                                         as ic_filtro_dinamico,
	   isnull(m.ic_acoes_menu,'N')                                                as ic_acoes_menu,
	   'N'                                                                        as ic_admin,
       isnull(m.cd_parametro, isnull(@cd_parametro_menu,0))                       as cd_parametro_menu,
       --Verificar--
       isnull('S','N')                                                            as ic_parametro_tabela,
       isnull(m.ic_cliente,'N')                                                   as ic_cliente,
       cast(isnull('N','N') as char(1))                                           as ic_doc_caminho_atributo,

       --Por enquanto-- Podemos ter Modal também nos menus de Procedures --CCF--02/12/2025

       'N'                                                                        as ic_modal_atributo,
       case when isnull(mm.cd_menu_modal,0)>0 then 
         mm.cd_menu_modal
       else
         @cd_menu_modal
       end                                                                        as cd_menu_modal,
       case when isnull(m.cd_form_modal,0)>0 then 'S'
       else
         case when @sqlTabsheet<>'' then 'S'
         else
           isnull(m.ic_selecao_registro,'N')
         end
       end                                                                        as ic_selecao_registro,
       isnull(m.cd_form_modal,0)                                                  as cd_form_modal,
       isnull(fm.ic_grid_modal,'')                                                as ic_grid_modal,
       --Verificar uma Forma Automática--
       isnull('N','N')                                                            as ic_data_padrao,
       ----------------
       isnull(m.cd_relatorio,0)                                                   as cd_relatorio,
       isnull(0,0)                                                                as cd_atributo_relatorio,
       isnull(m.ic_card_menu,'N')                                                 as ic_card_menu,
       isnull(m.ic_treeview_menu,'N')                                             as ic_treeview_menu,
       isnull('N','N')                                                            as ic_atributo_pai,
       isnull('N','N')                                                            as ic_atributo_filho,
       isnull('N','N')                                                            as ic_treeview_atributo


       -----------------------------------------------------------------------------------------------
       
       -- into #Resultado
      --select * from egisadmin.dbo.menu_tabsheet
      --select * from egisadmin.dbo.menu_modal
      
     
       FROM
         EGISADMIN.dbo.meta_procedure_colunas mpc
		 inner join EGISADMIN.dbo.Menu m                          on m.cd_menu         = mpc.cd_menu_id
         left outer join egisadmin.dbo.Modal fm                   on fm.cd_modal       = m.cd_form_modal
         left outer join egisadmin.dbo.Menu_Modal mm              on mm.cd_menu_origem = mpc.cd_menu_id
		 LEFT outer join egisadmin.dbo.atributo_grafico ag        on ag.cd_menu = m.cd_menu and ag.nm_atributo = mpc.nome_coluna
		 left outer join EGISADMIN.dbo.menu_atributo_pesquisa map on map.nm_atributo_pesquisa = mpc.nome_coluna and 1=2
  		 left outer join EGISADMIN.dbo.Menu_Tabela_Atributo mtb   on mtb.cd_menu              = @cd_menu      and
		                                                             --mtb.cd_tabela            = 9999       and  --sem tabela por enquanto
																	--tmb.cd_atributo          = A.cd_atributo and
																	 mtb.nm_menu_atributo     = mpc.nome_coluna



     	--LEFT OUTER JOIN EGISADMIN.DBO.TABELA T             on T.NM_TABELA             = TABLE_NAME
     	--LEFT OUTER JOIN EGISADMIN.DBO.ATRIBUTO A           on A.CD_TABELA             = T.CD_TABELA AND A.NM_ATRIBUTO = COLUMN_NAME
     	--left outer join egisadmin.dbo.natureza_atributo na on na.cd_natureza_atributo = a.cd_natureza_atributo --select * from  egisadmin.dbo.natureza_atributo  
		 --left outer join EGISADMIN.dbo.Menu_Tabsheet mta    on mta.cd_tabsheet         = a.cd_tabsheet and mta.cd_tabela = T.cd_tabela

		-->>> como 
     	--left outer join egisadmin.dbo.tabsheet tab         on tab.cd_tabsheet         = a.cd_tabsheet
     	    
       WHERE
         nome_procedure = @nome_procedure
         and
         ISNULL(mpc.visivel,0) = 1
		 and
		 mpc.cd_menu_id = @cd_menu
     
	 --select * from meta_procedure_colunas

       order by
         1,
         isnull(mpc.qt_ordem_coluna,ordem_coluna)

     
     
  end

  --select @nome_procedure, @cd_menu

  --select * from meta_procedure_colunas
  --select * from  INFORMATION_SCHEMA.COLUMNS

	--select * from egisadmin.dbo.tabela_tabsheet where cd_tabela = 148
	--select @cd_menu

  --WHERE TABLE_NAME = 'Requisicao_Interna';

  --select * from #Resultado
  --order by
  --  1, nu_ordem

  


go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_payload_tabela 
------------------------------------------------------------------------------
--exec pr_egis_payload_tabela '[{"cd_parametro":1,"cd_menu":"8820","cd_usuario":"4772","dt_inicial":"2025-05-01 00:00:00","dt_final":"2025-05-31 00:00:00"}]'
------------------------------------------------------------------------------
--com atributos apenas do modal--
--exec pr_egis_payload_tabela '[{"cd_parametro":1,"cd_menu":"8518","cd_usuario":"4772","ic_modal_pesquisa" : "S" }]'
------------------------------------------------------------------------------

--use egissql_363
--go
--exec pr_egis_payload_tabela '[{"cd_parametro":1,"cd_menu":"8269","cd_usuario":"4772","dt_inicial":"2025-05-01 00:00:00","dt_final":"2025-05-31 00:00:00"}]'

--------------------------------------------------------------------------------------------------------------------------------
--pr_egis_payload_tabela           --> Estrutura das Tabelas
--pr_egis_pesquisa_dados           --> Consulta dos Dados da Tabela
--pr_egis_api_crud_dados_especial  --> insert . update . delete 
------------------------------------------------------------------------------------------------------------------------------------------------------------
--exec pr_egis_payload_tabela '[{"cd_parametro":1,"cd_menu":"8820","cd_usuario":"4772","dt_inicial":"2025-05-01 00:00:00","dt_final":"2025-05-31 00:00:00"}]'
------------------------------------------------------------------------------------------------------------------------------------------------------------
--exec pr_egis_payload_tabela '[{"cd_parametro":1,"cd_menu":"8104","cd_usuario":"4772","dt_inicial":"2025-05-01 00:00:00","dt_final":"2025-05-31 00:00:00"}]'
------------------------------------------------------------------------------------------------------------------------------------------------------------
--Select cd_empresa as cd_empresa, nm_empresa as Descricao from  vw_empresa order by nm_empresa

--exec pr_egis_payload_tabela '[
--    {
--        "cd_parametro": 1,
--        "cd_form": "0",
--        "cd_menu": 6125,
--        "nm_tabela_origem": "",
--        "cd_usuario": "5056"
--    }
--]'

--select * from egisadmin.dbo.menu
/*
'[{
    "cd_form": 0,
	"cd_menu" : "8115", 
	"nm_tabela_origem": "",
	"cd_usuario": 1
}]'
*/

go

--select cd_relatorio, * from egisadmin.dbo.menu where cd_menu = 
--use egissql_329
--select * from egisadmin.dbo.Tabela_Tabsheet_Atributo where cd_tabela = 148
--select * from egisadmin.dbo.Tabela_Tabsheet where cd_tabela = 148
--select * from egisadmin.dbo.Tabsheet where cd_tabsheet = 60
--select * from egisadmin.dbo.Menu_Tabela_Atributo where cd_tabela = 148
--select * from egisadmin.dbo.
--select cd_tabsheet, * from egisadmin.dbo.Atributo where cd_tabela = 424
--select * from egisadmin.dbo.menu where cd_menu = 6437

--use egissql_decora
--select * from egisadmin.dbo.form where cd_form = 167
--select * from egisadmin.dbo.atributo_lista_valor where cd_tabela = 148

--