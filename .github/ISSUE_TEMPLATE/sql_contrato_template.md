# sql_contrato.md — Template (SQL Server 2016 / Codex)

> **Uso:** Copie este arquivo para cada demanda e preencha **todos** os campos antes de enviar ao Codex/ChatGPT.  
> **Regra de ouro:** o Codex **não pode adivinhar** tabelas, colunas, regras ou joins.

---

## 0. Metadados da Demanda

- **Projeto:** [NOME_DO_PROJETO]
- **Ticket/ID:** [ID]
- **Autor (Solicitante):** [NOME]
- **Revisor (DBA/Tech Lead):** [NOME]
- **Data:** [AAAA-MM-DD]
- **Ambiente-alvo:** [DEV/HML/PRD]
- **Versão SQL Server:** 2016 (obrigatório)

---

## 1. Tipo de Entrega

Marque com `x`:

- [ ] Stored Procedure (Procedure)
- [ ] Function (Scalar)
- [ ] Function (Table-Valued)
- [ ] View
- [ ] Script de alteração (DDL/DML)
- [ ] Otimização/Refatoração
- [ ] Correção de bug

**Nome do objeto (padrão do projeto):**  
- `pr_` / `usp_` / `ufn_` / `vw_` : `[NOME_DO_OBJETO_AQUI]`

---

## 2. Objetivo (Funcional)

Descreva **em uma frase** o que deve acontecer.

- **Objetivo:**  
  [DESCREVA O QUE A ROTINA DEVE FAZER]

---

## 3. Escopo

### 3.1 O que está incluído
- [ITEM 1]
- [ITEM 2]

### 3.2 O que NÃO está incluído (importante para não gerar retrabalho)
- [ITEM 1]
- [ITEM 2]

---

## 4. Entradas e Saídas

### 4.1 Parâmetros de entrada
| Parâmetro | Tipo | Obrigatório | Descrição | Exemplo |
|---|---|---:|---|---|
| @Parametro1 | INT | Sim/Não | [DESCRIÇÃO] | 123 |
| @Parametro2 | DATE | Sim/Não | [DESCRIÇÃO] | '2026-01-04' |

### 4.2 Saída (Resultado esperado)

**A) Retorno (SELECT) — colunas e tipos**  
> Se for relatório/consulta, liste todas as colunas. **Não deixe o Codex inventar.**

| Coluna | Tipo | Origem (tabela.coluna) | Observações |
|---|---|---|---|
| Coluna1 | VARCHAR(50) | dbo.TabelaA.CampoX | [OBS] |
| Coluna2 | DECIMAL(18,2) | dbo.TabelaB.CampoY | [OBS] |

**B) Efeitos colaterais (INSERT/UPDATE/DELETE)**  
- Tabelas alteradas: [LISTAR]
- Colunas alteradas: [LISTAR]
- Regras de atualização: [LISTAR]

---

## 5. Regras de Negócio (Obrigatório)

Liste regras numeradas, objetivas e testáveis:

1. [REGRA 1]
2. [REGRA 2]
3. [REGRA 3]

**Regras de filtro (se houver):**
- Status válidos: [LISTAR]
- Período: [COMO CALCULAR / INCLUSIVO / EXCLUSIVO]
- Considerar nulos? [SIM/NÃO — COMO TRATAR]

---

## 6. Fontes de Dados (Tabelas/Views/Joins)

> **Obrigatório:** informe **nome exato** de cada tabela/view e **como** elas se relacionam.

### 6.1 Tabelas/Views envolvidas
| Objeto | Tipo | Leitura/Gravação | Observações |
|---|---|---|---|
| dbo.TabelaA | Tabela | Leitura | [OBS] |
| dbo.ViewB | View | Leitura | [OBS] |

### 6.2 Relacionamentos / Joins (explícitos)
- `dbo.TabelaA.CodCliente = dbo.TabelaB.CodCliente`
- [OUTROS JOINS]

### 6.3 Dicionário de Colunas (recomendado)
Cole aqui o “schema” mínimo (colunas relevantes) **ou** anexe a saída de `sp_help` / `INFORMATION_SCHEMA.COLUMNS`.

```text
[Tabela/View] - colunas relevantes:
- Campo1 (tipo) — descrição
- Campo2 (tipo) — descrição
```

---

## 7. Requisitos Técnicos (Obrigatório)

Marque com `x`:

- [x] Compatível com **SQL Server 2016** (não usar recursos acima)
- [x] `SET NOCOUNT ON`
- [x] `TRY...CATCH` com `THROW`
- [ ] Transação explícita (`BEGIN TRAN/COMMIT/ROLLBACK`) — **somente se necessário**
- [ ] Idempotência (criação/alteração segura do objeto)
- [ ] Sem cursor
- [ ] Sem tabelas temporárias
- [ ] Pode usar tabelas temporárias
- [ ] Pode usar CTE
- [ ] Pode usar tabela variável
- [ ] Pode usar `MERGE` (**evitar se não for obrigatório**)

**Padrão de nomenclatura:**
- Prefixos: `pr_` / `usp_` / `ufn_` / `vw_`
- Alias curtos e claros
- Comentários obrigatórios em blocos críticos

---

## 8. Performance e Volumetria

- Volume estimado de registros: [N]
- Tabelas com maior volume: [LISTAR]
- Índices relevantes existentes: [LISTAR OU “DESCONHECIDO”】【
- Tempo aceitável: [EX: < 5s / < 30s]
- Considerações: [EX: janela de execução, concorrência, lock]

---

## 9. Tratamento de Erros e Logs

- Como registrar erro (se existir tabela de log): [DESCREVER]
- Mensagens esperadas: [DESCREVER]
- Erros que devem abortar: [LISTAR]

---

## 10. Testes e Aceite

### 10.1 Casos de teste (mínimo 3)
1. **Cenário:** [DESCRIÇÃO]  
   **Entrada:** [PARAMS]  
   **Esperado:** [RESULTADO]

2. **Cenário:** [DESCRIÇÃO]  
   **Entrada:** [PARAMS]  
   **Esperado:** [RESULTADO]

3. **Cenário:** [DESCRIÇÃO]  
   **Entrada:** [PARAMS]  
   **Esperado:** [RESULTADO]

### 10.2 Critérios de aceite
- [ ] Compila sem erro
- [ ] Retorna exatamente as colunas definidas
- [ ] Regras de negócio atendidas
- [ ] Performance dentro do esperado
- [ ] Comentários/documentação presentes

---

## 11. Prompt de Execução para o Codex (Copiar/Colar)

> **Cole este bloco no Codex/ChatGPT junto com este contrato preenchido.**

```
Você é um especialista em T-SQL para Microsoft SQL Server 2016.
Gere o código do objeto solicitado exatamente conforme o sql_contrato.md preenchido.

Regras obrigatórias:
- NÃO invente tabelas, colunas, parâmetros, regras ou joins.
- Se faltar informação, responda com uma lista objetiva do que está faltando.
- Use SET NOCOUNT ON e TRY...CATCH com THROW.
- Entregue o script final pronto para execução (CREATE/ALTER) e com comentários.
```
