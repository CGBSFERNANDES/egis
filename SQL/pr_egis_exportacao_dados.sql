--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_273

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_exportacao_dados' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_exportacao_dados

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_exportacao_dados','P') IS NOT NULL
    DROP PROCEDURE pr_egis_modelo_procedure;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_exportacao_dados
-------------------------------------------------------------------------------
-- pr_egis_exportacao_dados
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
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_exportacao_dados
@json nvarchar(max) = ''

--with encryption


as

--select @json

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


declare @cd_empresa          int
declare @cd_parametro        int
declare @cd_documento        int = 0
declare @cd_item_documento   int
declare @cd_usuario          int 
declare @dt_hoje             datetime
declare @dt_inicial          datetime = null 
declare @dt_final            datetime = null
declare @cd_ano              int = 0
declare @cd_mes              int = 0
declare @cd_modelo           int = 0
declare @top_rows            int = 0
declare @ic_tipo_saida       varchar(12) = 'N'
declare @nm_view             SYSNAME
declare @json_meta           NVARCHAR(MAX)
declare @nm_root             NVARCHAR(128)
declare @nm_array            NVARCHAR(128);
declare @ic_admin_tabela     char(1)      = 'N'
declare @nm_tabela           varchar(500) = ''
declare @cd_tabela_parametro int          = 0
declare @nm_objeto           varchar(100) = ''
declare @nm_filtro_parametro varchar(100) = ''
declare @json_final          NVARCHAR(MAX) = ''
declare @cd_cnpj             varchar(18)   = ''
declare @cd_pedido_venda     varchar(10)   = 0


--SELECT @json_final AS data;


-- Captura do JSON do SELECT dinâmico
declare @catch               TABLE (json nvarchar(max));
-----


--SYSNAME

----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano = year(getdate())
set @cd_mes = month(getdate())  


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

--select * from #json
--return


select @cd_empresa          = valor from #json where campo = 'cd_empresa'             
select @cd_parametro        = valor from #json where campo = 'cd_parametro'          
select @cd_usuario          = valor from #json where campo = 'cd_usuario'             
select @dt_inicial          = valor from #json where campo = 'dt_inicial'             
select @dt_final            = valor from #json where campo = 'dt_final'             
select @cd_modelo           = valor from #json where campo = 'cd_modelo'             
select @nm_tabela           = valor from #json where campo = 'nm_tabela'
select @ic_admin_tabela     = valor from #json where campo = 'ic_admin_tabela'
select @cd_tabela_parametro = valor from #json where campo = 'cd_tabela_parametro'
select @cd_cnpj             = valor from #json where campo = 'cd_cnpj'
select @cd_pedido_venda     = valor from #json where campo = 'orderId'

--------------------------------------------------------------------------------------

if @dt_inicial is null or @dt_final is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end

--------------------------------------------------------------------------------------

set @cd_pedido_venda = isnull(TRY_CAST(@cd_pedido_venda as int),0)
set @cd_empresa      = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

--select @cd_pedido_venda
--return

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @top_rows     = 0
set @cd_parametro = ISNULL(@cd_parametro,0)

--IF @top_rows IS NULL OR @top_rows<=0 SET @top_rows = 500;

IF ISNULL(@cd_parametro,0) = 0
BEGIN

  SELECT
    m.cd_modelo,
    m.nm_modelo,
    m.cd_tabela,
    m.nm_obs_modelo,
    m.cd_modulo,
    m.nm_woorkbook,
    m.cd_menu,
    isnull(m.ic_admin_tabela,'N')                 as ic_admin_tabela,
    f.nm_view, f.nm_root, f.nm_array, f.json_meta,
    'N' as ic_pesquisa_tabela,
    isnull(m.ic_exportacao_json,'N')              as ic_exportacao_json

    into #Modelo
    FROM 
      egisadmin.dbo.Modelo_Exportacao_Dados m                   WITH(NOLOCK)
      left outer join egisadmin.dbo.Modelo_Exportacao_Formato f WITH(NOLOCK)
                                                                ON f.cd_modelo = m.cd_modelo    
  ORDER BY m.nm_modelo;

  --set @cd_tabela_parametro = 1

  if @cd_tabela_parametro = 1
  begin
    insert into #Modelo
    select
    t.cd_tabela  as cd_modelo,
    t.nm_tabela  as nm_modelo,
    t.cd_tabela,
    t.ds_tabela  as nm_obs_modelo,
    null         as cd_modulo,
    null         as nm_woorkbook,
    null as cd_menu,
    isnull(t.ic_sap_admin,'N') as ic_admin_tabela,
    null as nm_view, null as nm_root, null as nm_array, null as json_meta,
    'S' as ic_pesquisa_tabela,
    'N' as ic_exportacao_json,
    cast('' as varchar(100))    as nm_filtro_parametro
    from
      egisadmin.dbo.tabela t
    order by 
      t.nm_tabela
  end

  ----------------------------------------
  select * from #Modelo order by nm_modelo
  -----------------------------------------

  RETURN;

END

--Mostra os documentos Disponíveis---

IF ISNULL(@cd_parametro,0) = 100
BEGIN

  SELECT
    m.cd_modelo,
    m.nm_modelo
    
  FROM 
      egisadmin.dbo.Modelo_Exportacao_Dados m                   WITH(NOLOCK)
      left outer join egisadmin.dbo.Modelo_Exportacao_Formato f WITH(NOLOCK)
                                                                ON f.cd_modelo = m.cd_modelo    
  ORDER BY m.nm_modelo;

  return

 END



--Dados de Formato para Exportação------

  IF @cd_modelo IS NOT NULL
    BEGIN
      SELECT @ic_tipo_saida = f.ic_tipo_saida,
             @nm_view       = f.nm_view,
             @json_meta     = f.json_meta,
             @nm_root       = NULLIF(f.nm_root,N''),
             @nm_array      = NULLIF(f.nm_array,N'')
      FROM egisadmin.dbo.Modelo_Exportacao_Formato f WITH(NOLOCK)
      WHERE f.cd_modelo = @cd_modelo;
    END

    /* Helper: monta lista de colunas conforme json_meta (ordem) */

    DECLARE @col_select NVARCHAR(MAX) = N'*';  -- default
    IF @json_meta IS NOT NULL AND ISJSON(@json_meta)=1
    BEGIN
      ;WITH meta AS (
        SELECT
          TRY_CAST(JSON_VALUE(j.value,'$.order') AS INT) AS ord,
          JSON_VALUE(j.value,'$.field') AS field,
          NULLIF(JSON_VALUE(j.value,'$.as'),N'') AS [as]
        FROM OPENJSON(@json_meta,'$.columns') j
      )
      SELECT @col_select = STUFF((
         SELECT N', ' + QUOTENAME(m.field) + CASE WHEN m.[as] IS NOT NULL THEN N' AS ' + QUOTENAME(m.[as]) ELSE N'' END
         FROM meta m
         WHERE m.field IS NOT NULL
         ORDER BY ISNULL(m.ord, 100000), m.field
         FOR XML PATH(''), TYPE).value('.','nvarchar(max)'),1,2,'');
      IF @col_select IS NULL OR LTRIM(RTRIM(@col_select))=N'' SET @col_select=N'*';
    END

   --------------------------------------------------------------------------------------------

--

