---
name: "Microtarefa SQL (Procedure)"
about: "Padronização/otimização de stored procedure (SQL Server 2016) com retorno HTTP padrão"
title: "[SQL][PROC] <nome_da_procedure> - <ação curta>"
labels: ["sql", "procedure"]
---

## Contexto
- Onde isso é usado? (tela/endpoint/job):
- Problema observado (tempo alto, timeout, erro, inconsistência):
- Evidência (prints/logs/tempo médio/p95, IO alto, deadlock, etc.):

## Escopo (obrigatório)
**Alterar apenas:**
- Procedure: `dbo.<nome_da_procedure>`

**Opcional (no máximo 1 item por microtarefa):**
- [ ] Criar/ajustar 1 índice (incluir script)
- [ ] Ajustar 1 query crítica dentro da procedure

**Não fazer nesta microtarefa:**
- [ ] Refatorar outras procedures
- [ ] Alterar regra de negócio
- [ ] Mudanças de layout/contrato no front

## Contrato de retorno (padrão)
- O **último resultset** deve ser sempre:
  - `sucesso` (bit)
  - `codigo` (int, HTTP: 200/400/404/500)
  - `mensagem` (nvarchar)

## Entradas / Saídas
**Parâmetros**
- Liste parâmetros e defaults relevantes.

**Dados retornados**
- Quais resultsets de dados existem antes do status? (descreva rapidamente)

## Critérios de aceite
- [ ] Mantém o comportamento funcional (mesmos dados/colunas para os mesmos inputs)
- [ ] Retorna status HTTP padronizado (último resultset)
- [ ] Compatível com SQL Server 2016
- [ ] Não deixa transação aberta em erro (TRY/CATCH + rollback quando necessário)

## Plano de validação (obrigatório)
Cole o script que será usado para validar antes/depois:

```sql
-- Baseline / validação
SET STATISTICS IO, TIME ON;

-- Exemplo:
-- DECLARE @json NVARCHAR(MAX) = N'{...}';
-- EXEC dbo.<nome_da_procedure> @json = @json;

SET STATISTICS IO, TIME OFF;
```

## Métrica de melhoria (se for otimização)
- Tempo alvo (ms) e cenário:
- Logical reads alvo:
- Observações sobre volume (linhas, cardinalidade, etc.):

## Risco e rollback
- Risco: Baixo / Médio / Alto
- Rollback:
  - [ ] Script para restaurar a procedure anterior
  - [ ] Se criou índice: script de DROP do índice
