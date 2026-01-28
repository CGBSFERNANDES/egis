IF OBJECT_ID('dbo.pr_egis_relatorio_etiqueta_remetente', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_etiqueta_remetente;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_etiqueta_remetente
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2025-01-XX
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Gerar o HTML da Etiqueta do Remetente (cd_relatorio = 417)

  Requisitos / Regras de Negócio
    - Apenas 1 parâmetro de entrada: @json NVARCHAR(MAX)
    - Formato esperado do JSON: [{"cd_nota_saida": <int>, "qt_copia": <int>}]
      * qt_copia opcional (padrão = 1; limite de segurança = 10)
      * Permite ajustar o tamanho da etiqueta via "largura_cm" e "altura_cm" no JSON
    - Quando não houver cd_nota_saida informado, imprime etiqueta apenas com dados do remetente
    - 1ª etiqueta: dados do destinatário + remetente
    - 2ª etiqueta: imagem do Sedex (modelo fornecido)
    - Retorno obrigatório: coluna única RelatorioHTML com o HTML completo

  Requisitos Técnicos
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Compatível com SQL Server 2016
    - Código comentado e voltado para performance (set-based)

  Fontes de Dados utilizadas (leitura)
    - vw_nfe_emitente_nota_fiscal (dados do remetente por nota)
    - vw_nfe_destintario_nota_fiscal (dados do destinatário por nota)
    - nota_saida (data e identificação)
    - egisadmin.dbo.empresa / Cidade / Estado (fallback de remetente)
-------------------------------------------------------------------------------------------------*/
CREATE or alter PROCEDURE pr_egis_relatorio_etiqueta_remetente
    @json NVARCHAR(MAX) = ''-- Parâmetro único vindo do front-end
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Variáveis e defaults
        -----------------------------------------------------------------------------------------*/
        DECLARE
            @cd_relatorio        INT           = 417,
            @html                NVARCHAR(MAX) = N'',
            @jsonNormalized      NVARCHAR(MAX) = NULL,
            @largura_padrao_cm   DECIMAL(10, 2) = 10.0, -- largura padrão da etiqueta
            @altura_padrao_cm    DECIMAL(10, 2) = 15.0, -- altura padrão da etiqueta
            @qt_copia_padrao     INT           = 1,
            @qt_copia_limite     INT           = 10,
            @img_modelo_destino  NVARCHAR(500) = N'https://github.com/user-attachments/assets/6c30548e-8258-443a-9ae4-bb672dda493a',
            @img_modelo_sedex    NVARCHAR(500) = N'https://github.com/user-attachments/assets/5675961f-8af4-453b-96d8-369289d7d22b',
			@cd_empresa          int = 0,
			@cd_nota_saida       int = 0
        /*-----------------------------------------------------------------------------------------
          2) Normaliza JSON (aceita objeto ou array)
        -----------------------------------------------------------------------------------------*/
     
        /*-----------------------------------------------------------------------------------------    
          1.a) Validação mínima do JSON    
        -----------------------------------------------------------------------------------------*/    
        IF NULLIF(LTRIM(RTRIM(@json)), N'') IS NOT NULL AND ISJSON(@json) = 0    
            THROW 50001, 'Payload JSON inválido em @json.', 1;    
    
        /*-----------------------------------------------------------------------------------------    
          2) Normaliza JSON e parse de datas com múltiplos formatos    
        -----------------------------------------------------------------------------------------*/    
        IF NULLIF(LTRIM(RTRIM(@json)), N'') IS NOT NULL AND ISJSON(@json) = 1    
        BEGIN    
            -- Se vier como array, pegar primeiro elemento    
            IF LEFT(LTRIM(@json), 1) = '['    
                SET @json = JSON_QUERY(@json, '$[0]');    
    
   
			
            SET @cd_empresa = TRY_CAST(JSON_VALUE(@json, '$.cd_empresa') AS INT);
			SET @cd_nota_saida = TRY_CAST(
        NULLIF(JSON_VALUE(@json, '$.cd_identificacao_nota_saida'), '')
        AS INT
    );
            -- ==================================================================    
            -- PARSE DATA INICIAL - Suporta múltiplos formatos    
            -- ==================================================================    
           
    end
	--set @cd_nota_saida = 13752
        /*-----------------------------------------------------------------------------------------    
          3) Datas padrão: tenta Parametro_Relatorio e cai no mês corrente    
        -----------------------------------------------------------------------------------------*/    
     
   -- select  @json
        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa()); 
		
        /*-----------------------------------------------------------------------------------------
          3) Carrega solicitações (sem cursor) e aplica defaults/limites
        -----------------------------------------------------------------------------------------*/
        DECLARE @Solicitacoes TABLE
        (
            cd_nota_saida INT         NULL,
            qt_copia      INT         NULL,
            largura_cm    DECIMAL(10, 2) NULL,
            altura_cm     DECIMAL(10, 2) NULL
        );

        INSERT INTO @Solicitacoes (cd_nota_saida, qt_copia, largura_cm, altura_cm)
        SELECT
            TRY_CAST(j.cd_nota_saida AS INT)      AS cd_nota_saida,
            TRY_CAST(j.qt_copia AS INT)           AS qt_copia,
            TRY_CAST(j.largura_cm AS DECIMAL(10,2)) AS largura_cm,
            TRY_CAST(j.altura_cm AS DECIMAL(10,2))  AS altura_cm
        FROM OPENJSON(@json)
        WITH (
            cd_nota_saida INT           '$.cd_identificacao_nota_saida',
            qt_copia      INT           '$.qt_copia',
            largura_cm    DECIMAL(10,2) '$.largura_cm',
            altura_cm     DECIMAL(10,2) '$.altura_cm'
        ) AS j;
		     IF NOT EXISTS (SELECT 1 FROM @Solicitacoes)
            INSERT INTO @Solicitacoes (cd_nota_saida, qt_copia, largura_cm, altura_cm)
            VALUES (NULL, NULL, NULL, NULL);

        UPDATE s
        SET
            qt_copia  = CASE
                            WHEN s.qt_copia IS NULL OR s.qt_copia <= 0 THEN @qt_copia_padrao
                            WHEN s.qt_copia > @qt_copia_limite THEN @qt_copia_limite
                            ELSE s.qt_copia
                        END,
            largura_cm = CASE
                            WHEN s.largura_cm IS NULL OR s.largura_cm <= 0 THEN @largura_padrao_cm
                            ELSE s.largura_cm
                         END,
            altura_cm  = CASE
                            WHEN s.altura_cm IS NULL OR s.altura_cm <= 0 THEN @altura_padrao_cm
                            ELSE s.altura_cm
                         END
        FROM @Solicitacoes AS s;
		
        /*-----------------------------------------------------------------------------------------
          4) Conjunto base com cópias (evita cursor) + dados de remetente/destinatário
        -----------------------------------------------------------------------------------------*/
        ;WITH Copias AS (
            SELECT
                s.cd_nota_saida,
                s.largura_cm,
                s.altura_cm,
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS id_solicitacao,
                c.copia_id
            FROM @Solicitacoes AS s
            CROSS APPLY (
                SELECT TOP (s.qt_copia) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS copia_id
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
                em.xNome       AS nm_remetente,
                em.xFant       AS nm_fantasia_remetente,
                em.CNPJ        AS doc_remetente,
                em.IE          AS ie_remetente,
                em.xLgr        AS logradouro_remetente,
                em.xCpl        AS complemento_remetente,
                em.nro         AS numero_remetente,
                em.xBairro     AS bairro_remetente,
                em.xMun        AS cidade_remetente,
                em.UF          AS uf_remetente,
                em.CEP         AS cep_remetente,
                em.fone        AS fone_remetente,
                de.xNome       AS nm_destinatario,
                de.xFant       AS nm_fantasia_destinatario,
                COALESCE(NULLIF(de.CNPJ2, ''), NULLIF(de.CPF, '')) AS doc_destinatario,
                de.xLgr        AS logradouro_destinatario,
                de.xCpl        AS complemento_destinatario,
                de.nro         AS numero_destinatario,
                de.xBairro     AS bairro_destinatario,
                de.xMun        AS cidade_destinatario,
                de.UF          AS uf_destinatario,
                de.CEP         AS cep_destinatario,
                de.fone        AS fone_destinatario,
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
                    ve.xNome,
                    ve.xFant,
                    ve.CNPJ,
                    ve.IE,
                    ve.xLgr,
                    ve.xCpl,
                    ve.nro,
                    ve.xBairro,
                    ve.xMun,
                    ve.UF,
                    ve.CEP,
                    ve.fone
                FROM vw_nfe_emitente_nota_fiscal AS ve
                WHERE ve.cd_nota_saida = c.cd_nota_saida
                ORDER BY ve.cd_identificacao_nota_saida
            ) AS em
            OUTER APPLY (
                SELECT TOP (1)
                    vd.xNome,
                    vd.xFant,
                    vd.CNPJ2,
                    vd.CPF,
                    vd.xLgr,
                    vd.xCpl,
                    vd.nro,
                    vd.xBairro,
                    vd.xMun,
                    vd.UF,
                    vd.CEP,
                    vd.fone
                FROM vw_nfe_destintario_nota_fiscal AS vd
                WHERE vd.cd_nota_saida = c.cd_nota_saida
                ORDER BY vd.cd_identificacao_nota_saida
            ) AS de
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
                -- Remetente (usa fallback da empresa quando view não retornar)
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
                COALESCE(NULLIF(d.fone_remetente, ''), d.cd_telefone_empresa, '') AS fone_remetente,
                -- Destinatário (permite vazio quando não houver nota)
                COALESCE(NULLIF(d.nm_destinatario, ''), d.nm_fantasia_destinatario, '') AS nm_destinatario,
                COALESCE(NULLIF(d.doc_destinatario, ''), '') AS doc_destinatario,
                COALESCE(NULLIF(d.logradouro_destinatario, ''), '') AS logradouro_destinatario,
                COALESCE(NULLIF(d.complemento_destinatario, ''), '') AS complemento_destinatario,
                COALESCE(NULLIF(d.numero_destinatario, ''), '') AS numero_destinatario,
                COALESCE(NULLIF(d.bairro_destinatario, ''), '') AS bairro_destinatario,
                COALESCE(NULLIF(d.cidade_destinatario, ''), '') AS cidade_destinatario,
                COALESCE(NULLIF(d.uf_destinatario, ''), '') AS uf_destinatario,
                COALESCE(NULLIF(d.cep_destinatario, ''), '') AS cep_destinatario,
                COALESCE(NULLIF(d.fone_destinatario, ''), '') AS fone_destinatario
            FROM Dados AS d
        ),
        Escapado AS (
            SELECT
                n.*,
                -- Sanitiza caracteres especiais mínimos para HTML
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
                REPLACE(REPLACE(REPLACE(ISNULL(n.fone_remetente, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS fone_remetente_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.nm_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS nm_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.doc_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS doc_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.logradouro_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS logradouro_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.complemento_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS complemento_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.numero_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS numero_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.bairro_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS bairro_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.cidade_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS cidade_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.uf_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS uf_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.cep_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS cep_destinatario_html,
                REPLACE(REPLACE(REPLACE(ISNULL(n.fone_destinatario, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') AS fone_destinatario_html
            FROM Normalizado AS n
        ),
		

        HtmlPorEtiqueta AS (
            SELECT
                e.id_solicitacao,
                e.copia_id,
                e.cd_nota_saida,
                -- Monta a 1ª etiqueta (dados)
                '<div class="label-pair">' +
                '  <div class="label-card label-dados" style="width:' + CONVERT(VARCHAR(20), CAST(e.largura_cm AS DECIMAL(10,2))) + 'cm;height:' + CONVERT(VARCHAR(20), CAST(e.altura_cm AS DECIMAL(10,2))) + 'cm;">' +
                '    <div class="label-header">' +
                '      <div class="label-title">Etiqueta do Remetente</div>' +
                '      <div class="label-meta">Relatório ' + CAST(@cd_relatorio AS VARCHAR(10)) + ISNULL(' · Nota: ' + CAST(e.cd_nota_saida AS VARCHAR(20)), '') + ISNULL(' · Cópia ' + CAST(e.copia_id AS VARCHAR(10)), '') + '</div>' +
                '    </div>' +
                '    <div class="section bloco">' +
                '      <div class="section-title">Destinatário</div>' +
                '      <div class="linha forte">' + NULLIF(e.nm_destinatario_html, '') + '</div>' +
                '      <div class="linha">' + CASE WHEN NULLIF(e.doc_destinatario_html, '') IS NULL THEN '' ELSE 'Documento: ' + e.doc_destinatario_html END + '</div>' +
                '      <div class="linha">' + NULLIF(LTRIM(RTRIM(CONCAT(e.logradouro_destinatario_html,
                                                                       CASE WHEN NULLIF(e.numero_destinatario_html, '') IS NULL THEN '' ELSE ', ' + e.numero_destinatario_html END,
                                                                       CASE WHEN NULLIF(e.complemento_destinatario_html, '') IS NULL THEN '' ELSE ' - ' + e.complemento_destinatario_html END))), '') + '</div>' +
                '      <div class="linha">' + NULLIF(LTRIM(RTRIM(CONCAT(e.bairro_destinatario_html,
                                                                       CASE WHEN NULLIF(e.bairro_destinatario_html, '') IS NULL THEN '' ELSE ' - ' END,
                                                                       e.cidade_destinatario_html,
                                                                       CASE WHEN NULLIF(e.uf_destinatario_html, '') IS NULL THEN '' ELSE '/' + e.uf_destinatario_html END))), '') + '</div>' +
                '      <div class="linha">' + CASE WHEN NULLIF(e.cep_destinatario_html, '') IS NULL THEN '' ELSE 'CEP: ' + e.cep_destinatario_html END + '</div>' +
                '      <div class="linha">' + CASE WHEN NULLIF(e.fone_destinatario_html, '') IS NULL THEN '' ELSE 'Telefone: ' + e.fone_destinatario_html END + '</div>' +
                '    </div>' +
                '    <div class="section bloco">' +
                '      <div class="section-title">Remetente</div>' +
                '      <div class="linha forte">' + NULLIF(e.nm_remetente_html, '') + '</div>' +
                '      <div class="linha">' + CASE WHEN NULLIF(e.doc_remetente_html, '') IS NULL THEN '' ELSE 'CNPJ: ' + e.doc_remetente_html END + '</div>' +
                '      <div class="linha">' + CASE WHEN NULLIF(e.ie_remetente_html, '') IS NULL THEN '' ELSE 'IE: ' + e.ie_remetente_html END + '</div>' +
                '      <div class="linha">' + NULLIF(LTRIM(RTRIM(CONCAT(e.logradouro_remetente_html,
                                                                       CASE WHEN NULLIF(e.numero_remetente_html, '') IS NULL THEN '' ELSE ', ' + e.numero_remetente_html END,
                                                                       CASE WHEN NULLIF(e.complemento_remetente_html, '') IS NULL THEN '' ELSE ' - ' + e.complemento_remetente_html END))), '') + '</div>' +
                '      <div class="linha">' + NULLIF(LTRIM(RTRIM(CONCAT(e.bairro_remetente_html,
                                                                       CASE WHEN NULLIF(e.bairro_remetente_html, '') IS NULL THEN '' ELSE ' - ' END,
                                                                       e.cidade_remetente_html,
                                                                       CASE WHEN NULLIF(e.uf_remetente_html, '') IS NULL THEN '' ELSE '/' + e.uf_remetente_html END))), '') + '</div>' +
                '      <div class="linha">' + CASE WHEN NULLIF(e.cep_remetente_html, '') IS NULL THEN '' ELSE 'CEP: ' + e.cep_remetente_html END + '</div>' +
                '      <div class="linha">' + CASE WHEN NULLIF(e.fone_remetente_html, '') IS NULL THEN '' ELSE 'Telefone: ' + e.fone_remetente_html END + '</div>' +
                '      <div class="linha pequeno">' + ISNULL('Data da Nota: ' + CONVERT(VARCHAR(10), e.dt_nota_saida, 103), 'Sem data informada') + '</div>' +
                '    </div>' +
                '  </div>' +
                -- 2ª etiqueta (imagem Sedex)
                '  <div class="label-card label-sedex" style="width:' + CONVERT(VARCHAR(20), CAST(e.largura_cm AS DECIMAL(10,2))) + 'cm;height:' + CONVERT(VARCHAR(20), CAST(e.altura_cm AS DECIMAL(10,2))) + 'cm;">' +
                '    <img src="' + @img_modelo_sedex + '" alt="Etiqueta Sedex" />' +
                '  </div>' +
                '</div></body>' +    
            '</html>'
                AS html_parte
            FROM Escapado AS e
        )
        SELECT @html = '
		 <html>   
         <head>   
         <meta charset="UTF-8">   
         <title>Etiqueta Remetente</title> 
<style>
  :root {
    --label-font: "Arial", sans-serif;
    --label-color: #000;
  }
  body { margin: 0; padding: 0; font-family: var(--label-font); color: var(--label-color); }
  .label-pair { display: flex; gap: 8px; margin-bottom: 12px; page-break-inside: avoid; }
  .label-card { box-sizing: border-box; border: 1px solid #000; padding: 10px; font-size: 12px; position: relative; }
  .label-dados { display: flex; flex-direction: column; justify-content: space-between; }
  .label-sedex img { width: 100%; height: 100%; object-fit: contain; }
  .label-header { margin-bottom: 6px; }
  .label-title { font-size: 16px; font-weight: bold; letter-spacing: 0.5px; }
  .label-meta { font-size: 11px; color: #333; }
  .section { margin-top: 6px; }
  .section-title { font-weight: bold; text-transform: uppercase; margin-bottom: 4px; }
  .bloco { border-top: 1px solid #000; padding-top: 6px; }
  .linha { line-height: 1.3; }
  .linha.forte { font-size: 14px; font-weight: bold; }
  .linha.pequeno { font-size: 11px; color: #444; }
  @media print { .label-pair { page-break-inside: avoid; } }
</style>
</head>    
            <body>' 
+
        (
            SELECT hp.html_parte
            FROM HtmlPorEtiqueta AS hp
            ORDER BY hp.id_solicitacao, hp.copia_id
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)');

        IF NULLIF(@html, N'') IS NULL
            SET @html = '<div style="font-family: Arial, sans-serif; font-size: 14px;">Nenhum dado encontrado para gerar as etiquetas do relatório ' + CAST(@cd_relatorio AS VARCHAR(10)) + '.</div>';

        /*-----------------------------------------------------------------------------------------
          5) Retorno único
        -----------------------------------------------------------------------------------------*/
        SELECT ISNULL(@html, N'') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @erro NVARCHAR(2048) = CONCAT('pr_egis_relatorio_etiqueta_remetente falhou: ', ERROR_MESSAGE());
        THROW 51000, @erro, 1;
    END CATCH
END
GO
--exec pr_egis_relatorio_etiqueta_remetente '[{"cd_nota_saida":13752}]'

