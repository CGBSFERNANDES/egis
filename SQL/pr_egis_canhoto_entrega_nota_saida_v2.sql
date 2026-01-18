IF OBJECT_ID('dbo.pr_egis_canhoto_entrega_nota_saida', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_canhoto_entrega_nota_saida;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_canhoto_entrega_nota_saida
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-01-XX
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : ChatGPT (OpenAI)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório 428 - Canhoto de Entrega (Nota Fiscal de Saída)
                     - Gera HTML (RelatorioHTML) para impressão de canhotos.
                     - Uma nota fiscal por bloco, com linha pontilhada e ícone de tesoura.

  Parâmetro único de entrada (JSON):
    @json NVARCHAR(MAX) --> [{"dt_inicial": "", "dt_final": "", "cd_nota_saida": 0}]

  Requisitos Técnicos:
    - SET NOCOUNT ON
    - TRY...CATCH
    - Sem cursor (set-based)
    - Compatível com SQL Server 2016
    - Código comentado

  Fontes de dados de leitura:
    - nota_saida (cd_identificacao_nota_saida)
    - vw_nfe_emitente_nota_fiscal (emitente)
    - vw_nfe_identificacao_nota_fiscal (identificação da nota)
    - vw_nfe_destintario_nota_fiscal (destinatário)
    - vw_nfe_transporte_nota_fiscal (transporte)
    - egisadmin.dbo.empresa (dados da empresa)
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_canhoto_entrega_nota_saida
    @json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Normaliza e valida JSON de entrada (aceita objeto ou array)
        -----------------------------------------------------------------------------------------*/
        DECLARE @jsonNormalized NVARCHAR(MAX) = LTRIM(RTRIM(ISNULL(@json, N'')));

        IF @jsonNormalized = N''
            SET @jsonNormalized = N'[{}]';

        IF ISJSON(@jsonNormalized) = 0
            THROW 50001, 'JSON de entrada inválido ou mal formatado.', 1;

        IF JSON_VALUE(@jsonNormalized, '$[0]') IS NULL
            SET @jsonNormalized = CONCAT('[', @jsonNormalized, ']');

        /*-----------------------------------------------------------------------------------------
          2) Carrega parâmetros em tabela (sem cursor)
        -----------------------------------------------------------------------------------------*/
        DECLARE @Parametros TABLE
        (
            dt_inicial NVARCHAR(30) NULL,
            dt_final NVARCHAR(30) NULL,
            cd_nota_saida INT NULL
        );

        INSERT INTO @Parametros (dt_inicial, dt_final, cd_nota_saida)
        SELECT
            j.dt_inicial,
            j.dt_final,
            TRY_CAST(j.cd_nota_saida AS INT) AS cd_nota_saida
        FROM OPENJSON(@jsonNormalized)
        WITH (
            dt_inicial NVARCHAR(30) '$.dt_inicial',
            dt_final NVARCHAR(30) '$.dt_final',
            cd_nota_saida INT '$.cd_nota_saida'
        ) AS j;

        IF NOT EXISTS (SELECT 1 FROM @Parametros)
            THROW 50002, 'Nenhum parâmetro informado em @json.', 1;

        DECLARE
            @dt_inicial_raw NVARCHAR(30) = NULL,
            @dt_final_raw NVARCHAR(30) = NULL,
            @cd_nota_saida INT = NULL,
            @dt_inicial DATETIME = NULL,
            @dt_final DATETIME = NULL;

        SELECT TOP (1)
            @dt_inicial_raw = NULLIF(LTRIM(RTRIM(dt_inicial)), ''),
            @dt_final_raw = NULLIF(LTRIM(RTRIM(dt_final)), ''),
            @cd_nota_saida = cd_nota_saida
        FROM @Parametros;

        SET @dt_inicial = COALESCE(
            TRY_CONVERT(DATETIME, @dt_inicial_raw, 103),
            TRY_CONVERT(DATETIME, @dt_inicial_raw, 120),
            TRY_CONVERT(DATETIME, @dt_inicial_raw)
        );

        SET @dt_final = COALESCE(
            TRY_CONVERT(DATETIME, @dt_final_raw, 103),
            TRY_CONVERT(DATETIME, @dt_final_raw, 120),
            TRY_CONVERT(DATETIME, @dt_final_raw)
        );

        /*-----------------------------------------------------------------------------------------
          3) Carrega dados principais da nota/empresa
        -----------------------------------------------------------------------------------------*/
        ;WITH Base AS
        (
            SELECT
                ns.cd_nota_saida,
                COALESCE(ns.cd_identificacao_nota_saida, ident.cd_identificacao_nota_saida) AS cd_identificacao_nota_saida,
                ns.dt_nota_saida,
                ns.vl_total AS vl_total_nota,
                ident.nNF AS nr_nota,
                ident.serie AS nr_serie,
                emit.xNome AS nm_emitente,
                emit.xFant AS nm_fantasia_emitente,
                emit.CNPJ AS cnpj_emitente,
                emit.IE AS ie_emitente,
                emit.xLgr AS endereco_emitente,
                emit.nro AS numero_emitente,
                emit.xBairro AS bairro_emitente,
                emit.xMun AS cidade_emitente,
                emit.UF AS uf_emitente,
                emit.CEP AS cep_emitente,
                dest.xNome AS nm_destinatario,
                dest.xFant AS nm_fantasia_destinatario,
                COALESCE(NULLIF(dest.CNPJ2, ''), NULLIF(dest.CPF, '')) AS doc_destinatario,
                dest.xLgr AS endereco_destinatario,
                dest.nro AS numero_destinatario,
                dest.xBairro AS bairro_destinatario,
                dest.xMun AS cidade_destinatario,
                dest.UF AS uf_destinatario,
                dest.CEP AS cep_destinatario,
                transp.xNome AS nm_transportadora,
                transp.CNPJ AS cnpj_transportadora,
                transp.xMun AS cidade_transportadora,
                transp.UF AS uf_transportadora,
                emp.nm_empresa,
                emp.nm_fantasia_empresa,
                emp.cd_cgc_empresa,
                emp.cd_ie_empresa,
                emp.nm_endereco_empresa,
                emp.cd_numero,
                emp.nm_bairro_empresa,
                emp.nm_cidade_empresa,
                emp.sg_estado_empresa,
                emp.cd_cep_empresa,
                emp.cd_telefone_empresa,
                cp.nm_condicao_pagamento
            FROM nota_saida AS ns WITH (NOLOCK)
            LEFT JOIN condicao_pagamento AS cp WITH (NOLOCK)
                ON cp.cd_condicao_pagamento = ns.cd_condicao_pagamento
            OUTER APPLY (
                SELECT TOP (1)
                    v.cd_identificacao_nota_saida,
                    v.nNF,
                    v.serie
                FROM vw_nfe_identificacao_nota_fiscal AS v
                WHERE v.cd_nota_saida = ns.cd_nota_saida
                ORDER BY v.cd_identificacao_nota_saida
            ) AS ident
            OUTER APPLY (
                SELECT TOP (1)
                    v.xNome,
                    v.xFant,
                    v.CNPJ,
                    v.IE,
                    v.xLgr,
                    v.nro,
                    v.xBairro,
                    v.xMun,
                    v.UF,
                    v.CEP
                FROM vw_nfe_emitente_nota_fiscal AS v
                WHERE v.cd_nota_saida = ns.cd_nota_saida
                ORDER BY v.cd_identificacao_nota_saida
            ) AS emit
            OUTER APPLY (
                SELECT TOP (1)
                    d.xNome,
                    d.xFant,
                    d.CNPJ2,
                    d.CPF,
                    d.xLgr,
                    d.nro,
                    d.xBairro,
                    d.xMun,
                    d.UF,
                    d.CEP
                FROM vw_nfe_destintario_nota_fiscal AS d
                WHERE d.cd_nota_saida = ns.cd_nota_saida
                ORDER BY d.cd_identificacao_nota_saida
            ) AS dest
            OUTER APPLY (
                SELECT TOP (1)
                    t.xNome,
                    t.CNPJ,
                    t.xMun,
                    t.UF
                FROM vw_nfe_transporte_nota_fiscal AS t
                WHERE t.cd_nota_saida = ns.cd_nota_saida
                ORDER BY t.cd_identificacao_nota_saida
            ) AS transp
            OUTER APPLY (
                SELECT TOP (1)
                    e.nm_empresa,
                    e.nm_fantasia_empresa,
                    e.cd_cgc_empresa,
                    e.cd_iest_empresa AS cd_ie_empresa,
                    e.nm_endereco_empresa,
                    e.cd_numero,
                    e.nm_bairro_empresa,
                    cid.nm_cidade AS nm_cidade_empresa,
                    est.sg_estado AS sg_estado_empresa,
                    dbo.fn_formata_cep(e.cd_cep_empresa) AS cd_cep_empresa,
                    e.cd_telefone_empresa
                FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)
                LEFT JOIN Cidade AS cid WITH (NOLOCK) ON cid.cd_cidade = e.cd_cidade
                LEFT JOIN Estado AS est WITH (NOLOCK) ON est.cd_estado = cid.cd_estado
                WHERE e.cd_empresa = dbo.fn_empresa()
            ) AS emp
            WHERE
                (@cd_nota_saida IS NULL OR ns.cd_nota_saida = @cd_nota_saida)
                AND (@dt_inicial IS NULL OR ns.dt_nota_saida >= @dt_inicial)
                AND (
                    @dt_final IS NULL
                    OR ns.dt_nota_saida < DATEADD(DAY, 1, CONVERT(DATE, @dt_final))
                )
        ),
        Dados AS
        (
            SELECT
                b.*, 
                ROW_NUMBER() OVER (ORDER BY b.dt_nota_saida, b.cd_nota_saida) AS rn,
                COUNT(*) OVER () AS total_registros
            FROM Base AS b
        )

        select * into #TmpDados from Dados

        /*-----------------------------------------------------------------------------------------
          4) Validação de existência de dados
        -----------------------------------------------------------------------------------------*/
        IF NOT EXISTS (SELECT 1 FROM #TmpDados)
            THROW 50004, 'Nenhum dado encontrado para os filtros informados.', 1;

        /*-----------------------------------------------------------------------------------------
          5) Monta HTML de saída (RelatorioHTML)
        -----------------------------------------------------------------------------------------*/
        DECLARE @html NVARCHAR(MAX) = N'';
        DECLARE @data_hora NVARCHAR(20) =
            CONVERT(VARCHAR(10), GETDATE(), 103) + N' ' + CONVERT(VARCHAR(5), GETDATE(), 108);
        DECLARE @style NVARCHAR(MAX) =
N'<style>
    body { font-family: ''Segoe UI'', Arial, sans-serif; color: #222; margin: 0; padding: 0; }
    .report { width: 100%; }
    .canhoto { border: 1px solid #444; padding: 12px 14px; margin-bottom: 12px; box-sizing: border-box; }
    .header { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; }
    .logo { font-weight: 700; font-size: 20px; line-height: 1.1; }
    .logo-sub { font-weight: 600; font-size: 11px; letter-spacing: 0.3px; }
    .header-center { flex: 1; text-align: center; font-size: 16px; font-weight: 700; }
    .header-right { text-align: right; font-size: 11px; min-width: 140px; }
    .line { border-bottom: 1px solid #444; margin: 6px 0 10px; }
    .label { font-weight: 700; }
    .receipt-table { width: 100%; border-collapse: collapse; font-size: 11px; }
    .box { border: 1px solid #444; vertical-align: top; padding: 6px; }
    .box-left { width: 78%; }
    .box-right { width: 22%; text-align: center; }
    .box-title { font-size: 10px; font-weight: 700; margin-bottom: 6px; }
    .box-row { display: flex; border-top: 1px solid #444; }
    .box-cell { flex: 1; padding: 6px; border-right: 1px solid #444; min-height: 20px; }
    .box-cell:last-child { border-right: 0; }
    .nf-title { font-size: 12px; font-weight: 700; }
    .nf-number { font-size: 18px; font-weight: 700; margin: 4px 0; }
    .nf-serie { font-size: 12px; font-weight: 700; }
    .info-row { display: flex; justify-content: space-between; gap: 12px; font-size: 11px; margin-top: 6px; }
    .info-left { flex: 1; }
    .dest-name { font-weight: 700; }
    .cut-line { display: flex; align-items: center; gap: 8px; margin: 6px 0 12px; color: #666; }
    .cut-text { flex: 1; overflow: hidden; white-space: nowrap; font-size: 11px; }
    .scissor { font-size: 14px; }
</style>';

        SET @html = @style + N'<div class="report">';

        SET @html = @html +
        (
            SELECT
                '<div class="canhoto">' +
                    '<div class="header">' +
                        '<div class="logo">' +
                            ISNULL(COALESCE(NULLIF(d.nm_fantasia_empresa, ''''), NULLIF(d.nm_empresa, ''''), NULLIF(d.nm_emitente, '''')), '''') +
                            '<div class="logo-sub">' +
                                ISNULL(COALESCE(NULLIF(d.nm_empresa, ''''), NULLIF(d.nm_emitente, '''')), '''') +
                            '</div>' +
                        '</div>' +
                        '<div class="header-center">Canhotos de Entrega</div>' +
                        '<div class="header-right">' +
                            '<div><span class="label">PÁG.:</span> 1</div>' +
                            '<div><span class="label">DATA / HORA:</span> ' + @data_hora + '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="line"></div>' +
                    '<table class="receipt-table">' +
                        '<tr>' +
                            '<td class="box box-left">' +
                                '<div class="box-title">RECEBEMOS OS PRODUTOS / SERVIÇOS CONSTANTES NA NOTA FISCAL INDICADA AO LADO</div>' +
                                '<div class="box-row">' +
                                    '<div class="box-cell"><span class="label">DATA DE RECEBIMENTO</span><br>&nbsp;</div>' +
                                    '<div class="box-cell"><span class="label">IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR</span><br>&nbsp;</div>' +
                                '</div>' +
                            '</td>' +
                            '<td class="box box-right">' +
                                '<div class="nf-title">NF-e</div>' +
                                '<div class="nf-number">' + ISNULL(CONVERT(VARCHAR(20), d.nr_nota), '') + '</div>' +
                                '<div class="nf-serie">Série: ' + ISNULL(CONVERT(VARCHAR(10), d.nr_serie), '') + '</div>' +
                            '</td>' +
                        '</tr>' +
                    '</table>' +
                    '<div class="info-row">' +
                        '<div class="info-left">' +
                            '<div class="dest-name">' + ISNULL(d.nm_destinatario, '') + '</div>' +
                        '</div>' +
                        '<div>' + ISNULL(NULLIF(d.nm_fantasia_destinatario, ''), '') + '</div>' +
                    '</div>' +
                    '<div class="info-row">' +
                        '<div><span class="label">VALOR NOTA:</span> ' + ISNULL(dbo.fn_formata_valor(ISNULL(d.vl_total_nota, 0)), '') + '</div>' +
                        '<div><span class="label">FORMA DE PAGAMENTO:</span> ' + ISNULL(d.nm_condicao_pagamento, '') + '</div>' +
                    '</div>' +
                '</div>' +
                CASE
                    WHEN d.rn < d.total_registros THEN
                        '<div class="cut-line"><span class="cut-text">....................................................................................................................</span><span class="scissor">✂</span></div>'
                    ELSE
                        ''
                END
            FROM #TmpDados AS d
            ORDER BY d.rn
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)');

        SET @html = @html + N'</div>';

        /*-----------------------------------------------------------------------------------------
          6) Retorno do HTML
        -----------------------------------------------------------------------------------------*/
        SELECT ISNULL(@html, N'') AS RelatorioHTML;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, @ErrorMessage, 1;
    END CATCH;
END;
GO
use egissql_357
go

exec pr_egis_canhoto_entrega_nota_saida '[{"dt_inicial":"12/01/2025", "dt_final": "12/31/2025"}]'
