use  egissql_345

--agenda_entrega
--agenda_entrega_composicao
--select * from parametro_logistica
--agenda_entrega_parametro

--select * from tipo_horario
--select * from agenda_entrega_parametro
--select * from reserva_agenda
--select * from agenda_entrega
--select * from agenda_entrega_composicao


declare @cd_usuario int = 1
declare @dt_inicial datetime = '06/01/2025'
declare @dt_final   datetime = '06/30/2025'

declare @qt_horario          int      = 0
declare @qt_veiculo          int      = 0
declare @qt_motorista        int      = 0
declare @qt_entrega          int      = 0
declare @qt_cliente          int      = 0
declare @qt_vendedor		 int      = 0
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

  --insert into status_agenda
  --select * from egissql.dbo.status_agenda
  --select * from  tipo_horario

select @qt_horario, @qt_veiculo, @qt_motorista, @qt_entrega

select 
  * 
into #tipo_horario
from
  tipo_horario
where
  isnull(ic_ativo_horario,'N')='S'


select * from #tipo_horario


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

    update
	  #agenda_entrega
	set cd_agenda_entrega = cd_agenda_entrega + cd_interface

	insert into Agenda_Entrega
	select * from #agenda_entrega

	drop table #agenda_entrega
    
	set @dt_entrega = @dt_entrega + 1

end

select * from Agenda_Entrega

drop table #tipo_horario

select
 p.cd_pedido_venda,
 p.dt_pedido_venda,
 p.dt_pedido_venda as dt_entrega_agenda,
 p.cd_cliente,
 p.vl_total_pedido_ipi as vl_total_pedido

into
  #Carteira

from
 
 pedido_venda p
 inner join cliente c on c.cd_cliente = p.cd_cliente

where
  p.cd_pedido_venda in ( select i.cd_pedido_venda from Pedido_Venda_Item i
                         where
						   i.cd_pedido_venda = p.cd_pedido_venda
						   and
						   i.dt_cancelamento_item is null
						   and
						   isnull(i.qt_saldo_pedido_venda,0)>0
                        )
  and
  p.cd_pedido_venda not in ( select a.cd_pedido_venda from Agenda_Entrega_Composicao a
                             where
							   a.cd_pedido_venda = p.cd_pedido_venda
							   )

  
  



---Composicao---

insert into Agenda_Entrega_Composicao 
(
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
dt_usuario )

values
(
2,
10,
1,
1,
1,
null,
1,
CAST('histórico dados da entrega no item' as varchar),
1,
GETDATE(),
1,
getdate()
)

--update
 
 --select * from agenda_entrega_composicao

--drop table #agenda_entrega

--delete from Agenda_Entrega
update agenda_entrega_composicao set cd_agenda_entrega = 11
