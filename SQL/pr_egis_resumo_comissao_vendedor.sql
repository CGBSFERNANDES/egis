IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_resumo_comissao_vendedor' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_resumo_comissao_vendedor

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_resumo_comissao_vendedor
-------------------------------------------------------------------------------
--pr_egis_resumo_comissao_vendedor
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2018
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008
--Autor(es)        : Carlos Cardoso Fernandes
--                   
--
--Banco de Dados   : Egissql
--
--Objetivo         : Resumo de Venda no Período por Produto
--
--Data             : 31.05.2017
--Alteração        : 12.06.2017
--
-- 13.02.2018 - quando for produto especial ( cd_produto ) = 0, mostrar o grupo de produto - Carlos Fernandes
-------------------------------------------------------------------------------------------------------------
create procedure pr_egis_resumo_comissao_vendedor
@cd_parametro int      = 0,
@cd_usuario   int      = 0

as

if @cd_parametro is null or @cd_parametro = 0
   set @cd_parametro = 0


set @cd_usuario = isnull(@cd_usuario,0)

if @cd_usuario>0
begin
  set @cd_parametro = dbo.fn_usuario_vendedor(@cd_usuario)
end

SET DATEFORMAT mdy


declare @cd_ano                 int 
declare @cd_mes                 int
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @dt_hoje                datetime
declare @dt_perc_smo            datetime
declare @cd_tipo_vendedor       int

set @cd_ano           = year(getdate())
set @cd_mes           = month(getdate()) 


set @cd_mes = @cd_mes - 1

if @cd_mes = 0
begin
  set @cd_mes = 12
  set @cd_ano = @cd_ano - 1

end   

set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
set @dt_hoje          = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @dt_perc_smo      = '01/01/2018'
set @cd_tipo_vendedor = 0


CREATE TABLE #pr_egis_resumo_comissao_vendedor (
    cd_controle                INT,
    controle                   INT,
    ordem                      INT,
    NomeSetor                  VARCHAR(100),
    devolvido                  VARCHAR(100),
    cliente                    VARCHAR(200),
    pedido                     INT,
    nota                       INT,
    cd_identificacao_nota_saida INT,
    datanota                   DATETIME,
    qtd                        DECIMAL(18,2),
    base_comissao              DECIMAL(18,2),
    venda                      DECIMAL(18,2),
    comissao                   DECIMAL(18,2),
    pc_comissao_vendedor       DECIMAL(18,2),
    percomissao                DECIMAL(18,2),
    Setor                      INT,
    datadevolucao              DATETIME NULL,
    motivodev                  VARCHAR(200) NULL,
    venda_comissao             DECIMAL(18,2),
    cd_vendedor_interno        INT,
    ic_pagamento_duplicata     CHAR(1),
    cd_identificacao           VARCHAR(50),
    dt_pagamento_documento     DATETIME NULL,
    pc_contrato_cliente        DECIMAL(18,2),
    tipo_pedido                VARCHAR(50),
    NomeVendedor               VARCHAR(200),
    total_string               VARCHAR(200),
    base_string                VARCHAR(200)
);

insert into #pr_egis_resumo_comissao_vendedor
exec dbo.pr_calculo_comissao  7,
                              @cd_parametro,  --vendedor
                              @dt_inicial,
                              @dt_final,
                              @dt_perc_smo,
                              @cd_tipo_vendedor,
                              'N',
                              'N'


declare @vl_base_comissao decimal(25,2) = 0.00
declare @vl_comissao      decimal(25,2) = 0.00

select
  @vl_base_comissao = sum( base_comissao),
  @vl_comissao      = sum( comissao )

from 
  #pr_egis_resumo_comissao_vendedor 

select 
  setor as cd_vendedor,
  sum( base_comissao) as vl_base_comissao,
  sum( comissao)      as vl_comissao
into
  #Comissao

from
  #pr_egis_resumo_comissao_vendedor
group by
   Setor




select
  v.cd_vendedor,
  v.nm_fantasia_vendedor,
  v.nm_vendedor,
  tv.nm_tipo_vendedor,
  tp.nm_tipo_pessoa,
  v.cd_cnpj_vendedor,
  v.cd_celular,
  v.nm_email_vendedor,
  v.pc_comissao_vendedor,

  --Dados Bancários--------------------------------------------------------------
  
  v.nm_pix_vendedor,
  b.cd_numero_banco,
  v.cd_agencia_banco_vendedor,
  v.cd_conta_corrente,

  --Valores----------------
  c.vl_base_comissao                as vl_base_calculo,
  c.vl_comissao

from 
  vendedor v
  left outer join tipo_vendedor tv on tv.cd_tipo_vendedor = v.cd_tipo_vendedor
  left outer join tipo_pessoa tp   on tp.cd_tipo_pessoa   = v.cd_tipo_pessoa
  left outer join banco b          on b.cd_banco          = v.cd_banco
  left outer join #Comissao c      on c.cd_vendedor       = v.cd_vendedor

order by
  v.nm_vendedor


   

go







------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_resumo_comissao_vendedor 0,113
------------------------------------------------------------------------------
