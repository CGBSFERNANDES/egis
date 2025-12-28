IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_api_gera_cadastro_cliente' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_api_gera_cadastro_cliente

GO

-------------------------------------------------------------------------------
--sp_helptext pr_api_gera_cadastro_cliente
-------------------------------------------------------------------------------
--pr_api_gera_cadastro_cliente
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql
--
--Objetivo         : Geração do Cadastro do Cliente
--Data             : 22.12.2021
--Alteração        : 
--
-- 29.07.2014 - Novos campos - Carlos Fernandes
-- 02.07.2021 - Novo Campo ic_identificacao_entrada - Pedro Jardim
-- 27.12.2021 - Correção de alguns campos - Denis Rabello
-- 07.04.2022 - Ajustes para salvar corretamento o cliente(CNPJ ou CPF) - Denis Rabello
-- 26.10.2022 - ajustes Diversos - Carlos Fernandes
-- 17.01.2023 - Ajuste no cd_inscricao_estadual e ic_isento_insc_cliente - Denis Rabello
------------------------------------------------------------------------------ 
create procedure pr_api_gera_cadastro_cliente  
@json nvarchar(max) = ''
  
as  
  
 set @json = isnull(@json,'')

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
declare @cd_cliente           int = 0  
declare @cd_tipo_pessoa       int = 0
declare @cd_destinatario      int = 0
declare @name                 varchar(60)   = ''
declare @email                varchar(150)  = ''
declare @phone                varchar(15)   = ''
declare @cnpj                 varchar(18)   = ''
declare @endereco             nvarchar(max) = ''
declare @cd_cep               varchar(8)    = ''
declare @nm_endereco          varchar(60)   = ''
declare @cd_numero            varchar(10)   = ''
declare @nm_cidade            varchar(60)   = ''
declare @sg_estado            varchar(2)    = ''
declare @nm_bairro            varchar(20)   = ''
declare @cd_cidade            int           = 0
declare @cd_estado            int           = 0
declare @cd_vendedor          int           = 0


--cliente

----------------------------------------------------------------------------------------------------------------

set @cd_empresa        = 0
set @cd_parametro      = 0
set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
set @cd_ano            = year(getdate())
set @cd_mes            = month(getdate())  
set @endereco          = ''

----------------------------------------------------------------------------------------------------------------

if @dt_inicial is null
begin
  set @dt_inicial       = dbo.fn_data_inicial(@cd_mes,@cd_ano)
  set @dt_final         = dbo.fn_data_final(@cd_mes,@cd_ano)
end

--tabela
--select ic_sap_admin, * from Tabela where cd_tabela = 5287

----------------------------------------------------------------------------------------

select                     

 1                                                   as id_registro,
 IDENTITY(int,1,1)                                   as id,
 valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI as campo,                     
 valores.[value]                                     as valor                    
                    
 into #json                    
 from                
   openjson(@json)root                    
   cross apply openjson(root.value) as valores      

-- extrair o objeto address

SELECT 
    j.id_registro,
    v.[key]   AS campo,
    v.[value] AS valor
INTO #endereco
FROM #json j
CROSS APPLY OPENJSON(j.valor) v
WHERE j.campo = 'address';

 
--select * from #json
--select * from #Endereco
--return

--------------------------------------------------------------------------------------------

select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
select @cd_parametro           = valor from #json where campo = 'cd_parametro'          
select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
select @dt_inicial             = valor from #json where campo = 'dt_inicial'             
select @dt_final               = valor from #json where campo = 'dt_final'             
select @cd_modelo              = valor from #json where campo = 'cd_modelo' 
select @name                   = valor from #json where campo = 'name' 
select @email                  = valor from #json where campo = 'email'
select @phone                  = valor from #json where campo = 'phone'
select @cnpj                   = valor from #json where campo = 'cnpj'
select @cd_vendedor            = valor from #json where campo = 'cd_vendedor'


--------------------------------------------------------------------------------------
--Endereco
--------------------------------------------------------------------------------------
select @cd_cep                   = valor from #endereco where campo = 'zip'
select @nm_endereco              = valor from #endereco where campo = 'street'
select @cd_numero                = valor from #endereco where campo = 'number'
select @nm_cidade                = valor from #endereco where campo = 'city'
select @sg_estado                = valor from #endereco where campo = 'state'
select @nm_bairro                = valor from #endereco where campo = 'bairro'

set @cd_cep = replace(@cd_cep,'-','')

--------------------------------------------------------------------------------------

