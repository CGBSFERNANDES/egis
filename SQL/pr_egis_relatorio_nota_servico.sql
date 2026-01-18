IF OBJECT_ID('dbo.pr_egis_relatorio_nota_servico', 'P') IS NOT NULL
    DROP PROCEDURE dbo.pr_egis_relatorio_nota_servico;
GO

/*-------------------------------------------------------------------------------------------------
  pr_egis_relatorio_nota_servico
---------------------------------------------------------------------------------------------------
  GBS Global Business Solution Ltda                                                     2026-02-26
---------------------------------------------------------------------------------------------------
  Stored Procedure : Microsoft SQL Server 2016
  Autor(es)        : Codex (assistente)
  Banco de Dados   : Egissql - Banco do Cliente
  Objetivo         : Relatório HTML - Nota Fiscal de Serviço (cd_relatorio = 421)

  Requisitos:
    - Somente 1 parâmetro de entrada (@json)
    - SET NOCOUNT ON / TRY...CATCH
    - Sem cursor
    - Performance para grandes volumes
    - Código comentado

  Observações:
    - Entrada: @json = '[{"cd_nota_saida": <int>}]'
    - Os dados são extraídos do XML armazenado em dbo.nfse_xml.ds_xml
    - O cd_nota_saida é tratado como o identificador do XML (cd_nfse_xml)
    - Retorna HTML no padrão RelatorioHTML
-------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE dbo.pr_egis_relatorio_nota_servico
    @json NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cd_relatorio           INT           = 421,
        @cd_empresa             INT           = NULL,
        @cd_usuario             INT           = NULL,
        @cd_nota_saida          INT           = NULL,
        @cd_nfse_xml            INT           = NULL,
        @ds_xml                 NVARCHAR(MAX) = NULL,
        @xml                    XML           = NULL;

    DECLARE
        @titulo              VARCHAR(200)  = 'Nota Fiscal de Serviços',
        @logo                VARCHAR(400)  = 'logo_gbstec_sistema.jpg',
        @nm_cor_empresa      VARCHAR(20)   = '#1976D2',
        @nm_endereco_empresa VARCHAR(200)  = '',
        @cd_numero_endereco  VARCHAR(20)   = '',
        @nm_bairro_empresa   VARCHAR(80)   = '',
        @cd_cep_empresa      VARCHAR(20)   = '',
        @nm_cidade_empresa   VARCHAR(80)   = '',
        @sg_estado_empresa   VARCHAR(10)   = '',
        @cd_telefone_empresa VARCHAR(200)  = '',
        @nm_email_internet   VARCHAR(200)  = '',
        @nm_fantasia_empresa VARCHAR(200)  = '',
        @cd_cnpj_empresa     VARCHAR(60)   = '',
        @nm_titulo_relatorio VARCHAR(200)  = NULL,
        @ds_relatorio        VARCHAR(8000) = '',
        @data_hora_atual     VARCHAR(50)   = CONVERT(VARCHAR, GETDATE(), 103) + ' ' + CONVERT(VARCHAR, GETDATE(), 108);

    DECLARE
        --@cd_nfse_xml           int          = 0,
        @nr_nfse               VARCHAR(30)  = '',
        @cd_verificacao        VARCHAR(60)  = '',
        @dt_emissao            VARCHAR(30)  = '',
        @cnpj_prestador        VARCHAR(20)  = '',
        @im_prestador          VARCHAR(30)  = '',
        @razao_prestador       VARCHAR(200) = '',
        @fantasia_prestador    VARCHAR(200) = '',
        @endereco_prestador    VARCHAR(200) = '',
        @numero_prestador      VARCHAR(20)  = '',
        @bairro_prestador      VARCHAR(80)  = '',
        @municipio_prestador   VARCHAR(80)  = '',
        @uf_prestador          VARCHAR(5)   = '',
        @cep_prestador         VARCHAR(20)  = '',
        @cnpj_tomador          VARCHAR(20)  = '',
        @cpf_tomador           VARCHAR(20)  = '',
        @razao_tomador         VARCHAR(200) = '',
        @endereco_tomador      VARCHAR(200) = '',
        @numero_tomador        VARCHAR(20)  = '',
        @bairro_tomador        VARCHAR(80)  = '',
        @municipio_tomador     VARCHAR(80)  = '',
        @uf_tomador            VARCHAR(5)   = '',
        @cep_tomador           VARCHAR(20)  = '',
        @item_lista_servico    VARCHAR(30)  = '',
        @cod_trib_municipio    VARCHAR(30)  = '',
        @municipio_prestacao   VARCHAR(30)  = '',
        @ds_discriminacao      NVARCHAR(2000) = '',
        @vl_servicos           VARCHAR(40)  = '',
        @vl_base_calculo       VARCHAR(40)  = '',
        @vl_iss                VARCHAR(40)  = '',
        @vl_liquido            VARCHAR(40)  = '',
        @aliq_iss              VARCHAR(40)  = '';

    BEGIN TRY
        /*-----------------------------------------------------------------------------------------
          1) Normaliza JSON (aceita array [ { ... } ])
        -----------------------------------------------------------------------------------------*/
        IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inv�lido ou vazio em @json.', 1;

        --IF JSON_VALUE(@json, '$[0]') IS NOT NULL
        --    SET @json = JSON_QUERY(@json, '$[0]');


        select                     
        
         1                                                   as id_registro,
         IDENTITY(int,1,1)                                   as id,
         valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
         valores.[value]                                     as valor                    
                            
         into #json                    
         from                
           openjson(@json)root                    
           cross apply openjson(root.value) as valores     

        --------------------------------------------------------------------------------------------
        select @cd_nfse_xml = TRY_CAST(valor AS INT) from #json where campo = 'cd_nfse_xml';
        select @cd_empresa  = TRY_CAST(valor AS INT) from #json where campo = 'cd_empresa';
        select @cd_usuario  = TRY_CAST(valor AS INT) from #json where campo = 'cd_usuario';
        -----
                
        IF ISNULL(@cd_nfse_xml, 0) = 0
            THROW 50002, 'cd_nota_saida não informado.', 1;

        --SET @cd_nfse_xml = @cd_nota_saida;
        --select @cd_nfse_xml

