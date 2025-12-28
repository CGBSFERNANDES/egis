--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_mensagem_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_mensagem_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_mensagem_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_mensagem_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_mensagem_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_mensagem_processo_modulo
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
--                   Modelo de Procedure com Processos
--                   Mensagens do WhatsApp
--
--Data             : 16.11.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_mensagem_processo_modulo
------------------------
@json nvarchar(max) = ''
------------------------------------------------------------------------------
--with encryption


as

set @json = isnull(@json,'')

-- ver nível atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;

--return

--set @json = isnull(@json,'')

 SET NOCOUNT ON;
 SET XACT_ABORT ON;

 BEGIN TRY
 
 /* 1) Validar payload - parameros de Entrada da Procedure */
 IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

 /* 2) Normalizar: aceitar array[0] ou objeto */
 IF JSON_VALUE(@json, '$[0]') IS NOT NULL
            SET @json = JSON_QUERY(@json, '$[0]'); -- pega o primeiro elemento


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


declare @cd_empresa              int
declare @cd_parametro            int
declare @cd_documento            int = 0
declare @cd_item_documento       int
declare @cd_usuario              int 
declare @dt_hoje                 datetime
declare @dt_inicial              datetime 
declare @dt_final                datetime
declare @cd_ano                  int = 0
declare @cd_mes                  int = 0
declare @cd_modelo               int = 0
declare @cd_campanha             int = 0
declare @cd_mensagem             int = 0
declare @cd_modulo               int = 0
declare @cd_controle             int = 0
declare @cd_fone_cliente         varchar(15)   = ''
declare @nm_email_cliente        varchar(500)  = ''
declare @cd_celular_validacao    varchar(20)   = ''
declare @cd_evento               int           = 0
declare @ds_mensagem_complemento nvarchar(max) = ''
declare @nm_fantasia_cliente     varchar(60)   = ''

--declare @cd_documento         int          = 0


----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
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

 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

--------------------------------------------------------------------------------------------

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo'             
select @cd_campanha            = valor from #json where campo = 'cd_campanha'             
select @cd_mensagem            = valor from #json where campo = 'cd_mensagem'
select @cd_modulo              = valor from #json where campo = 'cd_modulo'
select @cd_celular_validacao   = valor from #json where campo = 'cd_celular_validacao'
select @cd_evento              = valor from #json where campo = 'cd_evento' 
select @cd_documento           = valor from #json where campo = 'cd_documento'

