--Acerto da Tabela de Destinação do Produto----------------------------------------------------------------------------

--destinacao_produto

--select * from nfe_presenca_comprador

--select * from 




--SELECT * FROM Local_Operacao

--Local Operação

DELETE FROM Local_Operacao

GO

INSERT INTO dbo.Local_Operacao (cd_local_operacao, nm_local_operacao, sg_local_operacao, cd_usuario, dt_usuario)
VALUES (1, '1=Operação interna', '1', 4, '2014-01-07 11:46:30')
GO

INSERT INTO dbo.Local_Operacao (cd_local_operacao, nm_local_operacao, sg_local_operacao, cd_usuario, dt_usuario)
VALUES (2, '2=Operação interestadual', '2', 4, '2014-01-07 11:46:45')
GO

INSERT INTO dbo.Local_Operacao (cd_local_operacao, nm_local_operacao, sg_local_operacao, cd_usuario, dt_usuario)
VALUES (3, '3=Operação com exterior', '3', 4, '2014-01-07 11:46:48')
GO


--

--SELECT * FROM NFE_Formato_Impressao

DELETE FROM NFE_Formato_Impressao

GO


INSERT INTO dbo.NFE_Formato_Impressao (cd_formato_impressao, nm_formato_impressao, sg_formato_impressao, cd_usuario, dt_usuario)
VALUES (1, '0=Sem geração de DANFE', '0', 4, '2014-01-07 11:57:30')
GO

INSERT INTO dbo.NFE_Formato_Impressao (cd_formato_impressao, nm_formato_impressao, sg_formato_impressao, cd_usuario, dt_usuario)
VALUES (2, '1=DANFE normal, Retrato', '1', 4, '2014-01-07 11:57:53')
GO

INSERT INTO dbo.NFE_Formato_Impressao (cd_formato_impressao, nm_formato_impressao, sg_formato_impressao, cd_usuario, dt_usuario)
VALUES (3, '2=DANFE normal, Paisagem', '2', 4, '2014-01-07 11:58:04')
GO

INSERT INTO dbo.NFE_Formato_Impressao (cd_formato_impressao, nm_formato_impressao, sg_formato_impressao, cd_usuario, dt_usuario)
VALUES (4, '3=DANFE Simplificado', '3', 4, '2014-01-07 11:58:14')
GO

INSERT INTO dbo.NFE_Formato_Impressao (cd_formato_impressao, nm_formato_impressao, sg_formato_impressao, cd_usuario, dt_usuario)
VALUES (5, '4=DANFE NFC-e;', '4', 4, '2014-01-07 11:58:23')
GO

INSERT INTO dbo.NFE_Formato_Impressao (cd_formato_impressao, nm_formato_impressao, sg_formato_impressao, cd_usuario, dt_usuario)
VALUES (6, '5=DANFE NFC-e em mensagem eletrônica', '5', 4, '2014-01-07 11:58:34')
GO


--SELECT * FROM NFE_Forma_Emissao

GO

DELETE FROM NFE_Forma_Emissao
GO


INSERT INTO dbo.NFE_Forma_Emissao (cd_forma_emissao, nm_forma_emissao, sg_forma_emissao, cd_usuario, dt_usuario, nm_fantasia_emissao)
VALUES (1, '1=Emissão normal (não em contingência);', '1', 4, '2014-01-07 12:04:15', 'Normal')
GO

INSERT INTO dbo.NFE_Forma_Emissao (cd_forma_emissao, nm_forma_emissao, sg_forma_emissao, cd_usuario, dt_usuario, nm_fantasia_emissao)
VALUES (2, '2=Contingência FS-IA, com impressão do DANFE em formulário de segurança;', '2', 4, '2014-01-07 12:05:20', 'FS-IA')
GO

INSERT INTO dbo.NFE_Forma_Emissao (cd_forma_emissao, nm_forma_emissao, sg_forma_emissao, cd_usuario, dt_usuario, nm_fantasia_emissao)
VALUES (3, '3=Contingência SCAN (Sistema de Contingência do Ambiente Nacional', '3', 4, '2014-01-07 12:05:49', 'SCAN')
GO

