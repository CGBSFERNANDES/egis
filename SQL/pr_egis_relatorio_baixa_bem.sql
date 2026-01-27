IF EXISTS (SELECT name 
       FROM   sysobjects 
       WHERE  name = N'pr_egis_relatorio_baixa_bem' 
       AND    type = 'P')
    DROP PROCEDURE pr_egis_relatorio_baixa_bem
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_baixa_bem
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2025-04-07
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatorio HTML - Baixa do Bem (cd_relatorio = 443)

  Requisitos:
    - Somente 1 parametro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Codigo comentado
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE pr_egis_relatorio_baixa_bem
    @json NVARCHAR(MAX) = ''
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        ------------------------------------------------------------------------------
        -- Variaveis de controle
        ------------------------------------------------------------------------------
        DECLARE
            @cd_relatorio            INT           = 443,
            @cd_empresa              INT           = 0,
            @cd_usuario              INT           = 0,
            @dt_inicial              DATETIME      = NULL,
            @dt_final                DATETIME      = NULL,
            @dt_hoje                 DATETIME      = NULL,
            @cd_ano                  INT           = 0,
            @cd_mes                  INT           = 0,
            @cd_dia                  INT           = 0,
            @titulo                  VARCHAR(200)  = 'Baixa de Aquisicao do Bem',
            @logo                    VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
            @nm_cor_empresa          VARCHAR(20)   = '#1976D2',
            @nm_endereco_empresa     VARCHAR(200)  = '',
            @cd_telefone_empresa     VARCHAR(200)  = '',
            @nm_email_internet       VARCHAR(200)  = '',
            @nm_cidade               VARCHAR(200)  = '',
            @sg_estado               VARCHAR(10)   = '',
            @nm_fantasia_empresa     VARCHAR(200)  = '',
            @cd_numero_endereco_emp  VARCHAR(20)   = '',
            @cd_cep_empresa          VARCHAR(20)   = '',
            @nm_pais                 VARCHAR(20)   = '',
            @cd_cnpj_empresa         VARCHAR(60)   = '',
            @cd_inscestadual_empresa VARCHAR(100)  = '',
            @nm_dominio_internet     VARCHAR(200)  = '',
            @ds_relatorio            VARCHAR(8000) = '',
            @data_hora_atual         VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

        ------------------------------------------------------------------------------
        -- Extracao de parametros do JSON (obrigatorio)
        ------------------------------------------------------------------------------
        SET @json = ISNULL(@json, '');

        IF @json <> ''
        BEGIN
            SELECT
                1                                                    AS id_registro,
                IDENTITY(INT, 1, 1)                                  AS id,
                valores.[key] COLLATE SQL_Latin1_General_CP1_CI_AI   AS campo,
                valores.[value]                                      AS valor
            INTO #json
            FROM openjson(@json) AS root
            CROSS APPLY openjson(root.value) AS valores;

            SELECT @cd_empresa   = valor FROM #json WHERE campo = 'cd_empresa';
            SELECT @cd_usuario   = valor FROM #json WHERE campo = 'cd_usuario';
            SELECT @dt_inicial   = valor FROM #json WHERE campo = 'dt_inicial';
            SELECT @dt_final     = valor FROM #json WHERE campo = 'dt_final';
            SELECT @cd_relatorio = valor FROM #json WHERE campo = 'cd_relatorio';
        END

        SET @cd_relatorio = ISNULL(@cd_relatorio, 443);
        SET @cd_empresa = CASE WHEN ISNULL(@cd_empresa, 0) = 0 THEN dbo.fn_empresa() ELSE @cd_empresa END;

        ------------------------------------------------------------------------------
        -- Parametros do relatorio (quando disponiveis)
        ------------------------------------------------------------------------------
        SELECT
            @titulo       = ISNULL(r.nm_relatorio, @titulo),
            @ds_relatorio = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.Relatorio AS r
        WHERE r.cd_relatorio = @cd_relatorio;

        SELECT
            @dt_inicial = ISNULL(pr.dt_inicial, @dt_inicial),
            @dt_final   = ISNULL(pr.dt_final, @dt_final)
        FROM Parametro_Relatorio AS pr
        WHERE pr.cd_relatorio = @cd_relatorio
          AND pr.cd_usuario   = @cd_usuario;

        SET @dt_hoje = CONVERT(DATETIME, LEFT(CONVERT(VARCHAR, GETDATE(), 121), 10) + ' 00:00:00', 121);
        SET @cd_ano = YEAR(@dt_hoje);
        SET @cd_mes = MONTH(@dt_hoje);
        SET @cd_dia = DAY(@dt_hoje);

        IF @dt_inicial IS NULL OR @dt_inicial = '19000101'
        BEGIN
            SET @dt_inicial = dbo.fn_data_inicial(@cd_mes, @cd_ano);
            SET @dt_final   = dbo.fn_data_final(@cd_mes, @cd_ano);
        END

        ------------------------------------------------------------------------------
        -- Dados da empresa
        ------------------------------------------------------------------------------
        SELECT
            @logo                    = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, @logo),
            @nm_cor_empresa          = CASE WHEN ISNULL(e.nm_cor_empresa, '') <> '' THEN e.nm_cor_empresa ELSE '#1976D2' END,
            @nm_endereco_empresa     = ISNULL(e.nm_endereco_empresa, ''),
            @cd_telefone_empresa     = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet       = ISNULL(e.nm_email_internet, ''),
            @nm_cidade               = ISNULL(c.nm_cidade, ''),
            @sg_estado               = ISNULL(es.sg_estado, ''),
            @nm_fantasia_empresa     = ISNULL(e.nm_fantasia_empresa, ''),
            @cd_cep_empresa          = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @cd_numero_endereco_emp  = LTRIM(RTRIM(ISNULL(e.cd_numero, ''))),
            @nm_pais                 = LTRIM(RTRIM(ISNULL(p.sg_pais, ''))),
            @cd_cnpj_empresa         = dbo.fn_formata_cnpj(LTRIM(RTRIM(ISNULL(e.cd_cgc_empresa, '')))),
            @cd_inscestadual_empresa = LTRIM(RTRIM(ISNULL(e.cd_iest_empresa, ''))),
            @nm_dominio_internet     = LTRIM(RTRIM(ISNULL(e.nm_dominio_internet, '')))
        FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)
        LEFT JOIN Estado AS es WITH (NOLOCK) ON es.cd_estado = e.cd_estado
        LEFT JOIN Cidade AS c WITH (NOLOCK) ON c.cd_cidade = e.cd_cidade AND c.cd_estado = e.cd_estado
        LEFT JOIN Pais AS p WITH (NOLOCK) ON p.cd_pais = e.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        ------------------------------------------------------------------------------
        -- Dados do relatorio
        ------------------------------------------------------------------------------
        SELECT
            IDENTITY(INT, 1, 1)                                             AS cd_controle,
            CONVERT(DATE, b.dt_aquisicao_bem)                                AS dt_aquisicao_bem,
            b.dt_baixa_bem,
            CASE WHEN ISNULL(b.cd_patrimonio_bem, '0') = '0' THEN 'N' ELSE 'S' END AS sem_identificacao,
            CASE WHEN ISNULL(b.cd_apolice_seguro, 0) = 0 THEN 'N' ELSE 'S' END      AS seguro,
            CASE WHEN ISNULL(b.dt_garantia_bem, 0) >= GETDATE() THEN 'S' ELSE 'N' END AS garantia,
            b.cd_bem,
            b.nm_bem,
            b.cd_patrimonio_bem,
            gb.nm_grupo_bem,
            cc.nm_centro_custo,
            sb.nm_status_bem,
            b.cd_nota_saida,
            b.cd_item_nota_saida,
            b.qt_item_nota_saida,
            b.cd_cliente,
            c.nm_fantasia_cliente,
            d.nm_departamento,
            b.qt_bem,
            p.nm_planta,
            s.nm_seguradora,
            opf.cd_mascara_operacao,
            vb.vl_original_bem,
            b.cd_tipo_baixa_bem,
            tbb.nm_tipo_baixa_bem
        INTO #Consulta
        FROM bem AS b WITH (NOLOCK)
        LEFT JOIN Grupo_Bem AS gb WITH (NOLOCK) ON gb.cd_grupo_bem = b.cd_grupo_bem
        LEFT JOIN Status_Bem AS sb WITH (NOLOCK) ON sb.cd_status_bem = b.cd_status_bem
        LEFT JOIN Centro_Custo AS cc WITH (NOLOCK) ON cc.cd_centro_custo = b.cd_centro_custo
        LEFT JOIN Cliente AS c WITH (NOLOCK) ON c.cd_cliente = b.cd_cliente
        LEFT JOIN Departamento AS d WITH (NOLOCK) ON d.cd_departamento = b.cd_departamento
        LEFT JOIN Planta AS p WITH (NOLOCK) ON p.cd_planta = b.cd_planta
        LEFT JOIN Seguradora AS s WITH (NOLOCK) ON s.cd_seguradora = b.cd_seguradora
        LEFT JOIN Operacao_Fiscal AS opf WITH (NOLOCK) ON opf.cd_operacao_fiscal = b.cd_operacao_fiscal
        LEFT JOIN Valor_Bem AS vb WITH (NOLOCK) ON vb.cd_bem = b.cd_bem
        LEFT JOIN Tipo_Baixa_Bem AS tbb WITH (NOLOCK) ON tbb.cd_tipo_baixa_bem = b.cd_tipo_baixa_bem
        WHERE b.dt_baixa_bem BETWEEN @dt_inicial AND @dt_final
        ORDER BY b.dt_baixa_bem, b.cd_patrimonio_bem;

        ------------------------------------------------------------------------------
        -- Montagem do HTML
        ------------------------------------------------------------------------------
        DECLARE
            @html            VARCHAR(MAX) = '',
            @html_empresa    VARCHAR(MAX) = '',
            @html_titulo     VARCHAR(MAX) = '',
            @html_cab_det    VARCHAR(MAX) = '',
            @html_detalhe    VARCHAR(MAX) = '',
            @html_rod_det    VARCHAR(MAX) = '',
            @html_rodape     VARCHAR(MAX) = '',
            @html_geral      VARCHAR(MAX) = '';

        SET @html_empresa = '
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>' + ISNULL(@titulo, '') + '</title>
    <style>
        body { font-family: Arial, sans-serif; color: #333; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        table, th, td { border: 1px solid #ddd; }
        th, td { padding: 6px; text-align: center; font-size: 12px; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .header { padding: 5px; text-align: center; }
        .section-title { background-color: #1976D2; color: white; padding: 6px; border-radius: 4px; font-size: 18px; }
        img { max-width: 250px; margin-right: 10px; }
        .title { color: #1976D2; }
        .report-date-time { text-align: right; margin-top: 20px; }
        .group-row { background-color: #e6eef7; font-weight: bold; }
        .subtotal-row { background-color: #f5f5f5; font-weight: bold; }
        .total-row { background-color: #dfe7f1; font-weight: bold; }
    </style>
</head>
<body>
    <div style="display:flex; justify-content: space-between; align-items:center;">
        <div style="width:35%; margin-right:20px">
            <img src="' + @logo + '" alt="Logo da Empresa">
        </div>
        <div style="width:65%; padding-left:10px">
            <p class="title">' + @nm_fantasia_empresa + '</p>
            <p><strong>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco_emp + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade + ' - ' + @sg_estado + ' - ' + @nm_pais + '</strong></p>
            <p><strong>Fone: </strong>' + @cd_telefone_empresa + ' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
            <p>' + @nm_dominio_internet + ' - ' + @nm_email_internet + '</p>
        </div>
    </div>
';

        SET @html_titulo = '
    <div class="section-title">Relatorio de Baixa do Bem</div>
    <p><strong>Periodo:</strong> ' + CONVERT(VARCHAR, @dt_inicial, 103) + ' a ' + CONVERT(VARCHAR, @dt_final, 103) + '</p>
';

        SET @html_cab_det = '
    <table>
        <tr>
            <th>Sem Identificacao</th>
            <th>Seguro</th>
            <th>Garantia</th>
            <th>Data Baixa</th>
            <th>Bem</th>
            <th>Descricao Bem</th>
            <th>Patrimonio</th>
            <th>Grupo</th>
            <th>Centro de Custo</th>
            <th>Status</th>
            <th>Nota Saida</th>
            <th>Item Nota</th>
            <th>Qt Item</th>
            <th>Cliente</th>
            <th>Nome Cliente</th>
            <th>Departamento</th>
            <th>Qt Bem</th>
            <th>Planta</th>
            <th>Seguradora</th>
            <th>Operacao</th>
            <th>Valor Original</th>
            <th>Tipo Baixa</th>
            <th>Descricao Baixa</th>
        </tr>
';

        --------------------------------------------------------------------------
        -- Loop por data de aquisicao com subtotal
        --------------------------------------------------------------------------
        DECLARE
            @dt_grupo              DATE = NULL,
            @qt_bem_grupo          INT = 0,
            @vl_original_grupo     DECIMAL(18, 4) = 0,
            @qt_bem_total          INT = 0,
            @vl_original_total     DECIMAL(18, 4) = 0;

        SELECT
            @qt_bem_total      = ISNULL(SUM(ISNULL(qt_bem, 0)), 0),
            @vl_original_total = ISNULL(SUM(ISNULL(vl_original_bem, 0)), 0)
        FROM #Consulta;

        WHILE EXISTS (SELECT 1 FROM #Consulta)
        BEGIN
            SELECT TOP (1)
                @dt_grupo = dt_aquisicao_bem
            FROM #Consulta
            ORDER BY dt_aquisicao_bem;

            SET @html_detalhe = @html_detalhe +
                '<tr class="group-row"><td colspan="23">Data de Aquisicao: ' + ISNULL(CONVERT(VARCHAR, @dt_grupo, 103), '') + '</td></tr>';

            SET @html_detalhe = @html_detalhe +
            (
                SELECT
                    '<tr>' +
                    '<td>' + ISNULL(sem_identificacao, '') + '</td>' +
                    '<td>' + ISNULL(seguro, '') + '</td>' +
                    '<td>' + ISNULL(garantia, '') + '</td>' +
                    '<td>' + ISNULL(CONVERT(VARCHAR, dt_baixa_bem, 103), '') + '</td>' +
                    '<td>' + ISNULL(CAST(cd_bem AS VARCHAR(20)), '') + '</td>' +
                    '<td>' + ISNULL(nm_bem, '') + '</td>' +
                    '<td>' + ISNULL(cd_patrimonio_bem, '') + '</td>' +
                    '<td>' + ISNULL(nm_grupo_bem, '') + '</td>' +
                    '<td>' + ISNULL(nm_centro_custo, '') + '</td>' +
                    '<td>' + ISNULL(nm_status_bem, '') + '</td>' +
                    '<td>' + ISNULL(CAST(cd_nota_saida AS VARCHAR(20)), '') + '</td>' +
                    '<td>' + ISNULL(CAST(cd_item_nota_saida AS VARCHAR(20)), '') + '</td>' +
                    '<td>' + ISNULL(CAST(qt_item_nota_saida AS VARCHAR(20)), '') + '</td>' +
                    '<td>' + ISNULL(CAST(cd_cliente AS VARCHAR(20)), '') + '</td>' +
                    '<td>' + ISNULL(nm_fantasia_cliente, '') + '</td>' +
                    '<td>' + ISNULL(nm_departamento, '') + '</td>' +
                    '<td>' + ISNULL(CAST(qt_bem AS VARCHAR(20)), '') + '</td>' +
                    '<td>' + ISNULL(nm_planta, '') + '</td>' +
                    '<td>' + ISNULL(nm_seguradora, '') + '</td>' +
                    '<td>' + ISNULL(cd_mascara_operacao, '') + '</td>' +
                    '<td>' + ISNULL(dbo.fn_formata_valor(ISNULL(vl_original_bem, 0)), '0') + '</td>' +
                    '<td>' + ISNULL(CAST(cd_tipo_baixa_bem AS VARCHAR(20)), '') + '</td>' +
                    '<td>' + ISNULL(nm_tipo_baixa_bem, '') + '</td>' +
                    '</tr>'
                FROM #Consulta
                WHERE dt_aquisicao_bem = @dt_grupo
                ORDER BY dt_baixa_bem, cd_patrimonio_bem
                FOR XML PATH(''), TYPE
            ).value('.', 'VARCHAR(MAX)');

            SELECT
                @qt_bem_grupo      = ISNULL(SUM(ISNULL(qt_bem, 0)), 0),
                @vl_original_grupo = ISNULL(SUM(ISNULL(vl_original_bem, 0)), 0)
            FROM #Consulta
            WHERE dt_aquisicao_bem = @dt_grupo;

            SET @html_detalhe = @html_detalhe +
                '<tr class="subtotal-row">' +
                '<td colspan="16">Sub-total</td>' +
                '<td>' + CAST(@qt_bem_grupo AS VARCHAR(20)) + '</td>' +
                '<td colspan="3"></td>' +
                '<td>' + ISNULL(dbo.fn_formata_valor(@vl_original_grupo), '0') + '</td>' +
                '<td colspan="2"></td>' +
                '</tr>';

            DELETE FROM #Consulta WHERE dt_aquisicao_bem = @dt_grupo;
        END

        SET @html_rod_det =
            '<tr class="total-row">' +
            '<td colspan="16">Total Geral</td>' +
            '<td>' + CAST(@qt_bem_total AS VARCHAR(20)) + '</td>' +
            '<td colspan="3"></td>' +
            '<td>' + ISNULL(dbo.fn_formata_valor(@vl_original_total), '0') + '</td>' +
            '<td colspan="2"></td>' +
            '</tr>';

        SET @html_rodape = '
    </table>
    <p>' + @ds_relatorio + '</p>
    <div class="report-date-time">Gerado em: ' + @data_hora_atual + '</div>
</body>
</html>';

        SET @html = @html_empresa + @html_titulo + @html_cab_det + @html_detalhe + @html_rod_det + @html_rodape;

        SELECT 'Baixa_Bem_' + CONVERT(VARCHAR(20), @cd_relatorio) AS pdfName,
               ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        SELECT
            'ERRO AO GERAR RELATORIO 443 - BAIXA DO BEM: ' + ERROR_MESSAGE() AS MensagemErro;
    END CATCH
END
GO

-- exec pr_egis_relatorio_baixa_bem @json = '[{"dt_inicial":"2000-01-01","dt_final":"2026-01-31"}]'
