IF OBJECT_ID('dbo.pr_egis_relatorio_contrato_servico', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_contrato_servico;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_contrato_servico
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-05
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Contrato de Serviços (cd_relatorio = 422)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Entrada: @json = '[{"cd_contrato_servico": <int>}]'
    - Dados extraídos da view dbo.vw_contrato_servico_cliente
    - Retorna HTML no padrão RelatorioHTML
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_contrato_servico
    @json NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_relatorio          INT           = 422,
        @cd_empresa            INT           = NULL,
        @cd_contrato_servico   INT           = NULL,
        @titulo                VARCHAR(200)  = 'Contrato de Serviços',
        @logo                  VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
        @nm_cor_empresa        VARCHAR(20)   = '#1976D2',
        @nm_endereco_empresa   VARCHAR(200)  = '',
        @cd_numero_endereco    VARCHAR(20)   = '',
        @nm_bairro_empresa     VARCHAR(80)   = '',
        @cd_cep_empresa        VARCHAR(20)   = '',
        @nm_cidade_empresa     VARCHAR(80)   = '',
        @sg_estado_empresa     VARCHAR(10)   = '',
        @cd_telefone_empresa   VARCHAR(200)  = '',
        @nm_email_internet     VARCHAR(200)  = '',
        @nm_fantasia_empresa   VARCHAR(200)  = '',
        @cd_cnpj_empresa       VARCHAR(60)   = '',
        @nm_titulo_relatorio   VARCHAR(200)  = NULL,
        @ds_relatorio          VARCHAR(8000) = '',
        @data_hora_atual       VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Validação e normalização do JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
        IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

        IF JSON_VALUE(@json, '$[0]') IS NOT NULL
            SET @json = JSON_QUERY(@json, '$[0]');

        SELECT
            @cd_contrato_servico = TRY_CAST(JSON_VALUE(@json, '$.cd_contrato_servico') AS INT);

        IF ISNULL(@cd_contrato_servico, 0) = 0
            THROW 50002, 'cd_contrato_servico não informado.', 1;

        /*-----------------------------------------------------------------------------------------
          2) Cabeçalho do relatório (relatorio + empresa)
        -----------------------------------------------------------------------------------------*/
        SELECT
            @titulo              = ISNULL(r.nm_relatorio, @titulo),
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.relatorio AS r
        WHERE r.cd_relatorio = @cd_relatorio;

        SET @cd_empresa = dbo.fn_empresa();

        SELECT TOP (1)
            @logo                = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, @logo),
            @nm_cor_empresa      = ISNULL(e.nm_cor_empresa, '#1976D2'),
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, ''),
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, ''),
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(e.cd_numero, ''))),
            @nm_bairro_empresa   = ISNULL(e.nm_bairro_empresa, ''),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @nm_cidade_empresa   = ISNULL(c.nm_cidade, ''),
            @sg_estado_empresa   = ISNULL(est.sg_estado, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @cd_cnpj_empresa     = ISNULL(e.cd_cgc_empresa, '')
        FROM Empresa AS e
        LEFT JOIN Cidade AS c  ON c.cd_cidade  = e.cd_cidade
        LEFT JOIN Estado AS est ON est.cd_estado = c.cd_estado
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          3) Carrega dados do contrato (view obrigatória)
        -----------------------------------------------------------------------------------------*/
        SELECT TOP (1)
            *
        INTO #contrato_servico
        FROM dbo.vw_contrato_servico_cliente WITH (NOLOCK)
        WHERE cd_contrato_servico = @cd_contrato_servico;

        IF NOT EXISTS (SELECT 1 FROM #contrato_servico)
            THROW 50003, 'Contrato não encontrado em vw_contrato_servico_cliente.', 1;

        /*-----------------------------------------------------------------------------------------
          4) Converte o registro do contrato em pares Campo/Valor (sem cursor)
        -----------------------------------------------------------------------------------------*/
        CREATE TABLE #contrato_campos
        (
            ordem INT NOT NULL,
            campo NVARCHAR(200) NOT NULL,
            valor NVARCHAR(MAX) NULL
        );

        DECLARE @sql NVARCHAR(MAX) = N'';

        SELECT @sql = @sql +
            N'INSERT INTO #contrato_campos (ordem, campo, valor) ' +
            N'SELECT ' + CAST(c.column_id AS NVARCHAR(10)) + N', N''' + REPLACE(c.name, '''', '''''') + N''', ' +
            N'TRY_CONVERT(NVARCHAR(MAX), ' + QUOTENAME(c.name) + N') ' +
            N'FROM #contrato_servico;'
        FROM sys.columns AS c
        WHERE c.object_id = OBJECT_ID('dbo.vw_contrato_servico_cliente')
        ORDER BY c.column_id;

        IF NULLIF(@sql, N'') IS NULL
            THROW 50004, 'Não foi possível obter as colunas de vw_contrato_servico_cliente.', 1;

        EXEC sp_executesql @sql;

        /*-----------------------------------------------------------------------------------------
          5) Monta HTML do contrato
        -----------------------------------------------------------------------------------------*/
        DECLARE @html NVARCHAR(MAX) = N'';
        DECLARE @style NVARCHAR(MAX) =
N'<style>
    body { font-family: ''Segoe UI'', Arial, sans-serif; color: #222; margin: 0; padding: 0; }
    .report { padding: 24px; }
    .header { display: flex; align-items: center; justify-content: space-between; border-bottom: 3px solid ' + @nm_cor_empresa + N'; padding-bottom: 12px; margin-bottom: 20px; }
    .header__logo img { max-height: 60px; }
    .header__title { text-align: right; }
    .header__title h1 { margin: 0; font-size: 20px; }
    .header__title span { display: block; font-size: 12px; color: #666; }
    .company { font-size: 12px; color: #444; margin-bottom: 16px; }
    .company strong { color: #111; }
    .section-title { font-size: 14px; font-weight: 700; margin: 16px 0 8px; color: ' + @nm_cor_empresa + N'; }
    .table { width: 100%; border-collapse: collapse; font-size: 12px; }
    .table th, .table td { border: 1px solid #ddd; padding: 6px 8px; text-align: left; vertical-align: top; }
    .table th { background: #f6f6f6; width: 30%; }
</style>';

        SET @html = @style +
            N'<div class="report">' +
                N'<div class="header">' +
                    N'<div class="header__logo"><img src="' + @logo + N'" alt="Logo" /></div>' +
                    N'<div class="header__title">' +
                        N'<h1>' + ISNULL(@nm_titulo_relatorio, @titulo) + N'</h1>' +
                        N'<span>Emissão: ' + @data_hora_atual + N'</span>' +
                    N'</div>' +
                N'</div>' +
                N'<div class="company">' +
                    N'<strong>' + @nm_fantasia_empresa + N'</strong><br />' +
                    ISNULL(@nm_endereco_empresa, '') + N' ' + ISNULL(@cd_numero_endereco, '') + N'<br />' +
                    ISNULL(@nm_bairro_empresa, '') + N' - ' + ISNULL(@nm_cidade_empresa, '') + N'/' + ISNULL(@sg_estado_empresa, '') + N' - ' + ISNULL(@cd_cep_empresa, '') + N'<br />' +
                    N'CNPJ: ' + ISNULL(@cd_cnpj_empresa, '') + N' | Fone: ' + ISNULL(@cd_telefone_empresa, '') + N' | Email: ' + ISNULL(@nm_email_internet, '') +
                N'</div>' +
                N'<div class="section-title">Dados do Contrato</div>' +
                N'<table class="table">' +
                    N'<tbody>';

        SET @html = @html +
        (
            SELECT
                N'<tr>' +
                    N'<th>' + campo + N'</th>' +
                    N'<td>' + ISNULL(valor, '') + N'</td>' +
                N'</tr>'
            FROM #contrato_campos
            ORDER BY ordem
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)');

        SET @html = @html +
                N'</tbody>' +
            N'</table>' +
        N'</div>';

        SELECT ISNULL(@html, N'') AS RelatorioHTML;

        /*-----------------------------------------------------------------------------------------
          6) Integração com tabela de log (quando aplicável)
             - Caso exista uma tabela de log padrão no ambiente, registrar aqui.
        -----------------------------------------------------------------------------------------*/

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, @ErrorMessage, 1;
    END CATCH;
END;
GO
