IF OBJECT_ID('dbo.pr_egis_relatorio_resumo_comissao_vendedor', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_resumo_comissao_vendedor;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_resumo_comissao_vendedor
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2025-02-18
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Resumo de Comissão por Vendedor (cd_relatorio = 427)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Utiliza a procedure legado pr_egis_resumo_comissao_vendedor
    - Aceita JSON como array ou objeto com (dt_inicial, dt_final)
    - Retorna HTML no padrão RelatorioHTML
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_resumo_comissao_vendedor
    @json NVARCHAR(MAX) = NULL -- Parâmetros vindos do front-end (datas)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /*---------------------------------------------------------------------------------------------
      1) Variáveis de trabalho
    ---------------------------------------------------------------------------------------------*/
    DECLARE
        @cd_relatorio     INT          = 427,
        @cd_empresa       INT          = NULL,
        @cd_usuario       INT          = NULL,
        @dt_inicial       DATE         = NULL,
        @dt_final         DATE         = NULL,
        @qt_registros     INT          = 0,
        @vl_total_base    DECIMAL(25,2) = 0,
        @vl_total_comissao DECIMAL(25,2) = 0,
        @cd_parametro      INT = 0

    DECLARE
        @titulo              VARCHAR(200)  = 'Resumo de Comissão por Vendedor',
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
        @nm_titulo_relatorio VARCHAR(200)  = NULL,
        @ds_relatorio        VARCHAR(8000) = '',
        @data_hora_atual     VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

    /*---------------------------------------------------------------------------------------------
      2) HTML (partes)
    ---------------------------------------------------------------------------------------------*/
    DECLARE
        @html_header   NVARCHAR(MAX) = N'',
        @html_cabecalho NVARCHAR(MAX) = N'',
        @html_detalhe  NVARCHAR(MAX) = N'',
        @html_totais   NVARCHAR(MAX) = N'',
        @html_footer   NVARCHAR(MAX) = N'',
        @html          NVARCHAR(MAX) = N'';

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          3) Normaliza JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
       
if @json<>''
begin
  select                     
    1                                                    as id_registro,
    IDENTITY(int,1,1)                                    as id,
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
    valores.[value]              as valor                    
                    
    into #json                    
    from                
      openjson(@json)root                    
      cross apply openjson(root.value) as valores      

-------------------------------------------------------------------------------------------------

--select * from #json

-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'


