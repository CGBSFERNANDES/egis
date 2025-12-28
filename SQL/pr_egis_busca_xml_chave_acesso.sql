--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_317

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_busca_xml_chave_acesso' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_busca_xml_chave_acesso

GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_busca_xml_chave_acesso
-------------------------------------------------------------------------------
-- pr_egis_busca_xml_chave_acesso
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Egis
--                   Notícias e Eventos
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_busca_xml_chave_acesso
@json nvarchar(max) = ''

--with encryption


as


SET NOCOUNT ON;

set @json = isnull(@json,'')


select                     

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]                                      as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

declare @chave varchar(44) = ''
declare @cd_parametro int  = 0

select @chave             = valor from #json where campo = 'cd_chave_acesso'       
select @cd_parametro      = valor from #json where campo = 'cd_parametro'       

--set @chave = cast(@json as varchar(44))

declare @cd_nota_saida       int           = 0
declare @ds_nota_xml_retorno nvarchar(max) = ''
declare @cd_chave_acesso     varchar(50)   = ''


--Verifica se é nota de Entrada e foi realizado o Manifesto--

if @chave<>''
begin

  SELECT TOP (1) @ds_nota_xml_retorno = CONVERT(varchar(max), xml_conteudo) 
  FROM DFe_Inbox 
  WHERE chave_nfe = @chave AND tipo='proc' and isnull(cast(xml_conteudo as nvarchar(max)),'')<>'' 
  ORDER BY recebido_em DESC
  
  if @ds_nota_xml_retorno<>''
  begin
    select @ds_nota_xml_retorno as 'xml'
    return
  end
end




select
   top 1
   @cd_nota_saida   = isnull(cd_nota_saida,0),
   @cd_chave_acesso = substring(n.cd_chave_acesso,4,44)
from
  nota_saida n
where
  substring(n.cd_chave_acesso,4,44) = @chave

if @cd_nota_saida = 0 
begin
  select
    top 1
    @cd_nota_saida   = isnull(cd_nota_saida,0),
	@cd_chave_acesso = 'NFe'+cd_chave_acesso
  from
    nota_validacao 
  where
    cd_chave_acesso = @chave

  update
    nota_saida
  set
    cd_chave_acesso = @cd_chave_acesso
  where
    cd_nota_saida   = @cd_nota_saida
    and
    cd_chave_acesso <> @cd_chave_acesso
    and
    @cd_nota_saida>0
    and 
    @cd_chave_acesso<>''

end


--select @cd_nota_saida, @chave 
--select cd_chave_acesso, * from nota_saida
--select * from nota_validacao
--29250827677562000120550010000000011334866002
--29250827677562000120550010000000021937329618

if @cd_nota_saida>0 
begin
  
  --12.08.2025-- producao
  
  select @ds_nota_xml_retorno = ds_nota_xml_retorno --ds_nota_documento --ds_nota_xml_retorno
  from
    Nota_Saida_Documento 
  where
    cd_nota_saida = @cd_nota_saida

	select @ds_nota_xml_retorno as 'xml'
	return

end

if @cd_nota_saida > 0 and @ds_nota_xml_retorno=''
begin

  select 
    @ds_nota_xml_retorno        = ds_xml_nota
    --@cd_protocolo_nfe           = isnull(cd_protocolo_nfe,'') 
  from
    Nota_Validacao
  where
    cd_nota_saida = @cd_nota_saida
	and
	isnull(ic_validada,'N')='S'

	select @ds_nota_xml_retorno as 'xml' --@cd_protocolo_nfe as cd_protocolo_nfe
	return

end

--Nota e Entrada--

if @ds_nota_xml_retorno='' --and 1=2
begin
  --select 2 as aqui

  select @ds_nota_xml_retorno = 
     cast( ds_nota_documento as nvarchar(max))    --ds_nota_documento --ds_nota_xml_retorno
    
  
  from
    Nota_Entrada_Documento ne 
	inner join nota_entrada_complemento nec on nec.cd_nota_entrada = ne.cd_nota_entrada and
	                                           nec.cd_fornecedor   = ne.cd_fornecedor   and
											   nec.cd_serie_nota_fiscal = ne.cd_serie_nota_fiscal
  where
    nec.cd_chave_acesso = @chave
    
  if cast(@ds_nota_xml_retorno as nvarchar(max)) <>''
  begin
	select @ds_nota_xml_retorno as 'xml'
	return
  end

