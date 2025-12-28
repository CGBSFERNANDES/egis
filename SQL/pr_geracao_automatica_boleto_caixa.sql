IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_geracao_automatica_boleto_caixa' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_geracao_automatica_boleto_caixa

GO

-------------------------------------------------------------------------------
--sp_helptext pr_geracao_automatica_boleto_caixa
-------------------------------------------------------------------------------
--pr_geracao_automatica_boleto_caixa
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql - Banco do Cliente
--
--Objetivo         : Geração Automática de Boleto/Número Bancário
--                   Linha Digitável
--                   Cliente/Banco/Conta Padrão da Emprea   
--        
--Data             : 24.01.2021
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_geracao_automatica_boleto_caixa 
@json          nvarchar(max) = ''

--@cd_nota_saida int = 0,
--@cd_usuario    int = 0

--with encryption


as

declare @cd_nota_saida int = 0
declare @cd_usuario    int = 0

select 'Boleto gerado com Sucesso ' as Msg
return


SET NOCOUNT ON;

--select * from nota_saida_parcela

set dateformat mdy

--select * from nota_saida_parcela

--select * from 
--select * from conta_agencia_banco

declare @cd_empresa            int = 0
declare @cd_conta_banco        int = 0 
declare @cd_banco              int = 0
declare @numero_banco          varchar(3)
declare @moeda                 char(1)    = 9 --Real--
declare @fator_vencimento      varchar(4)
declare @valor_titulo          varchar(25)
declare @carteira              varchar(3)
declare @nosso_numero          varchar(20)
declare @dac_numero            char(1)
declare @agencia               varchar(4)
declare @conta                 varchar(20)
declare @dac_conta             varchar(2)
declare @posicao_livre         varchar(3) = ''
declare @codigo_barra          varchar(100)
declare @dac                   char(1)
declare @vl_parcela_nota_saida decimal(25,2)
declare @cd_parcela_nota_saida int
declare @vl_fator              int
declare @dt_inicio_fator       datetime
declare @dt_vencimento         datetime
declare @cd_nosso_numero       int
declare @dac_nosso_numero      char(1)
declare @linha_digitavel       varchar(100)
declare @cedente               varchar(10)
declare @cd_documento_receber  int = 0
declare @cd_portador           int = 0


set @cd_empresa            = dbo.fn_empresa()
set @cd_portador           = 0
set @cd_nosso_numero       = 0
set @vl_parcela_nota_saida = 0
set @cd_parcela_nota_saida = 1
set @cd_banco              = 0
set @cd_conta_banco        = 0
set @numero_banco          = ''
set @moeda                 = 9
set @fator_vencimento      = ''
set @valor_titulo          = ''
set @carteira              = ''
set @nosso_numero          = ''
set @dac_numero            = ''
set @agencia               = ''
set @conta                 = ''
set @dac_conta             = ''
set @posicao_livre         = '000'
set @codigo_barra          = ''
set @dac                   = ''
set @dac_nosso_numero      = ''
set @linha_digitavel       = ''
set @cedente               = ''
set @cd_documento_receber  = 0
set @cd_empresa            = dbo.fn_empresa()

--select dbo.fn_mascara_valor_duas_casas(123.45)
--select dbo.fn_mascara_valor_duas_casas_F(123.45)

--Parâmetro Boleto--

--Banco tem que vir do Cliente/Parâmetro/Conta Padrão

select
  top 1
  @cd_conta_banco = isnull(cd_conta_banco,0)
from
  Parametro_Boleto
where
  cd_empresa = @cd_empresa
  and
  isnull(cd_conta_banco,0)>0

--0) Conta Bancária---

select
  @cd_conta_banco = case when isnull(ci.cd_conta_banco,0)>0 
                    then ci.cd_conta_banco 
                    else
                       case when isnull(ce.cd_conta_banco,0)>0 then ce.cd_conta_banco else @cd_conta_banco end
                    end
     --isnull(ci.cd_conta_banco,@cd_conta_banco)

from
  nota_saida n
  left outer join cliente_informacao_credito ci on ci.cd_cliente = n.cd_cliente
  left outer join cliente_empresa ce            on ce.cd_cliente = n.cd_cliente

