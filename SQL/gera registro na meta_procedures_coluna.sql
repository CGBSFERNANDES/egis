select cd_chave_acesso, * from Nota_Saida where dt_nota_saida = '05/24/2025'
use EGISSQL_RUBIO
go
select * from meta_procedure_colunas where nome_procedure = 'pr_processo_validacao_api_nota_fiscal'
--insert into 

select
   nome_procedure      = 'pr_processo_validacao_api_nota_fiscal',
   nome_coluna         = 'cd_chave_acesso',
   tipo_coluna         = 'varchar',
   ordem_coluna		   = 15,
   titulo_exibicao	   = 'Chave de Acesso',
   visivel			   = 1,
   criado_em		   = getdate(),
   largura			   = null,
   menu				   = 'Validação NFe',
   cd_menu_id		   = 8115,
   qt_ordem_coluna	   = 15,
   contagem			   = 0,
   soma				   = 0,
   formato_coluna	   = '',
   tipo_grafico		   = null,
   ordem			   = null,
   cor				   = null,
   agrupador_base	   = null,
   ativo			   = 1
   into  #mpc

insert into   meta_procedure_colunas select * from #mpc

drop table #mpc

