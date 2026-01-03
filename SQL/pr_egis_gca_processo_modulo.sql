IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_gca_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_gca_processo_modulo

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_gca_processo_modulo
-------------------------------------------------------------------------------
--pr_egis_gca_processo_modulo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : GCA - Gestão de Caixa
--                   Processo do Módulo de Gestão de Caixa
--
--Data             : 20.07.2025
--Alteração        : 29.10.2025 - Ajustes no insert into dos movimentos caixa - Denis Rabello 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_gca_processo_modulo    
@json nvarchar(max) = ''              

--with encryption

as                        

set @json = isnull(@json,'')
                        
declare @cd_empresa          int                        
declare @cd_parametro        int                        
declare @cd_documento        int = 0                        
declare @cd_item_documento   int                        
declare @cd_cliente          int                        
declare @cd_cliente_parametro int              
declare @cd_relatorio        int                         
declare @cd_usuario          int                         
declare @cpf                 varchar(20) = ''                         
declare @ic_status_servidor_nfe varchar(1) = 'N'                        
declare @dt_hoje             datetime                        
declare @dt_inicial          datetime                         
declare @dt_final            datetime                        
declare @cd_ano              int = 0                        
declare @cd_mes              int = 0                        
declare @vl_sub_total_tela   decimal(25,2) = 0.00                
declare @vl_desconto         decimal(25,2) = 0.00              
declare @vl_total_hoje       decimal(25,2) = 0.00                        
declare @cd_vendedor         int           = 0                        
declare @cd_operador_caixa   int           = 0                        
declare @cd_menu             int           = 0                        
declare @nm_fantasia_empresa varchar(30)   = ''                        
declare @ic_imposto_venda    char(1)       = 'N'                        
declare @cd_movimento_caixa  int           = 0            
declare @cd_item_divisao int               = 0          
declare @vl_pagamento float                = 0.00  
declare @vl_taxa_pagamento float           = 0.00
declare @nm_obs_divisao varchar(60)        = ''          
declare @nm_produto_busca    varchar(50)   = ''                  
declare @ic_parametro int = 1                        
declare @nm_fantasia_funcionario varchar(50) = ''               
declare @nm_fantasia_cliente varchar(50) = ''           
declare @dt_nascimento_cliente datetime           
declare @cd_ddd_cliente varchar(10) = ''           
declare @cd_celular_cliente varchar(20) = ''           
declare @nm_email_cliente varchar(50) = ''           
declare @cd_funcionario nvarchar(max)=''               
declare @cd_identificacao_promocao varchar(30) = ''              
declare @cd_promocao int = 0   
declare @qt_limite_promocao_semana int = 0
declare @qt_promocao_semana int = 0         
declare @operador    varchar(50) = ''                        
declare @operador_password   varchar(50) = ''                        
declare @nm_nfe_link  varchar(50) = ''                        
declare @nm_basesql  varchar(50) = ''                        
declare @jsonItens        nvarchar(max)=''              
declare @cd_tabela_preco int              
declare @cd_funcionario_int int          
declare @qt_produto_promocao float
declare @vl_troco float  
declare @cd_bandeira_cartao int
declare @cd_nsu_tef varchar(50)          
declare @cd_autorizacao_tef varchar(50) 
declare @cd_nsu_tef_pix varchar(50)          
declare @cd_autorizacao_tef_pix varchar(50) 
declare @nm_bandeira_cartao varchar(50)
declare @pc_taxa_bandeira float = 0.00
declare @ic_finalizado_divisao char(1)
declare @ic_nfce char(1)
-- Declaração de variáveis específicas para verificação                        
DECLARE @ic_atendimento CHAR(1);                        
DECLARE @cd_terminal INT = 0;                        
DECLARE @operador_final INT = 0;     
-- Extrair dados específicos para criação do movimento de caixa                        
declare @cd_tipo_movimento_caixa int          
declare @cd_terminal_caixa int          
declare @cd_tipo_pagamento int
declare @cd_tipo_pagamento_tab int
declare @cd_loja int
declare @cd_cpf_digitado varchar(18)
declare @cd_maquina_cartao int
declare @cd_condicao_pagamento int
declare @cd_condicao_pagamento_band int
-- Periodo Semana------------------------------------------------
declare @dt_inicio_semana datetime
declare @dt_fim_semana datetime
          
DECLARE @cd_nota_saida int          
declare @base_url varchar(200)          
set @base_url = ''          
              
           
set @cd_empresa        = 0                        
set @cd_parametro      = 0                        
set @cd_documento      = 0                        
set @cd_relatorio      = 0                        
set @cd_item_documento = 0                        
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)                        
set @cd_ano            = year(getdate())                        
set @cd_mes            = month(getdate())                          
set @vl_sub_total_tela = 0                        
                        
if @dt_inicial is null                        
begin                        
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)                        
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)                        
end                        

set @dt_inicio_semana = DATEADD(wk, DATEDIFF(wk, 0, @dt_hoje), 0)-1                  
set @dt_fim_semana = DATEADD(wk, DATEDIFF(wk, 0, @dt_hoje), 0) +5

if @nm_basesql = ''                        
begin                        
 SET @nm_basesql = 'EGISSQL_358'                        
end                        
--tabela                        
--select ic_sap_admin, * from Tabela where cd_tabela = 5287              
              
              
                        
select                                             
                        
 1                                                    as id_registro,                        
 IDENTITY(int,1,1)                                    as id,                        
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                                        
 valores.[value]              as valor                                            
                                            
 into #json                                            
 from                                        
  openjson(@json)root                                            
   cross apply openjson(root.value) as valores                              
                        
select @cd_empresa             = valor from #json where campo = 'cd_empresa'                           
select @cd_documento           = valor from #json where campo = 'cd_documento'                        
select @cd_relatorio           = valor from #json where campo = 'cd_relatorio'                        
select @cd_item_documento      = valor from #json where campo = 'cd_item_documento'                        
select @cd_parametro           = valor from #json where campo = 'cd_parametro'                                  
select @cd_cliente             = valor from #json where campo = 'cd_cliente'                                  
select @cd_usuario             = valor from #json where campo = 'cd_usuario'                                     
select @dt_inicial             = valor from #json where campo = 'dt_inicial'                                     
select @dt_final               = valor from #json where campo = 'dt_final'                                     
select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'                        
select @cd_operador_caixa      = valor from #json where campo = 'cd_operador_caixa'                        
select @cd_menu                = valor from #json where campo = 'cd_menu'                        
select @cd_movimento_caixa     = valor from #json where campo = 'cd_movimento_caixa'             
select @cd_item_divisao        = valor from #json where campo = 'cd_item_divisao'          
select @vl_pagamento           = valor from #json where campo = 'vl_pagamento'          
select @nm_obs_divisao         = valor from #json where campo = 'nm_obs_divisao'          
select @cpf                    = valor from #json where campo = 'cpf'          
select @operador      = valor from #json where campo = 'operador'          
select @operador_password      = valor from #json where campo = 'operador_password'          
select @nm_produto_busca = valor from #json where campo = 'nm_produto_busca'                        
select @ic_parametro = valor  from #json where campo = 'ic_parametro'                         
select @nm_fantasia_funcionario = valor  from #json where campo = 'nm_fantasia_funcionario'              
select @nm_fantasia_cliente = valor  from #json where campo = 'nm_fantasia_cliente'              
select @dt_nascimento_cliente = valor from #json where campo = 'dt_nascimento_cliente'          
select @cd_ddd_cliente = valor  from #json where campo = 'cd_ddd_cliente'              
select @cd_celular_cliente = valor  from #json where campo = 'cd_celular_cliente'              
select @nm_email_cliente = valor  from #json where campo = 'nm_email_cliente'          
select @cd_funcionario = valor from #json where campo = 'cd_funcionario'              
select @cd_identificacao_promocao = valor from #json where campo = 'cd_identificacao_promocao'              
select @vl_sub_total_tela  = valor from #json with(nolock) where campo = 'vl_sub_total_tela'            
select @vl_troco           = valor from #json with(nolock) where campo = 'vl_troco'          
select @cd_nsu_tef         = valor from #json with(nolock) where campo = 'cd_nsu_tef'          
select @cd_autorizacao_tef = valor from #json with(nolock) where campo = 'cd_autorizacao_tef'
select @cd_nsu_tef_pix         = valor from #json with(nolock) where campo = 'cd_nsu_tef_pix'          
select @cd_autorizacao_tef_pix = valor from #json with(nolock) where campo = 'cd_autorizacao_tef_pix'
select @nm_bandeira_cartao = valor from #json with(nolock) where campo = 'nm_bandeira_cartao'
select @jsonitens          = valor from #json with(nolock) where campo = 'jsonItens' 
select @ic_finalizado_divisao = valor from #json where campo = 'ic_finalizado'  
select @ic_nfce = valor from #json where campo = 'ic_nfce'            

select @cd_tipo_movimento_caixa = valor from #json where campo = 'cd_tipo_movimento_caixa'                        
select @cd_tipo_pagamento = valor from #json where campo = 'cd_tipo_pagamento'                        
select @cd_loja = valor from #json where campo = 'cd_loja'
              
if (isnull(@ic_nfce,'') = '') or (@ic_nfce is null)
  set @ic_nfce = 'S'

if ltrim(rtrim(@nm_bandeira_cartao)) = ''
  set @nm_bandeira_cartao = null

IF not EXISTS (SELECT name FROM sysobjects                   
           WHERE name = N'Movimento_Caixa_Bandeira' AND type = 'U')                  
begin                  
  Create Table Movimento_Caixa_Bandeira                
  (cd_movimento_caixa int NOT NULL,  
   cd_item_divisao    int NOT NULL,
   nm_bandeira_cartao varchar(50) NULL,          
   cd_bandeira_cartao int NULL
   Constraint PK_Movimento_Caixa_Bandeira                 
   Primary Key (cd_movimento_caixa, cd_item_divisao)) ON [PRIMARY]                
end

IF not EXISTS (SELECT name FROM sysobjects                     
           WHERE name = N'Pedido_Venda_Caixa' AND type = 'U')                    
begin                    
  Create Table Pedido_Venda_Caixa                  
  (cd_pedido_venda int NOT NULL,                  
   ic_finalizado char(1) NULL,             
   cd_cpf_informado varchar(18) NULL,            
   cd_funcionario int NULL,            
   cd_promocao int NULL            
   Constraint PK_Pedido_Venda_Caixa                   
   Primary Key (cd_pedido_venda)) ON [PRIMARY]                  
end

set @cd_empresa = ISNULL(@cd_empresa,0)          
if @cd_empresa = 0          
   set @cd_empresa = dbo.fn_empresa()          
                        
if @cd_operador_caixa = 0                        
begin          
 select top 1           
   @cd_operador_caixa = cd_operador_caixa          
 from          
   Abertura_Caixa          
 order by          
   cd_abertura_caixa desc          
           
          
 --set @cd_operador_caixa = 1                        
end          
                        
set @cd_tabela_preco = 0              
              
              
select              
  @cd_cliente_parametro = cd_cliente              
from              
  Parametro_loja              
              
if @cd_cliente_parametro is null or @cd_cliente_parametro = 0              
  set @cd_cliente_parametro = 0              
              
if isnull(@cd_cliente,0) = 0 and @cd_cliente_parametro > 0             
  set @cd_cliente = @cd_cliente_parametro              
              
if isnull(@cd_funcionario,'') <> ''              
begin              
  select              
    @cd_tabela_preco = cd_tabela_preco              
  from              
    Parametro_loja              
end              
              
if @cd_tabela_preco is null or @cd_tabela_preco = 0              
begin              
  select top 1              
    @cd_tabela_preco = cd_tabela_preco              
  from              
    config_terminal_venda              
end              
                
              
if @cd_tabela_preco is null or @cd_tabela_preco = 0              
  set @cd_tabela_preco = 0  

select
  @cd_tipo_pagamento_tab = isnull(cd_tipo_pagamento,0)
from
  Tipo_Pagamento_Caixa
where
  cd_tipo_pagamento_net = @cd_tipo_pagamento

if @cd_tipo_pagamento_tab is null or isnull(@cd_tipo_pagamento_tab,0) = 0
  set @cd_tipo_pagamento_tab = @cd_tipo_pagamento              
                        
set @cd_documento = ISNULL(@cd_documento,0)            
          
   -- Declara variável para fase do produto                        
   DECLARE @cd_fase_produto INT = 0;                        
                        
   -- HIERARQUIA DE FASES: Terminal -> Operador -> Produto                        
   -- 1º Tenta fase do TERMINAL                        
   SELECT @cd_fase_produto = ISNULL(cd_fase_produto, 0)                        
   FROM Config_Terminal_Venda with (nolock);                        
                        
   -- 2º Se terminal não tem, tenta fase do OPERADOR                        
   IF @cd_fase_produto = 0 AND @cd_operador_caixa IS NOT NULL                        
   BEGIN                        
      SELECT @cd_fase_produto = ISNULL(cd_fase_produto, 0)                        
      FROM Operador_Caixa with (nolock)                        
      WHERE cd_operador_caixa = @cd_operador_caixa;         
   END               
                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                
--Processos                                   
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
                        
--parametro para mostrar o nome da empresa                        
                        
                        
--parametro para mostrar o terminal                        
                        
--Login                        
  --> Automário                        
  --> terminal de caixa na tabela disposível                        
      --Terminal_Caixa                        
                        
                        
 --Parametro para mostrar o número do Terminal                        
                        
                        
                        
 --Quando digita o CPF, tem que fazer o Busca do Cadastro do Cliente                        
                        
 --Se for CPF novo insert na Tabela de Cliente ( somente com o CPF, sem nome )                        
                        
                        
                        
                        
                        
 --Busca as forma de pagamento                        
                        
   --select * from Forma_Pagamento order by nm_forma_pagamento --cd_ordem__forma_pagamento                
                        
                        
 --Busca os dados do Servidor de Email do Cliente                        
   --> usuario_email ou config_usuario_email ( Nota Fiscal Eletrônica ) --> frmNotaFiscalEletronica                        
                        
                        
 --TEF-- ( Alexandre/JP )                        
                        
                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
--01 - Carregar o Pedido de Venda                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
                        
if @cd_parametro = 1 and @cd_documento>0                        
begin                        
                        
  select                         
    pvi.cd_pedido_venda,                        
    pvi.cd_item_pedido_venda,                        
    pvi.cd_produto,                        
    pvi.nm_fantasia_produto,                        
    pvi.nm_produto_pedido,                        
    pvi.qt_item_pedido_venda,                        
    isnull(pvi.qt_saldo_pedido_venda,0) as qt_saldo_pedido_venda,                        
    pvi.vl_unitario_item_pedido,                        
    ( pvi.qt_item_pedido_venda * pvi.vl_unitario_item_pedido ) as vl_total_item_pedido,                              
    pvi.pc_icms,                        
    --pf.cd_tributacao,                        
    --Tributacao do Produto para o Cupom Fiscal                        
    tcf.qt_parametro as cd_tributacao,                                
                            
    c.cd_cliente                        
                            
into                        
  #Registro_Venda                        
                        
from                         
  Pedido_venda_item pvi       with (nolock)                        
  left join pedido_venda pv   with (nolock)                 on pv.cd_pedido_venda = pvi.cd_pedido_venda                       
  left join produto p         with (nolock)                 on p.cd_produto = pvi.cd_produto                        
  left join produto_fiscal pf with (nolock)                 on pf.cd_produto = pvi.cd_produto                        
  left join Unidade_Medida um with (nolock)                 on um.cd_unidade_medida = pvi.cd_unidade_medida                        
  left join Cliente c         with (nolock)                 on c.cd_cliente = pv.cd_cliente                        
  left outer join tributacao_cupom_fiscal tcf with (nolock) on tcf.cd_tributacao = p.cd_tributacao                        
                        
                          
where                           
  pvi.cd_pedido_venda = @cd_documento                        
  and                        
  isnull(pvi.cd_item_pedido_venda,0)>0                                   
  and                         
  pvi.dt_cancelamento_item is null                                          
                        
order by                        
  pv.cd_pedido_venda                        
                
                        
select                        
   *                        
from                        
   #Registro_Venda                        
                        
order by                        
  cd_pedido_venda,                        
  cd_item_pedido_venda                        
                        
                        
drop table #Registro_Venda                        
                        
return                        
                        
end                        
                        
                        
--select @cd_parametro                        
                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
--02 - Carregar a Comanda                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 2                        
begin                        
 select @cd_parametro                        
end                        
                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 03 - Criar Pedido de Venda                 
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 3                        
begin   

 --IF @cpf is not null                        
 --BEGIN                        
 -- IF not exists(SELECT cd_cliente FROM Cliente WHERE cd_cnpj_cliente = @cpf)            
 --  BEGIN                        
 --   SELECT @cd_cliente = ISNULL(MAX(cd_cliente), 0) + 1 FROM Cliente;                        
 --   INSERT INTO Cliente (                        
 --     cd_cliente, nm_fantasia_cliente, nm_razao_social_cliente,          
 --     ic_destinacao_cliente, dt_cadastro_cliente, cd_tipo_pessoa,          
 --     cd_cnpj_cliente, cd_ramo_atividade, cd_status_cliente,           
 --     cd_transportadora, cd_tipo_mercado, cd_idioma, cd_usuario,                        
 --     dt_usuario, ic_liberado_pesq_credito)                        
 --   VALUES           
 --   (@cd_cliente, 'TEMP', 'COMANDA TEMP',          
 --    '1', GETDATE(), 2, @cpf, 1, 1, 1,          
 --     1, 1, 1, GETDATE(), 'S')          
                                        
 --    UPDATE Cliente                        
 --    SET                         
 --     nm_fantasia_cliente = CAST(@cd_cliente AS VARCHAR(10)),                        
 --     nm_razao_social_cliente = 'COMANDA ' + CAST(@cd_cliente AS VARCHAR(10))                        
 --    WHERE cd_cliente = @cd_cliente;                        
 --  END                        
 --END                   
          
    -- Extrair dados específicos para criação do pedido                        
                            
    declare @ds_observacao varchar(2000)                        
    declare @cd_tipo_pedido int                        
                       
    select @ds_observacao = valor from #json where campo = 'ds_observacao'                        
    select @cd_tipo_pedido = valor from #json where campo = 'cd_tipo_pedido'                        
    -- Buscar próximo número do pedido                        
    declare @cd_pedido_venda int                        
    select @cd_pedido_venda = isnull(max(cd_pedido_venda), 0) + 1 from pedido_venda with (nolock)         
        
 if isnull(@cd_tipo_pedido,0) = 0        
    begin        
      select         
         @cd_tipo_pedido = cd_tipo_pedido        
       from        
         Tipo_Pedido        
       where        
         isnull(ic_consumidor,'N') = 'S'        
    end             
               
    SET @cd_vendedor = case when isnull((SELECT dbo.fn_usuario_vendedor(@cd_usuario)),0) = 0 then 2               
                         else (SELECT dbo.fn_usuario_vendedor(@cd_usuario)) end              
          
    -- Inserir cabeçalho do pedido                        
    insert into pedido_venda (                        
      cd_pedido_venda,                        
      dt_pedido_venda,                        
      cd_cliente,                        
      cd_vendedor,                    
      cd_vendedor_interno,                  
      cd_condicao_pagamento,                        
      cd_transportadora,                        
      cd_tipo_pedido,                        
      cd_usuario,                        
      dt_usuario,                        
      vl_total_pedido_venda,                  
      dt_credito_pedido_venda,                  
      cd_usuario_credito_pedido,                  
      ic_fechado_pedido,              
      ic_fechamento_total,            
      dt_fechamento_pedido,                  
      cd_destinacao_produto,                  
      cd_tipo_pagamento_frete                  
    ) values (                        
      @cd_pedido_venda,                        
      getdate(),                        
      @cd_cliente,                        
      isnull(@cd_vendedor,2),                     
      1,                  
      1,                        
      null,                        
      isnull(@cd_tipo_pedido, 1), -- Tipo padrão 1 (Venda)                        
      @cd_usuario,                        
      getdate(),                        
      0.00, -- Total inicial zero                        
      @dt_hoje,                  
      @cd_usuario,                  
      'S',         
      'S',        
      @dt_hoje,                  
      2,                  
      4              
    )                      
                
    if exists(select cd_pedido_venda from Pedido_Venda_Caixa where cd_pedido_venda = @cd_pedido_venda)          
 begin          
      update Pedido_Venda_Caixa          
      set ic_finalizado = 'N',          
          cd_cpf_informado = @cpf          
      where       
          cd_pedido_venda = @cd_pedido_venda          
 end          
 else          
 begin          
      insert into Pedido_Venda_Caixa                
      (cd_pedido_venda, ic_finalizado, cd_cpf_informado)                
      values                
      (@cd_pedido_venda, 'N', @cpf)                
    end          
                        
    -- Retornar dados do pedido criado                        
    select                         
      pv.cd_pedido_venda,                        
      pv.dt_pedido_venda,                        
      pv.cd_cliente,                        
      c.nm_fantasia_cliente,                        
      pv.cd_vendedor,                        
      v.nm_fantasia_vendedor,                        
      pv.cd_condicao_pagamento,                        
      cp.nm_condicao_pagamento,                        
      pv.vl_total_pedido_venda,                        
      'Pedido criado com sucesso' as ds_mensagem                        
    from pedido_venda pv                        
    left join cliente c on c.cd_cliente = pv.cd_cliente                        
    left join vendedor v on v.cd_vendedor = pv.cd_vendedor                        
    left join condicao_pagamento cp on cp.cd_condicao_pagamento = pv.cd_condicao_pagamento                        
    where pv.cd_pedido_venda = @cd_pedido_venda                        
                        
                      