where
  n.cd_nota_saida = @cd_nota_saida
  
--1) Documento--

--select * from nota_saida_parcela

---looop    1 parcela
--while exists ( -- todas as parcelas da NF )


select
  top 1
  @vl_parcela_nota_saida = isnull(nsp.vl_parcela_nota_saida,0),
  @cd_parcela_nota_saida = nsp.cd_parcela_nota_saida,
  @dt_vencimento         = nsp.dt_parcela_nota_saida,
  @cd_documento_receber  = isnull(d.cd_documento_receber,0)

  --@valor_titulo          = fn_mascara_valor_duas_casas_F(vl_parcela_nota_saida)

from
  nota_saida_parcela nsp
  left outer join documento_receber d on d.cd_nota_saida         = nsp.cd_nota_saida and
                                         d.cd_parcela_nota_saida = nsp.cd_parcela_nota_saida
where
  nsp.cd_nota_saida = @cd_nota_saida

--select @cd_parcela_nota_saida, @cd_nota_saida, @cd_documento_receber
--return
  

--select * from documento_receber
--update
--  documento_receber
--  set
--    cd_parcela_nota_saida = 1
 

------------------------------------------------------------------------------

-- 2) Valor em centavos -> 10 dígitos
-- evita problemas de locale e pontuação

DECLARE @valor_centavos BIGINT =
    CAST(ROUND(ISNULL(@vl_parcela_nota_saida,0.00),2) * 100 AS BIGINT);

SET @valor_titulo = RIGHT(REPLICATE('0',10) + CAST(@valor_centavos AS VARCHAR(20)), 10)

--select @dt_vencimento

--Formatar o valor do Título--
  
set @valor_titulo = rtrim(ltrim(replace((select convert(varchar, convert(numeric(14,2),round(isnull(@vl_parcela_nota_saida,0.00),6,2)),103)),'.','')))  
  
set @valor_titulo = replicate('0',10 - len(@valor_titulo)) + @valor_titulo  
 
--select @valor_titulo
--return

--
-----------------------------------------------------
--select * from conta_agencia_banco
--select * from agencia_banco
--select * from portador
--select * from tipo_cobranca
--select * from carteira_cobranca
--select * from conta_carteira_cobranca
-------------------------------------------------------

select
  @cd_portador  = c.cd_portador,
  @cd_banco     = c.cd_banco,
  @moeda        = 9,
  --@numero_banco = cast(b.cd_numero_banco as varchar(3)),
  --@conta        = ltrim(rtrim(isnull(c.nm_conta_banco,''))),
  --@dac_conta    = ltrim(rtrim(isnull(c.cd_dac_conta_banco,''))),
  --@agencia      = ltrim(rtrim(isnull(a.cd_numero_agencia_banco,''))),
  --@carteira     = ltrim(rtrim(cast(isnull(cob.cd_num_carteira_cobranca,0) as varchar(3)))),
  --@cedente      = ltrim(rtrim(isnull(c.cd_cedente_conta,''))),
  @numero_banco = RIGHT(REPLICATE('0',3) + CAST(b.cd_numero_banco AS VARCHAR(3)),3),
  @conta        = RIGHT(REPLICATE('0',5) + REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(c.nm_conta_banco,''))),'-',''),'.',''),5),
  @dac_conta    = RIGHT(REPLICATE('0',1) + LTRIM(RTRIM(ISNULL(c.cd_dac_conta_banco,''))),1),
  @agencia      = RIGHT(REPLICATE('0',4) + REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(a.cd_numero_agencia_banco,''))),'-',''),'.',''),4),
  @carteira     = RIGHT(REPLICATE('0',3) + CAST(ISNULL(cob.cd_num_carteira_cobranca,0) AS VARCHAR(3)),3),
  @cedente      = LTRIM(RTRIM(ISNULL(c.cd_cedente_conta,'')))