IF @cd_parametro = 1
BEGIN
  IF @cd_modelo IS NULL OR @cd_modelo <= 0
  THROW 50002, 'cd_modelo obrigatório.', 1;


  DECLARE @cd_tabela INT = 0

  --@nm_tabela SYSNAME;
  
  SELECT 
     @cd_tabela           = isnull(m.cd_tabela,0),
     @nm_filtro_parametro = isnull(nm_atributo_filtro,'')
  FROM 
     egisadmin.dbo.Modelo_Exportacao_Dados m WITH(NOLOCK)
  WHERE
     m.cd_modelo = @cd_modelo;

  -------------------------------------------------------------------
  if @cd_tabela =  0
  begin
    select top 1 
      @nm_tabela = isnull(nm_tabela,'')
    from
      egisadmin.dbo.tabela
    where
      cd_tabela = @cd_modelo
  end
  
  SELECT @nm_tabela = t.nm_tabela 
  FROM egisadmin.dbo.tabela t WITH(NOLOCK)
  WHERE t.cd_tabela = @cd_tabela;


  IF @nm_tabela IS NULL
     THROW 50003, 'Modelo sem tabela associada.', 1;


  -- Opção A: consulta rápida (TOP 500). Adapte WHERE conforme necessário.

  DECLARE @sql NVARCHAR(MAX) = N'SELECT * FROM ' + QUOTENAME(@nm_tabela) + N' WITH(NOLOCK)';


  -- Gancho para filtro de datas se houver colunas padronizadas (ex.: dt_movimento)

  if @nm_filtro_parametro<>''
  begin
    IF @dt_inicial IS NOT NULL AND @dt_final IS NOT NULL AND EXISTS (
    SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(@nm_tabela) AND name = @nm_filtro_parametro)
    BEGIN
      --SET @sql = @sql + N' WHERE dt_movimento >= @p_ini AND dt_movimento < DATEADD(DAY,1,@p_fim)';
      SET @sql = @sql + N' WHERE ' + @nm_filtro_parametro + N' >= @p_ini AND ' + @nm_filtro_parametro + N' < DATEADD(DAY,1,@p_fim)';

    END
  end


DECLARE @params NVARCHAR(200) = N'@p_ini DATETIME2(0), @p_fim DATETIME2(0)';

EXEC sp_executesql @sql, @params, @p_ini=@dt_inicial, @p_fim=@dt_final;

RETURN;
END

--Rodar processos Específicos----------------------------------------------------------------

if @cd_parametro = 9
begin

  --Produtos------------------------------------------------------------------------

    if @cd_modelo = 10
    begin



   --Cayena / NAF - Estoque
  
  select
    --top 1
      --p.cd_produto                          as 'productId',
      p.cd_mascara_produto                  as 'productId',
      p.nm_produto                          as 'description',
  --um.sg_unidade_medida                  as 'units',
  ( SELECT um.sg_unidade_medida AS codUni, um.nm_unidade_medida AS descrUni FOR JSON PATH ) as 'units',

  --Teste e temos que tratar conforme a Tabela de Preço--
  case when isnull(p.vl_produto,0) = 0 then
   1.00
  else
    isnull(p.vl_produto,0.00)
  end                                        as 'price',
  -------------------------------------------------------
  isnull(ps.qt_saldo_reserva_produto,0) as 'stock',
  p.cd_codigo_barra_produto             as 'EAN',
  null                                  as 'validade',
  case when isnull(pig.nm_imagem_produto,'')<>'' and pig.cd_tipo_imagem_produto=1
  then
    pig.nm_imagem_produto
  else
  cast('' as nvarchar(max))
  end                                   as 'foto',
  isnull(qt_peso_medio_produto,0)       as 'PESOMEDIO',
  mp.nm_marca_produto
  
  --USE EGISSQL_273

from
  produto p
  inner join unidade_medida um      on um.cd_unidade_medida = p.cd_unidade_medida
  left outer join produto_saldo ps  on ps.cd_produto = p.cd_produto
                                       and
                                       ps.cd_fase_produto = p.cd_fase_produto_baixa
  left outer join marca_produto mp   on mp.cd_marca_produto = p.cd_marca_produto
  left outer join produto_imagem pig on pig.cd_produto    = p.cd_produto and pig.cd_tipo_imagem_produto = 1


  --select * from produto_imagem
where
  isnull(p.cd_status_produto,1) = 1
  and
  isnull(ps.qt_saldo_reserva_produto,0)>0
  and
  isnull(p.cd_fase_produto_baixa,0) = 3

order by
  p.cd_mascara_produto


    /*
    select  @json_final = (
    select
      --p.cd_produto                          as 'productId',
      p.cd_mascara_produto                  as 'productId',
      p.nm_produto                          as 'description',
  --um.sg_unidade_medida                  as 'units',
   JSON_QUERY((
    SELECT
      um.sg_unidade_medida AS codUni,
      um.nm_unidade_medida AS descrUni
    FOR JSON PATH
  )) AS units,
  --Teste e temos que tratar conforme a Tabela de Preço--
  case when isnull(p.vl_produto,0) = 0 then
   1.00
  else
    isnull(p.vl_produto,0.00)
  end                                        as 'price',
  -------------------------------------------------------
  isnull(ps.qt_saldo_reserva_produto,0) as 'stock',
  p.cd_codigo_barra_produto             as 'EAN',
  null                                  as 'validade',
  case when isnull(pig.nm_imagem_produto,'')<>'' and pig.cd_tipo_imagem_produto=1
  then
    pig.nm_imagem_produto
  else
  cast('' as nvarchar(max))
  end                                   as 'foto',
  isnull(qt_peso_medio_produto,0)       as 'PESOMEDIO',
  mp.nm_marca_produto
  
  --USE EGISSQL_273

from
  produto p
  inner join unidade_medida um      on um.cd_unidade_medida = p.cd_unidade_medida
  left outer join produto_saldo ps  on ps.cd_produto = p.cd_produto
                                       and
                                       ps.cd_fase_produto = p.cd_fase_produto_baixa
  left outer join marca_produto mp   on mp.cd_marca_produto = p.cd_marca_produto
  left outer join produto_imagem pig on pig.cd_produto    = p.cd_produto and pig.cd_tipo_imagem_produto = 1


  --select * from produto_imagem
where
  isnull(p.cd_status_produto,1) = 1
  and
  isnull(ps.qt_saldo_reserva_produto,0)>0
  and
  isnull(p.cd_fase_produto_baixa,0) = 3

order by
  p.cd_mascara_produto
FOR JSON PATH );

select  @json_final as data 
*/

   --update produto_saldo set qt_saldo_reserva_produto = 1000 where cd_produto between 1 and 10


      return


    end

--Clientes

