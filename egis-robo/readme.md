# 🤖 Robo Sync Alpha – Validação NF-e / NFC-e

Este projeto implementa um **robô de sincronização em Node.js**, responsável por integrar
o **banco local do cliente (Alpha / Egissql)** com o **servidor de produção na nuvem (Egissql_334)**,
permitindo a **validação de NF-e / NFC-e** de forma segura, automática e confiável.

---

## 🎯 Objetivo

- Ler notas fiscais **pendentes de validação** no banco local do cliente (Alpha)
- Copiar os dados necessários da nota para o servidor de produção
- Criar registros na `Nota_Validacao` da nuvem para disparar o processo de validação
- Aguardar a validação oficial no servidor de produção
- **Devolver o resultado da validação** (status, protocolo, XML, erros) para o banco local

Tudo isso sem VPN, usando apenas **conexão direta SQL Server**.

---

## 🏗️ Arquitetura

