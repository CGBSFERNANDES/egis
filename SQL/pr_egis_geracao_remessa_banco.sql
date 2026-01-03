--BANCO DA EMPRESA/CLIENTE
--   
--use EGISSQL_355

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_geracao_remessa_banco' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_geracao_remessa_banco

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_geracao_remessa_banco
-------------------------------------------------------------------------------
--pr_egis_geracao_remessa_banco
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
--                   Geração de Remessa de Banco
--
--Data             : 03.09.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_geracao_remessa_banco
@json nvarchar(max) = ''

--with encryption


as

SET NOCOUNT ON;

--select @json

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

-- 4) Validação

IF ISJSON(@json) <> 1
BEGIN
    THROW 50001, 'JSON inválido em @json.', 1;
    RETURN;
END


declare @cd_empresa             int
declare @cd_parametro           int = 0
declare @cd_documento           int = 0
declare @cd_item_documento      int
declare @cd_usuario             int 
declare @dt_hoje                datetime
declare @dt_inicial             datetime 
declare @dt_final               datetime
declare @cd_ano                 int = 0
declare @cd_mes                 int = 0
declare @cd_conta_banco         int = 0
declare @cd_portador            int = 0
declare @nr_sequencial_remessa  INT     = NULL
declare @id_sistema_remessa     CHAR(2) = NULL;
declare @cd_ultimo_contador     int     = 0
declare @cd_documento_magnetico int     = 0

----------------------------------------------------------------------------------------------------------------

set @cd_empresa             = 0
set @cd_parametro           = 0
set @cd_documento           = 0
set @cd_item_documento      = 0
set @dt_hoje                = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano                 = year(getdate())
set @cd_mes                 = month(getdate())  
set @cd_documento_magnetico = 0


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
select @cd_conta_banco         = valor from #json where campo = 'cd_conta_banco'


if @cd_conta_banco>0
begin
  select 
    top 1 
    @cd_documento_magnetico = isnull(cd_documento_magnetico,0)
  from
    Conta_Agencia_Banco
  where
    cd_conta_banco = @cd_conta_banco
end

--Ultimo Contador-----

select
  @cd_ultimo_contador = isnull(@cd_ultimo_contador,0)
from
  Sequencia_Arquivo_Magnetico
where
  cd_documento_magnetico = @cd_documento_magnetico
 
set @nr_sequencial_remessa = isnull(@cd_ultimo_contador,0) + 1

/*
select * from Sequencia_Arquivo_Magnetico


select @nr_sequencial_remessa = TRY_CONVERT(INT, valor)
FROM #json WHERE campo = 'nr_sequencial_remessa';

SELECT @id_sistema_remessa = LEFT(TRY_CONVERT(VARCHAR(10), valor), 2)
FROM #json WHERE campo = 'id_sistema_remessa';

IF @nr_sequencial_remessa IS NULL OR @nr_sequencial_remessa < 1 OR @nr_sequencial_remessa > 9999999
  SET @nr_sequencial_remessa = 1;

IF @id_sistema_remessa IS NULL OR LTRIM(RTRIM(@id_sistema_remessa)) = ''
  SET @id_sistema_remessa = 'MX';

*/


if isnull(@cd_parametro,0) = 1
begin
    select
   c.*,
   b.nm_fantasia_banco,
   d.nm_documento_magnetico,
   d.nm_mascara_arquivo,
   d.nm_local_arquivo,
   d.nm_extensao_arquivo

  from
    conta_agencia_banco c
    inner join banco b on b.cd_banco = c.cd_banco
    inner join Documento_Arquivo_Magnetico d on d.cd_documento_magnetico = c.cd_documento_magnetico
  where
   isnull(c.cd_documento_magnetico,0)>0
  order by
    c.nm_conta_banco

  return
end
-----------------------------------------------------------------------------------------
IF @cd_conta_banco IS NULL OR @cd_conta_banco = 0
   THROW 50002, 'Informe cd_conta_banco no JSON.', 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_empresa   = dbo.fn_empresa()
set @cd_parametro = ISNULL(@cd_parametro,0)

