use egissql_192

go

drop table logServicoNFe

go

IF OBJECT_ID('logServicoNFe', 'U') IS NOT NULL
    DROP TABLE logServicoNFe;
GO

CREATE TABLE logServicoNFe (
    id_log INT IDENTITY(1,1) PRIMARY KEY,
    cd_nota_saida INT NOT NULL,
    ds_erro TEXT NULL,
    dt_ocorrencia DATETIME NULL,
    cd_usuario_inclusao INT NULL,
    dt_usuario_inclusao DATETIME NULL,
    cd_usuario INT NULL,
    dt_usuario DATETIME NULL
);
GO
