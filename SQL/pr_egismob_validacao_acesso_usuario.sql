USE EGISADMIN
GO

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egisnet_validacao_acesso_usuario' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egisnet_validacao_acesso_usuario

GO
 -------------------------------------------------------------------------------  
--sp_helptext pr_egisnet_validacao_acesso_usuario  
-------------------------------------------------------------------------------  
--GBS Global Business Solution Ltda                                        2018  
-------------------------------------------------------------------------------  
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016  
--Autor(es)        : Carlos Cardoso Fernandes  
--Banco de Dados   : EgisAdminr  
--Objetivo         : Validação de Acesso de Usuário - EgisNet  
--                   Portal  
--  
--Data             : 10.11.2018   
--Alteração        :   
-- 27.11.2018      : Colocação do email do usuário - Carlos Fernandes  
-- 23.03.2020      : Foto do Usuário - Carlos Fernandes  
-- 16.04.2020      : Acerto do retorno da Imagem - Carlos Fernandes  
-- 09.10.2020      : Verificação e Ajustes - Carlos Fernandes  
-- 19.10.2020      : ajuste da api - Código - Fabiano/Carlos/Luis  
-- 04.11.2020 - acerto do nome do módulo - Carlos Fernandes  
-- 19.05.2021 - Acesso automático no EgisNet - Mateus/Carlos  
-- 22.07.2021 - Vídeo do Módulo - Carlos Fernandes / Mateus
-- 12.10.2021 - Novo Flag para Chamar o Componente de Processo/Etapas do Pipeline do Módulo - Carlos Fernandes
-- 02.11.2021 - Verificar se o Login e Módulo deve dar acesso ao Operador de Chat/Atendimento - Carlos Fernandes
-- 29.10.2023 - Validação do Registro de Usuário - Carlos Fernandes
------------------------------------------------------------------------------------------------------------------------------------------------------------
--

create procedure pr_egisnet_validacao_acesso_usuario  
@cd_parametro        int      = 0,  --0 - Usuário/Padrão  
                                    --1 - Cliente  
                                    --2 - Fornecedores  
                                    --3 - Vendedores/Representantes  
                                    --4 - Visitates  (Outros)  
  
@nm_fantasia_usuario varchar(200)     = '',  
@cd_senha_usuario    char(10)         = '',  
@nm_email_usuario    varchar(200)     = '' ,  
@ic_tipo_senha       char(1)          = 'P',
@cd_contato          int              = 0

--@cd_empresa_selecao  int              = 0 
  
as  
  
if @cd_parametro is null or @cd_parametro = 0  
   set @cd_parametro = 0  
  
if @nm_email_usuario is null or @nm_email_usuario = ''  
   set @nm_email_usuario = ''  
  
set @cd_senha_usuario    = ltrim(rtrim(isnull(@cd_senha_usuario,'')))  
set @nm_fantasia_usuario = ltrim(rtrim(isnull(@nm_fantasia_usuario,'')))
set @nm_email_usuario    = ltrim(rtrim(isnull(@nm_email_usuario,'')))
set @ic_tipo_senha       = isnull(@ic_tipo_senha,'P')
set @cd_contato          = isnull(@cd_contato,0)

--set @cd_empresa_selecao = isnull(@cd_empresa_selecao,0)
  
--verificar se no nome do usuário foi passado o email....  
  
declare @cd_modulo  int  = 0
declare @qt_posicao int  = 0
declare @cd_usuario int  = 0
declare @url_usuario varchar(500) = ''

set @url_usuario = 'https://www.egisnet.com.br/img/pessoas.png'
set @qt_posicao = 0  
set @cd_modulo  = 0  
set @cd_usuario = 0
  
select @qt_posicao = isnull(CHARINDEX('@', @nm_fantasia_usuario ) ,0)  
  
if @qt_posicao>0  
   set @nm_email_usuario = ltrim(rtrim(@nm_fantasia_usuario))  
  
--busca dados do usuário pelo email--  

--select @nm_email_usuario

