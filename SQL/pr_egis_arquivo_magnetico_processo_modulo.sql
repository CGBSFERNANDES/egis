--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_arquivo_magnetico_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_arquivo_magnetico_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_arquivo_magnetico_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_arquivo_magnetico_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_arquivo_magnetico_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_arquivo_magnetico_processo_modulo
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
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_arquivo_magnetico_processo_modulo
------------------------
@json nvarchar(max) = ''
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
declare @jsonRemessa            nvarchar(max)
declare @cd_conta_banco         int = 0
declare @ds_retorno             nvarchar(max);
declare @nm_documento_magnetico varchar(40) = ''
declare @cd_documento_magnetico int         = 0
declare @cd_identificacao       varchar(25) = ''

----------------------------------------------------------------------------------------------------------------
declare @dados_registro           nvarchar(max) = ''
declare @dados_modal              nvarchar(max) = ''
----------------------------------------------------------------------------------------------------------------
declare @dados_arquivo            nvarchar(max) = ''
declare @nm_arquivo               nvarchar(260) = ''
declare @conteudo_texto           nvarchar(max) = ''
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
select @cd_conta_banco         = valor from #json where campo = 'cd_conta_banco'
select @nm_documento_magnetico = valor from #json where campo = 'nm_documento_magnetico'
select @cd_documento_magnetico = valor from #json where campo = 'cd_documento_magnetico'

--------------------------------------------------------------------------------------

select @dados_registro         = valor from #json where campo = 'dados_registro'
select @dados_modal            = valor from #json where campo = 'dados_modal'
select @dados_arquivo          = valor from #json where campo = 'dados_arquivo'

--select @nm_arquivo             = JSON_VALUE(@dados_arquivo, '$.nm_arquivo');
--select @conteudo_texto         = JSON_VALUE(@dados_arquivo, '$.conteudo_texto');

--------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro         = ISNULL(@cd_parametro,0)

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



-------------------------------------------------modal-----------------------------------------------------
if @dados_modal<>''
begin

  ---------------------------------------------------------
  -- 1) Monta tabela com os dados digitados no modal
  ---------------------------------------------------------
  declare
    @json_modal nvarchar(max) = ''

  set @json_modal = isnull(@dados_modal, '')

  -- Tabela com os campos/valores do modal
  declare @DadosModal table (
    id    int identity(1,1),
    campo varchar(200),
    valor nvarchar(max)
  )

  if (isnull(@json_modal, '') <> '')
  begin
    insert into @DadosModal (campo, valor)
    select
        m.[key]   as campo,
        m.[value] as valor
    from openjson(@json_modal) as m
  end

end

-----------------------------------------------------------------------------------------------------------



  --Geração do Arquivo Magnético
  --documento_arquivo_magnetico

  if @cd_parametro = 1
  begin
    
    declare @dt_inicio_sped datetime
    declare @dt_final_sped  datetime

    select 
      top 1
      @dt_inicio_sped = DT_INI,
      @dt_final_sped  = DT_FIN
    from 
      vw_EFD_REGISTRO_0000
    where
      ic_ativo_movimento = 'S'
    
    -- Criação da tabela temporária
    DECLARE @sped TABLE (
      LINHA NVARCHAR(MAX),
      REG   VARCHAR(100),
      ID    INT,
      ITEM  INT
    );

    insert into @sped
    exec pr_geracao_sped_fiscal_egisnet @dt_inicio_sped, @dt_final_sped
    -----------------------------------

    --select LINHA as ds_retorno
    --from
    --  @sped
    --order by ITEM

    -- Variável para armazenar o retorno