---------------------------------------------------------------------------
-- 2) Coleta de parâmetros da empresa e conta
---------------------------------------------------------------------------

declare  
            @nm_fantasia_empresa      varchar(30), 
            @nm_empresa               varchar(80),
    		@cd_cnpj_empresa          varchar(14),
            @cd_cnpj_empresa_1        varchar(14),
    		@cd_identificacao_empresa varchar(50) = '',
    		@cd_banco                 int = 0,
    		@nm_banco                 varchar(40),
            @cd_numero_banco          int = 0,
            @agencia                  VARCHAR(4),
            @conta                    VARCHAR(5),
            @dv_conta                 CHAR(1),
            @carteira                 VARCHAR(3),
            @codigo_cedente           VARCHAR(20); -- se aplicável


--Empresa--

select      
  @nm_empresa          = nm_empresa,
  @nm_fantasia_empresa = nm_fantasia_empresa,      
  @cd_cnpj_empresa     = case when cd_empresa in (360,370,371,372,373,374,376) then '03418924000109' else cd_cgc_empresa end,
  @cd_cnpj_empresa_1   = cd_cgc_empresa
from      
  EgisAdmin.dbo.Empresa      
where      
  cd_empresa = @cd_empresa      


--Banco---

-- Dados bancários da conta + carteira padrão (ajuste se sua carteira vier de outro lugar)

SELECT
  @cd_banco                 = isnull(cab.cd_banco,0),
  @cd_portador              = isnull(cab.cd_portador,0),
  @agencia                  = RIGHT(REPLICATE('0',4) + REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(a.cd_numero_agencia_banco,''))),'-',''),'.',''),4),
  @conta                    = RIGHT(REPLICATE('0',5) + REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(cab.nm_conta_banco,''))),'-',''),'.',''),5),
  @dv_conta                 = RIGHT(REPLICATE('0',1) + LTRIM(RTRIM(ISNULL(cab.cd_dac_conta_banco,''))),1),
  @carteira                 = RIGHT(REPLICATE('0',3) + CAST(ISNULL(cob.cd_num_carteira_cobranca,0) AS VARCHAR(3)),3),
  @cd_identificacao_empresa = isnull(cab.nm_convenio_cobranca,'')
FROM Conta_Agencia_Banco cab
JOIN Agencia_Banco a                 ON a.cd_agencia_banco = cab.cd_agencia_banco
LEFT JOIN conta_carteira_cobranca cc ON cc.cd_conta_banco = cab.cd_conta_banco
LEFT JOIN carteira_cobranca cob      ON cob.cd_carteira_cobranca = cc.cd_carteira_cobranca
WHERE
  cab.cd_conta_banco = @cd_conta_banco;

-----------

select
  @cd_identificacao_empresa = case when @cd_identificacao_empresa='' then
                                isnull(cd_identificacao_empresa,'')
                              else
                                cd_identificacao_empresa
                              end,
  @nm_banco                 = nm_banco,
  @cd_numero_banco          = cd_numero_banco
from  
  Banco
where
  cd_banco = @cd_banco
 
--select @cd_conta_banco, @cd_portador, @cd_numero_banco
--return

-----------------
--3) Documentos para Enviar para o Banco --------------------------------------------------
------------------

select
  dr.*,
  --Dados do Cliente-----------------------------------------------------------------------
  c.nm_fantasia,
  c.nm_razao_social,
  c.cd_cnpj,
  c.cd_inscestadual,
  c.nm_endereco,
  c.cd_numero_endereco,
  c.nm_complemento_endereco,
  c.nm_bairro,
  c.cd_cep,
  c.nm_pais,
  c.nm_estado,
  c.sg_estado,
  c.nm_cidade,
  c.cd_tipo_pessoa

into
  #DocumentoRemessa

