SET SQL_SAFE_UPDATES = 0;

-- =========================================================
-- INICIANDO A TRANSAÇÃO 
-- =========================================================

START TRANSACTION; 

CREATE TABLE IF NOT EXISTS AuditoriaPagamento (
	idAuditoria INT PRIMARY KEY auto_increment,
    idPagamentoOriginal INT NOT NULL,
    idApolice INT NOT NULL,
    referenciaExterna VARCHAR (50) NOT NULL, 
    valor DECIMAL (10,2) NOT NULL, 
    statusOriginal VARCHAR (200) NOT NULL,
    dataPagamentoOriginal DATETIME NOT NULL,
    motivo  VARCHAR (200) NOT NULL,
    dataCorreca DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    executadoPor VARCHAR(50) NOT NULL
)ENGINE=InnoDB;

-- =========================================================
-- MOVENDO PARA TABELA DE AUDITORIA
-- =========================================================

DELETE FROM AuditoriaPagamento WHERE referenciaExterna = 'TX-2024-0010';

INSERT INTO AuditoriaPagamento (
    idPagamentoOriginal,
    idApolice,
    referenciaExterna,
    valor,
    statusOriginal,
    dataPagamentoOriginal,
    motivo,
    executadoPor
)
SELECT
    idPagamento,
    idApolice,
    referenciaExterna,
    valor,
    status,
    dataPagamento,
    'Duplicidade por reprocessamento - SUP-001',
    'dev_sustentacao'
FROM Pagamento
WHERE referenciaExterna = 'TX-2024-0010'
  AND status = 'CONFIRMADO'
  AND idPagamento > (
      SELECT MIN(idPagamento)
      FROM Pagamento
      WHERE referenciaExterna = 'TX-2024-0010'
        AND status = 'CONFIRMADO'
  );
  
-- =========================================================
-- BLOCO 4: Marcar duplicados na tabela original
-- =========================================================

-- Passo 1: capturar o menor idPagamento do grupo duplicado
SET @minIdDuplicado = (
    SELECT MIN(idPagamento)
    FROM Pagamento
    WHERE referenciaExterna = 'TX-2024-0010'
      AND status = 'CONFIRMADO'
);

-- Passo 2: marcar como DUPLICADO todos os registros do grupo,
-- exceto o primeiro (o menor id, que é o legítimo)

UPDATE Pagamento
SET status = 'DUPLICADO'
WHERE referenciaExterna = 'TX-2024-0010'
  AND status = 'CONFIRMADO'
  AND idPagamento > @minIdDuplicado;
