
--Composição do Arquivo Mag.
exec dbo.pr_arquivo_magnetico  @ic_parametro=4,@cd_arquivo_magnetico=1,@cd_tipo_sessao=NULL,@cd_sessao_documento=NULL
go
--Campos da sessao 37 - primeira
exec pr_arquivo_magnetico @ic_parametro = 1, @cd_arquivo_magnetico = 1, @cd_tipo_sessao = 1, @cd_sessao_documento = 37 
go
exec pr_arquivo_magnetico @ic_parametro = 1, @cd_arquivo_magnetico = 1, @cd_tipo_sessao = 2, @cd_sessao_documento = 38 
go
exec pr_arquivo_magnetico @ic_parametro = 1, @cd_arquivo_magnetico = 1, @cd_tipo_sessao = 2, @cd_sessao_documento = 40 
go
exec pr_arquivo_magnetico @ic_parametro = 1, @cd_arquivo_magnetico = 1, @cd_tipo_sessao = 2, @cd_sessao_documento = 39

go
exec dbo.pr_arquivo_magnetico  @ic_parametro=2,@cd_arquivo_magnetico=1,@cd_tipo_sessao=NULL,@cd_sessao_documento=37



go
exec dbo.pr_arquivo_magnetico  @ic_parametro=3,@cd_arquivo_magnetico=1,@cd_tipo_sessao=1,@cd_sessao_documento=NULL
exec dbo.pr_arquivo_magnetico  @ic_parametro=3,@cd_arquivo_magnetico=1,@cd_tipo_sessao=2,@cd_sessao_documento=NULL


go
exec dbo.pr_arquivo_magnetico  @ic_parametro=6,@cd_arquivo_magnetico=1,@cd_tipo_sessao=NULL,@cd_sessao_documento=37
go

exec dbo.pr_arquivo_magnetico  @ic_parametro=6,@cd_arquivo_magnetico=1,@cd_tipo_sessao=NULL,@cd_sessao_documento=38

go

exec dbo.pr_atualiza_controle_numeracao_remessa  @cd_arquivo_magnetico=1,@ic_parametro=1,@cd_usuario=1

go
exec dbo.pr_arquivo_magnetico  @ic_parametro=5,@cd_arquivo_magnetico=NULL,@cd_tipo_sessao=NULL,@cd_sessao_documento=NULL








