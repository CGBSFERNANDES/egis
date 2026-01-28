IF OBJECT_ID('dbo.pr_egis_relatorio_prestacao_conta', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_prestacao_conta;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_prestacao_conta
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-05
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Prestação de Contas (cd_relatorio = 437)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Entrada: @json = '[{"cd_prestacao": <int>}]'
    - Retorna HTML no padrão RelatorioHTML
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_prestacao_conta
    @json NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_relatorio              INT          = 437,
        @cd_empresa                INT          = NULL,
        @cd_usuario                INT          = NULL,
        @cd_prestacao              INT          = NULL,
        @ic_nao_reembolsavel       CHAR(1)      = 'N',
        @ic_cartao_credito         CHAR(1)      = 'N',
        @ic_imposto                CHAR(1)      = 'N',
        @pc_imposto                FLOAT        = 0,
        @vl_adiantamento           FLOAT        = 0,
        @vl_despesas               FLOAT        = 0,
        @vl_nao_reembolsavel       FLOAT        = 0,
        @vl_reembolsavel           FLOAT        = 0,
        @vl_resultado              FLOAT        = 0,
        @vl_devolucao_moeda        FLOAT        = 0,
        @vl_imposto_prestacao      FLOAT        = 0,
        @ic_tipo_deposito_prestacao CHAR(1)     = '';

    DECLARE
        @titulo                VARCHAR(200) = 'Prestação de Contas',
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
        @vl_receber FLOAT = 0,
        @vl_pagar   FLOAT = 0;

    DECLARE
        @dt_prestacao              DATE,
        @nm_tipo_prestacao         VARCHAR(200),
        @nm_motivo_prestacao       VARCHAR(200),
        @nm_funcionario            VARCHAR(200),
        @cd_chapa_funcionario      VARCHAR(60),
        @cd_cpf_funcionario        VARCHAR(60),
        @nm_setor_funcionario      VARCHAR(200),
        @nm_departamento           VARCHAR(200),
        @nm_centro_custo           VARCHAR(200),
        @nm_banco                  VARCHAR(200),
        @cd_banco                  VARCHAR(30),
        @cd_agencia_funcionario    VARCHAR(60),
        @cd_conta_funcionario      VARCHAR(60),
        @nm_moeda                  VARCHAR(200),
        @nm_local_viagem           VARCHAR(200),
        @dt_inicio_viagem          DATE,
        @dt_fim_viagem             DATE,
        @nm_projeto_viagem         VARCHAR(200),
        @cd_identificacao_projeto  VARCHAR(200),
        @nm_assunto_viagem         VARCHAR(200),
        @nm_cartao_credito         VARCHAR(200),
        @nm_funcionario_autorizacao VARCHAR(200),
        @vl_prestacao_corrigido    FLOAT,
        @vl_total_prestacao_moeda  FLOAT;

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

        SELECT @cd_prestacao = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_prestacao';

        SELECT @cd_usuario = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_usuario';

        IF ISNULL(@cd_prestacao, 0) = 0
            THROW 50002, 'cd_prestacao não informado.', 1;

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
          3) Dados da prestação
        -----------------------------------------------------------------------------------------*/
        SELECT
            pc.cd_prestacao,
            pc.dt_prestacao,
            tpc.nm_tipo_prestacao,
            mpc.nm_motivo_prestacao,
            f.nm_funcionario,
            f.cd_chapa_funcionario,
            f.nm_setor_funcionario,
            f.cd_cpf_funcionario,
            f.cd_agencia_funcionario,
            f.cd_conta_funcionario,
            f.cd_banco,
            b.nm_banco,
            m.nm_fantasia_moeda,
            d.nm_departamento,
            c.nm_centro_custo,
            rv.nm_local_viagem,
            rv.dt_inicio_viagem,
            rv.dt_fim_viagem,
            pv.nm_projeto_viagem,
            pv.cd_identificacao_projeto,
            av.nm_assunto_viagem,
            tcc.nm_cartao_credito,
            ISNULL(pc.vl_prestacao, 0)
                * CASE WHEN ISNULL(pc.vl_prestacao, 0) < 0 THEN -1 ELSE 1 END AS vl_prestacao_corrigido,
            (
                SELECT
                    SUM(ISNULL(pcm.vl_total_prestacao_moeda, 0))
                FROM prestacao_conta_moeda AS pcm
                WHERE pcm.cd_prestacao = pc.cd_prestacao
                  AND ISNULL(pcm.ic_tipo_lancamento, 'A') = 'M'
            ) AS vl_total_prestacao_moeda,
            fl.nm_funcionario AS nm_funcionario_autorizacao
        INTO #prestacao
        FROM Prestacao_Conta AS pc WITH (NOLOCK)
        LEFT JOIN Tipo_Prestacao_Conta AS tpc
            ON pc.cd_tipo_prestacao = tpc.cd_tipo_prestacao
        LEFT JOIN Motivo_Prestacao_Conta AS mpc
            ON mpc.cd_motivo_prestacao = pc.cd_motivo_prestacao
        LEFT JOIN Funcionario AS f
            ON f.cd_funcionario = pc.cd_funcionario
        LEFT JOIN Funcionario AS fl
            ON pc.cd_funcionario_liberacao = fl.cd_funcionario
        LEFT JOIN Moeda AS m
            ON m.cd_moeda = pc.cd_moeda
        LEFT JOIN Departamento AS d
            ON d.cd_departamento = pc.cd_departamento
        LEFT JOIN Centro_Custo AS c
            ON c.cd_centro_custo = pc.cd_centro_custo
        LEFT JOIN Requisicao_Viagem AS rv
            ON rv.cd_requisicao_viagem = pc.cd_requisicao_viagem
        LEFT JOIN Projeto_Viagem AS pv
            ON pv.cd_projeto_viagem = rv.cd_projeto_viagem
        LEFT JOIN Banco AS b
            ON b.cd_banco = f.cd_banco
        LEFT JOIN Assunto_Viagem AS av
            ON av.cd_assunto_viagem = pc.cd_assunto_viagem
        LEFT JOIN Tipo_Cartao_Credito AS tcc
            ON tcc.cd_cartao_credito = pc.cd_cartao_credito
        WHERE pc.cd_prestacao = @cd_prestacao;

        IF NOT EXISTS (SELECT 1 FROM #prestacao)
            THROW 50003, 'Prestação de contas não encontrada.', 1;

        SELECT TOP (1)
            @dt_prestacao               = dt_prestacao,
            @nm_tipo_prestacao          = nm_tipo_prestacao,
            @nm_motivo_prestacao        = nm_motivo_prestacao,
            @nm_funcionario             = nm_funcionario,
            @cd_chapa_funcionario       = cd_chapa_funcionario,
            @cd_cpf_funcionario         = cd_cpf_funcionario,
            @nm_setor_funcionario       = nm_setor_funcionario,
            @nm_departamento            = nm_departamento,
            @nm_centro_custo            = nm_centro_custo,
            @nm_banco                   = nm_banco,
            @cd_banco                   = cd_banco,
            @cd_agencia_funcionario     = cd_agencia_funcionario,
            @cd_conta_funcionario       = cd_conta_funcionario,
            @nm_moeda                   = nm_fantasia_moeda,
            @nm_local_viagem            = nm_local_viagem,
            @dt_inicio_viagem           = dt_inicio_viagem,
            @dt_fim_viagem              = dt_fim_viagem,
            @nm_projeto_viagem          = nm_projeto_viagem,
            @cd_identificacao_projeto   = cd_identificacao_projeto,
            @nm_assunto_viagem          = nm_assunto_viagem,
            @nm_cartao_credito          = nm_cartao_credito,
            @nm_funcionario_autorizacao = nm_funcionario_autorizacao,
            @vl_prestacao_corrigido     = vl_prestacao_corrigido,
            @vl_total_prestacao_moeda   = vl_total_prestacao_moeda
        FROM #prestacao;

        /*-----------------------------------------------------------------------------------------
          4) Parametrizações e totais
        -----------------------------------------------------------------------------------------*/
        SELECT
            @ic_imposto = ISNULL(ic_imposto, 'N'),
            @pc_imposto = ISNULL(pc_imposto, 0)
        FROM parametro_prestacao_conta
        WHERE cd_empresa = @cd_empresa;

        --SELECT
        --    @ic_nao_reembolsavel = ISNULL(pc.ic_nao_reembolsavel, 'N'),
        --    @ic_cartao_credito = ISNULL(pc.ic_cartao_credito, 'N')
        --FROM Prestacao_Conta AS pc WITH (NOLOCK)
        --WHERE pc.cd_prestacao = @cd_prestacao;

        SELECT
            @vl_devolucao_moeda = ISNULL(SUM(ISNULL(vl_total_prestacao_moeda, 0)), 0)
        FROM Prestacao_Conta_Moeda
        WHERE cd_prestacao = @cd_prestacao
          AND ISNULL(ic_tipo_lancamento, 'M') = 'M';

        SELECT
            @vl_adiantamento = ISNULL(SUM(ISNULL(vl_adiantamento, 0)), 0)
        FROM Solicitacao_Adiantamento
        WHERE cd_prestacao = @cd_prestacao;

        SELECT
            @vl_despesas = ISNULL(SUM(ISNULL(vl_total_despesa, 0)), 0)
        FROM prestacao_conta_composicao AS pcc
        LEFT JOIN tipo_despesa AS td
            ON td.cd_tipo_despesa = pcc.cd_tipo_despesa
        WHERE pcc.cd_prestacao = @cd_prestacao;

        SELECT
            @vl_nao_reembolsavel = ISNULL(SUM(ISNULL(vl_total_despesa, 0)), 0)
        FROM prestacao_conta_composicao AS pcc
        LEFT JOIN tipo_despesa AS td
            ON td.cd_tipo_despesa = pcc.cd_tipo_despesa
        WHERE pcc.cd_prestacao = @cd_prestacao
          AND ISNULL(td.ic_reembolsavel_despesa, 'N') = 'N';

        SELECT
            @vl_reembolsavel = ISNULL(SUM(ISNULL(vl_total_despesa, 0)), 0)
        FROM prestacao_conta_composicao AS pcc
        LEFT JOIN tipo_despesa AS td
            ON td.cd_tipo_despesa = pcc.cd_tipo_despesa
        WHERE pcc.cd_prestacao = @cd_prestacao
          AND ISNULL(td.ic_reembolsavel_despesa, 'N') = 'S';

        IF ISNULL(@ic_nao_reembolsavel, 'N') = 'N'
        BEGIN
            SET @vl_resultado = @vl_despesas - (@vl_adiantamento - @vl_devolucao_moeda);
        END
        ELSE
        BEGIN
            SET @vl_resultado = (@vl_despesas - (@vl_adiantamento - @vl_devolucao_moeda)) - @vl_nao_reembolsavel;
        END

        IF @vl_resultado < 0
            SET @ic_tipo_deposito_prestacao = 'E';
        ELSE IF @vl_resultado > 0
            SET @ic_tipo_deposito_prestacao = 'F';
        ELSE
            SET @ic_tipo_deposito_prestacao = '';

        SET @vl_imposto_prestacao = 0;

        IF @ic_imposto = 'S' AND @ic_cartao_credito = 'N'
        BEGIN
            SET @vl_imposto_prestacao = @vl_reembolsavel
                * (CASE WHEN @vl_reembolsavel < 0 THEN -1 ELSE 1 END)
                * (@pc_imposto / 100);
            SET @vl_resultado = @vl_resultado + ISNULL(@vl_imposto_prestacao, 0);
        END

        /*-----------------------------------------------------------------------------------------
          5) Itens da composição da prestação
        -----------------------------------------------------------------------------------------*/
        SELECT
            td.nm_tipo_despesa,
            cc.sg_centro_custo,
            pcc.vl_total_despesa
        INTO #composicao
        FROM prestacao_conta_composicao AS pcc
        LEFT JOIN tipo_despesa AS td
            ON td.cd_tipo_despesa = pcc.cd_tipo_despesa
        LEFT JOIN Centro_Custo AS cc
            ON cc.cd_centro_custo = pcc.cd_centro_custo
        WHERE pcc.cd_prestacao = @cd_prestacao;

        SELECT
            @html_itens = (
                SELECT
                    N'<tr>' +
                    N'<td style="text-align:center;">' + CAST(ROW_NUMBER() OVER (ORDER BY nm_tipo_despesa) AS NVARCHAR(10)) + N'</td>' +
                    N'<td>' + ISNULL(nm_tipo_despesa, '') + N'</td>' +
                    N'<td></td>' +
                    N'<td style="text-align:right;"></td>' +
                    N'<td style="text-align:right;"></td>' +
                    N'<td style="text-align:right;">' + ISNULL(dbo.fn_formata_valor(vl_total_despesa), '') + N'</td>' +
                    N'<td></td>' +
                    N'<td></td>' +
                    N'<td style="text-align:center;">' + ISNULL(sg_centro_custo, '') + N'</td>' +
                    N'</tr>'
                FROM #composicao
                ORDER BY nm_tipo_despesa
                FOR XML PATH(''), TYPE
            ).value('.', 'nvarchar(max)');

        IF NULLIF(@html_itens, '') IS NULL
            SET @html_itens = N'<tr><td colspan="3" style="text-align:center;">Sem itens</td></tr>';

        /*-----------------------------------------------------------------------------------------
          6) Montagem do HTML
        -----------------------------------------------------------------------------------------*/
        SET @vl_receber = CASE WHEN @vl_resultado > 0 THEN @vl_resultado ELSE 0 END;
        SET @vl_pagar = CASE WHEN @vl_resultado < 0 THEN @vl_resultado * -1 ELSE 0 END;

        SET @html =
            N'<!DOCTYPE html>' +
            N'<html><head><meta charset="utf-8" />' +
            N'<style>' +
            N'body{font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#000;margin:0;}' +
            N'.container{width:100%;border:1px solid #333;}' +
            N'.header{width:100%;border-bottom:1px solid #333;}' +
            N'.header td{vertical-align:middle;padding:8px;}' +
            N'.title{font-size:22px;font-weight:bold;text-align:center;padding:6px 0;}' +
            N'.subtitle{font-size:12px;text-align:center;padding:4px 0;border-top:1px solid #333;border-bottom:1px solid #333;}' +
            N'.info{width:100%;border-collapse:collapse;}' +
            N'.info td{padding:4px 6px;}' +
            N'.label{font-weight:bold;}' +
            N'.section{border-top:1px solid #333;border-bottom:1px solid #333;font-weight:bold;padding:4px 6px;}' +
            N'.bar{background:#e5e5e5;font-weight:bold;text-align:center;border-top:1px solid #333;border-bottom:1px solid #333;padding:4px 6px;}' +
            N'.table{width:100%;border-collapse:collapse;}' +
            N'.table th,.table td{border:1px solid #333;padding:4px 6px;}' +
            N'.table th{background:#f2f2f2;text-align:center;}' +
            N'.total{font-weight:bold;text-align:center;border:1px solid #333;padding:6px;}' +
            N'</style></head><body>' +
            N'<table class="container" cellpadding="0" cellspacing="0">' +
            N'<tr><td>' +
            N'<table class="header" cellpadding="0" cellspacing="0">' +
            N'<tr>' +
            N'<td style="width:35%;"><img src="' + @logo + N'" style="max-width:160px;"></td>' +
            N'<td style="width:30%;text-align:center;font-weight:bold;">' + ISNULL(@nm_fantasia_empresa, '') + N'</td>' +
            N'<td style="width:35%;text-align:right;font-weight:bold;">DATA/HORA: ' + ISNULL(@data_hora_atual, '') + N'</td>' +
            N'</tr>' +
            N'</table>' +
            N'</td></tr>' +
            N'<tr><td class="title">' + ISNULL(@nm_titulo_relatorio, @titulo) + N'</td></tr>' +
            N'<tr><td class="subtitle">O PRESENTE RELATÓRIO VISA O ACERTO E A LIQUIDAÇÃO DAS DESPESAS ABAIXO APRESENTADAS</td></tr>' +

            N'<tr><td>' +
            N'<table class="info" cellpadding="0" cellspacing="0">' +
            N'<tr>' +
            N'<td class="label">Data da Prestação:</td><td>' + ISNULL(CONVERT(VARCHAR, @dt_prestacao, 103), '') + N'</td>' +
            N'<td class="label" style="text-align:right;">Prestação Nº:</td><td style="text-align:right;">' + CAST(@cd_prestacao AS VARCHAR(20)) + N'</td>' +
            N'</tr>' +
            N'<tr>' +
            N'<td class="label">Funcionário:</td><td>' + ISNULL(@nm_funcionario, '') + N'</td>' +
            N'<td class="label" style="text-align:right;">Matrícula:</td><td style="text-align:right;">' + ISNULL(@cd_chapa_funcionario, '') + N'</td>' +
            N'</tr>' +
            N'<tr>' +
            N'<td class="label">Departamento:</td><td>' + ISNULL(@nm_departamento, '') + N'</td>' +
            N'<td class="label" style="text-align:right;">CPF:</td><td style="text-align:right;">' + ISNULL(@cd_cpf_funcionario, '') + N'</td>' +
            N'</tr>' +
            N'<tr>' +
            N'<td class="label">Banco:</td><td>' + ISNULL(@nm_banco, '') + N'</td>' +
            N'<td class="label" style="text-align:right;">Agência:</td><td style="text-align:right;">' + ISNULL(@cd_agencia_funcionario, '') + N'</td>' +
            N'</tr>' +
            N'<tr>' +
            N'<td class="label">Conta:</td><td>' + ISNULL(@cd_conta_funcionario, '') + N'</td>' +
            N'<td class="label" style="text-align:right;">Centro de Custo:</td><td style="text-align:right;">' + ISNULL(@nm_centro_custo, '') + N'</td>' +
            N'</tr>' +
            N'<tr>' +
            N'<td class="label">Período:</td><td>' + ISNULL(CONVERT(VARCHAR, @dt_inicio_viagem, 103), '') + N' a ' +
                ISNULL(CONVERT(VARCHAR, @dt_fim_viagem, 103), '') + N'</td>' +
            N'<td class="label" style="text-align:right;">Local:</td><td style="text-align:right;">' + ISNULL(@nm_local_viagem, '') + N'</td>' +
            N'</tr>' +
            N'<tr>' +
            N'<td class="label">Assunto:</td><td>' + ISNULL(@nm_assunto_viagem, '') + N'</td>' +
            N'<td class="label" style="text-align:right;">Cartão de Crédito:</td><td style="text-align:right;">' + ISNULL(@nm_cartao_credito, '') + N'</td>' +
            N'</tr>' +
            N'</table>' +
            N'</td></tr>' +

            N'<tr><td class="section">A Receber</td></tr>' +
            N'<tr><td style="padding:4px 6px;">' + ISNULL(dbo.fn_formata_valor(@vl_receber), '') + N'</td></tr>' +
            N'<tr><td class="section">A Pagar</td></tr>' +
            N'<tr><td style="padding:4px 6px;">' + ISNULL(dbo.fn_formata_valor(@vl_pagar), '') + N'</td></tr>' +
            N'<tr><td class="section">Importante</td></tr>' +
            N'<tr><td style="padding:4px 6px;"></td></tr>' +

            N'<tr><td class="bar">Discriminação das Despesas</td></tr>' +
            N'<tr><td>' +
            N'<table class="table" cellpadding="0" cellspacing="0">' +
            N'<tr>' +
            N'<th>Item</th>' +
            N'<th>Despesa</th>' +
            N'<th>Nº Doc</th>' +
            N'<th>Qtd.</th>' +
            N'<th>Vl. Unitário</th>' +
            N'<th>Valor Total</th>' +
            N'<th>Cliente/Finalidade</th>' +
            N'<th>Observação</th>' +
            N'<th>C.C.</th>' +
            N'</tr>' +
            ISNULL(@html_itens, '') +
            N'</table>' +
            N'</td></tr>' +

            N'<tr><td class="total">Total de Despesas: ' + ISNULL(dbo.fn_formata_valor(@vl_despesas), '') + N'</td></tr>' +
            N'<tr><td class="bar">RESUMO</td></tr>' +
            N'</table>' +
            N'</body></html>';

        /*-----------------------------------------------------------------------------------------
          7) Retorno do relatório
        -----------------------------------------------------------------------------------------*/
        SELECT ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE
            @ds_erro  NVARCHAR(4000) = ERROR_MESSAGE(),
            @cd_erro  INT            = ERROR_NUMBER(),
            @cd_linha INT            = ERROR_LINE();

        RAISERROR('Erro na pr_egis_relatorio_prestacao_conta (%d - linha %d): %s', 16, 1, @cd_erro, @cd_linha, @ds_erro);
    END CATCH
END;
GO

--select * from prestacao_conta 988

--exec pr_egis_relatorio_prestacao_conta '[{"cd_prestacao": 988}]'