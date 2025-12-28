IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_processo_logistica_entregas' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_processo_logistica_entregas

GO

-------------------------------------------------------------------------------
--sp_helptext pr_processo_logistica_entregas
-------------------------------------------------------------------------------
--pr_processo_logistica_entregas
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
create procedure pr_processo_logistica_entregas
--@json nvarchar(max) = ''
@json varchar(8000) = ''

--with encryption


as

set dateformat 'MDY'

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
--select @dt_inicial = try_convert(datetime, valor, 103) from #json where campo = 'dt_inicial'
--select @dt_final   = try_convert(datetime, valor, 103) from #json where campo = 'dt_final'

--select @dt_inicial, @dt_final


set @cd_ano = year(getdate())
set @cd_mes = month(getdate())

  
  --Início do Período

  if @dt_inicial is null or @dt_inicial = '' or isnull(@dt_inicial,'') = ''
    set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)  

	--Final do Periodo
  if @dt_final is null or @dt_final = '' or isnull(@dt_final,'') = ''
	set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano) 

----------------------------------------------------------------------------------------------------------    
--Dados da empresa
----------------------------------------------------------------------------------------------------------    

declare
            @titulo                     varchar(200),
		    @logo                       varchar(400),			
			@nm_cor_empresa             varchar(20),
			@nm_endereco_empresa  	    varchar(200) = '',
			@cd_telefone_empresa    	varchar(200) = '',
			@nm_email_internet		    varchar(200) = '',
			@nm_cidade				    varchar(200) = '',
			@sg_estado				    varchar(10)	 = '',
			@nm_fantasia_empresa	    varchar(200) = '',
			@numero					    int = 0,
			
			@cd_cep_empresa			    varchar(20) = '',			
	--		@nm_fantasia_cliente  	    varchar(200) = '',
--			@cd_cnpj_cliente		    varchar(30) = '',
	--		@nm_razao_social_cliente	varchar(200) = '',
		--	@nm_cidade_cliente			varchar(200) = '',
--			@sg_estado_cliente			varchar(5)	= '',
--			@cd_numero_endereco			varchar(20) = '',
--			@nm_condicao_pagamento		varchar(100) = '',
--			@ds_relatorio				varchar(8000) = '',
	--		@subtitulo					varchar(40)   = '',
			--@footerTitle				varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = ''


	select 
		@logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
		@nm_cor_empresa		   	    = isnull(e.nm_cor_empresa,'#1976D2'),
		@nm_endereco_empresa 	    = isnull(e.nm_endereco_empresa,''),
		@cd_telefone_empresa	    = isnull(e.cd_telefone_empresa,''),
		@nm_email_internet	  	    = isnull(e.nm_email_internet,''),
		@nm_cidade			    	= isnull(c.nm_cidade,''),
		@sg_estado				    = isnull(es.sg_estado,''),
		@nm_fantasia_empresa	    = isnull(e.nm_fantasia_empresa,''),
		@cd_cep_empresa			    = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),
		@cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),
		@nm_pais					= ltrim(rtrim(isnull(p.sg_pais,''))),
		@cd_cnpj_empresa			= dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),
		@cd_inscestadual_empresa	=  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),
		@nm_dominio_internet		=  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))
			   
	from egisadmin.dbo.empresa e	with(nolock)
	left outer join Estado es		with(nolock) on es.cd_estado = e.cd_estado
	left outer join Cidade c		with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado
	left outer join Pais p			with(nolock) on p.cd_pais = e.cd_pais
	where 
		cd_empresa = @cd_empresa



--Geração da Agenda-----------------------------------------------------------------------------

