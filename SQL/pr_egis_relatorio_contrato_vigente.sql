IF OBJECT_ID('dbo.pr_egis_relatorio_contrato_vigente', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_contrato_vigente;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_contrato_vigente
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-05
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Contratos Vigentes em Aberto (cd_relatorio = 431)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Entradas esperadas em @json:
    {
      "dt_inicial": "2025-02-01",
      "dt_final":   "2025-02-28",
      "cd_empresa": 1,
      "cd_usuario": 10
    }

  Observações:
    - Se dt_inicial/dt_final não forem informadas, tenta Parametro_Relatorio;
    - Caso Parametro_Relatorio não exista, usa o mês corrente.
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_contrato_vigente
    @json NVARCHAR(MAX) = ''
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Variáveis de trabalho
        -----------------------------------------------------------------------------------------*/
        DECLARE
            @cd_relatorio       INT           = 431,
            @cd_empresa         INT           = NULL,
            @cd_usuario         INT           = NULL,
            @dt_inicial         DATE          = NULL,
            @dt_final           DATE          = NULL,
            @dt_final_limit     DATETIME      = NULL,
            @titulo             VARCHAR(200)  = 'Contratos Vigentes em Aberto',
            @nm_titulo_relatorio VARCHAR(200) = NULL,
            @ds_relatorio       VARCHAR(8000) = '',
            @logo               VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
            @nm_cor_empresa     VARCHAR(20)   = '#1976D2',
            @nm_endereco_empresa VARCHAR(200) = '',
            @cd_numero_endereco VARCHAR(20)   = '',
            @nm_bairro_empresa  VARCHAR(80)   = '',
            @cd_cep_empresa     VARCHAR(20)   = '',
            @nm_cidade_empresa  VARCHAR(80)   = '',
            @sg_estado_empresa  VARCHAR(10)   = '',
            @cd_telefone_empresa VARCHAR(200) = '',
            @nm_email_internet  VARCHAR(200)  = '',
            @nm_fantasia_empresa VARCHAR(200) = '',
            @cd_cnpj_empresa    VARCHAR(60)   = '',
            @data_hora_atual    VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

        DECLARE @dt_ini_str NVARCHAR(50) = NULL;
        DECLARE @dt_fim_str NVARCHAR(50) = NULL;

        /*-----------------------------------------------------------------------------------------
          2) Validação e normalização do JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
        IF NULLIF(LTRIM(RTRIM(@json)), N'') IS NOT NULL AND ISJSON(@json) = 0
            THROW 50001, 'Payload JSON inválido em @json.', 1;

        IF NULLIF(LTRIM(RTRIM(@json)), N'') IS NOT NULL AND ISJSON(@json) = 1
        BEGIN
            IF LEFT(LTRIM(@json), 1) = '['
                SET @json = JSON_QUERY(@json, '$[0]');

            SET @dt_ini_str = JSON_VALUE(@json, '$.dt_inicial');
            SET @dt_fim_str = JSON_VALUE(@json, '$.dt_final');

            SET @cd_empresa = TRY_CAST(JSON_VALUE(@json, '$.cd_empresa') AS INT);
            SET @cd_usuario = TRY_CAST(JSON_VALUE(@json, '$.cd_usuario') AS INT);

            /*-------------------------------------------------------------------------------------
              Parse da data inicial (suporte a múltiplos formatos)
            -------------------------------------------------------------------------------------*/
            IF @dt_ini_str IS NOT NULL AND LEN(LTRIM(RTRIM(@dt_ini_str))) > 0
            BEGIN
                SET @dt_inicial = TRY_CAST(@dt_ini_str AS DATE);
                IF @dt_inicial IS NULL
                    SET @dt_inicial = TRY_CONVERT(DATE, @dt_ini_str, 103);
                IF @dt_inicial IS NULL
                    SET @dt_inicial = TRY_CONVERT(DATE, @dt_ini_str, 101);
                IF @dt_inicial IS NULL
                    SET @dt_inicial = TRY_CONVERT(DATE, REPLACE(@dt_ini_str, '-', '/'), 103);
            END

            /*-------------------------------------------------------------------------------------
              Parse da data final (suporte a múltiplos formatos)
            -------------------------------------------------------------------------------------*/
            IF @dt_fim_str IS NOT NULL AND LEN(LTRIM(RTRIM(@dt_fim_str))) > 0
            BEGIN
                SET @dt_final = TRY_CAST(@dt_fim_str AS DATE);
                IF @dt_final IS NULL
                    SET @dt_final = TRY_CONVERT(DATE, @dt_fim_str, 103);
                IF @dt_final IS NULL
                    SET @dt_final = TRY_CONVERT(DATE, @dt_fim_str, 101);
                IF @dt_final IS NULL
                    SET @dt_final = TRY_CONVERT(DATE, REPLACE(@dt_fim_str, '-', '/'), 103);
            END
        END

        /*-----------------------------------------------------------------------------------------
          3) Datas padrão: tenta Parametro_Relatorio e cai no mês corrente
        -----------------------------------------------------------------------------------------*/
        IF @dt_inicial IS NULL OR @dt_final IS NULL
        BEGIN
            SELECT
                @dt_inicial = COALESCE(@dt_inicial, pr.dt_inicial),
                @dt_final   = COALESCE(@dt_final,   pr.dt_final)
            FROM Parametro_Relatorio AS pr WITH (NOLOCK)
            WHERE pr.cd_relatorio = @cd_relatorio
              AND (@cd_usuario IS NULL OR pr.cd_usuario_relatorio = @cd_usuario);
        END

        IF @dt_inicial IS NULL OR @dt_final IS NULL
        BEGIN
            SET @dt_inicial = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
            SET @dt_final   = EOMONTH(@dt_inicial);
        END

        SET @dt_final_limit = DATEADD(SECOND, 86399, CAST(@dt_final AS DATETIME));
        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());

        /*-----------------------------------------------------------------------------------------
          4) Cabeçalho do relatório (relatorio + empresa)
        -----------------------------------------------------------------------------------------*/
        SELECT
            @titulo              = ISNULL(r.nm_relatorio, @titulo),
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.relatorio AS r WITH (NOLOCK)
        WHERE r.cd_relatorio = @cd_relatorio;

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
            @cd_cnpj_empresa     = ISNULL(dbo.fn_formata_cnpj(LTRIM(RTRIM(ISNULL(e.cd_cgc_empresa, '')))), '')
        FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)
        LEFT JOIN Cidade AS c WITH (NOLOCK) ON c.cd_cidade = e.cd_cidade AND c.cd_estado = e.cd_estado
        LEFT JOIN Estado AS est WITH (NOLOCK) ON est.cd_estado = e.cd_estado
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          5) Base do relatório (Contratos Vigentes em Aberto)
        -----------------------------------------------------------------------------------------*/
        SELECT
            cs.cd_contrato_pagar,
            cs.nm_contrato_pagar,
            cs.dt_emissao_contrato,
            cs.dt_vcto_1p_contrato_pagar,
            f.nm_fantasia_fornecedor,
            cs.vl_total_contrato_pagar,
            cs.qt_parcela_contrato_pagar,
            cs.vl_parcela_contrato,
            cs.dt_fim_contrato,
            tcpp.nm_tipo_conta_pagar,
            tco.nm_tipo_contrato
        INTO #contratos
        FROM Contrato_Pagar AS cs WITH (NOLOCK)
        LEFT JOIN Fornecedor AS f WITH (NOLOCK) ON f.cd_fornecedor = cs.cd_fornecedor
        LEFT JOIN Tipo_Conta_Pagar AS tcpp WITH (NOLOCK) ON tcpp.cd_tipo_conta_pagar = cs.cd_tipo_conta_pagar
        LEFT JOIN Tipo_Contrato AS tco WITH (NOLOCK) ON tco.cd_tipo_contrato = cs.cd_tipo_contrato
        LEFT JOIN Status_Contrato AS sc WITH (NOLOCK) ON sc.cd_status_contrato = cs.cd_status_contrato
       
	   WHERE 
			cs.dt_emissao_contrato >= @dt_inicial
          AND 
		  cs.dt_emissao_contrato <= @dt_final_limit
          AND 
		  
		  UPPER(ISNULL(sc.nm_status_contrato, '')) IN ('VIGENTE', 'ABERTO', 'ATIVO')
        ORDER BY cs.dt_emissao_contrato, cs.cd_contrato_pagar;

        /*-----------------------------------------------------------------------------------------
          6) Montagem do HTML
        -----------------------------------------------------------------------------------------*/
        DECLARE @html NVARCHAR(MAX) = N'';
        DECLARE @style NVARCHAR(MAX) =
