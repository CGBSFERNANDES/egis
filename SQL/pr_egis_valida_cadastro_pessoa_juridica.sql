--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_valida_cadastro_pessoa_juridica' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_valida_cadastro_pessoa_juridica

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_valida_cadastro_pessoa_juridica','P') IS NOT NULL
    DROP PROCEDURE pr_egis_admin_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_valida_cadastro_pessoa_juridica
-------------------------------------------------------------------------------
-- pr_egis_valida_cadastro_pessoa_juridica
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
--                   Modelo de Procedure com Processos
--
--Data             : 20.12.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_valida_cadastro_pessoa_juridica
------------------------
@json nvarchar(max) = ''
------------------------------------------------------------------------------
--with encryption


as

-- ver nível atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;
  
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
  
  
declare @cd_empresa           int  
declare @cd_parametro         int  
declare @cd_documento         int = 0  
declare @cd_item_documento    int  
declare @cd_usuario           int   
declare @dt_hoje              datetime  
declare @dt_inicial           datetime   
declare @dt_final             datetime  
declare @cd_ano               int = 0  
declare @cd_mes               int = 0  
declare @cd_modelo            int = 0  
declare @cd_documento_receber int = 0  
declare @vl_saldo_documento   decimal(25,2) = 0.00  
declare @vl_documento_receber decimal(25,2) = 0.00  
declare @cd_identificacao     varchar(50)  
declare @cd_cnpj              varchar(18) = ''  
declare @cd_tipo_destinatario int = 0   
  
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
  
select                       
  
 1                                                   as id_registro,  
 IDENTITY(int,1,1)                                   as id,  
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                       
 valores.[value]                                     as valor                      
                      
 into #json                      
 from                  
   openjson(@json)root                      
   cross apply openjson(root.value) as valores        
  
--------------------------------------------------------------------------------------------  
  
select @cd_empresa             = valor from #json where campo = 'cd_empresa'               
select @cd_parametro           = valor from #json where campo = 'cd_parametro'            
select @cd_usuario             = valor from #json where campo = 'cd_usuario'               
select @dt_inicial             = valor from #json where campo = 'dt_inicial'               
select @dt_final               = valor from #json where campo = 'dt_final'               
select @cd_modelo              = valor from #json where campo = 'cd_modelo'   
select @cd_cnpj                = valor from #json where campo = 'cd_cnpj'  
  
--------------------------------------------------------------------------------------  
  
set @cd_empresa = ISNULL(@cd_empresa,0)  
  
if @cd_empresa = 0  
   set @cd_empresa = dbo.fn_empresa()  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------      
--Processos             
---------------------------------------------------------------------------------------------------------------------------------------------------------      
set @cd_parametro         = ISNULL(@cd_parametro,0)  
set @cd_cnpj              = isnull(@cd_cnpj,'')  
set @cd_tipo_destinatario = isnull(@cd_tipo_destinatario,0)  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------      
  
  
IF ISNULL(@cd_parametro,0) = 0  
BEGIN  
  
  select   
    'Sucesso'     as Msg,  
     @cd_modelo   AS cd_modelo,  
     @cd_empresa  AS cd_empresa,  
     @dt_inicial  AS dt_inicial,  
     @dt_final    AS dt_final,  
     @cd_usuario  AS cd_usuario  
  
  
  RETURN;  
  
END  
  
--select * from tipo_destinatario  
  
----------------------------------------------------------------------------------------------------  
  
if @cd_parametro = 1  
begin  
  select * from tipo_destinatario  
  return  