from      
  Documento_Receber dr with(nolock)

  left outer join Conta_Agencia_Banco cag           with(nolock) on cag.cd_conta_banco     = dr.cd_conta_banco_remessa
  left outer join Agencia_Banco a                   with(nolock) on a.cd_banco             = cag.cd_banco and
                                                                    a.cd_agencia_banco     = cag.cd_agencia_banco
  left outer join Banco b                           with(nolock) on b.cd_banco             = a.cd_banco
  left outer join Banco_Boleto bb                   with(nolock) on bb.cd_banco            = b.cd_banco
  inner join vw_destinatario c                      with(nolock) on c.cd_destinatario      = dr.cd_cliente and
                                                                    c.cd_tipo_destinatario = dr.cd_tipo_destinatario
where      
   isnull(dr.vl_saldo_documento,0)>0 
   and
   dr.dt_cancelamento_documento is null
   and
   dr.cd_conta_banco_remessa = @cd_conta_banco
   and
   isnull(dr.cd_remessa_banco,0) = 0

   --select * from documento_receber

--select * from #DocumentoRemessa
--return
    
  --    dr.cd_portador = @cd_portador
  --and dr.dt_cancelamento_documento is null      
  --and dr.ic_envio_documento  = 'S'      
  --and isnull(dr.vl_saldo_documento,0)  > 0    
  --and dr.dt_devolucao_documento is null  
  --and dr.ic_emissao_documento = 'N'  
   --delete from documento_receber where cd_portador = 999
   --select * from documento_receber
   

IF NOT EXISTS (SELECT top 1 cd_documento_receber FROM #DocumentoRemessa)
BEGIN
  --RAISERROR('Nenhum Documento a Receber para remessa nesta conta/portador.',16,1);  
  SELECT 'Nenhum Documento a Receber para remessa nesta conta/portador.' AS ArquivoRemessa;
  RETURN;
END

-----------------------------------------------------
--select * from #DocumentoRemessa
-----------------------------------------------------

---------------------------------------------------------------------------
-- 4) Base do arquivo (linhas) – NSR = Número Sequencial do Registro
---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#RemessaLinhas') IS NOT NULL DROP TABLE #RemessaLinhas;
CREATE TABLE #RemessaLinhas (
nsr INT IDENTITY(1,1) PRIMARY KEY,
linha VARCHAR(402) -- 400 + NSR(6) – deixamos folga; ajustamos depois
);


-- Helpers de formatação
DECLARE @hoje        DATE = CONVERT(date, GETDATE());
DECLARE @data_hoje_6 CHAR(6) =
      RIGHT('0' + CONVERT(VARCHAR(2), DAY(@hoje)),   2)
    + RIGHT('0' + CONVERT(VARCHAR(2), MONTH(@hoje)), 2)
    + RIGHT('0' + CONVERT(VARCHAR(2), (YEAR(@hoje) % 100)), 2);

--select @hoje, @data_hoje_6
--return

-- Nome da empresa no header: 30 colunas
DECLARE @nm_empresa_30 CHAR(30) = LEFT(ISNULL(@nm_empresa,''),30);
-- Conta do header = 7 dígitos (sem DV); se você guarda @conta com 5/6 dígitos, padronize aqui:
DECLARE @conta7 CHAR(7) = RIGHT('0000000' + REPLACE(REPLACE(@conta,'-',''),'.',''), 7);


--> Cabeçalho

---------------------------------------------------------------------------
-- 5) HEADER (registro "01REMESSA…" do Itaú)
-- Este header reproduz o padrão visto no seu arquivo-exemplo.
---------------------------------------------------------------------------
DECLARE @header VARCHAR(400) = '';
DECLARE @banco3 CHAR(3) = RIGHT('000' + CAST(ISNULL(@cd_numero_banco,0) AS VARCHAR(3)), 3);

---Tratamento do Header---------------------------------------------------------------------

if @cd_numero_banco = 341
begin

  SET @header =
    '01'      +                                           -- pos. 01-02
    'REMESSA' +                                           -- pos. 03-09
    '01' +                                                -- pos. 10-11
    RIGHT(LEFT('COBRANCA' + REPLICATE(' ',15),15),15) +   -- pos. 12-26
    RIGHT('0000' + @agencia, 4) +                         -- pos. 27-30
    @conta7 + @dv_conta +                                 -- pos. 31-38 (conta 7) + pos. 39 (DV) = 8
    REPLICATE(' ', 8) +                                   -- pos. 39-46 (cód. cedente / uso do banco)
    RIGHT(LEFT(@nm_empresa_30 + REPLICATE(' ',30),30),30) +  -- pos. 47-76
    '341' + RIGHT(LEFT('BANCO ITAU SA' + REPLICATE(' ',15),15),15) + -- pos. 77-94
    @data_hoje_6 +                                        -- pos. 95-100 (DDMMAAAA)
    REPLICATE(' ', 400 - 100);  -- completa até 400       -- pos. 101-400     

