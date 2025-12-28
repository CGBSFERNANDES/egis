--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL
--USE EGISSQL_249
--go

use EGISADMIN
go

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_config_nfe_empresa' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_config_nfe_empresa

GO


-------------------------------------------------------------------------------
--sp_helptext pr_egis_config_nfe_empresa
-------------------------------------------------------------------------------
--pr_egis_config_nfe_empresa
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
--                   Notícias e Eventos
--
--Data             : 20.07.2025
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_config_nfe_empresa
@json nvarchar(max) = ''

--with encryption


as

set @json = isnull(@json,'')

SET NOCOUNT ON;


  IF ISJSON(@json) <> 1
  BEGIN
    RAISERROR ('JSON inválido', 16, 1);
    RETURN;
  END;


declare @cd_empresa           int
declare @cd_parametro         int = 0
declare @cd_usuario           int = 0
declare @dt_hoje              datetime
declare @dt_inicial           datetime 
declare @dt_final             datetime
declare @cd_ano               int = 0
declare @cd_mes               int = 0  
declare @cd_regime_tributario int = 0
declare @cd_senha_certificado varchar(30)  = ''
declare @cd_seguranca_nfc     varchar(100) = ''
declare @cd_id_seguranca_nfc  varchar(100) = ''
declare @cd_ambiente_nfe      varchar      = ''
declare @nm_empresa           varchar(60)  = ''
declare @sg_estado_empresa    varchar(02)  = ''
declare @nm_certificado       varchar(500) = ''
declare @schemes              varchar(100) = ''
declare @cd_cnpj_empresa      varchar(18)  = ''
declare @nm_banco_empresa     varchar(100) = ''
declare @nm_banco_origem      varchar(100) = ''
declare @nm_logotipo_empresa  varchar(500) = ''
declare @cd_modelo_danfe      int          = 1   --padrão


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

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]              as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_cnpj_empresa        = valor from #json where campo = 'cd_cnpj_empresa'   

set @cd_empresa      = ISNULL(@cd_empresa,0)
set @cd_cnpj_empresa = isnull(@cd_cnpj_empresa,'')

if @cd_empresa>0 and @cd_cnpj_empresa = ''
begin
  select
    @cd_cnpj_empresa = cd_cgc_empresa
  from
    egisadmin.dbo.empresa
  where
    cd_empresa = @cd_empresa
end

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()

--select * from egisadmin.dbo.empresa

--select
--  *
--from
--  egisadmin.dbo.empresa
--where
--  --cd_empresa = @cd_empresa
--  cd_cgc_empresa = @cd_cnpj_empresa
--  and
--  isnull(ic_ativa_empresa,'N')  = 'S'


select
  top 1
  @cd_empresa           = e.cd_empresa,
  @cd_senha_certificado = ltrim(rtrim(isnull(n.cd_senha_certificado,''))),
  @nm_certificado       = ltrim(rtrim(isnull(n.nm_certificado,''))),
  @nm_banco_empresa     = case when isnull(n.nm_banco_empresa,'')<>'' then n.nm_banco_empresa else e.nm_banco_empresa end, 
  @nm_logotipo_empresa  = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
  @cd_modelo_danfe      = isnull(n.cd_modelo_danfe,1),
  @nm_banco_origem      = e.nm_banco_empresa

from
  egisadmin.dbo.empresa e
  inner join egisadmin.dbo.NFe_Empresa n on n.cd_empresa = e.cd_empresa
where
  --cd_empresa = @cd_empresa
  --cd_cgc_empresa = @cd_cnpj_empresa
  e.cd_cgc_empresa = @cd_cnpj_empresa
  and
  isnull(e.ic_ativa_empresa,'N')  = 'S'
order by
  e.cd_empresa


--select @nm_banco_origem, @Nm_banco_empresa, @cd_cnpj_empresa, @cd_empresa

--return


