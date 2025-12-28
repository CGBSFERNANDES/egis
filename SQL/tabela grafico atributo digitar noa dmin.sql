use EGISADMIN
go

select * from meta_procedure_parametros
select * from meta_procedure_colunas

update
  meta_procedure_colunas
  set
   formato_coluna = 'currency'
   where
    tipo_coluna = 'float'

	update
  meta_procedure_colunas
  set
   titulo_exibicao = titulo_exibicao + '.'
   where
   nome_procedure = 'pr_posicao_contas_pagar_por_conta_anual'
   and
   ordem_coluna between 6 and 17
   


   CREATE TABLE atributo_grafico (
  id INT IDENTITY PRIMARY KEY,
  cd_menu INT NOT NULL,
  nm_atributo VARCHAR(100) NOT NULL,
  tipo_grafico VARCHAR(20) NOT NULL, -- Ex: 'bar', 'pie', 'line'
  ordem INT DEFAULT 1,
  cor VARCHAR(20),                   -- Opcional: 'azul', '#FF0000', etc
  agrupador_base VARCHAR(100),      -- Ex: 'Classificação', 'Tipo'
  ativo BIT DEFAULT 1
);

ALTER TABLE atributo_grafico ADD ativo BIT DEFAULT 1

go

INSERT INTO atributo_grafico (cd_menu, nm_atributo, tipo_grafico, ordem, cor, agrupador_base)
VALUES
(8084, 'Vencidas', 'bar', 1, 'blue', 'Classificação'),
(8084, 'TotalGeral', 'pie', 2, 'green', 'Tipo'),
(8084, 'Mai', 'line', 3, 'orange', 'Classificação');



SELECT
  pf.*,
  ag.tipo_grafico,
  ag.agrupador_base,
  ag.cor,
  ag.ordem
FROM payload_padrao_formulario pf
LEFT JOIN atributo_grafico ag
  ON pf.cd_menu = ag.cd_menu AND pf.nm_atributo = ag.nm_atributo
WHERE pf.cd_menu = 8084
ORDER BY ag.ordem

