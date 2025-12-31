use EGISSQL_RUBIO
go
return


--drop table meta_procedure_colunas
--go
--CREATE TABLE dbo.meta_procedure_colunas (
--    id INT IDENTITY(1,1) PRIMARY KEY,
--    nome_procedure VARCHAR(100),
--    nome_coluna VARCHAR(100), 
--    tipo_coluna VARCHAR(50),
--    ordem_coluna INT,
--    titulo_exibicao VARCHAR(200), -- editável
--    visivel BIT DEFAULT 1,
--    criado_em DATETIME DEFAULT GETDATE()
--);
--go
--ALTER TABLE dbo.meta_procedure_colunas
--ADD largura INT NULL;

--go
--ALTER TABLE dbo.meta_procedure_colunas
--ADD menu VARCHAR(100) NULL;
--go
--ALTER TABLE dbo.meta_procedure_colunas
--ADD cd_menu_id int NULL;
--alter table dbo.meta_procedure_colunas add contagem char(1) null
--alter table dbo.meta_procedure_colunas add soma char(1) null

--ALTER TABLE dbo.meta_procedure_colunas ALTER COLUMN contagem bit NULL;
--ALTER TABLE dbo.meta_procedure_colunas ALTER COLUMN soma bit NULL;
--go
--alter table dbo.meta_procedure_colunas add qt_ordem_coluna int
--go
--ALTER TABLE meta_procedure_colunas
--ADD formato_coluna VARCHAR(50);
--go
--alter table meta_procedure_colunas add tipo_grafico	varchar(20);
--alter table meta_procedure_colunas add ordem	int;
--alter table meta_procedure_colunas add cor	varchar(20);
--alter table meta_procedure_colunas add agrupador_base	varchar(100);
--alter table meta_procedure_colunas add ativo	bit	;


----delete from meta_procedure_colunas




--select * from egisamin.dbo.menu order by menu

--drop table dbo.meta_procedures
--go

--CREATE TABLE dbo.meta_procedures (https://chatgpt.com/g/g-p-6805c7dfa4a08191bd046323614a44c5-modulos/project
--  id INT IDENTITY(1,1) PRIMARY KEY,
--  nome_procedure VARCHAR(150) UNIQUE,
--  criado_em DATETIME DEFAULT GETDATE()
--);

--SELECT * FROM dbo.meta_procedures ORDER BY nome_procedure;

--CREATE TABLE dbo.meta_procedure_parametros (
--  id INT IDENTITY(1,1) PRIMARY KEY,
--  nome_procedure VARCHAR(150),
--  nome_parametro VARCHAR(100),
--  tipo_parametro VARCHAR(50),
--  valor_padrao VARCHAR(100),
--  obrigatorio BIT DEFAULT 1,
--  editavel BIT DEFAULT 1,
--  ordem_parametro INT
--);

--alter table meta_procedure_parametros add titulo_parametro varchar(80)

--SELECT 
--  p.name AS nome_parametro,
--  t.name AS tipo_parametro,
--  p.default_value,
--  p.is_output,
--  p.parameter_id
--FROM sys.parameters p
--JOIN sys.types t ON p.user_type_id = t.user_type_id
--WHERE object_id = OBJECT_ID('dbo.pr_ranking_produto');


--SELECT * FROM meta_procedure_parametros
--use egissql
--go

--use egisadmin

--update
--meta_procedure_colunas
--set
-- cd_menu_id = 8084
--where
--  nome_procedure = 'pr_posicao_contas_pagar_por_conta_anual'

--  select * from egisadmin.dbo.menu_procedimento where cd_menu = 8084

--  --insert into egisadmin.dbo.menu_procedimento ( cd_menu, cd_procedimento ) values ( 8084 )


----Atualiza o Admin----------------------------------------------------------------------
--select * from egisadmin.dbo.meta_procedures
--select * from meta_procedure_colunas
--select * from meta_procedure_parametros


--insert into egisadmin.dbo.meta_procedures 
--select * from meta_procedures where id not in ( select id from egisadmin.dbo.meta_procedures )
--insert into egisadmin.dbo.meta_procedure_colunas 
--select * from meta_procedure_colunas where id not in ( select id from egisadmin.dbo.meta_procedure_colunas )
--insert into egisadmin.dbo.meta_procedure_parametros select * from meta_procedure_parametros where id not in ( select id from egisadmin.dbo.meta_procedure_parametros )


--use egissql_rubio
--go

--update
--  meta_procedure_colunas 
--  set
--    formato_coluna = 'currency'
  
--  where --cd_menu_id = 8114
--    --and
--	tipo_coluna = 'float'