-- Concatenar todas as linhas em um único texto
SELECT @ds_retorno =
    STUFF((
        SELECT CHAR(13) + CHAR(10) + LINHA
        FROM @sped
        ORDER BY ITEM
        FOR XML PATH(''), TYPE
        
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '')  


    select @ds_retorno + CHAR(13) + CHAR(10) as ds_retorno
    --------------------------------
-- Agora @ds_retorno contém o "arquivo texto"
--PRINT @ds_retorno;

    --  select 'Sped ' as ds_retorno
    return

  end

  if @cd_parametro = 10
  begin
  
    -------------------------------------------------------------------
    -- 1) Validar se veio algo em dados_registro
    -------------------------------------------------------------------
    if NULLIF(@dados_registro, N'') IS NULL
    begin
       select 'Nenhum registro selecionado (dados_registro vazio).' as Msg
       return
    end

    if ISJSON(@dados_registro) <> 1
    begin
       select 'Lista de registros inválida em dados_registro.' as Msg
       return
    end

   -------------------------------------------------------------------
   -- 2) Quebrar o JSON de dados_registro
   -------------------------------------------------------------------
   if object_id('tempdb..#sel') is not null
       drop table #sel

   select
       IDENTITY(int,1,1)                             as id,
       j.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo, 
       j.[value]                                     as valor
   into #sel
   from                
   openjson(@dados_registro) root                    
   cross apply openjson(root.value) as j  
   
  select @nm_documento_magnetico = valor from #sel where campo = 'nm_documento_magnetico'

   --select * from #sel

    --select @nm_documento_magnetico


    select
       @cd_documento_magnetico = cd_documento_magnetico
    from
       Documento_Arquivo_Magnetico
    where
       nm_documento_magnetico = @nm_documento_magnetico

    --select @cd_documento_magnetico

    if @cd_documento_magnetico>0
    begin
      select
        top 1
        @cd_conta_banco = isnull(cd_conta_banco,0)
      from
        Conta_Agencia_Banco
      where
        cd_documento_magnetico = @cd_documento_magnetico
    end

    --select @cd_conta_banco

    --set @cd_conta_banco = 1

    SELECT @jsonRemessa =
    (
      SELECT
        @cd_conta_banco as cd_conta_banco,
        @cd_usuario     as cd_usuario
      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )

    SET @jsonRemessa = N'[' + @jsonRemessa + N']';

    --select @jsonRemessa

    --EXEC pr_egis_geracao_remessa_banco @jsonRemessa
    ------------------------------------------------
    -- Criação da tabela temporária
    DECLARE @remessa TABLE (
      LINHA NVARCHAR(MAX)
      
    );

    insert into @remessa
    EXEC pr_egis_geracao_remessa_banco @jsonRemessa
    -----------------------------------

    -- Variável para armazenar o retorno

    -- Concatenar todas as linhas em um único texto
    SELECT @ds_retorno =
      STUFF((
        SELECT CHAR(13) + CHAR(10) + LINHA
        FROM @remessa
       
        FOR XML PATH(''), TYPE
        
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '')  


    --select @ds_retorno

    if isnull(@ds_retorno,'')=''
    begin
      set @ds_retorno = 'Não existem Documentos a Receber para Geração !'
    end
    --else
   
    select @ds_retorno + CHAR(13) + CHAR(10) as ds_retorno
    ------------------------------------------------------
    return

  end
  

  --Retorno do Banco----------------------------------------------------------------------------

  if @cd_parametro = 100
  begin
    
    --select @cd_documento_magnetico

    -------------------------------------------------------------------
    -- 1.1) Validar se veio dados_arquivo (upload retorno)
    -------------------------------------------------------------------
    if NULLIF(@dados_arquivo, N'') IS NULL
    begin
       select 'Arquivo não enviado (dados_arquivo vazio).' as Msg
       return
    end
    
    -- extrai nome e conteúdo do arquivo vindo do front
    select
      @nm_arquivo     = JSON_VALUE(@dados_arquivo, '$.nm_arquivo'),
      @conteudo_texto = JSON_VALUE(@dados_arquivo, '$.conteudo_texto')
    
    if NULLIF(@conteudo_texto, N'') IS NULL
    begin
       select 'Conteúdo do arquivo vazio (conteudo_texto).' as Msg
       return
    end
    
    -- normaliza quebra de linha: remove CR, usa LF
    --set @conteudo_texto = replace(@conteudo_texto, char(13), '')
    
    -- ✅ prioridade: conteudo_texto