if @cd_parametro = 0 or @cd_parametro = 1
begin

   declare @qt_horario           int      = 0
   declare @qt_veiculo           int      = 0
   declare @qt_motorista         int      = 0
   declare @qt_entrega           int      = 0
   declare @qt_cliente           int      = 0
   declare @qt_vendedor		     int      = 0
   declare @qt_produto			 int      = 0
   declare @cd_status_agenda	 int      = 1
   
   select
     top 1
     @qt_horario   = isnull(qt_horario,0),
     @qt_veiculo   = isnull(qt_veiculo,0),
     @qt_motorista = isnull(qt_motorista,0),
     @qt_entrega   = isnull(qt_entrega,0)
   from
     agenda_entrega_parametro
   
   --select @qt_veiculo

   --use egissql_247

   --insert into Agenda_Entrega_Parametro
   --select * from egissql_345.dbo.Agenda_Entrega_Parametro

     --insert into status_agenda
     --select * from egissql.dbo.status_agenda
     --select * from  tipo_horario
   
   --select @qt_horario, @qt_veiculo, @qt_motorista, @qt_entrega
   
   select 
     * 
   into 
     #tipo_horario
   from
     tipo_horario
   where
     isnull(ic_ativo_horario,'N')='S'
   
   
   --select * from #tipo_horario
   
   
   --agenda_entrega
   declare @dt_entrega datetime 
   
   set @dt_entrega = @dt_inicial
   
   while  @dt_entrega<=@dt_final
   begin
   
       declare @cd_agenda_entrega int = 0
   
       select 
         @cd_agenda_entrega = max(cd_agenda_entrega) 
       from
         Agenda_Entrega
       
       set @cd_agenda_entrega = ISNULL(@cd_agenda_entrega,0)
   
       select
         @cd_agenda_entrega   as cd_agenda_entrega,
         @dt_entrega          as dt_entrega,      
         @qt_entrega          as qt_entrega,
         @qt_motorista        as qt_motorista,
         @qt_veiculo          as qt_veiculo,
         @qt_cliente          as qt_cliente,
         @qt_vendedor         as qt_vendedor,
         @qt_produto          as qt_produto,
         @qt_horario          as qt_horario,
         @cd_status_agenda    as cd_status_agenda,
   	     CAST('' as varchar)  as ds_agenda,
   	     IDENTITY(int,1,1)    as cd_interface,
   	     @cd_usuario          as cd_usuario_inclusao,
         getdate()            as dt_usuario_inclusao,
         @cd_usuario          as cd_usuario,
         getdate()            as dt_usuario 
   
   
       into 
   	     #agenda_entrega
   

      --select @qt_veiculo

       update
   	     #agenda_entrega
   	   set 
	     cd_agenda_entrega = cd_agenda_entrega + cd_interface
   
       --Agenda Master------
	   --select * from Agenda_Entrega

   	   insert into Agenda_Entrega
   	   select ae.* from #agenda_entrega ae
	   where
	     ae.dt_entrega not in ( select e.dt_entrega from Agenda_Entrega e where e.dt_entrega = @dt_entrega and e.dt_entrega = ae.dt_entrega )
		 and
		 ae.dt_entrega is not null

       ----------------------------------

   	   drop table #agenda_entrega   
       
       set @dt_entrega = @dt_entrega + 1
   
   end
   
   --select * from Agenda_Entrega
   --select * from pedido_entrega order by dt_pedido_entrega desc
   
   --drop table #tipo_horario
   
   --Carteira de Pedidos-------------------------------------------------------------------

   select
    p.cd_pedido_entrega,
    p.dt_pedido_entrega,
    p.dt_entrega              as dt_entrega_agenda,
	p.hr_entrega,
    p.cd_cliente,
    p.vl_total_entrega    as vl_total_pedido,
	r.cd_veiculo,
	r.cd_entregador
   
   into
     #Carteira
   
   from
    
    pedido_entrega p
    inner join cliente c         on c.cd_cliente         = p.cd_cliente
	left outer join Romaneio r   on r.cd_romaneio        = p.cd_romaneio

    --select * from romaneio
	--select * from Agenda_Entrega_Composicao where cd_pedido_entrega = 23
	--select * from pedido_entrega where cd_pedido_entrega = 23

   where
     YEAR(p.dt_pedido_entrega)>=@cd_ano
	 and
     ISNULL(qt_entrega,0)>0
	 and
	 p.dt_pedido_entrega is not null
	 and
     p.cd_pedido_entrega not in ( select a.cd_pedido_entrega from Agenda_Entrega_Composicao a
                                where
   							      a.cd_pedido_entrega = p.cd_pedido_entrega
   							   )
   
     --and
     --p.dt_entrega between @dt_inicial and @dt_final
	 ------------------------------------------------------------------------------------
	 --> pedidos faturados não pode entrar
	 -------------------------------------
	 --Urgente

	 --select * from #Carteira where cd_pedido_entrega = 23


     --and
	 --p.cd_pedido_entrega = 34806
   
   --select * from #Carteira order by dt_pedido_entrega desc

   --delete from Agenda_Entrega
   --select * from Agenda_Entrega_Composicao where cd_pedido_entrega = 34806
   --select * from Agenda_Entrega order by dt_entrega desc

   ----> Falta gerar a Agenda Aqui-------
   -- Para cada pedido
   --1. Ver data desejada
   --2. Buscar horário mais apropriado (de acordo com hr_entrega ou mais vazio)
   --3. Ver se cabe mais uma entrega naquele horário (comparando com qt_veiculo)
   --4. Se sim, inserir na composição com:
   --    - cd_agenda_entrega (do dia)
   --    - cd_tipo_horario
   --    - cd_pedido_venda
   --    - motorista/veículo atribuídos
   -----------------------------------------------------------------------------------

   -- Trecho da procedure: Geração inteligente da agenda (cd_parametro = 0)