end                        
                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 04 -  Inserir Pedido de Venda Item                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 4                        
begin                 
    -- Extrair dados do item                        
    declare @cd_produto_item int                        
    declare @qt_item decimal(15,3)                        
    declare @vl_unitario_item decimal(15,2)                        
    declare @pc_desconto_item decimal(5,2)                        
    declare @cd_item_pedido int                        
                        
    select @cd_documento = valor from #json where campo = 'cd_pedido_venda'                       
    select @cd_produto_item = valor from #json where campo = 'cd_produto'                        
    select @qt_item = valor from #json where campo = 'qt_item'                        
    select @vl_unitario_item = valor from #json where campo = 'vl_unitario'                        
    select @pc_desconto_item = valor from #json where campo = 'pc_desconto'                        
                        
    -- Validações                        
    if @cd_documento is null or @cd_documento = 0                        
      raiserror('Número do pedido é obrigatório', 16, 1)                                          
    if @cd_produto_item is null or @cd_produto_item = 0                        
      raiserror('Produto é obrigatório', 16, 1)                        
                        
    if @qt_item is null or @qt_item <= 0                        
      raiserror('Quantidade deve ser maior que zero', 16, 1)                        
                        
    -- Verificar se pedido existe e está aberto                        
    if not exists (select 1 from pedido_venda where cd_pedido_venda = @cd_documento )                        
      raiserror('Pedido não encontrado ou não está aberto', 16, 1)                        
                        
    -- Buscar informações do produto                        
    declare @cd_unidade_medida int                        
    declare @vl_total_item decimal(15,2)                        
    declare @pc_icms decimal(5,2)                        
    declare @cd_tributacao int            
          
  if not exists(select top 1 cd_pedido_venda from pedido_venda_item where cd_pedido_venda = @cd_documento and cd_produto = @cd_produto_item)          
  begin          
    -- Buscar próximo item do pedido                        
    if @cd_item_pedido is null or @cd_item_pedido = 0                        
      select @cd_item_pedido = isnull(max(cd_item_pedido_venda), 0) + 1                         
      from pedido_venda_item                         
      where cd_pedido_venda = @cd_documento                        
                        
    select                         
      @cd_unidade_medida = p.cd_unidade_medida,          
      @cd_tributacao = p.cd_tributacao          
    from produto p          
    where p.cd_produto = @cd_produto_item                        
                        
    -- Calcular valor total do item                        
    set @vl_total_item = @qt_item * @vl_unitario_item * (1 - isnull(@pc_desconto_item, 0) / 100)                        
                        
    -- Inserir item do pedido                        
    insert into pedido_venda_item (                       
      cd_pedido_venda,                        
      cd_item_pedido_venda,                        
      cd_produto,                        
      nm_fantasia_produto,                        
      nm_produto_pedido,                        
      qt_item_pedido_venda,                        
      qt_saldo_pedido_venda,                        
      vl_unitario_item_pedido,                        
      pc_desconto_item_pedido,                        
      vl_lista_item_pedido,          
      cd_unidade_medida,          
      pc_icms,          
      dt_cancelamento_item,          
      cd_usuario,          
      dt_usuario          
    ) values (          
      @cd_documento,          
      @cd_item_pedido,          
      @cd_produto_item,          
      (select nm_fantasia_produto from produto where cd_produto = @cd_produto_item),          
      (select nm_produto from produto where cd_produto = @cd_produto_item),          
      @qt_item,          
      @qt_item, -- Saldo inicial igual à quantidade          
      @vl_unitario_item,          
      @pc_desconto_item,          
      @vl_unitario_item, -- Valor de lista igual ao unitário          
    @cd_unidade_medida,          
      @pc_icms,          
      null, --Não cancelado          
      @cd_usuario,          
      getdate())          
                        
    -- Atualizar total do pedido                        
    update pedido_venda                        
    set vl_total_pedido_venda = vl_total_pedido_venda + @vl_total_item,                        
        dt_usuario = getdate()                        
    where cd_pedido_venda = @cd_documento           
  end          
  else          
  begin          
    select          
      @cd_item_pedido = cd_item_pedido_venda          
    from          
      pedido_venda_item          
    where          
      cd_pedido_venda = @cd_documento          
      and          
      cd_produto = @cd_produto_item          
  end          
                        
    -- Retornar dados do item inserido                        
    select                         
      pvi.cd_pedido_venda,                        
      pvi.cd_item_pedido_venda,                        
      pvi.cd_produto,                        
      pvi.nm_fantasia_produto,                        
      pvi.qt_item_pedido_venda,                        
      pvi.vl_unitario_item_pedido,                        
      pvi.pc_desconto_item_pedido,                        
      (pvi.qt_item_pedido_venda * pvi.vl_unitario_item_pedido * (1 - isnull(pvi.pc_desconto_item_pedido, 0) / 100)) as vl_total_item,                        
      pvi.pc_icms,                        
      um.sg_unidade_medida,                        
      'Item adicionado com sucesso' as ds_mensagem                        
    from pedido_venda_item pvi                        
    left join unidade_medida um on um.cd_unidade_medida = pvi.cd_unidade_medida                     
    where pvi.cd_pedido_venda = @cd_documento                        
      and pvi.cd_item_pedido_venda = @cd_item_pedido                        
                                    
end                        
                               
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 05  - Remover Pedido de Venda Item                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
                        
if @cd_parametro = 5                        
begin                        
          
    -- Extrair dados para remoção do item                        
    declare @cd_item_remover int                        
                        
    select @cd_documento = valor from #json where campo = 'cd_pedido_venda'                        
    select @cd_item_remover = valor from #json where campo = 'cd_item_pedido_venda'                        
    select @cd_usuario = valor from #json where campo = 'cd_usuario'                        
                
    -- Validações                        
    if @cd_documento is null or @cd_documento = 0                        
      raiserror('Número do pedido é obrigatório', 16, 1)                        
                        
    if @cd_item_remover is null or @cd_item_remover = 0                        
      raiserror('Item do pedido é obrigatório', 16, 1)                        
                    
    -- Verificar se pedido existe e está aberto                        
    if not exists (select 1 from pedido_venda where cd_pedido_venda = @cd_documento)                        
      raiserror('Pedido não encontrado ou não está aberto', 16, 1)                        
                        
    -- Verificar se item existe no pedido                        
    if not exists (select 1 from pedido_venda_item where cd_pedido_venda = @cd_documento and cd_item_pedido_venda = @cd_item_remover)                        
      raiserror('Item não encontrado no pedido', 16, 1)                        
                        
    -- Buscar valor do item para atualizar o total do pedido                        
    declare @vl_item_remover decimal(15,2)                        
                            
    select @vl_item_remover = (qt_item_pedido_venda * vl_unitario_item_pedido * (1 - isnull(pc_desconto_item_pedido, 0) / 100))                        
    from pedido_venda_item                        
    where cd_pedido_venda = @cd_documento                        
      and cd_item_pedido_venda = @cd_item_remover                        
                        
    -- Remover o item (fisicamente ou logicamente)                        
    -- Opção 1: Remoção física (DELETE)                        
 delete from pedido_venda_item                        
    where cd_pedido_venda = @cd_documento                        
and cd_item_pedido_venda = @cd_item_remover                        
                        
    -- Atualizar total do pedido                        
    update pedido_venda                        
    set vl_total_pedido_venda = vl_total_pedido_venda - isnull(@vl_item_remover, 0),                        
        dt_usuario = getdate()                        
    where cd_pedido_venda = @cd_documento                        
                        
    -- Retornar confirmação da remoção                        
    select                         
      @cd_documento as cd_pedido_venda,                        
      @cd_item_remover as cd_item_removido,                        
      @vl_item_remover as vl_item_removido,                        
      pv.vl_total_pedido_venda as vl_novo_total,                        
      'Item removido com sucesso' as ds_mensagem,                        
      (select count(*) from pedido_venda_item where cd_pedido_venda = @cd_documento) as qt_itens_restantes                        
    from pedido_venda pv                        
    where pv.cd_pedido_venda = @cd_documento                        
                                    
end                
              
