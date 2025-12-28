--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_processo_pesquisa_modulos' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_processo_pesquisa_modulos

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_processo_pesquisa_modulos','P') IS NOT NULL
    DROP PROCEDURE pr_egis_processo_pesquisa_modulos;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_processo_pesquisa_modulos
-------------------------------------------------------------------------------
-- pr_egis_processo_pesquisa_modulos
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Egis
--                   Processo de Pesquisa em Tabelas dos Módulos 
--
--Data             : 10.12.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_processo_pesquisa_modulos
------------------------

@json nvarchar(max) = '' --Parametro de entrada
------------------------------------------------------------------------------
--with encryption


as

-- ver nível atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;

--return

--set @json = isnull(@json,'')

 SET NOCOUNT ON;
 SET XACT_ABORT ON;

 BEGIN TRY
 
 /* 1) Validar payload - parameros de Entrada da Procedure */
 IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

 /* 2) Normalizar: aceitar array[0] ou objeto */
 IF JSON_VALUE(@json, '$[0]') IS NOT NULL
            SET @json = JSON_QUERY(@json, '$[0]'); -- pega o primeiro elemento


set @json = replace(
             replace(
               replace(
                replace(
                  replace(
                    replace(
                      replace(
                        replace(
                          replace(
                            replace(
                              replace(
                                replace(
                                  replace(
                                    replace(
                                    @json, CHAR(13), ' '),
                                  CHAR(10),' '),
                                ' ',' '),
                              ':\\\"',':\\"'),
                            '\\\";','\\";'),
                          ':\\"',':\\\"'),
                        '\\";','\\\";'),
                      '\\"','\"'),
                    '\"', '"'),
                  '',''),
                '["','['),
              '"[','['),
             ']"',']'),
          '"]',']') 

--Declaração das variaveis que seram utlizadas no procedimento (calculo, consulta, update, delete,insert,etc...)

declare @cd_empresa             int
declare @cd_parametro           int
declare @cd_documento           int = 0
declare @cd_item_documento      int
declare @cd_usuario             int 
declare @dt_hoje                datetime
declare @dt_inicial             datetime 
declare @dt_final               datetime
declare @cd_ano                 int = 0
declare @cd_mes                 int = 0
declare @cd_modelo              int = 0
declare @cd_tabela              int = 0 
declare @nm_atributo            varchar(80)
declare @nm_menu                varchar(120) = ''
declare @cd_cliente             int          = 0
declare @cd_vendedor            int          = 0
declare @nm_fantasia_cliente    varchar(60)  = ''
declare @cd_produto             int          = 0
declare @nm_fantasia_produto    varchar(60)  = ''
declare @cd_mascara_produto     varchar(60)  = ''
declare @nm_produto             varchar(120) = ''
declare @cd_fornecedor          int          = 0
declare @nm_fantasia_fornecedor varchar(60)  = ''
declare @nm_pesquisa_produto    varchar(120) = ''


----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano = year(getdate())
set @cd_mes = month(getdate())  

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end


--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287


--Montagem da tabela temporaria que vai receber o json e vai configurar cada variavel de entrada

select                     
 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root  --Comando que transforma o string json em uma tabela                   
   cross apply openjson(root.value) as valores      
   -- Para debug os parametros de entrada, descomentar o código abaixo
   --select * from #json 
   --return


