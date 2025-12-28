--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_rubio


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_compras_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_compras_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_compras_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_compras_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_compras_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_compras_processo_modulo
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
--                   COMPRAS
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_compras_processo_modulo
------------------------
@json nvarchar(max) = '' --> parâmetro de Entrada
------------------------------------------------------------------------------
--with encryption


as

-- ver nível atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;

--return

--set @json = isnull(@json,'')

 SET NOCOUNT ON;
 SET XACT_ABORT ON;
 set dateformat mdy



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

----------------------------------------------------------------------------------------------------

declare @cd_empresa                     int = 0
declare @cd_parametro                   int = 0
declare @cd_documento                   int = 0
declare @cd_item_documento              int = 0
declare @cd_usuario                     int = 0
declare @dt_hoje                        datetime
declare @dt_inicial                     datetime 
declare @dt_final                       datetime
declare @cd_ano                         int = 0
declare @cd_mes                         int = 0
declare @cd_modelo                      int = 0

----------------------------------------------------------------------------------------------------------------
--fornecedor_produto
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

--------------------------------------------------------------------------------------------
--Definição das Variáveis
--------------------------------------------------------------------------------------------
declare @cd_fornecedor_produto          int = 0
declare @cd_fornecedor                  int = 0 
declare @cd_produto                     int = 0
declare @ic_cotacao_fornecedor          char(1)       = 'N'  
declare @nm_referencia_fornecedor       varchar(60)   = ''
declare @nm_marca_fornecedor            varchar(30)   = ''
declare @dt_cotacao_fornecedor          datetime
declare @dt_pedido_fornecedor           datetime
declare @nm_condicao_pagamento          varchar(30)   = '' 
declare @qt_dia_entrega_fornecedor      int           = 0 
declare @ds_observacao_produto          nvarchar(max) = ''
declare @cd_unidade_medida              int 
declare @cd_condicao_pagamento          int
declare @nm_produto_fornecedor          varchar(120)  = ''
declare @ds_produto_fornecedor          nvarchar(max) = ''
declare @qt_minimo_fornecedor           int
declare @cd_opcao_compra                int
declare @cd_moeda                       int = 1
declare @qt_dia_compra_fornecedor       int
declare @qt_nota_prod_fornecedor        int
declare @cd_ean_produto_fornecedor      varchar(70) = '' 
declare @cd_dun_produto_fornecedor      varchar(70) = ''
declare @cd_ca_produto_fornecedor       varchar(70) = ''
declare @qt_ca_prazo_validade           int         = 0
declare @cd_laudo_ca_fornecedor         varchar(50) = '' 
declare @cd_pedido_compra               int         = 0

--------------------------------------------------------------------------------------------------

--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

--Recebo o Json do Parametro @json 
--------------------------------------------------------------------------------------------------
select                     
 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json) root                    
   cross apply openjson(root.value) as valores      

--#json ( tabela temporário onde foi transformado a string de Json em Tabela )

--select * from #json
--return

--------------------------------------------------------------------------------------------

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo'             
select @cd_fornecedor          = valor from #json where campo = 'cd_fornecedor'             
select @cd_produto             = valor from #json where campo = 'cd_produto'             
select @cd_pedido_compra       = valor from #json where campo = 'cd_pedido_compra'             

--select * from #json

--select @cd_pedido_compra as Pedido
--return

-------------------------------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

--------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro     = ISNULL(@cd_parametro,0)
set @cd_pedido_compra = isnull(@cd_pedido_compra,0)
---------------------------------------------------------------------------------------------------------------------------------------------------------    

IF ISNULL(@cd_parametro,0) = 0
BEGIN

  select 
    'Sucesso'     as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final

  RETURN;

END
    
--Geração da Tabela de Produto x Fornecedor caso já existam pedidos de Compras--------------------------

if @cd_parametro = 1
begin
  ----
  exec pr_geracao_automatica_produto_fornecedor '','',@cd_usuario,'N'
  ----
  RETURN
end

-------------------------------------------------------------------------------------------

if @cd_parametro = 2
begin
  --select @cd_parametro
  ----
  exec pr_consulta_cadastro_produto_fornecedor @cd_fornecedor 
  ----
  RETURN

