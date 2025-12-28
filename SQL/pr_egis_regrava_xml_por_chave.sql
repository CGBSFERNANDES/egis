CREATE OR ALTER PROCEDURE pr_egis_regrava_xml_por_chave
  @cd_chave_acesso VARCHAR(44)   = '',
  @xml             NVARCHAR(MAX) = '',
  @protocolo       VARCHAR(40) = NULL,
  @dt_aut          DATETIME2(0) = NULL,
  @json            nvarchar(max) = ''
AS
BEGIN

SET NOCOUNT ON;

set @json = isnull(@json,'')


--  if @xml = ''
--     return

BEGIN TRY

 select                     

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]              as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores    


  DECLARE @cd_nota_saida INT = 0

  select @cd_nota_saida          = valor from #json where campo = 'cd_nota_saida'

  select @cd_nota_saida
  --return

  if @cd_chave_acesso<>''
  begin
  set @cd_nota_saida = 
    (SELECT TOP 1 cd_nota_saida
       FROM nota_saida
      WHERE SUBSTRING(cd_chave_acesso,4,44) = @cd_chave_acesso);
  end


  IF @cd_nota_saida IS NULL
  BEGIN
    RAISERROR('Chave não localizada.', 16, 1);
    RETURN;
  END



  UPDATE Nota_Validacao
     SET ds_xml_nota      = @xml,
         cd_protocolo_nfe = COALESCE(@protocolo, cd_protocolo_nfe),
         dt_autorizacao   = COALESCE(@dt_aut, dt_autorizacao),
         ic_validada      = 'S',
         dt_usuario       = GETDATE(),
         cd_chave_acesso = COALESCE(@cd_chave_acesso, cd_chave_acesso)

   WHERE cd_nota_saida = @cd_nota_saida;

  IF EXISTS (SELECT 1 FROM Nota_Saida_Documento WHERE cd_nota_saida = @cd_nota_saida)
      UPDATE Nota_Saida_Documento
         SET ds_nota_xml_retorno = @xml,
             dt_usuario          = GETDATE()
       WHERE cd_nota_saida = @cd_nota_saida;
  ELSE
  BEGIN
      DECLARE @novo INT = ISNULL((SELECT MAX(cd_nota_documento) FROM Nota_Saida_Documento),0) + 1;
      INSERT INTO Nota_Saida_Documento
         (cd_nota_documento, cd_nota_saida, cd_tipo_documento, ds_nota_documento, ds_nota_xml_retorno, cd_usuario, dt_usuario)
      VALUES
         (@novo, @cd_nota_saida, 1, NULL, @xml, NULL, GETDATE());
  END

  IF @protocolo IS NOT NULL
  BEGIN
    IF EXISTS (SELECT 1 FROM Nota_Saida_Recibo WHERE cd_nota_saida = @cd_nota_saida)
      UPDATE Nota_Saida_Recibo
         SET cd_protocolo_nfe = @protocolo,
             dt_autorizacao_nota = COALESCE(@dt_aut, dt_autorizacao_nota)
       WHERE cd_nota_saida = @cd_nota_saida;
    ELSE
      INSERT INTO Nota_Saida_Recibo (cd_nota_saida, cd_protocolo_nfe, dt_autorizacao_nota)
      VALUES (@cd_nota_saida, @protocolo, COALESCE(@dt_aut, GETDATE()));
  END

END


    SELECT
      ok       = 1,
      msg      = N'Atualizado com sucesso',
      chave    = @cd_chave_acesso,
      protocolo= @protocolo,
      dt_aut   = CONVERT(varchar(19), @dt_aut, 120);
END TRY
  BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    -- opcional: log em tabela de erros
    SELECT ok = 0, msg = @msg;
  END CATCH
END
go

