# 💾 Scripts SQL - API de Notificações WhatsApp

Este repositório contém os scripts SQL responsáveis por alimentar a API de notificações WhatsApp desenvolvida para o sistema de gestão hospitalar baseado no **Tasy EMR (Philips)**. Através desses scripts, a base de dados gera automaticamente mensagens que são consumidas por uma API em Flask e enviadas via BLiP (Take) para beneficiários de um plano de saúde.

---

## 📦 Visão Geral

Este projeto é composto por:

- Criação da tabela principal de notificações (`API_BLIP_PAS`)
- Procedure para envio automatizado de lembretes de consulta
- Trigger para notificações de novos boletos emitidos
- Dados de teste para simulações
- Query para monitoramento do job agendado no banco

---

## 🗂️ Estrutura de diretórios

```
scrip_sql_api/
│
├── CREATE TABLE API_BLIP_PAS.sql           # Script para criação da tabela principal
├── INSERT TEST.sql                         # Script de inserção de dados de teste
├── job/
│   └── notificacao.log                     # Logs do job de notificações (exemplo)
├── procedures/
│   └── inserir_notificacoes_consulta.sql  # Procedure para inserir notificações baseadas em consultas agendadas
└── trigger/
    └── trg_notificacao_novo_boleto.sql    # Trigger para notificação automática de novos boletos emitidos
```

---

## Como usar

- Execute o script CREATE TABLE API_BLIP_PAS.sql para criar a tabela no banco Oracle.
- Crie as sequences necessárias, se aplicável (exemplo: SEQ_ZEK_NOTIFICACOES).
- Implemente a procedure inserir_notificacoes_consulta.sql no banco.
- Implemente a trigger trg_notificacao_novo_boleto.sql para automatizar notificações de boletos.
- Utilize o script de inserção para testar a tabela.
- Agende a execução da procedure conforme a rotina do ambiente (ex: via Oracle DBMS Scheduler).

---

## Requisitos e Dependências

- Banco de dados Oracle.
- Sequences associadas (ex: SEQ_ZEK_NOTIFICACOES).
- Funções auxiliares usadas na procedure (ex: pls_obter_dados_segurado, obter_desc_agenda).
- Pacotes customizados como pkg_date_formaters e wheb_usuario_pck.
- A aplicação Python API BLiP para consumo dos dados da tabela.

---


## 🧱 Estrutura dos Scripts

### 🗃️ `CREATE TABLE API_BLIP_PAS.sql`

Cria a tabela principal onde a API irá buscar os dados das notificações.

Campos principais:

- `NR_SEQ_SEGURADO`: ID do beneficiário
- `NR_SEQ_NOTIFICACAO`: ID da notificação
- `DS_MENSAGEM`: Texto da mensagem
- `CD_STATUS`: Status da notificação (1 = pendente, 2 = enviada, etc.)
- `DT_CRIACAO`: Data de criação do registro
- `DT_VISUALIZACAO`: Quando a mensagem foi lida (caso aplicável)
- `DS_TITULO`: Título da notificação
- `CD_PERMISSAO`: Controle de exibição (1 = permitido, 2 = bloqueado)

---

### 🔁 `procedures/inserir_notificacoes_consulta.sql`

Procedure `inserir_notificacoes_consulta` que insere registros automaticamente com base nas consultas agendadas para o **dia seguinte**. Utiliza funções auxiliares do próprio Tasy:

- `pls_obter_dados_segurado`
- `obter_desc_agenda`
- `obter_data_agenda_consulta`
- `pkg_date_formaters.to_varchar`

> Esta procedure pode ser agendada por um `JOB` Oracle, rodando diariamente.

---

### 🚨 `trigger/trg_notificacao_novo_boleto.sql`

Trigger `trg_notificacao_novo_boleto` que roda após a inserção de um novo `titulo_receber` (boleto), verificando se o CPF está vinculado a um segurado e inserindo notificações personalizadas tanto para o app quanto para a API.

Inclui:

- Validação de `cd_pessoa_fisica`
- Inserção de mensagem customizada com data de emissão e vencimento
- Dupla inserção: `zek_app_notificacoes` e `api_blip_pas`

---

### 🧪 `INSERT TEST.sql`

Script para inserir um exemplo de notificação manualmente, útil para testes da API localmente.

---

### 🕒 `job.sql`

Consulta simples que lista jobs Oracle ativos relacionados a essa integração:

```sql
SELECT job, what, TO_CHAR(next_date, 'DD/MM/YYYY HH24: MI : SS') AS proxima_execucao, broken
FROM user_jobs
WHERE UPPER(what) LIKE '%CONSULTA%';
```

---

## 👨‍💻 Autor

**João Leal**  
Analista de Sistemas 

📧 joaovictorl3@outlook.com  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-perfil-blue?logo=linkedin)](https://www.linkedin.com/in/joao-leal-ti/)


---

🔗 Integração com API
Estes scripts fazem parte de uma solução maior, integrada com a seguinte API:

https://github.com/BlackSouza1337/notificacao_api

🛠️ **Rafael Souza** – Desenvolvedor da API e integração completa

---

## 📄 Licença

MIT License

Copyright (c) 2025 jaovleal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