--update
--  meta_procedure_colunas 
--  set
--    formato_coluna = 'shorDate'
  
--  where --cd_menu_id = 8114
--    --and
--	tipo_coluna = 'datetime'




----where cd_menu_id = 122

----insert into egisadmin.dbo.meta_procedure_colunas
----select * from meta_procedure_colunas       where cd_menu_id = 122



----04.04.2025
----04.04.2025
----CREATE INDEX IDX_SERVICO on servico ( cd_servico )
----CREATE INDEX meta_procedure_colunas on meta_procedure_colunas ( nome_procedure )
----CREATE INDEX IDX_meta_procedure_parametros on meta_procedure_parametros ( nome_procedure )

--use egissql_rubio
--go
--alter table meta_procedure_colunas 
--add
--tipo_grafico varchar(20),
--ordem int,
--cor varchar(20),
--agrupador_base varchar(100),
--ativo bit 

--USE EGISADMIN
--GO
--use egissql_342
--use egisadmin
--go

--update
--  meta_procedure_colunas
--  set
--    cd_menu_id = '8134' 
--where nome_procedure = 'pr_egis_historico_cliente'

--SELECT * FROM MENU

--select * from meta_procedure_colunas where nome_procedure = 'pr_egis_historico_cliente'
--select * from meta_procedures
--select * from meta_procedure_colunas
--select * from meta_procedure_parametros

--delete from meta_procedure_colunas where nome_procedure = 'pr_processo_gnre'
--use egissql_rubio
--go
--update
--  meta_procedures
--  set
--     nome_procedure = 'pr_consulta_entregas_base_retirada' 
--    where

--	  id = 4525
-- delete from meta_procedures where id = 4525


--use EGISSQL_RUBIO
--go



--select * from meta_procedures where nome_procedure = 'pr_processo_logistica_entregas'
--select * from meta_procedure_colunas where nome_procedure = 'pr_egis_vendas_semanal'
--USE EGISADMIN
--go
--select * from meta_procedure_colunas where nome_procedure = 'pr_egis_vendas_semanal'
--select * from meta_procedure_colunas where nome_procedure = 'pr_egis_faturamento_cliente_logistica'
--select * from meta_procedure_parametros where nome_procedure = 'pr_egis_proposta_cliente'

--drop table #tmp_menu_coluna
--go

--select * into #tmp_menu_coluna from meta_procedure_colunas where nome_procedure = 'pr_egis_processo_modulos' and cd_menu_id = 8147


--select * from #tmp_menu_coluna

--update
--  meta_procedure_colunas
--  set
--   nome_coluna = 'nm_fantasia_cliente'
--where
--  id=754



--update
--  #tmp_menu_coluna
--set
--  nome_coluna = 'cd_centro_custo',
--  titulo_exibicao = 'Código'
  
--where  
--  id = 648


--update
--  #tmp_menu_coluna
--set
--  nome_coluna = 'cd_mascara_centro_custo',
--  titulo_exibicao = 'Máscara'
  
--where  
--  id = 649

--update
--  #tmp_menu_coluna
--set
--  nome_coluna = 'nm_centro_custo',
--  titulo_exibicao = 'Centro de Custo'
  
--where  
--  id = 650




--update
--  meta_procedure_colunas
--set
--  nome_coluna = 'cd_plano_financeiro',
--  titulo_exibicao = 'Código'
  
--where  
--  id = 656

  
--insert into meta_procedure_colunas
--select 
--nome_procedure  ,
--nome_coluna		,
--tipo_coluna		,
--ordem_coluna	,
--titulo_exibicao	,
--visivel			,
--criado_em		,
--largura			,
--menu			,
--cd_menu_id		,
--qt_ordem_coluna	,
--contagem		,
--soma			,
--formato_coluna	,
--tipo_grafico	,
--ordem			,
--cor				,
--agrupador_base	,
--ativo			

--from #tmp_menu_coluna

--drop table #tmp_menu_coluna

----insert into 

--select
--   nome_procedure      = 'pr_processo_logistica_entregas',
--   nome_coluna         = 'nm_servico',
--   tipo_coluna         = 'varchar',
--   ordem_coluna		   = 20,
--   titulo_exibicao	   = 'Serviço',
--   visivel			   = 1,
--   criado_em		   = getdate(),
--   largura			   = null,
--   menu				   = 'Agenda de Entregas',
--   cd_menu_id		   = 8097,
--   qt_ordem_coluna	   = 20,
--   contagem			   = 0,
--   soma				   = 0,
--   formato_coluna	   = '',
--   tipo_grafico		   = null,
--   ordem			   = null,
--   cor				   = null,
--   agrupador_base	   = null,
--   ativo			   = 1
--   into  #mpc