end

--------------------------------------------------------------------------------------------

if @cd_parametro = 3
begin

    --select
    --   nei.cd_pedido_compra,
    --   max(ne.dt_receb_nota_entrada) as dt_receb_nota_entrada
    -- into
    --   #vw_entrada_pedido_compra
    -- from 
    --   Nota_Entrada_item nei with (nolock)
                                       
    --   inner join nota_entrada ne        on ne.cd_nota_entrada        = nei.cd_nota_entrada      and
    --                                        ne.cd_serie_nota_fiscal   = nei.cd_serie_nota_fiscal and
    --                                        ne.cd_fornecedor          = nei.cd_fornecedor
    --   inner join pedido_compra pc       on pc.cd_pedido_compra       = nei.cd_pedido_compra
       
    -- where
    --    isnull(nei.cd_pedido_compra,0)<>0
    --    and
        
    --    --Pedido de Compra
    --    nei.cd_pedido_compra = case when @cd_pedido_compra = 0 then nei.cd_pedido_compra else @cd_pedido_compra end

    --    and
    --    --Data de Emissão
    --    pc.dt_pedido_compra between 
    --                        case when @cd_pedido_compra = 0 then @dt_inicial
    --                        else  
    --                          pc.dt_pedido_compra
    --                        end 
    --                        and
    --                        case when @cd_pedido_compra = 0 then @dt_final else pc.dt_pedido_compra
    --                        end
        
    --    group by
    --      nei.cd_pedido_compra


    --    CREATE INDEX IX_vw_entrada_pedido_compra ON #vw_entrada_pedido_compra (cd_pedido_compra);


          --select * from  #vw_entrada_pedido_compra
          --return

         select
           pcr.cd_pedido_compra,
           max(isnull(cd_item_revisao,0))    as cd_item_revisao,
           max(isnull(nm_revisao_pedido,'')) as nm_revisao_pedido
         into
           #vw_revisao_pedido_compra
         from
           pedido_compra_revisao pcr
           inner join pedido_compra pc on pc.cd_pedido_compra = pcr.cd_pedido_compra
         where
           pcr.cd_pedido_compra = pc.cd_pedido_compra
           and
           --Pedido de Compra
            pcr.cd_pedido_compra = case when @cd_pedido_compra = 0 then pcr.cd_pedido_compra else @cd_pedido_compra end
         
            and
            --Data de Emissão
            pc.dt_pedido_compra between 
                                case when @cd_pedido_compra = 0 then @dt_inicial
                                else  
                                  pc.dt_pedido_compra
                                end 
                                and
                                case when @cd_pedido_compra = 0 then @dt_final else pc.dt_pedido_compra
                                end
         group by
           pcr.cd_pedido_compra

           --select * from #vw_revisao_pedido_compra
           --return

           select
           --  distinct
             pc.cd_pedido_compra,
           --  i.cd_requisicao_compra,
             count(distinct i.cd_requisicao_compra)              as qt_requisicao_pedido,
             max(i.cd_requisicao_compra)                         as cd_requisicao_compra
           into #vw_requisicao_pedido_compra
           from
             pedido_compra pc
             inner join pedido_compra_item i on i.cd_pedido_compra = pc.cd_pedido_compra
           where
             isnull(i.cd_requisicao_compra,0)>0
             and
             --Pedido de Compra
              pc.cd_pedido_compra = case when @cd_pedido_compra = 0 then pc.cd_pedido_compra else @cd_pedido_compra end
           
              and
              --Data de Emissão
              pc.dt_pedido_compra between 
                                  case when @cd_pedido_compra = 0 then @dt_inicial
                                  else  
                                    pc.dt_pedido_compra
                                  end 
                                  and
                                  case when @cd_pedido_compra = 0 then @dt_final else pc.dt_pedido_compra
                                  end
           group by
             pc.cd_pedido_compra
           
           
           --select * from #vw_requisicao_pedido_compra
           --return