IF NULLIF(@conteudo_texto, N'') IS NULL
BEGIN
   -- fallback: se vier só base64 (opcional)
   DECLARE @b64 NVARCHAR(MAX) = JSON_VALUE(@dados_arquivo, '$.conteudo_base64');
   IF NULLIF(@b64, N'') IS NULL
   BEGIN
      SELECT 'Arquivo não enviado (conteudo_texto e conteudo_base64 vazios).' AS Msg;
      RETURN;
   END

   -- decode base64 -> texto (SQL Server)
   SET @conteudo_texto =
      CAST(CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@b64"))', 'VARBINARY(MAX)') AS NVARCHAR(MAX));
   
   END

    -------------------------------------------------------------------
    -- 1) Validar se veio algo em dados_registro
    -------------------------------------------------------------------
    if NULLIF(@dados_registro, N'') IS NULL
    begin
       select 'Nenhum registro selecionado (dados_registro vazio).' as Msg
       return
    end

    if ISJSON(@dados_registro) <> 1
    begin
       select 'Lista de registros inválida em dados_registro.' as Msg
       return
    end

   -------------------------------------------------------------------
   -- 2) Quebrar o JSON de dados_registro
   -------------------------------------------------------------------
   if object_id('tempdb..#selRetorno') is not null
       drop table #selRetorno

   select
       IDENTITY(int,1,1)                             as id,
       j.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo, 
       j.[value]                                     as valor
   into #selRetorno
   from                
   openjson(@dados_registro) root                    
   cross apply openjson(root.value) as j  
   
  select @nm_documento_magnetico = valor from #selRetorno where campo = 'nm_documento_magnetico'

  --select @nm_documento_magnetico 
  --return
   --select * from #sel

    --select @nm_documento_magnetico


    select
       @cd_documento_magnetico = cd_documento_magnetico
    from
       Documento_Arquivo_Magnetico
    where
       nm_documento_magnetico = @nm_documento_magnetico

    --select @cd_documento_magnetico
    --return

    if @cd_documento_magnetico>0
    begin
      select
        top 1
        @cd_conta_banco = isnull(cd_conta_banco,0)
      from
        Conta_Agencia_Banco
      where
        --Retorno do Banco--
        cd_documento_retorno = @cd_documento_magnetico
        ----------------------------------------------
    end

    --select @cd_conta_banco
    --return

    --select * from 
    /* OBS:
       Os tipos de sessão são os seguintes
       1 - HEADER
       2 - DETALHE
       3 - TRAILER (rodapé)
  */
      
    select
      c.*,
      t.ic_data_sistema,
      t.ic_data_inicial,
      t.ic_data_final,
      t.ic_contador_documento,
      t.ic_somatoria,
      t.ic_contador_detalhe,
      t.ic_repetir_caracter,
      t.ic_limpa_literal,
      t.ic_preenche_zero,
      t.ic_alinhamento,
      t.ic_mostra_virgula,
      t.ic_tipo_campo,
      t.nm_formato_mascara
    into
     #LayOutRetorno

    from
      campo_arquivo_magnetico c,
      tipo_campo_arquivo_magnetico t
    where 
      c.cd_tipo_campo = t.cd_tipo_campo and
      c.cd_sessao_documento in (select 
                                  cd_sessao_arquivo_magneti 
                                from 
                                  sessao_arquivo_magnetico 
                                where 
                                  cd_documento_magnetico = @cd_documento_magnetico and
                                  --cd_tipo_sessao = @cd_tipo_sessao and
                                  isnull(ic_sessao_inativa,'N') <> 'S')
    order by
      c.cd_sessao_documento,
      c.cd_inicio_posicao

     --select @cd_documento_magnetico
     --select * from #LayOutRetorno order by nm_campo_ligacao desc
     --return



    -------------------------------------------------------------------
    -- 2) Quebrar o arquivo em linhas
    -------------------------------------------------------------------
    if object_id('tempdb..#linhas') is not null drop table #linhas;
    
    create table #linhas (
      nr_linha int identity(1,1),
      linha nvarchar(max)
    );
    
    insert into #linhas(linha)
    select value
    from string_split(@conteudo_texto, char(10))
    where ltrim(rtrim(value)) <> '';

    --select * from #linhas
    --return


    -------------------------------------------------------------------
    -- 3) Descobrir colunas do #LayOutRetorno (nome do campo e tamanho)
    -- (evita depender do nome exato da coluna de tamanho)
    -------------------------------------------------------------------
    DECLARE @col_inicio  SYSNAME = 'cd_inicio_posicao';
    DECLARE @col_tamanho SYSNAME = NULL;
    DECLARE @col_nome    SYSNAME = NULL;
    DECLARE @col_decimais SYSNAME = NULL;

-- ✅ Coluna certa para o "nome do campo": nm_campo_ligacao (se existir)
IF COL_LENGTH('tempdb..#LayOutRetorno', 'nm_campo_ligacao') IS NOT NULL
  SET @col_nome = 'nm_campo_ligacao';
ELSE IF COL_LENGTH('tempdb..#LayOutRetorno', 'nm_atributo') IS NOT NULL
  SET @col_nome = 'nm_atributo';
ELSE IF COL_LENGTH('tempdb..#LayOutRetorno', 'nm_campo') IS NOT NULL
  SET @col_nome = 'nm_campo';
ELSE
BEGIN
  SELECT 'Layout sem coluna nm_campo_ligacao/nm_atributo/nm_campo.' AS Msg;
  RETURN;
END

-- ✅ Coluna de tamanho: tenta as mais comuns do seu cadastro
IF COL_LENGTH('tempdb..#LayOutRetorno', 'qt_tamanho') IS NOT NULL
  SET @col_tamanho = 'qt_tamanho';
ELSE IF COL_LENGTH('tempdb..#LayOutRetorno', 'cd_tamanho') IS NOT NULL
  SET @col_tamanho = 'cd_tamanho';
ELSE IF COL_LENGTH('tempdb..#LayOutRetorno', 'qt_tamanho_posicao') IS NOT NULL
  SET @col_tamanho = 'qt_tamanho_posicao';
ELSE IF COL_LENGTH('tempdb..#LayOutRetorno', 'cd_fim_posicao') IS NOT NULL
  SET @col_tamanho = 'cd_fim_posicao'; -- (vamos tratar como fim e converter pra tamanho no SQL dinâmico)
ELSE
BEGIN
  SELECT 'Layout sem coluna de tamanho (qt_tamanho/cd_tamanho/qt_tamanho_posicao/cd_fim_posicao).' AS Msg;
  RETURN;
END