---------------------------------------------------------------------------------------------------------------------------------------------------------                                      
-- 06 - Calculo de Promoção                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                                      
if @cd_parametro = 6                        
begin                        
                          
  set @cd_funcionario_int = cast(@cd_funcionario as int)                      
                        
  if @cd_funcionario_int is null or @cd_funcionario_int = 0                        
    set @cd_funcionario_int = 0                        
                        
  if @cd_identificacao_promocao is null or @cd_identificacao_promocao = ''                        
    set @cd_identificacao_promocao = ''                        
                   
  select top 1                         
    @cd_promocao = cd_promocao,
    @qt_limite_promocao_semana = qt_limite_promocao_semana
  from                         
    Promocao                         
  where                         
    cd_identificacao_promocao = @cd_identificacao_promocao                   
    and                  
    isnull(ic_ativa_promocao,'N') = 'S'                  
                     
  if isnull(@qt_limite_promocao_semana,0) > 0
  begin
    select
      @qt_promocao_semana = count(mcp.cd_movimento_caixa)
    from
      Movimento_Caixa_Promocao mcp
      inner join Movimento_Caixa mc on mc.cd_movimento_caixa = mcp.cd_movimento_caixa
    where
      mc.dt_cancel_movimento_caixa is null
      and
      mc.dt_movimento_caixa between @dt_inicio_semana and @dt_fim_semana
      and
      mcp.cd_promocao = @cd_promocao
      and
      mcp.cd_funcionario = @cd_funcionario_int

    if isnull(@qt_promocao_semana,0) >= isnull(@qt_limite_promocao_semana,0)
      set @cd_promocao = 0
  end

  if @cd_promocao is null or @cd_promocao = 0                        
    set @cd_promocao = 0  

  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------

  select                                                          
    identity(int,1,1) as id,                                                          
    [key] as campo,                                       
    [value] as valor                                                          
  into                                                           
    #JsonI                        
  from                                                           
    openjson(@jsonItens) root;                          
                                
  CREATE TABLE #ItensSelecionados (                                                          
    cd_produto int,                                                          
    cd_categoria int,                         
    vl_unitario float,                        
    qt_selecionado int                                                          
    );                                                          
                                                                  
  CREATE TABLE #JsonI2 (                                                          
    id      INT IDENTITY(1,1),                                                                    
    [key]   NVARCHAR(255),                                                          
    [value] NVARCHAR(MAX)                                                          
    );                         
                                  
  declare @idJson              int = 0                              
  declare @jsonItem            nvarchar(max) = ''                                                          
  declare @cd_produto_json     int = 0                                                       
  --declare @cd_categoria_json   int = 0                         
  declare @vl_unitario_json    float = 0                        
  declare @qt_selecionado_json int = 0                         
                          
  while exists(select top 1 id from #JsonI)                        
  begin                                                          
    select                                            
      top 1                                                           
      @idJson    = id,                                                              
      @jsonItem = valor                                                          
    from                                                           
      #JsonI                                                          
                                                                     
    delete from #JsonI2                                                        
                                             
    insert into #JsonI2 ([key], [value])select [key], [value] from openjson(@jsonItem)                        
                                                                     
    select @cd_produto_json     = [value] from #jsonI2 where [key] = 'cd_produto'                        
    --select @cd_categoria_json   = [value] from #jsonI2 where [key] = 'cd_categoria_produto'                        
    select @vl_unitario_json    = [value] from #jsonI2 where [key] = 'vl_unitario'                        
    select @qt_selecionado_json = [value] from #jsonI2 where [key] = 'qt_selecionado'                        
                                        
    insert into #ItensSelecionados                         
    select                                                           
      @cd_produto_json     as cd_produto,                        
      --@cd_categoria_json   as cd_categoria,                        
      cd_categoria_produto as cd_categoria,                        
      @vl_unitario_json    as vl_unitario,              
      @qt_selecionado_json as qt_selecionado                        
    from                        
      Produto                        
    where                        
      cd_produto = @cd_produto_json                        
                                                                     
    delete from #JsonI where id = @idJson                        
                                                                  
  end                        
                          
  --select * from #ItensSelecionados                        
  set @qt_produto_promocao = 0                    
                      
  select                     
    @qt_produto_promocao = sum(qt_selecionado)                    
  from                    
    #ItensSelecionados
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
                        
  if @cd_funcionario_int = 0                        
  begin                        
    if @cd_promocao > 0                        
    begin                        
      if exists(select top 1                        
                  pp.cd_produto                        
                from                    
                  Fidelidade_Programa fp                    
                  inner join Promocao_Produto pp on pp.cd_promocao = fp.cd_promocao                    
                  inner join #ItensSelecionados s on s.cd_produto = pp.cd_produto                        
                where                        
                  fp.cd_promocao = @cd_promocao)                        
      begin                    
     --select 'a'              
       select top 1                        
          @vl_desconto = s.vl_unitario * (pp.pc_promocao_desconto / 100)                        
        from                         
          Promocao_Produto pp                        
          inner join #ItensSelecionados s on s.cd_produto = pp.cd_produto                        
        where                        
          pp.cd_promocao = @cd_promocao                        
       order by                        
          vl_unitario asc                        
                              
        select top 1                        
          isnull(@vl_sub_total_tela,0)   as vl_sub_total_tela,                        
          isnull(@vl_desconto,0)         as vl_desconto,                        
          isnull(@vl_sub_total_tela,0) -                         
          isnull(@vl_desconto,0)         as vl_total                      
      end                    
      else                    
      if exists(select top 1                        
                  pp.cd_produto                        
                from                         
                  Promocao_Produto pp                        
                  inner join #ItensSelecionados s on s.cd_produto = pp.cd_produto                        
                where                        
           pp.cd_promocao = @cd_promocao)                    
      begin                
     --select 'b'              
        select top 1                        
          @vl_desconto = s.vl_unitario * (pp.pc_promocao_desconto / 100)                        
        from                         
          Promocao_Produto pp                        
          inner join #ItensSelecionados s on s.cd_produto = pp.cd_produto                        
        where                        
          pp.cd_promocao = @cd_promocao                        
          and                        
          @qt_produto_promocao > 1                        
        order by                        
          vl_unitario asc                        
                              
        select top 1                        
          isnull(@vl_sub_total_tela,0)   as vl_sub_total_tela,                        
          isnull(@vl_desconto,0)         as vl_desconto,             
          isnull(@vl_sub_total_tela,0) -                         
          isnull(@vl_desconto,0)         as vl_total                          
      end                        
      else                        
      begin                        
        select                        
          cd_categoria,                        
          sum(qt_selecionado) as qt_selecionado_categoria                        
        into                        
          #QTDCategoriaPromocao                        
        from                        
          #ItensSelecionados                        
        group by                        
          cd_categoria                        
        order by                        
          cd_categoria                        
                              
        if exists(select top 1                        
                    pcp.cd_categoria_produto                        
                  from                         
                    Promocao_Categoria_Produto pcp                        
                    inner join #QTDCategoriaPromocao sc on sc.cd_categoria = pcp.cd_categoria_produto                        
                  where                        
                    pcp.cd_promocao = @cd_promocao                        
                    and                        
                    sc.qt_selecionado_categoria >= pcp.qt_venda)                        
        begin                 
          --select 'c'              
          select                        
            @vl_desconto = sum((s.vl_unitario * s.qt_selecionado) * (pcp.pc_desconto / 100))                  
          from                         
            Promocao_Categoria_Produto pcp      
            inner join #ItensSelecionados s on s.cd_categoria = pcp.cd_categoria_produto                        
          where                        
            pcp.cd_promocao = @cd_promocao                            
                              
          select top 1                        
            isnull(@vl_sub_total_tela,0)   as vl_sub_total_tela,                        
            isnull(@vl_desconto,0)         as vl_desconto,                        
            isnull(@vl_sub_total_tela,0) -                         
            isnull(@vl_desconto,0)         as vl_total                         
                              
          drop table #QTDCategoriaPromocao                        
        end                        
        else                    
        begin                    
          if exists(select top 1                        
                      p.cd_promocao                    
                    from                         
                      Promocao p                        
                    where                        
                      p.cd_promocao = @cd_promocao)                        
          begin               
            --select 'd'              
            select top 1                        
              @vl_sub_total_tela                                    as vl_sub_total_tela,                        
              @vl_sub_total_tela * (c.pc_desconto_promocao/100)     as vl_desconto,                        
              @vl_sub_total_tela * (1-(c.pc_desconto_promocao/100)) as vl_total,                    
              c.pc_desconto_promocao                    
            from                        
              Promocao c                     
            where                        
              c.cd_promocao = @cd_promocao                    
          end                    
          else                        
          begin                 
            --select 'e'              
            select top 1                        
              @vl_sub_total_tela           as vl_sub_total_tela,                        
              @vl_sub_total_tela * (0)     as vl_desconto,                        
              @vl_sub_total_tela * (1-(0)) as vl_total                         
          end                        
        end                    
      end                           
    end                        
    else                        
    begin --A                  
         --select 'f'              
         select top 1                        
           @vl_sub_total_tela           as vl_sub_total_tela,                        
           @vl_sub_total_tela * (0)     as vl_desconto,                        
           @vl_sub_total_tela * (1-(0)) as vl_total                            
    end                        
  end                        
  else                        
  begin
    if @cd_promocao > 0                        
    begin                        
      if exists(select top 1                        
                  pp.cd_produto                        
                from                    
                  Fidelidade_Programa fp                    
                  inner join Promocao_Produto pp on pp.cd_promocao = fp.cd_promocao                    
                  inner join #ItensSelecionados s on s.cd_produto = pp.cd_produto                        
                where                        
                  fp.cd_promocao = @cd_promocao)                        
      begin                    
       --select 'a1'              
       select top 1                        
          @vl_desconto = s.vl_unitario * (pp.pc_promocao_desconto / 100)                        
        from                         
          Promocao_Produto pp                        
          inner join #ItensSelecionados s on s.cd_produto = pp.cd_produto                        
        where                        
          pp.cd_promocao = @cd_promocao                        
       order by                        
          vl_unitario asc                        
                              
        select top 1                        
          isnull(@vl_sub_total_tela,0)   as vl_sub_total_tela,                        
          isnull(@vl_desconto,0)         as vl_desconto,                        
          isnull(@vl_sub_total_tela,0) -                         
          isnull(@vl_desconto,0)         as vl_total                      
      end                    
      else                    
      if exists(select top 1                        
                  pp.cd_produto                        
                from                         
                  Promocao_Produto pp                        
                  inner join #ItensSelecionados s on s.cd_produto = pp.cd_produto                        
                where                        
                  pp.cd_promocao = @cd_promocao)                    
      begin                
        --select 'b1'              
        select top 1                        
          @vl_desconto = s.vl_unitario * (pp.pc_promocao_desconto / 100)                        
        from                         
          Promocao_Produto pp                        
          inner join #ItensSelecionados s on s.cd_produto = pp.cd_produto                        
        where                        
          pp.cd_promocao = @cd_promocao                        
          --and                        
          --@qt_produto_promocao > 1                        
        order by                        
          vl_unitario asc                        
                              
        select top 1                        
          isnull(@vl_sub_total_tela,0)   as vl_sub_total_tela,                        
          isnull(@vl_desconto,0)         as vl_desconto,             
          isnull(@vl_sub_total_tela,0) -                         
          isnull(@vl_desconto,0)         as vl_total                          
      end                        
      else                        
      begin                        
        select                        
          cd_categoria,                        
          sum(qt_selecionado) as qt_selecionado_categoria                        
        into                        
          #QTDCategoriaPromocao1                        
        from                        
          #ItensSelecionados                        
        group by                        
          cd_categoria                        
        order by                        
          cd_categoria                        
                              
        if exists(select top 1                        
                    pcp.cd_categoria_produto                        
                  from                         
                    Promocao_Categoria_Produto pcp                        
                    inner join #QTDCategoriaPromocao1 sc on sc.cd_categoria = pcp.cd_categoria_produto                        
                  where                        
                    pcp.cd_promocao = @cd_promocao                        
                    and                        
                    sc.qt_selecionado_categoria >= pcp.qt_venda)                        
        begin                 
          --select 'c1'              
          select                        
            @vl_desconto = sum((s.vl_unitario * s.qt_selecionado) * (pcp.pc_desconto / 100))                  
          from                         
            Promocao_Categoria_Produto pcp      
            inner join #ItensSelecionados s on s.cd_categoria = pcp.cd_categoria_produto                        
          where                        
            pcp.cd_promocao = @cd_promocao                            
                              
          select top 1                        
            isnull(@vl_sub_total_tela,0)   as vl_sub_total_tela,                        
            isnull(@vl_desconto,0)         as vl_desconto,                        
            isnull(@vl_sub_total_tela,0) -                         
            isnull(@vl_desconto,0)         as vl_total                         
                              
          drop table #QTDCategoriaPromocao1                        
        end                        
        else                    
        begin                    
          if exists(select top 1                        
                      p.cd_promocao                    
                    from                         
                      Promocao p                        
                    where                        
                      p.cd_promocao = @cd_promocao)                        
          begin               
            --select 'd1'              
            select top 1                        
              @vl_sub_total_tela                                    as vl_sub_total_tela,                        
              @vl_sub_total_tela * (c.pc_desconto_promocao/100)     as vl_desconto,                        
              @vl_sub_total_tela * (1-(c.pc_desconto_promocao/100)) as vl_total,                    
              c.pc_desconto_promocao                    
            from                        
              Promocao c                     
            where                        
              c.cd_promocao = @cd_promocao                    
          end                    
          else                        
          begin                 
            --select 'e1'              
            select top 1                        
              @vl_sub_total_tela           as vl_sub_total_tela,                        
              @vl_sub_total_tela * (0)     as vl_desconto,                        
              @vl_sub_total_tela * (1-(0)) as vl_total                         
          end                        
        end                    
      end                           
    end                        
    else                        
    begin
      --select 'g'              
      select top 1                        
        @vl_sub_total_tela                                       as vl_sub_total_tela,                        
        @vl_sub_total_tela * (c.pc_desconto_funcionario/100)     as vl_desconto,                        
        @vl_sub_total_tela * (1-(c.pc_desconto_funcionario/100)) as vl_total                        
      from                        
        Config_Terminal_Venda c   
    end
  end                        
                        
end            
                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                                      
-- 07 - Criar Movimento de Caixa e Movimento de Caixa Item                                  
---------------------------------------------------------------------------------------------------------------------------------------------------------                                 
                                  
if @cd_parametro = 7                  
begin                       
                    
    select @cd_documento = valor from #json where campo = 'cd_pedido_venda'                 
                    
    -- Validações obrigatórias                                  
    if @cd_documento is null or @cd_documento = 0                                  
      raiserror('Número do pedido é obrigatório', 16, 1)                                  
                    
    if @cd_tipo_movimento_caixa is null or @cd_tipo_movimento_caixa = 0                    
      raiserror('Tipo de movimento de caixa é obrigatório', 16, 1)                    
                    
    if @cd_tipo_pagamento is null or @cd_tipo_pagamento = 0                    
      raiserror('Tipo de pagamento é obrigatório', 16, 1)                    
                    
    -- Verificar se pedido existe e está finalizado                    
    if not exists (select 1 from pedido_venda where cd_pedido_venda = @cd_documento)                    
      raiserror('Pedido não encontrado', 16, 1)        
      
    -- Buscar informações do pedido                    
    declare @vl_total_pedido decimal(25,2)                    
    declare @cd_usuario_pedido int                    
                      
    select                    
      @vl_total_pedido = vl_total_pedido_venda,                    
      @cd_cliente = cd_cliente,                    
      @cd_vendedor = cd_vendedor,                    
      @cd_condicao_pagamento = cd_condicao_pagamento,                    
      @cd_usuario_pedido = cd_usuario,                    
      @cd_tabela_preco = cd_tabela_preco,                    
      @vl_desconto     = vl_desconto_pedido_venda                    
    from pedido_venda                                  
    where cd_pedido_venda = @cd_documento                       
                       
    select                                   
      @cd_cpf_digitado = cd_cpf_informado                                
    from Pedido_Venda_Caixa                                  
    where cd_pedido_venda = @cd_documento                    
                                    
    -- Obter configuração do terminal                                  
    SELECT @ic_atendimento = ic_atendimento                                   
    FROM Config_Terminal_Venda;                     
                        
    IF @ic_atendimento = 'S'                                  
    BEGIN                                  
      SET @cd_terminal = 2;                                  
      SET @cd_operador_caixa = NULL                                  
    END                                  
    ELSE                                  
    BEGIN                                  
      SET @cd_terminal = 1;                                  
    END                                  
                      
    -- Definir valores padrão se não informados                                  
    set @cd_loja = isnull(@cd_loja, @cd_empresa)                                 
                                 
    --Abertura do Caixa                              
    declare @cd_abertura_caixa_mov int                              
    select @cd_abertura_caixa_mov = ac.cd_abertura_caixa from abertura_caixa ac where ac.cd_operador_caixa = @cd_operador_caixa and dt_ultimo_fechamento is null                              

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    --VERIFICAÇÃO DOS TIPOS DE PAGAMENTO COM TAXA, BANDEIRA E CÓDIGOS DE AUTORIZAÇÃO-------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
      if @cd_tipo_pagamento <> 1                  
      begin                  
        if isnull(@cd_nsu_tef,'') = ''                  
          set @cd_maquina_cartao = 2    
        else                  
          set @cd_maquina_cartao = 1                  
      end          
          
      select           
        @cd_bandeira_cartao = cd_bandeira_cartao,          
        @pc_taxa_bandeira = case when @cd_tipo_pagamento in (4,9)          
                              then isnull(pc_taxa_bandeira,0)          
                              else case when @cd_tipo_pagamento = 3          
                                     then isnull(pc_taxa_antecipacao,0)          
                                     else 0          
                                   end          
                            end,    
        @cd_condicao_pagamento_band = case when @cd_tipo_pagamento in (4,9)          
                                        then isnull(cd_condicao_pagamento_deb,0)          
                                        else case when @cd_tipo_pagamento = 3          
                                               then isnull(cd_condicao_pagamento_cred,0)          
                                               else 0          
                                             end          
                                      end    
      from          
        Bandeira_Cartao          
      where
        ltrim(rtrim(@nm_bandeira_cartao)) like '%'+nm_bandeira_cartao+'%'          
          
      if @cd_tipo_pagamento = 8 --PIX          
      begin          
        select           
         @pc_taxa_bandeira = isnull(pc_taxa_pix,0)          
        from          
          Config_Terminal_Venda          
          
        set @cd_nsu_tef         = @cd_nsu_tef_pix          
        set @cd_autorizacao_tef = @cd_autorizacao_tef_pix          
      end          
          
      if isnull(@pc_taxa_bandeira,0) > 0          
      begin          
        set @vl_taxa_pagamento = round(((@vl_total_pedido-isnull(@vl_desconto,0))*@pc_taxa_bandeira)/100,2)          
          
        if @cd_tipo_pagamento = 8 --PIX          
        begin          
          if @vl_taxa_pagamento < 0.12          
            set @vl_taxa_pagamento = 0.12          
        end          
      end          
          
      if not exists(select top 1 cd_movimento_caixa from Movimento_Caixa_Bandeira           
                    where cd_movimento_caixa = @cd_movimento_caixa and cd_item_divisao = 0)          
      begin          
        INSERT INTO MOVIMENTO_CAIXA_BANDEIRA (          
         cd_movimento_caixa,          
         cd_item_divisao,          
         nm_bandeira_cartao,          
         cd_bandeira_cartao)          
        VALUES (          
         @cd_movimento_caixa,          
         0,          
         @nm_bandeira_cartao,          
         @cd_bandeira_cartao)          
      end          
      else          
      begin          
        UPDATE MOVIMENTO_CAIXA_BANDEIRA          
        set           
          nm_bandeira_cartao = @nm_bandeira_cartao,          
          cd_bandeira_cartao = @cd_bandeira_cartao          
        where          
          cd_movimento_caixa = @cd_movimento_caixa           
          and           
          cd_item_divisao = 0          
      end          
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------

                    
  if not exists(select top 1 cd_movimento_caixa from Movimento_Caixa_Item where cd_pedido_venda = @cd_documento)                    
  begin                    
      -- Buscar próximo número do movimento de caixa                                  
      select @cd_movimento_caixa = isnull(max(cd_movimento_caixa), 0) + 1 from movimento_caixa with (nolock)                                  
                                                       
      -- Inserir movimento de caixa                                  
      INSERT INTO MOVIMENTO_CAIXA (     
        cd_movimento_caixa,                                  
        dt_movimento_caixa,                                  
        vl_movimento_caixa,                                  
        cd_tipo_movimento_caixa,                                  
        nm_obs_movimento_caixa,                                  
        cd_cliente,                                  
        cd_vendedor,                                  
        cd_nota_saida,                                  
        cd_usuario,                                  
        dt_usuario,                                  
        ic_movimento_finalizado,                                  
        vl_total_venda,                                  
        cd_condicao_pagamento,                                  
        cd_loja,                                  
        cd_empresa,                                  
        cd_operador_caixa,                                  
        cd_tabela_preco,                                  
        vl_dinheiro,                                  
        vl_cartao_credito,                                  
        vl_cartao_debito,                  
        vl_voucher,                  
        vl_pix,                                  
        cd_tipo_pagamento,                                  
        cd_terminal_caixa,                              
        cd_abertura_caixa,                      
        cd_cpf_cliente,                    
        vl_desconto,                    
        vl_troco                    
      )                  
      SELECT                                   
        @cd_movimento_caixa,                                  
        @dt_hoje,                                  
        @vl_total_pedido,                                  
        @cd_tipo_movimento_caixa,                                  
        'Movimento gerado a partir do pedido ' + CAST(@cd_documento AS VARCHAR),                                  
        c.cd_cliente,                                  
        @cd_vendedor,                                  
        NULL,                                  
        @cd_usuario_pedido,                    
        GETDATE(),                                  
        'S',                                  
        @vl_total_pedido,                                  
        @cd_condicao_pagamento,                                  
        @cd_loja,                                  
        @cd_empresa,                                  
        @cd_operador_caixa,                                  
        @cd_tabela_preco,                                  
        CASE WHEN @cd_tipo_pagamento in (1,6,10) THEN @vl_total_pedido ELSE 0 END, --vl_dinheiro    
        --CASE WHEN @cd_tipo_pagamento = 1 THEN @vl_total_pedido ELSE 0 END, --vl_dinheiro    
        CASE WHEN @cd_tipo_pagamento = 3 THEN @vl_total_pedido ELSE 0 END, --vl_cartao_credito                                 
        CASE WHEN @cd_tipo_pagamento = 4 THEN @vl_total_pedido ELSE 0 END, --vl_cartao_debito                                 
        CASE WHEN @cd_tipo_pagamento = 9 THEN @vl_total_pedido ELSE 0 END, --vl_voucher    
        --CASE WHEN @cd_tipo_pagamento = 6 THEN @vl_total_pedido ELSE 0 END, --vl_voucher    
        CASE WHEN @cd_tipo_pagamento = 8 THEN @vl_total_pedido ELSE 0 END, --vl_pix                  
        @cd_tipo_pagamento_tab,                                  
        @cd_terminal,                              
        @cd_abertura_caixa_mov,                      
        @cd_cpf_digitado,                    
        @vl_desconto,                    
        @vl_troco                    
      from                      
        Cliente c                      
      where                      
        c.cd_cliente = @cd_cliente                   
                                    
                  
      -- Inserir pagamento no movimento de caixa                                        
      INSERT INTO MOVIMENTO_CAIXA_PAGAMENTO (                                        
          cd_movimento_caixa,                                        
          cd_tipo_pagamento,                                        
          vl_pagamento_caixa,                                        
          nm_obs_pagamento,                                        
          cd_usuario,                                        
          dt_usuario,                                        
          cd_bandeira_cartao,                  
          cd_maquina_cartao,                  
          dt_vencimento_parcela,                  
          cd_nsu_tef,                  
          cd_autorizacao_tef,                  
          vl_taxa_pagamento)         
      VALUES (     
          @cd_movimento_caixa,                                        
          @cd_tipo_pagamento_tab,                                        
          @vl_total_pedido,                                        
          'Pagamento gerado a partir do pedido ' + CAST(@cd_movimento_caixa AS VARCHAR),                                        
          @cd_usuario_pedido,                                        
          GETDATE(),                                        
          @cd_bandeira_cartao,                                        
          @cd_maquina_cartao,                                        
          NULL,                          
          @cd_nsu_tef,                          
          @cd_autorizacao_tef,                  
          @vl_taxa_pagamento)                      
                      
      -- Inserir itens do movimento de caixa                                  
      INSERT INTO MOVIMENTO_CAIXA_ITEM (                                  
        cd_movimento_caixa,                                  
        cd_item_movimento_caixa,                                  
        cd_produto,                                  
        qt_item_movimento_caixa,                                  
        vl_item_movimento_caixa,                                  
        vl_produto,                                  
        vl_total_item,                              
        dt_cancel_item,                              
        ic_estoque_movimento,                              
        cd_usuario,                                  
        dt_usuario,                                  
        cd_cupom_fiscal,                                  
        cd_operacao_fiscal,                              
        dt_entrega,                              
        cd_pedido_venda,
        ic_sel_fechamento,
        cd_tipo_local_entrega,
        vl_frete,
        ic_frete_digitado,
        cd_item_pedido_venda,
        ic_desconto_acima,
        vl_item_desconto,
        cd_tipo_pedido
        )                                  
      SELECT                                   
        @cd_movimento_caixa,                                  
        ROW_NUMBER() OVER (ORDER BY pvi.cd_item_pedido_venda),                                  
        pvi.cd_produto,                                  
        pvi.qt_item_pedido_venda,           
        pvi.vl_unitario_item_pedido,                                  
        pvi.vl_lista_item_pedido,                                  
        (pvi.qt_item_pedido_venda * pvi.vl_unitario_item_pedido),                                
        null,                              
        p.ic_estoque_caixa_produto,                              
        @cd_usuario_pedido,                                  
        GETDATE(),                                  
        NULL,                                  
        1, -- cd_operacao_fiscal (ajustar conforme necessário)                                
        GETDATE(),                              
        pvi.cd_pedido_venda,                              
        'S',                              
        4,                              
        0.00,                              
        'N',                              
        pvi.cd_item_pedido_venda,                              
        'N',                               
        0.00,                              
        pv.cd_tipo_pedido                              
      FROM                              
        PEDIDO_VENDA_ITEM pvi       with(nolock)                              
        inner join Pedido_Venda pv  with(nolock) on pv.cd_pedido_venda = pvi.cd_pedido_venda                               
        left outer join Produto p   with(nolock) on p.cd_produto       = pvi.cd_produto                              
      WHERE pvi.cd_pedido_venda = @cd_documento                                  
        AND pvi.dt_cancelamento_item IS NULL   
        
  end --end do if not exists                    
  else                    
  begin                    
    select                    
      @cd_movimento_caixa = cd_movimento_caixa                    
    from                    
      Movimento_Caixa_Item                    
    where                    
      cd_pedido_venda = @cd_documento  
      
    update Movimento_Caixa
    set
      dt_movimento_caixa = @dt_hoje,
      vl_movimento_caixa = @vl_total_pedido,
      vl_total_venda     = @vl_total_pedido,
      vl_dinheiro        = CASE WHEN @cd_tipo_pagamento in (1,6,10) THEN @vl_total_pedido ELSE 0 END, --vl_dinheiro
      --vl_dinheiro        = CASE WHEN @cd_tipo_pagamento = 1 THEN @vl_total_pedido ELSE 0 END, --vl_dinheiro
      vl_cartao_credito  = CASE WHEN @cd_tipo_pagamento = 3 THEN @vl_total_pedido ELSE 0 END, --vl_cartao_credito
      vl_cartao_debito   = CASE WHEN @cd_tipo_pagamento = 4 THEN @vl_total_pedido ELSE 0 END, --vl_cartao_debito 
      vl_voucher         = CASE WHEN @cd_tipo_pagamento = 9 THEN @vl_total_pedido ELSE 0 END, --vl_voucher
      --vl_voucher         = CASE WHEN @cd_tipo_pagamento = 6 THEN @vl_total_pedido ELSE 0 END, --vl_voucher
      vl_pix             = CASE WHEN @cd_tipo_pagamento = 8 THEN @vl_total_pedido ELSE 0 END, --vl_pix
      cd_tipo_pagamento  = @cd_tipo_pagamento_tab
    where
      cd_movimento_caixa = @cd_movimento_caixa

    update Movimento_Caixa_Pagamento
    set
      cd_tipo_pagamento  = @cd_tipo_pagamento_tab,
      vl_pagamento_caixa = @vl_total_pedido,
      cd_bandeira_cartao = @cd_bandeira_cartao,
      cd_maquina_cartao  = @cd_maquina_cartao,
      cd_nsu_tef         = @cd_nsu_tef,
      cd_autorizacao_tef = @cd_autorizacao_tef,
      vl_taxa_pagamento  = @vl_taxa_pagamento
    where
      cd_movimento_caixa = @cd_movimento_caixa
  end 
                                    
      update Pedido_Venda_Caixa                          
      set ic_finalizado = 'S'                          
      where                          
        cd_pedido_venda = @cd_documento     
            
      if isnull(@cd_condicao_pagamento_band,0) > 0    
      begin    
        update Pedido_Venda    
        set cd_condicao_pagamento = @cd_condicao_pagamento_band    
        where    
          cd_pedido_venda = @cd_documento    
    
        update Movimento_Caixa    
        set cd_condicao_pagamento = @cd_condicao_pagamento_band    
        where    
          cd_movimento_caixa = @cd_movimento_caixa    
      end    
                      
      ------------------------------------------------------------------------------                    
                      
      declare @qt_item_mov int                    
      declare @vl_total_calc float                    
      declare @pc_desc_calc float                    
      set @vl_total_calc = 0            set @pc_desc_calc = 0                    
                      
      select @vl_total_calc = sum(qt_item_movimento_caixa * vl_item_movimento_caixa)                         
      from Movimento_Caixa_Item                         
      where cd_movimento_caixa = @cd_movimento_caixa                     
                      
      select @pc_desc_calc = (@vl_desconto*100/@vl_total_calc)                    
                      
      ----                    
      update Movimento_Caixa_Item                        
      set vl_item_desconto = round((qt_item_movimento_caixa * vl_item_movimento_caixa)*(@pc_desc_calc/100),2)                    
      where                         
        cd_movimento_caixa = @cd_movimento_caixa                     
                      
      select                     
        @vl_desconto = sum(vl_item_desconto)                    
      from                    
        Movimento_Caixa_Item                        
      where                         
        cd_movimento_caixa = @cd_movimento_caixa                     
                      
      update Movimento_Caixa                    
      set vl_desconto = @vl_desconto                    
      where                         
        cd_movimento_caixa = @cd_movimento_caixa   
        

                     
      ------------------------------------------------------------------------------                                        
   declare @qt_total_ponto_fid int                    
   declare @qt_venda_fid int                    
   declare @dt_inicio_fid datetime                    
   declare @dt_fim_fid datetime                    
   declare @cd_categoria_fid int                    
                      
      if exists(select cd_pedido_venda from Pedido_Venda_Caixa                     
                where cd_pedido_venda = @cd_documento                     
                and (isnull(cd_funcionario,0) > 0 or isnull(cd_promocao,0) > 0))                    
      begin                    
        select                     
          @cd_funcionario_int = isnull(cd_funcionario,0),                    
          @cd_promocao = isnull(cd_promocao,0)                    
        from                     
          Pedido_Venda_Caixa                     
        where                    
          cd_pedido_venda = @cd_documento                    
                      
        if @cd_funcionario_int > 0                    
        begin                    
          if exists(select cd_movimento_caixa                     
                    from Movimento_Caixa_Funcionario                     
                    where cd_movimento_caixa = @cd_movimento_caixa)                    
          begin                    
            update Movimento_Caixa_Funcionario                    
            set cd_funcionario = @cd_funcionario_int                    
            where cd_movimento_caixa = @cd_movimento_caixa                    
          end                    
          else                    
          begin                    
            insert into Movimento_Caixa_Funcionario                    
            (cd_movimento_caixa, cd_usuario, dt_usuario, cd_funcionario)                    
            values                    
            (@cd_movimento_caixa, @cd_usuario, @dt_hoje, @cd_funcionario_int)                    
          end                      
        end                    
                      
        if exists(select cd_movimento_caixa                     
                  from Movimento_Caixa_Promocao                     
                  where cd_movimento_caixa = @cd_movimento_caixa)                    
        begin                    
          update Movimento_Caixa_Promocao                    
          set cd_promocao = @cd_promocao, cd_funcionario = @cd_funcionario_int                    
          where cd_movimento_caixa = @cd_movimento_caixa                    
        end                    
        else                    
        begin                    
          insert into Movimento_Caixa_Promocao                    
          (cd_movimento_caixa, cd_promocao, cd_usuario_inclusao,                    
          dt_usuario_inclusao, cd_usuario, dt_usuario, cd_funcionario)                    
          values                    
          (@cd_movimento_caixa, @cd_promocao, @cd_usuario,                    
          @dt_hoje, @cd_usuario, @dt_hoje, @cd_funcionario_int)                    
                              
        end                    
                      
        if @cd_promocao > 0                    
        begin                    
          select                    
            @cd_cliente = cd_cliente                    
          from                     
            Movimento_Caixa                    
          where                    
            cd_movimento_caixa = @cd_movimento_caixa                    
                              
          select                     
            @qt_total_ponto_fid = isnull(qt_total_ponto_resgate,0),                    
            @dt_inicio_fid = dt_inicio_vigencia,                    
            @dt_fim_fid = dt_fim_vigencia,                    
            @cd_categoria_fid = cd_categoria_fidelidade                    
          from                     
            fidelidade_programa                    
          where                    
            cd_promocao = @cd_promocao                    
            and                    
            isnull(ic_ativo_fidelidade,'N') = 'S'                    
                    
          --------------------------------------------------------------------------------------------                    
          select                    
            m.cd_cliente,                    
            m.cd_movimento_caixa,                    
            isnull((select sum(qt_item_movimento_caixa)                     
             from Movimento_caixa_Item i                    
             inner join Produto p on p.cd_produto = i.cd_produto                    
             where i.cd_movimento_caixa = m.cd_movimento_caixa                    
               and p.cd_categoria_produto = @cd_categoria_fid),0) as qt_ponto_fidelidade                    
          into                    
            #Movimento_Fid                    
          from                    
            Movimento_Caixa m                    
            inner join Cliente c on c.cd_cliente = m.cd_cliente                    
          where                    
            m.cd_cliente = @cd_cliente                    
            and                    
            m.dt_cancel_movimento_caixa is null                    
            and                    
            m.dt_movimento_caixa between @dt_inicio_fid and @dt_fim_fid                    
          group by                    
            m.cd_cliente,                    
            m.cd_movimento_caixa                    
          --------------------------------------------------------------------------------------------                    
                              
          select                    
            @qt_venda_fid = (sum(m.qt_ponto_fidelidade)-sum(isnull(r.qt_ponto_resgate,0)))                    
          from                    
            #Movimento_Fid m                    
            left outer join Movimento_Caixa_Resgate r on r.cd_movimento_caixa = m.cd_movimento_caixa                    
            left outer join Movimento_Caixa_Promocao p on p.cd_movimento_caixa = m.cd_movimento_caixa                    
          where                    
            m.cd_cliente = @cd_cliente                    
            and                    
            isnull(p.cd_promocao,0) <> isnull(@cd_promocao,0)                    
                              
          if ((isnull(@qt_total_ponto_fid,0)-isnull(@qt_venda_fid,0)) <= 0) and (isnull(@qt_venda_fid,0) > 0)                    
          begin                    
            exec dbo.pr_gera_programa_fidelidade_cliente_caixa  3, 0, @cd_usuario_pedido, @cd_cliente                    
          end                    
        end                    
      end                    
      else                    
      begin                    
        delete from Movimento_Caixa_Promocao where cd_movimento_caixa = @cd_movimento_caixa                    
      end                    
                   
                      
    -- Retornar dados do movimento criado                                  
    select                                   
      mc.cd_movimento_caixa,                             
      mc.dt_movimento_caixa,                               
      mc.vl_movimento_caixa,                                  
      mc.cd_tipo_movimento_caixa,                                  
      tmc.nm_tipo_movimento_caixa,                                  
      mc.cd_cliente,                                  
      c.nm_fantasia_cliente,                                  
      mc.cd_vendedor,                                  
      v.nm_fantasia_vendedor,                                  
      mc.vl_total_venda,                    
      mc.cd_condicao_pagamento,                    
      mc.vl_dinheiro,                    
      mc.vl_cartao_credito,                                  
      mc.vl_cartao_debito,                                  
      mc.vl_pix,                                  
     cp.nm_condicao_pagamento,                                  
      mc.cd_tipo_pagamento,        
      isnull(tpc.ic_padrao_nfce,'N') as ic_padrao_nfce,        
      isnull(tpc.ic_nfce_tipo,'N') as ic_nfce_tipo,        
      (select count(*) from movimento_caixa_item where cd_movimento_caixa = mc.cd_movimento_caixa) as qt_itens,        
      'Movimento de caixa criado com sucesso' as ds_mensagem                                
    from                   
      MOVIMENTO_CAIXA mc                                
      left outer join tipo_movimento_caixa tmc on tmc.cd_tipo_movimento_caixa = mc.cd_tipo_movimento_caixa                                
      left outer join cliente c on c.cd_cliente = mc.cd_cliente                                
      left outer join vendedor v on v.cd_vendedor = mc.cd_vendedor                                
      left outer join condicao_pagamento cp on cp.cd_condicao_pagamento = mc.cd_condicao_pagamento        
      left outer join Tipo_Pagamento_Caixa tpc on tpc.cd_tipo_pagamento = mc.cd_tipo_pagamento                       
    where      
      mc.cd_movimento_caixa = @cd_movimento_caixa                                  
                                    
end                       
                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 08 - Terminal de Caixa Configuração                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 8                        
 begin                        
  declare @cd_pedido_aberto int              
          
  select top 1                
    @cd_pedido_aberto = cd_pedido_venda                
  from                
    Pedido_Venda_Caixa                
  where                
    ic_finalizado = 'N'                
  order by cd_pedido_venda desc                
                
  select 
    isnull(ic_atendimento,'N') as ic_atendimento,
    isnull(ic_entrega,'N') as ic_entrega,
    isnull(ic_funcionario,'N') as ic_funcionario,
    isnull(ic_tef,'N') as ic_tef,
    isnull(ic_carteira_digital,'N') as ic_carteira_digital,
    isnull(ic_historico_fidelidade,'N') as ic_historico_fidelidade,
    isnull(ic_mudanca_tipo_cupom,'N') as ic_mudanca_tipo_cupom,
    isnull(ic_cupom_desconto,'N') as ic_cupom_desconto,
    isnull(ic_comprovante_sistema,'N') as ic_comprovante_sistema,
    isnull(ic_voucher_web,'N') as ic_voucher_web,
    isnull(ic_ifood_web,'N') as ic_ifood_web,
    isnull(qt_casa_decimal_terminal,0) as qt_casa_decimal_terminal,
    isnull(@cd_pedido_aberto,0) as cd_pedido_aberto
  from 
    Config_Terminal_Venda                
 end                       
                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 09 - Login Operador                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
                        
if @cd_parametro = 9                         
begin                        
 SELECT                         
    *                        
 FROM operador_caixa    WHERE nm_fantasia_operador = @operador                         
 AND cd_senha_operador_caixa = @operador_password                      
end                        
                        
                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 10 - Verificar se existe caixa aberto                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                          
IF @cd_parametro = 10                        
BEGIN                        
                      
    -- Obter configuração do terminal                        
    SELECT @ic_atendimento = isnull(ic_atendimento,'N')      
    FROM Config_Terminal_Venda;                        
                        
    -- Validar se operador é obrigatório                        
    IF @ic_atendimento = 'N' AND @cd_operador_caixa IS NULL                        
    BEGIN                        
        RAISERROR('Operador é obrigatório quando ic_atendimento = ''N''', 16, 1);                        
        RETURN;                        
    END                        
          
          
    -- Definir valores baseados na configuração                        
    IF @ic_atendimento = 'S'                        
    BEGIN                        
        SET @cd_terminal = 2;                        
        SET @operador_final = NULL; -- Não precisa de operador                        
    END                        
    ELSE                        
    BEGIN                        
        --SET @cd_terminal = 1;                       
      select @cd_terminal = cd_terminal_caixa from terminal_caixa_operador where cd_operador_caixa = @cd_operador_caixa                      
      SET @operador_final = @cd_operador_caixa; -- Usa o operador informado                        
    END          
          
      
    -- Verificar se já existe caixa aberto (condição simplificada)                        
    IF EXISTS (                        
        SELECT 1                         
        FROM Abertura_Caixa                         
        WHERE cd_terminal_caixa = @cd_terminal                        
        AND dt_ultimo_fechamento IS NULL                        
        AND (                        
            (@ic_atendimento = 'S') OR -- Para atendimento 'S', não verifica operador                        
            (@ic_atendimento = 'N' AND cd_operador_caixa = @operador_final)                        
        )                        
    )      
    BEGIN                        
        -- Retornar dados do caixa já aberto                        
        SELECT                         
            'CAIXA_JA_ABERTO' as status,                        
            cd_abertura_caixa,                         
            dt_abertura_caixa,                         
            vl_abertura_caixa,                        
            nm_obs_abertura_caixa,                         
            cd_usuario,                         
            cd_operador_caixa,                        
            cd_terminal_caixa,                         
            cd_movimento_caixa,                         
            hr_abertura_caixa,                        
            @ic_atendimento as ic_atendimento_config                        
        FROM Abertura_Caixa                         
        WHERE cd_terminal_caixa = @cd_terminal                        
  AND dt_ultimo_fechamento IS NULL                        
        AND (                        
            (@ic_atendimento = 'S') OR -- Para atendimento 'S', não verifica operador                        
            (@ic_atendimento = 'N' AND cd_operador_caixa = @operador_final)                        
        );                        
    END                        
    ELSE                        
    BEGIN                        
        -- Retornar que não existe caixa aberto                        
        SELECT                         
  'CAIXA_FECHADO' as status,                        
            NULL as cd_abertura_caixa,                         
            NULL as dt_abertura_caixa,                         
            NULL as vl_abertura_caixa,                        
            NULL as nm_obs_abertura_caixa,                         
            NULL as cd_usuario,                         
            NULL as cd_operador_caixa,                        
          NULL as cd_terminal_caixa,                         
            NULL as cd_movimento_caixa,                         
            NULL as hr_abertura_caixa,                        
            @ic_atendimento as ic_atendimento_config;                        
    END                        
END                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 11 - Abrir Caixa             
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
IF @cd_parametro = 11                        
BEGIN                        
                           
    DECLARE @ultimo_movimento INT;                        
    DECLARE @novo_cd_abertura INT;                        
                        
    -- Obter configuração do terminal                        
    SELECT @ic_atendimento = ic_atendimento                         
    FROM Config_Terminal_Venda;                        
                        
    -- Validar se operador é obrigatório                        
    IF @ic_atendimento = 'N' AND @cd_operador_caixa IS NULL                        
    BEGIN                        
        RAISERROR('Operador é obrigatório quando ic_atendimento = ''N''', 16, 1);                        
        RETURN;                        
    END                        
                        
    -- Definir valores baseados na configuração                        
    IF @ic_atendimento = 'S'                        
    BEGIN                   
        SET @cd_terminal = 2;                        
        SET @operador_final = NULL; -- Não precisa de operador                        
    END                        
    ELSE                        
    BEGIN                        
        SET @cd_terminal = 1;                        
        SET @operador_final = @cd_operador_caixa; -- Usa o operador informado                        
    END                        
                        
    -- Verificar se já existe caixa aberto antes de criar                        
    IF EXISTS (                        
        SELECT 1                         
        FROM Abertura_Caixa                         
        WHERE cd_terminal_caixa = @cd_terminal                        
        AND dt_ultimo_fechamento IS NULL                        
        AND (                        
            (@ic_atendimento = 'S' AND cd_operador_caixa IS NULL) OR                        
           (@ic_atendimento = 'N' AND cd_operador_caixa = @operador_final)                        
        )                        
    )                        
    BEGIN                        
        RAISERROR('Já existe um caixa aberto para este terminal/operador', 16, 1);                        
        RETURN;                        
    END                        
                        
    -- Obter último movimento de caixa                        
    SELECT @ultimo_movimento = ISNULL(MAX(cd_movimento_caixa), 0)                         
    FROM Movimento_Caixa;                        
                        
    -- Obter próximo código de abertura                        
    SELECT @novo_cd_abertura = ISNULL(MAX(cd_abertura_caixa), 0) + 1                         
    FROM Abertura_Caixa;                        
                        
    -- Inserir nova abertura de caixa                        
    INSERT INTO Abertura_Caixa (    
        cd_abertura_caixa,                         
        dt_abertura_caixa,                         
        vl_abertura_caixa,                         
        nm_obs_abertura_caixa,                        
        cd_usuario,                         
        dt_usuario,                       
        dt_ultimo_fechamento,                         
        vl_ultimo_fechamento,                        
        cd_vendedor,                         
        cd_loja,                         
        cd_operador_caixa,                         
        cd_terminal_caixa,                         
        cd_movimento_caixa,                        
        vl_dinheiro_fechamento,                         
        hr_abertura_caixa,                         
        cd_usuario_inclusao,                         
        dt_usuario_inclusao                        
    )                        
    VALUES (                        
        @novo_cd_abertura,                         
        GETDATE(),                         
        0,                         
        NULL,                        
        @cd_usuario,             
        GETDATE(),                         
        NULL,                         
        0,                        
        @cd_vendedor,                         
        @cd_loja,                         
        @operador_final,                         
        @cd_terminal,                         
        @ultimo_movimento,                        
        0,                         
        CONVERT(TIME, GETDATE()),                         
        @cd_usuario,                         
        GETDATE()                        
    );                        
                        
    -- Retornar os dados do caixa recém-aberto                        
    SELECT                         
        'CAIXA_ABERTO' as status,                        
    cd_abertura_caixa,                         
        dt_abertura_caixa,                         
        vl_abertura_caixa,                        
        nm_obs_abertura_caixa,                         
        cd_usuario,                         
        cd_operador_caixa,                        
        cd_terminal_caixa,                         
        cd_movimento_caixa,                         
        hr_abertura_caixa,                        
        @ic_atendimento as ic_atendimento_config                        
    FROM Abertura_Caixa                         
    WHERE cd_abertura_caixa = @novo_cd_abertura;                        
END                        
                        
IF @cd_parametro = 12                        
BEGIN                        
    -- Declaração de variáveis específicas para fechamento de caixa                        
                            
    DECLARE @cd_abertura_atual INT;                        
    DECLARE @cd_movimento_abertura INT;                        
    DECLARE @vl_total_vendas MONEY;                        
    DECLARE @novo_cd_fechamento INT;                        
    DECLARE @dt_abertura DATETIME;                        
    DECLARE @hr_abertura TIME;                        
                        
    -- Obter configuração do terminal                        
    SELECT @ic_atendimento = ic_atendimento                         
    FROM Config_Terminal_Venda;                        
                        
    -- Definir valores baseados na configuração                        
    IF @ic_atendimento = 'S'                        
    BEGIN                        
        SET @cd_terminal = 2;                        
        SET @operador_final = NULL;                        
    END                        
    ELSE                        
    BEGIN                        
        SET @cd_terminal = 1;                        
        SET @operador_final = @cd_operador_caixa;                        
    END                        
                        
-- Verificar se existe caixa aberto para fechar                        
    IF NOT EXISTS (                        
        SELECT 1                         
        FROM Abertura_Caixa                         
        WHERE cd_terminal_caixa = @cd_terminal                        
        AND dt_ultimo_fechamento IS NULL                        
        AND (                        
            (@ic_atendimento = 'S' AND cd_operador_caixa IS NULL) OR                        
            (@ic_atendimento = 'N' AND cd_operador_caixa = @operador_final)                        
        )                        
    )                        
    BEGIN                        
        RAISERROR('Não existe caixa aberto para fechar', 16, 1);                        
        RETURN;                        
    END                        
                        
    -- Obter dados do caixa aberto atual                        
    SELECT                         
        @cd_abertura_atual = cd_abertura_caixa,                        
        @cd_movimento_abertura = cd_movimento_caixa,                        
        @dt_abertura = dt_abertura_caixa,                        
        @hr_abertura = hr_abertura_caixa                        
    FROM Abertura_Caixa                         
    WHERE cd_terminal_caixa = @cd_terminal                        
    AND dt_ultimo_fechamento IS NULL                        
    AND (                       
        (@ic_atendimento = 'S' AND cd_operador_caixa IS NULL) OR                        
        (@ic_atendimento = 'N' AND cd_operador_caixa = @operador_final)                        
    );                        
                        
    -- Calcular o valor total das vendas a partir do movimento de abertura                        
    SELECT @vl_total_vendas = ISNULL(SUM(vl_total_venda), 0)                        
    FROM Movimento_Caixa                         
    WHERE cd_movimento_caixa > @cd_movimento_abertura                        
   AND (                        
        (@ic_atendimento = 'S' AND cd_operador_caixa IS NULL) OR                        
        (@ic_atendimento = 'N' AND cd_operador_caixa = @operador_final)                        
    )                        
    AND cd_terminal_caixa = @cd_terminal;                        
                        
    -- Obter próximo código de fechamento                        
    SELECT @novo_cd_fechamento = ISNULL(MAX(cd_fechamento_caixa), 0) + 1                         
    FROM Fechamento_Caixa;                        
                        
    -- Inserir na tabela Fechamento_Caixa                        
    INSERT INTO Fechamento_Caixa (                        
        cd_fechamento_caixa,                        
        dt_fechamento_caixa,                        
        vl_fechamento_caixa,                        
        vl_real_fechamento_caixa,                        
        nm_obs_fechamento_caixa,                        
        ds_fechamento_caixa,                        
        cd_usuario,                        
        dt_usuario,                        
        cd_vendedor,                        
        cd_loja,                        
        cd_terminal_caixa,                        
        cd_operador_caixa,                        
        hr_fechamento_caixa,                        
        cd_usuario_inclusao,                        
        dt_usuario_inclusao,                    
        cd_abertura_caixa                        
    )                        
    VALUES (                        
        @novo_cd_fechamento,                        
        GETDATE(), -- dt_fechamento_caixa                        
        @vl_total_vendas, -- vl_fechamento_caixa (valor calculado)                        
        @vl_total_vendas, -- vl_real_fechamento_caixa (assumindo que é igual ao calculado)                        
        NULL, -- nm_obs_fechamento_caixa (pode ser ajustado)                        
        'Fechamento automático de caixa', -- ds_fechamento_caixa                        
        @cd_usuario, -- cd_usuario                        
        GETDATE(), -- dt_usuario     
        @cd_vendedor, -- cd_vendedor                        
        @cd_loja, -- cd_loja                        
        @cd_terminal, -- cd_terminal_caixa                        
        @operador_final, -- cd_operador_caixa                        
        CONVERT(TIME, GETDATE()), -- hr_fechamento_caixa                        
        @cd_usuario, -- cd_usuario_inclusao                        
        GETDATE(), -- dt_usuario_inclusao                        
        @cd_abertura_atual -- cd_abertura_caixa                        
    );                        
                        
    -- Atualizar a tabela Abertura_Caixa com os dados de fechamento                        
    UPDATE Abertura_Caixa                         
    SET                         
        dt_ultimo_fechamento = GETDATE(),                        
        vl_ultimo_fechamento = @vl_total_vendas,                        
        dt_usuario = GETDATE(),                        
        cd_usuario = @cd_usuario                        
    WHERE cd_abertura_caixa = @cd_abertura_atual;                        
                        
    -- Retornar os dados do fechamento realizado                        
    SELECT                         
        'CAIXA_FECHADO' as status,                        
        @novo_cd_fechamento as cd_fechamento_caixa,                        
        GETDATE() as dt_fechamento_caixa,                        
        @vl_total_vendas as vl_fechamento_caixa,                        
        @vl_total_vendas as vl_real_fechamento_caixa,                        
        @cd_abertura_atual as cd_abertura_caixa,                        
        @cd_terminal as cd_terminal_caixa,                        
        @operador_final as cd_operador_caixa,                        
        CONVERT(TIME, GETDATE()) as hr_fechamento_caixa,                        
        @ic_atendimento as ic_atendimento_config,                        
        @cd_movimento_abertura as cd_movimento_abertura,                        
        (SELECT COUNT(*) FROM Movimento_Caixa WHERE cd_movimento_caixa > @cd_movimento_abertura) as total_movimentos                        
    FROM Fechamento_Caixa                         
    WHERE cd_fechamento_caixa = @novo_cd_fechamento;                        
END                        
                        
if @cd_parametro = 13                        
begin                        
 SELECT                         
    ISNULL(c.cd_conta_banco, 0) AS cd_conta_banco,                        
    a.nm_pix                        
FROM                         
    config_terminal_venda AS c                        
LEFT JOIN                         
    conta_agencia_banco AS a ON a.cd_conta_banco = c.cd_conta_banco                        
WHERE                         
    ISNULL(c.cd_conta_banco, 0) > 0;                        
end                        
                        
if @cd_parametro = 14                        
begin                        
 EXEC dbo.pr_consulta_funcionario                        
   @cd_parametro = 0,                        
   @ic_parametro = @ic_parametro,                        
   @nm_fantasia = @nm_fantasia_funcionario                        
                          
end                        
                        
if @cd_parametro = 15                        
begin                        
 DECLARE @json_param VARCHAR(MAX);                        
    SET @json_param = '[{"cd_operador_caixa": ' + CAST(@cd_operador_caixa AS VARCHAR) + '}]';                        
 exec pr_egisnet_operacao_tef @json_param                        
end                
              
---------------------------------------------------------------------------------------------------------------------------------------------------------                                      
-- 16 - Calcula total Pedido com Desconto                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                                 
if @cd_parametro = 16                        
begin                        
                    
  declare @vl_total_pedido_venda float                    
  declare @vl_total_ipi          float                    
  declare @vl_icms_st            float                    
  declare @vl_desconto_pedido    float                    
  declare @pc_desconto_pedido    float                    
                                        
  set @vl_total_pedido_venda = 0.00                    
  set @vl_total_ipi          = 0.00                    
  set @vl_icms_st            = 0.00                    
  set @vl_desconto_pedido    = 0.00                    
  set @pc_desconto_pedido    = 0.00                    
                    
  set @cd_funcionario_int = cast(@cd_funcionario as int)                      
                        
  if @cd_funcionario_int is null or @cd_funcionario_int = 0                        
    set @cd_funcionario_int = 0                        
                        
  if @cd_identificacao_promocao is null or @cd_identificacao_promocao = ''                        
    set @cd_identificacao_promocao = ''                        
                        
  select top 1                         
    @cd_promocao = cd_promocao,
    @qt_limite_promocao_semana = qt_limite_promocao_semana
  from                         
    Promocao                         
  where                         
    cd_identificacao_promocao = @cd_identificacao_promocao                   
    and                  
    isnull(ic_ativa_promocao,'N') = 'S'  
    
  if isnull(@qt_limite_promocao_semana,0) > 0
  begin
    select
      @qt_promocao_semana = count(mcp.cd_movimento_caixa)
    from
      Movimento_Caixa_Promocao mcp
      inner join Movimento_Caixa mc on mc.cd_movimento_caixa = mcp.cd_movimento_caixa
    where
      mc.dt_cancel_movimento_caixa is null
      and
      mc.dt_movimento_caixa between @dt_inicio_semana and @dt_fim_semana
      and
      mcp.cd_promocao = @cd_promocao
      and
      mcp.cd_funcionario = @cd_funcionario_int

    if isnull(@qt_promocao_semana,0) >= isnull(@qt_limite_promocao_semana,0)
      set @cd_promocao = 0
  end

  if @cd_promocao is null or @cd_promocao = 0                        
    set @cd_promocao = 0   

  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  select                     
    i.cd_produto,                    
    i.vl_lista_item_pedido as vl_unitario,                    
    i.qt_item_pedido_venda as qt_selecionado                    
  into                    
    #PedidoItem                    
  from                                            
    Pedido_Venda_Item i          
  where                                      
    i.cd_pedido_venda = @cd_documento                     
    and                                      
    i.dt_cancelamento_item is null                     
            
  set @qt_produto_promocao = 0                    
                
  select                     
    @qt_produto_promocao = sum(qt_selecionado)                    
  from                    
    #PedidoItem                    
                
  select                                                         
    @vl_total_pedido_venda = sum ( cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) as float)),                                      
    @vl_total_ipi          = sum ( round(cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) * isnull(pc_ipi,0)/100 as float),2)),                                      
    @vl_icms_st            = sum ( cast(isnull(vl_item_icms_st,0) as decimal(25,2)) )                                      
  from                                            
    Pedido_Venda_Item                                      
  where                                      
    cd_pedido_venda = @cd_documento                                      
    and                             
    dt_cancelamento_item is null                      
  group by                                      
    cd_pedido_venda 
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
                        
  if @cd_funcionario_int = 0                        
  begin                        
    if @cd_promocao > 0                        
    begin                      
      update Pedido_Venda_Caixa                    
      set cd_promocao = @cd_promocao                    
      where cd_pedido_venda = @cd_documento                      
                    
      --select * from #PedidoItem                        
      if exists(select top 1                        
                  pp.cd_produto                        
                from                    
                  Fidelidade_Programa fp                    
                  inner join Promocao_Produto pp on pp.cd_promocao = fp.cd_promocao                    
                  inner join #PedidoItem s on s.cd_produto = pp.cd_produto                        
                where                        
                  fp.cd_promocao = @cd_promocao)                        
      begin                        
        select top 1                        
          @vl_desconto = round(s.vl_unitario * (pp.pc_promocao_desconto / 100),2)                        
        from                         
          Promocao_Produto pp                        
          inner join #PedidoItem s on s.cd_produto = pp.cd_produto                        
        where                
          pp.cd_promocao = @cd_promocao                         
        order by                        
          vl_unitario asc                    
                    
        set @pc_desconto_pedido = (100*@vl_desconto)/@vl_total_pedido_venda                    
                              
        update                    
          Pedido_Venda                    
        set                    
          vl_total_pedido_venda = @vl_total_pedido_venda,                    
          vl_desconto_pedido_venda = @vl_desconto,                    
          pc_desconto_pedido_venda = @pc_desconto_pedido,                    
          vl_icms_st = @vl_icms_st,                    
          vl_total_ipi = @vl_total_ipi,                    
          vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto                    
        where                    
          cd_pedido_venda = @cd_documento                    
                              
        select top 1                        
          isnull(@vl_sub_total_tela,0)   as vl_sub_total_tela,                        
          isnull(@vl_desconto,0)         as vl_desconto,                        
          isnull(@vl_sub_total_tela,0) -                         
          isnull(@vl_desconto,0)         as vl_total                          
      end                        
      else                    
      if exists(select top 1                        
                  pp.cd_produto                        
                from                         
                  Promocao_Produto pp                        
                  inner join #PedidoItem s on s.cd_produto = pp.cd_produto                        
                where                        
                  pp.cd_promocao = @cd_promocao)                        
      begin                        
        select top 1                        
          @vl_desconto = round(s.vl_unitario * (pp.pc_promocao_desconto / 100),2)                       
        from                         
          Promocao_Produto pp                        
          inner join #PedidoItem s on s.cd_produto = pp.cd_produto                        
        where                        
          pp.cd_promocao = @cd_promocao                        
          and                        
          @qt_produto_promocao > 1                        
        order by                        
          vl_unitario asc                    
                    
        set @pc_desconto_pedido = (100*@vl_desconto)/@vl_total_pedido_venda                    
                              
        update                    
          Pedido_Venda                    
        set                    
          vl_total_pedido_venda = @vl_total_pedido_venda,                    
          vl_desconto_pedido_venda = @vl_desconto,                    
          pc_desconto_pedido_venda = @pc_desconto_pedido,                    
          vl_icms_st = @vl_icms_st,                    
          vl_total_ipi = @vl_total_ipi,                    
          vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto                    
        where                    
          cd_pedido_venda = @cd_documento                    
                              
        select top 1                        
          isnull(@vl_sub_total_tela,0)   as vl_sub_total_tela,                        
          isnull(@vl_desconto,0)         as vl_desconto,                        
          isnull(@vl_sub_total_tela,0) -                         
          isnull(@vl_desconto,0)         as vl_total                          
      end                        
      else                        
      begin                        
        select                        
          cd_categoria_produto as cd_categoria,                        
          sum(qt_selecionado)  as qt_selecionado_categoria                        
        into                        
          #QTDCategoriaPromocaoPV                        
        from                        
          #PedidoItem i                    
          left outer join Produto p on p.cd_produto = i.cd_produto                    
        group by                        
          cd_categoria_produto                        
        order by                        
          cd_categoria_produto                        
                              
        if exists(select top 1                    
                    pcp.cd_categoria_produto                    
                  from                    
                    Promocao_Categoria_Produto pcp                        
                    inner join #QTDCategoriaPromocaoPV sc on sc.cd_categoria = pcp.cd_categoria_produto                        
         where                        
                    pcp.cd_promocao = @cd_promocao                        
                    and                        
                    sc.qt_selecionado_categoria >= pcp.qt_venda)                        
        begin                        
          select top 1                        
            @vl_desconto = round(sum((s.vl_unitario * s.qt_selecionado) * (pcp.pc_desconto / 100)),2)                        
          from                         
            Promocao_Categoria_Produto pcp                      
            left outer join Produto p on p.cd_categoria_produto = pcp.cd_categoria_produto                       
            inner join #PedidoItem s on s.cd_produto = p.cd_produto                        
          where                        
            pcp.cd_promocao = @cd_promocao                        
                       
          set @pc_desconto_pedido = (100*@vl_desconto)/@vl_total_pedido_venda                    
                              
          update                    
            Pedido_Venda                    
          set                    
            vl_total_pedido_venda = @vl_total_pedido_venda,                    
            vl_desconto_pedido_venda = @vl_desconto,                    
            pc_desconto_pedido_venda = @pc_desconto_pedido,                    
            vl_icms_st = @vl_icms_st,                    
            vl_total_ipi = @vl_total_ipi,                    
            vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto                    
          where                    
            cd_pedido_venda = @cd_documento                    
                    
          select top 1                        
            isnull(@vl_total_pedido_venda,0)   as vl_sub_total_tela,                        
            isnull(@vl_desconto,0)             as vl_desconto,                        
            isnull(@vl_total_pedido_venda,0) -                         
            isnull(@vl_desconto,0)             as vl_total                         
                              
          drop table #QTDCategoriaPromocaoPV                        
        end                        
        else                    
        begin                    
          if exists(select top 1                        
                      p.cd_promocao                    
                    from                         
                      Promocao p                        
                    where                        
                      p.cd_promocao = @cd_promocao)                        
          begin                    
                    
            select top 1                        
              @vl_desconto = round(@vl_total_pedido_venda * (c.pc_desconto_promocao / 100),2)                    
            from                        
              Promocao c                     
            where                        
              c.cd_promocao = @cd_promocao                    
                    
            set @pc_desconto_pedido = (100*@vl_desconto)/@vl_total_pedido_venda                    
                                
            update                    
              Pedido_Venda                    
            set                    
              vl_total_pedido_venda = @vl_total_pedido_venda,                    
              vl_desconto_pedido_venda = @vl_desconto,                    
              pc_desconto_pedido_venda = @pc_desconto_pedido,                    
              vl_icms_st = @vl_icms_st,                    
              vl_total_ipi = @vl_total_ipi,                    
              vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto                    
            where                    
              cd_pedido_venda = @cd_documento                    
                    
            select top 1                        
              @vl_total_pedido_venda          as vl_sub_total_tela,                        
              @vl_total_pedido_venda * (c.pc_desconto_promocao/100)     as vl_desconto,                        
              @vl_total_pedido_venda * (1-(c.pc_desconto_promocao/100)) as vl_total,                    
              c.pc_desconto_promocao                    
            from                        
              Promocao c                    
            where                        
              c.cd_promocao = @cd_promocao                    
          end                    
          else                        
          begin                      
            select                                                         
             @vl_total_pedido_venda = sum ( cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) as float)),                                      
             @vl_total_ipi          = sum ( round(cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) * isnull(pc_ipi,0)/100 as float),2)),                          
             @vl_icms_st            = sum ( cast(isnull(vl_item_icms_st,0) as decimal(25,2)) )                                      
            from                                            
              Pedido_Venda_Item                                      
            where                                      
              cd_pedido_venda = @cd_documento                                      
              and                                      
              dt_cancelamento_item is null                      
            group by                                      
              cd_pedido_venda                    
                    
            update                    
              Pedido_Venda                    
            set                    
              vl_total_pedido_venda = @vl_total_pedido_venda,                    
              vl_desconto_pedido_venda = @vl_desconto_pedido,                
              pc_desconto_pedido_venda = @pc_desconto_pedido,                    
              vl_icms_st = @vl_icms_st,                    
              vl_total_ipi = @vl_total_ipi,                    
              vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto_pedido                    
            where                    
              cd_pedido_venda = @cd_documento                    
                    
            select top 1                        
              @vl_total_pedido_venda           as vl_sub_total_tela,                        
              @vl_total_pedido_venda * (0)     as vl_desconto,                        
              @vl_total_pedido_venda * (1-(0)) as vl_total                         
          end                    
        end                    
      end                           
    end                   
    else                        
    begin --A                      
      select                                                         
       @vl_total_pedido_venda = sum ( cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) as float)),                                      
       @vl_total_ipi          = sum ( round(cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) * isnull(pc_ipi,0)/100 as float),2)),                                      
       @vl_icms_st            = sum ( cast(isnull(vl_item_icms_st,0) as decimal(25,2)) )                                      
      from                                            
        Pedido_Venda_Item                                      
      where                                      
        cd_pedido_venda = @cd_documento                                      
        and                                      
        dt_cancelamento_item is null                      
      group by                                      
        cd_pedido_venda                    
                    
      update                    
        Pedido_Venda                    
      set                    
        vl_total_pedido_venda = @vl_total_pedido_venda,                    
        vl_desconto_pedido_venda = @vl_desconto_pedido,                    
        pc_desconto_pedido_venda = @pc_desconto_pedido,                    
        vl_icms_st = @vl_icms_st,                    
        vl_total_ipi = @vl_total_ipi,                    
        vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto_pedido                        where                    
        cd_pedido_venda = @cd_documento                     
                    
      select top 1                        
        @vl_total_pedido_venda           as vl_sub_total_tela,                        
        @vl_total_pedido_venda * (0)     as vl_desconto,                        
        @vl_total_pedido_venda * (1-(0)) as vl_total                            
    end                        
  end                        
  else                        
  begin                        
    update Pedido_Venda_Caixa                    
    set cd_funcionario = @cd_funcionario_int                    
    where cd_pedido_venda = @cd_documento                     

    if @cd_promocao > 0                        
    begin                      
      update Pedido_Venda_Caixa                    
      set cd_promocao = @cd_promocao                    
      where cd_pedido_venda = @cd_documento                      
                    
      --select * from #PedidoItem                        
      if exists(select top 1                        
                  pp.cd_produto                        
                from                    
                  Fidelidade_Programa fp                    
                  inner join Promocao_Produto pp on pp.cd_promocao = fp.cd_promocao                    
                  inner join #PedidoItem s on s.cd_produto = pp.cd_produto                        
                where                        
                  fp.cd_promocao = @cd_promocao)                        
      begin                        
        select top 1                        
          @vl_desconto = round(s.vl_unitario * (pp.pc_promocao_desconto / 100),2)                        
        from                         
          Promocao_Produto pp                        
          inner join #PedidoItem s on s.cd_produto = pp.cd_produto                        
        where                
          pp.cd_promocao = @cd_promocao                         
        order by                        
          vl_unitario asc                    
                    
        set @pc_desconto_pedido = (100*@vl_desconto)/@vl_total_pedido_venda                    
                              
        update                    
          Pedido_Venda                    
        set                    
          vl_total_pedido_venda = @vl_total_pedido_venda,                    
          vl_desconto_pedido_venda = @vl_desconto,                    
          pc_desconto_pedido_venda = @pc_desconto_pedido,                    
          vl_icms_st = @vl_icms_st,                    
          vl_total_ipi = @vl_total_ipi,                    
          vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto                    
        where                    
          cd_pedido_venda = @cd_documento                    
                              
        select top 1                        
          isnull(@vl_sub_total_tela,0)   as vl_sub_total_tela,                        
          isnull(@vl_desconto,0)         as vl_desconto,                        
          isnull(@vl_sub_total_tela,0) -                         
          isnull(@vl_desconto,0)         as vl_total                          
      end                        
      else                    
      if exists(select top 1                        
                  pp.cd_produto                        
                from                         
                  Promocao_Produto pp                        
                  inner join #PedidoItem s on s.cd_produto = pp.cd_produto                        
                where                        
                  pp.cd_promocao = @cd_promocao)                        
      begin                        
        select top 1                        
          @vl_desconto = round(s.vl_unitario * (pp.pc_promocao_desconto / 100),2)                       
        from                         
          Promocao_Produto pp                        
          inner join #PedidoItem s on s.cd_produto = pp.cd_produto                        
        where                        
          pp.cd_promocao = @cd_promocao                        
          --and                        
          --@qt_produto_promocao > 1                        
        order by                        
          vl_unitario asc                    
                    
        set @pc_desconto_pedido = (100*@vl_desconto)/@vl_total_pedido_venda                    
                              
        update                    
          Pedido_Venda                    
        set                    
          vl_total_pedido_venda = @vl_total_pedido_venda,                    
          vl_desconto_pedido_venda = @vl_desconto,                    
          pc_desconto_pedido_venda = @pc_desconto_pedido,                    
          vl_icms_st = @vl_icms_st,                    
          vl_total_ipi = @vl_total_ipi,                    
          vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto                    
        where                    
          cd_pedido_venda = @cd_documento                    
                              
        select top 1                        
          isnull(@vl_sub_total_tela,0)   as vl_sub_total_tela,                        
          isnull(@vl_desconto,0)         as vl_desconto,                        
          isnull(@vl_sub_total_tela,0) -                         
          isnull(@vl_desconto,0)         as vl_total                          
      end                        
      else                        
      begin                        
        select                        
          cd_categoria_produto as cd_categoria,                        
          sum(qt_selecionado)  as qt_selecionado_categoria                        
        into                        
          #QTDCategoriaPromocaoPV1                        
        from                        
          #PedidoItem i                    
          left outer join Produto p on p.cd_produto = i.cd_produto                    
        group by                        
          cd_categoria_produto                        
        order by                        
          cd_categoria_produto                        
                              
        if exists(select top 1                    
                    pcp.cd_categoria_produto                    
                  from                    
                    Promocao_Categoria_Produto pcp                        
                    inner join #QTDCategoriaPromocaoPV1 sc on sc.cd_categoria = pcp.cd_categoria_produto                        
         where                        
                    pcp.cd_promocao = @cd_promocao                        
                    and                        
                    sc.qt_selecionado_categoria >= pcp.qt_venda)                        
        begin                        
          select top 1                        
            @vl_desconto = round(sum((s.vl_unitario * s.qt_selecionado) * (pcp.pc_desconto / 100)),2)                        
          from                         
            Promocao_Categoria_Produto pcp                      
            left outer join Produto p on p.cd_categoria_produto = pcp.cd_categoria_produto                       
            inner join #PedidoItem s on s.cd_produto = p.cd_produto                        
          where                        
            pcp.cd_promocao = @cd_promocao                        
                       
          set @pc_desconto_pedido = (100*@vl_desconto)/@vl_total_pedido_venda                    
                              
          update                    
            Pedido_Venda                    
          set                    
            vl_total_pedido_venda = @vl_total_pedido_venda,                    
            vl_desconto_pedido_venda = @vl_desconto,                    
            pc_desconto_pedido_venda = @pc_desconto_pedido,                    
            vl_icms_st = @vl_icms_st,                    
            vl_total_ipi = @vl_total_ipi,                    
            vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto                    
          where                    
            cd_pedido_venda = @cd_documento                    
                    
          select top 1                        
            isnull(@vl_total_pedido_venda,0)   as vl_sub_total_tela,                        
            isnull(@vl_desconto,0)             as vl_desconto,                        
            isnull(@vl_total_pedido_venda,0) -                         
            isnull(@vl_desconto,0)             as vl_total                         
                              
          drop table #QTDCategoriaPromocaoPV1                        
        end                        
        else                    
        begin                    
          if exists(select top 1                        
                      p.cd_promocao                    
                    from                         
                      Promocao p                        
                    where                        
                      p.cd_promocao = @cd_promocao)                        
          begin                    
                    
            select top 1                        
              @vl_desconto = round(@vl_total_pedido_venda * (c.pc_desconto_promocao / 100),2)                    
            from                        
              Promocao c                     
            where                        
              c.cd_promocao = @cd_promocao                    
                    
            set @pc_desconto_pedido = (100*@vl_desconto)/@vl_total_pedido_venda                    
                                
            update                    
              Pedido_Venda                    
            set                    
              vl_total_pedido_venda = @vl_total_pedido_venda,                    
              vl_desconto_pedido_venda = @vl_desconto,                    
              pc_desconto_pedido_venda = @pc_desconto_pedido,                    
              vl_icms_st = @vl_icms_st,                    
              vl_total_ipi = @vl_total_ipi,                    
              vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto                    
            where                    
              cd_pedido_venda = @cd_documento                    
                    
            select top 1                        
              @vl_total_pedido_venda          as vl_sub_total_tela,                        
              @vl_total_pedido_venda * (c.pc_desconto_promocao/100)     as vl_desconto,                        
              @vl_total_pedido_venda * (1-(c.pc_desconto_promocao/100)) as vl_total,                    
              c.pc_desconto_promocao                    
            from                        
              Promocao c                    
            where                        
              c.cd_promocao = @cd_promocao                    
          end                    
          else                        
          begin                      
            select                                                         
             @vl_total_pedido_venda = sum ( cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) as float)),                                      
             @vl_total_ipi          = sum ( round(cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) * isnull(pc_ipi,0)/100 as float),2)),                          
             @vl_icms_st            = sum ( cast(isnull(vl_item_icms_st,0) as decimal(25,2)) )                                      
            from                                            
              Pedido_Venda_Item                                      
            where                                      
              cd_pedido_venda = @cd_documento                                      
              and                                      
              dt_cancelamento_item is null                      
            group by                                      
              cd_pedido_venda                    
                    
            update                    
              Pedido_Venda                    
            set                    
              vl_total_pedido_venda = @vl_total_pedido_venda,                    
              vl_desconto_pedido_venda = @vl_desconto_pedido,                
              pc_desconto_pedido_venda = @pc_desconto_pedido,                    
              vl_icms_st = @vl_icms_st,                    
              vl_total_ipi = @vl_total_ipi,                    
              vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto_pedido                    
            where                    
              cd_pedido_venda = @cd_documento                    
                    
            select top 1                        
              @vl_total_pedido_venda           as vl_sub_total_tela,                        
              @vl_total_pedido_venda * (0)     as vl_desconto,                        
              @vl_total_pedido_venda * (1-(0)) as vl_total                         
          end                    
        end                    
      end                           
    end                   
    else                        
    begin
      select                                                         
       @vl_total_pedido_venda = sum ( cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) as float)),                                      
       @vl_total_ipi          = sum ( round(cast(isnull(vl_unitario_item_pedido,0) * isnull(qt_item_pedido_venda,0) * isnull(pc_ipi,0)/100 as float),2)),                                    
       @vl_icms_st            = sum ( cast(isnull(vl_item_icms_st,0) as decimal(25,2)) )                                      
      from                                            
        Pedido_Venda_Item                                      
      where                                      
        cd_pedido_venda = @cd_documento                                      
        and                                      
        dt_cancelamento_item is null                      
      group by                                      
        cd_pedido_venda  
      
      select                      
        @vl_desconto_pedido = round((@vl_total_pedido_venda+@vl_total_ipi+@vl_icms_st) * (c.pc_desconto_funcionario/100),2),                    
        @pc_desconto_pedido = c.pc_desconto_funcionario                    
      from                        
        Config_Terminal_Venda c         
        
                      
      update Pedido_Venda
      set                    
        vl_total_pedido_venda = @vl_total_pedido_venda,                    
        vl_desconto_pedido_venda = @vl_desconto_pedido,                    
        pc_desconto_pedido_venda = @pc_desconto_pedido,                    
        vl_icms_st = @vl_icms_st,                    
        vl_total_ipi = @vl_total_ipi,                    
        vl_total_pedido_ipi = (@vl_total_pedido_venda + @vl_total_ipi + @vl_icms_st) - @vl_desconto_pedido                    
      where                    
        cd_pedido_venda = @cd_documento                    
                      
      select top 1                        
        @vl_total_pedido_venda                                       as vl_sub_total_tela,                        
        @vl_total_pedido_venda * (c.pc_desconto_funcionario/100)     as vl_desconto,
        @vl_total_pedido_venda * (1-(c.pc_desconto_funcionario/100)) as vl_total                        
      from                        
        Config_Terminal_Venda c
    end
  end                        
                        
