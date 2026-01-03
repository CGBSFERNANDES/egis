--BANCO DA EMPRESA/CLIENTE
--use EGISSQL_355

IF OBJECT_ID(N'dbo.pr_egis_nfe_monitor_processo', N'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_nfe_monitor_processo;
GO


-------------------------------------------------------------------------------
--sp_helptext  pr_egis_nfe_monitor_processo
-------------------------------------------------------------------------------
-- pr_egis_nfe_monitor_processo
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
--Data             : 03.01.2026
--Alteração        : 
--
--
------------------------------------------------------------------------------

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE pr_egis_nfe_monitor_processo
------------------------
@json nvarchar(max) = ''
------------------------------------------------------------------------------
--with encryption


as

-- ver nvel atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;

--return

--set @json = isnull(@json,'')

 SET NOCOUNT ON;
 SET XACT_ABORT ON;
 
    DECLARE @__sucesso BIT = 0;
    DECLARE @__codigo  INT = 0;
    DECLARE @__mensagem NVARCHAR(4000) = N'OK';
 

 BEGIN TRY
 
 /* 1) Validar payload - parameros de Entrada da Procedure */
 IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON invlido ou vazio em @json.', 1;

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
                                '',' '),
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


declare @cd_empresa             int
declare @cd_parametro           int
declare @cd_documento           int = 0
declare @cd_item_documento      int
declare @cd_usuario             int 
declare @dt_hoje                datetime
declare @dt_inicial             datetime 
declare @dt_final               datetime
declare @dt_inicial_anterior    datetime 
declare @dt_final_anterior      datetime
declare @cd_ano                 int = 0
declare @cd_mes                 int = 0
declare @cd_modelo              int = 0
declare @cd_grupo_usuario       int = 0
declare @qt_contrato_empresa    int = 0
declare @cd_modulo              int = 0
declare @cd_empresa_faturamento int = 0
declare @cd_serie_nota          int = 0

--select * from egisadmin.dbo.empresa

----------------------------------------------------------------------------------------------------------------

declare @dados_registro           nvarchar(max) = ''
declare @dados_modal              nvarchar(max) = ''
----------------------------------------------------------------------------------------------------------------

set @cd_empresa          = 0
set @cd_parametro        = 0
set @dt_hoje             = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano              = year(getdate())
set @cd_mes              = month(getdate())  
set @qt_contrato_empresa = 0

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
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
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
select @cd_grupo_usuario       = valor from #json where campo = 'cd_grupo_usuario'
select @cd_modulo              = valor from #json where campo = 'cd_modulo'
select @cd_serie_nota          = valor from #json where campo = 'cd_serie_nota'
select @cd_empresa_faturamento = valor from #json where campo = 'cd_empresa_faturamento'

---------------------------------------------------------------------------------------------

select @dados_registro         = valor from #json where campo = 'dados_registro'
select @dados_modal            = valor from #json where campo = 'dados_modal'

--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro           = ISNULL(@cd_parametro,0)
set @cd_usuario             = isnull(@cd_usuario,0)
set @cd_grupo_usuario       = isnull(@cd_grupo_usuario,0)
set @cd_modulo              = isnull(@cd_modulo,0)
set @cd_serie_nota          = isnull(@cd_serie_nota,0)
set @cd_empresa_faturamento = isnull(@cd_empresa_faturamento,0)

-- Calcula o mesmo dia/mês, mas com ano anterior 
SET @dt_inicial_anterior = DATEFROMPARTS(YEAR(@dt_inicial) - 1, MONTH(@dt_inicial), DAY(@dt_inicial)); 
SET @dt_final_anterior   = DATEFROMPARTS(YEAR(@dt_final) - 1, MONTH(@dt_final), DAY(@dt_final));

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


 
    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  RETURN;

END

--Tipos de Documentos ou Nota Fiscais---------------------------------------------