--------------------------------------------------------------------------------------------
-- Definição da variavel de trabalho com o valor do atributo da tabela #json

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo'   
select @cd_tabela              = valor from #json where campo = 'cd_tabela'
select @nm_atributo            = valor from #json where campo = 'nm_atributo'
select @nm_menu				   = valor from #json where campo = 'nm_menu'
select @cd_cliente             = valor from #json where campo = 'cd_cliente'
select @nm_fantasia_cliente    = valor from #json where campo = 'nm_fantasia_cliente'
select @nm_fantasia_produto    = valor from #json where campo = 'nm_fantasia_produto'
select @cd_mascara_produto     = valor from #json where campo = 'cd_mascara_produto'
select @cd_produto             = valor from #json where campo = 'cd_produto'
select @cd_fornecedor          = valor from #json where campo = 'cd_fornecedor'
select @nm_fantasia_fornecedor = valor from #json where campo = 'nm_fantasia_fornecedor'
select @nm_pesquisa_produto    = valor from #json where campo = 'nm_pesquisa_produto'
select @nm_produto             = valor from #json where campo = 'nm_produto'
--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro         = ISNULL(@cd_parametro,0)
set @cd_modelo            = isnull(@cd_modelo,0)
set @cd_tabela            = isnull(@cd_tabela,0)
set @nm_atributo          = isnull(@nm_atributo,0)
set @cd_cliente           = isnull(@cd_cliente,0)
set @nm_fantasia_cliente  = isnull(@nm_fantasia_cliente,'')
set @cd_mascara_produto   = ltrim(rtrim(isnull(@cd_mascara_produto,'')))
set @nm_pesquisa_produto  = isnull(@nm_pesquisa_produto,'')
set @nm_produto           = isnull(@nm_produto,'')

---------------------------------------------------------------------------------------------------------------------------------------------------------    

--Teste de execução para validar 


IF ISNULL(@cd_parametro,0) = 0
BEGIN
  select 
    'Sucesso' as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final,
	 @cd_usuario  as cd_usuario


  RETURN;

END

--Dados de Pesquisa do Cliente --

if @cd_parametro = 1
begin

  select
    c.cd_cliente,
    c.nm_fantasia_cliente,
    c.nm_razao_social_cliente,
    v.nm_fantasia_vendedor,

    --Crédito-----------------------------------------------------
    i.ic_serasa_cliente,
    i.ic_bloqueio_faturamento,
    i.ic_alerta_credito_cliente,
    i.ic_bloqueio_total_cliente,
    i.dt_suspensao_credito,
    i.nm_credito_suspenso,
    i.ic_credito_suspenso,
    i.ds_observacao_credito,
    i.dt_situacao_credito,
    c.dt_cadastro_cliente,
    isnull(i.vl_limite_credito_cliente,0) as vl_limite_credito_cliente


  from
    cliente c
    left outer join vendedor v                   on v.cd_vendedor = c.cd_vendedor
    left outer join cliente_informacao_credito i on i.cd_cliente  = c.cd_cliente
    left outer join condicao_pagamento cp        on cp.cd_condicao_pagamento = i.cd_condicao_pagamento
    left outer join forma_pagamento fp           on fp.cd_forma_pagamento    = i.cd_forma_pagamento

  where
    --c.cd_cliente = case when @cd_cliente = 0 then c.cd_cliente else @cd_cliente end
     (@cd_cliente = 0 OR c.cd_cliente = @cd_cliente)
        AND (@nm_fantasia_cliente IS NULL OR c.nm_fantasia_cliente LIKE '%' + @nm_fantasia_cliente + '%')
  order by
    c.nm_fantasia_cliente

  return

end

--Dados de Pesquisa do Produto --

if @cd_parametro = 10
begin
  
  select
    p.cd_produto,
    p.cd_mascara_produto,
    p.nm_fantasia_produto,
    p.nm_produto,
    um.sg_unidade_medida,
    isnull(ps.qt_saldo_reserva_produto,0) as qt_saldo_reserva_produto,
    isnull(p.qt_dias_entrega_medio,0)     as qt_dias_entrega_medio,
    isnull(gp.nm_grupo_produto,'')        as nm_grupo_produto,
    isnull(cp.nm_categoria_produto,'')    as nm_categoria_produto,
    isnull(fp.nm_familia_produto,'')      as nm_familia_produto

  from
    produto p
    inner join Grupo_Produto gp          on gp.cd_grupo_produto   = p.cd_grupo_produto
    left outer join categoria_produto cp on cp.cd_categoria_produto = p.cd_categoria_produto
    left outer join unidade_medida um    on um.cd_unidade_medida  = p.cd_unidade_medida
    left outer join produto_saldo ps     on ps.cd_produto         = p.cd_produto         and ps.cd_fase_produto = p.cd_fase_produto_baixa
    left outer join familia_produto fp on fp.cd_familia_produto = p.cd_familia_produto
  where
    ( @cd_mascara_produto is null or p.cd_mascara_produto like '%' + @cd_mascara_produto + '%' )
    AND (@nm_produto IS NULL OR p.nm_produto LIKE '%' + @nm_produto + '%')
  
  order by
    p.cd_mascara_produto

  return

