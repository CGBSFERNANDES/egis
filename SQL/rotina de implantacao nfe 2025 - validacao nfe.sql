use egissql_319
go



--NFe
EXEC pr_processo_validacao_api_nota_fiscal '[{"cd_parametro":2,"cd_nota_saida":491580,"cd_usuario":113}]'
go

select * from nota_validacao

delete from nota_saida_rejeicao
delete from nota_validacao

select * from nota_saida_rejeicao

select cd_tributacao, * from nota_saida_item where cd_nota_saida = 491580
select * from tributacao



--select * from vw_nfe_icms_nota_fiscal where cd_nota_saida = 20158

--insert into situacao_tributaria
--select * from egissql_317.dbo.situacao_tributaria

--insert into classificacao_tributaria
--select * from egissql_317.dbo.classificacao_tributaria

--delete from nota_saida_rejeicao
--delete nota_validacao
--go
--select * from nota_validacao

--select cd_tributacao,* from nota_saida_item where cd_nota_saida = 20158

--update
--   tributacao
--set
--   cd_situacao_tributaria = 1,
--   cd_classificacao       = 1




--2025-11-11 12:45:10 [INFO] Início gerar-xml-NFC {"origem":"gerar-xml-NFC.php"}
--2025-11-11 12:45:10 [INFO] PR rejeicao (pr_egis_gera_rejeicao_nota_saida) {"nm_banco":"EGISSQL_EXSTO","chave":"35251112321219000171550010000155131000201586","cStat":"0","xMotivo":"ICMS sem subgrupo (ex.: ICMSSN201/ICMS10...)","etapa":"VALIDACAO_LOCAL","payload_usado":"[{\"cd_parametro\":0},{\"cd_empresa\":63},{\"cd_nota_saida\":20158},{\"cd_usuario\":113},{\"cd_serie_nota\":0},{\"cd_chave_acesso\":\"35251112321219000171550010000155131000201586\"},{\"cStat\":\"0\"},{\"xMotivo\":\"ICMS sem subgrupo (ex.: ICMSSN201/ICMS10...)\"},{\"ds_etapa\":\"VALIDACAO_LOCAL\"},{\"ds_rejeicao_nota\":\"[]\"}]","retorno":[{"mensagem":"Procedure executada sem retorno."}],"erro":null}
--2025-11-11 12:45:10 [ERROR] Rejeição NFe {"cStat":"0","xMotivo":"ICMS sem subgrupo (ex.: ICMSSN201/ICMS10...)","etapa":"VALIDACAO_LOCAL","context":[]}
