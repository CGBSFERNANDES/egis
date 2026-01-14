IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_relatorio_consulta_positivacao_cliente' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_relatorio_consulta_positivacao_cliente

GO

-------------------------------------------------------------------------------
--sp_helptext pr_relatorio_consulta_positivacao_cliente
-------------------------------------------------------------------------------
--pr_egis_relatorio_diario_pedidos_separacao
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2024
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000/2008/2012/2014/2016/2020
--
--Autor(es)        : Carlos Cardoso Fernandes
--
--Banco de Dados   : Egissql - Banco do Cliente 
--
--Objetivo         : Relatório Padrão Egis HTML - EgisMob, EgisNet, Egis
--Data             : 24.08.2024
--Alteração        : 
--
--
------------------------------------------------------------------------------
create procedure pr_relatorio_consulta_positivacao_cliente
@cd_relatorio int   = 0,
@json nvarchar(max) = '' 

--with encryption
--use egissql_317

as

set @json = isnull(@json,'')
declare @data_grafico_bar       nvarchar(max)
declare @cd_empresa             int = 0
declare @cd_form                int = 0
declare @cd_usuario             int = 0
declare @dt_usuario             datetime = ''
declare @cd_documento           int = 0
declare @cd_parametro           int = 0
declare @dt_hoje                datetime
declare @dt_inicial             datetime
declare @dt_final               datetime
declare @cd_ano                 int    
declare @cd_mes                 int    
declare @cd_dia                 int
--declare @cd_relatorio           int = 0

--Dados do Relatório---------------------------------------------------------------------------------

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
			@nm_fantasia_cliente  	    varchar(200) = '',
			@cd_cnpj_cliente		    varchar(30) = '',
			@nm_razao_social_cliente	varchar(200) = '',
			@nm_endereco_cliente		varchar(200) = '',
			@nm_bairro					varchar(200) = '',
			@nm_cidade_cliente			varchar(200) = '',
			@sg_estado_cliente			varchar(5)	= '',
			@cd_numero_endereco			varchar(20) = '',
			@cd_telefone				varchar(20) = '',
			@nm_condicao_pagamento		varchar(100) = '',
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

set @dt_hoje           = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)        
set @cd_parametro      = 0
set @cd_empresa        = 0
set @cd_form           = 0
set @cd_parametro      = 0
set @cd_documento      = 0
set @dt_usuario        = GETDATE()
------------------------------------------------------------------------------------------------------

if @json<>''
begin
  select                     
    1                                                    as id_registro,
    IDENTITY(int,1,1)                                    as id,
    valores.[key]  COLLATE SQL_Latin1_General_CP1_CI_AI  as campo,                     
    valores.[value]              as valor                    
                    
    into #json                    
    from                
      openjson(@json)root                    
      cross apply openjson(root.value) as valores      

-------------------------------------------------------------------------------------------------

--select * from #json

-------------------------------------------------------------------------------------------------

  select @cd_empresa             = valor from #json where campo = 'cd_empresa'             
  select @cd_usuario             = valor from #json where campo = 'cd_usuario'             
  select @cd_documento           = valor from #json where campo = 'cd_documento_form'
  select @cd_relatorio           = valor from #json where campo = 'cd_relatorio_form'
  select @dt_inicial             = valor from #json where campo = 'dt_inicial'
  select @dt_final               = valor from #json where campo = 'dt_final'


   set @cd_documento = isnull(@cd_documento,0)

   if @cd_documento = 0
   begin
     select @cd_documento           = valor from #json where campo = 'cd_documento'

   end
end


-------------------------------------------------------------------------------------------------
declare @ic_processo char(1) = 'N'
 
 --select @cd_relatorio

select
  @titulo      = nm_relatorio,
  @ic_processo = isnull(ic_processo_relatorio, 'N')
from
  egisadmin.dbo.Relatorio
where
  cd_relatorio = @cd_relatorio

----------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------

 --select @cd_processo as cd_processo, @json as jsonT into JsonProcesso
  --select * from JsonProcesso
  --drop table JsonProcesso

