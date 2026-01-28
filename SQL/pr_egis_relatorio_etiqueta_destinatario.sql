IF OBJECT_ID('dbo.pr_egis_relatorio_etiqueta_destinatario', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_etiqueta_destinatario;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_etiqueta_destinatario
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-01-XX
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : ChatGPT (OpenAI)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório 416 - Etiqueta do Destinatário
                     - Gera HTML (RelatorioHTML) pronto para impressão em impressora térmica
                       no formato padrão 10cm x 15cm (ajustável).
                     - Aceita emissão sem cd_nota_saida (apenas remetente padrão) ou vinculada
                       à nota para preencher dados do destinatário.

  Parâmetro único de entrada (JSON):
    @json NVARCHAR(MAX)  --> [{"cd_nota_saida": <int|null>, "qt_copia": <int>, 
                               "largura_cm": <decimal>, "altura_cm": <decimal>}]
      * qt_copia: padrão 1; mínimo 1; máximo 10
      * largura_cm / altura_cm: padrão 10 x 15; ignora valores <= 0

  Requisitos Técnicos:
    - SET NOCOUNT ON
    - TRY...CATCH
    - Sem cursor; abordagem set-based
    - Compatível com SQL Server 2016
    - Código comentado e preparado para alto volume

  Fontes de dados de leitura:
    - vw_nfe_destintario_nota_fiscal (dados do destinatário)
    - vw_nfe_emitente_nota_fiscal (dados do remetente por nota)
    - nota_saida (data da nota)
    - egisadmin.dbo.empresa / Cidade / Estado (fallback de remetente quando não houver nota)
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_etiqueta_destinatario
    @json NVARCHAR(MAX) -- Parâmetro único vindo do front-end
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Constantes e variáveis de trabalho
        -----------------------------------------------------------------------------------------*/
        DECLARE
            @cd_relatorio       INT            = 416,
            @jsonNormalized     NVARCHAR(MAX),
            @html               NVARCHAR(MAX) = N'',
            @largura_padrao_cm  DECIMAL(10, 2) = 10.0,
            @altura_padrao_cm   DECIMAL(10, 2) = 15.0,
            @qt_copia_padrao    INT            = 1,
            @qt_copia_limite    INT            = 10;

        /*-----------------------------------------------------------------------------------------
          2) Normaliza e valida JSON de entrada (aceita objeto ou array)
        -----------------------------------------------------------------------------------------*/
        SET @jsonNormalized = LTRIM(RTRIM(ISNULL(@json, N'')));

        IF @jsonNormalized = N''
            SET @jsonNormalized = N'[{}]';

        IF ISJSON(@jsonNormalized) = 0
            THROW 50001, 'JSON de entrada inválido ou mal formatado.', 1;

        -- Aceita objeto isolado e converte para array
        IF JSON_VALUE(@jsonNormalized, '$[0]') IS NULL
            SET @jsonNormalized = CONCAT('[', @jsonNormalized, ']');

        /*-----------------------------------------------------------------------------------------
          3) Carrega parâmetros em tabela (sem cursor) e aplica defaults/limites
        -----------------------------------------------------------------------------------------*/
        DECLARE @Parametros TABLE
        (
            cd_nota_saida INT           NULL,
            qt_copia      INT           NULL,
            largura_cm    DECIMAL(10,2) NULL,
            altura_cm     DECIMAL(10,2) NULL
        );

        INSERT INTO @Parametros (cd_nota_saida, qt_copia, largura_cm, altura_cm)
        SELECT
            TRY_CAST(j.cd_nota_saida AS INT)       AS cd_nota_saida,
            TRY_CAST(j.qt_copia AS INT)            AS qt_copia,
            TRY_CAST(j.largura_cm AS DECIMAL(10,2)) AS largura_cm,
            TRY_CAST(j.altura_cm AS DECIMAL(10,2))  AS altura_cm
        FROM OPENJSON(@jsonNormalized)
        WITH (
            cd_nota_saida INT            '$.cd_nota_saida',
            qt_copia      INT            '$.qt_copia',
            largura_cm    DECIMAL(10,2)  '$.largura_cm',
            altura_cm     DECIMAL(10,2)  '$.altura_cm'
        ) AS j;

        IF NOT EXISTS (SELECT 1 FROM @Parametros)
            INSERT INTO @Parametros (cd_nota_saida, qt_copia, largura_cm, altura_cm)
            VALUES (NULL, NULL, NULL, NULL);

        UPDATE p
        SET
            qt_copia = CASE
                           WHEN p.qt_copia IS NULL OR p.qt_copia <= 0 THEN @qt_copia_padrao
                           WHEN p.qt_copia > @qt_copia_limite THEN @qt_copia_limite
                           ELSE p.qt_copia
                       END,
            largura_cm = CASE WHEN p.largura_cm IS NULL OR p.largura_cm <= 0 THEN @largura_padrao_cm ELSE p.largura_cm END,
            altura_cm  = CASE WHEN p.altura_cm IS NULL OR p.altura_cm <= 0 THEN @altura_padrao_cm ELSE p.altura_cm END
        FROM @Parametros AS p;

        /*-----------------------------------------------------------------------------------------
          4) Monta base com cópias e dados (sem cursor)
             - Quando não houver nota, usa remetente padrão para preencher etiqueta em branco
        -----------------------------------------------------------------------------------------*/
        ;WITH Copias AS (
            SELECT
                p.cd_nota_saida,
                p.largura_cm,
                p.altura_cm,
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS id_solicitacao,
                c.copia_id
            FROM @Parametros AS p
            CROSS APPLY (
                SELECT TOP (p.qt_copia) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS copia_id
                FROM sys.objects AS so
            ) AS c
        ),
        Dados AS (
            SELECT
                c.id_solicitacao,
                c.copia_id,
                c.cd_nota_saida,
                c.largura_cm,
                c.altura_cm,
                ns.dt_nota_saida,
                -- Dados do destinatário pela nota (se existir)
                vd.xNome     AS nm_destinatario,
                vd.xFant     AS nm_fantasia_destinatario,
                COALESCE(NULLIF(vd.CNPJ2, ''), NULLIF(vd.CPF, '')) AS doc_destinatario,
                vd.xLgr      AS logradouro_destinatario,
                vd.xCpl      AS complemento_destinatario,
                vd.nro       AS numero_destinatario,
                vd.xBairro   AS bairro_destinatario,
                vd.xMun      AS cidade_destinatario,
                vd.UF        AS uf_destinatario,
                vd.CEP       AS cep_destinatario,
                vd.fone      AS fone_destinatario,
                -- Remetente associado à nota
                ve.xNome     AS nm_remetente,
                ve.xFant     AS nm_fantasia_remetente,
                ve.CNPJ      AS doc_remetente,
                ve.IE        AS ie_remetente,
                ve.xLgr      AS logradouro_remetente,
                ve.xCpl      AS complemento_remetente,
                ve.nro       AS numero_remetente,
                ve.xBairro   AS bairro_remetente,
                ve.xMun      AS cidade_remetente,
                ve.UF        AS uf_remetente,
                ve.CEP       AS cep_remetente,
                ve.fone      AS fone_remetente,
                -- Fallback remetente (empresa padrão)
                emp.nm_empresa,
                emp.nm_fantasia_empresa,
                emp.cd_cgc_empresa,
                emp.cd_ie_empresa,
                emp.nm_endereco_empresa,
                emp.nm_complemento,
                emp.cd_numero,
                emp.nm_bairro_empresa,
                emp.nm_cidade_empresa,
                emp.sg_estado_empresa,
                emp.cd_cep_empresa,
                emp.cd_telefone_empresa
            FROM Copias AS c
            LEFT JOIN nota_saida AS ns WITH (NOLOCK) ON ns.cd_nota_saida = c.cd_nota_saida
            OUTER APPLY (
                SELECT TOP (1)
                    v.xNome,
                    v.xFant,
                    v.CNPJ,
                    v.IE,
                    v.xLgr,
                    v.xCpl,
                    v.nro,
                    v.xBairro,
                    v.xMun,
                    v.UF,
                    v.CEP,
                    v.fone
                FROM vw_nfe_emitente_nota_fiscal AS v
                WHERE v.cd_nota_saida = c.cd_nota_saida
                ORDER BY v.cd_identificacao_nota_saida
            ) AS ve
            OUTER APPLY (
                SELECT TOP (1)
                    d.xNome,
                    d.xFant,
                    d.CNPJ2,
                    d.CPF,
                    d.xLgr,
                    d.xCpl,
                    d.nro,
                    d.xBairro,
                    d.xMun,
                    d.UF,
                    d.CEP,
                    d.fone
                FROM vw_nfe_destintario_nota_fiscal AS d
                WHERE d.cd_nota_saida = c.cd_nota_saida
                ORDER BY d.cd_identificacao_nota_saida
            ) AS vd
            OUTER APPLY (
                SELECT TOP (1)
                    e.nm_empresa,
                    e.nm_fantasia_empresa,
                    e.cd_cgc_empresa,
                    e.cd_iest_empresa AS cd_ie_empresa,
                    e.nm_endereco_empresa,
                    e.nm_complemento_endereco AS nm_complemento,
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
        ),
        Normalizado AS (
            SELECT
                d.id_solicitacao,
                d.copia_id,
                d.cd_nota_saida,
                d.largura_cm,
                d.altura_cm,
                d.dt_nota_saida,
                -- Destinatário
                COALESCE(NULLIF(d.nm_destinatario, ''), NULLIF(d.nm_fantasia_destinatario, '')) AS nm_destinatario,
                COALESCE(NULLIF(d.doc_destinatario, ''), '') AS doc_destinatario,
                COALESCE(NULLIF(d.logradouro_destinatario, ''), '') AS logradouro_destinatario,
                COALESCE(NULLIF(d.complemento_destinatario, ''), '') AS complemento_destinatario,
                COALESCE(NULLIF(d.numero_destinatario, ''), '') AS numero_destinatario,
                COALESCE(NULLIF(d.bairro_destinatario, ''), '') AS bairro_destinatario,
                COALESCE(NULLIF(d.cidade_destinatario, ''), '') AS cidade_destinatario,
                COALESCE(NULLIF(d.uf_destinatario, ''), '') AS uf_destinatario,
                COALESCE(NULLIF(d.cep_destinatario, ''), '') AS cep_destinatario,
                COALESCE(NULLIF(d.fone_destinatario, ''), '') AS fone_destinatario,
                -- Remetente (prioriza dados da nota; usa fallback)
                COALESCE(NULLIF(d.nm_remetente, ''), NULLIF(d.nm_fantasia_remetente, ''), d.nm_empresa, d.nm_fantasia_empresa, '') AS nm_remetente,
                COALESCE(NULLIF(d.doc_remetente, ''), d.cd_cgc_empresa, '') AS doc_remetente,
                COALESCE(NULLIF(d.ie_remetente, ''), d.cd_ie_empresa, '') AS ie_remetente,
                COALESCE(NULLIF(d.logradouro_remetente, ''), d.nm_endereco_empresa, '') AS logradouro_remetente,
                COALESCE(NULLIF(d.complemento_remetente, ''), d.nm_complemento, '') AS complemento_remetente,
                COALESCE(NULLIF(d.numero_remetente, ''), d.cd_numero, '') AS numero_remetente,
                COALESCE(NULLIF(d.bairro_remetente, ''), d.nm_bairro_empresa, '') AS bairro_remetente,
                COALESCE(NULLIF(d.cidade_remetente, ''), d.nm_cidade_empresa, '') AS cidade_remetente,
                COALESCE(NULLIF(d.uf_remetente, ''), d.sg_estado_empresa, '') AS uf_remetente,
                COALESCE(NULLIF(d.cep_remetente, ''), d.cd_cep_empresa, '') AS cep_remetente,
                COALESCE(NULLIF(d.fone_remetente, ''), d.cd_telefone_empresa, '') AS fone_remetente
            FROM Dados AS d
        ),
        Escapado AS (
            SELECT
                n.*,
                -- Escapa caracteres básicos para HTML
                REPLACE(REPLACE(REPLACE(ISNULL(n.nm_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS nm_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.doc_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS doc_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.logradouro_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS logradouro_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.complemento_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS complemento_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.numero_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS numero_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.bairro_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS bairro_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.cidade_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS cidade_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.uf_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS uf_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.cep_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS cep_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.fone_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS fone_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.nm_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS nm_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.doc_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS doc_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.ie_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS ie_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.logradouro_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS logradouro_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.complemento_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS complemento_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.numero_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS numero_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.bairro_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS bairro_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.cidade_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS cidade_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.uf_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS uf_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.cep_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS cep_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.fone_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS fone_remetente_html
            FROM Normalizado AS n
        ),
        HtmlEtiquetas AS (
            SELECT
                e.id_solicitacao,
                e.copia_id,
                e.cd_nota_saida,
                -- Monta HTML de cada etiqueta usando FOR XML (compatível com SQL 2016)
                '<div class=\"label\" style=\"width:' + CONVERT(VARCHAR(20), CAST(e.largura_cm AS DECIMAL(10,2))) + 'cm;height:' +
                CONVERT(VARCHAR(20), CAST(e.altura_cm AS DECIMAL(10,2))) + 'cm;\">' +
                '  <div class=\"header\">' +
                '    <div class=\"title\">Destinatário</div>' +
                '    <div class=\"meta\">Relatório ' + CAST(@cd_relatorio AS VARCHAR(10)) +
                CASE WHEN e.cd_nota_saida IS NULL THEN '' ELSE ' · Nota ' + CAST(e.cd_nota_saida AS VARCHAR(20)) END +
                ' · Cópia ' + CAST(e.copia_id AS VARCHAR(10)) + '</div>' +
                '  </div>' +
                '  <div class=\"destinatario\">' +
                '    <div class=\"linha destaque\">' + ISNULL(NULLIF(e.nm_destinatario_html, ''), '') + '</div>' +
                '    <div class=\"linha\">' + CASE WHEN NULLIF(e.doc_destinatario_html, '') IS NULL THEN '' ELSE 'Doc.: ' + e.doc_destinatario_html END + '</div>' +
                '    <div class=\"linha\">' + ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(e.logradouro_destinatario_html,' ', e.numero_destinatario_html,
                                                                        CASE WHEN NULLIF(e.complemento_destinatario_html, '') IS NULL THEN '' ELSE ' - ' + e.complemento_destinatario_html END))), ''), '') + '</div>' +
                '    <div class=\"linha\">' + ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(e.bairro_destinatario_html,
                                                                        CASE WHEN NULLIF(e.bairro_destinatario_html, '') IS NULL THEN '' ELSE ' - ' END,
                                                                        e.cidade_destinatario_html,
                                                                        CASE WHEN NULLIF(e.uf_destinatario_html, '') IS NULL THEN '' ELSE '/' + e.uf_destinatario_html END))), ''), '') + '</div>' +
                '    <div class=\"linha\">' + CASE WHEN NULLIF(e.cep_destinatario_html, '') IS NULL THEN '' ELSE 'CEP: ' + e.cep_destinatario_html END + '</div>' +
                '    <div class=\"linha\">' + CASE WHEN NULLIF(e.fone_destinatario_html, '') IS NULL THEN '' ELSE 'Fone: ' + e.fone_destinatario_html END + '</div>' +
                '  </div>' +
                '  <div class=\"remetente\">' +
                '    <div class=\"label-remetente\">Remetente</div>' +
                '    <div class=\"linha\">' + ISNULL(NULLIF(e.nm_remetente_html, ''), '') + '</div>' +
                '    <div class=\"linha\">' + CASE WHEN NULLIF(e.doc_remetente_html, '') IS NULL THEN '' ELSE 'CNPJ: ' + e.doc_remetente_html END + '</div>' +
                '    <div class=\"linha\">' + CASE WHEN NULLIF(e.ie_remetente_html, '') IS NULL THEN '' ELSE 'IE: ' + e.ie_remetente_html END + '</div>' +
                '    <div class=\"linha\">' + ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(e.logradouro_remetente_html,' ', e.numero_remetente_html,
                                                                        CASE WHEN NULLIF(e.complemento_remetente_html, '') IS NULL THEN '' ELSE ' - ' + e.complemento_remetente_html END))), ''), '') + '</div>' +
                '    <div class=\"linha\">' + ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(e.bairro_remetente_html,
                                                                        CASE WHEN NULLIF(e.bairro_remetente_html, '') IS NULL THEN '' ELSE ' - ' END,
                                                                        e.cidade_remetente_html,
                                                                        CASE WHEN NULLIF(e.uf_remetente_html, '') IS NULL THEN '' ELSE '/' + e.uf_remetente_html END))), ''), '') + '</div>' +
                '    <div class=\"linha\">' + CASE WHEN NULLIF(e.cep_remetente_html, '') IS NULL THEN '' ELSE 'CEP: ' + e.cep_remetente_html END + '</div>' +
                '    <div class=\"linha\">' + CASE WHEN NULLIF(e.fone_remetente_html, '') IS NULL THEN '' ELSE 'Fone: ' + e.fone_remetente_html END + '</div>' +
                '    <div class=\"linha pequeno\">' + ISNULL('Data da Nota: ' + CONVERT(VARCHAR(10), e.dt_nota_saida, 103), 'Sem data da nota') + '</div>' +
                '  </div>' +
                '</div>'
            FROM Escapado AS e
        )
        /*-----------------------------------------------------------------------------------------
          5) Consolida HTML final
        -----------------------------------------------------------------------------------------*/
        DECLARE @style NVARCHAR(MAX) =