IF COL_LENGTH('tempdb..#LayOutRetorno', 'qt_decimal') IS NOT NULL
  SET @col_decimais = 'qt_decimal';
ELSE IF COL_LENGTH('tempdb..#LayOutRetorno', 'nr_decimais') IS NOT NULL
  SET @col_decimais = 'nr_decimais';
ELSE IF COL_LENGTH('tempdb..#LayOutRetorno', 'qt_casas_decimais') IS NOT NULL
  SET @col_decimais = 'qt_casas_decimais';
ELSE IF COL_LENGTH('tempdb..#LayOutRetorno', 'cd_decimais') IS NOT NULL
  SET @col_decimais = 'cd_decimais';
ELSE
BEGIN
  SELECT 'Layout sem coluna de tamanho (qt_decimal).' AS Msg;
  RETURN;
END

-- se não existir, fica null mesmo (a gente trata como 0)


    -------------------------------------------------------------------
    -- 4) Extrair campos por linha de detalhe e chamar pr_atualiza_doc_rec_retorno
    -------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#val') IS NOT NULL DROP TABLE #val;
CREATE TABLE #val (
  nr_linha INT,
  nm_campo SYSNAME,
  valor NVARCHAR(MAX),
  decimais int null
);

DECLARE @sql NVARCHAR(MAX);

-- Se o "tamanho" na verdade é "fim", converte pra tamanho = fim - inicio + 1

IF @col_tamanho = 'cd_fim_posicao'
BEGIN
 SET @sql = N'
INSERT INTO #val(nr_linha, nm_campo, valor, decimais)
SELECT
  l.nr_linha,
  CAST(ly.' + QUOTENAME(@col_nome) + N' AS SYSNAME) AS nm_campo,
  LTRIM(RTRIM(SUBSTRING(l.linha,
                        ly.' + QUOTENAME(@col_inicio) + N',
                        (ly.' + QUOTENAME(@col_tamanho) + N' - ly.' + QUOTENAME(@col_inicio) + N' + 1)
                       ))) AS valor,
  ' + CASE WHEN @col_decimais IS NULL THEN 'NULL' ELSE 'TRY_CONVERT(int, ly.' + QUOTENAME(@col_decimais) + N')' END + N' AS decimais
