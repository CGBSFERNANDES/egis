IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_processo_validacao_entrada_comercial' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_processo_validacao_entrada_comercial

GO

-------------------------------------------------------------------------------
--sp_helptext pr_processo_validacao_entrada_comercial
-------------------------------------------------------------------------------
--pr_processo_validacao_entrada_comercial
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Processo de Entrada de Validação do Comercial
--
--Data             : 03.06.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_processo_validacao_entrada_comercial
--@json nvarchar(max) = ''
@json varchar(8000) = ''

--with encryption


as


declare @dt_hoje datetime  
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)         
  
if @json= '' 
begin  
  select 'Parâmetros inválidos !' as Msg  
  return  
end  

set @json = replace(@json,'''','')
----------------------------------------------------------------------------------------------------------    

select                 
identity(int,1,1)             as id,                 
    valores.[key]             as campo,                 
    valores.[value]           as valor                
into #json                
from                 
   openjson(@json)root                
   cross apply openjson(root.value) as valores 	

----------------------------------------------------------------------------------------------------------    

--Declare--

----------------------------------------------------------------------------------------------------------    

declare @cd_parametro    int = 0
declare @cd_usuario      int = 0
declare @dt_inicial      datetime
declare @dt_final        datetime
declare @cd_vendedor     int = 0
declare @cd_cliente      int = 0
declare @cd_veiculo      int = 0
declare @cd_motorista    int = 0
declare @cd_entregador   int = 0
declare @cd_pedido_venda int = 0
declare @ds_observacao   varchar(8000) = '' --nvarchar(max) = ''
declare @cd_ano          int = 0
declare @cd_mes          int = 0
declare @cd_empresa      int = 0
declare @cd_consulta     int = 0

----------------------------------------------------------------------------------------------------------    
set @cd_empresa = dbo.fn_empresa()
----------------------------------------------------------------------------------------------------------
select @cd_parametro	        = valor from #json  with(nolock) where campo = 'cd_parametro' 
select @cd_usuario   		    = valor from #json  with(nolock) where campo = 'cd_usuario'
select @dt_inicial   		    = valor from #json  with(nolock) where campo = 'dt_inicial'
select @dt_final   		        = valor from #json  with(nolock) where campo = 'dt_final'
select @cd_consulta   		    = valor from #json  with(nolock) where campo = 'cd_consulta'
----------------------------------------------------------------------------------------------------------


set @cd_ano = year(getdate())
set @cd_mes = month(getdate())

  
  --Início do Período

  if @dt_inicial is null or @dt_inicial = '' or isnull(@dt_inicial,'') = ''
    set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)  

	--Final do Periodo
  if @dt_final is null or @dt_final = '' or isnull(@dt_final,'') = ''
	set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano) 

----------------------------------------------------------------------------------------------------------    
--Dados das Propostas em Aberto
----------------------------------------------------------------------------------------------------------    

--Geração da Fila-----------------------------------------------------------------------------

if @cd_parametro = 0
begin

  --Fila_Validacao_Proposta

  select
    c.cd_consulta,
	max(cast(0 as int ))           as cd_status_validacao,
    max(@cd_usuario)               as cd_usuario_inclusao,
    max(getdate())                 as dt_usuario_inclusao,
    max(@cd_usuario)               as cd_usuario,
    max(getdate())                 as dt_usuario,
	max(cast('' as varchar(8000))) as ds_validacao

	into #Fila_Validacao_Proposta
	from
	  Consulta c
      inner join consulta_itens i on i.cd_consulta  = c.cd_consulta
	  
	  
    where
	  c.dt_consulta between @dt_inicial and @dt_final
	  and
	  isnull(i.cd_pedido_venda,0) = 0
	  and
	  i.dt_perda_consulta_itens is null
	  and
	  c.cd_consulta not in ( select f.cd_consulta from Fila_Validacao_Proposta f where f.cd_consulta = c.cd_consulta )

   group by
     c.cd_consulta

   order by
      c.cd_consulta desc

   insert into Fila_Validacao_Proposta
   select * from #Fila_Validacao_Proposta

   select * from Fila_Validacao_Proposta order by dt_usuario 

   drop table #Fila_Validacao_Proposta

   return
  


end

----------------------------------------------------------------------------------------
if @cd_parametro = 1  
begin

  select
    c.cd_consulta,
	max(c.dt_consulta)             as dt_consulta,
	max(c.cd_cliente)              as cd_cliente,
	max(c.cd_vendedor)             as cd_vendedor,
	max(c.cd_transportadora)       as cd_transportadora,
	max(c.cd_condicao_pagamento)   as cd_condicao_pagamento,
	max(c.vl_total_consulta)       as vl_total_consulta,
	max(c.vl_frete_consulta)       as vl_frete_consulta,
	max(c.cd_tipo_proposta)        as cd_tipo_proposta

	from
	  Consulta c
      inner join consulta_itens i          on i.cd_consulta  = c.cd_consulta
	  inner join Cliente cli               on cli.cd_cliente = c.cd_cliente
	  inner join Fila_Validacao_Proposta f on f.cd_consulta  = c.cd_consulta

    where
	  c.dt_consulta between @dt_inicial and @dt_final
	  and
	  isnull(i.cd_pedido_venda,0) = 0
	  and
	  i.dt_perda_consulta_itens is null
	  and
	  ISNULL(f.cd_status_validacao,0) = 0

   group by
     c.cd_consulta

   order by
      c.cd_consulta desc


  return

end

--Validação da Proposta-----------------------------------------------------------------

IF @cd_parametro = 10
BEGIN

    DECLARE @json_parametros varchar(8000) = @json;

    -- Loop ou OPENJSON para processar cada item

    SELECT * INTO #temp
    FROM OPENJSON(@json)
    WITH (
        cd_consulta INT '$.cd_consulta'
    );

	select * into #Tipo_Validacao from Tipo_Validacao

	declare @cd_tipo_validacao         int
	declare @ds_validacao              varchar(8000) = '' --nvarchar(max) = ''
	declare @nm_razao_social           varchar(60)   = ''
	declare @cd_cep                    int           = 0
	--declare @cd_vendedor             int           = 0
	declare @cd_vendedor_interno       int           = 0
	declare @cd_transportadora         int           = 0
	declare @cd_tipo_pagamento_frete   int
	declare @cd_cnpj_cliente           varchar(18)   = ''
	declare @cd_inscestadual           varchar(18)   = ''
	declare @nm_tipo_inscricao         varchar(50)   = ''
	declare @cnpj_valido               int           = 0
  	declare @cd_condicao_pagamento     int = 0
	declare @cd_tipo_pedido            int = 0
	declare @cd_tipo_proposta          int = 0
	declare @cd_tabela_preco           int = 0
	declare @cd_estado                 int = 0
	declare @cd_cidade                 int = 0
	declare @cd_empresa_fat            int = 0
	declare @nm_tabela_preco           varchar(80) = ''
	declare @nm_tipo_pedido            varchar(80) = ''
	declare @ic_tabela_preco           char(1)     = ''
	declare @dt_pedido_venda           datetime    
	declare @nm_validacao              varchar(100) = ''
	declare @cd_tipo_pessoa            int          = 0
	declare @nm_endereco               varchar(60)  = ''
	declare @nm_bairro                 varchar(25)  = ''
	declare @cd_cidade_ibge            varchar(25)  = ''
	declare @cd_numero                 varchar(10)  = ''
	declare @cd_portador               int          = 0
	declare @cd_conta_banco            int          = 0
	declare @cd_conta_banco_inf        int          = 0
	declare @cd_pais                   int          = 0
	declare @cd_status_validacao       int          = 1
	declare @cd_forma_pagamento        int          = 0
	declare @qt_parcela                int          = 0
	declare @qt_parcela_condicao       int          = 0
    declare @cd_telefone               varchar(15)  = ''
	declare @ic_boleto_forma_pagamento char(1)      = 'N'
	declare @ic_roteiro_retira         char(1)      = 'N'
	declare @cd_transp_fechamento      int          = 0
	declare @ic_rastreamento           char(1)      = 'N'

	select
	  top 1
	  @cd_transp_fechamento = isnull(cd_transp_fechamento,0)
    from
	  Parametro_Cadastro
    where
	  isnull(cd_transp_fechamento,0)>0

	  --select cd_transp_fechamento, * from Parametro_Cadastro

    --Consulta--

	--declare @cd_tipo_pedido          int          = 0

	--declare @cd_estado               int          = 0
	--declare @cd_cidade               int          = 0
	
	-----------------------------------------------Dados da Proposta------------------------------------------------------------
	--consulta --use egissql_rubio

	select
      top 1
	  @nm_razao_social           = cli.nm_razao_social_cliente,
	  @cd_cep                    = cli.cd_cep,
	  @cd_vendedor               = c.cd_vendedor,
	  @cd_vendedor_interno       = c.cd_vendedor_interno,
	  @cd_transportadora         = c.cd_transportadora,
	  @cd_cnpj_cliente           = cli.cd_cnpj_cliente,
	  @cd_inscestadual           = cli.cd_inscestadual,
	  @cnpj_valido               =
	  case when cli.cd_tipo_pessoa=1 then 
	   dbo.fn_valida_cnpj_retorno(cli.cd_cnpj_cliente) --select dbo.fn_valida_cnpj_retorno('04602326000140')
	  else 
	   9
	  end,
	  @cd_condicao_pagamento     = isnull(c.cd_condicao_pagamento,0),
	  @cd_tipo_proposta          = isnull(c.cd_tipo_proposta,0),
	  @cd_tipo_pedido            = case when isnull(tp.cd_tipo_pedido,0)>0 then tp.cd_tipo_pedido else isnull(cli.cd_tipo_pedido,0) end,
	  @cd_tabela_preco           = isnull(cli.cd_tabela_preco,0),	  
	  @ds_validacao              = '',
	  @nm_tabela_preco           = tap.nm_tabela_preco,
	  @nm_tipo_pedido            = tp.nm_tipo_proposta,	
	  @cd_tipo_pessoa            = isnull(cli.cd_tipo_pessoa,''),
	  @nm_endereco               = isnull(cli.nm_endereco_cliente,''),
	  @cd_numero                 = isnull(cli.cd_numero_endereco,''),
	  @nm_bairro                 = isnull(cli.nm_bairro,''),
	  @cd_cidade                 = isnull(cli.cd_cidade,0),
	  @cd_estado                 = isnull(cli.cd_estado,0),
	  @cd_pais                   = isnull(cli.cd_pais,0),
	  @cd_conta_banco            = case when isnull(ce.cd_conta_banco,0)>0 then ce.cd_conta_banco else ISNULL(i.cd_conta_banco,0) end,
	  @cd_conta_banco_inf        = isnull(i.cd_conta_banco,0),    
	  @cd_portador               = isnull(i.cd_portador,0),
	  @cd_forma_pagamento        = isnull(c.cd_forma_pagamento,0),
	  @cd_telefone               = isnull(cli.cd_telefone,0),
	  @ic_boleto_forma_pagamento = isnull(ic_boleto_forma_pagamento,'N'),
	  @ic_roteiro_retira         = isnull(t.ic_roteiro_retira,'N'),
	  @ic_rastreamento           = ISNULL(t.ic_rastreamento,'N')
	  
	from
	  Consulta c
	  inner join Cliente cli                       on cli.cd_cliente        = c.cd_cliente
	  left outer join cliente_empresa ce           on ce.cd_cliente         = c.cd_cliente
	  LEFT outer join Cliente_Informacao_Credito i on i.cd_cliente          = c.cd_cliente
	  left outer join Consulta_Empresa coe         on coe.cd_consulta       = c.cd_consulta
	  left outer join Tipo_Proposta tp             on tp.cd_tipo_proposta   = c.cd_tipo_proposta
	  left outer join Tabela_Preco tap             on tap.cd_tabela_preco   = c.cd_tabela_preco
	  left outer join Forma_Pagamento fp           on fp.cd_forma_pagamento = c.cd_forma_pagamento  --case when isnull(c.cd_forma_pagamento,0)>0 then c.cd_forma_pagamento else i.cd_forma_pagamento end
	  left outer join Transportadora t             on t.cd_transportadora   = c.cd_transportadora

    where
	  c.cd_consulta = @cd_consulta
	  	   
	while exists ( select top 1 cd_tipo_validacao from #Tipo_Validacao )
	begin

	  select top 1
	    @cd_tipo_validacao = ISNULL(cd_tipo_validacao,0)
	  from
	    #Tipo_Validacao
	  order by
	    cd_tipo_validacao

		--------------------------------
		--set @cd_vendedor = 0
		--set @cd_telefone = ''
		--set @cd_condicao_pagamento = 0
		--set @cd_forma_pagamento = 0
		--set @cd_transportadora = 0
		-------------------------------

		--CNPJ--
		if @cd_tipo_validacao = 1 and @cd_tipo_pessoa = 1 and ( @cnpj_valido <> 1 or @cd_cnpj_cliente = '' )
		begin
	      set @ds_validacao = @ds_validacao + ' CNPJ do Cliente Inválido '
	      set @cd_status_validacao = 0
		end

		--IE--

		if @cd_tipo_validacao = 2 and @cd_tipo_pessoa = 1 and ( @cd_inscestadual = '' )
		begin
	      set @ds_validacao = @ds_validacao + ' Inscrição do Cliente Inválida '
	      set @cd_status_validacao = 0
		end

		if @cd_tipo_validacao = 3 and (@nm_endereco='' or @nm_bairro='' or @cd_numero = '' or LEN(@nm_bairro)<2 )
		begin
	      set @ds_validacao = @ds_validacao + ' Endereço do Cliente Inválido, verificar --> Endereço, Bairro, Número ! '
	      set @cd_status_validacao = 0

		end

		if @cd_tipo_validacao = 3 and ( @cd_cidade = 0 or @cd_estado=0 )
		begin
		  set @ds_validacao = @ds_validacao + ' Falta o Cadastro da Cidade e Estado do Cliente ! '
	      set @cd_status_validacao = 0
		end

		--Vendedor--

		if @cd_tipo_validacao = 4 and ( @cd_vendedor = 0 OR @cd_vendedor_interno = 0 )
		begin
		  set @ds_validacao         = @ds_validacao + ' Vendedor Inválido, verificar --> Interno e Externo '
	      set @cd_status_validacao = 0

		end

		--Transportadora--
		if @cd_tipo_validacao = 5 and @cd_transportadora = 0
		begin
	      set @ds_validacao = @ds_validacao + ' falta a transportadora '
	      set @cd_status_validacao = 0

		end
	
	    --select * from transportadora where cd_transportadora = 180

	    if @cd_tipo_validacao = 5 and @cd_transportadora>0 and @cd_transp_fechamento>0 and @cd_transp_fechamento=@cd_transportadora
		begin
	      set @ds_validacao        = @ds_validacao + ' seleciontar uma transportadora válida : '+CAST(@cd_transp_fechamento as varchar(10))
	      set @cd_status_validacao = 0
		end

		--Tipo de Pagamento de Frete---

		if @cd_tipo_validacao = 6 and @cd_tipo_pagamento_frete = 0 
		begin
	      set @ds_validacao        = @ds_validacao + ' falta a tipo de pagamento de frete !'
	      set @cd_status_validacao = 0
		end
		
		--Tipo de Pedido--

		if @cd_tipo_validacao = 7 and @cd_tipo_pedido = 0
		begin
	      set @ds_validacao        = @ds_validacao + ' sem definição do Tipo de Pedido !'
	      set @cd_status_validacao = 0
		end


		if @cd_tipo_validacao = 8 and 1=2
		begin
	      set @ds_validacao        = @ds_validacao + ' Empresa Faturamento '
	      set @cd_status_validacao = 0		    
		end

		if @cd_tipo_validacao = 9 and @cd_conta_banco = 0 and @cd_condicao_pagamento>0 and @ic_boleto_forma_pagamento='S'
		begin
	      set @ds_validacao        = @ds_validacao + ' Cliente sem Conta Bancária para Geração do Boleto !'
	      set @cd_status_validacao = 0		    
		end

		if @cd_tipo_validacao = 10 and @cd_portador = 0 and @cd_condicao_pagamento>0 and @ic_boleto_forma_pagamento='S'
		begin
	      set @ds_validacao        = @ds_validacao + ' Portador '
	      set @cd_status_validacao = 0		    
		end

		--Sem definição da Condição de Pagamento

		if @cd_tipo_validacao = 11 
		begin   

		  if @cd_condicao_pagamento = 0
		  begin
	        set @ds_validacao        = @ds_validacao + ' Falta a Condição de Pagamento !'
	        set @cd_status_validacao = 0
		  end
        
		set @qt_parcela = 0
		  
		  select @qt_parcela = ISNULL(qt_parcela_condicao_pgto,0)
		  from
		    Condicao_Pagamento
          where
		    cd_condicao_pagamento = @cd_condicao_pagamento

          if @qt_parcela = 0
		  begin
	        set @ds_validacao        = @ds_validacao + ' Falta a quantidade de parcela na Condição de Pagamento !'
	        set @cd_status_validacao = 0		    
		  end

		  select @qt_parcela_condicao = COUNT(cpp.cd_condicao_pagamento)
		  from
		    condicao_pagamento_parcela cpp
		  where
		    cd_condicao_pagamento = @cd_condicao_pagamento

		  --Verifica se a condição de pagamento tem parcela

          if @qt_parcela<>@qt_parcela_condicao
		  begin
	        set @ds_validacao        = @ds_validacao + ' quantidade de parcela(s) na Condição de Pagamento Inválida !'
	        set @cd_status_validacao = 0		    
		  end
  
        end

		--Telefone

		if @cd_tipo_validacao = 12 and @cd_telefone = ''
		begin
	      set @ds_validacao        = @ds_validacao + ' Falta Telefone do Cliente ou Contato !'
	      set @cd_status_validacao = 0		    
		end

		--Método de Entrega

		if @cd_tipo_validacao = 13 and 1=2
		begin
	      set @ds_validacao        = @ds_validacao + ' Método de Entrega'
	      set @cd_status_validacao = 0		    
		end

		if @cd_tipo_validacao = 14 and @cd_forma_pagamento = 0
		begin
	      set @ds_validacao        = @ds_validacao + ' Forma de Pagamento'
	      set @cd_status_validacao = 0		    
		end

		--Valor do Frete <> Retira e Transportadora e tem que ser Correio ou Motoboy - Entrega

		if @cd_tipo_validacao = 15 and 1=2 
		begin
	      set @ds_validacao        = @ds_validacao + ' Valor do Frete'
	      set @cd_status_validacao = 0		    
		end

		if @cd_tipo_validacao = 16 and 1=2
		begin
	      set @ds_validacao        = @ds_validacao + ' Observações de Faturamento'
	      set @cd_status_validacao = 0		    
		end

		if @cd_tipo_validacao = 17 and 1=2
		begin
	      set @ds_validacao        = @ds_validacao + ' PIX'
	      set @cd_status_validacao = 0		    
		end

		--Estoque dos Itens

		if @cd_tipo_validacao = 18 and 1=2
		begin
	      set @ds_validacao        = @ds_validacao + ' Estoque '
	      set @cd_status_validacao = 0		    
		end

		--Estoque dos Itens

		if @cd_tipo_validacao = 19 and 1=2
		begin
	      set @ds_validacao        = @ds_validacao + ' Entrega Parcial '
	      set @cd_status_validacao = 0		    
		end

		if @cd_tipo_validacao = 20 and 1=2
		begin
	      set @ds_validacao        = @ds_validacao + ' Destinação do Produto '
	      set @cd_status_validacao = 0		    
		end


		--Razão Social---

      	if @cd_tipo_validacao = 21 and @nm_razao_social = ''
	    begin
	      set @ds_validacao = @ds_validacao + ' falta a razão social '
	      set @cd_status_validacao = 0
	   end



      --

      delete from #Tipo_Validacao
	  where
	    cd_tipo_validacao = @cd_tipo_validacao

   end




    -- Exemplo de regra: validar se proposta existe e está apta

    UPDATE F
    SET
        F.cd_status_validacao = @cd_status_validacao,
        F.cd_usuario          = @cd_usuario,
        F.dt_usuario          = GETDATE(),
		f.ds_validacao        = @ds_validacao
    FROM Fila_Validacao_Proposta F
    JOIN #temp T ON T.cd_consulta = F.cd_consulta
    WHERE F.cd_status_validacao = 0;

    -- Retorno

    SELECT
        cd_consulta                       AS cd_consulta,
		@cd_status_validacao              as cd_status_validacao,
		case when @cd_status_validacao = 1 then
          'Validação concluída com sucesso !' 
		else
		  'Proposta com Restrição de Fechamento, por favor, verifique a ocorrência no relatório !'
        
		end  AS msg,

		@ds_validacao  as ds_log_validacao

    FROM Fila_Validacao_Proposta
    WHERE cd_consulta IN (SELECT cd_consulta FROM #temp);

END




go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_processo_validacao_entrada_comercial
------------------------------------------------------------------------------
--go
--select * from tipo_validacao

--Fila
--exec pr_processo_validacao_entrada_comercial '[{"cd_parametro": 0,"cd_usuario": 1,"dt_inicial"  : "06/01/2025","dt_final"    : "06/30/2025"}]'
--go

--Propostas para Validação
--exec pr_processo_validacao_entrada_comercial '[{"cd_parametro": 1,"cd_usuario": 1,"dt_inicial"  : "06/01/2025","dt_final"    : "06/30/2025"}]'


--Validação da Proposta 
--exec pr_processo_validacao_entrada_comercial '[{"cd_parametro": 10,"cd_consulta": 98903, "cd_usuario": 1}]'
-------------------------------------------------------------------------------------------------------
--select * from Fila_Validacao_Proposta where cd_consulta = 98903


--Dados para o Relatório
--'[{"cd_empresa" = 96, "cd_relatorio": 335,"cd_consulta": 98903, "cd_usuario": 1}]'
go

--pr_egis_relatorio_validacao_proposta



