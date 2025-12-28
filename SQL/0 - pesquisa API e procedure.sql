use egisadmin
go
declare @cd_procedimento int = 1460

select cd_procedimento,* from api where cd_api = 585
select * from procedimento where cd_procedimento = @cd_procedimento

--select * from atributo where cd_tabela = 1448

--update
--  atributo
--  set
--    ic_pesquisa_atributo = 's'
--    where
--      cd_tabela = 1448
--      and
--      cd_atributo = 11

--      go

--      select * from meta_procedure_colunas where cd_menu_id = 5935

      