-- Loop por pedidos na #Carteira e alocação com base em horário e capacidade

-- Assumimos que a tabela #tipo_horario já está carregada com os horários ativos
-- E que a tabela #Carteira já está com os pedidos a agendar

--DECLARE @cd_agenda_entrega INT
DECLARE @cd_tipo_horario INT
DECLARE @hr_pedido varchar(8) = ''
DECLARE @hora_pedido TIME
DECLARE @ped_cursor CURSOR
DECLARE @cd_pedido INT, @dt_pedido DATETIME, @vl_total NUMERIC(18,2)


--select @qt_veiculo

SET @ped_cursor = CURSOR FOR
SELECT c.cd_pedido_entrega, c.dt_entrega_agenda, c.cd_cliente, c.vl_total_pedido, c.cd_veiculo, c.cd_entregador, c.hr_entrega
FROM #Carteira c
where
  ISNULL(c.vl_total_pedido,0)>0 and c.dt_entrega_agenda is not null
  and
  c.cd_pedido_entrega not in ( select a.cd_pedido_entrega   from agenda_entrega_composicao a where a.cd_pedido_entrega = c.cd_pedido_entrega )

  --select * from #Carteira where cd_pedido_entrega = 23

OPEN @ped_cursor
FETCH NEXT FROM @ped_cursor INTO @cd_pedido, @dt_pedido, @cd_cliente, @vl_total, @cd_veiculo, @cd_entregador, @hr_pedido


WHILE @@FETCH_STATUS = 0
BEGIN
  -- Encontrar a agenda do dia correspondente
  SELECT TOP 1 @cd_agenda_entrega = cd_agenda_entrega
  FROM Agenda_Entrega
  WHERE dt_entrega = @dt_pedido

  --select @dt_pedido

  -- Encontrar tipo_horario mais próximo do horário do pedido
  --tipo_horario

  -- Conversão segura da hora
SET @hora_pedido = try_convert(TIME, @hr_pedido)

--select * from #tipo_horario

-- Seleciona o tipo de horário compatível
SELECT TOP 1 @cd_tipo_horario = cd_tipo_horario
FROM #tipo_horario
WHERE @hora_pedido BETWEEN try_convert(time, hr_inicio_horario) AND try_convert(time, hr_fim_horario)
ORDER BY ABS(DATEDIFF(MINUTE, @hora_pedido, try_convert(time, hr_inicio_horario)))
-----------------------------------------

  -- Verificar quantas entregas já existem para essa agenda e horário

  IF (
    (SELECT COUNT(*) FROM Agenda_Entrega_Composicao
     WHERE cd_agenda_entrega = @cd_agenda_entrega
     AND cd_tipo_horario = @cd_tipo_horario) < @qt_veiculo
  )
  BEGIN
    -- Inserir na composição da agenda
    INSERT INTO Agenda_Entrega_Composicao (
      cd_composicao,
      cd_agenda_entrega,
      cd_item_agenda,
      cd_tipo_horario,
      cd_reserva_agenda,
      cd_pedido_venda,
      cd_status_agenda,
      ds_composicao,
      cd_usuario_inclusao,
      dt_usuario_inclusao,
      cd_usuario,
      dt_usuario,
	  cd_pedido_entrega
    )
    VALUES (
      (SELECT ISNULL(MAX(cd_composicao), 0) + 1 FROM Agenda_Entrega_Composicao),
      @cd_agenda_entrega,
      1,
      @cd_tipo_horario,
      NULL,
      @cd_pedido,
      @cd_status_agenda,
      'Agendado via rotina automática',
      @cd_usuario,
      GETDATE(),
      @cd_usuario,
      GETDATE(),
	  @cd_pedido

    )

  END

  FETCH NEXT FROM @ped_cursor INTO @cd_pedido, @dt_pedido, @cd_cliente, @vl_total, @cd_veiculo, @cd_entregador, @hr_pedido