end

--Bradesco

if @cd_numero_banco=237
begin


IF @nr_sequencial_remessa IS NULL OR @nr_sequencial_remessa < 1 OR @nr_sequencial_remessa > 9999999
  SET @nr_sequencial_remessa = 1;

IF @id_sistema_remessa IS NULL OR LTRIM(RTRIM(@id_sistema_remessa)) = ''
  SET @id_sistema_remessa = 'MX';

  -- Bradesco CNAB400 header
  DECLARE @cod_empresa_20 CHAR(20) =
     RIGHT(REPLICATE('0',20) + REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ISNULL(@cd_identificacao_empresa,''))),'-',''),'.',''),'/',''), 20);

  set @nm_empresa_30 = LEFT(UPPER(ISNULL(@nm_empresa,'')) + REPLICATE(' ',30), 30);
  DECLARE @seq7 CHAR(7) = RIGHT('0000000' + CAST(@nr_sequencial_remessa AS VARCHAR(7)), 7);

  SET @header =
      '01' +
      'REMESSA' +
      '01' +
      LEFT('COBRANCA' + REPLICATE(' ',15), 15) +
      @cod_empresa_20 +
      @nm_empresa_30 +
      '237' +
      LEFT('BRADESCO' + REPLICATE(' ',15), 15) +
      @data_hoje_6 +         -- DDMMAA
      REPLICATE(' ',8) +
      @id_sistema_remessa +  -- ex MX
      @seq7 +                -- ex 0000261
      REPLICATE(' ', 394 - 117);  -- completa até 394 (NSR vai depois)

end


INSERT INTO #RemessaLinhas(linha) VALUES(@header);


--select * from #RemessaLinhas
--return


---------------------------------------------------------------------------


--> Detalhe
---------------------------------------------------------------------------
-- 6) DETALHES (um por documento) – Registro tipo "1" (CNAB 400 Itaú)
-- Campos essenciais (ajuste mapeamentos conforme sua base):
-- • Seu Número (nº do documento)
-- • Nosso Número (8) + DV
-- • Vencimento (DDMMAA)
-- • Valor (13,2 sem pontuação)
-- • Carteira, Agência, Conta, etc.
---------------------------------------------------------------------------
DECLARE
  @nome_sacado   CHAR(30),
  @endereco      CHAR(40),
  @bairro        CHAR(12),
  @cep8          CHAR(8),
  @cidade        CHAR(15),
  @uf            CHAR(2);


DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
SELECT 
   dr.cd_documento_receber,
   dr.cd_nota_saida,
   dr.cd_banco_documento_recebe,
   dr.cd_digito_bancario,
   ISNULL(dr.vl_saldo_documento, ISNULL(dr.vl_documento_receber,0))            AS valor,
   COALESCE(dr.dt_vencimento_documento, dr.dt_vencimento_documento, dr.dt_emissao_documento, CONVERT(date, GETDATE()))
                                                                               AS dt_venc,
   COALESCE(dr.cd_identificacao, CAST(dr.cd_documento_receber AS VARCHAR(20))) AS seu_numero

FROM
  #DocumentoRemessa dr

ORDER BY dr.cd_documento_receber;

--documento_receber--


DECLARE @cd_documento_receber       INT = 0,
        @cd_nota_saida              INT = 0,
        @valor                      DECIMAL(15,2),
        @dt_venc                    DATE,
        @seu_numero                 VARCHAR(20),
        @cd_banco_documento_recebe  VARCHAR(20),
        @cd_digito_bancario         CHAR(1)