N'<style>
    * { box-sizing: border-box; }
    body { margin: 0; padding: 0; font-family: ''Segoe UI'', Arial, sans-serif; color: #1f1f1f; }
    .labels { display: flex; flex-wrap: wrap; gap: 8px; }
    .label { border: 1px solid #444; padding: 12px; position: relative; overflow: hidden; }
    .header { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 8px; }
    .title { font-size: 14px; font-weight: 700; letter-spacing: 0.5px; text-transform: uppercase; }
    .meta { font-size: 11px; color: #444; }
    .destinatario, .remetente { margin-bottom: 8px; }
    .destinatario { border-top: 2px solid #000; padding-top: 6px; }
    .remetente { border-top: 1px dashed #777; padding-top: 6px; }
    .label-remetente { font-size: 12px; font-weight: 600; margin-bottom: 2px; text-transform: uppercase; }
    .linha { font-size: 12px; line-height: 1.25; }
    .linha.destaque { font-size: 14px; font-weight: 700; margin-bottom: 2px; }
    .pequeno { font-size: 11px; color: #555; }
</style>';

        SET @html = @style + N'<div class="labels">';

        SET @html = @html +
        (
            SELECT h.*
            FROM HtmlEtiquetas AS h
            ORDER BY h.id_solicitacao, h.copia_id
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)');

        SET @html = @html + N'</div>';

        SELECT ISNULL(@html, N'') AS RelatorioHTML;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, @ErrorMessage, 1;
    END CATCH;
END;
