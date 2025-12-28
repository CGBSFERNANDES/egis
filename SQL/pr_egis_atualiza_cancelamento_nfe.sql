--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_atualiza_cancelamento_nfe' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_atualiza_cancelamento_nfe

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_atualiza_cancelamento_nfe
-------------------------------------------------------------------------------
--pr_egis_atualiza_cancelamento_nfe
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
create procedure pr_egis_atualiza_cancelamento_nfe
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


SET NOCOUNT ON;

-- 1) NÃO destrua o JSON
-- REMOVA qualquer linha como:
-- SET @json = REPLACE(@json, '\', '');

-- 2) Se vier como "string de JSON": "...."
--select @json

/*
set @json = replace(
             replace(
               replace(
                replace(
                  replace(
                    replace(
                      replace(
                        replace(
                          replace(
                            replace(
                              replace(
                                replace(
                                  replace(
                                    replace(
                                    @json, CHAR(13), ' '),
                                  CHAR(10),' '),
                                ' ',' '),
                              ':\\\"',':\\"'),
                            '\\\";','\\";'),
                          ':\\"',':\\\"'),
                        '\\";','\\\";'),
                      '\\"','\"'),
                    '\"', '"'),
                  '',''),
                '["','['),
              '"[','['),
             ']"',']'),
          '"]',']') 
*/

-- 4) Validação

IF ISJSON(@json) <> 1
BEGIN
    THROW 50001, 'JSON inválido em @json.', 1;
    RETURN;
END


declare @cd_empresa          int = 0
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
declare @cd_movimento_caixa  int           = 0
declare @dt_validacao_caixa  datetime


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
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
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
select @cd_movimento_caixa     = valor from #json where campo = 'cd_movimento_caixa'

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

set @cd_parametro       = ISNULL(@cd_parametro,0)
set @cd_movimento_caixa = isnull(@cd_movimento_caixa,0)
set @cd_nota_saida      = isnull(@cd_nota_saida,0)

if @cd_parametro = 1 --and @cd_movimento_caixa>0
begin
 
  --Validar e buscara o Movimento de Caixa pela nota de Saída
 
  if @cd_movimento_caixa = 0 and @cd_nota_saida>0
  begin
    select 
      top 1
      @cd_movimento_caixa = isnull(cd_movimento_caixa,0),
      @dt_validacao_caixa = dt_movimento_caixa
    from
      movimento_caixa
    where
      cd_nota_saida = @cd_nota_saida
   order by
      cd_nota_saida

  end

  --------------------------------------------------------------------
  --Verifica se Existe a Nota Fiscal de Saída para Update na Validação
  --------------------------------------------------------------------
  if @cd_nota_saida = 0 and @cd_movimento_caixa>0
  begin

    set @cd_nota_saida = 0

    select
      top 1
      @cd_nota_saida      = cd_nota_saida,
      @dt_validacao_caixa = dt_movimento_caixa
    from
      movimento_caixa

    where
      cd_movimento_caixa = @cd_movimento_caixa
      and
      isnull(cd_nota_saida,0)>0
    order by
      cd_nota_saida

  end


  if @cd_movimento_caixa > 0 and @dt_validacao_caixa = @dt_hoje 
  begin

    --Itens do Movimento de caixa

    update
      Movimento_Caixa_Item
    set
      dt_cancel_item            = @dt_hoje,
      cd_usuario                = @cd_usuario
    where 
      cd_movimento_caixa = @cd_movimento_caixa
 
  --Movimento de caixa----------------------------------------------------------------------------------

  update
    movimento_caixa
  set
    dt_cancel_movimento_caixa = @dt_hoje,
    cd_usuario                = @cd_usuario
  where 
    cd_movimento_caixa = @cd_movimento_caixa

  end

  --Envia a Nota Fiscal para o Robo de Cancelamento----------------------------------------------------
  if @cd_nota_saida>0 and @dt_validacao_caixa = @dt_hoje 
  begin
    update
      nota_validacao
    set
      ic_cancelar = 'S'
    from
      nota_validacao nv
      inner join nota_saida n on n.cd_nota_saida = nv.cd_nota_saida
    where
      nv.cd_nota_saida = @cd_nota_saida
      and
      n.dt_nota_saida  = @dt_hoje
      -----------------------------------------------------------------------------------------------
  end

  ---------------------------------------------------------------------------------------------------

  return

