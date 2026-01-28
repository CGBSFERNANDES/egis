IF OBJECT_ID('dbo.pr_egis_relatorio_solicitacao_adiantamento', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_solicitacao_adiantamento;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_solicitacao_adiantamento
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-05
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Solicitação de Adiantamento (cd_relatorio = 438)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Entrada: @json = '[{"cd_solicitacao": <int>}]'
    - Retorna HTML no padrão RelatorioHTML
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_solicitacao_adiantamento
    @json NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_relatorio              INT           = 438,
        @cd_empresa                INT           = NULL,
        @cd_usuario                INT           = NULL,
        @cd_solicitacao            INT           = NULL,
        @data_hora_atual           VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

    DECLARE
        @titulo                    VARCHAR(200)  = 'Solicitação de Adiantamento',
        @logo                      VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
        @nm_cor_empresa            VARCHAR(20)   = '#1976D2',
        @nm_endereco_empresa       VARCHAR(200)  = '',
        @cd_numero_endereco        VARCHAR(20)   = '',
        @nm_bairro_empresa         VARCHAR(80)   = '',
        @cd_cep_empresa            VARCHAR(20)   = '',
        @nm_cidade_empresa         VARCHAR(80)   = '',
        @sg_estado_empresa         VARCHAR(10)   = '',
        @cd_telefone_empresa       VARCHAR(200)  = '',
        @nm_email_internet         VARCHAR(200)  = '',
        @nm_fantasia_empresa       VARCHAR(200)  = '';

    DECLARE
        @dt_solicitacao            DATE          = NULL,
        @dt_vencimento             DATE          = NULL,
        @vl_adiantamento           DECIMAL(18,2) = NULL,
        @nm_funcionario            VARCHAR(200)  = NULL,
        @cd_chapa_funcionario      VARCHAR(60)   = NULL,
        @nm_setor_funcionario      VARCHAR(200)  = NULL,
        @nm_departamento           VARCHAR(200)  = NULL,
        @nm_finalidade_adiantamento VARCHAR(200) = NULL,
        @nm_usuario_liberacao      VARCHAR(200)  = NULL,
        @dias                      INT           = NULL,
        @sg_moeda                  VARCHAR(20)   = NULL,
        @dt_requisicao_viagem      DATE          = NULL,
        @ds_requisicao_viagem      VARCHAR(200)  = NULL,
        @nm_tipo_adiantamento      VARCHAR(200)  = NULL,
        @nm_centro_custo           VARCHAR(200)  = NULL,
        @nm_cartao_credito         VARCHAR(200)  = NULL,
        @nm_assunto_viagem         VARCHAR(200)  = NULL,
        @nm_funcionario_autorizacao VARCHAR(200) = NULL;

    DECLARE
        @html NVARCHAR(MAX) = '';

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Normaliza JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
        IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

        SELECT
            1                                                 AS id_registro,
            IDENTITY(INT, 1, 1)                               AS id,
            valores.[key] COLLATE SQL_Latin1_General_CP1_CI_AI AS campo,
            valores.[value]                                   AS valor
        INTO #json
        FROM openjson(@json) AS root
        CROSS APPLY openjson(root.value) AS valores;

        SELECT @cd_solicitacao = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_solicitacao';

        SELECT @cd_usuario = TRY_CAST(valor AS INT)
        FROM #json
        WHERE campo = 'cd_usuario';

        IF ISNULL(@cd_solicitacao, 0) = 0
            THROW 50002, 'cd_solicitacao não informado.', 1;

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
            @nm_bairro_empresa   = ISNULL(e.nm_bairro_empresa, '')
        FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)
        LEFT JOIN Estado AS es WITH (NOLOCK)
            ON es.cd_estado = e.cd_estado
        LEFT JOIN Cidade AS c WITH (NOLOCK)
            ON c.cd_cidade = e.cd_cidade
           AND c.cd_estado = e.cd_estado
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          3) Dados da solicitação de adiantamento
        -----------------------------------------------------------------------------------------*/
        SELECT DISTINCT
            sa.cd_solicitacao,
            sa.dt_solicitacao,
            sa.dt_vencimento,
            sa.vl_adiantamento,
            f.nm_funcionario,
            f.cd_chapa_funcionario,
            f.nm_setor_funcionario,
            d.nm_departamento,
            fa.nm_finalidade_adiantamento,
            u.nm_usuario AS nm_usuario_liberacao,
            DATEDIFF(DAY, sa.dt_vencimento, GETDATE()) AS dias,
            m.sg_moeda,
            rv.dt_requisicao_viagem,
            tv.nm_tipo_viagem + ' - ' + av.nm_assunto_viagem AS ds_requisicao_viagem,
            ta.nm_tipo_adiantamento,
            cc.nm_centro_custo,
            ct.nm_cartao_credito,
            av.nm_assunto_viagem,
            fl.nm_funcionario AS nm_funcionario_autorizacao
        INTO #solicitacao
        FROM Solicitacao_Adiantamento AS sa WITH (NOLOCK)
        LEFT JOIN Funcionario AS f WITH (NOLOCK)
            ON sa.cd_funcionario = f.cd_funcionario
        LEFT JOIN Funcionario AS fl WITH (NOLOCK)
            ON fl.cd_funcionario = sa.cd_funcionario_liberacao
        LEFT JOIN Departamento AS d WITH (NOLOCK)
            ON d.cd_departamento = sa.cd_departamento
        LEFT JOIN Centro_Custo AS cc WITH (NOLOCK)
            ON cc.cd_centro_custo = sa.cd_centro_custo
        LEFT JOIN Finalidade_Adiantamento AS fa WITH (NOLOCK)
            ON sa.cd_finalidade_adiantamento = fa.cd_finalidade_adiantamento
        LEFT JOIN egisadmin.dbo.Usuario AS u WITH (NOLOCK)
            ON u.cd_usuario = sa.cd_usuario_liberacao
        LEFT JOIN Solicitacao_Adiantamento_Baixa AS sab WITH (NOLOCK)
            ON sab.cd_solicitacao = sa.cd_solicitacao
        LEFT JOIN Moeda AS m WITH (NOLOCK)
            ON m.cd_moeda = sa.cd_moeda
        LEFT JOIN Requisicao_Viagem AS rv WITH (NOLOCK)
            ON rv.cd_requisicao_viagem = sa.cd_requisicao_viagem
        LEFT JOIN Assunto_Viagem AS av WITH (NOLOCK)
            ON av.cd_assunto_viagem = ISNULL(rv.cd_assunto_viagem, sa.cd_assunto_viagem)
        LEFT JOIN Tipo_Viagem AS tv WITH (NOLOCK)
            ON rv.cd_tipo_viagem = tv.cd_tipo_viagem
        LEFT JOIN Tipo_Adiantamento AS ta WITH (NOLOCK)
            ON ta.cd_tipo_adiantamento = sa.cd_tipo_adiantamento
        LEFT JOIN Tipo_Cartao_Credito AS ct WITH (NOLOCK)
            ON ct.cd_cartao_credito = sa.cd_cartao_credito
        WHERE sa.cd_solicitacao = @cd_solicitacao;

        IF NOT EXISTS (SELECT 1 FROM #solicitacao)
            THROW 50003, 'Solicitação de adiantamento não encontrada.', 1;

        SELECT TOP 1
            @dt_solicitacao             = dt_solicitacao,
            @dt_vencimento              = dt_vencimento,
            @vl_adiantamento            = vl_adiantamento,
            @nm_funcionario             = nm_funcionario,
            @cd_chapa_funcionario       = cd_chapa_funcionario,
            @nm_setor_funcionario       = nm_setor_funcionario,
            @nm_departamento            = nm_departamento,
            @nm_finalidade_adiantamento = nm_finalidade_adiantamento,
            @nm_usuario_liberacao       = nm_usuario_liberacao,
            @dias                       = dias,
            @sg_moeda                   = sg_moeda,
            @dt_requisicao_viagem       = dt_requisicao_viagem,
            @ds_requisicao_viagem       = ds_requisicao_viagem,
            @nm_tipo_adiantamento       = nm_tipo_adiantamento,
            @nm_centro_custo            = nm_centro_custo,
            @nm_cartao_credito          = nm_cartao_credito,
            @nm_assunto_viagem          = nm_assunto_viagem,
            @nm_funcionario_autorizacao = nm_funcionario_autorizacao
        FROM #solicitacao
        ORDER BY cd_solicitacao DESC;

        /*-----------------------------------------------------------------------------------------
          4) Monta HTML
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
                  N'<h3 style="margin-bottom:6px;">Dados da Solicitação</h3>' +
                  N'<div><strong>Número:</strong> ' + CAST(@cd_solicitacao AS VARCHAR(20)) + N'</div>' +
                  N'<div><strong>Data:</strong> ' + ISNULL(CONVERT(VARCHAR(10), @dt_solicitacao, 103), '') + N'</div>' +
                  N'<div><strong>Vencimento:</strong> ' + ISNULL(CONVERT(VARCHAR(10), @dt_vencimento, 103), '') + N'</div>' +
                  N'<div><strong>Dias:</strong> ' + CAST(ISNULL(@dias, 0) AS VARCHAR(20)) + N'</div>' +
                  N'<div><strong>Valor:</strong> ' + ISNULL(dbo.fn_formata_valor(@vl_adiantamento), '') + N'</div>' +
                  N'<div><strong>Moeda:</strong> ' + ISNULL(@sg_moeda, '') + N'</div>' +
                N'</div>' +
                N'<div style="flex:1; min-width:240px;">' +
                  N'<h3 style="margin-bottom:6px;">Solicitante</h3>' +
                  N'<div><strong>Funcionário:</strong> ' + ISNULL(@nm_funcionario, '') + N'</div>' +
                  N'<div><strong>Chapa:</strong> ' + ISNULL(@cd_chapa_funcionario, '') + N'</div>' +
                  N'<div><strong>Setor:</strong> ' + ISNULL(@nm_setor_funcionario, '') + N'</div>' +
                  N'<div><strong>Departamento:</strong> ' + ISNULL(@nm_departamento, '') + N'</div>' +
                  N'<div><strong>Centro de Custo:</strong> ' + ISNULL(@nm_centro_custo, '') + N'</div>' +
                N'</div>' +
              N'</div>' +

              N'<div style="margin-top:16px; display:flex; flex-wrap:wrap; gap:24px;">' +
                N'<div style="flex:1; min-width:240px;">' +
                  N'<h3 style="margin-bottom:6px;">Finalidade</h3>' +
                  N'<div><strong>Finalidade:</strong> ' + ISNULL(@nm_finalidade_adiantamento, '') + N'</div>' +
                  N'<div><strong>Tipo de Adiantamento:</strong> ' + ISNULL(@nm_tipo_adiantamento, '') + N'</div>' +
                  N'<div><strong>Cartão de Crédito:</strong> ' + ISNULL(@nm_cartao_credito, '') + N'</div>' +
                N'</div>' +
                N'<div style="flex:1; min-width:240px;">' +
                  N'<h3 style="margin-bottom:6px;">Viagem</h3>' +
                  N'<div><strong>Data Requisição:</strong> ' + ISNULL(CONVERT(VARCHAR(10), @dt_requisicao_viagem, 103), '') + N'</div>' +
                  N'<div><strong>Requisição:</strong> ' + ISNULL(@ds_requisicao_viagem, '') + N'</div>' +
                  N'<div><strong>Assunto:</strong> ' + ISNULL(@nm_assunto_viagem, '') + N'</div>' +
                N'</div>' +
              N'</div>' +

              N'<div style="margin-top:16px; display:flex; flex-wrap:wrap; gap:24px;">' +
                N'<div style="flex:1; min-width:240px;">' +
                  N'<h3 style="margin-bottom:6px;">Liberação</h3>' +
                  N'<div><strong>Usuário:</strong> ' + ISNULL(@nm_usuario_liberacao, '') + N'</div>' +
                  N'<div><strong>Funcionário Autorização:</strong> ' + ISNULL(@nm_funcionario_autorizacao, '') + N'</div>' +
                N'</div>' +
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

--select * from solicitacao_adiantamento

--exec pr_egis_relatorio_solicitacao_adiantamento '[{"cd_solicitacao": 11}]'