FROM #linhas l
CROSS JOIN #LayOutRetorno ly
WHERE LEFT(l.linha,1) = ''1''
  AND NULLIF(LTRIM(RTRIM(CAST(ly.' + QUOTENAME(@col_nome) + N' AS NVARCHAR(200)))), '''') IS NOT NULL;
';

END
ELSE
BEGIN
 SET @sql = N'
INSERT INTO #val(nr_linha, nm_campo, valor, decimais)
SELECT
  l.nr_linha,
  CAST(ly.' + QUOTENAME(@col_nome) + N' AS SYSNAME) AS nm_campo,
  LTRIM(RTRIM(SUBSTRING(l.linha,
                        ly.' + QUOTENAME(@col_inicio) + N',
                        (ly.' + QUOTENAME(@col_tamanho) + N' + ISNULL(' 
                          + CASE WHEN @col_decimais IS NULL THEN '0' ELSE 'TRY_CONVERT(int, ly.' + QUOTENAME(@col_decimais) + N')' END +
                        N',0))
                       ))) AS valor,
  ' + CASE WHEN @col_decimais IS NULL THEN '0' ELSE 'TRY_CONVERT(int, ly.' + QUOTENAME(@col_decimais) + N')' END + N' AS decimais
FROM #linhas l
CROSS JOIN #LayOutRetorno ly
WHERE LEFT(l.linha,1) = ''1''
  AND NULLIF(LTRIM(RTRIM(CAST(ly.' + QUOTENAME(@col_nome) + N' AS NVARCHAR(200)))), '''') IS NOT NULL;
';
END

EXEC sp_executesql @sql;

IF OBJECT_ID('tempdb..#valn') IS NOT NULL DROP TABLE #valn;

SELECT
  nr_linha,
  nm_campo,
  valor,
  ISNULL(decimais, 0) AS decimais,
  CASE
    WHEN (nm_campo LIKE 'vl_%' OR nm_campo LIKE '%valor%' OR nm_campo LIKE '%vl%')
     AND NULLIF(valor,'') IS NOT NULL
      THEN TRY_CONVERT(decimal(25,6), valor) / POWER(CAST(10 AS decimal(25,6)), ISNULL(decimais,0))
    ELSE NULL
  END AS valor_decimal
INTO #valn
FROM #val;


    --select * from #valn
    --return
    -------------------------------------------------------------------------------------------

    -- Pivot mínimo para parâmetros da pr_atualiza_doc_rec_retorno

    if object_id('tempdb..#ret') is not null drop table #ret;
    select
      nr_linha,
      max(case when lower(nm_campo) = 'cd_identificacao' then valor end) as cd_identificacao,
      max(case when lower(nm_campo) = 'cd_ocorrencia' then valor end) as cd_ocorrencia,
      max(case when lower(nm_campo) = 'cd_bancario' then valor end) as cd_bancario,
      max(case when lower(nm_campo) = 'cd_banco' then valor end) as cd_banco,
    
      -- valores (assumindo que vêm sem separador e com 2 decimais implícitos)
      max(case when lower(nm_campo) = 'vl_tarifa_cobranca' then valor end) as vl_tarifa_cobranca_txt,
      max(case when lower(nm_campo) = 'vl_abatimento' then valor end) as vl_abatimento_txt,
      max(case when lower(nm_campo) = 'vl_desconto' then valor end) as vl_desconto_txt,
     -- max(case when lower(nm_campo) = 'vl_recebido' then valor end) as vl_recebido_txt,
      MAX(CASE WHEN LOWER(nm_campo)='vl_recebido' THEN valor_decimal END) AS vl_recebido_txt,

      max(case when lower(nm_campo) = 'vl_juros_mora' then valor end) as vl_juros_mora_txt,
      max(case when lower(nm_campo) = 'vl_outro_credito' then valor end) as vl_outro_credito_txt,
    
      max(case when lower(nm_campo) = 'dt_credito_literal' then valor end) as dt_credito_literal,
      max(case when lower(nm_campo) = 'dt_ocorrencia_literal' then valor end) as dt_ocorrencia_literal,
      max(case when lower(nm_campo) = 'nm_conta_banco' then valor end) as nm_conta_banco,
      max(case when lower(nm_campo) = 'cd_conta_banco_remessa' then valor end) as cd_conta_banco_remessa,
      max(case when lower(nm_campo) = 'cd_banco_sicredi' then valor end) as cd_banco_sicredi
    into #ret
    from #valn
    group by nr_linha;
    
    --select * from #ret
    --return

    -- só processa identificações que existam em documento_receber
    
    --select * from #ret

    DELETE r
    FROM #ret r
    WHERE NOT EXISTS (
      SELECT 1 FROM documento_receber d WITH (NOLOCK)
      WHERE d.cd_identificacao = r.cd_identificacao 
    );
    
    --select * from #ret

    -- loop chamando a pr
    
    declare
      --@cd_identificacao varchar(15),
      @cd_ocorrencia char(2),
      @cd_bancario varchar(30),
      @cd_banco varchar(3),
      @vl_tarifa_cobranca decimal(25,2),
      @vl_abatimento decimal(25,2),
      @vl_desconto decimal(25,2),
      @vl_recebido decimal(25,2),
      @vl_juros_mora decimal(25,2),
      @vl_outro_credito decimal(25,2),
      @dt_credito_literal varchar(8),
      @dt_ocorrencia_literal varchar(8),
      @nm_conta_banco varchar(30),
      @cd_conta_banco_remessa varchar(8),
      @dt_credito datetime,
      @dt_ocorrencia datetime,
      @cd_banco_sicredi varchar(3);
    
    --select * from #ret

    declare c cursor local fast_forward for
    select
      cd_identificacao, cd_ocorrencia, cd_bancario, cd_banco,
      try_convert(decimal(25,2), nullif(vl_tarifa_cobranca_txt,'0.00')),
      try_convert(decimal(25,2), nullif(vl_abatimento_txt,'0.00')),
      try_convert(decimal(25,2), nullif(vl_desconto_txt,'0.00')),
      try_convert(decimal(25,2), nullif(vl_recebido_txt,'0.00')),
      try_convert(decimal(25,2), nullif(vl_juros_mora_txt,'0.00')),
      try_convert(decimal(25,2), nullif(vl_outro_credito_txt,'0.00')),
      dt_credito_literal, 
      dt_ocorrencia_literal,
      nm_conta_banco, 
      cd_conta_banco_remessa, 
      cd_banco_sicredi
    from #ret
    where cd_identificacao is not null;
    
    open c;
    fetch next from c into
      @cd_identificacao, @cd_ocorrencia, @cd_bancario, @cd_banco,
      @vl_tarifa_cobranca, @vl_abatimento, @vl_desconto, @vl_recebido, @vl_juros_mora, @vl_outro_credito,
      @dt_credito_literal, @dt_ocorrencia_literal, @nm_conta_banco, @cd_conta_banco_remessa, @cd_banco_sicredi;
    
    while @@fetch_status = 0
    begin
      --exec dbo.pr_atualiza_doc_rec_retorno
           set @cd_identificacao       = isnull(@cd_identificacao,'')
           set @cd_ocorrencia          = isnull(@cd_ocorrencia,'')
           set @cd_bancario            = isnull(@cd_bancario,'')
           set @cd_banco               = isnull(@cd_banco,'')
           set @vl_tarifa_cobranca     = isnull(@vl_tarifa_cobranca,0)
           set @vl_abatimento          = isnull(@vl_abatimento,0)
           set @vl_desconto            = isnull(@vl_desconto,0)
           set @vl_recebido            = isnull(@vl_recebido,0)
           set @vl_juros_mora          = isnull(@vl_juros_mora,0)
           set @vl_outro_credito       = isnull(@vl_outro_credito,0)
           set @dt_credito             = '' -- a pr aceita datetime, mas você também manda literal
           set @cd_usuario             = @cd_usuario
           set @nm_conta_banco         = isnull(@nm_conta_banco,'')
           set @dt_ocorrencia          = '' -- idem
           set @cd_conta_banco_remessa = isnull(@cd_conta_banco_remessa,'')
           set @dt_credito_literal     = isnull(@dt_credito_literal,'')
           set @dt_ocorrencia_literal  = isnull(@dt_ocorrencia_literal,'')
           set @cd_banco_sicredi       = isnull(@cd_banco_sicredi,'');

           --select @cd_ocorrencia

           --select @vl_recebido


           EXEC dbo.pr_atualiza_doc_rec_retorno
       @cd_identificacao       = @cd_identificacao,
       @cd_ocorrencia          = @cd_ocorrencia,
       @cd_bancario            = @cd_bancario,
       @cd_banco               = @cd_banco,
       @vl_tarifa_cobranca     = @vl_tarifa_cobranca,
       @vl_abatimento          = @vl_abatimento,
       @vl_desconto            = @vl_desconto,
       @vl_recebido            = @vl_recebido,
       @vl_juros_mora          = @vl_juros_mora,
       @vl_outro_credito       = @vl_outro_credito,
       @dt_credito             = @dt_credito,
       @cd_usuario             = @cd_usuario,
       @nm_conta_banco         = @nm_conta_banco,
       @dt_ocorrencia          = @dt_ocorrencia,
       @cd_conta_banco_remessa = @cd_conta_banco_remessa,
       @dt_credito_literal     = @dt_credito_literal,
       @dt_ocorrencia_literal  = @dt_ocorrencia_literal,
       @cd_banco_sicredi       = @cd_banco_sicredi;

    
      fetch next from c into
        @cd_identificacao, @cd_ocorrencia, @cd_bancario, @cd_banco,
        @vl_tarifa_cobranca, @vl_abatimento, @vl_desconto, @vl_recebido, @vl_juros_mora, @vl_outro_credito,
        @dt_credito_literal, @dt_ocorrencia_literal, @nm_conta_banco, @cd_conta_banco_remessa, @cd_banco_sicredi;

    end
    
    close c;
    deallocate c;


    SELECT 'OK - retorno processado: ' + ISNULL(@nm_arquivo,'') AS ds_retorno;



    return
  end



  if @cd_parametro = 9999
  begin
    return
  end

    
/* Padrão se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;
   
 END TRY
    BEGIN CATCH
        DECLARE
            @errnum   INT            = ERROR_NUMBER(),
            @errmsg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @errproc  NVARCHAR(128)  = ERROR_PROCEDURE(),
            @errline  INT            = ERROR_LINE(),
            @fullmsg  NVARCHAR(2048);



         -- Monta a mensagem (THROW aceita até 2048 chars no 2º parâmetro)
    SET @fullmsg =
          N'Erro em pr_egis_arquivo_magnetico_processo_modulo ('
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



------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_arquivo_magnetico_processo_modulo
------------------------------------------------------------------------------

go
/*
exec  pr_egis_arquivo_magnetico_processo_modulo '[{"cd_parametro": 0}]'
exec  pr_egis_arquivo_magnetico_processo_modulo '[{"cd_parametro": 1, "cd_modelo": 1}]'                                           ]'
exec  pr_egis_arquivo_magnetico_processo_modulo '[{"cd_parametro": 2, "cd_modelo": 1}]'   
exec  pr_egis_arquivo_magnetico_processo_modulo '[{"cd_parametro": 10, "cd_modelo": 1}]'    
*/
go
------------------------------------------------------------------------------
GO


--select * from documento_receber_pagamento


--exec  pr_egis_arquivo_magnetico_processo_modulo '[{"cd_parametro": 1, "cd_modelo": 1}]' 
--exec  pr_egis_arquivo_magnetico_processo_modulo '[{"cd_parametro": 10, "cd_conta_banco": 1, "cd_usuario": 1}]'

--exec  pr_egis_arquivo_magnetico_processo_modulo '[{"cd_parametro": 100, "cd_conta_banco": 1, "cd_usuario": 1}]'



--exec pr_egis_arquivo_magnetico_processo_modulo '[
--    {
--        "ic_json_parametro": "S",
--        "cd_parametro": 10,
--        "cd_usuario": 5056,
--        "cd_modal": 14,
--        "dt_inicial": "12-01-2025",
--        "dt_final": "12-31-2025",
--        "dados_modal": {
--            "itens": []
--        },
--        "dados_registro": [
--            {
--                "nm_documento_magnetico": "Remessa Itau",
--                "nm_local_documento": ""
--            }
--        ]
--    }
--]'

