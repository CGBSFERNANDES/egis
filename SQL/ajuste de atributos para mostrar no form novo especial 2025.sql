use egisadmin
go
--select * from atributo where cd_tabela = 47


update
  atributo
  set
   ic_mostra_grid = 'N',
   ic_edita_cadastro = 'N',
   ic_mostra_relatorio = 'N',
   ic_mostra_cadastro  = 'N'

   where 
     cd_tabela = 47
     and
     cd_atributo in 
     (
  6,   
7,
8,
9,
13,
16,
22,
23,
24,
25,
26,
27,
28,
29,
30,
31,
32,
33,
34,
35,
36,
37,
43,
44,
45,
46,
47,
54,
55,
56,
57,
58,
59,
60
     )

