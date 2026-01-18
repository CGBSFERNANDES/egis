IF OBJECT_ID('dbo.pr_egis_etiqueta_volume_nota', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_etiqueta_volume_nota;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_etiqueta_volume_nota
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-01-XX
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : ChatGPT (OpenAI)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório 425 - Etiqueta de Volume (Nota Fiscal)
                     - Gera HTML (RelatorioHTML) de etiqueta de volume conforme qt_volume.
                     - Uma etiqueta por volume, exibindo os dados principais da nota.

  Parâmetro único de entrada (JSON):
    @json NVARCHAR(MAX)  --> [{"cd_nota_saida": <int>}]

  Requisitos Técnicos:
    - SET NOCOUNT ON
    - TRY...CATCH
    - Sem cursor (set-based)
    - Compatível com SQL Server 2016
    - Código comentado

  Fontes de dados de leitura:
    - vw_nfe_emitente_nota_fiscal (emitente)
    - vw_nfe_identificacao_nota_fiscal (identificação da nota)
    - vw_nfe_destintario_nota_fiscal (destinatário)
    - vw_nfe_transporte_nota_fiscal (transporte/volumes)
    - egisadmin.dbo.empresa (dados da empresa)
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_etiqueta_volume_nota
    @json NVARCHAR(MAX) = '' -- Parâmetro único vindo do front-end
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

        --select @jsonNormalized

        -- Aceita objeto isolado e converte para array
        --IF JSON_VALUE(@jsonNormalized, '$[0]') IS NULL
        --    SET @jsonNormalized = CONCAT('[', @jsonNormalized, ']');

        --select @jsonNormalized

        /*-----------------------------------------------------------------------------------------
          2) Carrega parâmetros em tabela (sem cursor)
        -----------------------------------------------------------------------------------------*/
        DECLARE @Parametros TABLE
        (
            cd_nota_saida INT NULL
        );

        INSERT INTO @Parametros (cd_nota_saida)
        SELECT
            TRY_CAST(j.cd_nota_saida AS INT) AS cd_nota_saida
        FROM OPENJSON(@jsonNormalized)
        WITH (
            cd_nota_saida INT '$.cd_nota_saida'
        ) AS j;

        IF NOT EXISTS (SELECT 1 FROM @Parametros)
            THROW 50002, 'Nenhum parâmetro informado em @json.', 1;

        --select * from @Parametros

        IF EXISTS (SELECT 1 FROM @Parametros WHERE cd_nota_saida IS NULL)
            THROW 50003, 'Parâmetro cd_nota_saida é obrigatório.', 1;

        /*-----------------------------------------------------------------------------------------
          3) Carrega dados principais da nota/empresa
        -----------------------------------------------------------------------------------------*/
        DECLARE @Volumes TABLE
        (
            cd_nota_saida INT NULL,
            cd_identificacao_nota_saida VARCHAR(60) NULL,
            nr_nota VARCHAR(20) NULL,
            nr_serie VARCHAR(10) NULL,
            nm_emitente VARCHAR(120) NULL,
            nm_fantasia_emitente VARCHAR(120) NULL,
            cnpj_emitente VARCHAR(20) NULL,
            ie_emitente VARCHAR(20) NULL,
            endereco_emitente VARCHAR(200) NULL,
            numero_emitente VARCHAR(20) NULL,
            bairro_emitente VARCHAR(100) NULL,
            cidade_emitente VARCHAR(100) NULL,
            uf_emitente VARCHAR(10) NULL,
            cep_emitente VARCHAR(15) NULL,
            nm_destinatario VARCHAR(120) NULL,
            nm_fantasia_destinatario VARCHAR(120) NULL,
            doc_destinatario VARCHAR(20) NULL,
            endereco_destinatario VARCHAR(200) NULL,
            numero_destinatario VARCHAR(20) NULL,
            bairro_destinatario VARCHAR(100) NULL,
            cidade_destinatario VARCHAR(100) NULL,
            uf_destinatario VARCHAR(10) NULL,
            cep_destinatario VARCHAR(15) NULL,
            nm_transportadora VARCHAR(120) NULL,
            cnpj_transportadora VARCHAR(20) NULL,
            cidade_transportadora VARCHAR(100) NULL,
            uf_transportadora VARCHAR(10) NULL,
            qt_volume INT NULL,
            especie_volume VARCHAR(60) NULL,
            peso_liquido VARCHAR(30) NULL,
            peso_bruto VARCHAR(30) NULL,
            nm_empresa VARCHAR(120) NULL,
            nm_fantasia_empresa VARCHAR(120) NULL,
            cd_cgc_empresa VARCHAR(20) NULL,
            cd_ie_empresa VARCHAR(20) NULL,
            nm_endereco_empresa VARCHAR(200) NULL,
            cd_numero VARCHAR(20) NULL,
            nm_bairro_empresa VARCHAR(100) NULL,
            nm_cidade_empresa VARCHAR(100) NULL,
            sg_estado_empresa VARCHAR(10) NULL,
            cd_cep_empresa VARCHAR(15) NULL,
            cd_telefone_empresa VARCHAR(30) NULL,
            qt_volume_normalizado INT NOT NULL,
            nr_volume INT NOT NULL
        );

        ;WITH Base AS
        (
            SELECT
                p.cd_nota_saida,
                ident.cd_identificacao_nota_saida,
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
                TRY_CAST(transp.qVol AS INT) AS qt_volume,
                transp.esp AS especie_volume,
                transp.pesoL AS peso_liquido,
                transp.pesoB AS peso_bruto,
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
            FROM @Parametros AS p
            OUTER APPLY (
                SELECT TOP (1)
                    v.cd_identificacao_nota_saida,
                    v.nNF,
                    v.serie
                FROM vw_nfe_identificacao_nota_fiscal AS v
                WHERE v.cd_nota_saida = p.cd_nota_saida
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
                WHERE v.cd_nota_saida = p.cd_nota_saida
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
                WHERE d.cd_nota_saida = p.cd_nota_saida
                ORDER BY d.cd_identificacao_nota_saida
            ) AS dest
            OUTER APPLY (
                SELECT TOP (1)
                    t.xNome,
                    t.CNPJ,
                    t.xMun,
                    t.UF,
                    t.qVol,
                    t.esp,
                    t.pesoL,
                    t.pesoB
                FROM vw_nfe_transporte_nota_fiscal AS t
                WHERE t.cd_nota_saida = p.cd_nota_saida
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
        ),
        Tally AS
        (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
            FROM sys.all_objects
        )
        INSERT INTO @Volumes (
            cd_nota_saida,
            cd_identificacao_nota_saida,
            nr_nota,
            nr_serie,
            nm_emitente,
            nm_fantasia_emitente,
            cnpj_emitente,
            ie_emitente,
            endereco_emitente,
            numero_emitente,
            bairro_emitente,
            cidade_emitente,
            uf_emitente,
            cep_emitente,
            nm_destinatario,
            nm_fantasia_destinatario,
            doc_destinatario,
            endereco_destinatario,
            numero_destinatario,
            bairro_destinatario,
            cidade_destinatario,
            uf_destinatario,
            cep_destinatario,
            nm_transportadora,
            cnpj_transportadora,
            cidade_transportadora,
            uf_transportadora,
            qt_volume,
            especie_volume,
            peso_liquido,
            peso_bruto,
            nm_empresa,
            nm_fantasia_empresa,
            cd_cgc_empresa,
            cd_ie_empresa,
            nm_endereco_empresa,
            cd_numero,
            nm_bairro_empresa,
            nm_cidade_empresa,
            sg_estado_empresa,
            cd_cep_empresa,
            cd_telefone_empresa,
            qt_volume_normalizado,
            nr_volume
        )
        SELECT
            b.cd_nota_saida,
            b.cd_identificacao_nota_saida,
            b.nr_nota,
            b.nr_serie,
            b.nm_emitente,
            b.nm_fantasia_emitente,
            b.cnpj_emitente,
            b.ie_emitente,
            b.endereco_emitente,
            b.numero_emitente,
            b.bairro_emitente,
            b.cidade_emitente,
            b.uf_emitente,
            b.cep_emitente,
            b.nm_destinatario,
            b.nm_fantasia_destinatario,
            b.doc_destinatario,
            b.endereco_destinatario,
            b.numero_destinatario,
            b.bairro_destinatario,
            b.cidade_destinatario,
            b.uf_destinatario,
            b.cep_destinatario,
            b.nm_transportadora,
            b.cnpj_transportadora,
            b.cidade_transportadora,
            b.uf_transportadora,
            b.qt_volume,
            b.especie_volume,
            b.peso_liquido,
            b.peso_bruto,
            b.nm_empresa,
            b.nm_fantasia_empresa,
            b.cd_cgc_empresa,
            b.cd_ie_empresa,
            b.nm_endereco_empresa,
            b.cd_numero,
            b.nm_bairro_empresa,
            b.nm_cidade_empresa,
            b.sg_estado_empresa,
            b.cd_cep_empresa,
            b.cd_telefone_empresa,
            CASE WHEN ISNULL(b.qt_volume, 0) <= 0 THEN 1 ELSE b.qt_volume END AS qt_volume_normalizado,
            t.n AS nr_volume
        FROM Base AS b
        JOIN Tally AS t
          ON t.n <= CASE WHEN ISNULL(b.qt_volume, 0) <= 0 THEN 1 ELSE b.qt_volume END;
        /*-----------------------------------------------------------------------------------------
          4) Validação de existência de dados
        -----------------------------------------------------------------------------------------*/
        IF NOT EXISTS (SELECT 1 FROM @Volumes)
            THROW 50004, 'Nenhum dado encontrado para a nota informada.', 1;

        /*-----------------------------------------------------------------------------------------
          5) Monta HTML de saída (RelatorioHTML)
        -----------------------------------------------------------------------------------------*/
        DECLARE @html NVARCHAR(MAX) = N'';
        DECLARE @style NVARCHAR(MAX) =
N'<style>
    body { font-family: ''Segoe UI'', Arial, sans-serif; color: #222; margin: 0; padding: 0; }
    .label { border: 1px solid #444; padding: 10px 12px; margin-bottom: 8px; box-sizing: border-box; }
    .header { display: flex; justify-content: space-between; align-items: center; font-size: 12px; }
    .title { font-size: 16px; font-weight: 700; margin: 6px 0; }
    .section { font-size: 12px; margin-bottom: 6px; }
    .section strong { display: inline-block; min-width: 90px; }
    .barcode { font-size: 14px; letter-spacing: 2px; font-weight: 600; text-align: center; margin-top: 6px; }
    .volume { font-size: 13px; font-weight: 700; text-align: right; }
</style>';

        SET @html = @style;

        SET @html = @html +
        (
            SELECT
                '<div class="label">' +
                    '<div class="header">' +
                        '<div>' +
                            '<div><strong>Empresa:</strong> ' + ISNULL(v.nm_empresa, '') + '</div>' +
                            '<div><strong>Fantasia:</strong> ' + ISNULL(v.nm_fantasia_empresa, '') + '</div>' +
                            '<div><strong>CNPJ:</strong> ' + ISNULL(v.cd_cgc_empresa, '') + '</div>' +
                        '</div>' +
                        '<div class="volume">Volume ' + CONVERT(VARCHAR(10), v.nr_volume) + ' / ' + CONVERT(VARCHAR(10), v.qt_volume_normalizado) + '</div>' +
                    '</div>' +
                    '<div class="title">Etiqueta de Volume - NF-e</div>' +
                    '<div class="section"><strong>Emitente:</strong> ' + ISNULL(v.nm_emitente, '') + '</div>' +
                    '<div class="section"><strong>Destinatário:</strong> ' + ISNULL(v.nm_destinatario, '') + '</div>' +
                    '<div class="section"><strong>Transportadora:</strong> ' + ISNULL(v.nm_transportadora, '') + '</div>' +
                    '<div class="section"><strong>Nota:</strong> ' + ISNULL(CONVERT(VARCHAR(20), v.nr_nota), '') + ' Série ' + ISNULL(CONVERT(VARCHAR(10), v.nr_serie), '') + '</div>' +
                    '<div class="section"><strong>Espécie:</strong> ' + ISNULL(v.especie_volume, '') + ' <strong>Peso:</strong> ' + ISNULL(CONVERT(VARCHAR(20), v.peso_liquido), '') + '</div>' +
                    '<div class="section"><strong>NFe:</strong> ' + ISNULL(v.cd_identificacao_nota_saida, '') + '</div>' +
                    '<div class="barcode">' + ISNULL(v.cd_identificacao_nota_saida, '') + '</div>' +
                '</div>'
            FROM @Volumes AS v
            ORDER BY v.cd_nota_saida, v.nr_volume
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)');

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

--select * from nota_saida

exec pr_egis_etiqueta_volume_nota '[{"cd_nota_saida": 553}]'

----------------