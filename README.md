# Egis

## Descrição

Este projeto é um sistema web desenvolvido em Vue.js para gestão de processos, etapas, clientes e operações comerciais, com integração a APIs, recursos de Kanban, relatórios e funcionalidades avançadas de interface. O sistema é voltado para ambientes corporativos e utiliza componentes do Quasar Framework, DevExtreme DataGrid e integrações diversas.

---

## Requisitos

- **Node.js:** v14.21.3
- **NPM:** 6.14.18

> **Atenção:**
> O projeto **não é compatível** com versões superiores ao Node 16.x e NPM 7.x. O uso de versões mais recentes pode causar falhas na instalação de dependências ou no build do projeto.

---

## Variáveis de Ambiente

Crie um arquivo `.env` (ou `.env.local`) na raiz do projeto com as variáveis abaixo. Todas as chaves seguem o padrão `VUE_APP_*` exigido pelo Vue CLI para serem expostas ao front-end.

| Variável | Obrigatória | Descrição |
| --- | --- | --- |
| `VUE_APP_API_BASE` | Não (valor padrão: `https://egisnet.com.br/api`) | URL base para as requisições da API. Pode ser sobrescrita em tempo de execução pelo valor salvo em `localStorage` (`API_BASE`). |
| `VUE_APP_GOOGLE_API_KEY` | Sim | Chave da API do Google Maps usada pelos componentes de mapa. |
| `VUE_APP_CLIENT_ID` | Conforme uso | Client ID para integrações com a API da Alelo/Veloe. |
| `VUE_APP_CLIENT_SECRET` | Conforme uso | Client Secret para integrações com a API da Alelo/Veloe. |
| `VUE_APP_CONTRACT` | Conforme uso | Código de contrato utilizado nas consultas da integração Alelo/Veloe. |
| `VUE_APP_VERSION` | Não | Versão exibida na interface; preenchida automaticamente pelo script `scripts/update-build.js`. |
| `VUE_APP_BUILD` | Não | Número de build exibido na interface; preenchido automaticamente pelo script `scripts/update-build.js`. |

Exemplo de `.env` mínimo:

```env
VUE_APP_API_BASE=https://egisnet.com.br/api
VUE_APP_GOOGLE_API_KEY=coloque-sua-chave-aqui
```

---

## Instalação

```bash
npm install
```

---

## Scripts

- **Desenvolvimento (hot-reload):**
  ```bash
  npm run serve
  ```
- **Build para produção:**
  ```bash
  npm run build
  ```
- **Lint e correção de arquivos:**
  ```bash
  npm run lint
  ```

---

## Dependências Principais

- [Vue.js](https://vuejs.org/)
- [Quasar Framework](https://quasar.dev/)
- [DevExtreme DataGrid](https://js.devexpress.com/)
- [html2pdf.js v0.9.0](https://www.npmjs.com/package/html2pdf.js/v/0.9.0)

---

## Documentação de componentes

- [GlobalNotifyModal – guia de uso](docs/GlobalNotifyModal.md): como adicionar o modal de notificação global em telas existentes (inclui exemplo em `mostraUsuarioGrupo.vue`).

---

## Configuração

Para personalizar configurações adicionais, consulte a [documentação oficial do Vue CLI](https://cli.vuejs.org/config/).

---

## Observações

- Certifique-se de instalar todas as dependências antes de rodar o projeto.
- As variáveis `VUE_APP_VERSION` e `VUE_APP_BUILD` são atualizadas automaticamente sempre que os scripts `serve` ou `build` são executados.
- Para funcionalidades específicas (como geração de PDF), verifique se as dependências opcionais estão corretamente instaladas.

---