-----------------------------------------------------------------------------------------
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
		@nm_cor_empresa		   	    = isnull(e.nm_cor_empresa,'#1976D2'),
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
--Dados do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------

declare @html            nvarchar(max) = '' --Total
declare @html_empresa    nvarchar(max) = '' --Cabeçalho da Empresa
declare @html_titulo     nvarchar(max) = '' --Título
declare @html_cab_det    nvarchar(max) = '' --Cabeçalho do Detalhe
declare @html_detalhe    nvarchar(max) = '' --Detalhes
declare @html_rod_det    nvarchar(max) = '' --Rodapé do Detalhe
declare @html_rodape     nvarchar(max) = '' --Rodape
declare @html_geral      nvarchar(max) = '' --Geral

declare @data_hora_atual nvarchar(50)  = ''

set @html         = ''
set @html_empresa = ''
set @html_titulo  = ''
set @html_cab_det = ''
set @html_detalhe = ''
set @html_rod_det = ''
set @html_rodape  = ''
set @html_geral   = ''

-- Obtém a data e hora atual
set @data_hora_atual = convert(nvarchar, getdate(), 103) + ' ' + convert(nvarchar, getdate(), 108)
------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------
--Título do Relatório
---------------------------------------------------------------------------------------------------------------------------------------------
--select * from egisadmin.dbo.relatorio


--select @titulo
--
--select @nm_cor_empresa
-----------------------
--Cabeçalho da Empresa----------------------------------------------------------------------------------------------------------------------
-----------------------

SET @html_empresa = '
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title >'+@titulo+'</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            color: #333;
        }

        .section-title {
            background-color: '+@nm_cor_empresa+';
            color: white;
            padding: 5px;
            margin-bottom: 10px;
			border-radius:5px;
			font-size: 120%;
        }
       
        img {
            max-width: 250px;
			margin-right:10px;
        }

        .title { 
            color: '+@nm_cor_empresa+';
        }

		p {
			margin:5px;
			padding:0;
		}
		
		.chartsContainer {
        display: flex;
        padding: 50px;
        gap: 20px;
      }

     
    </style>

    </style>
</head>
<body>
   
    <div style="display: flex; justify-content: space-between; align-items:center">
		<div style="width:30%; margin-right:20px">
			<img src="'+@logo+'" alt="Logo da Empresa">
		</div>
		<div style="width:70%; padding-left:10px">
			<p class="title">'+@nm_fantasia_empresa+'</p>
		    <p><strong>'+@nm_endereco_empresa+', '+@cd_numero_endereco_empresa + ' - '+@cd_cep_empresa+ ' - '+@nm_cidade+' - '+@sg_estado+' - ' + @nm_pais + '</strong></p>
		    <p><strong>Fone: </strong>'+@cd_telefone_empresa+' - <strong>CNPJ: </strong>' + @cd_cnpj_empresa + ' - <strong>I.E: </strong>' + @cd_inscestadual_empresa + '</p>
		    <p>'+@nm_dominio_internet+ ' - ' + @nm_email_internet+'</p>
		</div>    
    </div>'

--select @html_empresa

		

--Detalhe--
--Procedure de Cada Relatório-------------------------------------------------------------------------------------

select a.*, g.nm_grupo_relatorio into #RelAtributo 
from
  egisadmin.dbo.Relatorio_Atributo a 
  left outer join egisadmin.dbo.relatorio_grupo g on g.cd_grupo_relatorio = a.cd_grupo_relatorio
where 
  a.cd_relatorio = @cd_relatorio
order by
  qt_ordem_atributo

declare @cd_item_relatorio  int           = 0
declare @nm_cab_atributo    varchar(100)  = ''
declare @nm_dados_cab_det   nvarchar(max) = ''
declare @nm_grupo_relatorio varchar(60)   = ''


--select * from egisadmin.dbo.relatorio_grupo

select * into #AuxRelAtributo from #RelAtributo order by qt_ordem_atributo

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

