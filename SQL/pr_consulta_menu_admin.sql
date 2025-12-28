USE EGISSQL_341
GO
create procedure pr_consulta_menu_admin
as
select * from EGISADMIN.dbo.menu
order by
  nm_menu

  go

  exec pr_consulta_menu_admin