OPEN cur;
FETCH NEXT FROM cur INTO @cd_documento_receber, 
                         @cd_nota_saida, 
                         @cd_banco_documento_recebe,
                         @cd_digito_bancario,
                         @valor, @dt_venc, @seu_numero

WHILE @@FETCH_STATUS = 0
BEGIN

  -- Busca do nosso número --

  DECLARE 
     @nosso_numero_base VARCHAR(8),
     @dv_nosso          CHAR(1),
     @nosso_com_dv      VARCHAR(9);

  SET @nosso_numero_base = @cd_banco_documento_recebe
  SET @dv_nosso          = @cd_digito_bancario
  SET @nosso_com_dv      = @cd_banco_documento_recebe + @cd_digito_bancario

---------------------------------------------------------------------------
-- Valor (13,2) sem pontuação

--Calculo Juros--

declare @pc_juros float = 0.00
select 
  top 1
  @pc_juros = isnull(pc_taxa_cobranca_banco,0)
from
  Parametro_Financeiro

declare @jurosCalculado char(13)

DECLARE @valor_13 CHAR(13) = RIGHT(REPLICATE('0',13) + REPLACE(REPLACE(CONVERT(VARCHAR(20), CONVERT(NUMERIC(13,2), ROUND(@valor,2)), 2),'.',''),',',''),13);
----------------------------------

-- Data de vencimento DDMMAA
-- Data de vencimento em DDMMAA (compatível 2016)
DECLARE @venc DATE = CAST(@dt_venc AS DATE);  -- garante só a data

-- (opcional) fallback se @dt_venc vier NULL
IF @venc IS NULL SET @venc = CAST(GETDATE() AS DATE);

DECLARE @venc_6 CHAR(6) =
      RIGHT('0' + CONVERT(VARCHAR(2), DAY(@venc)),   2)
    + RIGHT('0' + CONVERT(VARCHAR(2), MONTH(@venc)), 2)
    + RIGHT('0' + CONVERT(VARCHAR(2), (YEAR(@venc) % 100)), 2);

 --select @venc_6

-- Seu número (10 pos) – ajuste conforme contrato
DECLARE @seu_num_10 CHAR(10) = LEFT(RIGHT(REPLICATE('0',10) + REPLACE(REPLACE(@seu_numero,'-',''),'.',''),10),10);

--Dados do Cliente/Destinatário--

-- buscar do recebedor/sacado do título
declare @TipoDest varchar(2) 
DECLARE @vlrjuros CHAR(13) = RIGHT(REPLICATE('0',13) + REPLACE(REPLACE(CONVERT(VARCHAR(20), CONVERT(NUMERIC(13,2), ROUND(@valor,2)), 2),'.',''),',',''),13)

SELECT
  @nome_sacado    = LEFT(ISNULL(dr.nm_razao_social, dr.nm_fantasia), 30),
  @endereco       = LEFT(ISNULL(dr.nm_endereco + ', ' + dr.cd_numero_endereco, ''), 40),
  @bairro         = LEFT(ISNULL(dr.nm_bairro,''), 12),
  @cep8           = RIGHT(REPLICATE('0',8) + REPLACE(REPLACE(ISNULL(dr.cd_cep,''),'-',''),'.',''), 8),
  @cidade         = LEFT(ISNULL(dr.nm_cidade,''), 15),
  @uf             = LEFT(ISNULL(dr.sg_estado,''), 2),
  @TipoDest       = LEFT(ISNULL(dr.cd_tipo_pessoa,'0'), 2),
  @jurosCalculado = RIGHT(REPLICATE('0',13) + REPLACE(REPLACE(CONVERT(VARCHAR(20), CONVERT(NUMERIC(13,2), ROUND((@valor * (@pc_juros/100)/30),2)), 2),'.',''),',',''),13)
FROM
  #DocumentoRemessa dr
where
  cd_documento_receber = @cd_documento_receber

-- Montagem do registro detalhe (tipo "1").
-- OBS: O Itaú tem várias variantes; os campos abaixo cobrem o essencial.
DECLARE @det VARCHAR(400) = '';
-------------------------------


