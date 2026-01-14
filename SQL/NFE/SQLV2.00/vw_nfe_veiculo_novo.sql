IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_veiculo_novo' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_veiculo_novo
GO

CREATE VIEW vw_nfe_veiculo_novo  

----------------------------------------------------------------------------------------
--sp_helptext vw_nfe_veiculo_novo  
----------------------------------------------------------------------------------------
--GBS - Global Business Solution                                               2020
----------------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2000  
--Autor(es)        : Carlos Cardoso Fernandes  
--Banco de Dados   : EGISSQL   
--  
--Objetivo         : Geração dos Dados de Veículo para Validação da NFe
--                   Dados Adicionais 
--  
--Data             : 18.09.2020
--Atualização
-- 07.12.2020      : xCor => busca os dados cadastro de cor_veiculo - Pedro Jardim
-- 13.09.2022      : Inclusão de Novos Campos -- Fagner Cardoso
----------------------------------------------------------------------------------------  

  
as      
  
select    
  ns.cd_identificacao_nota_saida,    
  ns.cd_nota_saida,      
  nsi.cd_item_nota_saida,  
  ns.dt_nota_saida,    
  cv.cd_pedido_venda,  
  cv.cd_item_pedido_venda,  
  cast(isnull(tov.sg_nfe_tipo_operacao,'') as char(1))        as tpOp,               --Tipo da Operação,  
  cast(isnull(cv.nm_chassi_veiculo,'') as varchar(17))        as chassi,  
  cast(isnull(cv.cd_cor_montadora,'') as varchar(4))          as cCor,  
  cast(isnull(cor.nm_cor,'') as varchar(40))                  as xCor,  
  cast(isnull(cv.nm_potencia,'')   as varchar(4))             as pot,  
  cast(cast(isnull(qt_cilindradas,0) as int ) as varchar(4))  as cilin,  
  
  --pesoL  
  --pesoB  
  isnull(CONVERT(varchar, convert(numeric(22,0), isnull(cv.qt_peso_veiculo,0)),103),'0.0000') as pesoL,  
  
  isnull(CONVERT(varchar, convert(numeric(22,0), isnull(cv.qt_peso_veiculo,0)),103),'0.0000') as pesoB,  
  
  isnull(cv.nm_serie_veiculo,'')                                                              as nSerie,  
  
  isnull(tc.sg_nfe_tipo_combustivel,'')                                                       as tpComb,  
  
  isnull(cv.nm_numero_motor, '')                                                              as nMotor,  
    
  isnull(CONVERT(varchar, convert(numeric(22,4), isnull(cv.qt_max_tracao,0)),103),'0.0000')   as CMT,  
  
  cast(isnull(cv.qt_distancia_eixo,0) as varchar(4))                                          as dist,  
  cast(isnull(cv.qt_ano_modelo,0) as varchar(4))                                              as anoMod,  
  cast(isnull(cv.qt_ano_fabricacao,0) as varchar(4))                                          as anoFab,  
  cast(isnull(cv.nm_tipo_pintura,'') as varchar(1))                                           as tpPint,  
  cast(isnull(tv.sg_nfe_tipo_veiculo,'') as varchar(2))                                       as tpVeic,  
  cast(isnull(ev.sg_nfe_especie_veiculo,'') as varchar(1))                                    as espVeic,  
  cast(isnull(cc.sg_nfe_condicao,'') as varchar(1))                                           as VIN,  
  cast(isnull(cve.sg_nfe_condicao_veiculo,'') as varchar(1))                                  as condVeic,  
  cast(isnull(cv.nm_marca_modelo,'') as varchar(25))                                          as cMod,  
  cast(isnull(cor.sg_nfe_cor_veiculo,'') as varchar(2))                                       as cCorDENATRAN,   
  cast(isnull(cv.nm_lotacao,0) as varchar(3))                                                 as lota,  
  cast(isnull(rv.sg_nfe_restricao_veiculo,0) as varchar(1))                                   as tpRest,
  cast(isnull(ev.nm_especie_veiculo,0) as varchar(60))                                        as nm_especie_veiculo,    
  cast(isnull(tca.nm_tipo_carroceria,0) as varchar(60))                                       as nm_tipo_carroceria,
  cast(isnull(tr.nm_tipo_rodado,0) as varchar(60))                                            as nm_tipo_rodado  
from  
  Cliente_Veiculo cv               
  left outer join Nota_Saida_Item nsi       on nsi.cd_nota_saida        = cv.cd_nota_saida  
                                           and nsi.cd_item_nota_saida   = cv.cd_item_nota_saida  
  left outer join Nota_Saida ns             on ns.cd_nota_saida         = nsi.cd_nota_saida  
  left outer join Tipo_Operacao_Veiculo tov on tov.cd_tipo_operacao     = cv.cd_tipo_operacao  
  left outer join Condicao_Veiculo cve      on cve.cd_condicao_veiculo  = cv.cd_condicao_veiculo  
  left outer join Restricao_Veiculo rv      on rv.cd_restricao_veiculo  = cv.cd_restricao_veiculo  
  left outer join Especie_Veiculo ev        on ev.cd_especie_veiculo    = cv.cd_especie_veiculo  
  left outer join Condicao_Chassi cc        on cc.cd_condicao           = cv.cd_condicao  
  left outer join Cor_Veiculo cor           on cor.cd_cor               = cv.cd_cor_veiculo  
  left outer join tipo_combustivel tc       on tc.cd_tipo_combustivel   = cv.cd_tipo_combustivel  
  left outer join Tipo_Veiculo tv           on tv.cd_tipo_veiculo       = cv.cd_tipo_veiculo  
  left outer join Tipo_Carroceria tca       on tca.cd_tipo_carroceria   = cv.cd_tipo_carroceria
  left outer join Tipo_Rodado tr            on tr.cd_tipo_rodado        = cv.cd_tipo_rodado
    

