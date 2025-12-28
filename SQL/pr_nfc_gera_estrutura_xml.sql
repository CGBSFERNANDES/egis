--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_nfc_gera_estrutura_xml' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_nfc_gera_estrutura_xml

GO

-------------------------------------------------------------------------------
--sp_helptext pr_nfc_gera_estrutura_xml
-------------------------------------------------------------------------------
--pr_nfc_gera_estrutura_xml
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : GCA - Gestão de Caixa
--                   Processo do Módulo de Gestão de Caixa
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_nfc_gera_estrutura_xml
@json nvarchar(max) = ''

--with encryption


as

set @json = isnull(@json,'')

declare @cd_empresa          int
declare @cd_parametro        int
declare @cd_documento        int = 0
declare @cd_item_documento   int
declare @cd_usuario          int 
declare @dt_hoje             datetime
declare @dt_inicial          datetime 
declare @dt_final            datetime
declare @cd_ano              int = 0
declare @cd_mes              int = 0
declare @cd_nota_saida       int = 0

set @cd_empresa        = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @cd_item_documento = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano = year(getdate())
set @cd_mes = month(getdate())  

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end


--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

select                     

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]              as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_documento           = valor from #json where campo = 'cd_documento'
select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_nota_saida          = valor from #json where campo = 'cd_nota_saida'             

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()


set @cd_nota_saida = ISNULL(@cd_nota_saida,0)

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--01 - Carregar o Pedido de Venda
---------------------------------------------------------------------------------------------------------------------------------------------------------    

