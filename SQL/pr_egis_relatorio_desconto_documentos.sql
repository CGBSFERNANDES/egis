IF OBJECT_ID('dbo.pr_egis_relatorio_desconto_documentos', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_desconto_documentos;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_desconto_documentos
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-08
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Remessa de Documentos (cd_relatorio = 423)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Entrada: @json = '[{"cd_remessa_banco": <int>, "cd_conta_banco": <int>}]'
    - Dados extraídos de documento_receber + joins conforme especificação
    - Retorna HTML no padrão RelatorioHTML
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_desconto_documentos
    @json NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_relatorio         INT           = 423,
        @cd_empresa           INT           = NULL,
        @cd_remessa_banco     INT           = NULL,
        @cd_conta_banco       INT           = NULL,
        @titulo               VARCHAR(200)  = 'Remessa de Documentos',
        @logo                 VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
        @nm_cor_empresa       VARCHAR(20)   = '#1976D2',
        @nm_endereco_empresa  VARCHAR(200)  = '',
        @cd_numero_endereco   VARCHAR(20)   = '',
        @nm_bairro_empresa    VARCHAR(80)   = '',
        @cd_cep_empresa       VARCHAR(20)   = '',
        @nm_cidade_empresa    VARCHAR(80)   = '',
        @sg_estado_empresa    VARCHAR(10)   = '',
        @cd_telefone_empresa  VARCHAR(200)  = '',
        @nm_email_internet    VARCHAR(200)  = '',
        @nm_fantasia_empresa  VARCHAR(200)  = '',
        @cd_cnpj_empresa      VARCHAR(60)   = '',
        @nm_titulo_relatorio  VARCHAR(200)  = NULL,
        @ds_relatorio         VARCHAR(8000) = '',
        @data_hora_atual      VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Validação e normalização do JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
        IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

        IF JSON_VALUE(@json, '$[0]') IS NOT NULL
            SET @json = JSON_QUERY(@json, '$[0]');

           -- select @json
   
SELECT
    @cd_remessa_banco = cd_remessa_banco,
    @cd_conta_banco   = cd_conta_banco
FROM OPENJSON(@json)
WITH (
    ic_json_parametro NVARCHAR(1) '$.ic_json_parametro',
    cd_menu           INT         '$.cd_menu',
    cd_usuario        NVARCHAR(10)'$.cd_usuario',
    cd_relatorio      INT         '$.cd_relatorio',
    cd_remessa_banco  INT         '$.cd_remessa_banco',
    cd_conta_banco    INT         '$.cd_conta_banco'
);

        
        IF ISNULL(@cd_remessa_banco, 0) = 0
            THROW 50002, 'cd_remessa_banco não informado.', 1;

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
        FROM egisadmin.dbo.Empresa AS e
        LEFT JOIN Cidade AS c   ON c.cd_cidade  = e.cd_cidade
        LEFT JOIN Estado AS est ON est.cd_estado = c.cd_estado
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          3) Dados da remessa
        -----------------------------------------------------------------------------------------*/
        SELECT
            p.nm_portador,
            cab.cd_numero_banco,
            cab.nm_agencia_banco,
            cab.nm_conta_banco,
            d.cd_remessa_banco,
            d.cd_identificacao,
            d.vl_documento_receber,
            d.cd_cliente,
            c.nm_fantasia_cliente,
            c.nm_razao_social_cliente,
            d.dt_emissao_documento,
            d.dt_vencimento_documento,
            est.sg_estado,
            cid.nm_cidade
        INTO #remessa_dados
        FROM documento_receber AS d
        inner join documento_receber_desconto drd on drd.cd_documento_receber = d.cd_documento_receber
        INNER JOIN cliente AS c
            ON c.cd_cliente = d.cd_cliente
        LEFT JOIN estado AS est
            ON est.cd_estado = c.cd_estado
        LEFT JOIN cidade AS cid
            ON cid.cd_estado = est.cd_estado
           AND cid.cd_cidade = c.cd_cidade
        LEFT JOIN portador AS p
            ON p.cd_portador = d.cd_portador
        LEFT JOIN vw_conta_agencia_banco AS cab
            ON cab.cd_conta_banco = d.cd_conta_banco_remessa
        WHERE
         --d.cd_remessa_banco = @cd_remessa_banco
          --AND (@cd_conta_banco IS NULL OR @cd_conta_banco = 0 OR d.cd_conta_banco_remessa = @cd_conta_banco);

        DECLARE
            @qt_documentos INT = 0,
            @vl_total      DECIMAL(25, 2) = 0;

        SELECT
            @qt_documentos = COUNT(1),
            @vl_total      = ISNULL(SUM(vl_documento_receber), 0)
        FROM #remessa_dados;

        /*-----------------------------------------------------------------------------------------
          4) Monta HTML
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
    .summary { font-size: 12px; margin-bottom: 12px; }
    .table { width: 100%; border-collapse: collapse; font-size: 12px; }
    .table th, .table td { border: 1px solid #ddd; padding: 6px 8px; text-align: left; vertical-align: top; }
    .table th { background: #f6f6f6; }
    .table tfoot td { font-weight: 700; background: #fafafa; }
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
                N'<div class="section-title">Remessa</div>' +
                N'<div class="summary">' +
                    N'Remessa: ' + CAST(@cd_remessa_banco AS NVARCHAR(20)) +
                    CASE WHEN ISNULL(@cd_conta_banco, 0) > 0 THEN N' | Conta Banco: ' + CAST(@cd_conta_banco AS NVARCHAR(20)) ELSE N'' END +
                    N' | Documentos: ' + CAST(@qt_documentos AS NVARCHAR(20)) +
                    N' | Total: ' + CONVERT(NVARCHAR(30), CAST(@vl_total AS MONEY), 1) +
                N'</div>' +
                N'<table class="table">' +
                    N'<thead>' +
                        N'<tr>' +
                            N'<th>Portador</th>' +
                            N'<th>Banco</th>' +
                            N'<th>Agência</th>' +
                            N'<th>Conta</th>' +
                            N'<th>Remessa</th>' +
                            N'<th>Identificação</th>' +
                            N'<th>Valor</th>' +
                            N'<th>Cliente</th>' +
                            N'<th>Razão Social</th>' +
                            N'<th>Emissão</th>' +
                            N'<th>Vencimento</th>' +
                            N'<th>UF</th>' +
                            N'<th>Cidade</th>' +
                        N'</tr>' +
                    N'</thead>' +
                    N'<tbody>';


                    --select @html

                   -- select * from #remessa_dados

        SET @html = @html +
        (
            SELECT
                N'<tr>' +
                    N'<td>' + ISNULL(nm_portador, '') + N'</td>' +
                   N'<td>' + ISNULL(CONVERT(NVARCHAR(20), cd_numero_banco), '') + N'</td>' +
                    N'<td>' + ISNULL(nm_agencia_banco, '') + N'</td>' +
                    N'<td>' + ISNULL(nm_conta_banco, '') + N'</td>' +
                    N'<td>' + ISNULL(CONVERT(NVARCHAR(20), cd_remessa_banco), '') + N'</td>' +
                    N'<td>' + ISNULL(cd_identificacao, '') + N'</td>' +
                    N'<td style="text-align:right;">' + CONVERT(NVARCHAR(30), CAST(ISNULL(vl_documento_receber, 0) AS MONEY), 1) + N'</td>' +
                    N'<td>' + ISNULL(nm_fantasia_cliente, '') + N'</td>' +
                    N'<td>' + ISNULL(nm_razao_social_cliente, '') + N'</td>' +
                    N'<td>' + ISNULL(CONVERT(NVARCHAR(10), dt_emissao_documento, 103), '') + N'</td>' +
                    N'<td>' + ISNULL(CONVERT(NVARCHAR(10), dt_vencimento_documento, 103), '') + N'</td>' +
                    N'<td>' + ISNULL(sg_estado, '') + N'</td>' +
                    N'<td>' + ISNULL(nm_cidade, '') + N'</td>' +
                N'</tr>'
            FROM #remessa_dados
            ORDER BY cd_identificacao, dt_vencimento_documento
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)');

       -- select @html

        SET @html = @html +
                    N'</tbody>' +
                    N'<tfoot>' +
                        N'<tr>' +
                            N'<td colspan="6">Totais</td>' +
                            N'<td style="text-align:right;">' + CONVERT(NVARCHAR(30), CAST(@vl_total AS MONEY), 1) + N'</td>' +
                            N'<td colspan="6"></td>' +
                        N'</tr>' +
                    N'</tfoot>' +
                N'</table>' +
            N'</div>';

        SELECT ISNULL(@html, N'') AS RelatorioHTML;

        /*-----------------------------------------------------------------------------------------
          5) Integração com tabela de log (quando aplicável)
             - Caso exista uma tabela de log padrão no ambiente, registrar aqui.
        -----------------------------------------------------------------------------------------*/
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, @ErrorMessage, 1;
    END CATCH;
END;
GO

--select cd_remessa_banco,* from documento_receber where isnull(cd_remessa_banco,0) <> 0

exec pr_egis_relatorio_remessa_documentos '[
    {
        "ic_json_parametro": "S",
        "cd_menu": 8235,
        "cd_usuario": "5034",
        "cd_relatorio": 423,
        "cd_remessa_banco": 6
    }
]'

