use egissql_231
go

select * from situacao_tributaria

select * from tributacao
select * from classificacao_tributaria

update tributacao
set
  cd_situacao_tributaria      = 1,
  cd_classificacao            = 1
where
  isnull(cd_situacao_tributaria,0) = 0

  

select
  t.cd_tributacao,
  st.cd_identificacao as CST_IBSCBS,
  ct.cd_identificacao as SITUACAO

from
  tributacao t
left outer join situacao_tributaria st      on st.cd_situacao_tributaria = t.cd_situacao_tributaria
left outer join classificacao_tributaria ct on ct.cd_classificacao  = t.cd_classificacao

