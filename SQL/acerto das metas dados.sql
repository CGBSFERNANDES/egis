use egissql_rubio
go


--insert meta_procedures ( nome_procedure, criado_em ) values ('pr_dashboard_modulo_assistencia_tecnica', getdate())


--select * from meta_procedures           where nome_procedure = 'pr_dashboard_modulo_assistencia_tecnica'
--select * from meta_procedure_colunas    where nome_procedure = 'pr_dashboard_modulo_assistencia_tecnica'
--select * from meta_procedure_parametros where nome_procedure = 'pr_dashboard_modulo_assistencia_tecnica'


--select * from meta_procedure_parametros

drop table egisadmin.dbo.meta_procedures 
drop table egisadmin.dbo.meta_procedure_colunas 
drop table egisadmin.dbo.meta_procedure_parametros 
go

select * into egisadmin.dbo.meta_procedures           from meta_procedures 
select * into egisadmin.dbo.meta_procedure_parametros from meta_procedure_parametros
select * into egisadmin.dbo.meta_procedure_colunas    from meta_procedure_colunas