end

--Atualização do Cancelamento da Nota Fiscal---------------------------------------------------------

set @cd_chave_acesso = isnull(@cd_chave_acesso,'')

if @cd_parametro = 0 and @cd_chave_acesso<>''

   set @cd_nota_saida = 0

   select
     @cd_nota_saida = cd_nota_saida
   from
     nota_validacao
   where
     cd_chave_acesso = @cd_chave_acesso


--Atualizar o XML da Nota

select
  top 1
  @ds_xml_nota = ds_xml_nota
from
  Nota_Validacao
where
  cd_nota_saida = @cd_nota_saida
  and
  cast(ds_xml_nota as nvarchar(max))<>''


    ------------------------------------------------------------
    -- Normaliza JSON (aceita tanto lista de objetos quanto lista de pares)
    ------------------------------------------------------------
    DECLARE @t TABLE (chave NVARCHAR(200), valor NVARCHAR(MAX));


    /* Tenta formato [{"campo": "valor"}, ...] */
    IF EXISTS (SELECT 1 FROM OPENJSON(@json))
    BEGIN
        INSERT INTO @t(chave, valor)
        SELECT k.[key], k.[value]
        FROM OPENJSON(@json) AS j
        CROSS APPLY OPENJSON(j.[value]) AS k
        WHERE k.[key] IS NOT NULL;
    END

    /* Se não popular, tenta formato [["campo","valor"], ...] */
    IF NOT EXISTS (SELECT 1 FROM @t)
    BEGIN
        INSERT INTO @t(chave, valor)
        SELECT j.[value] AS chave,
               j2.[value] AS valor
        FROM OPENJSON(@json) WITH ([value] NVARCHAR(MAX) AS JSON) AS p
        CROSS APPLY OPENJSON(p.[value]) WITH ([value] NVARCHAR(MAX) '$') AS j
        CROSS APPLY OPENJSON(p.[value]) WITH ([value] NVARCHAR(MAX) '$[1]') AS j2
        WHERE j.[value] IS NOT NULL;
    END

    ------------------------------------------------------------
    -- Extrai campos
    ------------------------------------------------------------
    DECLARE
       -- @cd_chave_acesso   NVARCHAR(44),
        --@cd_protocolo_nfe  NVARCHAR(50),
        @cd_protocolo_canc NVARCHAR(50),
        @dt_cancelamento_s NVARCHAR(50),
        @ds_xml_evento     NVARCHAR(MAX),
        @ic_cancelada      CHAR(1);

    SELECT @cd_chave_acesso   = (SELECT valor FROM @t WHERE chave='cd_chave_acesso'),
           @cd_protocolo_nfe  = (SELECT valor FROM @t WHERE chave='cd_protocolo_nfe'),
           @cd_protocolo_canc = (SELECT valor FROM @t WHERE chave='cd_protocolo_canc'),
           @dt_cancelamento_s = (SELECT valor FROM @t WHERE chave='dt_cancelamento'),
           @ds_xml_evento     = (SELECT valor FROM @t WHERE chave='ds_xml_evento'),
           @ic_cancelada      = COALESCE((SELECT valor FROM @t WHERE chave='ic_cancelada'),'N');

    IF (@cd_chave_acesso IS NULL OR LEN(@cd_chave_acesso) <> 44)
    BEGIN
        RAISERROR('cd_chave_acesso ausente ou inválida', 16, 1);
        RETURN;
    END

    -- Converte data ISO 8601 da SEFAZ
    DECLARE @dt_cancelamento DATETIME2(0) = TRY_CONVERT(DATETIME2(0), @dt_cancelamento_s, 126);

    ------------------------------------------------------------
    -- Atualiza nota_validacao; insere se não existir
    ------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM nota_validacao WHERE cd_nota_saida = @cd_nota_saida)
    BEGIN
        UPDATE nota_validacao
           SET ic_cancelada        = @ic_cancelada,
               cd_protocolo_canc   = NULLIF(@cd_protocolo_canc,''),
               dt_cancelamento     = @dt_cancelamento,
               ds_xml_evento       = @ds_xml_evento,
               cd_usuario          = @cd_usuario,
               dt_usuario          = SYSDATETIME(),
               ic_cancelar         = 'N'
         WHERE 
           --cd_chave_acesso = @cd_chave_acesso
           cd_nota_saida = @cd_nota_saida

        UPDATE
           nota_saida
        set
          cd_status_nota       = 7,
          dt_cancel_nota_saida = --@dt_cancelamento
                                 convert(datetime,left(convert(varchar,@dt_cancelamento,121),10)+' 00:00:00',121)
        where
         cd_nota_saida = @cd_nota_saida


    END


    IF EXISTS (SELECT 1 FROM nota_validacao_cancelamento WHERE cd_chave_acesso = @cd_chave_acesso)
    BEGIN
        UPDATE nota_validacao_cancelamento
           SET ic_cancelada        = @ic_cancelada,
               cd_protocolo_canc   = NULLIF(@cd_protocolo_canc,''),
               dt_cancelamento     = @dt_cancelamento,
               ds_xml_evento       = @ds_xml_evento,
               dt_usuario_inclusao = SYSDATETIME()
         WHERE cd_chave_acesso = @cd_chave_acesso;
    END
    ELSE
    BEGIN
        INSERT INTO nota_validacao_cancelamento
            (cd_nota_saida, cd_chave_acesso, ic_cancelada, cd_protocolo_nfe, cd_protocolo_canc, dt_cancelamento, ds_xml_evento, dt_usuario_inclusao)
        VALUES
            (@cd_nota_saida, @cd_chave_acesso, @ic_cancelada, NULLIF(@cd_protocolo_nfe,''), NULLIF(@cd_protocolo_canc,''), @dt_cancelamento, @ds_xml_evento, SYSDATETIME());
    END

    ------------------------------------------------------------
    -- (Opcional) Se você guarda eventos em tabela própria:
    -- INSERT INTO nota_saida_evento (cd_chave_acesso, tp_evento, protocolo_evento, dh_evento, xml_evento)
    -- VALUES (@cd_chave_acesso, '110111', @cd_protocolo_canc, @dt_cancelamento, @ds_xml_evento);
    ------------------------------------------------------------

    SELECT 1 AS ok, 'Cancelamento atualizado' AS mensagem;

