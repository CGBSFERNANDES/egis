--BANCO DA EMPRESA/CLIENTE
--
--use EGISSQL_355

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_gera_rejeicao_nota_saida' 
	   AND 	  type = 'P')
    DROP PROCEDURE  pr_egis_gera_rejeicao_nota_saida

GO

-------------------------------------------------------------------------------
--sp_helptext  pr_egis_gera_rejeicao_nota_saida
-------------------------------------------------------------------------------
-- pr_egis_gera_rejeicao_nota_saida
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
create procedure  pr_egis_gera_rejeicao_nota_saida
@json nvarchar(max) = ''

--with encryption


as

--return

--set @json = isnull(@json,'')



-- set @json = replace(
--              replace(
--                replace(
--                 replace(
--                   replace(
--                     replace(
--                       replace(
--                         replace(
--                           replace(
--                             replace(
--                               replace(
--                                 replace(
--                                   replace(
--                                     replace(
--                                     @json, CHAR(13), ' '),
--                                   CHAR(10),' '),
--                                 ' ',' '),
--                               ':\\\"',':\\"'),
--                             '\\\";','\\";'),
--                           ':\\"',':\\\"'),
--                         '\\";','\\\";'),
--                       '\\"','\"'),
--                     '\"', '"'),
--                   '',''),
--                 '["','['),
--               '"[','['),
--              ']"',']'),
--           '"]',']') 


declare @cd_empresa          int
declare @cd_parametro        int
declare @cd_documento        int = 0
declare @cd_item_documento   int
declare @cd_usuario          int 
declare @dt_hoje             datetime
declare @dt_inicial          datetime 
declare @dt_final            datetime
declare @cd_ano              int = 0
declare @cd_mes              int = 0
declare @cd_nota_saida       int = 0
declare @cd_rejeicao         int = 0
declare @ds_rejeicao_nota    nvarchar(max) = ''
declare @dt_rejeicao         datetime  
declare @ds_xml_retorno      nvarchar(max) = ''
declare @xMotivo             nvarchar(max) = ''


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

 1                                                    as id_registro,
 IDENTITY(int,1,1)                                    as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
 valores.[value]                                      as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_nota_saida          = valor from #json where campo = 'cd_nota_saida'
select @cd_rejeicao            = valor from #json where campo = 'cd_motivo'
select @dt_rejeicao            = valor from #json where campo = 'dt_rejeicao'
select @ds_rejeicao_nota       = valor from #json where campo = 'ds_motivo'
select @ds_xml_retorno         = valor from #json where campo = 'ds_xml_retorno'
select @xMotivo                = valor from #json where campo = 'xMotivo'


-------------------------------------------------------------------------------------------------------------------------------------
set @dt_rejeicao      = case when @dt_rejeicao is null then @dt_hoje else @dt_rejeicao end
set @ds_rejeicao_nota = isnull(@ds_rejeicao_nota,'')
set @ds_xml_retorno   = isnull(@ds_xml_retorno,'')

if @ds_xml_retorno = ''
begin
  set @ds_xml_retorno = 'Estrutura do XML - Log'
end


----------
if @xMotivo<>'' and @ds_xml_retorno=''
begin
  set @ds_xml_retorno = isnull(@ds_xml_retorno,'') + ' '+@xMotivo
end
----
if @xMotivo<>'' and @ds_rejeicao_nota=''
begin
  set @ds_rejeicao_nota = isnull(@ds_rejeicao_nota,'') + ' '+@xMotivo
end
----
set @cd_empresa = ISNULL(@cd_empresa,0)

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()



---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    

set @cd_parametro = ISNULL(@cd_parametro,0)

if @cd_parametro = 0
begin
  --nfe_rejeicao

  --nota_saida_rejeicao
  --select * from nota_saida_rejeicao

    IF EXISTS (
       SELECT 1 FROM nota_saida_rejeicao
       WHERE 
         cd_nota_saida = @cd_nota_saida
       )
    begin
	  update
	    nota_saida_rejeicao
	  set
	    dt_rejeicao       = @dt_rejeicao,
		cd_rejeicao       = @cd_rejeicao,
		ds_rejeicao_nota  = @ds_rejeicao_nota,
		ds_xml_retorno    = @ds_xml_retorno
      where
	    cd_nota_saida     = @cd_nota_saida

	end
	else
	begin
	  insert into nota_saida_rejeicao ( cd_nota_saida, dt_rejeicao, cd_rejeicao, ds_rejeicao_nota, ds_xml_retorno )
	  values
	  (@cd_nota_saida, @dt_rejeicao, @cd_rejeicao, @ds_rejeicao_nota, @ds_xml_retorno )
	   
	end
 
  end

  -------------------------------------------
  select 'Rejeição da Nota Atualizada' as Msg
  -------------------------------------------

  --select * from nota_saida_rejeicao




---------------------------------------------------------------------------------------------------------------------------------------------------------    
go



--use egissql_rubio


go
--use egissql_361
go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec  pr_egis_gera_rejeicao_nota_saida
------------------------------------------------------------------------------

go
/*
--exec  pr_egis_gera_rejeicao_nota_saida '[{"cd_parametro": 0},
                                          {"cd_empresa": 319}, {"ds_retorno":""}, {"ds_xml_nota":""}, {"cd_chave_acesso":""}, {"ic_validada":"N"},
                                          {"dt_autorizacao": ""}, {"cd_protocolo_nfe": ""}, {"ic_json_parametro": "S"}
                                         ]'
*/
go
------------------------------------------------------------------------------
GO
--delete from nota_saida_rejeicao

--select * from nota_saida_rejeicao
--select * from nota_validacao

--use egissql_274

--use EGISSQL