/*
//Retorno//
*/
/*

exec pr_egis_arquivo_magnetico_processo_modulo '[
    {
        "ic_json_parametro": "S",
        "cd_parametro": 100,
        "cd_usuario": 5003,
        "cd_modal": 15,
        "dt_inicial": "12-01-2025",
        "dt_final": "12-31-2025",
        "dados_modal": {
            "itens": [
                {
                    "nm_documento_magnetico": "2",
                    "nm_local_documento": "CN25085A.RET (1).txt"
                },
                {
                    "nm_documento_magnetico": "",
                    "nm_local_documento": ""
                }
            ]
        },
        "dados_registro": [
            {
                "nm_documento_magnetico": "Retorno Itau",
                "nm_local_documento": ""
            }
        ],
        "dados_arquivo": {
            "nm_arquivo": "CN25085A.RET (1).txt",
            "mime_type": "text/plain",
            "tamanho": 1206,
            "conteudo_texto": "02RETORNO01COBRANCA       006600138108        CISNEROS ICE C D SORVETES LTDA341BANCO ITAU S.A.25082501600BPI00478260825                                                                                                                                                                                                                                                                                   000001\r\n10214810875000163006600138108        8406633                  00056243            109000562432             I06250825MC-000049   00056243            31072500000000427943411012401000000000000000000000000000000000000000000000000000000000000000000000000000000000000004398500000000011910000000000000   26082500000000000000000000000LANCHONETE PORTAL DA BARRA LTD                                    BL000002\r\n9201341          000000000000000000000000000000          000000000000000000000000000000                                                  000000000000000000000000000000          0000020100000014278629  26/08S004780000006200000005252042                                                                                                                                                                000003\r\n",
            "conteudo_base64": "MDJSRVRPUk5PMDFDT0JSQU5DQSAgICAgICAwMDY2MDAxMzgxMDggICAgICAgIENJU05FUk9TIElDRSBDIEQgU09SVkVURVMgTFREQTM0MUJBTkNPIElUQVUgUy5BLjI1MDgyNTAxNjAwQlBJMDA0NzgyNjA4MjUgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAwMDAwMQ0KMTAyMTQ4MTA4NzUwMDAxNjMwMDY2MDAxMzgxMDggICAgICAgIDg0MDY2MzMgICAgICAgICAgICAgICAgICAwMDA1NjI0MyAgICAgICAgICAgIDEwOTAwMDU2MjQzMiAgICAgICAgICAgICBJMDYyNTA4MjVNQy0wMDAwNDkgICAwMDA1NjI0MyAgICAgICAgICAgIDMxMDcyNTAwMDAwMDAwNDI3OTQzNDExMDEyNDAxMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDA0Mzk4NTAwMDAwMDAwMDExOTEwMDAwMDAwMDAwMDAwICAgMjYwODI1MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDBMQU5DSE9ORVRFIFBPUlRBTCBEQSBCQVJSQSBMVEQgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBCTDAwMDAwMg0KOTIwMTM0MSAgICAgICAgICAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAgICAgICAgICAgMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAgICAgICAgICAgMDAwMDAyMDEwMDAwMDAxNDI3ODYyOSAgMjYvMDhTMDA0NzgwMDAwMDA2MjAwMDAwMDA1MjUyMDQyICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAwMDAwMw0K"
        }
    }
]'
*/