end


        /*-----------------------------------------------------------------------------------------
          4) Datas padrão: tenta Parametro_Relatorio e cai no mês corrente
        -----------------------------------------------------------------------------------------*/
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

        /*-----------------------------------------------------------------------------------------
          5) Normaliza parâmetros obrigatórios
        -----------------------------------------------------------------------------------------*/
        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());

        /*-----------------------------------------------------------------------------------------
          6) Dados da empresa (EgisAdmin)
        -----------------------------------------------------------------------------------------*/
        SELECT
            @logo                = ISNULL('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa, @logo),
            @nm_cor_empresa      = ISNULL(e.nm_cor_empresa, @nm_cor_empresa),
            @nm_endereco_empresa = ISNULL(e.nm_endereco_empresa, ''),
            @cd_telefone_empresa = ISNULL(e.cd_telefone_empresa, ''),
            @nm_email_internet   = ISNULL(e.nm_email_internet, ''),
            @nm_cidade           = ISNULL(c.nm_cidade, ''),
            @sg_estado           = ISNULL(es.sg_estado, ''),
            @nm_fantasia_empresa = ISNULL(e.nm_fantasia_empresa, ''),
            @cd_cep_empresa      = ISNULL(dbo.fn_formata_cep(e.cd_cep_empresa), ''),
            @cd_numero_endereco  = LTRIM(RTRIM(ISNULL(e.cd_numero, 0))),
            @nm_pais             = LTRIM(RTRIM(ISNULL(p.sg_pais, '')))
        FROM egisadmin.dbo.empresa AS e WITH (NOLOCK)
        LEFT JOIN Estado AS es WITH (NOLOCK) ON es.cd_estado = e.cd_estado
        LEFT JOIN Cidade AS c WITH (NOLOCK) ON c.cd_cidade = e.cd_cidade AND c.cd_estado = e.cd_estado
        LEFT JOIN Pais AS p WITH (NOLOCK) ON p.cd_pais = e.cd_pais
        WHERE e.cd_empresa = @cd_empresa;

        SELECT
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.Relatorio AS r WITH (NOLOCK)
        WHERE r.cd_relatorio = @cd_relatorio;

        /*-----------------------------------------------------------------------------------------
          7) Coleta dados base (procedure legado)
        -----------------------------------------------------------------------------------------*/
        CREATE TABLE #resumo_comissao_vendedor (
              cd_controle                INT,
    controle                   INT,
    ordem                      INT,
    NomeSetor                  VARCHAR(100),
    devolvido                  VARCHAR(100),
    cliente                    VARCHAR(200),
    pedido                     INT,
    nota                       INT,
    cd_identificacao_nota_saida INT,
    datanota                   DATETIME,
    qtd                        DECIMAL(18,2),
    base_comissao              DECIMAL(18,2),
    venda                      DECIMAL(18,2),
    comissao                   DECIMAL(18,2),
    pc_comissao_vendedor       DECIMAL(18,2),
    percomissao                DECIMAL(18,2),
    Setor                      INT,
    datadevolucao              DATETIME NULL,
    motivodev                  VARCHAR(200) NULL,
    venda_comissao             DECIMAL(18,2),
    cd_vendedor_interno        INT,
    ic_pagamento_duplicata     CHAR(1),
    cd_identificacao           VARCHAR(50),
    dt_pagamento_documento     DATETIME NULL,
    pc_contrato_cliente        DECIMAL(18,2),
    tipo_pedido                VARCHAR(50),
    NomeVendedor               VARCHAR(200),
    total_string               VARCHAR(200),
    base_string                VARCHAR(200)
);


        if @cd_parametro is null or @cd_parametro = 0
   set @cd_parametro = 0


set @cd_usuario = isnull(@cd_usuario,0)

if @cd_usuario>0
begin
  set @cd_parametro = dbo.fn_usuario_vendedor(@cd_usuario)
end

SET DATEFORMAT mdy


declare @cd_ano                 int 
declare @cd_mes                 int
declare @dt_hoje                datetime
declare @dt_perc_smo            datetime
declare @cd_tipo_vendedor       int

set @cd_ano           = year(getdate())
set @cd_mes           = month(getdate()) 


set @cd_mes = @cd_mes - 1

if @cd_mes = 0
begin
  set @cd_mes = 12
  set @cd_ano = @cd_ano - 1

end   

set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @dt_perc_smo      = '01/01/2018'
set @cd_tipo_vendedor = 0


        INSERT INTO #resumo_comissao_vendedor
        exec dbo.pr_calculo_comissao  7,
                              @cd_parametro,  --vendedor
                              @dt_inicial,
                              @dt_final,
                              @dt_perc_smo,
                              @cd_tipo_vendedor,
                              'N',
                              'N'

        /*-----------------------------------------------------------------------------------------
          8) Totais (count / soma da base de cálculo e comissão)
        -----------------------------------------------------------------------------------------*/
     declare @vl_base_comissao decimal(25,2) = 0.00
     declare @vl_comissao      decimal(25,2) = 0.00

     --select * from #resumo_comissao_vendedor

select
  --@qt_registros     = count( case when isnull(comissao,0)>0 then cd_controle end ),
  @vl_base_comissao = sum( base_comissao),
  @vl_comissao      = sum( comissao )

from 
  #resumo_comissao_vendedor 

  --select @qt_registros

select 
  setor as cd_vendedor,
  sum( base_comissao) as vl_base_comissao,
  sum( comissao)      as vl_comissao
into
  #Comissao

from
  #resumo_comissao_vendedor