set @cd_empresa = ISNULL(@cd_empresa,0)

--------------------------------------------------------------------------------------

if @cd_empresa = 0
   set @cd_empresa = dbo.fn_empresa()


set @cd_destinatario = isnull(@cd_destinatario,0)
set @cd_usuario      = isnull(@cd_usuario,0)

select top 0 * into #Destinatario from NFE_Destinatario
insert into #Destinatario ( cd_destinatario, cd_tipo_destinatario ) values ( 1,1 ) 
-----------------------------------------------------------------

select
  top 1
  @cd_estado = cd_estado,
  @cd_cidade = cd_cidade
from
  cep 
where
  cd_cep = @cd_cep


--select * from #json
--select * from #endereco

set @cd_destinatario = 1

update
  #Destinatario
set
  cd_destinatario          = 1,
  cd_tipo_destinatario     = 1,
  nm_destinatario          = @name,
  nm_fantasia_destinatario = cast(@name as varchar(60)),
  cd_cnpj                  = @cnpj,
  cd_telefone              = replace(ltrim(rtrim(replace(@phone,'-',''))),'+',''),
  nm_endereco              = @nm_endereco,
  cd_numero                = @cd_numero,
  cd_cep                   = replace(@cd_cep,'-',''),
  dt_usuario               = getdate(),
  cd_usuario               = @cd_usuario,
  dt_cadastro_destinatario = getdate(),
  nm_bairro                = @nm_bairro,
  cd_cidade                = @cd_cidade,
  cd_estado                = @cd_estado,
  cd_pais                  = 1
  
from
  #Destinatario d

--select * from #json
--select * from #endereco
--select * from #Destinatario

--return



---------------------------------------------------------------------------------------------------------------------------------------------------------    
--Processos           
---------------------------------------------------------------------------------------------------------------------------------------------------------    

------------------------------------------------------------------------------------------------------

select  
  @cd_cliente = isnull(max( cd_cliente ),0)  
from  
  cliente f  
  
set @cd_cliente     = isnull(@cd_cliente,0) + 1  
set @cd_tipo_pessoa = 1  
set @dt_hoje        = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)      
  
