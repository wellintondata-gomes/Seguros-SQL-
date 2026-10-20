# SeguroSQL — Case de Sustentação e Correção de Dados

## Sobre o projeto
Este é um projeto de portfólio focado em desenvolvimento e sustentação de sistemas, simulando a resolução de um chamado técnico no setor de seguros. A solução implementa um fluxo completo de investigação, auditoria e correção de registros financeiros em duplicidade. O ambiente foi construído utilizando **MySQL** e o **MySQL Workbench**, com foco em integridade relacional, transações seguras e preservação de histórico.

## O Cenário (O Chamado SUP-001)
Um Desenvolvedor SQL Jr. recebe o chamado **SUP-001**. O sistema registrou pagamentos em duplicidade no histórico de uma apólice. O risco desse comportamento é grave: distorcer o volume financeiro, inflar relatórios de receita e fazer a diretoria tomar decisões baseadas em dados que não refletem a realidade.

## O Diagnóstico (A Investigação)
Para identificar se os registros eram de fato duplicados, a estratégia não foi investigar pelo valor (afinal, três parcelas de R$ 400 podem ser pagamentos legítimos e mensais). A abordagem correta foi cruzar a **referência externa** (o "código de transação" que confirma a origem do pagamento), o **status** e a **janela de tempo** (momento exato do registro). 

Através dessa investigação, foi possível detectar 3 pagamentos com o mesmo valor, mesma apólice e mesma referência externa, registrados num intervalo de poucos segundos. A análise temporal e de status foi o que separou as **duplicidades reais** (cópias idênticas em segundos) dos **falsos positivos** (como pagamentos legítimos e estornos registrados com dias de diferença).

## A Solução Técnica
A correção não apaga os dados. Preservar o histórico é fundamental, pois os registros contam uma história que precisa ser investigada para tratar a causa raiz, auditar e implementar melhorias no sistema. 

A estratégia adotada no script de correção (`04_fix.sql`) foi:
1. **Copiar os registros duplicados** para uma tabela de auditoria (`AuditoriaPagamento`).
2. **Marcar os registros originais** na tabela de pagamentos com o status `'DUPLICADO'` (soft delete).
3. **Isolar a correção em uma transação** com validações prévias (`START TRANSACTION` e `COMMIT`), garantindo idempotência e segurança.

## Decisões Técnicas e Aprendizados
*   **Preservação de Histórico (Soft Delete):** Registros financeiros não devem ser excluídos. Eles são evidências do problema e indicam onde melhorias devem ser implementadas.
*   **Idempotência:** O script executa um `DELETE` na tabela de auditoria antes do `INSERT`, permitindo que possa ser reexecutado várias vezes sem duplicar os dados de auditoria.
*   **Uso de `DECIMAL` em vez de `FLOAT`:** Em movimentações financeiras, a precisão não é um diferencial, é um requisito. O `DECIMAL` armazena o valor exato, garantindo que as somas e conciliações financeiras batam.
*   **Transações e Validação:** Uso de `START TRANSACTION` para garantir que, se as validações falharem, um `ROLLBACK` devolve o banco ao estado original.
*   **Contorno de Limitações do MySQL (Erros 1093 e 1175):** Uso de variáveis de sessão (`@minIdDuplicado`) para evitar conflito de UPDATE e SELECT na mesma tabela, e desativação temporária do *Safe Update Mode* para execução dos scripts.

## Como Executar
**Pré-requisitos:** MySQL 8.0+ e MySQL Workbench.

1. Execute `database/01_schema.sql` (cria as tabelas e chaves estrangeiras).
2. Execute `database/02_seed_data.sql` (popula o banco com dados fictícios e o cenário do problema).
3. Execute `investigation/03_investigation.sql` (mostra as consultas de investigação que isolam o problema).
4. Execute `fix/04_fix.sql` (aplica a correção de forma segura e idempotente).
5. Execute `tests/05_tests.sql` (valida se os registros corretos foram afetados e os legítimos preservados).

## Tecnologias
- MySQL 8.0
- MySQL Workbench