end  
  
  --Validação de Cadastro---  
  
  if @cd_parametro = 2  
  begin  
  
  SELECT TOP 1  
      LEFT(  
        (  
            COALESCE('Receita|', '') +  
            COALESCE(CASE WHEN c.cd_cnpj_cliente IS NOT NULL THEN 'Cliente|' END, '') +  
            COALESCE(CASE WHEN f.cd_cnpj_fornecedor IS NOT NULL THEN 'Fornecedor|' END, '') +  
            COALESCE(CASE WHEN t.cd_cnpj_transportadora IS NOT NULL THEN 'Transportadora|' END, '')  
        ),  
        LEN(  
            COALESCE('Receita|', '') +  
            COALESCE(CASE WHEN c.cd_cnpj_cliente IS NOT NULL THEN 'Cliente|' END, '') +  
            COALESCE(CASE WHEN f.cd_cnpj_fornecedor IS NOT NULL THEN 'Fornecedor|' END, '') +  
            COALESCE(CASE WHEN t.cd_cnpj_transportadora IS NOT NULL THEN 'Transportadora|' END, '')  
        ) - 1  
    ) AS TipoDestinatario,  
    crp.*,  
    CASE   
        WHEN c.cd_cnpj_cliente IS NOT NULL THEN 'Cliente'  
        WHEN f.cd_cnpj_fornecedor IS NOT NULL THEN 'Fornecedor'  
        WHEN t.cd_cnpj_transportadora IS NOT NULL THEN 'Transportadora'  
        ELSE 'Não cadastrado'  
    END AS TipoDestinatarioUnico,  
  
      
    -- Receita  
    crp.nm_fantasia              AS Receita_Fantasia,  
    crp.nm_razao_social          AS Receita_RazaoSocial,  
    crp.cd_inscestual            AS Receita_IE,  
    crp.nm_endereco              AS Receita_Endereco,  
  crp.cd_numero                AS Receita_Numero,  
    crp.nm_complemento           AS Receita_Complemento,  
    crp.nm_bairro                AS Receita_Bairro,  
    crp.nm_cidade                AS Receita_Cidade,  
    crp.ic_estado                AS Receita_Estado,  
    crp.nm_cep                   AS Receita_CEP,  
    crp.nm_telefone              AS Receita_Telefone,  
  
    -- Cliente  
    c.nm_fantasia_cliente      AS Cliente_Fantasia,  
    c.nm_razao_social_cliente  AS Cliente_RazaoSocial,  
    c.cd_inscestadual          AS Cliente_IE,  
    c.nm_endereco_cliente      AS Cliente_Endereco,  
    c.cd_numero_endereco       AS Cliente_Numero,  
    c.nm_complemento_endereco  AS Cliente_Complemento,  
    c.nm_bairro                AS Cliente_Bairro,  
    c.cd_cep                   AS Cliente_CEP,  
    c.cd_telefone              AS Cliente_Telefone,  
  
    -- Fornecedor  
    f.nm_fantasia_fornecedor  AS Fornecedor_Fantasia,  
    f.nm_razao_social         AS Fornecedor_RazaoSocial,  
    f.cd_inscEstadual         AS Fornecedor_IE,  
    f.nm_endereco_fornecedor  AS Fornecedor_Endereco,  
    f.cd_numero_endereco      AS Fornecedor_Numero,  
    f.nm_complemento_endereco AS Fornecedor_Complemento,  
    f.nm_bairro               AS Fornecedor_Bairro,  
    f.cd_cep                  AS Fornecedor_CEP,  
    f.cd_telefone             AS Fornecedor_Telefone,  
  
    -- Transportadora  
    t.nm_fantasia           AS Transportadora_Fantasia,  
    t.nm_transportadora     AS Transportadora_RazaoSocial,  
    t.cd_insc_estadual      AS Transportadora_IE,  
    t.nm_endereco           AS Transportadora_Endereco,  
    t.cd_numero_endereco    AS Transportadora_Numero,  
    t.nm_endereco_complemento AS Transportadora_Complemento,  
    t.nm_bairro             AS Transportadora_Bairro,  
    t.cd_cep                AS Transportadora_CEP,  
    t.cd_telefone           AS Transportadora_Telefone,  
  
    -- Comparações detalhadas  
  
    --CASE   
    --    WHEN crp.nm_fantasia = c.nm_fantasia_cliente   
    --     AND crp.nm_fantasia = f.nm_fantasia_fornecedor   
    --     AND crp.nm_fantasia = t.nm_fantasia   
    --    THEN 'OK'  
    --    ELSE CONCAT(  
    --        CASE WHEN crp.nm_fantasia <> c.nm_fantasia_cliente THEN 'Cliente diferente; ' ELSE '' END,  
    --        CASE WHEN crp.nm_fantasia <> f.nm_fantasia_fornecedor THEN 'Fornecedor diferente; ' ELSE '' END,  
    --        CASE WHEN crp.nm_fantasia <> t.nm_fantasia THEN 'Transportadora diferente; ' ELSE '' END  
    --    )  
    --END AS Analise_Fantasia,  
  
    CASE   
        WHEN crp.nm_razao_social = c.nm_razao_social_cliente   
         AND crp.nm_razao_social = f.nm_razao_social   
         AND crp.nm_razao_social = t.nm_transportadora   
        THEN 'OK'  
        ELSE CONCAT(  
            CASE WHEN crp.nm_razao_social <> c.nm_razao_social_cliente THEN 'Cliente diferente; ' ELSE '' END,  
            CASE WHEN crp.nm_razao_social <> f.nm_razao_social THEN 'Fornecedor diferente; ' ELSE '' END,  
            CASE WHEN crp.nm_razao_social <> t.nm_transportadora THEN 'Transportadora diferente; ' ELSE '' END  
        )  
    END AS Analise_RazaoSocial,  
  
    CASE   
        WHEN crp.cd_inscestual = c.cd_inscestadual   
         AND crp.cd_inscestual = f.cd_inscEstadual   
         AND crp.cd_inscestual = t.cd_insc_estadual   
        THEN 'OK'  
        ELSE CONCAT(  
            CASE WHEN crp.cd_inscestual <> c.cd_inscestadual THEN 'Cliente diferente; ' ELSE '' END,  
            CASE WHEN crp.cd_inscestual <> f.cd_inscEstadual THEN 'Fornecedor diferente; ' ELSE '' END,  
            CASE WHEN crp.cd_inscestual <> t.cd_insc_estadual THEN 'Transportadora diferente; ' ELSE '' END  
        )  
    END AS Analise_IE,  
  
    CASE   
        WHEN crp.nm_endereco = c.nm_endereco_cliente   
         AND crp.nm_endereco = f.nm_endereco_fornecedor   
         AND crp.nm_endereco = t.nm_endereco   
        THEN 'OK'  
        ELSE CONCAT(  
            CASE WHEN crp.nm_endereco <> c.nm_endereco_cliente THEN 'Cliente diferente; ' ELSE '' END,  
            CASE WHEN crp.nm_endereco <> f.nm_endereco_fornecedor THEN 'Fornecedor diferente; ' ELSE '' END,  
            CASE WHEN crp.nm_endereco <> t.nm_endereco THEN 'Transportadora diferente; ' ELSE '' END  
        )  
    END AS Analise_Endereco,  
  
    CASE   
        WHEN crp.cd_numero = c.cd_numero_endereco   
         AND crp.cd_numero = f.cd_numero_endereco   
         AND crp.cd_numero = t.cd_numero_endereco   
        THEN 'OK'  
        ELSE CONCAT(  
            CASE WHEN crp.cd_numero <> c.cd_numero_endereco THEN 'Cliente diferente; ' ELSE '' END,  
            CASE WHEN crp.cd_numero <> f.cd_numero_endereco THEN 'Fornecedor diferente; ' ELSE '' END,  
            CASE WHEN crp.cd_numero <> t.cd_numero_endereco THEN 'Transportadora diferente; ' ELSE '' END  
        )  
    END AS Analise_Numero,  
  
    CASE   
        WHEN crp.nm_bairro = c.nm_bairro   
         AND crp.nm_bairro = f.nm_bairro   
         AND crp.nm_bairro = t.nm_bairro   
        THEN 'OK'  
        ELSE CONCAT(  
            CASE WHEN crp.nm_bairro <> c.nm_bairro THEN 'Cliente diferente; ' ELSE '' END,  
            CASE WHEN crp.nm_bairro <> f.nm_bairro THEN 'Fornecedor diferente; ' ELSE '' END,  
            CASE WHEN crp.nm_bairro <> t.nm_bairro THEN 'Transportadora diferente; ' ELSE '' END  
        )  
    END AS Analise_Bairro,  
  
  
     -- Cidade (somente Receita nas tabelas informadas)  
    'Somente Receita' AS Analise_Cidade,  
  
    -- Estado (somente Receita nas tabelas informadas)  
    'Somente Receita' AS Analise_Estado,  
  
    -- CEP (compara só dígitos)  
    CASE  
        WHEN r_norm.cep = c_norm.cep  
         AND r_norm.cep = f_norm.cep  
         AND r_norm.cep = t_norm.cep  
        THEN 'OK'  
        ELSE CONCAT(  
            CASE WHEN c_norm.cep IS NULL THEN 'Cliente ausente; '   
                 WHEN r_norm.cep <> c_norm.cep THEN 'Cliente diferente; ' END,  
            CASE WHEN f_norm.cep IS NULL THEN 'Fornecedor ausente; '   
                 WHEN r_norm.cep <> f_norm.cep THEN 'Fornecedor diferente; ' END,  
            CASE WHEN t_norm.cep IS NULL THEN 'Transportadora ausente; '   
                 WHEN r_norm.cep <> t_norm.cep THEN 'Transportadora diferente; ' END  
        )  
    END AS Analise_CEP  
  
    -- Telefone (compara só dígitos)  
    --CASE  
    --    WHEN r_norm.telefone = c_norm.telefone  
    --     AND r_norm.telefone = f_norm.telefone  
    --     AND r_norm.telefone = t_norm.telefone  
    --    THEN 'OK'  
    --    ELSE CONCAT(  
    --        CASE WHEN c_norm.telefone IS NULL THEN 'Cliente ausente; '   
    --             WHEN r_norm.telefone <> c_norm.telefone THEN 'Cliente diferente; ' END,  
    --        CASE WHEN f_norm.telefone IS NULL THEN 'Fornecedor ausente; '   
    --             WHEN r_norm.telefone <> f_norm.telefone THEN 'Fornecedor diferente; ' END,  
    --        CASE WHEN t_norm.telefone IS NULL THEN 'Transportadora ausente; '   
    --             WHEN r_norm.telefone <> t_norm.telefone THEN 'Transportadora diferente; ' END  
    --    )  
    --END AS Analise_Telefone  
  
  
  
    --CASE   
    --    WHEN crp.nm_cidade = c.nm_cidade   
    --     AND crp.nm_cidade = f.nm_cidade   
    --     AND crp.nm_cidade = t.nm_cidade   
    --    THEN 'OK'  
    --    ELSE CONCAT(  
    --        CASE WHEN crp.nm_cidade <> c.nm_cidade THEN 'Cliente diferente; ' ELSE '' END,  
    --        CASE WHEN crp.nm_cidade <> f.nm_cidade THEN 'Fornecedor diferente; ' ELSE '' END,  
    --        CASE WHEN crp.nm_cidade <> t.nm_cidade THEN 'Transportadora diferente; ' ELSE '' END  
    --    )  
    --END AS Analise_Cidade,  
  
    --CASE   
    --    WHEN crp.ic_estado = c.ic_estado   
    --     AND crp.ic_estado = f.ic_estado   
    --     AND crp.ic_estado = t.ic_estado   
    --    THEN 'OK'  
    --    ELSE CONCAT(  
    --        CASE WHEN crp.ic_estado <> c.ic_estado THEN 'Cliente diferente; ' ELSE '' END,  
    --        CASE WHEN crp.ic_estado <> f.ic_estado THEN 'Fornecedor diferente; ' ELSE '' END,  
    --        CASE WHEN crp.ic_estado <> t.ic_estado THEN 'Transportadora diferente; ' ELSE '' END  
    --    )  
    --END AS Analise_Estado,  
  
  
  