if @cd_modelo = 11
begin
  --select * from vendedor

  /*
  select 
    c.cd_cliente                as 'clientId', 
    c.nm_razao_social_cliente   as 'Name',
    c.nm_email_cliente          as 'email',
    c.cd_telefone               as 'phone',
    c.cd_cnpj_cliente           as 'cnpj',
    c.cd_cep                    as 'cep',

    ltrim(c.nm_endereco_cliente)
    +
    ' '
    +
    c.cd_numero_endereco
    +
    ' '
    +ltrim(rtrim(c.nm_complemento_endereco))
    +
    ' '
    +ltrim(rtrim(c.nm_bairro))
    +
    ' '
    +ltrim(rtrim(cid.nm_cidade))+ ' ' + e.sg_estado as 'address',

    
    case when c.cd_status_cliente = 1 then
      'true'
    else
      'false'
    end                         as isActive


  from
    cliente c
    left outer join estado e   on e.cd_estado = c.cd_estado
    left outer join cidade cid on cid.cd_estado = c.cd_estado and cid.cd_cidade = c.cd_cidade
  where
    c.cd_status_cliente = 1
    and
    c.cd_vendedor = 48
    and
    c.cd_cnpj_cliente = @cd_cnpj

  order by
    c.cd_cliente

  */

  SELECT
    c.cd_cliente              AS clientId,
    c.nm_razao_social_cliente AS Name,
    c.nm_email_cliente        AS email,
    c.cd_telefone             AS phone,
    c.cd_cnpj_cliente         AS cnpj,

    -- objeto address
    (
      SELECT
        LTRIM(c.nm_endereco_cliente) AS street,
        c.cd_numero_endereco         AS number,
        cid.nm_cidade                AS city,
        e.sg_estado                  AS state,
        c.cd_cep                     AS zip
      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS address,

    CASE WHEN c.cd_status_cliente = 1 THEN 'true' ELSE 'false' END AS isActive
FROM cliente c
LEFT JOIN estado e   ON e.cd_estado = c.cd_estado
LEFT JOIN cidade cid ON cid.cd_estado = c.cd_estado AND cid.cd_cidade = c.cd_cidade
WHERE c.cd_status_cliente = 1
  AND c.cd_vendedor = 48
  AND c.cd_cnpj_cliente = @cd_cnpj
ORDER BY c.cd_cliente


    --select * from cliente where cd_vendedor = 48 order by nm_razao_social_cliente
    --select * from vendedor

  return
end

if @cd_modelo = 12
begin
  select
     top 100
     pv.cd_pedido_venda as 'OrderId',
     pv.dt_pedido_venda as 'date',
     pv.cd_cliente      as 'ClienteID'

  from
     pedido_venda pv
  order by
     pv.dt_pedido_venda desc
  return
end

--Cadastro de Cliente---------------------------------------------------------------

if @cd_modelo = 50
begin

  exec pr_api_gera_cadastro_cliente @json
 
  return
end

--Cadastro do Pedido de Venda

if @cd_modelo = 60
begin

  exec pr_api_gera_cadastro_pedido_venda @json
 
  return
end

--Status de Pedido de Venda

if @cd_modelo = 70
begin

    --notaFiscal

    --substring(n.cd_chave_acesso,4,44)                               as 'chaveNF',  --select cd_chave_acesso, * from nota_saida
    --n.dt_nota_saida                                                 as 'issueDate',
    --n.vl_total     
    --as 'totalValue',
   -- objeto notaFiscal
    --Itens

    /*
    p.cd_mascara_produto                                            as 'productId',
    p.nm_produto                                                    as 'description',
    case when isnull(nsi.qt_item_nota_saida,0)>0 then
      nsi.qt_item_nota_saida
    else
      i.qt_item_pedido_venda
    end                                                             as 'quantity',
    case when isnull(nsi.vl_unitario_item_nota,0)>0 then
      nsi.vl_unitario_item_nota
    else
      i.vl_unitario_item_pedido
    end                                                             as 'price',

    i.dt_entrega_vendas_pedido                                      as 'delivery'
    


  select 
    pv.cd_pedido_venda                            as 'orderId',
    pv.cd_cliente                                 as 'clienteId',
    pv.dt_pedido_venda                            as 'date',

    case when i.dt_cancelamento_item is not null then
     'Cancelado'
    else
      case when isnull(n.cd_nota_saida,0)>0 then
        'Faturado'
      else
        case when isnull(i.qt_saldo_pedido_venda,0)>0 then
          'Aberto'
        else
          cast('Pedido Confirmado' as varchar(80))
        end
      end
    end                                           as 'status',

    JSON_QUERY((
        SELECT
            SUBSTRING(n.cd_chave_acesso,4,44) AS chaveNF,
            n.dt_nota_saida                   AS issueDate,
            n.vl_total                        AS totalValue
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )) AS notaFiscal,
    
   
        -- array de items
    JSON_QUERY((
        SELECT
            p.cd_mascara_produto AS productId,
            p.nm_produto         AS description,
            CASE WHEN ISNULL(nsi.qt_item_nota_saida,0)>0 
                 THEN nsi.qt_item_nota_saida 
                 ELSE i.qt_item_pedido_venda END AS quantity,
            CASE WHEN ISNULL(nsi.vl_unitario_item_nota,0)>0 
                 THEN nsi.vl_unitario_item_nota 
                 ELSE i.vl_unitario_item_pedido END AS price,
            i.dt_entrega_vendas_pedido AS delivery
        FROM pedido_venda_item i
        LEFT JOIN nota_saida_item nsi 
               ON nsi.cd_pedido_venda = i.cd_pedido_venda 
              AND nsi.cd_item_pedido_venda = i.cd_item_pedido_venda
        INNER JOIN produto p 
               ON p.cd_produto = i.cd_produto
        WHERE i.cd_pedido_venda = pv.cd_pedido_venda
        FOR JSON PATH
    )) AS items


  from
    pedido_venda pv
    inner join pedido_venda_item i      on i.cd_pedido_venda        = pv.cd_pedido_venda
    left outer join nota_saida_item nsi on nsi.cd_pedido_venda      = i.cd_pedido_venda and
                                           nsi.cd_item_pedido_venda = i.cd_item_pedido_venda

    left outer join nota_saida n        on n.cd_nota_saida          = nsi.cd_nota_saida --and n.cd_status_nota
    inner join produto p                on p.cd_produto             = i.cd_produto
  
  where
    pv.cd_pedido_venda = @cd_pedido_venda

  */
  SELECT
  pv.cd_pedido_venda AS orderId,
  pv.cd_cliente      AS clienteId,
  pv.dt_pedido_venda AS date,

  CASE
    WHEN EXISTS (
      SELECT 1
      FROM pedido_venda_item i
      WHERE i.cd_pedido_venda = pv.cd_pedido_venda
        AND i.dt_cancelamento_item IS NOT NULL
    ) THEN 'Cancelado'
    WHEN EXISTS (
      SELECT 1
      FROM nota_saida_item nsi
      WHERE nsi.cd_pedido_venda = pv.cd_pedido_venda
        AND ISNULL(nsi.cd_nota_saida, 0) > 0
    ) THEN 'Faturado'
    WHEN EXISTS (
      SELECT 1
      FROM pedido_venda_item i
      WHERE i.cd_pedido_venda = pv.cd_pedido_venda
        AND ISNULL(i.qt_saldo_pedido_venda, 0) > 0
    ) THEN 'Aberto'
    ELSE 'Pedido Confirmado'
  END AS status,

  JSON_QUERY(nf.notaFiscal) AS notaFiscal,
  JSON_QUERY(it.items)      AS items

FROM pedido_venda pv

OUTER APPLY (
  SELECT (
    SELECT
      SUBSTRING(n.cd_chave_acesso, 4, 44) AS chaveNF,
      n.dt_nota_saida                     AS issueDate,
      n.vl_total                          AS totalValue
    FROM nota_saida n
    INNER JOIN nota_saida_item nsi
      ON nsi.cd_nota_saida = n.cd_nota_saida
    WHERE nsi.cd_pedido_venda = pv.cd_pedido_venda
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
  ) AS notaFiscal
) nf

OUTER APPLY (
  SELECT (
    SELECT
      p.cd_mascara_produto AS productId,
      p.nm_produto         AS description,
      cast(CASE
        WHEN ISNULL(nsi.qt_item_nota_saida, 0) > 0
          THEN nsi.qt_item_nota_saida
        ELSE i.qt_item_pedido_venda
      END as decimal(25,4)) AS quantity,
      cast(CASE
        WHEN ISNULL(nsi.vl_unitario_item_nota, 0) > 0
          THEN nsi.vl_unitario_item_nota
        ELSE i.vl_unitario_item_pedido
      END as decimal(25,4)) AS price,
      i.dt_entrega_vendas_pedido AS delivery
    FROM pedido_venda_item i
    LEFT JOIN nota_saida_item nsi
      ON nsi.cd_pedido_venda      = i.cd_pedido_venda
     AND nsi.cd_item_pedido_venda = i.cd_item_pedido_venda
    INNER JOIN produto p
      ON p.cd_produto = i.cd_produto
    WHERE i.cd_pedido_venda = pv.cd_pedido_venda
    FOR JSON PATH
  ) AS items
) it

WHERE pv.cd_pedido_venda = @cd_pedido_venda;


  return

end


if @cd_modelo = 80
begin
 /*
 PEDIDO CONFIRMADO
PEDIDO FATURADO
PEDIDO CANCELADO CAYENA
PEDIDO CANCELADO FORNECEDOR
PEDIDO DEVOLVIDO
VENDA ENCERRADA NA DATA
PRODUTO NAO CADASTRADO
CLIENTE COM VENDEDOR ATIVO / INATIVO
PRODUTO BLOQUEADO PARA VENDA
PRECO DE VENDA NAO LIBERADO
SEM ESTOQUE DISPONIVEL
RESTRICAO DE DATA DE ENTREGA
CADASTRO PENDENTE DE APROVACAO
 */


 SELECT (
    SELECT 
        c.Nome,
        p.IdPedido,
        p.IdCliente,
        p.DataPedido,
        p.ValorTotal
    FROM pedidos p
    INNER JOIN Clientes c ON c.IdCliente = p.IdCliente
    FOR JSON PATH
) AS data;

  return
end

  if @cd_modelo = 8
  begin
    select 'Json Específico' as Msg, @cd_modelo as cd_modelo

    PRINT 'Json o Modelo da Loja' 
    
    RETURN
  end

  RETURN

end


--Mostrar as tabelas do Admin----

if @cd_parametro = 500 or @ic_admin_tabela='S'
begin
  select cd_tabela, nm_tabela, ds_tabela, isnull(ic_sap_admin,'N') as ic_sap_admin 
  from egisadmin.dbo.tabela
  order by
    nm_tabela
  return
end

/* ===== 600) LISTAR TABELAS/VIEWS (para ic_admin_tabela='S') ===== */

IF @cd_parametro = 600
BEGIN
  DECLARE @q NVARCHAR(100) = NULLIF(JSON_VALUE(@json,'$.q'), N''); -- filtro opcional pelo nome
  ;WITH objs AS (
    SELECT
      N'TABLE' AS tp,
      s.name   AS schema_name,
      t.name   AS object_name,
      QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) AS nm_tabela
    FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    UNION ALL
    SELECT
      N'VIEW' AS tp,
      s.name, v.name,
      QUOTENAME(s.name) + N'.' + QUOTENAME(v.name)
    FROM sys.views v
    JOIN sys.schemas s ON s.schema_id = v.schema_id
  )
  SELECT TOP (2000)
         tp,
         schema_name,
         object_name,
         nm_tabela
  FROM objs
  WHERE (@q IS NULL OR nm_tabela LIKE '%' + @q + '%')
    AND schema_name NOT IN ('sys','INFORMATION_SCHEMA')      -- evita catálogo
  ORDER BY tp, schema_name, object_name;
  RETURN;