END

CLOSE @ped_cursor
DEALLOCATE @ped_cursor




   if @cd_parametro = 0
   begin
     ------------------------------------------------------------------------------------------
     select 'Agenda Gerada com Sucesso !' as msg 
     ------------------------------------------------------------------------------------------    
     return
   end

   ---Composicao---
   
   --insert into Agenda_Entrega_Composicao 
   --(
   --cd_composicao,
   --cd_agenda_entrega,
   --cd_item_agenda,
   --cd_tipo_horario,
   --cd_reserva_agenda,
   --cd_pedido_venda,
   --cd_status_agenda,
   --ds_composicao,
   --cd_usuario_inclusao,
   --dt_usuario_inclusao,
   --cd_usuario,
   --dt_usuario )
   
   --values
   --(
   --2,
   --10,
   --1,
   --1,
   --1,
   --null,
   --1,
   --CAST('histórico dados da entrega no item' as varchar),
   --1,
   --GETDATE(),
   --1,
   --getdate()
   --)
   
   ----update
    
   -- --select * from agenda_entrega_composicao
   
   ----drop table #agenda_entrega
   
   ----delete from Agenda_Entrega
   --update agenda_entrega_composicao set cd_agenda_entrega = 11
   
   
  --return
  


end


--Mostrar a Agenda----------------------------------------------------------------

if @cd_parametro = 1
begin
  
  --select * from agenda_entrega a

  /*
  select
    a.cd_agenda_entrega,
	a.dt_entrega,
    pv.cd_pedido_entrega,
	pv.dt_pedido_entrega,
	pv.dt_entrega,
	pv.hr_entrega,
	pv.nm_endereco,
	pv.nm_bairro,
	pv.cd_numero,
	pv.vl_total_entrega                       as vl_total,
	v.nm_fantasia_vendedor,
	pv.cd_cliente,
	cli.nm_fantasia_cliente,
	cli.nm_razao_social_cliente,
	r.cd_veiculo,
	r.cd_entregador,
	vc.cd_placa_veiculo,
	vc.nm_veiculo,
	e.nm_entregador

	--tp.nm_tipo_pedido,
	--fp.nm_forma_pagamento

  from
    Agenda_Entrega a
	inner join agenda_entrega_composicao c on c.cd_agenda_entrega     = a.cd_agenda_entrega
	left outer join Pedido_entrega pv      on pv.cd_pedido_venda      = c.cd_pedido_venda
	left outer join Cliente cli            on cli.cd_cliente          = pv.cd_cliente
	left outer join Vendedor v             on v.cd_vendedor           = pv.cd_vendedor
	left outer join Romaneio r             on r.cd_romaneio           = pv.cd_romaneio
	left outer join Entregador e           on e.cd_entregador         = r.cd_entregador
	left outer join Veiculo vc             on vc.cd_veiculo           = r.cd_veiculo

  where
    a.dt_entrega between @dt_inicial and @dt_final

	--select * from pedido_entrega

*/

declare @qt_volume_agenda  decimal(25,2) = 0.00
declare @qt_entrega_agenda int = 0
declare @vl_total_agenda   decimal(25,4) = 0.00

set @qt_entrega_agenda  = 0.00
set @vl_total_agenda    = 0.00
set @qt_volume_agenda   = 0.00


select
  @qt_volume_agenda   = sum( isnull(pv.qt_entrega,0) ),
  @qt_entrega_agenda  = COUNT(distinct pv.cd_pedido_entrega),
  @vl_total_agenda    = SUM( isnull(pv.vl_total_entrega,0))

from
  Agenda_Entrega a
  inner join agenda_entrega_composicao c on c.cd_agenda_entrega     = a.cd_agenda_entrega
  inner join Pedido_entrega pv           on pv.cd_pedido_entrega    = c.cd_pedido_entrega

where
  a.dt_entrega between @dt_inicial and @dt_final
  and
  ISNULL(pv.vl_total_entrega,0)>0
  and
  ( ISNULL(pv.ic_fracionado,'N') = 'N' or isnull(qt_saldo_entrega,0)>0)
--qt_entrega_agenda e vl_total_agenda