-- Preparos
DECLARE @cnpj14 CHAR(14) = RIGHT(REPLICATE('0',14) + ISNULL(@cd_cnpj_empresa,''), 14);
DECLARE @cnpj14_1 CHAR(14) = RIGHT(REPLICATE('0',14) + ISNULL(@cd_cnpj_empresa_1,''), 14);
DECLARE @ag4    CHAR(4)  = RIGHT('0000' + @agencia, 4);
DECLARE @dv1    CHAR(1)  = @dv_conta;

-- Nosso número base (8) + DV (1)
DECLARE @nosso8 CHAR(8) = RIGHT('00000000' + @nosso_numero_base, 8);
DECLARE @nosso9 CHAR(9) = @nosso8 + @dv_nosso;

-- “Seu número” curto (até 6/7 dígitos) – para espelhar o seu arquivo bom, use o que você espera ver ali
DECLARE @seu_curto CHAR(6) = RIGHT('000000' + REPLACE(REPLACE(@seu_numero,'-',''),'/',''), 6);

-- Valor do título (13,2) → 13 dígitos inteiros sem pontuação
DECLARE @valor13 CHAR(13) = RIGHT(REPLICATE('0',13) + REPLACE(REPLACE(CONVERT(VARCHAR(20), CONVERT(NUMERIC(13,2), ROUND(@valor,2)), 2),'.',''),',',''),13);

-- Datas
DECLARE @emiss_6 CHAR(6) = @data_hoje_6; -- já calculado no header

-- Sacado (upper + pad)
DECLARE @nome30   CHAR(30) = RIGHT(LEFT(UPPER(ISNULL(@nome_sacado,'')) + REPLICATE(' ',30),30),30);
DECLARE @ender40  CHAR(40) = RIGHT(LEFT(UPPER(ISNULL(@endereco  ,'')) + REPLICATE(' ',40),40),40);
DECLARE @bairro12 CHAR(12) = RIGHT(LEFT(UPPER(ISNULL(@bairro    ,'')) + REPLICATE(' ',12),12),12);
DECLARE @cidade15 CHAR(15) = RIGHT(LEFT(UPPER(ISNULL(@cidade   ,'')) + REPLICATE(' ',15),15),15);
DECLARE @uf2      CHAR(2)  = RIGHT(LEFT(UPPER(ISNULL(@uf       ,'')) + REPLICATE(' ',2), 2),2);

--Banco Itaú----------------------------------------------------------------------------------------

if @cd_numero_banco=341
begin

-- Montagem POSICIONAL do DETALHE (394 colunas)
  SET @det  =
    '1' +                 -- 001 (tipo)
    '02' +                -- 002-003 (CNPJ do cedente; use '01' se for CPF)
    @cnpj14 +             -- 004-017
    @ag4 +                -- 018-021
    @conta7 + @dv1 +      -- 022-029
    REPLICATE(' ', 8) +   -- 030-037 (uso do banco)  <<< mantém 8 espaços como no header
    'MC' + @seu_curto +          -- 038-043  (espelhando seu arquivo bom: “337114” aparece logo aqui)
    REPLICATE(' ', 17) +  -- 044-062  (uso do banco)
    
    --'00005000' +          -- 063-070  (ex.: multa/juros dia – igual ao seu bom)
    @nosso8 +
    REPLICATE(' ', 12) +  -- 071-082
    '0109' +              -- 083-086  (carteira/espécie conforme contrato – seu bom traz “0109”)
    REPLICATE(' ', 21) +  -- 087-107
    'I01' +               -- 108-110  (código ocorrência Itaú – igual ao seu bom)
    RIGHT(LEFT('MC' + @seu_curto + REPLICATE(' ',10),10),10) + -- 111-122 (seu número expandido)
    RIGHT(@venc_6,6) +  -- 127-132 (ex.: “191025” no seu bom → dia 19/10/25)
    @valor13 +            -- 133-145 (valor título)
    '341' +               -- 146-148 (banco)
    REPLICATE(' ', 5) +   -- 149-153
    '01' +                -- 154-155 (espécie)
    'N' +                 -- 156 (aceite)
    @emiss_6 +            -- 157-162 (emissão)
    '43'   +              -- 1° Instrução
    '59'   +              -- 2° Instrução
    @jurosCalculado    +  -- 163-224 (juros/descontos/outros)
    REPLICATE('0', 46) +
    @TipoDest +
    @cnpj14_1 +
    @nome30 +             -- 225-254
    REPLICATE(' ', 10) +
    @ender40 +            -- 255-294
    @bairro12 +           -- 295-306
    @cep8 +               -- 307-314
    @cidade15 +           -- 315-329
    @uf2 +                -- 330-331
    REPLICATE(' ', 394-331); -- 332-394 (filler)
    