FROM EGISCNPJ.dbo.Consulta_Receita_Pessoa crp  
LEFT JOIN dbo.Cliente c   
       ON c.cd_cnpj_cliente = crp.cd_cnpj  
LEFT JOIN dbo.Fornecedor f   
       ON f.cd_cnpj_fornecedor = crp.cd_cnpj  
LEFT JOIN dbo.Transportadora t   
       ON t.cd_cnpj_transportadora = crp.cd_cnpj  
  
  
       -- Normalizações centralizadas para comparação justa  
CROSS APPLY (  
    SELECT  
        UPPER(LTRIM(RTRIM(crp.nm_fantasia)))     AS nm_fantasia,  
        UPPER(LTRIM(RTRIM(crp.nm_razao_social))) AS nm_razao_social,  
        UPPER(LTRIM(RTRIM(crp.cd_inscestual)))   AS ie,  
        UPPER(LTRIM(RTRIM(crp.nm_endereco)))     AS endereco,  
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), crp.cd_numero))), '')) AS numero,  
        UPPER(LTRIM(RTRIM(crp.nm_complemento)))  AS complemento,  
        UPPER(LTRIM(RTRIM(crp.nm_bairro)))       AS bairro,  
        -- CEP/Telefone: somente dígitos  
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(  
               LTRIM(RTRIM(crp.nm_cep)),'-',''),' ',''),  
               '.',''),',',''),'/',''),'(',''),')',''),'+',''),'_',''),'–','') AS cep,  
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(  
               LTRIM(RTRIM(crp.nm_telefone)),'-',''),' ',''),  
               '.',''),',',''),'/',''),'(',''),')',''),'+',''),'_',''),'–','') AS telefone  
) AS r_norm  
CROSS APPLY (  
    SELECT  
        UPPER(LTRIM(RTRIM(c.nm_fantasia_cliente)))     AS nm_fantasia,  
        UPPER(LTRIM(RTRIM(c.nm_razao_social_cliente))) AS nm_razao_social,  
        UPPER(LTRIM(RTRIM(c.cd_inscestadual)))         AS ie,  
        UPPER(LTRIM(RTRIM(c.nm_endereco_cliente)))     AS endereco,  
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), c.cd_numero_endereco))), '')) AS numero,  
        UPPER(LTRIM(RTRIM(c.nm_complemento_endereco))) AS complemento,  
        UPPER(LTRIM(RTRIM(c.nm_bairro)))               AS bairro,  
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(  
               LTRIM(RTRIM(c.cd_cep)),'-',''),' ',''),  
               '.',''),',',''),'/',''),'(',''),')',''),'+',''),'_',''),'–','') AS cep,  
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(  
               LTRIM(RTRIM(c.cd_telefone)),'-',''),' ',''),  
               '.',''),',',''),'/',''),'(',''),')',''),'+',''),'_',''),'–','') AS telefone  
) AS c_norm  
CROSS APPLY (  
    SELECT  
        UPPER(LTRIM(RTRIM(f.nm_fantasia_fornecedor))) AS nm_fantasia,  
        UPPER(LTRIM(RTRIM(f.nm_razao_social)))        AS nm_razao_social,  
        UPPER(LTRIM(RTRIM(f.cd_inscEstadual)))        AS ie,  
        UPPER(LTRIM(RTRIM(f.nm_endereco_fornecedor))) AS endereco,  
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), f.cd_numero_endereco))), '')) AS numero,  
        UPPER(LTRIM(RTRIM(f.nm_complemento_endereco))) AS complemento,  
        UPPER(LTRIM(RTRIM(f.nm_bairro)))              AS bairro,  
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(  
               LTRIM(RTRIM(f.cd_cep)),'-',''),' ',''),  
               '.',''),',',''),'/',''),'(',''),')',''),'+',''),'_',''),'–','') AS cep,  
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(  
               LTRIM(RTRIM(f.cd_telefone)),'-',''),' ',''),  
               '.',''),',',''),'/',''),'(',''),')',''),'+',''),'_',''),'–','') AS telefone  
) AS f_norm  
CROSS APPLY (  
    SELECT  
        UPPER(LTRIM(RTRIM(t.nm_fantasia)))          AS nm_fantasia,  
        UPPER(LTRIM(RTRIM(t.nm_transportadora)))    AS nm_razao_social,  
        UPPER(LTRIM(RTRIM(t.cd_insc_estadual)))     AS ie,  
        UPPER(LTRIM(RTRIM(t.nm_endereco)))          AS endereco,  
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(CONVERT(VARCHAR(20), t.cd_numero_endereco))), '')) AS numero,  
        UPPER(LTRIM(RTRIM(t.nm_endereco_complemento))) AS complemento,  
        UPPER(LTRIM(RTRIM(t.nm_bairro)))            AS bairro,  
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(  
               LTRIM(RTRIM(t.cd_cep)),'-',''),' ',''),  
               '.',''),',',''),'/',''),'(',''),')',''),'+',''),'_',''),'–','') AS cep,  
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(  
               LTRIM(RTRIM(t.cd_telefone)),'-',''),' ',''),  
               '.',''),',',''),'/',''),'(',''),')',''),'+',''),'_',''),'–','') AS telefone  
) AS t_norm  
  
