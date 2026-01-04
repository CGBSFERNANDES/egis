## O que foi feito
- ( ) Padronização de retorno HTTP (200/400/404/500) no último resultset
- ( ) TRY/CATCH + XACT_ABORT + NOCOUNT
- ( ) Ajuste pontual de performance (descrever)

## Issue vinculada
- Closes #

## Como testar
Cole aqui o script de validação (ou referencie o bloco da issue):
```sql
SET STATISTICS IO, TIME ON;
-- EXEC dbo.<proc> ...
SET STATISTICS IO, TIME OFF;
```

## Resultados (antes/depois)
- Tempo:
  - Antes:
  - Depois:
- Logical reads:
  - Antes:
  - Depois:

## Risco
- Baixo / Médio / Alto
- Observações:

## Checklist
- [ ] SQL Server 2016 compatível
- [ ] Último resultset é status (sucesso/codigo/mensagem)
- [ ] Em erro: sem transação aberta (rollback quando aplicável)
- [ ] Sem alteração funcional nos dados retornados