--  select 'Nota Atualizada : '+cast(@cd_nota_saida as varchar(20)) as Msg

--   end

--end

--use egissql_345
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_atualiza_cancelamento_nfe
------------------------------------------------------------------------------
go

--select * from movimento_caixa
--select * from Nota_Validacao

--update 
--  nota_validacao
--  set
--    ic_cancelar = 'N'

     
--    go

--use egissql_371

--select * from movimento_caixa order by cd_movimento_caixa desc


--exec pr_egis_atualiza_cancelamento_nfe 
--exec pr_egis_atualiza_cancelamento_nfe '[{"cd_parametro":1,"cd_movimento_caixa":"530","cd_usuario":"113","dt_inicial":"2025-05-01 00:00:00","dt_final":"2025-05-31 00:00:00"}]'

go
--select * from nota_validacao

--update 
--  nota_validacao
--  set
--    ic_cancelar = 'N'


go

------------------------------------------------------------------------------
GO

--select * from nota_validacao


--exec pr_egis_atualiza_cancelamento_nfe 
--'[{"cd_parametro": 0, "cd_chave_acesso":"35251103418924007294650010000002931000002000"},{"cd_protocolo_canc":"13525000007697031"},{"dt_cancelamento":"2025-11-09T04:21:21+00:00"},{"ds_xml_evento":"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http:\/\/www.w3.org\/2003\/05\/soap-envelope\" xmlns:xsi=\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\" xmlns:xsd=\"http:\/\/www.w3.org\/2001\/XMLSchema\"><soap:Body><nfeResultMsg xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\/wsdl\/NFeRecepcaoEvento4\"><retEnvEvento versao=\"1.00\" xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\"><idLote>202511090121204<\/idLote><tpAmb>2<\/tpAmb><verAplic>SP_EVENTOS_PL_100<\/verAplic><cOrgao>35<\/cOrgao><cStat>128<\/cStat><xMotivo>Lote de Evento Processado<\/xMotivo><retEvento versao=\"1.00\"><infEvento><tpAmb>2<\/tpAmb><verAplic>SP_EVENTOS_PL_100<\/verAplic><cOrgao>35<\/cOrgao><cStat>135<\/cStat><xMotivo>Evento registrado e vinculado a NF-e<\/xMotivo><chNFe>35251103418924007294650010000002931000002000<\/chNFe><tpEvento>110111<\/tpEvento><xEvento>Cancelamento registrado<\/xEvento><nSeqEvento>1<\/nSeqEvento><dhRegEvento>2025-11-09T01:21:21-03:00<\/dhRegEvento><nProt>13525000007697031<\/nProt><\/infEvento><\/retEvento><\/retEnvEvento><\/nfeResultMsg><\/soap:Body><\/soap:Envelope>"},{"ic_cancelada":"S"},{"ic_cancelar":"N"},{"ic_json_parametro":"S"}]'


