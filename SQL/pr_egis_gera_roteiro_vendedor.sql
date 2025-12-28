--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_gera_roteiro_vendedor' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_gera_roteiro_vendedor

GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_gera_roteiro_vendedor
-------------------------------------------------------------------------------
-- pr_egis_gera_roteiro_vendedor
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
--                   Notícias e Eventos
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_gera_roteiro_vendedor
@json nvarchar(max) = ''

--with encryption


as

--return

--set @json = isnull(@json,'')



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
declare @cd_vendedor            int = 0
declare @qt_visita_diaria       int = 0
declare @qt_dia_util_visita     int = 0
declare @criterio               VARCHAR(10) = NULL -- 'valor'|'distancia'|'mix'
declare @hora_inicio            TIME(0) = '09:00'  -- pode virar parâmetro
declare @hora_fim               TIME(0) = '17:00'  -- idem
declare @ic_distribuicao_semana char(1) = 'N'   

-- Defaults
SET @criterio = ISNULL(@criterio,'mix');
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

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]                                      as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'
select @ic_distribuicao_semana = valor from #json where campo = 'ic_distribuicao_semana' 

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()


select
  @qt_visita_diaria   = isnull(qt_visita_diaria,8),
  @qt_dia_util_visita = isnull(qt_dia_util_visita,5)
from
  parametro_visita
where
  cd_empresa = @cd_empresa

 --select * from parametro_visita


---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    

set @cd_parametro = ISNULL(@cd_parametro,0)

--if @cd_parametro = 0
--begin

--  -------------------------------------------
--  select @cd_vendedor as Msg
--  -------------------------------------------

