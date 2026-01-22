IF OBJECT_ID('dbo.pr_egis_relatorio_ordem_servico_consultoria', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_ordem_servico_consultoria;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_ordem_servico_consultoria
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-05
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Gerar o relatório HTML da Ordem de Serviço Consultoria (cd_relatorio = 434)

  Parâmetro único de entrada (JSON):
    @json NVARCHAR(MAX) --> [{ "cd_ordem_servico": 0 }]

  Requisitos Técnicos:
    - SET NOCOUNT ON
    - TRY...CATCH
    - Sem cursor
    - Performance voltada para grandes volumes
    - Código comentado

  Observações:
    - Dados da empresa devem vir de egisadmin.dbo.Empresa
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_ordem_servico_consultoria
    @json NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -------------------------------------------------------------------------------------------------
        -- 1) Declarações e normalização do JSON
        -------------------------------------------------------------------------------------------------
        DECLARE
            @cd_relatorio         INT = 434,
            @cd_empresa           INT = 0,
            @cd_ordem_servico     INT = 0,
            @cd_usuario           INT = NULL,
            @dt_usuario           DATETIME = GETDATE();

        DECLARE
            @titulo               VARCHAR(200) = 'Ordem de Serviço - Consultoria',
            @nm_titulo_relatorio  VARCHAR(200) = NULL,
            @ds_relatorio         VARCHAR(8000) = '',
            @logo                 VARCHAR(400) = 'logo_gbstec_sistema.jpg',
            @nm_cor_empresa       VARCHAR(20) = '#1976D2',
            @nm_fantasia_empresa  VARCHAR(200) = '',
            @nm_endereco_empresa  VARCHAR(200) = '',
            @cd_numero_endereco   VARCHAR(20) = '',
            @cd_cep_empresa       VARCHAR(20) = '',
            @nm_cidade_empresa    VARCHAR(200) = '',
            @sg_estado_empresa    VARCHAR(10) = '',
            @cd_telefone_empresa  VARCHAR(200) = '',
            @nm_email_empresa     VARCHAR(200) = '',
            @nm_pais_empresa      VARCHAR(20) = '';

        DECLARE
            @os_dt_ordem          VARCHAR(30) = '',
            @os_cliente           VARCHAR(200) = '',
            @os_razao_social      VARCHAR(200) = '',
            @os_analista          VARCHAR(200) = '',
            @os_contato           VARCHAR(200) = '',
            @os_departamento      VARCHAR(200) = '',
            @os_centro_custo      VARCHAR(200) = '',
            @os_atividade         VARCHAR(200) = '',
            @os_tipo_treinamento  VARCHAR(200) = '',
            @os_usuario           VARCHAR(200) = '',
            @os_observacao        VARCHAR(500) = '',
            @os_total_horas       VARCHAR(50) = '';

        DECLARE
            @vl_total_servico     DECIMAL(18, 2) = 0,
            @vl_total_despesa     DECIMAL(18, 2) = 0,
            @vl_total_geral       DECIMAL(18, 2) = 0;

        SET @json = ISNULL(@json, '');

        IF LTRIM(RTRIM(@json)) = ''
            SET @json = N'[{}]';

        -------------------------------------------------------------------------------------------------
        -- 2) Extração do JSON conforme contrato obrigatório
        -------------------------------------------------------------------------------------------------
        SELECT
            1                                                    AS id_registro,
            IDENTITY(INT, 1, 1)                                  AS id,
            valores.[key] COLLATE SQL_Latin1_General_CP1_CI_AI   AS campo,
            valores.[value]                                      AS valor
        INTO #json
        FROM
            OPENJSON(@json) AS root
            CROSS APPLY OPENJSON(root.value) AS valores;

        SELECT @cd_ordem_servico = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_ordem_servico';

        SET @cd_ordem_servico = ISNULL(@cd_ordem_servico, 0);

        IF @cd_ordem_servico = 0
            THROW 50001, 'Parâmetro cd_ordem_servico não informado ou inválido.', 1;

        -------------------------------------------------------------------------------------------------
        -- 3) Dados gerais do relatório e empresa
        -------------------------------------------------------------------------------------------------
        SET @cd_empresa = dbo.fn_empresa();

        SELECT
            @titulo              = ISNULL(r.nm_relatorio, @titulo),
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.Relatorio AS r WITH (NOLOCK)
        WHERE r.cd_relatorio = @cd_relatorio;

        SELECT TOP (1)
            @logo                = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, @logo),
            @nm_cor_empresa      = ISNULL(e.nm_cor_empresa, @nm_cor_empresa),
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, ''),
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, ''),
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(e.cd_numero, ''))),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @nm_cidade_empresa   = ISNULL(c.nm_cidade, ''),
            @sg_estado_empresa   = ISNULL(es.sg_estado, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_empresa    = ISNULL(e.nm_email_internet, ''),
            @nm_pais_empresa     = ISNULL(p.sg_pais, '')
        FROM egisadmin.dbo.Empresa AS e WITH (NOLOCK)
        LEFT JOIN egisadmin.dbo.Cidade AS c WITH (NOLOCK)
            ON c.cd_cidade = e.cd_cidade
        LEFT JOIN egisadmin.dbo.Estado AS es WITH (NOLOCK)
            ON es.cd_estado = c.cd_estado
        LEFT JOIN egisadmin.dbo.Pais AS p WITH (NOLOCK)
            ON p.cd_pais = es.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        -------------------------------------------------------------------------------------------------
        -- 4) Dados da ordem de serviço (capa)
        -------------------------------------------------------------------------------------------------
        SELECT
            osa.cd_ordem_servico,
            osa.dt_ordem_servico,
            osa.cd_cliente,
            c.nm_fantasia_cliente,
            c.nm_razao_social_cliente,
            a.nm_fantasia_analista,
            d.nm_departamento_cliente,
            co.nm_fantasia_contato,
            cc.nm_centro_custo,
            aa.nm_atividade_analista,
            tp.nm_tipo_treinamento,
            v.nm_fantasia_usuario,
            (ISNULL(osa.qt_total_normal_ordem, 0) + ISNULL(osa.qt_total_extra_ordem, 0) + ISNULL(osa.qt_total_desloc_ordem, 0)) AS qt_total_geral,
            osa.nm_obs_ordem_servico
        INTO #OrdemServico
        FROM Ordem_Servico_Analista AS osa WITH (NOLOCK)
        LEFT JOIN Cliente AS c WITH (NOLOCK)
            ON c.cd_cliente = osa.cd_cliente
        LEFT JOIN Analista AS a WITH (NOLOCK)
            ON a.cd_analista = osa.cd_analista
        LEFT JOIN Cliente_Contato AS co WITH (NOLOCK)
            ON co.cd_cliente = osa.cd_cliente
           AND co.cd_contato = osa.cd_contato
        LEFT JOIN Departamento_Cliente AS d WITH (NOLOCK)
            ON d.cd_departamento_cliente = osa.cd_departamento_cliente
        LEFT JOIN Centro_Custo AS cc WITH (NOLOCK)
            ON cc.cd_centro_custo = osa.cd_centro_custo
        LEFT JOIN Atividade_Analista AS aa WITH (NOLOCK)
            ON aa.cd_atividade_analista = osa.cd_atividade_analista
        LEFT JOIN Tipo_Treinamento AS tp WITH (NOLOCK)
            ON tp.cd_tipo_treinamento = osa.cd_tipo_treinamento
        LEFT JOIN vw_usuario_oficial AS v WITH (NOLOCK)
            ON v.cd_usuario = osa.cd_usuario_liberacao
        WHERE osa.cd_ordem_servico = @cd_ordem_servico;

        IF NOT EXISTS (SELECT 1 FROM #OrdemServico)
            THROW 50002, 'Nenhuma ordem de serviço encontrada para os parâmetros informados.', 1;

        -------------------------------------------------------------------------------------------------
        -- 5) Itens da ordem de serviço
        -------------------------------------------------------------------------------------------------
        SELECT
            i.*,
            s.nm_servico,
            a.nm_fantasia_analista,
            CASE
                WHEN ISNULL(i.qt_item_extra1_ordem, 0) = 0 AND ISNULL(i.qt_item_extra2_ordem, 0) = 0 THEN 0
                ELSE 1
            END AS ic_extra,
            CASE
                WHEN ISNULL(i.qt_item_desloc_ordem, 0) = 0 THEN 0
                ELSE 1
            END AS ic_desloc,
            ROUND((
                    (CAST(DATEPART(HOUR, CAST(i.qt_item_normal_ordem AS DATETIME)) AS FLOAT) +
                     (CAST(DATEPART(MINUTE, CAST(i.qt_item_normal_ordem AS DATETIME)) AS FLOAT) / 60)) +
                    (CAST(DATEPART(HOUR, CAST(i.qt_item_extra1_ordem AS DATETIME)) AS FLOAT) +
                     (CAST(DATEPART(MINUTE, CAST(i.qt_item_extra1_ordem AS DATETIME)) AS FLOAT) / 60))
                ), 1) *
                CASE
                    WHEN ISNULL(i.vl_servico_ordem_servico, 0) = 0 THEN ISNULL(s.vl_servico, a.vl_analista)
                    ELSE ISNULL(i.vl_servico_ordem_servico, 0)
                END AS vl_total_servico
        INTO #Itens
        FROM Ordem_Servico_Analista_Item AS i WITH (NOLOCK)
        INNER JOIN Ordem_Servico_Analista AS os WITH (NOLOCK)
            ON os.cd_ordem_servico = i.cd_ordem_servico
        LEFT JOIN Servico AS s WITH (NOLOCK)
            ON s.cd_servico = i.cd_servico
        LEFT JOIN Analista AS a WITH (NOLOCK)
            ON a.cd_analista = os.cd_analista
        WHERE i.cd_ordem_servico = @cd_ordem_servico;

        -------------------------------------------------------------------------------------------------
        -- 6) Despesas da ordem de serviço
        -------------------------------------------------------------------------------------------------
        SELECT
            osad.*,
            dp.cd_identificacao_document
        INTO #Despesas
        FROM Ordem_Servico_Analista_Despesa AS osad WITH (NOLOCK)
        LEFT JOIN Documento_Pagar AS dp WITH (NOLOCK)
            ON dp.cd_documento_pagar = osad.cd_documento_pagar
        WHERE osad.cd_ordem_servico = @cd_ordem_servico;

        -------------------------------------------------------------------------------------------------
        -- 7) Totais e dados de cabeçalho
        -------------------------------------------------------------------------------------------------
        SELECT
            @os_dt_ordem = CONVERT(VARCHAR(10), dt_ordem_servico, 103),
            @os_cliente = ISNULL(nm_fantasia_cliente, ''),
            @os_razao_social = ISNULL(nm_razao_social_cliente, ''),
            @os_analista = ISNULL(nm_fantasia_analista, ''),
            @os_contato = ISNULL(nm_fantasia_contato, ''),
            @os_departamento = ISNULL(nm_departamento_cliente, ''),
            @os_centro_custo = ISNULL(nm_centro_custo, ''),
            @os_atividade = ISNULL(nm_atividade_analista, ''),
            @os_tipo_treinamento = ISNULL(nm_tipo_treinamento, ''),
            @os_usuario = ISNULL(nm_fantasia_usuario, ''),
            @os_observacao = ISNULL(nm_obs_ordem_servico, ''),
            @os_total_horas = CAST(qt_total_geral AS VARCHAR(50))
        FROM #OrdemServico;

        SELECT @vl_total_servico = ISNULL(SUM(vl_total_servico), 0)
        FROM #Itens;

        IF EXISTS (
            SELECT 1
            FROM tempdb.sys.columns
            WHERE object_id = OBJECT_ID('tempdb..#Despesas')
              AND name = 'vl_despesa_ordem_servico'
        )
        BEGIN
            SELECT @vl_total_despesa = ISNULL(SUM(vl_despesa_ordem_servico), 0)
            FROM #Despesas;
        END
        ELSE IF EXISTS (
            SELECT 1
            FROM tempdb.sys.columns
            WHERE object_id = OBJECT_ID('tempdb..#Despesas')
              AND name = 'vl_despesa_ordem'
        )
        BEGIN
            SELECT @vl_total_despesa = ISNULL(SUM(vl_despesa_ordem), 0)
            FROM #Despesas;
        END
        ELSE IF EXISTS (
            SELECT 1
            FROM tempdb.sys.columns
            WHERE object_id = OBJECT_ID('tempdb..#Despesas')
              AND name = 'vl_despesa'
        )
        BEGIN
            SELECT @vl_total_despesa = ISNULL(SUM(vl_despesa), 0)
            FROM #Despesas;
        END

        SET @vl_total_geral = ISNULL(@vl_total_servico, 0) + ISNULL(@vl_total_despesa, 0);

        -------------------------------------------------------------------------------------------------
        -- 8) Montagem do HTML (cabeçalho + tabs)
        -------------------------------------------------------------------------------------------------
        DECLARE
            @html_header          NVARCHAR(MAX) = '',
            @html_footer          NVARCHAR(MAX) = '',
            @html_items_header    NVARCHAR(MAX) = '',
            @html_items_rows      NVARCHAR(MAX) = '',
            @html_items_table     NVARCHAR(MAX) = '',
            @html_desp_header     NVARCHAR(MAX) = '',
            @html_desp_rows       NVARCHAR(MAX) = '',
            @html_desp_table      NVARCHAR(MAX) = '',
            @html                NVARCHAR(MAX) = '';

        SET @html_header =
            '<html><head><meta charset="utf-8" />' +
            '<style>' +
            'body { font-family: Arial, Helvetica, sans-serif; color: #333; font-size: 12px; }' +
            '.header { border-bottom: 2px solid ' + @nm_cor_empresa + '; padding-bottom: 10px; margin-bottom: 15px; }' +
            '.header .logo { float: left; width: 120px; }' +
            '.header .empresa { margin-left: 130px; }' +
            '.titulo { font-size: 18px; font-weight: bold; color: ' + @nm_cor_empresa + '; }' +
            '.subtitulo { font-size: 13px; margin-top: 4px; }' +
            '.section { margin-top: 12px; }' +
            '.label { font-weight: bold; }' +
            '.info-grid { width: 100%; }' +
            '.info-grid td { padding: 4px 6px; vertical-align: top; }' +
            'table { width: 100%; border-collapse: collapse; margin-top: 10px; }' +
            'th, td { border: 1px solid #dcdcdc; padding: 6px; text-align: left; font-size: 11px; }' +
            'th { background-color: #f3f3f3; }' +
            '.tabs { margin-top: 15px; }' +
            '.tabs input[type=radio] { display: none; }' +
            '.tabs label { display: inline-block; padding: 6px 12px; margin-right: 4px; background: #f3f3f3; cursor: pointer; border: 1px solid #dcdcdc; border-bottom: none; }' +
            '.tabs label:hover { background: #e8e8e8; }' +
            '.tab-content { display: none; border: 1px solid #dcdcdc; padding: 10px; }' +
            '#tab-servicos:checked ~ #content-servicos { display: block; }' +
            '#tab-despesas:checked ~ #content-despesas { display: block; }' +
            '</style></head><body>' +
            '<div class="header">' +
            '  <div class="logo"><img src="' + @logo + '" style="max-width:110px;" /></div>' +
            '  <div class="empresa">' +
            '    <div class="titulo">' + ISNULL(@nm_titulo_relatorio, @titulo) + '</div>' +
            '    <div class="subtitulo">' + @nm_fantasia_empresa + '</div>' +
            '    <div class="subtitulo">' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @nm_cidade_empresa + ' / ' + @sg_estado_empresa + '</div>' +
            '    <div class="subtitulo">' + @cd_telefone_empresa + ' | ' + @nm_email_empresa + '</div>' +
            '  </div>' +
            '  <div style="clear:both"></div>' +
            '</div>' +
            '<div class="section">' +
            '  <table class="info-grid">' +
            '    <tr>' +
            '      <td><span class="label">Ordem:</span> ' + CAST(@cd_ordem_servico AS VARCHAR(20)) + '</td>' +
            '      <td><span class="label">Data:</span> ' + @os_dt_ordem + '</td>' +
            '      <td><span class="label">Analista:</span> ' + @os_analista + '</td>' +
            '    </tr>' +
            '    <tr>' +
            '      <td><span class="label">Cliente:</span> ' + @os_cliente + '</td>' +
            '      <td><span class="label">Razão Social:</span> ' + @os_razao_social + '</td>' +
            '      <td><span class="label">Contato:</span> ' + @os_contato + '</td>' +
            '    </tr>' +
            '    <tr>' +
            '      <td><span class="label">Departamento:</span> ' + @os_departamento + '</td>' +
            '      <td><span class="label">Centro de Custo:</span> ' + @os_centro_custo + '</td>' +
            '      <td><span class="label">Atividade:</span> ' + @os_atividade + '</td>' +
            '    </tr>' +
            '    <tr>' +
            '      <td><span class="label">Tipo Treinamento:</span> ' + @os_tipo_treinamento + '</td>' +
            '      <td><span class="label">Usuário Liberação:</span> ' + @os_usuario + '</td>' +
            '      <td><span class="label">Horas Totais:</span> ' + @os_total_horas + '</td>' +
            '    </tr>' +
            '    <tr>' +
            '      <td colspan="3"><span class="label">Observação:</span> ' + @os_observacao + '</td>' +
            '    </tr>' +
            '  </table>' +
            '</div>' +
            '<div class="section">' + ISNULL(@ds_relatorio, '') + '</div>' +
            '<div class="section">' +
            '  <table class="info-grid">' +
            '    <tr>' +
            '      <td><span class="label">Total Serviços:</span> ' + CONVERT(VARCHAR(30), @vl_total_servico) + '</td>' +
            '      <td><span class="label">Total Despesas:</span> ' + CONVERT(VARCHAR(30), @vl_total_despesa) + '</td>' +
            '      <td><span class="label">Total Geral:</span> ' + CONVERT(VARCHAR(30), @vl_total_geral) + '</td>' +
            '    </tr>' +
            '  </table>' +
            '</div>' +
            '<div class="tabs">' +
            '  <input type="radio" id="tab-servicos" name="tabs" checked>' +
            '  <label for="tab-servicos">Serviços</label>' +
            '  <input type="radio" id="tab-despesas" name="tabs">' +
            '  <label for="tab-despesas">Despesas</label>';

        -------------------------------------------------------------------------------------------------
        -- 9) Montagem dinâmica da tabela de itens
        -------------------------------------------------------------------------------------------------
        DECLARE @colsItens TABLE (colname SYSNAME, colorder INT);

        INSERT INTO @colsItens (colname, colorder)
        SELECT c.name, c.column_id
        FROM tempdb.sys.columns AS c
        WHERE c.object_id = OBJECT_ID('tempdb..#Itens')
        ORDER BY c.column_id;

        SELECT
            @html_items_header = STUFF((
                SELECT '<th>' + colname + '</th>'
                FROM @colsItens
                ORDER BY colorder
                FOR XML PATH(''), TYPE
            ).value('.', 'nvarchar(max)'), 1, 0, '');

        DECLARE @rowExprItens NVARCHAR(MAX) = '';

        SELECT @rowExprItens = @rowExprItens +
            ' + ''<td>'' + ISNULL(CONVERT(NVARCHAR(MAX), ' + QUOTENAME(colname) + '), '''') + ''</td>'''
        FROM @colsItens
        ORDER BY colorder;

        DECLARE @sqlItens NVARCHAR(MAX) =
            'SELECT @rowsOut = COALESCE(@rowsOut, '''') + ''<tr>'' ' + @rowExprItens + ' + ''</tr>'' FROM #Itens;';

        EXEC sp_executesql @sqlItens, N'@rowsOut NVARCHAR(MAX) OUTPUT', @rowsOut = @html_items_rows OUTPUT;

        SET @html_items_table =
            '<table>' +
            '<thead><tr>' + ISNULL(@html_items_header, '') + '</tr></thead>' +
            '<tbody>' + ISNULL(@html_items_rows, '') + '</tbody>' +
            '</table>';

        -------------------------------------------------------------------------------------------------
        -- 10) Montagem dinâmica da tabela de despesas
        -------------------------------------------------------------------------------------------------
        DECLARE @colsDesp TABLE (colname SYSNAME, colorder INT);

        INSERT INTO @colsDesp (colname, colorder)
        SELECT c.name, c.column_id
        FROM tempdb.sys.columns AS c
        WHERE c.object_id = OBJECT_ID('tempdb..#Despesas')
        ORDER BY c.column_id;

        SELECT
            @html_desp_header = STUFF((
                SELECT '<th>' + colname + '</th>'
                FROM @colsDesp
                ORDER BY colorder
                FOR XML PATH(''), TYPE
            ).value('.', 'nvarchar(max)'), 1, 0, '');

        DECLARE @rowExprDesp NVARCHAR(MAX) = '';

        SELECT @rowExprDesp = @rowExprDesp +
            ' + ''<td>'' + ISNULL(CONVERT(NVARCHAR(MAX), ' + QUOTENAME(colname) + '), '''') + ''</td>'''
        FROM @colsDesp
        ORDER BY colorder;

        DECLARE @sqlDesp NVARCHAR(MAX) =
            'SELECT @rowsOut = COALESCE(@rowsOut, '''') + ''<tr>'' ' + @rowExprDesp + ' + ''</tr>'' FROM #Despesas;';

        EXEC sp_executesql @sqlDesp, N'@rowsOut NVARCHAR(MAX) OUTPUT', @rowsOut = @html_desp_rows OUTPUT;

        SET @html_desp_table =
            '<table>' +
            '<thead><tr>' + ISNULL(@html_desp_header, '') + '</tr></thead>' +
            '<tbody>' + ISNULL(@html_desp_rows, '') + '</tbody>' +
            '</table>';

        -------------------------------------------------------------------------------------------------
        -- 11) Fechamento do HTML com tabs
        -------------------------------------------------------------------------------------------------
        SET @html_footer =
            '  <div class="tab-content" id="content-servicos">' + ISNULL(@html_items_table, '') + '</div>' +
            '  <div class="tab-content" id="content-despesas">' + ISNULL(@html_desp_table, '') + '</div>' +
            '</div>' +
            '</body></html>';

        SET @html = @html_header + @html_footer;

        SELECT ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_relatorio_ordem_servico_consultoria falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        THROW ERROR_NUMBER(), @errMsg, ERROR_STATE();
    END CATCH
END;
GO