from
  Conta_Agencia_Banco c
  inner join banco b                         on b.cd_banco               = c.cd_banco
  inner join agencia_banco a                 on a.cd_agencia_banco       = c.cd_agencia_banco
  left outer join conta_carteira_cobranca cc on cc.cd_conta_banco        = c.cd_conta_banco
  left outer join carteira_cobranca cob      on cob.cd_carteira_cobranca = cc.cd_carteira_cobranca
  
where
  c.cd_conta_banco = @cd_conta_banco

-------------------------------------------------------------------------------------------------------------
--Nosso Número--
-------------------------------------------------------------------------------------------------------------
--select cd_nota_saida,* from documento_receber where cd_nota_saida  = 644
set @cd_nosso_numero = 0

select 
  @cd_nosso_numero = max(isnull(cast(cd_banco_documento_recebe as int),0)) + 1
from
  documento_receber d
where
  --d.cd_conta_banco_remessa = @cd_conta_banco
  d.cd_portador = @cd_portador

-------------------------------------------------
set @cd_nosso_numero = isnull(@cd_nosso_numero,0) 
-------------------------------------------------


--select @cd_nosso_numero
--return

--cd_conta_banco_remessa, se tiver 0, o importante é pegar a conta padrao, ou do cliente

--select * from documento_receber

--where
--  d.cd_nota_saida = @cd_nota_saida
--order by
--  d.cd_parcela_nota_saida 

--select @cd_nosso_numero
--return

--select * from Boleto_Numero_Interno

if isnull(@cd_nosso_numero,0) = 0
begin
  select
    @cd_nosso_numero = isnull(cd_nosso_numero_boleto,0) + isnull(qt_passo_boleto,0)
  from
    Boleto_Numero_Interno
  where
    cd_conta_banco = @cd_conta_banco
end

-------------------------------------------------------------------------------------
if isnull(@cd_nosso_numero,0) = 0
   set @cd_nosso_numero = isnull(@cd_nosso_numero,0) + 1
-------------------------------------------------------------------------------------


--select @cd_nosso_numero
--return

-------------------------------------------------------------------------------------------------------------
--Cálculo do Dígito do Nosso Número
------------------------------------
--select  @conta, @dac_conta, @agencia, @carteira
-------------------------------------------------------------------------------------------------------------
--return

set @nosso_numero = dbo.fn_strzero(@cd_nosso_numero,8)

--select @agencia + @conta + @carteira + @nosso_numero as coluna

set @dac_nosso_numero = dbo.Modulo10(@agencia + @conta + @carteira + @nosso_numero)

--------------------------------------------------------------------------------------------------------------

--select @nosso_numero, @dac_nosso_numero
--return

--ADigitoNossoNumero := Modulo10(ACodigoAgencia + ANumeroConta + ACarteira + ANossoNumero);

--select @cd_nosso_numero, @nosso_numero, @dac_nosso_numero

--Fator de Vencimento--

--set @dt_inicio_fator = '10/07/1997'
/* 6) Fator de vencimento — regra FEBRABAN
   Até 21/02/2025: dias desde 07/10/1997 (base antiga).
   A partir de 22/02/2025: fator reinicia em 1000 e soma dias desde 22/02/2025. */

DECLARE 
  @base_antiga DATE = '1997-10-07',
  @base_nova   DATE = '2025-02-22'
  

IF CAST(@dt_vencimento AS DATE) <= '2025-02-21'
BEGIN
  SET @vl_fator = DATEDIFF(DAY, @base_antiga, @dt_vencimento);  -- 0000 até 9999
END
ELSE
BEGIN
  SET @vl_fator = 1000 + DATEDIFF(DAY, @base_nova, @dt_vencimento); -- 1000, 1001, ...
END

-- Converte para 4 dígitos (zero-padding)
SET @fator_vencimento = RIGHT(REPLICATE('0',4) + CAST(@vl_fator AS VARCHAR(8)), 4);
------------------------------------------------------------------------------------

---set @vl_fator = cast( @dt_vencimento - @dt_inicio_fator as int )

--select @fator_vencimento, @vl_fator
--return


--select @dt_vencimento, @dt_inicio_fator

