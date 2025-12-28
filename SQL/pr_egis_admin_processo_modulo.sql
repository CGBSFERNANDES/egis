--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_admin_processo_modulo' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_admin_processo_modulo

GO

SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('pr_egis_admin_processo_modulo','P') IS NOT NULL
    DROP PROCEDURE pr_egis_admin_processo_modulo;
GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_admin_processo_modulo
-------------------------------------------------------------------------------
-- pr_egis_admin_processo_modulo
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : EgisAdmin ou Egissql - Banco do Cliente
--
--Objetivo         : Egis
--                   Modelo de Procedure com Processos
--
--Data             : 20.12.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure  pr_egis_admin_processo_modulo
------------------------
@json nvarchar(max) = ''
------------------------------------------------------------------------------
--with encryption


as

-- ver nível atual
--SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME();

-- se < 130, ajustar:
--ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130;

--return

--set @json = isnull(@json,'')

 SET NOCOUNT ON;
 SET XACT_ABORT ON;

 BEGIN TRY
 
 /* 1) Validar payload - parameros de Entrada da Procedure */
 IF NULLIF(@json, N'') IS NULL OR ISJSON(@json) <> 1
            THROW 50001, 'Payload JSON inválido ou vazio em @json.', 1;

 /* 2) Normalizar: aceitar array[0] ou objeto */
 IF JSON_VALUE(@json, '$[0]') IS NOT NULL
            SET @json = JSON_QUERY(@json, '$[0]'); -- pega o primeiro elemento


set @json = replace(
             replace(
               replace(
                replace(
                  replace(
                    replace(
                      replace(
                        replace(
                          replace(
                            replace(
                              replace(
                                replace(
                                  replace(
                                    replace(
                                    @json, CHAR(13), ' '),
                                  CHAR(10),' '),
                                ' ',' '),
                              ':\\\"',':\\"'),
                            '\\\";','\\";'),
                          ':\\"',':\\\"'),
                        '\\";','\\\";'),
                      '\\"','\"'),
                    '\"', '"'),
                  '',''),
                '["','['),
              '"[','['),
             ']"',']'),
          '"]',']') 


declare @cd_empresa           int
declare @cd_parametro         int
declare @cd_documento         int = 0
declare @cd_item_documento    int
declare @cd_usuario           int 
declare @dt_hoje              datetime
declare @dt_inicial           datetime 
declare @dt_final             datetime
declare @cd_ano               int = 0
declare @cd_mes               int = 0
declare @cd_modelo            int = 0
declare @cd_grupo_usuario     int = 0


----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano = year(getdate())
set @cd_mes = month(getdate())  

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end


--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

select                     

 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

--------------------------------------------------------------------------------------------

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo' 
select @cd_grupo_usuario       = valor from #json where campo = 'cd_grupo_usuario'

--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro         = ISNULL(@cd_parametro,0)
set @cd_usuario           = isnull(@cd_usuario,0)
set @cd_grupo_usuario     = isnull(@cd_grupo_usuario,0)

---------------------------------------------------------------------------------------------------------------------------------------------------------    


IF ISNULL(@cd_parametro,0) = 0
BEGIN

  select 
    'Sucesso'     as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final,
     @cd_usuario  AS cd_usuario


  RETURN;

END

--select * from tipo_destinatario

----------------------------------------------------------------------------------------------------
--Grupo de Usuários
--

if @cd_parametro = 1
begin
  --select @cd_empresa

  SELECT
    --cv.cd_cadeia_valor,
    --cv.nm_cadeia_valor,
    --m.cd_modulo,
    --m.nm_modulo,
    GU.cd_grupo_usuario,   
    GU.nm_grupo_usuario + ' (' + cast(GU.cd_grupo_usuario as varchar(10)) + ')' as nm_grupo_usuario,   
    UGU.cd_usuario  

FROM
 egisadmin.dbo.GrupoUsuario GU
 inner join egisadmin.dbo.Empresa_grupo_usuario eg      on eg.cd_grupo_usuario  = gu.cd_grupo_usuario

 left outer join egisadmin.dbo.Usuario_GrupoUsuario UGU on UGU.cd_grupo_usuario = GU.cd_grupo_usuario and
                                                           UGU.cd_usuario       = @cd_usuario        
                                                           
 --left outer join egisadmin.dbo.Modulo_GrupoUsuario mg    on mg.cd_grupo_usuario = gu.cd_grupo_usuario
 --left outer join egisadmin.dbo.Modulo m                  on m.cd_modulo         = mg.cd_modulo
 --left outer join egisadmin.dbo.Cadeia_Valor cv           on cv.cd_cadeia_valor  = m.cd_cadeia_valor