--end


 ----------------------------------------------------------------------
 -- Base de clientes alvo
 -- Requisitos mínimos esperados em dbo.cliente:
 --   cd_cliente (PK), cd_vendedor, cd_cep, cd_criterio_visita, cd_semana, vl_faturamento (opcional)
 ----------------------------------------------------------------------
  IF OBJECT_ID('tempdb..#cli') IS NOT NULL DROP TABLE #cli;
  SELECT
    c.cd_cliente,
    c.cd_vendedor,
    c.cd_cep,
    c.cd_criterio_visita,               -- 'S','Q1','Q2','M'
    -- Normaliza dia da semana:
    --select * from semana
    c.cd_semana,
    CASE
      WHEN TRY_CONVERT(INT, c.cd_semana) IN (2,3,4,5,6,7)
        THEN CASE TRY_CONVERT(INT, c.cd_semana)
               WHEN 2 THEN 'SEG' WHEN 3 THEN 'TER' WHEN 4 THEN 'QUA'
               WHEN 5 THEN 'QUI' WHEN 6 THEN 'SEX' WHEN 7 THEN 'SAB'
             END
      WHEN UPPER(c.cd_semana) IN ('SEG','TER','QUA','QUI','SEX','SAB')
        THEN UPPER(c.cd_semana)
      ELSE 'SEG' -- fallback
    END AS sg_semana,
    TRY_CONVERT(INT, LEFT(ISNULL(c.cd_cep,''),5))         AS cep_prefix,
    ISNULL(TRY_CONVERT(INT, LEFT(NULLIF(cd_cep,''),3)),0) AS cep_cluster,
    ISNULL(TRY_CONVERT(DECIMAL(18,2), 0.00), 0)           AS vl_faturamento   --c.vl_faturamento
  INTO #cli
  FROM dbo.cliente c WITH(NOLOCK)
  WHERE --(@cd_vendedor IS NULL OR c.cd_vendedor = @cd_vendedor);
    c.cd_vendedor = @cd_vendedor

  -- Se não houver clientes, encerra amigavelmente
  IF NOT EXISTS (SELECT 1 FROM #cli)
  BEGIN
    SELECT 'Sem clientes para os parâmetros informados.' AS Msg, 0 AS RegistrosGerados;
    RETURN;
  END

  --mostra os clientes

  --select * from #cli
  --order by
  --  cd_semana, cep_prefix, cd_cep

----------------------------------------------------------------------
-- Ordenação por critério
----------------------------------------------------------------------

 IF OBJECT_ID('tempdb..#base') IS NOT NULL DROP TABLE #base;
    SELECT
      cd_vendedor, cd_cliente, cd_criterio_visita, cd_semana, cd_cep,
      cep_prefix, vl_faturamento,
      rn = ROW_NUMBER() OVER (
            PARTITION BY cd_vendedor, cd_semana
            ORDER BY
              CASE WHEN @criterio='distancia' THEN cep_prefix END ASC,
              CASE WHEN @criterio IN ('valor','mix') THEN vl_faturamento END DESC,
              cd_cliente
          )
    INTO #base
    FROM #cli;

    IF OBJECT_ID('tempdb..#selec') IS NOT NULL DROP TABLE #selec;
    SELECT
      identity(Int,1,1) as cd_roteiro_vendedor,
      b.cd_vendedor,
      b.cd_cliente,
      b.cd_criterio_visita,
      b.cd_semana,
      qt_ordem_visita = b.rn,
      cd_cep = b.cd_cep
    INTO #selec
    FROM #base b
    WHERE b.rn <= @qt_visita_diaria;

    ------------------------------------------------------------
    -- 4) Limpa e insere em vendedor_roteiro
    ------------------------------------------------------------
    IF OBJECT_ID('tempdb..#vend') IS NOT NULL DROP TABLE #vend;
    SELECT DISTINCT cd_vendedor INTO #vend FROM #selec;

    DELETE vr
    FROM dbo.vendedor_roteiro vr
    WHERE EXISTS (SELECT 1 FROM #vend v WHERE v.cd_vendedor = vr.cd_vendedor);

    -- calcula espaçamento de horário
    DECLARE @minutos_totais INT = DATEDIFF(MINUTE, @hora_inicio, @hora_fim);
    DECLARE @slot INT = CASE
                           WHEN @qt_visita_diaria > 0 THEN NULLIF(@minutos_totais / @qt_visita_diaria,0)
                           ELSE 0
                        END;
    SET @slot = ISNULL(@slot, 30); -- fallback de 30 min se janela for pequena

    INSERT INTO vendedor_roteiro
      (cd_roteiro_vendedor, cd_vendedor, cd_cliente, cd_criterio_visita, cd_semana,
       qt_ordem_visita, cd_cep, hr_visita_roteiro,
       cd_usuario_inclusao, dt_usuario_inclusao, cd_usuario, dt_usuario)
    SELECT
      s.cd_roteiro_vendedor,
      s.cd_vendedor,
      s.cd_cliente,
      s.cd_criterio_visita,
      s.cd_semana,
      s.qt_ordem_visita,
      s.cd_cep,
      CAST(DATEADD(MINUTE, (@slot * (s.qt_ordem_visita - 1)), CAST(@hora_inicio AS DATETIME)) AS TIME(0)) AS hr_visita_roteiro,
      @cd_usuario, GETDATE(), @cd_usuario, GETDATE()
    FROM #selec s
    ORDER BY s.cd_vendedor,
             CASE s.cd_semana WHEN 'SEG' THEN 1 WHEN 'TER' THEN 2 WHEN 'QUA' THEN 3
                              WHEN 'QUI' THEN 4 WHEN 'SEX' THEN 5 WHEN 'SAB' THEN 6 ELSE 7 END,
             s.qt_ordem_visita;


    select * from vendedor_roteiro where cd_vendedor = @cd_vendedor

    SELECT 'Roteiro gerado com sucesso.' AS Msg, COUNT(*) AS RegistrosGerados
    FROM #selec;

  
    
--SELECT 'Roteiro gerado com sucesso.' AS Msg,
 --        @@ROWCOUNT AS RegistrosGerados;





---------------------------------------------------------------------------------------------------------------------------------------------------------    

go



------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_gera_roteiro_vendedor
------------------------------------------------------------------------------
--
exec  pr_egis_gera_roteiro_vendedor '[{"cd_vendedor": 8}, "ic_distribuicao_semana":"S" ]' 
--

go
/*
exec  pr_egis_gera_roteiro_vendedor '[{"cd_vendedor": 8}]' 
                                           
*/
go
------------------------------------------------------------------------------
GO
--use egissql_317
--select * from vendedor