------------------------------------------------------------------
--select @cd_banco, @moeda, @numero_banco, @conta, @dac_conta, @agencia, @carteira, @vl_parcela_nota_saida, @valor_titulo,
--       @nosso_numero, @dac_nosso_numero, @posicao_livre, @vl_fator
---------------------------------------------------------------------------------------------------------------------------
--select @vl_fator

  /* 7) Campo livre por banco
     Itaú (341):  carteira(3) + nosso(8) + dv_nosso(1) + agencia(4) + conta(5) + dv_conta(1) + "000"(3)
     Adicione novos WHEN para 237/001/033 etc. conforme layout de cada banco. */
  
  declare @campo_livre nvarchar(max) = ''

  SET @campo_livre = NULL;

  IF @numero_banco = '341'
  BEGIN
    SET @campo_livre = @carteira + @nosso_numero + @dac_nosso_numero + @agencia + @conta + @dac_conta + '000';
  END
  ELSE
  BEGIN
    -- Esqueleto para outros bancos (preencher layout do campo livre)
    -- IF @numero_banco = '237' BEGIN ... END
    -- IF @numero_banco = '001' BEGIN ... END
    -- Por enquanto: retorna erro claro
    RAISERROR('Banco %s ainda não está parametrizado no layout do campo livre.', 16, 1, @numero_banco);
    RETURN;
  END

--select @campo_livre
--return


--Código de Barra----------------------------------------------------------------------------------------------------------

set @codigo_barra = @numero_banco              +
                    @moeda                     +
					cast(@vl_fator as char(4)) +
					@valor_titulo              + 
					@carteira                  +
					@nosso_numero              +  
					@dac_nosso_numero          +
					@agencia                   +
					@conta                     +
					@dac_conta                 +
					@posicao_livre


--select @codigo_barra
--return

--set @@codigo_barra_barra = '3419166700000123451101234567880057123457000'

set @dac = dbo.Modulo11(@codigo_barra)
----------------------------------------------------------------------------------------------------------------------------

--select @codigo_barra
--select @dac
--return

----------------------------------------------------------------------------------------------------------------------------
set @codigo_barra = @numero_banco              +
                    @moeda                     +
					@dac                       + --DAC - Cálculado Acima
					cast(@vl_fator as char(4)) +
					@valor_titulo              + 
					@carteira                  +
					@nosso_numero              +  
					@dac_nosso_numero          +
					@agencia                   +
					@conta                     +
					@dac_conta                 +
					@posicao_livre

--select @codigo_barra
--return

---------------------------------------------------------------------------------------------------------------------------

--           select dbo.Modulo11('3419166700000123451101234567880057123457000') as digito



--select @vl_fator as vl_fator

--select @vencimento

--select @dt_inicio_fator + @vl_fator

---Linha Digitável----------------------------------------------------------------------------------------------------------

declare @p1     varchar(100)
declare @p2     varchar(100)
declare @p3     varchar(100)
declare @p4     varchar(100)
declare @p5     varchar(100)
declare @p6     varchar(100)
declare @Campo1 varchar(100)
declare @Campo2 varchar(100)
declare @Campo3 varchar(100)
declare @Campo4 varchar(100)
declare @Campo5 varchar(100)

------------------------------

set @p1 = ''
set @p2 = ''
set @p3 = ''
set @p4 = ''
set @p5 = ''
set @p6 = ''

set @Campo1 = ''
set @Campo2 = ''
set @Campo3 = ''
set @Campo4 = ''
set @Campo5 = ''

/*
   {
      Campo 1 - composto pelo código do banco, código da moeda, as cinco primeiras posições
      do campo livre e DV (modulo10) desse campo
   }
*/

     set @p1     = Substring(@codigo_barra,1,4)
     set @p2     = Substring(@codigo_barra,20,5)
     set @p3     = dbo.Modulo10(@p1+@p2);
     set @p4     = @p1+@p2+@p3;
     set @p5     = Substring(@p4,1,5);
     set @p6     = Substring(@p4,6,5);
     ----------------------------------

     set @Campo1 = @p5+'.'+@p6;

     --------------------------------------------------------------------------
     --select @Campo1
     --------------------------------------------------------------------------

