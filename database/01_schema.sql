DROP database IF EXISTS Segurosql ;

CREATE database Segurosql;

USE Segurosql;

DROP TABLE IF EXISTS Apolice;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Pagamento;

CREATE TABLE Cliente (
    idCliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    documento VARCHAR(20) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Apolice (
    idApolice INT PRIMARY KEY AUTO_INCREMENT,
    idCliente INT NOT NULL,
    numeroApolice VARCHAR(30) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL,
    premio DECIMAL(10,2) NOT NULL,
		CONSTRAINT fkApoliceCliente
			FOREIGN KEY (idCliente)
			REFERENCES Cliente(idCliente)
			ON DELETE RESTRICT
			ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Pagamento(
	idPagamento INT PRIMARY KEY AUTO_INCREMENT, 
    idApolice INT NOT NULL, 
    referenciaExterna VARCHAR(50) NOT NULL, 
    valor decimal(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL, 
    dataPagamento DATETIME NOT NULL, 
		CONSTRAINT fkPagamentoApolice 
			FOREIGN KEY (idApolice)
            REFERENCES Apolice(idApolice)
            ON DELETE RESTRICT 
            ON UPDATE CASCADE
) ENGINE=InnoDB;