end


if @cd_parametro = 100
begin
  
  select
    c.cd_cliente,
    c.nm_fantasia_cliente,
    c.nm_razao_social_cliente,
    v.nm_fantasia_vendedor,
    tp.nm_tipo_pessoa,

    --Tipo de Pessoa-----------------------------------------------------------

    case when c.cd_tipo_pessoa = 1 then            
      dbo.fn_formata_cnpj(c.cd_cnpj_cliente)            
    else            
      dbo.fn_formata_cpf(c.cd_cnpj_cliente)            
    end                                                   as 'cd_cnpj_cliente',            
    c.cd_inscestadual,      

    --Endereço do Cliente    
    c.cd_cep,   
    rtrim(ltrim(c.nm_endereco_cliente))+', '+rtrim(ltrim(c.cd_numero_endereco)) as nm_endereco_cliente,      
    c.nm_complemento_endereco,      
    c.nm_bairro,
    ci.nm_cidade,      
    e.sg_estado,  
    r.nm_ramo_atividade,      
    f.nm_fonte_informacao,      
    s.nm_status_cliente,      
    c.cd_ddd,       
    c.cd_telefone,      
    ------------------------
    c.dt_cadastro_cliente,      
    cp.nm_condicao_pagamento, 
    cv.nm_criterio_visita,   
    
    --Crédito-----------------------------------------------------
    i.ic_serasa_cliente,
    i.ic_bloqueio_faturamento,
    i.ic_alerta_credito_cliente,
    i.ic_bloqueio_total_cliente,
    i.dt_suspensao_credito,
    i.nm_credito_suspenso,
    i.ic_credito_suspenso,
    i.ds_observacao_credito,
    i.dt_situacao_credito,
    c.dt_cadastro_cliente,
    isnull(i.vl_limite_credito_cliente,0) as vl_limite_credito_cliente


  from
    cliente c
    left outer join tipo_pessoa tp                   with (nolock) on tp.cd_tipo_pessoa            = c.cd_tipo_pessoa
    left outer join vendedor v                       with (nolock) on v.cd_vendedor                = c.cd_vendedor
    left outer join cliente_informacao_credito i     with (nolock) on i.cd_cliente                 = c.cd_cliente
    left outer join condicao_pagamento cp            with (nolock) on cp.cd_condicao_pagamento     = i.cd_condicao_pagamento
    left outer join forma_pagamento fp               with (nolock) on fp.cd_forma_pagamento        = i.cd_forma_pagamento
    left outer join Ramo_Atividade r                 with (nolock) on c.cd_ramo_atividade          = r.cd_ramo_atividade                  
    left outer join Fonte_Informacao f               with (nolock) on c.cd_Fonte_Informacao        = f.cd_fonte_informacao                
    left outer join Status_Cliente s                 with (nolock) on s.cd_status_cliente          = c.cd_status_cliente                  
    left outer join Pais pa                          with (nolock) on pa.cd_pais                   = c.cd_pais                                        
    left outer join Estado e                         with (nolock) on e.cd_pais                    = c.cd_pais       
                                                                    and e.cd_estado                    = c.cd_estado  
    left outer join Cidade ci                        with (nolock) on ci.cd_pais                       = c.cd_pais       
                                                                      and ci.cd_estado                 = c.cd_estado       
                                                                      and ci.cd_cidade                 = c.cd_cidade                                               
    left outer join Cliente_Grupo gc                 with (nolock) on c.cd_cliente_grupo           = gc.cd_cliente_grupo                      
    left outer join Cliente_Regiao rg                with (nolock) on c.cd_regiao                  = rg.cd_cliente_regiao                    
    left outer join Tipo_Mercado tm                  with (nolock) on c.cd_tipo_mercado            = tm.cd_tipo_mercado                              
    left outer join Criterio_Visita cv               with (nolock) on cv.cd_criterio_visita        = c.cd_criterio_visita   
          
  where
    --c.cd_cliente = case when @cd_cliente = 0 then c.cd_cliente else @cd_cliente end
     (@cd_cliente = 0 OR c.cd_cliente = @cd_cliente)
     AND
     (@nm_fantasia_cliente IS NULL OR c.nm_fantasia_cliente LIKE '%' + @nm_fantasia_cliente + '%')
  
  order by
    c.nm_fantasia_cliente

  return