/*-----------------------------------------------------------------------------------------
  2) Busca dados da NFSe (XML + colunas da tabela para fallback)
-----------------------------------------------------------------------------------------*/
DECLARE
    @t_nr_nfse             VARCHAR(30),
    @t_cd_verificacao      VARCHAR(60),
    @t_dt_emissao          DATETIME,
    @t_cnpj_prestador      VARCHAR(20),
    @t_cnpj_tomador        VARCHAR(20),
    @t_im_prestador        VARCHAR(30),
    @t_vl_servicos         DECIMAL(18,2),
    @t_vl_iss              DECIMAL(18,2),
    @t_vl_liquido          DECIMAL(18,2),
    @t_aliq_iss            DECIMAL(18,6),
    @t_base_calculo        DECIMAL(18,2),
    @t_item_lista_servico  VARCHAR(30),
    @t_cod_trib_municipio  VARCHAR(60),
    @t_municipio_prestacao VARCHAR(30),
    @t_ds_discriminacao    NVARCHAR(2000);

    
SELECT TOP (1)
    @ds_xml              = n.ds_xml,
    @cd_empresa          = COALESCE(@cd_empresa, n.cd_empresa),

    -- fallback (campos da tabela)
    @t_nr_nfse             = n.nr_nfse,
    @t_cd_verificacao      = n.cd_verificacao,
    @t_dt_emissao          = n.dt_emissao,
    @t_cnpj_prestador      = n.cnpj_prestador,
    @t_cnpj_tomador        = isnull(n.cnpj_tomador, f.cd_cnpj_fornecedor),
    @t_im_prestador        = n.im_prestador,
    @t_vl_servicos         = n.vl_servicos,
    @t_vl_iss              = n.vl_iss,
    @t_vl_liquido          = n.vl_liquido,
    @t_aliq_iss            = n.aliq_iss,
    @t_base_calculo        = n.base_calculo,
    @t_item_lista_servico  = n.item_lista_servico,
    @t_cod_trib_municipio  = n.cod_trib_municipio,
    @t_municipio_prestacao = n.municipio_prestacao,
    @t_ds_discriminacao    = n.ds_discriminacao
FROM dbo.nfse_xml AS n WITH (NOLOCK)
   left outer join fornecedor f on f.cd_fornecedor = n.cd_fornecedor

