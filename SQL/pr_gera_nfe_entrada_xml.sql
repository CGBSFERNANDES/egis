/*
pr_gera_nfe_entrada_xml
-------------------------------------------
Lê o XML armazenado em nota_xml(ds_xml) e popula:
- NFE_Emitente
- NFE_Destinatario
- NFE_Nota
- NFE_Produto_Servico
- NFE_IPI
- NFE_Total_Nota
- NFE_Parcela

select * from nota_entrada
select * from NFE_Emitente
select * from NFE_Destinatario
select * from NFE_Nota
select * from NFE_Produto_Servico
select * from NFE_IPI
select * from NFE_Total_Nota
select * from NFE_Parcela

---------------------------------------------------------------------------

delete from NFE_Emitente
delete from NFE_Destinatario
delete from NFE_Nota
delete from NFE_Produto_Servico
delete from NFE_IPI
delete from NFE_Total_Nota
delete from NFE_Parcela
delete from nota_xml

delete from nota_entrada_item
delete from nota_entrada_documento
delete from nota_entrada_parcela
delete from nota_entrada_registro
delete from nota_entrada_item_registro
delete from nota_entrada_complemento
delete from nota_entrada_documento
delete from nota_entrada
delete from documento_pagar_pagamento
delete from documento_pagar
delete from movimento_estoque

--------------------------------------------------------------------------------------

--select * from nota_entrada
--select * from nota_xml
--select * from documento_pagar

--update produto set cd_codigo_barra_produto = ''


Pré-requisitos recomendados (ajuste conforme seu banco):
- Tabela dbo.nota_xml com colunas: cd_nota INT (PK) e ds_xml NVARCHAR(MAX) ou XML (conteúdo do XML da NF-e)
- Sequences para chaves técnicas quando aplicável.
*/

/* ===== Sequences (opcionais; ajuste/execute uma vez) ===== */
IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'seq_nfe_emitente')
    EXEC('CREATE SEQUENCE dbo.seq_nfe_emitente AS INT START WITH 1 INCREMENT BY 1');
IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'seq_nfe_destinatario')
    EXEC('CREATE SEQUENCE dbo.seq_nfe_destinatario AS INT START WITH 1 INCREMENT BY 1');

GO