--select * from egisadmin.dbo.Modulo_GrupoUsuario
--select * from egisadmin.dbo.GrupoUsuario                                                           
--select * from egisadmin.dbo.Empresa_grupo_usuario                                                           
--select * from egisadmin.dbo.Usuario_GrupoUsuario

where
   eg.cd_empresa = case when @cd_empresa = 0 then eg.cd_empresa else @cd_empresa end
   --and
   --eg.cd_usuario = case when @cd_usuario = 0 then eg.cd_usuario else @cd_usuario end


ORDER BY
  GU.nm_grupo_usuario  

  return

end

----------------------------------------------------------------------------------------------------
--Usuários da Empresa
--

if @cd_parametro = 2
begin

  --Acessos--

  select
  distinct
  identity(int,1,1)                                                                                      as cd_controle,
  format(
  convert(datetime,left(convert(varchar,l.dt_log_acesso,121),10)+' 00:00:00',121),'dd/MM/yyyy')          as dt_log_acesso,
  max(FORMAT(l.dt_log_acesso, 'HH:mm:ss'))                                                               as hr_log_acesso,
  l.cd_usuario,
  l.cd_modulo,
  sum(case when l.sg_log_acesso = '0' then 1 else 0 end)                                                 as qt_entrada,
  sum(case when l.sg_log_acesso = '1' then 1 else 0 end)                                                 as qt_saida,

  sum(case when l.sg_log_acesso = '0' then 1 else 0 end) 
  -                                              
  sum(case when l.sg_log_acesso = '1' then 1 else 0 end)                                                 as qt_status,
  
  max(upper(u.nm_usuario))                                                                               as nm_usuario,
  max(upper(u.nm_fantasia_usuario))                                                                      as nm_fantasia_usuario,
  ( select top 1 ue.cd_empresa from egisadmin.dbo.Usuario_Empresa ue where ue.cd_usuario = l.cd_usuario )              as cd_empresa_acesso,
  max( isnull(m.nm_modulo,''))                                                                           as nm_modulo,
  max( isnull(m.sg_modulo,''))                                                                           as sg_modulo
  


  into
    #acesso

from
  egisadmin.dbo.LogAcesso l
 
  inner join egisadmin.dbo.usuario u          on u.cd_usuario  = l.cd_usuario
  inner join egisadmin.dbo.usuario_empresa ue on ue.cd_usuario = u.cd_usuario 
  left outer join egisadmin.dbo.modulo m      on m.cd_modulo   = l.cd_modulo 

  --select top 1000 * from logacesso

where
  --l.cd_modulo = 0
  --and
  l.dt_log_acesso>=@dt_hoje
  and
  isnull(l.cd_usuario,0)>0
  and
  l.cd_usuario = case when @cd_usuario = 0 then l.cd_usuario else @cd_usuario end
  and
  ue.cd_empresa = @cd_empresa

  --select * from egisadmin.dbo.LogAcesso l

