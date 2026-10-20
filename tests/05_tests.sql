-- =========================================================
-- BLOCO 5: Validação antes do COMMIT
-- =========================================================
SELECT COUNT(*) AS totalDuplicados FROM Pagamento WHERE status = 'DUPLICADO';
SELECT COUNT(*) AS totalLegitimos FROM Pagamento WHERE referenciaExterna = 'TX-2024-0010' AND status = 'CONFIRMADO';
SELECT COUNT(*) AS totalAuditados FROM AuditoriaPagamento;
SELECT idApolice, status, COUNT(*) AS total FROM Pagamento WHERE idApolice IN (1, 3, 4) GROUP BY idApolice, status ORDER BY idApolice;

-- =========================================================
-- BLOCO 6: Efetivar a correção
-- =========================================================
COMMIT;

SET SQL_SAFE_UPDATES = 1;