if @cd_parametro = 1
begin
   /*
   	    tipoDocOptions: [
	      { label: 'NF-e (Modelo 55/65)', value: 'NFE' },
	      { label: 'NFS-e (Serviço)', value: 'NFSE' },
	      { label: 'CT-e', value: 'CTE' }
	    ],
    */
    
SELECT 
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS id,
    v.label,
    v.value,
    v.cd_modelo,
    v.nm_documento
FROM 
    (VALUES
        ('NF-e (Modelo 55)', 'NFE55', 55, 'Nota Fiscal Eletrônica de mercadorias'),
        ('NF-e (Modelo 65)', 'NFE65', 65, 'Nota Fiscal de Consumidor Eletrônica'),
        ('NFS-e (Serviço)', 'NFSE', 99, 'Nota Fiscal de Serviço Eletrônica'),
        ('CT-e', 'CTE', 57, 'Conhecimento de Transporte Eletrônico'),
        ('NF-e Comunicação (Modelo 21)', 'NFE21', 21, 'Nota Fiscal de Comunicação')
    ) AS v(label, value, cd_modelo, nm_documento);
      
 
    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  return

end

--Tipo de Movimento--

if @cd_parametro = 2
begin

  SELECT 
      ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS id,
      v.label,
      v.value
  FROM 
      (VALUES
          ('Entrada', 'ENTRADA'),
          ('Saída', 'SAIDA')
         
      ) AS v(label, value);

  return

end

--Série das Notas Fiscais

if @cd_parametro = 3
begin

  select 
    snf.cd_serie_nota_fiscal, 
    snf.sg_serie_nota_fiscal, 
    snf.nm_serie_nota_fiscal, 
    snf.ic_nfe_serie_nota,
    snf.cd_modelo_serie_nota,
    snf.cd_empresa_selecao,
    ef.nm_fantasia_empresa

  from 
    Serie_Nota_Fiscal snf
    left outer join empresa_faturamento ef on ef.cd_empresa = snf.cd_empresa_selecao
  
  order by
    snf.cd_serie_nota_fiscal

    --1-Nota_Saida
    --2-Nota_Saida 
    --3-Nota_Saida
    --4-cte_xml
    --5-Nota_Saida

    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
 return

end

--Empresas Faturamento

if @cd_parametro = 4
begin
  --select * from empresa_faturamento

  select 
   ef.cd_empresa,
   ef.nm_empresa,
   ef.nm_fantasia_empresa,
   ef.cd_cnpj_empresa,
   ef.cd_empresa_origem,
   e.nm_logo_empresa
  from 
     empresa_faturamento ef
     inner join egisadmin.dbo.empresa e on e.cd_empresa = ef.cd_empresa_origem

  order by
    ef.cd_empresa

    --1-Nota_Saida
    --2-Nota_Saida 
    --3-Nota_Saida
    --4-cte_xml
    --5-Nota_Saida

    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
 return

end

--Resumo de Notas Fiscais----

--select @cd_serie_nota, @cd_empresa_faturamento