WHERE n.cd_nfse_xml = @cd_nfse_xml;

  /*-----------------------------------------------------------------------------------------
  3) Sanitiza XML e converte (se existir). Se não existir ou falhar, usa fallback da tabela.
-----------------------------------------------------------------------------------------*/
IF NULLIF(@ds_xml, N'') IS NOT NULL
BEGIN
    SET @ds_xml = REPLACE(@ds_xml, NCHAR(65279), N''); -- remove BOM

    IF LEFT(LTRIM(@ds_xml), 5) = N'<?xml'
    BEGIN
        DECLARE @pos_header INT = CHARINDEX(N'?>', @ds_xml);
        IF @pos_header > 0 SET @ds_xml = STUFF(@ds_xml, 1, @pos_header + 2, N'');
    END;

    SET @xml = TRY_CONVERT(XML, @ds_xml);

    -- se falhar o parse, derruba o xml e cai no fallback
 IF @xml IS NULL
   BEGIN
      SET @ds_xml = NULL;
      SET @xml = NULL; -- ✅ garante fallback
   END
END
ELSE
BEGIN
   SET @xml = NULL; -- ✅ garante fallback
END
        /*-----------------------------------------------------------------------------------------
          4) Cabe�alho do relat�rio (relatorio + empresa)
        -----------------------------------------------------------------------------------------*/
        SELECT
            @titulo              = ISNULL(r.nm_relatorio, @titulo),
            @nm_titulo_relatorio = NULLIF(r.nm_titulo_relatorio, ''),
            @ds_relatorio        = ISNULL(r.ds_relatorio, '')
        FROM egisadmin.dbo.relatorio AS r
        WHERE r.cd_relatorio = @cd_relatorio;

        SET @cd_empresa = ISNULL(NULLIF(@cd_empresa, 0), dbo.fn_empresa());

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
        LEFT JOIN Cidade AS c  ON c.cd_cidade  = e.cd_cidade
        LEFT JOIN Estado AS est ON est.cd_estado = c.cd_estado
        WHERE e.cd_empresa = @cd_empresa;

        /*-----------------------------------------------------------------------------------------
          5) Extrai dados do XML (layout Abrasf/Ginfes)
        -----------------------------------------------------------------------------------------*/

        IF @xml IS NOT NULL
        BEGIN
        SELECT
            @nr_nfse         = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="IdentificacaoNfse"]/*[local-name()="Numero"]/text())[1]', 'varchar(30)'), ''),
            @cd_verificacao  = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="IdentificacaoNfse"]/*[local-name()="CodigoVerificacao"]/text())[1]', 'varchar(60)'), ''),
            @dt_emissao      = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="DataEmissao"]/text())[1]', 'varchar(40)'), ''),
            @cnpj_prestador  = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="PrestadorServico"]//*[local-name()="IdentificacaoPrestador"]/*[local-name()="Cnpj"]/text())[1]', 'varchar(20)'), ''),
            @im_prestador    = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="PrestadorServico"]//*[local-name()="IdentificacaoPrestador"]/*[local-name()="InscricaoMunicipal"]/text())[1]', 'varchar(30)'), ''),
            @razao_prestador = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="PrestadorServico"]/*[local-name()="RazaoSocial"]/text())[1]', 'varchar(200)'), ''),
            @fantasia_prestador = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="PrestadorServico"]/*[local-name()="NomeFantasia"]/text())[1]', 'varchar(200)'), ''),
            @endereco_prestador = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="PrestadorServico"]/*[local-name()="Endereco"]/*[local-name()="Endereco"]/text())[1]', 'varchar(200)'), ''),
            @numero_prestador   = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="PrestadorServico"]/*[local-name()="Endereco"]/*[local-name()="Numero"]/text())[1]', 'varchar(20)'), ''),
            @bairro_prestador   = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="PrestadorServico"]/*[local-name()="Endereco"]/*[local-name()="Bairro"]/text())[1]', 'varchar(80)'), ''),
            @municipio_prestador = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="PrestadorServico"]/*[local-name()="Endereco"]/*[local-name()="Municipio"]/text())[1]', 'varchar(80)'), ''),
            @uf_prestador       = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="PrestadorServico"]/*[local-name()="Endereco"]/*[local-name()="Uf"]/text())[1]', 'varchar(5)'), ''),
            @cep_prestador      = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="PrestadorServico"]/*[local-name()="Endereco"]/*[local-name()="Cep"]/text())[1]', 'varchar(20)'), ''),
            @cnpj_tomador       = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="TomadorServico"]//*[local-name()="CpfCnpj"]/*[local-name()="Cnpj"]/text())[1]', 'varchar(20)'), ''),
            @cpf_tomador        = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="TomadorServico"]//*[local-name()="CpfCnpj"]/*[local-name()="Cpf"]/text())[1]', 'varchar(20)'), ''),
            @razao_tomador      = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="TomadorServico"]/*[local-name()="RazaoSocial"]/text())[1]', 'varchar(200)'), ''),
            @endereco_tomador   = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="TomadorServico"]/*[local-name()="Endereco"]/*[local-name()="Endereco"]/text())[1]', 'varchar(200)'), ''),
            @numero_tomador     = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="TomadorServico"]/*[local-name()="Endereco"]/*[local-name()="Numero"]/text())[1]', 'varchar(20)'), ''),
            @bairro_tomador     = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="TomadorServico"]/*[local-name()="Endereco"]/*[local-name()="Bairro"]/text())[1]', 'varchar(80)'), ''),
            @municipio_tomador  = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="TomadorServico"]/*[local-name()="Endereco"]/*[local-name()="Municipio"]/text())[1]', 'varchar(80)'), ''),
            @uf_tomador         = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="TomadorServico"]/*[local-name()="Endereco"]/*[local-name()="Uf"]/text())[1]', 'varchar(5)'), ''),
            @cep_tomador        = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="TomadorServico"]/*[local-name()="Endereco"]/*[local-name()="Cep"]/text())[1]', 'varchar(20)'), ''),
            @item_lista_servico = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="Servico"]/*[local-name()="ItemListaServico"]/text())[1]', 'varchar(30)'), ''),
            @cod_trib_municipio = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="Servico"]/*[local-name()="CodigoTributacaoMunicipio"]/text())[1]', 'varchar(30)'), ''),
            @municipio_prestacao = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="Servico"]/*[local-name()="MunicipioPrestacaoServico"]/text())[1]', 'varchar(30)'), ''),
            @ds_discriminacao   = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="Servico"]/*[local-name()="Discriminacao"]/text())[1]', 'nvarchar(2000)'), ''),
            @vl_servicos        = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="Servico"]/*[local-name()="Valores"]/*[local-name()="ValorServicos"]/text())[1]', 'varchar(40)'), ''),
            @vl_base_calculo    = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="Servico"]/*[local-name()="Valores"]/*[local-name()="BaseCalculo"]/text())[1]', 'varchar(40)'), ''),
            @vl_iss             = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="Servico"]/*[local-name()="Valores"]/*[local-name()="ValorIss"]/text())[1]', 'varchar(40)'), ''),
            @vl_liquido         = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="Servico"]/*[local-name()="Valores"]/*[local-name()="ValorLiquidoNfse"]/text())[1]', 'varchar(40)'), ''),
            @aliq_iss           = ISNULL(@xml.value('(/*[local-name()="Nfse"]/*[local-name()="Servico"]/*[local-name()="Valores"]/*[local-name()="Aliquota"]/text())[1]', 'varchar(40)'), '');


            --Aliquota do ISS
            --TRY_CAST(valor AS INT) 
            set @t_aliq_iss   = try_cast(@aliq_iss as DECIMAL(18,6))
            
            --

         END

ELSE
BEGIN

  declare @cd_fornecedor int = 0

    -- dados “crus”
    SET @nr_nfse            = ISNULL(@t_nr_nfse, '');
    SET @cd_verificacao     = ISNULL(@t_cd_verificacao, '');

    -- data: dd/MM/yyyy HH:mm:ss
    SET @dt_emissao =
        CASE
            WHEN @t_dt_emissao IS NULL THEN ''
            ELSE CONVERT(VARCHAR(10), @t_dt_emissao, 103) + ' ' + CONVERT(VARCHAR(8), @t_dt_emissao, 108)
        END;

    -- cnpj (sem função pronta, só mantém; se quiser, eu te passo máscara)
    SET @cnpj_prestador     = ISNULL(@t_cnpj_prestador, '');
    SET @cnpj_tomador       = ISNULL(@t_cnpj_tomador, '');
    SET @im_prestador       = ISNULL(@t_im_prestador, '');

    SET @item_lista_servico  = ISNULL(@t_item_lista_servico, '');
    SET @cod_trib_municipio  = ISNULL(@t_cod_trib_municipio, '');
    SET @municipio_prestacao = ISNULL(@t_municipio_prestacao, '');
    SET @ds_discriminacao    = ISNULL(@t_ds_discriminacao, '');

    -- valores formatados pt-BR (500.00 -> 500,00)
    SET @vl_servicos =
        CASE WHEN @t_vl_servicos IS NULL THEN '' ELSE REPLACE(CONVERT(VARCHAR(40), CONVERT(MONEY, @t_vl_servicos), 1), '.', ',') END;
    SET @vl_base_calculo =
        CASE WHEN @t_base_calculo IS NULL THEN '' ELSE REPLACE(CONVERT(VARCHAR(40), CONVERT(MONEY, @t_base_calculo), 1), '.', ',') END;
    SET @vl_iss =
        CASE WHEN @t_vl_iss IS NULL THEN '' ELSE REPLACE(CONVERT(VARCHAR(40), CONVERT(MONEY, @t_vl_iss), 1), '.', ',') END;
    SET @vl_liquido =
        CASE WHEN @t_vl_liquido IS NULL THEN '' ELSE REPLACE(CONVERT(VARCHAR(40), CONVERT(MONEY, @t_vl_liquido), 1), '.', ',') END;

    -- aliquota (0.0348 -> 3,48%)
    SET @aliq_iss =
        CASE
            WHEN @t_aliq_iss IS NULL THEN ''
            ELSE REPLACE(CONVERT(VARCHAR(40), CONVERT(DECIMAL(18,4), @t_aliq_iss * 100.0)), '.', ',') + '%'
        END;
END

if @t_aliq_iss>0
begin


  SET @aliq_iss =
        CASE
            WHEN @t_aliq_iss IS NULL THEN ''
            ELSE REPLACE(CONVERT(VARCHAR(40), CONVERT(DECIMAL(18,4), @t_aliq_iss * 100.0)), '.', ',') + '%'
        END;

  set @t_vl_iss     = @t_aliq_iss * @t_base_calculo
  set @t_vl_liquido = @t_base_calculo - @t_vl_iss

  SET @vl_iss =
        CASE WHEN @t_vl_iss IS NULL THEN '' ELSE REPLACE(CONVERT(VARCHAR(40), CONVERT(MONEY, @t_vl_iss), 1), '.', ',') END;
  
  SET @vl_liquido =
        CASE WHEN @t_vl_liquido IS NULL THEN '' ELSE REPLACE(CONVERT(VARCHAR(40), CONVERT(MONEY, @t_vl_liquido), 1), '.', ',') END;


end
        /*-----------------------------------------------------------------------------------------
          6) Monta o HTML final
        -----------------------------------------------------------------------------------------*/
        DECLARE @html NVARCHAR(MAX);

        SET @html =
