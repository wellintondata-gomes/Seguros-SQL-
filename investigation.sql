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
-- Duplicidade real: [preencher]
-- Caso ambíguo (recobrança legítima): [preencher]
-- Falsos positivos descartados: [preencher]
-- Justificativa: [preencher]
-- ============================================================