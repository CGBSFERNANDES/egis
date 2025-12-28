--BANCO DO CLIENTE
--USE EGISSQL
--GO
--use egissql_341

-------------------------------------------------------------------------------          
--sp_helptext pr_egis_importacao_dados          
-------------------------------------------------------------------------------          
--GBS Global Business Solution Ltda                                        2025         
-------------------------------------------------------------------------------          
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016          
--Autor(es)        : Kelvin Viana        
--                   Carlos Fernandes
--Banco de Dados   : EgisAdmin          
--Objetivo         : Pr de importação de dados.    
--Data             : 07.06.2024          
--API              : 897/1377    
--Alterção		   : Correção na abertura de json no parametro 1. Kelvin Viana.
-- 11.09.2024 - Ajustes Diversos - Carlos/Fabiano
-- 23.09.2024 - Nova Atualização de Produto de Inventário - Carlos Fernandes
-- 27.12.2024 - Novos Desenvolvimentos - Contas a Receber e Tabela de Preço - Carlos Fernandes
-- 02.03.2025 - Complemento do Desenvolvimento para Zero Grau e clientes novos - Carlos Fernandes
------------------------------------------------------------------------------------------------------------

create or alter procedure pr_egis_importacao_dados          
@json nvarchar(max) = ''       
      
as     

set @json = isnull(@json,'')

if @json = ''
begin
  select 'Arquivo para importação está vazio !' as MSG, 0 as Cod
  return
end

      
declare @cd_parametro          int = 0        
declare @cd_menu               int = 0    
declare @cd_usuario            int = 0    
declare @cd_modelo             int = 0    
declare @cd_tipo_carga         int = 0
declare @jsonMig               nvarchar(max)  = ''
declare @nm_arquivo            varchar(200) 
declare @nm_workbook           varchar(200) = ''
declare @cd_modulo             int          = 0
declare @nm_planilha           varchar(80)  = ''
declare @cd_empresa            int          = 0

