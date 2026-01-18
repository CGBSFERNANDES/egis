update
  Produto_Custo
  set
    ic_estoque_fatura_produto='S',
	ic_estoque_venda_produto ='S',
	ic_venda_saldo_negativo  ='S'

	from  Produto_Custo pc
	inner join Produto p on p.cd_produto = pc.cd_produto

where
  ic_wapnet_produto='S'

  UPDATE
   Produto_Saldo
   SET
    qt_saldo_reserva_produto = 60000,
	qt_saldo_atual_produto = 60000
where
   qt_saldo_reserva_produto<=0


  
