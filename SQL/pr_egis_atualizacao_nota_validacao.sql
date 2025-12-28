IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_atualizacao_nota_validacao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_atualizacao_nota_validacao

GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO  
-------------------------------------------------------------------------------
--sp_helptext pr_egis_atualizacao_nota_validacao
-------------------------------------------------------------------------------
--pr_egis_atualizacao_nota_validacao
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
--                   Not�cias e Eventos
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_atualizacao_nota_validacao
@json nvarchar(max) = ''

--with encryption

as

--drop table AleJson
--select * from AleJson
--select cast(@json as nvarchar(max))  as ale into AleJson
--select 'ok' as msg

--set @json = isnull(@json,'')

--set @json = isnull(@json,'')

--select @json


--SET NOCOUNT ON;

-- 1) NÃO destrua o JSON
-- REMOVA qualquer linha como:
-- SET @json = REPLACE(@json, '\', '');

-- 2) Se vier como "string de JSON": "...."
--select @json

-- set @json = replace(
--              replace(
--                replace(
--                 replace(
--                   replace(
--                     replace(
--                       replace(
--                         replace(
--                           replace(
--                             replace(
--                               replace(
--                                 replace(
--                                   replace(
--                                     replace(
--                                     @json, CHAR(13), ' '),
--                                   CHAR(10),' '),
--                                 ' ',' '),
--                               ':\\\"',':\\"'),
--                             '\\\";','\\";'),
--                           ':\\"',':\\\"'),
--                         '\\";','\\\";'),
--                       '\\"','\"'),
--                     '\"', '"'),
--                   '',''),
--                 '["','['),
--               '"[','['),
--              ']"',']'),
--           '"]',']') 

-- 4) Validação

IF ISJSON(@json) <> 1
BEGIN
    THROW 50001, 'JSON inválido em @json.', 1;
    RETURN;
END


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
declare @ds_retorno          nvarchar(max) = ''
declare @ds_xml_nota         nvarchar(max) = ''
declare @cd_chave_acesso     varchar(60)   = ''
declare @ic_validada         char(1)       = 'N'
declare @dt_autorizacao      datetime 
declare @dt_auto_recebe      nvarchar(50)  = ''
declare @dt_validacao        datetime
declare @cd_protocolo_nfe    varchar(40)   = ''
declare @cd_nota_saida       int           = 0



----------------------------------------------------------------------------------------------------------------

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
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]                                      as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

--select * from #json

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_documento           = valor from #json where campo = 'cd_documento'
select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @ds_retorno             = valor from #json where campo = 'ds_retorno'             
select @ds_xml_nota            = valor from #json where campo = 'ds_xml_nota'             
select @cd_chave_acesso        = valor from #json where campo = 'cd_chave_acesso'             
select @ic_validada            = valor from #json where campo = 'ic_validada'             
select @dt_auto_recebe         = valor from #json where campo = 'dt_autorizacao'  
select @dt_validacao           = valor from #json where campo = 'dt_validacao'  
select @cd_protocolo_nfe       = valor from #json where campo = 'cd_protocolo_nfe'             
select @cd_nota_saida          = valor from #json where campo = 'cd_nota_saida'

--select @cd_protocolo_nfe

-------------------------------------------------------------------------------------------------------------------------------------
--  select 'passo i ' , @ds_xml_nota

set @ds_xml_nota = isnull(cast(@ds_xml_nota as nvarchar(max)),'')
set @cd_empresa  = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()


set @cd_documento = ISNULL(@cd_documento,0)

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    

set @cd_parametro = ISNULL(@cd_parametro,0)

--nota fiscal já validada-----------------------------------------------------------------------

--select @dt_autorizacao, @cd_protocolo_nfe, @ds_xml_nota

-------------------------------------------------------

if @cd_nota_saida > 0 and cast(@ds_xml_nota as nvarchar(max)) = '' and (@dt_autorizacao is null or isnull(@cd_protocolo_nfe,'')='')
begin

  select top 1 
     @ds_xml_nota      = isnull(cast(n.ds_xml_nota as nvarchar(max)),''),
     @cd_protocolo_nfe = n.cd_protocolo_nfe,
     @dt_autorizacao   = n.dt_autorizacao,
     @ds_retorno       = n.ds_retorno
     
  from
     nota_validacao n

  where 
     n.cd_nota_saida = @cd_nota_saida
     and
     cast(n.ds_xml_nota as nvarchar(max)) <> ''

  if @ds_xml_nota=''
  begin
     select top 1
       @cd_chave_acesso = substring(ns.cd_chave_acesso,4,44),
       @ds_xml_nota     = cast(d.ds_nota_xml_retorno as nvarchar(max))
     from
       nota_saida_documento d
       inner join nota_saida ns on ns.cd_nota_saida = d.cd_nota_saida
     where
       d.cd_nota_saida = @cd_nota_saida
       and
       cast(d.ds_nota_xml_retorno as nvarchar(max)) <> ''
  end

    --select @cd_nota_saida, @ds_xml_nota

end

---------------------------------------------------------------------------------------
--select 'passo - 0' , @ds_xml_nota

if ( @dt_autorizacao is null or isnull(@cd_protocolo_nfe,'')='' ) and @ds_xml_nota<>''
begin

  --select 'passo' , @ds_xml_nota

  DECLARE @x XML = TRY_CONVERT(XML, @ds_xml_nota);

  --select @x

  --IF @x IS NULL 
  --   set @x = cast(@ds_xml_nota as nvarchar(max))
 
  DECLARE 
    @cStatProt   INT,
    @chNFe       NVARCHAR(44),
    @dhRecbtoRaw NVARCHAR(40);

  --------------------------------------------------------------------------------
  -- 1) Tenta extrair quando o root é nfeProc (seu caso enviado)
  --------------------------------------------------------------------------------
;WITH XMLNAMESPACES (DEFAULT 'http://www.portalfiscal.inf.br/nfe')
SELECT
    @cStatProt         = @x.value('(/nfeProc/protNFe/infProt/cStat/text())[1]', 'int'),
    @cd_protocolo_nfe  = case when @cd_protocolo_nfe is null then
                         @x.value('(/nfeProc/protNFe/infProt/nProt/text())[1]','nvarchar(40)')
                         else
                           @cd_protocolo_nfe
                         end,
    @chNFe             = @x.value('(/nfeProc/protNFe/infProt/chNFe/text())[1]','nvarchar(44)'),
    @dhRecbtoRaw       = @x.value('(/nfeProc/protNFe/infProt/dhRecbto/text())[1]','nvarchar(40)');