--select @nm_dados_cab_det

--select @nm_grupo_relatorio,@nm_dados_cab_det,* from #RelAtributo


--------------------------------------------------------------------------------------------------------------------------

declare @vl_ponto_venda         decimal(25,2) = 700
declare @pc_positivacao_cliente decimal(25,2) = 80
declare @qt_cliente_positivado  int           = 0


--set @dt_inicial  = '12/01/2024'
--set @dt_final    = '12/31/2024'

select
  @vl_ponto_venda          = ISNULL(vl_ponto_venda,0),
  @pc_positivacao_cliente  = ISNULL(pc_positivacao_cliente,0)
from
  Politica_Comercial_Periodo
where
  dt_inicio_periodo = @dt_inicial and
  dt_final_periodo  = @dt_final

select 
  c.cd_vendedor,
  MAX(v.nm_fantasia_vendedor)   as nm_fantasia_vendedor,
  count(distinct c.cd_cliente ) as qt_cliente,
  @vl_ponto_venda * COUNT(distinct c.cd_cliente) as vl_meta  
 
  into #PoliticaMes

 from 
   cliente c 
   inner join Vendedor v on v.cd_vendedor = c.cd_vendedor
 where 
   c.cd_status_cliente = 1
 group by
   c.cd_vendedor

declare @qt_total                decimal(25,2) = 0
declare @pc_positivacao          decimal(25,2) = 0
declare @qt_meta_dia_positicacao decimal(25,2) = 0

select
  @qt_total = SUM(qt_cliente)
from
  #PoliticaMes


------------------------------------------------------------------------------------------------------------------
select
  @qt_cliente_positivado = COUNT(distinct n.cd_cliente)
from
  nota_saida n
  inner join Operacao_Fiscal opf                     on opf.cd_operacao_fiscal     = n.cd_operacao_fiscal
  inner join Grupo_Operacao_Fiscal g                 on g.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal

where
  n.dt_nota_saida between @dt_inicial and @dt_final
  and
  n.cd_status_nota<>7
	and
	n.cd_status_nota<>7
	and
	isnull(opf.ic_comercial_operacao,'N')  = 'S'
	and
	IsNull(opf.ic_analise_op_fiscal,'S') = 'S' 
	and
	g.cd_tipo_operacao_fiscal = 2

set @pc_positivacao = round(@qt_cliente_positivado/@qt_total * 100,0)

  declare @qt_dia_util   as integer  
  declare @qt_dia_transc as integer  
  declare @dt_agenda     as datetime
 
  set @dt_hoje     = convert(datetime,left(convert(varchar,getdate(),121),10)+' 00:00:00',121)
  set @dt_agenda = @dt_hoje
    
  set @qt_dia_util = ( select count(dt_agenda) from Agenda   
                       where month(dt_agenda) = month(@dt_agenda) and  
                       year(dt_agenda) = year(@dt_agenda) and  
                       ic_util = 'S')  
  
  set @qt_dia_transc = ( select count(dt_agenda) from Agenda   
                       where month(dt_agenda) = month(@dt_agenda) and  
                       year(dt_agenda) = year(@dt_agenda) and  
         dt_agenda <= @dt_agenda and  
                       ic_util = 'S')  


  set @qt_meta_dia_positicacao = round(@qt_total / @qt_dia_util,0)


--select * from #PoliticaMes
--------------------------------------------------------------------------------------------------------------------------


set @data_grafico_bar = (select
						  convert(nvarchar,day(n.dt_nota_saida))  as dt_nota_saida,
						  count(distinct n.cd_cliente)  as qt_cliente_positivado
						from
						  nota_saida n
						  inner join Operacao_Fiscal opf                     on opf.cd_operacao_fiscal     = n.cd_operacao_fiscal
						  inner join Grupo_Operacao_Fiscal g                 on g.cd_grupo_operacao_fiscal = opf.cd_grupo_operacao_fiscal

						where
						  n.dt_nota_saida between @dt_inicial and @dt_final
						  and
						  n.cd_status_nota<>7
							and
							n.cd_status_nota<>7
							and
							isnull(opf.ic_comercial_operacao,'N')  = 'S'
							and
							IsNull(opf.ic_analise_op_fiscal,'S') = 'S' 
							and
							g.cd_tipo_operacao_fiscal = 2

						group by
						  n.dt_nota_saida FOR JSON AUTO)

						 -- select @data_grafico_bar

