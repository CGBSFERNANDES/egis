IF OBJECT_ID('dbo.pr_egis_relatorio_inventario_ativo_periodo', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_inventario_ativo_periodo;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_inventario_ativo_periodo
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-08
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Inventário do Bem do Ativo (cd_relatorio = 445)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Entrada: @json = '[{"dt_inicial": "2026-01-01", "dt_final": "2026-01-31"}]'
    - Dados extraídos de Bem + tabelas relacionadas conforme especificação
    - Retorna HTML no padrão RelatorioHTML
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_inventario_ativo_periodo
    @json NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_relatorio         INT           = 445,
        @cd_empresa           INT           = NULL,
        @dt_inicial_param     NVARCHAR(50)  = NULL,
        @dt_final_param       NVARCHAR(50)  = NULL,
        @dt_inicial           DATETIME      = NULL,
        @dt_final             DATETIME      = NULL,
        @titulo               VARCHAR(200)  = 'Relatório de Inventário do Bem do Ativo',
        @logo                 VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
        @nm_cor_empresa       VARCHAR(20)   = '#1976D2',
        @nm_endereco_empresa  VARCHAR(200)  = '',
        @cd_numero_endereco   VARCHAR(20)   = '',
        @nm_bairro_empresa    VARCHAR(80)   = '',
        @cd_cep_empresa       VARCHAR(20)   = '',
        @nm_cidade_empresa    VARCHAR(80)   = '',
        @sg_estado_empresa    VARCHAR(10)   = '',
        @cd_telefone_empresa  VARCHAR(200)  = '',
        @nm_email_internet    VARCHAR(200)  = '',
        @nm_fantasia_empresa  VARCHAR(200)  = '',
        @cd_cnpj_empresa      VARCHAR(60)   = '',
        @nm_titulo_relatorio  VARCHAR(200)  = NULL,
        @ds_relatorio         VARCHAR(8000) = '',
        @data_hora_atual      VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Validação e normalização do JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
        IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

        /*-----------------------------------------------------------------------------------------
          2) Método obrigatório de extração do JSON
        -----------------------------------------------------------------------------------------*/
        SELECT
            1                                                    AS id_registro,
            IDENTITY(INT, 1, 1)                                  AS id,
            valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  AS campo,
            valores.[value]                                      AS valor
        INTO #json
        FROM OPENJSON(@json) AS root
        CROSS APPLY OPENJSON(root.value) AS valores;

        SELECT @dt_inicial_param = valor FROM #json WHERE campo = 'dt_inicial';
        SELECT @dt_final_param   = valor FROM #json WHERE campo = 'dt_final';

        SET @dt_inicial = TRY_CONVERT(DATETIME, @dt_inicial_param, 121);
        SET @dt_final   = TRY_CONVERT(DATETIME, @dt_final_param, 121);

        IF @dt_inicial IS NULL OR @dt_final IS NULL
            THROW 50002, 'dt_inicial e/ou dt_final não informado(s) ou inválido(s).', 1;

        /*-----------------------------------------------------------------------------------------
          3) Cabeçalho do relatório (relatorio + empresa)
        -----------------------------------------------------------------------------------------*/
        SELECT
            @titulo              = ISNULL(r.nm_relatorio, @titulo),
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.relatorio AS r
        WHERE r.cd_relatorio = @cd_relatorio;

        SET @cd_empresa = dbo.fn_empresa();

        SELECT TOP (1)
            @logo                = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, @logo),
            @nm_cor_empresa      = ISNULL(e.nm_cor_empresa, '#1976D2'),
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, ''),
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, ''),
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(e.cd_numero, ''))),
            @nm_bairro_empresa   = ISNULL(e.nm_bairro_empresa, ''),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @nm_cidade_empresa   = ISNULL(c.nm_cidade, ''),
            @sg_estado_empresa   = ISNULL(est.sg_estado, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @cd_cnpj_empresa     = ISNULL(e.cd_cgc_empresa, '')
        FROM egisadmin.dbo.Empresa AS e
        LEFT JOIN Cidade AS c
            ON c.cd_cidade = e.cd_cidade
        LEFT JOIN Estado AS est
            ON est.cd_estado = c.cd_estado
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          4) Dados do relatório
        -----------------------------------------------------------------------------------------*/
        SELECT
            b.cd_bem,
            gb.nm_grupo_bem,
            b.nm_mascara_bem,
            b.cd_patrimonio_bem,
            b.nm_bem,
            b.nm_marca_bem,
            b.nm_modelo_bem,
            b.nm_serie_bem,
            sb.cd_status_bem,
            sb.nm_status_bem,
            b.dt_aquisicao_bem,
            vb.vl_original_bem,
            f.nm_fantasia_fornecedor,
            nei.cd_nota_entrada,
            nei.cd_serie_nota_fiscal,
            nei.cd_item_nota_entrada,
            lb.cd_localizacao_bem,
            lb.nm_localizacao_bem,
            cc.cd_centro_custo,
            cc.nm_centro_custo,
            d.cd_departamento,
            d.nm_departamento,
            vb.cd_moeda,
            vm.vl_moeda,
            (vm.vl_moeda * vb.vl_original_bem) AS vl_total
        INTO #dados
        FROM Bem AS b
        LEFT JOIN Valor_Bem AS vb
            ON b.cd_bem = vb.cd_bem
        LEFT JOIN Fornecedor AS f
            ON b.cd_fornecedor = f.cd_fornecedor
        LEFT JOIN Nota_Entrada_Item AS nei
            ON b.cd_nota_entrada = nei.cd_nota_entrada
           AND b.cd_item_nota_entrada = nei.cd_item_nota_entrada
        LEFT JOIN Centro_Custo AS cc
            ON b.cd_centro_custo = cc.cd_centro_custo
        LEFT JOIN Departamento AS d
            ON d.cd_departamento = b.cd_departamento
        LEFT JOIN Localizacao_Bem AS lb
            ON b.cd_localizacao_bem = lb.cd_localizacao_bem
        LEFT JOIN Status_Bem AS sb
            ON b.cd_status_bem = sb.cd_status_bem
        LEFT JOIN Parametro_Ativo AS pa
            ON vb.cd_moeda = pa.cd_moeda
        LEFT JOIN Valor_Moeda AS vm
            ON pa.cd_moeda = vm.cd_moeda
        LEFT JOIN Grupo_Bem AS gb
            ON gb.cd_grupo_bem = b.cd_grupo_bem
        WHERE
            b.dt_aquisicao_bem BETWEEN @dt_inicial AND @dt_final;

        DECLARE
            @qt_registros INT = 0,
            @vl_total_geral DECIMAL(25, 2) = 0;

        SELECT
            @qt_registros = COUNT(1),
            @vl_total_geral = ISNULL(SUM(ISNULL(vl_total, 0)), 0)
        FROM #dados;

        /*-----------------------------------------------------------------------------------------
          5) Monta HTML
        -----------------------------------------------------------------------------------------*/
        DECLARE @html NVARCHAR(MAX) = N'';
        DECLARE @style NVARCHAR(MAX) =
