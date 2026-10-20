-- ============================================================
-- SUP-001: Investigação de pagamentos duplicados
-- Objetivo: dimensionar, classificar e justificar os registros
-- afetados antes de qualquer correção.
-- ============================================================

-- Consulta 1: dimensionar volume por apólice
SELECT
    idApolice,
    COUNT(*) AS totalPagamentos,
    SUM(valor) AS valorTotal
FROM Pagamento
GROUP BY idApolice
ORDER BY totalPagamentos DESC;


-- Consulta 2: agrupar por referência externa
SELECT
    referenciaExterna,
    COUNT(*) AS ocorrencias,
    COUNT(DISTINCT idApolice) AS apolicesDistintas,
    COUNT(DISTINCT valor) AS valoresDistintos,
    COUNT(DISTINCT status) AS statusDistintos
FROM Pagamento
GROUP BY referenciaExterna
HAVING COUNT(*) > 1
ORDER BY ocorrencias DESC;
-- Consulta 3: comparação com investigação ingênua por valor
SELECT
    valor,
    COUNT(*) AS ocorrencias,
    GROUP_CONCAT(DISTINCT idApolice ORDER BY idApolice) AS apolices
FROM Pagamento
GROUP BY valor
HAVING COUNT(*) > 1
ORDER BY ocorrencias DESC;

-- Consulta 4: detalhar candidatos com evidência temporal
SELECT
    p.idPagamento,
    p.idApolice,
    p.referenciaExterna,
    p.valor,
    p.status,
    p.dataPagamento,
    TIMESTAMPDIFF(SECOND,
        MIN(p.dataPagamento) OVER (PARTITION BY p.referenciaExterna),
        p.dataPagamento) AS segundosDesdePrimeiro
FROM Pagamento p
WHERE p.referenciaExterna IN (
    SELECT referenciaExterna
    FROM Pagamento
    GROUP BY referenciaExterna
    HAVING COUNT(*) > 1
)
ORDER BY p.referenciaExterna, p.dataPagamento;

-- ============================================================
-- CONCLUSÃO DA INVESTIGAÇÃO
-- ------------------------------------------------------------
-- Duplicidade real:
--   Referência: TX-2024-0010
--   Apólice: 2
--   Registros: idPagamento 4, 5 e 6
--   Evidência:
--     - Mesma referência externa, mesmo valor, mesmo status.
--     - Janela temporal de 10 segundos entre o primeiro e o último.
--     - Assinatura de reprocessamento automático (falha de idempotência).
--
-- Caso ambíguo (recobrança legítima):
--   Referência: TX-2024-0030
--   Apólice: 4
--   Registros: idPagamento 10 (CONFIRMADO) e 11 (ESTORNADO)
--   Evidência:
--     - Mesma referência, mesmo valor, status diferentes.
--     - Janela temporal de 1 dia (86400 segundos).
--     - Assinatura de histórico: pagamento seguido de estorno.
--
-- Falsos positivos descartados:
--   Apólices: 1, 3 e 4 (parcial)
--   Motivo:
--     - Apólice 1: valor 400.00 aparece 3x, mas com referências
--       externas distintas. São parcelas mensais legítimas.
--     - Apólice 3: valor 800.00 aparece 3x, mas com referências
--       externas distintas. São parcelas mensais legítimas.
--     - Apólice 4: valor 600.00 aparece 2x, mas com status
--       diferentes. É histórico de estorno, não duplicidade.
--
-- Justificativa:
--   A investigação por valor produz falsos positivos porque
--   parcelas legítimas compartilham o mesmo valor. A chave
--   correta é a referência externa combinada com o status:
--   mesma referência + mesmo status = cópia (duplicidade);
--   mesma referência + status diferente = histórico (legítimo).
--   A janela temporal confirma a natureza de cada caso.
-- ============================================================