WHERE crp.cd_cnpj = @cd_cnpj  
order by crp.dt_usuario desc  
      
    --select   
    --  top 1  
    --  crp.*   
    --from  
    --  EGISCNPJ.dbo.Consulta_Receita_Pessoa crp  
      
    --where  
    --  crp.cd_cnpj = @cd_cnpj  
  
  
    return  
  
  end  
  
  ----------------------------------------------------------------------------------------------------  
  
  if @cd_parametro = 3  
  begin  
        
    select * from Cliente c  
    where  
      cd_cnpj_cliente = @cd_cnpj  
  
    return  
  
  end  
  
  --------------------------------------------------------------------------------------  
    
  if @cd_parametro = 4  
  begin  
        
    select * from Fornecedor f  
    where  
      cd_cnpj_fornecedor = @cd_cnpj  
  
    return  
  
  end  
  
  ----------------------------------------------------------------------------------------------------  
  
  if @cd_parametro = 5  
  begin  
        
    select * from Transportadora t  
    where  
      cd_cnpj_transportadora = @cd_cnpj  
  
    return  
  
  end  
  
  
  if @cd_parametro = 10  
  begin  
    declare @qt_cliente   int = 0  
    declare @dt_validacao datetime = null   
    select  
      @qt_cliente = count(cd_cliente)  
    from  
      cliente c  
    where  
      c.cd_status_cliente = 1  
  
    --select * from cadastro_validacao  
  
    select   
      @dt_validacao = max(dt_validacao)  
    from  
      cadastro_validacao  
  
  
    select @qt_cliente as qt_cliente, @dt_validacao as dt_validacao  
  
  
    return  
  end  
  
  if @cd_parametro = 15  
  begin  
    --Fila_Validacao_CNPJ--  
    --select * from consulta_receita_pessoa where cd_cnpj = '02314572000170'  
    --select * from egiscnpj.dbo.consulta_receita_pessoa where cd_cnpj = '07633295000425'  
    --select * from egiscnpj.dbo.fila_validacao_cnpj order by dt_usuario desc  
    --select * from egiscnpj.dbo.consulta_receita_pessoa order by dt_usuario desc  
      
    INSERT INTO egiscnpj.dbo.fila_validacao_cnpj (  
    cd_fila,  
    cd_cnpj,  
    nm_status_validacao,  
    cd_usuario_inclusao,  
    dt_usuario_inclusao,  
    cd_usuario,  
    dt_usuario,  
    cd_empresa,  
    nm_banco_empresa  
)  
SELECT  
    (SELECT ISNULL(MAX(cd_fila),0) + 1 FROM egiscnpj.dbo.fila_validacao_cnpj) AS cd_fila,  
    TRY_CAST(@cd_cnpj as VARCHAR(18)) as cd_cnpj,  
    'PENDENTE' AS nm_status_validacao,  
    TRY_CAST(@cd_usuario AS INT) as cd_usuario_inclusao,  
    GETDATE() AS dt_usuario_inclusao,  
    TRY_CAST(@cd_usuario AS INT) as cd_usuario,  
    GETDATE() AS dt_usuario,  
    TRY_CAST(@cd_empresa AS INT) as cd_empresa,  
    DB_NAME() AS nm_banco_empresa   -- aqui pega o nome do banco atual  