END


/* 2) Retornar somente o mapa de campos do modelo */
    IF @cd_parametro = 2
    BEGIN
      SELECT mp.campo_data, mp.campo_valor, mp.campo_id, mp.campo_memo
      FROM egisadmin.dbo.Modelo_Exportacao_Mapa mp WITH(NOLOCK)
      WHERE mp.cd_modelo = @cd_modelo;
      RETURN;
    END

/*
/* Carrega definições do modelo (para os demais parâmetros) */
    DECLARE
       @ic_tipo_saida VARCHAR(12)
      ,@nm_view       SYSNAME
      ,@json_meta     NVARCHAR(MAX)
      ,@nm_root       NVARCHAR(128)
      ,@nm_array      NVARCHAR(128);

    IF @cd_modelo IS NOT NULL
    BEGIN
      SELECT @ic_tipo_saida = f.ic_tipo_saida,
             @nm_view       = f.nm_view,
             @json_meta     = f.json_meta,
             @nm_root       = NULLIF(f.nm_root,N''),
             @nm_array      = NULLIF(f.nm_array,N'')
      FROM egisadmin.dbo.Modelo_Exportacao_Formato f WITH(NOLOCK)
      WHERE f.cd_modelo = @cd_modelo;
    END

    /* Helper: monta lista de colunas conforme json_meta (ordem) */
    DECLARE @col_select NVARCHAR(MAX) = N'*';  -- default
    IF @json_meta IS NOT NULL AND ISJSON(@json_meta)=1
    BEGIN
      ;WITH meta AS (
        SELECT
          TRY_CAST(JSON_VALUE(j.value,'$.order') AS INT) AS ord,
          JSON_VALUE(j.value,'$.field') AS field,
          NULLIF(JSON_VALUE(j.value,'$.as'),N'') AS [as]
        FROM OPENJSON(@json_meta,'$.columns') j
      )
      SELECT @col_select = STUFF((
         SELECT N', ' + QUOTENAME(m.field) + CASE WHEN m.[as] IS NOT NULL THEN N' AS ' + QUOTENAME(m.[as]) ELSE N'' END
         FROM meta m
         WHERE m.field IS NOT NULL
         ORDER BY ISNULL(m.ord, 100000), m.field
         FOR XML PATH(''), TYPE).value('.','nvarchar(max)'),1,2,'');
      IF @col_select IS NULL OR LTRIM(RTRIM(@col_select))=N'' SET @col_select=N'*';
    END