CREATE OR ALTER PROCEDURE pr_gera_nfe_entrada_xml
(
    @cd_nota INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xml XML;
    
    --select * from nota_xml

    --select @cd_nota

    /* Lê o XML da nota */
-- lê da Nota_XML pelo cd_xml_nota e remove a declaração XML antes de converter

SELECT @xml = TRY_CONVERT(XML,
    CASE 
      WHEN LEFT(LTRIM(CAST(ds_xml AS NVARCHAR(MAX))),5)='<?xml'
        THEN STUFF(CAST(ds_xml AS NVARCHAR(MAX)), 1, CHARINDEX('?>', CAST(ds_xml AS NVARCHAR(MAX)))+1, '')
      ELSE CAST(ds_xml AS NVARCHAR(MAX))
    END)
FROM dbo.Nota_XML WITH (NOLOCK)
WHERE cd_xml_nota = @cd_nota;


    --select @xml
    
    IF @xml IS NULL
    BEGIN
        RAISERROR('XML não encontrado ou inválido para cd_nota=%d.', 16, 1, @cd_nota);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        /* ====== Captura nós principais ignorando namespaces via *: ====== */
        DECLARE @tpAmb INT,
                @natOp NVARCHAR(60),
                @serie INT,
                @nNF INT,
                @dhEmi DATETIME,
                @dhSaiEnt DATETIME,
                @indFinal INT,
                @idDest INT,
                @finNFe INT,
                @chNFe VARCHAR(45),
                @nProt VARCHAR(40),
                @dhRecbto DATETIME,
                @cUF INT,
                @mod INT;

        /* IDE */
        SELECT
            @cUF      = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:cUF/text())[1]', 'int'),
            @natOp    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:natOp/text())[1]', 'nvarchar(60)'),
            @mod      = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:mod/text())[1]', 'int'),
            @serie    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:serie/text())[1]', 'int'),
            @nNF      = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:nNF/text())[1]', 'int'),
            @dhEmi    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:dhEmi/text())[1]', 'datetime'),
            @dhSaiEnt = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:dhSaiEnt/text())[1]', 'datetime'),
            @tpAmb    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:tpAmb/text())[1]', 'int'),
            @indFinal = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:indFinal/text())[1]', 'int'),
            @idDest   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:idDest/text())[1]', 'int'),
            @finNFe   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:ide/*:finNFe/text())[1]', 'int');

        /* Protocolo/autorização */
        SELECT
            @chNFe   = @xml.value('(/*:nfeProc/*:protNFe/*:infProt/*:chNFe/text())[1]', 'varchar(45)'),
            @nProt   = @xml.value('(/*:nfeProc/*:protNFe/*:infProt/*:nProt/text())[1]', 'varchar(40)'),
            @dhRecbto= @xml.value('(/*:nfeProc/*:protNFe/*:infProt/*:dhRecbto/text())[1]', 'datetime');

        /* ====== Emitente ====== */
        DECLARE @emit_xNome NVARCHAR(60), @emit_xFant NVARCHAR(60), @emit_CNPJ VARCHAR(18), @emit_CPF VARCHAR(18),
                @emit_xLgr NVARCHAR(60), @emit_nro NVARCHAR(15), @emit_xCpl NVARCHAR(60), @emit_xBairro NVARCHAR(60),
                @emit_cMun VARCHAR(7), @emit_xMun NVARCHAR(60), @emit_UF CHAR(2), @emit_CEP VARCHAR(8),
                @emit_cPais VARCHAR(4), @emit_xPais NVARCHAR(60), @emit_fone VARCHAR(15),
                @emit_IE VARCHAR(18), @emit_IEST VARCHAR(18), @emit_IM VARCHAR(18), @emit_CNAE VARCHAR(7), @emit_CRT INT;

        SELECT
            @emit_xNome = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:xNome/text())[1]', 'nvarchar(60)'),
            @emit_xFant = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:xFant/text())[1]', 'nvarchar(60)'),
            @emit_CNPJ  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:CNPJ/text())[1]', 'varchar(18)'),
            @emit_CPF   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:CPF/text())[1]', 'varchar(18)'),
            @emit_xLgr  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:xLgr/text())[1]', 'nvarchar(60)'),
            @emit_nro   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:nro/text())[1]', 'nvarchar(15)'),
            @emit_xCpl  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:xCpl/text())[1]', 'nvarchar(60)'),
            @emit_xBairro=@xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:xBairro/text())[1]', 'nvarchar(60)'),
            @emit_cMun  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:cMun/text())[1]', 'varchar(7)'),
            @emit_xMun  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:xMun/text())[1]', 'nvarchar(60)'),
            @emit_UF    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:UF/text())[1]', 'char(2)'),
            @emit_CEP   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:CEP/text())[1]', 'varchar(8)'),
            @emit_cPais = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:cPais/text())[1]', 'varchar(4)'),
            @emit_xPais = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:xPais/text())[1]', 'nvarchar(60)'),
            @emit_fone  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:enderEmit/*:fone/text())[1]', 'varchar(15)'),
            @emit_IE    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:IE/text())[1]', 'varchar(18)'),
            @emit_IEST  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:IEST/text())[1]', 'varchar(18)'),
            @emit_IM    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:IM/text())[1]', 'varchar(18)'),
            @emit_CNAE  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:CNAE/text())[1]', 'varchar(7)'),
            @emit_CRT   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:emit/*:CRT/text())[1]', 'int');

        DECLARE @cd_emitente INT;

        /* Tenta localizar emitente por CNPJ/CPF */
        SELECT TOP 1 @cd_emitente = cd_emitente
        FROM dbo.NFE_Emitente WITH (UPDLOCK, HOLDLOCK)
        WHERE (NULLIF(@emit_CNPJ,'') IS NOT NULL AND cd_cnpj_emitente = @emit_CNPJ)
           OR (NULLIF(@emit_CPF,'')  IS NOT NULL AND cd_cpf_emitente  = @emit_CPF);

        IF @cd_emitente IS NULL
        BEGIN
            SET @cd_emitente = NEXT VALUE FOR dbo.seq_nfe_emitente;
            INSERT INTO dbo.NFE_Emitente
            (
                cd_emitente, nm_emitente, nm_fantasia_emitente, cd_cnpj_emitente, cd_cpf_emitente,
                nm_endereco, cd_numero, nm_complemento, nm_bairro, cd_municipio, nm_municipio, sg_estado,
                cd_cep, cd_pais, nm_pais, nm_telefone, cd_inscricao, cd_inscricao_st, cd_inscricao_municipal,
                cd_cnae_fiscal, cd_regime_tributario, cd_usuario, dt_usuario, cd_status_emitente, cd_nota
            )
            VALUES
            (
                @cd_emitente, @emit_xNome, @emit_xFant, @emit_CNPJ, @emit_CPF,
                @emit_xLgr, @emit_nro, @emit_xCpl, @emit_xBairro, @emit_cMun, @emit_xMun, @emit_UF,
                @emit_CEP, @emit_cPais, @emit_xPais, @emit_fone, @emit_IE, @emit_IEST, @emit_IM,
                @emit_CNAE, @emit_CRT, NULL, GETDATE(), null, @cd_nota
            );
        END
        ELSE
        BEGIN
            UPDATE dbo.NFE_Emitente
            SET nm_emitente = ISNULL(@emit_xNome, nm_emitente),
                nm_fantasia_emitente = ISNULL(@emit_xFant, nm_fantasia_emitente),
                cd_cnpj_emitente = ISNULL(@emit_CNPJ, cd_cnpj_emitente),
                cd_cpf_emitente = ISNULL(@emit_CPF, cd_cpf_emitente),
                nm_endereco = ISNULL(@emit_xLgr, nm_endereco),
                cd_numero = ISNULL(@emit_nro, cd_numero),
                nm_complemento = ISNULL(@emit_xCpl, nm_complemento),
                nm_bairro = ISNULL(@emit_xBairro, nm_bairro),
                cd_municipio = ISNULL(@emit_cMun, cd_municipio),
                nm_municipio = ISNULL(@emit_xMun, nm_municipio),
                sg_estado = ISNULL(@emit_UF, sg_estado),
                cd_cep = ISNULL(@emit_CEP, cd_cep),
                cd_pais = ISNULL(@emit_cPais, cd_pais),
                nm_pais = ISNULL(@emit_xPais, nm_pais),
                nm_telefone = ISNULL(@emit_fone, nm_telefone),
                cd_inscricao = ISNULL(@emit_IE, cd_inscricao),
                cd_inscricao_st = ISNULL(@emit_IEST, cd_inscricao_st),
                cd_inscricao_municipal = ISNULL(@emit_IM, cd_inscricao_municipal),
                cd_cnae_fiscal = ISNULL(@emit_CNAE, cd_cnae_fiscal),
                cd_regime_tributario = ISNULL(@emit_CRT, cd_regime_tributario),
                dt_usuario = GETDATE(),
                cd_nota = @cd_nota
            WHERE cd_emitente = @cd_emitente;

        END

        /* ====== Destinatário ====== */
        DECLARE @dest_xNome NVARCHAR(60), @dest_xFant NVARCHAR(60), @dest_CNPJ VARCHAR(18), @dest_CPF VARCHAR(18),
                @dest_xLgr NVARCHAR(60), @dest_nro NVARCHAR(10), @dest_xCpl NVARCHAR(60), @dest_xBairro NVARCHAR(60),
                @dest_cMun INT, @dest_cUF INT, @dest_cPais INT, @dest_CEP VARCHAR(8), @dest_fone VARCHAR(15),
                @dest_IE VARCHAR(18), @dest_SUFRAMA VARCHAR(10), @dest_email VARCHAR(150),
                @dest_idPessoa INT;

        SELECT
            @dest_xNome = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:xNome/text())[1]', 'nvarchar(60)'),
            @dest_CNPJ  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:CNPJ/text())[1]', 'varchar(18)'),
            @dest_CPF   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:CPF/text())[1]', 'varchar(18)'),
            @dest_xLgr  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:enderDest/*:xLgr/text())[1]', 'nvarchar(60)'),
            @dest_nro   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:enderDest/*:nro/text())[1]', 'nvarchar(10)'),
            @dest_xCpl  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:enderDest/*:xCpl/text())[1]', 'nvarchar(60)'),
            @dest_xBairro=@xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:enderDest/*:xBairro/text())[1]', 'nvarchar(60)'),
            @dest_cMun  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:enderDest/*:cMun/text())[1]', 'int'),
            @dest_cUF   = NULL,
            @dest_cPais = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:enderDest/*:cPais/text())[1]', 'int'),
            @dest_CEP   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:enderDest/*:CEP/text())[1]', 'varchar(8)'),
            @dest_fone  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:enderDest/*:fone/text())[1]', 'varchar(15)'),
            @dest_IE    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:IE/text())[1]', 'varchar(18)'),
            @dest_SUFRAMA=@xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:ISUF/text())[1]', 'varchar(10)'),
            @dest_email = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:dest/*:email/text())[1]', 'varchar(150)');

        DECLARE @cd_destinatario INT;
        SELECT TOP 1 @cd_destinatario = cd_destinatario
        FROM dbo.NFE_Destinatario WITH (UPDLOCK, HOLDLOCK)
        WHERE (NULLIF(@dest_CNPJ,'') IS NOT NULL AND cd_cnpj = @dest_CNPJ)
           OR (NULLIF(@dest_CPF,'')  IS NOT NULL AND cd_cpf  = @dest_CPF);

        IF @cd_destinatario IS NULL
        BEGIN
            SET @cd_destinatario = NEXT VALUE FOR dbo.seq_nfe_destinatario;
            INSERT INTO dbo.NFE_Destinatario
            (
                cd_destinatario, cd_tipo_destinatario, nm_destinatario, nm_fantasia_destinatario, cd_interface,
                dt_cadastro_destinatario, cd_usuario, dt_usuario, cd_auxiliar, cd_cnpj, cd_cpf, nm_endereco, cd_numero,
                nm_complemento, nm_bairro, cd_cidade, cd_estado, cd_pais, cd_cep, cd_telefone,
                cd_inscricao_estadual, cd_suframa, cd_email, cd_nota
            )
            VALUES
            (
                @cd_destinatario, @idDest, @dest_xNome, NULL, NULL,
                GETDATE(), NULL, GETDATE(), NULL, @dest_CNPJ, @dest_CPF, @dest_xLgr, @dest_nro,
                @dest_xCpl, @dest_xBairro, @dest_cMun, @cUF, @dest_cPais, @dest_CEP, @dest_fone,
                @dest_IE, @dest_SUFRAMA, @dest_email, @cd_nota
            );
        END
        ELSE
        BEGIN
            UPDATE dbo.NFE_Destinatario
            SET nm_destinatario = ISNULL(@dest_xNome, nm_destinatario),
                cd_cnpj = ISNULL(@dest_CNPJ, cd_cnpj),
                cd_cpf  = ISNULL(@dest_CPF, cd_cpf),
                nm_endereco = ISNULL(@dest_xLgr, nm_endereco),
                cd_numero   = ISNULL(@dest_nro, cd_numero),
                nm_complemento = ISNULL(@dest_xCpl, nm_complemento),
                nm_bairro = ISNULL(@dest_xBairro, nm_bairro),
                cd_cidade = ISNULL(@dest_cMun, cd_cidade),
                cd_estado = ISNULL(@cUF, cd_estado),
                cd_pais = ISNULL(@dest_cPais, cd_pais),
                cd_cep = ISNULL(@dest_CEP, cd_cep),
                cd_telefone = ISNULL(@dest_fone, cd_telefone),
                cd_inscricao_estadual = ISNULL(@dest_IE, cd_inscricao_estadual),
                cd_suframa = ISNULL(@dest_SUFRAMA, cd_suframa),
                cd_email = ISNULL(@dest_email, cd_email),
                dt_usuario = GETDATE(),
                cd_nota = @cd_nota
            WHERE cd_destinatario = @cd_destinatario;
        END

        /* ====== Nota (cabeçalho) ====== */
        DECLARE @infCpl NVARCHAR(MAX) = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:infAdic/*:infCpl/text())[1]', 'nvarchar(max)');

        IF EXISTS (SELECT 1 FROM dbo.NFE_Nota WITH (NOLOCK) WHERE cd_nota = @cd_nota)
        BEGIN
            UPDATE dbo.NFE_Nota
            SET cd_identificacao = @nNF,
                cd_serie_nota    = @serie,
                cd_tipo_nota     = @mod,
                cd_chave_acesso  = @chNFe,
                dt_emissao_nota  = @dhEmi,
                dt_entrada_nota  = ISNULL(@dhSaiEnt, @dhEmi),
                cd_destinatario  = @cd_destinatario,
                dt_autorizacao_nota = @dhRecbto,
                cd_protocolo_nota = @nProt,
                cd_situacao = 1,
                cd_emitente = @cd_emitente,
                ds_inf_adicional = @infCpl,
                sg_versao_nfe = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/@versao)[1]','varchar(10)'),
                dt_usuario = GETDATE()
            WHERE cd_nota = @cd_nota;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.NFE_Nota
            (
                cd_nota, cd_identificacao, cd_serie_nota, cd_tipo_nota, cd_chave_acesso,
                dt_emissao_nota, dt_entrada_nota, dt_vencimento_nota, cd_destinatario,
                dt_autorizacao_nota, cd_protocolo_nota, cd_recibo_nota, cd_situacao, cd_sistema,
                nm_xmls_nota, nm_obs_nota, cd_usuario, dt_usuario, cd_finalidade_nfe, cd_forma_emissao,
                cd_ambiente, cd_formato_impressao, cd_ano, cd_mes, ic_destinatario, ic_transportadora,
                ic_contabilidade, ic_fiscal, ic_email, ic_download, cd_emitente, sg_versao_nfe, cd_origem, ds_inf_adicional
            )
            VALUES
            (
                @cd_nota, @nNF, @serie, @mod, @chNFe,
                @dhEmi, ISNULL(@dhSaiEnt, @dhEmi), NULL, @cd_destinatario,
                @dhRecbto, @nProt, NULL, 1, NULL,
                NULL, NULL, NULL, GETDATE(), @finNFe, NULL,
                @tpAmb, NULL, YEAR(ISNULL(@dhEmi, GETDATE())), MONTH(ISNULL(@dhEmi, GETDATE())), NULL, NULL,
                NULL, NULL, NULL, NULL, @cd_emitente, @xml.value('(/*:nfeProc/*:NFe/*:infNFe/@versao)[1]','varchar(10)'), NULL, @infCpl
            );
        END

        /* ====== Totais ====== */
        DECLARE @vBC FLOAT, @vICMS FLOAT, @vBCST FLOAT, @vST FLOAT, @vProd FLOAT, @vFrete FLOAT,
                @vSeg FLOAT, @vDesc FLOAT, @vII FLOAT, @vIPI FLOAT, @vPIS FLOAT, @vCOFINS FLOAT,
                @vOutro FLOAT, @vNF FLOAT, @vServ FLOAT, @vBCISS FLOAT, @vISS FLOAT,
                @vRetPIS FLOAT, @vRETCOFINS FLOAT, @vRETCSLL FLOAT, @vBCIRRF FLOAT, @vIRRF FLOAT,
                @vBCRetPrev FLOAT, @vRetPrev FLOAT;

        SELECT
            @vBC     = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vBC/text())[1]', 'float'),
            @vICMS   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vICMS/text())[1]', 'float'),
            @vBCST   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vBCST/text())[1]', 'float'),
            @vST     = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vST/text())[1]', 'float'),
            @vProd   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vProd/text())[1]', 'float'),
            @vFrete  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vFrete/text())[1]', 'float'),
            @vSeg    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vSeg/text())[1]', 'float'),
            @vDesc   = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vDesc/text())[1]', 'float'),
            @vII     = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vII/text())[1]', 'float'),
            @vIPI    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vIPI/text())[1]', 'float'),
            @vPIS    = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vPIS/text())[1]', 'float'),
            @vCOFINS = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vCOFINS/text())[1]', 'float'),
            @vOutro  = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vOutro/text())[1]', 'float'),
            @vNF     = @xml.value('(/*:nfeProc/*:NFe/*:infNFe/*:total/*:ICMSTot/*:vNF/text())[1]', 'float');

        MERGE dbo.NFE_Total_Nota AS tgt
        USING (SELECT @cd_nota cd_nota) AS src
        ON tgt.cd_nota = src.cd_nota
        WHEN MATCHED THEN UPDATE SET
            vBC=@vBC, vICMS=@vICMS, vBCST=@vBCST, vST=@vST, vProd=@vProd, vFrete=@vFrete, vSeg=@vSeg,
            vDesc=@vDesc, vII=@vII, vIPI=@vIPI, vPis=@vPIS, vCOFINS=@vCOFINS, vOutro=@vOutro,
            vNF=@vNF, dt_usuario=GETDATE()
        WHEN NOT MATCHED THEN INSERT (cd_nota, vBC, vICMS, vBCST, vST, vProd, vFrete, vSeg, vDesc, vII, vIPI, vPis, vCOFINS, vOutro, vNF, cd_usuario, dt_usuario)
        VALUES (@cd_nota, @vBC, @vICMS, @vBCST, @vST, @vProd, @vFrete, @vSeg, @vDesc, @vII, @vIPI, @vPIS, @vCOFINS, @vOutro, @vNF, NULL, GETDATE());

        /* ====== Itens: NFE_Produto_Servico + NFE_IPI ====== */
        /* Limpa itens anteriores (opcional) */
        DELETE FROM dbo.NFE_IPI WHERE cd_nota = @cd_nota;
        DELETE FROM dbo.NFE_Produto_Servico WHERE cd_nota = @cd_nota;

        ;WITH Itens AS (
            SELECT
                TRY_CAST(Det.value('@nItem','int') AS INT)              AS nItem,
                Det.value('(./*:prod/*:cProd/text())[1]','varchar(60)') AS cProd,
                Det.value('(./*:prod/*:cEAN/text())[1]','varchar(60)')  AS cEAN,
                Det.value('(./*:prod/*:xProd/text())[1]','nvarchar(120)') AS xProd,
                Det.value('(./*:prod/*:NCM/text())[1]','varchar(8)')     AS NCM,
                Det.value('(./*:prod/*:EXTIPI/text())[1]','varchar(3)')  AS EXTIPI,
                Det.value('(./*:prod/*:CFOP/text())[1]','varchar(4)')    AS CFOP,
                Det.value('(./*:prod/*:uCom/text())[1]','varchar(6)')    AS uCom,
                Det.value('(./*:prod/*:qCom/text())[1]','float')         AS qCom,
                Det.value('(./*:prod/*:vUnCom/text())[1]','float')       AS vUnCom,
                Det.value('(./*:prod/*:vProd/text())[1]','float')        AS vProd,
                Det.value('(./*:prod/*:cEANTrib/text())[1]','varchar(60)') AS cEANTrib,
                Det.value('(./*:prod/*:uTrib/text())[1]','varchar(6)')   AS uTrib,
                Det.value('(./*:prod/*:qTrib/text())[1]','float')        AS qTrib,
                Det.value('(./*:prod/*:vUnTrib/text())[1]','float')      AS vUnTrib,
                Det.value('(./*:prod/*:vFrete/text())[1]','float')       AS vFrete,
                Det.value('(./*:prod/*:vSeg/text())[1]','float')         AS vSeg,
                Det.value('(./*:prod/*:vDesc/text())[1]','float')        AS vDesc,
                Det.value('(./*:prod/*:vOutro/text())[1]','float')       AS vOutro,
                Det.value('(./*:prod/*:indTot/text())[1]','int')         AS indTot,
                Det.query('./*:imposto')                                  AS ImpostoNode
            FROM @xml.nodes('/*:nfeProc/*:NFe/*:infNFe/*:det') AS T(Det)
        )
        INSERT INTO dbo.NFE_Produto_Servico
        (
            cd_nota, cd_item_nota, cProd, cEan, xProd, NCM, EXTIPI, CFOP, uCom, qCom, vUnCom, vProd, cEanTrib, uTrib, qTrib, vUndTrib,
            vFrete, vSeg, vDesc, vOutro, indTot, nDI, dDI, xLocDesemb, UFDesemb, dDesemb, cExportador, xPed, nItemPed,
            cd_usuario, dt_usuario, pPIS, vPIS, PISAliq_CST, PISAliq_vBC, pICMS, vICMS, COFINSAliq_CST, COFINSAliq_vBC,
            pCOFINS, vCOFINS, pIPI, vIPI, IPITrib_CST, IPITrib_vBC, ICMTrib_CST, vII, pII, pIVA, vBCST, vICMSST, cd_operacao_fiscal
        )
        SELECT
            @cd_nota, I.nItem, I.cProd, I.cEAN, I.xProd, I.NCM, I.EXTIPI, I.CFOP, I.uCom, I.qCom, I.vUnCom, I.vProd,
            I.cEANTrib, I.uTrib, I.qTrib, I.vUnTrib, I.vFrete, I.vSeg, I.vDesc, I.vOutro, I.indTot,
            NULL, NULL, NULL, NULL, NULL, NULL,
            Imp.value('(./*:ICMS/*//*[local-name()="CST" or local-name()="CSOSN"]/text())[1]','varchar(10)') AS xPed,
            Imp.value('(./*:ICMS/*//*[local-name()="pICMS"]/text())[1]','float') AS nItemPed,
            NULL, GETDATE(),
            Imp.value('(./*:PIS/*//*[local-name()="pPIS"]/text())[1]','float') AS pPIS,
            Imp.value('(./*:PIS/*//*[local-name()="vPIS"]/text())[1]','float') AS vPIS,
            Imp.value('(./*:PIS/*//*[local-name()="CST"]/text())[1]','varchar(10)') AS PISAliq_CST,
            Imp.value('(./*:PIS/*//*[local-name()="vBC"]/text())[1]','float') AS PISAliq_vBC,
            Imp.value('(./*:ICMS/*//*[local-name()="pICMS"]/text())[1]','float') AS pICMS,
            Imp.value('(./*:ICMS/*//*[local-name()="vICMS"]/text())[1]','float') AS vICMS,
            Imp.value('(./*:COFINS/*//*[local-name()="CST"]/text())[1]','varchar(10)') AS COFINSAliq_CST,
            Imp.value('(./*:COFINS/*//*[local-name()="vBC"]/text())[1]','float') AS COFINSAliq_vBC,
            Imp.value('(./*:COFINS/*//*[local-name()="pCOFINS"]/text())[1]','float') AS pCOFINS,
            Imp.value('(./*:COFINS/*//*[local-name()="vCOFINS"]/text())[1]','float') AS vCOFINS,
            Imp.value('(./*:IPI/*//*[local-name()="pIPI"]/text())[1]','float') AS pIPI,
            Imp.value('(./*:IPI/*//*[local-name()="vIPI"]/text())[1]','float') AS vIPI,
            Imp.value('(./*:IPI/*//*[local-name()="CST"]/text())[1]','varchar(10)') AS IPITrib_CST,
            Imp.value('(./*:IPI/*//*[local-name()="vBC"]/text())[1]','float') AS IPITrib_vBC,
            --Imp.value('(./*:ICMS/*/*[starts-with(local-name(),"ICMS")]/local-name()[1])','varchar(10)') AS ICMTrib_CST,
           -- Imp.value('(./*:ICMS/*[1]/local-name(.)[1])','varchar(10)') AS ICMTrib_CST,
         --  Imp.value('(./*:ICMS/*[1]/local-name(.)[1])','varchar(20)') AS ICMTrib_CST,
            --null AS ICMTrib_CST,
            Imp.value('local-name((./*:ICMS/*)[1])','varchar(20)') AS ICMTrib_CST,

            Imp.value('(./*:II/*:vII/text())[1]','float') AS vII,
            Imp.value('(./*:II/*:vDespAdu/text())[1]','float') AS pII,
            NULL AS pIVA,
            Imp.value('(./*:ICMS/*//*[local-name()="vBCST"]/text())[1]','float') AS vBCST,
            Imp.value('(./*:ICMS/*//*[local-name()="vICMSST"]/text())[1]','float') AS vICMSST,
            null as cd_operacao_fiscal

        FROM Itens I
        CROSS APPLY I.ImpostoNode.nodes('.') as N(Imp);

        /* Tabela NFE_IPI (separada para quem precisa) */
        INSERT INTO dbo.NFE_IPI
        (
            cd_nota, cd_item_nota, clEnq, CNPJProd, cSelo, qSelo, cEnq, IPITrib, CST, vBC, pIPI, qUnid, vUnid, vIPI,
            IPINT, CSTIPI, cd_usuario, dt_usuario
        )
        SELECT
            @cd_nota,
            TRY_CAST(Det.value('@nItem','int') AS INT) AS cd_item_nota,
            Det.value('(./*:imposto/*:IPI/*:clEnq/text())[1]','varchar(5)'),
            Det.value('(./*:imposto/*:IPI/*:CNPJProd/text())[1]','varchar(14)'),
            Det.value('(./*:imposto/*:IPI/*:cSelo/text())[1]','varchar(60)'),
            Det.value('(./*:imposto/*:IPI/*:qSelo/text())[1]','float'),
            Det.value('(./*:imposto/*:IPI/*:cEnq/text())[1]','varchar(3)'),
            NULL,
            Det.value('(./*:imposto/*:IPI//*:CST/text())[1]','varchar(3)'),
            Det.value('(./*:imposto/*:IPI//*:vBC/text())[1]','float'),
            Det.value('(./*:imposto/*:IPI//*:pIPI/text())[1]','float'),
            Det.value('(./*:imposto/*:IPI//*:qUnid/text())[1]','float'),
            Det.value('(./*:imposto/*:IPI//*:vUnid/text())[1]','float'),
            Det.value('(./*:imposto/*:IPI//*:vIPI/text())[1]','float'),
            NULL, NULL, NULL, GETDATE()
        FROM @xml.nodes('/*:nfeProc/*:NFe/*:infNFe/*:det') AS X(Det)
        WHERE X.Det.exist('./*:imposto/*:IPI[1]') = 1;

        /* ====== Duplicatas / Parcela ====== */
        DELETE FROM NFE_Parcela WHERE cd_nota = @cd_nota;
        SELECT
            @cd_nota                                      as cd_nota,
            identity(int,1,1)                             as cd_parcela_nota,
            D.value('(./*:nDup/text())[1]','varchar(15)') AS nDup,
            D.value('(./*:dVenc/text())[1]','datetime')    AS dVenc,
            D.value('(./*:vDup/text())[1]','float')       AS vDup,
            NULL as cd_usuario, GETDATE() as dt_usuario
        into
          #nfeParcela

        FROM @xml.nodes('/*:nfeProc/*:NFe/*:infNFe/*:cobr/*:dup') AS T(D);

        INSERT INTO dbo.NFE_Parcela (cd_nota, cd_parcela_nota, nDup, dVenc, vDup, cd_usuario, dt_usuario)
        select * from #nfeParcela

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        DECLARE @err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Falha ao processar NF-e %d: %s', 16, 1, @cd_nota, @err);
        RETURN;
    END CATCH
