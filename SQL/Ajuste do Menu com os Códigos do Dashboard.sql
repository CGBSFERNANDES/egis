USE EGISADMIN
GO
select * from dashboard

SELECT CD_DASHBOARD, * FROM MENU

--contas a pagar

update
 Menu
 set
   cd_dashboard = 3   --cd_modulo
where   
  cd_menu = 8145


  --financeiro

update
 Menu
 set
   cd_dashboard = 56 --cd_modulo
where   
  cd_menu = 8150


  update
 Menu
 set
   cd_dashboard = 41 --cd_modulo
where   
  cd_menu = 8151


  select * from Menu where cd_menu = 8151