*/
/* ===== 10) EXPORTAÇÃO POR MODELO ===== */

    IF @cd_parametro = 10
    BEGIN
      IF @nm_view IS NULL
        THROW 50012, 'Modelo sem VIEW configurada (Modelo_Exportacao_Formato.nm_view).', 1;

      /* Excel → dados + meta */
      IF UPPER(@ic_tipo_saida) = 'EXCEL'
      BEGIN
        DECLARE @sqlE NVARCHAR(MAX) =
          N'SELECT ' + @col_select + N'
            FROM ' + QUOTENAME(@nm_view) + N' WITH(NOLOCK)
            WHERE 1=1
              AND (@p_emp IS NULL OR cd_empresa = @p_emp)
              AND (@p_ini IS NULL OR dt_movimento >= @p_ini)
              AND (@p_fim IS NULL OR dt_movimento < DATEADD(DAY,1,@p_fim))
            ORDER BY 1';

        DECLARE @paramsE NVARCHAR(200) = N'@p_emp INT, @p_ini DATETIME2(0), @p_fim DATETIME2(0)';
        EXEC sp_executesql @sqlE, @paramsE, @p_emp=@cd_empresa, @p_ini=@dt_inicial, @p_fim=@dt_final;

        /* 2º resultset: meta (para o front montar cabeçalhos/ordem) */
        SELECT @json_meta AS json_meta, @ic_tipo_saida AS ic_tipo_saida;
        RETURN;
      END

     
      /* JSON → retorna um único campo [json] com o payload final */
      IF UPPER(@ic_tipo_saida) = 'JSON'
      BEGIN
        /* monta SELECT conforme meta (renomeia colunas com "as") */
        DECLARE @sqlJ NVARCHAR(MAX) =
          N'SELECT ' + @col_select + N'
            FROM ' + QUOTENAME(@nm_view) + N' WITH(NOLOCK)
            WHERE 1=1
              AND (@p_emp IS NULL OR cd_empresa = @p_emp)
              AND (@p_ini IS NULL OR dt_movimento >= @p_ini)
              AND (@p_fim IS NULL OR dt_movimento < DATEADD(DAY,1,@p_fim))
            ORDER BY 1';

        DECLARE @paramsJ NVARCHAR(200) = N'@p_emp INT, @p_ini DATETIME2(0), @p_fim DATETIME2(0)';

        /* linhas em JSON */
        DECLARE @rows NVARCHAR(MAX);
        DECLARE @sqlRows NVARCHAR(MAX) =
          N'SELECT @out = (SELECT * FROM (' + @sqlJ + N') AS X FOR JSON PATH, INCLUDE_NULL_VALUES)';
        EXEC sp_executesql @sqlRows,
             N'@p_emp INT,@p_ini DATETIME2(0),@p_fim DATETIME2(0),@out NVARCHAR(MAX) OUTPUT',
             @p_emp=@cd_empresa, @p_ini=@dt_inicial, @p_fim=@dt_final, @out=@rows OUTPUT;

        IF @rows IS NULL SET @rows = N'[]';

        /* monta objeto final: { root: { cd_modelo, periodo, arrayName:[...] } } ou { arrayName:[...] } */
       

        IF @nm_root IS NOT NULL
        BEGIN
          SET @json = (
            SELECT
              @cd_modelo   AS cd_modelo,
              @cd_empresa  AS cd_empresa,
              @dt_inicial  AS dt_inicial,
              @dt_final    AS dt_final,
              JSON_QUERY(@rows) AS [itens]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
          );

          /* se desejar um nome de array custom (nm_array) */
          IF @nm_array IS NOT NULL AND @nm_array <> N'itens'
            SET @json = REPLACE(@json,'"itens":', '"' + @nm_array + '":');

          /* embrulha em root */
          SET @json = (
            SELECT JSON_QUERY(@json) AS [@nm_root]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
          );
          /* Ajusta a key root para o nome desejado */
          SET @json = REPLACE(@json,'["@nm_root"]', '"' + @nm_root + '"');
        END
        ELSE
        BEGIN
          /* sem root: { itens:[...] } */
          SET @json = (
            SELECT JSON_QUERY(@rows) AS [itens]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
          );
          IF @nm_array IS NOT NULL AND @nm_array <> N'itens'
            SET @json = REPLACE(@json,'"itens":', '"' + @nm_array + '":');
        END

        SELECT [json] = @json;  -- 1 linha / 1 coluna
        RETURN;
      END
        
        --THROW 50013, 'ic_tipo_saida do modelo não suportado nesta versão.', 1;
END

-- Consultas dos Atributos de Exportação para o Arquivo Destino 

IF @cd_parametro = 15
Begin
  select
   t.nm_tabela,
   a.nm_atributo,
   d.*,
   na.nm_natureza_atributo,
   na.nm_formato,
   na.nm_datatype
  from
    egisadmin.dbo.modelo_exportacao_dados_composicao d
    left outer join egisadmin.dbo.tabela t             on t.cd_tabela   = d.cd_tabela
    left outer join egisadmin.dbo.atributo a           on a.nm_atributo = d.nm_atributo and a.cd_tabela = d.cd_tabela
    left outer join egisadmin.dbo.natureza_atributo na on na.cd_natureza_atributo = d.cd_natureza_atributo



  where
    cd_modelo = @cd_modelo


  RETURN

end

---Luna-------------------------------------------------------------------------------------------------------------

IF @cd_parametro = 20
  BEGIN

    --select * from egisadmin.dbo.Modelo_Exportacao_Dados

    --select @cd_modelo
    --return
    set @nm_objeto = ''
    
    select
      top 1
      @nm_objeto=isnull(nm_objeto_principal,'')
    from
      egisadmin.dbo.Modelo_Exportacao_Dados

    where
      cd_modelo = @cd_modelo


    if @cd_modelo in ( 2, 3, 4, 5, 6, 7 )
    begin

      -- Supondo @dt_inicial e @dt_final já recebidos como parâmetro


SELECT 
    @json_final = (
        SELECT 
            ns.cd_nota_saida                  as id,
            'BR'                              as idFilial,
            emi.CNPJ                          as cnpjFilial,
            emi.xFant                         as nomeFilial,
            emi.xNome                         as razaosocialFilial,
            REPLACE(chv.ChaveAcesso,'NFe','') as chaveNotaFiscal,
            id.cd_identificacao_nota_saida    as numeroNotaFiscal,
            chv.serie                         as serieNotaFiscal,
            CONVERT(varchar(10), id.dEmi, 23) as dataEmissaoNotaFiscal,
            CAST(tot.vNF AS varchar(20))      as valorNotaFiscal,
            id.[Mod]                          as codModeloDocumento,
            'SPED'                            as tipoNotaFiscal,
            'A'                               as statusNotaFiscal,
            '99999999999'                     as codigoCliente,
            'CPF'                             as cliente,
            CAST('' AS varchar(60))           as nomeCliente,
            CAST('' AS varchar(60))           as nomeFantasiaCliente,

            -- Itens da Nota Fiscal (como ARRAY de objetos, sem barras)
            JSON_QUERY((
                SELECT 
                     item.cProd  as codProduto,
                     '672'       as codigoTes,
                     item.xProd  as descProduto,
                     item.qCom   as quantProduto,
                     item.vProd  as valorProduto,
                     item.vDesc  as descontoUnitario,
                     item.uCom   as codUnidadeProduto,
                     item.vUnCom as valorUnitario,
                     item.CFOP   as idCFOP,
                     item.CST    as situacaoTributaria,
                     item.nItem  as numeroItemNota
                FROM vw_nfe_produto_servico_nota_fiscal item
                WHERE item.cd_nota_saida = emi.cd_nota_saida
                FOR JSON PATH
            ))                                  as itensNotaFiscal,
            JSON_QUERY((
                select 
                  isnull(tpc.nm_tipo_pagamento,'')       as grupoPagto,
                  isnull(tpc.nm_codigo_natureza,'')      as codnatureza,
                  isnull(tpc.nm_natureza_financeira,'')  as naturezaFinanceira,
                  CONVERT(varchar(10), nfe.dVenc, 23)    as diasvenc,
                  cast(round(nfe.vPag,2) as varchar)     as valorParcela,
                  ''                                     as txid,
                  isnull(mcp.cd_nsu_tef,'')              as nsu,
                  isnull(mcp.cd_autorizacao_tef,'')      as codautorizacao,
                  isnull(bc.nm_bandeira_cartao,'')       as bandeira,
                  cast(cast(nfe.nDup as int) as varchar) as parcela,
                  '0'                                    as tipoPagamento,
                  '0.00'                                 as taxaparc,
                  '1'                                    as idParcelamento,
                  'false'                                as pagtoGarantia

                from  
                  vw_nfe_parcela_nota_fiscal nfe
                  left outer join Movimento_Caixa mc       on mc.cd_nota_saida       = nfe.cd_nota_saida
                  inner join Movimento_Caixa_Pagamento mcp on mcp.cd_movimento_caixa = mc.cd_movimento_caixa 
                  left outer join Tipo_Pagamento_Caixa tpc on tpc.cd_tipo_pagamento  = mcp.cd_tipo_pagamento
                  left outer join Bandeira_Cartao bc       on bc.cd_bandeira_cartao  = mcp.cd_bandeira_cartao
                
                where 
                  nfe.cd_nota_saida = emi.cd_nota_saida

                FOR JSON PATH

            ))                                  as formaPagamento

        FROM 
            vw_nfe_emitente_nota_fiscal emi
            LEFT JOIN vw_nfe_identificacao_nota_fiscal id ON id.cd_nota_saida  = emi.cd_nota_saida
            LEFT JOIN vw_nfe_chave_acesso chv             ON chv.cd_nota_saida = emi.cd_nota_saida
            LEFT JOIN vw_nfe_totais_nota_fiscal tot       ON tot.cd_nota_saida = emi.cd_nota_saida
            LEFT JOIN Nota_Saida ns                       ON ns.cd_nota_saida  = emi.cd_nota_saida
        WHERE 
            emi.dt_nota_saida BETWEEN @dt_inicial AND @dt_final
            AND ns.cd_status_nota = 5
            AND id.[Mod] = '65'
        ORDER BY
            id.cd_identificacao_nota_saida ASC
        FOR JSON PATH
    );