INSERT INTO dbo.NFE_Forma_Emissao (cd_forma_emissao, nm_forma_emissao, sg_forma_emissao, cd_usuario, dt_usuario, nm_fantasia_emissao)
VALUES (4, 'Contingência DPEC (Declaração Prévia da Emissão em Contingência);', '4', 4, '2014-01-07 12:07:47', 'DPEC')
GO

INSERT INTO dbo.NFE_Forma_Emissao (cd_forma_emissao, nm_forma_emissao, sg_forma_emissao, cd_usuario, dt_usuario, nm_fantasia_emissao)
VALUES (5, 'Contingência FS-DA, com impressão do DANFE em formulário de segurança;', '5', 4, '2014-01-07 12:08:12', 'FS-DA')
GO

INSERT INTO dbo.NFE_Forma_Emissao (cd_forma_emissao, nm_forma_emissao, sg_forma_emissao, cd_usuario, dt_usuario, nm_fantasia_emissao)
VALUES (6, '6=Contingência SVC-AN (SEFAZ Virtual de Contingência do AN);', '6', 4, '2014-01-07 12:08:33', ' SVC-AN')
GO

INSERT INTO dbo.NFE_Forma_Emissao (cd_forma_emissao, nm_forma_emissao, sg_forma_emissao, cd_usuario, dt_usuario, nm_fantasia_emissao)
VALUES (7, '7=Contingência SVC-RS (SEFAZ Virtual de Contingência', '7', 4, '2014-01-07 12:08:48', 'SVC-RS')
GO

INSERT INTO dbo.NFE_Forma_Emissao (cd_forma_emissao, nm_forma_emissao, sg_forma_emissao, cd_usuario, dt_usuario, nm_fantasia_emissao)
VALUES (8, '9=Contingência off-line da NFC-e;', '9', 4, '2014-01-07 12:09:01', 'NFC-e')
GO



--SELECT * FROM NFE_Finalidade

delete from NFE_Finalidade


GO

INSERT INTO dbo.NFE_Finalidade (cd_finalidade_nfe, nm_finalidade_nfe, sg_finalidade_nfe, cd_usuario, dt_usuario)
VALUES (1, '1=NF-e normal;', '1', 4, '2014-01-07 12:11:48')
GO

INSERT INTO dbo.NFE_Finalidade (cd_finalidade_nfe, nm_finalidade_nfe, sg_finalidade_nfe, cd_usuario, dt_usuario)
VALUES (2, '2=NF-e complementar;', '2', 4, '2014-01-07 12:11:56')
GO

INSERT INTO dbo.NFE_Finalidade (cd_finalidade_nfe, nm_finalidade_nfe, sg_finalidade_nfe, cd_usuario, dt_usuario)
VALUES (3, '3=NF-e de ajuste;', '3', 4, '2014-01-07 12:12:07')
GO

INSERT INTO dbo.NFE_Finalidade (cd_finalidade_nfe, nm_finalidade_nfe, sg_finalidade_nfe, cd_usuario, dt_usuario)
VALUES (4, '4=Devolução/Retorno.', '4', 4, '2014-01-07 12:11:37')
GO




--SELECT * FROM NFE_Presenca_Comprador
GO


DELETE FROM NFE_Presenca_Comprador
GO

INSERT INTO dbo.NFE_Presenca_Comprador (cd_presenca, nm_presenca, sg_presenca, cd_usuario, dt_usuario)
VALUES (1, '0=Não se aplica (por exemplo, para a Nota Fiscal complementar ou de ajuste);', '0', 4, '2014-01-07 12:17:41')
GO

INSERT INTO dbo.NFE_Presenca_Comprador (cd_presenca, nm_presenca, sg_presenca, cd_usuario, dt_usuario)
VALUES (2, '1=Operação presencial;', '1', 4, '2014-01-07 12:18:16')
GO

