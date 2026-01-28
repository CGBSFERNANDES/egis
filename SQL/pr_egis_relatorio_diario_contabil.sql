/*-------------------------------------------------------------------------------------------------  
  pr_egis_relatorio_diario_contabil  
---------------------------------------------------------------------------------------------------  
  GBS Global Business Solution Ltda       
  use egissql_376
  2026-01-12  
---------------------------------------------------------------------------------------------------  
  CORREÇÃO FINAL: Layout idêntico ao testerelatorio.html + decode XML  
-------------------------------------------------------------------------------------------------*/  
CREATE or alter PROCEDURE dbo.pr_egis_relatorio_diario_contabil  
    @cd_relatorio INT           = 408,  
    @cd_parametro INT           = 0,  
    @json         NVARCHAR(MAX) = NULL  
AS  
BEGIN  
    SET NOCOUNT ON;  
    SET XACT_ABORT ON;  
  
    BEGIN TRY  
	--use egissql_376
        /*-----------------------------------------------------------------------------------------  
          1) Variáveis  
        -----------------------------------------------------------------------------------------*/  
        DECLARE  
            @cd_empresa   INT           = 0,  
            @cd_usuario   INT           = 0,  
            @dt_inicial   DATE          = NULL,  
            @dt_final     DATE          = NULL,  
            @dt_limite    DATETIME      = NULL,  
            @ic_parametro INT           = 2;  
  
        DECLARE @dt_ini_str NVARCHAR(50) = NULL;  
        DECLARE @dt_fim_str NVARCHAR(50) = NULL;  
  
        DECLARE  
            @titulo              NVARCHAR(200)  = N'Diário Contábil',  
            @nm_titulo_relatorio NVARCHAR(200)  = NULL,  
            @ds_relatorio        NVARCHAR(MAX)  = N'',  
            @logo                NVARCHAR(400)  = N'logo_gbstec_sistema.jpg',  
            @nm_fantasia_empresa NVARCHAR(200)  = N'',  
            @nm_endereco_empresa NVARCHAR(200)  = N'',  
            @cd_numero_endereco  NVARCHAR(20)   = N'',  
            @cd_cep_empresa      NVARCHAR(20)   = N'',  
            @nm_cidade           NVARCHAR(200)  = N'',  
            @sg_estado           NVARCHAR(10)   = N'',  
            @cd_telefone_empresa NVARCHAR(200)  = N'',  
            @nm_email_internet   NVARCHAR(200)  = N'',  
            @nm_pais             NVARCHAR(20)   = N'',  
            @cd_cnpj_empresa     NVARCHAR(60)   = N'',  
            @cd_inscestadual     NVARCHAR(100)  = N'',  
			@cd_form             int =0,
            @cor_empresa         NVARCHAR(20)   = N'#1976D2',  
            @data_hora_atual     NVARCHAR(50)   = CONVERT(NVARCHAR(50), GETDATE(), 103) + N' ' + CONVERT(NVARCHAR(50), GETDATE(), 108);  
  
        /*-----------------------------------------------------------------------------------------  
          2) Parse JSON com suporte a múltiplos formatos de data  
        -----------------------------------------------------------------------------------------*/  
        IF NULLIF(LTRIM(RTRIM(@json)), N'') IS NOT NULL AND ISJSON(@json) = 1  
        BEGIN  
            IF LEFT(LTRIM(@json), 1) = '['  
                SET @json = JSON_QUERY(@json, '$[0]');  
  
            SET @dt_ini_str = JSON_VALUE(@json, '$.dt_inicial');  
            SET @dt_fim_str = JSON_VALUE(@json, '$.dt_final');  
            SET @cd_empresa   = TRY_CAST(JSON_VALUE(@json, '$.cd_empresa') AS INT);  
			SET @cd_form   = TRY_CAST(JSON_VALUE(@json, '$.cd_form') AS INT); 
            SET @cd_usuario   = TRY_CAST(JSON_VALUE(@json, '$.cd_usuario') AS INT);  
            SET @cd_parametro = COALESCE(NULLIF(@cd_parametro, 0), TRY_CAST(JSON_VALUE(@json, '$.cd_parametro') AS INT));  
            SET @ic_parametro = COALESCE(TRY_CAST(JSON_VALUE(@json, '$.ic_parametro') AS INT), @ic_parametro);  
  
            -- Parse data inicial  
            IF @dt_ini_str IS NOT NULL AND LEN(LTRIM(RTRIM(@dt_ini_str))) > 0  
            BEGIN  
                SET @dt_inicial = TRY_CAST(@dt_ini_str AS DATE);  
                IF @dt_inicial IS NULL SET @dt_inicial = TRY_CONVERT(DATE, @dt_ini_str, 103);  
                IF @dt_inicial IS NULL SET @dt_inicial = TRY_CONVERT(DATE, @dt_ini_str, 101);  
            END  
  
            -- Parse data final  
            IF @dt_fim_str IS NOT NULL AND LEN(LTRIM(RTRIM(@dt_fim_str))) > 0  
            BEGIN  
                SET @dt_final = TRY_CAST(@dt_fim_str AS DATE);  
                IF @dt_final IS NULL SET @dt_final = TRY_CONVERT(DATE, @dt_fim_str, 103);  
                IF @dt_final IS NULL SET @dt_final = TRY_CONVERT(DATE, @dt_fim_str, 101);  
            END  
        END  
  
        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());  
        IF @ic_parametro NOT IN (1, 2) SET @ic_parametro = 2;  
  
        /*-----------------------------------------------------------------------------------------  
          3) Datas padrão  
        -----------------------------------------------------------------------------------------*/  
        IF (@dt_inicial IS NULL OR @dt_final IS NULL)  
        BEGIN  
            SELECT  
                @dt_inicial = COALESCE(@dt_inicial, pr.dt_inicial),  
                @dt_final   = COALESCE(@dt_final,   pr.dt_final)  
            FROM Parametro_Relatorio pr WITH (NOLOCK)  
            WHERE pr.cd_relatorio = @cd_relatorio  
              AND (ISNULL(@cd_usuario, 0) = 0 OR pr.cd_usuario_relatorio = @cd_usuario);  
        END  
  
        IF @dt_inicial IS NULL OR @dt_final IS NULL  
        BEGIN  
            SET @dt_inicial = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);  
            SET @dt_final   = EOMONTH(@dt_inicial);  
        END  
  
        SET @dt_limite = DATEADD(DAY, 1, @dt_final);  
  
        /*-----------------------------------------------------------------------------------------  
          4) Dados do relatório e da empresa  
        -----------------------------------------------------------------------------------------*/  
        SELECT  
            @titulo              = ISNULL(r.nm_relatorio, @titulo),  
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, N''),  
            @ds_relatorio        = ISNULL(CAST(r.ds_relatorio AS NVARCHAR(MAX)), N'')  
        FROM egisadmin.dbo.relatorio r WITH (NOLOCK)  
        WHERE r.cd_relatorio = @cd_relatorio;  
  
        SELECT TOP (1)  
            @logo                = ISNULL(N'https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, N'logo_gbstec_sistema.jpg'),  
            @cor_empresa         = ISNULL(e.nm_cor_empresa, N'#1976D2'),  
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, N''),  
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, N''),  
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(CAST(e.cd_numero AS NVARCHAR(20)), N''))),  
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), N''),  
            @nm_cidade           = ISNULL(c.nm_cidade, N''),  
            @sg_estado           = ISNULL(es.sg_estado, N''),  
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, N''),  
            @nm_email_internet   = ISNULL(e.nm_email_internet, N''),  
            @nm_pais             = ISNULL(p.sg_pais, N''),  
            @cd_cnpj_empresa     = ISNULL(dbo.fn_formata_cnpj(LTRIM(RTRIM(ISNULL(e.cd_cgc_empresa, N'')))), N''),  
            @cd_inscestadual     = LTRIM(RTRIM(ISNULL(e.cd_iest_empresa, N'')))  
        FROM egisadmin.dbo.empresa e WITH (NOLOCK)  
        LEFT JOIN Estado es  WITH (NOLOCK) ON es.cd_estado  = e.cd_estado  
        LEFT JOIN Cidade c   WITH (NOLOCK) ON c.cd_cidade   = e.cd_cidade AND c.cd_estado = e.cd_estado  
        LEFT JOIN Pais p     WITH (NOLOCK) ON p.cd_pais     = e.cd_pais  
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
          5) Base de lançamentos  
        -----------------------------------------------------------------------------------------*/  
        SELECT  
            m.cd_empresa,  
            m.cd_lote,  
            m.cd_lancamento_contabil,  
            m.dt_lancamento_contabil,  
            ISNULL(m.cd_reduzido_debito, 0)     AS cd_reduzido_debito,  
            ISNULL(m.cd_reduzido_credito, 0)    AS cd_reduzido_credito,  
            ISNULL(m.vl_lancamento_contabil, 0) AS vl_lancamento_contabil,  
            ISNULL(m.cd_historico_contabil, 0)  AS cd_historico_contabil,  
            CAST(ISNULL(m.ds_historico_contabil, N'') AS NVARCHAR(MAX)) AS ds_historico_contabil,  
            CONCAT(CAST(ISNULL(m.cd_lote, 0) AS NVARCHAR(8)), N'-', CAST(ISNULL(m.cd_lancamento_contabil, 0) AS NVARCHAR(8))) AS Lancamento,  
            ISNULL(lot.ic_ativa_lote, 'N') AS ic_ativa_lote  
        INTO #BaseMovimento  
        FROM Movimento_contabil AS m WITH (NOLOCK)  
        OUTER APPLY (  
            SELECT TOP (1) l.ic_ativa_lote  
            FROM Lote_contabil l WITH (NOLOCK)  
            WHERE l.cd_lote = m.cd_lote  
        ) AS lot  
        WHERE m.cd_empresa = @cd_empresa  
          AND m.dt_lancamento_contabil >= @dt_inicial  
          AND m.dt_lancamento_contabil <  @dt_limite  
          AND ISNULL(lot.ic_ativa_lote, 'N') <> 'N';  
  
        /*-----------------------------------------------------------------------------------------  
          6) Tabela simplificada  
        -----------------------------------------------------------------------------------------*/  
        SELECT  
            b.dt_lancamento_contabil AS Data,  
            b.Lancamento,  
            LEFT(ISNULL(pd.cd_mascara_conta, N''), 20) AS Debito,  
            LEFT(ISNULL(pc.cd_mascara_conta, N''), 20) AS Credito,  
            b.cd_historico_contabil                    AS CodHistorico,  
            b.ds_historico_contabil                    AS Historico,  
            b.vl_lancamento_contabil                   AS Valor  
        INTO #DiarioSimplificado  
        FROM #BaseMovimento b  
        LEFT JOIN Plano_conta pd WITH (NOLOCK) ON pd.cd_empresa = b.cd_empresa AND pd.cd_conta_reduzido = b.cd_reduzido_debito  
        LEFT JOIN Plano_conta pc WITH (NOLOCK) ON pc.cd_empresa = b.cd_empresa AND pc.cd_conta_reduzido = b.cd_reduzido_credito;  
  
        /*-----------------------------------------------------------------------------------------  
          7) Tabela detalhada (débito + crédito)  
        -----------------------------------------------------------------------------------------*/  
        SELECT  
            b.dt_lancamento_contabil                   AS Data,  
            b.Lancamento,  
            b.cd_reduzido_debito                       AS Codigo,  
            b.cd_reduzido_credito                      AS Contrapartida,  
            LEFT(ISNULL(pd.nm_conta, N''), 40)         AS Conta,  
            LEFT(ISNULL(pd.cd_mascara_conta, N''), 20) AS Classificacao,  
            LEFT(ISNULL(pc.cd_mascara_conta, N''), 20) AS ClassifContra,  
            b.cd_historico_contabil                    AS CodHistorico,  
            b.ds_historico_contabil                    AS Historico,  
            b.vl_lancamento_contabil                   AS Debito,  
            CAST(0 AS DECIMAL(18, 2))                  AS Credito  
        INTO #Aux_Diario_Contabil  
        FROM #BaseMovimento b  
        INNER JOIN Plano_conta pd WITH (NOLOCK) ON pd.cd_empresa = b.cd_empresa AND pd.cd_conta_reduzido = b.cd_reduzido_debito AND b.cd_reduzido_debito <> 0  
        LEFT JOIN  Plano_conta pc WITH (NOLOCK) ON pc.cd_empresa = b.cd_empresa AND pc.cd_conta_reduzido = b.cd_reduzido_credito;  
  
        INSERT INTO #Aux_Diario_Contabil (Data, Lancamento, Codigo, Contrapartida, Conta, Classificacao, ClassifContra, CodHistorico, Historico, Debito, Credito)  
        SELECT  
            b.dt_lancamento_contabil,  
            b.Lancamento,  
            b.cd_reduzido_credito,  
            b.cd_reduzido_debito,  
            LEFT(ISNULL(pc.nm_conta, N''), 40),  
            LEFT(ISNULL(pc.cd_mascara_conta, N''), 20),  
            LEFT(ISNULL(pd.cd_mascara_conta, N''), 20),  
            b.cd_historico_contabil,  
            b.ds_historico_contabil,  
            CAST(0 AS DECIMAL(18, 2)),  
            b.vl_lancamento_contabil  
        FROM #BaseMovimento b  
        INNER JOIN Plano_conta pc WITH (NOLOCK) ON pc.cd_empresa = b.cd_empresa AND pc.cd_conta_reduzido = b.cd_reduzido_credito AND b.cd_reduzido_credito <> 0  
        LEFT JOIN  Plano_conta pd WITH (NOLOCK) ON pd.cd_empresa = b.cd_empresa AND pd.cd_conta_reduzido = b.cd_reduzido_debito;  
  
        /*-----------------------------------------------------------------------------------------  
          8) Preview opcional  
        -----------------------------------------------------------------------------------------*/  
        IF @cd_parametro = 1  
        BEGIN  
            SELECT * FROM #DiarioSimplificado ORDER BY Data, Lancamento;  
            DROP TABLE #BaseMovimento;  
            DROP TABLE #DiarioSimplificado;  
            DROP TABLE #Aux_Diario_Contabil;  
            RETURN;  
        END  
  
        IF @cd_parametro = 2  
        BEGIN  
            SELECT * FROM #Aux_Diario_Contabil ORDER BY Data, Classificacao, Lancamento;  
            DROP TABLE #BaseMovimento;  
            DROP TABLE #DiarioSimplificado;  
            DROP TABLE #Aux_Diario_Contabil;  
            RETURN;  
        END  
  
        /*-----------------------------------------------------------------------------------------  
          9) Gerar HTML (LAYOUT IDÊNTICO AO testerelatorio.html)  
        -----------------------------------------------------------------------------------------*/  
        DECLARE  
            @html_rows   NVARCHAR(MAX) = N'',  
            @html        NVARCHAR(MAX) = N'',  
            @total_debito   DECIMAL(18, 2) = 0,  
            @total_credito  DECIMAL(18, 2) = 0,  
            @total_valor    DECIMAL(18, 2) = 0,  
            @titulo_exibir  NVARCHAR(200)  = ISNULL(NULLIF(@nm_titulo_relatorio, N''), @titulo);  
  
        SELECT @total_valor = SUM(Valor) FROM #DiarioSimplificado;  
        SELECT @total_debito = SUM(Debito), @total_credito = SUM(Credito) FROM #Aux_Diario_Contabil;  
  
        IF @ic_parametro = 1  
        BEGIN  
            -- ✅ MODO SIMPLIFICADO - Quebrar linhas longas  
            SELECT @html_rows = (  
                SELECT  
                    '<tr>' +  
                    '<td>' + CONVERT(NCHAR(10), d.Data, 103) + '</td>' +  
                    '<td>' + ISNULL(d.Lancamento, N'') + '</td>' +  
                    '<td>' + ISNULL(d.Debito, N'') + '</td>' +  
                    '<td>' + ISNULL(d.Credito, N'') + '</td>' +  
                    '<td>' + ISNULL(CAST(d.CodHistorico AS NVARCHAR(12)), N'') + '</td>' +  
                    '<td>' + ISNULL(d.Historico, N'') + '</td>' +  
                    '<td style="text-align:right">' + FORMAT(d.Valor, 'N2') + '</td>' +  
                    '</tr>' AS [text()]  
                FROM #DiarioSimplificado AS d  
                ORDER BY d.Data, d.Lancamento  
                FOR XML PATH('')  
            );  
        END  
        ELSE  
        BEGIN  
            -- ✅ MODO DETALHADO - Quebrar linhas longas  
            SELECT @html_rows = (  
                SELECT  
                    '<tr>' +  
                    '<td>' + CONVERT(NCHAR(10), d.Data, 103) + '</td>' +  
                    '<td>' + ISNULL(d.Lancamento, N'') + '</td>' +  
                     
                    '<td>' + ISNULL(d.Conta, N'') + '</td>' +  
                    '<td>' + ISNULL(d.Classificacao, N'') + '</td>' +  
                    '<td>' + ISNULL(d.ClassifContra, N'') + '</td>' +  
                    '<td>' + ISNULL(d.Historico, N'') + '</td>' +  
                    '<td style="text-align:right">' + FORMAT(d.Debito, 'N2') + '</td>' +  
                    '</tr>' AS [text()]  
                FROM #Aux_Diario_Contabil AS d  
                ORDER BY d.Data, d.Classificacao, d.Lancamento  
 FOR XML PATH('')  
            );  
        END  
  
        -- ✅ DECODIFICAR ENTIDADES XML  
        SET @html_rows = REPLACE(@html_rows, N'&lt;', N'<');  
        SET @html_rows = REPLACE(@html_rows, N'&gt;', N'>');  
        SET @html_rows = REPLACE(@html_rows, N'&amp;', N'&');  
        SET @html_rows = REPLACE(@html_rows, N'&quot;', N'"');  
  
        -- ✅ MONTAR HTML FINAL (IDÊNTICO AO testerelatorio.html)  
        IF @ic_parametro = 1  
        BEGIN  
            SET @html =  
                '<html><head><meta charset="UTF-8"><title>' + ISNULL(@titulo_exibir, N'') + '</title>' +  
                '<style>' +  
                'body{font-family:Arial,sans-serif;color:#333;padding:20px}' +  
                'h1{color:' + @cor_empresa + '}' +  
                'table{width:100%;border-collapse:collapse;margin-top:20px}' +  
                'th,td{border:1px solid #ddd;padding:8px;font-size:12px}' +  
                'th{background-color:#f2f2f2;text-align:left}' +
				 '.section-title {
            background-color: #1976D2;
            color: white;
            padding: 5px;
            margin-bottom: 10px;
            border-radius: 5px;
            font-size: 120%;
        }'+
                'tfoot td{background-color:#fafafa}' +  
                '</style></head><body>' +  
                '<div style="display:flex;justify-content:space-between;align-items:center">' +  
                '<div style="width:30%;padding-right:20px"><img src="' + @logo + '" alt="Logo" style="max-width:220px"></div>' +  
                '<div style="width:70%;padding-left:10px">' +  
                '<h1>' + ISNULL(@titulo_exibir, N'') + '</h1>' +  
                '<p><strong>' + @nm_fantasia_empresa + '</strong></p>' +  
                '<p>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade + ' - ' + @sg_estado + ' - ' + @nm_pais + '</p>' +  
                '<p><strong>Fone: </strong>' + @cd_telefone_empresa + ' | <strong>Email: </strong>' + @nm_email_internet + '</p>' +  
                '<p><strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' | <strong>I.E: </strong>' + @cd_inscestadual + '</p>' +  
                '<p><strong>Período: </strong>' + CONVERT(NCHAR(10), @dt_inicial, 103) + ' a ' + CONVERT(NCHAR(10), @dt_final, 103) + '</p>' +  
                '</div></div>' +  
                '<div style="margin-top:10px">' + @ds_relatorio + '</div>' +  
                '<div style="text-align:right;font-size:11px;margin-top:10px">Gerado em: ' + @data_hora_atual + '</div>' +  
                '<table><thead><tr><th>Data</th><th>Lançamento</th><th>Débito</th><th>Crédito</th><th>Cód. Histórico</th><th>Histórico</th><th>Valor</th></tr></thead>' +  
                '<tbody>' + ISNULL(@html_rows, N'') + '</tbody>' +  
                '<tfoot><tr><td colspan="6" style="text-align:right"><strong>Total</strong></td><td style="text-align:right"><strong>' + FORMAT(ISNULL(@total_valor, 0), 'N2') + '</strong></td></tr></tfoot>' +  
                '</table></body></html>';  
        END  
        ELSE  
        BEGIN  
            SET @html =  
                '<html><head><meta charset="UTF-8"><title>' + ISNULL(@titulo_exibir, N'') + '</title>' +  
                '<style>' +  
                'body{font-family:Arial,sans-serif;color:#333;padding:20px}' +  
                'h1{color:' + @cor_empresa + '}' +  
                'table{width:100%;border-collapse:collapse;margin-top:20px}' +  
                'th,td{border:1px solid #ddd;padding:8px;font-size:12px}' +  
                'th{background-color:#f2f2f2;text-align:left}' +  
                'tfoot td{background-color:#fafafa}' + 
				'.section-title {
            background-color: #1976D2;
            color: white;
            padding: 5px;
            margin-bottom: 10px;
            border-radius: 5px;
            font-size: 120%;
        }'+
                '</style></head><body>' +  
				
                '<div style="display:flex;justify-content:space-between;align-items:center">' +  
                '<div style="width:30%;padding-right:20px"><img src="' + @logo + '" alt="Logo" style="max-width:220px"></div>' +  
                '<div style="width:70%;padding-left:10px">' +  
                '<h1>' + ISNULL(@titulo_exibir, N'') + '</h1>' +  
                '<p><strong>' + @nm_fantasia_empresa + '</strong></p>' +  
                '<p>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade + ' - ' + @sg_estado + ' - ' + @nm_pais + '</p>' +  
                '<p><strong>Fone: </strong>' + @cd_telefone_empresa + ' | <strong>Email: </strong>' + @nm_email_internet + '</p>' +  
                '<p><strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' | <strong>I.E: </strong>' + @cd_inscestadual + '</p>' +  
                '<p><strong>Período: </strong>' + CONVERT(NCHAR(10), @dt_inicial, 103) + ' a ' + CONVERT(NCHAR(10), @dt_final, 103) + '</p>' +  
                '</div></div>' +   
				----------------------------------------------------------------------------------------
				'<div class="section-title">
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p> 
        <p style="display: inline; text-align: center; padding: 25%;">
            Diário Contábil
        </p>
    </div>'+
                
                '<table><thead>
				<tr>
				<th>Data</th>
				<th>Lançamento</th>
				<th>Conta</th>
				<th>Débito</th>
				<th>Crédito</th>
				
				<th>Histórico</th>
				<th>Valor</th>
				</tr>
				</thead>' +  
                '<tbody>' + ISNULL(@html_rows, N'') + '</tbody>' +  
                '<tfoot><tr><td colspan="6" style="text-align:right"><strong>Totais</strong></td><td style="text-align:right"><strong>' + FORMAT(ISNULL(@total_debito, 0), 'N2') + '</strong></td></tr></tfoot>' +  
                '</table><div style="text-align:right;font-size:11px;margin-top:10px">Gerado em: ' + @data_hora_atual + '</div>  </body></html>';  
        END  
  
        SELECT ISNULL(@html, N'') AS RelatorioHTML;  
  
        DROP TABLE #BaseMovimento;  
        DROP TABLE #DiarioSimplificado;  
        DROP TABLE #Aux_Diario_Contabil;  
  
    END TRY  
    BEGIN CATCH  
        IF OBJECT_ID('tempdb..#BaseMovimento') IS NOT NULL DROP TABLE #BaseMovimento;  
        IF OBJECT_ID('tempdb..#DiarioSimplificado') IS NOT NULL DROP TABLE #DiarioSimplificado;  
        IF OBJECT_ID('tempdb..#Aux_Diario_Contabil') IS NOT NULL DROP TABLE #Aux_Diario_Contabil;  
  
        DECLARE @erro NVARCHAR(2048) = CONCAT(N'pr_egis_relatorio_diario_contabil: ', ERROR_MESSAGE());  
        SELECT N'<html><body><h1 style="color:red;">Erro ao gerar relatório</h1><p>' + @erro + N'</p></body></html>' AS RelatorioHTML;  
    END CATCH  
END  