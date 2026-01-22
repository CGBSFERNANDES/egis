IF OBJECT_ID('dbo.pr_egis_relatorio_nota_debito', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_nota_debito;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_nota_debito
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-05
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Nota Débito (cd_relatorio = 435)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Entrada: @json = '[{"cd_nota_debito": <int>}]'
    - Retorna HTML no padrão RelatorioHTML
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_nota_debito
    @json NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_relatorio           INT          = 435,
        @cd_empresa             INT          = NULL,
        @cd_usuario             INT          = NULL,
        @cd_nota_debito         INT          = NULL,
        @ic_aberto              CHAR(1)      = 'N',
        @nm_caminho_nota_debito VARCHAR(400) = '';

    DECLARE
        @titulo                VARCHAR(200) = 'Nota Débito',
        @logo                  VARCHAR(400) = 'logo_gbstec_sistema.jpg',
        @nm_cor_empresa        VARCHAR(20)  = '#1976D2',
        @nm_endereco_empresa   VARCHAR(200) = '',
        @cd_numero_endereco    VARCHAR(20)  = '',
        @nm_bairro_empresa     VARCHAR(80)  = '',
        @cd_cep_empresa        VARCHAR(20)  = '',
        @nm_cidade_empresa     VARCHAR(80)  = '',
        @sg_estado_empresa     VARCHAR(10)  = '',
        @cd_telefone_empresa   VARCHAR(200) = '',
        @nm_email_internet     VARCHAR(200) = '',
        @nm_fantasia_empresa   VARCHAR(200) = '',
        @cd_cnpj_empresa       VARCHAR(60)  = '',
        @nm_titulo_relatorio   VARCHAR(200) = NULL,
        @data_hora_atual       VARCHAR(50)  = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

    DECLARE
        @html                  NVARCHAR(MAX) = '',
        @html_itens            NVARCHAR(MAX) = '';

    DECLARE
        @cd_nota_debito_despesa       INT,
        @dt_nota_debito_despesa       DATE,
        @dt_inicio_ref_nota_debito    DATE,
        @dt_final_ref_nota_debito     DATE,
        @nm_ref_nota_debito           VARCHAR(200),
        @dt_vencimento_nota_debito    DATE,
        @ds_nota_debito               NVARCHAR(2000),
        @vl_nota_debito               DECIMAL(18, 2),
        @nm_fantasia_cliente          VARCHAR(200),
        @nm_razao_social_cliente      VARCHAR(200),
        @telefone_cliente             VARCHAR(50),
        @cd_banco                     INT,
        @nm_fantasia_banco            VARCHAR(200),
        @cd_numero_agencia_banco      VARCHAR(30),
        @nm_conta_banco               VARCHAR(200),
        @nm_fantasia_contato          VARCHAR(200),
        @nm_centro_custo              VARCHAR(200),
        @nm_analista                  VARCHAR(200),
        @cd_identificacao_cliente     VARCHAR(60),
        @nm_portador                  VARCHAR(200),
        @nm_agencia_banco             VARCHAR(200),
        @cd_numero_banco              VARCHAR(30),
        @cd_identificacao_nota_saida  VARCHAR(60),
        @nm_caminho_nota_debito_saida VARCHAR(400);

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Normaliza JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
        IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

        SELECT
            1                                                   AS id_registro,
            IDENTITY(INT, 1, 1)                                 AS id,
            valores.[key] COLLATE SQL_Latin1_General_CP1_CI_AI   AS campo,
            valores.[value]                                     AS valor
        INTO #json
        FROM openjson(@json) AS root
        CROSS APPLY openjson(root.value) AS valores;

        SELECT @cd_nota_debito = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_nota_debito';

        SELECT @cd_usuario = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_usuario';

        IF ISNULL(@cd_nota_debito, 0) = 0
            THROW 50002, 'cd_nota_debito não informado.', 1;

        /*-----------------------------------------------------------------------------------------
          2) Dados da empresa (egisadmin)
        -----------------------------------------------------------------------------------------*/
        SET @cd_empresa = dbo.fn_empresa();

        SELECT
            @logo                = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, 'logo_gbstec_sistema.jpg'),
            @nm_cor_empresa      = ISNULL(e.nm_cor_empresa, '#1976D2'),
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @nm_cidade_empresa   = ISNULL(c.nm_cidade, ''),
            @sg_estado_empresa   = ISNULL(es.sg_estado, ''),
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, ''),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(e.cd_numero, 0))),
            @nm_bairro_empresa   = ISNULL(e.nm_bairro_empresa, ''),
            @cd_cnpj_empresa     = dbo.fn_formata_cnpj(LTRIM(RTRIM(ISNULL(e.cd_cgc_empresa, ''))))
        FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)
        LEFT JOIN Estado AS es WITH (NOLOCK)
            ON es.cd_estado = e.cd_estado
        LEFT JOIN Cidade AS c WITH (NOLOCK)
            ON c.cd_cidade = e.cd_cidade
           AND c.cd_estado = e.cd_estado
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          3) Dados da nota de débito
        -----------------------------------------------------------------------------------------*/
        SELECT
            n.cd_nota_debito_despesa,
            n.dt_nota_debito_despesa,
            n.dt_inicio_ref_nota_debito,
            n.dt_final_ref_nota_debito,
            n.nm_ref_nota_debito,
            n.dt_vencimento_nota_debito,
            n.ds_nota_debito,
            n.vl_nota_debito,
            c.nm_fantasia_cliente,
            c.nm_razao_social_cliente,
            '(' + c.cd_ddd + ') ' + c.cd_telefone AS Telefone,
            b.cd_banco,
            b.nm_fantasia_banco,
            ag.cd_numero_agencia_banco,
            cab.nm_conta_banco,
            co.nm_fantasia_contato,
            cc.nm_centro_custo,
            a.nm_analista,
            n.cd_identificacao_cliente,
            po.nm_portador,
            ag.nm_agencia_banco,
            b.cd_numero_banco,
            ISNULL(ns.cd_identificacao_nota_saida, 0) AS cd_identificacao_nota_saida,
            @nm_caminho_nota_debito AS nm_caminho_nota_debito
        INTO #imp_nota_debito
        FROM Nota_Debito_Despesa AS n
        LEFT JOIN Cliente AS c
            ON c.cd_cliente = n.cd_cliente
        LEFT JOIN Cliente_Contato AS co
            ON co.cd_cliente = n.cd_cliente
           AND co.cd_contato = n.cd_contato
        LEFT JOIN cliente_informacao_credito AS ci
            ON ci.cd_cliente = n.cd_cliente
        LEFT JOIN Portador AS po
            ON po.cd_portador = ci.cd_portador
        LEFT JOIN Conta_Agencia_Banco AS cab
            ON cab.cd_conta_banco = po.cd_conta_banco
        LEFT JOIN Agencia_Banco AS ag
            ON ag.cd_agencia_banco = cab.cd_agencia_banco
           AND ag.cd_banco = cab.cd_banco
        LEFT JOIN banco AS b
            ON b.cd_banco = cab.cd_banco
        LEFT JOIN Centro_Custo AS cc
            ON cc.cd_centro_custo = n.cd_centro_custo
        LEFT JOIN Analista AS a
            ON a.cd_analista = n.cd_analista
        LEFT JOIN Nota_Saida AS ns
            ON ns.cd_nota_saida = n.cd_nota_saida
        WHERE ((n.cd_nota_debito_despesa = @cd_nota_debito)
            OR (@cd_nota_debito = 0 AND n.dt_pagto_nota_debito IS NULL))
          AND ISNULL(n.ic_emitida_nota_debito, 'N') = CASE
                WHEN @ic_aberto = 'N' THEN ISNULL(n.ic_emitida_nota_debito, 'N')
                ELSE 'N'
              END
        ORDER BY n.cd_nota_debito_despesa;

        IF NOT EXISTS (SELECT 1 FROM #imp_nota_debito)
            THROW 50003, 'Nota Débito não encontrada.', 1;

        SELECT TOP (1)
            @cd_nota_debito_despesa       = cd_nota_debito_despesa,
            @dt_nota_debito_despesa       = dt_nota_debito_despesa,
            @dt_inicio_ref_nota_debito    = dt_inicio_ref_nota_debito,
            @dt_final_ref_nota_debito     = dt_final_ref_nota_debito,
            @nm_ref_nota_debito           = nm_ref_nota_debito,
            @dt_vencimento_nota_debito    = dt_vencimento_nota_debito,
            @ds_nota_debito               = ds_nota_debito,
            @vl_nota_debito               = vl_nota_debito,
            @nm_fantasia_cliente          = nm_fantasia_cliente,
            @nm_razao_social_cliente      = nm_razao_social_cliente,
            @telefone_cliente             = Telefone,
            @cd_banco                     = cd_banco,
            @nm_fantasia_banco            = nm_fantasia_banco,
            @cd_numero_agencia_banco      = cd_numero_agencia_banco,
            @nm_conta_banco               = nm_conta_banco,
            @nm_fantasia_contato          = nm_fantasia_contato,
            @nm_centro_custo              = nm_centro_custo,
            @nm_analista                  = nm_analista,
            @cd_identificacao_cliente     = cd_identificacao_cliente,
            @nm_portador                  = nm_portador,
            @nm_agencia_banco             = nm_agencia_banco,
            @cd_numero_banco              = cd_numero_banco,
            @cd_identificacao_nota_saida  = CAST(cd_identificacao_nota_saida AS VARCHAR(60)),
            @nm_caminho_nota_debito_saida = nm_caminho_nota_debito
        FROM #imp_nota_debito;

        /*-----------------------------------------------------------------------------------------
          4) Itens (despesas) da nota de débito
        -----------------------------------------------------------------------------------------*/
        SELECT
            @html_itens = (
                SELECT
                    N'<tr>' +
                    N'<td>' + ISNULL(td.nm_tipo_despesa, '') + N'</td>' +
                    N'<td style="text-align:right;">' + CAST(ISNULL(ni.qt_nota_debito, 0) AS VARCHAR(20)) + N'</td>' +
                    N'<td style="text-align:right;">' + ISNULL(dbo.fn_formata_valor(ni.vl_item_nota_debito), '') + N'</td>' +
                    N'<td style="text-align:right;">' + ISNULL(dbo.fn_formata_valor(ni.qt_nota_debito * ni.vl_item_nota_debito), '') + N'</td>' +
                    N'<td>' + ISNULL(ni.nm_obs_item_nota_debito, '') + N'</td>' +
                    N'<td>' + ISNULL(CONVERT(VARCHAR(10), ni.dt_despesa, 103), '') + N'</td>' +
                    N'<td>' + ISNULL(ni.cd_documento_despesa, '') + N'</td>' +
                    N'</tr>'
                FROM Nota_Debito_Despesa_Composicao AS ni
                LEFT JOIN Tipo_Despesa AS td
                    ON td.cd_tipo_despesa = ni.cd_tipo_despesa
                WHERE ni.cd_nota_debito_despesa = @cd_nota_debito_despesa
                ORDER BY ni.cd_item_nota_despesa
                FOR XML PATH(''), TYPE
            ).value('.', 'nvarchar(max)');

        /*-----------------------------------------------------------------------------------------
          5) Monta HTML
        -----------------------------------------------------------------------------------------*/
        SET @html =
            N'<div style="font-family: Arial, sans-serif; font-size: 13px; color: #333;">' +
              N'<div style="display:flex; align-items:center; gap:16px; border-bottom:2px solid ' + @nm_cor_empresa + N'; padding-bottom:12px;">' +
                N'<div><img src="' + @logo + N'" alt="Logo" style="height:60px;"></div>' +
                N'<div>' +
                  N'<div style="font-size:18px; font-weight:bold;">' + @nm_fantasia_empresa + N'</div>' +
                  N'<div>' + @nm_endereco_empresa + N', ' + @cd_numero_endereco + N' - ' + @nm_bairro_empresa + N'</div>' +
                  N'<div>' + @nm_cidade_empresa + N'/' + @sg_estado_empresa + N' - CEP ' + @cd_cep_empresa + N'</div>' +
                  N'<div>Telefone: ' + @cd_telefone_empresa + N' | E-mail: ' + @nm_email_internet + N'</div>' +
                N'</div>' +
              N'</div>' +

              N'<h2 style="margin:16px 0 8px; color:' + @nm_cor_empresa + N';">' + @titulo + N'</h2>' +

              N'<div style="display:flex; flex-wrap:wrap; gap:24px;">' +
                N'<div style="flex:1; min-width:240px;">' +
                  N'<h3 style="margin-bottom:6px;">Dados da Nota</h3>' +
                  N'<div><strong>Número:</strong> ' + CAST(@cd_nota_debito_despesa AS VARCHAR(20)) + N'</div>' +
                  N'<div><strong>Emissão:</strong> ' + ISNULL(CONVERT(VARCHAR(10), @dt_nota_debito_despesa, 103), '') + N'</div>' +
                  N'<div><strong>Vencimento:</strong> ' + ISNULL(CONVERT(VARCHAR(10), @dt_vencimento_nota_debito, 103), '') + N'</div>' +
                  N'<div><strong>Período:</strong> ' + ISNULL(CONVERT(VARCHAR(10), @dt_inicio_ref_nota_debito, 103), '') + N' a ' + ISNULL(CONVERT(VARCHAR(10), @dt_final_ref_nota_debito, 103), '') + N'</div>' +
                  N'<div><strong>Referência:</strong> ' + ISNULL(@nm_ref_nota_debito, '') + N'</div>' +
                  N'<div><strong>Valor:</strong> ' + ISNULL(dbo.fn_formata_valor(@vl_nota_debito), '') + N'</div>' +
                N'</div>' +
                N'<div style="flex:1; min-width:240px;">' +
                  N'<h3 style="margin-bottom:6px;">Cliente</h3>' +
                  N'<div><strong>Fantasia:</strong> ' + ISNULL(@nm_fantasia_cliente, '') + N'</div>' +
                  N'<div><strong>Razão Social:</strong> ' + ISNULL(@nm_razao_social_cliente, '') + N'</div>' +
                  N'<div><strong>Telefone:</strong> ' + ISNULL(@telefone_cliente, '') + N'</div>' +
                  N'<div><strong>Contato:</strong> ' + ISNULL(@nm_fantasia_contato, '') + N'</div>' +
                  N'<div><strong>Identificação Cliente:</strong> ' + ISNULL(@cd_identificacao_cliente, '') + N'</div>' +
                N'</div>' +
              N'</div>' +

              N'<div style="margin-top:16px; display:flex; flex-wrap:wrap; gap:24px;">' +
                N'<div style="flex:1; min-width:240px;">' +
                  N'<h3 style="margin-bottom:6px;">Banco / Portador</h3>' +
                  N'<div><strong>Banco:</strong> ' + ISNULL(@nm_fantasia_banco, '') + N' (' + ISNULL(@cd_numero_banco, '') + N')</div>' +
                  N'<div><strong>Agência:</strong> ' + ISNULL(@cd_numero_agencia_banco, '') + N' - ' + ISNULL(@nm_agencia_banco, '') + N'</div>' +
                  N'<div><strong>Conta:</strong> ' + ISNULL(@nm_conta_banco, '') + N'</div>' +
                  N'<div><strong>Portador:</strong> ' + ISNULL(@nm_portador, '') + N'</div>' +
                N'</div>' +
                N'<div style="flex:1; min-width:240px;">' +
                  N'<h3 style="margin-bottom:6px;">Outros</h3>' +
                  N'<div><strong>Centro de Custo:</strong> ' + ISNULL(@nm_centro_custo, '') + N'</div>' +
                  N'<div><strong>Analista:</strong> ' + ISNULL(@nm_analista, '') + N'</div>' +
                  N'<div><strong>Nota Fiscal:</strong> ' + ISNULL(@cd_identificacao_nota_saida, '') + N'</div>' +
                N'</div>' +
              N'</div>' +

              N'<div style="margin-top:16px;">' +
                N'<h3 style="margin-bottom:6px;">Descrição</h3>' +
                N'<p style="margin:0;">' + ISNULL(@ds_nota_debito, '') + N'</p>' +
              N'</div>' +

              N'<div style="margin-top:16px;">' +
                N'<h3 style="margin-bottom:6px;">Despesas</h3>' +
                N'<table style="width:100%; border-collapse:collapse; font-size:12px;">' +
                  N'<thead>' +
                    N'<tr style="background:#f5f5f5;">' +
                      N'<th style="border:1px solid #ddd; padding:6px; text-align:left;">Tipo</th>' +
                      N'<th style="border:1px solid #ddd; padding:6px; text-align:right;">Quantidade</th>' +
                      N'<th style="border:1px solid #ddd; padding:6px; text-align:right;">Valor Unit.</th>' +
                      N'<th style="border:1px solid #ddd; padding:6px; text-align:right;">Total</th>' +
                      N'<th style="border:1px solid #ddd; padding:6px; text-align:left;">Observação</th>' +
                      N'<th style="border:1px solid #ddd; padding:6px; text-align:left;">Data</th>' +
                      N'<th style="border:1px solid #ddd; padding:6px; text-align:left;">Documento</th>' +
                    N'</tr>' +
                  N'</thead>' +
                  N'<tbody>' +
                    ISNULL(@html_itens, N'') +
                  N'</tbody>' +
                N'</table>' +
              N'</div>' +

              N'<div style="margin-top:16px; text-align:right; font-weight:bold;">' +
                N'Total Nota Débito: ' + ISNULL(dbo.fn_formata_valor(@vl_nota_debito), '') +
              N'</div>' +

              N'<div style="margin-top:12px; font-size:12px; color:#666;">Emitido em ' + @data_hora_atual + N'</div>' +
            N'</div>';

        SELECT ISNULL(@html, N'') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, @ErrorMessage, 1;
    END CATCH
END;
GO

--exec pr_egis_relatorio_nota_debito '[{"cd_nota_debito": 1}]'