N'<style>
    body { font-family: ''Segoe UI'', Arial, sans-serif; color: #222; margin: 0; padding: 0; }
    .report { padding: 24px; }
    .header { display: flex; align-items: center; justify-content: space-between; border-bottom: 3px solid ' + @nm_cor_empresa + N'; padding-bottom: 12px; margin-bottom: 20px; }
    .header__logo img { max-height: 60px; }
    .header__title { text-align: right; }
    .header__title h1 { margin: 0; font-size: 20px; }
    .header__title span { display: block; font-size: 12px; color: #666; }
    .company { font-size: 12px; color: #444; margin-bottom: 16px; }
    .company strong { color: #111; }
    .summary { font-size: 12px; margin-bottom: 12px; }
    .table { width: 100%; border-collapse: collapse; font-size: 10px; }
    .table th, .table td { border: 1px solid #ddd; padding: 6px 8px; text-align: left; vertical-align: top; }
    .table th { background: #f6f6f6; }
    .group { background: #eef3f8; font-weight: 700; }
    .subtotal { background: #fafafa; font-weight: 700; }
    .total { background: #e9f5e9; font-weight: 700; }
    .footer { margin-top: 18px; font-size: 11px; color: #555; }
</style>';

        DECLARE @html_body NVARCHAR(MAX) = N'';

        SET @html_body = (
            SELECT
                N'<tr class="group"><td colspan="24">Departamento: ' + ISNULL(d.nm_departamento, 'Não informado') + N'</td></tr>' +
                (
                    SELECT
                        N'<tr>' +
                            N'<td>' + ISNULL(CAST(d2.cd_bem AS NVARCHAR(20)), '') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_grupo_bem, '') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_mascara_bem, '') + N'</td>' +
                            N'<td>' + ISNULL(d2.cd_patrimonio_bem, '') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_bem, '') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_marca_bem, '') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_modelo_bem, '') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_serie_bem, '') + N'</td>' +
                            N'<td>' + ISNULL(CAST(d2.cd_status_bem AS NVARCHAR(20)), '') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_status_bem, '') + N'</td>' +
                            N'<td>' + ISNULL(CONVERT(VARCHAR(10), d2.dt_aquisicao_bem, 103), '') + N'</td>' +
                            N'<td>' + ISNULL(CONVERT(NVARCHAR(30), CAST(ISNULL(d2.vl_original_bem, 0) AS MONEY), 1), '0,00') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_fantasia_fornecedor, '') + N'</td>' +
                            N'<td>' + ISNULL(CAST(d2.cd_nota_entrada AS NVARCHAR(20)), '') + N'</td>' +
                            N'<td>' + ISNULL(CAST(d2.cd_serie_nota_fiscal AS NVARCHAR(20)), '') + N'</td>' +
                            N'<td>' + ISNULL(CAST(d2.cd_item_nota_entrada AS NVARCHAR(20)), '') + N'</td>' +
                            N'<td>' + ISNULL(CAST(d2.cd_localizacao_bem AS NVARCHAR(20)), '') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_localizacao_bem, '') + N'</td>' +
                            N'<td>' + ISNULL(CAST(d2.cd_centro_custo AS NVARCHAR(20)), '') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_centro_custo, '') + N'</td>' +
                            N'<td>' + ISNULL(CAST(d2.cd_departamento AS NVARCHAR(20)), '') + N'</td>' +
                            N'<td>' + ISNULL(d2.nm_departamento, '') + N'</td>' +
                            N'<td>' + ISNULL(CAST(d2.cd_moeda AS NVARCHAR(20)), '') + N'</td>' +
                            N'<td>' + ISNULL(CONVERT(NVARCHAR(30), CAST(ISNULL(d2.vl_total, 0) AS MONEY), 1), '0,00') + N'</td>' +
                        N'</tr>'
                    FROM #dados AS d2
                    WHERE ISNULL(d2.cd_departamento, -1) = ISNULL(d.cd_departamento, -1)
                    ORDER BY d2.nm_bem
                    FOR XML PATH(''), TYPE
                ).value('.', 'nvarchar(max)') +
                N'<tr class="subtotal"><td colspan="23">Subtotal - ' + ISNULL(d.nm_departamento, 'Não informado') + N'</td>' +
                N'<td>' + CONVERT(NVARCHAR(30), CAST(ISNULL(s.vl_subtotal, 0) AS MONEY), 1) + N'</td></tr>'
            FROM (
                SELECT DISTINCT cd_departamento, nm_departamento
                FROM #dados
            ) AS d
            CROSS APPLY (
                SELECT SUM(ISNULL(vl_total, 0)) AS vl_subtotal
                FROM #dados AS d3
                WHERE ISNULL(d3.cd_departamento, -1) = ISNULL(d.cd_departamento, -1)
            ) AS s
            ORDER BY d.nm_departamento
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)');

        IF @qt_registros = 0
            SET @html_body = N'<tr><td colspan="24">Nenhum registro encontrado para o período informado.</td></tr>';

        SET @html = @style +
            N'<div class="report">' +
                N'<div class="header">' +
                    N'<div class="header__logo"><img src="' + @logo + N'" alt="Logo" /></div>' +
                    N'<div class="header__title">' +
                        N'<h1>' + ISNULL(@nm_titulo_relatorio, @titulo) + N'</h1>' +
                        N'<span>Emissão: ' + @data_hora_atual + N'</span>' +
                    N'</div>' +
                N'</div>' +
                N'<div class="company">' +
                    N'<strong>' + @nm_fantasia_empresa + N'</strong><br />' +
                    ISNULL(@nm_endereco_empresa, '') + N' ' + ISNULL(@cd_numero_endereco, '') + N'<br />' +
                    ISNULL(@nm_bairro_empresa, '') + N' - ' + ISNULL(@nm_cidade_empresa, '') + N'/' + ISNULL(@sg_estado_empresa, '') + N' - ' + ISNULL(@cd_cep_empresa, '') + N'<br />' +
                    N'CNPJ: ' + ISNULL(@cd_cnpj_empresa, '') + N' | Fone: ' + ISNULL(@cd_telefone_empresa, '') + N' | Email: ' + ISNULL(@nm_email_internet, '') +
                N'</div>' +
                N'<div class="summary">' +
                    N'Período: ' + CONVERT(VARCHAR(10), @dt_inicial, 103) + N' até ' + CONVERT(VARCHAR(10), @dt_final, 103) +
                    N' | Registros: ' + CAST(@qt_registros AS NVARCHAR(20)) +
                    N' | Total Geral: ' + CONVERT(NVARCHAR(30), CAST(@vl_total_geral AS MONEY), 1) +
                N'</div>' +
                N'<table class="table">' +
                    N'<thead>' +
                        N'<tr>' +
                            N'<th>Cód. Bem</th>' +
                            N'<th>Grupo</th>' +
                            N'<th>Máscara</th>' +
                            N'<th>Patrimônio</th>' +
                            N'<th>Bem</th>' +
                            N'<th>Marca</th>' +
                            N'<th>Modelo</th>' +
                            N'<th>Série</th>' +
                            N'<th>Status</th>' +
                            N'<th>Descrição Status</th>' +
                            N'<th>Dt. Aquisição</th>' +
                            N'<th>Valor Original</th>' +
                            N'<th>Fornecedor</th>' +
                            N'<th>Nota Entrada</th>' +
                            N'<th>Série NF</th>' +
                            N'<th>Item NF</th>' +
                            N'<th>Localização</th>' +
                            N'<th>Descrição Local</th>' +
                            N'<th>Centro Custo</th>' +
                            N'<th>Descrição CC</th>' +
                            N'<th>Departamento</th>' +
                            N'<th>Descrição Dep.</th>' +
                            N'<th>Moeda</th>' +
                            N'<th>Total</th>' +
                        N'</tr>' +
                    N'</thead>' +
                    N'<tbody>' +
                        @html_body +
                        N'<tr class="total"><td colspan="23">Total Geral</td><td>' +
                        CONVERT(NVARCHAR(30), CAST(@vl_total_geral AS MONEY), 1) +
                        N'</td></tr>' +
                    N'</tbody>' +
                N'</table>' +
                N'<div class="footer">' +
                    N'<strong>Observações:</strong> ' + ISNULL(@ds_relatorio, '') + N'<br />' +
                    N'Gerado em: ' + @data_hora_atual +
                N'</div>' +
            N'</div>';

        /*-----------------------------------------------------------------------------------------
          6) Retorno padrão
        -----------------------------------------------------------------------------------------*/
        SELECT ISNULL(@html, N'') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER()  AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

------------------------------------------------------------------------------
-- Testando a Stored Procedure
------------------------------------------------------------------------------

--exec pr_egis_relatorio_inventario_ativo_periodo @json = '[{"dt_inicial": "2026-01-01", "dt_final": "2026-01-31"}]'