if @cd_parametro = 5
begin
  -- Exemplo de controle por parâmetro -- 6 = Hoje -- 7 = Semanal -- 8 = Trimestral -- 9 = Semestral -- 10 = Anual

  
  /*
  select 
    snf.cd_serie_nota_fiscal, 
    max(snf.sg_serie_nota_fiscal)          as sg_serie_nota_fiscal, 
    max(snf.nm_serie_nota_fiscal)          as nm_serie_nota_fiscal,
    max(snf.ic_nfe_serie_nota)             as ic_nfe_serie_nota,
    max(snf.cd_modelo_serie_nota)          as cd_modelo_serie_nota,
    count(distinct snf.cd_empresa_selecao) as cd_empresa_selecao,
    count(ns.cd_nota_saida)                as qt_nota_saida,
    sum(case when isnull(ns.cd_status_nota,0)<>7 then
          ns.vl_total
        else
           0.00
        end)                                as vl_total
  into 
    #Serie   
  from 
    Serie_Nota_Fiscal snf
    left outer join empresa_faturamento ef on ef.cd_empresa = snf.cd_empresa_selecao
    left outer join Nota_Saida ns          on ns.cd_serie_nota = snf.cd_serie_nota_fiscal
  where
    ns.dt_nota_saida between @dt_inicial and @dt_final

  group by
    snf.cd_serie_nota_fiscal

  order by
    snf.cd_serie_nota_fiscal

  select * from #Serie
  order by
    qt_nota_saida desc

  */

  --select * from semana
  --select * from mes

  -- Série do período atual

 SELECT 
    snf.cd_serie_nota_fiscal, 
    MAX(snf.sg_serie_nota_fiscal)           AS sg_serie_nota_fiscal, 
    MAX(snf.nm_serie_nota_fiscal)           AS nm_serie_nota_fiscal,
    MAX(snf.ic_nfe_serie_nota)              AS ic_nfe_serie_nota,
    MAX(snf.cd_modelo_serie_nota)           AS cd_modelo_serie_nota,
    COUNT(DISTINCT snf.cd_empresa_selecao)  AS cd_empresa_selecao,
    COUNT(ns.cd_nota_saida)                 AS qt_nota_saida,
    count(distinct ns.cd_cliente)           as qt_cliente,
    count(distinct ns.cd_vendedor)          as qt_vendedor,
    count(distinct ns.sg_estado_nota_saida) as qt_estado,
    count(distinct ns.nm_cidade_nota_saida) as qt_cidade,
    SUM(CASE WHEN ISNULL(ns.cd_status_nota,0)<>7 THEN ns.vl_total ELSE 0 END) AS vl_total
INTO #SerieAtualParametro
FROM Serie_Nota_Fiscal snf
LEFT JOIN empresa_faturamento ef ON ef.cd_empresa = snf.cd_empresa_selecao
LEFT JOIN Nota_Saida ns          ON ns.cd_serie_nota = snf.cd_serie_nota_fiscal
WHERE 
  ns.dt_nota_saida BETWEEN @dt_inicial AND @dt_final
  and
  ns.cd_serie_nota = case when @cd_serie_nota = 0 then ns.cd_serie_nota else @cd_serie_nota end
  and
  isnull(snf.cd_empresa_selecao,0) = case when @cd_empresa_faturamento = 0 
                                     then isnull(snf.cd_empresa_selecao,0)
                                     else
                                         @cd_empresa_faturamento
                                     end

GROUP BY snf.cd_serie_nota_fiscal;

-- Série do período anterior

SELECT 
    snf.cd_serie_nota_fiscal, 
    COUNT(ns.cd_nota_saida)                AS qt_nota_saida_ant,
    SUM(CASE WHEN ISNULL(ns.cd_status_nota,0)<>7 THEN ns.vl_total ELSE 0 END) AS vl_total_ant
INTO #SerieAnteriorParametro
FROM Serie_Nota_Fiscal snf
LEFT JOIN Nota_Saida ns ON ns.cd_serie_nota = snf.cd_serie_nota_fiscal
WHERE
  ns.dt_nota_saida BETWEEN @dt_inicial_anterior AND @dt_final_anterior
  and
  ns.cd_serie_nota = case when @cd_serie_nota = 0 then ns.cd_serie_nota else @cd_serie_nota end
  and
  isnull(snf.cd_empresa_selecao,0) = case when @cd_empresa_faturamento = 0 
                                     then isnull(snf.cd_empresa_selecao,0)
                                     else
                                         @cd_empresa_faturamento
                                     end

GROUP BY snf.cd_serie_nota_fiscal;

-- Consolidado com % participação, ticket médio e delta