select  
  @cd_cliente                            as cd_cliente,  
  substring(e.nm_destinatario,1,60)      as nm_fantasia_cliente,
  cast(e.nm_destinatario as varchar(60)) as nm_razao_social_cliente,
  cast('' as varchar)                    as nm_razao_social_cliente_c,
  cast('' as varchar)                    as nm_dominio_cliente,
  cast('' as varchar)                    as nm_email_cliente,
  NULL                                   as ic_destinacao_cliente,
  NULL                                   as cd_suframa_cliente,
  NULL                                   as cd_reparticao_origem,
  NULL                                   as pc_desconto_cliente,
  @dt_hoje                               as dt_cadastro_cliente,
  cast('' as varchar)                    as ds_cliente,
  NULL                                   as cd_conceito_cliente,
  case when isnull(e.cd_cnpj,'') <> ''
    then 1
	  else 2
  end   	                             as cd_tipo_pessoa,
  NULL                                   as cd_fonte_informacao,
  NULL                                   as cd_ramo_atividade,
  1                                      as cd_status_cliente,
  NULL                                   as cd_transportadora,
  NULL                                as cd_criterio_visita,
  NULL                                as cd_tipo_comunicacao,
  NULL                                as cd_tipo_mercado,
  1                                   as cd_idioma,
  NULL                                as cd_cliente_filial,
  cep.cd_identifica_cep               as cd_identifica_cep,
  case when isnull(e.cd_cnpj,'') <> ''
    then isnull(e.cd_cnpj,'')
	  else case when isnull(e.cd_cpf,'') <> ''
           then isnull(e.cd_cpf,'')
           else null
         end
  end               	              as cd_cnpj_cliente,
  NULL                           		as cd_inscMunicipal,
  case when (isnull(e.cd_inscricao_estadual,'') = '') or (e.cd_inscricao_estadual = 'ISENTO') 
    then 'ISENTO' 
    else e.cd_inscricao_estadual  
  end                               as cd_inscestadual,
  e.cd_cep                       		as cd_cep,
  e.nm_endereco                  		as nm_endereco_cliente,
  e.cd_numero                    		as cd_numero_endereco,
  e.nm_complemento               		as nm_complemento_endereco,
  e.nm_bairro                    		as nm_bairro,
  c.cd_cidade                    		as cd_cidade,
  est.cd_estado                  		as cd_estado,
  est.cd_pais                    		as cd_pais,
  c.cd_ddd_cidade                		as cd_ddd,
  case when e.cd_telefone <> ''
    then substring(e.cd_telefone,3,9)
	else null end                  		as cd_telefone,
  e.cd_telefone                  		as cd_fax,
  @cd_usuario                    		as cd_usuario,
  getdate()                      		as dt_usuario,
  NULL                           		as cd_cliente_sap,
  'N'                            		as ic_contrib_icms_cliente,
  NULL                           		as cd_aplicacao_segmento,
  NULL                           		as cd_filial_empresa,
  NULL                           		as ic_liberado_pesq_credito,
  NULL                           		as cd_tipo_tabela_preco,
  NULL                           		as cd_regiao,
  NULL                           		as cd_centro_custo,
  NULL                           		as cd_cliente_grupo,
  NULL                           		as cd_destinacao_produto,
  NULL                           		as ic_exportador_cliente,
  NULL                           		as nm_especificacao_ramo,
  NULL                           		as ic_wapnet_cliente,
  @cd_vendedor                    		as cd_vendedor,
  1                              		as cd_vendedor_interno,
  1                              		as cd_condicao_pagamento,
  NULL                           		as cd_cliente_filial_sap,
  NULL                           		as cd_categoria_cliente,
  NULL                           		as ic_wapnet_wap,
  NULL                           		as nm_divisao_area,
  NULL                           		as ic_permite_agrupar_pedido,
  NULL                           		as nm_ponto_ref_cliente,
  NULL                           		as pc_comissao_cliente,
  case when (isnull(e.cd_inscricao_estadual,'') = '') or (e.cd_inscricao_estadual = 'ISENTO') 
    then 'S'   
    else null end                   as ic_isento_insc_cliente, 
  NULL                           		as cd_conta,
  cast('' as varchar)            		as ds_cliente_endereco,
  NULL                           		as ic_mp66_cliente,
  NULL                           		as nm_cidade_mercado_externo,
  NULL                           		as sg_estado_mercado_externo,
  NULL                           		as nm_pais_mercado_externo,
  NULL                           		as qt_distancia_cliente,
  NULL                           		as ic_rateio_comissao_client,
  NULL                           		as cd_pag_guia_cliente,
  NULL                           		as ic_inscestadual_valida,
  NULL                           		as ic_habilitado_suframa,
  NULL                           		as ic_global_cliente,
  NULL                           		as ic_foco_cliente,
  NULL                           		as ic_oem_cliente,
  NULL                           		as ic_distribuidor_cliente,
  NULL                           		as cd_cliente_global,
  NULL                           		as dt_exportacao_registro,
  NULL                           		as cd_porto,
  NULL                           		as cd_abablz_cliente,
  NULL                           		as cd_swift_cliente,
  1                              		as cd_moeda,
  NULL                           		as cd_barra_cliente,
  NULL                           		as ic_fmea_cliente,
  NULL                           		as cd_fornecedor_cliente,
  NULL                           		as ic_plano_controle_cliente,
  NULL                           		as ic_op_simples_cliente,
  NULL                           		as cd_dispositivo_legal,
  NULL                           		as ic_promocao_cliente,
  NULL                           		as ic_contrato_cliente,
  NULL                           		as cd_idioma_produto_exp,
  NULL                           		as cd_loja,
  NULL                           		as cd_tabela_preco,
  NULL                           		as pc_icms_reducao_cliente,
  NULL                           		as ic_epp_cliente,
  NULL                           		as ic_me_cliente,
  NULL                           		as cd_forma_pagamento,
  NULL                           		as ic_dif_aliq_icms,
  NULL                           		as cd_tratamento_pessoa,
  NULL                           		as cd_tipo_pagamento,
  NULL                           		as cd_cliente_prospeccao,
  NULL                           		as cd_tipo_documento,
  NULL                           		as ic_sub_tributaria_cliente,
  NULL                           		as ic_analise_cliente,
  NULL                           		as cd_portador,
  NULL                           		as cd_ddd_celular_cliente,
  NULL                           		as cd_celular_cliente,
  NULL                           		as dt_aniversario_cliente,
  NULL                           		as ic_inss_cliente,
  NULL                           		as ic_polo_plastico_cliente,
  NULL                           		as ic_dispositivo_polo,
  NULL                           		as ic_valida_ie_cliente,
  NULL                           		as cd_tipo_pagamento_frete,
  NULL                           		as ic_multi_form_cliente,
  NULL                           		as ic_fat_minimo_cliente,
  NULL                           		as ic_pis_cofins_cliente,
  NULL                           		as pc_pis_cliente,
  NULL                           		as pc_cofins_cliente,
  NULL                           		as cd_tipo_local_entrega,
  NULL                           		as ic_cpv_cliente,
  NULL                           		as cd_plano_financeiro,
  NULL                           		as ic_espelho_nota_cliente,
  NULL                           		as ic_arquivo_nota_cliente,
  NULL                           		as cd_interface,
  NULL                           		as qt_latitude_cliente,
  NULL                           		as qt_longitude_cliente,
  NULL                           		as cd_unidade_medida,
  NULL                           		as ic_ipi_base_st_cliente,
  NULL                           		as cd_insc_rural_cliente,
  NULL                           		as ic_reter_piscofins_cliente,
  NULL                           		as cd_codificacao_cliente,
  NULL                           		as ic_retencao_cliente,
  NULL                           		as cd_classificacao_cliente,
  NULL                           		as cd_situacao_operacao,
  NULL                           		as ic_desconto_suframa,
  NULL                           		as cd_empresa,
  NULL                           		as ic_transferencia_cliente,
  NULL                           		as cd_nivel_inspecao,
  NULL                           		as cd_cnae,
  NULL                           		as ic_publico_dif_cliente,
  NULL                           		as cd_senha_acesso,
  NULL                           		as ic_diferimento_icms,
  NULL                           		as ic_reduz_base_st_cliente,
  NULL                           		as pc_carga_trib_media_cliente,
  NULL                           		as cd_natureza_retencao,
  NULL                           		as dt_ativacao_cliente,
  NULL                           		as cd_vendedor_prospeccao,
  NULL                           		as pc_contrato_cliente,
  NULL                           		as cd_tipo_pedido,
  NULL                           		as cd_semana,
  NULL                           		as cd_criterio_entrega,
  NULL                           		as cd_itinerario,
  NULL                           		as dt_final_operacao_cliente,
  NULL                           		as cd_exportacao,
  NULL                           		as cd_cep_externo,
  'N'                            		as ic_op_automatica,
  'N'                            		as ic_desconto_icms,
  NULL                           		as nm_arquivo_etiqueta_cliente,
  NULL                           		as cd_aplicacao_markup,
  'N'                            		as ic_laudo_cliente,
  'N'                            		as ic_ret_parcela_piscof_cliente,
  'N'                            		as ic_programacao_cliente,
  'N'                            		as ic_obriga_liberacao_custo,
  @cd_usuario                    		as cd_usuario_inclusao,
  getdate()                      		as dt_usuario_inclusao,
  'N'                            		as ic_laudo_saida,
  null                                  as pc_icms_st_reducao,
  null                                  as cd_regime_tributario

