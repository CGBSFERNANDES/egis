IF OBJECT_ID('dbo.pr_egis_relatorio_ordem_servico_grafica', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_ordem_servico_grafica;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_ordem_servico_grafica
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-05
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Gerar o relatório HTML da Ordem de Serviço Gráfica (cd_relatorio = 433)

  Parâmetro único de entrada (JSON):
    @json NVARCHAR(MAX) --> [{ "cd_ordem_servico": 0, "dt_inicial": "", "dt_final": "", "cd_usuario": 0, "cd_usuario_impressao": 0 }]

  Requisitos Técnicos:
    - SET NOCOUNT ON
    - TRY...CATCH
    - Sem cursor
    - Performance voltada para grandes volumes
    - Código comentado

  Observações:
    - Dados da empresa devem vir de egisadmin.dbo.Empresa
    - Quando cd_ordem_servico = 0, utiliza dt_inicial/dt_final para filtragem
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_ordem_servico_grafica
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
            @cd_relatorio         INT = 433,
            @cd_empresa           INT = NULL,
            @cd_usuario           INT = NULL,
            @cd_usuario_impressao INT = NULL,
            @cd_ordem_servico     INT = NULL,
            @dt_inicial           DATETIME = NULL,
            @dt_final             DATETIME = NULL;

        DECLARE
            @titulo               VARCHAR(200) = 'Ordem de Serviço',
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

        IF NULLIF(@json, N'') IS NULL
            SET @json = N'{}';

        IF ISJSON(@json) = 0
            THROW 50001, 'JSON de entrada inválido ou mal formatado.', 1;

        --IF JSON_VALUE(@json, '$[0]') IS NOT NULL
           --SET @json = JSON_QUERY(@json, '$[0]');

           --select @json

        
        select                     

         1                                                    as id_registro,
         IDENTITY(int,1,1)                                    as id,
         valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
         valores.[value]                                      as valor                    
                    
         into #json                    
         from                
           openjson(@json)root                    
           cross apply openjson(root.value) as valores      

        --select * from #json

        select @cd_ordem_servico              = valor from #json where campo = 'cd_documento_form'      
        
        --SELECT
        --    @cd_ordem_servico     = TRY_CAST(JSON_VALUE(@json, '$.cd_ordem_servico') AS INT),
        --    @dt_inicial           = TRY_CAST(JSON_VALUE(@json, '$.dt_inicial') AS DATETIME),
        --    @dt_final             = TRY_CAST(JSON_VALUE(@json, '$.dt_final') AS DATETIME),
        --    @cd_usuario           = TRY_CAST(JSON_VALUE(@json, '$.cd_usuario') AS INT),
        --    @cd_usuario_impressao = TRY_CAST(JSON_VALUE(@json, '$.cd_usuario_impressao') AS INT);

        SET @cd_empresa = dbo.fn_empresa();
        SET @cd_ordem_servico = ISNULL(@cd_ordem_servico, 0);
        SET @cd_usuario_impressao = ISNULL(@cd_usuario_impressao, @cd_usuario);

        --select @cd_ordem_servico
        --return

        -------------------------------------------------------------------------------------------------
        -- 2) Datas padrão (Parametro_Relatorio ou mês atual)
        -------------------------------------------------------------------------------------------------
        IF @cd_ordem_servico = 0
        BEGIN
            SELECT
                @dt_inicial = COALESCE(@dt_inicial, pr.dt_inicial),
                @dt_final   = COALESCE(@dt_final, pr.dt_final)
            FROM Parametro_Relatorio AS pr WITH (NOLOCK)
            WHERE pr.cd_relatorio = @cd_relatorio
              AND (@cd_usuario IS NULL OR pr.cd_usuario = @cd_usuario);
        END

        IF @dt_inicial IS NULL OR @dt_final IS NULL
        BEGIN
            SET @dt_inicial = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
            SET @dt_final   = EOMONTH(@dt_inicial);
        END

        -------------------------------------------------------------------------------------------------
        -- 3) Dados do relatório e empresa
        -------------------------------------------------------------------------------------------------
        SELECT
            @titulo              = ISNULL(r.nm_relatorio, @titulo),
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.relatorio AS r WITH (NOLOCK)
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
        -- 4) Dados da ordem de serviço (capa)
        -------------------------------------------------------------------------------------------------
        SELECT
            osg.cd_ordem_servico,
            osg.dt_ordem_servico,
            osg.cd_cliente,
            c.nm_fantasia_cliente,
            c.nm_razao_social_cliente,
            c.cd_cnpj_cliente,
            cpe.ds_perfil_cliente,
            cpe.ds_perfil_entrega_cliente,
            osg.cd_vendedor_interno,
            vi.nm_fantasia_vendedor                                        AS nm_fantasia_vendedor_interno,
            vi.nm_endereco_vendedor + ' - ' + vi.nm_complemento_endereco   AS nm_endereco_vendedor_interno,
            vi.cd_numero_endereco                                          AS cd_numero_vendedor_interno,
            vi.nm_bairro_vendedor                                          AS nm_bairro_vendedor_interno,
            ISNULL(vi.cd_ddd_vendedor, '11') + ' ' + vi.cd_telefone_vendedor AS cd_telefone_vendedor_interno,
            osg.cd_vendedor,
            v.nm_fantasia_vendedor,
            osg.cd_condicao_pagamento,
            cp.nm_condicao_pagamento,
            osg.cd_transportadora,
            t.nm_transportadora,
            t.cd_cnpj_transportadora,
            osg.cd_tipo_midia,
            tm.nm_tipo_midia,
            osg.dt_entrada_ordem,
            osg.vl_ordem_servico,
            osg.ds_ordem_servico,
            osg.nm_local_entrega,
            osg.nm_obs_ordem_servico,
            osg.nm_obs_ordem_servico_comp,
            osg.hr_entrega_ordem,
            osg.cd_usuario,
            osg.dt_usuario,
            osg.cd_contato,
            con.nm_contato_cliente AS nm_contato,
            con.cd_ddd_contato_cliente + ' ' + con.cd_telefone_contato AS cd_telefone_contato,
            con.cd_ddd_contato_cliente + ' ' + con.cd_fax_contato AS cd_fax_contato,
            con.cd_ramal AS cd_ramal_contato,
            con.cd_email_contato_cliente AS nm_email_contato,
            ca.nm_cargo AS nm_cargo_contato,
            osg.dt_aprovacao_ordem,
            osg.nm_contato_aprovacao,
            osg.nm_obs_aprovacao,
            osg.dt_fechamento_ordem,
            osg.nm_obs_fechamento,
            osg.cd_pedido_venda,
            v.nm_vendedor,
            tp.nm_tipo_vendedor,
            u.nm_fantasia_usuario,
            sog.nm_status_ordem,
            e.nm_entregador,
            osg.nm_status_os,
            osg.cd_tipo_endereco,
            tpo.nm_tipo_prioridade,
            ui.nm_fantasia_usuario AS nm_usuario_impressao,
            it.nm_itinerario,
            osg.nm_endereco_entrega
        INTO #OrdemServico
        FROM ordem_servico_grafica AS osg WITH (NOLOCK)
        LEFT JOIN cliente AS c WITH (NOLOCK)
            ON c.cd_cliente = osg.cd_cliente
        LEFT JOIN cliente_perfil AS cpe WITH (NOLOCK)
            ON cpe.cd_cliente = osg.cd_cliente
        LEFT JOIN vendedor AS v WITH (NOLOCK)
            ON v.cd_vendedor = osg.cd_vendedor
        LEFT JOIN cidade AS cidv WITH (NOLOCK)
            ON cidv.cd_cidade = v.cd_cidade
           AND cidv.cd_estado = v.cd_estado
        LEFT JOIN vendedor AS vi WITH (NOLOCK)
            ON vi.cd_vendedor = osg.cd_vendedor_interno
        LEFT JOIN condicao_pagamento AS cp WITH (NOLOCK)
            ON cp.cd_condicao_pagamento = osg.cd_condicao_pagamento
        LEFT JOIN transportadora AS t WITH (NOLOCK)
            ON t.cd_transportadora = osg.cd_transportadora
        LEFT JOIN tipo_midia AS tm WITH (NOLOCK)
            ON tm.cd_tipo_midia = osg.cd_tipo_midia
        LEFT JOIN cliente_contato AS con WITH (NOLOCK)
            ON con.cd_cliente = osg.cd_cliente
           AND con.cd_contato = osg.cd_contato
        LEFT JOIN cargo AS ca WITH (NOLOCK)
            ON ca.cd_cargo = con.cd_cargo
        LEFT JOIN tipo_vendedor AS tp WITH (NOLOCK)
            ON tp.cd_tipo_vendedor = v.cd_tipo_vendedor
        LEFT JOIN EgisAdmin.dbo.Usuario AS u WITH (NOLOCK)
            ON u.cd_usuario = osg.cd_usuario_original
        LEFT JOIN Status_Ordem_grafica AS sog WITH (NOLOCK)
            ON sog.cd_status_ordem = osg.cd_status_ordem
        LEFT JOIN Entregador AS e WITH (NOLOCK)
            ON e.cd_entregador = osg.cd_entregador
        LEFT JOIN Tipo_Prioridade AS tpo WITH (NOLOCK)
            ON tpo.cd_tipo_prioridade = osg.cd_tipo_prioridade
        LEFT JOIN Itinerario AS it WITH (NOLOCK)
            ON it.cd_itinerario = c.cd_itinerario
        LEFT JOIN EgisAdmin.dbo.Usuario AS ui WITH (NOLOCK)
            ON ui.cd_usuario = @cd_usuario_impressao
        WHERE
            osg.dt_ordem_servico BETWEEN CASE WHEN @cd_ordem_servico = 0 THEN @dt_inicial ELSE osg.dt_ordem_servico END
                                    AND CASE WHEN @cd_ordem_servico = 0 THEN @dt_final ELSE osg.dt_ordem_servico END
            AND osg.cd_ordem_servico = CASE WHEN @cd_ordem_servico = 0 THEN osg.cd_ordem_servico ELSE @cd_ordem_servico END;

        IF NOT EXISTS (SELECT 1 FROM #OrdemServico)
            THROW 50002, 'Nenhuma ordem de serviço encontrada para os parâmetros informados.', 1;

        -------------------------------------------------------------------------------------------------
        -- 5) Itens da ordem de serviço (produtos)
        -------------------------------------------------------------------------------------------------
        DECLARE @cd_fase_produto INT = 0;

        SELECT
            @cd_fase_produto = ISNULL(cd_fase_produto, 0)
        FROM Parametro_Comercial WITH (NOLOCK)
        WHERE cd_empresa = dbo.fn_empresa();

        SELECT
            os.*,
            p.nm_fantasia_produto,
            p.nm_produto,
            p.cd_mascara_produto,
            ISNULL(ps.qt_saldo_reserva_produto, 0) AS Disponivel
        INTO #Itens
        FROM ordem_servico_grafica_produto AS os WITH (NOLOCK)
        LEFT JOIN produto AS p WITH (NOLOCK)
            ON p.cd_produto = os.cd_produto
        LEFT JOIN produto_saldo AS ps WITH (NOLOCK)
            ON ps.cd_produto = p.cd_produto
           AND ps.cd_fase_produto = CASE
                                        WHEN ISNULL(p.cd_fase_produto_baixa, 0) > 0
                                            THEN p.cd_fase_produto_baixa
                                        ELSE @cd_fase_produto
                                    END
        WHERE os.cd_ordem_servico IN (SELECT cd_ordem_servico FROM #OrdemServico);

        -------------------------------------------------------------------------------------------------
        -- 6) Captura campos do cabeçalho
        -------------------------------------------------------------------------------------------------
        DECLARE
            @os_numero              VARCHAR(30) = '',
            @os_data                VARCHAR(20) = '',
            @os_cliente             VARCHAR(200) = '',
            @os_cliente_razao       VARCHAR(200) = '',
            @os_cnpj_cliente        VARCHAR(30) = '',
            @os_condicao_pagamento  VARCHAR(100) = '',
            @os_transportadora      VARCHAR(100) = '',
            @os_tipo_midia          VARCHAR(100) = '',
            @os_vendedor            VARCHAR(200) = '',
            @os_vendedor_interno    VARCHAR(200) = '',
            @os_contato             VARCHAR(200) = '',
            @os_contato_telefone    VARCHAR(60) = '',
            @os_contato_email       VARCHAR(200) = '',
            @os_local_entrega       VARCHAR(200) = '',
            @os_obs                 VARCHAR(800) = '',
            @os_status              VARCHAR(200) = '',
            @os_prioridade          VARCHAR(200) = '',
            @os_usuario_impressao   VARCHAR(200) = '';

        SELECT TOP (1)
            @os_numero             = CONVERT(VARCHAR(30), cd_ordem_servico),
            @os_data               = CONVERT(VARCHAR(10), dt_ordem_servico, 103),
            @os_cliente            = ISNULL(nm_fantasia_cliente, ''),
            @os_cliente_razao      = ISNULL(nm_razao_social_cliente, ''),
            @os_cnpj_cliente       = ISNULL(cd_cnpj_cliente, ''),
            @os_condicao_pagamento = ISNULL(nm_condicao_pagamento, ''),
            @os_transportadora     = ISNULL(nm_transportadora, ''),
            @os_tipo_midia         = ISNULL(nm_tipo_midia, ''),
            @os_vendedor           = ISNULL(nm_fantasia_vendedor, ''),
            @os_vendedor_interno   = ISNULL(nm_fantasia_vendedor_interno, ''),
            @os_contato            = ISNULL(nm_contato, ''),
            @os_contato_telefone   = ISNULL(cd_telefone_contato, ''),
            @os_contato_email      = ISNULL(nm_email_contato, ''),
            @os_local_entrega      = ISNULL(nm_local_entrega, ''),
            @os_obs                = ISNULL(nm_obs_ordem_servico, ''),
            @os_status             = ISNULL(nm_status_ordem, ''),
            @os_prioridade         = ISNULL(nm_tipo_prioridade, ''),
            @os_usuario_impressao  = ISNULL(nm_usuario_impressao, '')
        FROM #OrdemServico;

        -------------------------------------------------------------------------------------------------
        -- 7) Montagem do HTML (cabeçalho + tabela de itens dinâmica)
        -------------------------------------------------------------------------------------------------
        DECLARE
            @html_header NVARCHAR(MAX) = '',
            @html_footer NVARCHAR(MAX) = '',
            @html_items_header NVARCHAR(MAX) = '',
            @html_items_rows NVARCHAR(MAX) = '',
            @html_items_table NVARCHAR(MAX) = '',
            @html NVARCHAR(MAX) = '';

        DECLARE @titulo_exibir VARCHAR(200) = ISNULL(NULLIF(@nm_titulo_relatorio, ''), @titulo);

        SET @html_header =
            '<html>' +
            '<head>' +
            '  <meta charset="UTF-8">' +
            '  <title>' + ISNULL(@titulo_exibir, 'Relatório') + '</title>' +
            '  <style>' +
            '    body { font-family: Arial, sans-serif; color: #333; padding: 20px; }' +
            '    h1 { color: ' + @nm_cor_empresa + '; margin-bottom: 4px; }' +
            '    h3 { margin-top: 0; color: #555; }' +
            '    table { width: 100%; border-collapse: collapse; margin-top: 15px; }' +
            '    th, td { border: 1px solid #ddd; padding: 6px; font-size: 12px; }' +
            '    th { background-color: #f2f2f2; text-align: left; }' +
            '    .section { margin-top: 15px; }' +
            '    .label { font-weight: bold; }' +
            '  </style>' +
            '</head>' +
            '<body>' +
            '  <div style="display:flex; justify-content: space-between; align-items: center;">' +
            '    <div style="width:30%; padding-right:20px;"><img src="' + @logo + '" alt="Logo" style="max-width: 220px;"></div>' +
            '    <div style="width:70%; padding-left:10px;">' +
            '      <h1>' + ISNULL(@titulo_exibir, '') + '</h1>' +
            '      <h3>Ordem de Serviço Gráfica</h3>' +
            '      <p><strong>' + @nm_fantasia_empresa + '</strong></p>' +
            '      <p>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade_empresa + ' - ' + @sg_estado_empresa + ' - ' + @nm_pais_empresa + '</p>' +
            '      <p><strong>Fone: </strong>' + @cd_telefone_empresa + ' | <strong>Email: </strong>' + @nm_email_empresa + '</p>' +
            '    </div>' +
            '  </div>' +
            '  <div style="text-align:right; font-size:11px; margin-top:10px;">Gerado em: ' + @data_hora_atual + '</div>' +
            '  <div class="section">' +
            '    <p><span class="label">OS:</span> ' + @os_numero + ' &nbsp; <span class="label">Data:</span> ' + @os_data + '</p>' +
            '    <p><span class="label">Cliente:</span> ' + @os_cliente + ' &nbsp; <span class="label">Razão Social:</span> ' + @os_cliente_razao + '</p>' +
            '    <p><span class="label">CNPJ:</span> ' + @os_cnpj_cliente + '</p>' +
            '    <p><span class="label">Vendedor:</span> ' + @os_vendedor + ' &nbsp; <span class="label">Vendedor Interno:</span> ' + @os_vendedor_interno + '</p>' +
            '    <p><span class="label">Condição:</span> ' + @os_condicao_pagamento + ' &nbsp; <span class="label">Tipo Mídia:</span> ' + @os_tipo_midia + '</p>' +
            '    <p><span class="label">Transportadora:</span> ' + @os_transportadora + '</p>' +
            '    <p><span class="label">Contato:</span> ' + @os_contato + ' &nbsp; <span class="label">Telefone:</span> ' + @os_contato_telefone + ' &nbsp; <span class="label">Email:</span> ' + @os_contato_email + '</p>' +
            '    <p><span class="label">Local Entrega:</span> ' + @os_local_entrega + '</p>' +
            '    <p><span class="label">Status:</span> ' + @os_status + ' &nbsp; <span class="label">Prioridade:</span> ' + @os_prioridade + '</p>' +
            '    <p><span class="label">Usuário Impressão:</span> ' + @os_usuario_impressao + '</p>' +
            '    <p><span class="label">Observações:</span> ' + @os_obs + '</p>' +
            '  </div>' +
            '  <div class="section">' + ISNULL(@ds_relatorio, '') + '</div>' +
            '  <div class="section"><h3>Itens</h3></div>';

        -------------------------------------------------------------------------------------------------
        -- 8) Cabeçalho dinâmico de itens
        -------------------------------------------------------------------------------------------------
        DECLARE @cols TABLE (colname SYSNAME, colorder INT);

        INSERT INTO @cols (colname, colorder)
        SELECT
            c.name,
            c.column_id
        FROM tempdb.sys.columns AS c
        WHERE c.object_id = OBJECT_ID('tempdb..#Itens')
        ORDER BY c.column_id;

        SELECT
            @html_items_header = STUFF((
                SELECT '<th>' + colname + '</th>'
                FROM @cols
                ORDER BY colorder
                FOR XML PATH(''), TYPE
            ).value('.', 'nvarchar(max)'), 1, 0, '');

        -------------------------------------------------------------------------------------------------
        -- 9) Linhas dinâmicas de itens
        -------------------------------------------------------------------------------------------------
        DECLARE @rowExpr NVARCHAR(MAX) = '';

        SELECT @rowExpr = @rowExpr +
            ' + ''<td>'' + ISNULL(CONVERT(NVARCHAR(MAX), ' + QUOTENAME(colname) + '), '''') + ''</td>'''
        FROM @cols
        ORDER BY colorder;

        DECLARE @sql NVARCHAR(MAX) =
            'SELECT @rowsOut = COALESCE(@rowsOut, '''') + ''<tr>'' ' + @rowExpr + ' + ''</tr>'' FROM #Itens;';

        EXEC sp_executesql @sql, N'@rowsOut NVARCHAR(MAX) OUTPUT', @rowsOut = @html_items_rows OUTPUT;

        SET @html_items_table =
            '<table>' +
            '<thead><tr>' + ISNULL(@html_items_header, '') + '</tr></thead>' +
            '<tbody>' + ISNULL(@html_items_rows, '') + '</tbody>' +
            '</table>';

        SET @html_footer = '</body></html>';
        SET @html = @html_header + @html_items_table + @html_footer;

        SELECT ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_relatorio_ordem_servico_grafica falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        --THROW ERROR_NUMBER(), @errMsg, ERROR_STATE();
    END CATCH
END;
GO


EXEC pr_egis_relatorio_ordem_servico_grafica '[{ "cd_ordem_servico": 116006 }]'