SELECT 
    a.cd_serie_nota_fiscal,
    a.sg_serie_nota_fiscal,
    a.nm_serie_nota_fiscal,
    a.cd_modelo_serie_nota,
    a.qt_nota_saida,
    a.vl_total,
    CAST(100.0 * a.vl_total / SUM(a.vl_total) OVER() AS DECIMAL(10,2)) AS perc_participacao,
    CASE WHEN a.qt_nota_saida > 0 THEN a.vl_total / a.qt_nota_saida ELSE 0 END AS ticket_medio,
    ISNULL(b.qt_nota_saida_ant,0) AS qt_nota_saida_ant,
    ISNULL(b.vl_total_ant,0)      AS vl_total_ant,
    a.vl_total - ISNULL(b.vl_total_ant,0) AS delta_valor,
    (CASE WHEN ISNULL(b.vl_total_ant,0) > 0 
          THEN (a.vl_total - b.vl_total_ant) * 100.0 / b.vl_total_ant 
          ELSE NULL END) AS delta_perc,

    a.qt_cliente,
    a.qt_vendedor,
    a.qt_estado,
    a.qt_cidade
FROM #SerieAtualParametro a
LEFT JOIN #SerieAnteriorParametro b ON a.cd_serie_nota_fiscal = b.cd_serie_nota_fiscal
ORDER BY perc_participacao DESC;

    --1-Nota_Saida
    --2-Nota_Saida 
    --3-Nota_Saida
    --4-cte_xml
    --5-Nota_Saida

    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
 return

end

if @cd_parametro in (6,7,8,9,10,11,12)
begin


--DECLARE @cd_parametro INT;   -- 6=Hoje, 7=Diário, 8=Semanal, 9=Mensal, 10=Trimestral, 11=Semestral, 12=Anual
--DECLARE @dt_inicial DATE;    -- fornecido pelo usuário
--DECLARE @dt_final   DATE;    -- fornecido pelo usuário

--DECLARE @cd_parametro INT;   -- 6=Hoje, 7=Diário(30 dias), 8=Semanal, 9=Mensal, 10=Trimestral, 11=Semestral, 12=Anual(últimos 3 anos)
--DECLARE @dt_inicial DATE;    -- fornecido pelo usuário
--DECLARE @dt_final   DATE;    -- fornecido pelo usuário

-- Normaliza intervalo conforme visão

-- Normaliza intervalo conforme visão, SEM usar GETDATE()

IF @cd_parametro = 6
BEGIN
    -- Hoje: força @dt_inicial = @dt_final
    SET @dt_inicial = @dt_hoje --@dt_final;
END
ELSE IF @cd_parametro = 7
BEGIN
   SET @dt_inicial = @dt_inicial
    -- Diário: últimos 30 dias a partir de @dt_final
    --SET @dt_inicial = DATEADD(DAY, -29, @dt_final);
END
ELSE IF @cd_parametro = 8
BEGIN
    -- Semanal: últimos 7 dias a partir de @dt_final
    SET @dt_inicial = DATEADD(DAY, -6, @dt_hoje);
END
ELSE IF @cd_parametro = 9
BEGIN
    -- Mensal: mantém intervalo informado pelo usuário
    -- Exemplo: se usuário passar 01/01/2025 a 31/12/2025, usamos esse range
    SET @dt_inicial = @dt_inicial;
    SET @dt_final   = @dt_final;
END
ELSE IF @cd_parametro = 10
BEGIN
    -- Trimestral: mantém intervalo informado pelo usuário
    SET @dt_inicial = @dt_inicial;
    SET @dt_final   = @dt_final;
END
ELSE IF @cd_parametro = 11
BEGIN
    -- Semestral: mantém intervalo informado pelo usuário
    SET @dt_inicial = @dt_inicial;
    SET @dt_final   = @dt_final;
END
ELSE IF @cd_parametro = 12
BEGIN
    -- Anual: últimos 3 anos relativos ao @dt_final informado
    SET @dt_inicial = DATEFROMPARTS(YEAR(@dt_final) - 3, 1, 1);
    SET @dt_final   = DATEFROMPARTS(YEAR(@dt_final), 12, 31);
END

--select @cd_empresa_faturamento, @cd_serie_nota