into  
  #cliente  
  
  --sp_help cliente

from  
  #destinatario e  
  left join estado est on est.cd_estado = e.cd_estado    
  left join cep        on cep.cd_cep    = e.cd_cep  
  left join cidade c   on c.cd_cidade   = cep.cd_cidade 
  
where  
  e.cd_destinatario  = @cd_destinatario 
  and  
  (e.cd_cnpj not in ( select cd_cnpj_cliente from cliente where cd_cnpj_cliente = e.cd_cnpj) 
  or
  isnull(e.cd_cpf,'')  not in ( select isnull(cd_cnpj_cliente,'') as cd_cpf from cliente where cd_cnpj_cliente = isnull(e.cd_cpf,'')))

--select * from nfe_destinatario
--select * from nfe_emitente
--select * from #Destinatario

--select * from   #cliente  

--return
 
declare @cd_cnpj     varchar(18) = ''
--declare @nm_endereco varchar(60)
--declare @cd_cep      varchar(8)

set @cd_cnpj  = ''
set @cd_cep   = ''

select
  @cd_cnpj = cd_cnpj_cliente,
  @cd_cep  = isnull(cd_cep,'')
from
  #cliente
  
--Atualiza os Dados do Cliente----------------------------------------------------------------------------------------------------------------

if @cd_cnpj<>''
begin
   --validar o Cep---
   if not exists( select top 1 cd_cep from Cep 
                  where
				    cd_cep = @cd_cep)
   begin
    
     exec pr_api_pesquisa_cnpj_receita @cd_cnpj, @cd_usuario, 1
	 --exec pr_api_pesquisa_cnpj_receita '58706862000114', 113, 1

	 --select 'aqui'

   end