--EXEC pr_egis_regrava_xml_por_chave 
--  @cd_chave_acesso = '29250827677562000120550010000007041000000112',
--  @xml = N'"<?xml version=\"1.0\" encoding=\"UTF-8\"?><nfeProc versao=\"4.00\" xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\"><NFe xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\"><infNFe Id=\"NFe29250827677562000120550010000007041000000112\" versao=\"4.00\"><ide><cUF>29<\/cUF><cNF>00000011<\/cNF><natOp>VENDAS DE PRODUCAO ESTABELECIMENTO<\/natOp><mod>55<\/mod><serie>1<\/serie><nNF>704<\/nNF><dhEmi>2025-08-19T08:58:21-03:00<\/dhEmi><dhSaiEnt>2025-08-20T08:58:21-03:00<\/dhSaiEnt><tpNF>1<\/tpNF><idDest>1<\/idDest><cMunFG>2932903<\/cMunFG><tpImp>1<\/tpImp><tpEmis>1<\/tpEmis><cDV>2<\/cDV><tpAmb>2<\/tpAmb><finNFe>1<\/finNFe><indFinal>0<\/indFinal><indPres>1<\/indPres><indIntermed>0<\/indIntermed><procEmi>0<\/procEmi><verProc>1.2.3<\/verProc><\/ide><emit><CNPJ>27677562000120<\/CNPJ><xNome>FABRICA ACAI PAREAKI LTDA<\/xNome><xFant>PAREAKI<\/xFant><enderEmit><xLgr>RUA ALGUIDAR<\/xLgr><nro>SN<\/nro><xBairro>JAQUEIRA<\/xBairro><cMun>2932903<\/cMun><xMun>VALENCA<\/xMun><UF>BA<\/UF><CEP>45400000<\/CEP><cPais>1058<\/cPais><xPais>Brasil<\/xPais><fone>75982695609<\/fone><\/enderEmit><IE>140346417<\/IE><IM>000000000000000<\/IM><CRT>1<\/CRT><\/emit><dest><CNPJ>35990338000112<\/CNPJ><xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL<\/xNome><enderDest><xLgr>RUA PEDRO LONGO<\/xLgr><nro>341<\/nro><xBairro>PITUBA<\/xBairro><cMun>2914901<\/cMun><xMun>ITACARE<\/xMun><UF>BA<\/UF><CEP>45530000<\/CEP><cPais>1058<\/cPais><xPais>Brasil<\/xPais><fone>7399173704<\/fone><\/enderDest><indIEDest>1<\/indIEDest><IE>164550543<\/IE><\/dest><autXML><CNPJ>13352975000120<\/CNPJ><\/autXML><det nItem=\"1\"><prod><cProd>PRD00097<\/cProd><cEAN>SEM GTIN<\/cEAN><xProd>SUNDAE CHOCOLATE<\/xProd><NCM>21050010<\/NCM><CFOP>5101<\/CFOP><uCom>UN<\/uCom><qCom>4.0000<\/qCom><vUnCom>5.0000000000<\/vUnCom><vProd>20.00<\/vProd><cEANTrib>SEM GTIN<\/cEANTrib><uTrib>UN<\/uTrib><qTrib>4.0000<\/qTrib><vUnTrib>5.0000000000<\/vUnTrib><indTot>1<\/indTot><nItemPed>0<\/nItemPed><\/prod><imposto><vTotTrib>20.00<\/vTotTrib><ICMS><ICMSSN101><orig>0<\/orig><CSOSN>101<\/CSOSN><pCredSN>1.25<\/pCredSN><vCredICMSSN>0.25<\/vCredICMSSN><\/ICMSSN101><\/ICMS><PIS><PISOutr><CST>49<\/CST><vBC>0.00<\/vBC><pPIS>0.0000<\/pPIS><vPIS>0.00<\/vPIS><\/PISOutr><\/PIS><COFINS><COFINSOutr><CST>49<\/CST><vBC>0.00<\/vBC><pCOFINS>0.0000<\/pCOFINS><vCOFINS>0.00<\/vCOFINS><\/COFINSOutr><\/COFINS><\/imposto><\/det><det nItem=\"2\"><prod><cProd>PRD00098<\/cProd><cEAN>SEM GTIN<\/cEAN><xProd>SUNDAE MORANGO<\/xProd><NCM>21050010<\/NCM><CFOP>5101<\/CFOP><uCom>UN<\/uCom><qCom>5.0000<\/qCom><vUnCom>5.0000000000<\/vUnCom><vProd>25.00<\/vProd><cEANTrib>SEM GTIN<\/cEANTrib><uTrib>UN<\/uTrib><qTrib>5.0000<\/qTrib><vUnTrib>5.0000000000<\/vUnTrib><indTot>1<\/indTot><nItemPed>0<\/nItemPed><\/prod><imposto><vTotTrib>25.00<\/vTotTrib><ICMS><ICMSSN101><orig>0<\/orig><CSOSN>101<\/CSOSN><pCredSN>1.25<\/pCredSN><vCredICMSSN>0.31<\/vCredICMSSN><\/ICMSSN101><\/ICMS><PIS><PISOutr><CST>49<\/CST><vBC>0.00<\/vBC><pPIS>0.0000<\/pPIS><vPIS>0.00<\/vPIS><\/PISOutr><\/PIS><COFINS><COFINSOutr><CST>49<\/CST><vBC>0.00<\/vBC><pCOFINS>0.0000<\/pCOFINS><vCOFINS>0.00<\/vCOFINS><\/COFINSOutr><\/COFINS><\/imposto><\/det><total><ICMSTot><vBC>0.00<\/vBC><vICMS>0.00<\/vICMS><vICMSDeson>0.00<\/vICMSDeson><vFCP>0.00<\/vFCP><vBCST>0.00<\/vBCST><vST>0.00<\/vST><vFCPST>0.00<\/vFCPST><vFCPSTRet>0.00<\/vFCPSTRet><vProd>45.00<\/vProd><vFrete>0.00<\/vFrete><vSeg>0.00<\/vSeg><vDesc>0.00<\/vDesc><vII>0.00<\/vII><vIPI>0.00<\/vIPI><vIPIDevol>0.00<\/vIPIDevol><vPIS>0.00<\/vPIS><vCOFINS>0.00<\/vCOFINS><vOutro>0.00<\/vOutro><vNF>45.00<\/vNF><vTotTrib>45.00<\/vTotTrib><\/ICMSTot><\/total><transp><modFrete>9<\/modFrete><\/transp><cobr><fat><nFat>07 DIAS<\/nFat><vOrig>45.00<\/vOrig><vDesc>0.00<\/vDesc><vLiq>45.00<\/vLiq><\/fat><dup><nDup>001<\/nDup><dVenc>2025-08-27<\/dVenc><vDup>45.00<\/vDup><\/dup><\/cobr><pag><detPag><indPag>1<\/indPag><tPag>14<\/tPag><vPag>45.00<\/vPag><\/detPag><\/pag><infAdic><infCpl>DARIO ITACARE ** CONFIRA SEU PEDIDO NO ATO DA ENTREGA, NAO ACEITAMOS RECLAMACOES POSTERIORES APOS A DATA DO RECEBIMENTO ** Vendedor: VANDERLEI Contato: Pedido(s) de Venda: 6-It.1,2;<\/infCpl><\/infAdic><infRespTec><CNPJ>16875807000108<\/CNPJ><xContato>GBS TECNOLOGIA E CONSULTORIA LTDA<\/xContato><email>financeiro@gbstec.com.br<\/email><fone>39074141<\/fone><\/infRespTec><\/infNFe><Signature xmlns=\"http:\/\/www.w3.org\/2000\/09\/xmldsig#\"><SignedInfo><CanonicalizationMethod Algorithm=\"http:\/\/www.w3.org\/TR\/2001\/REC-xml-c14n-20010315\"\/><SignatureMethod Algorithm=\"http:\/\/www.w3.org\/2000\/09\/xmldsig#rsa-sha1\"\/><Reference URI=\"#NFe29250827677562000120550010000007041000000112\"><Transforms><Transform Algorithm=\"http:\/\/www.w3.org\/2000\/09\/xmldsig#enveloped-signature\"\/><Transform Algorithm=\"http:\/\/www.w3.org\/TR\/2001\/REC-xml-c14n-20010315\"\/><\/Transforms><DigestMethod Algorithm=\"http:\/\/www.w3.org\/2000\/09\/xmldsig#sha1\"\/><DigestValue>1oT256xGrrpd\/opZ3lNnw4Ay2so=<\/DigestValue><\/Reference><\/SignedInfo><SignatureValue>emTwLebC4qRMpTh3vMy26TqD2QPmEkJEg3L1rLXW71t4vtRAfiUKPTnO8LkgL+pdkM4QIhx1pNMjgCeVHo4FfcQP1n++nbnX4tXF\/TtNSfk1rJ70Ki8+g54iHIYG2\/cDzdybbG0waoozrkvRgVpNRHPpRAeuSBuN4Jb8KU25gwiXY8OX52XeHGYDuhIAZczEDiEsTRsh13BEUE4WJt31\/skOcJ\/JZuvbhkLROX1Z9skL4S2WgtkvyJLv1Be38AhL2opw4dXqspSGWb8bgyFcgZ9vP5fO7+JVmt5zUkc4t4Z2+qK8Oxi6qYZEwxmRbTLT4RUNBVa8uMgI9M1LT1po3A==<\/SignatureValue><KeyInfo><X509Data><X509Certificate>MIIHSDCCBTCgAwIBAgIIRXwlAwZwjDIwDQYJKoZIhvcNAQELBQAwWTELMAkGA1UEBhMCQlIxEzARBgNVBAoTCklDUC1CcmFzaWwxFTATBgNVBAsTDEFDIFNPTFVUSSB2NTEeMBwGA1UEAxMVQUMgU09MVVRJIE11bHRpcGxhIHY1MB4XDTI1MDMwNzEyMzUwMFoXDTI2MDMwNzEyMzUwMFowgeQxCzAJBgNVBAYTAkJSMRMwEQYDVQQKEwpJQ1AtQnJhc2lsMQswCQYDVQQIEwJCQTEQMA4GA1UEBxMHVmFsZW5jYTEeMBwGA1UECxMVQUMgU09MVVRJIE11bHRpcGxhIHY1MRcwFQYDVQQLEw4zMjQ2NzMyOTAwMDE1MzEZMBcGA1UECxMQVmlkZW9jb25mZXJlbmNpYTEaMBgGA1UECxMRQ2VydGlmaWNhZG8gUEogQTExMTAvBgNVBAMTKEZBQlJJQ0EgQUNBSSBQQVJFQUtJIExUREE6Mjc2Nzc1NjIwMDAxMjAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCc66I4vGk5wrZveTubKmrZV0J7RnGqn8YHxgHp7Cz50tHHtrbhzAiOKOrsKStfVsPTOyCnNZ6C7xJLEu8UiAbMdLRFOh+JrVRkZDQpIhj3Bf\/unRJmMA7jVCWLR6jb2p0N9rLxTCVj2EfLEr\/iB+yiNuAxYHq5aRBBfBUNqfsDXmrijmAXjxVpUxYd94GjO+8HfScs61FccSHhIxkim76TN5YJvWxSn5seWsRWUHjk\/bLtdlchSM58nm2\/51YbjfkRvHzuT6Xzv2on+6D4cC0n9VVNGiwUcAU7cBWjzOWuBvz13KWAb3jnNwsoeI+qt6zjXuePRSy6CCuw7wUS+0qbAgMBAAGjggKGMIICgjAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFMVS7SWACd+cgsifR8bdtF8x3bmxMFQGCCsGAQUFBwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL2NjZC5hY3NvbHV0aS5jb20uYnIvbGNyL2FjLXNvbHV0aS1tdWx0aXBsYS12NS5wN2IwgcEGA1UdEQSBuTCBtoEXYW5zZWxtb2VqYW5heUBnbWFpbC5jb22gKAYFYEwBAwKgHxMdQU5TRUxNTyBOQVNDSU1FTlRPIERPUyBTQU5UT1OgGQYFYEwBAwOgEBMOMjc2Nzc1NjIwMDAxMjCgPQYFYEwBAwSgNBMyMTEwMjE5OTMwNTcyOTIxMjUwMDAwMDAwMDAwMDAwMDAwMDAxNTk4NDEwMTEzc3NwYmGgFwYFYEwBAwegDhMMMDAwMDAwMDAwMDAwMF0GA1UdIARWMFQwUgYGYEwBAgEmMEgwRgYIKwYBBQUHAgEWOmh0dHA6Ly9jY2QuYWNzb2x1dGkuY29tLmJyL2RvY3MvZHBjLWFjLXNvbHV0aS1tdWx0aXBsYS5wZGYwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMIGMBgNVHR8EgYQwgYEwPqA8oDqGOGh0dHA6Ly9jY2QuYWNzb2x1dGkuY29tLmJyL2xjci9hYy1zb2x1dGktbXVsdGlwbGEtdjUuY3JsMD+gPaA7hjlodHRwOi8vY2NkMi5hY3NvbHV0aS5jb20uYnIvbGNyL2FjLXNvbHV0aS1tdWx0aXBsYS12NS5jcmwwHQYDVR0OBBYEFJW47Jff7X2v9nCgWUIBd6ZQlvyZMA4GA1UdDwEB\/wQEAwIF4DANBgkqhkiG9w0BAQsFAAOCAgEAOkOLkXpspXFAB8tcxVnPJzrl+ykVCUBk\/nMsrssrBmplQTF5RP5Fjx8Sh2+91fLlvximTzUnDBnkvrRTeWLcI3qDUAZt6wkQkTdyRIEdkVPn2x7+V0L09wsBbzbIPL5EBh0+pwtYU0TMLJHNcmFumbJEY88\/EtjRXHpfi3Sxsm4xRExHLBAbfGMNUMwoMRwJVuPhcJX4GgxJ8f+QK2tThktaYF\/jRM0JGUSiolohMQvmq\/jcL8SLx6X6jRGr20ALR5XzCzOci69Vc1\/wx+9YuKEMBoW4J7nXWzC67+bU8u21vqi7udyWfAyY6Veqqd0wnC+K2JbrgRtnO7SY5dIeIt\/ao6prMAzvwUyOUfCDV2Xdz7Ou55DpGMHq+\/BShh1hEcyKy+pRh5ifcMiIZrajffoBGJIVP97qulrc8rTeUY\/ENPRYFBFC3EdB2yl3hu46zn6vwrtiCGbrqEznP04p\/d3jnDEdLzCttFsmRuLtuqfdXeR\/fvO5OKc+o7gbXVO2qerHOF\/SYTJnU7BMUGLTGYNVMfcoBckM+QStcF7QmGJW659kkesxZVu56tj0d\/0zWxAiwcT6KjVNqfz7LHmSuJvxrlNL89FEnpZCB5LI\/\/+5AjM7DUI2vt6G0jr2AxgaXCAtKbvSfkHADVH+BVzrJE82hHAt2DD7RMVD5FmYkFU=<\/X509Certificate><\/X509Data><\/KeyInfo><\/Signature><\/NFe><protNFe versao=\"4.00\"><infProt><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENP_v7.0.2<\/verAplic><chNFe>29250827677562000120550010000007041000000112<\/chNFe><dhRecbto>2025-08-20T08:58:22-03:00<\/dhRecbto><nProt>129252006297744<\/nProt><digVal>1oT256xGrrpd\/opZ3lNnw4Ay2so=<\/digVal><cStat>100<\/cStat><xMotivo>Autorizado o uso da NF-e<\/xMotivo><\/infProt><\/protNFe><\/nfeProc>","xml_retorno":"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http:\/\/www.w3.org\/2003\/05\/soap-envelope\" xmlns:xsi=\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\" xmlns:xsd=\"http:\/\/www.w3.org\/2001\/XMLSchema\"><soap:Body><nfeResultMsg xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\/wsdl\/NFeAutorizacao4\"><retEnviNFe xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\" versao=\"4.00\"><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENW_v7.0.2<\/verAplic><cStat>104<\/cStat><xMotivo>Lote processado<\/xMotivo><cUF>29<\/cUF><dhRecbto>2025-08-20T08:58:22-03:00<\/dhRecbto><protNFe versao=\"4.00\"><infProt><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENP_v7.0.2<\/verAplic><chNFe>29250827677562000120550010000007041000000112<\/chNFe><dhRecbto>2025-08-20T08:58:22-03:00<\/dhRecbto><nProt>129252006297744<\/nProt><digVal>1oT256xGrrpd\/opZ3lNnw4Ay2so=<\/digVal><cStat>100<\/cStat><xMotivo>Autorizado o uso da NF-e<\/xMotivo><\/infProt><\/protNFe><\/retEnviNFe><\/nfeResultMsg><\/soap:Body><\/soap:Envelope>"',
  
