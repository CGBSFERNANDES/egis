--acerto da tabela do enquadramento do IPI
--

ALTER TABLE Tributacao_IPI ADD cd_cenq_ipi VARCHAR (3) NULL 

go

update
 tributacao_ipi 
set
 cd_cenq_ipi = '999'

go



GO

ALTER TABLE dbo.Tributacao WITH NOCHECK ADD CONSTRAINT
	FK_Tributacao_Tributacao_IPI FOREIGN KEY
	(
	cd_tributacao_ipi
	) REFERENCES dbo.Tributacao_IPI
	(
	cd_tributacao_ipi
	) NOT FOR REPLICATION


go

ALTER TABLE dbo.Tributacao
	NOCHECK CONSTRAINT FK_Tributacao_Tributacao_IPI

go


delete from tributacao_Ipi
go

SELECT * FROM  tributacao_ipi
go

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (1, 'Entrada com recuperação de crédito', '00', 4, '2008-11-05 17:39:25', NULL, NULL, NULL, '999')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (2, 'Outras Entradas', '49', 4, '2008-11-05 17:39:34', NULL, NULL, NULL, '999')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (3, 'Saída Tributada', '50', 4, '2010-03-09 07:47:59', NULL, '1', NULL, '999')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (4, 'Outras Saídas', '99', 4, '2008-11-05 17:40:09', NULL, NULL, NULL, '999')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (5, 'Entrada Tributada com alíquota Zero', '01', 4, '2008-11-05 17:49:48', NULL, NULL, NULL, '999')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (6, 'Entrada Isenta', '02', 4, '2016-01-04 11:46:29', NULL, NULL, NULL, '301')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (7, 'Entrada não-tributada', '03', 4, '2008-11-05 17:50:08', NULL, NULL, NULL, '999')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (8, 'Entrada Imune', '04', 4, '2016-01-04 11:46:46', NULL, NULL, NULL, '001')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (9, 'Entrada com Suspensão', '05', 4, '2016-01-04 11:46:55', NULL, NULL, NULL, '101')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (10, 'Saída Tributada com Alíquota Zera', '51', 4, '2008-11-05 17:50:50', NULL, NULL, NULL, '999')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (11, 'Saída Isenta', '51', 4, '2008-11-05 17:51:00', NULL, NULL, NULL, '999')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (12, 'Saida não-tributada', '53', 4, '2008-11-05 17:51:14', NULL, NULL, NULL, '999')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (13, 'Saída Imune', '54', 4, '2008-11-05 17:51:31', NULL, NULL, NULL, '999')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (14, 'Saída com Suspensão', '55', 4, '2016-01-04 11:50:16', NULL, NULL, NULL, '199')
GO

INSERT INTO dbo.Tributacao_IPI (cd_tributacao_ipi, nm_tributacao_ipi, cd_digito_tributacao_ipi, cd_usuario, dt_usuario, sg_tab_nfe_tributacao, ic_indicador_tributacao, ic_tipo_tributacao, cd_cenq_ipi)
VALUES (15, 'Saída Isenta 52', '52', 4, '2016-01-04 11:47:37', NULL, NULL, NULL, '399')
GO





