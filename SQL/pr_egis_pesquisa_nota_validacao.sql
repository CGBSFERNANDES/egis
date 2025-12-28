--BANCO DO CLIENTE
--USE EGISSQL_341
--GO
--use egissql_371

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_pesquisa_nota_validacao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_pesquisa_nota_validacao

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_pesquisa_nota_validacao
-------------------------------------------------------------------------------
--pr_egis_pesquisa_nota_validacao
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EGISSQL
--
--Objetivo         : Pesquisa de Dados da Nota Validação 
--
--Data             : 22.04.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_pesquisa_nota_validacao
@cd_nota_saida int = 0

--with encryption


as

set @cd_nota_saida = isnull(@cd_nota_saida,0)

declare @dt_hoje datetime  
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)         
  
if @cd_nota_saida = 0 
begin  
  select 'Parâmetros inválidos !' as Msg  
  return  
end  

----------------------------------------------------------------------------------------------------------    
declare @cd_parametro              int = 0
declare @cd_usuario                int = 0
declare @cd_empresa                int = 0
declare @cd_cliente                int = 0
declare @cd_tipo_destinatario      int = 0
declare @cd_vendedor               int = 0
declare @nm_email_vendedor         nvarchar(max) = ''
declare @ic_nfe_email              char(1)       = 'N'

set @cd_empresa = dbo.fn_empresa()

--Dados do Servidor NFe para verificar se gera os dados para o email--

select
  @ic_nfe_email = isnull(ic_nfe_email,'S')
from
  egisadmin.dbo.nfe_empresa
where
  cd_empresa = @cd_empresa

  --select @ic_nfe_email




--Dados da Nota Fiscal--------------------------------------------------------------

select
  @cd_cliente           = isnull(n.cd_cliente,0),
  @cd_usuario           = isnull(n.cd_usuario,0),
  @cd_tipo_destinatario = isnull(n.cd_tipo_destinatario,0),
  @cd_vendedor          = isnull(n.cd_vendedor,0)

from
  nota_saida n

where
  n.cd_nota_saida = @cd_nota_saida


--Contatos para Envio do Email do XML-------------------------------------------------

/*
select 
  cd_tipo_destinatario,
  cd_destinatario,
  Contato,
  Email,
  cd_ddd_celular,
  cd_celular

from 
  vw_destinatario_contato_nfe

where
  cd_tipo_destinatario = @cd_tipo_destinatario and
  cd_destinatario      = @cd_cliente 

order by
   Contato

*/

--Servidor de Email--

--insert into config_servidor_email
--select * from egissql_317.dbo.config_servidor_email

--update config_servidor_email
--set
--  cd_empresa = 273


select
   @cd_empresa as cd_empresa,
   u.cd_usuario,
  case when isnull(ue.nm_email_usuario,'')<>'' and ue.nm_email_usuario <> isnull(u.nm_email_usuario,'') 
  then
   ue.nm_email_usuario
   else
   u.nm_email_usuario
   end                                        nm_email_usuario,
   ue.cd_senha_email_usuario,
   ue.nm_servidor_email,
   isnull(ue.ic_autenticacao,'N') as ic_autenticacao,
   isnull(ue.qt_porta_envio,0)     as qt_porta_envio,
   isnull(ue.ic_tls, 'N') as ic_tls

into 
  #DadosEmail

from
   egisadmin.dbo.Usuario u with (nolock) 
   left outer join egisadmin.dbo.Usuario_Email ue on ue.cd_usuario_email = u.cd_usuario and
                                                     isnull(ue.cd_empresa,0) = case when isnull(ue.cd_empresa,0)=0  then isnull(ue.cd_empresa,0) else @cd_empresa end

   
where
   u.cd_usuario = @cd_usuario 


--Vendedor--

        SELECT @cd_tipo_destinatario as cd_tipo_destinatario,
               @cd_cliente           as cd_destinatario,
               nm_vendedor           as Contato,
               nm_email_vendedor     as Email,
               cd_ddd_vendedor       as cd_ddd_celular,
               cd_celular            as cd_celular
        into #Vendedor
        FROM Vendedor
        WHERE cd_vendedor = @cd_vendedor
        and
        isnull(nm_email_vendedor,'')<>''
        and isnull(ic_nfe_vendedor,'N') = 'S'


--select * from parametro_faturamento


--Nota_Saida_Email
--select * from nota_saida_email

