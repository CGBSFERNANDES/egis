--ajuste na tabela de atributo--

update
  atributo
  set
    ic_mostra_grid ='N',
ic_edita_cadastro = 'N',
ic_mostra_relatorio = 'N',
ic_mostra_cadastro = 'N'

where
  cd_tabela = 314
  and
  nu_ordem>7


  update
    atributo
    set
      ic_data_padrao = 'S',
      ic_data_hoje   = 'S'
    where
      cd_tabela = 225
      and
      cd_atributo = 3