end
-----

-----

--Atualizar os dados da Receita

update
  #Cliente
set 
  nm_fantasia_cliente = case when c.nm_fantasia_cliente<>isnull(p.nm_fantasia,c.nm_fantasia_cliente) then
                             p.nm_fantasia
                        else
                             c.nm_fantasia_cliente
                        end,
  nm_endereco_cliente = case when isnull(c.nm_endereco_cliente,'') <> isnull(p.nm_endereco,c.nm_endereco_cliente) then
                             p.nm_endereco
                        else 
                             c.nm_endereco_cliente
                        end,                                  
  cd_cep =              case when c.cd_cep<>p.nm_cep then
                             p.nm_cep
                        else
                             c.cd_cep
                        end
from
  #cliente c
  inner join Consulta_Receita_Pessoa p on replace(replace(replace(p.cd_cnpj,'.',''),'/',''),'-','') = c.cd_cnpj_cliente

  --select * from Consulta_Receita_Pessoa

----------------------------------------------------------------------------------------

--select * from #cliente  
  
insert into cliente   
(
 cd_cliente,
 nm_fantasia_cliente,
 nm_razao_social_cliente,
 nm_razao_social_cliente_c,
 nm_dominio_cliente,
 nm_email_cliente,
 ic_destinacao_cliente,
 cd_suframa_cliente,
 cd_reparticao_origem,
 pc_desconto_cliente,
 dt_cadastro_cliente,
 ds_cliente,
 cd_conceito_cliente,
 cd_tipo_pessoa,
 cd_fonte_informacao,
 cd_ramo_atividade,
 cd_status_cliente,
 cd_transportadora,
 cd_criterio_visita,
 cd_tipo_comunicacao,
 cd_tipo_mercado,
 cd_idioma,
 cd_cliente_filial,
 cd_identifica_cep,
 cd_cnpj_cliente,
 cd_inscMunicipal,
 cd_inscestadual,
 cd_cep,
 nm_endereco_cliente,
 cd_numero_endereco,
 nm_complemento_endereco,
 nm_bairro,
 cd_cidade,
 cd_estado,
 cd_pais,
 cd_ddd,
 cd_telefone,
 cd_fax,
 cd_usuario,
 dt_usuario,
 cd_cliente_sap,
 ic_contrib_icms_cliente,
 cd_aplicacao_segmento,
 cd_filial_empresa,
 ic_liberado_pesq_credito,
 cd_tipo_tabela_preco,
 cd_regiao,
 cd_centro_custo,
 cd_cliente_grupo,
 cd_destinacao_produto,
 ic_exportador_cliente,
 nm_especificacao_ramo,
 ic_wapnet_cliente,
 cd_vendedor,
 cd_vendedor_interno,
 cd_condicao_pagamento,
 cd_cliente_filial_sap,
 cd_categoria_cliente,
 ic_wapnet_wap,
 nm_divisao_area,
 ic_permite_agrupar_pedido,
 nm_ponto_ref_cliente,
 pc_comissao_cliente,
 ic_isento_insc_cliente,
 cd_conta,
 ds_cliente_endereco,
 ic_mp66_cliente,
 nm_cidade_mercado_externo,
 sg_estado_mercado_externo,
 nm_pais_mercado_externo,
 qt_distancia_cliente,
 ic_rateio_comissao_client,
 cd_pag_guia_cliente,
 ic_inscestadual_valida,
 ic_habilitado_suframa,
 ic_global_cliente,
 ic_foco_cliente,
 ic_oem_cliente,
 ic_distribuidor_cliente,
 cd_cliente_global,
 dt_exportacao_registro,
 cd_porto,
 cd_abablz_cliente,
 cd_swift_cliente,
 cd_moeda,
 cd_barra_cliente,
 ic_fmea_cliente,
 cd_fornecedor_cliente,
 ic_plano_controle_cliente,
 ic_op_simples_cliente,
 cd_dispositivo_legal,
 ic_promocao_cliente,
 ic_contrato_cliente,
 cd_idioma_produto_exp,
 cd_loja,
 cd_tabela_preco,
 pc_icms_reducao_cliente,
 ic_epp_cliente,
 ic_me_cliente,
 cd_forma_pagamento,
 ic_dif_aliq_icms,
 cd_tratamento_pessoa,
 cd_tipo_pagamento,
 cd_cliente_prospeccao,
 cd_tipo_documento,
 ic_sub_tributaria_cliente,
 ic_analise_cliente,
 cd_portador,
 cd_ddd_celular_cliente,
 cd_celular_cliente,
 dt_aniversario_cliente,
 ic_inss_cliente,
 ic_polo_plastico_cliente,
 ic_dispositivo_polo,
 ic_valida_ie_cliente,
 cd_tipo_pagamento_frete,
 ic_multi_form_cliente,
 ic_fat_minimo_cliente,
 ic_pis_cofins_cliente,
 pc_pis_cliente,
 pc_cofins_cliente,
 cd_tipo_local_entrega,
 ic_cpv_cliente,
 cd_plano_financeiro,
 ic_espelho_nota_cliente,
 ic_arquivo_nota_cliente,
 cd_interface,
 qt_latitude_cliente,
 qt_longitude_cliente,
 cd_unidade_medida,
 ic_ipi_base_st_cliente,
 cd_insc_rural_cliente,
 ic_reter_piscofins_cliente,
 cd_codificacao_cliente,
 ic_retencao_cliente,
 cd_classificacao_cliente,
 cd_situacao_operacao,
 ic_desconto_suframa,
 cd_empresa,
 ic_transferencia_cliente,
 cd_nivel_inspecao,
 cd_cnae,
 ic_publico_dif_cliente,
 cd_senha_acesso,
 ic_diferimento_icms,
 ic_reduz_base_st_cliente,
 pc_carga_trib_media_cliente,
 cd_natureza_retencao,
 dt_ativacao_cliente,
 cd_vendedor_prospeccao,
 pc_contrato_cliente,
 cd_tipo_pedido,
 cd_semana,
 cd_criterio_entrega,
 cd_itinerario,
 dt_final_operacao_cliente,
 cd_exportacao,
 cd_cep_externo,
 ic_op_automatica,
 ic_desconto_icms,
 nm_arquivo_etiqueta_cliente,
 cd_aplicacao_markup,
 ic_laudo_cliente,
 ic_ret_parcela_piscof_cliente,
 ic_programacao_cliente,
 ic_obriga_liberacao_custo,
 cd_usuario_inclusao,
 dt_usuario_inclusao,
 ic_laudo_saida,
 pc_icms_st_reducao,
 cd_regime_tributario
)   
  