select 
  distinct
  pc.cd_pedido_compra,
  pc.dt_pedido_compra,

  pc.vl_total_pedido_ipi as vl_total_pedido_compra,   
  pc.vl_total_ipi_pedido as vl_ipi,
	pc.vl_frete_pedido_compra as vl_frete,
	pc.vl_icms_st             as vl_icms_st,
	pc.vl_desconto_pedido_compra as vl_desconto,
  pc.dt_nec_pedido_compra,
  case when pc.cd_status_pedido in (9,14) then
    0 else cast (pc.dt_nec_pedido_compra - (getdate()-1) as int) end as Dias,
  f.nm_fantasia_fornecedor,
  c.nm_comprador, 
  cp.nm_condicao_pagamento, pc.ic_fechado_pedido_compra as ic_fechado,
  case when (select sum(qt_saldo_item_ped_compra) from pedido_compra_item 
             where cd_pedido_compra=pc.cd_pedido_compra) <= 0 and (pc.cd_status_pedido <> 14)
    then 'N' else 'S' end as ic_aberto,
  case when (pc.dt_nec_pedido_compra < cast((cast(GetDate() as int) -1) as datetime) and pc.cd_status_pedido not in (9,14))
    then 'S' else 'N' end as ic_atraso,
  case when IsNull(pc.ic_aprov_comprador_pedido,'N') ='N'
    then 'S' else 'N' end as ic_sem_liberacao,
    IsNull(pc.ic_aprov_pedido_compra,'N') as 'ic_aprovado',
    sp.nm_status_pedido,
  case when pc.cd_status_pedido in (9,10) then
    'S' else 'N' end as 'ic_recebido',
  ( select min(dt_entrega_item_ped_compr) 
    from Pedido_Compra_Item x with (nolock) 
    where x.cd_pedido_compra = pc.cd_pedido_compra ) as dt_entrega_item,
  ap.nm_aplicacao_produto,
  pl.nm_plano_compra,
  case when isnull(( select top 1 cd_pedido_compra
    from
      pedido_compra_follow pf with (nolock) 
   where
      pf.cd_pedido_compra = pc.cd_pedido_compra ),0)<>0 then 'S' else 'N' end  as ic_follow,
  case when isnull(vwr.qt_requisicao_pedido,0)>1 then 'Diversas' else cast(vwr.cd_requisicao_compra as varchar(08)) end as nm_requisicao,

isnull(pc.ic_multa_pedido,0) as ic_multa_pedido,
isnull(pc.vl_multa_pedido_compra,0) as vl_multa_pedido_compra,
isnull(pc.ic_inspecao_pedido_compra,0) as ic_inspecao_pedido_compra,
cc.nm_condicao_compra,
wrev.nm_revisao_pedido,
ccu.cd_mascara_centro_custo,
ccu.nm_centro_custo,
proj.cd_interno_projeto,
-- isnull(sr.nm_status_recebimento,'Aberto') as nm_status_recebimento,
isnull(( select top 1 isnull(sr.nm_status_recebimento,'Aberto')
         from
            status_recebimento sr
            inner join pedido_compra_recebimento pcr on pcr.cd_pedido_compra      = pc.cd_pedido_compra and
                                                        pcr.cd_item_pedido_compra = 0 and
                                                        sr.cd_status_recebimento = pcr.cd_status_recebimento),'') as nm_status_recebimento,
we.dt_receb_nota_entrada,
isnull(pc.vl_adiantamento_fornecedor,0)   as vl_adiantamento_fornecedor,
dt_vencimento_adiantamento
,(select top 1 vwb.dt_pagamento_documento from vw_baixa_documento_pagar vwb where vwb.cd_pedido_compra = pc.cd_pedido_compra order by vwb.dt_pagamento_documento desc) as dt_pagamento_documento,
isnull(t.nm_fantasia,'')                                     as nm_fantasia_transportadora,
isnull(tpf.nm_tipo_pagamento_frete,'')          as nm_tipo_pagamento_frete,
  ( select sum(isnull(x.qt_item_pesbr_ped_compra,0)) 
    from Pedido_Compra_Item x with (nolock) 
    where x.cd_pedido_compra = pc.cd_pedido_compra ) as qt_peso_bruto_total