where  
  @cd_cnpj not in ( select f.cd_cnpj from EGISCNPJ.dbo.fila_validacao_cnpj f  
                    where   
                      f.cd_cnpj = @cd_cnpj )  
--FROM egiscnj.dbo.consulta_receita_pessoa crp  
--WHERE crp.cd_cnpj = @cd_cnpj;  
  
  
    return  
  end  
  
  
  if @cd_parametro = 20  
  begin  
  
  INSERT INTO cadastro_validacao (  
    cd_validacao,  
    cd_tipo_destinatario,  
    cd_destinatario,  
    dt_validacao,  
    cd_cnpj,  
    nm_endereco,  
    cd_numero,  
    nm_complemento,  
    nm_bairro,  
    nm_cidade,  
    sg_estado,  
    cd_cep,  
    cd_usuario_inclusao,  
    dt_usuario_inclusao,  
    cd_usuario,  
    dt_usuario  
)  
SELECT  
  (SELECT ISNULL(MAX(cd_validacao),0) + 1 FROM cadastro_validacao) AS cd_validacao,  
   
    TRY_CAST(1 AS INT),  
    TRY_CAST(0 AS INT),  
    GETDATE(),  
   TRY_CAST(crp.cd_cnpj AS VARCHAR(18)),  
    TRY_CAST(crp.nm_endereco AS VARCHAR(60)),  
    TRY_CAST(crp.cd_numero AS VARCHAR(10)),  
    TRY_CAST(crp.nm_complemento AS VARCHAR(60)),  
    TRY_CAST(crp.nm_bairro AS VARCHAR(25)),  
    TRY_CAST(crp.nm_cidade AS VARCHAR(60)),  
    TRY_CAST(crp.ic_estado AS CHAR(2)),  
    TRY_CAST(crp.nm_cep AS VARCHAR(8)),  
    TRY_CAST(crp.cd_usuario_inclusao AS INT),  
    TRY_CAST(crp.dt_usuario_inclusao AS DATETIME),  
    TRY_CAST(crp.cd_usuario AS INT),  
    TRY_CAST(crp.dt_usuario AS DATETIME)  
