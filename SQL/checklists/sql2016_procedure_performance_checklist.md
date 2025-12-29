# Checklist de performance (SQL Server 2016) - Procedures

## Antes de mexer
- [ ] Capturar cenário de teste (parâmetros reais ou amostra representativa)
- [ ] Rodar baseline:
  - `SET STATISTICS IO, TIME ON;`
  - Executar a procedure 3x (descartar a 1ª se houver cache frio)
  - Anotar tempo médio e logical reads
- [ ] Confirmar se a lentidão é:
  - [ ] CPU (tempo alto, IO baixo)
  - [ ] IO (logical reads altos)
  - [ ] bloqueio/deadlock (waits/locks)

## Durante a análise
- [ ] Verificar SARGability (evitar funções na coluna filtrada)
- [ ] Checar JOINs: chaves, cardinalidade, filtros cedo
- [ ] Paginação: preferir `ORDER BY ... OFFSET/FETCH` quando aplicável
- [ ] Evitar `SELECT *`
- [ ] Usar parâmetros tipados corretos (NVARCHAR vs VARCHAR, tamanhos coerentes)

## Índices (se necessário)
- [ ] Propor no máximo 1 índice por microtarefa
- [ ] Justificar com a query alvo (colunas em WHERE/JOIN/ORDER BY)
- [ ] Incluir script de rollback (DROP INDEX)
- [ ] Atenção a impacto de escrita (mais índices = INSERT/UPDATE mais caros)

## Depois da mudança
- [ ] Rodar novamente `STATISTICS IO, TIME`
- [ ] Comparar antes/depois (tempo e reads)
- [ ] Garantir mesma saída funcional (mesmas colunas/linhas)
- [ ] Garantir retorno do status HTTP como último resultset
