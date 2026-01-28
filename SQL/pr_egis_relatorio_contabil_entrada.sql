/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_contabil_entrada
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-01-07
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Contabilização de Entradas (cd_relatorio = 414)
  Alteração        : 2026-01-07 - Corrigido parse de datas + decode XML

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON e TRY...CATCH com THROW
    - Sem cursor e focado em performance
    - Utiliza a procedure pr_contabiliza_nota_entrada (analítica ou sintética)
    - Entrega o HTML no campo RelatorioHTML (compatível com pr_egis_processa_fila_relatorio)

  Entradas esperadas em @json:
    {
      "dt_inicial": "2025-02-01",
      "dt_final":   "2025-02-28",
      "ic_parametro": 1,   -- 1=Analítico (padrão) | 2=Sintético
      "ic_preview": 0      -- 1 = retorna dataset ao invés do HTML
    }
	
-------------------------------------------------------------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.pr_egis_relatorio_contabil_entrada
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
            @cd_relatorio     INT           = 414,
            @cd_empresa       INT           = NULL,
            @cd_usuario       INT           = NULL,
            @dt_inicial       DATE          = NULL,
            @dt_final         DATE          = NULL,
            @dt_final_limit   DATETIME      = NULL,
            @ic_parametro     INT           = 1,
            @ic_preview       BIT           = 0;

        -- Variáveis auxiliares para parse de data
        DECLARE @dt_ini_str NVARCHAR(50) = NULL;
        DECLARE @dt_fim_str NVARCHAR(50) = NULL;

        DECLARE
            @titulo              VARCHAR(200)  = 'Contabilização de Entradas',
            @nm_titulo_relatorio VARCHAR(200)  = NULL,
            @ds_relatorio        VARCHAR(8000) = '',
            @logo                VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
            @nm_cor_empresa      VARCHAR(20)   = '#1976D2',
            @nm_endereco_empresa VARCHAR(200)  = '',
            @cd_telefone_empresa VARCHAR(200)  = '',
            @nm_email_internet   VARCHAR(200)  = '',
            @nm_cidade           VARCHAR(200)  = '',
            @sg_estado           VARCHAR(10)   = '',
            @nm_fantasia_empresa VARCHAR(200)  = '',
            @cd_numero_endereco  VARCHAR(20)   = '',
            @cd_cep_empresa      VARCHAR(20)   = '',
            @nm_pais             VARCHAR(20)   = '',
            @cd_cnpj_empresa     VARCHAR(60)   = '',
            @cd_inscestadual     VARCHAR(100)  = '',
            @data_hora_atual     VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

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

            -- Extrair strings de data ANTES de converter
            SET @dt_ini_str = JSON_VALUE(@json, '$.dt_inicial');
            SET @dt_fim_str = JSON_VALUE(@json, '$.dt_final');

            -- Parse dos outros campos
            SET @cd_empresa   = TRY_CAST(JSON_VALUE(@json, '$.cd_empresa') AS INT);
            SET @cd_usuario   = TRY_CAST(JSON_VALUE(@json, '$.cd_usuario') AS INT);
            SET @ic_parametro = COALESCE(TRY_CAST(JSON_VALUE(@json, '$.ic_parametro') AS INT), @ic_parametro);
            SET @ic_preview   = COALESCE(TRY_CAST(JSON_VALUE(@json, '$.ic_preview') AS BIT), @ic_preview);

            -- ==================================================================
            -- PARSE DATA INICIAL - Suporta múltiplos formatos
            -- ==================================================================
            IF @dt_ini_str IS NOT NULL AND LEN(LTRIM(RTRIM(@dt_ini_str))) > 0
            BEGIN
                -- 1. Formato ISO: yyyy-MM-dd (ex: 2023-01-01)
                SET @dt_inicial = TRY_CAST(@dt_ini_str AS DATE);
                
                -- 2. Formato brasileiro: dd/MM/yyyy (ex: 01/01/2023)
                IF @dt_inicial IS NULL
                    SET @dt_inicial = TRY_CONVERT(DATE, @dt_ini_str, 103);
                
                -- 3. Formato americano: MM/dd/yyyy (ex: 01/01/2023)
                IF @dt_inicial IS NULL
                    SET @dt_inicial = TRY_CONVERT(DATE, @dt_ini_str, 101);
                
                -- 4. Formato com hífen brasileiro: dd-MM-yyyy
                IF @dt_inicial IS NULL
                    SET @dt_inicial = TRY_CONVERT(DATE, REPLACE(@dt_ini_str, '-', '/'), 103);
            END

            -- ==================================================================
            -- PARSE DATA FINAL - Suporta múltiplos formatos
            -- ==================================================================
            IF @dt_fim_str IS NOT NULL AND LEN(LTRIM(RTRIM(@dt_fim_str))) > 0
            BEGIN
                -- 1. Formato ISO: yyyy-MM-dd (ex: 2023-12-31)
                SET @dt_final = TRY_CAST(@dt_fim_str AS DATE);
                
                -- 2. Formato brasileiro: dd/MM/yyyy (ex: 31/12/2023)
                IF @dt_final IS NULL
                    SET @dt_final = TRY_CONVERT(DATE, @dt_fim_str, 103);
                
                -- 3. Formato americano: MM/dd/yyyy (ex: 12/31/2023)
                IF @dt_final IS NULL
                    SET @dt_final = TRY_CONVERT(DATE, @dt_fim_str, 101);
                
                -- 4. Formato com hífen brasileiro: dd-MM-yyyy
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

        SET @cd_empresa   = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());
        SET @ic_parametro = CASE WHEN @ic_parametro NOT IN (1, 2) THEN 1 ELSE @ic_parametro END;
        SET @dt_final_limit = DATEADD(SECOND, 86399, CAST(@dt_final AS DATETIME));

        /*-----------------------------------------------------------------------------------------
          4) Cabeçalho do relatório (egisadmin + dados da empresa)
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
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(CAST(e.cd_numero AS VARCHAR(20)), ''))),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @nm_cidade           = ISNULL(c.nm_cidade, ''),
            @sg_estado           = ISNULL(est.sg_estado, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @nm_pais             = ISNULL(p.sg_pais, ''),
            @cd_cnpj_empresa     = ISNULL(dbo.fn_formata_cnpj(LTRIM(RTRIM(ISNULL(e.cd_cgc_empresa, '')))), ''),
            @cd_inscestadual     = LTRIM(RTRIM(ISNULL(e.cd_iest_empresa, '')))
        FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)
        LEFT JOIN Estado AS est WITH (NOLOCK) ON est.cd_estado = e.cd_estado
        LEFT JOIN Cidade AS c   WITH (NOLOCK) ON c.cd_cidade  = e.cd_cidade AND c.cd_estado = e.cd_estado
        LEFT JOIN Pais AS p     WITH (NOLOCK) ON p.cd_pais    = e.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          5) Carrega a base a partir da pr_contabiliza_nota_entrada
        -----------------------------------------------------------------------------------------*/
        IF @ic_parametro = 1
        BEGIN
            CREATE TABLE #EntradasAnalitico (
                cd_chave                   INT,
                Nome_Lancamento_Padrao     VARCHAR(100),
                Mascara_Lancamento_Padrao  VARCHAR(50),
                Reduzido_Lancamento_Padrao VARCHAR(20),
                Reduzido_Credito           VARCHAR(20),
                cd_conta_plano             INT,
                Documento                  VARCHAR(20),
                Fornecedor                 VARCHAR(200),
                DataContabilizacao         DATETIME,
                DataEmissao                DATETIME,
                REM                        VARCHAR(40),
                Operacao_Fiscal            VARCHAR(200),
                Operacao_Fiscal_Nome       VARCHAR(200),
                Operacao_Fiscal_Mascara    VARCHAR(50),
                ValorComercial             CHAR(1),
                Servico                    CHAR(1),
                ValorTotal                 DECIMAL(25, 2),
                ValorICMS                  DECIMAL(25, 2),
                ValorIPI                   DECIMAL(25, 2),
                ValorIRRF                  DECIMAL(25, 2),
                ValorINSS                  DECIMAL(25, 2),
                ValorISS                   DECIMAL(25, 2),
                vl_pis_nota_entrada        DECIMAL(25, 2),
                vl_cofins_nota_entrada     DECIMAL(25, 2),
                vl_csll_nota_entrada       DECIMAL(25, 2),
                Provisao                   CHAR(1)
            );

            INSERT INTO #EntradasAnalitico
            EXEC pr_contabiliza_nota_entrada
                @ic_parametro = 1,
                @dt_inicial   = @dt_inicial,
                @dt_final     = @dt_final_limit;

            IF ISNULL(@ic_preview, 0) = 1
            BEGIN
                SELECT *
                FROM #EntradasAnalitico
                ORDER BY DataContabilizacao, Mascara_Lancamento_Padrao, Documento;
                DROP TABLE #EntradasAnalitico;
                RETURN;
            END

            /*-------------------------------------------------------------------------------------
              6) Totais e linhas formatadas (Analítico)
            -------------------------------------------------------------------------------------*/
            DECLARE
                @tot_vl_total   DECIMAL(25, 2),
                @tot_icms       DECIMAL(25, 2),
                @tot_ipi        DECIMAL(25, 2),
                @tot_irrf       DECIMAL(25, 2),
                @tot_inss       DECIMAL(25, 2),
                @tot_iss        DECIMAL(25, 2),
                @tot_pis        DECIMAL(25, 2),
                @tot_cofins     DECIMAL(25, 2),
                @tot_csll       DECIMAL(25, 2);

            SELECT
                @tot_vl_total = SUM(ISNULL(ValorTotal, 0)),
                @tot_icms     = SUM(ISNULL(ValorICMS, 0)),
                @tot_ipi      = SUM(ISNULL(ValorIPI, 0)),
                @tot_irrf     = SUM(ISNULL(ValorIRRF, 0)),
                @tot_inss     = SUM(ISNULL(ValorINSS, 0)),
                @tot_iss      = SUM(ISNULL(ValorISS, 0)),
                @tot_pis      = SUM(ISNULL(vl_pis_nota_entrada, 0)),
                @tot_cofins   = SUM(ISNULL(vl_cofins_nota_entrada, 0)),
                @tot_csll     = SUM(ISNULL(vl_csll_nota_entrada, 0))
            FROM #EntradasAnalitico;

            DECLARE
                @html_rows NVARCHAR(MAX),
                @html      NVARCHAR(MAX),
                @html_header NVARCHAR(MAX),
                @html_footer NVARCHAR(MAX),
                @titulo_exibir VARCHAR(200);

            SET @titulo_exibir = ISNULL(NULLIF(@nm_titulo_relatorio, ''), @titulo);

            -- Gerar linhas HTML com decode de entidades XML
            SELECT @html_rows = (
                SELECT
                    '<tr><td>' + ISNULL(f.Mascara_Lancamento_Padrao, '') + '</td><td>' + ISNULL(f.Nome_Lancamento_Padrao, '') + '</td><td>' + ISNULL(f.Reduzido_Lancamento_Padrao, '') + '</td><td>' + ISNULL(f.Documento, '') + '</td><td>' + ISNULL(f.Fornecedor, '') + '</td><td style="text-align:center">' + CONVERT(CHAR(10), f.DataContabilizacao, 103) + '</td><td>' + ISNULL(f.Operacao_Fiscal, '') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorTotal, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorICMS, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorIPI, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorIRRF, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorINSS, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorISS, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.vl_pis_nota_entrada, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.vl_cofins_nota_entrada, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.vl_csll_nota_entrada, 0), 'N2') + '</td><td style="text-align:center">' + ISNULL(f.Servico, '') + '</td></tr>' AS [text()]
                FROM #EntradasAnalitico AS f
                ORDER BY f.DataContabilizacao, f.Mascara_Lancamento_Padrao, f.Documento
                FOR XML PATH('')
            );

            -- Decodificar entidades XML
            SET @html_rows = REPLACE(@html_rows, N'&lt;', N'<');
            SET @html_rows = REPLACE(@html_rows, N'&gt;', N'>');
            SET @html_rows = REPLACE(@html_rows, N'&amp;', N'&');
            SET @html_rows = REPLACE(@html_rows, N'&quot;', N'"');

            SET @html_header =
                '<html>' +
                '<head>' +
                '<meta charset="UTF-8">' +
                '<title>' + ISNULL(@titulo_exibir, '') + '</title>' +
                '<style>' +
                'body { font-family: Arial, sans-serif; padding: 20px; }' +
                'h1 { color: ' + @nm_cor_empresa + '; }' +
                'table { width: 100%; border-collapse: collapse; margin-top: 10px; }' +
                'th, td { border: 1px solid #ddd; padding: 6px; font-size: 12px; }' +
                'th { background: ' + @nm_cor_empresa + '; color: white; text-align: left; }' +
                'tfoot td { font-weight: bold; background: #f5f5f5; }' +
							'    .section-title {  
            background-color: #1976D2;  
            color: white;  
            padding: 5px;  
            margin-bottom: 10px;  
		    border-radius: 5px;  
		    font-size: 100%;  
		  }  ' +
                '</style>' +
                '</head>' +
                '<body>' +
                '<div style="display:flex; justify-content: space-between; align-items: center;">' +
                '<div style="width:30%; padding-right:20px;"><img src="' + @logo + '" alt="Logo" style="max-width: 220px;"></div>' +
                '<div style="width:70%; padding-left:10px;">' +
                '<h1>' + ISNULL(@titulo_exibir, '') + '</h1>' +
                '<p><strong>' + @nm_fantasia_empresa + '</strong></p>' +
                '<p>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade + '/' + @sg_estado + ' - ' + @nm_pais + '</p>' +
                '<p><strong>Fone: </strong>' + @cd_telefone_empresa + ' | <strong>Email: </strong>' + @nm_email_internet + '</p>' +
                '<p><strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' | <strong>I.E: </strong>' + @cd_inscestadual + '</p>' +
                '<p><strong>Período: </strong>' + CONVERT(CHAR(10), @dt_inicial, 103) + ' a ' + CONVERT(CHAR(10), @dt_final, 103) + '</p>' +
                '</div>' +
                '</div>' +
                '<div class="section-title">  
					  <p style="display: inline;text-align: left;">Período: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
					  <p style="display: inline; text-align: center; padding: 20%;">' + ISNULL(@ds_relatorio, '') + '</p>  
				 </div>' +
                
                '<table>' +
                '<thead>' +
                '<tr>' +
                '<th>Classificação</th>' +
                '<th>Conta</th>' +
                '<th>Reduzido</th>' +
                '<th>Documento</th>' +
                '<th>Fornecedor</th>' +
                '<th>Data</th>' +
                '<th>Operação Fiscal</th>' +
                '<th>Valor Total</th>' +
                '<th>ICMS</th>' +
                '<th>IPI</th>' +
                '<th>IRRF</th>' +
                '<th>INSS</th>' +
                '<th>ISS</th>' +
                '<th>PIS</th>' +
                '<th>COFINS</th>' +
                '<th>CSLL</th>' +
                '<th>Serviço</th>' +
                '</tr>' +
                '</thead>' +
                '<tbody>';

            SET @html_footer =
                '</tbody>' +
                '<tfoot>' +
                '<tr>' +
                '<td colspan="7" style="text-align:right"><strong>Totais</strong></td>' +
                '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_vl_total, 0), 'N2') + '</strong></td>' +
                '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_icms, 0), 'N2') + '</strong></td>' +
                '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_ipi, 0), 'N2') + '</strong></td>' +
                '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_irrf, 0), 'N2') + '</strong></td>' +
                '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_inss, 0), 'N2') + '</strong></td>' +
                '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_iss, 0), 'N2') + '</strong></td>' +
                '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_pis, 0), 'N2') + '</strong></td>' +
                '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_cofins, 0), 'N2') + '</strong></td>' +
                '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_csll, 0), 'N2') + '</strong></td>' +
                '<td></td>' +
                '</tr>' +
                '</tfoot>' +
                '</table>' +
				'<div style="text-align:right; font-size:11px; margin-top:10px;">Gerado em: ' + @data_hora_atual + '</div>' +
                '</body>' +
                '</html>';

            SET @html = @html_header + ISNULL(@html_rows, '') + @html_footer;
            SELECT ISNULL(@html, '') AS RelatorioHTML;

            DROP TABLE #EntradasAnalitico;
            RETURN;
        END

        /*-----------------------------------------------------------------------------------------
          6b) Modo Sintético (ic_parametro = 2)
        -----------------------------------------------------------------------------------------*/
        CREATE TABLE #EntradasSintetico (
            cd_chave                   INT,
            Nome_Lancamento_Padrao     VARCHAR(100),
            Mascara_Lancamento_Padrao  VARCHAR(50),
            Reduzido_Lancamento_Padrao VARCHAR(20),
            cd_credito_nota_fiscal     INT,
            cd_debito_nota_fiscal      INT,
            cd_credito_ipi             INT,
            cd_debito_ipi              INT,
            cd_credito_icms            INT,
            cd_debito_icms             INT,
            cd_credito_irrf            INT,
            cd_debito_irrf             INT,
            cd_credito_inss            INT,
            cd_debito_inss             INT,
            cd_credito_iss             INT,
            cd_debito_iss              INT,
            cd_credito_pis             INT,
            cd_debito_pis              INT,
            cd_credito_cofins          INT,
            cd_debito_cofins           INT,
            cd_credito_csll            INT,
            cd_debito_csll             INT,
            cd_historico_nota_fiscal   INT,
            cd_historico_ipi           INT,
            cd_historico_icms          INT,
            cd_historico_irrf          INT,
            cd_historico_inss          INT,
            cd_historico_iss           INT,
            cd_historico_pis           INT,
            cd_historico_cofins        INT,
            cd_historico_csll          INT,
            ValorTotal                 DECIMAL(25, 2),
            ValorICMS                  DECIMAL(25, 2),
            ValorIPI                   DECIMAL(25, 2),
            ValorIRRF                  DECIMAL(25, 2),
            ValorINSS                  DECIMAL(25, 2),
            ValorISS                   DECIMAL(25, 2),
            ValorPIS                   DECIMAL(25, 2),
            ValorCOFINS                DECIMAL(25, 2),
            ValorCSLL                  DECIMAL(25, 2),
            Servico                    CHAR(1),
            Provisao                   CHAR(1)
        );

        INSERT INTO #EntradasSintetico
        EXEC pr_contabiliza_nota_entrada
            @ic_parametro = 2,
            @dt_inicial   = @dt_inicial,
            @dt_final     = @dt_final_limit;

        IF ISNULL(@ic_preview, 0) = 1
        BEGIN
            SELECT *
            FROM #EntradasSintetico
            ORDER BY Mascara_Lancamento_Padrao, Nome_Lancamento_Padrao;
            DROP TABLE #EntradasSintetico;
            RETURN;
        END

        DECLARE
            @tot_vl_total_s  DECIMAL(25, 2),
            @tot_icms_s      DECIMAL(25, 2),
            @tot_ipi_s       DECIMAL(25, 2),
            @tot_irrf_s      DECIMAL(25, 2),
            @tot_inss_s      DECIMAL(25, 2),
            @tot_iss_s       DECIMAL(25, 2),
            @tot_pis_s       DECIMAL(25, 2),
            @tot_cofins_s    DECIMAL(25, 2),
            @tot_csll_s      DECIMAL(25, 2),
            @html_rows_s     NVARCHAR(MAX),
            @html_s          NVARCHAR(MAX),
            @html_header_s   NVARCHAR(MAX),
            @html_footer_s   NVARCHAR(MAX),
            @titulo_exibir_s VARCHAR(200);

        SELECT
            @tot_vl_total_s = SUM(ISNULL(ValorTotal, 0)),
            @tot_icms_s     = SUM(ISNULL(ValorICMS, 0)),
            @tot_ipi_s      = SUM(ISNULL(ValorIPI, 0)),
            @tot_irrf_s     = SUM(ISNULL(ValorIRRF, 0)),
            @tot_inss_s     = SUM(ISNULL(ValorINSS, 0)),
            @tot_iss_s      = SUM(ISNULL(ValorISS, 0)),
            @tot_pis_s      = SUM(ISNULL(ValorPIS, 0)),
            @tot_cofins_s   = SUM(ISNULL(ValorCOFINS, 0)),
            @tot_csll_s     = SUM(ISNULL(ValorCSLL, 0))
        FROM #EntradasSintetico;

        SET @titulo_exibir_s = ISNULL(NULLIF(@nm_titulo_relatorio, ''), @titulo);

        -- Gerar linhas HTML com decode de entidades XML
        SELECT @html_rows_s = (
            SELECT
                '<tr><td>' + ISNULL(f.Mascara_Lancamento_Padrao, '') + '</td><td>' + ISNULL(f.Nome_Lancamento_Padrao, '') + '</td><td>' + ISNULL(f.Reduzido_Lancamento_Padrao, '') + '</td><td>' + ISNULL(CAST(f.cd_debito_nota_fiscal AS VARCHAR(20)), '') + '</td><td>' + ISNULL(CAST(f.cd_credito_nota_fiscal AS VARCHAR(20)), '') + '</td><td>' + ISNULL(CAST(f.cd_debito_icms AS VARCHAR(20)), '') + '</td><td>' + ISNULL(CAST(f.cd_credito_icms AS VARCHAR(20)), '') + '</td><td>' + ISNULL(CAST(f.cd_debito_ipi AS VARCHAR(20)), '') + '</td><td>' + ISNULL(CAST(f.cd_credito_ipi AS VARCHAR(20)), '') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorTotal, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorICMS, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorIPI, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorIRRF, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorINSS, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorISS, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorPIS, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorCOFINS, 0), 'N2') + '</td><td style="text-align:right">' + FORMAT(ISNULL(f.ValorCSLL, 0), 'N2') + '</td><td style="text-align:center">' + ISNULL(f.Servico, '') + '</td></tr>' AS [text()]
            FROM #EntradasSintetico AS f
            ORDER BY f.Mascara_Lancamento_Padrao, f.Nome_Lancamento_Padrao
            FOR XML PATH('')
        );

        -- Decodificar entidades XML
        SET @html_rows_s = REPLACE(@html_rows_s, N'&lt;', N'<');
        SET @html_rows_s = REPLACE(@html_rows_s, N'&gt;', N'>');
        SET @html_rows_s = REPLACE(@html_rows_s, N'&amp;', N'&');
        SET @html_rows_s = REPLACE(@html_rows_s, N'&quot;', N'"');

        SET @html_header_s =
            '<html>' +
            '<head>' +
            '<meta charset="UTF-8">' +
            '<title>' + ISNULL(@titulo_exibir_s, '') + '</title>' +
            '<style>' +
            'body { font-family: Arial, sans-serif; padding: 20px; }' +
            'h1 { color: ' + @nm_cor_empresa + '; }' +
            'table { width: 100%; border-collapse: collapse; margin-top: 10px; }' +
            'th, td { border: 1px solid #ddd; padding: 6px; font-size: 12px; }' +
            'th { background: ' + @nm_cor_empresa + '; color: white; text-align: left; }' +
            'tfoot td { font-weight: bold; background: #f5f5f5; }' +
			'    .section-title {  
            background-color: #1976D2;  
            color: white;  
            padding: 5px;  
            margin-bottom: 10px;  
		    border-radius: 5px;  
		    font-size: 100%;  
		    text-align: center;
		  }  ' +
            '</style>' +
            '</head>' +
            '<body>' +
            '<div style="display:flex; justify-content: space-between; align-items: center;">' +
            '<div style="width:30%; padding-right:20px;"><img src="' + @logo + '" alt="Logo" style="max-width: 220px;"></div>' +
            '<div style="width:70%; padding-left:10px;">' +
            '<h1 >' + ISNULL(@titulo_exibir_s, '') + '</h1>' +
            '<p><strong>' + @nm_fantasia_empresa + '</strong></p>' +
            '<p>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade + '/' + @sg_estado + ' - ' + @nm_pais + '</p>' +
            '<p><strong>Fone: </strong>' + @cd_telefone_empresa + ' | <strong>Email: </strong>' + @nm_email_internet + '</p>' +
            '<p><strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' | <strong>I.E: </strong>' + @cd_inscestadual + '</p>' +
            '<p><strong>Período: </strong>' + CONVERT(CHAR(10), @dt_inicial, 103) + ' a ' + CONVERT(CHAR(10), @dt_final, 103) + '</p>' +
            '</div>' +
            '</div>' +
            '<p class="section-title">' + ISNULL(@ds_relatorio, '') + '</p>' +            
            '<table>' +
            '<thead>' +
            '<tr>' +
            '<th>Classificação</th>' +
            '<th>Conta</th>' +
            '<th>Reduzido</th>' +
            '<th>Débito Nota</th>' +
            '<th>Crédito Nota</th>' +
            '<th>Débito ICMS</th>' +
            '<th>Crédito ICMS</th>' +
            '<th>Débito IPI</th>' +
            '<th>Crédito IPI</th>' +
            '<th>Valor Total</th>' +
            '<th>ICMS</th>' +
            '<th>IPI</th>' +
            '<th>IRRF</th>' +
            '<th>INSS</th>' +
            '<th>ISS</th>' +
            '<th>PIS</th>' +
            '<th>COFINS</th>' +
            '<th>CSLL</th>' +
            '<th>Serviço</th>' +
            '</tr>' +
            '</thead>' +
            '<tbody>';

        SET @html_footer_s =
            '</tbody>' +
            '<tfoot>' +
            '<tr>' +
            '<td colspan="9" style="text-align:right"><strong>Totais</strong></td>' +
            '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_vl_total_s, 0), 'N2') + '</strong></td>' +
            '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_icms_s, 0), 'N2') + '</strong></td>' +
            '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_ipi_s, 0), 'N2') + '</strong></td>' +
            '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_irrf_s, 0), 'N2') + '</strong></td>' +
            '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_inss_s, 0), 'N2') + '</strong></td>' +
            '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_iss_s, 0), 'N2') + '</strong></td>' +
            '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_pis_s, 0), 'N2') + '</strong></td>' +
            '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_cofins_s, 0), 'N2') + '</strong></td>' +
            '<td style="text-align:right"><strong>' + FORMAT(ISNULL(@tot_csll_s, 0), 'N2') + '</strong></td>' +
            '<td></td>' +
            '</tr>' +
            '</tfoot>' +
            '</table>' +
			'<div style="text-align:right; font-size:11px; margin-top:10px;">Gerado em: ' + @data_hora_atual + '</div>' +
            '</body>' +
            '</html>';

        SET @html_s = @html_header_s + ISNULL(@html_rows_s, '') + @html_footer_s;
        SELECT ISNULL(@html_s, '') AS RelatorioHTML;

        DROP TABLE #EntradasSintetico;

    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_relatorio_contabil_entrada falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        THROW 50000, @errMsg, 1;
    END CATCH
END
GO

--EXEC pr_egis_relatorio_contabil_entrada  @json = N'[{"dt_inicial": "2023-01-01", "dt_final": "2023-12-31"}]';
--use egissql_376