FROM egiscnpj.dbo.consulta_receita_pessoa crp  
--CROSS JOIN (SELECT MAX(cd_validacao) AS cd_validacao FROM cadastro_validacao) cv  
WHERE crp.cd_cnpj = @cd_cnpj;  
  
update  
  cliente  
set  
  cd_cep              = case when cd_cep <> cast(nm_cep as varchar(8)) then nm_cep else c.cd_cep end,  
  
  nm_endereco_cliente = case when nm_endereco_cliente <> cast(nm_endereco as varchar(60)) then  
                            crp.nm_endereco  
                        else  
                           c.nm_endereco_cliente   
                        end,  
  
  cd_numero_endereco = case when cd_numero_endereco <> cast(cd_numero as varchar(10)) then  
                            crp.cd_numero  
                        else  
                           c.cd_numero_endereco   
                        end,  
  
  nm_complemento_endereco = case when nm_complemento_endereco <> cast(crp.nm_complemento as varchar(60))   
                            and  
                            isnull(crp.nm_complemento,'')<>''  
                            then  
                              crp.nm_complemento  
                            else  
                              c.nm_complemento_endereco   
                            end,  
  
  
  nm_bairro               = case when c.nm_bairro <> cast(crp.nm_bairro as varchar(60)) then  
                              crp.nm_bairro  
                            else  
                              c.nm_bairro   
                            end,  
  
  cd_inscestadual         = case when cd_inscestadual <> cast(crp.cd_inscestual as varchar(18)) then  
                              crp.cd_inscestual  
                            else  
                              c.cd_inscestadual   
                            end,  
  
  
  cd_telefone         = case when cd_telefone<>STUFF(nm_telefone, PATINDEX('%([0-9][0-9])%', nm_telefone), 5, '') then  
                          STUFF(nm_telefone, PATINDEX('%([0-9][0-9])%', nm_telefone), 5, '')  
                        else  
                          c.cd_telefone  
                        end  
  
  
