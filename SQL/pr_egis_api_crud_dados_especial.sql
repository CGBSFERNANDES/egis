 --BANCO DA EMPRESA
--------------------
--USE EGISadmin

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_api_crud_dados_especial' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_api_crud_dados_especial

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_api_crud_dados_especial
-------------------------------------------------------------------------------
--pr_egis_api_crud_dados_especial
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--                   Alexandre
--
--Banco de Dados   : Egissql - Banco do Cliente
--
--Objetivo         : Procedure de Insert/Update/Exclusão/Log/Consulta/Relatório
--                  de Form Especial
--
--Data             : 21.06.2024
--Alteração        : 24.08.2024
--
------------------------------------------------------------------------------
create procedure pr_egis_api_crud_dados_especial

@json nvarchar(max) = ''

--with encryption

as


declare @cd_empresa             int = 0
declare @cd_modulo_form         int = 0
declare @cd_modulo              int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento_form      int = 0
declare @cd_item_documento_form int = 0
declare @cd_parametro           int = 0
declare @retorno_chave          nvarchar(max) = ''    
declare @nm_tabela              varchar(80)   = ''
declare @nm_atributo            varchar(200)  = ''
declare @ic_chave_incremento    char(1) = 'N'
declare @ic_atributo_chave      char(1) = 'N'
declare @ic_chave_estrangeira   char(1) = 'N'
declare @nm_atributo_chave      nvarchar(max) = ''
declare @nm_atributo_where      nvarchar(max) = '' 
declare @nm_atributo_pai        nvarchar(max) = ''
declare @nm_atributo_incremento nvarchar(max) = ''
declare @vl_atributo_pai        nvarchar(max) = ''
declare @where_filtro           nvarchar(max) = ''
declare @ParamDefinition        nvarchar(max) = ''
declare @nm_chave               nvarchar(max) = ''   --Chave
declare @campos                 nvarchar(max) = ''
declare @inclusao               nvarchar(max) = ''
declare @cd_natureza_atributo   int
declare @qt_tamanho_atributo    int
declare @campo                  varchar(80)   = ''
declare @chave                  char(1)       = 'N'
declare @valor                  nvarchar(max) = ''
declare @iusuario               int           = 0
declare @cd_menu                int           = 0
declare @dsAux                  nvarchar(max) = ''
declare @ds_log                 nvarchar(max) = ''
declare @cd_cliente_form        int           = 0
declare @cd_contato_form        int           = 0
declare @cd_tipo_email          int           = 0
declare @cd_mensagem            int           = 0
declare @cd_processo            int           = 0
declare @lookup_formEspecial    nvarchar(max) = ''
declare @ic_tipo_atributo       int           = 0
declare @registroJson           nvarchar(max) = ''
declare @CampoChave             SYSNAME = 'cd_documento_form';  -- ou parâmetro
DECLARE @Db                     SYSNAME;
DECLARE @Schema                 SYSNAME;
DECLARE @Tabela                 SYSNAME;

set @json              = ISNULL(@json,'')
set @cd_parametro      = 0
set @retorno_chave     = ''
set @cd_modulo_form    = 0
set @cd_modulo         = 0
set @cd_empresa        = 0
set @cd_form           = 0
set @cd_documento_form = 0
set @iusuario          = 0
set @dsAux             = ''
set @cd_cliente_form   = 0
set @cd_contato_form   = 0
set @cd_mensagem       = 0
set @cd_processo       = 0

--select * from egisadmin.dbo.form

select                     

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]                                      as valor,
 cast('' as char(1))                                  as chave
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

--tabela de json
--select * from #json


select @cd_empresa             = case when valor = 'null' then null else valor end from #json where campo = 'cd_empresa'             
select @cd_modulo_form         = case when valor = 'null' then null else valor end from #json where campo = 'cd_modulo_form'             
select @cd_form                = case when valor = 'null' then null else valor end from #json where campo = 'cd_form'             
select @cd_documento_form      = case when valor = 'null' then null else valor end from #json where campo = 'cd_documento_form'
select @cd_item_documento_form = case when valor = 'null' then null else valor end from #json where campo = 'cd_item_documento_form'
select @cd_parametro           = case when valor = 'null' then null else valor end from #json where campo = 'cd_parametro_form'          
select @cd_usuario             = case when valor = 'null' then null else valor end from #json where campo = 'cd_usuario'             
select @dt_usuario             = case when valor = 'null' then null else valor end from #json where campo = 'dt_usuario'
select @cd_menu                = case when valor = 'null' then null else valor end from #json where campo = 'cd_menu'
select @cd_cliente_form        = case when valor = 'null' then null else valor end from #json where campo = 'cd_cliente_form' 
select @cd_contato_form        = case when valor = 'null' then null else valor end from #json where campo = 'cd_contato_form'
select @lookup_formEspecial    = case when valor = 'null' then null else valor end from #json where campo = 'lookup_formEspecial'

--set @dt_usuario = getdate()

if isnull(@lookup_formEspecial,'{}') <> '{}' --Atualiza a tabela vinculada ao Atributo
begin

declare @nm_valor_inicial_atributo       nvarchar(max) = ''
declare @cd_tabela_pesquisa_lookup       int = 0
declare @nm_campo_chave_combo_box_lookup nvarchar(max) = ''
declare @nm_tabela_lookup                nvarchar(max) = ''
declare @chave_tabela_lookup             nvarchar(max) = ''
declare @camposUpdateLookup              nvarchar(max) = ''
declare @sqlUpdateLookup                 nvarchar(max) = ''

select @nm_valor_inicial_atributo       = [value]   from openjson(@lookup_formEspecial)root where [key] = 'nm_valor_inicial'                     
select @cd_tabela_pesquisa_lookup       = [value]   from openjson(@lookup_formEspecial)root where [key] = 'cd_tabela_pesquisa'  
select @nm_campo_chave_combo_box_lookup = [value]   from openjson(@lookup_formEspecial)root where [key] = 'nm_campo_chave_combo_box'  

--select @nm_valor_inicial_atributo, @cd_tabela_pesquisa_lookup, @nm_campo_chave_combo_box_lookup 
--select [key], [value] from openjson(@lookup_formEspecial)root

select @chave_tabela_lookup = [value]   from openjson(@nm_valor_inicial_atributo)root where [key] = @nm_campo_chave_combo_box_lookup  

   
-----------------------------------------------------------------------------------------------------------------------------------------------------

