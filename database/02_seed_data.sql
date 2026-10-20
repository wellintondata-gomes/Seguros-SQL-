SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Pagamento;
TRUNCATE TABLE Apolice;
TRUNCATE TABLE Cliente;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO Cliente (nome, documento) VALUES 
	('Ana Souza', '5.555.555'), 
    ('Reginaldo Primo', '2.222.222'),
    ('Flavio Rufino', '7.777.777');
    
INSERT INTO Apolice (idCliente, numeroApolice, status, premio) VALUES 
	('1', 'AP-2024-0001', 'ATIVA', 1200.00),
    ('1', 'AP-2024-0002', 'ATIVA', 850.00),
    ('2', 'AP-2024-0003', 'ATIVA', 2400.00),
    ('3', 'AP-2024-0004', 'ENCERRADA', 600.00);
    
INSERT INTO Pagamento (idApolice,  referenciaExterna, valor, status, dataPagamento) VALUES
	(1, 'TX-2024-0001', 400.00, 'CONFIRMADO', '2024-01-10 10:00:00'),
    (1, 'TX-2024-0002', 400.00, 'CONFIRMADO', '2024-02-10 10:00:00'),
    (1, 'TX-2024-0003', 400.00, 'CONFIRMADO', '2024-03-10 10:00:00'),
    
    (2, 'TX-2024-0010', 850.00, 'CONFIRMADO', '2023-01-15 14:30:00'),
    (2, 'TX-2024-0010', 850.00, 'CONFIRMADO', '2023-01-15 14:30:05'),
    (2, 'TX-2024-0010', 850.00, 'CONFIRMADO', '2023-01-15 14:30:10'),
    
    (3, 'TX-2024-0020', 800.00, 'CONFIRMADO', '2024-01-20 09:00:00'),
    (3, 'TX-2024-0021', 800.00, 'CONFIRMADO', '2024-01-20 09:00:00'),
	(3, 'TX-2024-0022', 800.00, 'CONFIRMADO', '2024-01-20 09:00:00'),
    
    (4, 'TX-2024-0030', 600.00, 'CONFIRMADO', '2024-01-25 11:00:00'),
	(4, 'TX-2024-0030', 600.00, 'ESTORNADO', '2024-01-26 11:00:00');
    

