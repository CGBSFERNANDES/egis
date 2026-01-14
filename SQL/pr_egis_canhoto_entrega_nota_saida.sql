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
                emp.cd_telefone_empresa
            FROM nota_saida AS ns WITH (NOLOCK)
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
        /*-----------------------------------------------------------------------------------------
          4) Validação de existência de dados
        -----------------------------------------------------------------------------------------*/
        IF NOT EXISTS (SELECT 1 FROM Dados)
            THROW 50004, 'Nenhum dado encontrado para os filtros informados.', 1;

        /*-----------------------------------------------------------------------------------------
          5) Monta HTML de saída (RelatorioHTML)
        -----------------------------------------------------------------------------------------*/
        DECLARE @html NVARCHAR(MAX) = N'';
        DECLARE @style NVARCHAR(MAX) =
N'<style>
    body { font-family: ''Segoe UI'', Arial, sans-serif; color: #222; margin: 0; padding: 0; }
    .report { width: 100%; }
    .canhoto { border: 1px solid #444; padding: 12px 16px; margin-bottom: 12px; box-sizing: border-box; }
    .title { font-size: 16px; font-weight: 700; text-align: center; margin-bottom: 8px; }
    .row { display: flex; justify-content: space-between; gap: 12px; font-size: 12px; }
    .col { flex: 1; }
    .label { font-weight: 600; }
    .section { margin: 6px 0; font-size: 12px; }
    .barcode { font-size: 14px; letter-spacing: 2px; text-align: center; font-weight: 700; margin-top: 8px; }
    .cut-line { display: flex; align-items: center; gap: 8px; margin: 6px 0 12px; color: #666; }
    .cut-text { flex: 1; overflow: hidden; white-space: nowrap; font-size: 11px; }
    .scissor { font-size: 14px; }
    .signature { margin-top: 12px; font-size: 12px; display: flex; justify-content: space-between; gap: 12px; }
    .signature span { flex: 1; border-top: 1px solid #444; padding-top: 4px; text-align: center; }
</style>';

        SET @html = @style + N'<div class="report">';

        SET @html = @html +
        (
            SELECT
                '<div class="canhoto">' +
                    '<div class="title">CANHOTO DE ENTREGA</div>' +
                    '<div class="section"><span class="label">Empresa:</span> ' + ISNULL(d.nm_empresa, '') + '</div>' +
                    '<div class="section"><span class="label">Endereço:</span> ' + ISNULL(d.nm_endereco_empresa, '') + ', ' + ISNULL(CONVERT(VARCHAR(20), d.cd_numero), '') +
                        ' - ' + ISNULL(d.nm_bairro_empresa, '') + ' - ' + ISNULL(d.nm_cidade_empresa, '') + '/' + ISNULL(d.sg_estado_empresa, '') +
                        ' CEP ' + ISNULL(d.cd_cep_empresa, '') +
                    '</div>' +
                    '<div class="row">' +
                        '<div class="col"><span class="label">CNPJ:</span> ' + ISNULL(d.cd_cgc_empresa, '') + '</div>' +
                        '<div class="col"><span class="label">IE:</span> ' + ISNULL(d.cd_ie_empresa, '') + '</div>' +
                        '<div class="col"><span class="label">Telefone:</span> ' + ISNULL(d.cd_telefone_empresa, '') + '</div>' +
                    '</div>' +
                    '<div class="section"><span class="label">Emitente:</span> ' + ISNULL(d.nm_emitente, '') + '</div>' +
                    '<div class="section"><span class="label">Destinatário:</span> ' + ISNULL(d.nm_destinatario, '') + ' (' + ISNULL(d.doc_destinatario, '') + ')</div>' +
                    '<div class="section"><span class="label">Endereço Destinatário:</span> ' + ISNULL(d.endereco_destinatario, '') + ', ' + ISNULL(d.numero_destinatario, '') +
                        ' - ' + ISNULL(d.bairro_destinatario, '') + ' - ' + ISNULL(d.cidade_destinatario, '') + '/' + ISNULL(d.uf_destinatario, '') +
                        ' CEP ' + ISNULL(d.cep_destinatario, '') +
                    '</div>' +
                    '<div class="row">' +
                        '<div class="col"><span class="label">NF-e:</span> ' + ISNULL(CONVERT(VARCHAR(20), d.nr_nota), '') + '</div>' +
                        '<div class="col"><span class="label">Série:</span> ' + ISNULL(CONVERT(VARCHAR(10), d.nr_serie), '') + '</div>' +
                        '<div class="col"><span class="label">Emissão:</span> ' + ISNULL(CONVERT(VARCHAR(10), d.dt_nota_saida, 103), '') + '</div>' +
                    '</div>' +
                    '<div class="section"><span class="label">Transportadora:</span> ' + ISNULL(d.nm_transportadora, '') + ' (' + ISNULL(d.cnpj_transportadora, '') + ')</div>' +
                    '<div class="barcode">' + ISNULL(d.cd_identificacao_nota_saida, '') + '</div>' +
                    '<div class="signature">' +
                        '<span>Data de Recebimento</span>' +
                        '<span>Assinatura do Recebedor</span>' +
                    '</div>' +
                '</div>' +
                CASE
                    WHEN d.rn < d.total_registros THEN
                        '<div class="cut-line"><span class="cut-text">....................................................................................................................</span><span class="scissor">✂</span></div>'
                    ELSE
                        ''
                END
            FROM Dados AS d
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
