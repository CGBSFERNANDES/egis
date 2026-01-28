/*-------------------------------------------------------------------------------------------------    
  pr_egis_relatorio_balanco_patrimonial    
---------------------------------------------------------------------------------------------------    
  GBS Global Business Solution Ltda                                                     2026-01-08    
---------------------------------------------------------------------------------------------------    
  Stored Procedure : Microsoft SQL Server 2016    
  Autor(es)        : Codex (assistente)    
  Banco de Dados   : Egissql - Banco do Cliente    
  Objetivo         : Relatório HTML - Balanço Patrimonial (cd_relatorio = 412)    
  Alteração        : 2026-01-08 - Layout idêntico ao pr_egis_relatorio_contabil_entrada    
    
  Requisitos:    
    - Somente 1 parâmetro de entrada (@json)    
    - SET NOCOUNT ON e TRY...CATCH com THROW    
    - Sem cursor e focado em performance    
    - Utiliza a procedure pr_balanco_patrimonial    
    - Entrega o HTML no campo RelatorioHTML (compatível com pr_egis_processa_fila_relatorio)    
    
  Entradas esperadas em @json:    
    {    
      "dt_inicial": "2023-01-01",    
      "dt_final":   "2023-12-31",    
      "ic_preview": 0      -- 1 = retorna dataset ao invés do HTML    
    }    
-------------------------------------------------------------------------------------------------*/    
CREATE OR ALTER PROCEDURE dbo.pr_egis_relatorio_balanco_patrimonial    
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
            @cd_relatorio        INT           = 412,    
            @cd_empresa          INT           = NULL,    
            @cd_usuario          INT           = NULL,    
            @dt_inicial          DATETIME      = NULL,    
            @dt_final            DATETIME      = NULL,    
            @ic_preview          BIT           = 0;    
    
        -- Variáveis auxiliares para parse de data    
        DECLARE @dt_ini_str NVARCHAR(50) = NULL;    
        DECLARE @dt_fim_str NVARCHAR(50) = NULL;    
    
        DECLARE    
            @titulo              VARCHAR(200)  = 'Balanço Patrimonial',    
            @nm_titulo_relatorio VARCHAR(200)  = NULL,    
            @ds_relatorio        VARCHAR(8000) = '',    
            @logo                VARCHAR(400)  = 'logo_gbstec_sistema.jpg',    
            @nm_fantasia_empresa VARCHAR(200)  = '',    
            @nm_endereco_empresa VARCHAR(200)  = '',    
            @cd_numero_endereco  VARCHAR(20)   = '',    
            @cd_cep_empresa      VARCHAR(20)   = '',    
            @nm_cidade           VARCHAR(200)  = '',    
            @sg_estado           VARCHAR(10)   = '',    
            @cd_telefone_empresa VARCHAR(200)  = '',    
            @nm_email_internet   VARCHAR(200)  = '',    
            @nm_pais             VARCHAR(20)   = '',    
            @cd_cnpj_empresa     VARCHAR(60)   = '',    
            @cd_inscestadual     VARCHAR(100)  = '',    
            @nm_cor_empresa      VARCHAR(20)   = '#1976D2',    
            @data_hora_atual     VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108),   
			@cd_form             int =0
    
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
			SET @cd_form = JSON_VALUE(@json, '$.cd_form');  
            -- Parse dos outros campos    
            SET @cd_empresa = TRY_CAST(JSON_VALUE(@json, '$.cd_empresa') AS INT);    
            SET @cd_usuario = TRY_CAST(JSON_VALUE(@json, '$.cd_usuario') AS INT);    
            SET @ic_preview = COALESCE(TRY_CAST(JSON_VALUE(@json, '$.ic_preview') AS BIT), @ic_preview);    
    
            -- ==================================================================    
            -- PARSE DATA INICIAL - Suporta múltiplos formatos    
            -- ==================================================================    
            IF @dt_ini_str IS NOT NULL AND LEN(LTRIM(RTRIM(@dt_ini_str))) > 0    
            BEGIN    
                -- 1. Formato ISO: yyyy-MM-dd (ex: 2023-01-01)    
                SET @dt_inicial = TRY_CAST(@dt_ini_str AS DATETIME);    
                    
                -- 2. Formato brasileiro: dd/MM/yyyy (ex: 01/01/2023)    
                IF @dt_inicial IS NULL    
                    SET @dt_inicial = TRY_CONVERT(DATETIME, @dt_ini_str, 103);    
                    
                -- 3. Formato americano: MM/dd/yyyy (ex: 01/01/2023)    
                IF @dt_inicial IS NULL    
                    SET @dt_inicial = TRY_CONVERT(DATETIME, @dt_ini_str, 101);    
                    
                -- 4. Formato com hífen brasileiro: dd-MM-yyyy    
                IF @dt_inicial IS NULL    
                    SET @dt_inicial = TRY_CONVERT(DATETIME, REPLACE(@dt_ini_str, '-', '/'), 103);    
            END    
    
            -- ==================================================================    
            -- PARSE DATA FINAL - Suporta múltiplos formatos    
            -- ==================================================================    
            IF @dt_fim_str IS NOT NULL AND LEN(LTRIM(RTRIM(@dt_fim_str))) > 0    
            BEGIN    
                -- 1. Formato ISO: yyyy-MM-dd (ex: 2023-12-31)    
                SET @dt_final = TRY_CAST(@dt_fim_str AS DATETIME);    
                    
                -- 2. Formato brasileiro: dd/MM/yyyy (ex: 31/12/2023)    
                IF @dt_final IS NULL    
                    SET @dt_final = TRY_CONVERT(DATETIME, @dt_fim_str, 103);    
                    
                -- 3. Formato americano: MM/dd/yyyy (ex: 12/31/2023)    
                IF @dt_final IS NULL    
                    SET @dt_final = TRY_CONVERT(DATETIME, @dt_fim_str, 101);    
                    
                -- 4. Formato com hífen brasileiro: dd-MM-yyyy    
                IF @dt_final IS NULL    
                    SET @dt_final = TRY_CONVERT(DATETIME, REPLACE(@dt_fim_str, '-', '/'), 103);    
            END    
        END    
    
        /*-----------------------------------------------------------------------------------------    
          3) Datas padrão: tenta Parametro_Relatorio e cai no mês corrente    
        -----------------------------------------------------------------------------------------*/    
        IF @dt_inicial IS NULL OR @dt_final IS NULL    
        BEGIN    
            SELECT TOP 1    
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
    
        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());    
    
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
            @sg_estado           = ISNULL(es.sg_estado, ''),    
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),    
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),    
            @nm_pais             = ISNULL(p.sg_pais, ''),    
            @cd_cnpj_empresa     = ISNULL(dbo.fn_formata_cnpj(LTRIM(RTRIM(ISNULL(e.cd_cgc_empresa, '')))), ''),    
            @cd_inscestadual     = LTRIM(RTRIM(ISNULL(e.cd_iest_empresa, '')))    
        FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)    
        LEFT JOIN Estado AS es WITH (NOLOCK) ON es.cd_estado = e.cd_estado    
        LEFT JOIN Cidade AS c  WITH (NOLOCK) ON c.cd_cidade  = e.cd_cidade AND c.cd_estado = e.cd_estado    
        LEFT JOIN Pais AS p    WITH (NOLOCK) ON p.cd_pais    = e.cd_pais    
        WHERE e.cd_empresa = @cd_empresa;    
		
		if isnull(@cd_form,0) <> 91
		begin
			select top 1 
				@dt_inicial  = dt_inicial_exercicio, 
			    @dt_final 	 = dt_final_exercicio
			from parametro_contabil
			where isnull(ic_exercicio_ativo,'N') = 'S'  
		end
			
        /*-----------------------------------------------------------------------------------------    
          5) Carregar dados do Balanço Patrimonial    
        -----------------------------------------------------------------------------------------*/    
        CREATE TABLE #dados_balanco (    
            cd_conta             INT,    
            cd_grupo_conta       INT,    
            nm_grupo_conta       VARCHAR(100),    
            cd_mascara_conta     VARCHAR(50),    
            nm_conta             VARCHAR(200),    
            ic_conta_balanco     VARCHAR(10),    
            qt_grau_conta        INT,    
            vl_saldo_conta       DECIMAL(18,2),    
            ic_saldo_conta       VARCHAR(10)    
        );    
    
        INSERT INTO #dados_balanco    
        EXEC pr_balanco_patrimonial @dt_inicial, @dt_final;    
    
        /*-----------------------------------------------------------------------------------------    
          6) Preview opcional    
        -----------------------------------------------------------------------------------------*/    
        IF ISNULL(@ic_preview, 0) = 1    
        BEGIN    
            SELECT *     
            FROM #dados_balanco     
            ORDER BY cd_mascara_conta;    
            DROP TABLE #dados_balanco;    
            RETURN;    
        END    
    
        /*-----------------------------------------------------------------------------------------    
          7) Gerar HTML com o mesmo layout da pr_egis_relatorio_contabil_entrada    
        -----------------------------------------------------------------------------------------*/    
        DECLARE    
            @html_rows  NVARCHAR(MAX),    
            @html          NVARCHAR(MAX),    
            @html_header   NVARCHAR(MAX),    
            @html_footer   NVARCHAR(MAX),    
            @titulo_exibir VARCHAR(200);    
    
        SET @titulo_exibir = ISNULL(NULLIF(@nm_titulo_relatorio, ''), @titulo);    
    
        -- Gerar linhas HTML com decode de entidades XML    
        SELECT @html_rows = (    
            SELECT    
                '<tr>' +    
                '<td>' + ISNULL(CAST(cd_grupo_conta AS VARCHAR(50)), '') + '</td>' +    
                '<td>' + ISNULL(nm_grupo_conta, '') + '</td>' +    
                '<td>' + ISNULL(CAST(cd_mascara_conta AS VARCHAR(50)), '') + '</td>' +    
                '<td>' + ISNULL(nm_conta, '') + '</td>' +    
                '<td style="text-align:center">' + ISNULL(ic_conta_balanco, '') + '</td>' +    
                '<td style="text-align:center">' + ISNULL(CAST(qt_grau_conta AS VARCHAR(10)), '') + '</td>' +    
                '<td style="text-align:right">' + ISNULL(dbo.fn_formata_valor(vl_saldo_conta), 0) + '</td>' +    
                '<td style="text-align:center">' + ISNULL(ic_saldo_conta,'') + '</td>' +    
                '</tr>' AS [text()]    
            FROM #dados_balanco    
            ORDER BY cd_mascara_conta    
            FOR XML PATH('')    
        );    
    
        -- Decodificar entidades XML    
        SET @html_rows = REPLACE(@html_rows, N'&lt;', N'<');    
        SET @html_rows = REPLACE(@html_rows, N'&gt;', N'>');    
        SET @html_rows = REPLACE(@html_rows, N'&amp;', N'&');    
        SET @html_rows = REPLACE(@html_rows, N'&quot;', N'"');    
    
        -- Montar HTML completo (IGUAL ao pr_egis_relatorio_contabil_entrada)    
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
              
            'tfoot td { font-weight: bold; background: #f5f5f5; }' +    
            '.section-title { background-color: #1976D2; color: white; padding: 5px; margin-bottom: 10px; border-radius: 5px; font-size: 100%; }' +    
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
            ' <div class="section-title">
	    <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p> 
        <p style="display: inline; text-align: center; padding: 25%;">' + ISNULL(@ds_relatorio, '') + '</p>
		    </div>'+  
		
            '<table>' +    
            '<thead>' +    
            '<tr>' +    
            '<th>Cód. Grupo</th>' +    
            '<th>Grupo Conta</th>' +    
            '<th>Máscara</th>' +    
            '<th>Conta</th>' +    
   '<th>Balanço</th>' +    
            '<th>Grau</th>' +    
            '<th style="text-align:right">Saldo</th>' +    
            '<th>D/C</th>' +    
            '</tr>' +    
            '</thead>' +    
            '<tbody>';    
    
        SET @html_footer =    
            '</tbody>' +    
            '</table>' +    
            '<div style="text-align:right; font-size:11px; margin-top:10px;">Gerado em: ' + @data_hora_atual + '</div>' +    
            '</body>' +    
            '</html>';    
    
        SET @html = @html_header + ISNULL(@html_rows, '') + @html_footer;    
    
        DROP TABLE #dados_balanco;    
    
        SELECT ISNULL(@html, '') AS RelatorioHTML;    
    
    END TRY    
    BEGIN CATCH    
        IF OBJECT_ID('tempdb..#dados_balanco') IS NOT NULL     
            DROP TABLE #dados_balanco;    
            
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(    
            'pr_egis_relatorio_balanco_patrimonial falhou: %s (linha %d)',    
            ERROR_MESSAGE(),    
            ERROR_LINE()    
        );    
    
        THROW 50000, @errMsg, 1;    
    END CATCH    
END 