end


if @ds_nota_xml_retorno = ''
begin
  --select @cd_chave_acesso

   select
     top 1 @ds_nota_xml_retorno = 
     cast( ds_xml as nvarchar(max))    --ds_nota_documento --ds_nota_xml_retorno
   from
     nota_xml n
     left outer join NFE_Nota e on e.cd_nota = n.cd_xml_nota

   where
     isnull(n.cd_chave_acesso, e.cd_chave_acesso)  = @cd_chave_acesso

     select @ds_nota_xml_retorno as 'xml'
	 return

end

go
--use egissql_317
go

--select * from nota_entrada_complemento order by dt_usuario desc
--select * from nota_xml
--go
--select * from nfe_nota where cd_chave_acesso ='35170408218435000119550010000011041600001009'
--go

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_busca_xml_chave_acesso "35251033092357000104550020000015821000022823"

--exec  pr_egis_busca_xml_chave_acesso '[{"cd_chave_acesso" : "35251103418924007375650010000005281000005566"}]'

--3781
------------------------------------------------------------------------------
--select * from nota_validacao
--select * from nota_saida_documento

--<?xml version="1.0" encoding="UTF-8"?><nfeProc versao="4.00" xmlns="http://www.portalfiscal.inf.br/nfe"><NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe Id="NFe35250810904110000131550010000298451000037802" versao="4.00"><ide><cUF>35</cUF><cNF>00003780</cNF><natOp>VENDA DE MERCADORIA</natOp><mod>55</mod><serie>1</serie><nNF>29845</nNF><dhEmi>2025-08-11T15:55:23-03:00</dhEmi><tpNF>1</tpNF><idDest>1</idDest><cMunFG>3505708</cMunFG><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>2</cDV><tpAmb>2</tpAmb><finNFe>1</finNFe><indFinal>1</indFinal><indPres>9</indPres><indIntermed>0</indIntermed><procEmi>0</procEmi><verProc>1.2.3</verProc></ide><emit><CNPJ>10904110000131</CNPJ><xNome>BARUAGUA COM. DE AGUA MINERAL LTDA.</xNome><xFant>BARUAGUA</xFant><enderEmit><xLgr>RUA TAMOIO,</xLgr><nro>15</nro><xBairro>VL. PINDORAMA</xBairro><cMun>3505708</cMun><xMun>BARUERI</xMun><UF>SP</UF><CEP>06413140</CEP><cPais>1058</cPais><xPais>Brasil</xPais><fone>41612319</fone></enderEmit><IE>206126211115</IE><IM>000000000000000</IM><CNAE>2599399</CNAE><CRT>1</CRT></emit><dest><CNPJ>08343492000804</CNPJ><xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL</xNome><enderDest><xLgr>AVENIDA ERMANO MARCHETTI</xLgr><nro>1435</nro><xBairro>ÁGUA BRANCA</xBairro><cMun>3550308</cMun><xMun>SAO PAULO</xMun><UF>SP</UF><CEP>05038001</CEP><cPais>1058</cPais><xPais>Brasil</xPais><fone>1147325155</fone></enderDest><indIEDest>1</indIEDest><IE>149847337111</IE><email>domingos.silva@mrv.com.br</email></dest><det nItem="1"><prod><cProd>00001</cProd><cEAN>SEM GTIN</cEAN><xProd>AGUA POTAVEL</xProd><NCM>22019000</NCM><CFOP>5102</CFOP><uCom>M3</uCom><qCom>100.0000</qCom><vUnCom>31.8850000000</vUnCom><vProd>3188.50</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>M3</uTrib><qTrib>100.0000</qTrib><vUnTrib>31.8850000000</vUnTrib><indTot>1</indTot><nItemPed>0</nItemPed></prod><imposto><vTotTrib>3188.50</vTotTrib><ICMS><ICMSSN101><orig>0</orig><CSOSN>101</CSOSN><pCredSN>1.25</pCredSN><vCredICMSSN>39.86</vCredICMSSN></ICMSSN101></ICMS><PIS><PISOutr><CST>99</CST><vBC>0.00</vBC><pPIS>0.0000</pPIS><vPIS>0.00</vPIS></PISOutr></PIS><COFINS><COFINSOutr><CST>99</CST><vBC>0.00</vBC><pCOFINS>0.0000</pCOFINS><vCOFINS>0.00</vCOFINS></COFINSOutr></COFINS></imposto></det><total><ICMSTot><vBC>0.00</vBC><vICMS>0.00</vICMS><vICMSDeson>0.00</vICMSDeson><vFCP>0.00</vFCP><vBCST>0.00</vBCST><vST>0.00</vST><vFCPST>0.00</vFCPST><vFCPSTRet>0.00</vFCPSTRet><vProd>3188.50</vProd><vFrete>0.00</vFrete><vSeg>0.00</vSeg><vDesc>0.00</vDesc><vII>0.00</vII><vIPI>0.00</vIPI><vIPIDevol>0.00</vIPIDevol><vPIS>0.00</vPIS><vCOFINS>0.00</vCOFINS><vOutro>0.00</vOutro><vNF>3188.50</vNF><vTotTrib>3188.50</vTotTrib></ICMSTot></total><transp><modFrete>9</modFrete></transp><pag><detPag><indPag>1</indPag><tPag>14</tPag><vPag>3188.50</vPag></detPag></pag><infRespTec><CNPJ>16875807000108</CNPJ><xContato>GBS TECNOLOGIA E CONSULTORIA LTDA</xContato><email>financeiro@gbstec.com.br</email><fone>39074141</fone></infRespTec></infNFe><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/><Reference URI="#NFe35250810904110000131550010000298451000037802"><Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><DigestValue>Rzpfm4o9fpMs3qr/LeURb4BjlRg=</DigestValue></Reference></SignedInfo><SignatureValue>cGW+CfCkpnCT46j0Lz/XA/ituMDRByX9eOY6DYVkee/Omn+avHilnUMvLsY/B7FnHOpIfdEQJYWaehmLfmqT/vqCajY32NDNYncIxmY/g42eTlrno9o9o/obf37TE9SjlnFBOZoeqQrE5OCxzV4aQY/wGR+QSGf8pv1iYNPuAQ2/pjJtKUSS5C6Z/wiYkCE2cb+uWjfZZ+K04ZLLMcbTtyi6jtISW6H+MSaUg1Th0Wi8grx6wyo1cghBgMbWgrs2uz2j0i/67jmXXke1NRySBj3noWPdm8tRYb18/2YmvcO4EvfyZP0ewpLo9uCvYsXm7EdogTiZgsvZRClnQtIIIQ==</SignatureValue><KeyInfo><X509Data><X509Certificate>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</X509Certificate></X509Data></KeyInfo></Signature></NFe><protNFe versao="4.00"><infProt><tpAmb>2</tpAmb><verAplic>SP_NFE_PL009_V4</verAplic><chNFe>35250810904110000131550010000298451000037802</chNFe><dhRecbto>2025-08-11T15:55:24-03:00</dhRecbto><nProt>135250006668862</nProt><digVal>Rzpfm4o9fpMs3qr/LeURb4BjlRg=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso da NF-e</xMotivo></infProt></protNFe></nfeProc>
--<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><nfeResultMsg xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeAutorizacao4"><retEnviNFe versao="4.00" xmlns="http://www.portalfiscal.inf.br/nfe"><tpAmb>2</tpAmb><verAplic>SP_NFE_PL009_V4</verAplic><cStat>104</cStat><xMotivo>Lote processado</xMotivo><cUF>35</cUF><dhRecbto>2025-08-11T15:55:24-03:00</dhRecbto><protNFe versao="4.00"><infProt><tpAmb>2</tpAmb><verAplic>SP_NFE_PL009_V4</verAplic><chNFe>35250810904110000131550010000298451000037802</chNFe><dhRecbto>2025-08-11T15:55:24-03:00</dhRecbto><nProt>135250006668862</nProt><digVal>Rzpfm4o9fpMs3qr/LeURb4BjlRg=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso da NF-e</xMotivo></infProt></protNFe></retEnviNFe></nfeResultMsg></soap:Body></soap:Envelope>
go
