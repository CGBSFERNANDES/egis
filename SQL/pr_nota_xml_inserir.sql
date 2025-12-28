---- 1. Tabela
--IF OBJECT_ID('dbo.nota_xml', 'U') IS NOT NULL
--  DROP TABLE dbo.nota_xml;
--GO

--CREATE TABLE dbo.nota_xml (
--  cd_xml_nota          INT IDENTITY(1,1) PRIMARY KEY,
--  cd_tipo_xml          INT           NOT NULL,          -- ex.: 55=NFe, 65=NFCe (ajuste como preferir)
--  ds_xml               NVARCHAR(MAX) NOT NULL,          -- XML completo
--  cd_usuario_inclusao  INT           NOT NULL,
--  dt_usuario_inclusao  DATETIME      NOT NULL DEFAULT(GETDATE()),
--  cd_usuario           INT           NULL,              -- último usuário que alterou (se usar update)
--  dt_usuario           DATETIME      NULL               -- data da última alteração
--);
--GO


--select * from nota_xml

--ALTER TABLE nota_xml
--ALTER COLUMN ds_xml NVARCHAR(MAX);

--go

IF OBJECT_ID('pr_nota_xml_inserir', 'P') IS NOT NULL
  DROP PROCEDURE pr_nota_xml_inserir;
GO

CREATE PROCEDURE pr_nota_xml_inserir
@json nvarchar(max) = ''
AS
BEGIN
  SET NOCOUNT ON;


  set @json = isnull(@json,'')


declare @dt_hoje datetime  
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)         
  
if @json= '' 
begin  
  select 'Parâmetros inválidos !' as Msg  
  return  
end  

