use egissql_289
go
--delete from nota_saida_rejeicao
go
select * from nota_saida_rejeicao
go
--delete from nota_validacao
go
select * from nota_validacao

--select * from nota_saida order by dt_nota_saida desc

--22410
--select * from nota_saida where cd_nota_saida = '17374'

--select * from nota_validacao
--NFe
--EXEC pr_processo_validacao_api_nota_fiscal '[{"cd_parametro":2,"cd_nota_saida":22503,"cd_usuario":113}]'
--
--17374

--use egisadmin
--go

--exec pr_egis_config_nfe_empresa '[{"cd_cnpj_empresa": "51337443000103"}]'