--------------------------------------------------------------------------------
-- 2) Fallback: quando o retorno vem embrulhado em SOAP (retEnviNFe/retConsReci)
--------------------------------------------------------------------------------
IF @cd_protocolo_nfe IS NULL
BEGIN
    ;WITH XMLNAMESPACES (
        'http://www.portalfiscal.inf.br/nfe' AS nfe,
        'http://www.w3.org/2003/05/soap-envelope' AS soap
    )
    SELECT TOP (1)
        @cStatProt        = T.N.value('(nfe:cStat/text())[1]','int'),
        @cd_protocolo_nfe = T.N.value('(nfe:nProt/text())[1]','nvarchar(40)'),
        @chNFe            = T.N.value('(nfe:chNFe/text())[1]','nvarchar(44)'),
        @dhRecbtoRaw      = T.N.value('(nfe:dhRecbto/text())[1]','nvarchar(40)')
    FROM @x.nodes('//soap:Envelope/soap:Body//*[local-name()="infProt"]') AS T(N);
END

--------------------------------------------------------------------------------
-- 3) Converte dhRecbto (ex.: 2025-08-19T13:54:04-03:00) para datetime2
--------------------------------------------------------------------------------
DECLARE @dto DATETIMEOFFSET(0) = TRY_CONVERT(DATETIMEOFFSET(0), @dhRecbtoRaw);
--SET @dt_autorizacao  = CASE WHEN @dto IS NOT NULL THEN CAST(@dto AS DATETIME2(0)) END;
set @cd_chave_acesso = case when isnull(@chNFe,'')<>'' then @chNFe else @cd_chave_acesso end
-----------------------------

-- Converte de forma robusta para datetime2/datetime
IF (@dt_auto_recebe IS NOT NULL AND LTRIM(RTRIM(@dt_auto_recebe)) <> '')
BEGIN
    -- 1) ISO-8601 com fuso: 2025-08-19T13:54:04-03:00

    --select @dt_auto_recebe
    
    IF @dto IS NOT NULL
    BEGIN
        SET @dt_autorizacao = CAST(@dto AS DATETIME2(0)); -- ou DATETIME se sua coluna for datetime
    END
    ELSE
    BEGIN
       set @dt_auto_recebe = replace(@dt_auto_recebe,'\','')
       --
        -- 2) yyyy-mm-dd hh:mi:ss (121) ou dd/mm/yyyy (103)
        SET @dt_autorizacao =
            COALESCE(
                TRY_CONVERT(DATETIME2(0), @dt_auto_recebe, 121), -- 2025-08-19 13:54:04
                TRY_CONVERT(DATETIME2(0), @dt_auto_recebe, 126), -- 2025-08-19T13:54:04
                TRY_CONVERT(DATETIME2(0), @dt_auto_recebe, 103)  -- 19/08/2025 13:54:04
            );
    END

end

--------------------------------------------------------------------------------
-- 4) Atualiza se protocolo indica autorização/denegação e se achou a chave
--------------------------------------------------------------------------------
--select @cStatProt, @dt_autorizacao

IF (@cStatProt IN (100,150,110)) AND @chNFe IS NOT NULL
BEGIN
    UPDATE NV
       SET NV.cd_protocolo_nfe = COALESCE(@cd_protocolo_nfe, NV.cd_protocolo_nfe),
           NV.dt_autorizacao   = COALESCE(@dt_autorizacao  , NV.dt_autorizacao),
           NV.ic_validada      = 'S',
           NV.cd_chave_acesso  = COALESCE(@chNFe  , NV.cd_chave_acesso)
     FROM Nota_Validacao NV
     WHERE --NV.cd_chave_acesso = @chNFe;
       NV.cd_nota_saida = @cd_nota_saida
END



--select @dt_autorizacao, @cd_protocolo_nfe
  --   select @dt_autorizacao, @cd_protocolo_nfe


end

--select * from nota_saida_recibo

if ( @cd_parametro = 0 and cast(@ds_xml_nota as nvarchar(max))<>'' ) OR ( @cd_parametro = 9 )
begin

  --select @ds_xml_nota, @dt_autorizacao, @cd_protocolo_nfe

  update
    Nota_Validacao
  set
    cd_usuario              = @cd_usuario,
    dt_usuario              = GETDATE(),
    cd_status_validacao     = 2,  --select * from egissql.dbo.status_validacao 
    dt_validacao            = GETDATE(),
    ds_retorno              = @ds_retorno,
    ic_validada             = case when @dt_autorizacao is null then @ic_validada else 'S' end,
    ic_impresso             = 'N',
    dt_autorizacao          = @dt_autorizacao,
    cd_protocolo_nfe        = @cd_protocolo_nfe,
    ds_xml_nota             = @ds_xml_nota,
    cd_chave_acesso         = case when isnull(cd_chave_acesso,'')='' then @cd_chave_acesso else cd_chave_acesso end

  from
    nota_validacao n

  where
    n.cd_nota_saida           = @cd_nota_saida

  --Nota Saida--

  if @ds_xml_nota <> '' and @cd_protocolo_nfe<>''
  begin
    update
	  Nota_Saida
	set
	  ic_nfe_nota_saida = 'S'
    where
	  cd_nota_saida = @cd_nota_saida

  end

  --ic_nfe_nota_saida

  --Nota Saida Recibo----------------------------------------------------------------------------------------

  if @ds_xml_nota <> '' and @cd_protocolo_nfe<>''
  begin
    IF EXISTS (
       SELECT 1 FROM Nota_Saida_Recibo
       WHERE 
         cd_nota_saida = @cd_nota_saida
       )
    begin
      update
	      Nota_Saida_Recibo
	    set
  	    cd_protocolo_nfe    = @cd_protocolo_nfe,
        dt_autorizacao_nota = case when isnull(@dt_autorizacao,'') <> '' then @dt_autorizacao else @dt_validacao end
      WHERE 
        cd_nota_saida = @cd_nota_saida
   end
   else
   begin
	  insert into Nota_Saida_Recibo ( cd_nota_saida, cd_protocolo_nfe, dt_autorizacao_nota )
	  values
	  (@cd_nota_saida, @cd_protocolo_nfe, case when isnull(@dt_autorizacao,'') <> '' then @dt_autorizacao else @dt_validacao end )
	   
	end
 
  end


  --Nota Saida Documento-------------------------------------------------------------------------------------

  if @ds_xml_nota <> '' and @cd_protocolo_nfe<>''
  begin
    IF EXISTS (
       SELECT 1 FROM nota_saida_documento 
       WHERE 
         cd_nota_saida = @cd_nota_saida
       )
   BEGIN

    -- Atualiza se já existe

    UPDATE nota_saida_documento
    SET
      ds_nota_documento   = @ds_retorno,   --@ds_xml_nota
      ds_nota_xml_retorno = @ds_xml_nota,  --@ds_retorno, --@ds_xml_nota,	  
      dt_usuario          = GETDATE(),
      cd_usuario          = @cd_usuario
    WHERE
      --cd_nota_documento = @cd_nota_documento
       cd_nota_saida = @cd_nota_saida

  END
  ELSE
  BEGIN

    declare @cd_nota_documento int = 0
	declare @cd_tipo_documento int = 1

	select
	  @cd_nota_documento = MAX(cd_nota_documento) 
	from
	  Nota_Saida_Documento

    set @cd_nota_documento = isnull(@cd_nota_documento,0) + 1

    -- Insere novo registro
    INSERT INTO nota_saida_documento (
      cd_nota_documento,
      cd_nota_saida,
      cd_tipo_documento,
      ds_nota_documento,
      ds_nota_xml_retorno,
      cd_usuario,
      dt_usuario
    )
    VALUES (
      @cd_nota_documento,
      @cd_nota_saida,
      @cd_tipo_documento,
      @ds_retorno,
      @ds_xml_nota,
      @cd_usuario,
      GETDATE()
    );
  END
  end

  select 'Nota Atualizada : '+cast(@cd_nota_saida as varchar(20)) as Msg
  ------
