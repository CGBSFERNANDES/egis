--tabelas para chat--

--1. cadastrar no admin
--2. criar em todos os clientes
--3. EgisChat

--USE EGISCHAT
--GO

--use egissql_351
go

CREATE TABLE chat_mensagens (
  id_mensagem INT IDENTITY(1,1) PRIMARY KEY,
  id_usuario INT NOT NULL,
  texto NVARCHAR(MAX) NOT NULL,
  origem VARCHAR(20) NOT NULL, -- 'cliente' ou 'operador'
  empresa VARCHAR(50) NOT NULL,
  data_envio DATETIME DEFAULT GETDATE()
);


go

CREATE TABLE chat_atendimentos (
  id_atendimento INT IDENTITY(1,1) PRIMARY KEY,
  id_usuario_cliente INT NOT NULL,
  id_usuario_operador INT NULL, -- NULL enquanto não assumir
  status VARCHAR(20) NOT NULL DEFAULT 'pendente', -- 'pendente', 'atendendo', 'finalizado'
  empresa VARCHAR(50) NOT NULL,
  data_inicio DATETIME DEFAULT GETDATE(),
  data_fim DATETIME NULL
);

go

CREATE TABLE chat_usuarios (
  id_usuario INT IDENTITY(1,1) PRIMARY KEY,
  nome NVARCHAR(100) NOT NULL,
  empresa VARCHAR(50) NOT NULL,
  tipo VARCHAR(20) NOT NULL, -- 'cliente' ou 'operador'
  status VARCHAR(20) DEFAULT 'ativo' -- 'ativo', 'inativo'
);



go


-- Tabela de Mensagens do Chat
--CREATE TABLE chat_mensagens (
--  id_mensagem INT IDENTITY(1,1) PRIMARY KEY,
--  id_usuario INT NOT NULL,
--  texto NVARCHAR(MAX) NOT NULL,
--  origem VARCHAR(20) NOT NULL, -- 'cliente' ou 'operador'
--  empresa VARCHAR(50) NOT NULL,
--  data_envio DATETIME DEFAULT GETDATE()
--);

go

--select * from chat_mensagens


--select * from chat_atendimentos


-- Tabela de Controle de Atendimentos
--CREATE TABLE chat_atendimentos (
--  id_atendimento INT IDENTITY(1,1) PRIMARY KEY,
--  id_usuario_cliente INT NOT NULL,
--  id_usuario_operador INT NULL, -- NULL enquanto não for assumido
--  status VARCHAR(20) NOT NULL DEFAULT 'pendente', -- 'pendente', 'atendendo', 'finalizado'
--  empresa VARCHAR(50) NOT NULL,
--  data_inicio DATETIME DEFAULT GETDATE(),
--  data_fim DATETIME NULL
--);

go

-- (Opcional) Cadastro de Usuários para o chat
--select * from chat_usuarios

--CREATE TABLE chat_usuarios (
--  id_usuario INT IDENTITY(1,1) PRIMARY KEY,
--  nome NVARCHAR(100) NOT NULL,
--  empresa VARCHAR(50) NOT NULL,
--  tipo VARCHAR(20) NOT NULL, -- 'cliente' ou 'operador'
--  status VARCHAR(20) DEFAULT 'ativo'
--);

go

-- Procedure: Iniciar Atendimento

--exec sp_iniciar_atendimento

CREATE PROCEDURE sp_iniciar_atendimento
  @id_usuario_cliente INT,
  @empresa VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  -- Verifica se já existe atendimento pendente para esse cliente
  IF NOT EXISTS (
    SELECT 1 FROM chat_atendimentos
    WHERE id_usuario_cliente = @id_usuario_cliente AND status = 'pendente'
  )
  BEGIN
    INSERT INTO chat_atendimentos (id_usuario_cliente, empresa)
    VALUES (@id_usuario_cliente, @empresa);
  END
END

go

-- Procedure: Assumir Atendimento

CREATE PROCEDURE sp_assumir_atendimento
  @id_atendimento INT,
  @id_usuario_operador INT
AS
BEGIN
  UPDATE chat_atendimentos
  SET id_usuario_operador = @id_usuario_operador,
      status = 'atendendo'
  WHERE id_atendimento = @id_atendimento;
END

go

-- Procedure: Finalizar Atendimento
CREATE PROCEDURE sp_finalizar_atendimento
  @id_atendimento INT
AS
BEGIN
  UPDATE chat_atendimentos
  SET status = 'finalizado',
      data_fim = GETDATE()
  WHERE id_atendimento = @id_atendimento;
END

go

-- ALTER TABLE chat_mensagens
ALTER TABLE chat_mensagens ADD id_atendimento INT NULL;
go

ALTER TABLE chat_atendimentos
ADD avaliacao INT NULL, -- de 1 a 5
    comentario NVARCHAR(500) NULL;

	go