SELECT @camposUpdateLookup = STUFF((
    SELECT ', ' + 
           [key] + ' = ' +
           CASE 
               WHEN ISNUMERIC([value]) = 1 AND [value] NOT LIKE '%[^0-9]%' THEN [value]  -- inteiro
               ELSE '''' + REPLACE([value], '''', '''''') + '''' -- string, com tratamento de aspas
           END
    FROM OPENJSON(@nm_valor_inicial_atributo)
    WHERE [key] <> @nm_campo_chave_combo_box_lookup
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')
, 1, 2, '');

   --------------

select top 1 @nm_tabela_lookup = nm_tabela from egisadmin.dbo.tabela where cd_tabela = @cd_tabela_pesquisa_lookup

set @sqlUpdateLookup = 'update '+@nm_tabela_lookup+' set '+@camposUpdateLookup
+' where '+@nm_campo_chave_combo_box_lookup+' = '+@chave_tabela_lookup

 exec(@sqlUpdateLookup)

--select @sqlUpdateLookup -- select cd_telefone,* from Cliente where cd_cliente = 678 

end

--Usuário e Data---

update
  #json
set
  valor = @cd_usuario
where
  campo = 'cd_usuario' 

--select * from #json

--update
--  #json
--set
--  valor = GETDATE()
--where
--  campo = 'dt_usuario'


--select * from #json
--select * from egisadmin.dbo.processo_sistema

--Tabela Temporária com os Dados do Form e Atributos---

select 
 f.cd_tabela,
 f.cd_atributo,
 f.ic_tipo_atributo,
 isnull(f.ic_chave_incremento,'N')                              as ic_chave_incremento,
 t.nm_tabela,
 isnull(a.nm_atributo,'')  COLLATE SQL_Latin1_General_CP1_CI_AI as nm_atributo,
 a.ds_atributo,
 isnull(a.ic_atributo_chave,'N')                                as ic_atributo_chave,
 isnull(a.ic_chave_estrangeira,'N')                             as ic_chave_estrangeira,
 a.qt_tamanho_atributo,
 a.cd_natureza_atributo,
 ISNULL(f.vl_padrao_atributo,'')                                as vl_padrao_atributo,
 ISNULL(f.ic_hora_atributo,'N')                                 as ic_hora_atributo,
 ISNULL(fo.cd_tipo_email,0)                                     as cd_tipo_email,
 ISNULL(fo.cd_mensagem,0)                                       as cd_mensagem,
 ISNULL(fo.cd_processo,0)                                       as cd_processo,
 isnull(t.ic_sap_admin,'N')                                     as ic_admin

into
  #AtributoForm

from
  egisadmin.dbo.form_tabSheet_atributo f --select * from egisadmin.dbo.Form  where cd_form = 53
  inner join egisadmin.dbo.tabela t    on t.cd_tabela = f.cd_tabela
  inner join egisadmin.dbo.atributo a  on a.cd_tabela = f.cd_tabela and a.cd_atributo = f.cd_atributo --select * from egisadmin.dbo.atributo where cd_tabela = 148
  inner join EGISADMIN.dbo.Form fo     on fo.cd_form  = f.cd_form

where
  f.cd_form = @cd_form 
  and
  1=2

  --temporariamente CCF
  set @cd_form = 0

  --select * from #AtributoForm 
-----------------------------------------------------------------------------------------------------------------------------------------------------

if @cd_menu>0 and @cd_form = 0
begin

--select * from egisadmin.dbo.atributo

select 
 t.cd_tabela,
 a.cd_atributo,
 cast('2' as char(1))                                               as ic_tipo_atributo,                             
 isnull(a.ic_numeracao_automatica,'N')                              as ic_chave_incremento,
 t.nm_tabela,
 isnull(a.nm_atributo,'')  COLLATE SQL_Latin1_General_CP1_CI_AI as nm_atributo,
 a.ds_atributo,
 isnull(a.ic_atributo_chave,'N')                                as ic_atributo_chave,
 isnull(a.ic_chave_estrangeira,'N')                             as ic_chave_estrangeira,
 a.qt_tamanho_atributo,
 a.cd_natureza_atributo,
 ISNULL(a.vl_default,'')                                        as vl_padrao_atributo,
 ISNULL('N','N')                                                as ic_hora_atributo,
 ISNULL(0,0)                                                    as cd_tipo_email,
 ISNULL(0,0)                                                    as cd_mensagem,
 --ISNULL(0,0)                                                    as cd_processo,
isnull(( select top 1 mp.cd_processo_sistema from egisadmin.dbo.menu_processo mp 
   where
     mp.cd_menu = m.cd_menu ),0)                                as cd_processo,
 isnull(t.ic_sap_admin,'N')                                     as ic_admin

into
  #AtributoMenu

from
  EGISADMIN.dbo.menu m 
  inner join EGISADMIN.dbo.menu_tabela mt on mt.cd_menu  = m.cd_menu
  inner join egisadmin.dbo.tabela t       on t.cd_tabela = mt.cd_tabela
  inner join egisadmin.dbo.atributo a     on a.cd_tabela = t.cd_tabela 
  
  
where
  m.cd_menu = @cd_menu

--select * from #AtributoMenu

--RETURN

insert into #AtributoForm
select * from #AtributoMenu

--select * from #AtributoForm
--select * from #AtributoMenu
--return

end

-----------------------------------------------------------------------------------------------------------------------------------------------------

--select * from #AtributoForm
--return

--Atualiza o json com os Atributos Chaves----------------------------------------------------------

update
  #json
set
  chave = f.ic_atributo_chave
from
  #json j
  left outer join #AtributoForm f on f.nm_atributo = j.campo
where
  ic_atributo_chave = 'S'

  
  --select * from #json

--Verifica se o Form possui e-mail e WhatsApp---

select 
  top 1
  @cd_mensagem   = cd_mensagem,
  @cd_tipo_email = cd_tipo_email,
  @cd_processo   = cd_processo
from  
  #AtributoForm a
   
--select * from egisadmin.dbo.form_tabSheet_atributo
--select * from #AtributoForm
--return

--select 
--@cd_empresa             as cd_empresa,
--@cd_modulo              as cd_modulo,
--@cd_form                as cd_form,
--@cd_documento_form      as cd_documento_form,
--@cd_item_documento_form as cd_item_documento_form,
--@cd_parametro           as cd_parametro_form

--select @json



declare @sqlcampos varchar(8000) = ''
declare @id        int

set @sqlcampos = ''
set @id        = 0
set @campo     = ''

--select * from #json

--select @cd_cliente_form, @cd_contato_form
--return
select 

  --select dbo.fn_hora_agora(getdate()) as hora

  identity(int,1,1) as id,  
  campo = a.nm_atributo,
  valor = MAX(case when a.ic_hora_atributo='S' then
               cast(dbo.fn_hora_agora(GETDATE()) as varchar(5))
             else  
              case when a.nm_atributo='cd_cliente' and @cd_cliente_form>0 then
                LTRIM(rtrim(cast(@cd_cliente_form as varchar(9))))
   	          else   
    	         case when a.nm_atributo='cd_contato' and ISNULL(@cd_contato_form,0)<>0 then LTRIM(rtrim(cast(@cd_contato_form as varchar(9))))
		         else
				   case when ISNULL(valor,'')<>'' 
                   then valor 
			       else case when isnull(vl_padrao_atributo,'')<>'' then vl_padrao_atributo else cast('' as varchar) end
				   end
                 end
				end
			  end),
  
  MAX(a.nm_tabela)           as nm_tabela,
  
  a.cd_tabela,
  a.cd_atributo,
  max(a.nm_atributo)          as nm_atributo,
  max(a.ic_tipo_atributo)     as ic_tipo_atributo,
  MAX(a.ic_chave_incremento)  as ic_chave_incremento,
  MAX(a.ic_atributo_chave)    as ic_atributo_chave,
  MAX(a.ic_chave_estrangeira) as ic_chave_estrangeira,
  MAX(a.qt_tamanho_atributo)  as qt_tamanho_atributo,
  MAX(a.cd_natureza_atributo) as cd_natureza_atributo,
  MAX(a.vl_padrao_atributo)   as vl_padrao_atributo,
  MAX(a.ic_hora_atributo)     as ic_hora_atributo,
  max(a.ic_admin)             as ic_admin

into #aux 
from
  #AtributoForm a
  left outer join #json j     on j.campo = a.nm_atributo

where
	a.nm_atributo not in ('cd_usuario', 'dt_usuario')
  --inner join #AtributoForm a on a.nm_atributo  = j.campo
                                                         
group by 
 a.cd_tabela,
 a.cd_atributo,
 a.nm_atributo

 --j.campo,
 --j.valor

 --select * from #aux
-- return

 --Nova tabela para fazer abaixo a inclusao dos campos novamente, devido a mudanca de chave
------------------------------------
select * into #AuxInclusao from #aux
------------------------------------

set @campos = 'cd_usuario, dt_usuario'

---set @inclusao = cast(@cd_usuario as nvarchar(30))+',
--cast('''+CONVERT(VARCHAR, GETDATE(), 120)+''' as datetime) '

SET @inclusao =
  CAST(@cd_usuario AS nvarchar(30)) + ', cast(''' +
  CONVERT(varchar(23), SYSDATETIME(), 121) + ''' as datetime2(3))';

--select * from egisadmin.dbo.Form_TabSheet_Atributo where cd_form = 5
--select * from #aux

while exists ( select top 1 id from #aux)
begin

  select top 1
    @id                   = id,
	@campo                = campo,
	@nm_tabela            = case when ic_admin = 'S' then 'egisadmin.dbo.' else cast('' as varchar(1)) end + isnull(nm_tabela,''),
	@nm_atributo          = ISNULL(nm_atributo,''),

    @valor                = case when isnull(vl_padrao_atributo,'')<>'' then
	                           vl_padrao_atributo
							 else
							   ltrim(rtrim(valor))
                             end,

	@cd_natureza_atributo = cd_natureza_atributo,
	@qt_tamanho_atributo  = qt_tamanho_atributo,


	@nm_atributo_chave = case when isnull(ic_atributo_chave,'N') = 'S' and isnull(@nm_atributo_chave,'') = '' then nm_atributo						  
                              when isnull(ic_atributo_chave,'N') = 'S' and isnull(@nm_atributo_chave,'') <> '' then
	                               isnull(@nm_atributo_chave,'')+','+nm_atributo else @nm_atributo_chave end,

	@nm_atributo_pai = case when ISNULL(ic_chave_incremento,'N')  ='N'  and
	                             isnull(ic_atributo_chave,'N')    = 'S' and
	                             isnull(ic_chave_estrangeira,'N') = 'N' 
								 then nm_atributo	
	                   when isnull(ic_atributo_chave,'N') = 'S' and isnull(ic_chave_estrangeira,'N') = 'S' and isnull(@nm_atributo_pai,'') = '' 
	                   then nm_atributo						  
                            when isnull(ic_atributo_chave,'N') = 'S' and isnull(ic_chave_estrangeira,'N') = 'S' and isnull(@nm_atributo_pai,'') <> '' then
	                             isnull(@nm_atributo_pai,'')+','+nm_atributo else @nm_atributo_pai end,

	@nm_atributo_incremento = case when  isnull(ic_atributo_chave,'N')   = 'S' --
	                                and  isnull(ic_chave_incremento,'N') = 'S' --
	                                and isnull(ic_chave_estrangeira,'N') = 'N' --
									then nm_atributo                           --						  
                                    else @nm_atributo_incremento
                              end



  from
    #aux
	
  order by
    id
	
  --select @nm_atributo_incremento, @nm_atributo_chave
  --return
  --select @nm_atributo, @cd_natureza_atributo, @qt_tamanho_atributo

  if @campo not in ('id', 'id')
  begin

    set @sqlcampos = @sqlcampos
                  +
                  case when @sqlcampos<>'' then ', ' else '' end
				  +
                  case when @campo<>'' then '['+@campo+']' else CAST('' as varchar(200)) end

  --select @campos
  --select @sqlcampos as 'final'

       set @campos = @campos 
                 +
				 case when @campos <> '' then ', ' else '' end
				 +
				 @nm_atributo

	--select @cd_natureza_atributo, @qt_tamanho_atributo, @valor
   --montagem do campo--
       set @inclusao = @inclusao +        
                case when @inclusao<>'' then ', ' else '' end         
        
       +   
	   
              case when @campo='dt_usuario' or @campo='dt_usuario_inclusao' then 
              
               'cast(' +cast(''''+CONVERT(varchar(23), SYSDATETIME(), 121) + '''' as varchar)+' as datetime)'

 --  'cast('+cast(''''+CONVERT(VARCHAR, GETDATE(), 120)+'''' as varchar)+' as datetime)'        
              
              else        
                case 
	               when @cd_natureza_atributo = 1 then  --int   
                   ''        
                   +        
                   case when isnull(@valor,'') = '' then 'null' else @valor end         
                   +        
                   '' 
	               when @cd_natureza_atributo = 2 then  --varchar           
                   ''''        
                    +        
                    SUBSTRING(@valor, 1, isnull(@qt_tamanho_atributo,8000))        
       +        
       ''''         
	   when @cd_natureza_atributo = 4 then  --datetime
       'cast('+        
       ''''        
       +        
       ltrim(rtrim(@valor))        
       +        
       ''''         
       +' as datetime)'
       +        
       ''         
	   when @cd_natureza_atributo = 5 then  --char        
       ''''        
       +        
       SUBSTRING(@valor, 1, isnull(@qt_tamanho_atributo,8000))        
       +        
       ''''         
	   	   when @cd_natureza_atributo = 7 then  --text       
       ''''        
       +        
       isnull(ltrim(rtrim(@valor)),'')        
       +        
       ''''         
	   when @cd_natureza_atributo = 9 then  --varbinary   
          'cast('+        
       ''''        
       +        
       ltrim(rtrim(@valor))        
       +        
       ''''         
       +' as varbinary(max))'
                     else
       ''''        
       +        
       ltrim(rtrim(@valor))        
       +        
       ''''         
       end        
     end

  end



  delete from #aux
  where
    id = @id


end

--select
--  @nm_tabela
--return

--select @inclusao
--return

--Validação se existe registro na Tabela requerida, se não gerar insert (Solicitação CCF)

declare @sql_valida   nvarchar(max) = ''
declare @count_valida int = 0

   if CHARINDEX(',', @nm_atributo_chave) = 0  and @cd_documento_form in (1,2) --Apenas se for chave única
   begin
   set @sql_valida = 'SELECT  @count_valida = COUNT(*) from '+@nm_tabela+' where '+@nm_atributo_chave+' = @cd_documento_form'

	 --select @sql_valida
	  EXEC sp_executesql @sql_valida,  N'@cd_documento_form INT, @count_valida INT OUTPUT', @cd_documento_form, @count_valida OUTPUT
	  --select @count_valida

	  IF isnull(@count_valida,0) = 0
         set @cd_parametro = 1

   end


-------------------------------------------------------------------------------------------------------------
	  --if exists @sql_valida
--select @nm_atributo_pai
--select @nm_atributo_incremento
--return
-------------------
--select @sqlcampos
--select @inclusao
--return
-------------------

set @sqlcampos = LTRIM(rtrim(@sqlcampos))

declare @sqlfinal       nvarchar(max) = ''
declare @sql            nvarchar(max) = ''
declare @sqlIncremento  nvarchar(max) = ''

--select @cd_parametro, @nm_atributo_chave


--Inclusao--
--select * from #AuxInclusao

--select @cd_parametro

if @cd_parametro = 1
begin try
  
  set @sqlIncremento = ''
  
  --select @nm_atributo_chave as chave

  if CHARINDEX(',',@nm_atributo_chave) <> 0 or @nm_atributo_chave<>''
  begin

     --select @nm_tabela
	 --select @nm_atributo_chave as chave


	 select @vl_atributo_pai = valor from #json where campo = @nm_atributo_pai 
	 if isnull(@vl_atributo_pai,'') = ''
	 set @vl_atributo_pai = @cd_documento_form

	 --select @nm_atributo_pai,* from #json

	if @nm_atributo_pai <> '' and isnull(@vl_atributo_pai,'') <> ''

	 set @where_filtro = ' where '+ @nm_atributo_pai + ' = ' + @vl_atributo_pai

	-- select @nm_atributo_incremento
	--select @where_filtro

	 if @nm_atributo_incremento<>'' and SUBSTRING(@nm_atributo_incremento,1,1)<>''
	 begin
	   --select @sqlIncremento

       set @sqlIncremento = ' select @nm_chave = cast( isnull(( select max('+@nm_atributo_incremento+') from '+@nm_tabela+' '+isnull(@where_filtro,'')+' ),0) + 1 as nvarchar(max))'

	 
	 --select @sqlIncremento

       SET @ParamDefinition = N'@nm_chave nvarchar(max) OUTPUT';

	 --select @dsAux

	   if @sqlIncremento<>''
	   begin
          EXEC sp_executesql @sqlIncremento, @ParamDefinition, @nm_chave=@nm_chave OUTPUT

	 --Verifica se já recebe Campo Chave --select * from Copia_Tabela_Preco
	 --select @nm_chave, @valor, @nm_atributo_incremento

  	   select @valor = valor from
	     #AuxInclusao
       where
	      campo = @nm_atributo_incremento

		  --select * from #AuxInclusao

       --select @valor

     end

	--select @nm_chave, @valor
	 --Atualizar o 

	 if @nm_chave<>'' and (isnull(@valor,'') = '' or isnull(@valor,0) = 0)
	 begin
	   --select @nm_chave, @nm_atributo_incremento, @valor	
	   update
	     #AuxInclusao
       set
	      valor = @nm_chave
       where
	      campo = @nm_atributo_incremento

	end

        --select * from #json
		--select 'oi'

		-- gerar novamente o campo da inclusao--

		set @sqlcampos = ''
       --select * from egisadmin.dbo.Form_TabSheet_Atributo where cd_form = 162
	   --Refaz a inclusão se tiver #auxInclusao
	   --select * from #auxInclusao
	   if exists( select top 1 id from #auxInclusao)
	   begin
	     set @inclusao = cast(@cd_usuario as nvarchar(30))
                  --+', cast(''' +CONVERT(VARCHAR, GETDATE(), 120)+''' as datetime) '
                  +', cast(''' +CONVERT(varchar(23), SYSDATETIME(), 121) + ''' as datetime2(3))'
	   end
	   --

	   --select * from #AuxInclusao
       --return

       while exists ( select top 1 id from #auxInclusao)
       begin

         select top 1
           @id                   = id,
	       @campo                = campo,
	       --@nm_tabela            = isnull(nm_tabela,''),
           @nm_tabela            = case when ic_admin = 'S' then 'egisadmin.dbo.' else cast('' as varchar(1)) end + isnull(nm_tabela,''),
	       @nm_atributo          = ISNULL(nm_atributo,''),
           @valor                = ltrim(rtrim(valor)),
	       @cd_natureza_atributo = cd_natureza_atributo,
		   @qt_tamanho_atributo  =  qt_tamanho_atributo,
           @ic_chave_incremento  = ic_chave_incremento,
           @ic_atributo_chave    = ic_atributo_chave,
           @ic_chave_estrangeira = ic_chave_estrangeira


        from
          #AuxInclusao
	
        order by
          id

        --select @id, @campo, @nm_tabela, @nm_atributo, @valor, @cd_natureza_atributo
		--select top 1 * from #auxInclusao

        if @campo not in ('id', 'id')
        begin
          set @sqlcampos = @sqlcampos
                  +
                  case when @sqlcampos<>'' then ', ' else '' end
				  +
                  case when @campo<>'' then '['+@campo+']' else CAST('' as varchar(200)) end


           --montagem do campo--
		   --select @inclusao
       set @inclusao = @inclusao +        
                case when @inclusao<>'' then ', ' else '' end         
        
       +   
	   
              case when @campo='dt_usuario' or @campo='dt_usuario_inclusao' 
              
              then
              --'cast('+cast(''''+CONVERT(VARCHAR, GETDATE(), 120)+'''' as varchar)+' as datetime)'        
              'cast(' +cast(''''+CONVERT(varchar(23), SYSDATETIME(), 121) + '''' as varchar)+' as datetime)'

              else        
                case 
				   when @ic_atributo_chave = 'S' and isnull(@valor,'') = '' then  --pk vazia   
                   ''        
                   +        
                   cast(isnull(@cd_documento_form,0) as varchar)     
                   +        
                   '' 
	               when @cd_natureza_atributo = 1 then  --int   
                   ''        
                   +        
                   case when isnull(@valor,'') = '' then 'null' else @valor end         
                   +        
                   '' 
	               when @cd_natureza_atributo = 2 then  --varchar           
                   ''''        
                    +        
                    SUBSTRING(@valor, 1, isnull(@qt_tamanho_atributo,8000))         
       +        
       ''''         
	   when @cd_natureza_atributo = 4 then  --datetime
       'cast('+              
       case when isnull(@valor,'') = '' then 'null' else ''''+ltrim(rtrim(@valor))+'''' end            
       +' as datetime)'
       +        
       ''         
	   when @cd_natureza_atributo = 5 then  --char        
       ''''        
       +        
       SUBSTRING(@valor, 1, isnull(@qt_tamanho_atributo,8000))        
       +        
       ''''         
	   	   when @cd_natureza_atributo = 7 then  --text       
       ''''        
       +        
       isnull(ltrim(rtrim(@valor)),'')        
       +        
       ''''         
	   when @cd_natureza_atributo = 9 then  --varbinary   
          'cast('+        
       ''''        
       +        
       ltrim(rtrim(@valor))        
       +        
       ''''         
       +' as varbinary(max))'
                     else
       ''''        
       +        
       ltrim(rtrim(@valor))        
       +        
       ''''         
       end        

     end			   
 
  end



  delete from #AuxInclusao
  where
    id = @id

	--select '1' as a
end

--select '1' as a


	 end

	 --select @nm_chave
	 --select @sqlIncremento

  end

  --select @nm_tabela, @campos, @inclusao

  ----------------------------------------------------------------------------------
  set @sql = 'INSERT INTO '+@nm_tabela+'( '+@campos+' ) VALUES (' + @inclusao + ' )'
  ----------------------------------------------------------------------------------
  --ccf 
  --select @sql
  --return
  ----------------------------------------------------------------------------------
  --ccf 
  --abrir aqui para teste
 -- select @sql, @valor

  exec(@sql)

  -----------------------------------------------------------------------------------------------------------------------------------------

  --log--
  --exec pr_gera_log_operacao @cd_empresa, @cd_modulo, @cd_menu, @cd_tabela, @cd_usuario, @ic_parametro, @nm_log, @ds_log
  --
  -----------------------------------------------------------------------------------------------------------------------------------------

  --select 'Registro Incluído com Sucesso' as Msg, @nm_chave as 'chave'

  set @cd_documento_form = cast(@nm_chave as int)

  --
  -- Exemplo: egisadmin.dbo.Contabilizacao_Processo
  SET @Db     = PARSENAME(@nm_tabela, 3);
  SET @Schema = PARSENAME(@nm_tabela, 2);
  SET @Tabela = PARSENAME(@nm_tabela, 1);
   

  IF @Tabela IS NULL
      BEGIN
        SET @Tabela = @nm_tabela;
        SET @Schema = 'dbo';
        SET @Db = DB_NAME();
      END
      ELSE
      BEGIN
        IF @Schema IS NULL SET @Schema = 'dbo';
        IF @Db IS NULL     SET @Db = DB_NAME();
      END


 
SELECT TOP (1) @CampoChave = c.name
FROM sys.key_constraints kc
JOIN sys.index_columns ic
  ON ic.object_id = kc.parent_object_id
 AND ic.index_id  = kc.unique_index_id
JOIN sys.columns c
  ON c.object_id = ic.object_id
 AND c.column_id = ic.column_id
WHERE kc.[type] = 'PK'
  AND kc.parent_object_id = OBJECT_ID(
        QUOTENAME(@Db) + '.' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Tabela)
      )
ORDER BY ic.key_ordinal;

 IF @CampoChave IS NULL
 BEGIN
   SELECT
     'Não foi possível localizar a chave primária (PK) da tabela para retornar o registro.' AS Msg,
     'I'    AS modo,
     @chave AS chave,
     NULL   AS registro;
   RETURN;
 END
 ----------------------------
 
  set @registroJson           =''

  -- monta SQL seguro

SET @sql = N'
SELECT @registroJson_OUT =
(
  SELECT TOP (1) t.*
  FROM ' 
    + QUOTENAME(@Db) + N'.'
    + QUOTENAME(@Schema) + N'.'
    + QUOTENAME(@Tabela) + N' t
  WHERE t.' + QUOTENAME(@nm_atributo_chave) + N' = @chave
  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
);';

  EXEC sp_executesql
    @sql,
    N'@chave INT, @registroJson_OUT NVARCHAR(MAX) OUTPUT',
    @chave = @cd_documento_form,
    @registroJson_OUT = @registroJson OUTPUT;
  
  -- Contrato padronizado (para o front não sofrer)

  SELECT
    'Registro Incluído com Sucesso : '+  @nm_chave AS Msg,
    'I'                                AS [modo],                 -- 'I' ou 'A' (você já tem isso no fluxo)
    @cd_documento_form                 AS [chave],
    @registroJson                      AS [registro];


  --Gerar um email-----
  if @cd_tipo_email>0
  begin

    print @cd_tipo_email

  end


  --Gerar um Whatspp----
  if @cd_mensagem>0
  begin
    print @cd_mensagem
  end

  end try
  begin catch
    --select @sql
	select 'Não foi possível incluir o registro...'+@sql as Msg
  end catch 

 --select @cd_parametro

  ---Alteração--------------------------------------------------------------------------------------------------------------------------

  if @cd_parametro = 2
  begin

	begin try

	   --select @nm_chave
	   --return

	  if @nm_atributo_chave<>'' and charindex(',',@nm_atributo_chave) = 0 --Chave única
      begin
	    select @vl_atributo_pai = valor from #json where campo = @nm_atributo_pai
	    select @nm_chave        = valor from #json where campo = @nm_atributo_chave
      end
	  else if @nm_atributo_chave<>'' and charindex(',',@nm_atributo_chave) <> 0 --Mais de uma chve
	  begin
	     DECLARE @whereComposto VARCHAR(MAX) = '';
        
         WITH CTE_Items AS (
             SELECT LTRIM(RTRIM(value)) AS item
             FROM STRING_SPLIT(@nm_atributo_chave, ',')
         )
         SELECT @whereComposto = STUFF((
             SELECT ' and ' + campo + ' = ' + valor
             FROM #json
             WHERE campo IN (SELECT item FROM CTE_Items)
             FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 5, '');
	    
          --SELECT @whereComposto AS whereComposto;
	  end

      --select @nm_atributo_chave, @vl_atributo_pai, @nm_chave
	  --select * from #json
	  --return


      declare @alteracao nvarchar(max)
  
      set @alteracao    = ''

      set @iusuario = 0

	  select * into #alteracao from #json

	  --select * from #alteracao
	  --return


      while exists( select top 1 id from #alteracao)
      begin
  
        select top 1 
	      @id                   = id,	  
	      @campo                = ltrim(rtrim(isnull(campo,''))),
	      @valor                = ltrim(rtrim(valor)),
		  @chave                = isnull(chave,'N')
	  
        from
          #alteracao

       --Montagem da Where de Alteração quando for Atributo Composto
	   set @nm_atributo_where = @nm_atributo_where 
	                            + 
	                             case when @nm_atributo_where='' and @chave='S' then
	                                 @campo + ' = ' + @valor
	                             else
								     case when @chave='S' then 
								      ' and '+  @campo + ' = ' + @valor 
								     else 
								       cast('' as varchar(1))
                                     end
								end

          

       --select @id, @campo, @valor 
       set @cd_natureza_atributo = 0

       select
         @cd_natureza_atributo = isnull(cd_natureza_atributo,0),
		 @ic_tipo_atributo     = isnull(ic_tipo_atributo,0)
       from
         #AtributoForm

       where
         nm_atributo = @campo
		 
       --select @campo

       if @campo = 'cd_usuario' 
       begin
     
         set @iusuario = 1
         --set @valor    = ltrim(rtrim(cast(@cd_usuario as varchar(15))))
	     set @cd_usuario = cast(ltrim(rtrim(cast(@valor as varchar(15)))) as int)
	     --select @valor
	     --select @cd_usuario

       end

      --Define o Valor do Módulo--

      if @campo='cd_modulo'  
      begin
        set @cd_modulo = cast(isnull(@valor,'') as int)
      end

   --
      --Define o Valor do Menu--
      if @campo='cd_menu'
      begin
        set @cd_menu = cast(isnull(@valor,'') as int)
      end
   --
   --select * from egisadmin.dbo.natureza_atributo
   --select @valor as valor, @cd_natureza_atributo as cd_natureza_atributo
   --montagem do campo--
   
      if @cd_natureza_atributo<>0 and @nm_atributo_chave<>@campo and @ic_tipo_atributo <> 4 --Não faz update em campos do tipo 4 Não editável (Solicitação CCF)
      begin
	  --select @valor,@campo as campo,@cd_natureza_atributo as cd_natureza_atributo,@alteracao
        set @alteracao = @alteracao +
	               case when @alteracao<>'' then ', ' else '' end +  @campo + ' = ' +
				   case when @cd_natureza_atributo = 9 then --varbinary
				     'cast('+
				     ''''
				     +
				     ltrim(rtrim(@valor))
				     +
				     ''''
				     +
				     ' as varbinary(max))'
				   else
				   case when @cd_natureza_atributo = 7 then --Text
				     ''''+ltrim(rtrim(isnull(@valor,'')))+''''
				   else
				   case when @cd_natureza_atributo = 4 then --Datetime
				    'convert(datetime, '+
					case when isnull(@valor,'') = '' then 'null'
                    else ''''+ltrim(rtrim(isnull(replace(replace(@valor,'T',' '),'Z',''),GETDATE())))+'''' end
					 +
					 ' ,121)'
				   else
				   case when @cd_natureza_atributo in (2,5) then --Varchar e Char
				    case 
					 when @valor is null then ''+ltrim(rtrim(isnull(@valor,'NULL')))+''
					 when isnull(@valor,'') = '' then ''''+ltrim(rtrim(isnull(@valor,'NULL')))+''''
					else ''''+ltrim(rtrim(isnull(@valor,'NULL')))+'''' end
				   else
				   case when @cd_natureza_atributo in (1,6) then --Int
					''
				     +
				     case when isnull(@valor,'') = '' then 'NULL' else ltrim(rtrim(isnull(@valor,'NULL'))) end
				     +
				     ''
				   else
				     ''
				     +
				     case when isnull(@valor,'') = '' then 'NULL' else ltrim(rtrim(isnull(@valor,'NULL'))) end
				     +
				     ''
				end
		     end
		  end
	   end
	 end
   end

   delete from #alteracao
   where
     id = @id
	 
  end

  --select @nm_atributo_where
  
  --select @alteracao

  --incluir o usuário caso não tenha--

  --select @iusuario


  if @iusuario=0
     set @alteracao = @alteracao + ', cd_usuario = '+cast(@cd_usuario as varchar(10))
    
   --incluir a data de alteracao--
   
  if @iusuario=0
     set @alteracao = @alteracao +
                    ', dt_usuario = getdate() '	
	                
  --select @alteracao
  --return

 -- print @sql

  --exec (@sql)     --Fazendo um DataSet..

  --log--
   
  --set @dsAux = ' select @ds_log = ( select * from '+@nm_tabela+' where '+@nm_atributo_chave+' = '+@nm_chave+' for json auto ) '
  
  --select @dsAux

  --exec ( @dsAux )


  --SET @ParamDefinition = N'@ds_log nvarchar(max) OUTPUT';

  --EXEC sp_executesql @dsAux, @ParamDefinition, @ds_log=@ds_log OUTPUT;


  --Log--

  --exec pr_gera_log_operacao @cd_empresa, @cd_modulo, @cd_menu, @cd_tabela, @cd_usuario, @ic_parametro, @nm_log, @ds_log

  ------------------------------------------------------------------------------------------------------------------------------------------
  --select @nm_tabela, @alteracao, @nm_atributo_chave, @nm_chave
  --return

   --Update--
    --select @nm_atributo_chave,@nm_chave,@nm_atributo_pai,@vl_atributo_pai

	--select @vl_atributo_pai

	if isnull(@vl_atributo_pai,'') <> ''
	begin
	   --set @sql = 'UPDATE  '+@nm_tabela+' set ' + @alteracao + ' where '+@nm_atributo_chave+' = '+@nm_chave +' and '
	   --+ @nm_atributo_pai +' = '+ @vl_atributo_pai

	   --set @nm_chave = 

	   set @sql = 'UPDATE  '+@nm_tabela+' set ' + @alteracao + ' where '+@nm_atributo_where
	   
	   --select @sql
       --return

	   --select @nm_atributo_chave, @nm_chave, @nm_atributo_pai, @vl_atributo_pai
	   --return
	   
	end
	 else if isnull(@whereComposto,'') <> ''
	 begin
        set @sql = 'UPDATE  '+@nm_tabela+' set ' + @alteracao + ' where '+@whereComposto
     end
	 else
	 begin
        set @sql = 'UPDATE  '+@nm_tabela+' set ' + @alteracao + ' where '+@nm_atributo_chave+' = '+@nm_chave
     end
     
	 --select @sql
     -- exec (@sql)
     --return
	 ------------------------
	 EXEC sp_executesql @sql
	 ------------------------


   -----------
   --select @nm_chave as nm_chave, @nm_atributo_chave as atributo_chave

   -----------------
   if @nm_chave<>'' or @nm_atributo_chave<>''
   begin
      --select 'Registro Alterado com Sucesso : ' + @nm_chave as Msg

      set @cd_documento_form = cast(@nm_chave as int)
          
      --select @cd_documento_form, @nm_chave, @nm_atributo_chave
          
      SET @Db     = PARSENAME(@nm_tabela, 3);
      SET @Schema = PARSENAME(@nm_tabela, 2);
      SET @Tabela = PARSENAME(@nm_tabela, 1);

      --select @db, @Schema, @nm_tabela

      IF @Tabela IS NULL
      BEGIN
        SET @Tabela = @nm_tabela;
        SET @Schema = 'dbo';
        SET @Db = DB_NAME();
      END
      ELSE
      BEGIN
        IF @Schema IS NULL SET @Schema = 'dbo';
        IF @Db IS NULL     SET @Db = DB_NAME();
      END
            -- monta SQL seguro

      SET @sql = N'
      SELECT @registroJson_OUT =
      (
        SELECT TOP (1) t.*
        FROM ' 
          + QUOTENAME(@Db) + N'.'
          + QUOTENAME(@Schema) + N'.'
          + QUOTENAME(@Tabela) + N' t
        WHERE t.' + QUOTENAME(@nm_atributo_chave) + N' = @chave
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
      );';
            
      --select @sql

      EXEC sp_executesql
        @sql,
        N'@chave INT, @registroJson_OUT NVARCHAR(MAX) OUTPUT',
        @chave = @cd_documento_form,
        @registroJson_OUT = @registroJson OUTPUT;
      
      -- Contrato padronizado (para o front não sofrer)
      SELECT
        'Registro Alterado com Sucesso : ' + @nm_chave AS Msg,
        'A'                                AS [modo],                 -- 'I' ou 'A' (você já tem isso no fluxo)
        @cd_documento_form                 AS [chave],
        @registroJson                      AS [registro];

   end
   -------------------------------------------------------------------------------------------------------------------------------
   end try
  begin catch
    --select @nm_chave
	--EXEC sp_executesql @sql
	select 'Não foi possível alterar o registro ...'+@sql as Msg
  end catch 

end
  
  ------------------------------------------------------------CHAMADA DE PROCESSO----------------------------------------------------------------

  --Carlos Fernandes / Alexandre 24.08.204
  --select @cd_processo
  ----------------------------------------------------------------------------------------------------------------------------------------------
  if @cd_processo>0
  begin
    declare @sJsonProcesso nvarchar(max) = ''
    --Json
    set @sJsonProcesso =
    '[{"cd_empresa":"'+cast(@cd_empresa as varchar(6))+'", "cd_modulo":"'+cast(@cd_modulo as varchar(6))+'", "cd_menu":"0", "cd_processo":"'+cast(@cd_processo as varchar(6))+'", '+
    ' "cd_item_processo":"1", "cd_documento":"'+cast(@cd_documento_form as varchar)+'", "cd_item_documento":"0","cd_parametro":"'+cast(isnull(@cd_parametro,0) as varchar)+'", "cd_usuario":"'+cast(@cd_usuario as varchar(6))+'"}]'
  
   --select @sJsonProcesso as sJsonProcesso
   --select * from sJsonProcesso
   --drop table sJsonProcesso
    -----------------------------------------------------------------------------------------------------------------------------------------------
    exec pr_api_geracao_processo_sistema @sJsonProcesso
	return
    ----------------------------------------------------------------------------------------------------------------------------------------------
  end

  --Delete-------------------------------------------------------------------------------------------------------------

if @cd_parametro = 3
begin
  --select @cd_documento_form, @nm_chave, @nm_atributo_chave

  if isnull(@nm_chave,'') <>'' and @cd_documento_form = 0
     set @cd_documento_form = cast(@nm_chave as int)

  if isnull(@nm_atributo_chave,'') = ''
  begin
	select 'Sem atributo indicado para excluir!'
	return
  end

   if isnull(@cd_documento_form,'') = ''
  begin
	select 'Sem registro indicado para excluir!'
	return
  end

  declare @cd_atributo_chave_pai  nvarchar(300) = ''
  declare @cd_atributo_chave_item nvarchar(300) = ''
       SELECT 
	       value, 
	       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
	   INTO 
		#ExclusaoFormEspecialGrid
       FROM 
	       STRING_SPLIT(@nm_atributo_chave, ',')

		   --select * from #ExclusaoFormEspecialGrid

   SELECT 
       @cd_atributo_chave_pai = (SELECT value FROM #ExclusaoFormEspecialGrid WHERE rn = 1),
       @cd_atributo_chave_item = (SELECT value FROM #ExclusaoFormEspecialGrid WHERE rn = 2)
   
   --SELECT @cd_atributo_chave_pai AS AtributoPai, @cd_atributo_chave_item AS AtributoFilho

  set @sql = 'DELETE FROM '+@nm_tabela+' where '+@cd_atributo_chave_pai+'  = ' + cast(@cd_documento_form as varchar) + case when isnull(@cd_atributo_chave_item,'') = '' then '' else ' and '+@cd_atributo_chave_item+' = '+cast(@cd_item_documento_form as varchar) end

  --select @sql as [sql], @nm_tabela as nm_tabela, @cd_atributo_chave_pai as cd_atributo_chave_pai, @cd_documento_form as cd_documento_form, @cd_atributo_chave_item as cd_atributo_chave_item, @cd_item_documento_form as cd_item_documento_form

  exec(@sql)	


   --select 'Registro Excluido com Sucesso : ' + cast(@cd_documento_form as varchar) as Msg

   SELECT
    'Registro Excluido com Sucesso : ' + cast(@cd_documento_form as varchar) AS [Msg],
    'E' AS [modo],
    @cd_documento_form AS [chave],
    NULL AS [registro];

end

--select @json as 'json' into ccfale 
--drop table #jon
--select * from Requisicao_Compra_Item where cd_requisicao_compra = 3

go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_api_crud_dados_especial
--'[
--{
--    "cd_menu": "0",
--    "cd_form": 94,
--    "cd_parametro_form": "1",
--    "cd_usuario": "4595",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "4595",
--    "dt_usuario": "2025-04-22",
--    "lookup_formEspecial": {},
--    "cd_ordem_servico": "",
--    "dt_ordem_servico": "",
--    "hr_entrada_registro": "13:51",
--    "cd_cliente": null,
--    "nm_contato_ap_ordem_serv": "",
--    "cd_marca_produto": null,
--    "nm_modelo_produto": "",
--    "cd_numero_serie": "",
--    "dt_visita_ordem_servico": "2025-04-22",
--    "ds_aspecto": "",
--    "cd_tipo_defeito_cliente": null,
--    "ds_def_cli_ordem_servico": "",
--    "nm_obs_pagto_ordem": "",
--    "cd_status_ordem_servico": 1,
--    "detalhe": [],
--    "lote": [],
--    "cd_modulo": "232"
--}
--]'

go

--exec pr_egis_api_crud_dados_especial
--'[{
--    "cd_menu": 8024,
--    "cd_form": "125",
--    "cd_parametro_form": 1,
--    "cd_usuario": "113",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "",
--    "dt_usuario": "2025-05-06T17:45:07.618Z",
--    "lookup_formEspecial": {},
--    "detalhe": [],
--    "lote": [],
--    "cd_modulo": "",
--    "cd_documento_form": "0",
--    "cd_banco": "",
--    "nm_banco": "joao",
--    "nm_fantasia_banco": "JOAO",
--    "sg_banco": "237",
--    "cd_numero_banco": "237",
--    "cd_identificacao_empresa": "237",
--    "ic_pad_cambio_banco": "N",
--    "ds_banco": "teste",
--    "nm_dominio_banco": "",
--    "qt_dia_limite_cnab_banco": "",
--    "ic_bloqueio_cnab_banco": "",
--    "ic_selecao_cnab_banco": "",
--    "cd_interface": "",
--    "sg_historico_banco": "",
--    "nm_titulo_recibo": "",
--    "ic_sem_sacador": "",
--    "ic_nome_sacador": "",
--    "cd_digito_banco": "",
--    "nm_logo_web_banco": "",
--    "cd_conta": "",
--    "ic_financeira_banco": "",
--    "vl_tarifa_ted": "",
--    "nm_aba_banco": "",
--    "cd_formulario": "",
--    "cd_arquivo_magnetico_remessa": "",
--    "cd_arquivo_magnetico_retorno": "",
--    "cd_plano_financeiro": ""}
--]'

--exec pr_egis_api_crud_dados_especial '[{    
--    "cd_menu": "6434",
--    "cd_form": "42",
--    "cd_parametro_form": 1,
--    "cd_usuario": "4721",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "",
--    "dt_usuario": "2025-05-05T19:45:44.499Z",
--    "lookup_formEspecial": {},
--    "detalhe": [],
--    "lote": [],
--    "cd_modulo": "",
--    "cd_documento_form": "0",
--    "cd_requisicao_interna": "",
--    "dt_requisicao_interna": "2025-05-01",
--    "dt_necessidade": "2025-05-01",
--    "cd_departamento": "1",
--    "cd_centro_custo": "1",
--    "cd_aplicacao_produto": "",
--    "cd_usuario_requisicao": "113",
--    "dt_estoque_req_interna": "",
--    "nm_item_requisicao": "",
--    "ic_maquina": "",
--    "cd_loja": "",
--    "ic_lib_estoque_requisicao": "",
--    "dt_lib_estoque_requisicao": "",
--    "cd_motivo_req_interna": "",
--    "cd_guia_fracionamento": "",
--    "cd_funcionario": "",
--    "cd_status_requisicao": "",
--    "cd_consulta": "",
--    "cd_posicao_separacao": "",
--    "dt_retirada_requisicao": "",
--    "cd_pedido_venda": "",
--    "cd_terceiro": "",
--    "cd_projeto": "",
--    "cd_identificacao_requisicao": "",
--    "cd_ordem_servico": ""
--}]'
go
--USE EGISSQL
--select * from requisicao_interna

--exec pr_egis_api_crud_dados_especial '[{
--    "cd_menu": 8141,
--    "cd_form": "0",
--    "cd_parametro_form": 1,
--    "cd_usuario": "113",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "",
--    "dt_usuario": "2025-06-13T16:15:02.612Z",
--    "lookup_formEspecial": {},
--    "detalhe": [],
--    "lote": [],
--    "cd_modulo": "",
--    "cd_documento_form": "4",
--    "cd_segmento": "4",
--    "nm_segmento": "CTP.......",
--    "nm_fantasia": "CTP",
--    "ic_ativo_segmento": "S",
--    "nm_icone_segmento": ""
--}]'
--go
--use egissql_318

--exec pr_egis_api_crud_dados_especial
--'[{
--    "cd_menu": 7949,
--    "cd_form": "44",
--    "cd_parametro_form": 1,
--    "cd_usuario": "113",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "",
--    "dt_usuario": "2025-05-14T15:18:40.665Z",
--    "lookup_formEspecial": {},
--    "detalhe": [],
--    "lote": [],
--    "cd_modulo": "",
--    "cd_documento_form": "0",
--    "cd_tabela_preco": "*",
--    "nm_tabela_preco": "teste",
--    "sg_tabela_preco": "TESTE",
--    "cd_tipo_tabela_preco": "1",
--    "ic_padrao_tabela_preco": "N",
--    "ic_status_tabela_preco": "A",
--    "cd_moeda": "2",
--    "nm_obs_tabela_preco": "TSTE",
--    "pc_tabela_preco": "",
--    "ic_produto_tabela": "N",
--    "dt_inicio_tabela": "",
--    "dt_fim_tabela": "",
--    "cd_condicao_pagamento": "",
--    "cd_condicao_pagamento_descricao": "",
--    "cd_interface": "",
--    "ic_imposto_tabela_preco": "N",
--    "cd_tipo_pedido": "",
--    "cd_empresa": "",
--    "ic_sel_caixa": "",
--    "ic_exporta_tabela_preco": "",
--    "cd_identificacao_tabela": "",
--    "cd_destinacao_produto": "",
--    "vl_fator_imposto_tabela": "",
--    "cd_cliente_grupo": "",
--    "cd_fornecedor": "",
--    "cd_fornecedor_descricao": "",
--    "ic_importacao_produto": "",
--    "ic_fora_estado_cliente": "",
--    "ic_categoria_produto": ""}
--]
--'
--use egissql_317
--go

--select * from consulta order by cd_consulta desc





--exec pr_egis_api_crud_dados_especial '[{
--    "cd_menu": 8830,
--    "cd_form": "0",
--    "cd_parametro_form": 1,
--    "cd_usuario": "113",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "",
--    "lookup_formEspecial": {},
--    "detalhe": [],
--    "lote": [],
--    "cd_modulo": "",
--    "cd_documento_form": "0",
--    "cd_sugestao": "",
--    "nm_sugestao": "Vendas de Hoje",
--    "ds_sugestao": "",
--    "ds_exemplos": "",
--    "ds_keywords": "",
--    "tp_destino": 1,
--    "cd_rota": 187,
--    "nm_procedure": "",
--    "nm_local_componente": "",
--    "nm_caminho_componente": "",
--    "ic_ativo": "N",
--    "cd_grupo_usuario": "",
--    "cd_parametro": ""
--}]'



--exec pr_egis_api_crud_dados_especial '[{
--    "cd_menu": 8830,
--    "cd_form": "0",
--    "cd_parametro_form": 2,
--    "cd_usuario": "113",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "",
--    "lookup_formEspecial": {},
--    "detalhe": [],
--    "lote": [],
--    "cd_modulo": "",
--    "cd_documento_form": 2,
--    "cd_sugestao": 2,
--    "nm_sugestao": "Vendas Mensais",
--    "ds_sugestao": "",
--    "ds_exemplos": "",
--    "ds_keywords": "",
--    "tp_destino": 1,
--    "cd_rota": 187,
--    "nm_procedure": "",
--    "nm_local_componente": "",
--    "nm_caminho_componente": "",
--    "ic_ativo": "N",
--    "cd_grupo_usuario": "",
--    "cd_parametro": ""
--}]'