--------------------------------------------------------------------------------------------------------------

set @html_geral =' <div class="chartsContainer">
      <div class="chartBox" style="width: 39%;">
        <canvas id="myChart"></canvas>
        <p style="margin: 20px;text-align: center;">'+cast(isnull(@pc_positivacao,0) as nvarchar(10))+'(%) Positivação dos clientes foram positivados, do objetivo mensal de '+cast(cast(@qt_total * (@pc_positivacao_cliente / 100)as decimal(25,2)) as nvarchar(25))+'.</p>
      </div>

      <div class="chartBox" style="width: 61%;height: 100%;">
        <canvas id="barChart" ></canvas>
      </div>
    </div>

    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/chart.js/dist/chart.umd.min.js"></script>
    <script>
      const data = {
        labels: ["'+cast(isnull(@qt_cliente_positivado,'') as nvarchar (10))+' Cliente Positivados", "'+CAST((ISNULL(@qt_cliente_positivado, 0) / ISNULL(@qt_dia_transc, 1) * ISNULL(@qt_dia_util, 1)) AS NVARCHAR(20))+' São esperados até hoje (dia '+ CAST(DAY(@dt_agenda) AS NVARCHAR(10)) +')"],
        datasets: [{
          label: "Quantidade",
          data: ['+cast(round(cast(@qt_total as decimal(25,2))*(@pc_positivacao_cliente / 100),0) as nvarchar(25))+',0],
          backgroundColor: [
            "rgb(0, 128, 0)", 
            "rgba(54, 162, 235, 1)"
          ],
          needleValue: '+cast(isnull(@qt_cliente_positivado,'') as nvarchar (10))+', 
          borderColor: "white",
          borderWidth: 2,
          cutout: "55%",
          circumference: 180,
          rotation: 270
        }]
      };
    
      const gaugeNeedle = {
        id: "gaugeNeedle",
        afterDatasetDraw(chart, args, options) {
          const { ctx, config, data, chartArea: { top, bottom, left, right, width, height } } = chart;
          ctx.save();
    
          const needleValue = data.datasets[0].needleValue;
          const dataTotal = data.datasets[0].data.reduce((a, b) => a + b, 0);
          const angle = Math.PI + (1 / dataTotal * needleValue * Math.PI);
          const cx = width / 2;
          const cy = chart._metasets[0].data[0].y;
    
         
          ctx.translate(cx, cy);
          ctx.rotate(angle);
          ctx.beginPath();
          ctx.moveTo(0, -2);
          ctx.lineTo(height - (ctx.canvas.offsetTop + 80), 0);
          ctx.lineTo(0, 2);
          ctx.fillStyle = "rgba(54, 162, 235, 1)"; 
          ctx.fill();
          ctx.translate(-cx, -cy);
          ctx.beginPath();
          ctx.arc(cx, cy, 5, 0, 10);
          ctx.fill();   
          ctx.restore();
    
  
          ctx.font = "50px Helvetica";
          ctx.fillStyle = "rgb(0, 128, 0)";
          ctx.fillText(needleValue, cx, cy + 50);
          ctx.textAlign = "center";
          ctx.restore();
        }
      };
    
      
  const bottomLabelsPlugin = {
  id: "bottomLabels",
  afterDraw(chart) {
    const { ctx, chartArea: { left, right, bottom, width } } = chart;

    ctx.save();
    ctx.font = "22px Arial";
    ctx.textAlign = "center";
    ctx.fillStyle = "black";

    
    const cx = (left + right) / 2;  
    const cy = bottom;             
    const adjustedRadius = width / 3; 

    
    const zeroX = cx - adjustedRadius; 
    const zeroY = cy - 65;             

    const hundredX = cx + adjustedRadius; 
    const hundredY = cy - 65;         


    ctx.fillText("0", zeroX, zeroY);
    ctx.fillText('+cast(round(cast(@qt_total as decimal(25,2))*(@pc_positivacao_cliente / 100),0) as nvarchar(25))+', hundredX, hundredY);

    ctx.restore();
  }
};
    
      const config = {
        type: "doughnut",
        data,
        options: {
          plugins: {
            legend: {
              display: true, 
              position: "bottom", 
              labels: {
                color: "black", 
                font: {
                  size: 18
                }
              }
            },
            title: {
              display: true,
              text: "Positivação",
              font: {
                size: 22
              },
              color: "black"
            },
            tooltip: {
              enabled: true 
            }
          },
          responsive: true,
          scales: { 
                  x: {
                      display: false 
                  },
                  y: {
                      display: false 
            }
          }
        },
        plugins: [gaugeNeedle, bottomLabelsPlugin]
      };'