-- Ajuste de DATEFIRST para bater com tabela 'semana' (1=Domingo)
SET DATEFIRST 7;

;WITH Dados AS (
    SELECT
        snf.cd_serie_nota_fiscal,
        MAX(snf.sg_serie_nota_fiscal) AS sg_serie_nota_fiscal,
        MAX(snf.nm_serie_nota_fiscal) AS nm_serie_nota_fiscal,
        MAX(snf.ic_nfe_serie_nota)    AS ic_nfe_serie_nota,
        MAX(snf.cd_modelo_serie_nota) AS cd_modelo_serie_nota,
        COUNT(DISTINCT snf.cd_empresa_selecao) AS cd_empresa_selecao,
        COUNT(ns.cd_nota_saida) AS qt_nota_saida,
        SUM(CASE WHEN ISNULL(ns.cd_status_nota,0)<>7 THEN ns.vl_total ELSE 0 END) AS vl_total,
        CAST(ns.dt_nota_saida AS DATE) AS dt_nota_saida,
        DATEPART(WEEKDAY, ns.dt_nota_saida) AS cd_semana,
        DATEPART(MONTH,  ns.dt_nota_saida) AS cd_mes,
        DATEPART(QUARTER,ns.dt_nota_saida) AS cd_trimestre,
        YEAR(ns.dt_nota_saida)            AS cd_ano
    FROM Serie_Nota_Fiscal snf
    LEFT JOIN empresa_faturamento ef ON ef.cd_empresa = snf.cd_empresa_selecao
    LEFT JOIN Nota_Saida ns          ON ns.cd_serie_nota = snf.cd_serie_nota_fiscal
    WHERE ns.dt_nota_saida BETWEEN @dt_inicial AND @dt_final
          and
          ns.cd_serie_nota = case when @cd_serie_nota = 0 then ns.cd_serie_nota else @cd_serie_nota end
          and
          isnull(snf.cd_empresa_selecao,0) = case when @cd_empresa_faturamento = 0 
                                     then isnull(snf.cd_empresa_selecao,0)
                                     else
                                         @cd_empresa_faturamento
                                     end
        
    GROUP BY snf.cd_serie_nota_fiscal, CAST(ns.dt_nota_saida AS DATE),
             DATEPART(WEEKDAY, ns.dt_nota_saida),
             DATEPART(MONTH,  ns.dt_nota_saida),
             DATEPART(QUARTER,ns.dt_nota_saida),
             YEAR(ns.dt_nota_saida)
),
DimSemana AS (
    SELECT cd_semana, nm_semana, sg_semana FROM semana
),
DimMes AS (
    SELECT cd_mes, nm_mes, sg_mes FROM mes
),
Tagged AS (
    SELECT
        d.*,
        CASE
            WHEN @cd_parametro = 6 THEN 'HOJE'
            WHEN @cd_parametro = 7 THEN CONVERT(VARCHAR(10), d.dt_nota_saida, 120) -- YYYY-MM-DD
            WHEN @cd_parametro = 8 THEN CONCAT('SEM-', d.cd_semana)
            WHEN @cd_parametro = 9 THEN CONCAT('MES-', d.cd_mes, '-', d.cd_ano)    -- inclui ano para não mesclar anos diferentes
            WHEN @cd_parametro = 10 THEN CONCAT('TRI-', d.cd_ano, '-', d.cd_trimestre)
            WHEN @cd_parametro = 11 THEN CONCAT('SEM-', d.cd_ano, '-', CASE WHEN d.cd_trimestre IN (1,2) THEN 1 ELSE 2 END)
            WHEN @cd_parametro = 12 THEN CONCAT('ANO-', d.cd_ano)
        END AS period_key,
        CASE
            WHEN @cd_parametro = 6 THEN 'Hoje'
            WHEN @cd_parametro = 7 THEN CONVERT(VARCHAR(10), d.dt_nota_saida, 103) -- dd/MM/yyyy
            WHEN @cd_parametro = 8 THEN s.nm_semana
            WHEN @cd_parametro = 9 THEN CONCAT(m.nm_mes, '/', d.cd_ano)
            WHEN @cd_parametro = 10 THEN CONCAT('Tri ', d.cd_trimestre, '/', d.cd_ano)
            WHEN @cd_parametro = 11 THEN CONCAT('Sem ', CASE WHEN d.cd_trimestre IN (1,2) THEN 1 ELSE 2 END, '/', d.cd_ano)
            WHEN @cd_parametro = 12 THEN CAST(d.cd_ano AS VARCHAR(4))
        END AS period_label
    FROM Dados d
    LEFT JOIN DimSemana s ON s.cd_semana = d.cd_semana
    LEFT JOIN DimMes    m ON m.cd_mes    = d.cd_mes
),
AggAtual AS (
    SELECT
        cd_serie_nota_fiscal,
        MAX(sg_serie_nota_fiscal) AS sg_serie_nota_fiscal,
        MAX(nm_serie_nota_fiscal) AS nm_serie_nota_fiscal,
        MAX(ic_nfe_serie_nota)    AS ic_nfe_serie_nota,
        MAX(cd_modelo_serie_nota) AS cd_modelo_serie_nota,
        period_key,
        MAX(period_label)         AS period_label,
        SUM(qt_nota_saida)        AS qt_nota_saida,
        SUM(vl_total)             AS vl_total
    FROM Tagged
    GROUP BY cd_serie_nota_fiscal, period_key
),

