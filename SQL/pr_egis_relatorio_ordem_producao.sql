IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_egis_relatorio_ordem_producao' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_egis_relatorio_ordem_producao

GO

-------------------------------------------------------------------------------
--sp_helptext pr_egis_relatorio_ordem_producao
-------------------------------------------------------------------------------
--pr_egis_relatorio_ordem_producao
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Joao Pedro Marcal
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatorio Padrao Egis HTML - EgisMob, EgisNet, Egis
--Data             : 10.01.2025	
--Alteracao        : 
--
--
------------------------------------------------------------------------------
create procedure pr_egis_relatorio_ordem_producao
@cd_relatorio int   = 0,
@cd_parametro int   = 0,
@json varchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
declare @data_grafico_bar       varchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @cd_documento           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
declare @cd_vendedor            int = 0 
declare @cd_grupo_relatorio     int = 0
declare @id                     int = 0 
declare @cd_processo            int = 0

--Dados do Relatorio---------------------------------------------------------------------------------

     declare
            @titulo                     varchar(200),
		    @logo                       varchar(400),			
			@nm_cor_empresa             varchar(20),
			@nm_endereco_empresa  	    varchar(200) = '',
			@cd_telefone_empresa    	varchar(200) = '',
			@nm_email_internet		    varchar(200) = '',
			@nm_cidade				    varchar(200) = '',
			@sg_estado				    varchar(10)	 = '',
			@nm_fantasia_empresa	    varchar(200) = '',
			@numero					    int = 0,
			@dt_pedido				    varchar(60) = '',
			@cd_cep_empresa			    varchar(20) = '',
			@cd_cliente				    int = 0,
	--		@nm_fantasia_cliente  	    varchar(200) = '',
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			@cd_numero_endereco			varchar(20) = '',
			@ds_relatorio				varchar(8000) = '',
			@subtitulo					varchar(40)   = '',
			@footerTitle				varchar(200)  = '',
			@cd_numero_endereco_empresa varchar(20)	  = '',
			@cd_pais					int = 0,
			@nm_pais					varchar(20) = '',
			@cd_cnpj_empresa			varchar(60) = '',
			@cd_inscestadual_empresa    varchar(100) = '',
			@nm_dominio_internet		varchar(200) = ''
		         


--------------------------------------------------------------------------------------------------------

if @json<>''
begin
  select                     
    1                                                    as id_registro,
    IDENTITY(int,1,1)                                    as id,
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
    valores.[value]              as valor                    
                    
    into #json                    
    from                
      openjson(@json)root                    
      cross apply openjson(root.value) as valores      

-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_processo            = valor from #json where campo = 'cd_pedido_venda'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'

   end
   --parametro EgisMob(Não tirar)
   if isnull(@cd_processo,0) = 0 
     begin 
	 set @cd_processo = @cd_documento
	 end 
	
end


-------------------------------------------------------------------------------------------------
declare @ic_processo char(1) = 'N'
 
 --select @cd_relatorio
 
select  
  @titulo             = nm_relatorio,  
  @ic_processo        = isnull(ic_processo_relatorio, 'N'),  
  @cd_grupo_relatorio = ISNULL(cd_grupo_relatorio,0)  
from  
  egisadmin.dbo.Relatorio  
where  
  cd_relatorio = @cd_relatorio  
 
 
----------------------------------------------------------------------------------------------------------------------------
select  
  @dt_inicial       = isnull(dt_inicial,0),  
  @dt_final         = isnull(dt_final,0),
  @cd_processo      = isnull(cd_pedido_venda,0)
from   
  Parametro_Relatorio  
  
where  
  cd_relatorio = @cd_relatorio  
  and  
  cd_usuario   = @cd_usuario  
----------------------------------------------------------------------------------------------------------------------------

set @cd_ano           = year(@dt_hoje)    
set @cd_dia           = day(@dt_hoje)
set @cd_mes           = month(@dt_hoje)