end

--Consulta de Fornecedores--

if @cd_parametro = 200
begin
    Select
      ic_status_fornecedor =
      case
			when isNull(f.ic_status_fornecedor,'A') = 'A' then
				'Ativo' 
			else 
				 'Inativo' 
      end,         

      f.cd_fornecedor,
      f.nm_fantasia_fornecedor,
      f.nm_razao_social,
      f.nm_razao_social_comple, 
      r.nm_ramo_atividade,
      c.nm_fantasia_comprador,
      p.cd_ddi_pais, 
      f.cd_ddd,
      f.cd_telefone,
      f.cd_cep,
      ci.nm_cidade,
      e.sg_estado,
      f.dt_cadastro_fornecedor,
      p.nm_pais,
      f.cd_cnpj_fornecedor,
      f.ic_simples_fornecedor,
      tm.nm_tipo_mercado,
      gf.nm_grupo_fornecedor,
      ap.nm_aplicacao_produto,
      cp.nm_condicao_pagamento,
      --Endereço do Fornecedor
      rtrim(ltrim(f.nm_endereco_fornecedor))+', '+rtrim(ltrim(f.cd_numero_endereco)) as nm_endereco_fornecedor,
      f.nm_complemento_endereco,
      f.nm_bairro,
      ci.cd_cidade_ibge,
      cc.nm_centro_custo,
    		tr.nm_transportadora,
			tp.nm_tipo_pessoa,     
      fic.ic_suspenso_compra,
      f.cd_inscEstadual, 
           
      cab.nm_conta_banco as nm_conta_pagamento, 
      cab.cd_conta_banco as cd_conta_pagamento
     from
     Fornecedor f with (nolock)
     left outer join Tipo_Pessoa tp           with (nolock) on f.cd_tipo_pessoa         = tp.cd_tipo_pessoa
     left outer join Ramo_Atividade r         with (nolock) on f.cd_ramo_atividade      = r.cd_ramo_atividade
     left outer join Estado e                 with (nolock) on f.cd_estado              = e.cd_estado
     left outer join Cidade ci                with (nolock) on f.cd_cidade              = ci.cd_cidade
     left outer join Comprador c              with (nolock) on c.cd_comprador           = f.cd_comprador
     left outer join pais p                   with (nolock) on f.cd_pais                = p.cd_pais
     left outer join tipo_mercado tm          with (nolock) on tm.cd_tipo_mercado       = f.cd_tipo_mercado
     left outer join EGISADMIN.dbo.Usuario us with (nolock) on f.cd_usuario             = us.cd_usuario
     left outer join Grupo_Fornecedor gf      with (nolock) on gf.cd_grupo_fornecedor   = f.cd_grupo_fornecedor
     left outer join Destinacao_Produto dp    with (nolock) on dp.cd_destinacao_produto = f.cd_destinacao_produto
     left outer join Aplicacao_produto ap     with (nolock) on ap.cd_aplicacao_produto  = f.cd_aplicacao_produto
     left outer join Condicao_Pagamento cp    with (nolock) on cp.cd_condicao_pagamento = f.cd_condicao_pagamento
     left outer join centro_custo cc          with (nolock) on cc.cd_centro_custo       = f.cd_centro_custo
     left outer join plano_financeiro pf      with (nolock) on pf.cd_plano_financeiro   = f.cd_plano_financeiro
		 left outer join plano_conta pc 					with (nolock) on pc.cd_conta 						  = f.cd_conta		
		 left outer join transportadora tr        with (nolock) on tr.cd_transportadora     = f.cd_transportadora
     left outer join fornecedor_informacao_compra fic with (nolock) on fic.cd_fornecedor = f.cd_fornecedor
     left outer join fornecedor_pagamento fp  with (nolock) on fp.cd_fornecedor         = f.cd_fornecedor
     left outer join conta_agencia_banco cab  with (nolock) on cab.cd_conta_banco       = fp.cd_conta_banco
     left outer join banco b                  with (nolock) on b.cd_banco               = f.cd_banco
     left outer join termo_comercial tc       with (nolock) on tc.cd_termo_comercial    = f.cd_termo_comercial
  where
    
    --c.cd_cliente = case when @cd_cliente = 0 then c.cd_cliente else @cd_cliente end
     (@cd_fornecedor = 0 OR f.cd_fornecedor = @cd_fornecedor)
        AND (@nm_fantasia_fornecedor IS NULL OR f.nm_fantasia_fornecedor LIKE '%' + @nm_fantasia_fornecedor + '%')
  order by
    f.nm_fantasia_fornecedor

  return

