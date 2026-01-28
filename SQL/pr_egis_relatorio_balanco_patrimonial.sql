IF OBJECT_ID('dbo.pr_egis_relatorio_balanco_patrimonial', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_balanco_patrimonial;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_balanco_patrimonial
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-03-04
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Gerar o relatório HTML do Balanço Patrimonial (cd_relatorio = 412)

  Regras:
    - Apenas um parâmetro de entrada (@json) com dt_inicial e dt_final
    - SET NOCOUNT ON, TRY/CATCH, sem cursores
    - Performance voltada para grandes volumes
    - Utiliza a procedure legado pr_balanco_patrimonial para obter os dados
    - Retorna o HTML em coluna única (RelatorioHTML) compatível com o engine de relatórios
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_balanco_patrimonial
    @json NVARCHAR(MAX) = NULL -- [{ "dt_inicial": "YYYY-MM-DD", "dt_final": "YYYY-MM-DD", "ic_preview": 0/1 }]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -------------------------------------------------------------------------------------------------
        -- 1) Declarações e defaults
        -------------------------------------------------------------------------------------------------
        DECLARE
            @cd_relatorio        INT           = 412,
            @cd_empresa          INT           = NULL,
            @cd_usuario          INT           = NULL,
            @dt_inicial          DATE          = NULL,
            @dt_final            DATE          = NULL,
            @ic_preview          BIT           = 0;

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
            @nm_cor_empresa      VARCHAR(20)   = '#1976D2',
            @data_hora_atual     VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

        -------------------------------------------------------------------------------------------------
        -- 2) Normalização do JSON (aceita array [ { ... } ])
        -------------------------------------------------------------------------------------------------
        IF NULLIF(@json, N'') IS NOT NULL AND ISJSON(@json) = 1
        BEGIN
            IF JSON_VALUE(@json, '$[0]') IS NOT NULL
                SET @json = JSON_QUERY(@json, '$[0]');

            SELECT
                @cd_empresa = COALESCE(@cd_empresa, TRY_CAST(JSON_VALUE(@json, '$.cd_empresa') AS INT)),
                @cd_usuario = COALESCE(@cd_usuario, TRY_CAST(JSON_VALUE(@json, '$.cd_usuario') AS INT)),
                @dt_inicial = COALESCE(@dt_inicial, TRY_CAST(JSON_VALUE(@json, '$.dt_inicial') AS DATE)),
                @dt_final   = COALESCE(@dt_final,   TRY_CAST(JSON_VALUE(@json, '$.dt_final')   AS DATE)),
                @ic_preview = COALESCE(@ic_preview, TRY_CAST(JSON_VALUE(@json, '$.ic_preview') AS BIT));
        END

        -------------------------------------------------------------------------------------------------
        -- 3) Datas padrão: Parametro_Relatorio -> mês corrente
        -------------------------------------------------------------------------------------------------
        SELECT
            @dt_inicial = COALESCE(@dt_inicial, pr.dt_inicial),
            @dt_final   = COALESCE(@dt_final,   pr.dt_final)
        FROM Parametro_Relatorio AS pr WITH (NOLOCK)
        WHERE pr.cd_relatorio = @cd_relatorio
          AND (@cd_usuario IS NULL OR pr.cd_usuario_relatorio = @cd_usuario);

        IF @dt_inicial IS NULL OR @dt_final IS NULL
        BEGIN
            SET @dt_inicial = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
            SET @dt_final   = EOMONTH(@dt_inicial);
        END

        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());
        SET @ic_preview = ISNULL(@ic_preview, 0);

        -------------------------------------------------------------------------------------------------
        -- 4) Dados do relatório e empresa
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
            @nm_cidade           = ISNULL(c.nm_cidade, ''),
            @sg_estado           = ISNULL(es.sg_estado, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @nm_pais             = ISNULL(p.sg_pais, '')
        FROM Empresa AS e
        LEFT JOIN Cidade AS c  ON c.cd_cidade  = e.cd_cidade
        LEFT JOIN Estado AS es ON es.cd_estado = c.cd_estado
        LEFT JOIN Pais AS p    ON p.cd_pais    = es.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        -------------------------------------------------------------------------------------------------
        -- 5) Metadados do resultado da pr_balanco_patrimonial
        -------------------------------------------------------------------------------------------------
        DECLARE @cols TABLE (
            column_ordinal   INT,
            name             SYSNAME,
            system_type_name NVARCHAR(256),
            is_nullable      BIT,
            is_hidden        BIT,
            is_numeric       BIT
        );

        BEGIN TRY
            INSERT INTO @cols (is_hidden, column_ordinal, name, is_nullable, system_type_name)
            EXEC sys.sp_describe_first_result_set
                N'EXEC pr_balanco_patrimonial @cd_empresa = 1, @dt_inicial = ''1900-01-01'', @dt_final = ''1900-01-31''';
        END TRY
        BEGIN CATCH
            -- Fallback: metadados mínimos para manter a geração de HTML
            INSERT INTO @cols (column_ordinal, name, system_type_name, is_nullable, is_hidden)
            VALUES
                (1, 'Classificacao', 'nvarchar(200)', 1, 0),
                (2, 'Descricao',     'nvarchar(300)', 1, 0),
                (3, 'Valor',         'decimal(18,2)', 1, 0),
                (4, 'Tipo',          'nvarchar(40)',  1, 0);
        END CATCH;

        IF NOT EXISTS (SELECT 1 FROM @cols WHERE ISNULL(is_hidden, 0) = 0)
            THROW 51000, 'Não foi possível determinar as colunas retornadas por pr_balanco_patrimonial.', 1;

        UPDATE c
        SET c.is_numeric =
            CASE
                WHEN c.system_type_name LIKE 'decimal%'  OR c.system_type_name LIKE 'numeric%' OR
                     c.system_type_name LIKE 'money%'    OR c.system_type_name LIKE 'smallmoney%' OR
                     c.system_type_name LIKE 'float%'    OR c.system_type_name LIKE 'real%' OR
                     c.system_type_name LIKE 'bigint%'   OR c.system_type_name LIKE 'int%' OR
                     c.system_type_name LIKE 'smallint%' OR c.system_type_name LIKE 'tinyint%'
                    THEN 1
                ELSE 0
            END
        FROM @cols AS c;

        -------------------------------------------------------------------------------------------------
        -- 6) Cria tabela temporária conforme metadados
        -------------------------------------------------------------------------------------------------
        DECLARE @ddl NVARCHAR(MAX) = N'CREATE TABLE #BalancoPatrimonial (id_row INT IDENTITY(1,1) NOT NULL PRIMARY KEY,';

        SELECT @ddl += QUOTENAME(c.name) + N' ' + c.system_type_name + CASE WHEN ISNULL(c.is_nullable, 1) = 1 THEN N' NULL,' ELSE N' NOT NULL,' END
        FROM @cols AS c
        WHERE ISNULL(c.is_hidden, 0) = 0
        ORDER BY c.column_ordinal;

        SET @ddl = LEFT(@ddl, LEN(@ddl) - 1) + N');';
        EXEC (@ddl);

        DECLARE @col_list NVARCHAR(MAX) = (
            SELECT ',' + QUOTENAME(c.name)
            FROM @cols AS c
            WHERE ISNULL(c.is_hidden, 0) = 0
            ORDER BY c.column_ordinal
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)');

        SET @col_list = STUFF(@col_list, 1, 1, '');

        IF NULLIF(@col_list, '') IS NULL
            THROW 51001, 'Nenhuma coluna identificada para preencher o Balanço Patrimonial.', 1;

        DECLARE @exec_sql NVARCHAR(MAX) =
            N'INSERT INTO #BalancoPatrimonial (' + @col_list + N') ' +
            N'EXEC pr_balanco_patrimonial @cd_empresa = @cd_empresa, @dt_inicial = @dt_inicial, @dt_final = @dt_final;';

        BEGIN TRY
            EXEC sp_executesql @exec_sql,
                N'@cd_empresa INT, @dt_inicial DATE, @dt_final DATE',
                @cd_empresa = @cd_empresa,
                @dt_inicial = @dt_inicial,
                @dt_final   = @dt_final;
        END TRY
        BEGIN CATCH
            DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
                'Falha ao executar pr_balanco_patrimonial: %s (linha %d)',
                ERROR_MESSAGE(),
                ERROR_LINE()
            );
            THROW ERROR_NUMBER(), @errMsg, ERROR_STATE();
        END CATCH;

        -------------------------------------------------------------------------------------------------
        -- 7) Pré-visualização opcional
        -------------------------------------------------------------------------------------------------
        IF ISNULL(@ic_preview, 0) = 1
        BEGIN
            SELECT *
            FROM #BalancoPatrimonial
            ORDER BY id_row;
            RETURN;
        END

        -------------------------------------------------------------------------------------------------
        -- 8) Montagem das linhas HTML (dinâmico conforme colunas)
        -------------------------------------------------------------------------------------------------
        DECLARE
            @html_header_cells NVARCHAR(MAX),
            @html_rows         NVARCHAR(MAX),
            @html_footer_cells NVARCHAR(MAX),
            @html_table        NVARCHAR(MAX),
            @html_header       NVARCHAR(MAX),
            @html_footer       NVARCHAR(MAX),
            @html              NVARCHAR(MAX);

        SET @html_header_cells = (
            SELECT
                '<th' + CASE WHEN c.is_numeric = 1 THEN ' style="text-align:right"' ELSE '' END + '>' +
                ISNULL(c.name, '') + '</th>'
            FROM @cols AS c
            WHERE ISNULL(c.is_hidden, 0) = 0
            ORDER BY c.column_ordinal
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)');

        DECLARE @row_sql NVARCHAR(MAX) = N'
            SELECT @out_rows =
                (SELECT ''<tr>'' + ' + STUFF((
                        SELECT
                            'ISNULL(''<td' +
                            CASE WHEN c.is_numeric = 1 THEN ' style="text-align:right"' ELSE '' END +
                            '>'' + ' +
                            'CASE WHEN ' + CASE WHEN c.is_numeric = 1 THEN 'TRY_CONVERT(decimal(38,6), ' + QUOTENAME(c.name) + ') IS NULL'
                                                ELSE QUOTENAME(c.name) + ' IS NULL' END +
                            ' THEN '''' ELSE ' +
                            CASE WHEN c.is_numeric = 1
                                 THEN 'FORMAT(TRY_CONVERT(decimal(38,6), ' + QUOTENAME(c.name) + '), ''N2'')'
                                 ELSE 'CONVERT(nvarchar(max), ' + QUOTENAME(c.name) + ')'
                            END + ' END + ''</td>'', '''') + ' + CHAR(10)
                        FROM @cols AS c
                        WHERE ISNULL(c.is_hidden, 0) = 0
                        ORDER BY c.column_ordinal
                        FOR XML PATH(''), TYPE
                    ).value('.', 'nvarchar(max)'), 1, 0, '') + ''</tr>''
                 FROM #BalancoPatrimonial
                 ORDER BY id_row
                 FOR XML PATH(''''), TYPE).value(''.'', ''nvarchar(max)'');';

        EXEC sp_executesql @row_sql, N'@out_rows NVARCHAR(MAX) OUTPUT', @out_rows = @html_rows OUTPUT;

        DECLARE @footer_sql NVARCHAR(MAX) = N'
            SELECT @out_footer =
                ''<tr>'' + ' + STUFF((
                        SELECT
                            CASE WHEN c.is_numeric = 1
                                 THEN ''''<td style="text-align:right"><strong>'' + FORMAT(ISNULL(SUM(TRY_CONVERT(decimal(38,6), ' + QUOTENAME(c.name) + ')), 0), ''N2'') + ''</strong></td>'' + '
                                 ELSE ''''<td></td>'' + '
                            END
                        FROM @cols AS c
                        WHERE ISNULL(c.is_hidden, 0) = 0
                        ORDER BY c.column_ordinal
                        FOR XML PATH(''), TYPE
                    ).value('.', 'nvarchar(max)'), 1, 0, '') + ''</tr>''
            FROM #BalancoPatrimonial;';

        EXEC sp_executesql @footer_sql, N'@out_footer NVARCHAR(MAX) OUTPUT', @out_footer = @html_footer_cells OUTPUT;

        SET @html_table =
            '<table>' +
            '<thead><tr>' + ISNULL(@html_header_cells, '') + '</tr></thead>' +
            '<tbody>' + ISNULL(@html_rows, '') + '</tbody>' +
            '<tfoot>' + ISNULL(@html_footer_cells, '') + '</tfoot>' +
            '</table>';

        -------------------------------------------------------------------------------------------------
        -- 9) Cabeçalho e rodapé do HTML
        -------------------------------------------------------------------------------------------------
        DECLARE @titulo_exibir VARCHAR(200) = ISNULL(NULLIF(@nm_titulo_relatorio, ''), @titulo);

        SET @html_header =
            '<html>' +
            '<head>' +
            '  <meta charset="UTF-8">' +
            '  <title>' + ISNULL(@titulo_exibir, 'Relatório') + '</title>' +
            '  <style>' +
            '    body { font-family: Arial, sans-serif; color: #333; padding: 20px; }' +
            '    h1 { color: ' + @nm_cor_empresa + '; margin-bottom: 4px; }' +
            '    h3 { color: #555; margin-top: 0; }' +
            '    table { width: 100%; border-collapse: collapse; margin-top: 20px; }' +
            '    th, td { border: 1px solid #ddd; padding: 8px; font-size: 12px; }' +
            '    th { background-color: #f2f2f2; text-align: left; }' +
            '    tfoot td { background-color: #fafafa; font-weight: bold; }' +
            '  </style>' +
            '</head>' +
            '<body>' +
            '  <div style="display:flex; justify-content: space-between; align-items: center;">' +
            '    <div style="width:30%; padding-right:20px;"><img src="' + @logo + '" alt="Logo" style="max-width: 220px;"></div>' +
            '    <div style="width:70%; padding-left:10px;">' +
            '      <h1>' + ISNULL(@titulo_exibir, '') + '</h1>' +
            '      <h3>Balanço Patrimonial</h3>' +
            '      <p><strong>' + @nm_fantasia_empresa + '</strong></p>' +
            '      <p>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade + ' - ' + @sg_estado + ' - ' + @nm_pais + '</p>' +
            '      <p><strong>Fone: </strong>' + @cd_telefone_empresa + ' | <strong>Email: </strong>' + @nm_email_internet + '</p>' +
            '      <p><strong>Período: </strong>' + CONVERT(CHAR(10), @dt_inicial, 103) + ' a ' + CONVERT(CHAR(10), @dt_final, 103) + '</p>' +
            '    </div>' +
            '  </div>' +
            '  <div style="margin-top:10px;">' + ISNULL(@ds_relatorio, '') + '</div>' +
            '  <div style="text-align:right; font-size:11px; margin-top:10px;">Gerado em: ' + @data_hora_atual + '</div>';

        SET @html_footer = '  </body></html>';
        SET @html        = @html_header + @html_table + @html_footer;

        SELECT ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_relatorio_balanco_patrimonial falhou: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        THROW ERROR_NUMBER(), @errMsg, ERROR_STATE();
    END CATCH
END
GO