select
  @qt_entrega_agenda                           as qt_entrega_agenda,
  @vl_total_agenda                             as vl_total_agenda,
  @qt_volume_agenda                            as qt_volume_agenda,
  pv.dt_entrega                                as dt_entrega,
  pv.hr_entrega                                as hr_entrega,
  r.cd_veiculo,
  r.cd_entregador,
  isnull(vc.nm_veiculo, 'Sem Definição')       as nm_veiculo,
  isnull(vc.cd_placa_veiculo,'XXX-9999')       as cd_placa,
  isnull(e.nm_entregador,'Falta Roteirização') as nm_entregador,
  pv.cd_pedido_entrega                         as cd_pedido,
  pv.vl_total_entrega                          as vl_total,
  ISNULL(pv.qt_entrega,0)                      as qt_entrega,
  s.nm_servico,
  a.ds_agenda                                  as ds_observacao,
  
  --Dados------------------------------------------------------------------------------------
  pv.cd_cliente,
  cli.nm_fantasia_cliente,
  cli.nm_razao_social_cliente,
  v.nm_fantasia_vendedor,
  pv.nm_endereco,
  pv.nm_bairro,
  pv.cd_numero,
  cid.nm_cidade,
  est.sg_estado,

  --Dados da Empresa--

  @logo                as logo,
  @nm_fantasia_empresa as nm_fantasia_empresa

  

from
  Agenda_Entrega a
  inner join agenda_entrega_composicao c on c.cd_agenda_entrega     = a.cd_agenda_entrega
  left join Pedido_entrega pv            on pv.cd_pedido_entrega    = c.cd_pedido_entrega
  left join Cliente cli                  on cli.cd_cliente          = pv.cd_cliente
  left join Vendedor v                   on v.cd_vendedor           = pv.cd_vendedor
  left join Romaneio r                   on r.cd_romaneio           = pv.cd_romaneio
  left join Entregador e                 on e.cd_entregador         = r.cd_entregador
  left join Veiculo vc                   on vc.cd_veiculo           = r.cd_veiculo
  left join Estado est                   on est.cd_estado           = pv.cd_estado
  left join Cidade cid                   on cid.cd_estado           = pv.cd_estado and cid.cd_cidade           = pv.cd_cidade
  left join servico s                    on s.cd_servico            = pv.cd_servico

where
  a.dt_entrega between @dt_inicial and @dt_final
  and
  ISNULL(pv.vl_total_entrega,0)>0

order by
  a.dt_entrega, pv.hr_entrega


end


--Agenda de Feriados

if @cd_parametro = 5
begin
  --select * from Feriado
  --select * from agenda_feriado

  select
    a.dt_agenda_feriado,
	a.cd_feriado,
	f.nm_feriado
  from
    Agenda_Feriado a
    inner join Feriado f on f.cd_feriado = a.cd_feriado
 where
   a.dt_agenda_feriado between @dt_inicial-90 and @dt_final


end




go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_processo_logistica_entregas
------------------------------------------------------------------------------
--go
--select * from tipo_validacao
--select * from Agenda_Entrega
go

--delete from Agenda_Entrega_Composicao
--go
--delete from Agenda_Entrega
--go

--Gerar a Agenda
--exec pr_processo_logistica_entregas '[{"cd_parametro": 0,"cd_usuario": 1,"dt_inicial"  : "06/01/2025","dt_final"    : "07/31/2025"}]'
--go
--Consultar a Agenda
--exec pr_processo_logistica_entregas '[{"cd_parametro": 1,"cd_usuario": 1,"dt_inicial"  : "06/01/2025","dt_final"    : "07/31/2025"}]'
--go
--Gerar os Feriados
--exec pr_processo_logistica_entregas '[{"cd_parametro": 5,"cd_usuario": 1,"dt_inicial"  : "01/01/2025","dt_final"    : "06/30/2025"}]'



--qt_entrega, vl_total, e count(cd_pedido_entrega) do dia selecionado

--delete from agenda_entrega
--delete from agenda_entrega_composicao
--select * from pedido_entrega


/*

CREATE TABLE tb_evento_atualizacao_agenda (
  id_evento INT IDENTITY(1,1) PRIMARY KEY,
  dt_evento DATETIME DEFAULT GETDATE(),
  tipo_evento VARCHAR(50),
  origem VARCHAR(50),
  observacoes TEXT
);

CREATE TRIGGER trg_novo_pedido_agenda
ON tb_pedido_venda
AFTER INSERT
AS
BEGIN
  INSERT INTO tb_evento_atualizacao_agenda (tipo_evento, origem, observacoes)
  VALUES ('novo_pedido', 'trigger', 'Atualização automática da agenda');
END;



*/	