end


--Bradesco-------------------------------------------------------------------

if @cd_numero_banco = 237
begin
  DECLARE @carteira2 CHAR(2) = RIGHT('00' + RIGHT(ISNULL(@carteira,'0'),2), 2);
  --DECLARE @ag4      CHAR(4) = RIGHT('0000' + @agencia, 4);

  -- Nosso número Bradesco: 11 + DV
  DECLARE @nosso11 CHAR(11) = RIGHT(REPLICATE('0',11) + ISNULL(@nosso_numero_base,''), 11);
  DECLARE @dvnosso CHAR(1)  = ISNULL(@dv_nosso,'0');

  -- 021-037: 0 + carteira(2) + agencia(4) + conta(7) + dv(1) + 00  => 17
  DECLARE @id_empresa_17 CHAR(17) = '0' + @carteira2 + @ag4 + @conta7 + @dv_conta + '00';

  -- 038-062: controle do participante (25)
  DECLARE @controle25 CHAR(25) = LEFT(ISNULL(@seu_numero,'') + REPLICATE(' ',25), 25);

  -- seu número (10) em posições internas do detalhe (uso comum)
  DECLARE @seu10 CHAR(10) = RIGHT(REPLICATE('0',10) + LEFT(REPLACE(REPLACE(ISNULL(@seu_numero,''),'-',''),'/',''),10), 10);

  -- Montagem mínima com campos-chave + filler até 394
  SET @det =
      '1' +
      REPLICATE('0', 19) +       -- 002-020 (débito automático)
      @id_empresa_17 +            -- 021-037
      'MX' + @controle25 +               -- 038-062
      '237' +                     -- 063-065
      '0' +                       -- 066 (sem multa)
      '0000' +                    -- 067-070
      @nosso11 +                  -- 071-081
      @dvnosso +                  -- 082
      REPLICATE('0', 10) +        -- 083-092 desconto bonificação/dia
      '2' +                       -- 093 (cliente emite boleto)
      ' ' +                       -- 094
      REPLICATE(' ', 15) +        -- 095-109
      @seu10 +                    -- 110-119
      '0' +                       -- 120
      @venc_6 +                   -- 121-126 DDMMAA
      @valor13 +                  -- 127-139 valor (13)
      REPLICATE(' ', 394-139);    -- completa até 394


end

--Fim de Detalhe-------------------------------------------------------------------------------------

-- Ajusta para 394 e insere (o NSR será anexado depois)
SET @det = LEFT(@det + REPLICATE(' ', 394), 394);




IF isnull(@det,'')<>''
   INSERT INTO #RemessaLinhas(linha) VALUES(@det);

FETCH NEXT FROM cur INTO @cd_documento_receber, 
                         @cd_nota_saida, 
                         @cd_banco_documento_recebe,
                         @cd_digito_bancario,
                         @valor, @dt_venc, @seu_numero
END

CLOSE cur; DEALLOCATE cur;

--> Rodapé

---------------------------------------------------------------------------
-- 7) TRAILER
---------------------------------------------------------------------------
DECLARE @trl VARCHAR(400) = '9' + REPLICATE(' ', 393); -- até 394

IF isnull(@trl,'')<>''
  INSERT INTO #RemessaLinhas(linha) VALUES(@trl);

---------------------------------------------------------------------------
-- 8) Anexa o NSR (número sequencial) em 6 dígitos ao final de cada linha (pos. 395-400)
---------------------------------------------------------------------------
UPDATE #RemessaLinhas
SET linha = LEFT(linha, 394) + RIGHT(REPLICATE('0',6) + CAST(nsr AS VARCHAR(6)), 6);