-- Período anterior: desloca o intervalo pelo mesmo span (dias) para trás
Span AS (
    SELECT DATEDIFF(DAY, @dt_inicial, @dt_final) + 1 AS dias_span
),
DadosAnt AS (
    SELECT
        snf.cd_serie_nota_fiscal,
        COUNT(ns.cd_nota_saida) AS qt_nota_saida_ant,
        SUM(CASE WHEN ISNULL(ns.cd_status_nota,0)<>7 THEN ns.vl_total ELSE 0 END) AS vl_total_ant,
        CAST(ns.dt_nota_saida AS DATE) AS dt_nota_saida,
        DATEPART(WEEKDAY, ns.dt_nota_saida) AS cd_semana,
        DATEPART(MONTH,  ns.dt_nota_saida) AS cd_mes,
        DATEPART(QUARTER,ns.dt_nota_saida) AS cd_trimestre,
        YEAR(ns.dt_nota_saida)            AS cd_ano
    FROM Serie_Nota_Fiscal snf
    CROSS APPLY Span sp
    LEFT JOIN Nota_Saida ns ON ns.cd_serie_nota = snf.cd_serie_nota_fiscal
    WHERE ns.dt_nota_saida BETWEEN @dt_inicial_anterior AND @dt_final_anterior

            and
            ns.cd_serie_nota = case when @cd_serie_nota = 0 then ns.cd_serie_nota else @cd_serie_nota end
            and
            isnull(snf.cd_empresa_selecao,0) = case when @cd_empresa_faturamento = 0 
                                     then isnull(snf.cd_empresa_selecao,0)
                                     else
                                         @cd_empresa_faturamento
                                     end            
              
    GROUP BY snf.cd_serie_nota_fiscal, CAST(ns.dt_nota_saida AS DATE),
             DATEPART(WEEKDAY, ns.dt_nota_saida),
             DATEPART(MONTH,  ns.dt_nota_saida),
             DATEPART(QUARTER,ns.dt_nota_saida),
             YEAR(ns.dt_nota_saida)
),
TaggedAnt AS (
    SELECT
        d.*,
        CASE
            WHEN @cd_parametro = 6 THEN 'HOJE'
            WHEN @cd_parametro = 7 THEN CONVERT(VARCHAR(10), d.dt_nota_saida, 120)
            WHEN @cd_parametro = 8 THEN CONCAT('SEM-', d.cd_semana)
            WHEN @cd_parametro = 9 THEN CONCAT('MES-', d.cd_mes, '-', d.cd_ano)
            WHEN @cd_parametro = 10 THEN CONCAT('TRI-', d.cd_ano, '-', d.cd_trimestre)
            WHEN @cd_parametro = 11 THEN CONCAT('SEM-', d.cd_ano, '-', CASE WHEN d.cd_trimestre IN (1,2) THEN 1 ELSE 2 END)
            WHEN @cd_parametro = 12 THEN CONCAT('ANO-', d.cd_ano)
        END AS period_key
    FROM DadosAnt d
),
AggAnt AS (
    SELECT
        cd_serie_nota_fiscal,
        period_key,
        SUM(qt_nota_saida_ant) AS qt_nota_saida_ant,
        SUM(vl_total_ant)      AS vl_total_ant
    FROM TaggedAnt
    GROUP BY cd_serie_nota_fiscal, period_key
)