from  
  cliente c  
  inner join egiscnpj.dbo.consulta_receita_pessoa crp on crp.cd_cnpj = c.cd_cnpj_cliente  
where  
  cd_cnpj_cliente = @cd_cnpj  
  
  --select cd_telefone, * from cliente where cd_cnpj_cliente = '04602326000140'  
  
return  
  
  end  
  
if @cd_parametro = 50  
begin  
  select  
    c.cd_cliente, c.cd_cnpj_cliente, c.nm_razao_social_cliente, c.dt_cadastro_cliente  
  from  
    cliente c  
  where  
    isnull(c.cd_status_cliente,0) = 1  
    and  
    c.cd_cnpj_cliente not in ( select p.cd_cnpj from egiscnpj.dbo.consulta_receita_pessoa p  
                               where  
                                 p.cd_cnpj = c.cd_cnpj_cliente)  
    and  
    isnull(c.cd_tipo_pessoa,0) = 1  
    and  
    isnull(c.cd_cnpj_cliente,'')<>''  
    --and  
    --len(c.cd_cnpj_cliente)   
  order by  
    c.dt_cadastro_cliente desc, c.nm_fantasia_cliente  
  
  return  
end  
  
  
if @cd_parametro = 9999  
begin  
  return  
end  
  
--use egissql_317  
--  
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
          N'Erro em pr_egis_valida_cadastro_pessoa_juridica ('  
        + ISNULL(@errproc, N'SemProcedure') + N':'  
        + CONVERT(NVARCHAR(10), @errline)  
        + N') #' + CONVERT(NVARCHAR(10), @errnum)  
        + N' - ' + ISNULL(@errmsg, N'');  
  
    -- Garante o limite do THROW  
    SET @fullmsg = LEFT(@fullmsg, 2048);  
  
    -- Relança com contexto (state 1..255)  
    THROW 50000, @fullmsg, 1;  
  
        -- Relança erro com contexto  
        --THROW 50000, CONCAT('Erro em pr_egis_valida_cadastro_pessoa_juridica (',  
        --                    ISNULL(@errproc, 'SemProcedure'), ':',  
        --                    @errline, ') #', @errnum, ' - ', @errmsg), 1;  
    END CATCH  
  

---------------------------------------------------------------------------------------------------------------------------------------------------------    
go



------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_admin_processo_modulo
------------------------------------------------------------------------------
--use egissql
--go

--exec  pr_egis_admin_processo_modulo '[{"cd_parametro": 0 }]' 
--exec  pr_egis_valida_cadastro_pessoa_juridica '[{"cd_parametro": 1, "cd_usuario": 113 }]' 

go
------------------------------------------------------------------------------
GO