--------------------------------------------------------------------------------------------------------------
  set @html_cab_det =' 
		const barData = {
      };

      const redLinePlugin = {
        id: "redLine",
        beforeDraw: (chart) => {
          const ctx = chart.ctx;
          const yScale = chart.scales.y;

          
          const yValue = '+cast(isnull(@qt_meta_dia_positicacao,0) as nvarchar(10))+'; 
          const y = yScale.getPixelForValue(yValue);

          ctx.save();
          ctx.beginPath();
          ctx.moveTo(chart.chartArea.left, y);
          ctx.lineTo(chart.chartArea.right, y);
          ctx.strokeStyle = "rgba(255, 99, 132, 1)";
          ctx.lineWidth = 3;
          ctx.stroke();
          ctx.restore();
        },
      };

      const barConfig = {
	  type: "bar",
	  data: {
		datasets: [{
		  label:"Clientes Positivados",
		  data: '+isnull(@data_grafico_bar,'')+'
		},
		{
		label:"Previsão do Dias",
		data: 0
		},
		]
	  },
	  options: {
		parsing: {
		  xAxisKey: "dt_nota_saida",
		  yAxisKey: "qt_cliente_positivado"
		},
	   plugins: {
            legend: {
              position: "bottom",
              labels: {
                font: {
                  size: 18,
                },
              },
            },
            title: {
              display: true,
              text: "Positivação de Clientes Diária",
              font: {
                size: 22,
              },
              padding: {
                top: 20,
                bottom: 100,
              },
            },
          },
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                stepSize: 20,
                min: 0,
                max: 60,
              },
            },
          },
        },
        plugins: [redLinePlugin], 
      };

      const myChart = new Chart(
        document.getElementById("myChart"),
        config
      );
    
      new Chart(document.getElementById("barChart"), barConfig);
    </script>

  </body>
</html>
'
--------------------------------------------------------------------------------------------------------------------
declare @html_totais nvarchar(max)=''
declare @titulo_total varchar(500)=''

set @html_rodape =
    '<div class="company-info">
		<p><strong>'+@footerTitle+'</strong></p>
	</div>
   
    <p>'+@ds_relatorio+'</p>
	<div class="report-date-time">
       <p style="text-align:right">Gerado em: '+@data_hora_atual+'</p>
    </div>'



--HTML Completo--------------------------------------------------------------------------------------

set @html         = 
    @html_empresa +
    @html_titulo  +
	@html_geral   + 
	@html_cab_det +
    @html_detalhe +
	@html_rod_det +
	@html_totais  + 
    @html_rodape  

---------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------
select isnull(@html,'') as RelatorioHTML
-------------------------------------------------------------------------------------------------------------------------------------------------------

go


------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_egis_relatorio_padrao
------------------------------------------------------------------------------
--exec pr_relatorio_consulta_positivacao_cliente 214,'' 
------------------------------------------------------------------------------