SELECT
    a.cd_serie_nota_fiscal,
    a.sg_serie_nota_fiscal,
    a.nm_serie_nota_fiscal,
    a.ic_nfe_serie_nota,
    a.cd_modelo_serie_nota,
    a.period_label,
    a.qt_nota_saida,
    a.vl_total,
    CAST(100.0 * a.vl_total / NULLIF(SUM(a.vl_total) OVER (PARTITION BY a.period_key), 0) AS DECIMAL(10,2)) AS perc_participacao,
    CASE WHEN a.qt_nota_saida > 0 THEN CAST(a.vl_total / a.qt_nota_saida AS DECIMAL(18,2)) ELSE 0 END AS ticket_medio,
    ISNULL(b.qt_nota_saida_ant, 0) AS qt_nota_saida_ant,
    ISNULL(b.vl_total_ant, 0)      AS vl_total_ant,
    CAST(a.vl_total - ISNULL(b.vl_total_ant, 0) AS DECIMAL(18,2)) AS delta_valor,
    CASE WHEN ISNULL(b.vl_total_ant, 0) > 0
         THEN CAST((a.vl_total - b.vl_total_ant) * 100.0 / b.vl_total_ant AS DECIMAL(10,2))
         ELSE NULL
    END AS delta_perc
FROM AggAtual a
LEFT JOIN AggAnt  b ON b.cd_serie_nota_fiscal = a.cd_serie_nota_fiscal
                   AND b.period_key          = a.period_key
ORDER BY a.period_key, a.vl_total DESC;


    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;

  return

end

--Notas Fiscais de Acordo com a Série Analítica

if @cd_parametro = 20
begin
  select
    ns.cd_nota_saida,
    sn.nm_status_nota,
    ns.cd_serie_nota,
    snf.sg_serie_nota_fiscal,
    ns.dt_nota_saida,
    ns.dt_saida_nota_saida,
    ns.nm_fantasia_nota_saida,
    ns.nm_razao_social_nota,
    isnull(ns.vl_total,0)                as vl_total,

    case when isnull(nv.cd_chave_acesso,'')<>'' then
      nv.cd_chave_acesso
    else
      ns.cd_chave_acesso
    end                                   as cd_chave_acesso,
    
    --select * from nota_validacao
    
    nv.dt_autorizacao,
    nv.cd_protocolo_nfe,
    isnull(nv.ic_cancelada,'N')           as ic_cancelada,
    nv.dt_cancelamento,
    nv.cd_protocolo_canc,
    nv.ds_xml_nota,
    nsd.ds_nota_xml_retorno

  from
    nota_saida ns
    inner join Serie_Nota_Fiscal snf on snf.cd_serie_nota_fiscal  = ns.cd_serie_nota
    left outer join Nota_Saida_Documento nsd on nsd.cd_nota_saida = ns.cd_nota_saida
    left outer join nota_Saida_Recibo    nsr on nsr.cd_nota_saida = ns.cd_nota_saida
    left outer join Nota_Validacao nv        on nv.cd_nota_saida  = ns.cd_nota_saida
    left outer join Status_Nota sn           on ns.cd_status_nota = ns.cd_status_nota
  where
    ns.dt_nota_saida between @dt_inicial and @dt_final
    and
    ns.cd_serie_nota = case when @cd_serie_nota = 0 then ns.cd_serie_nota else @cd_serie_nota end
    and
    isnull(snf.cd_empresa_selecao,0) = case when @cd_empresa_faturamento = 0 
                                     then isnull(snf.cd_empresa_selecao,0)
                                     else
                                         @cd_empresa_faturamento
                                     end         
    order by
     snf.cd_serie_nota_fiscal, ns.dt_nota_saida desc, ns.cd_nota_saida

    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  return