end



if @cd_parametro = 999
begin

  return

end

   
/* Padrão se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;
   
 END TRY
    BEGIN CATCH
        DECLARE
            @errnum   INT          = ERROR_NUMBER(),
            @errmsg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @errproc  NVARCHAR(128) = ERROR_PROCEDURE(),
            @errline  INT          = ERROR_LINE(),
            @fullmsg  NVARCHAR(2048);



         -- Monta a mensagem (THROW aceita até 2048 chars no 2º parâmetro)
    SET @fullmsg =
          N'Erro em pr_egis_modelo_procedure ('
        + ISNULL(@errproc, N'SemProcedure') + N':'
        + CONVERT(NVARCHAR(10), @errline)
        + N') #' + CONVERT(NVARCHAR(10), @errnum)
        + N' - ' + ISNULL(@errmsg, N'');

    -- Garante o limite do THROW
    SET @fullmsg = LEFT(@fullmsg, 2048);

    -- Relança com contexto (state 1..255)
    THROW 50000, @fullmsg, 1;

        -- Relança erro com contexto
        --THROW 50000, CONCAT('Erro em pr_egis_modelo_procedure (',
        --                    ISNULL(@errproc, 'SemProcedure'), ':',
        --                    @errline, ') #', @errnum, ' - ', @errmsg), 1;
    END CATCH

---------------------------------------------------------------------------------------------------------------------------------------------------------    
go

--update
--  cliente_informacao_credito
--  set
--    vl_limite_credito_cliente = 1000
--where
-- isnull(vl_limite_credito_cliente,0) = 0

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_processo_pesquisa_modulos
------------------------------------------------------------------------------

--sp_helptext pr_egis_modelo_procedure

go

--use egissql_rubio
--go

/*
exec  pr_egis_processo_pesquisa_modulos '[{"cd_parametro": 0}]'
exec  pr_egis_processo_pesquisa_modulos '[{"cd_parametro": 1, "nm_fantasia_cliente":"ad"}]'
exec  pr_egis_processo_pesquisa_modulos '[{"cd_parametro": 10, "cd_mascara_produto":"ek.0500"}]'
exec  pr_egis_processo_pesquisa_modulos '[{"cd_parametro": 100, "nm_fantasia_cliente":"k"}]'
exec  pr_egis_processo_pesquisa_modulos '[{"cd_parametro": 200, "cd_fornecedor":"1"}]'
exec  pr_egis_processo_pesquisa_modulos '[{"cd_parametro": 999, "cd_modelo": 1}]'                                   
*/
go

-----------------------------------------------------------------------------------------------------------------
GO
--use egissql_368


--select * from cliente

--insert into cliente
--select top 1 * from egissql_368.dbo.cliente

--update
--  egisadmin.dbo.menu
--  set
--    ic_json_parametro = 'S',
--    cd_parametro = 100,
--      ic_selecao_registro = 'S'
--where
--  cd_menu = 8788


  