-- Retorna uma única linha, com uma coluna "data" que é um ARRAY JSON
SELECT @json_final AS data;
----------------------------

     
      return


    end

    --Produtos para Venda - Api da Cayena---------------------------------------------------------------------------------

    if @cd_modelo = 10
    begin

      --Cayena / NAF - Estoque
      select
        p.cd_produto                          as 'productId',
        p.nm_produto                          as 'description',
  --um.sg_unidade_medida                  as 'units',
   (
    SELECT
      um.sg_unidade_medida AS codUni,
      um.nm_unidade_medida AS descrUni
    FOR JSON PATH
  )                                          as 'units',
  --Teste e temos que tratar conforme a Tabela de Preço--
  case when isnull(p.vl_produto,0) = 0 then
   1.00
  else
    isnull(p.vl_produto,0.00)
  end                                        as 'price',
  -------------------------------------------------------
  isnull(ps.qt_saldo_reserva_produto,0) as 'stock',
  p.cd_codigo_barra_produto             as 'EAN',
  null                                  as 'validade',
  cast('' as nvarchar(max))             as 'foto'
from
  produto p
  inner join unidade_medida um     on um.cd_unidade_medida = p.cd_unidade_medida
  left outer join produto_saldo ps on ps.cd_produto = p.cd_produto
                                      and
                                      ps.cd_fase_produto = p.cd_fase_produto_baixa
where
  isnull(p.cd_status_produto,1) = 1
  and
  isnull(ps.qt_saldo_reserva_produto,0)>0

order by
  p.cd_mascara_produto

   
      return
    end

DECLARE @cols  nvarchar(max);
DECLARE @from  nvarchar(max);
--DECLARE @sql   nvarchar(max);
DECLARE @p_ini datetime = @dt_inicial;
DECLARE @p_fim datetime = @dt_final;

/* 1) Base do modelo: materializa em #m */

IF OBJECT_ID('tempdb..#m') IS NOT NULL DROP TABLE #m;
SELECT 
  m.cd_item_modelo,
  m.cd_tabela,
  m.nm_atributo,             -- pode vir 'alias.coluna' ou só 'coluna'
  m.nm_atributo_destino,     -- nome no JSON
  m.nm_valor_padrao_atributo,
  cast(m.ds_atributo_destino as nvarchar(max)) as ds_atributo_destino,
  m.nm_objeto,
  isnull(t.ic_sap_admin,'N')     as ic_admin,
  isnull(m.ic_tabela_master,'N') as ic_tabela_master


INTO #m
FROM 
  egisadmin.dbo.Modelo_Exportacao_Dados_Composicao m WITH (NOLOCK)
  left outer join egisadmin.dbo.tabela t on t.cd_tabela = m.cd_tabela
 
WHERE 
  m.cd_modelo = @cd_modelo

order by
  m.cd_item_modelo

  --select * from #m
  --return


--AND m.nm_objeto = @obj   -- (ligue se quiser filtrar por objeto)

/* 2) Tabelas e aliases dinâmicos: #aliases
   AJUSTE: troque egisadmin.dbo.Tabela pelo seu catálogo real cd_tabela -> nm_tabela
*/
IF OBJECT_ID('tempdb..#aliases') IS NOT NULL DROP TABLE #aliases;
WITH tabs AS (
  SELECT DISTINCT    
    m.cd_item_modelo,
    m.cd_tabela,
    t.nm_tabela,
    --ROW_NUMBER() OVER (ORDER BY m.cd_tabela) AS rn,
    m.cd_tabela as rn,
    case when isnull(t.ic_sap_admin,'N') = 'S' then 'EgisAdmin' else '' end nm_alias_banco
  FROM #m m
  JOIN egisadmin.dbo.Tabela t WITH (NOLOCK) ON t.cd_tabela = m.cd_tabela
  --order by m.cd_item_modelo
)

SELECT
  --cd_item_modelo,
  distinct
  t.cd_tabela,
  t.nm_tabela,
  CAST('t' + CAST(rn AS varchar(5)) AS sysname) AS alias,
  t.nm_alias_banco,
  cast(0 as int)        as cd_item_modelo,
  cast('N' as char(1))  as ic_tabela_master

INTO #aliases
FROM tabs t;

--select * from #aliases
--return

update
  #aliases
set 
 cd_item_modelo   = m.cd_item_modelo,
 ic_tabela_master = m.ic_tabela_master
from
  #aliases a
  inner join #m m on m.cd_tabela = a.cd_tabela

/* 3) Normaliza expressão do atributo com alias: #m_norm */
IF OBJECT_ID('tempdb..#m_norm') IS NOT NULL DROP TABLE #m_norm;


SELECT
  m.cd_item_modelo,
  m.cd_tabela,
  m.nm_atributo,
  m.nm_atributo_destino,
  m.nm_valor_padrao_atributo,
  m.ds_atributo_destino,
  a.alias,
  CASE 
    WHEN NULLIF(LTRIM(RTRIM(m.nm_atributo)), '') IS NULL THEN NULL
    WHEN CHARINDEX('.', m.nm_atributo) > 0 THEN m.nm_atributo
    ELSE a.alias + '.' + QUOTENAME(m.nm_atributo)
  END AS expr_origem
INTO #m_norm
FROM #m m
left JOIN #aliases a ON a.cd_tabela = m.cd_tabela
order by
  m.cd_item_modelo


--select * from #m_norm
--order by
--  cd_item_modelo

--select * from #aliases
--return



/* 4) FROM / JOIN dinâmico */