if @dt_inicial is null  or @dt_inicial = '01/01/1900'    
begin      
      
  set @cd_ano = year(@dt_hoje)      
  set @cd_mes = month(@dt_hoje)      
      
  set @dt_inicial = dbo.fn_data_inicial(@cd_mes,@cd_ano)      
  set @dt_final   = dbo.fn_data_final(@cd_mes,@cd_ano)      
      
end   

-----------------------------------------------------------------------------------------
--Empresa
----------------------------------
set @cd_empresa = dbo.fn_empresa()
-----------------------------------

	--Dados da empresa-----------------------------------------------------------

	select 
		@logo = isnull('https://egisnet.com.br/img/' + e.nm_caminho_logo_empresa,'logo_gbstec_sistema.jpg'),
		@nm_cor_empresa             = case when isnull(e.nm_cor_empresa,'')<>'' then isnull(e.nm_cor_empresa,'#1976D2') else '#1976D2' end,
		@nm_endereco_empresa 	    = isnull(e.nm_endereco_empresa,''),
		@cd_telefone_empresa	    = isnull(e.cd_telefone_empresa,''),
		@nm_email_internet	  	    = isnull(e.nm_email_internet,''),
		@nm_cidade			    	= isnull(c.nm_cidade,''),
		@sg_estado				    = isnull(es.sg_estado,''),
		@nm_fantasia_empresa	    = isnull(e.nm_fantasia_empresa,''),
		@cd_cep_empresa			    = isnull(dbo.fn_formata_cep(e.cd_cep_empresa),''),
		@cd_numero_endereco_empresa = ltrim(rtrim(isnull(e.cd_numero,0))),
		@nm_pais					= ltrim(rtrim(isnull(p.sg_pais,''))),
		@cd_cnpj_empresa			= dbo.fn_formata_cnpj(ltrim(rtrim(isnull(e.cd_cgc_empresa,'')))),
		@cd_inscestadual_empresa	=  ltrim(rtrim(isnull(e.cd_iest_empresa,''))),
		@nm_dominio_internet		=  ltrim(rtrim(isnull(e.nm_dominio_internet,'')))
			   
	from egisadmin.dbo.empresa e	with(nolock)
	left outer join Estado es		with(nolock) on es.cd_estado = e.cd_estado
	left outer join Cidade c		with(nolock) on c.cd_cidade  = e.cd_cidade and c.cd_estado = e.cd_estado
	left outer join Pais p			with(nolock) on p.cd_pais = e.cd_pais
	where 
		cd_empresa = @cd_empresa


---------------------------------------------------------------------------------------------------------------------------------------------
--Dados do Relatorio
---------------------------------------------------------------------------------------------------------------------------------------------

declare @html            varchar(max) = '' --Total
declare @html_empresa    varchar(max) = '' --Cabecalho da Empresa
declare @html_titulo     varchar(max) = '' --Titulo
declare @html_cab_det    varchar(max) = '' --Cabecalho do Detalhe
declare @html_detalhe    varchar(max) = '' --Detalhes
declare @html_rod_det    varchar(max) = '' --Rodape do Detalhe
declare @html_rodape     varchar(max) = '' --Rodape
declare @html_geral      varchar(max) = '' --Geral

declare @data_hora_atual varchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''
set @html_geral   = ''


set @data_hora_atual = convert(varchar, getdate(), 103) + ' ' + convert(varchar, getdate(), 108)


----------------------------------------------------------------------------------------------------------------------