if @nm_email_usuario <> ''   
begin  
  
  print 'busca fantasia pelo email'  
  
  select top 1  
    @nm_fantasia_usuario = ltrim(rtrim(isnull(nm_fantasia_usuario,'')))  
 from  
    Usuario   
 where  
    upper(nm_email_usuario) = upper(@nm_email_usuario)  

 --select @nm_fantasia_usuario

 -- select 
 --    cd_usuario,
 --    ltrim(rtrim(isnull(nm_fantasia_usuario,'')))  
 --from  
 --   Usuario   
 --where  
 --   upper(nm_email_usuario) = upper(@nm_email_usuario)  

  --update
 --   usuario
 -- set
	--nm_email_usuario = 'x@gbstec.com.br'
 -- where 
 --   cd_usuario in ( 1478, 1661)


end  
  
set @nm_fantasia_usuario = upper(ltrim(ltrim(rtrim(@nm_fantasia_usuario))))  
set @cd_senha_usuario    = upper(ltrim(ltrim(rtrim(@cd_senha_usuario))))  
  
--usuario_imagem  
--select nm_caminho_imagem from usuario_imagem  
     
set dateformat mdy  
  
declare @vb_imagem          varbinary(max)  
declare @vb_base64          nvarchar(max)  
declare @dt_hoje            datetime  
  
set @dt_hoje    = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)      
  
  
--Usuário padrão do sistema----------------------------------------------------------------------------------  
  
  
if @cd_parametro=0   
begin  
  
  select
    top 1
    @cd_usuario = u.cd_usuario
  from
    usuario u
  where
     upper(ltrim(rtrim(u.nm_fantasia_usuario))) = upper(@nm_fantasia_usuario)  and  
     (ltrim(rtrim(upper(u.cd_senha_usuario)))   = @cd_senha_usuario  or  ltrim(rtrim(upper(u.cd_senha_repnet_usuario))) = @cd_senha_usuario )
     and  
     isnull(u.ic_ativo,'A')                     = 'A'  

  --select @cd_usuario

 -- select
 --   top 1
	----@vb_base64 = convert(nvarchar(max),u.vb_imagem) 
	--@vb_base64 = u.vb_imagem,
	--@vb_imagem = u.vb_imagem
 -- from 
 --   Usuario_Imagem_Portal u
 -- where
 --   u.cd_usuario = @cd_usuario

    if @cd_usuario>0
	begin
     select top 1 @vb_base64 = vb_imagem
     from openjson(
        (
        select top 1 vb_imagem
        from  Usuario_Imagem_Portal 
        where
		   cd_usuario = @cd_usuario		
        for json auto
        )
     ) with( vb_imagem varchar(max))

    end
	
	--select @vb_base64, @vb_imagem, convert(nvarchar(max),@vb_imagem)	  

   select   
     u.cd_usuario                                   as cd_controle,  
     u.cd_usuario,  
     upper(ltrim(rtrim(u.nm_fantasia_usuario)))     as nm_fantasia_usuario,  
	 u.nm_usuario,
     upper(ltrim(rtrim(u.cd_senha_usuario)))        as cd_senha_usuario,  
	 u.cd_celular_usuario,
	 ltrim(rtrim(u.nm_email_usuario))               as nm_email_usuario,

     --upper(ltrim(rtrim(u.cd_senha_repnet_usuario))) as cd_senha_usuario,  
  
     isnull(u.cd_idioma,1)                          as cd_idioma,  
     u.dt_nascimento_usuario,  
     isnull(u.ic_controle_aniversario,'N')       as ic_controle_aniversario,  
     u.cd_horario_acesso,  
     u.dt_ultimo_acesso_usuario                  as dt_ultimo_acesso,  
     isnull(u.cd_vendedor,0)                     as cd_vendedor,  
     @cd_parametro                               as cd_tipo_acesso,  
     ltrim(rtrim(isnull(u.nm_email_usuario,''))) as nm_usuario_email,  
     u.cd_usuario                                as cd_contato,  
     --Dados da empresa--  
     e.cd_empresa,  
     e.nm_banco_empresa,  
     e.nm_empresa,  
     e.nm_fantasia_empresa,  
     e.cd_cgc_empresa,  
     --------------------------------------------------------------------------  
     --Conexão  
     ------  
     isnull(ec.ip_acesso,'181.191.209.84')             as ip_acesso,  
     isnull(ec.serveradmin,'EGISADMIN')                as serveradmin,     
     isnull(ec.serversql,e.nm_banco_empresa)           as serversql,  
     isnull(ec.userSQL,'sa')                           as userSQL,  
     isnull(ec.senhaSQL,'sql@127')                     as senhaSQL,  
  
  
  
  ui.vb_imagem,  

  @vb_base64                                           as vb_base64,

  --dbo.fn_varbinary_base64(u.cd_usuario)              as vb_base64,  

  --( select top 1 convert(nvarchar(max), up.vb_imagem) from egisadmin.dbo.Usuario_Imagem_Portal up
  --where
  --   up.cd_usuario = u.cd_usuario)                      as vb_base64,

  --( select top 1 up.vb_imagem  from egisadmin.dbo.Usuario_Imagem_Portal up
  --  where
	 -- up.cd_usuario = u.cd_usuario )                    as vb_base64,
  
  --Dados Adicionais  
  isnull(u.ic_moeda_usuario,'N')                     as ic_moeda_usuario,  
  isnull(u.ic_dica_usuario,'N')                      as ic_dica_usuario,  
  isnull(u.ic_lista_aniversariantes,'S')             as ic_lista_aniversariantes,  
  upper(ltrim(rtrim(isnull(u.cd_senha_usuario,'')))) as cd_senha_acesso,  
  --upper(ltrim(rtrim(isnull(u.cd_senha_repnet_usuario,'')))) as cd_senha_acesso,  
  cast(0 as int)                                     as cd_tipo_destinatario,  
  cast(0 as int)                                     as cd_destinatario,  
  isnull(ue.cd_modulo,0)                             as cd_modulo,
  ar.cd_rota,
  ar.nm_identificacao_rota,
  isnull(( select top 1 mf.cd_api  
           from   
       modulo_funcao mf   
     where  
       mf.cd_modulo = ue.cd_modulo),0)         as cd_api,  
  --cast(0 as int)                                     as cd_api,  
  isnull(e.nm_logo_empresa,'')                       as nm_logo_empresa,  
  isnull(e.nm_caminho_logo_empresa,'')               as nm_caminho_logo_empresa,  
  m.nm_modulo,  
  isnull(m.nm_video_modulo,'')                       as nm_video_modulo,
     isnull( (select top 1 cd_menu from  
            Usuario_Acesso_Automatico ua  
            where  
      ua.cd_usuario_acesso = u.cd_usuario),0)         as cd_menu,
  isnull(m.ic_etapa_processo,'N')                     as ic_etapa_processo,
  isnull(u.ic_chat_usuario,'N')                       as ic_chat_usuario,
  ISNULL(ui.nm_caminho_imagem,@url_usuario)           as url_usuario,
  282                                                 as cd_modulo_start 
	    
  
   into #Usuario  
  
       --select * from usuario_imagem
       --usuario_imagem
  
   from  
     usuario u  
     inner join Usuario_Empresa ue      on ue.cd_usuario = u.cd_usuario and isnull(ic_acesso_padrao,'N')='S'  
     inner join Empresa e               on e.cd_empresa  = ue.cd_empresa   
     left outer join Empresa_Conexao ec on ec.cd_empresa = e.cd_empresa  
     left outer join Usuario_Imagem ui  on ui.cd_usuario = u.cd_usuario  
     left outer join modulo m           on m.cd_modulo   = ue.cd_modulo  
     left outer join Menu me            on me.cd_menu    = ue.cd_menu
	 left outer join API_Rota ar        on ar.cd_rota    = me.cd_rota
  
