IF OBJECT_ID('dbo.pr_egis_relatorio_parcelas_contrato_pagar', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_parcelas_contrato_pagar;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_parcelas_contrato_pagar
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2025-01-01
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatorio HTML - Parcelas do Contrato a Pagar (cd_relatorio = 432)

  Parametro unico de entrada (JSON):
    @json NVARCHAR(MAX) --> [{"dt_inicial":"YYYY-MM-DD","dt_final":"YYYY-MM-DD"}]

  Requisitos Tecnicos:
    - SET NOCOUNT ON
    - TRY...CATCH
    - Sem cursor (abordagem set-based)
    - Performance para grandes volumes
    - Codigo comentado

  Observacoes:
    - As parcelas estao em contrato_pagar_composicao
    - Empresa deve ser lida de egisadmin.dbo.Empresa
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_parcelas_contrato_pagar
    @json NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_relatorio        INT           = 432,
        @cd_empresa          INT           = NULL,
        @dt_inicial          DATETIME      = NULL,
        @dt_final            DATETIME      = NULL,
        @dt_hoje             DATETIME      = GETDATE(),
        @titulo              VARCHAR(200)  = 'Parcelas do Contrato a Pagar',
        @logo                VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
        @nm_cor_empresa      VARCHAR(20)   = '#1976D2',
        @nm_endereco_empresa VARCHAR(200)  = '',
        @cd_telefone_empresa VARCHAR(200)  = '',
        @nm_email_internet   VARCHAR(200)  = '',
        @nm_cidade           VARCHAR(200)  = '',
        @sg_estado           VARCHAR(10)   = '',
        @nm_fantasia_empresa VARCHAR(200)  = '',
        @cd_cep_empresa      VARCHAR(20)   = '',
        @cd_numero_empresa   VARCHAR(20)   = '',
        @nm_pais             VARCHAR(20)   = '',
        @cd_cnpj_empresa     VARCHAR(60)   = '',
        @cd_inscestadual     VARCHAR(100)  = '',
        @nm_dominio_internet VARCHAR(200)  = '',
        @ds_relatorio        VARCHAR(8000) = '',
        @qt_parcelas         INT           = 0,
        @vl_total_parcelas   DECIMAL(18,2) = 0,
        @data_hora_atual     VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Normaliza e valida JSON de entrada (aceita objeto ou array)
        -----------------------------------------------------------------------------------------*/
        DECLARE @jsonNormalized NVARCHAR(MAX) = LTRIM(RTRIM(ISNULL(@json, N'')));

        IF @jsonNormalized = N''
            SET @jsonNormalized = N'[{}]';

        IF ISJSON(@jsonNormalized) = 0
            THROW 50001, 'JSON de entrada invalido ou mal formatado.', 1;

        IF JSON_VALUE(@jsonNormalized, '$[0]') IS NULL
            SET @jsonNormalized = CONCAT('[', @jsonNormalized, ']');

        DECLARE @Parametros TABLE
        (
            dt_inicial DATETIME NULL,
            dt_final   DATETIME NULL
        );

        INSERT INTO @Parametros (dt_inicial, dt_final)
        SELECT
            TRY_CAST(j.dt_inicial AS DATETIME),
            TRY_CAST(j.dt_final AS DATETIME)
        FROM OPENJSON(@jsonNormalized)
        WITH (
            dt_inicial NVARCHAR(30) '$.dt_inicial',
            dt_final   NVARCHAR(30) '$.dt_final'
        ) AS j;

        SELECT TOP (1)
            @dt_inicial = p.dt_inicial,
            @dt_final   = p.dt_final
        FROM @Parametros AS p;

        /*-----------------------------------------------------------------------------------------
          2) Aplica periodo default (mes corrente) quando nao informado
        -----------------------------------------------------------------------------------------*/
        IF @dt_inicial IS NULL OR @dt_inicial = '1900-01-01'
            SET @dt_inicial = dbo.fn_data_inicial(MONTH(@dt_hoje), YEAR(@dt_hoje));

        IF @dt_final IS NULL OR @dt_final = '1900-01-01'
            SET @dt_final = dbo.fn_data_final(MONTH(@dt_hoje), YEAR(@dt_hoje));

        IF @dt_final < @dt_inicial
        BEGIN
            DECLARE @dt_swap DATETIME = @dt_inicial;
            SET @dt_inicial = @dt_final;
            SET @dt_final = @dt_swap;
        END

        /*-----------------------------------------------------------------------------------------
          3) Dados do relatorio (titulo/descritivo)
        -----------------------------------------------------------------------------------------*/
        SELECT
            @titulo       = ISNULL(r.nm_relatorio, @titulo),
            @ds_relatorio = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.relatorio AS r
        WHERE r.cd_relatorio = @cd_relatorio;

        /*-----------------------------------------------------------------------------------------
          4) Dados da empresa (obrigatorio: egisadmin.dbo.Empresa)
        -----------------------------------------------------------------------------------------*/
        SET @cd_empresa = dbo.fn_empresa();

        SELECT TOP (1)
            @logo                = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, @logo),
            @nm_cor_empresa      = ISNULL(e.nm_cor_empresa, '#1976D2'),
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @nm_cidade           = ISNULL(c.nm_cidade, ''),
            @sg_estado           = ISNULL(es.sg_estado, ''),
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, ''),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @cd_numero_empresa   = LTRIM(RTRIM(ISNULL(e.cd_numero, ''))),
            @nm_pais             = LTRIM(RTRIM(ISNULL(p.sg_pais, ''))),
            @cd_cnpj_empresa     = dbo.fn_formata_cnpj(LTRIM(RTRIM(ISNULL(e.cd_cgc_empresa, '')))),
            @cd_inscestadual     = LTRIM(RTRIM(ISNULL(e.cd_iest_empresa, ''))),
            @nm_dominio_internet = LTRIM(RTRIM(ISNULL(e.nm_dominio_internet, '')))
        FROM egisadmin.dbo.Empresa AS e WITH (NOLOCK)
        LEFT JOIN Estado AS es WITH (NOLOCK) ON es.cd_estado = e.cd_estado
        LEFT JOIN Cidade AS c WITH (NOLOCK) ON c.cd_cidade = e.cd_cidade AND c.cd_estado = e.cd_estado
        LEFT JOIN Pais AS p WITH (NOLOCK) ON p.cd_pais = e.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          5) Base do relatorio (parcelas do contrato no periodo)
        -----------------------------------------------------------------------------------------*/
        SELECT
            cp.cd_contrato_pagar,
            cs.nm_contrato_pagar,
            cs.dt_emissao_contrato,
            cp.dt_parc_contrato,
            f.nm_fantasia_fornecedor,
            cp.vl_parc_contrato,
            tcpp.nm_tipo_conta_pagar,
            tco.nm_tipo_contrato,
            d.nm_departamento
        INTO #parcelas
        FROM contrato_pagar_composicao AS cp WITH (NOLOCK)
        INNER JOIN contrato_pagar AS cs WITH (NOLOCK)
            ON cs.cd_contrato_pagar = cp.cd_contrato_pagar
        LEFT JOIN fornecedor AS f WITH (NOLOCK)
            ON f.cd_fornecedor = cs.cd_fornecedor
        LEFT JOIN tipo_conta_pagar AS tcpp WITH (NOLOCK)
            ON tcpp.cd_tipo_conta_pagar = cs.cd_tipo_conta_pagar
        LEFT JOIN tipo_contrato AS tco WITH (NOLOCK)
            ON tco.cd_tipo_contrato = cs.cd_tipo_contrato
        LEFT JOIN departamento AS d WITH (NOLOCK)
            ON d.cd_departamento = cs.cd_departamento
        WHERE
            cp.dt_parc_contrato >= @dt_inicial
            AND cp.dt_parc_contrato <= @dt_final
            AND cs.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          6) Totais e contadores
        -----------------------------------------------------------------------------------------*/
        SELECT
            @qt_parcelas = COUNT(1),
            @vl_total_parcelas = ISNULL(SUM(vl_parc_contrato), 0)
        FROM #parcelas;

        /*-----------------------------------------------------------------------------------------
          7) HTML - cabecalho e conteudo
        -----------------------------------------------------------------------------------------*/
        DECLARE
            @html_empresa NVARCHAR(MAX) = N'',
            @html_geral   NVARCHAR(MAX) = N'',
            @html_detalhe NVARCHAR(MAX) = N'',
            @html_totais  NVARCHAR(MAX) = N'',
            @html         NVARCHAR(MAX) = N'';

        SET @html_empresa = N'
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>' + @titulo + N'</title>
    <style>
        body { font-family: Arial, sans-serif; color: #333; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        table, th, td { border: 1px solid #ddd; }
        th, td { padding: 8px; font-size: 12px; }
        th { background-color: #f2f2f2; color: #333; text-align: center; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
        .section-title { background-color: ' + @nm_cor_empresa + N'; color: white; padding: 5px; border-radius: 5px; font-size: 120%; }
        .company-info { text-align: right; }
        .report-date-time { text-align: right; font-size: 12px; color: #666; }
        .tamanho { font-size: 12px; }
    </style>
</head>
<body>';

        SET @html_geral = N'
<div class="header">
    <div>
        <img src="' + @logo + N'" alt="Logo" />
    </div>
    <div class="company-info">
        <strong>' + @nm_fantasia_empresa + N'</strong><br />
        ' + @nm_endereco_empresa + N', ' + @cd_numero_empresa + N'<br />
        ' + @nm_cidade + N' - ' + @sg_estado + N'<br />
        CEP: ' + @cd_cep_empresa + N'<br />
        CNPJ: ' + @cd_cnpj_empresa + N'<br />
        IE: ' + @cd_inscestadual + N'<br />
        ' + @cd_telefone_empresa + N' | ' + @nm_email_internet + N'
    </div>
</div>
<div class="report-date-time">' + @data_hora_atual + N'</div>
<h3 class="section-title">' + @titulo + N'</h3>
<p><strong>Periodo:</strong> ' + ISNULL(dbo.fn_data_string(@dt_inicial), '') + N' a ' + ISNULL(dbo.fn_data_string(@dt_final), '') + N'</p>
<table>
    <tr>
        <th>Codigo</th>
        <th>Contrato</th>
        <th>Emissao</th>
        <th>Vencimento</th>
        <th>Fornecedor</th>
        <th>Valor Parcela</th>
        <th>Classificacao</th>
        <th>Tipo de Contrato</th>
        <th>Departamento</th>
    </tr>';

        SELECT
            @html_detalhe = (
                SELECT
                    N'<tr>' +
                    N'<td class="tamanho">' + ISNULL(CAST(p.cd_contrato_pagar AS VARCHAR(20)), '') + N'</td>' +
                    N'<td class="tamanho">' + ISNULL(p.nm_contrato_pagar, '') + N'</td>' +
                    N'<td class="tamanho">' + ISNULL(dbo.fn_data_string(p.dt_emissao_contrato), '') + N'</td>' +
                    N'<td class="tamanho">' + ISNULL(dbo.fn_data_string(p.dt_parc_contrato), '') + N'</td>' +
                    N'<td class="tamanho">' + ISNULL(p.nm_fantasia_fornecedor, '') + N'</td>' +
                    N'<td class="tamanho" style="text-align:right;">' + ISNULL(dbo.fn_formata_valor(p.vl_parc_contrato), '0') + N'</td>' +
                    N'<td class="tamanho">' + ISNULL(p.nm_tipo_conta_pagar, '') + N'</td>' +
                    N'<td class="tamanho">' + ISNULL(p.nm_tipo_contrato, '') + N'</td>' +
                    N'<td class="tamanho">' + ISNULL(p.nm_departamento, '') + N'</td>' +
                    N'</tr>'
                FROM #parcelas AS p
                ORDER BY p.dt_parc_contrato, p.cd_contrato_pagar
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)');

        IF NULLIF(@html_detalhe, N'') IS NULL
            SET @html_detalhe = N'<tr><td class="tamanho" colspan="9">Nenhum registro encontrado para o periodo informado.</td></tr>';

        SET @html_totais = N'
</table>
<table>
    <tr>
        <th>Contador</th>
        <th>Total por Valor da Parcela</th>
    </tr>
    <tr>
        <td class="tamanho">' + CAST(@qt_parcelas AS VARCHAR(20)) + N'</td>
        <td class="tamanho" style="text-align:right;">' + ISNULL(dbo.fn_formata_valor(@vl_total_parcelas), '0') + N'</td>
    </tr>
</table>
</body>
</html>';

        SET @html = @html_empresa + @html_geral + @html_detalhe + @html_totais;

        /*-----------------------------------------------------------------------------------------
          8) Saida do relatorio
        -----------------------------------------------------------------------------------------*/
        IF @html <> ''
            SELECT @html AS RelatorioHTML;
        ELSE
            SELECT 'Relatorio nao configurado.' AS RelatorioHTML;

        /*-----------------------------------------------------------------------------------------
          9) (Opcional) Log de execucao de relatorio
             - Caso exista tabela de log padrao no ambiente, registrar aqui.
        -----------------------------------------------------------------------------------------*/

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, 'Erro ao gerar Relatorio 432 - Parcelas do Contrato a Pagar. ' + @ErrorMessage, 1;
    END CATCH;
END;
GO