end           
          
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 17 - Pesquisa de Cliente          
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 17          
begin            
  declare @dt_inicio_fidelidade datetime          
  declare @dt_fim_fidelidade datetime          
  declare @ic_programa_fidelidade char(1)          
  declare @qt_total_ponto int          
  declare @cd_promocao_fidelidade int          
  declare @cd_id_promocao_fidelidade varchar(30)          
  declare @cd_produto_fidelidade int          
  declare @cd_categoria_fidelidade int          
  set @ic_programa_fidelidade = 'N'          
  set @qt_total_ponto = 0          
          
  declare @nm_fantasia_produto_fid varchar(30)          
  declare @cd_mascara_produto_fid varchar(30)          
  declare @nm_produto_fid varchar(120)          
  declare @cd_codigo_barra_produto_fid varchar(70)          
  declare @sg_unidade_medida_fid char(10)          
  declare @qt_saldo_disponivel_fid float          
  declare @vl_unitario_fid float          
  declare @vl_tabela_fid float          
  declare @cd_tributacao_fid int          
  declare @cd_tributacao_cupom_fid varchar(5)          
          
  select          
    @ic_programa_fidelidade = isnull(ic_programa_fidelidade,'N')          
  from          
    Config_Terminal_Venda          
          
  select           
    @qt_total_ponto          = isnull(qt_total_ponto_resgate,0),          
    @dt_inicio_fidelidade    = dt_inicio_vigencia,          
    @dt_fim_fidelidade       = dt_fim_vigencia,          
    @cd_promocao_fidelidade  = cd_promocao,          
    @cd_categoria_fidelidade = cd_categoria_fidelidade          
  from           
    fidelidade_programa          
  where          
    isnull(ic_ativo_fidelidade,'N') = 'S'          
          
  select top 1               
    @cd_id_promocao_fidelidade = cd_identificacao_promocao          
  from               
    Promocao               
  where               
    cd_promocao = @cd_promocao_fidelidade          
          
  select top 1          
    @cd_produto_fidelidade = cd_produto          
  from               
    Promocao_Produto          
  where               
    cd_promocao = @cd_promocao_fidelidade          
          
  select          
    @nm_fantasia_produto_fid = p.nm_fantasia_produto,                        
    @cd_mascara_produto_fid = p.cd_mascara_produto,            
    @nm_produto_fid = p.nm_produto,                        
    @cd_codigo_barra_produto_fid = p.cd_codigo_barra_produto,                        
    @sg_unidade_medida_fid = um.sg_unidade_medida,                        
    @qt_saldo_disponivel_fid = ISNULL(ps.qt_saldo_reserva_produto, 0),          
    @vl_unitario_fid = case when isnull(tpp.vl_tabela_produto,0) > 0 then tpp.vl_tabela_produto else p.vl_produto end,          
    @vl_tabela_fid = case when isnull(tpp.vl_tabela_produto,0) > 0 then tpp.vl_tabela_produto else p.vl_produto end,          
    @cd_tributacao_fid = p.cd_tributacao,                        
    @cd_tributacao_cupom_fid = tcf.qt_parametro          
  from              
    produto p        with(nolock)          
    left outer join Tabela_Preco_Produto tpp on tpp.cd_tabela_preco  = @cd_tabela_preco and              
                                                tpp.cd_produto       = p.cd_produto              
    left join unidade_medida um with(nolock) on um.cd_unidade_medida = p.cd_unidade_medida                        
    left join produto_saldo ps  with(nolock) on ps.cd_produto        = CASE WHEN ISNULL(p.cd_produto_baixa_estoque, 0) <> 0              
                                                                         THEN p.cd_produto_baixa_estoque              
                                                                         ELSE p.cd_produto              
                                                                       END              
                                            and ps.cd_fase_produto   = CASE WHEN @cd_fase_produto <> 0               
                                                                         THEN @cd_fase_produto              
                                                                         ELSE ISNULL(p.cd_fase_produto_baixa, 0)              
                                   END              
    left join (select               
                 cd_tributacao,                         
                 MAX(qt_parametro) as qt_parametro                        
               from              
                 tributacao_cupom_fiscal with(nolock)                        
               group by cd_tributacao) tcf   on tcf.cd_tributacao    = p.cd_tributacao              
  where                        
    p.ic_produto_caixa = 'S'          
    and          
    p.cd_produto = @cd_produto_fidelidade          
          
  ----------------------------------------------------------------------------------------------------          
  --Verificando Quantidade de Pontos por venda de produtos da Categoria          
  select          
    m.cd_cliente,          
    m.cd_movimento_caixa,          
    isnull((select sum(qt_item_movimento_caixa)           
     from Movimento_caixa_Item i          
     inner join Produto p on p.cd_produto = i.cd_produto          
     where i.cd_movimento_caixa = m.cd_movimento_caixa          
       and p.cd_categoria_produto = @cd_categoria_fidelidade),0) as qt_ponto_fidelidade          
  into          
    #Movimento_Fidelidade          
  from          
    Movimento_Caixa m          
    inner join Cliente c on c.cd_cliente = m.cd_cliente          
  where          
    --Nome Cliente          
    ((c.nm_fantasia_cliente like '%' + @nm_fantasia_cliente + '%')  or          
 --CPF/CNPJ          
    (replace(replace(c.cd_cnpj_cliente,'.',''),'-','') like '%' + @nm_fantasia_cliente + '%') or          
    --Telefone          
    (case when ltrim(rtrim(isnull(c.cd_ddd,''))) = ''           
      then ltrim(rtrim(isnull(c.cd_telefone,'')))          
      else case when ltrim(rtrim(isnull(c.cd_telefone,''))) = ''           
             then ''          
             else ltrim(rtrim(isnull(c.cd_ddd,'')))+ ltrim(rtrim(isnull(c.cd_telefone,'')))          
           end          
    end like '%' + @nm_fantasia_cliente + '%'))          
    and          
    m.dt_cancel_movimento_caixa is null          
    and          
    m.dt_movimento_caixa between @dt_inicio_fidelidade and @dt_fim_fidelidade          
  group by          
    m.cd_cliente,          
    m.cd_movimento_caixa          
  ----------------------------------------------------------------------------------------------------          
          
  select          
    c.cd_cliente,          
    c.nm_fantasia_cliente,          
    c.cd_cnpj_cliente      as cd_cpf_cnpj,          
    case when ltrim(rtrim(isnull(c.cd_ddd,''))) = ''           
      then ltrim(rtrim(isnull(c.cd_telefone,'')))          
      else case when ltrim(rtrim(isnull(c.cd_telefone,''))) = ''           
             then ''          
             else '('+ltrim(rtrim(isnull(c.cd_ddd,'')))+') '+ ltrim(rtrim(isnull(c.cd_telefone,'')))          
           end          
    end                    as cd_celular,          
    c.dt_aniversario_cliente,          
    c.nm_email_cliente,          
    case when (DAY(c.dt_aniversario_cliente) = DAY(@dt_hoje)) and (MONTH(c.dt_aniversario_cliente) = MONTH(@dt_hoje))          
      then 'S'          
      else 'N'          
    end                    as ic_aniversario,          
    isnull((          
      select          
        sum(m.qt_ponto_fidelidade)-          
        sum(isnull(r.qt_ponto_resgate,0))          
      from          
        #Movimento_Fidelidade m          
        left outer join Movimento_Caixa_Resgate r on r.cd_movimento_caixa = m.cd_movimento_caixa          
        left outer join Movimento_Caixa_Promocao p on p.cd_movimento_caixa = m.cd_movimento_caixa          
      where          
        m.cd_cliente = c.cd_cliente          
        and          
        isnull(p.cd_promocao,0) <> isnull(@cd_promocao_fidelidade,0)          
 ),0)                    as qt_compra_cliente          
  into          
    #DadosClienteCardGrid          
  from          
    Cliente c          
  where          
    --Nome Cliente          
    ((c.nm_fantasia_cliente like '%' + @nm_fantasia_cliente + '%')  or          
 --CPF/CNPJ          
    (replace(replace(c.cd_cnpj_cliente,'.',''),'-','') like '%' + @nm_fantasia_cliente + '%') or          
    --Telefone          
    (case when ltrim(rtrim(isnull(c.cd_ddd,''))) = ''           
      then ltrim(rtrim(isnull(c.cd_telefone,'')))          
      else case when ltrim(rtrim(isnull(c.cd_telefone,''))) = ''           
             then ''          
             else ltrim(rtrim(isnull(c.cd_ddd,'')))+ ltrim(rtrim(isnull(c.cd_telefone,'')))          
           end          
    end like '%' + @nm_fantasia_cliente + '%') )         
          
  ----------------------------------------------------------------------------------------------------          
  --Select Final          
  select           
    *,          
    case when ic_aniversario = 'S'          
      then 'Parabéns hoje é seu Aniversário!'          
      else ''          
    end                     as nm_mensagem_aniversario,          
    @ic_programa_fidelidade as ic_programa_fidelidade,          
    @qt_total_ponto         as qt_total_ponto,          
    case when (@qt_total_ponto-qt_compra_cliente) <= 0          
      then 0          
      else (@qt_total_ponto-qt_compra_cliente)          
    end                     as qt_falta_resgate,          
    case when @ic_programa_fidelidade = 'S'          
      then case when (@qt_total_ponto-qt_compra_cliente) <= 0          
             then 'Parabéns Brinde Disponível!'          
             else 'Falta '+cast((@qt_total_ponto-qt_compra_cliente) as varchar(10))+' ponto(s) para o Brinde.'          
        end          
      else ''          
    end                          as nm_mensagem_brinde,          
    @cd_id_promocao_fidelidade   as nm_identificacao_promocao,            
    @cd_produto_fidelidade       as cd_produto,          
    @nm_fantasia_produto_fid     as nm_fantasia_produto,                        
    @cd_mascara_produto_fid      as cd_mascara_produto,                        
    @nm_produto_fid              as nm_produto,                        
    @cd_codigo_barra_produto_fid as cd_codigo_barra_produto,                        
    @sg_unidade_medida_fid       as sg_unidade_medida,                        
    @qt_saldo_disponivel_fid     as qt_saldo_disponivel,                        
    @vl_unitario_fid             as vl_unitario,               
    @vl_tabela_fid       as vl_tabela,               
    @cd_tributacao_fid           as cd_tributacao,                        
    @cd_tributacao_cupom_fid     as cd_tributacao_cupom          
  from          
    #DadosClienteCardGrid          
          
