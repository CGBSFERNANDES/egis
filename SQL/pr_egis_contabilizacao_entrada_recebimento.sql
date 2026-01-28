IF OBJECT_ID('dbo.pr_egis_contabilizacao_entrada_recebimento', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_contabilizacao_entrada_recebimento;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_contabilizacao_entrada_recebimento
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-11
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Contabilização de Entradas (cd_relatorio = 440)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Entrada: @json = '[{"dt_inicial": "2025-01-01", "dt_final": "2025-01-31", "cd_usuario": 1, "cd_relatorio": 440}]'
    - Retorna HTML no padrão RelatorioHTML
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_contabilizacao_entrada_recebimento
    @json NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_relatorio             INT           = 440,
        @cd_empresa               INT           = 0,
        @cd_usuario               INT           = 0,
        @dt_inicial               DATETIME      = NULL,
        @dt_final                 DATETIME      = NULL,
        @titulo                   VARCHAR(200)  = 'Contabilização de Entradas',
        @logo                     VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
        @nm_cor_empresa           VARCHAR(20)   = '#1976D2',
        @nm_endereco_empresa      VARCHAR(200)  = '',
        @cd_telefone_empresa      VARCHAR(200)  = '',
        @nm_email_internet        VARCHAR(200)  = '',
        @nm_cidade                VARCHAR(200)  = '',
        @sg_estado                VARCHAR(10)   = '',
        @nm_fantasia_empresa      VARCHAR(200)  = '',
        @cd_cep_empresa           VARCHAR(20)   = '',
        @cd_numero_endereco       VARCHAR(20)   = '',
        @nm_pais                  VARCHAR(20)   = '',
        @cd_cnpj_empresa          VARCHAR(60)   = '',
        @cd_inscestadual_empresa  VARCHAR(100)  = '';

    DECLARE
        @html             NVARCHAR(MAX) = '',
        @html_empresa     NVARCHAR(MAX) = '',
        @html_titulo      NVARCHAR(MAX) = '',
        @html_cab_det     NVARCHAR(MAX) = '',
        @html_detalhe     NVARCHAR(MAX) = '',
        @html_rodape      NVARCHAR(MAX) = '';

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Normaliza JSON (entrada obrigatória) e extrai parâmetros
        -----------------------------------------------------------------------------------------*/
        SET @json = ISNULL(@json, N'');

        IF @json = N''
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

        SELECT
            1                                                    AS id_registro,
            IDENTITY(INT, 1, 1)                                  AS id,
            valores.[key] COLLATE SQL_Latin1_General_CP1_CI_AI    AS campo,
            valores.[value]                                      AS valor
        INTO #json
        FROM openjson(@json) AS root
        CROSS APPLY openjson(root.value) AS valores;

        SELECT @dt_inicial = TRY_CAST(valor AS DATETIME)
        FROM #json
        WHERE campo = 'dt_inicial';

        SELECT @dt_final = TRY_CAST(valor AS DATETIME)
        FROM #json
        WHERE campo = 'dt_final';

        SELECT @cd_usuario = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_usuario';

        SELECT @cd_relatorio = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_relatorio';

        /*-----------------------------------------------------------------------------------------
          2) Dados do relatório e parâmetros padrão
        -----------------------------------------------------------------------------------------*/
        SELECT
            @titulo = ISNULL(r.nm_titulo_relatorio, r.nm_relatorio)
        FROM egisadmin.dbo.Relatorio AS r WITH (NOLOCK)
        WHERE r.cd_relatorio = @cd_relatorio;

        SELECT
            @dt_inicial = ISNULL(p.dt_inicial, @dt_inicial),
            @dt_final   = ISNULL(p.dt_final, @dt_final)
        FROM Parametro_Relatorio AS p WITH (NOLOCK)
        WHERE p.cd_relatorio = @cd_relatorio
          AND p.cd_usuario = @cd_usuario;

        IF @dt_inicial IS NULL OR @dt_final IS NULL
        BEGIN
            SET @dt_inicial = dbo.fn_data_inicial(MONTH(GETDATE()), YEAR(GETDATE()));
            SET @dt_final = dbo.fn_data_final(MONTH(GETDATE()), YEAR(GETDATE()));
        END

        /*-----------------------------------------------------------------------------------------
          3) Dados da empresa (egisadmin)
        -----------------------------------------------------------------------------------------*/
        SET @cd_empresa = dbo.fn_empresa();

        SELECT
            @logo                    = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, 'logo_gbstec_sistema.jpg'),
            @nm_cor_empresa          = ISNULL(e.nm_cor_empresa, '#1976D2'),
            @nm_endereco_empresa     = ISNULL(e.nm_endereco_empresa, ''),
            @cd_telefone_empresa     = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet       = ISNULL(e.nm_email_internet, ''),
            @nm_cidade               = ISNULL(c.nm_cidade, ''),
            @sg_estado               = ISNULL(es.sg_estado, ''),
            @nm_fantasia_empresa     = ISNULL(e.nm_fantasia_empresa, ''),
            @cd_cep_empresa          = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @cd_numero_endereco      = LTRIM(RTRIM(ISNULL(e.cd_numero, 0))),
            @nm_pais                 = LTRIM(RTRIM(ISNULL(p.sg_pais, ''))),
            @cd_cnpj_empresa         = dbo.fn_formata_cnpj(LTRIM(RTRIM(ISNULL(e.cd_cgc_empresa, '')))),
            @cd_inscestadual_empresa = LTRIM(RTRIM(ISNULL(e.cd_iest_empresa, '')))
        FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)
        LEFT JOIN Estado AS es WITH (NOLOCK)
            ON es.cd_estado = e.cd_estado
        LEFT JOIN Cidade AS c WITH (NOLOCK)
            ON c.cd_cidade = e.cd_cidade
           AND c.cd_estado = e.cd_estado
        LEFT JOIN Pais AS p WITH (NOLOCK)
            ON p.cd_pais = e.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          4) Contas padrão para entrada e tributos
        -----------------------------------------------------------------------------------------*/
        DECLARE
            @cd_lancamento_padrao_entrada INT = 0,
            @cd_lancamento_padrao_pis     INT = 0,
            @cd_lancamento_padrao_cofins  INT = 0,
            @cd_lancamento_padrao_icms    INT = 0,
            @cd_lancamento_padrao_ipi     INT = 0,
            @cd_lancamento_padrao_ibs     INT = 0,
            @cd_lancamento_padrao_cbs     INT = 0,
            @cd_conta_debito_entrada      INT = 0,
            @cd_conta_credito_entrada     INT = 0,
            @cd_conta_debito_pis          INT = 0,
            @cd_conta_credito_pis         INT = 0,
            @cd_conta_debito_cofins       INT = 0,
            @cd_conta_credito_cofins      INT = 0,
            @cd_conta_debito_icms         INT = 0,
            @cd_conta_credito_icms        INT = 0,
            @cd_conta_debito_ipi          INT = 0,
            @cd_conta_credito_ipi         INT = 0,
            @cd_conta_debito_ibs          INT = 0,
            @cd_conta_credito_ibs         INT = 0,
            @cd_conta_debito_cbs          INT = 0,
            @cd_conta_credito_cbs         INT = 0;

        SELECT
            @cd_conta_debito_entrada  = cd_conta_debito,
            @cd_conta_credito_entrada = cd_conta_credito
        FROM Lancamento_Padrao WITH (NOLOCK)
        WHERE cd_lancamento_padrao = @cd_lancamento_padrao_entrada;

        SELECT
            @cd_conta_debito_pis  = cd_conta_debito,
            @cd_conta_credito_pis = cd_conta_credito
        FROM Lancamento_Padrao WITH (NOLOCK)
        WHERE cd_lancamento_padrao = @cd_lancamento_padrao_pis;

        SELECT
            @cd_conta_debito_cofins  = cd_conta_debito,
            @cd_conta_credito_cofins = cd_conta_credito
        FROM Lancamento_Padrao WITH (NOLOCK)
        WHERE cd_lancamento_padrao = @cd_lancamento_padrao_cofins;

        SELECT
            @cd_conta_debito_icms  = cd_conta_debito,
            @cd_conta_credito_icms = cd_conta_credito
        FROM Lancamento_Padrao WITH (NOLOCK)
        WHERE cd_lancamento_padrao = @cd_lancamento_padrao_icms;

        SELECT
            @cd_conta_debito_ipi  = cd_conta_debito,
            @cd_conta_credito_ipi = cd_conta_credito
        FROM Lancamento_Padrao WITH (NOLOCK)
        WHERE cd_lancamento_padrao = @cd_lancamento_padrao_ipi;

        SELECT
            @cd_conta_debito_ibs  = cd_conta_debito,
            @cd_conta_credito_ibs = cd_conta_credito
        FROM Lancamento_Padrao WITH (NOLOCK)
        WHERE cd_lancamento_padrao = @cd_lancamento_padrao_ibs;

        SELECT
            @cd_conta_debito_cbs  = cd_conta_debito,
            @cd_conta_credito_cbs = cd_conta_credito
        FROM Lancamento_Padrao WITH (NOLOCK)
        WHERE cd_lancamento_padrao = @cd_lancamento_padrao_cbs;

        /*-----------------------------------------------------------------------------------------
          5) Base total de entradas
        -----------------------------------------------------------------------------------------*/
        SELECT
            n.dt_receb_nota_entrada AS dt_lancamento,
            MAX(pd.cd_conta)         AS cd_conta_debito,
            MAX(pd.cd_mascara_conta) AS cd_mascara_conta_debito,
            MAX(pd.nm_conta)         AS nm_conta_debito,
            MAX(pc.cd_conta)         AS cd_conta_credito,
            MAX(pc.cd_mascara_conta) AS cd_mascara_conta_credito,
            MAX(pc.nm_conta)         AS nm_conta_credito,
            SUM(ISNULL(i.vl_total_nota_entr_item, 0)) AS vl_debito,
            SUM(ISNULL(i.vl_total_nota_entr_item, 0)) AS vl_credito,
            MAX('Total')             AS nm_tipo_contabilizacao
        INTO #Total
        FROM nota_entrada AS n WITH (NOLOCK)
        INNER JOIN nota_entrada_item AS i WITH (NOLOCK)
            ON i.cd_nota_saida = n.cd_nota_saida
        INNER JOIN produto AS p WITH (NOLOCK)
            ON p.cd_produto = i.cd_produto
        INNER JOIN produto_compra AS pco WITH (NOLOCK)
            ON pco.cd_produto = i.cd_produto
        INNER JOIN aplicacao_produto AS ap WITH (NOLOCK)
            ON ap.cd_aplicacao_produto = pco.cd_aplicacao_produto
        LEFT JOIN plano_conta AS pc WITH (NOLOCK)
            ON pc.cd_conta = ap.cd_conta
        LEFT JOIN plano_conta AS pd WITH (NOLOCK)
            ON pd.cd_conta = @cd_conta_debito_entrada
        WHERE n.dt_receb_nota_entrada BETWEEN @dt_inicial AND @dt_final
        GROUP BY n.dt_receb_nota_entrada;

        /*-----------------------------------------------------------------------------------------
          6) Base PIS
        -----------------------------------------------------------------------------------------*/
        SELECT
            n.dt_receb_nota_entrada AS dt_lancamento,
            MAX(pd.cd_conta)         AS cd_conta_debito,
            MAX(pd.cd_mascara_conta) AS cd_mascara_conta_debito,
            MAX(pd.nm_conta)         AS nm_conta_debito,
            MAX(pc.cd_conta)         AS cd_conta_credito,
            MAX(pc.cd_mascara_conta) AS cd_mascara_conta_credito,
            MAX(pc.nm_conta)         AS nm_conta_credito,
            SUM(ISNULL(i.vl_pis_item_nota, 0)) AS vl_debito,
            SUM(ISNULL(i.vl_pis_item_nota, 0)) AS vl_credito,
            MAX('PIS')               AS nm_tipo_contabilizacao
        INTO #ContabilizaPIS
        FROM nota_entrada AS n WITH (NOLOCK)
        INNER JOIN nota_entrada_item AS i WITH (NOLOCK)
            ON i.cd_nota_saida = n.cd_nota_saida
        INNER JOIN produto AS p WITH (NOLOCK)
            ON p.cd_produto = i.cd_produto
        INNER JOIN produto_compra AS pco WITH (NOLOCK)
            ON pco.cd_produto = i.cd_produto
        INNER JOIN aplicacao_produto AS ap WITH (NOLOCK)
            ON ap.cd_aplicacao_produto = pco.cd_aplicacao_produto
        LEFT JOIN plano_conta AS pc WITH (NOLOCK)
            ON pc.cd_conta = ap.cd_conta
        LEFT JOIN plano_conta AS pd WITH (NOLOCK)
            ON pd.cd_conta = @cd_conta_debito_pis
        WHERE n.dt_receb_nota_entrada BETWEEN @dt_inicial AND @dt_final
        GROUP BY n.dt_receb_nota_entrada;

        /*-----------------------------------------------------------------------------------------
          7) Base COFINS
        -----------------------------------------------------------------------------------------*/
        SELECT
            n.dt_receb_nota_entrada AS dt_lancamento,
            MAX(pd.cd_conta)         AS cd_conta_debito,
            MAX(pd.cd_mascara_conta) AS cd_mascara_conta_debito,
            MAX(pd.nm_conta)         AS nm_conta_debito,
            MAX(pc.cd_conta)         AS cd_conta_credito,
            MAX(pc.cd_mascara_conta) AS cd_mascara_conta_credito,
            MAX(pc.nm_conta)         AS nm_conta_credito,
            SUM(ISNULL(i.vl_cofins_item_nota, 0)) AS vl_debito,
            SUM(ISNULL(i.vl_cofins_item_nota, 0)) AS vl_credito,
            MAX('COFINS')            AS nm_tipo_contabilizacao
        INTO #ContabilizaCOFINS
        FROM nota_entrada AS n WITH (NOLOCK)
        INNER JOIN nota_entrada_item AS i WITH (NOLOCK)
            ON i.cd_nota_saida = n.cd_nota_saida
        INNER JOIN produto AS p WITH (NOLOCK)
            ON p.cd_produto = i.cd_produto
        INNER JOIN produto_compra AS pco WITH (NOLOCK)
            ON pco.cd_produto = i.cd_produto
        INNER JOIN aplicacao_produto AS ap WITH (NOLOCK)
            ON ap.cd_aplicacao_produto = pco.cd_aplicacao_produto
        LEFT JOIN plano_conta AS pc WITH (NOLOCK)
            ON pc.cd_conta = ap.cd_conta
        LEFT JOIN plano_conta AS pd WITH (NOLOCK)
            ON pd.cd_conta = @cd_conta_debito_cofins
        WHERE n.dt_receb_nota_entrada BETWEEN @dt_inicial AND @dt_final
        GROUP BY n.dt_receb_nota_entrada;

        /*-----------------------------------------------------------------------------------------
          8) Base ICMS
        -----------------------------------------------------------------------------------------*/
        SELECT
            n.dt_receb_nota_entrada AS dt_lancamento,
            MAX(pd.cd_conta)         AS cd_conta_debito,
            MAX(pd.cd_mascara_conta) AS cd_mascara_conta_debito,
            MAX(pd.nm_conta)         AS nm_conta_debito,
            MAX(pc.cd_conta)         AS cd_conta_credito,
            MAX(pc.cd_mascara_conta) AS cd_mascara_conta_credito,
            MAX(pc.nm_conta)         AS nm_conta_credito,
            SUM(ISNULL(i.vl_icms_nota_entrada, 0)) AS vl_debito,
            SUM(ISNULL(i.vl_icms_nota_entrada, 0)) AS vl_credito,
            MAX('ICMS')              AS nm_tipo_contabilizacao
        INTO #ContabilizaICMS
        FROM nota_entrada AS n WITH (NOLOCK)
        INNER JOIN nota_entrada_item AS i WITH (NOLOCK)
            ON i.cd_nota_saida = n.cd_nota_saida
        INNER JOIN produto AS p WITH (NOLOCK)
            ON p.cd_produto = i.cd_produto
        INNER JOIN produto_compra AS pco WITH (NOLOCK)
            ON pco.cd_produto = i.cd_produto
        INNER JOIN aplicacao_produto AS ap WITH (NOLOCK)
            ON ap.cd_aplicacao_produto = pco.cd_aplicacao_produto
        LEFT JOIN plano_conta AS pc WITH (NOLOCK)
            ON pc.cd_conta = ap.cd_conta
        LEFT JOIN plano_conta AS pd WITH (NOLOCK)
            ON pd.cd_conta = @cd_conta_debito_icms
        WHERE n.dt_receb_nota_entrada BETWEEN @dt_inicial AND @dt_final
        GROUP BY n.dt_receb_nota_entrada;

        /*-----------------------------------------------------------------------------------------
          9) Base IPI
        -----------------------------------------------------------------------------------------*/
        SELECT
            n.dt_receb_nota_entrada AS dt_lancamento,
            MAX(pd.cd_conta)         AS cd_conta_debito,
            MAX(pd.cd_mascara_conta) AS cd_mascara_conta_debito,
            MAX(pd.nm_conta)         AS nm_conta_debito,
            MAX(pc.cd_conta)         AS cd_conta_credito,
            MAX(pc.cd_mascara_conta) AS cd_mascara_conta_credito,
            MAX(pc.nm_conta)         AS nm_conta_credito,
            SUM(ISNULL(i.vl_ipi_nota_entrada, 0)) AS vl_debito,
            SUM(ISNULL(i.vl_ipi_nota_entrada, 0)) AS vl_credito,
            MAX('IPI')               AS nm_tipo_contabilizacao
        INTO #ContabilizaIPI
        FROM nota_entrada AS n WITH (NOLOCK)
        INNER JOIN nota_entrada_item AS i WITH (NOLOCK)
            ON i.cd_nota_saida = n.cd_nota_saida
        INNER JOIN produto AS p WITH (NOLOCK)
            ON p.cd_produto = i.cd_produto
        INNER JOIN produto_compra AS pco WITH (NOLOCK)
            ON pco.cd_produto = i.cd_produto
        INNER JOIN aplicacao_produto AS ap WITH (NOLOCK)
            ON ap.cd_aplicacao_produto = pco.cd_aplicacao_produto
        LEFT JOIN plano_conta AS pc WITH (NOLOCK)
            ON pc.cd_conta = ap.cd_conta
        LEFT JOIN plano_conta AS pd WITH (NOLOCK)
            ON pd.cd_conta = @cd_conta_debito_ipi
        WHERE n.dt_receb_nota_entrada BETWEEN @dt_inicial AND @dt_final
        GROUP BY n.dt_receb_nota_entrada;

        /*-----------------------------------------------------------------------------------------
          10) Base IBS
        -----------------------------------------------------------------------------------------*/
        SELECT
            n.dt_receb_nota_entrada AS dt_lancamento,
            MAX(pd.cd_conta)         AS cd_conta_debito,
            MAX(pd.cd_mascara_conta) AS cd_mascara_conta_debito,
            MAX(pd.nm_conta)         AS nm_conta_debito,
            MAX(pc.cd_conta)         AS cd_conta_credito,
            MAX(pc.cd_mascara_conta) AS cd_mascara_conta_credito,
            MAX(pc.nm_conta)         AS nm_conta_credito,
            SUM(ISNULL(0.00, 0)) AS vl_debito,
            SUM(ISNULL(0.00, 0)) AS vl_credito,
            MAX('IBS')               AS nm_tipo_contabilizacao
        INTO #ContabilizaIBS
        FROM nota_entrada AS n WITH (NOLOCK)
        INNER JOIN nota_entrada_item AS i WITH (NOLOCK)
            ON i.cd_nota_saida = n.cd_nota_saida
        INNER JOIN produto AS p WITH (NOLOCK)
            ON p.cd_produto = i.cd_produto
        INNER JOIN produto_compra AS pco WITH (NOLOCK)
            ON pco.cd_produto = i.cd_produto
        INNER JOIN aplicacao_produto AS ap WITH (NOLOCK)
            ON ap.cd_aplicacao_produto = pco.cd_aplicacao_produto
        LEFT JOIN plano_conta AS pc WITH (NOLOCK)
            ON pc.cd_conta = ap.cd_conta
        LEFT JOIN plano_conta AS pd WITH (NOLOCK)
            ON pd.cd_conta = @cd_conta_debito_ibs
        WHERE n.dt_receb_nota_entrada BETWEEN @dt_inicial AND @dt_final
        GROUP BY n.dt_receb_nota_entrada;

        /*-----------------------------------------------------------------------------------------
          11) Base CBS
        -----------------------------------------------------------------------------------------*/
        SELECT
            n.dt_receb_nota_entrada AS dt_lancamento,
            MAX(pd.cd_conta)         AS cd_conta_debito,
            MAX(pd.cd_mascara_conta) AS cd_mascara_conta_debito,
            MAX(pd.nm_conta)         AS nm_conta_debito,
            MAX(pc.cd_conta)         AS cd_conta_credito,
            MAX(pc.cd_mascara_conta) AS cd_mascara_conta_credito,
            MAX(pc.nm_conta)         AS nm_conta_credito,
            SUM(ISNULL(0.00, 0)) AS vl_debito,
            SUM(ISNULL(0.00, 0)) AS vl_credito,
            MAX('CBS')               AS nm_tipo_contabilizacao
        INTO #ContabilizaCBS
        FROM nota_entrada AS n WITH (NOLOCK)
        INNER JOIN nota_entrada_item AS i WITH (NOLOCK)
            ON i.cd_nota_saida = n.cd_nota_saida
        INNER JOIN produto AS p WITH (NOLOCK)
            ON p.cd_produto = i.cd_produto
        INNER JOIN produto_compra AS pco WITH (NOLOCK)
            ON pco.cd_produto = i.cd_produto
        INNER JOIN aplicacao_produto AS ap WITH (NOLOCK)
            ON ap.cd_aplicacao_produto = pco.cd_aplicacao_produto
        LEFT JOIN plano_conta AS pc WITH (NOLOCK)
            ON pc.cd_conta = ap.cd_conta
        LEFT JOIN plano_conta AS pd WITH (NOLOCK)
            ON pd.cd_conta = @cd_conta_debito_cbs
        WHERE n.dt_receb_nota_entrada BETWEEN @dt_inicial AND @dt_final
        GROUP BY n.dt_receb_nota_entrada;

        /*-----------------------------------------------------------------------------------------
          12) Consolida para impressão
        -----------------------------------------------------------------------------------------*/
        SELECT *
        INTO #Resultado
        FROM #Total
        UNION ALL
        SELECT * FROM #ContabilizaPIS
        UNION ALL
        SELECT * FROM #ContabilizaCOFINS
        UNION ALL
        SELECT * FROM #ContabilizaICMS
        UNION ALL
        SELECT * FROM #ContabilizaIPI
        UNION ALL
        SELECT * FROM #ContabilizaIBS
        UNION ALL
        SELECT * FROM #ContabilizaCBS;

        /*-----------------------------------------------------------------------------------------
          13) Monta HTML
        -----------------------------------------------------------------------------------------*/
        SET @html_empresa =
            '<table style="width:100%; font-family: Arial; font-size:12px; border-collapse:collapse;">' +
            '<tr>' +
            '  <td style="width:15%;"><img src="' + @logo + '" style="height:40px;" /></td>' +
            '  <td style="text-align:left;">' +
            '    <div style="font-size:14px; font-weight:bold; color:' + @nm_cor_empresa + ';">' + @nm_fantasia_empresa + '</div>' +
            '    <div>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + '</div>' +
            '    <div>' + @nm_cidade + ' - ' + @sg_estado + ' - ' + @cd_cep_empresa + '</div>' +
            '    <div>CNPJ: ' + @cd_cnpj_empresa + ' IE: ' + @cd_inscestadual_empresa + '</div>' +
            '  </td>' +
            '</tr>' +
            '</table>';

        SET @html_titulo =
            '<table style="width:100%; font-family: Arial; font-size:13px; border-collapse:collapse;">' +
            '<tr>' +
            '  <td style="text-align:left; font-weight:bold;">' + @titulo + '</td>' +
            '  <td style="text-align:right;">Período: ' + CONVERT(VARCHAR(10), @dt_inicial, 103) + ' até ' + CONVERT(VARCHAR(10), @dt_final, 103) + '</td>' +
            '</tr>' +
            '</table>';

        SET @html_cab_det =
            '<table style="width:100%; border-collapse:collapse; font-family: Arial; font-size:12px;" border="1">' +
            '<thead style="background:#f0f0f0;">' +
            '  <tr>' +
            '    <th style="width:12%;">Data</th>' +
            '    <th>Débito</th>' +
            '    <th>Crédito</th>' +
            '    <th style="width:12%;">Valor</th>' +
            '    <th style="width:12%;">Tipo</th>' +
            '  </tr>' +
            '</thead><tbody>';

        SET @html_detalhe = ISNULL((
            SELECT
                '<tr>' +
                '<td>' + CONVERT(VARCHAR(10), r.dt_lancamento, 103) + '</td>' +
                '<td>' + ISNULL(r.cd_mascara_conta_debito, '') + ' - ' + ISNULL(r.nm_conta_debito, '') + '</td>' +
                '<td>' + ISNULL(r.cd_mascara_conta_credito, '') + ' - ' + ISNULL(r.nm_conta_credito, '') + '</td>' +
                '<td style="text-align:right;">' + CAST(ISNULL(dbo.fn_formata_valor(r.vl_credito), 0) AS NVARCHAR(20)) + '</td>' +
                '<td>' + ISNULL(r.nm_tipo_contabilizacao, '') + '</td>' +
                '</tr>'
            FROM #Resultado AS r
            ORDER BY r.dt_lancamento, r.nm_tipo_contabilizacao
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)'), '');

        IF ISNULL(@html_detalhe, '') = ''
        BEGIN
            SET @html_detalhe = '<tr><td colspan="5" style="text-align:center;">Sem registros no período.</td></tr>';
        END

        DECLARE
            @vl_total_debito   DECIMAL(18, 2) = 0,
            @vl_total_credito  DECIMAL(18, 2) = 0,
            @html_resumo       NVARCHAR(MAX) = '',
            @html_totais       NVARCHAR(MAX) = '';

        SELECT
            @vl_total_debito  = ISNULL(SUM(r.vl_debito), 0),
            @vl_total_credito = ISNULL(SUM(r.vl_credito), 0)
        FROM #Resultado AS r;

        SET @html_resumo =
            '<br /><table style="width:100%; border-collapse:collapse; font-family: Arial; font-size:12px;" border="1">' +
            '<thead style="background:#f0f0f0;">' +
            '  <tr>' +
            '    <th>Débito</th>' +
            '    <th>Crédito</th>' +
            '    <th>Valor</th>' +
            '    <th>Tipo de Contabilização</th>' +
            '  </tr>' +
            '</thead><tbody>' +
            ISNULL((
                SELECT
                    '<tr>' +
                    '<td>' + ISNULL(MAX(r.cd_mascara_conta_debito), '') + ' - ' + ISNULL(MAX(r.nm_conta_debito), '') + '</td>' +
                    '<td>' + ISNULL(MAX(r.cd_mascara_conta_credito), '') + ' - ' + ISNULL(MAX(r.nm_conta_credito), '') + '</td>' +
                    '<td style="text-align:right;">' + CAST(ISNULL(dbo.fn_formata_valor(SUM(r.vl_credito)), 0) AS NVARCHAR(20)) + '</td>' +
                    '<td>' + ISNULL(r.nm_tipo_contabilizacao, '') + '</td>' +
                    '</tr>'
                FROM #Resultado AS r
                GROUP BY r.nm_tipo_contabilizacao
                FOR XML PATH(''), TYPE
            ).value('.', 'nvarchar(max)'), '') +
            '</tbody></table>';

        SET @html_totais =
            '<br /><table style="width:100%; border-collapse:collapse; font-family: Arial; font-size:12px;" border="1">' +
            '<tr>' +
            '  <td style="text-align:right;"><strong>Total Débito</strong></td>' +
            '  <td style="text-align:right;">' + CAST(ISNULL(dbo.fn_formata_valor(@vl_total_debito), 0) AS NVARCHAR(20)) + '</td>' +
            '  <td style="text-align:right;"><strong>Total Crédito</strong></td>' +
            '  <td style="text-align:right;">' + CAST(ISNULL(dbo.fn_formata_valor(@vl_total_credito), 0) AS NVARCHAR(20)) + '</td>' +
            '</tr>' +
            '</table>';

        SET @html_rodape = '</tbody></table>' + @html_totais + @html_resumo;

        SET @html =
            '<html><head><meta charset="UTF-8"></head><body>' +
            @html_empresa + '<br />' +
            @html_titulo + '<br />' +
            @html_cab_det +
            @html_detalhe +
            @html_rodape +
            '</body></html>';

        SELECT ISNULL(@html, N'') AS RelatorioHTML;

        /*-----------------------------------------------------------------------------------------
          14) Limpeza
        -----------------------------------------------------------------------------------------*/
        DROP TABLE #Resultado;
        DROP TABLE #Total;
        DROP TABLE #ContabilizaPIS;
        DROP TABLE #ContabilizaCOFINS;
        DROP TABLE #ContabilizaICMS;
        DROP TABLE #ContabilizaIPI;
        DROP TABLE #ContabilizaIBS;
        DROP TABLE #ContabilizaCBS;
        DROP TABLE #json;
    END TRY
    BEGIN CATCH
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();

        IF OBJECT_ID('tempdb..#Resultado') IS NOT NULL DROP TABLE #Resultado;
        IF OBJECT_ID('tempdb..#Total') IS NOT NULL DROP TABLE #Total;
        IF OBJECT_ID('tempdb..#ContabilizaPIS') IS NOT NULL DROP TABLE #ContabilizaPIS;
        IF OBJECT_ID('tempdb..#ContabilizaCOFINS') IS NOT NULL DROP TABLE #ContabilizaCOFINS;
        IF OBJECT_ID('tempdb..#ContabilizaICMS') IS NOT NULL DROP TABLE #ContabilizaICMS;
        IF OBJECT_ID('tempdb..#ContabilizaIPI') IS NOT NULL DROP TABLE #ContabilizaIPI;
        IF OBJECT_ID('tempdb..#ContabilizaIBS') IS NOT NULL DROP TABLE #ContabilizaIBS;
        IF OBJECT_ID('tempdb..#ContabilizaCBS') IS NOT NULL DROP TABLE #ContabilizaCBS;
        IF OBJECT_ID('tempdb..#json') IS NOT NULL DROP TABLE #json;

        SELECT '<html><body><h3>Erro ao gerar relatório.</h3><p>' + @msg + '</p></body></html>' AS RelatorioHTML;
    END CATCH
END
GO

--use egissql_359

--Geracao a integração Contabil---


--exec pr_egis_contabilizacao_entrada_recebimento @json = '[{"dt_inicial":"2025-01-01","dt_final":"2027-01-31","cd_usuario":1,"cd_relatorio":439}]'


--