--insert into   meta_procedure_colunas select * from #mpc

--drop table #mpc


--USE EGISSQL_RUBIO
--GO
--select * FROM meta_procedure_colunas 
--use egisadmin
--menu

--select * FROM EGISADMIN.DBO.meta_procedure_colunas 
----delete from meta_procedure_colunas where nome_coluna = 'undefined'
----delete from meta_procedure_colunas where id>322 --nome_coluna = 'undefined'



--SELECT * from meta_procedure_colunas where cd_menu_id = 8114

--update
--  meta_procedure_colunas 
--  set
--    formato_coluna = 'currency'
  
--  where --cd_menu_id = 8114
--    --and
--	tipo_coluna = 'float'


--	update
--	  egisadmin.dbo.menu

--	  set
--	    ic_json_parametro = 'S'
--	 where
--	   cd_menu = 8134


	   update
	     meta_procedure_colunas
set
      cd_menu_id = 8181
where
  cd_menu_id = 7377


  use egisadmin
  go

  use egissql_rubio
  go

update
  meta_procedure_colunas
  set
    contagem = 0,
	soma = 1
where
  id = 819


update
  meta_procedure_colunas
  set
    cd_menu_id = 8169
	where
	  cd_menu_id = 5617

--  --delete from meta_procedure_colunas where nome_procedure = 'pr_egis_faturamento_veiculo'

--  select * from meta_procedure_colunas where nome_procedure = 'pr_egis_pagar_processo_modulo'

--  update
--     meta_procedure_colunas
--	 set
--	   formato_coluna = 'currency',
--	   soma = 1
--	   where
--	   id 
--	   in
--	   (
--	   773,
--774,
--775,
--776,
--777,
--778,
--779,
--780,
--781
--	   )

/*
use egisadmin
go
use egissql_rubio

drop table #novoreg
select *  from meta_procedure_colunas where cd_menu_id = 8261 
select * into #novoreg from meta_procedure_colunas where cd_menu_id = 8261 and id = 2025
drop table #novoreg
select * from #novoreg

update 
  #novoreg
set
  nome_coluna = 'fasePedido',
  tipo_coluna = 'varchar',
  qt_ordem_coluna = 26,
  titulo_exibicao = 'fasePedido',

  contagem = 0

update
   #novoreg
set 
  cd_menu_id = 8261

update
  meta_procedure_colunas
set
 -- nome_coluna = 'C2',
 -- tipo_coluna = 'varchar',
  qt_ordem_coluna = 24,
  --titulo_exibicao = 'C2',
  contagem = 0
where
 id = 2024

select * from #novoreg

update 
  #novoreg
set
  nome_coluna = 'C2',
  tipo_coluna = 'varchar',
  qt_ordem_coluna = qt_ordem_coluna + 1,
  titulo_exibicao = 'Atividades',
  contagem = 0


  insert into meta_procedure_colunas
   ( nome_procedure,
nome_coluna,
tipo_coluna,
ordem_coluna,
titulo_exibicao,
visivel,
criado_em,
largura,
menu,
cd_menu_id,
qt_ordem_coluna,
contagem,
soma,
formato_coluna,
tipo_grafico,
ordem,
cor,
agrupador_base,
ativo)

  select 
  
nome_procedure,
nome_coluna,
tipo_coluna,
ordem_coluna,
titulo_exibicao,
visivel,
criado_em,
largura,
menu,
cd_menu_id,
qt_ordem_coluna,
contagem,
soma,
formato_coluna,
tipo_grafico,
ordem,
cor,
agrupador_base,
ativo
  from #novoreg

update
  egisadmin.dbo.meta_procedure_colunas
  set
    formato_coluna = ''
  where
    id=1811

  update
     meta_procedure_colunas
	 set
	   formato_coluna = 'currency',
	   soma = 1
	   where
	     id = 819


		 UPDATE
		   EGISADMIN.DBO.MENU
		   SET
		     CD_DASHBOARD = 57
			 WHERE
			   CD_MENU = 8185


			   update
			     egisadmin.dbo.menu
				 set
				   ic_json_parametro = 'S',
				   cd_parametro = 200
				  -- ic_cliente        = 'S'
				where
				  cd_menu = 8760



				  use egissql_rubio
go

update
  meta_procedure_colunas
set 
  qt_ordem_coluna = 4
where
  id = 2474

--select * from meta_procedure_colunas where nome_procedure = 'pr_egis_visita_processo_modulo'
--select * from meta_procedure_parametros where nome_procedure = 'pr_egis_visita_processo_modulo'

select top 1 * into #mpp from meta_procedure_parametros where nome_procedure = 'pr_mapa_carteira_cliente_aberto'


update
  #mpp
set
 nome_parametro = '@cd_usuario',
 tipo_parametro = 'int',
 titulo_parametro = 'Usuário'
  
  select * from #mpp

  insert into meta_procedure_parametros
  select
    nome_procedure,
    nome_parametro,
    tipo_parametro,
    valor_padrao,
    obrigatorio,
    editavel,
    ordem_parametro,
    titulo_parametro
   from #mpp


drop table #mpp


*/
--	   update
--	   meta_procedure_colunas
--	     set
--		   visivel = 0
--		   where
--		     id = 778