SELECT @from =
  STUFF((
    SELECT
      CASE WHEN --ROW_NUMBER() OVER (ORDER BY a.cd_tabela) = 1
               ic_tabela_master = 'S' 

           THEN CHAR(13) + 'FROM ' + QUOTENAME(a.nm_tabela) + ' ' + a.alias
           ELSE CHAR(13) + 'LEFT JOIN ' + QUOTENAME(a.nm_tabela) + ' ' + a.alias + ' ON 1=1'  -- <== AJUSTE seus ONs reais aqui
      END
    FROM #aliases a
    ORDER BY a.cd_item_modelo, a.cd_tabela
    FOR XML PATH(''), TYPE
  ).value('.','nvarchar(max)'), 1, 1, '');

/* 5) Colunas dinâmicas (preferindo ds_atributo_destino se você quiser) */
SET @cols = NULL;

SELECT @cols =
  STUFF((
    SELECT
      ', ' + QUOTENAME(n.nm_atributo_destino) + ' = ' +
      'COALESCE((' +
        CASE 
          WHEN NULLIF(LTRIM(RTRIM(n.ds_atributo_destino)), '') IS NOT NULL THEN n.ds_atributo_destino
          WHEN NULLIF(LTRIM(RTRIM(n.expr_origem)), '') IS NOT NULL THEN n.expr_origem
          ELSE 'NULL'
        END
      + '), ' +
        CASE 
          WHEN n.nm_valor_padrao_atributo IS NULL OR LTRIM(RTRIM(n.nm_valor_padrao_atributo)) = '' 
            THEN 'NULL'
          ELSE QUOTENAME(n.nm_valor_padrao_atributo, '''')
        END
      + ')'
    FROM #m_norm n
    --WHERE n.nm_objeto = @obj   -- (ligue se estiver trabalhando objeto a objeto)
    ORDER BY n.cd_item_modelo
    FOR XML PATH(''), TYPE
  ).value('.','nvarchar(max)'), 1, 2, '');

/* 6) Alias “principal” para filtro (pegando o de menor cd_tabela, ajuste se precisar) */
DECLARE @alias_principal sysname;
SELECT TOP (1) @alias_principal = alias FROM #aliases 
order by
  cd_item_modelo

--select 
--@alias_principal
--return


/* 7) SELECT final → JSON */
SET @sql = N'
  SELECT (
    SELECT ' + @cols + CHAR(13) + @from + N'
    WHERE ' + @alias_principal + N'.dt_nota_saida >= @p_ini
      AND ' + @alias_principal + N'.dt_nota_saida < DATEADD(day, 1, @p_fim)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
  ) AS json;';

-- Debug opcional:
 SELECT @from AS from_sql, @cols AS cols_sql, @sql AS full_sql;

return


--DECLARE @catch TABLE (json nvarchar(max));

-- executa o SELECT dinâmico que retorna 1 linha/coluna: json
INSERT INTO @catch(json)
EXEC sp_executesql
  @sql,
  N'@p_ini datetime, @p_fim datetime',
  @p_ini = @p_ini,
  @p_fim = @p_fim;

IF ISNULL(@nm_objeto, '') <> ''
BEGIN
  -- Envelopa como {"data":[ ... ]}
  DECLARE @json_out nvarchar(max);

  SELECT @json_out =
    N'{"data":[' +
    ISNULL(
      STUFF((
        SELECT ',' + c.json
        FROM @catch AS c
        FOR XML PATH(''), TYPE
      ).value('.','nvarchar(max)'), 1, 1, ''),
      N''
    ) + N']}';

  SELECT @json_out AS json_out;  -- saída final

END
ELSE
BEGIN
  -- Sem envelope: retorna o JSON “cru” gerado pelo SELECT dinâmico
  -- (se houver mais de 1 linha em @catch, você pode escolher a 1ª ou concatenar)
  SELECT json AS json_out
  FROM @catch;
END


return;


   IF @cd_modelo = 21111111
  BEGIN
    -- tabela acumuladora dos JSONs por objeto
    DECLARE @tjson TABLE (
      nm_objeto sysname,
      json      nvarchar(max)
    );

    -- lista de objetos do modelo
    IF OBJECT_ID('tempdb..#objs') IS NOT NULL DROP TABLE #objs;
    SELECT DISTINCT nm_objeto
    INTO #objs
    FROM egisadmin.dbo.Modelo_Exportacao_Dados_Composicao WITH (NOLOCK)
    WHERE cd_modelo = @cd_modelo;

    -- variáveis necessárias (AGORA declaradas!)
    DECLARE
      @obj  sysname
      --@cols nvarchar(max)

      --@sql  nvarchar(max);

    set @sql = ''

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
      SELECT nm_objeto FROM #objs ORDER BY nm_objeto;

    OPEN c; FETCH NEXT FROM c INTO @obj;

    WHILE @@FETCH_STATUS = 0
    BEGIN
      /* Monta a lista de colunas:
         - usa ds_atributo_destino quando não vazio
         - senão tenta nm_atributo (ajuste se precisar prefixar alias/tabela)
         - sempre aplica COALESCE com o valor padrão
      */

      SET @cols = NULL;

      SELECT @cols =
        STUFF((
          SELECT
            ', ' +
            QUOTENAME(m.nm_atributo_destino) + ' = ' +
            'COALESCE((' +
              CASE
                WHEN NULLIF(LTRIM(RTRIM(m.nm_atributo)), '') IS NOT NULL
                  THEN m.nm_atributo
                WHEN NULLIF(LTRIM(RTRIM(m.nm_atributo)), '') IS NOT NULL
                  THEN QUOTENAME(m.nm_atributo)   -- <== ajuste aqui se precisar prefixar alias (ex.: ns.[campo])
                ELSE 'NULL'
              END
            + '), ' +
              CASE
                WHEN m.nm_valor_padrao_atributo IS NULL THEN 'NULL'
                ELSE QUOTENAME(m.nm_valor_padrao_atributo, '''')
              END
            + ')'
          FROM egisadmin.dbo.Modelo_Exportacao_Dados_Composicao m WITH (NOLOCK)
          WHERE m.cd_modelo = @cd_modelo
            AND m.nm_objeto = @obj
          ORDER BY m.cd_item_modelo
          FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)'), 1, 2, '');

      /* FROM/JOIN do “contexto” das expressões.
         Ajuste conforme suas tabelas/aliases usados em ds_atributo_destino:
           - ns = Nota_Saida
           - nsi = Nota_Saida_Item
           - cli = Cliente
         e os filtros por período.
      */

      --select @cols

      --return


      SET @sql = N'
        SELECT (
          SELECT ' + @cols + '
          FROM Nota_Saida ns WITH (NOLOCK)
          LEFT JOIN Nota_Saida_Item nsi WITH (NOLOCK) ON nsi.cd_nota_saida = ns.cd_nota_saida
          LEFT JOIN Cliente cli WITH (NOLOCK)        ON cli.cd_cliente    = ns.cd_cliente
          -- ... inclua outros JOINs necessários às suas expressões ...
          WHERE ns.dt_nota_saida >= @p_ini
            AND ns.dt_nota_saida < DATEADD(day, 1, @p_fim)
          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS json;
      ';

      --select @sql

      
      INSERT INTO @catch(json)
      EXEC sp_executesql
           @sql,
           N'@p_ini datetime, @p_fim datetime',
           @p_ini = @dt_inicial,
           @p_fim = @dt_final;

      INSERT INTO @tjson(nm_objeto, json)
      SELECT @obj, json FROM @catch;

      FETCH NEXT FROM c INTO @obj;

    END

    CLOSE c; DEALLOCATE c;

    -- Saída final: um array com { nm_objeto, objeto(json) }
    SELECT (
      SELECT nm_objeto, json AS objeto
      FROM @tjson
      FOR JSON PATH, ROOT('data')
    ) AS json_out;

    RETURN;
  END
END


---


 /* Padrão se nenhum caso for tratado */
 SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;
   
 END TRY
    BEGIN CATCH
        DECLARE
            @errnum   INT          = ERROR_NUMBER(),
            @errmsg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @errproc  NVARCHAR(128) = ERROR_PROCEDURE(),
            @errline  INT          = ERROR_LINE(),
            @fullmsg  NVARCHAR(2048);



         -- Monta a mensagem (THROW aceita até 2048 chars no 2º parâmetro)
    SET @fullmsg =
          N'Erro em pr_egis_exportacao_dados ('
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
--exec  pr_egis_modelo_procedure
------------------------------------------------------------------------------

go
/*
exec  pr_egis_exportacao_dados '[{"cd_parametro": 0}]'
exec  pr_egis_exportacao_dados '[{"cd_parametro": 100}]'
exec  pr_egis_exportacao_dados '[{"cd_parametro": 20, "cd_modelo": 2, "dt_inicial":"2025-11-21", "dt_final":"2025-11-21"}]'
*/
go
------------------------------------------------------------------------------
GO
--use egissql_360

-- objeto único
--EXEC dbo.pr_egis_modelo_procedure
--N'{
--   "cd_empresa": 1,
--   "cd_parametro": 0,
--   "cd_usuario": 123,
--   "dt_inicial": "2025-09-01 00:00:00",
--   "dt_final":   "2025-09-30 23:59:59"
--}';

-- array com 1 objeto (também aceito)

--EXEC pr_egis_exportacao_dados
--N'[{
--   "cd_empresa": 1,
--   "cd_parametro": 15,
--   "cd_modelo": 2,

--   "cd_usuario": 123
--}]';

