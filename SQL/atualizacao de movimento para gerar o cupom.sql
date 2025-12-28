use egissql_360
go

select * from movimento_caixa where isnull(cd_nota_saida,0) = 0 and dt_movimento_caixa = '11/09/2025'

select * from nota_saida where dt_nota_saida = '11/09/2025'


select * from Nota_validacao

exec pr_egis_gca_processo_modulo '[{"cd_parametro": 100},{"cd_movimento_caixa":359}, 
{"cd_documento":0},
{"cd_usuario":4915}]'


--{
--    "cd_usuario": 4915,
--    "cd_parametro": 100,
--    "cd_documento": 69,
--    "cd_movimento_caixa": 359,
--    "vl_troco": 0,
--    "appVersion": "1.0.88",
--    "appName": "EgisApp

--'select * from movimento_caixa

use egissql_371
go

select * from nota_validacao