/*

      {
         Campo 2 - composto pelas posiçoes 6 a 15 do campo livre
         e DV (modulo10) deste campo
      }
*/
      set @p1     = Substring(@codigo_barra,25,10)
      set @p2     = dbo.Modulo10(@p1)
      set @p3     = @p1+@p2
      set @p4     = Substring(@p3,1,5)
      set @p5     = Substring(@p3,6,6)
      ---------------------------
      set @Campo2 = @p4+'.'+@p5;
      --------------------------

	  --select @Campo2, @p5, @p1
      --return

/*
   {
      Campo 3 - composto pelas posicoes 16 a 25 do campo livre
      e DV (modulo10) deste campo
   }
*/

     set @p1     = Substring(@codigo_barra,35,10);
     set @p2     = dbo.Modulo10(@p1);
     set @p3     = @p1+@p2;
     set @p4     = Substring(@p3,1,5);
     set @p5     = Substring(@p3,6,6);
     ---------------------------
     set @Campo3 = @p4+'.'+@p5;
     ---------------------------

	 --select @Campo3 

/*
   {
      Campo 4 - digito verificador do @codigo_barra de barras
   }
*/

      ------------------------------------------
      set @Campo4 = Substring(@codigo_barra,5,1)
      ------------------------------------------

	  --select @codigo_barra
	  --select @Campo4

/*
   {
      Campo 5 - composto pelo valor nominal do documento, sem indicacao
      de zeros a esquerda e sem edicao (sem ponto e virgula). Quando se
      tratar de valor zerado, a representacao deve ser 000 (tres zeros).
   }
*/

   --------------------------------------------
   set @Campo5 = Substring(@codigo_barra,6,14);
   --------------------------------------------
   --select @Campo5

   -------------------------------------------------------------

   set @linha_digitavel = ltrim(rtrim(@Campo1)) + ' ' + 
                          ltrim(rtrim(@Campo2)) + ' ' + 
						  ltrim(rtrim(@Campo3)) + ' ' + 
						  ltrim(rtrim(@Campo4)) + ' ' + 
						  ltrim(rtrim(@Campo5))

   --------------------------------------------------------------
						  

--select @linha_digitavel as Linha_Digitavel, 
--       @codigo_barra    as Codigo_Barra

--return

----------------------------------------------------------------------------------


-- 10) Saída para o front-end
/*
  SELECT
    Numero_Banco       = @numero_banco,
    Carteira           = @carteira,
    Agencia            = @agencia,
    Conta              = @conta,
    NossoNumero        = @nosso_numero,
    NossoNumeroComDV   = @nosso_numero + @dac_nosso_numero,
    Campo_Livre        = @campo_livre,
    Codigo_Barras      = @codigo_barra,   -- 44 dígitos
    Linha_Digitavel    = @linha_digitavel,-- 47 caracteres formatados
    FatorVencimento    = @fator_vencimento,
    ValorTitulo44_10   = @valor_titulo,
    Vencimento         = @dt_vencimento,
    Cedente            = @cedente;
    */

    /* ===================== PERSISTÊNCIA NA Documento_Receber_Boleto ===================== */

--return