end




---------------------------------------------------------------------------------------------------------------------------------------------------------    
go

--3796--

go
--use egissql_361
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_atualizacao_nota_validacao
------------------------------------------------------------------------------
go


--exec pr_egis_atualizacao_nota_validacao 
--'[{\"cd_parametro\":\"0\"},{\"cd_nota_saida\":\"45\"},{\"cd_empresa\":354},{\"ds_retorno\":\"<?xml version=\\\"1.0\\\" encoding=\\\"utf-8\\\"?><soap:Envelope xmlns:soap=\\\"http:\/\/www.w3.org\/2003\/05\/soap-envelope\\\" xmlns:xsi=\\\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\\\" xmlns:xsd=\\\"http:\/\/www.w3.org\/2001\/XMLSchema\\\"><soap:Body><nfeResultMsg xmlns=\\\"http:\/\/www.portalfiscal.inf.br\/nfe\/wsdl\/NFeAutorizacao4\\\"><retEnviNFe xmlns=\\\"http:\/\/www.portalfiscal.inf.br\/nfe\\\" versao=\\\"4.00\\\"><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENW_v7.0.1<\/verAplic><cStat>104<\/cStat><xMotivo>Lote processado<\/xMotivo><cUF>29<\/cUF><dhRecbto>2025-08-20T17:47:17-03:00<\/dhRecbto><protNFe versao=\\\"4.00\\\"><infProt><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENP_v7.0.1<\/verAplic><chNFe>29250827677562000120550010000007381000000455<\/chNFe><dhRecbto>2025-08-20T17:47:17-03:00<\/dhRecbto><nProt>129251006621610<\/nProt><digVal>8L3stoa+zwLm8ZvhDHA7UfbNZPY=<\/digVal><cStat>100<\/cStat><xMotivo>Autorizado o uso da NF-e<\/xMotivo><\/infProt><\/protNFe><\/retEnviNFe><\/nfeResultMsg><\/soap:Body><\/soap:Envelope>\"},{\"ds_xml_nota\":\"<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?><nfeProc versao=\\\"4.00\\\" xmlns=\\\"http:\/\/www.portalfiscal.inf.br\/nfe\\\"><NFe xmlns=\\\"http:\/\/www.portalfiscal.inf.br\/nfe\\\"><infNFe Id=\\\"NFe29250827677562000120550010000007381000000455\\\" versao=\\\"4.00\\\"><ide><cUF>29<\/cUF><cNF>00000045<\/cNF><natOp>VENDAS DE PRODUCAO ESTABELECIMENTO<\/natOp><mod>55<\/mod><serie>1<\/serie><nNF>738<\/nNF><dhEmi>2025-08-20T17:47:17-03:00<\/dhEmi><dhSaiEnt>2025-08-21T17:47:17-03:00<\/dhSaiEnt><tpNF>1<\/tpNF><idDest>1<\/idDest><cMunFG>2932903<\/cMunFG><tpImp>1<\/tpImp><tpEmis>1<\/tpEmis><cDV>5<\/cDV><tpAmb>2<\/tpAmb><finNFe>1<\/finNFe><indFinal>0<\/indFinal><indPres>1<\/indPres><indIntermed>0<\/indIntermed><procEmi>0<\/procEmi><verProc>1.2.3<\/verProc><\/ide><emit><CNPJ>27677562000120<\/CNPJ><xNome>FABRICA ACAI PAREAKI LTDA<\/xNome><xFant>PAREAKI<\/xFant><enderEmit><xLgr>RUA ALGUIDAR<\/xLgr><nro>SN<\/nro><xBairro>JAQUEIRA<\/xBairro><cMun>2932903<\/cMun><xMun>VALENCA<\/xMun><UF>BA<\/UF><CEP>45400000<\/CEP><cPais>1058<\/cPais><xPais>Brasil<\/xPais><fone>75982695609<\/fone><\/enderEmit><IE>140346417<\/IE><IM>000000000000000<\/IM><CRT>1<\/CRT><\/emit><dest><CNPJ>35990338000112<\/CNPJ><xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL<\/xNome><enderDest><xLgr>RUA PEDRO LONGO<\/xLgr><nro>341<\/nro><xBairro>PITUBA<\/xBairro><cMun>2914901<\/cMun><xMun>ITACARE<\/xMun><UF>BA<\/UF><CEP>45530000<\/CEP><cPais>1058<\/cPais><xPais>Brasil<\/xPais><fone>7399173704<\/fone><\/enderDest><indIEDest>1<\/indIEDest><IE>164550543<\/IE><\/dest><autXML><CNPJ>13352975000120<\/CNPJ><\/autXML><det nItem=\\\"1\\\"><prod><cProd>PRD00006<\/cProd><cEAN>SEM GTIN<\/cEAN><xProd>ACAI BANANA 10LT<\/xProd><NCM>21069090<\/NCM><CFOP>5101<\/CFOP><uCom>UN<\/uCom><qCom>1.0000<\/qCom><vUnCom>145.0000000000<\/vUnCom><vProd>145.00<\/vProd><cEANTrib>SEM GTIN<\/cEANTrib><uTrib>UN<\/uTrib><qTrib>1.0000<\/qTrib><vUnTrib>145.0000000000<\/vUnTrib><indTot>1<\/indTot><xPed>Web<\/xPed><nItemPed>0<\/nItemPed><\/prod><imposto><vTotTrib>145.00<\/vTotTrib><ICMS><ICMSSN101><orig>0<\/orig><CSOSN>101<\/CSOSN><pCredSN>1.25<\/pCredSN><vCredICMSSN>1.81<\/vCredICMSSN><\/ICMSSN101><\/ICMS><PIS><PISOutr><CST>49<\/CST><vBC>0.00<\/vBC><pPIS>0.0000<\/pPIS><vPIS>0.00<\/vPIS><\/PISOutr><\/PIS><COFINS><COFINSOutr><CST>49<\/CST><vBC>0.00<\/vBC><pCOFINS>0.0000<\/pCOFINS><vCOFINS>0.00<\/vCOFINS><\/COFINSOutr><\/COFINS><\/imposto><\/det><det nItem=\\\"2\\\"><prod><cProd>PRD00002<\/cProd><cEAN>SEM GTIN<\/cEAN><xProd>ACAI PURO 10LT<\/xProd><NCM>21069090<\/NCM><CFOP>5101<\/CFOP><uCom>UN<\/uCom><qCom>1.0000<\/qCom><vUnCom>145.0000000000<\/vUnCom><vProd>145.00<\/vProd><cEANTrib>SEM GTIN<\/cEANTrib><uTrib>UN<\/uTrib><qTrib>1.0000<\/qTrib><vUnTrib>145.0000000000<\/vUnTrib><indTot>1<\/indTot><xPed>Web<\/xPed><nItemPed>0<\/nItemPed><\/prod><imposto><vTotTrib>145.00<\/vTotTrib><ICMS><ICMSSN101><orig>0<\/orig><CSOSN>101<\/CSOSN><pCredSN>1.25<\/pCredSN><vCredICMSSN>1.81<\/vCredICMSSN><\/ICMSSN101><\/ICMS><PIS><PISOutr><CST>49<\/CST><vBC>0.00<\/vBC><pPIS>0.0000<\/pPIS><vPIS>0.00<\/vPIS><\/PISOutr><\/PIS><COFINS><COFINSOutr><CST>49<\/CST><vBC>0.00<\/vBC><pCOFINS>0.0000<\/pCOFINS><vCOFINS>0.00<\/vCOFINS><\/COFINSOutr><\/COFINS><\/imposto><\/det><det nItem=\\\"3\\\"><prod><cProd>PRD00041<\/cProd><cEAN>SEM GTIN<\/cEAN><xProd>CREME CUPUACU 10LT<\/xProd><NCM>21050010<\/NCM><CFOP>5101<\/CFOP><uCom>UN<\/uCom><qCom>1.0000<\/qCom><vUnCom>115.0000000000<\/vUnCom><vProd>115.00<\/vProd><cEANTrib>SEM GTIN<\/cEANTrib><uTrib>UN<\/uTrib><qTrib>1.0000<\/qTrib><vUnTrib>115.0000000000<\/vUnTrib><indTot>1<\/indTot><xPed>Web<\/xPed><nItemPed>0<\/nItemPed><\/prod><imposto><vTotTrib>115.00<\/vTotTrib><ICMS><ICMSSN101><orig>0<\/orig><CSOSN>101<\/CSOSN><pCredSN>1.25<\/pCredSN><vCredICMSSN>1.44<\/vCredICMSSN><\/ICMSSN101><\/ICMS><PIS><PISOutr><CST>49<\/CST><vBC>0.00<\/vBC><pPIS>0.0000<\/pPIS><vPIS>0.00<\/vPIS><\/PISOutr><\/PIS><COFINS><COFINSOutr><CST>49<\/CST><vBC>0.00<\/vBC><pCOFINS>0.0000<\/pCOFINS><vCOFINS>0.00<\/vCOFINS><\/COFINSOutr><\/COFINS><\/imposto><\/det><total><ICMSTot><vBC>0.00<\/vBC><vICMS>0.00<\/vICMS><vICMSDeson>0.00<\/vICMSDeson><vFCP>0.00<\/vFCP><vBCST>0.00<\/vBCST><vST>0.00<\/vST><vFCPST>0.00<\/vFCPST><vFCPSTRet>0.00<\/vFCPSTRet><vProd>405.00<\/vProd><vFrete>0.00<\/vFrete><vSeg>0.00<\/vSeg><vDesc>0.00<\/vDesc><vII>0.00<\/vII><vIPI>0.00<\/vIPI><vIPIDevol>0.00<\/vIPIDevol><vPIS>0.00<\/vPIS><vCOFINS>0.00<\/vCOFINS><vOutro>0.00<\/vOutro><vNF>405.00<\/vNF><vTotTrib>405.00<\/vTotTrib><\/ICMSTot><\/total><transp><modFrete>3<\/modFrete><transporta><CNPJ>27677562000120<\/CNPJ><xNome>NOSSO CARRO<\/xNome><IE>140346417<\/IE><xEnder>Rua Alguidar-SN JAQUEIRA<\/xEnder><xMun>VALENCA<\/xMun><UF>BA<\/UF><\/transporta><veicTransp><placa>XXX9999<\/placa><\/veicTransp><\/transp><cobr><fat><nFat>07 DIAS<\/nFat><vOrig>405.00<\/vOrig><vDesc>0.00<\/vDesc><vLiq>405.00<\/vLiq><\/fat><dup><nDup>001<\/nDup><dVenc>2025-08-28<\/dVenc><vDup>405.00<\/vDup><\/dup><\/cobr><pag><detPag><indPag>1<\/indPag><tPag>14<\/tPag><vPag>405.00<\/vPag><\/detPag><\/pag><infAdic><infCpl>Vendedor: VANDERLEICodigo do Cliente: 1DARIO ITACARE ** CONFIRA SEU PEDIDO NO ATO DA ENTREGA, NAO ACEITAMOS RECLAMACOES POSTERIORES APOS A DATA DO RECEBIMENTO **Pedido(s) de Venda: 50Pedido de Compra<\/infCpl><\/infAdic><infRespTec><CNPJ>16875807000108<\/CNPJ><xContato>GBS TECNOLOGIA E CONSULTORIA LTDA<\/xContato><email>financeiro@gbstec.com.br<\/email><fone>39074141<\/fone><\/infRespTec><\/infNFe><Signature xmlns=\\\"http:\/\/www.w3.org\/2000\/09\/xmldsig#\\\"><SignedInfo><CanonicalizationMethod Algorithm=\\\"http:\/\/www.w3.org\/TR\/2001\/REC-xml-c14n-20010315\\\"\/><SignatureMethod Algorithm=\\\"http:\/\/www.w3.org\/2000\/09\/xmldsig#rsa-sha1\\\"\/><Reference URI=\\\"#NFe29250827677562000120550010000007381000000455\\\"><Transforms><Transform Algorithm=\\\"http:\/\/www.w3.org\/2000\/09\/xmldsig#enveloped-signature\\\"\/><Transform Algorithm=\\\"http:\/\/www.w3.org\/TR\/2001\/REC-xml-c14n-20010315\\\"\/><\/Transforms><DigestMethod Algorithm=\\\"http:\/\/www.w3.org\/2000\/09\/xmldsig#sha1\\\"\/><DigestValue>8L3stoa+zwLm8ZvhDHA7UfbNZPY=<\/DigestValue><\/Reference><\/SignedInfo><SignatureValue>a8jII+nb13c8ZHkZk\/DF+je6AOr+Fj4yfDaDMZTgzcPxan3Yhz\/PwG8eewkqSu1elm5P8OhyjtyCMg+5g9fOZFAEHYDYPCpWYaLRoiy9gQisLlsFbgkNvL97XpK14px0FzbHdL\/6WXtSQ19SovoneIGK+o\/UAjmpX9U88IswXo8zgCdtWFBs2M6NBRRDgPVpDbdN42WJjr+F5J0E9nlwiRQqMHohYrOQyLq+vgtrU7SGMINRxDEKWYgypa0BBLHXiIrZm7CdIHDJ+O2cR91pZMKM\/X4Y2C+1iwc30\/TzGFQa67PjD4iAcgbQUqXUHSEusQx0I+eLqVunULuUFuOCfA==<\/SignatureValue><KeyInfo><X509Data><X509Certificate>MIIHSDCCBTCgAwIBAgIIRXwlAwZwjDIwDQYJKoZIhvcNAQELBQAwWTELMAkGA1UEBhMCQlIxEzARBgNVBAoTCklDUC1CcmFzaWwxFTATBgNVBAsTDEFDIFNPTFVUSSB2NTEeMBwGA1UEAxMVQUMgU09MVVRJIE11bHRpcGxhIHY1MB4XDTI1MDMwNzEyMzUwMFoXDTI2MDMwNzEyMzUwMFowgeQxCzAJBgNVBAYTAkJSMRMwEQYDVQQKEwpJQ1AtQnJhc2lsMQswCQYDVQQIEwJCQTEQMA4GA1UEBxMHVmFsZW5jYTEeMBwGA1UECxMVQUMgU09MVVRJIE11bHRpcGxhIHY1MRcwFQYDVQQLEw4zMjQ2NzMyOTAwMDE1MzEZMBcGA1UECxMQVmlkZW9jb25mZXJlbmNpYTEaMBgGA1UECxMRQ2VydGlmaWNhZG8gUEogQTExMTAvBgNVBAMTKEZBQlJJQ0EgQUNBSSBQQVJFQUtJIExUREE6Mjc2Nzc1NjIwMDAxMjAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCc66I4vGk5wrZveTubKmrZV0J7RnGqn8YHxgHp7Cz50tHHtrbhzAiOKOrsKStfVsPTOyCnNZ6C7xJLEu8UiAbMdLRFOh+JrVRkZDQpIhj3Bf\/unRJmMA7jVCWLR6jb2p0N9rLxTCVj2EfLEr\/iB+yiNuAxYHq5aRBBfBUNqfsDXmrijmAXjxVpUxYd94GjO+8HfScs61FccSHhIxkim76TN5YJvWxSn5seWsRWUHjk\/bLtdlchSM58nm2\/51YbjfkRvHzuT6Xzv2on+6D4cC0n9VVNGiwUcAU7cBWjzOWuBvz13KWAb3jnNwsoeI+qt6zjXuePRSy6CCuw7wUS+0qbAgMBAAGjggKGMIICgjAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFMVS7SWACd+cgsifR8bdtF8x3bmxMFQGCCsGAQUFBwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL2NjZC5hY3NvbHV0aS5jb20uYnIvbGNyL2FjLXNvbHV0aS1tdWx0aXBsYS12NS5wN2IwgcEGA1UdEQSBuTCBtoEXYW5zZWxtb2VqYW5heUBnbWFpbC5jb22gKAYFYEwBAwKgHxMdQU5TRUxNTyBOQVNDSU1FTlRPIERPUyBTQU5UT1OgGQYFYEwBAwOgEBMOMjc2Nzc1NjIwMDAxMjCgPQYFYEwBAwSgNBMyMTEwMjE5OTMwNTcyOTIxMjUwMDAwMDAwMDAwMDAwMDAwMDAxNTk4NDEwMTEzc3NwYmGgFwYFYEwBAwegDhMMMDAwMDAwMDAwMDAwMF0GA1UdIARWMFQwUgYGYEwBAgEmMEgwRgYIKwYBBQUHAgEWOmh0dHA6Ly9jY2QuYWNzb2x1dGkuY29tLmJyL2RvY3MvZHBjLWFjLXNvbHV0aS1tdWx0aXBsYS5wZGYwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMIGMBgNVHR8EgYQwgYEwPqA8oDqGOGh0dHA6Ly9jY2QuYWNzb2x1dGkuY29tLmJyL2xjci9hYy1zb2x1dGktbXVsdGlwbGEtdjUuY3JsMD+gPaA7hjlodHRwOi8vY2NkMi5hY3NvbHV0aS5jb20uYnIvbGNyL2FjLXNvbHV0aS1tdWx0aXBsYS12NS5jcmwwHQYDVR0OBBYEFJW47Jff7X2v9nCgWUIBd6ZQlvyZMA4GA1UdDwEB\/wQEAwIF4DANBgkqhkiG9w0BAQsFAAOCAgEAOkOLkXpspXFAB8tcxVnPJzrl+ykVCUBk\/nMsrssrBmplQTF5RP5Fjx8Sh2+91fLlvximTzUnDBnkvrRTeWLcI3qDUAZt6wkQkTdyRIEdkVPn2x7+V0L09wsBbzbIPL5EBh0+pwtYU0TMLJHNcmFumbJEY88\/EtjRXHpfi3Sxsm4xRExHLBAbfGMNUMwoMRwJVuPhcJX4GgxJ8f+QK2tThktaYF\/jRM0JGUSiolohMQvmq\/jcL8SLx6X6jRGr20ALR5XzCzOci69Vc1\/wx+9YuKEMBoW4J7nXWzC67+bU8u21vqi7udyWfAyY6Veqqd0wnC+K2JbrgRtnO7SY5dIeIt\/ao6prMAzvwUyOUfCDV2Xdz7Ou55DpGMHq+\/BShh1hEcyKy+pRh5ifcMiIZrajffoBGJIVP97qulrc8rTeUY\/ENPRYFBFC3EdB2yl3hu46zn6vwrtiCGbrqEznP04p\/d3jnDEdLzCttFsmRuLtuqfdXeR\/fvO5OKc+o7gbXVO2qerHOF\/SYTJnU7BMUGLTGYNVMfcoBckM+QStcF7QmGJW659kkesxZVu56tj0d\/0zWxAiwcT6KjVNqfz7LHmSuJvxrlNL89FEnpZCB5LI\/\/+5AjM7DUI2vt6G0jr2AxgaXCAtKbvSfkHADVH+BVzrJE82hHAt2DD7RMVD5FmYkFU=<\/X509Certificate><\/X509Data><\/KeyInfo><\/Signature><\/NFe><protNFe versao=\\\"4.00\\\"><infProt><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENP_v7.0.1<\/verAplic><chNFe>29250827677562000120550010000007381000000455<\/chNFe><dhRecbto>2025-08-20T17:47:17-03:00<\/dhRecbto><nProt>129251006621610<\/nProt><digVal>8L3stoa+zwLm8ZvhDHA7UfbNZPY=<\/digVal><cStat>100<\/cStat><xMotivo>Autorizado o uso da NF-e<\/xMotivo><\/infProt><\/protNFe><\/nfeProc>\"},{\"cd_chave_acesso\":\"29250827677562000120550010000007381000000455\"},{\"ic_validada\":\"S\"},{\"dt_autorizacao\":\"20\/08\/2025 17:47:17\"},{\"cd_protocolo_nfe\":\"129251006621610\"},{\"ic_json_parametro\":\"S\"}]
--'
--'[{\"cd_parametro\":\"0\"},{\"cd_nota_saida\":\"42\"},{\"cd_empresa\":354},
--{\"ds_retorno\":\"<?xml version=\\\"1.0\\\" encoding=\\\"utf-8\\\"?><soap:Envelope xmlns:soap=\\\"http:\/\/www.w3.org\/2003\/05\/soap-envelope\\\" xmlns:xsi=\\\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\\\" xmlns:xsd=\\\"http:\/\/www.w3.org\/2001\/XMLSchema\\\"><soap:Body><nfeResultMsg xmlns=\\\"http:\/\/www.portalfiscal.inf.br\/nfe\/wsdl\/NFeAutorizacao4\\\"><retEnviNFe xmlns=\\\"http:\/\/www.portalfiscal.inf.br\/nfe\\\" versao=\\\"4.00\\\"><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENW_v7.0.1<\/verAplic><cStat>104<\/cStat><xMotivo>Lote processado<\/xMotivo><cUF>29<\/cUF><dhRecbto>2025-08-20T16:55:08-03:00<\/dhRecbto><protNFe versao=\\\"4.00\\\"><infProt><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENP_v7.0.1<\/verAplic><chNFe>29250827677562000120550010000007351000000429<\/chNFe><dhRecbto>2025-08-20T16:55:08-03:00<\/dhRecbto><nProt>129251006621538<\/nProt><digVal>+m+j+9ciVinfw3Eav25FYQFxEow=<\/digVal><cStat>100<\/cStat><xMotivo>Autorizado o uso da NF-e<\/xMotivo><\/infProt><\/protNFe><\/retEnviNFe><\/nfeResultMsg><\/soap:Body><\/soap:Envelope>\"},{\"ds_xml_nota\":\"<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?><nfeProc versao=\\\"4.00\\\" xmlns=\\\"http:\/\/www.portalfiscal.inf.br\/nfe\\\"><NFe xmlns=\\\"http:\/\/www.portalfiscal.inf.br\/nfe\\\"><infNFe Id=\\\"NFe29250827677562000120550010000007351000000429\\\" versao=\\\"4.00\\\"><ide><cUF>29<\/cUF><cNF>00000042<\/cNF><natOp>VENDAS DE PRODUCAO ESTABELECIMENTO<\/natOp><mod>55<\/mod><serie>1<\/serie><nNF>735<\/nNF><dhEmi>2025-08-20T16:55:07-03:00<\/dhEmi><dhSaiEnt>2025-08-21T16:55:07-03:00<\/dhSaiEnt><tpNF>1<\/tpNF><idDest>1<\/idDest><cMunFG>2932903<\/cMunFG><tpImp>1<\/tpImp><tpEmis>1<\/tpEmis><cDV>9<\/cDV><tpAmb>2<\/tpAmb><finNFe>1<\/finNFe><indFinal>0<\/indFinal><indPres>1<\/indPres><indIntermed>0<\/indIntermed><procEmi>0<\/procEmi><verProc>1.2.3<\/verProc><\/ide><emit><CNPJ>27677562000120<\/CNPJ><xNome>FABRICA ACAI PAREAKI LTDA<\/xNome><xFant>PAREAKI<\/xFant><enderEmit><xLgr>RUA ALGUIDAR<\/xLgr><nro>SN<\/nro><xBairro>JAQUEIRA<\/xBairro><cMun>2932903<\/cMun><xMun>VALENCA<\/xMun><UF>BA<\/UF><CEP>45400000<\/CEP><cPais>1058<\/cPais><xPais>Brasil<\/xPais><fone>75982695609<\/fone><\/enderEmit><IE>140346417<\/IE><IM>000000000000000<\/IM><CRT>1<\/CRT><\/emit><dest><CNPJ>35990338000112<\/CNPJ><xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL<\/xNome><enderDest><xLgr>RUA PEDRO LONGO<\/xLgr><nro>341<\/nro><xBairro>PITUBA<\/xBairro><cMun>2914901<\/cMun><xMun>ITACARE<\/xMun><UF>BA<\/UF><CEP>45530000<\/CEP><cPais>1058<\/cPais><xPais>Brasil<\/xPais><fone>7399173704<\/fone><\/enderDest><indIEDest>1<\/indIEDest><IE>164550543<\/IE><\/dest><autXML><CNPJ>13352975000120<\/CNPJ><\/autXML><det nItem=\\\"1\\\"><prod><cProd>PRD00032<\/cProd><cEAN>SEM GTIN<\/cEAN><xProd>SORVETE COCO 10LT<\/xProd><NCM>21050010<\/NCM><CFOP>5101<\/CFOP><uCom>UN<\/uCom><qCom>2.0000<\/qCom><vUnCom>115.0000000000<\/vUnCom><vProd>230.00<\/vProd><cEANTrib>SEM GTIN<\/cEANTrib><uTrib>UN<\/uTrib><qTrib>2.0000<\/qTrib><vUnTrib>115.0000000000<\/vUnTrib><indTot>1<\/indTot><xPed>Web<\/xPed><nItemPed>0<\/nItemPed><\/prod><imposto><vTotTrib>230.00<\/vTotTrib><ICMS><ICMSSN101><orig>0<\/orig><CSOSN>101<\/CSOSN><pCredSN>1.25<\/pCredSN><vCredICMSSN>2.88<\/vCredICMSSN><\/ICMSSN101><\/ICMS><PIS><PISOutr><CST>49<\/CST><vBC>0.00<\/vBC><pPIS>0.0000<\/pPIS><vPIS>0.00<\/vPIS><\/PISOutr><\/PIS><COFINS><COFINSOutr><CST>49<\/CST><vBC>0.00<\/vBC><pCOFINS>0.0000<\/pCOFINS><vCOFINS>0.00<\/vCOFINS><\/COFINSOutr><\/COFINS><\/imposto><\/det><total><ICMSTot><vBC>0.00<\/vBC><vICMS>0.00<\/vICMS><vICMSDeson>0.00<\/vICMSDeson><vFCP>0.00<\/vFCP><vBCST>0.00<\/vBCST><vST>0.00<\/vST><vFCPST>0.00<\/vFCPST><vFCPSTRet>0.00<\/vFCPSTRet><vProd>230.00<\/vProd><vFrete>0.00<\/vFrete><vSeg>0.00<\/vSeg><vDesc>0.00<\/vDesc><vII>0.00<\/vII><vIPI>0.00<\/vIPI><vIPIDevol>0.00<\/vIPIDevol><vPIS>0.00<\/vPIS><vCOFINS>0.00<\/vCOFINS><vOutro>0.00<\/vOutro><vNF>230.00<\/vNF><vTotTrib>230.00<\/vTotTrib><\/ICMSTot><\/total><transp><modFrete>3<\/modFrete><transporta><CNPJ>27677562000120<\/CNPJ><xNome>NOSSO CARRO<\/xNome><IE>140346417<\/IE><xEnder>Rua Alguidar-SN JAQUEIRA<\/xEnder><xMun>VALENCA<\/xMun><UF>BA<\/UF><\/transporta><veicTransp><placa>XXX9999<\/placa><\/veicTransp><\/transp><cobr><fat><nFat>07 DIAS<\/nFat><vOrig>230.00<\/vOrig><vDesc>0.00<\/vDesc><vLiq>230.00<\/vLiq><\/fat><dup><nDup>001<\/nDup><dVenc>2025-08-28<\/dVenc><vDup>230.00<\/vDup><\/dup><\/cobr><pag><detPag><indPag>1<\/indPag><tPag>14<\/tPag><vPag>230.00<\/vPag><\/detPag><\/pag><infAdic><infCpl>Vendedor: VANDERLEICodigo do Cliente: 1DARIO ITACARE ** CONFIRA SEU PEDIDO NO ATO DA ENTREGA, NAO ACEITAMOS RECLAMACOES POSTERIORES APOS A DATA DO RECEBIMENTO **Pedido(s) de Venda: 44Pedido de Compra<\/infCpl><\/infAdic><infRespTec><CNPJ>16875807000108<\/CNPJ><xContato>GBS TECNOLOGIA E CONSULTORIA LTDA<\/xContato><email>financeiro@gbstec.com.br<\/email><fone>39074141<\/fone><\/infRespTec><\/infNFe><Signature xmlns=\\\"http:\/\/www.w3.org\/2000\/09\/xmldsig#\\\"><SignedInfo><CanonicalizationMethod Algorithm=\\\"http:\/\/www.w3.org\/TR\/2001\/REC-xml-c14n-20010315\\\"\/><SignatureMethod Algorithm=\\\"http:\/\/www.w3.org\/2000\/09\/xmldsig#rsa-sha1\\\"\/><Reference URI=\\\"#NFe29250827677562000120550010000007351000000429\\\"><Transforms><Transform Algorithm=\\\"http:\/\/www.w3.org\/2000\/09\/xmldsig#enveloped-signature\\\"\/><Transform Algorithm=\\\"http:\/\/www.w3.org\/TR\/2001\/REC-xml-c14n-20010315\\\"\/><\/Transforms><DigestMethod Algorithm=\\\"http:\/\/www.w3.org\/2000\/09\/xmldsig#sha1\\\"\/><DigestValue>+m+j+9ciVinfw3Eav25FYQFxEow=<\/DigestValue><\/Reference><\/SignedInfo><SignatureValue>XbItdN1w8Wmj+NLFI9nUUWPzl09zq4H3T0Zc1vXRpCYZoLH7EFWRv+3WaYmV4iWMoNtPs8DZnQKN3PEjpRRxxAAG5ikFsUjN0cJF1OcFEIkw1NPiSbsqntwgb57uN+zkOsC\/Hqhh+A92f79GBrSXquZv+H96yXOVvt\/sd3EiEyxMn+GDjFuHAtAQLH8WSJ9v3BnoFZXuoMZtnRR\/Y750czmPNnDc56Qij3xMM17hEkEF1sopuFmRGR7FjcNCJTU0VQTSChLPmygIMT1UyLDvab19HtXHFVuUF9cZcOGjjUK01YHyK+m7alwNf5f3RacPfajCq5dQbwLLia29MgIpdg==<\/SignatureValue><KeyInfo><X509Data><X509Certificate>MIIHSDCCBTCgAwIBAgIIRXwlAwZwjDIwDQYJKoZIhvcNAQELBQAwWTELMAkGA1UEBhMCQlIxEzARBgNVBAoTCklDUC1CcmFzaWwxFTATBgNVBAsTDEFDIFNPTFVUSSB2NTEeMBwGA1UEAxMVQUMgU09MVVRJIE11bHRpcGxhIHY1MB4XDTI1MDMwNzEyMzUwMFoXDTI2MDMwNzEyMzUwMFowgeQxCzAJBgNVBAYTAkJSMRMwEQYDVQQKEwpJQ1AtQnJhc2lsMQswCQYDVQQIEwJCQTEQMA4GA1UEBxMHVmFsZW5jYTEeMBwGA1UECxMVQUMgU09MVVRJIE11bHRpcGxhIHY1MRcwFQYDVQQLEw4zMjQ2NzMyOTAwMDE1MzEZMBcGA1UECxMQVmlkZW9jb25mZXJlbmNpYTEaMBgGA1UECxMRQ2VydGlmaWNhZG8gUEogQTExMTAvBgNVBAMTKEZBQlJJQ0EgQUNBSSBQQVJFQUtJIExUREE6Mjc2Nzc1NjIwMDAxMjAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCc66I4vGk5wrZveTubKmrZV0J7RnGqn8YHxgHp7Cz50tHHtrbhzAiOKOrsKStfVsPTOyCnNZ6C7xJLEu8UiAbMdLRFOh+JrVRkZDQpIhj3Bf\/unRJmMA7jVCWLR6jb2p0N9rLxTCVj2EfLEr\/iB+yiNuAxYHq5aRBBfBUNqfsDXmrijmAXjxVpUxYd94GjO+8HfScs61FccSHhIxkim76TN5YJvWxSn5seWsRWUHjk\/bLtdlchSM58nm2\/51YbjfkRvHzuT6Xzv2on+6D4cC0n9VVNGiwUcAU7cBWjzOWuBvz13KWAb3jnNwsoeI+qt6zjXuePRSy6CCuw7wUS+0qbAgMBAAGjggKGMIICgjAJBgNVHRMEAjAAMB8GA1UdIwQYMBaAFMVS7SWACd+cgsifR8bdtF8x3bmxMFQGCCsGAQUFBwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL2NjZC5hY3NvbHV0aS5jb20uYnIvbGNyL2FjLXNvbHV0aS1tdWx0aXBsYS12NS5wN2IwgcEGA1UdEQSBuTCBtoEXYW5zZWxtb2VqYW5heUBnbWFpbC5jb22gKAYFYEwBAwKgHxMdQU5TRUxNTyBOQVNDSU1FTlRPIERPUyBTQU5UT1OgGQYFYEwBAwOgEBMOMjc2Nzc1NjIwMDAxMjCgPQYFYEwBAwSgNBMyMTEwMjE5OTMwNTcyOTIxMjUwMDAwMDAwMDAwMDAwMDAwMDAxNTk4NDEwMTEzc3NwYmGgFwYFYEwBAwegDhMMMDAwMDAwMDAwMDAwMF0GA1UdIARWMFQwUgYGYEwBAgEmMEgwRgYIKwYBBQUHAgEWOmh0dHA6Ly9jY2QuYWNzb2x1dGkuY29tLmJyL2RvY3MvZHBjLWFjLXNvbHV0aS1tdWx0aXBsYS5wZGYwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMIGMBgNVHR8EgYQwgYEwPqA8oDqGOGh0dHA6Ly9jY2QuYWNzb2x1dGkuY29tLmJyL2xjci9hYy1zb2x1dGktbXVsdGlwbGEtdjUuY3JsMD+gPaA7hjlodHRwOi8vY2NkMi5hY3NvbHV0aS5jb20uYnIvbGNyL2FjLXNvbHV0aS1tdWx0aXBsYS12NS5jcmwwHQYDVR0OBBYEFJW47Jff7X2v9nCgWUIBd6ZQlvyZMA4GA1UdDwEB\/wQEAwIF4DANBgkqhkiG9w0BAQsFAAOCAgEAOkOLkXpspXFAB8tcxVnPJzrl+ykVCUBk\/nMsrssrBmplQTF5RP5Fjx8Sh2+91fLlvximTzUnDBnkvrRTeWLcI3qDUAZt6wkQkTdyRIEdkVPn2x7+V0L09wsBbzbIPL5EBh0+pwtYU0TMLJHNcmFumbJEY88\/EtjRXHpfi3Sxsm4xRExHLBAbfGMNUMwoMRwJVuPhcJX4GgxJ8f+QK2tThktaYF\/jRM0JGUSiolohMQvmq\/jcL8SLx6X6jRGr20ALR5XzCzOci69Vc1\/wx+9YuKEMBoW4J7nXWzC67+bU8u21vqi7udyWfAyY6Veqqd0wnC+K2JbrgRtnO7SY5dIeIt\/ao6prMAzvwUyOUfCDV2Xdz7Ou55DpGMHq+\/BShh1hEcyKy+pRh5ifcMiIZrajffoBGJIVP97qulrc8rTeUY\/ENPRYFBFC3EdB2yl3hu46zn6vwrtiCGbrqEznP04p\/d3jnDEdLzCttFsmRuLtuqfdXeR\/fvO5OKc+o7gbXVO2qerHOF\/SYTJnU7BMUGLTGYNVMfcoBckM+QStcF7QmGJW659kkesxZVu56tj0d\/0zWxAiwcT6KjVNqfz7LHmSuJvxrlNL89FEnpZCB5LI\/\/+5AjM7DUI2vt6G0jr2AxgaXCAtKbvSfkHADVH+BVzrJE82hHAt2DD7RMVD5FmYkFU=<\/X509Certificate><\/X509Data><\/KeyInfo><\/Signature><\/NFe><protNFe versao=\\\"4.00\\\"><infProt><tpAmb>2<\/tpAmb><verAplic>SEFAZBA_NFENP_v7.0.1<\/verAplic><chNFe>29250827677562000120550010000007351000000429<\/chNFe><dhRecbto>2025-08-20T16:55:08-03:00<\/dhRecbto><nProt>129251006621538<\/nProt><digVal>+m+j+9ciVinfw3Eav25FYQFxEow=<\/digVal><cStat>100<\/cStat><xMotivo>Autorizado o uso da NF-e<\/xMotivo><\/infProt><\/protNFe><\/nfeProc>\"},{\"cd_chave_acesso\":\"29250827677562000120550010000007351000000429\"},{\"ic_validada\":\"S\"},{\"dt_autorizacao\":\"20\/08\/2025 16:55:08\"},{\"cd_protocolo_nfe\":\"129251006621538\"},{\"ic_json_parametro\":\"S\"}]'


/*
select * from nota_saida_documento where cd_nota_saida = 3799
select * from nota_saida_recibo    where cd_nota_saida = 3799
select * from nota_validacao       where cd_nota_saida = 3799                            
*/

go

------------------------------------------------------------------------------
GO

--DECLARE @json NVARCHAR(MAX) = '
--[
--    {
--        "cd_parametro": "0"
--    },
--    {
--        "cd_nota_saida": ""
--    },
--    {
--        "cd_empresa": 319
--    },
--    {
--        "ds_retorno": "Rejeição: Duplicidade de NF-e com diferença na Chave de Acesso [chNFe:35250709095917000191650010000009021823850511][nRec:351000039869786]"
--    },
--    {
--        "ds_xml_nota": "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap:Envelope xmlns:soap=\"http:\/\/www.w3.org\/2003\/05\/soap-envelope\" xmlns:xsi=\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\" xmlns:xsd=\"http:\/\/www.w3.org\/2001\/XMLSchema\"><soap:Body><nfeResultMsg xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\/wsdl\/NFeAutorizacao4\"><retEnviNFe xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\" versao=\"4.00\"><tpAmb>2<\/tpAmb><verAplic>SP_NFCE_PL_009_V400<\/verAplic><cStat>104<\/cStat><xMotivo>Lote processado<\/xMotivo><cUF>35<\/cUF><dhRecbto>2025-07-31T23:59:12-03:00<\/dhRecbto><protNFe versao=\"4.00\"><infProt><tpAmb>2<\/tpAmb><verAplic>SP_NFCE_PL_009_V400<\/verAplic><chNFe>35250709095917000191650010000009021662632313<\/chNFe><dhRecbto>2025-07-31T23:59:12-03:00<\/dhRecbto><cStat>539<\/cStat><xMotivo>Rejeição: Duplicidade de NF-e com diferença na Chave de Acesso [chNFe:35250709095917000191650010000009021823850511][nRec:351000039869786]<\/xMotivo><\/infProt><\/protNFe><\/retEnviNFe><\/nfeResultMsg><\/soap:Body><\/soap:Envelope>\n"
--    },
--    {
--        "cd_chave_acesso": "35250709095917000191650010000009021662632313"
--    },
--    {
--        "ic_validada": "X"
--    },
--    {
--        "dt_autorizacao": "09:00:00"
--    },
--    {
--        "cd_protocolo_nfe": "xxx"
--    },
--    {
--        "ic_json_parametro": "S"
--    }
--]
--'

--SELECT @json

--EXEC pr_egis_atualizacao_nota_validacao @json = @json

--use EGISSQL_rubio

--select * from nota_validacao

--35250809095917000191650010000015871000015879

--select * from vw_nfe_chave_acesso where cd_nota_saida = 1587

--NFe35250809095917000191650010000015871000015879


--select * from nota_saida_documento

--nota_saida_recibo
--insert Nota_Saida_Recibo into cd_nota_saida, cd_protocolo_nfe, dt_autorizacao_nota 
--select * from nota_validacao