end

if @cd_parametro = 9999
begin
 
    -- Status padronizado (sempre o ÚLTIMO resultset antes de sair)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
  return
end

--use egissql_317
--
/* Padro se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ao mapeada para cd_parametro=', @cd_parametro) AS Msg;
   
 
    -- Status padronizado (sempre o ÚLTIMO resultset)
    SET @__sucesso = 1;
    SET @__codigo  = 200;
    SET @__mensagem = N'OK';
    SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
 
 END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;

        DECLARE
            @errnum  INT = ERROR_NUMBER(),
            @errsev  INT = ERROR_SEVERITY(),
            @errsta  INT = ERROR_STATE(),
            @errline INT = ERROR_LINE(),
            @errmsg  NVARCHAR(2048) = ERROR_MESSAGE(),
            @errproc NVARCHAR(256)  = ERROR_PROCEDURE();

        SET @__sucesso = 0;
        SET @__codigo  = 500;
        SET @__mensagem =
            N'Erro em pr_egis_nfe_monitor_processo ('
            + ISNULL(@errproc, N'(sem_procedure)')
            + N':' + CONVERT(NVARCHAR(10), @errline)
            + N') #' + CONVERT(NVARCHAR(10), @errnum)
            + N' - ' + ISNULL(@errmsg, N'');

        -- Status padronizado (sempre o ÚLTIMO resultset)
        SELECT @__sucesso AS sucesso, @__codigo AS codigo, @__mensagem AS mensagem;
    END CATCH
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------    
go



------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  dbo.pr_egis_nfe_monitor_processo
------------------------------------------------------------------------------
--use egissql
--go
--use egissql


--select * from egisadmin.dbo.usuario

--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 0 }]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 1, "cd_usuario": 113 }]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 1, "cd_usuario": 113 }]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 2, "cd_usuario": 113 }]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 3, "cd_usuario": 113 }]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 4, "cd_usuario": 113 }]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 5, "cd_usuario": 113 , "dt_inicial" : "01/01/2025", "dt_final":"12/31/2026"}]' 
exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 5, "cd_usuario": 113 , "dt_inicial" : "01/01/2025", "dt_final":"12/31/2025"}]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 7, "cd_usuario": 113 , "dt_inicial" : "01/01/2025", "dt_final":"12/31/2026"}]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 8, "cd_usuario": 113 , "dt_inicial" : "01/01/2025", "dt_final":"12/31/2026"}]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 9, "cd_usuario": 113 , "dt_inicial" : "01/01/2025", "dt_final":"12/31/2026"}]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 10, "cd_usuario": 113 , "dt_inicial" : "01/01/2025", "dt_final":"12/31/2026"}]' --
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 11, "cd_usuario": 113 , "dt_inicial" : "01/01/2025", "dt_final":"12/31/2026"}]' 
--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 12, "cd_usuario": 113 , "dt_inicial" : "01/01/2025", "dt_final":"12/31/2026"}]' 

--exec  dbo.pr_egis_nfe_monitor_processo '[{"cd_parametro": 20, "cd_usuario": 113 , "dt_inicial" : "01/01/2025", "dt_final":"12/31/2026"}]' 

use egissql_377
go

-----------------------------------------------------------------------------------------------------------------
go