-------------------------
--documento_receber_boleto
---------------------------
BEGIN TRY
  BEGIN TRAN;

  IF ISNULL(@cd_documento_receber,0) = 0
  BEGIN
      RAISERROR('Não foi possível localizar cd_documento_receber para a nota %d.', 16, 1, @cd_nota_saida);
  END

  --1) Atualiza o Documento a Receber com o Número Bancário

  --select @cd_nosso_numero, @cd_documento_receber

  update
    documento_receber
  set
    cd_portador               = @cd_portador,
    cd_banco_documento_recebe = @cd_nosso_numero,
    cd_nosso_numero_documento = @cd_nosso_numero,
    cd_banco_doc_receber      = @cd_nosso_numero,
    cd_digito_bancario        = @dac_nosso_numero,
    ic_envio_documento        = 'S',
    cd_conta_banco_remessa    = @cd_conta_banco
    
  from
    documento_receber
  where
    cd_documento_receber = @cd_documento_receber

  --select cd_banco_documento_recebe from documento_receber where cd_documento_receber = @cd_documento_receber

  -- 2) Nome de arquivo sugerido (ajuste se já tiver padrão na sua app)
  DECLARE @nm_arquivo_boleto VARCHAR(200) =
      'BOL_' + RIGHT(REPLICATE('0',8) + CAST(@cd_documento_receber AS VARCHAR(20)),8)
      + '_' + CONVERT(VARCHAR(8), @dt_vencimento, 112) + '.pdf';

  -- 3) UPSERT: se já existe boleto para esse documento, atualiza; senão, insere
  IF EXISTS (SELECT 1
             FROM Documento_Receber_Boleto
             WHERE cd_documento_receber = @cd_documento_receber)
  BEGIN
      UPDATE Documento_Receber_Boleto
         SET cd_nosso_numero     = @cd_nosso_numero,         -- base (sem DV)
             dt_ultima_reemissao = GETDATE(),
             cd_codigo_barra     = @codigo_barra,
             cd_linha_digitavel  = @linha_digitavel,
             cd_usuario          = @cd_usuario,               -- último usuário (alteração)
             dt_usuario          = GETDATE(),
             nm_arquivo_boleto   = COALESCE(nm_arquivo_boleto, @nm_arquivo_boleto)
       WHERE cd_documento_receber = @cd_documento_receber;
  END
  ELSE
  BEGIN
      INSERT INTO Documento_Receber_Boleto
      (
        cd_documento_receber,
        cd_nosso_numero,
        dt_emissao_boleto,
        dt_ultima_reemissao,
        cd_codigo_barra,
        cd_linha_digitavel,
        cd_usuario_inclusao,
        dt_usuario_inclusao,
        cd_usuario,
        dt_usuario,
        nm_arquivo_boleto
      )
      VALUES
      (
        @cd_documento_receber,
        @cd_nosso_numero,       -- base (sem DV). Se preferir com DV, use: CAST(@nosso_numero + @dac_nosso_numero AS VARCHAR(20))
        GETDATE(),
        NULL,
        @codigo_barra,
        @linha_digitavel,
        @cd_usuario,
        GETDATE(),
        @cd_usuario,
        GETDATE(),
        @nm_arquivo_boleto
      );
  END

  COMMIT;

  -- 4) (Opcional) Retornar o registro para o front-end já com tudo que ele precisa
  SELECT
      drb.cd_documento_receber,
      drb.cd_nosso_numero,
      drb.cd_codigo_barra,
      drb.cd_linha_digitavel,
      drb.dt_emissao_boleto,
      drb.dt_ultima_reemissao,
      drb.nm_arquivo_boleto,
      -- Extras úteis para impressão:
      Numero_Banco     = @numero_banco,
      Carteira         = @carteira,
      Agencia          = @agencia,
      Conta            = @conta,
      NossoNumero      = @nosso_numero,
      NossoNumeroComDV = @nosso_numero + @dac_nosso_numero,
      ValorTitulo44_10 = @valor_titulo,
      FatorVencimento  = RIGHT(REPLICATE('0',4) + CAST(@vl_fator AS VARCHAR(8)),4),
      Vencimento       = @dt_vencimento
  FROM Documento_Receber_Boleto drb
  WHERE drb.cd_documento_receber = @cd_documento_receber;

END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE(),
          @ErrNum INT = ERROR_NUMBER();
  RAISERROR('Falha ao gravar boleto: %s (Erro %d)', 16, 1, @ErrMsg, @ErrNum);
END CATCH
/* ============================================================================= */

go

--select cd_documento_receber, cd_banco_documento_recebe from documento_receber order by cd_banco_documento_recebe

--delete from documento_receber where cd_documento_receber = 10
--go

--select * from documento_receber where cd_identificacao = '1413-1'
--select * from nota_saida where cd_identificacao_nota_saida = 1413
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_geracao_automatica_boleto_caixa  1,113
--go
--exec pr_geracao_automatica_boleto_caixa  6,113
------------------------------------------------------------------------------