from 
  Pedido_Compra pc                                                 with (nolock)
  left outer join Fornecedor f                                     with (nolock) on  pc.cd_fornecedor                   = f.cd_fornecedor
  left outer join Comprador c                                      with (nolock) on  c.cd_comprador                      = pc.cd_comprador
  left outer join Condicao_Pagamento cp                            with (nolock) on cp.cd_condicao_pagamento    = pc.cd_condicao_pagamento
  left outer join Status_Pedido sp                                 with (nolock) on sp.cd_status_pedido               = pc.cd_status_pedido
  left outer join Aplicacao_Produto ap                             with (nolock) on ap.cd_aplicacao_produto        = pc.cd_aplicacao_produto
  left outer join Plano_Compra pl                                  with (nolock) on pl.cd_plano_compra                = pc.cd_plano_compra
  left outer join #vw_requisicao_pedido_compra vwr                 with (nolock) on vwr.cd_pedido_compra           = pc.cd_pedido_compra
  left outer join condicao_compra cc                               with (nolock)on cc.cd_condicao_compra           = pc.cd_condicao_compra
  left outer join #vw_revisao_pedido_compra   wrev                 with (nolock) on wrev.cd_pedido_compra         = pc.cd_pedido_compra
  left outer join centro_custo ccu                                 with (nolock) on ccu.cd_centro_custo               = pc.cd_centro_custo
  left outer join projeto proj                                     with (nolock) on proj.cd_projeto                       = pc.cd_projeto
  left outer join pedido_compra_recebimento pcr                    with (nolock) on pcr.cd_pedido_compra            = pc.cd_pedido_compra
                                                                                                                   and pcr.cd_item_pedido_compra   = 0
  left outer join vw_entrada_pedido_compra we                      with (nolock) on we.cd_pedido_compra             = pc.cd_pedido_compra
  left outer join transportadora t                                 with (nolock) on t.cd_transportadora                = pc.cd_transportadora
  left outer join tipo_pagamento_frete tpf                         with (nolock) on tpf.cd_tipo_pagamento_frete = pc.cd_tipo_pagamento_frete

where 
   --Pedido de Compra
   pc.cd_pedido_compra = case when @cd_pedido_compra = 0 then pc.cd_pedido_compra else @cd_pedido_compra end

   and
   --Data de Emissão
   pc.dt_pedido_compra between 
                       case when @cd_pedido_compra = 0 then @dt_inicial
                       else  
                         pc.dt_pedido_compra
                       end 
                       and
                       case when @cd_pedido_compra = 0 then @dt_final else pc.dt_pedido_compra
                       end

order by
  pc.cd_pedido_compra desc

 -- drop table #vw_entrada_pedido_compra
  drop table #vw_requisicao_pedido_compra
  drop table #vw_revisao_pedido_compra

  RETURN

end

------------------------------------------------------------------------------------

if @cd_parametro = 999
begin
  select @cd_parametro
  RETURN
end

/* Padrão se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;
------------------------------------------------------------------------------------

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
--exec  pr_egis_compras_processo_modulo
------------------------------------------------------------------------------
--pr_egis_compras_processo_modulo
--sp_helptext pr_egis_modelo_procedure

go

/*
exec  pr_egis_compras_processo_modulo '[{"cd_parametro": 0}]'
exec  pr_egis_compras_processo_modulo '[{"cd_parametro": 1, "cd_modelo": 1}]'  
exec  pr_egis_compras_processo_modulo '[{"cd_parametro": 2, "cd_fornecedor": 1}]' 
exec  pr_egis_compras_processo_modulo '[{"cd_parametro": 3, "cd_pedido_compra": 29247, "cd_usuario" : 113, "xuxa": "meneguel"}]' 

'
'
*/
go
------------------------------------------------------------------------------
GO


--exec  pr_egis_compras_processo_modulo '[{"cd_parametro": 3, "cd_pedido_compra": 29247, "cd_usuario" : 113}]' 
exec  pr_egis_compras_processo_modulo
       '[{"cd_parametro": 3, "cd_pedido_compra": 0, "dt_inicial" : "10/01/2025", 
                                                    "dt_final": "10/31/2025", "cd_usuario" : 113}]' 