select * from #cliente  
 
--select * from #cliente 
--select * from cliente

  

drop table #cliente  


set @cd_parametro         = ISNULL(@cd_parametro,0)

IF ISNULL(@cd_parametro,0) = 0
BEGIN
  select 
    'Sucesso' as Msg,
     @cd_modelo   AS cd_modelo,
     @cd_empresa  AS cd_empresa,
     @dt_inicial  AS dt_inicial,
     @dt_final    AS dt_final,
     @cd_usuario  AS cd_usuario

  RETURN;

END

if @cd_parametro = 9 and @cd_cliente>0
begin
  select 
    'success'                        as 'status',
    'Cliente cadastrado com sucesso' as 'message',
    @cd_cliente                      as 'clientId'


  return

end


if @cd_parametro = 999
begin

  return

end
 
 
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
          N'Erro em pr_egis_modelo_procedure ('
        + ISNULL(@errproc, N'SemProcedure') + N':'
        + CONVERT(NVARCHAR(10), @errline)
        + N') #' + CONVERT(NVARCHAR(10), @errnum)
        + N' - ' + ISNULL(@errmsg, N'');

    -- Garante o limite do THROW
    SET @fullmsg = LEFT(@fullmsg, 2048);

    -- Relança com contexto (state 1..255)
    THROW 50000, @fullmsg, 1;

        -- Relança erro com contexto
        --THROW 50000, CONCAT('Erro em pr_egis_modelo_procedure (',
        --                    ISNULL(@errproc, 'SemProcedure'), ':',
        --                    @errline, ') #', @errnum, ' - ', @errmsg), 1;
    END CATCH

go

 

------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_api_gera_cadastro_cliente '[{
--  "name": "Cliente Exemplo",
--  "email": "cliente@exemplo.com",
--  "phone": "+5511999999999",
--  "cnpj": "12345678000195",
--  "address": {
--    "street": "Rua Exemplo",
--    "number": "123",
--    "city": "São Paulo",
--    "state": "SP",
--    "zip": "01000-000"
--  }
--}]'
--use egissql_273
--go

--delete from cliente where cd_cliente = 18926
--go

--select cd_vendedor, * from cliente where cd_cnpj_cliente = '12345678000195'

------------------------------------------------------------------------------