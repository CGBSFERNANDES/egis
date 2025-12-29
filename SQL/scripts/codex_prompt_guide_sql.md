# Guia de prompt para Codex (SQL Procedures)

## Regras de economia (para não estourar cota)
- 1 microtarefa = 1 procedure por rodada
- Patch mínimo: nada de refatorar o banco todo
- Sempre peça "mostre apenas o diff" quando possível
- Sempre forneça: procedure atual + objetivo + critérios

## Prompt padrão (copie e cole)
```
SQL Server 2016. Stored procedure: dbo.<proc>.

Objetivo:
- aplicar padrão oficial: NOCOUNT, XACT_ABORT, TRY/CATCH
- último resultset com status HTTP (sucesso/codigo/mensagem)
  - 200 OK, 400 validação, 404 não encontrado, 500 erro interno

Restrições:
- patch mínimo
- manter comportamento funcional e os SELECTs de dados existentes
- alterar somente esta procedure
- não criar índices a menos que eu peça explicitamente

Entregue:
- script completo da procedure OU diff das alterações
```

## Prompt para otimização pontual (copie e cole)
```
SQL Server 2016. Otimize apenas a query X dentro da procedure dbo.<proc>.
Cenário de teste: (cole o EXEC + parâmetros).
Métrica: reduzir logical reads e tempo, mantendo o mesmo resultado.
Sugira no máximo 1 índice opcional com script de rollback.
Mostre apenas o diff e explique o porquê em 5 bullets.
```