-- CREATE PROCEDURE pr_nfc_gera_estrutura_xml
--    @cd_nota_saida INT
--AS
--BEGIN
    SET NOCOUNT ON;

    DECLARE @xml XML
    DECLARE @xml_text NVARCHAR(MAX)

    -- Construção do XML da NFe (sem <protNFe>)

	/*
    SELECT @xml = (
        SELECT
            '4.00' AS '@versao',
            (
                SELECT
                    'http://www.portalfiscal.inf.br/nfe' AS '@xmlns',
                    -- infNFe
                    (
                        SELECT
                            'NFe' + CAST(I.cd_nota_saida AS VARCHAR) AS '@Id',
                            '4.00' AS '@versao',

                            -- ide
                            (
                                SELECT
                                    I.cUF,
                                    I.cNF,
                                    I.natOp,
                                    I.[mod] as 'mod',
                                    I.serie,
                                    I.nNF,
                                    I.dEmiNotaSaida as dhEmi,
                                    I.tpNF,
                                    I.B11a_idDest   as idDest,
                                    I.cMunFG,
                                    I.tpImp,
                                    I.tpEmis,
                                    I.cDV,
                                    I.tpAmb,
                                    I.finNFe,
                                    I.B25a_indFinal as indFinal,
                                    I.B25b_indPres  as indPres,
                                    --I.indIntermed,
									CAST(0 as int)  as indIntermed,
									--
                                    I.procEmi,
                                    I.verProc
                                FOR XML PATH('ide'), TYPE
                            ),

                            -- emit
                            (
                                SELECT
                                    E.CNPJ,
                                    E.xNome,
                                    E.xFant,
                                    (
                                        SELECT
                                            E.xLgr,
                                            E.nro,
                                            E.xBairro,
                                            E.cMun,
                                            E.xMun,
                                            E.UF,
                                            E.CEP,
                                            E.cPais,
                                            E.xPais,
                                            E.fone
                                        FOR XML PATH('enderEmit'), TYPE
                                    ),
                                    E.IE,
                                    E.IM,
                                    E.CNAE,
                                    E.C21_CRT as CRT
                                FOR XML PATH('emit'), TYPE
                            ),

                            -- det (produtos)
                            (
                                SELECT
                                    P.nItem AS '@nItem',
                                    (
                                        SELECT
                                            P.cProd,
                                            P.cEAN,
                                            P.xProd,
                                            P.NCM,
                                            P.CFOP,
                                            P.uCom,
                                            P.qCom,
                                            P.vUnCom,
                                            P.vProd,
                                            P.cEANTrib,
                                            P.uTrib,
                                            P.qTrib,
                                            P.vUnTrib,
                                            P.indTot
                                        FOR XML PATH('prod'), TYPE
                                    ),
                                    (
                                        SELECT
                                            -- ICMS (Simples Nacional - CSOSN 102)
                                        (
                                          SELECT
                                            S.orig,
                                            S.CSOSN
                                          FROM vw_nfe_simples_nacional_v200 S
                                          WHERE S.cd_nota_saida = P.cd_nota_saida
                                                AND S.cd_item_nota_saida = P.nItem
                                          FOR XML PATH('ICMSSN102'), TYPE


                                            ) AS 'ICMS',
                                            (
                                                SELECT
                                                    P.CSTPis AS CST,
                                                    P.vBCPis AS vBC,
                                                    P.pPIS AS pPIS,
                                                    P.vPIS AS vPIS
                                                FOR XML PATH('PISOutr'), TYPE
                                            ) AS 'PIS',
                                            (
                                                SELECT
                                                    P.CSTCOFINS AS CST,
                                                    P.vBCCOFINS AS vBC,
                                                    P.pCOFINS   AS pCOFINS,
                                                    P.vCOFINS   AS vCOFINS
                                                FOR XML PATH('COFINSOutr'), TYPE
                                            ) AS 'COFINS'
                                        FOR XML PATH('imposto'), TYPE
                                    )
                                FROM vw_nfe_produto_servico_nota_fiscal_api P
                                WHERE P.cd_nota_saida = I.cd_nota_saida
                                FOR XML PATH('det'), TYPE
                            ),

                            -- total
                            (
                                SELECT
                                    T.vBC,
                                    T.vICMS,
                                    T.vICMSDeson,
                                    T.vFCP,
                                    T.vBCST,
                                    T.vST,
                                    T.vFCPST,
                                    T.vFCPSTRet,
                                    T.vProd,
                                    T.vFrete,
                                    T.vSeg,
                                    T.vDesc,
                                    T.vII,
                                    T.vIPI,
                                    T.vIPIDevol,
                                    T.vPIS,
                                    T.vCOFINS,
                                    T.vOutro,
                                    T.vNF,
                                    T.vTotTrib
                                FOR XML PATH('ICMSTot'), TYPE
                            ) AS total,

                            -- transp
                            (
                                SELECT 9 AS modFrete
                                FOR XML PATH('transp'), TYPE
                            ),

                            -- pag
                            (
                                SELECT
                                    (
                                        SELECT
                                            P.indPag,
                                            P.tPag,
                                            P.vPag
                                        FROM vw_nfe_parcela_nota_fiscal P
                                        WHERE P.cd_nota_saida = I.cd_nota_saida
                                        FOR XML PATH('detPag'), TYPE
                                    )
                                FOR XML PATH('pag'), TYPE
                            )
                        FROM vw_nfe_identificacao_nota_fiscal I
                        INNER JOIN vw_nfe_emitente_nota_fiscal E ON E.cd_nota_saida = I.cd_nota_saida
                        INNER JOIN vw_nfe_totais_nota_fiscal T ON T.cd_nota_saida = I.cd_nota_saida
                        WHERE I.cd_nota_saida = @cd_nota_saida
                        FOR XML PATH('infNFe'), TYPE
                    ),

                    -- infNFeSupl (QRCode e URL)
             (
                SELECT
                    (
                        SELECT
                            --' <![CDATA[' + I.qrCode + ']]> ' AS [qrCode],
                            --I.urlChave
							'<![CDATA[ https://www.nfce.fazenda.sp.gov.br/NFCeConsultaPublica/Paginas/ConsultaQRCode.aspx?p=35250709095917000191650010000000111000000118|2|1|1|6D0931967311B97E4272DE8DA437BAADD4F0D74B ]]>'
							                                              as [qrCode],
							'https://www.nfce.fazenda.sp.gov.br/Consulta' as [urlChave] 
                        FOR XML PATH(''), TYPE
                    )
                FROM vw_nfe_identificacao_nota_fiscal I
                WHERE I.cd_nota_saida = @cd_nota_saida
                FOR XML PATH('infNFeSupl'), TYPE
              )

                    -- A tag Signature será adicionada futuramente
                FOR XML PATH('NFe'), TYPE
            )
    )
	*/

	-- Conversão do XML para string NVARCHAR(MAX)
   SET @xml_text = CAST(@xml AS NVARCHAR(MAX));

	;WITH XMLNAMESPACES(DEFAULT 'http://www.portalfiscal.inf.br/nfe')
      SELECT @xml = (
    SELECT
        '4.00' AS '@versao',
        (
            SELECT
                -- infNFe
                (
                    SELECT
                        'NFe' + CAST(I.cd_nota_saida AS VARCHAR) AS '@Id',
                        '4.00' AS '@versao',

                        -- ide
                        (
                            SELECT
                                I.cUF,
                                I.cNF,
                                I.natOp,
                                I.[mod] as 'mod',
                                I.serie,
                                I.nNF,
                                I.dEmiNotaSaida as dhEmi,
                                I.tpNF,
                                I.B11a_idDest   as idDest,
                                I.cMunFG,
                                I.tpImp,
                                I.tpEmis,
                                I.cDV,
                                I.tpAmb,
                                I.finNFe,
                                I.B25a_indFinal as indFinal,
                                I.B25b_indPres  as indPres,
                                CAST(0 as int)  as indIntermed,
                                I.procEmi,
                                I.verProc
                            FOR XML PATH('ide'), TYPE
                        ),

                        -- emit
                        (
                            SELECT
                                E.CNPJ,
                                E.xNome,
                                E.xFant,
                                (
                                    SELECT
                                        E.xLgr,
                                        E.nro,
                                        E.xBairro,
                                        E.cMun,
                                        E.xMun,
                                        E.UF,
                                        E.CEP,
                                        E.cPais,
                                        E.xPais,
                                        E.fone
                                    FOR XML PATH('enderEmit'), TYPE
                                ),
                                E.IE,
                                E.IM,
                                E.CNAE,
                                E.C21_CRT as CRT
                            FOR XML PATH('emit'), TYPE
                        ),

                        -- det (produtos)
                        (
                            SELECT
                                P.nItem AS '@nItem',
                                (
                                    SELECT
                                        P.cProd,
                                        P.cEAN,
                                        P.xProd,
                                        P.NCM,
                                        P.CFOP,
                                        P.uCom,
                                        P.qCom,
                                        P.vUnCom,
                                        P.vProd,
                                        P.cEANTrib,
                                        P.uTrib,
                                        P.qTrib,
                                        P.vUnTrib,
                                        P.indTot
                                    FOR XML PATH('prod'), TYPE
                                ),
                                (
                                    SELECT
                                        (
                                            SELECT
                                                S.orig,
                                                S.CSOSN
                                            FROM vw_nfe_simples_nacional_v200 S
                                            WHERE S.cd_nota_saida = P.cd_nota_saida
                                              AND S.cd_item_nota_saida = P.nItem
                                            FOR XML PATH('ICMSSN102'), TYPE
                                        ) AS 'ICMS',
                                        (
                                            SELECT
                                                P.CSTPis AS CST,
                                                P.vBCPis AS vBC,
                                                P.pPIS AS pPIS,
                                                P.vPIS AS vPIS
                                            FOR XML PATH('PISOutr'), TYPE
                                        ) AS 'PIS',
                                        (
                                            SELECT
                                                P.CSTCOFINS AS CST,
                                                P.vBCCOFINS AS vBC,
                                                P.pCOFINS   AS pCOFINS,
                                                P.vCOFINS   AS vCOFINS
                                            FOR XML PATH('COFINSOutr'), TYPE
                                        ) AS 'COFINS'
                                    FOR XML PATH('imposto'), TYPE
                                )
                            FROM vw_nfe_produto_servico_nota_fiscal_api P
                            WHERE P.cd_nota_saida = I.cd_nota_saida
                            FOR XML PATH('det'), TYPE
                        ),

                        -- total
                        (
                            SELECT
                                T.vBC,
                                T.vICMS,
                                T.vICMSDeson,
                                T.vFCP,
                                T.vBCST,
                                T.vST,
                                T.vFCPST,
                                T.vFCPSTRet,
                                T.vProd,
                                T.vFrete,
                                T.vSeg,
                                T.vDesc,
                                T.vII,
                                T.vIPI,
                                T.vIPIDevol,
                                T.vPIS,
                                T.vCOFINS,
                                T.vOutro,
                                T.vNF,
                                T.vTotTrib
                            FOR XML PATH('ICMSTot'), TYPE
                        ) AS total,

                        -- transp
                        (
                            SELECT 9 AS modFrete
                            FOR XML PATH('transp'), TYPE
                        ),

                        -- pag
                        (
                            SELECT
                                (
                                    SELECT
                                        P.indPag,
                                        P.tPag,
                                        P.vPag
                                    FROM vw_nfe_parcela_nota_fiscal P
                                    WHERE P.cd_nota_saida = I.cd_nota_saida
                                    FOR XML PATH('detPag'), TYPE
                                )
                            FOR XML PATH('pag'), TYPE
                        )
                    FROM vw_nfe_identificacao_nota_fiscal I
                    INNER JOIN vw_nfe_emitente_nota_fiscal E ON E.cd_nota_saida = I.cd_nota_saida
                    INNER JOIN vw_nfe_totais_nota_fiscal T ON T.cd_nota_saida = I.cd_nota_saida
                    WHERE I.cd_nota_saida = @cd_nota_saida
                    FOR XML PATH('infNFe'), TYPE
                ),

                -- infNFeSupl com CDATA no qrCode
                -- infNFeSupl corrigido:
                (
                    SELECT
                        --'<![CDATA[' + I.qrCode + ']]>' AS [qrCode],
                        --I.urlChave
						cast('' as nvarchar(max)) as  [qrCode],
						cast('' as nvarchar(max)) as  urlChave
                    FROM vw_nfe_identificacao_nota_fiscal I
                    WHERE I.cd_nota_saida = @cd_nota_saida
                    FOR XML PATH('infNFeSupl'), TYPE
                )
                -- A tag Signature será adicionada futuramente
            FOR XML PATH('NFe'), TYPE
        )
)

    -- Conversão do XML para string NVARCHAR(MAX)
    SET @xml_text = CAST(@xml AS NVARCHAR(MAX))

    -- Resultado
    SELECT @xml AS xml_formatado, @xml_text AS xml_texto

--END




---------------------------------------------------------------------------------------------------------------------------------------------------------    
go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_nfc_gera_estrutura_xml
------------------------------------------------------------------------------

go
exec pr_nfc_gera_estrutura_xml '[{"cd_parametro": 1}, {"cd_documento": 2}, {"dt_inicial":"06/01/2025"}, {"dt_final":"06/30/2025"}]'
go

--select * from Pedido_Venda_Item

------------------------------------------------------------------------------