N'<style>
  body { font-family: "Segoe UI", Arial, sans-serif; color: #222; }
  .nfse-container { width: 100%; border: 1px solid #ddd; padding: 1px; }
  .nfse-header { display: flex; justify-content: space-between; border-bottom: 2px solid ' + @nm_cor_empresa + N'; padding-bottom: 10px; margin-bottom: 12px; }
  .nfse-header__logo img { max-height: 70px; }
  .nfse-header__title { text-align: right; }
  .nfse-title { font-size: 20px; font-weight: 700; margin: 0; }
  .nfse-subtitle { font-size: 13px; margin: 4px 0 0 0; color: #555; }
  .nfse-section { margin-top: 16px; }
  .nfse-section h3 { font-size: 14px; margin: 0 0 6px 0; color: ' + @nm_cor_empresa + N'; }
  .nfse-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 6px 20px; font-size: 13px; }
  .nfse-grid span { display: block; }
  .nfse-values { width: 100%; border-collapse: collapse; margin-top: 8px; font-size: 13px; }
  .nfse-values th, .nfse-values td { border: 1px solid #ddd; padding: 6px 8px; text-align: right; }
  .nfse-values th { background: #f5f5f5; }
  .nfse-values td:first-child, .nfse-values th:first-child { text-align: left; }
  .nfse-footer { margin-top: 18px; font-size: 12px; color: #666; }
</style>' +
N'<div class="nfse-container">' +
  N'<div class="nfse-header">' +
    N'<div class="nfse-header__logo"><img src="' + @logo + N'" alt="Logo da Empresa"></div>' +
    N'<div class="nfse-header__title">' +
      N'<p class="nfse-title">' + ISNULL(@nm_titulo_relatorio, @titulo) + N'</p>' +
      N'<p class="nfse-subtitle">NFS-e: ' + @nr_nfse + N' | Verificação: ' + @cd_verificacao + N'</p>' +
      N'<p class="nfse-subtitle">Emissão: ' + @dt_emissao + N'</p>' +
    N'</div>' +
  N'</div>' +
  N'<div class="nfse-section">' +
    N'<h3>Prestador de Serviço</h3>' +
    N'<div class="nfse-grid">' +
      N'<span><strong>Razão Social:</strong> ' + @razao_prestador + N'</span>' +
      N'<span><strong>Nome Fantasia:</strong> ' + @fantasia_prestador + N'</span>' +
      N'<span><strong>CNPJ:</strong> ' + @cnpj_prestador + N'</span>' +
      N'<span><strong>Insc. Municipal:</strong> ' + @im_prestador + N'</span>' +
      N'<span><strong>Endereço:</strong> ' + @endereco_prestador + N', ' + @numero_prestador + N' - ' + @bairro_prestador + N'</span>' +
      N'<span><strong>Município:</strong> ' + @municipio_prestador + N'/' + @uf_prestador + N' - CEP ' + @cep_prestador + N'</span>' +
    N'</div>' +
  N'</div>' +
  N'<div class="nfse-section">' +
    N'<h3>Tomador de Serviço</h3>' +
    N'<div class="nfse-grid">' +
      N'<span><strong>Razão Social:</strong> ' + @razao_tomador + N'</span>' +
      N'<span><strong>CNPJ/CPF:</strong> ' + CASE WHEN @cnpj_tomador <> '' THEN @cnpj_tomador ELSE @cpf_tomador END + N'</span>' +
      N'<span><strong>Endereço:</strong> ' + @endereco_tomador + N', ' + @numero_tomador + N' - ' + @bairro_tomador + N'</span>' +
      N'<span><strong>Município:</strong> ' + @municipio_tomador + N'/' + @uf_tomador + N' - CEP ' + @cep_tomador + N'</span>' +
    N'</div>' +
  N'</div>' +
  N'<div class="nfse-section">' +
    N'<h3>Serviço</h3>' +
    N'<div class="nfse-grid">' +
      N'<span><strong>Item Lista Serviço:</strong> ' + @item_lista_servico + N'</span>' +
      N'<span><strong>Tributação Município:</strong> ' + @cod_trib_municipio + N'</span>' +
      N'<span><strong>Município Prestação:</strong> ' + @municipio_prestacao + N'</span>' +
    N'</div>' +
    N'<p style="margin-top:8px; font-size:13px;"><strong>Discriminação:</strong><br>' + @ds_discriminacao + N'</p>' +
  N'</div>' +
  N'<div class="nfse-section">' +
    N'<h3>Valores</h3>' +
    N'<table class="nfse-values">' +
      N'<tr><th>Descrição</th><th>Valor</th></tr>' +
      N'<tr><td>Valor dos Serviços</td><td>' + @vl_servicos + N'</td></tr>' +
      N'<tr><td>Base de Cálculo</td><td>' + @vl_base_calculo + N'</td></tr>' +
      N'<tr><td>Alíquota ISS</td><td>' + @aliq_iss + N'</td></tr>' +
      N'<tr><td>Valor ISS</td><td>' + @vl_iss + N'</td></tr>' +
      N'<tr><td>Valor Líquido</td><td>' + @vl_liquido + N'</td></tr>' +
    N'</table>' +
  N'</div>' +
  N'<div class="nfse-footer">' +
    N'<div><strong>' + @nm_fantasia_empresa + N'</strong> | CNPJ: ' + @cd_cnpj_empresa + N'</div>' +
    N'<div>' + @nm_endereco_empresa + N', ' + @cd_numero_endereco + N' - ' + @nm_bairro_empresa + N' - ' + @nm_cidade_empresa + N'/' + @sg_estado_empresa + N' - CEP ' + @cd_cep_empresa + N'</div>' +
    N'<div>Telefone: ' + @cd_telefone_empresa + N' | E-mail: ' + @nm_email_internet + N'</div>' +
    N'<div>Emitido em ' + @data_hora_atual + N'</div>' +
  N'</div>' +
N'</div>';

        SELECT ISNULL(@html, N'') AS RelatorioHTML;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50010, @ErrorMessage, 1;
    END CATCH
END;
GO


--exec pr_egis_relatorio_nota_servico '[{"cd_nfse_xml": 11}]'
