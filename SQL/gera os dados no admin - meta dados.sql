use egissql_rubio
go
select * from meta_procedures where nome_procedure = 'pr_depreciacao_periodo_apuracao'
select * from meta_procedure_colunas where nome_procedure = 'pr_depreciacao_periodo_apuracao'
select * from meta_procedure_parametros where nome_procedure = 'pr_depreciacao_periodo_apuracao'

--update
--  meta_procedure_colunas
--set
--  cd_menu_id = 8601
--where
--  cd_menu_id = 730
--go


drop table egisadmin.dbo.meta_procedures 
drop table egisadmin.dbo.meta_procedure_colunas 
drop table egisadmin.dbo.meta_procedure_parametros 
go
use egissql_rubio
go

select * into egisadmin.dbo.meta_procedures           from meta_procedures 
select * into egisadmin.dbo.meta_procedure_parametros from meta_procedure_parametros
select * into egisadmin.dbo.meta_procedure_colunas    from meta_procedure_colunas  


--select * from egisadmin.dbo.meta_procedures where nome_procedure = 'pr_consulta_nota_entrada'
--select * from egisadmin.dbo.meta_procedure_colunas where nome_procedure = 'pr_consulta_nota_entrada'
--select * from egisadmin.dbo.meta_procedure_parametros where nome_procedure = 'pr_consulta_nota_entrada'


--select * from meta_procedures where nome_procedure = 'pr_consulta_nota_entrada'
--select * from meta_procedure_colunas where nome_procedure = 'pr_consulta_nota_entrada'
--select * from meta_procedure_parametros where nome_procedure = 'pr_consulta_nota_entrada'