--select * from Usuario_Empresa  
  
  
   where  
     upper(ltrim(rtrim(u.nm_fantasia_usuario))) = upper(@nm_fantasia_usuario)  and  
     ltrim(rtrim(upper(u.cd_senha_usuario)))    = @cd_senha_usuario  
  --upper(ltrim(rtrim(u.cd_senha_repnet_usuario)))  = @cd_senha_usuario  
     and  
     isnull(u.ic_ativo,'A')                     = 'A'  

      
   --Egismob/Repnet-Aplicativo--  
  
   if not exists(select top 1 cd_usuario from #Usuario)  
   begin  

     insert into #Usuario  
     select  
       u.cd_usuario                                   as cd_controle,  
       u.cd_usuario,  
       upper(ltrim(rtrim(u.nm_fantasia_usuario)))     as nm_fantasia_usuario,  
	   u.nm_usuario,
       upper(ltrim(rtrim(u.cd_senha_repnet_usuario))) as cd_senha_usuario,  
  	   u.cd_celular_usuario,
	   ltrim(rtrim(u.nm_email_usuario))               as nm_email_usuario,
       isnull(u.cd_idioma,1)                          as cd_idioma,  
       u.dt_nascimento_usuario,  
       isnull(u.ic_controle_aniversario,'N')          as ic_controle_aniversario,  
       u.cd_horario_acesso,  
       u.dt_ultimo_acesso_usuario                     as dt_ultimo_acesso,  
       isnull(u.cd_vendedor,0)                        as cd_vendedor,  
       @cd_parametro                                  as cd_tipo_acesso,  
       upper(ltrim(rtrim(isnull(u.nm_usuario_email,''))))  
                                                      as nm_usuario_email,  
       u.cd_usuario                                   as cd_contato,  
       --Dados da empresa--  
       e.cd_empresa,  
       e.nm_banco_empresa,  
       e.nm_empresa,  
       e.nm_fantasia_empresa,  
       e.cd_cgc_empresa,  
       --------------------------------------------------------------------------  
       --Conexão  
       ------  
       isnull(ec.ip_acesso,'181.191.209.84')          as ip_acesso,  
       isnull(ec.serveradmin,'EGISADMIN')             as serveradmin,     
       isnull(ec.serversql,e.nm_banco_empresa)        as serversql,  
       isnull(ec.userSQL,'sa')                        as userSQL,  
       isnull(ec.senhaSQL,'sql@127')                  as senhaSQL,  
       ui.vb_imagem,  
       dbo.fn_varbinary_base64(u.cd_usuario)          as vb_base64,  
	--@vb_base64                                        as vb_base64,

       --Dados Adicionais  
    isnull(u.ic_moeda_usuario,'N')                 as ic_moeda_usuario,  
    isnull(u.ic_dica_usuario,'N')                  as ic_dica_usuario,  
    isnull(u.ic_lista_aniversariantes,'S')         as ic_lista_aniversariantes,      
--    upper(ltrim(rtrim(isnull(u.cd_senha_usuario,''))))  
--                                                   as cd_senha_acesso,  
  
    upper(ltrim(rtrim(isnull(u.cd_senha_repnet_usuario,''))))  
                                                   as cd_senha_acesso,  
      cast(0 as int)                                 as cd_tipo_destinatario,  
    cast(0 as int)                                 as cd_destinatario,  
    isnull(ue.cd_modulo,0)                         as cd_modulo, 
	ar.cd_rota,
    ar.nm_identificacao_rota,
--    cast(0 as int)                                as cd_api,  
     isnull(( select top 1 mf.cd_api  
           from   
       modulo_funcao mf   
     where  
       mf.cd_modulo = ue.cd_modulo),0)         as cd_api,  
  
       isnull(e.nm_logo_empresa,'')                       as nm_logo_empresa,  
    isnull(e.nm_caminho_logo_empresa,'')               as nm_caminho_logo_empresa,  
    m.nm_modulo,  
	isnull(m.nm_video_modulo,'')                       as nm_video_modulo,
    isnull( (select top 1 cd_menu from  
            Usuario_Acesso_Automatico ua  
            where  
      ua.cd_usuario_acesso = u.cd_usuario),0)           as cd_menu,
    isnull(m.ic_etapa_processo,'N')                     as ic_etapa_processo,
	isnull(u.ic_chat_usuario,'N')                       as ic_chat_usuario,
	ISNULL(ui.nm_caminho_imagem,@url_usuario)           as url_usuario,
	282                                                 as cd_modulo_start 
  
      
     from  
       usuario u  
       inner join Usuario_Empresa ue      on ue.cd_usuario = u.cd_usuario and isnull(ic_acesso_padrao,'N')='S'  
       inner join Empresa e               on e.cd_empresa  = ue.cd_empresa   
       left outer join Empresa_Conexao ec on ec.cd_empresa = e.cd_empresa  
       left outer join usuario_imagem ui  on ui.cd_usuario = u.cd_usuario  
       left outer join modulo m           on m.cd_modulo   = ue.cd_modulo
	   left outer join Menu me            on me.cd_menu    = ue.cd_menu
	   left outer join API_Rota ar        on ar.cd_rota    = me.cd_rota
  
--select * from Usuario_Empresa  
  
  
     where  
       ltrim(rtrim(upper(u.nm_fantasia_usuario)))     = upper(@nm_fantasia_usuario)  and  
       ltrim(rtrim(upper(u.cd_senha_repnet_usuario))) = @cd_senha_usuario  
       and  
       isnull(u.ic_ativo,'A')                     = 'A'  
  
    --select * from usuario  

   end     
     
     
  
   --Final--  
  
   if not exists(select top 1 cd_usuario from #Usuario)  
   begin  
   
     --Verifica se tem o Registro de Usuário Aguardando

	 select top 1  
       @nm_fantasia_usuario = ltrim(rtrim(isnull(nm_usuario,'')))  
     from  
       Registro_Usuario   
     where  
       upper(nm_email_usuario) = upper(@nm_email_usuario)  
	   or
	   upper(nm_usuario)       = upper(@nm_fantasia_usuario)

     --select @nm_fantasia_usuario  

     ---------------------------------------------------------
     --Verificar se Existe o Nome Fantasia de Login Cadastrado
	 ---------------------------------------------------------

	 if @nm_fantasia_usuario<>''
	 begin
       select   
	     top 1 
         isnull(ru.cd_usuario,ru.cd_registro)        as cd_usuario,  
         cast(1 as int)                              as cd_idioma,  
         cast(ru.nm_usuario as varchar(30))          as nm_fantasia_usuario,
		 ru.nm_usuario,
         cast(ru.nm_email_usuario as varchar(200))   as nm_email_usuario,  
         cast(ru.cd_senha_usuario as varchar(10))    as cd_senha_usuario,  
		 cast(case when ISNULL(ru.cd_telefone_usuario,'')<>'' then
		    ru.cd_telefone_usuario
		 else
 	        u.cd_celular_usuario
		 end as varchar(15))                         as cd_celular_usuario,
   	     --cast(ru.nm_email_usuario as varchar(150))   as nm_email_usuario,
         'Registro Aguardando Aprovação !'        as Mensagem,  
         cast(@cd_parametro as int)               as cd_tipo_acesso,   
         cast(ru.nm_email_usuario as varchar(200))   as nm_usuario_email,  
         cast(0 as int)                           as cd_contato,  
         cast(0 as int)                           as cd_vendedor,  
         @vb_imagem                               as vb_imagem,  
         @vb_base64                               as vb_base64,  
         cast(null as datetime)                   as dt_nascimento_usuario,  
         cast('N' as char(1))                     as ic_controle_aniversario,  
         cast(null as datetime)                   as dt_ultimo_acesso,  
         cast('N' as char(1))                     as ic_dica_usuario,  
         cast('N' as char(1))                     as ic_moeda_usuario,  
         cast('N' as char(1))                     as ic_lista_aniversariantes,
		 
         ----Dados da empresa--  
         e.cd_empresa,  
         e.nm_banco_empresa,  
         e.nm_empresa,  
         e.nm_fantasia_empresa,  
         e.cd_cgc_empresa

       ----------------------------------------------------------------------------  
       ----Conexão  
       --------  
       --isnull(ec.ip_acesso,'186.202.42.2')            as ip_acesso,  
       --isnull(ec.serveradmin,'EGISADMIN')             as serveradmin,     
       --isnull(ec.serversql,e.nm_banco_empresa)        as serversql,  
       --isnull(ec.userSQL,'sa')                        as userSQL,  
       --isnull(ec.senhaSQL,'sql@127')                  as senhaSQL,  


       from
	     Registro_Usuario ru
		 left outer join Empresa e on e.cd_empresa = ru.cd_empresa
		 left outer join Usuario u on u.cd_usuario = ru.cd_usuario

       where
	     upper(ru.nm_email_usuario) = upper(@nm_email_usuario)
  	     or
	     upper(ru.nm_usuario)       = upper(@nm_fantasia_usuario)
	 
	 end
	 else
	 begin

     --set @cd_parametro = 1  
     select   
     cast(0 as int)                  as cd_usuario,  
     cast(0 as int)                  as cd_idioma,  
     cast('' as varchar(30))         as nm_fantasia_usuario,
	 cast('' as varchar(60))         as nm_usuario,
     cast('' as varchar(200))        as nm_email_usuario,  
     cast('' as varchar(10))         as cd_senha_usuario,  
 	 cast('' as varchar(15))         as cd_celular_usuario,
	 cast('' as varchar(150))        as nm_email_usuario,
     'Registro não Localizado !'      as Mensagem,  
     cast(0 as int)                   as cd_tipo_acesso,   
     cast('' as varchar(200))         as nm_usuario_email,  
     cast(0 as int)                   as cd_contato,  
     cast(0 as int)                   as cd_vendedor,  
     @vb_imagem                       as vb_imagem,  
     @vb_base64                       as vb_base64,  
     cast(null as datetime)           as dt_nascimento_usuario,  
     cast('N' as char(1))             as ic_controle_aniversario,  
     cast(null as datetime)           as dt_ultimo_acesso,  
     cast('N' as char(1))             as ic_dica_usuario,  
     cast('N' as char(1))             as ic_moeda_usuario,  
     cast('N' as char(1))             as ic_lista_aniversariantes  
  
     end
  
--@nm_fantasia_usuario varchar(200)     = '',  
--@cd_senha_usuario    char(10)         = '',  
--@nm_email_usuario    varchar(200)     = '' ,  
     
   end  
   else  
   begin
   
     --02.11.2021--
     --verifica se o usuário é operador de Chat, e faz o Login na tabela de usuários disponíveis para atendimento--
     --ccf
	 --declare @cd_usuario int 

	 select 
	   @cd_usuario = isnull(cd_controle,0)
	 from
	    #Usuario
	 where
	    ic_chat_usuario = 'S' 

     --------------------------------------------------------------------------------------------------------------------------------------------------------
	 if @cd_usuario>0
	 begin
	   --1: Movimento, Usuário, Entrada
	   exec pr_registro_usuario_movimento_atendimento 1,@cd_usuario,1	    
	   ----------------------------------------------------------------
	   --print '1'
	 end

     --------------------------------------------------------------------------------------------------------------------------------------------------------
	 --Apresenta a Tabela Final com os Dados de Login
	 --
     select * from #Usuario      
     --------------------------------------------------------------------------------------------------------------------------------------------------------
   end       

end  
  
--Cliente-------------------------------------------------------------------------------  
  
if @cd_parametro=1  
begin  
  
 -- print @cd_parametro  
    
  select  
    a.cd_controle,  
    a.cd_empresa,  
    a.cd_cliente,  
    a.cd_contato,  
 --e.cd_empresa,  
    e.nm_banco_empresa,  
    e.nm_empresa,  
    e.nm_fantasia_empresa,  
    e.cd_cgc_empresa,  
    a.dt_ultimo_acesso,  
    ltrim(rtrim(a.cd_email_acesso))               as cd_email_acesso,   
     
    --Dados do Usuário--      
    --a.cd_controle                                 as cd_usuario,  
	a.cd_contato                                  as cd_usuario,
    ltrim(rtrim(a.nm_fantasia_contato))           as nm_fantasia_usuario,
	a.nm_fantasia_contato                         as nm_usuario,
    ltrim(rtrim(a.cd_senha_acesso))               as cd_senha_usuario,  
    cast('' as varchar(15))                       as cd_celular_usuario,
    cast('' as varchar(150))                      as nm_email_usuario,
    1                                             as cd_idioma,  
    @dt_hoje                                      as dt_nascimento_usuario,  
    'N'                                           as ic_controle_aniversario,  
    e.cd_horario_acesso,  
    @cd_parametro                                 as cd_tipo_acesso,  
    ltrim(rtrim(isnull(a.cd_email_acesso,'')))    as nm_usuario_email,  
    cast(0 as int)                                as cd_vendedor,  
       --------------------------------------------------------------------------  
       --Conexão  
       ------  
       isnull(ec.ip_acesso,'181.191.209.84')      as ip_acesso,  
       isnull(ec.serveradmin,'EGISADMIN')         as serveradmin,     
       isnull(ec.serversql,e.nm_banco_empresa)    as serversql,  
       isnull(ec.userSQL,'sa')                    as userSQL,  
       isnull(ec.senhaSQL,'sql@127')              as senhaSQL,  
       @vb_imagem                                 as vb_imagem,  
       @vb_base64                                 as vb_base64,  
       --Dados Adicionais  
    cast('N' as char(1))                       as ic_moeda_usuario,  
    cast('N' as char(1))                       as ic_dica_usuario,  
    cast('N' as char(1))                       as ic_lista_aniversariantes,  
    ltrim(rtrim(isnull(a.cd_senha_acesso,''))) as cd_senha_acesso,  
    isnull(220,0)                              as cd_modulo,  
    cast(0 as int)                             as cd_api,  
    isnull(e.nm_logo_empresa,'')                       as nm_logo_empresa,  
    isnull(e.nm_caminho_logo_empresa,'')               as nm_caminho_logo_empresa,  
    m.nm_modulo,  
	isnull(m.nm_video_modulo,'')                       as nm_video_modulo,
    cast(0 as int)                                     as cd_menu,  
    isnull(m.ic_etapa_processo,'N')                    as ic_etapa_processo,
	--'S'  as ic_etapa_processo,
	'N'                                                as ic_chat_usuario,
	ISNULL(e.nm_caminho_logo_empresa,@url_usuario)     as url_usuario,
	282                                                as cd_modulo_start 
     
  into #UsuarioCliente  
      
  from  
    acesso_portal_clientes a  
    inner join empresa e               on e.cd_empresa = a.cd_empresa  
    left outer join Empresa_Conexao ec on ec.cd_empresa = e.cd_empresa  
    left outer join modulo m           on m.cd_modulo   = 220   

	--select * from egisadmin.dbo.acesso_portal_clientes where cd_empresa = 3

  where  
    ltrim(rtrim(upper(a.nm_fantasia_contato)))  =  @nm_fantasia_usuario and      
    upper(a.cd_senha_acesso)                    =  @cd_senha_usuario    and  
    isnull(@nm_fantasia_usuario,'')<>''   
  
    
    
  if not exists(select top 1 cd_usuario from #UsuarioCliente)  
     set @cd_parametro = 2  
  else  
     --select @cd_parametro
     select * from #UsuarioCliente     
  
--select * from acesso_portal_clientes  
    
end  
  
--Fornecedores--  
  
if @cd_parametro=2  
begin  
  
  --print @cd_parametro  

  --select @cd_parametro
      
  select  
    a.cd_controle,  
    a.cd_empresa,  
    a.cd_fornecedor,  
    a.cd_contato_fornecedor                       as cd_contato,  
    e.nm_banco_empresa,  
    e.nm_empresa,  
    e.nm_fantasia_empresa,  
    e.cd_cgc_empresa,  
    a.dt_ultimo_acesso,  
    ltrim(rtrim(a.cd_email_acesso))               as cd_email_acesso,  
    --Dados do Usuário--      
    --a.cd_controle                                 as cd_usuario,  
	a.cd_contato_fornecedor                       as cd_usuario,  
    ltrim(rtrim(a.nm_fantasia_contato))           as nm_fantasia_usuario,  
	a.nm_fantasia_contato                         as nm_usuario,
    ltrim(rtrim(a.cd_senha_acesso))               as cd_senha_usuario,  
 	 cast('' as varchar(15))                      as cd_celular_usuario,
	 cast('' as varchar(150))                     as nm_email_usuario,

    1                                             as cd_idioma,  
    @dt_hoje                                      as dt_nascimento_usuario,  
    'N'                                           as ic_controle_aniversario,  
    e.cd_horario_acesso,  
    @cd_parametro                                 as cd_tipo_acesso,  
    ltrim(rtrim(isnull(a.cd_email_acesso,'')))    as nm_usuario_email,  
    cast(0 as int)                                as cd_vendedor,  
       --------------------------------------------------------------------------  
       --Conexão  
       ------  
       isnull(ec.ip_acesso,'181.191.209.84')      as ip_acesso,  
       isnull(ec.serveradmin,'EGISADMIN')         as serveradmin,     
       isnull(ec.serversql,e.nm_banco_empresa)    as serversql,  
       isnull(ec.userSQL,'sa')                    as userSQL,  
       isnull(ec.senhaSQL,'sql@127')              as senhaSQL,  
    @vb_imagem                                 as vb_imagem,  
    @vb_base64                                 as vb_base64,  
     --Dados Adicionais  
    cast('N' as char(1))                       as ic_moeda_usuario,  
    cast('N' as char(1))                       as ic_dica_usuario,  
      cast('N' as char(1))                       as ic_lista_aniversariantes,  
    ltrim(rtrim(isnull(a.cd_senha_acesso,''))) as cd_senha_acesso,  
    isnull(219,0)                              as cd_modulo,
	isnull(m.nm_video_modulo,'')               as nm_video_modulo,  
    cast(0 as int)                             as cd_api,  
    isnull(e.nm_logo_empresa,'')               as nm_logo_empresa,  
    isnull(e.nm_caminho_logo_empresa,'')       as nm_caminho_logo_empresa,  
    m.nm_modulo,  
    cast(0 as int)                                 as cd_menu,
    isnull(m.ic_etapa_processo,'N')                as ic_etapa_processo,
    'N'                                            as ic_chat_usuario,
	isnull(e.nm_caminho_logo_empresa,@url_usuario) as url_usuario,
	282                                            as cd_modulo_start 
   
  into #UsuarioFornecedor  
  from  
    acesso_portal_fornecedores a  
    inner join empresa e               on e.cd_empresa = a.cd_empresa  
    left outer join Empresa_Conexao ec on ec.cd_empresa = e.cd_empresa  
    left outer join modulo m           on m.cd_modulo   = 219  

    --select * from acesso_portal_fornecedores  
   
  where  
    (ltrim(rtrim(upper(a.nm_fantasia_contato))) =  @nm_fantasia_usuario or ltrim(rtrim(upper(a.cd_email_acesso ))) =  upper(@nm_fantasia_usuario) )
	and      
    upper(a.cd_senha_acesso)                    =  @cd_senha_usuario    
    and isnull(@nm_fantasia_usuario,'')<>''   
  
  --select * from egisadmin.dbo.acesso_portal_fornecedores where cd_empresa = 3
  --select @cd_senha_usuario, @nm_fantasia_usuario
    
  select * from #UsuarioFornecedor  
    
    
  end  
  
--Vendedores-------------------------------------------------------------------------------  
  
if @cd_parametro=3  
begin  
  print @cd_parametro  
end  
  
--select * from usuario where cd_usuario = 113  
  


go

----------------------------------------------------------------------------------------------  
--Executando
----------------------------------------------------------------------------------------------  
--pr_egisnet_validacao_acesso_usuario 2,'carlos@gbstec.com.br','25022','carlos@gbstec.com.br',''
--
--pr_egisnet_validacao_acesso_usuario 1,'marcelcom@lufaed.com.br','57879','marcelcom@lufaed.com.br','P',0
--
--exec pr_egisnet_validacao_acesso_usuario 0,'carlos','@123','','P',0

--exec pr_egisnet_validacao_acesso_usuario 0,'Kelvin','123456789','','P',0
--exec pr_egisnet_validacao_acesso_usuario 0,'piantinokelvin27@gmail.com','123456789','','P',0
--exec pr_egisnet_validacao_acesso_usuario 0,'carloshij','hij101101','','P',0
--exec pr_egisnet_validacao_acesso_usuario 0,'deboras','dsd123','','P',0
--exec pr_egisnet_validacao_acesso_usuario 0,'carloshij','hij101101','','P',0
----------------------------------------------------------------------------------------------  

--exec pr_egisnet_validacao_acesso_usuario 0,'test review','ApplE9!41','','P',0

----------------------------------------------------------------------------------------------  

--select * from registro_usuario

----------------------------------------------------------------------------------------------  
--@cd_parametro        int      = 0,  --0 - Usuário/Padrão  
--                                    --1 - Cliente  
--                                    --2 - Fornecedores  
--                                    --3 - Vendedores/Representantes  
--                                    --4 - Visitates  (Outros)  
  
--@nm_fantasia_usuario varchar(200)     = '',  
--@cd_senha_usuario    char(10)         = '',  
--@nm_email_usuario    varchar(200)     = '' ,  
--@ic_tipo_senha       char(1)          = 'P',
--@cd_contato          int              = 0  
  
--@nm_fantasia_usuario varchar(200)     = '',  
--@cd_senha_usuario    char(10)         = '',  
--@nm_email_usuario    varchar(200)     = '' ,  
--@ic_tipo_senha       char(1)          = 'P'  
----------------------------------------------------------------------------------------------  


--select * from usuario_imagem

--update
--  usuario_imagem
--set
--  nm_caminho_imagem = 'https://www.egisnet.com.br/img/login.png'
--where
--  cd_usuario = 3787


--insert into usuario_imagem (cd_usuario, nm_caminho_imagem, vb_imagem ) values (3787,'https://www.egisnet.com.br/img/logi.png',cast('1' as varbinary))