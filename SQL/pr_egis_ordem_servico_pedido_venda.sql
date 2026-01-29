IF OBJECT_ID('dbo.pr_egis_ordem_servico_pedido_venda', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_ordem_servico_pedido_venda;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_ordem_servico_pedido_venda
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-05
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Gerar o relatório HTML da Ordem de Serviço por Pedido (cd_relatorio = 436)

  Parâmetro único de entrada (JSON):
    @json NVARCHAR(MAX) --> [{ "cd_ordem_servico": 0, "cd_pedido_venda": 0, "cd_pedido_inicio": 0, "cd_pedido_fim": 0 }]

  Requisitos Técnicos:
    - SET NOCOUNT ON
    - TRY...CATCH
    - Sem cursor
    - Performance voltada para grandes volumes
    - Código comentado

  Observações:
    - Dados da empresa devem vir de egisadmin.dbo.Empresa
    - Utiliza o contrato obrigatório de extração do JSON via OPENJSON
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_ordem_servico_pedido_venda
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
            @cd_relatorio                INT = 436,
            @cd_empresa                  INT = 0,
            @cd_ordem_servico            INT = 0,
            @cd_pedido_venda             INT = 0,
            @cd_pedido_inicio            INT = 0,
            @cd_pedido_fim               INT = 0,
            @cd_usuario                  INT = 0,
            @ic_codigo_produto_rel_pedido CHAR(1) = 'N';

        DECLARE
            @titulo               VARCHAR(200) = 'Ordem de Serviço por Pedido',
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
            @nm_pais_empresa      VARCHAR(20) = '',
            @data_hora_atual      VARCHAR(50) = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

        DECLARE
            @os_numero            VARCHAR(20) = '',
            @os_data              VARCHAR(20) = '',
            @os_pedido            VARCHAR(20) = '',
            @os_cliente           VARCHAR(200) = '',
            @os_cliente_razao     VARCHAR(200) = '',
            @os_cnpj_cliente      VARCHAR(30) = '',
            @os_email_cliente     VARCHAR(200) = '',
            @os_telefone_cliente  VARCHAR(50) = '',
            @os_contato           VARCHAR(200) = '',
            @os_status            VARCHAR(100) = '',
            @os_usuario           VARCHAR(200) = '',
            @os_condicao_pag      VARCHAR(200) = '',
            @os_data_fechamento   VARCHAR(20) = '',
            @os_obs_fechamento    VARCHAR(400) = '';

        DECLARE
            @html_header NVARCHAR(MAX) = '',
            @html_body   NVARCHAR(MAX) = '',
            @html_footer NVARCHAR(MAX) = '',
            @html        NVARCHAR(MAX) = '';

        SET @json = ISNULL(@json, '');
        IF LTRIM(RTRIM(@json)) = ''
            SET @json = N'[{}]';

        -------------------------------------------------------------------------------------------------
        -- 2) Extração do JSON conforme contrato obrigatório
        -------------------------------------------------------------------------------------------------
        SELECT
            1                                                  AS id_registro,
            IDENTITY(INT, 1, 1)                                AS id,
            valores.[key] COLLATE SQL_Latin1_General_CP1_CI_AI AS campo,
            valores.[value]                                    AS valor
        INTO #json
        FROM
            OPENJSON(@json) AS root
            CROSS APPLY OPENJSON(root.value) AS valores;

        SELECT @cd_ordem_servico = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_ordem_servico';

        SELECT @cd_pedido_venda = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_pedido_venda';

        SELECT @cd_pedido_inicio = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_pedido_inicio';

        SELECT @cd_pedido_fim = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_pedido_fim';

        SELECT @cd_usuario = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_usuario';

        SET @cd_ordem_servico = ISNULL(@cd_ordem_servico, 0);
        SET @cd_pedido_venda = ISNULL(@cd_pedido_venda, 0);
        SET @cd_pedido_inicio = ISNULL(@cd_pedido_inicio, 0);
        SET @cd_pedido_fim = ISNULL(@cd_pedido_fim, 0);
        SET @cd_usuario = ISNULL(@cd_usuario, 0);

        IF @cd_ordem_servico = 0 AND @cd_pedido_venda = 0 AND @cd_pedido_inicio = 0 AND @cd_pedido_fim = 0
            THROW 50001, 'Informe cd_pedido_venda, cd_pedido_inicio/cd_pedido_fim ou cd_ordem_servico.', 1;

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
        -- 4) Consulta principal (ordens por pedido)
        -------------------------------------------------------------------------------------------------
        SELECT
            IDENTITY(INT, 1, 1)                    AS cd_controle,
            os.dt_ordem_servico,
            os.cd_ordem_servico,
            c.nm_razao_social_cliente,
            dbo.fn_formata_cnpj(c.cd_cnpj_cliente) AS cd_cnpj_cliente,
            c.nm_fantasia_cliente,
            c.nm_email_cliente,
            c.cd_ddd + '-' + c.cd_telefone         AS Telefone,
            CASE WHEN ISNULL(os.nm_contato_aprovacao, '') <> '' THEN
                os.nm_contato_aprovacao
            ELSE
                co.nm_contato_cliente
            END                                    AS Contato,
            co.cd_email_contato_cliente,
            os.cd_contato,
            os.dt_fechamento_ordem,
            os.nm_obs_fechamento,
            ISNULL(os.cd_pedido_venda, 0)          AS cd_pedido_venda,
            os.nm_status_os,
            ISNULL(osp.cd_item_ordem_servico, 0)   AS cd_item_ordem_servico,
            ISNULL(osp.qt_item_produto, 0)         AS qt_item_produto,
            ISNULL(osp.vl_unitario_produto, 0)     AS vl_unitario_produto,
            ISNULL(osp.vl_total_produto, 0)        AS vl_total_produto,
            CASE WHEN @ic_codigo_produto_rel_pedido = 'N' THEN
                p.nm_fantasia_produto
            ELSE
                p.cd_mascara_produto
            END                                    AS nm_fantasia_produto,
            p.cd_mascara_produto,
            p.nm_produto,
            ISNULL(osp.nm_produto_ordem, '')       AS nm_produto_ordem,
            ISNULL(osp.vl_total_produto, 0)        AS Total,
            oss.nm_item_servico,
            ISNULL(oss.qt_item_servico, 0)         AS qt_item_servico,
            ISNULL(oss.vl_unitario_servico, 0)     AS vl_unitario_servico,
            ISNULL(oss.vl_total_servico, 0)        AS vl_total_servico,
            ISNULL(osp.cd_item_pedido_compra, '')  AS cd_item_pedido_compra,
            ISNULL(osp.ic_item_arquivo_fechado, 'N') AS ic_item_arquivo_fechado,
            osp.nm_obs_item_produto,
            u.nm_fantasia_usuario,
            cp.nm_condicao_pagamento,
            cp.sg_condicao_pagamento
        INTO #Consulta_Ordem
        FROM ordem_servico_grafica AS os WITH (NOLOCK)
        LEFT JOIN cliente AS c WITH (NOLOCK)
            ON c.cd_cliente = os.cd_cliente
        LEFT JOIN cliente_contato AS co WITH (NOLOCK)
            ON co.cd_contato = os.cd_contato
            AND co.cd_cliente = os.cd_cliente
        LEFT JOIN vendedor AS vi WITH (NOLOCK)
            ON vi.cd_vendedor = os.cd_vendedor_interno
        LEFT JOIN vendedor AS ve WITH (NOLOCK)
            ON ve.cd_vendedor = os.cd_vendedor
        LEFT JOIN condicao_pagamento AS cp WITH (NOLOCK)
            ON cp.cd_condicao_pagamento = os.cd_condicao_pagamento
        LEFT JOIN transportadora AS t WITH (NOLOCK)
            ON t.cd_transportadora = os.cd_transportadora
        LEFT JOIN egisadmin.dbo.usuario AS u WITH (NOLOCK)
            ON u.cd_usuario = os.cd_usuario_original
        LEFT JOIN ordem_servico_grafica_produto AS osp WITH (NOLOCK)
            ON osp.cd_ordem_servico = os.cd_ordem_servico
        LEFT JOIN produto AS p WITH (NOLOCK)
            ON p.cd_produto = osp.cd_produto
        LEFT JOIN ordem_servico_grafica_servico AS oss WITH (NOLOCK)
            ON osp.cd_ordem_servico = os.cd_ordem_servico
        WHERE
            ISNULL(os.cd_pedido_venda, 0) = CASE WHEN @cd_pedido_venda = 0 THEN ISNULL(os.cd_pedido_venda, 0) ELSE @cd_pedido_venda END
            AND ISNULL(os.cd_pedido_venda, 0) BETWEEN
                CASE WHEN @cd_pedido_inicio = 0 THEN ISNULL(os.cd_pedido_venda, 0) ELSE @cd_pedido_inicio END AND
                CASE WHEN @cd_pedido_fim = 0 THEN ISNULL(os.cd_pedido_venda, 0) ELSE @cd_pedido_fim END
            AND (@cd_ordem_servico = 0 OR os.cd_ordem_servico = @cd_ordem_servico)
            AND os.nm_status_os = 'Ativa';

        -------------------------------------------------------------------------------------------------
        -- 5) Cabeçalho (informações principais)
        -------------------------------------------------------------------------------------------------
        SELECT TOP (1)
            @os_numero          = CONVERT(VARCHAR(20), cd_ordem_servico),
            @os_data            = CONVERT(VARCHAR(10), dt_ordem_servico, 103),
            @os_pedido          = CONVERT(VARCHAR(20), cd_pedido_venda),
            @os_cliente         = ISNULL(nm_fantasia_cliente, ''),
            @os_cliente_razao   = ISNULL(nm_razao_social_cliente, ''),
            @os_cnpj_cliente    = ISNULL(cd_cnpj_cliente, ''),
            @os_email_cliente   = ISNULL(nm_email_cliente, ''),
            @os_telefone_cliente = ISNULL(Telefone, ''),
            @os_contato         = ISNULL(Contato, ''),
            @os_status          = ISNULL(nm_status_os, ''),
            @os_usuario         = ISNULL(nm_fantasia_usuario, ''),
            @os_condicao_pag    = ISNULL(nm_condicao_pagamento, ''),
            @os_data_fechamento = CASE WHEN dt_fechamento_ordem IS NULL THEN '' ELSE CONVERT(VARCHAR(10), dt_fechamento_ordem, 103) END,
            @os_obs_fechamento  = ISNULL(nm_obs_fechamento, '')
        FROM #Consulta_Ordem
        ORDER BY cd_ordem_servico;

        -------------------------------------------------------------------------------------------------
        -- 6) Tabelas auxiliares de produtos e serviços
        -------------------------------------------------------------------------------------------------
        SELECT DISTINCT
            cd_item_ordem_servico,
            ISNULL(nm_fantasia_produto, '') AS nm_fantasia_produto,
            ISNULL(nm_produto, '') AS nm_produto,
            ISNULL(nm_produto_ordem, '') AS nm_produto_ordem,
            qt_item_produto,
            vl_unitario_produto,
            vl_total_produto
        INTO #Produtos
        FROM #Consulta_Ordem
        WHERE ISNULL(cd_item_ordem_servico, 0) > 0
           OR ISNULL(nm_fantasia_produto, '') <> '';

        SELECT DISTINCT
            ISNULL(nm_item_servico, '') AS nm_item_servico,
            qt_item_servico,
            vl_unitario_servico,
            vl_total_servico
        INTO #Servicos
        FROM #Consulta_Ordem
        WHERE ISNULL(nm_item_servico, '') <> '';

        -------------------------------------------------------------------------------------------------
        -- 7) Montagem do HTML do relatório
        -------------------------------------------------------------------------------------------------
        SET @html_header =
            '<html><head><meta charset="utf-8" />' +
            '<style>' +
            'body{font-family:Arial, sans-serif; font-size:12px; color:#333;}' +
            'h1{font-size:18px; margin:0;}' +
            '.header{display:flex; justify-content:space-between; align-items:center; border-bottom:2px solid ' + @nm_cor_empresa + '; padding-bottom:8px;}' +
            '.company{font-size:11px; line-height:1.4;}' +
            '.section{margin-top:12px;}' +
            '.label{font-weight:bold; color:#444;}' +
            'table{width:100%; border-collapse:collapse; margin-top:6px;}' +
            'th, td{border:1px solid #d9d9d9; padding:6px; font-size:11px; text-align:left;}' +
            'th{background:#f4f4f4;}' +
            '</style></head><body>' +
            '<div class="header">' +
            '  <div><img src="' + @logo + '" alt="Logo" style="max-height:60px;" /></div>' +
            '  <div style="text-align:right;">' +
            '    <h1>' + ISNULL(@nm_titulo_relatorio, @titulo) + '</h1>' +
            '    <div style="font-size:11px;">Gerado em: ' + @data_hora_atual + '</div>' +
            '  </div>' +
            '</div>' +
            '<div class="company">' +
            '  <strong>' + @nm_fantasia_empresa + '</strong><br />' +
            '  ' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + '<br />' +
            '  ' + @nm_cidade_empresa + ' - ' + @sg_estado_empresa + ' - ' + @nm_pais_empresa + '<br />' +
            '  Fone: ' + @cd_telefone_empresa + ' | Email: ' + @nm_email_empresa +
            '</div>' +
            '<div class="section">' +
            '  <p><span class="label">OS:</span> ' + @os_numero + ' &nbsp; <span class="label">Data:</span> ' + @os_data + ' &nbsp; <span class="label">Pedido:</span> ' + @os_pedido + '</p>' +
            '  <p><span class="label">Cliente:</span> ' + @os_cliente + ' &nbsp; <span class="label">Razão Social:</span> ' + @os_cliente_razao + '</p>' +
            '  <p><span class="label">CNPJ:</span> ' + @os_cnpj_cliente + ' &nbsp; <span class="label">Email:</span> ' + @os_email_cliente + '</p>' +
            '  <p><span class="label">Contato:</span> ' + @os_contato + ' &nbsp; <span class="label">Telefone:</span> ' + @os_telefone_cliente + '</p>' +
            '  <p><span class="label">Status:</span> ' + @os_status + ' &nbsp; <span class="label">Condição:</span> ' + @os_condicao_pag + '</p>' +
            '  <p><span class="label">Usuário:</span> ' + @os_usuario + ' &nbsp; <span class="label">Fechamento:</span> ' + @os_data_fechamento + '</p>' +
            '  <p><span class="label">Obs. Fechamento:</span> ' + @os_obs_fechamento + '</p>' +
            '</div>' +
            '<div class="section">' + ISNULL(@ds_relatorio, '') + '</div>';

        DECLARE @produto_rows NVARCHAR(MAX) = '';
        DECLARE @servico_rows NVARCHAR(MAX) = '';

        SELECT @produto_rows = (
            SELECT
                '<tr>' +
                '<td>' + ISNULL(CONVERT(VARCHAR(20), cd_item_ordem_servico), '') + '</td>' +
                '<td>' + ISNULL(nm_fantasia_produto, '') + '</td>' +
                '<td>' + ISNULL(nm_produto, '') + '</td>' +
                '<td>' + ISNULL(nm_produto_ordem, '') + '</td>' +
                '<td style="text-align:right;">' + ISNULL(CONVERT(VARCHAR(20), qt_item_produto), '') + '</td>' +
                '<td style="text-align:right;">' + ISNULL(CONVERT(VARCHAR(20), vl_unitario_produto), '') + '</td>' +
                '<td style="text-align:right;">' + ISNULL(CONVERT(VARCHAR(20), vl_total_produto), '') + '</td>' +
                '</tr>'
            FROM #Produtos
            ORDER BY cd_item_ordem_servico
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)');

        SELECT @servico_rows = (
            SELECT
                '<tr>' +
                '<td>' + ISNULL(nm_item_servico, '') + '</td>' +
                '<td style="text-align:right;">' + ISNULL(CONVERT(VARCHAR(20), qt_item_servico), '') + '</td>' +
                '<td style="text-align:right;">' + ISNULL(CONVERT(VARCHAR(20), vl_unitario_servico), '') + '</td>' +
                '<td style="text-align:right;">' + ISNULL(CONVERT(VARCHAR(20), vl_total_servico), '') + '</td>' +
                '</tr>'
            FROM #Servicos
            ORDER BY nm_item_servico
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)');

        SET @html_body =
            '<div class="section">' +
            '  <h3>Produtos</h3>' +
            '  <table>' +
            '    <thead>' +
            '      <tr>' +
            '        <th>Item</th><th>Produto</th><th>Descrição</th><th>Obs.</th><th>Qtde</th><th>Vl. Unit.</th><th>Vl. Total</th>' +
            '      </tr>' +
            '    </thead>' +
            '    <tbody>' + ISNULL(@produto_rows, '') + '</tbody>' +
            '  </table>' +
            '</div>' +
            '<div class="section">' +
            '  <h3>Serviços</h3>' +
            '  <table>' +
            '    <thead>' +
            '      <tr>' +
            '        <th>Serviço</th><th>Qtde</th><th>Vl. Unit.</th><th>Vl. Total</th>' +
            '      </tr>' +
            '    </thead>' +
            '    <tbody>' + ISNULL(@servico_rows, '') + '</tbody>' +
            '  </table>' +
            '</div>';

        SET @html_footer = '</body></html>';
        SET @html = @html_header + @html_body + @html_footer;

        SELECT ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_ordem_servico_pedido_venda falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        --THROW ERROR_NUMBER(), @errMsg, ERROR_STATE();


    END CATCH


END;
GO


--exec pr_egis_ordem_servico_pedido_venda '[{"cd_pedido_venda":1726}]'