----------------------------------------------------------------------------------------------------------    
-- Ajuste de Aspas no item da proposta (caso venha com Aspas no nome do produto) 
-- set @json = replace(@json,'''','')
----------------------------------------------------------------------------------------------------------    

select                 
identity(int,1,1)             as id,                 
    valores.[key]             as campo,                 
    valores.[value]           as valor,
    @json                     as jsonReg
into #jsonMaster                
from                 
   openjson(@json) root                
   cross apply openjson(root.value) as valores 

----------------------------------------------------------------------------------------------------------

select @cd_parametro              = valor from #jsonMaster  with(nolock) where campo = 'cd_parametro'     
select @cd_menu                   = valor from #jsonMaster  with(nolock) where campo = 'cd_menu'     
select @cd_usuario                = valor from #jsonMaster  with(nolock) where campo = 'cd_usuario'   
select @cd_modelo                 = valor from #jsonMaster  with(nolock) where campo = 'cd_modelo'   
select @nm_arquivo                = valor from #jsonMaster  with(nolock) where campo = 'nm_arquivo'   
select @jsonMig                   = valor from #jsonMaster  with(nolock) where campo = 'jsonMig'   
select @nm_workbook               = valor from #jsonMaster  with(nolock) where campo = 'nm_workbook'   
select @cd_modulo                 = valor from #jsonMaster  with(nolock) where campo = 'cd_modulo'   
select @nm_planilha               = valor from #jsonMaster  with(nolock) where campo = 'nm_planilha'     

-- Consulta das tabelas de importação-------------------------------------------------------------------------------------------------------

--set @cd_parametro = 1


if @cd_parametro = 0
begin
    select 
        identity(int,1,1)                       as cd_controle,
        isnull(mcd.cd_modelo,0)                 as cd_modelo,
        isnull(mcd.nm_modelo,'')                as nm_modelo,
        isnull(mcd.cd_tabela,0)                 as cd_tabela,
        isnull(mcd.nm_obs_modelo,'')            as nm_obs_modelo,
        isnull(t.nm_tabela,'')                  as nm_tabela,
        isnull(mcd.nm_woorkbook,'')             as nm_woorkbook,
        isnull(mcd.cd_senha_acesso,'')          as cd_senha_acesso,
		isnull(mcd.cd_modulo,0)                 as cd_modulo,
		isnull(mcd.nm_local_modelo_planilha,'') as nm_local_modelo_planilha,
		isnull(mcd.nm_modelo_planilha,'')       as nm_modelo_planilha
    into #ModeloCargaEgismob
    from egisadmin.dbo.modelo_carga_dados mcd with(nolock) --select * from egisadmin.dbo.modelo_carga_dados
    left outer join egisadmin.dbo.tabela t    with(nolock) on t.cd_tabela = mcd.cd_tabela
	where
	  mcd.cd_modulo = case when @cd_modulo = 0 then mcd.cd_modulo else @cd_modulo end
	  and
      mcd.cd_menu   = case when @cd_menu   = 0 then mcd.cd_menu   else @cd_menu   end

    select * from #ModeloCargaEgismob
	where
	  cd_modulo = case when @cd_modulo = 0 then cd_modulo else @cd_modulo end

    order by 
      nm_modelo

    return

	--select * from egisadmin.dbo.modelo_carga_dados

end

set @cd_empresa = dbo.fn_empresa()


-- Importação-------------------------------------------------------------------------------------------------------------------------

if @cd_parametro = 1
begin
    --select * from Log_Aplicativo
    insert into Log_Aplicativo(nm_log_aplicativo,dt_log_aplicativo, cd_documento, ds_log_aplicativo, cd_usuario) values(
        'Importação de Dados',
        getdate(),
        0,
        @json,
        @cd_usuario
    )

	if isnull(@jsonMig,'') <> ''
    begin
      set @json = @jsonMig
    end
	
	declare @jsonWork  nvarchar(max)=''
	
	if (ISJSON(@json)<>1)
    begin
      select 'Formato de Json Inválido !' as Msg,  0 as Cod
      return

    end

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE --TABLE_SCHEMA = 'TheSchema' AND
                       TABLE_NAME = 'Cadastro'))
BEGIN

    --Faça algo aqui...
	drop table Cadastro
	--------------------------------------------------------------------------------------------------------------------

END
	
	set @jsonWork = @json
	
	declare @nm_json    nvarchar(max) = ''
	declare @nm_coljson nvarchar(max) = ''
	declare @nm_cabjson nvarchar(max) = ''
	
	set @nm_json = case when @nm_workbook<>'' then @nm_workbook else '' end
	
	select 
      @nm_workbook = isnull(mcd.nm_woorkbook,'Cadastro')        
    from 
       egisadmin.dbo.modelo_carga_dados mcd with(nolock)
    where
       mcd.cd_modelo = @cd_modelo
	
	--select @nm_workbook

	set @nm_json     = 'Cadastro' --@nm_workbook
	set @nm_workbook = 'Cadastro' --@nm_workbook

	declare @jsonBackup nvarchar(max) = ''
	set @jsonBackup = @json
	select                     
    top 1
    IDENTITY(int,1,1)                                    as id,
	 @jsonBackup					                     as jsonReg,
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
    valores.[value]                                      as valor

into #json                    
from                
    openjson(@json) root                    
    cross apply openjson(root.value) as valores      
	
--select * from #json


	declare @id        int     = 0
	declare @icab      int     = 0
	declare @id_coluna int     = 0
	declare @sql       nvarchar(max)  = ''
	declare @nm_coluna nvarchar(max)  = ''
	declare @jsonReg   nvarchar(max)  = ''
	
	set @id        = 0
	set @id_coluna = 0
	
	while exists ( select top 1 id from #json )
    begin

    select top 1 
        @id      = id,
        @json    = ltrim(rtrim(valor)),
        @jsonReg = @json
    from
        #json

    order by
        id

    if @icab = 0
    begin
      
	  set @nm_coljson = ''

        SELECT identity(int,1,1) as id_coluna, * 
        into #Coluna
        FROM OPENJSON(@json);
  
        -- Montagem do Cabeçalho --

        while exists( select top 1 id_coluna from #Coluna )
        begin
            select top 1
                @id_coluna = id_coluna,
                @nm_coluna = [key]
            from
                #Coluna

            set @nm_cabjson =  
                            @nm_cabjson
                            +
                            ' '
                            +
                            +'"'+@nm_coluna+'"' +' varchar(800) '+''''+'$'+'."'+@nm_coluna+'"'+''''

            delete from #Coluna
            where
                id_coluna = @id_coluna       

            if exists( select top 1 id_coluna from #Coluna )
            begin
                set @nm_cabjson = @nm_cabjson+', '
            end

        end

        set @icab = 1
        set @nm_cabjson = @nm_cabjson + ' )'

        drop table #Coluna

    end

    delete from #json
    where
        id = @id
end
	
	set @nm_coljson = ''
	set @nm_coljson = case when @nm_coljson='' then 'SELECT * INTO '+@nm_json+ ' FROM OPENJSON('+''''+@jsonWork+''''+', ' +''''+'$.'+@nm_workbook+''''+') WITH ( '                        
	                    else ''
	                    end
	                    +
	                    @nm_cabjson
	
	
	--select @sql

	--select @nm_json

	EXEC sp_executesql @nm_coljson
	set @sql = 'select * from '+@nm_json
	if isnull(@sql,'') <> ''
	begin try
	--select @sql
	--EXEC sp_executesql @sql
	--select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod

	--produto Inventário--

	--select * from cd_modelo
	--select @cd_modelo
	
	--select * from egisadmin.dbo.modelo_carga_dados

  -- Projeto --------------------------

  if @cd_modelo = 34
  begin	 
	exec pr_gera_importacao_projeto_engenharia  0,@cd_usuario, @cd_modelo
    select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	return
  end


  -- Regiões --

	if @cd_modelo = 32
	begin	 
	  exec pr_gera_importacao_tabela_regiao_venda  0,@cd_usuario, @cd_modelo
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
    end

	  --------------------------------------------------------------------------------------------------------------------

	
   -- Agências Bancárias --

	--if @cd_modelo = 31
	--begin	 
	--  exec pr_gera_importacao_tabela_agencia_banco  0,@cd_usuario, @cd_modelo
 --     select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	--   return
	--  --------------------------------------------------------------------------------------------------------------------

	--end

   -- Banco --

	if @cd_modelo = 30
	begin	 
	  exec pr_gera_importacao_tabela_banco  0,@cd_usuario, @cd_modelo
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end


	-- Usuários --

	if @cd_modelo = 29
	begin	 
	  exec pr_gera_importacao_tabela_usuario  0,@cd_usuario, @cd_modelo
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end



	--Produtos--

	if @cd_modelo = 3
	begin	 
	  exec pr_gera_importacao_tabela_produto  0,@cd_usuario, @cd_modelo
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end

	-- Transportadora --

	if @cd_modelo = 28
	begin	 
	  exec pr_gera_importacao_tabela_transportadora  0,@cd_usuario, @cd_modelo
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end

	-- Vendedor --

	if @cd_modelo = 27
	begin	 
	  exec pr_gera_importacao_tabela_preco  0,@cd_usuario, @cd_modelo
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end

	-- Vendedor --

	if @cd_modelo = 26
	begin	 
	  exec pr_gera_importacao_tabela_vendedor  0,@cd_usuario, @cd_modelo
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end

	if @cd_modelo = 25
	begin	 
	  exec pr_gera_importacao_tabela_unidade_medida  0,@cd_usuario
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end

    -- Fornecedor ---

	if @cd_modelo = 24
	begin	 
	  exec pr_gera_importacao_tabela_fornecedor  0,@cd_usuario
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end

	----Fornecedor
	
	--if @cd_modelo = 24
	--begin	 
	--  exec pr_gera_importacao_tabela_fornecedor  0,@cd_usuario
 --     select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	--   return
	--  --------------------------------------------------------------------------------------------------------------------

	--end

	--Cliente
	
	if @cd_modelo = 6
	begin	 
	  exec pr_gera_importacao_tabela_cliente  0,@cd_usuario
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end

	--Modelo Vazio para Gerar somente a Tabela de Cadasro--

	if @cd_modelo = 23
	begin	 
	  exec pr_gera_importacao_tabela_modelo_vazio  0,@cd_usuario
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end

	--Condição de Pagamento

	if @cd_modelo = 22
	begin	 
	  exec pr_gera_importacao_tabela_condicao_pagamento  0,@cd_usuario
      select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end
	--Nota de Saída-- (Resumo)

	if @cd_modelo = 19
	begin	 
	  --select * from cadastro
	   exec pr_gera_importacao_tabela_nota_saida_resumo 0,@cd_usuario
	   select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end


	--Contas a Pagar--

	if @cd_modelo = 18
	begin	 
	  --select * from cadastro
	   exec pr_gera_importacao_tabela_previsao_pagar 0,@cd_usuario
	   select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end


	--Contas a Pagar--

	if @cd_modelo = 17
	begin	 
	  --select * from cadastro
	   exec pr_gera_importacao_tabela_documento_pagar 0,@cd_usuario
	   select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  --------------------------------------------------------------------------------------------------------------------

	end
	   
	--Plano Financeiro--

	if @cd_modelo = 16
	begin
	 
	  --select * from cadastro
	   exec pr_gera_importacao_tabela_plano_financeiro 0,@cd_usuario
	   select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	  -------------------------------------------------------------

	end

	--Contas a Receber

	if @cd_modelo = 15
	begin
	 
	  --select * from cadastro
	   exec pr_gera_importacao_tabela_documento_receber 0,@cd_usuario
	   select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	 


	   -------------------------------------------------------------
	end
	
	--Tabela de Preço x Produtos

	if @cd_modelo = 14
	begin
	 
	  --select * from cadastro
	   exec pr_gera_importacao_tabela_preco_produto 0,@cd_usuario
	   select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	   -------------------------------------------------------------
	end

	if @cd_modelo = 13
	begin
	 
	  --select * from cadastro
	   exec pr_gera_importacao_previsao_producao 0,@cd_usuario
	   select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	 


	   -------------------------------------------------------------
	end

	if @cd_modelo = 11
	begin
	 
	  --select * from cadastro
	   exec pr_gera_cadastro_bem_ativo 0,@cd_usuario
	   select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	   return
	 


	   -------------------------------------------------------------

	end

    if @cd_modelo = 10
	  begin
	 
	    --select * from cadastro

		--if @cd_empresa in (329,340)
		--begin
	 --    exec pr_gera_entrada_estoque_produto_inventario_descricao 0,@cd_usuario
  --      end
		--else
		--begin
		--  exec pr_gera_entrada_estoque_produto_inventario 0,@cd_usuario
		--end

		-----------------------------------------------------------------------------------------------------

	     select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	     return
	   -------------------------------------------------------------
	  end
	else

	begin	 
	  exec pr_geracao_pedido_venda_entrada_planilha 0,@cd_usuario, 0
	  select 'Importação de Dados realizada com Sucesso!' as Msg, 200 as Cod
	  return
	end
	
	--Pedido de Venda-------------------------------------------------------------------------------

	--if @cd_modelo = 9
	--begin
	  --exec pr_geracao_pedido_venda_entrada_planilha 0,@cd_usuario, 0
	--end

	--select * from egisadmin.dbo.modelo_carga_dados
	------------------------------------------------------------------------------------------------
	 end try
		  begin catch
	     select 'Não foi possível importar os dados!' as Msg, 500 as Cod
	     return
	   end catch
	-------------------------------------------------------------------------------------------------
		 
	  select 'Não foi possível importar os dados!' as Msg, 500 as Cod

	return

end


go


----------------------------------------------------------------------------------------------------------------
--exec pr_egismob_importacao_dados ''
----------------------------------------------------------------------------------------------------------------
/*
*/
--exec pr_egis_importacao_dados
--'[
--{
--    "cd_parametro": 0,
--    "cd_modulo": "0",
--    "cd_menu": 6434
--}
--]'

--select * from TABMIG_424_Requisicao_Interna


--use egissql_317
--go

--drop table Planilha3

--select * from Cadastro

--delete from cadastro

--drop table kelvin

--select * from pedido_venda order by cd_pedido_venda desc

--select * from cadastro


--exec pr_egismob_importacao_dados '[
--	{
--    "cd_parametro": 1,
--    "cd_menu": 4,
--    "nm_planilha": "Cadastro",
--    "nm_arquivo": "Pedido de Venda",
--    "jsonMig": {
--        "Cadastro": [
--            {
--                "Data": "2024-06-28T00:00:00.000Z",
--                "Ocorrencia": "Consulta das Propostas pelo Serviço e Cliente, com a possibilidade do Download dos arquivos incluídos;",
--                "Responsavel": "Alexandre",
--                "Previsao": "2024-07-19T00:00:00.000Z",
--                "Realizado": null,
--                "Observacoes": "Consulta com Filtros de Cliente e Serviço/Produto com Botão para Gerenciamento dos Arquivos."
--            }
--        ]
--    },
--    "cd_modelo": 11,
--    "cd_modulo": "373",
--    "cd_usuario": "1634"}
--]'

--use egissql_317
--go


--select * from TABMIG_424_Requisicao_Interna