end          
          
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 18 - Cadastro de Cliente          
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 18          
begin          
  set @cpf = replace(replace(ltrim(rtrim(@cpf)),'.',''),'-','')          
          
  declare @cd_ddd_cel varchar(20)          
  set @cd_ddd_cel = replace(replace(replace(ltrim(rtrim(@cd_ddd_cliente)),'(',''),')',''),' ','')+          
      replace(replace(replace(replace(ltrim(rtrim(@cd_celular_cliente)),'-',''),'(',''),')',''),' ','')          
        
  set @nm_fantasia_cliente = UPPER(@nm_fantasia_cliente)        
           
  if exists(select top 1 cd_cliente from vw_cadastro_cliente_matriz where nm_fantasia_cliente = @nm_fantasia_cliente and          
            replace(replace(replace(ltrim(rtrim(cd_ddd)),'(',''),')',''),' ','')+          
            replace(replace(replace(replace(ltrim(rtrim(cd_telefone)),'-',''),'(',''),')',''),' ','') = @cd_ddd_cel)          
  begin          
    select 'Já existe Registro com as mesmas informações inseridas!' as Msg          
  end          
  else          
  begin          
    exec pr_insere_cliente_gca_unificado        
    0,        
    @nm_fantasia_cliente,        
    @cpf,        
    @cd_ddd_cliente,         
    @cd_celular_cliente,         
    @nm_email_cliente,         
    @dt_nascimento_cliente,        
    @cd_usuario        
        
  --  SELECT @cd_cliente = ISNULL(MAX(cd_cliente), 0) + 1 FROM Cliente        
  --  INSERT INTO Cliente        
  --  (cd_cliente, nm_fantasia_cliente, nm_razao_social_cliente,        
  --   ic_destinacao_cliente, dt_cadastro_cliente, cd_tipo_pessoa,        
  --   cd_cnpj_cliente, cd_ramo_atividade, cd_status_cliente,        
  --   cd_transportadora, cd_tipo_mercado, cd_idioma, cd_usuario,        
  --   dt_usuario, ic_liberado_pesq_credito, cd_ddd, cd_telefone,        
  --   cd_ddd_celular_cliente, cd_celular_cliente,        
  --   nm_email_cliente, dt_aniversario_cliente)          
  --   VALUES          
  --  (@cd_cliente, @nm_fantasia_cliente, @nm_fantasia_cliente,          
  --   '1', GETDATE(), 2, @cpf, 1, 1, 1, 1, 1, 1, GETDATE(), 'S',          
  --   @cd_ddd_cliente, @cd_celular_cliente,         
  --   @cd_ddd_cliente, @cd_celular_cliente,         
  --@nm_email_cliente, @dt_nascimento_cliente)                 
          
    select 'Registro incluido com Sucesso!' as Msg          
  end          