SET @html_empresa = '
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title >'+isnull(@titulo,'')+'</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            color: #333;
			padding:20px;
        }

        h2 {
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }

        table,
        th,
        td {
            border: 1px solid #ddd;
        }

        th,
        td {
            padding: 10px;
			text-align: center;
        }

        th {
            background-color: #f2f2f2;
            color: #333;
            text-align: center;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .header {
            padding: 5px;
            text-align: center;
        }

        .section-title {
			background-color: #1976D2;
			color: white;
			padding: 5px;
			margin-bottom: 10px;
			border-radius: 5px;
			font-size: 100%;
			margin-left: 0;
			margin-right: 0;
		}

        img {
            max-width: 250px;
            margin-right: 10px;
        }

        .company-info {
            text-align: right;
            margin-bottom: 10px;
        }

        .proposal-info {
            text-align: left;
            margin-bottom: 10px;
        }

        .title {
            color: #1976D2;
        }

        .report-date-time {
            text-align: right;
            margin-bottom: 5px;
            margin-top: 50px;
        }

        p {
            margin: 5px;
            padding: 0;
        }

        .tamanhoTabela {
			font-size:14px;
            text-align: center;
        }
		.AlinharTabela {
            display:flex; 
            gap:10px;
            justify-content: space-between;
        }
		.TotalTable{
            font-weight: bold;
            font-size: 15px;
        }

    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:35%; margin-right:20px">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:45%; padding-left:10px">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		</div> 
		'


--Procedure de Cada Relatorio-------------------------------------------------------------------------------------
  
declare @cd_item_relatorio  int           = 0  
declare @nm_cab_atributo    varchar(100)  = ''  
declare @nm_dados_cab_det   varchar(max) = ''  
declare @nm_grupo_relatorio varchar(60)   = ''  
  
select a.*, g.nm_grupo_relatorio into #RelAtributo   
from  
  egisadmin.dbo.Relatorio_Atributo a   
  inner join egisadmin.dbo.relatorio_grupo g on g.cd_grupo_relatorio = a.cd_grupo_relatorio  
where   
  a.cd_relatorio = @cd_relatorio  
  
  --and  
  --g.cd_grupo_relatorio = 4  
  
order by  
  qt_ordem_atributo  
  
------------------------------------------------------------------------------------------------------------------  
  
  
select * into #AuxRelAtributo from #RelAtributo  
where  
  cd_grupo_relatorio = @cd_grupo_relatorio  
  
order by qt_ordem_atributo  
  
--select * from #AuxRelAtributo  
  
while exists ( select top 1 cd_item_relatorio from #AuxRelAtributo order by qt_ordem_atributo)  
begin  
  
  select top 1   
    @cd_item_relatorio  = cd_item_relatorio,  
 @nm_cab_atributo    = nm_cab_atributo,  
 @nm_grupo_relatorio = nm_grupo_relatorio  
  from  
    #AuxRelAtributo  
  order by  
    qt_ordem_atributo  
  
  
  set @nm_dados_cab_det = @nm_dados_cab_det + '<th> '+ @nm_cab_atributo+'</th>'  
  
  delete from #AuxRelAtributo  
  where  
    cd_item_relatorio = @cd_item_relatorio  
  
end  
  
--SELECT @nm_dados_cab_det  
  
drop table #AuxRelAtributo  
  
 
if isnull(@cd_parametro,0) = 2  
 begin  
  select * from #RelAtributo  
  return  
end  
--set @cd_processo = 1 
------------------------------------------------------------------------------------------------------------
 declare @ic_tipo_produto_pp char(1)
select
   @ic_tipo_produto_pp = isnull(ic_tipo_produto_pp, 'F')
from 
  parametro_manufatura
where
  cd_empresa = dbo.fn_empresa()

select     
  pp.*,
  @ic_tipo_produto_pp as ic_tipo_produto_pp ,
  p.cd_interno_projeto,
  pc.nm_item_desenho_projeto,
  (isnull(pc.qt_item_projeto,0)*isnull(pcm.qt_projeto_material,0))         as Qtd_Processo,
  pc.nm_item_desenho_projeto +'/'+cast(pcm.cd_projeto_material as varchar) as 'Material',
  sp.nm_status_processo,
  c.nm_fantasia_cliente, 
  pv.ds_pedido_venda,
  pv.dt_pedido_venda,  
  pvi.dt_entrega_vendas_pedido,
  v.nm_fantasia_vendedor,
  isnull(pv.ic_garantia_pedido_venda,'N') as ic_garantia_pedido_venda,
  isnull(pv.ic_amostra_pedido_venda,'N') as ic_amostra_pedido_venda,
  case
    when isnull(pvi.cd_pedido_venda,0) > 0 then
      case when isnull(pvi.cd_servico,0)>0 then
        cast(pvi.cd_servico as varchar(25))
      else
        case when isnull(pvi.cd_produto,0)>0 then
          pd.cd_mascara_produto
        else
          cast(pvi.cd_grupo_produto as varchar(25)) end
      end
    else
      pd.cd_mascara_produto
  end                                               as cd_mascara_produto,


  Case 
    When IsNull(pp.cd_id_item_pedido_venda,0) = 0 then
      case when isnull(pvi.cd_servico,0) > 0 then
        cast(s.nm_servico as varchar(25))
      else
         case when isnull(pvi.cd_produto,0)>0 and pvi.cd_produto = pp.cd_produto then
            IsNull(pvi.nm_fantasia_produto, pd.nm_fantasia_produto) 
         else pd.nm_fantasia_produto end
     end
    Else pd.nm_fantasia_produto
  End                                               as nm_fantasia_produto,


  Case  
    When isnull(pvi.cd_produto,0) <> 0 and pvi.cd_produto = pp.cd_produto then pvi.nm_produto_pedido
    When pvi.cd_servico  > 0 Then 
      case 
        when cast(pvi.ds_produto_pedido_venda as varchar(50)) <> '' then 
          s.nm_servico + ' - ' + cast( pvi.ds_produto_pedido_venda as varchar(50) )
        else pvi.nm_produto_pedido
      end
    else 
      case when isnull(pp.cd_produto,0)>0 then
            pd.nm_produto
      else
           pvi.nm_produto_pedido
      end
  End                                                as 'nm_produto',
 
  pd.qt_peso_liquido,
  pd.qt_peso_bruto,
  pd.cd_desenho_produto,
  pd.cd_rev_desenho_produto,
  um.sg_unidade_medida,
  pvi.qt_saldo_pedido_venda, 
  pvi.cd_consulta,
  pvi.cd_item_consulta,
  pvi.ic_orcamento_pedido_venda,
  op.sg_origem_processo,
  mp.nm_mat_prima,
  pvi.cd_pdcompra_item_pedido,
  ni.nm_nivel_inspecao,
  case when pad.dt_revisao_processo < '01/01/2000' then null else pad.dt_revisao_processo end as dt_revisao_processo,
  cor.nm_cor,
  pd.qt_multiplo_embalagem

  into
  #Ordem_Producao_capa

from
  Processo_Producao pp                     with (nolock) 
  left outer join Projeto p                       on p.cd_projeto       = pp.cd_projeto
  left outer join Projeto_Composicao pc           on pc.cd_projeto      = pp.cd_projeto and
                                                     pc.cd_item_projeto = pp.cd_item_projeto
  left outer join Projeto_Composicao_Material pcm on pcm.cd_projeto = pp.cd_projeto and
                                                     pcm.cd_item_projeto=pp.cd_item_projeto and
                                                     pcm.cd_projeto_material=pp.cd_projeto_material
  left outer join Pedido_Venda pv                 on pv.cd_pedido_venda = pp.cd_pedido_venda 
  left outer join Pedido_Venda_Item pvi           on pp.cd_pedido_venda = pvi.cd_pedido_venda and
                                                     pp.cd_item_pedido_venda = pvi.cd_item_pedido_venda 
  left outer join Vendedor v                      on v.cd_vendedor = pv.cd_vendedor
  left outer join Produto pd                      on pd.cd_produto = pp.cd_produto
  left outer join Servico s                       on s.cd_servico = pvi.cd_servico
  left outer join Unidade_Medida um               on um.cd_unidade_medida=pd.cd_unidade_medida
  left outer join Cliente c                       on case when isnull(pv.cd_cliente,0)=0 then pp.cd_cliente else pv.cd_cliente end  = c.cd_cliente 
  left outer join Status_Processo sp              on sp.cd_status_processo = pp.cd_status_processo 
  left outer join Origem_Processo op              on op.cd_origem_processo = pp.cd_origem_processo 
  left outer join Materia_Prima mp                on mp.cd_mat_prima = pcm.cd_materia_prima
  left outer join Processo_Qualidade pq           on pq.cd_processo = pp.cd_processo
  left outer join Nivel_Inspecao ni               on ni.cd_nivel_inspecao = pq.cd_nivel_inspecao
  left outer join processo_padrao pad             on pad.cd_processo_padrao = pp.cd_processo_padrao
  left outer join Cor cor                         on cor.cd_cor = pd.cd_cor
where
  pp.cd_processo = @cd_processo

------------------------------------------------------------------------------------------------------------
declare @cd_produto  int = 0
select
   --@ic_impressao_composicao=isnull(ic_impressao_composicao,'N'),
   @ic_tipo_produto_pp = isnull(ic_tipo_produto_pp, 'F')
from
    parametro_manufatura
where
   cd_empresa = @cd_empresa

select
  @cd_produto = isnull(cd_produto,0)
from
  processo_producao pp
where
  cd_processo = @cd_processo


select
  p.cd_mascara_produto,
  p.nm_fantasia_produto,
  p.nm_produto,
  @ic_tipo_produto_pp  as ic_tipo_produto_pp,
  um.sg_unidade_medida,
  dbo.fn_produto_localizacao(ppc.cd_produto,ppc.cd_fase_produto) as 'Localizacao',
  ps.qt_saldo_atual_produto                                      as 'Saldo_Fisico',
  ps.qt_saldo_reserva_produto                                    as 'Saldo_Disponivel',
  fp.nm_fase_produto,
  fp.sg_fase_produto,
  case when isnull(pp.qt_planejada_processo,0)>0 
  then
     case when isnull(ppc.qt_comp_processo,0)<>0 then
          ppc.qt_comp_processo
     else
       pc.qt_produto_composicao
     end / pp.qt_planejada_processo
  else
     0
  end                                                            as 'qt_unitario_comp',
  tpp.nm_tipo_produto_projeto, 
  tpp.sg_tipo_produto_projeto,

  case when isnull(ppg.cd_processo,0)<>0 then
    ppg.cd_processo
  else
    0
  end                                                             as 'cd_processo_gerado',
  isnull(ppc.qt_real_processo,0)                                  as 'qt_real_processo',
  isnull(ppc.cd_lote_item_processo,'')                            as 'cd_lote_item_processo',
  ppc.cd_produto                                                  as 'cd_produto_chave',
  ppc.nm_obs_comp_processo,
  case when isnull(ppc.qt_comp_processo,0)<>0 then
  ppc.qt_comp_processo
  else
   pc.qt_produto_composicao
  end as qt_comp_processo

  into 
  #Materiais

from

  Processo_Producao_Componente ppc   with (nolock) 
  left outer join  fn_composicao_produto_quantidade(@cd_produto,0) pc on ppc.cd_produto       = pc.cd_produto                                                                                                                           
  inner join Processo_Producao pp                                  on pp.cd_processo       = @cd_processo
  left outer join Produto p                                        on p.cd_produto         = pc.cd_produto
  left outer join Unidade_Medida um                                on um.cd_unidade_medida = p.cd_unidade_medida
  left outer join Fase_Produto fp                                  on fp.cd_fase_produto   = pc.cd_fase_produto
  left outer join Produto_Saldo ps                                 on ps.cd_produto        = pc.cd_produto and
                                                                      ps.cd_fase_produto   = pc.cd_fase_produto 
  left outer join Produto_Processo pr                              on pr.cd_produto        = pc.cd_produto
  left outer join Tipo_Produto_Projeto tpp                         on tpp.cd_tipo_produto_projeto = pr.cd_tipo_produto_projeto
  left outer join Processo_Producao ppg                            on ppg.cd_produto = pc.cd_produto and (ppg.cd_processo_origem = pp.cd_processo_origem or ppg.cd_processo_origem = pp.cd_processo )

where
  ppc.cd_processo = @cd_processo


order by
   ppc.cd_componente_processo
-----------------------------------------------------------------------------------------------------------------------------------------------------
declare @ic_proc_conversao_hora char(1)

select
   @ic_proc_conversao_hora = isnull(ic_proc_conversao_hora,'N')
from
  parametro_manufatura with (nolock) 
where
  cd_empresa = @cd_empresa

select
  identity(int,1,1) as cd_controle,
  ppc.*,
  m.nm_maquina                                      as nm_maquina_completo,
  case when m.ic_processo_maquina='D' then
    m.nm_maquina
  else m.nm_fantasia_maquina end as nm_maquina,
  case when gm.ic_processo_grupo_maquina='D' then
    gm.nm_grupo_maquina 
  else gm.nm_fantasia_grupo_maquina  end as nm_grupo_maquina  ,
  se.nm_servico_especial,
  se.ic_fornecedor_serv_especial,
  f.nm_fantasia_fornecedor,

  qt_hora = case when @ic_proc_conversao_hora='N' then
                 qt_hora_estimado_processo 
                   else
                 qt_hora_estimado_processo/60 
                 end,

  qt_setup = case when @ic_proc_conversao_hora='N' then
                 qt_hora_setup_processo 
                   else
                 qt_hora_setup_processo/60 
                 end,
    @ic_proc_conversao_hora as ic_proc_conversao_hora

	into
	#Operacao_rel

from Processo_Producao_Composicao ppc with (nolock) 
left outer join Maquina m            on m.cd_maquina = ppc.cd_maquina
left outer join Grupo_Maquina gm     on gm.cd_grupo_maquina  = ppc.cd_grupo_maquina
left outer join Servico_Especial se  on ppc.cd_servico_especial = se.cd_servico_especial
left outer join Fornecedor f         on ppc.cd_fornecedor = f.cd_fornecedor
where
  ppc.cd_processo = @cd_processo

order by ppc.cd_item_processo


------------------------------------------------------------------------------------------------------------
 if isnull(@cd_parametro,0) = 1  
 begin  
    select * from #Ordem_Producao_capa  
  return  
 end 
-------------------------------------------------------------------------------------------------------------
DECLARE 
  @dt_processo              datetime, 
  @nm_fantasia_vendedor     varchar(100) = '',
  @dt_pedido_venda          datetime,
  @cd_item_pedido_venda     int = 0, 
  @cd_pedido_venda          int = 0, 
  @nm_fantasia_cliente      varchar(100) = '',
  @cd_lote_produto_processo varchar(30) = '',
  @cd_processo_padrao       int = 0,
  @dt_entrega_processo      datetime,
  @cd_mascara_produto       varchar(25),
  @nm_fantasia_produto      varchar(100),
  @sg_unidade_medida        varchar(15),
  @qt_planejada_processo    float = 0,
  @nm_obs_prog_processo     varchar(250),
  @nm_produto               varchar(100),
  @nm_descricao_produto		varchar(100),
  @nm_tipo_produto_projeto	varchar(100),
  @Saldo_Disponivel         float = 0, 
  @qt_comp_processo         float = 0,
  @sg_unidade_medida_mat    varchar(30),
  @nm_fase_produto			varchar(35),
  @qt_unitario_comp         float = 0,
  @qt_real_processo         float = 0,
  @cd_lote_item_processo    int = 0,
  @qt_setup					float = 0,
  @qt_hora                  float = 0,
  @nm_status_processo       varchar(30)
--------------------------------------------------------------------------------------------------------------



select 
 
  @dt_processo              = dt_processo,
  @nm_fantasia_vendedor     = nm_fantasia_vendedor,
  @dt_pedido_venda          = dt_pedido_venda,
  @cd_item_pedido_venda     = cd_item_pedido_venda,
  @cd_pedido_venda          = cd_pedido_venda,
  @nm_fantasia_cliente      = nm_fantasia_cliente,
  @cd_lote_produto_processo = cd_lote_produto_processo,
  @cd_processo_padrao       = cd_processo_padrao,
  @dt_entrega_processo      = dt_entrega_processo,
  @cd_mascara_produto       = cd_mascara_produto,
  @nm_fantasia_produto      = nm_produto,
  @sg_unidade_medida        = sg_unidade_medida,
  @qt_planejada_processo    = qt_planejada_processo,
  @nm_obs_prog_processo     = nm_obs_prog_processo,
  @nm_status_processo       = nm_status_processo
  
from #Ordem_Producao_capa



select 

	@nm_produto              = nm_produto,
	@nm_descricao_produto    = nm_fantasia_produto,
	@nm_tipo_produto_projeto = nm_tipo_produto_projeto,
	@Saldo_Disponivel        = Saldo_Disponivel,
    @qt_comp_processo        = qt_comp_processo,
	@sg_unidade_medida_mat   = sg_unidade_medida,
	@nm_fase_produto         = nm_fase_produto,
	@qt_unitario_comp        = qt_unitario_comp,
	@qt_real_processo        = qt_real_processo,
	@cd_lote_item_processo   = cd_lote_item_processo
from #materiais


select 

 @qt_setup = sum(qt_setup),
 @qt_hora  = sum(qt_hora)

from #Operacao_rel

--------------------------------------------------------------------------------------------------------------
set @html_geral = '
        <div style="width:20%; text-align: right;padding-right:20px; font-size: 20px;color: red;">
            <p>O.P: '+cast(isnull(@cd_processo,0) as varchar)+'</p>
			<p>Status: '+isnull(@nm_status_processo,'')+'</p>
        </div>
    </div>
    <h1 style="text-align: center;">Ordem de Produção</h1>
    <p class="section-title" style="font-weight: bold;text-align: left; font-size: 18px;">Ordem Produção</p>
    <table>
        <tr>
            <td>
                <div class="AlinharTabela">
                    <p><strong>Pedido:</strong> '+cast(isnull(@cd_pedido_venda,0)as varchar)+'</p>
                    <p><strong>Item:</strong>'+cast(isnull(@cd_item_pedido_venda,0)as varchar)+' </p>
                    <p><strong>Emissão: </strong>'+isnull(dbo.fn_data_string(@dt_pedido_venda),'')+'</p>
                    <p><strong>Vendedor: </strong>'+isnull(@nm_fantasia_vendedor,'')+'</p>
					<p><strong>Data: </strong>'+isnull(dbo.fn_data_string(@dt_processo),'')+'</p>
                </div>
            </td>
        </tr>
    </table>
    <table>
        <tr>
            <td>
                <div class="AlinharTabela">                    
                    <p><strong>Cliente:</strong>'+ISNULL(@nm_fantasia_cliente,'')+'</p>
                    <p><strong>Lote:</strong> '+ISNULL(@cd_lote_produto_processo,'')+' </p>
                    <p><strong>Processo Padrão: </strong>'+cast(isnull(@cd_processo_padrao,0)as varchar)+'</p>
                    <p><strong>Entrega: </strong>'+isnull(dbo.fn_data_string(@dt_entrega_processo),'')+'</p>
                </div>
            </td>
        </tr>
    </table>               
    <table>
        <tr>
            <td>
                <div class="AlinharTabela">
                    <p><strong>Código:</strong> '+ISNULL(@cd_mascara_produto,'')+'</p>
                    <p><strong>Produto:</strong> '+ISNULL(@nm_fantasia_produto,'')+'</p>
                    <p><strong>Unidade: </strong>'+ISNULL(@sg_unidade_medida,'')+'</p>
                    <p><strong>Quantidade: </strong>'+CAST(isnull(@qt_planejada_processo,0) as varchar)+'</p>
                </div>
            </td>
        </tr>
    </table>     
    <p><strong>Observação: </strong></p>
    <p><strong>'+ISNULL(@nm_obs_prog_processo,'')+'</strong></p>
    <p class="section-title" style="font-weight: bold;text-align: left;font-size: 18px;">Materiais</p>
    
    <table style="width: 100%;">
        <tr>
            <th>Cód Produto</td>
            <th>Descrição</th>
            <th>Tipo</th>
            <th>Disponivel</th>
            <th>Qtd.</th>    
            <th>Un.</th>
            <th>Fase</th>
			<th>Qtd Unitário</th>
			<th>Apontamento</th>
			<th>Lote</th>
        </tr>
		<tr>
            <td>'+isnull(@nm_produto,'')+'</td>
            <td>'+isnull(@nm_descricao_produto,'')+'</td>
            <td>'+isnull(@nm_tipo_produto_projeto,'')+'</td> 
            <td>'+CAST(isnull(dbo.fn_formata_valor(@Saldo_Disponivel),0) as varchar)+'</td>
            <td>'+CAST(isnull(dbo.fn_formata_valor(@qt_comp_processo),0) as varchar)+'</td> 
            <td>'+isnull(@sg_unidade_medida_mat,'')+'</td>
            <td>'+ISNULL(@nm_fase_produto,'')+'</td>
			<td>'+CAST(isnull(dbo.fn_formata_valor(@qt_unitario_comp),0) as varchar)+'</td>
			<td>'+CAST(isnull(dbo.fn_formata_valor(@qt_real_processo),0) as varchar)+'</td> 
			<td>'+CAST(isnull(@cd_lote_item_processo,0) as varchar)+'</td>
        </tr> 
    </table>

    <p class="section-title" style="font-weight: bold;text-align: left;font-size: 18px;">Operações</p>
    <table class="tamanhoTabela">
        <tr>
            <th>Seq.</th>
            <th>Maquina</th>
            <th>Setup</th>
            <th>Prod.</th>
        </tr>'

--------------------------------------------------------------------------------------------------------------------
while exists ( select cd_controle from #Operacao_rel )  
begin  
  
  select top 1  
    @id           = cd_controle,  
    @html_geral = @html_geral + '  
           <tr >      
            <td >'+cast(isnull(cd_item_processo,0) as varchar(20))+'</td>  
			<td style="text-align: left">'+isnull(nm_maquina,'')+'</td>    
		    <td>'+isnull(dbo.fn_formata_valor_decimal(qt_setup,3),0) +'</td>     
            <td>'+isnull(dbo.fn_formata_valor_decimal(qt_hora,3),0) +'</td>   
           </tr>'  
         
  from  
    #Operacao_rel  
  
  order by  
    cd_controle  

  delete from #Operacao_rel  where  cd_controle = @id  
  
  
end  
                 
      
--------------------------------------------------------------------------------------------------------------------


set @html_rodape ='
	       <tr style="font-weight: bold;font-size: 15px;">     
            <td >Total</td>  
			<td ></td>    
		    <td>'+isnull(dbo.fn_formata_valor_decimal(@qt_setup,3),0) +'</td>     
            <td>'+isnull(dbo.fn_formata_valor_decimal(@qt_hora,3),0) +'</td>   
           </tr>
    </table>
    <div class="report-date-time" style="text-align:right">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p><br>
    </div>
	</body>
	</html>'


	
--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +
	@html_geral   + 
	@html_cab_det +
    @html_detalhe +
	@html_rod_det +
    @html_rodape  

---------------------

select 'Ordem_Produção '+CAST(ISNULL(@cd_processo, 0) AS NVARCHAR) AS pdfName,isnull(@html,'') as RelatorioHTML

-------------------------------------------------------------------------------------------------------------------------------------------------------
--select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_egis_relatorio_ordem_producao 379,0,''
------------------------------------------------------------------------------