--go
--EXEC pr_egis_exportacao_dados
--N'[{
--   "cd_parametro" : 9,
--   "cd_modelo": 50,
--   "dt_inicial" : "11/14/2025",
--   "dt_final" : "11/14/2025"
--}]';
go

--EXEC pr_egis_exportacao_dados
--N'[{
--   "cd_parametro" : 9,
--  "cd_modelo": 10
--}]';

--Cliente -- "cd_cnpj" : "40587150000168",

--EXEC pr_egis_exportacao_dados
--N'[{
--   "cd_parametro" : 9,
--  "cd_modelo": 11,
--  "cd_cnpj": "12678858000199"
--}]';

--select max(cd_pedido_venda) from pedido_venda

--select * from pedido_venda_item where cd_pedido_venda = 531850

--EXEC pr_egis_exportacao_dados
--N'[{
--   "cd_parametro" : 9,
--  "cd_modelo": 70,
--  "orderId": 531850

--}]'

--EXEC pr_egis_exportacao_dados
--N'[{
--   "cd_parametro" : 20,
--  "cd_modelo": 2
--}]';


--"filtros": "{ "uf": "SP" }"

--EXEC pr_egis_exportacao_dados
--N'[{
--   "cd_empresa": 1,
--   "cd_parametro": 20,
--   "cd_modelo": 2,
--   "cd_usuario": 123
--}]';


--EXEC pr_egis_exportacao_dados
--N'[{
--   "cd_empresa": 360,
--   "cd_parametro": 1,
--   "cd_usuario": 123,
   
--}]';
--EXEC pr_egis_exportacao_dados
--N'[{
--   "cd_empresa": 1,
--   "cd_parametro": 500,
--   "cd_usuario": 123
--}]';

--EXEC pr_egis_exportacao_dados
--N'[{
--   "cd_empresa": 1,
--   "cd_parametro": 600,
--   "cd_usuario": 123
--}]';

/*
use egisadmin

/* 1.1 – SQL por modelo (apenas SELECT parametrizado) */
IF OBJECT_ID('egisadmin.dbo.Modelo_Exportacao_SQL','U') IS NULL
CREATE TABLE egisadmin.dbo.Modelo_Exportacao_SQL(
  cd_modelo        INT           NOT NULL PRIMARY KEY
 ,sql_select       NVARCHAR(MAX) NOT NULL  -- somente SELECT
 ,nm_obs_sql       NVARCHAR(200) NULL
 ,dt_usuario       DATETIME2(0)  NOT NULL DEFAULT SYSDATETIME()
 ,cd_usuario       INT           NULL
);

/* 1.2 – Mapa de campos para exportações (inclui OFX) */
IF OBJECT_ID('egisadmin.dbo.Modelo_Exportacao_Mapa','U') IS NULL
CREATE TABLE egisadmin.dbo.Modelo_Exportacao_Mapa(
  cd_modelo   INT        NOT NULL PRIMARY KEY
 ,campo_data  SYSNAME    NULL   -- ex.: dt_movimento
 ,campo_valor SYSNAME    NULL   -- ex.: vl_lancamento
 ,campo_id    SYSNAME    NULL   -- ex.: cd_documento
 ,campo_memo  SYSNAME    NULL   -- ex.: ds_movimento_caixa
 ,dt_usuario  DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
 ,cd_usuario  INT        NULL
 ,CONSTRAINT FK_Mapa_Exp_Modelo FOREIGN KEY(cd_modelo)
    REFERENCES egisadmin.dbo.Modelo_Exportacao_Dados(cd_modelo)
);

/* onde você já tem: egisadmin.dbo.Modelo_Exportacao_Dados (cd_modelo, nm_modelo, cd_tabela, ...) */

/* 1) Formato/Configuração por modelo */
IF OBJECT_ID('egisadmin.dbo.Modelo_Exportacao_Formato','U') IS NULL
CREATE TABLE egisadmin.dbo.Modelo_Exportacao_Formato (
  cd_modelo     INT         NOT NULL PRIMARY KEY
 ,ic_tipo_saida VARCHAR(12) NOT NULL      -- 'EXCEL' | 'JSON' | (futuro: CSV/TXT/XML/OFX)
 ,nm_view       SYSNAME     NULL          -- VIEW base da exportação
 ,json_meta     NVARCHAR(MAX) NULL        -- meta de colunas (ordem, caption, tipos) para Excel/Grid
 ,nm_root       NVARCHAR(128) NULL        -- nome do root no JSON (opcional)
 ,nm_array      NVARCHAR(128) NULL        -- nome do array no JSON (ex.: 'itens')
 ,dt_usuario    DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
 ,cd_usuario    INT NULL
);

/* 2) (opcional) SQL parametrizado, caso algum modelo precise de SELECT custom
   — manter para outros casos; para esses dois modelos, vamos usar a VIEW. */
IF OBJECT_ID('egisadmin.dbo.Modelo_Exportacao_SQL','U') IS NULL
CREATE TABLE egisadmin.dbo.Modelo_Exportacao_SQL(
  cd_modelo   INT           NOT NULL PRIMARY KEY
 ,sql_select  NVARCHAR(MAX) NOT NULL
 ,nm_obs_sql  NVARCHAR(200) NULL
 ,dt_usuario  DATETIME2(0)  NOT NULL DEFAULT SYSDATETIME()
 ,cd_usuario  INT           NULL
);



*/

--use egissql_273

--go