--------------------------------------------------------------------------------------
set @cd_celular_validacao = isnull(@cd_celular_validacao,'')
set @cd_empresa           = ISNULL(@cd_empresa,0)
set @cd_evento            = isnull(@cd_evento,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro = ISNULL(@cd_parametro,0)


IF ISNULL(@cd_parametro,0) = 0
BEGIN
  select 
    'Sucesso' as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final


  RETURN;

END
    
--Mostra todas as Mensagens Disponíveis

if @cd_parametro = 1
begin
  select * from egisadmin.dbo.mensagem
  order by
    nm_mensagem

  return
end

--WhatsApp
--Mensagem de Teste para Validação da Api
-----------------------------------------------------------------

if @cd_parametro = 2
begin
  
  set @ds_mensagem_complemento = '>> Complemento da Mensagem <<'

  select
    top 1
    @cd_mensagem = cd_mensagem
  from
    egisadmin.dbo.Mensagem
  where
    isnull(ic_validacao,'N') = 'S'

  --set @cd_celular_validacao = '5511992737805'
  set @cd_evento            = 0

  if @cd_mensagem>0 and @cd_celular_validacao<>''
  begin
    
    exec pr_gera_mensagem_api_whatsapp @cd_modulo,0,@cd_usuario,@cd_celular_validacao,'', @cd_mensagem, @cd_evento, @ds_mensagem_complemento

  end
  else
  begin
    select 'Mensagem de Validação não Definida !' as Msg
  end

  return

end

if @cd_parametro = 3
begin
  
  set @ds_mensagem_complemento = ''
  set @cd_celular_validacao    = '5511992737805'
  set @cd_evento               = 0
  set @nm_fantasia_cliente     = ''

  --Busca o Telefone do Destinatário da Mensagem--
  --Variação de Acordo com o Tipo da Mensgaem--

  --Registro do Suporte do Cliente--
  if @cd_mensagem = 16
  begin
    --cliente_contato--
    --select * from registro_suporte

    select
      @nm_fantasia_cliente     = c.nm_fantasia_cliente,
      
      @ds_mensagem_complemento = 'No.' + cast(rs.cd_registro_suporte as varchar(20)) 
                                  + ' ' +
                                  isnull(cast(rs.ds_ocorrencia_suporte as nvarchar(max)),'')
                                  +
                                  ' o registro foi aberto, e em breve entraremos em contato !'
                               -----
                               ,

      @cd_celular_validacao    = isnull(cc.cd_ddi_celular,'55') 
                                 +
                                 isnull(cc.cd_ddd_celular,'')
                                 +
                                 replace(isnull(cc.cd_celular,''),'-','')


    from
      registro_suporte rs
      inner join cliente c          on c.cd_cliente  = rs.cd_cliente
      inner join cliente_contato cc on cc.cd_cliente = rs.cd_cliente and
                                       cc.cd_contato = rs.cd_contato

    where
      rs.cd_registro_suporte = @cd_documento
      and
      isnull(cc.cd_celular,'')<>''

      
  end

  --select cd_cliente, cd_contato from registro_suporte where cd_registro_suporte = 15433
  --select * from cliente_contato where cd_cliente = 445

  --select @cd_documento, @ds_mensagem_complemento
  --return

  ------------------------------------------Envio-----------------------------------------------------------------
  if @cd_mensagem>0 and @cd_celular_validacao<>''
  begin
    
    exec pr_gera_mensagem_api_whatsapp @cd_modulo,0,@cd_usuario,@cd_celular_validacao,'', 
                                       @cd_mensagem, 
                                       @cd_evento, 
                                       @ds_mensagem_complemento


    --Envio para nosso número de Suporte e Atendimento--

    if @cd_mensagem = 16
    begin

      set @cd_celular_validacao    = '5511979682516'
      set @ds_mensagem_complemento =  @nm_fantasia_cliente + ' - '+@ds_mensagem_complemento 

      exec pr_gera_mensagem_api_whatsapp @cd_modulo,0,@cd_usuario,@cd_celular_validacao,'', 
                                       @cd_mensagem, 
                                       @cd_evento, 
                                       @ds_mensagem_complemento

      set @cd_celular_validacao    = '5511932708331'
      --set @ds_mensagem_complemento =  @nm_fantasia_cliente + ' - '+@ds_mensagem_complemento 

      exec pr_gera_mensagem_api_whatsapp @cd_modulo,0,@cd_usuario,@cd_celular_validacao,'', 
                                       @cd_mensagem, 
                                       @cd_evento, 
                                       @ds_mensagem_complemento

      --Carlos Temporáriamente--

      set @cd_celular_validacao    = '5511992737805'
      --set @ds_mensagem_complemento =  @nm_fantasia_cliente + ' - '+@ds_mensagem_complemento 

      exec pr_gera_mensagem_api_whatsapp @cd_modulo,0,@cd_usuario,@cd_celular_validacao,'', 
                                       @cd_mensagem, 
                                       @cd_evento, 
                                       @ds_mensagem_complemento

                                        
      ----------------------------------------------------------------------------------------------

    end

  end
  else
  begin
    select 'Mensagem de Validação não Definida !' as Msg
  end

  return

end


if @cd_parametro = 99999
begin
  
  --select @cd_parametro = 2
  
  select
   c.* 
  into #Mensagem
  from
    cliente_prospeccao c
    inner join campanha_cliente cc on cc.cd_cliente_prospeccao = c.cd_cliente_prospeccao
  where
    isnull(c.cd_fone_cliente,'')<>''
    and
    cc.cd_campanha = @cd_campanha


  set @cd_mensagem = 15
  set @cd_evento   = 1

  while exists( select top 1 cd_cliente_prospeccao from #Mensagem )
  begin
    select top 1
      @cd_controle = cd_cliente_prospeccao,
      @cd_fone_cliente = cd_fone_cliente
    from
      #Mensagem

      select @cd_fone_cliente

      -----------------------------------------------------
      if substring(@cd_fone_cliente,1,2)<>'55' 
         set @cd_fone_cliente = '55' + @cd_fone_cliente
      -----------------------------------------------------   
      set @cd_fone_cliente = '5511945735382'

     exec pr_gera_mensagem_api_whatsapp @cd_modulo,0,@cd_usuario,@cd_fone_cliente,'', @cd_mensagem, @cd_evento

     ---Json-----
	
    delete from #Mensagem where
       @cd_controle = cd_cliente_prospeccao
  end

  return

end

--emails
if @cd_parametro = 3
begin
  select @cd_parametro
  --pr_gera_email_comunicacao_evento
  select
   c.* 
  into #MensagemEmail
  from
    cliente_prospeccao c
    inner join campanha_cliente cc on cc.cd_cliente_prospeccao = c.cd_cliente_prospeccao
  where
    isnull(c.cd_fone_cliente,'')<>''
    and
    cc.cd_campanha = @cd_campanha

  set @cd_mensagem = 15
  set @cd_evento   = 1

  while exists( select top 1 cd_cliente_prospeccao from #MensagemEmail )
  begin
    select top 1
      @cd_controle      = cd_cliente_prospeccao,
      @nm_email_cliente = nm_email_cliente
    from
      #MensagemEmail

      select @nm_email_cliente

      if @nm_email_cliente<>''
      begin
        print @nm_email_cliente
        --exec pr_gera_email_comunicacao_evento @nm_email_cliente, 0, @cd_evento
      end

      ---------------------------------------------------------------------------------
	
    delete from #MensagemEmail where
       @cd_controle = cd_cliente_prospeccao

  end

  return
end

/* Padrão se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;
   
 END TRY
    BEGIN CATCH
        DECLARE
            @errnum   INT            = ERROR_NUMBER(),
            @errmsg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @errproc  NVARCHAR(128)  = ERROR_PROCEDURE(),
            @errline  INT            = ERROR_LINE(),
            @fullmsg  NVARCHAR(2048);



         -- Monta a mensagem (THROW aceita até 2048 chars no 2º parâmetro)
    SET @fullmsg =
          N'Erro em pr_egis_modelo_procedure ('
        + ISNULL(@errproc, N'SemProcedure') + N':'
        + CONVERT(NVARCHAR(10), @errline)
        + N') #' + CONVERT(NVARCHAR(10), @errnum)
        + N' - ' + ISNULL(@errmsg, N'');

    -- Garante o limite do THROW
    SET @fullmsg = LEFT(@fullmsg, 2048);

    -- Relança com contexto (state 1..255)
    THROW 50000, @fullmsg, 1;

        -- Relança erro com contexto
        --THROW 50000, CONCAT('Erro em pr_egis_modelo_procedure (',
        --                    ISNULL(@errproc, 'SemProcedure'), ':',
        --                    @errline, ') #', @errnum, ' - ', @errmsg), 1;
    END CATCH

---------------------------------------------------------------------------------------------------------------------------------------------------------    
go



------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_mensagem_processo_modulo
------------------------------------------------------------------------------

--sp_helptext pr_egis_mensagem_processo_modulo


go
/*
--Validação da PR
exec  pr_egis_mensagem_processo_modulo '[{"cd_parametro": 0}]'
--Mostra as Mensagens--
exec  pr_egis_mensagem_processo_modulo '[{"cd_parametro": 1}]'  
--Envio Teste
exec  pr_egis_mensagem_processo_modulo '[{"cd_parametro": 2}, {"cd_celular_validacao": "5511995651245"}]'  
--
exec  pr_egis_mensagem_processo_modulo '[{"cd_parametro": 3}, {"cd_mensagem": 16}, {"cd_celular_validacao": "5511992737805"}]'  
]'
*/
go

--select * from registro_suporte

--use gbs_egissql

------------------------------------------------------------------------------
--exec  pr_egis_mensagem_processo_modulo '[{"cd_parametro": 3},{ "cd_mensagem": 16}, {"cd_documento": "15433"}, {"cd_celular_validacao": "5511992737805"}]'  