end 
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 40 - Exclusão total dos Itens do Pedido
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
                    
if @cd_parametro = 40
begin
  delete from Pedido_Venda_Item where cd_pedido_venda = @cd_documento

  select 'Itens Excluidos com Sucesso!' as Msg
end
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 60 - Pesquisar produto                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
                    
if @cd_parametro = 60                        
begin                        
                       
   -- Tabela temporária para produtos                        
   select                         
      TOP 50                        
      p.cd_produto,                        
      p.nm_fantasia_produto,                        
   p.cd_mascara_produto,                        
      p.nm_produto,                        
   p.cd_codigo_barra_produto,                        
      um.sg_unidade_medida,                        
      ISNULL(ps.qt_saldo_reserva_produto, 0) as qt_saldo_disponivel,                        
      case when isnull(tpp.vl_tabela_produto,0) > 0 then tpp.vl_tabela_produto else p.vl_produto end as vl_unitario,                  
      case when isnull(tpp.vl_tabela_produto,0) > 0 then tpp.vl_tabela_produto else p.vl_produto end as vl_tabela,                       
      p.cd_tributacao,                        
      tcf.qt_parametro as cd_tributacao_cupom                        
   into #ProdutosDisponiveis                        
   from produto p with (nolock)               
   left outer join Tabela_Preco_Produto tpp on tpp.cd_tabela_preco = @cd_tabela_preco and              
                                               tpp.cd_produto      = p.cd_produto              
   left join unidade_medida um with (nolock)                         
        on um.cd_unidade_medida = p.cd_unidade_medida                        
   left join produto_saldo ps with (nolock)                         
        on ps.cd_produto = CASE                        
                              WHEN ISNULL(p.cd_produto_baixa_estoque, 0) <> 0                         
                              THEN p.cd_produto_baixa_estoque                         
                            ELSE p.cd_produto                        
                           END                        
        AND ps.cd_fase_produto = CASE                         
                                    WHEN @cd_fase_produto <> 0 THEN @cd_fase_produto                        
                                    ELSE ISNULL(p.cd_fase_produto_baixa, 0)                        
                                 END                        
   left join (                        
        select                         
            cd_tributacao,                         
            MAX(qt_parametro) as qt_parametro                        
        from tributacao_cupom_fiscal with (nolock)                        
        group by cd_tributacao                        
   ) tcf on tcf.cd_tributacao = p.cd_tributacao                        
   where               
  (p.ic_produto_caixa = 'S')                        
  and                        
      (p.cd_grupo_produto not in (                        
         select cd_grupo_produto                         
         from grupo_produto                         
         where ic_garantia_grupo_produto = 'S')                         
         or p.cd_grupo_produto is null)                        
      and (                        
         @nm_produto_busca is null                         
         or @nm_produto_busca = '%' -- Retorna todos os itens quando for '&'                        
         or (UPPER(p.nm_fantasia_produto) like '%' + UPPER(@nm_produto_busca) + '%'                        
         or UPPER(p.nm_produto) like '%' + UPPER(@nm_produto_busca) + '%'                        
   or UPPER(p.cd_mascara_produto) like '%' + UPPER(@nm_produto_busca) + '%'                        
   or p.cd_produto like '%' + @nm_produto_busca + '%'-- Busca por parte do código de barras                        
         or p.cd_codigo_barra_produto like '%' + @nm_produto_busca + '%') -- Busca por parte do código de barras                        
      )                        
   order by p.nm_fantasia_produto                        
                        
   -- Retorna os produtos disponíveis                        
   select                         
      pd.*             
   from #ProdutosDisponiveis pd                        
   order by pd.nm_fantasia_produto                        
                        
   drop table #ProdutosDisponiveis                        