group by
  convert(datetime,left(convert(varchar,l.dt_log_acesso,121),10)+' 00:00:00',121),
  l.cd_usuario,
  l.cd_modulo
  


  select 
    e.cd_empresa,
	e.nm_fantasia_empresa,
	u.cd_usuario,
	upper(u.nm_fantasia_usuario)               as nm_fantasia_usuario,
	max(u.nm_usuario)                          as nm_usuario,
	count(a.qt_entrada)                        as qt_entrada,
	MAX(a.hr_log_acesso)                       as hr_log_acesso,
	MAX(a.dt_log_acesso)                       as dt_log_acesso,
    max(isnull(ui.nm_caminho_imagem,''))       as nm_caminho_imagem,
    max(u.nm_email_usuario)                    as nm_email_usuario,
    max(u.cd_celular_usuario)                  as cd_celular_usuario,
    max(u.dt_nascimento_usuario)               as dt_nascimento_usuario,
    max(d.nm_departamento)                     as nm_departamento



  into #AcessoUsuario
  
  from 
    --#acesso a
    egisadmin.dbo.usuario u
    left outer join egisadmin.dbo.usuario_empresa ue on ue.cd_usuario       = u.cd_usuario and
                                          ue.ic_acesso_padrao = 'S'

    inner join egisadmin.dbo.empresa e               on e.cd_empresa = ue.cd_empresa
	--inner join egisadmin.dbo.Usuario u               on u.cd_usuario = a.cd_usuario
    left outer join #acesso a                        on a.cd_usuario  = u.cd_usuario
    left outer join egisadmin.dbo.usuario_imagem ui  on ui.cd_usuario = u.cd_usuario
    left outer join departamento d                   on d.cd_departamento = u.cd_departamento

  where
    ue.cd_empresa = case when @cd_empresa = 0 then ue.cd_empresa else @cd_empresa end
    and
    isnull(u.ic_ativo,'A') = 'A'

  group by
     e.cd_empresa,
	 e.nm_fantasia_empresa,
 	 u.cd_usuario,
	 u.nm_fantasia_usuario



  order by
    e.cd_empresa


  select * from #AcessoUsuario
  order by
    nm_fantasia_usuario
  
  return

end

--Frases do Dia----------------------------

if @cd_parametro = 10
begin
  --select * from egisadmin.dbo.Dica_Modulo
  select
   cd_dica,
   nm_dica,
   ds_dica

  from
    egisadmin.dbo.Dica_Modulo

  return
end

--Módulos Disponíveis------------------------------------------------------------

if @cd_parametro = 20
begin

  select 
    m.cd_modulo,
    m.nm_modulo,
    mgu.cd_grupo_usuario,
    g.nm_grupo_usuario,

    case when isnull(mgu.cd_grupo_usuario,0)>0 then 'S' else 'N' end ic_grupo_modulo
  from
    egisadmin.dbo.modulo m
    left outer join egisadmin.dbo.Modulo_GrupoUsuario mgu on mgu.cd_modulo = m.cd_modulo and
                                                             mgu.cd_grupo_usuario = @cd_grupo_usuario
    

    left outer join egisadmin.dbo.GrupoUsuario g          on g.cd_grupo_usuario = mgu.cd_grupo_usuario
  where
        isnull(m.ic_liberado,'N') = 'S'

  order by
    m.nm_modulo

  --select * from egisadmin.dbo.Modulo_GrupoUsuario
  return

end
-----------------------

--Atualização dos Modulo_GrupoUsuario

if @cd_parametro = 30
begin
  return
end

--Menus dos Módulos--------------------------------------------------------------

if @cd_parametro = 40
begin
  select 
    m.cd_modulo,
    m.nm_modulo,
    f.cd_funcao,
    f.nm_funcao,
    mnu.cd_menu,
    mnu.nm_menu_titulo,
    mgu.cd_grupo_usuario,
    g.nm_grupo_usuario,

    case when isnull(mgu.cd_grupo_usuario,0)>0 then 'S' else 'N' end ic_grupo_modulo,

     isnull(gum.cd_menu,0)                                as cd_menu_grupo_usuario

  from
    egisadmin.dbo.modulo m
    inner join egisadmin.dbo.modulo_funcao_menu mfm       on mfm.cd_modulo  = m.cd_modulo
    inner join egisadmin.dbo.funcao f                     on f.cd_funcao    = mfm.cd_funcao
    inner join egisadmin.dbo.menu mnu                     on mnu.cd_menu    = mfm.cd_menu
    left outer join egisadmin.dbo.Modulo_GrupoUsuario mgu on mgu.cd_modulo  = m.cd_modulo and
                                                             mgu.cd_grupo_usuario = @cd_grupo_usuario
    

    left outer join egisadmin.dbo.GrupoUsuario g          on g.cd_grupo_usuario = mgu.cd_grupo_usuario
    left outer join egisadmin.dbo.grupo_usuario_menu gum  on gum.cd_grupo_usuario = g.cd_grupo_usuario and
                                                             gum.cd_menu          = mnu.cd_menu

  where
    mgu.cd_grupo_usuario = @cd_grupo_usuario
    and
    isnull(m.ic_liberado,'N') = 'S'

  order by
    m.nm_modulo


  --select * from egisadmin.dbo.modulo_funcao_menu

  return
end

--Usuários do Grupo de usuários