group by
   Setor

   select
  v.cd_vendedor,
  v.nm_fantasia_vendedor,
  v.nm_vendedor,
  tv.nm_tipo_vendedor,
  tp.nm_tipo_pessoa,
  v.cd_cnpj_vendedor,
  v.cd_celular,
  v.nm_email_vendedor,
  v.pc_comissao_vendedor,

  --Dados Bancários--------------------------------------------------------------
  
  v.nm_pix_vendedor,
  b.cd_numero_banco,
  v.cd_agencia_banco_vendedor,
  v.cd_conta_corrente,

  --Valores----------------
  c.vl_base_comissao                as vl_base_calculo,
  c.vl_comissao
  into
    #resumoComissao

from 
  vendedor v
  left outer join tipo_vendedor tv on tv.cd_tipo_vendedor = v.cd_tipo_vendedor
  left outer join tipo_pessoa tp   on tp.cd_tipo_pessoa   = v.cd_tipo_pessoa
  left outer join banco b          on b.cd_banco          = v.cd_banco
  left outer join #Comissao c      on c.cd_vendedor       = v.cd_vendedor

order by
  v.nm_vendedor


 select
   @qt_registros = count(cd_vendedor)
 from
   #resumoComissao
 where
    isnull(vl_comissao,0)>0

    --select @qt_registros

   --select * from #resumoComissao


        /*-----------------------------------------------------------------------------------------
          9) Monta HTML (RelatorioHTML)
        -----------------------------------------------------------------------------------------*/
        SET @html_header =
            '<html><head><meta charset="utf-8">' +
            '<style>' +
            'body{font-family:Arial, sans-serif;font-size:12px;color:#333;margin:0;padding:20px;}' +
            'table{width:100%;border-collapse:collapse;margin-top:10px;}' +
            'th,td{border:1px solid #ccc;padding:6px 8px;text-align:left;font-size:11px;}' +
            'th{font-size:13px;texte-align:center}' +
           
            '.totals{margin-top:10px;font-weight:bold;}' +
            '.report-date-time{text-align:right;font-size:11px;margin-top:10px;}' +
			
        '.section-title {
            background-color: #1976D2;
            color: white;
            padding: 5px;
            margin-bottom: 10px;
            border-radius: 5px;
            font-size: 120%;
        }'+

            '</style></head><body>';
		
        SET @html_cabecalho =
            '  <div style="display:flex;justify-content:space-between;align-items:center;">' +
            '    <div style="width:30%;padding-right:20px;"><img src="' + @logo + '" alt="Logo" style="max-width:220px;"></div>' +
            '    <div style="width:70%;padding-left:10px;">' +
            '      <p><strong>' + ISNULL(@nm_fantasia_empresa, '') + '</strong></p>' +
            '      <p>' + @nm_endereco_empresa + ', ' + @cd_numero_endereco + ' - ' + @cd_cep_empresa + ' - ' + @nm_cidade + ' - ' + @sg_estado + ' - ' + @nm_pais + '</p>' +
            '      <p><strong>Fone: </strong>' + @cd_telefone_empresa + ' | <strong>Email: </strong>' + @nm_email_internet + '</p>' +
            '      <p><strong>Período: </strong>' + CONVERT(CHAR(10), @dt_inicial, 103) + ' a ' + CONVERT(CHAR(10), @dt_final, 103) + '</p>' +
            '    </div>' +
            '  </div>' +
            '  
	 <div class="section-title">  
        <p style="display: inline;">Periodo: '+isnull(dbo.fn_data_string(@dt_inicial),'')+' á '+isnull(dbo.fn_data_string(@dt_final),'')+'</p>   
        <p style="display: inline; text-align: center; padding: 20%;">'+case when isnull(@titulo,'') <> '' then ''+isnull(@titulo,'')+'' else 'Contabilização Documento a Receber' end +'</p>  
    </div>  '

        SET @html_detalhe =
            '<table>' +
            '<thead>' +
            '<tr>' +
            '<th>Código</th>' +
            '<th>Fantasia</th>' +
            '<th>Vendedor</th>' +
            '<th>Tipo</th>' +
            '<th>Pessoa</th>' +
            '<th>CNPJ/CPF</th>' +
            '<th>Celular</th>' +
            '<th>e-mail</th>' +
            '<th>(%) comissão</th>' +
            '<th>Pix</th>' +
            '<th>Banco</th>' +
            '<th>Agência</th>' +
            '<th>Conta Corrente</th>' +
            '<th>Base de Cálculo</th>' +
            '<th>Comissão</th>' +
            '</tr>' +
            '</thead><tbody>' +
            ISNULL((
                SELECT
                    '<tr>' +
                    '<td>' + CAST(r.cd_vendedor AS VARCHAR(20)) + '</td>' +
                    '<td>' + ISNULL(r.nm_fantasia_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.nm_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.nm_tipo_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.nm_tipo_pessoa, '') + '</td>' +
                    '<td>' + ISNULL(r.cd_cnpj_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.cd_celular, '') + '</td>' +
                    '<td>' + ISNULL(r.nm_email_vendedor, '') + '</td>' +
                    '<td style="text-align:right;">' + CONVERT(VARCHAR(30), CAST(ISNULL(r.pc_comissao_vendedor, 0) AS MONEY), 1) + '</td>' +
                    '<td>' + ISNULL(r.nm_pix_vendedor, '') + '</td>' +
                    '<td>' + cast(ISNULL(r.cd_numero_banco, '') as varchar(20))+ '</td>' +
                    '<td>' + ISNULL(r.cd_agencia_banco_vendedor, '') + '</td>' +
                    '<td>' + ISNULL(r.cd_conta_corrente, '') + '</td>' +
                    '<td style="text-align:right;">' + CONVERT(VARCHAR(30), CAST(ISNULL(r.vl_base_calculo, 0) AS MONEY), 1) + '</td>' +
                    '<td style="text-align:right;">' + CONVERT(VARCHAR(30), CAST(ISNULL(r.vl_comissao, 0) AS MONEY), 1) + '</td>' +
                    '</tr>'
                FROM #resumoComissao AS r
                ORDER BY r.nm_vendedor
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), '') +
            '</tbody></table>';

        SET @html_totais =
            '<div class="totals">'+
			'<table>'+
            '<th>Total de Registros: ' + CAST(@qt_registros AS VARCHAR(20)) +'</th>'+
            '<th>Soma Base de Cálculo: ' + CONVERT(VARCHAR(30), CAST(@vl_base_comissao AS MONEY), 1) +'</th>'+
            '<th>Soma Comissão: '+ CONVERT(VARCHAR(30), CAST(@vl_comissao AS MONEY), 1) +'</th>'+
			'</table>'+
            '</div>';

        SET @html_footer =
            '<div class="report-date-time">Gerado em: ' + @data_hora_atual + '</div>' +
            '</body></html>';

        SET @html = @html_header + @html_cabecalho + @html_detalhe + @html_totais + @html_footer;

        SELECT ISNULL(@html, '') AS RelatorioHTML;
    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(2048) = FORMATMESSAGE(
            'pr_egis_relatorio_resumo_comissao_vendedor: %s (linha %d)',
            ERROR_MESSAGE(),
            ERROR_LINE()
        );

        THROW 50001, @errMsg, 1;
    END CATCH
END
GO


--use egissql_357



--exec pr_egis_relatorio_resumo_comissao_vendedor '[{
--    "cd_menu": "0",
--    "cd_form": 91,
--    "cd_documento_form": 4,
--    "cd_parametro_form": "2",
--    "cd_usuario": "4896",
--    "cd_cliente_form": "0",
--    "cd_contato_form": "4896",
--    "cd_filtro_tabela": null,
--    "dt_usuario": "2026-01-15",
--    "lookup_formEspecial": {},
--    "cd_parametro_relatorio": "4",
--    "cd_relatorio": "427",
--    "dt_inicial": "2026-01-15",
--    "dt_final": "2026-01-15",
--    "detalhe": [],
--    "lote": [],
--    "cd_modulo": "247"
--}]'