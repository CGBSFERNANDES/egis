---
name: Menu – Engine Único
about: Criar ou ajustar menu usando o Engine Único (unicoFormEspecial.vue)
title: "[MENU] <cd_menu> - <nome_menu>"
labels: engine, menu
---

## Identificação
**Código do Menu (cd_menu):**  
**Nome do Menu:**  

## Tipo de Menu
- [ ] Padrão (100% Engine)
- [ ] Padrão com Hooks
- [ ] Especial (fora do Engine)

## Descrição Funcional
Descreva o que o menu faz do ponto de vista do negócio.

## Wrapper Vue (my_<cd_menu>.vue)
Informações para gerar ou ajustar o wrapper:

- Título do Menu:
- PageSize do Grid:
- Slots utilizados (se houver):
- Observações de UI:

## Hooks do Engine (se houver)
Liste apenas se existir regra especial.

Exemplo:
- `beforeFetchRows`: aplicar filtro `status = 'ATIVO'`
- `mapPayload`: adicionar `cd_empresa`

## Campos / Metadados
Liste os campos do menu.

Exemplo:
- `cd_objetivo` (PK, int)
- `descricao` (string, obrigatório)
- `status` (string, lookup STATUS)
- `dt_inicio` (date)
- `dt_fim` (date)

## Lookups
Liste apenas se houver.

Exemplo:
- `status` → STATUS
- `cd_empresa` → EMPRESA

## Backend / Procedures
Informe o que deve existir ou ser criado.

Exemplo:
- `sp_menu_<cd_menu>_list`
- `sp_menu_<cd_menu>_save`
- `sp_menu_<cd_menu>_del`

## Checklist de Pronto
- [ ] Wrapper `my_<cd_menu>.vue` criado
- [ ] Metadados cadastrados
- [ ] Listagem funcionando
- [ ] Inserir / Atualizar funcionando
- [ ] Excluir funcionando (se aplicável)
- [ ] Testado no Engine Único

## Observações Técnicas
Qualquer detalhe que o Codex **não deve assumir**.