--  @protocolo = '129252006297699',
--  @dt_aut = '2025-08-19T22:13:26-03:00',
--  @json   = '[{"cd_parametro": 0}, {"cd_nota_saida": 11},
--                                         {"cd_empresa": 354}]'


--EXEC pr_egis_regrava_xml_por_chave 
--  @cd_chave_acesso = '',
--  @xml = N'"<?xml version=\"1.0\" encoding=\"UTF-8\"?><nfeProc versao=\"4.00\" xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\"><NFe xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\"><infNFe Id=\"NFe29250827677562000120550010000007041000000112\" versao=\"4.00\"><ide><cUF>29<\/cUF><cNF>00000011<\/cNF><natOp>VENDAS DE PRODUCAO ESTABELECIMENTO<\/natOp><mod>55<\/mod><serie>1<\/serie><nNF>704<\/nNF><dhEmi>2025-08-19T08:58:21-03:00<\/dhEmi><dhSaiEnt>2025-08-20T08:58:21-03:00<\/dhSaiEnt><tpNF>1<\/tpNF><idDest>1<\/idDest><cMunFG>2932903<\/cMunFG><tpImp>1<\/tpImp><tpEmis>1<\/tpEmis><cDV>2<\/cDV><tpAmb>2<\/tpAmb><finNFe>1<\/finNFe><indFinal>0<\/indFinal><indPres>1<\/indPres><indIntermed>0<\/indIntermed><procEmi>0<\/procEmi><verProc>1.2.3<\/verProc><\/ide><emit><CNPJ>27677562000120<\/CNPJ><xNome>FABRICA ACAI PAREAKI LTDA<\/xNome><xFant>PAREAKI<\/xFant><enderEmit><xLgr>RUA ALGUIDAR<\/xLgr><nro>SN<\/nro><xBairro>JAQUEIRA<\/xBairro><cMun>2932903<\/cMun><xMun>VALENCA<\/xMun><UF>BA<\/UF><CEP>45400000<\/CEP><cPais>1058<\/cPais><xPais>Brasil<\/xPais><fone>75982695609<\/fone><\/enderEmit><IE>140346417<\/IE><IM>000000000000000<\/IM><CRT>1<\/CRT><\/emit><dest><CNPJ>35990338000112<\/CNPJ><xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL<\/xNome><enderDest><xLgr>RUA PEDRO LONGO<\/xLgr><nro>341<\/nro><xBairro>PITUBA<\/xBairro><cMun>2914901<\/cMun><xMun>ITACARE<\/xMun><UF>BA<\/UF><CEP>45530000<\/CEP><cPais>1058<\/cPais><xPais>Brasil<\/xPais><fone>7399173704<\/fone><\/enderDest><indIEDest>1<\/indIEDest><IE>164550543<\/IE><\/dest><autXML><CNPJ>13352975000120<\/CNPJ><\/autXML><det nItem=\"1\"><prod><cProd>PRD00097<\/cProd><cEAN>SEM GTIN<\/cEAN><xProd>SUNDAE CHOCOLATE<\/xProd><NCM>21050010<\/NCM><CFOP>5101<\/CFOP><uCom>UN<\/uCom><qCom>4.0000<\/qCom><vUnCom>5.0000000000<\/vUnCom><vProd>20.00<\/vProd><cEANTrib>SEM GTIN<\/cEANTrib><uTrib>UN<\/uTrib><qTrib>4.0000<\/qTrib><vUnTrib>5.0000000000<\/vUnTrib><indTot>1<\/indTot><nItemPed>0<\/nItemPed><\/prod><imposto><vTotTrib>20.00<\/vTotTrib><ICMS><ICMSSN101><orig>0<\/orig><CSOSN>101<\/CSOSN><pCredSN>1.25<\/pCredSN><vCredICMSSN>0.25<\/vCredICMSSN><\/ICMSSN101><\/ICMS><PIS><PISOutr><CST>49<\/CST><vBC>0.00<\/vBC><pPIS>0.0000<\/pPIS><vPIS>0.00<\/vPIS><\/PISOutr><\/PIS><COFINS><COFINSOutr><CST>49<\/CST><vBC>0.00<\/vBC><pCOFINS>0.0000<\/pCOFINS><vCOFINS>0.00<\/vCOFINS><\/COFINSOutr><\/COFINS><\/imposto><\/det><det nItem=\"2\"><prod><cProd>PRD00098<\/cProd><cEAN>SEM GTIN<\/cEAN><xProd>SUNDAE MORANGO<\/xProd><NCM>21050010<\/NCM><CFOP>5101<\/CFOP><uCom>UN<\/uCom><qCom>5.0000<\/qCom><vUnCom>5.0000000000<\/vUnCom><vProd>25.00<\/vProd><cEANTrib>SEM GTIN<\/cEANTrib><uTrib>UN<\/uTrib><qTrib>5.0000<\/qTrib><vUnTrib>5.0000000000<\/vUnTrib><indTot>1<\/indTot><nItemPed>0<\/nItemPed><\/prod><imposto><vTotTrib>25.00<\/vTotTrib><ICMS><ICMSSN101><orig>0<\/orig><CSOSN>101<\/CSOSN><pCredSN>1.25<\/pCredSN><vCredICMSSN>0.31<\/vCredICMSSN><\/ICMSSN101><\/ICMS><PIS><PISOutr><CST>49<\/CST><vBC>0.00<\/vBC><pPIS>0.0000<\/pPIS><vPIS>0.00<\/vPIS><\/PISOutr><\/PIS><COFINS><COFINSOutr><CST>49<\/CST><vBC>0.00<\/vBC><pCOFINS>0.0000<\/pCOFINS><vCOFINS>0.00<\/vCOFINS><\/COFINSOutr><\/COFINS><\/imposto><\/det><total><ICMSTot><vBC>0.00<\/vBC><vICMS>0.00<\/vICMS><vICMSDeson>0.00<\/vICMSDeson><vFCP>0.00<\/vFCP><vBCST>0.00<\/vBCST><vST>0.00<\/vST><vFCPST>0.00<\/vFCPST><vFCPSTRet>0.00<\/vFCPSTRet><vProd>45.00<\/vProd><vFrete>0.00<\/vFrete><vSeg>0.00<\/vSeg><vDesc>0.00<\/vDesc><vII>0.00<\/vII><vIPI>0.00<\/vIPI><vIPIDevol>0.00<\/vIPIDevol><vPIS>0.00<\/vPIS><vCOFINS>0.00<\/vCOFINS><vOutro>0.00<\/vOutro><vNF>45.00<\/vNF><vTotTrib>45.00<\/vTotTrib><\/ICMSTot><\/total><transp><modFrete>9<\/modFrete><\/transp><cobr><fat><nFat>07 DIAS<\/nFat><vOrig>45.00<\/vOrig><vDesc>0.00<\/vDesc><vLiq>45.00<\/vLiq><\/fat><dup><nDup>001<\/nDup><dVenc>2025-08-27<\/dVenc><vDup>45.00<\/vDup><\/dup><\/cobr><pag><detPag><indPag>1<\/indPag><tPag>14<\/tPag><vPag>45.00<\/vPag><\/detPag><\/pag><infAdic><infCpl>DARIO ITACARE ** CONFIRA SEU PEDIDO NO ATO DA ENTREGA, NAO ACEITAMOS RECLAMACOES POSTERIORES APOS A DATA DO RECEBIMENTO ** Vendedor: VANDERLEI Contato: Pedido(s) de Venda: 6-It.1,2;<\/infCpl><\/infAdic><infRespTec><CNPJ>16875807000108<\/CNPJ><xContato>GBS TECNOLOGIA E CONSULTORIA LTDA<\/xContato><email>financeiro@gbstec.com.br<\/email><fone>39074141<\/fone><\/infRespTec><\/infNFe><Signature xmlns=\"http:\/\/www.w3.org\/2000\/09\/xmldsig#\"><SignedInfo><CanonicalizationMethod Algorithm=\"http:\/\/www.w3.org\/TR\/2001\/REC-xml-c14n-20010315\"\/><SignatureMethod Algorithm=\"http:\/\/www.w3.org\/2000\/09\/xmldsig#rsa-sha1\"\/><Reference URI=\"#NFe29250827677562000120550010000007041000000112\"><Transforms><Transform Algorithm=\"http:\/\/www.w3.org\/2000\/09\/xmldsig#enveloped-signature\"\/><Transform Algorithm=\"http:\/\/www.w3.org\/TR\/2001\/REC-xml-c14n-20010315\"\/><\/Transforms><DigestMethod Algorithm=\"http:\/\/www.w3.org\/2000\/09\/xmldsig#sha1\"\/><DigestValue>1oT256xGrrpd\/opZ3lNnw4Ay2so=<\/DigestValue><\/Reference><\/SignedInfo><SignatureValue>emTwLebC4qRMpTh3vMy26TqD2QPmEkJEg3L1rLXW71t4vtRAfiUKPTnO8LkgL+pdkM4QIhx1pNMjgCeVHo4FfcQP1n++nbnX4tXF\/TtNSfk1rJ70Ki8+g54iHIYG2\/cDzdybbG0waoozrkvRgVpNRHPpRAeuSBuN4Jb8KU25gwiXY8OX52XeHGYDuhIAZczEDiEsTRsh13BEUE4WJt31\/skOcJ\/JZuvbhkLROX1Z9skL4S2WgtkvyJLv1Be38AhL2opw4dXqspSGWb8bgyFcgZ9vP5fO7+JVmt5zUkc4t4Z2+qK8Oxi6qYZEwxmRbTLT4RUNBVa8uMgI9M1LT1po3A==<\/SignatureValue><KeyInfo><X509Data><X509Certificate>MIIHSDCCBTCgAwIBAgIIRXwlAwZwjDIwDQYJKoZIhvcNAQELBQAwWTELMAkGA1UEBhMCQlIxEzARBgNVBAoTCklDUC1CcmFzaWwxFTATBgNVBAsTDEFDIFNPTFVUSSB2NTEeMBwGA1UEAxMVQUMgU09MVVRJIE11bHRpcGxhIHY1MB4XDTI1MDMwNzEyMzUwMFoXDTI2MDMwNzEyMzUwMFowgeQxCzAJBgNVBAYTAkJSMRMwEQYDVQQKEwpJQ1AtQnJhc2lsMQswCQYDVQQIEwJCQTEQMA4GA1UEBxMHVmFsZW5jYTEeMBwGA1UECxMVQUMgU09MVVRJIE11bHRpcGxhIHY1MRcwFQYDVQQLEw4zMjQ2NzMyOTAwMDE1MzEZMBcGA1UECxMQVmlkZW9jb25mZXJlbmNpYTEaMBgGA1UECxMRQ2VydGlmaWNhZG8gUEogQTExMTAvBgNVBAMTKEZBQlJJQ0EgQUNBSSBQQVJFQUtJIExUREE6Mjc2Nzc1NjIwMDAxMjAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCc66I4vGk5wrZveTubKmrZV0J7RnGqn8YHxgHp7Cz50tHHtrbhzAiOKOrsKStfVsPTOyCnNZ6C7xJLEu8UiAbMdLRFOh+JrVRkZDQpIhj3Bf\/unRJmMA7jVCWLR6jb2p0N9rLxTCVj2EfLEr\/iB+yiNuAxYHq5aRBBfBUNqfsDXmrijmAXjxVpUxYd94GjO+8HfScs61FccSHhIxkim76TN5YJvWxSn5seWsRWUHjk\/bLtdlchSM58nm2\/51YbjfkRvHzuT6Xzv2on+6D4cC0n9VVNGiwUcAU7cBWjzOWuBvz13KWAb3jnNwsoeI+qt6zjXuePRSy6CCuw7wUS+0qbAgMBAAGjggKGMIICgjAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFMVS7SWACd+cgsifR8bdtF8x3bmxMFQGCCsGAQUFBwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL2NjZC5hY3NvbHV0aS5jb20uYnIvbGNyL2FjLXNvbHV0aS1tdWx0aXBsYS12NS5wN2IwgcEGA1UdEQSBuTCBtoEXYW5zZWxtb2VqYW5heUBnbWFpbC5jb22gKAYFYEwBAwKgHxMdQU5TRUxNTyBOQVNDSU1FTlRPIERPUyBTQU5UT1OgGQYFYEwBAwOgEBMOMjc2Nzc1NjIwMDAxMjCgPQYFYEwBAwSgNBMyMTEwMjE5OTMwNTcyOTIxMjUwMDAwMDAwMDAwMDAwMDAwMDAxNTk4NDEwMTEzc3NwYmGgFwYFYEwBAwegDhMMMDAwMDAwMDAwMDAwMF0GA1UdIARWMFQwUgYGYEwBAgEmMEgwRgYIKwYBBQUHAgEWOmh0dHA6Ly9jY2QuYWNzb2x1dGkuY29tLmJyL2RvY3MvZHBjLWFjLXNvbHV0aS1tdWx0aXBsYS5wZGYwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMIGMBgNVHR8EgYQwgYEwPqA8oDqGOGh0dHA6Ly9jY2QuYWNzb2x1dGkuY29tLmJyL2xjci9hYy1zb2x1dGktbXVsdGlwbGEtdjUuY3JsMD+gPaA7hjlodHRwOi8vY2NkMi5hY3NvbHV0aS5jb20uYnIvbGNyL2FjLXNvbHV0aS1tdWx0aXBsYS12NS5jcmwwHQYDVR0OBBYEFJW47Jff7X2v9nCgWUIBd6ZQlvyZMA4GA1UdDwEB\/wQEAwIF4DANBgkqhkiG9w0BAQsFAAOCAgEAOkOLkXpspXFAB8tcxVnPJzrl+ykVCUBk\/nMsrssrBmplQTF5RP5Fjx8Sh2+91fLlvximTzUnDBnkvrRTeWLcI3qDUAZt6wkQkTdyRIEdkVPn2x7+V0L09wsBbzbIPL5EBh0+pwtYU0TMLJHNcmFumbJEY88\/EtjRXHpfi3Sxsm4xRExHLBAbfGMNUMwoMRwJVuPhcJX4GgxJ8f+QK2tThktaYF\/jRM0JGUSiolohMQvmq\/jcL8SLx6X6jRGr20ALR5XzCzOci69Vc1\/wx+9YuKEMBoW4J7nXWzC67+bU8u21vqi7udyWfAyY6Veqqd0wnC+K2JbrgRtnO7SY5dIeIt\/ao6prMAzvwUyOUfCDV2Xdz7Ou55DpGMHq+\/BShh1hEcyKy+pRh5ifcMiIZrajffoBGJIVP97qulrc8rTeUY\/ENPRYFBFC3EdB2yl3hu46zn6vwrtiCGbrqEznP04p\/d3jnDEdLzCttFsmRuLtuqfdXeR\/fvO5OKc+o7gbXVO2qerHOF\/SYTJnU7BMUGLTGYNVMfcoBckM+QStcF7QmGJW659kkesxZVu56tj0d\/0zWxAiwcT6KjVNqfz7LHmSuJvxrlNL89FEnpZCB5LI\/\/+5AjM7DUI2vt6G0jr2AxgaXCAtKbvSfkHADVH+BVzrJE82hHAt2DD7RMVD5FmYkFU=<\/X509Certificate><\/X509Data><\/KeyInfo><\/Signature><\/NFe><protNFe versao=\"4.00\"><infProt><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENP_v7.0.2<\/verAplic><chNFe>29250827677562000120550010000007041000000112<\/chNFe><dhRecbto>2025-08-20T08:58:22-03:00<\/dhRecbto><nProt>129252006297744<\/nProt><digVal>1oT256xGrrpd\/opZ3lNnw4Ay2so=<\/digVal><cStat>100<\/cStat><xMotivo>Autorizado o uso da NF-e<\/xMotivo><\/infProt><\/protNFe><\/nfeProc>","xml_retorno":"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http:\/\/www.w3.org\/2003\/05\/soap-envelope\" xmlns:xsi=\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\" xmlns:xsd=\"http:\/\/www.w3.org\/2001\/XMLSchema\"><soap:Body><nfeResultMsg xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\/wsdl\/NFeAutorizacao4\"><retEnviNFe xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\" versao=\"4.00\"><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENW_v7.0.2<\/verAplic><cStat>104<\/cStat><xMotivo>Lote processado<\/xMotivo><cUF>29<\/cUF><dhRecbto>2025-08-20T08:58:22-03:00<\/dhRecbto><protNFe versao=\"4.00\"><infProt><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENP_v7.0.2<\/verAplic><chNFe>29250827677562000120550010000007041000000112<\/chNFe><dhRecbto>2025-08-20T08:58:22-03:00<\/dhRecbto><nProt>129252006297744<\/nProt><digVal>1oT256xGrrpd\/opZ3lNnw4Ay2so=<\/digVal><cStat>100<\/cStat><xMotivo>Autorizado o uso da NF-e<\/xMotivo><\/infProt><\/protNFe><\/retEnviNFe><\/nfeResultMsg><\/soap:Body><\/soap:Envelope>"',
  
--  @protocolo = '129252006297699',
--  @dt_aut = '2025-08-19T22:13:26-03:00',
--  @json   = '[{"cd_parametro": 0}, {"cd_nota_saida": 11},
--                                         {"cd_empresa": 354}]'
--  select * from nota_validacao