/*
  select
    @cd_regime_tributario = isnull(v.cd_regime_tributario,0),
    @cd_senha_certificado = isnull(v.cd_senha_certificado,''),
	@cd_seguranca_nfc     = isnull(v.cd_seguranca_nfc,''),
    @cd_id_seguranca_nfc  = isnull(v.cd_id_seguranca_nfc,''),
	@cd_ambiente_nfe      = v.cd_ambiente_nfe,
    @nm_empresa           = e.nm_empresa,
    @sg_estado_empresa    = isnull(est.sg_estado,'SP'),
    @nm_certificado       = isnull(v.nm_certificado_nfe,'certificado.pfx'),
    @schemes              = isnull(v.nm_versao_esquema_nfc,'PL_009_V4'),
	@cd_cnpj_empresa      = ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))
	

  from 
    Versao_NFE v
	inner join egisadmin.dbo.empresa e on e.cd_empresa  = v.cd_empresa
	inner join estado est              on est.cd_estado = e.cd_estado
  where
    v.cd_empresa = @cd_empresa
	and
    ISNULL(v.ic_ativa_versao_nfe,'N')='S'
	and
	ISNULL(v.cd_senha_certificado,'')<>''
*/

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    
set @cd_parametro = ISNULL(@cd_parametro,0) 

declare @sql nvarchar(max) = ''
--select @cd_empresa
-- Montagem do SQL dinâmico----

