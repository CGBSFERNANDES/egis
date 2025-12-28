 --   payload - fixo
	--"cd_menu": ""  --> menu que estamos session
 --   "cd_form": "0", --> session
 --   "cd_parametro_form": 2,  ( 1-inclucao 2-alteracao 3-exclusao ) --> operacao crud
 --   "cd_usuario": ""       --> sesion
 --   "cd_cliente_form": "",
 --   "cd_contato_form": "",
 --   "dt_usuario": "",  --> data de agora
 --   "lookup_formEspecial": {},
 --   "detalhe": [],
 --   "lote": [],
 --   "cd_modulo": "",
 --   "cd_documento_form": "", --> registro ( id ) quando form alteracao/exclucsao 0-> para inclusao

	--+ 

	--payload -> dados do payload da tabela editado pelo usuario no modal

	--Não foi possível alterar o registro ...UPDATE  Cor set cd_usuario = 1625, dt_usuario = convert(datetime, 'Apr 30 2025 11:08PM' ,120), cd_grupo_produto = NULL, cd_cor = 1, nm_cor = 'Azul......', sg_cor = 'AZ', pc_acresc_cor = NULL, vl_hexa_cor = '1', cd_cor_texto = NULL where cd_grupo_produto =  and cd_cor = 1
--exec pr_egis_api_crud_dados_especial
--'[{"cd_menu":"8068","cd_form":"167","cd_parametro_form":2,"cd_usuario":1625,"cd_cliente_form":"0","cd_contato_form":"","dt_usuario":"2025-04-30T14:27:00.000Z",
--"lookup_formEspecial":{},"detalhe":[],"lote":[],"cd_modulo":"","cd_documento_form":"1","cd_grupo_produto":"4","cd_cor":"1","nm_cor":"Azul....","sg_cor":"AZ        ","pc_acresc_cor":null,"vl_hexa_cor":"1                   ","cd_cor_texto":null,"cd_usuario_inclusao":null,"dt_usuario_inclusao":null}]'
----
--select * from cor


--exec pr_egis_api_crud_dados_especial '
--[{"cd_menu":"7269","cd_form":"0","cd_parametro_form":2,"cd_usuario":"113","dt_usuario":"2025-05-01T15:13:01.079Z","cd_empresa":"96",
--"cd_entregador":"1","nm_entregador":"DENIS DE ARRUDA BARBOSA","sg_entregador":"DAB..    ","ic_etiqueta_entregador":"N",
--"ic_minuta_entregador":"N","cd_transportadora":"176","cd_placa_entregador":"CTO4A58","ic_ativo_entregador":"S","cd_veiculo":"1",
--"ic_esporadico":"N","cd_usuario_entregador":"2670","cd_motorista":null}]
--'