--Usuário--
--select * from NFe_email_usuario

 SELECT @cd_tipo_destinatario          as cd_tipo_destinatario,
               @cd_cliente             as cd_destinatario,
               u.nm_usuario            as Contato,
               n.nm_email_usuario      as Email,
               cast('' as varchar(4))  as cd_ddd_celular,
               cd_celular_usuario      as cd_celular
        into #Usuario
        FROM NFe_email_usuario n
             inner join egisadmin.dbo.usuario u on u.cd_usuario = @cd_usuario
        WHERE
           u.cd_usuario = @cd_usuario
           and
           isnull(u.ic_ativo,'A') = 'A'
           and
           isnull(n.nm_email_usuario,'')<>''
        
--select * from #Vendedor
--select * from #Contato


--select * from #Usuario

        --select * from egisadmin.dbo.usuario

--Contato

        SELECT cd_tipo_destinatario,
               cd_destinatario,
               Contato,
               Email,
               cd_ddd_celular,
               cd_celular
        into #Contato
        FROM vw_destinatario_contato_nfe
        WHERE cd_tipo_destinatario = @cd_tipo_destinatario
          AND cd_destinatario      = @cd_cliente
       
        union select * from #Vendedor
        union select * from #Usuario

        order by
           Contato


--select * from #Contato

        
--select * from vw_nfe_emitente_nota_fiscal where cd_nota_saida = 4

--select * from config_servidor_email


--select * from nota_validacao

SELECT
  nv.ds_xml_nota, 
  nv.cd_chave_acesso, 
  --Empresa
  @cd_empresa                         as cd_empresa,
  --Dados do Destinatatário--
  n.nm_razao_social_nota,
  n.nm_fantasia_nota_saida,
  n.vl_total,
  'R$ ' + dbo.fn_formata_valor( n.vl_total )  as nm_total,
  'Nota: '+cast(n.cd_identificacao_nota_saida as varchar(20)) +
  ' - '+n.cd_chave_acesso +
  ' - '+e.xNome

                                              as nm_assunto_email,

  ds_mensagem = 'Segue a Nota Fiscal Eletrônica No. '+cast(n.cd_identificacao_nota_saida as varchar(20)) + ', Danfe em PDF e arquivo xml correspondente.'
                +
                ' Razão Social : '+n.nm_razao_social_nota
                +
                ' Valor Total R$ '+ 'R$ ' + dbo.fn_formata_valor( n.vl_total ),

  --Servidor de Email--
  case when isnull(s.nm_usuario_servidor_email,'')<>'' then
     s.nm_usuario_servidor_email
  else
    d.nm_email_usuario
  end                                       as nm_email_usuario,
  case when isnull(s.cd_senha_servidor_email,'')<>''   then
     s.cd_senha_servidor_email
  else
     d.cd_senha_email_usuario
  end                                        as cd_senha_email_usuario,
  case when isnull(s.nm_host_servidor_email,'')<>'' then
    s.nm_host_servidor_email
  else
    d.nm_servidor_email
  end                                        as nm_servidor_email,
  case when isnull(s.ic_autenticacao,'N')<>'' then
    s.ic_autenticacao
  else
    d.ic_autenticacao
  end                                        as ic_autenticacao,
  case when isnull(s.cd_smtp_servidor_email,0)>0 then
    s.cd_smtp_servidor_email
  else
     d.qt_porta_envio
  end                                        as qt_porta_envio,
  case when isnull(s.ic_tls,'')<>'' then
    s.ic_tls
  else
    d.ic_tls
  end                                         as ic_tls,
  isnull(s.ic_ssl,'N')                        as ic_ssl,

  (
        SELECT cd_tipo_destinatario,
               cd_destinatario,
               Contato,
               Email,
               cd_ddd_celular,
               cd_celular
        FROM #Contato
        WHERE cd_tipo_destinatario = @cd_tipo_destinatario
          AND cd_destinatario      = @cd_cliente
        ORDER BY Contato
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS Contato


FROM
  nota_validacao nv
  inner join nota_saida n                  on n.cd_nota_saida = nv.cd_nota_saida
  left outer join config_servidor_email s  on s.cd_empresa    = @cd_empresa
  left outer join #DadosEmail d            on d.cd_empresa    = @cd_empresa
  inner join vw_nfe_emitente_nota_fiscal e on e.cd_nota_saida = nv.cd_nota_saida

WHERE 
  nv.cd_nota_saida = @cd_nota_saida
  and
  ic_validada = 'S' and cd_status_validacao = 2
  and
  @ic_nfe_email = 'S'

go

--use egissql_372
--go

--select * from nota_saida
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_pesquisa_nota_validacao 22
------------------------------------------------------------------------------
--use egissql_273
--go
--select * from nota_validacao

--update
--  config_servidor_email
--  set
--   cd_empresa = 372

--select * from config_servidor_email