SET @sql = '
SELECT
    @cd_regime_tributario = ISNULL(v.cd_regime_tributario,0),
    @cd_senha_certificado = ISNULL(v.cd_senha_certificado,''''),
    @cd_seguranca_nfc     = case when isnull(v.cd_ambiente_nfe,2) = 2 then isnull(v.cd_seguranca_nfc_hom,'''') else ISNULL(v.cd_seguranca_nfc,'''') end,
    @cd_id_seguranca_nfc  = ISNULL(v.cd_id_seguranca_nfc,''''),
    @cd_ambiente_nfe      = v.cd_ambiente_nfe,
    @nm_empresa           = e.nm_empresa,
    @sg_estado_empresa    = ISNULL(est.sg_estado,''SP''),
    @nm_certificado       = ISNULL(v.nm_certificado_nfe,''certificado_''''+CAST(@cd_empresa as varchar(6)) +''''.pfx''),
    @schemes              = ISNULL(v.nm_versao_esquema_nfc,''PL_009_V4''),
    @cd_cnpj_empresa      = LTRIM(RTRIM(ISNULL(e.cd_cgc_empresa, '''')))
	--@nm_banco_empresa     = ltrim(RTRIM(isnull(e.nm_banco_empresa,'''')))
	
FROM ' + QUOTENAME(@nm_banco_origem) + '.dbo.Versao_NFE v
INNER JOIN egisadmin.dbo.empresa e ON e.cd_empresa     = v.cd_empresa
INNER JOIN estado est ON est.cd_estado                 = e.cd_estado

WHERE 
    v.cd_empresa = @cd_empresa
    AND ISNULL(v.ic_ativa_versao_nfe,''N'') = ''S''
    
';

--select @nm_banco_origem
--AND ISNULL(v.cd_senha_certificado,'''') <> ''''
--@nm_banco_empresa     = ltrim(RTRIM(isnull(e.nm_banco_empresa,'''')))
--select @nm_banco_empresa
--select @sql

---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Execuntando
---------------------------------------------------------------------------------------------------------------------------------------------------------    

if @cd_parametro = 0
begin

-- Executa o SQL dinâmico passando as variáveis de input/output

EXEC sp_executesql
    @sql,
    N'@cd_empresa INT,
      @cd_regime_tributario INT OUTPUT,
      @cd_senha_certificado VARCHAR(255) OUTPUT,
      @cd_seguranca_nfc VARCHAR(255) OUTPUT,
      @cd_id_seguranca_nfc VARCHAR(255) OUTPUT,
      @cd_ambiente_nfe VARCHAR(10) OUTPUT,
      @nm_empresa VARCHAR(255) OUTPUT,
      @sg_estado_empresa VARCHAR(10) OUTPUT,
      @nm_certificado VARCHAR(255) OUTPUT,
      @schemes VARCHAR(50) OUTPUT,
      @cd_cnpj_empresa VARCHAR(20) OUTPUT, 
	  @nm_banco_empresa varchar(100) OUTPUT',
	  
    @cd_empresa           = @cd_empresa,
    @cd_regime_tributario = @cd_regime_tributario OUTPUT,
    @cd_senha_certificado = @cd_senha_certificado OUTPUT,
    @cd_seguranca_nfc     = @cd_seguranca_nfc OUTPUT,
    @cd_id_seguranca_nfc  = @cd_id_seguranca_nfc OUTPUT,
    @cd_ambiente_nfe      = @cd_ambiente_nfe OUTPUT,
    @nm_empresa           = @nm_empresa OUTPUT,
    @sg_estado_empresa    = @sg_estado_empresa OUTPUT,
    @nm_certificado       = @nm_certificado OUTPUT,
    @schemes              = @schemes OUTPUT,
    @cd_cnpj_empresa      = @cd_cnpj_empresa OUTPUT,
	@nm_banco_empresa     = @nm_banco_empresa OUTPUT;

-- Exibe os valores obtidos
--select @nm_certificado

SELECT 
    @cd_empresa            as cd_empresa,
    isnull(n.ic_ativo,'N') as ic_ativo,
    @cd_regime_tributario  AS cd_regime_tributario,
    ltrim(rtrim(case when isnull(@cd_senha_certificado,'')<>'' 
    and 
    (@cd_senha_certificado = n.cd_senha_certificado )
    then
       @cd_senha_certificado
    else
       n.cd_senha_certificado
    end))                         AS cd_senha_certificado,
    --@cd_senha_certificado AS cd_senha_certificado,
    @cd_seguranca_nfc             AS cd_seguranca_nfc,
    @cd_id_seguranca_nfc          AS cd_id_seguranca_nfc,
    case when @cd_ambiente_nfe<>n.cd_ambiente_nfe then
       n.cd_ambiente_nfe
    else
    @cd_ambiente_nfe 
    end                           as cd_ambiente_nfe,
    @nm_empresa                   AS nm_empresa,
    @sg_estado_empresa            AS sg_estado_empresa,
    ltrim(rtrim(case when isnull(n.nm_certificado,'')<>'' then
      n.nm_certificado 
    else
      @nm_certificado 
    end))                            AS nm_certificado,
    case when isnull(n.nm_versao_esquema_nfc,'') <> @schemes and isnull(n.nm_versao_esquema_nfc,'')<> '' then
      isnull(n.nm_versao_esquema_nfc,'')
    else
      @schemes 
    end                              AS schemes,
    @cd_cnpj_empresa                 AS cd_cnpj_empresa,
	@nm_banco_empresa                as nm_banco_empresa,
    --@nm_banco_origem      as nm_banco_empresa,
	@nm_logotipo_empresa             as nm_logotipo_empresa,
    1                                as cd_modelo_danfe,
    @nm_banco_origem                 as nm_banco_origem,
    isnull(n.ic_imposto_cibs,'N')    as ic_imposto_cibs,
    isnull(n.hr_dfe_servico,'06:00') as hr_dfe_servico,
    isnull(n.cd_ult_nsu,1)           as ult_nsu,
    isnull(n.cd_max_NSU,1)           as max_nsu,
    isnull(n.ic_dfe_ativo,'N')       as ic_dfe_ativo,
    isnull(n.nm_pdf_local,'')        as nm_pdf_local

from
  egisadmin.dbo.NFe_Empresa n

where
  n.cd_empresa = @cd_empresa

  --select * from egisadmin.dbo.NFe_Empresa

  --EXEC sp_executesql @sql
  /*
  select
    @cd_regime_tributario as cd_regime_tributario,
	@cd_senha_certificado as cd_senha_certificado,
	@cd_seguranca_nfc     as cd_seguranca_nfc,	
    @cd_id_seguranca_nfc  as cd_id_seguranca_nfc,
	@cd_ambiente_nfe      as cd_ambiente_nfe,
    @nm_empresa           as nm_empresa,
    @sg_estado_empresa    as sg_estado,
    @nm_certificado       as nm_certificado,
    @schemes              as schemes,
	@cd_cnpj_empresa      as cd_cnpj

	*/


end

---------------------------------------------------------------------------------------------------------------------------------------------------------    
go
--use egissql_319
use egisadmin
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_config_nfe_empresa
------------------------------------------------------------------------------
--select * from nfe_empresa
go
--10904110000131
--exec pr_egis_config_nfe_empresa '[{"cd_cnpj_empresa": "59282345000128"}]'
--50010187000182
--exec pr_egis_config_nfe_empresa '[{"cd_cnpj_empresa": "50472679000190"}]'
--
go

--update
--  NFe_Empresa
--  set
--    ic_dfe_ativo = 'N'

--exec pr_egis_config_nfe_empresa '[{"cd_empresa": "377"}]'

------------------------------------------------------------------------------