if @cd_parametro = 50
begin
  select 
    u.cd_usuario,
    u.nm_usuario,
    u.nm_fantasia_usuario,
    ugu.cd_grupo_usuario,
    g.nm_grupo_usuario
   
  from
    egisadmin.dbo.usuario u
    inner join egisadmin.dbo.Usuario_GrupoUsuario ugu    on ugu.cd_usuario       = u.cd_usuario
    inner join egisadmin.dbo.GrupoUsuario g              on g.cd_grupo_usuario   = ugu.cd_grupo_usuario


  where
    ugu.cd_grupo_usuario = @cd_grupo_usuario
    and
    isnull(u.ic_ativo,'A') = 'A'

  order by
     u.nm_usuario
  return

end

--select * from egisadmin.dbo.grupo_usuario_menu where cd_grupo_usuario = 2512

if @cd_parametro = 9999
begin
  return
end

--use egissql_317
--
/* Padrão se nenhum caso for tratado */
SELECT CONCAT('Nenhuma ação mapeada para cd_parametro=', @cd_parametro) AS Msg;
   
 END TRY
    BEGIN CATCH
        DECLARE
            @errnum   INT          = ERROR_NUMBER(),
            @errmsg   NVARCHAR(4000) = ERROR_MESSAGE(),
            @errproc  NVARCHAR(128) = ERROR_PROCEDURE(),
            @errline  INT          = ERROR_LINE(),
            @fullmsg  NVARCHAR(2048);



         -- Monta a mensagem (THROW aceita até 2048 chars no 2º parâmetro)
    SET @fullmsg =
          N'Erro em pr_egis_admin_processo_modulo ('
        + ISNULL(@errproc, N'SemProcedure') + N':'
        + CONVERT(NVARCHAR(10), @errline)
        + N') #' + CONVERT(NVARCHAR(10), @errnum)
        + N' - ' + ISNULL(@errmsg, N'');

    -- Garante o limite do THROW
    SET @fullmsg = LEFT(@fullmsg, 2048);

    -- Relança com contexto (state 1..255)
    THROW 50000, @fullmsg, 1;

        -- Relança erro com contexto
        --THROW 50000, CONCAT('Erro em pr_egis_admin_processo_modulo (',
        --                    ISNULL(@errproc, 'SemProcedure'), ':',
        --                    @errline, ') #', @errnum, ' - ', @errmsg), 1;
    END CATCH

---------------------------------------------------------------------------------------------------------------------------------------------------------    
go



------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_admin_processo_modulo
------------------------------------------------------------------------------
--use egissql
--go
use egissql


--select * from egisadmin.dbo.usuario


--exec  pr_egis_admin_processo_modulo '[{"cd_parametro": 0 }]' 
--exec  pr_egis_admin_processo_modulo '[{"cd_parametro": 1, "cd_usuario": 113 }]' 
go
--exec  pr_egis_admin_processo_modulo '[{"ic_json_parametro": "S", "cd_parametro": 2, "cd_usuario": 113 }]' 
--go

--exec  pr_egis_admin_processo_modulo '[{"ic_json_parametro": "S", "cd_parametro": 10, "cd_usuario": 113 }]' 

--exec  pr_egis_admin_processo_modulo '[{"ic_json_parametro": "S", "cd_parametro": 20, "cd_grupo_usuario": 2512 }]' 

exec  pr_egis_admin_processo_modulo '[{"ic_json_parametro": "S", "cd_parametro": 40, "cd_grupo_usuario": 2512 }]' 
go
--exec  pr_egis_admin_processo_modulo '[{"ic_json_parametro": "S", "cd_parametro": 50, "cd_grupo_usuario": 2512 }]' 
go
go
go
------------------------------------------------------------------------------
GO

/*



exec  pr_egis_admin_processo_modulo '[
    {
        "ic_json_parametro": "S",
        "cd_parametro": 20,
        "cd_usuario": 113,
        "cd_grupo_usuario": 2512,
        "cd_empresa": "1"
    }
]'

select * from egisadmin.dbo.usuario_imagem

 select @vb_base64 = vb_imagem  
from openjson(  
    (  
        select  vb_imagem  
        from  egisadmin.dbo.Usuario_Imagem_Portal   
        where  
     cd_usuario = @cd_usuario    
        for json auto  
    )  
) with( vb_imagem varchar(max))  
  
  */