INSERT INTO dbo.NFE_Presenca_Comprador (cd_presenca, nm_presenca, sg_presenca, cd_usuario, dt_usuario)
VALUES (3, '2=Operação não presencial, pela Internet;', '2', 4, '2014-01-07 12:18:29')
GO

INSERT INTO dbo.NFE_Presenca_Comprador (cd_presenca, nm_presenca, sg_presenca, cd_usuario, dt_usuario)
VALUES (4, '3=Operação não presencial, Teleatendimento;', '3', 4, '2014-01-07 12:18:37')
GO

INSERT INTO dbo.NFE_Presenca_Comprador (cd_presenca, nm_presenca, sg_presenca, cd_usuario, dt_usuario)
VALUES (5, '4=NFC-e em operação com entrega em domicílio;', '4', 4, '2014-01-07 12:18:46')
GO

INSERT INTO dbo.NFE_Presenca_Comprador (cd_presenca, nm_presenca, sg_presenca, cd_usuario, dt_usuario)
VALUES (6, '9=Operação não presencial, outros', '9', 4, '2014-01-07 12:18:54')
GO



--SELECT * FROM NFE_Indicador_IE
GO

DELETE FROM NFE_Indicador_IE
GO

INSERT INTO dbo.NFE_Indicador_IE (cd_indicador_IE, nm_indicador_IE, sg_indicador_IE, cd_usuario, dt_usuario)
VALUES (1, '1=Contribuinte ICMS (informar a IE do destinatário);', '1', 4, '2014-01-07 12:31:07')
GO

INSERT INTO dbo.NFE_Indicador_IE (cd_indicador_IE, nm_indicador_IE, sg_indicador_IE, cd_usuario, dt_usuario)
VALUES (2, '2=Contribuinte isento de Inscrição no cadastro de Contribuintes do ICMS;', '2', 4, '2014-01-07 12:31:25')
GO

INSERT INTO dbo.NFE_Indicador_IE (cd_indicador_IE, nm_indicador_IE, sg_indicador_IE, cd_usuario, dt_usuario)
VALUES (3, '9=Não Contribuinte, que pode ou não possuir Inscrição Estadual no Cadastro de Co', '9', 4, '2014-01-07 12:31:43')
GO

--SELECT * FROM Forma_Importacao
go

DELETE FROM Forma_Importacao

go
INSERT INTO dbo.Forma_Importacao (cd_forma_importacao, nm_forma_importacao, sg_forma_importacao, cd_usuario, dt_usuario)
VALUES (1, '1=Importação por conta própria', '1', 4, '2014-01-07 17:02:07')
GO

INSERT INTO dbo.Forma_Importacao (cd_forma_importacao, nm_forma_importacao, sg_forma_importacao, cd_usuario, dt_usuario)
VALUES (2, '2=Importação por conta e ordem', '2', 4, '2014-01-07 16:59:22')
GO

INSERT INTO dbo.Forma_Importacao (cd_forma_importacao, nm_forma_importacao, sg_forma_importacao, cd_usuario, dt_usuario)
VALUES (3, '3=Importação por encomenda', '3', 4, '2014-01-07 16:59:46')
GO


-------------------------------------------------------------Atualização de Tabelas-------------------------------------------------------------------

update
  destinacao_produto
set
  cd_presenca         = 6,
  ic_consumidor_final = 'N' 

go

update
  destinacao_produto
set
  ic_consumidor_final = 'S' 

where
  cd_destinacao_produto = 2

go

---------------------------------------------------------------------------------------------------------------------------------------------------

--select * from local_operacao

select * from grupo_operacao_fiscal

--interna

update
  grupo_operacao_fiscal
set
  cd_local_operacao = 1
where
  cd_digito_grupo in (1,5)

update
  grupo_operacao_fiscal
set
  cd_local_operacao = 2

where
  cd_digito_grupo in (2,6)

update
  grupo_operacao_fiscal
set
  cd_local_operacao = 3
where
  cd_digito_grupo in (3,7)