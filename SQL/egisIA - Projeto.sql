use egisadmin
go

CREATE TABLE Fila_EgisIA (
    cd_fila           INT IDENTITY(1,1) PRIMARY KEY,
    nm_banco_empresa  VARCHAR(100) NOT NULL,   -- banco onde está a empresa (igual nm_banco_empresa que você já usa)
    cd_empresa        INT          NOT NULL,
    cd_usuario        INT          NOT NULL,
    pergunta          NVARCHAR(MAX) NOT NULL,
    resposta          NVARCHAR(MAX) NULL,
    nm_status         VARCHAR(20)  NOT NULL DEFAULT 'PENDENTE', -- PENDENTE, PROCESSANDO, PROCESSADO, ERRO
    dt_criacao        DATETIME     NOT NULL DEFAULT GETDATE(),
    dt_processado     DATETIME     NULL
);

INSERT INTO Fila_EgisIA (nm_banco_empresa, cd_empresa, cd_usuario, pergunta)
VALUES (@nm_banco_empresa, @cd_empresa, @cd_usuario, @pergunta);


use egisadmin
go

select * from Fila_EgisIA

use egissql
go

CREATE TABLE Fila_EgisIA (
    cd_fila           INT IDENTITY(1,1) PRIMARY KEY,
    nm_banco_empresa  VARCHAR(100) NOT NULL,   -- banco onde está a empresa (igual nm_banco_empresa que você já usa)
    cd_empresa        INT          NOT NULL,
    cd_usuario        INT          NOT NULL,
    pergunta          NVARCHAR(MAX) NOT NULL,
    resposta          NVARCHAR(MAX) NULL,
    nm_status         VARCHAR(20)  NOT NULL DEFAULT 'PENDENTE', -- PENDENTE, PROCESSANDO, PROCESSADO, ERRO
    dt_criacao        DATETIME     NOT NULL DEFAULT GETDATE(),
    dt_processado     DATETIME     NULL
);

INSERT INTO Fila_EgisIA (nm_banco_empresa, cd_empresa, cd_usuario, pergunta)
VALUES (@nm_banco_empresa, @cd_empresa, @cd_usuario, @pergunta);