END
GO

--EXEC dbo.pr_gera_nfe_entrada_xml @cd_nota = 5;
--go

/* ===== Exemplo de uso =====
EXEC dbo.pr_gera_nfe_entrada_xml @cd_nota = 4;
*/
   --delete from nfe_nota
   --delete nfe_total_nota
   --delete nfe_parcela
   --delete  nfe_ipi
   --delete  nfe_produto_servico
   --delete  nfe_emitente
   --delete  nfe_destinatario


    --select * from nfe_nota
    --select * from nfe_total_nota
    --select * from nfe_parcela
    --select * from nfe_ipi
    --select * from nfe_produto_servico
    --select * from nfe_emitente
    --select * from nfe_destinatario
    --select * from nfe_Status_Emitente

    --select * from operacao_fiscal order by cd_mascara_operacao
    --select * from empresa_faturamento

    --delete from Nota_Entrada_Empresa
    --delete from Nota_Entrada_Registro
    --delete from Nota_Entrada_Complemento
    --delete from nota_entrada_parcela
    --delete from nota_entrada_item
    --delete from nota_entrada

    --exec pr_geracao_nota_entrada_dados_nfe 1583, 765, 1, null, null, 4, 1
    --go
    --select * from nota_entrada

--    @cd_nota_entrada
--@cd_operacao_fiscal
--@cd_usuario
--@cd_pedido_compra
--@cd_item_pedido_compra
--@cd_nota_nfe
--@cd_empresa_fat