--			   update
--	   egisadmin.dbo.meta_procedure_colunas
--	     set
--		   visivel = 0
--		   where
--		     id = 778
/*
use egisadmin
go

			   update
	   meta_procedure_colunas
	     set
		   formato_coluna = 'shortDate'
		   where
		     tipo_coluna = 'datetime'
			 and
			 isnull(formato_coluna,'')=''


use egissql_rubio
go

update
  egisadmin.dbo.menu
  set 
    ic_json_parametro = 'N'
where
  cd_menu = 8292


--pr_mapa_carteira_cliente_aberto
select * from meta_procedure_colunas where cd_menu_id = '8292'
select * from meta_procedure_parametros where cd_menu_id = '8261'
update
  meta_procedure_colunas
set
 cd_menu_id = 8261
 where
   cd_menu_id = 7377


   update
     egisadmin.dbo.menu
	 set
	   ic_json_parametro = 'S',
	   cd_parametro = 1000
	   where
	     cd_menu = 8517


	  
select * from meta_procedures
use egissql_rubio

select * from meta_procedures where nome_procedure = 'pr_egis_pagar_processo_modulo'
-- insert meta_procedures ( nome_procedure, criado_em ) values ('pr_egis_visita_processo_modulo', getdate())

select * into #incMetaColuna from meta_procedure_colunas where nome_procedure = 'pr_egis_supnet_processo_modulo'

select * from #incMetaColuna

update
  #incMetaColuna
  set
   cd_menu_id = 7355

INSERT INTO meta_procedure_colunas
            (nome_procedure, cd_menu_id, menu, nome_coluna, tipo_coluna,
             titulo_exibicao, qt_ordem_coluna, visivel)
select
nome_procedure, cd_menu_id, menu, nome_coluna, tipo_coluna,
             titulo_exibicao, qt_ordem_coluna, visivel
from
  #incMetaColuna

			 go
			 use egissql_rubio
			 use egisadmin
			 --select * into #incMetaColuna from meta_procedure_colunas where nome_procedure = 'pr_egis_supnet_processo_modulo'
			 --select * from meta_procedures where nome_procedure = 'pr_consulta_trans_estado'
			 
			 --select * from meta_procedure_colunas where nome_procedure = 'pr_nota_transportadora'
			 --select * from meta_procedure_parametros where nome_procedure = 'pr_nota_transportadora'
			 update
			   meta_procedure_colunas
			   set
			     cd_menu_id = 8517
				where  
				  cd_menu_id = 4098

				  update
				     meta_procedure_colunas 
					 set
					   titulo_exibicao = 'Descritivo'
					where
					  id = 1880



			--where 
			--delete from meta_procedure_colunas where cd_menu_id = 8241
			use egissql_rubio

			select * from meta_procedures     where nome_procedure='pr_egis_visita_processo_modulo' 
			--= 8261
			delete from meta_procedure_colunas   where id = 2289
			select * from meta_procedure_colunas where cd_menu_id = 8676
			select * from meta_procedure_colunas where cd_menu_id = 8789
			select * from meta_procedure_colunas where nome_procedure = 'pr_egis_ativo_processo_modulo'

			*/

 insert meta_procedures ( nome_procedure, criado_em ) values ('pr_egis_servicos_processo_modulo', getdate())


use egissql_rubio
go

drop table egisadmin.dbo.meta_procedures 
drop table egisadmin.dbo.meta_procedure_colunas 
drop table egisadmin.dbo.meta_procedure_parametros 
go
use egissql_rubio
go

select * into egisadmin.dbo.meta_procedures           from meta_procedures 
select * into egisadmin.dbo.meta_procedure_parametros from meta_procedure_parametros
select * into egisadmin.dbo.meta_procedure_colunas    from meta_procedure_colunas      