end               
              
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 61 - Produtos Principais e Mais Vendidos                        
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 61                       
begin                        
  select top 6               
    p.cd_produto,                        
    p.nm_fantasia_produto,                        
    p.cd_mascara_produto,                        
    p.nm_produto,               
    p.cd_codigo_barra_produto,                        
    um.sg_unidade_medida,                        
    ISNULL(ps.qt_saldo_reserva_produto, 0) as qt_saldo_disponivel,                        
    case when isnull(tpp.vl_tabela_produto,0) > 0 then tpp.vl_tabela_produto else p.vl_produto end as vl_unitario,               
    case when isnull(tpp.vl_tabela_produto,0) > 0 then tpp.vl_tabela_produto else p.vl_produto end as vl_tabela,               
    p.cd_tributacao,                        
    tcf.qt_parametro as cd_tributacao_cupom              
  into              
    #ProdutoPrincMaisVend              
  from              
    Terminal_Venda_Produto tvp              
    inner join produto p        with(nolock) on p.cd_produto         = tvp.cd_produto              
    left outer join Tabela_Preco_Produto tpp on tpp.cd_tabela_preco  = @cd_tabela_preco and              
                                                tpp.cd_produto       = p.cd_produto              
    left join unidade_medida um with(nolock) on um.cd_unidade_medida = p.cd_unidade_medida           
    left join produto_saldo ps  with(nolock) on ps.cd_produto        = CASE WHEN ISNULL(p.cd_produto_baixa_estoque, 0) <> 0              
                                                                         THEN p.cd_produto_baixa_estoque              
                                                                         ELSE p.cd_produto              
                                                                       END              
                                            and ps.cd_fase_produto   = CASE WHEN @cd_fase_produto <> 0               
                                                                         THEN @cd_fase_produto              
                                                                         ELSE ISNULL(p.cd_fase_produto_baixa, 0)              
                                                                       END              
    left join (select               
                 cd_tributacao,                    
                 MAX(qt_parametro) as qt_parametro                        
               from              
                 tributacao_cupom_fiscal with(nolock)                        
               group by cd_tributacao) tcf   on tcf.cd_tributacao    = p.cd_tributacao              
  where                        
    p.ic_produto_caixa = 'S'              
              
              
  select               
    cd_produto, sum(qt_item_movimento_caixa) as qt_venda_produto              
  into              
    #ProdutosMaisVendidos              
  from               
    movimento_caixa_item               
  group by               
    cd_produto               
  order by               
    cd_produto              
                
  insert into #ProdutoPrincMaisVend              
  select top 6               
    p.cd_produto,                        
    p.nm_fantasia_produto,                        
    p.cd_mascara_produto,                        
    p.nm_produto,                        
    p.cd_codigo_barra_produto,                        
    um.sg_unidade_medida,                        
    ISNULL(ps.qt_saldo_reserva_produto, 0) as qt_saldo_disponivel,                        
    case when isnull(tpp.vl_tabela_produto,0) > 0 then tpp.vl_tabela_produto else p.vl_produto end as vl_unitario,                  
    case when isnull(tpp.vl_tabela_produto,0) > 0 then tpp.vl_tabela_produto else p.vl_produto end as vl_tabela,               
    p.cd_tributacao,                        
    tcf.qt_parametro as cd_tributacao_cupom              
  from              
    #ProdutosMaisVendidos mv              
    inner join produto p        with(nolock) on p.cd_produto         = mv.cd_produto              
    left outer join Tabela_Preco_Produto tpp on tpp.cd_tabela_preco  = @cd_tabela_preco and              
                                                tpp.cd_produto       = p.cd_produto              
    left join unidade_medida um with(nolock) on um.cd_unidade_medida = p.cd_unidade_medida                        
    left join produto_saldo ps  with(nolock) on ps.cd_produto        = CASE WHEN ISNULL(p.cd_produto_baixa_estoque, 0) <> 0              
                                                                         THEN p.cd_produto_baixa_estoque              
                                                                         ELSE p.cd_produto              
                                                                       END              
                                            and ps.cd_fase_produto   = CASE WHEN @cd_fase_produto <> 0               
                                                                         THEN @cd_fase_produto              
                                                                         ELSE ISNULL(p.cd_fase_produto_baixa, 0)              
                                                                       END              
    left join (select               
                 cd_tributacao,                         
                 MAX(qt_parametro) as qt_parametro                        
               from              
            tributacao_cupom_fiscal with(nolock)                        
               group by cd_tributacao) tcf   on tcf.cd_tributacao    = p.cd_tributacao         
  where              
    p.ic_produto_caixa = 'S'              
    and              
    mv.cd_produto not in (select x.cd_produto from #ProdutoPrincMaisVend x)              
  order by               
    mv.qt_venda_produto desc              
              
  select top 6 * from #ProdutoPrincMaisVend              
                 
  drop table #ProdutosMaisVendidos              
  drop table #ProdutoPrincMaisVend              
              
end              
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 75                        
begin                        
 DECLARE @resultado BIT = 0;                        
                            
    -- Verifica se o operador tem IC_auto_atendimento = true                        
    IF EXISTS (                        
        SELECT 1                         
        FROM operador_caixa                         
        WHERE cd_operador_caixa = @cd_operador_caixa                         
        AND IC_auto_atendimento ='S'                        
    )                        
BEGIN                        
        SET @resultado = 1;                        
    END                        
    ELSE                        
    BEGIN                        
        -- Verifica se existe abertura de caixa com dt_ultimo_fechamento NULL                        
        IF EXISTS (                       
            SELECT 1                         
            FROM abertura_caixa                         
            WHERE dt_ultimo_fechamento IS NULL                        
        )                        
        BEGIN                        
  SET @resultado = 1;                        
        END                        
    END                        
                            
    -- Retorna o resultado                        
    SELECT @resultado AS resultado;                        
end                        
                    
IF @cd_parametro = 100                        
BEGIN
 if exists(select          
             cd_movimento_caixa          
           from           
             Movimento_Caixa_Divisao
           where           
             cd_movimento_caixa = @cd_movimento_caixa)
    and
    isnull(@vl_troco,0) = 0
 begin
   select          
     @vl_troco = sum(isnull(vl_troco,0))
   from           
     Movimento_Caixa_Divisao
   where           
     cd_movimento_caixa = @cd_movimento_caixa
 end

 if exists(select          
             cd_movimento_caixa          
           from           
             Movimento_Caixa           
           where           
             cd_movimento_caixa = @cd_movimento_caixa)
    and
    isnull(@vl_troco,0) > 0
 begin          
   update Movimento_Caixa          
   set vl_troco = @vl_troco,          
       vl_dinheiro = vl_movimento_caixa+@vl_troco          
   where           
     cd_movimento_caixa = @cd_movimento_caixa
 end          
          
 -- Status do Servidor NFe                        
 SELECT TOP 1 @ic_status_servidor_nfe = ISNULL(ic_ativo, 'N')                         
 FROM egisadmin.dbo.NFe_Empresa                         
 WHERE cd_empresa = @cd_empresa;           
           
 --Link NFE          
 select          
   @base_url = case when isnull(nm_link_nfe_local,'')<>'' then nm_link_nfe_local else nm_link_nfe end          
 from          
   config_egismob           
 where          
   cd_empresa = @cd_empresa          
                        
 if exists(select top 1 cd_nota_saida from nota_saida where isnull(vl_total,0) = 0)          
 begin          
   delete from          
     Nota_Validacao          
   where          
     cd_nota_saida in (select cd_nota_saida from nota_saida where isnull(vl_total,0) = 0)          
 end          
          
 IF EXISTS (SELECT 1 FROM Movimento_Caixa WHERE cd_movimento_caixa = @cd_movimento_caixa AND cd_nota_saida IS NOT NULL)                
 BEGIN                        
                
  SELECT @cd_nota_saida = cd_nota_saida                         
  FROM Movimento_Caixa                         
  WHERE cd_movimento_caixa = @cd_movimento_caixa;                        
                        
  SELECT                         
   n.cd_nota_saida,                        
   s.ic_nfe_serie_nota,                        
   n.cd_chave_acesso,                        
   nv.ic_validada,                        
   CASE                         
    WHEN ISNULL(n.cd_chave_acesso, '') = ''                         
     OR ISNULL(s.ic_nfe_serie_nota, 'N') = 'N'                         
     OR ISNULL(nv.ic_validada, 'N') = 'N'                        
    THEN ''                        
   ELSE                     
    @nm_nfe_link + REPLACE(n.cd_chave_acesso, 'NFe', '') + '?banco=' + ISNULL(@nm_basesql, '')                        
   END AS nm_nfe_link,                        
   -- STATUS BASEADO NA NOTA_VALIDAÇÃO                        
   CASE                         
    WHEN s.cd_ambiente_nfe = 1 THEN 49  -- Homologação                        
    WHEN ISNULL(@ic_status_servidor_nfe, 'N') = 'S' AND nv.ic_validada = 'N' THEN 62  -- Aguardando validação                        
    WHEN ISNULL(@ic_status_servidor_nfe, 'N') <> 'S' AND nv.ic_validada <> 'S' THEN 61  -- Servidor offline                        
    ELSE 48  -- Validada com sucesso (quando nv.ic_validada = 'S')                        
   END AS cd_status_validacao,                        
   -- STATUS DIRETO DA NOTA_VALIDAÇÃO (se existir na tabela)                        
   CASE                         
    WHEN EXISTS (SELECT 1 FROM Nota_Saida_Rejeicao WHERE cd_nota_saida = n.cd_nota_saida) THEN 3  -- Rejeitada                        
    ELSE nv.cd_status_validacao                         
   END AS status_direto_validacao,          
   case when isnull(@base_url,'') = '' then 'https://egiserp.com.br/api/nfe/nfce/danfe/' else @base_url end as base_url          
  FROM Nota_Saida n                        
  INNER JOIN serie_nota_fiscal s ON s.cd_serie_nota_fiscal = n.cd_serie_nota                         
  LEFT JOIN Nota_Validação nv ON nv.cd_nota_saida = n.cd_nota_saida                        
  WHERE n.cd_nota_saida = @cd_nota_saida                        
  AND ISNULL(s.ic_nfe_serie_nota, 'N') = 'S';                        
 END                        
 ELSE                       
 BEGIN                        
                    
  if @ic_nfce = 'S'
  begin
    EXEC dbo.pr_gera_nota_saida_oficial                          
     @cd_movimento_caixa = @cd_movimento_caixa,                          
     @cd_pedido_venda = 0,                          
     @cd_usuario = @cd_usuario,                          
     @dt_nota_saida = null,                          
     @cd_operacao_fiscal = 0,                          
     @dt_saida_nota_saida = NULL,                          
     @ic_tipo_nota = 0,
     @cd_serie_nota = 0,
     @cd_identificacao_nf = NULL                         
  end
  else
  begin
    EXEC dbo.pr_gera_nota_saida_oficial                          
     @cd_movimento_caixa = @cd_movimento_caixa,                          
     @cd_pedido_venda = 0,                          
     @cd_usuario = @cd_usuario,                          
     @dt_nota_saida = null,                          
     @cd_operacao_fiscal = 0,                          
     @dt_saida_nota_saida = NULL,                          
     @ic_tipo_nota = 2,                          
     @cd_serie_nota = 0,                          
     @cd_identificacao_nf = NULL                         
  end                     
                        
  -- Após gerar a nota, executa o código criado                        
  DECLARE @cd_nota_saida_nova int;                        
                        
  SELECT @cd_nota_saida_nova = cd_nota_saida                         
  FROM Movimento_Caixa                         
  WHERE cd_movimento_caixa = @cd_movimento_caixa;                        
                        
  --INSERT INTO @ResultTable                        
  SELECT                         
   n.cd_nota_saida,                        
   s.ic_nfe_serie_nota,                        
   n.cd_chave_acesso,                        
   nv.ic_validada,                        
   CASE                         
    WHEN ISNULL(n.cd_chave_acesso, '') = ''                         
     OR ISNULL(s.ic_nfe_serie_nota, 'N') = 'N'                         
     OR ISNULL(nv.ic_validada, 'N') = 'N'                        
    THEN ''                        
   ELSE                         
    @nm_nfe_link + REPLACE(n.cd_chave_acesso, 'NFe', '') + '?banco=' + ISNULL(@nm_basesql, '')                        
   END AS nm_nfe_link,                        
   -- STATUS BASEADO NA NOTA_VALIDAÇÃO                        
   CASE                         
    WHEN s.cd_ambiente_nfe = 1 THEN 49  -- Homologação                        
    WHEN ISNULL(@ic_status_servidor_nfe, 'N') = 'S' AND nv.ic_validada = 'N' THEN 62  -- Aguardando validação                        
    WHEN ISNULL(@ic_status_servidor_nfe, 'N') <> 'S' AND nv.ic_validada <> 'S' THEN 61  -- Servidor offline                        
    ELSE 48  -- Validada com sucesso (quando nv.ic_validada = 'S')                        
   END AS cd_status_validacao,                        
   -- STATUS DIRETO DA NOTA_VALIDAÇÃO                        
   CASE                         
    WHEN EXISTS (SELECT 1 FROM Nota_Saida_Rejeicao WHERE cd_nota_saida = n.cd_nota_saida) THEN 3  -- Rejeitada                        
    ELSE nv.cd_status_validacao                         
   END AS status_direto_validacao,          
   case when isnull(@base_url,'') = '' then 'https://egiserp.com.br/api/nfe/nfce/danfe/' else @base_url end as base_url             
  FROM Nota_Saida n                        
  INNER JOIN serie_nota_fiscal s ON s.cd_serie_nota_fiscal = n.cd_serie_nota                         
  LEFT JOIN Nota_Validação nv ON nv.cd_nota_saida = n.cd_nota_saida                        
  WHERE n.cd_nota_saida = @cd_nota_saida_nova                        
  AND ISNULL(s.ic_nfe_serie_nota, 'N') = 'S';                        
                      
 END                        
END          
---------------------------------------------------------------------------------------------------------------------------------------------        
if @cd_parametro = 101 --Realiza abertura do caixa se estiver fechado            
begin            
  declare @cd_abertura_caixa_atualizacao int        
        
  select @cd_terminal = cd_terminal_caixa from terminal_caixa_operador where cd_operador_caixa = @cd_operador_caixa               
            
  if exists (select top 1 cd_abertura_caixa from Abertura_Caixa where dt_abertura_caixa = @dt_hoje and dt_ultimo_fechamento is null)        
  begin        
    select top 1         
      @cd_abertura_caixa_atualizacao = cd_abertura_caixa         
    from         
      Abertura_Caixa         
    where         
      dt_abertura_caixa = @dt_hoje         
      and         
      dt_ultimo_fechamento is null        
        
    update Abertura_Caixa        
    set cd_operador_caixa = @cd_operador_caixa        
 where        
      cd_abertura_caixa = @cd_abertura_caixa_atualizacao        
        
    update Movimento_Caixa        
    set cd_operador_caixa = @cd_operador_caixa        
    where        
      cd_abertura_caixa = @cd_abertura_caixa_atualizacao        
        
    select 'Caixa 1 aberto com sucesso!' as Msg, @cd_abertura_caixa_atualizacao as cd_abertura_caixa        
  end        
  else        
  begin        
    DECLARE @json_abertura NVARCHAR(MAX)          
                
    SET @json_abertura = N'[            
    {            
       "cd_parametro": 1,            
       "cd_usuario": ' + CONVERT(VARCHAR(10), ISNULL(@cd_usuario, 0)) + ',            
       "cd_terminal_caixa": ' + CONVERT(VARCHAR(10), ISNULL(@cd_terminal, 0)) + ',            
       "cd_abertura_caixa": null,            
       "dt_abertura_caixa": null,            
       "hr_abertura_caixa": null,            
       "dt_ultimo_fechamento": null,            
       "cd_operador_caixa": ' + CONVERT(VARCHAR(10), ISNULL(@cd_operador_caixa, 0)) + ',            
       "cd_movimento_caixa": null,            
       "vl_abertura_caixa": 0,            
       "vl_ultimo_fechamento": null,            
       "vl_dinheiro_fechamento": null,            
       "nm_obs_abertura_caixa": "Abertura do Caixa",            
       "Status": "Disponível"            
    }]'            
                
    EXEC pr_egisnet_controle_caixa @json_abertura         
  end          