'<html>
            <head>
            <meta charset="UTF-8">
            <title>Contrato Vigente</title>
            <style>
    body { font-family: ''Segoe UI'', Arial, sans-serif; color: #222; margin: 0; padding: 0; }
    .report { padding: 24px; }
    .header { display: flex; align-items: center; justify-content: space-between; border-bottom: 3px solid ' + @nm_cor_empresa + N'; padding-bottom: 12px; margin-bottom: 20px; }
    .header__logo img { max-height: 60px; }
    .header__title { text-align: right; }
    .header__title h1 { margin: 0; font-size: 20px; }
    .header__title span { display: block; font-size: 12px; color: #666; }
    .company { font-size: 12px; color: #444; margin-bottom: 12px; }
    .company strong { color: #111; }
    .section-title {
            background-color: #1976D2;
            color: white;
            padding: 5px;
            margin-bottom: 10px;
            border-radius: 5px;
            font-size: 120%;
        } 
    .period { font-size: 12px; color: #555; margin-bottom: 16px; }
    
    table { width: 100%; border-collapse: collapse; font-size: 12px; }
    th, td { border: 1px solid #ddd; padding: 6px 8px; text-align: left; vertical-align: top; }
    th { background: #f6f6f6; }
    .text-right { text-align: right; }
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
                N' <div class="section-title">' +
       N' <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>'+ 
      N' <p style="display: inline; text-align: center; padding: 25%;">Contratos Vigentes</p>' +
        N' </div>' +
                N'<table>' +
                    N'<thead>' +
                        N'<tr>' +
                            N'<th>Código</th>' +
                            N'<th>Contrato</th>' +
                            N'<th>Emissão</th>' +
                            N'<th>Vencimento</th>' +
                            N'<th>Fornecedor</th>' +
                            N'<th class="text-right">Total Contrato R$</th>' +
                            N'<th class="text-right">Parcelas</th>' +
                            N'<th class="text-right">Parcela Fixa</th>' +
                            N'<th>Término</th>' +
                            N'<th>Classificação</th>' +
                            N'<th>Tipo de Contrato</th>' +
                        N'</tr>' +
                    N'</thead>' +
                    N'<tbody>';

        IF EXISTS (SELECT 1 FROM #contratos)
        BEGIN
            SET @html = @html +
            (
                SELECT
                    N'<tr>' +
                        N'<td>' + CAST(cd_contrato_pagar AS VARCHAR(20)) + N'</td>' +
                        N'<td>' + ISNULL(nm_contrato_pagar, '') + N'</td>' +
                        N'<td>' + ISNULL(dbo.fn_data_string(dt_emissao_contrato), '') + N'</td>' +
                        N'<td>' + ISNULL(dbo.fn_data_string(dt_vcto_1p_contrato_pagar), '') + N'</td>' +
                        N'<td>' + ISNULL(nm_fantasia_fornecedor, '') + N'</td>' +
                        N'<td class="text-right">' + ISNULL(dbo.fn_formata_valor(vl_total_contrato_pagar), '0') + N'</td>' +
                        N'<td class="text-right">' + CAST(ISNULL(qt_parcela_contrato_pagar, 0) AS VARCHAR(10)) + N'</td>' +
                        N'<td class="text-right">' +
                            CASE WHEN ISNULL(vl_parcela_contrato, 0) > 0
                                THEN ISNULL(dbo.fn_formata_valor(vl_parcela_contrato), '0')
                                ELSE ''
                            END +
                        N'</td>' +
                        N'<td>' + ISNULL(dbo.fn_data_string(dt_fim_contrato), '') + N'</td>' +
                        N'<td>' + ISNULL(nm_tipo_conta_pagar, '') + N'</td>' +
                        N'<td>' + ISNULL(nm_tipo_contrato, '') + N'</td>' +
                    N'</tr>'
                FROM #contratos
                ORDER BY dt_emissao_contrato, cd_contrato_pagar
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)');
        END
        ELSE
        BEGIN
            SET @html = @html + N'<tr><td colspan="11">Nenhum contrato encontrado no período informado.</td></tr>';
        END

        SET @html = @html +
                    N'</tbody>' +
                N'</table>' +
            N'</div>'+
			'</body>' +
            '</html>';

        SELECT ISNULL(@html, N'') AS RelatorioHTML;

        /*-----------------------------------------------------------------------------------------
          7) Integração com tabela de log (quando aplicável)
             - Caso exista uma tabela de log padrão no ambiente, registrar aqui.
        -----------------------------------------------------------------------------------------*/

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, @ErrorMessage, 1;
    END CATCH;
END;
GO
--exec pr_egis_relatorio_contrato_vigente '[{
--    "cd_empresa": "368",
--    "cd_modulo": "377",
--    "cd_menu": "8325",
--    "cd_relatorio_form": 431,
--    "cd_processo": "",
--    "cd_form": 91,
--    "cd_documento_form": 18,
--    "cd_parametro_form": "2",
--    "cd_usuario": "5034",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "5034",
--    "cd_filtro_tabela": null,
--    "dt_usuario": "2026-01-20",
--    "lookup_formEspecial": {},
--    "cd_parametro_relatorio": "18",
--    "cd_relatorio": "432",
--    "dt_inicial": "2025-01-01",
--    "dt_final": "2027-01-20",
--    "detalhe": [],
--    "lote": [],
--    "cd_documento": "18"
--}]'