set @json = replace(@json,'''','')


declare 
   @cd_tipo_xml         INT,
   @ds_xml              NVARCHAR(MAX),
   @cd_usuario_inclusao INT,
   @cd_empresa          INT,
   @cd_usuario          INT,
   @cd_chave_acesso     varchar(100)  = '',
   @nsu                 varchar(200)  = '',
   @schema_xml          nvarchar(max) = '',
   @cnpj_base           varchar(18)   = '';
   
DECLARE @xml   XML;
DECLARE @chNFe VARCHAR(45) = ''

----------------------------------------------------------------------------------------------------------    

select                 
identity(int,1,1)             as id,                 
    valores.[key]             as campo,                 
    valores.[value]           as valor                
into #json                
from                 
   openjson(@json)root                
   cross apply openjson(root.value) as valores 	

----------------------------------------------------------------------------------------------------------    

--Declare--

----------------------------------------------------------------------------------------------------------    
set @cd_empresa             = dbo.fn_empresa()
----------------------------------------------------------------------------------------------------------
select @cd_tipo_xml         = valor from #json  with(nolock) where campo = 'cd_tipo_xml' 
select @ds_xml 	            = valor from #json  with(nolock) where campo = 'ds_xml' 
select @cd_usuario          = valor from #json  with(nolock) where campo = 'cd_usuario'  
select @cd_usuario_inclusao = valor from #json  with(nolock) where campo = 'cd_usuario_inclusao'  
select @cd_chave_acesso     = valor from #json  with(nolock) where campo = 'cd_chave_acesso'
select @nsu                 = valor from #json  with(nolock) where campo = 'nsu'
select @schema_xml          = valor from #json  with(nolock) where campo = 'schema_xml'
select @cnpj_base           = valor from #json  with(nolock) where campo = 'cnpj_base'
----------------------------------------------------------------------------------------------------------

set @cd_chave_acesso = isnull(@cd_chave_acesso,'')

-- lê da Nota_XML pelo cd_xml_nota e remove a declaração XML antes de converter
--
--SELECT @xml = TRY_CONVERT(XML,
--    CASE 
--      WHEN LEFT(LTRIM(CAST(@ds_xml AS NVARCHAR(MAX))),5)='<?xml'
--        THEN STUFF(CAST(@ds_xml AS NVARCHAR(MAX)), 1, CHARINDEX('?>', CAST(@ds_xml AS NVARCHAR(MAX)))+1, '')
--      ELSE CAST(@ds_xml AS NVARCHAR(MAX))
--    END)
--
--SELECT
--    @chNFe   = @xml.value('(/*:nfeProc/*:protNFe/*:infProt/*:chNFe/text())[1]', 'varchar(45)')
--*/

if not exists ( select top 1 cd_chave_acesso from nota_xml where cd_chave_acesso = @cd_chave_acesso )
  --and @cd_chave_acesso<>''
begin

     declare @cd_xml_nota int = 0
     
     select
       @cd_xml_nota = max(cd_xml_nota)
     from
       nota_xml
     
     set @cd_xml_nota = isnull(@cd_xml_nota,0) + 1
     
     
     INSERT INTO nota_xml (cd_xml_nota, cd_tipo_xml, ds_xml, 
                             cd_usuario_inclusao,
                             dt_usuario_inclusao, 
                             cd_chave_acesso,
                             nsu,
                             schema_xml,
                             cnpj_base,
                             cd_usuario,
                             dt_usuario
                             )
       VALUES (@cd_xml_nota, 
               @cd_tipo_xml, 
               @ds_xml, 
               @cd_usuario_inclusao, 
               GETDATE(), 
               @cd_chave_acesso,
               @nsu,
               @schema_xml,
               @cnpj_base,
               @cd_usuario_inclusao,
               getdate() );
     
       --delete from nota_xml select * from nota_xml

       --SELECT SCOPE_IDENTITY() AS cd_xml_nota;
       select @cd_xml_nota as cd_xml_nota
       -----------------------------------
     
       -- pr que faz a atualização do xml 
       exec pr_gera_nfe_entrada_xml @cd_xml_nota
       -----------------------------------------
     
       declare @cd_nota_entrada int = 0
     
       --select * from nfe_nota
     
       select
         @cd_nota_entrada = cd_identificacao
       from
         NFE_Nota
       where
         cd_nota = @cd_xml_nota
     
       -- Pr que faz a geracaio da nota fiscal de entrada, contas a pagar, baixa do pedido de compra, movimento de estoque 
       

       ----
       --exec pr_geracao_nota_entrada_dados_nfe @cd_nota_entrada, null, @cd_usuario, null, null, @cd_xml_nota, null
       -----------------------------------------------------------------------------------------------------------
 

 end     

 --    @cd_nota_entrada
--@cd_operacao_fiscal
--@cd_usuario
--@cd_pedido_compra
--@cd_item_pedido_compra
--@cd_nota_nfe
--@cd_empr

END

GO
return

--select * from nota_xml

--select * from nota_entrada

-- exec pr_geracao_nota_entrada_dados_nfe @cd_nota_entrada, null, @cd_usuario, null, null, @cd_xml_nota, null

--exec pr_geracao_nota_entrada_dados_nfe 11808, null, 113, null, null, 1, null
  

--select * from nfe_nota

--exec pr_nota_xml_inserir '[
--    {
--        "ic_json_parametro": "S",
--        "cd_tipo_xml": 55,
--        "ds_xml": "<?xml version=\"1.0\" encoding=\"UTF-8\"?><nfeProc versao=\"4.00\" xmlns=\"http://www.portalfiscal.inf.br/nfe\"><NFe xmlns=\"http://www.portalfiscal.inf.br/nfe\"><infNFe Id=\"NFe15251003424107000155550010000000061000000137\" versao=\"4.00\"><ide><cUF>15</cUF><cNF>00000013</cNF><natOp>VENDAS DE PRODUCAO ESTABELECIMENTO</natOp><mod>55</mod><serie>1</serie><nNF>6</nNF><dhEmi>2025-10-25T10:09:23-03:00</dhEmi><dhSaiEnt>2025-10-26T10:09:23-03:00</dhSaiEnt><tpNF>1</tpNF><idDest>1</idDest><cMunFG>1507300</cMunFG><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>7</cDV><tpAmb>2</tpAmb><finNFe>1</finNFe><indFinal>0</indFinal><indPres>1</indPres><indIntermed>0</indIntermed><procEmi>0</procEmi><verProc>1.2.3</verProc></ide><emit><CNPJ>03424107000155</CNPJ><xNome>REGINALDO L. SILVA - LTDA</xNome><xFant>REGIS SORVETES E PICOLES</xFant><enderEmit><xLgr>AVENIDA CEARA</xLgr><nro>503</nro><xBairro>SAO JOSE</xBairro><cMun>1507300</cMun><xMun>SAO FELIX DO XINGU</xMun><UF>PA</UF><CEP>68380000</CEP><cPais>1058</cPais><xPais>Brasil</xPais><fone>9481351476</fone></enderEmit><IE>152078010</IE><IM>000000000000000</IM><CNAE>0007032</CNAE><CRT>1</CRT></emit><dest><CNPJ>01234967000109</CNPJ><xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL</xNome><enderDest><xLgr>AV RIO XINGU</xLgr><nro>365</nro><xBairro>NOVO HORIZONTE</xBairro><cMun>1507300</cMun><xMun>SAO FELIX DO XINGU</xMun><UF>PA</UF><CEP>68380000</CEP><cPais>1058</cPais><xPais>Brasil</xPais><fone>94981420504</fone></enderDest><indIEDest>1</indIEDest><IE>152237496</IE></dest><det nItem=\"1\"><prod><cProd>1013</cProd><cEAN>SEM GTIN</cEAN><xProd>SORVETE CX 10 LTS CRIS</xProd><NCM>21050010</NCM><CEST>2300100</CEST><indEscala>S</indEscala><CFOP>5101</CFOP><uCom>CX</uCom><qCom>1.0000</qCom><vUnCom>120.0000000000</vUnCom><vProd>120.00</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>CX</uTrib><qTrib>1.0000</qTrib><vUnTrib>120.0000000000</vUnTrib><indTot>1</indTot><xPed>Web</xPed><nItemPed>0</nItemPed></prod><imposto><vTotTrib>17.27</vTotTrib><ICMS><ICMSSN101><orig>0</orig><CSOSN>101</CSOSN><pCredSN>1.25</pCredSN><vCredICMSSN>1.50</vCredICMSSN></ICMSSN101></ICMS><PIS><PISNT><CST>08</CST></PISNT></PIS><COFINS><COFINSNT><CST>08</CST></COFINSNT></COFINS></imposto></det><total><ICMSTot><vBC>0.00</vBC><vICMS>0.00</vICMS><vICMSDeson>0.00</vICMSDeson><vFCP>0.00</vFCP><vBCST>0.00</vBCST><vST>0.00</vST><vFCPST>0.00</vFCPST><vFCPSTRet>0.00</vFCPSTRet><vProd>120.00</vProd><vFrete>0.00</vFrete><vSeg>0.00</vSeg><vDesc>0.00</vDesc><vII>0.00</vII><vIPI>0.00</vIPI><vIPIDevol>0.00</vIPIDevol><vPIS>0.00</vPIS><vCOFINS>0.00</vCOFINS><vOutro>0.00</vOutro><vNF>120.00</vNF><vTotTrib>17.27</vTotTrib></ICMSTot></total><transp><modFrete>1</modFrete><transporta><CNPJ>01234967000109</CNPJ><xNome>NOSSO CARRO</xNome><IE>152237496</IE><xEnder>AV RIO XINGU-365 NOVO HORIZONTE</xEnder><xMun>SAO FELIX DO XINGU</xMun><UF>PA</UF></transporta><veicTransp><placa>XXX9999</placa></veicTransp><vol><qVol>1</qVol><pesoL>0.000</pesoL><pesoB>0.000</pesoB></vol></transp><cobr><fat><nFat>A VISTA</nFat><vOrig>120.00</vOrig><vDesc>0.00</vDesc><vLiq>120.00</vLiq></fat><dup><nDup>001</nDup><dVenc>2025-10-26</dVenc><vDup>120.00</vDup></dup></cobr><pag><detPag><indPag>1</indPag><tPag>01</tPag><vPag>120.00</vPag></detPag></pag><infAdic><infCpl>Vendedor: FLAVIANO Codigo do Cliente: 13 SUPERMERCADO ROMA ** CONFIRA SEU PEDIDO NO ATO DA ENTREGA, NAO ACEITAMOS RECLAMACOES POSTERIORES APOS A DATA DO RECEBIMENTO ** CONTA PARA TRANSFERENCIA BANCO BR</infCpl></infAdic><infRespTec><CNPJ>16875807000108</CNPJ><xContato>GBS TECNOLOGIA E CONSULTORIA LTDA</xContato><email>financeiro@gbstec.com.br</email><fone>39074141</fone></infRespTec></infNFe><Signature xmlns=\"http://www.w3.org/2000/09/xmldsig#\"><SignedInfo><CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/><SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/><Reference URI=\"#NFe15251003424107000155550010000000061000000137\"><Transforms><Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/><Transform Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><DigestValue>OtD40W+YDCYk8CNbEhlt/xsFpdc=</DigestValue></Reference></SignedInfo><SignatureValue>KjOORCc0Am9XkNZ/GyYPIv9E/Y1fZYy9jNDsu8ZOX870loLdMWpLNuImaLpL8Px5TE3wUx6jlqV6lBM/ICaa3G+fpAMUbwZWLGCmzDC74ERipvBiG7KP2hN7hUthmKyRtWv5fNCrZqBtOs8iQnHuHiUmL4xpbi6otGwn0ILMUymWh+IfiUMM7UZWFuGNi53VvEmP3BhvX/f5kP1JydVqrNXYaPZWrp1SIcZeiw6xxzcLjYuWrj79f/4LAa+rKk0M7JGkg0Tfe/i/pzU37rJNeLowbDhJMvgLiGdX3UwzldxryYeHJzt+TO1OCzcQVG1SyHoDO7w9FdvCyMmQcjkxQw==</SignatureValue><KeyInfo><X509Data><X509Certificate>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</X509Certificate></X509Data></KeyInfo></Signature></NFe><protNFe versao=\"4.00\"><infProt><tpAmb>2</tpAmb><verAplic>SVRS2510230858</verAplic><chNFe>15251003424107000155550010000000061000000137</chNFe><dhRecbto>2025-10-25T10:09:23-03:00</dhRecbto><nProt>315250000045653</nProt><digVal>OtD40W+YDCYk8CNbEhlt/xsFpdc=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso da NF-e</xMotivo></infProt></protNFe></nfeProc>",
--        "cd_usuario_inclusao": null
--    }
--]'


--exec pr_nota_xml_inserir
--'[{"cd_tipo_xml":2},{"cd_chave_acesso":"41250817069905000110550010000488191598364137"},{"ds_xml":"<nfeProc versao=\"4.00\" xmlns=\"http://www.portalfiscal.inf.br/nfe\"><NFe xmlns=\"http://www.portalfiscal.inf.br/nfe\"><infNFe Id=\"NFe41250817069905000110550010000488191598364137\" versao=\"4.00\"><ide><cUF>41</cUF><cNF>59836413</cNF><natOp>REMESSA DE AMOSTRA GRATIS</natOp><mod>55</mod><serie>1</serie><nNF>48819</nNF><dhEmi>2025-08-15T11:26:14-03:00</dhEmi><dhSaiEnt>2025-08-15T11:26:14-03:00</dhSaiEnt><tpNF>1</tpNF><idDest>2</idDest><cMunFG>4106902</cMunFG><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>7</cDV><tpAmb>1</tpAmb><finNFe>1</finNFe><indFinal>0</indFinal><indPres>9</indPres><indIntermed>0</indIntermed><procEmi>0</procEmi><verProc>NFeWebmais 4.01.6</verProc></ide><emit><CNPJ>17069905000110</CNPJ><xNome>UNIKA LTDA  INDUSTRIA</xNome><xFant>UNIKA INDUSTRIA</xFant><enderEmit><xLgr>R PARAIBA</xLgr><nro>2962</nro><xBairro>VILA GUAIRA</xBairro><cMun>4106902</cMun><xMun>CURITIBA</xMun><UF>PR</UF><CEP>80630000</CEP><cPais>1058</cPais><xPais>BRASIL</xPais><fone>4130900731</fone></enderEmit><IE>9062718509</IE><CRT>3</CRT></emit><dest><CNPJ>33092357000104</CNPJ><xNome>YEEZ IND. E COM. DE SORVETES E PICOLES LTDA</xNome><enderDest><xLgr>DA AGUA ESPRAIADA</xLgr><nro>5450</nro><xBairro>AGUA ESPRAIADA (CAUCAIA DO ALTO)</xBairro><cMun>3513009</cMun><xMun>COTIA</xMun><UF>SP</UF><CEP>06725153</CEP><cPais>1058</cPais><xPais>BRASIL</xPais><fone>1691221215</fone></enderDest><indIEDest>1</indIEDest><IE>278476681110</IE><email>SORVETESYEEZ@GMAIL.COM</email></dest><det nItem=\"1\"><prod><cProd>A6000308</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA NEUTRO CINQUE - 0,10 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>5.0000</qCom><vUnCom>31.8400000000</vUnCom><vProd>159.20</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>5.0000</qTrib><vUnTrib>31.8400000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0308250116A</nLote><qLote>5.000</qLote><dFab>2025-01-16</dFab><dVal>2026-01-16</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 16/01/2025 - Val: 16/01/2026 - A0308250116A: 5,00</infAdProd></det><det nItem=\"2\"><prod><cProd>A6000105</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA PASTA NOCE - 0,400 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>81.7400000000</vUnCom><vProd>81.74</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>81.7400000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0105240917A</nLote><qLote>1.000</qLote><dFab>2024-09-17</dFab><dVal>2025-09-17</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 17/09/2024 - Val: 17/09/2025 - A0105240917A: 1,00</infAdProd></det><det nItem=\"3\"><prod><cProd>A6000452</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA VARIEGATO PISTACCHIO - 0,35 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>44.4200000000</vUnCom><vProd>44.42</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>44.4200000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0452240729L</nLote><qLote>1.000</qLote><dFab>2025-01-25</dFab><dVal>2026-01-25</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 25/01/2025 - Val: 25/01/2026 - A0452240729L: 1,00</infAdProd></det><det nItem=\"4\"><prod><cProd>A6000380</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA BASE FRUTTA CREMOSA 100 - 0,40 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>5.0000</qCom><vUnCom>20.1600000000</vUnCom><vProd>100.80</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>5.0000</qTrib><vUnTrib>20.1600000000</vUnTrib><indTot>1</indTot><rastro><nLote>0380240913A</nLote><qLote>5.000</qLote><dFab>2024-09-13</dFab><dVal>2025-09-13</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 13/09/2024 - Val: 13/09/2025 - 0380240913A: 5,00</infAdProd></det><det nItem=\"5\"><prod><cProd>A6000059</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA PASTA MANGO 50 - 0,35 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>23.0200000000</vUnCom><vProd>23.02</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>23.0200000000</vUnTrib><indTot>1</indTot><rastro><nLote>0059240920A</nLote><qLote>1.000</qLote><dFab>2024-09-20</dFab><dVal>2025-09-20</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 20/09/2024 - Val: 20/09/2025 - 0059240920A: 1,00</infAdProd></det><det nItem=\"6\"><prod><cProd>A6000577</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA PASTA LIMONE SICILIANO - 0,35 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>38.3700000000</vUnCom><vProd>38.37</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>38.3700000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0577250804A</nLote><qLote>1.000</qLote><dFab>2025-08-04</dFab><dVal>2027-02-04</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 04/08/2025 - Val: 04/02/2027 - A0577250804A: 1,00</infAdProd></det><det nItem=\"7\"><prod><cProd>A6000418</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA STRACCIATELLA SCURA DIET - 0,35 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>31.6600000000</vUnCom><vProd>31.66</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>31.6600000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0418241125A</nLote><qLote>1.000</qLote><dFab>2024-11-25</dFab><dVal>2025-11-25</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 25/11/2024 - Val: 25/11/2025 - A0418241125A: 1,00</infAdProd></det><det nItem=\"8\"><prod><cProd>A6000103</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA PASTA NOCCIOLA SELEZIONE - 0,40 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>67.2400000000</vUnCom><vProd>67.24</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>67.2400000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0103241008A</nLote><qLote>1.000</qLote><dFab>2024-10-08</dFab><dVal>2025-10-08</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 08/10/2024 - Val: 08/10/2025 - A0103241008A: 1,00</infAdProd></det><det nItem=\"9\"><prod><cProd>A6000005</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA PASTA COCCO 100 - 0,40 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>33.8500000000</vUnCom><vProd>33.85</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>33.8500000000</vUnTrib><indTot>1</indTot><rastro><nLote>0005240926A</nLote><qLote>1.000</qLote><dFab>2024-09-26</dFab><dVal>2025-09-26</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 26/09/2024 - Val: 26/09/2025 - 0005240926A: 1,00</infAdProd></det><det nItem=\"10\"><prod><cProd>A6000684</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA CACAO 10/12 ALCALINO RED - 0,25 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>15.9100000000</vUnCom><vProd>15.91</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>15.9100000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0684250424A</nLote><qLote>1.000</qLote><dFab>2025-04-24</dFab><dVal>2026-04-24</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 24/04/2025 - Val: 24/04/2026 - A0684250424A: 1,00</infAdProd></det><det nItem=\"11\"><prod><cProd>A6000246</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA PASTA VANIGLIA NATURALE BOURBON 50 - 0,35 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>75.3000000000</vUnCom><vProd>75.30</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>75.3000000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0246241123A</nLote><qLote>1.000</qLote><dFab>2024-11-23</dFab><dVal>2025-11-23</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 23/11/2024 - Val: 23/11/2025 - A0246241123A: 1,00</infAdProd></det><det nItem=\"12\"><prod><cProd>A6000375</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA CREAM CHEESE (QUEIJO EM PO) 30 - 0,20 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>28.1800000000</vUnCom><vProd>28.18</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>28.1800000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0375250121A</nLote><qLote>1.000</qLote><dFab>2025-01-21</dFab><dVal>2026-01-21</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 21/01/2025 - Val: 21/01/2026 - A0375250121A: 1,00</infAdProd></det><det nItem=\"13\"><prod><cProd>A6000489</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA VARIEGATO FRUTTI GIALLI - 0,35 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>23.4400000000</vUnCom><vProd>23.44</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>23.4400000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0489250801A</nLote><qLote>1.000</qLote><dFab>2025-08-01</dFab><dVal>2027-02-01</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 01/08/2025 - Val: 01/02/2027 - A0489250801A: 1,00</infAdProd></det><det nItem=\"14\"><prod><cProd>A6000228</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA PASTA TIRAMISU 60 - 0,40 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>51.0500000000</vUnCom><vProd>51.05</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>51.0500000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0228241118A</nLote><qLote>1.000</qLote><dFab>2024-11-18</dFab><dVal>2025-11-18</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 18/11/2024 - Val: 18/11/2025 - A0228241118A: 1,00</infAdProd></det><det nItem=\"15\"><prod><cProd>A6000329</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA SUPERPANNA 15/30 - 0,20 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>20.6100000000</vUnCom><vProd>20.61</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>20.6100000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0329250113A</nLote><qLote>1.000</qLote><dFab>2025-01-13</dFab><dVal>2026-01-13</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 13/01/2025 - Val: 13/01/2026 - A0329250113A: 1,00</infAdProd></det><det nItem=\"16\"><prod><cProd>A6000495</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA VARIEGATO BANOFFE - 0,35 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>64.4700000000</vUnCom><vProd>64.47</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>64.4700000000</vUnTrib><indTot>1</indTot><rastro><nLote>0495250225A</nLote><qLote>1.000</qLote><dFab>2025-02-25</dFab><dVal>2026-02-25</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 25/02/2025 - Val: 25/02/2026 - 0495250225A: 1,00</infAdProd></det><det nItem=\"17\"><prod><cProd>A6000468</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA VARIEGATO BISCOTTO - 0,35 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>30.1000000000</vUnCom><vProd>30.10</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>30.1000000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0468241015A</nLote><qLote>1.000</qLote><dFab>2024-10-15</dFab><dVal>2025-10-15</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 15/10/2024 - Val: 15/10/2025 - A0468241015A: 1,00</infAdProd></det><det nItem=\"18\"><prod><cProd>A6000206</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA PASTA CIOCCOLATO GIANDUIA TORINO 100 - 0,40 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>56.6900000000</vUnCom><vProd>56.69</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>56.6900000000</vUnTrib><indTot>1</indTot><rastro><nLote>A0206240926A</nLote><qLote>1.000</qLote><dFab>2024-09-26</dFab><dVal>2025-09-26</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 26/09/2024 - Val: 26/09/2025 - A0206240926A: 1,00</infAdProd></det><det nItem=\"19\"><prod><cProd>A6000477</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA VARIEGATO FRUTTI DI BOSCO NEW - 0,35 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>21.6200000000</vUnCom><vProd>21.62</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>21.6200000000</vUnTrib><indTot>1</indTot><rastro><nLote>0477241220A</nLote><qLote>1.000</qLote><dFab>2024-12-20</dFab><dVal>2025-12-20</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 20/12/2024 - Val: 20/12/2025 - 0477241220A: 1,00</infAdProd></det><det nItem=\"20\"><prod><cProd>A7002123</cProd><cEAN>SEM GTIN</cEAN><xProd>AMOSTRA PASTA TUTTI FRUTTI 30 - 0,35 KG</xProd><NCM>21069090</NCM><CEST>1709700</CEST><cBenef>PR810001</cBenef><CFOP>6911</CFOP><uCom>un</uCom><qCom>1.0000</qCom><vUnCom>18.8700000000</vUnCom><vProd>18.87</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>un</uTrib><qTrib>1.0000</qTrib><vUnTrib>18.8700000000</vUnTrib><indTot>1</indTot><rastro><nLote>A2123250415B</nLote><qLote>1.000</qLote><dFab>2025-04-15</dFab><dVal>2026-04-15</dVal></rastro></prod><imposto><ICMS><ICMS40><orig>0</orig><CST>40</CST></ICMS40></ICMS><IPI><cEnq>303</cEnq><IPINT><CST>52</CST></IPINT></IPI><PIS><PISNT><CST>07</CST></PISNT></PIS><COFINS><COFINSNT><CST>07</CST></COFINSNT></COFINS></imposto><infAdProd>Fab: 15/04/2025 - Val: 15/04/2026 - A2123250415B: 1,00</infAdProd></det><total><ICMSTot><vBC>0.00</vBC><vICMS>0.00</vICMS><vICMSDeson>0.00</vICMSDeson><vFCP>0.00</vFCP><vBCST>0.00</vBCST><vST>0.00</vST><vFCPST>0.00</vFCPST><vFCPSTRet>0.00</vFCPSTRet><vProd>986.54</vProd><vFrete>0.00</vFrete><vSeg>0.00</vSeg><vDesc>0.00</vDesc><vII>0.00</vII><vIPI>0.00</vIPI><vIPIDevol>0.00</vIPIDevol><vPIS>0.00</vPIS><vCOFINS>0.00</vCOFINS><vOutro>0.00</vOutro><vNF>986.54</vNF></ICMSTot></total><transp><modFrete>0</modFrete><transporta><CNPJ>77778892000261</CNPJ><xNome>TRANSPORTADORA GAMPER LTDA</xNome><IE>9028854126</IE><xEnder>AV SENADOR SALGADO FILHO,216</xEnder><xMun>CURITIBA</xMun><UF>PR</UF></transporta><vol><qVol>2</qVol><esp>CAIXA</esp><pesoL>8.650</pesoL><pesoB>8.650</pesoB></vol></transp><pag><detPag><tPag>90</tPag><vPag>0.00</vPag></detPag></pag><infAdic><infCpl>ENTREGA DAS 8 AS 15 - ALMOCO 12 AS 13 ;NRO. FORMULARIO: 27337; END. ENTREGA: 06725-153, DA AGUA ESPRAIADA - , 5450, AGUA ESPRAIADA (CAUCAIA DO ALTO)-COTIA/SP -</infCpl><obsCont xCampo=\"emailEmit\"><xTexto>adm@unikabrasil.com</xTexto></obsCont><obsCont xCampo=\"exibeHrSaida\"><xTexto>0</xTexto></obsCont><obsCont xCampo=\"exibeDtSaida\"><xTexto>0</xTexto></obsCont><obsCont xCampo=\"qtdCasasDecP\"><xTexto>2</xTexto></obsCont><obsCont xCampo=\"qtdCasasDecQ\"><xTexto>4</xTexto></obsCont><obsCont xCampo=\"qtdCasasDecPU\"><xTexto>2</xTexto></obsCont></infAdic><infRespTec><CNPJ>07698596000194</CNPJ><xContato>Rogerio Campos</xContato><email>rogerio@webmaissistemas.com.br</email><fone>4830451976</fone></infRespTec></infNFe><Signature xmlns=\"http://www.w3.org/2000/09/xmldsig#\"><SignedInfo><CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\" /><SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\" /><Reference URI=\"#NFe41250817069905000110550010000488191598364137\"><Transforms><Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\" /><Transform Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\" /></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\" /><DigestValue>PyuKs+NT6Hn3pNUZZVAm+wQnHQY=</DigestValue></Reference></SignedInfo><SignatureValue>DXFAJzZcZGVt/zvuxZiYR7uaAaPRTVsGhp1wjwE1tf47zU+WjfNKE2yM7oJzKpM5/I2GzkBy83eh8G6g8T2MHaKCNTulPqOjhGcHkPidP33F7p4XVpmBVePU70dbXnqyOtbomDvOnGCU2msUW4yhEpOwTWWgiWdMxyxfv2HQwWCtX9d2994omkgc/Tc4f1M8c0MTPMOtI+/zEj6UmzY5tnG2g6DLXy0QvHtEz43GYdFxUpRUg6O64Dn6LxkpQ0uF9aS4oZwaRccsny9oVKxlL+gsITjTzDTBTR+JCjK2997eJMyZ2UmAI7UfaxuWKbP49vFSwcmAq70uYZejU4cv9Q==</SignatureValue><KeyInfo><X509Data><X509Certificate>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</X509Certificate></X509Data></KeyInfo></Signature></NFe><protNFe versao=\"4.00\"><infProt Id=\"ID141250268702705\"><tpAmb>1</tpAmb><verAplic>PR-v4_9_11</verAplic><chNFe>41250817069905000110550010000488191598364137</chNFe><dhRecbto>2025-08-15T11:27:05-03:00</dhRecbto><nProt>141250268702705</nProt><digVal>PyuKs+NT6Hn3pNUZZVAm+wQnHQY=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso da NF-e</xMotivo></infProt></protNFe></nfeProc>"},{"nsu":2682},{"schema_xml":"procNFe_v4.00.xsd"},{"cnpj_base":"33092357000104"},{"fonte":"distdfe"},{"cd_usuario_inclusao":null}]}
--'