end            
---------------------------------------------------------------------------------------------------------------------------------------------        
          
IF @cd_parametro = 102          
BEGIN           
 if exists(select          
             cd_movimento_caixa          
           from           
             Movimento_Caixa           
           where           
             cd_movimento_caixa = @cd_movimento_caixa          
             and          
             cd_tipo_pagamento = 1)          
 begin          
   update Movimento_Caixa          
   set vl_troco = @vl_troco,          
       vl_dinheiro = vl_movimento_caixa+@vl_troco          
   where           
     cd_movimento_caixa = @cd_movimento_caixa          
     and          
     cd_tipo_pagamento = 1          
 end          
          
 -- Status do Servidor NFe                        
 SELECT TOP 1 @ic_status_servidor_nfe = ISNULL(ic_ativo, 'N')                         
 FROM egisadmin.dbo.NFe_Empresa                         
 WHERE cd_empresa = @cd_empresa;           
           
 --Link NFE             
 select          
   @base_url = case when isnull(nm_link_nfe_local,'')<>'' then nm_link_nfe_local else nm_link_nfe end          
 from          
   config_egismob           
 where          
   cd_empresa = @cd_empresa          
                        
 if exists(select top 1 cd_nota_saida from nota_saida where isnull(vl_total,0) = 0)          
 begin          
   delete from          
     Nota_Validacao          
   where          
     cd_nota_saida in (select cd_nota_saida from nota_saida where isnull(vl_total,0) = 0)          
 end          
          
 IF EXISTS (SELECT 1 FROM Movimento_Caixa WHERE cd_movimento_caixa = @cd_movimento_caixa AND cd_nota_saida IS NOT NULL)                        
 BEGIN                        
                        
                        
  SELECT @cd_nota_saida = cd_nota_saida                         
  FROM Movimento_Caixa                         
  WHERE cd_movimento_caixa = @cd_movimento_caixa;                        
                        
  SELECT                 
   n.cd_nota_saida,                        
   s.ic_nfe_serie_nota,                        
   n.cd_chave_acesso,                        
   nv.ic_validada,                        
   CASE                         
    WHEN ISNULL(n.cd_chave_acesso, '') = ''                         
     OR ISNULL(s.ic_nfe_serie_nota, 'N') = 'N'                         
     OR ISNULL(nv.ic_validada, 'N') = 'N'                        
    THEN ''                        
   ELSE                         
    @nm_nfe_link + REPLACE(n.cd_chave_acesso, 'NFe', '') + '?banco=' + ISNULL(@nm_basesql, '')                        
   END AS nm_nfe_link,                        
   -- STATUS BASEADO NA NOTA_VALIDAÇÃO                        
   CASE                         
    WHEN s.cd_ambiente_nfe = 1 THEN 49  -- Homologação                        
    WHEN ISNULL(@ic_status_servidor_nfe, 'N') = 'S' AND nv.ic_validada = 'N' THEN 62  -- Aguardando validação                        
    WHEN ISNULL(@ic_status_servidor_nfe, 'N') <> 'S' AND nv.ic_validada <> 'S' THEN 61  -- Servidor offline                        
    ELSE 48  -- Validada com sucesso (quando nv.ic_validada = 'S')                        
   END AS cd_status_validacao,                        
   -- STATUS DIRETO DA NOTA_VALIDAÇÃO (se existir na tabela)                        
   CASE                         
    WHEN EXISTS (SELECT 1 FROM Nota_Saida_Rejeicao WHERE cd_nota_saida = n.cd_nota_saida) THEN 3  -- Rejeitada                        
    ELSE nv.cd_status_validacao                         
   END AS status_direto_validacao,          
   case when isnull(@base_url,'') = '' then 'https://egiserp.com.br/api/nfe/nfce/danfe/' else @base_url end as base_url          
  FROM Nota_Saida n                        
  INNER JOIN serie_nota_fiscal s ON s.cd_serie_nota_fiscal = n.cd_serie_nota                         
  LEFT JOIN Nota_Validação nv ON nv.cd_nota_saida = n.cd_nota_saida                        
  WHERE n.cd_nota_saida = @cd_nota_saida                        
  AND ISNULL(s.ic_nfe_serie_nota, 'N') = 'S';                        
 END           
end          
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 150 - Consulta da Divisão de Caixa                       
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 150           
begin          
  select          
    mc.cd_movimento_caixa,          
    d.cd_item_divisao,          
    d.cd_tipo_pagamento,          
    d.vl_pagamento,          
    d.nm_obs_divisao,          
    isnull(d.ic_finalizado,'N') as ic_finalizado,
    tp.nm_tipo_pagamento          
  from          
    movimento_caixa mc          
    inner join movimento_caixa_divisao d on d.cd_movimento_caixa = mc.cd_movimento_caixa          
    inner join tipo_pagamento_caixa tp   on tp.cd_tipo_pagamento = d.cd_tipo_pagamento          
  where          
    mc.cd_movimento_caixa = @cd_movimento_caixa          
end          
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 160 - Crud da Divisão                       
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 160           
begin      
  select top 1 cd_movimento_caixa from Movimento_Caixa_Divisao           
  where cd_movimento_caixa = @cd_movimento_caixa and cd_item_divisao = @cd_item_divisao

  if exists(select top 1 cd_movimento_caixa from Movimento_Caixa_Divisao           
            where cd_movimento_caixa = @cd_movimento_caixa and cd_item_divisao = @cd_item_divisao)          
  begin          
    update Movimento_Caixa_Divisao          
    set          
      cd_tipo_pagamento = @cd_tipo_pagamento_tab,          
      vl_pagamento = @vl_pagamento,          
      nm_obs_divisao = @nm_obs_divisao,          
      cd_usuario = @cd_usuario,          
      dt_usuario = @dt_hoje          
    where          
      cd_movimento_caixa = @cd_movimento_caixa           
      and          
      cd_item_divisao = @cd_item_divisao          
  end          
  else          
  begin          
    select @cd_item_divisao = max(isnull(cd_item_divisao,0))+1          
    from Movimento_Caixa_Divisao          
    where cd_movimento_caixa = @cd_movimento_caixa          
          
    if @cd_item_divisao is null or isnull(@cd_item_divisao,0) = 0          
      set @cd_item_divisao = 1          
          
    Insert Into Movimento_Caixa_Divisao          
    (cd_movimento_caixa, cd_item_divisao, cd_tipo_pagamento,          
     vl_pagamento, nm_obs_divisao, cd_usuario, dt_usuario)          
    Values          
    (@cd_movimento_caixa, @cd_item_divisao, @cd_tipo_pagamento_tab,           
     @vl_pagamento, @nm_obs_divisao, @cd_usuario, @dt_hoje)          
  end          
end    
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 161 - Exclusão da Divisão                       
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 161           
begin      
  delete from Movimento_Caixa_Divisao           
  where cd_movimento_caixa = @cd_movimento_caixa
        and
        isnull(ic_finalizado,'N') = 'N'
end
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 162 - Atualização da Divisão                       
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 162
begin      
    if @cd_tipo_pagamento <> 1        
    begin        
      if isnull(@cd_nsu_tef,'') = ''        
        set @cd_maquina_cartao = 2        
      else        
        set @cd_maquina_cartao = 1        
    end 

      select 
        @cd_bandeira_cartao = cd_bandeira_cartao,
        @pc_taxa_bandeira = case when @cd_tipo_pagamento in (4,9)
                              then isnull(pc_taxa_bandeira,0)
                              else case when @cd_tipo_pagamento = 3
                                     then isnull(pc_taxa_antecipacao,0)
                                     else 0
                                   end
                            end
      from
        Bandeira_Cartao
      where
        ltrim(rtrim(@nm_bandeira_cartao)) like '%'+nm_bandeira_cartao+'%'

      if @cd_tipo_pagamento = 8 --PIX
      begin
        select 
          @pc_taxa_bandeira = isnull(pc_taxa_pix,0)
        from
          Config_Terminal_Venda

        set @cd_nsu_tef         = @cd_nsu_tef_pix
        set @cd_autorizacao_tef = @cd_autorizacao_tef_pix
      end

      if isnull(@pc_taxa_bandeira,0) > 0
      begin
        select 
          @vl_taxa_pagamento = round((vl_pagamento*@pc_taxa_bandeira)/100,2)
        from
          Movimento_Caixa_Divisao
        where
          cd_movimento_caixa = @cd_movimento_caixa 
          and
          cd_item_divisao = @cd_item_divisao

        if @cd_tipo_pagamento = 8 --PIX
        begin
          if @vl_taxa_pagamento < 0.12
            set @vl_taxa_pagamento = 0.12
        end
      end

    if not exists(select top 1 cd_movimento_caixa from Movimento_Caixa_Bandeira 
                  where cd_movimento_caixa = @cd_movimento_caixa and cd_item_divisao = @cd_item_divisao)
    begin
      INSERT INTO MOVIMENTO_CAIXA_BANDEIRA (
       cd_movimento_caixa,
       cd_item_divisao,
       nm_bandeira_cartao,
       cd_bandeira_cartao)
      VALUES (
       @cd_movimento_caixa,
       @cd_item_divisao,
       @nm_bandeira_cartao,
       @cd_bandeira_cartao)
    end
    else
    begin
      UPDATE MOVIMENTO_CAIXA_BANDEIRA
      set 
        nm_bandeira_cartao = @nm_bandeira_cartao,
        cd_bandeira_cartao = @cd_bandeira_cartao
      where
        cd_movimento_caixa = @cd_movimento_caixa 
        and 
        cd_item_divisao = @cd_item_divisao
    end

    update Movimento_Caixa_Divisao
    set
      cd_usuario = @cd_usuario,
      dt_usuario = @dt_hoje,
      cd_bandeira_cartao = @cd_bandeira_cartao,
      cd_maquina_cartao = @cd_maquina_cartao,
      cd_nsu_tef = @cd_nsu_tef,
      cd_autorizacao_tef = @cd_autorizacao_tef,
      vl_taxa_pagamento = @vl_taxa_pagamento,
      ic_finalizado = @ic_finalizado_divisao,
      vl_troco = @vl_troco
    where
      cd_movimento_caixa = @cd_movimento_caixa
      and
      cd_item_divisao = @cd_item_divisao

    select 'Movimento Divisão Alterado com Sucesso!' as Msg
end
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
-- 170 - Lookup Tipo de Pagamento                       
---------------------------------------------------------------------------------------------------------------------------------------------------------                            
if @cd_parametro = 170           
begin          
  select          
    cd_tipo_pagamento,          
    nm_tipo_pagamento,          
    ic_tipo,          
    ic_baixa_autom_cta_receb,          
    cd_plano_financeiro,          
    cd_portador,          
    cd_tipo_pagamento_cupom,          
    qt_dia_vcto_cartao_credito,          
    pc_adm_cartao_credito,          
    ic_padrao_tipo_pagamento,          
    cd_identificacao_pagamento,          
    qt_ordem_caixa,          
    ic_ativo_caixa,          
    pc_desconto          
  from          
    Tipo_Pagamento_Caixa
  where 
    cd_tipo_pagamento in (1,3,4,6,8)
end 


go

--update
--  egisadmin.dbo.meta_procedure_colunas
--set
--  ativo = 1,
--  agrupador_base = 1
--where
--  nome_procedure = 'pr_monitor_egis_informacao'
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_gca_processo_modulo
------------------------------------------------------------------------------
/*
exec pr_egis_gca_processo_modulo
'[{
    "cd_usuario": 5004,
    "cd_parametro": 17,
    "nm_fantasia_cliente": "veneto",
    "appVersion": "1.0.88",
    "appName": "EgisApp"
}]'
*/

/*
exec pr_egis_gca_processo_modulo
'[{
    "cd_usuario": 4915,
    "cd_parametro": 18,
    "nm_fantasia_cliente": "teste",
    "dt_nascimento_cliente": "2000-11-01",
    "cd_ddd_cliente": "11",
    "cd_celular_cliente": "995651245",
    "cpf": "12345678998",
    "nm_email_cliente": "teste@gmail.com",
    "appVersion": "1.0.88",
    "appName": "EgisApp"
}]'

exec pr_egis_gca_processo_modulo
'[{
        "cd_usuario": 4915,
        "cd_parametro": 18,
        "nm_fantasia_cliente": "teste 3",
        "dt_nascimento_cliente": "1998-01-05",
        "cd_ddd_cliente": "11",
        "cd_celular_cliente": "99273",
        "cpf": "45698778998",
        "nm_email_cliente": "novo@gmail.com",
        "appVersion": "1.0.88",
        "appName": "EgisApp"
    }]'


	select * from cliente

	select cd_cliente, * from nota_saida
*/
------------------------------------------------------------------------------