---------------------------------------------------------------------------
-- 9) Saídas: (A) Linhas; (B) Arquivo completo com CRLF
-- 9) Saídas: (A) Linhas; (B) Arquivo completo com CRLF (sem XML)

--Verificação--
-- 400 colunas em TODAS as linhas?
--SELECT nsr, LEN(linha) AS len, SUBSTRING(linha,1,1) AS first_char, RIGHT(linha,6) AS nsr_sufixo-
--FROM #RemessaLinhas;

-- HEADER confere? (trecho em torno de agência/conta/DV/espaços)
--SELECT SUBSTRING(linha, 27, 4)   AS agencia,
--       SUBSTRING(linha, 31, 8)   AS conta_dv_8,
--       SUBSTRING(linha, 39, 8)   AS espacos_cedente
--FROM #RemessaLinhas WHERE nsr = 1;
---------------------------------------------


--SELECT nsr, linha
--FROM #RemessaLinhas
--ORDER BY nsr;

DECLARE @ArquivoRemessa VARCHAR(MAX) = '';

SELECT @ArquivoRemessa = @ArquivoRemessa + linha + CHAR(13) + CHAR(10)
FROM #RemessaLinhas
ORDER BY nsr;

  ---Atualização do Arquivo de Remessa--------------------------------------
  
  declare @cd_remessa_banco int = 0
  select @cd_remessa_banco = max(cd_remessa_banco)
  from
    remessa_banco_receber

  set @cd_remessa_banco = isnull(@cd_remessa_banco,0) + 1

  insert into remessa_banco_receber
  select
    @cd_remessa_banco   as cd_remessa_banco,
    @cd_portador        as cd_portador,
    @cd_conta_banco     as cd_conta_banco,
    @dt_hoje            as dt_remessa_banco,
    @cd_usuario         as cd_usuario_remessa_banco,
    0.00                as qt_docto_remessa_banco,
    0.00                as vl_total_remessa_banco,
    cast('' as varchar) as nm_obs_remessa_banco,
    @cd_usuario         as cd_usuario,
    getdate()           as dt_usuario

   
    ---------------------------------------------------------
    
    update
      documento_receber
     set
       cd_remessa_banco = @cd_remessa_banco
    from
      documento_receber d
    where
      d.cd_documento_receber in ( select dr.cd_documento_receber from #DocumentoRemessa dr
                                  where
                                    dr.cd_documento_receber = d.cd_documento_receber )

      and
      isnull(d.cd_remessa_banco,0) = 0



set @ArquivoRemessa = isnull(@ArquivoRemessa,'')

if @ArquivoRemessa = ''
begin
  set @ArquivoRemessa = 'Não Existem Documentos para Gerar Remessa !' 
end

------------------------------------------
SELECT @ArquivoRemessa AS ArquivoRemessa;
------------------------------------------
/*
DECLARE @ArquivoRemessa NVARCHAR(MAX) = N'';

SELECT @ArquivoRemessa = @ArquivoRemessa + linha + CHAR(13) + CHAR(10)
FROM #RemessaLinhas
ORDER BY nsr;

SELECT @ArquivoRemessa AS ArquivoRemessa;


;WITH C AS (
  SELECT (linha + CHAR(13)+CHAR(10)) AS part, nsr
  FROM #RemessaLinhas
)
SELECT (
  SELECT [text()] = part
  FROM C
  ORDER BY nsr
  FOR XML PATH('')
) AS ArquivoRemessa;
*/

--> Grava o Arquivo Texto <--
--> Front
--> Tabela --> Remessa_Itau_001_03092025

GO

--use egissql_354
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_geracao_remessa_banco 
------------------------------------------------------------------------------
go

--go

--use egissql_370

/*
EXEC pr_egis_geracao_remessa_banco 
    @json = N'[
      {     
        "cd_parametro": 1     
      }
    ]'
*/

--EXEC pr_egis_geracao_remessa_banco 
--    @json = N'[
--      {
        
--        "cd_conta_banco": 1,
--        "cd_usuario": 1        
--      }
--    ]'
----go