--exec pr_egis_atualiza_cancelamento_nfe 
--'[{"cd_chave_acesso":"35251103418924007294650010000002951000002021"},{"cd_protocolo_canc":"13525000007717699"},{"dt_cancelamento":"2025-11-09T14:09:28+00:00"},{"ds_xml_evento":"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:soap=\"http:\/\/www.w3.org\/2003\/05\/soap-envelope\" xmlns:xsi=\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\" xmlns:xsd=\"http:\/\/www.w3.org\/2001\/XMLSchema\"><soap:Body><nfeResultMsg xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\/wsdl\/NFeRecepcaoEvento4\"><retEnvEvento versao=\"1.00\" xmlns=\"http:\/\/www.portalfiscal.inf.br\/nfe\"><idLote>202511091109286<\/idLote><tpAmb>2<\/tpAmb><verAplic>SP_EVENTOS_PL_100<\/verAplic><cOrgao>35<\/cOrgao><cStat>128<\/cStat><xMotivo>Lote de Evento Processado<\/xMotivo><retEvento versao=\"1.00\"><infEvento><tpAmb>2<\/tpAmb><verAplic>SP_EVENTOS_PL_100<\/verAplic><cOrgao>35<\/cOrgao><cStat>135<\/cStat><xMotivo>Evento registrado e vinculado a NF-e<\/xMotivo><chNFe>35251103418924007294650010000002951000002021<\/chNFe><tpEvento>110111<\/tpEvento><xEvento>Cancelamento registrado<\/xEvento><nSeqEvento>1<\/nSeqEvento><dhRegEvento>2025-11-09T11:09:28-03:00<\/dhRegEvento><nProt>13525000007717699<\/nProt><\/infEvento><\/retEvento><\/retEnvEvento><\/nfeResultMsg><\/soap:Body><\/soap:Envelope>"},{"ic_cancelada":"S"},{"ic_cancelar":"N"},{"ic_json_parametro":"S"}]'