exec pr_egis_arquivo_magnetico_processo_modulo '[
    {
        "ic_json_parametro": "S",
        "cd_parametro": 100,
        "cd_usuario": 5003,
        "cd_modal": 15,
        "dt_inicial": "12-01-2025",
        "dt_final": "12-31-2025",
        "dados_modal": {
            "itens": [
                {
                    "nm_documento_magnetico": "2",
                    "nm_local_documento": "CN25085A (1).RET"
                },
                {
                    "nm_documento_magnetico": "",
                    "nm_local_documento": ""
                }
            ]
        },
        "dados_registro": [
            {
                "nm_documento_magnetico": "Retorno Itau",
                "nm_local_documento": ""
            }
        ],
        "dados_arquivo": {
            "nm_arquivo": "CN25085A (1).RET",
            "mime_type": "text/plain",
            "tamanho": 2412,
            "conteudo_texto": "02RETORNO01COBRANCA       006600138108        CISNEROS ICE C D SORVETES LTDA341BANCO ITAU S.A.25082501600BPI00478260825                                                                                                                                                                                                                                                                                   000001\r\n10214810875000163006600138108        8406633                  00056243            109000562432             I062508258406633   00056243            31072500000000427943411012401000000000000000000000000000000000000000000000000000000000000000000000000000000000000004398500000000011910000000000000   26082500000000000000000000000LANCHONETE PORTAL DA BARRA LTD                                      BL000002\r\n10214810875000163006600138108        8425133                  00056469            109000564693             I062508258425133   00056469            13082500000000581550810001801000000000000000000000000000000000000000000000000000000000000000000000000000000000000005952700000000013720000000000000   26082500000000000000000000000JOSENILDO BATISTA DA SILVA                                          B9000003\r\n10214810875000163006600138108        8449413                  00056648            109000566482             I062508258449413   00056648            06082500000000513340330109901000000000000000000000000000000000000000000000000000000000000000000000000000000000000005266600000000013320000000000000   26082500000000000000000000000BOTTS GASTROBAR LTDA                                                B3000004\r\n10214810875000163006600138108        8449423                  00056649            109000566490             I062508258449423   00056649            13082500000000513330330109901000000000000000000000000000000000000000000000000000000000000000000000000000000000000005254600000000012130000000000000   26082500000000000000000000000BOTTS GASTROBAR LTDA                                                B3000005\r\n9201341          000000000000000000000000000000          000000000000000000000000000000                                                  000000000000000000000000000000          0000020100000014278629  26/08S004780000006200000005252042                                                                                                                                                                000006\r\n",
            "conteudo_base64": "MDJSRVRPUk5PMDFDT0JSQU5DQSAgICAgICAwMDY2MDAxMzgxMDggICAgICAgIENJU05FUk9TIElDRSBDIEQgU09SVkVURVMgTFREQTM0MUJBTkNPIElUQVUgUy5BLjI1MDgyNTAxNjAwQlBJMDA0NzgyNjA4MjUgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAwMDAwMQ0KMTAyMTQ4MTA4NzUwMDAxNjMwMDY2MDAxMzgxMDggICAgICAgIDg0MDY2MzMgICAgICAgICAgICAgICAgICAwMDA1NjI0MyAgICAgICAgICAgIDEwOTAwMDU2MjQzMiAgICAgICAgICAgICBJMDYyNTA4MjU4NDA2NjMzICAgMDAwNTYyNDMgICAgICAgICAgICAzMTA3MjUwMDAwMDAwMDQyNzk0MzQxMTAxMjQwMTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwNDM5ODUwMDAwMDAwMDAxMTkxMDAwMDAwMDAwMDAwMCAgIDI2MDgyNTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwTEFOQ0hPTkVURSBQT1JUQUwgREEgQkFSUkEgTFREICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBCTDAwMDAwMg0KMTAyMTQ4MTA4NzUwMDAxNjMwMDY2MDAxMzgxMDggICAgICAgIDg0MjUxMzMgICAgICAgICAgICAgICAgICAwMDA1NjQ2OSAgICAgICAgICAgIDEwOTAwMDU2NDY5MyAgICAgICAgICAgICBJMDYyNTA4MjU4NDI1MTMzICAgMDAwNTY0NjkgICAgICAgICAgICAxMzA4MjUwMDAwMDAwMDU4MTU1MDgxMDAwMTgwMTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwNTk1MjcwMDAwMDAwMDAxMzcyMDAwMDAwMDAwMDAwMCAgIDI2MDgyNTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwSk9TRU5JTERPIEJBVElTVEEgREEgU0lMVkEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBCOTAwMDAwMw0KMTAyMTQ4MTA4NzUwMDAxNjMwMDY2MDAxMzgxMDggICAgICAgIDg0NDk0MTMgICAgICAgICAgICAgICAgICAwMDA1NjY0OCAgICAgICAgICAgIDEwOTAwMDU2NjQ4MiAgICAgICAgICAgICBJMDYyNTA4MjU4NDQ5NDEzICAgMDAwNTY2NDggICAgICAgICAgICAwNjA4MjUwMDAwMDAwMDUxMzM0MDMzMDEwOTkwMTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwNTI2NjYwMDAwMDAwMDAxMzMyMDAwMDAwMDAwMDAwMCAgIDI2MDgyNTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwQk9UVFMgR0FTVFJPQkFSIExUREEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBCMzAwMDAwNA0KMTAyMTQ4MTA4NzUwMDAxNjMwMDY2MDAxMzgxMDggICAgICAgIDg0NDk0MjMgICAgICAgICAgICAgICAgICAwMDA1NjY0OSAgICAgICAgICAgIDEwOTAwMDU2NjQ5MCAgICAgICAgICAgICBJMDYyNTA4MjU4NDQ5NDIzICAgMDAwNTY2NDkgICAgICAgICAgICAxMzA4MjUwMDAwMDAwMDUxMzMzMDMzMDEwOTkwMTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwNTI1NDYwMDAwMDAwMDAxMjEzMDAwMDAwMDAwMDAwMCAgIDI2MDgyNTAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwQk9UVFMgR0FTVFJPQkFSIExUREEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBCMzAwMDAwNQ0KOTIwMTM0MSAgICAgICAgICAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAgICAgICAgICAgMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAgICAgICAgICAgMDAwMDAyMDEwMDAwMDAxNDI3ODYyOSAgMjYvMDhTMDA0NzgwMDAwMDA2MjAwMDAwMDA1MjUyMDQyICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDAwMDAwNg0K"
        }
    }
]'