--  tpOp Tipo da operação E J01 N 1-1 1 1=Venda concessionária,
--2=Faturamento direto para consumidor final
--3=Venda direta para grandes consumidores (frotista, governo, 
--...)
--0=Outros
--131 J03 chassi Chassi do veículo E J01 C 1-1 17 VIN (código-identificação-veículo)
--132 J04 cCor Cor E J01 C 1-1 1-4 Código de cada montadora
--133 J05 xCor Descrição da Cor E J01 C 1-1 1-40
--134 J06 pot Potência Motor (CV) E J01 C 1-1 1-4 Potência máxima do motor do veículo em cavalo vapor (CV). 
--(potência-veículo)
--135 J07 cilin Cilindradas E J01 C 1-1 1-4 Capacidade voluntária do motor expressa em centímetros 
--cúbicos (CC). (cilindradas) (v2.0)
--136 J08 pesoL Peso Líquido E J01 C 1-1 1-9 Em toneladas - 4 casas decimais
--137 J09 pesoB Peso Bruto E J01 C 1-1 1-9 Peso Bruto Total - em tonelada - 4 casas decimais
--138 J10 nSerie Serial (série) E J01 C 1-1 1-9
--139 J11 tpComb Tipo de combustível E J01 C 1-1 1-2 Utilizar Tabela RENAVAM (v2.0)
--01=Álcool, 02=Gasolina, 03=Diesel, (...);
--16=Álcool/Gasolina; 17=Gasolina/Álcool/GNV
--18=Gasolina/Elétrico
--140 J12 nMotor Número de Motor E J01 C 1-1 1-21
--141 J13 CMT Capacidade Máxima de Tração E J01 C 1-1 1-9 CMT-Capacidade Máxima de Tração - em Toneladas 4 casas 
--decimais (v2.0)
--142 J14 dist Distância entre eixos E J01 C 1-1 1-4
--144 J16 anoMod Ano Modelo de Fabricação E J01 N 1-1 4
--145 J17 anoFab Ano de Fabricação E J01 N 1-1 4
--Nota Fiscal eletrônica
--Manual de Orientação do Contribuinte
--Pág. 189 / 299
--# ID Campo Descrição Ele Pai Tipo Ocor. Tam. Observação
--146 J18 tpPint Tipo de Pintura E J01 C 1-1 1
--147 J19 tpVeic Tipo de Veículo E J01 N 1-1 1-2 Utilizar Tabela RENAVAM, conforme exemplos abaixo:
--02=CICLOMOTO; 03=MOTONETA;
--04=MOTOCICLO; 05=TRICICLO;
--06=AUTOMÓVEL; 07=MICROÔNIBUS; 08=ÔNIBUS;
--10=REBOQUE; 11=SEMIRREBOQUE;
--13=CAMINHONETA; 14=CAMINHÃO;
--17=C. TRATOR; 22=ESP / ÔNIBUS; 23=MISTO / CAM;
--24=CARGA/CAM; ...
--148 J20 espVeic Espécie de Veículo E J01 N 1-1 1 Utilizar Tabela RENAVAM
--1=PASSAGEIRO; 2=CARGA; 3=MISTO;
--4=CORRIDA; 5=TRAÇÃO; 6=ESPECIAL;
--149 J21 VIN Condição do VIN E J01 C 1-1 1 Informa-se o veículo tem VIN (chassi) remarcado.
--R=Remarcado; N=Normal
--150 J22 condVeic Condição do Veículo E J01 N 1-1 1 1=Acabado; 2=Inacabado; 3=Semiacabado
--151 J23 cMod Código Marca Modelo E J01 N 1-1 1-6 Utilizar Tabela RENAVAM
--151a J24 cCorDENATRAN Código da Cor E J01 N 1-1 1-2 Segundo as regras de pré-cadastro do DENATRAN (v2.0)
--01=AMARELO, 02=AZUL, 03=BEGE,
--04=BRANCA, 05=CINZA, 06=-DOURADA,
--07=GRENÁ, 08=LARANJA, 09=MARROM,
--10=PRATA, 11=PRETA, 12=ROSA, 13=ROXA,
--14=VERDE, 15=VERMELHA, 16=FANTASIA
--151b J25 lota Capacidade máxima de lotação E J01 N 1-1 1-3 Quantidade máxima permitida de passageiros sentados, 
--inclusive o motorista. (v2.0)
--151c J26 tpRest Restrição E J01 N 1-1 1 0=Não há; 1=Alienação Fiduciária;
--2=Arrendamento Mercantil; 3=Reserva de Domínio;
--4=Penhor de Veículos; 9=Outras. (v2.0)



------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--select * from vw_nfe_veiculo_novo where cd_nota_saida = 50089
------------------------------------------------------------------------------------

go


