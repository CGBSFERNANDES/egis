IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_produto_servico_nota_fiscal' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_produto_servico_nota_fiscal

GO
------------------------------------------------------------------------------------ 
--sp_helptext vw_nfe_produto_servico_nota_fiscal
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                        2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSvuntribQL 
--
--Objetivo	        : Identificação do Detalhe Produto/Serviço da Nota Fiscal 
--                        paralote o sistema de emissão da Nota Fiscal Eletrônica
--
--Data                  : 05.11.2008
--Atualização           : 23.11.2008 - Ajustes Diversos - Carlos Fernandes
-- 29.11.2008 - Dados do IPI - Carlos Fernandes
-- 11.08.2009 - Ajustes Diversos - Carlos Fernandes
-- 11.09.2009 - Nota Fiscal de Complemento - Carlos Fernandes
-- 16.09.2009 - Auste dos Dados de importação - Carlos Fernandes 
-- 28.09.2009 - Ajuste da Alíquota PIS / COFINS - Carlos Fernandes
-- 30.11.2009 - Lote - Carlos Fernandes
-- 19.12.2009 - Ajuste dos (%) para SUBST. Tributária - Carlos Fernandes
-- 12.03.2010 - Ajuste do Valor do ICMS da Subst. Tributária - Carlos Fernandes
-- 03.05.2010 - Verificação BAse do ICMS ST - Carlos Fernandes
-- 17.06.2010 - Verificação da Tributação do IPI por Unidade - Carlos Fernandes
-- 27.09.2010 - Ajuste para novo lay-out v2.00 - Carlos Fernandes
-- 17.11.2010 - Ajuste das casas decimais do valor do Frete - Carlos/Luis Santana
-- 07.12.2010 - Ajuste para Importação - Carlos Fernandes
-- 10.01.2011 - Código de Barra do Produto - Carlos Fernandes
-- 01.11.2011 - Verificação do código EAN - Carlos Fernandes
-- 01.02.2012 - Mudanças no desconto e casas decimais do vuntrib - Marcelo
-- 06.02.2012 - Mudanças no desconto e casas decimais do vprod  - obrigatorio recalculo para pegar o valor total do item corretamente para evitar o problema do total da nota na validação. - Marcelo
-- 13.03.2012 - Zona Franca Manuas - Desconto - Carlos Fernandes
-- 30.09.2013 - Nome Fmasantasia do Produto - Carlos Fernandes
-- 10.12.2013 - Nova forma de buscar a CSOSN pela Tributação (qrySimples) - Luis/Carlos 
-- 02.10.2014 - Complemento de Campos para o Combustível - Carlos Fernandes
-- 06.10.2014 - Modalidade da Base de Cálculo ST - Carlos Fernandes
-- 23.12.2015 - Novo campo para NCM - Carlos Fernande/Fagner
-- 13.02.2017 - Código de Barra - agora tem o campo no item da Nota Fiscal - Carlos Fernandes
-- 12.07.2017 - novo flag na CFOP para Zerar a NCM quando for CFOP de anulação de frete - Carlos Fernandes
-- 23.07.2018 - Acerto do código de barra - CEAN/gtin - Fagner Cardoso.
-- 07.11.2018 - base de cálculo do PIS/COFINS - Fagner/Carlos 
-- 08.11.2018 - Acerto Base/Aliquota/Valor de IPI 0 quando nota de Devolução - Fagner Cardoso
-- 06.12.2018 - Acerto nos campos tpviatransporte/tpintermedio/vfrmm, quando era feito nota de importação sem DI, esses campos
--            - ficavam em branco e não pegava da tabela nota_saida_importacao - Fagner Cardoso
-- 30.05.2019 - Quando o produto for do cliente e tem a flag de usar na NF, o código e a descrição do Kardex
--						  serão utilizado no XML - Pedro Jardim
-- 18.07.2019 - Acerto Casas decimais vUnCom, qCom, vUnTrib - Fagner Cardoso
-- 14.08.2019 - Acertos dos Campos de IPI- Devolução - Apenas para Simples Nacional - Fagner Cardoso
-- 04.10.2019 - Ajuste do parametro ic_descritivo_nf_produto para concatenar a descrição da NF - Pedro Jardim 
-- 30.10.2019 - Código do Produto do Cliente - Carlos Fernandes
-- 17.02.2020 - Acerto tag vUnTrib e qTrib para calcular peso digitado na nota - Fagner Cardoso
-- 25.03.2020 - Acerto do campo pRedbc20, informar o valor correto de redução - Fagner Cardoso
-- 05.08.2020 - Acerto no xProd, incluso campo de Kardex da nota, quando inserido manualmente -- Fagner Cardoso/Luis Fernando
-- 14.12.2020 - Acerto campo CST40 -- Fagner Cardoso
-- 26.07.2021 - Verificar para Colocar o Código de Produto para Guarufilme - Carlos Fernandes
-- 02.12.2021 - Ajuste do nItemPed para não incluir os zeros a esquerda - Pedro Jardim
-- 16.12.2021 - Acerto Conversão de quantidade quando Exportação campo qTrib e vUnTrib -- Fagner Cardoso 
-- 07.04.2022 - Acerto volumes ( Guarufilme ) -- Fagner Cardoso
-- 29.07.2022 - Ajuste do campo qTrib para não multiplicar pela quantidade ao usar o qt_liquido_item_nota - Pedro Jardim
-- 14.09.2022 - Novo concatenação no xProd - Pedro Jardim
-- 10.05.2023 - Acerto Campo pICMSST30 -- Fagner Cardoso
-- 02.05.2025 - Ajustes no campo cEan e cEanTrib - Denis Rabello
------------------------------------------------------------------------------------------------------------------------------- 
CREATE VIEW vw_nfe_produto_servico_nota_fiscal            
as            
            
select            
  ns.cd_identificacao_nota_saida,            
  ns.dt_nota_saida,            
  nsi.cd_nota_saida,            
  nsi.cd_item_nota_saida,            
  nsi.cd_item_nota_saida                       as 'nItem',            
  isnull(tme.ic_mov_tipo_movimento,'S')        as ic_mov_tipo_movimento,            
  isnull(tipi.cd_digito_tributacao_ipi,'00')   as cd_digito_tributacao_ipi,            
  isnull(ti.cd_digito_tributacao_icms,'00')    as cd_digito_tributacao_icms,            
  isnull(tpis.cd_digito_tributacao_pis,'01')   as cd_digito_tributacao_pis,            
  isnull(tci.cd_digito_tributacao_cofins,'01') as cd_digito_tributacao_cofins,            
  case when isnull(nsi.cd_produto,0)=0  then  
    case when isnull(nsi.cd_mascara_produto,'') <> '' and (dbo.fn_empresa() <> 277) then        
      isnull(nsi.cd_mascara_produto,'')
	else
    case when isnull(nsi.nm_fantasia_produto, '') <> ''
      then isnull(nsi.nm_fantasia_produto, '')
      else 'CFOP9999'
    end
	end            
  else            
    case when isnull(snf.ic_medida_codigo,'N')='S' then isnull(( select top 1 vwp.codigo_produto from vw_medida_produto_item_nota vwp where vwp.cd_pedido_venda = nsi.cd_pedido_venda and vwp.cd_item_pedido_venda = nsi.cd_item_pedido_venda),nsi.cd_mascara_produto)            
 else            
    ltrim(rtrim(isnull(tp.sg_nota_pedido,'')))            
    +            
  case when isnull(pc.ic_nf_produto_cliente,'N')='S' and isnull(pc.nm_fantasia_prod_cliente,'')<>''            
     then case when isnull(pc.cd_nf_produto_cliente,'')<>'' then isnull(pc.cd_nf_produto_cliente,'') else isnull(pc.nm_fantasia_prod_cliente,'') end            
       else            
        case when isnull(p.ic_nf_fantasia_produto,'N')='N' then            
          case when nsi.cd_mascara_produto is null then            
            p.cd_mascara_produto            
          else            
           nsi.cd_mascara_produto            
         end            
       else            
         isnull(nsi.nm_fantasia_produto,p.nm_fantasia_produto)            
     end                 
  end            
  end  end                                                                                            as 'cProd',
            
  case when isnull(efat.ic_gtin_empresa,'N') = 'S'
  then        
  case when (isnull(cg.ic_tipo_ean_dun,'1') = '2') and (rtrim(ltrim(cast(um.sg_unidade_medida as varchar(6)))) = 'CX')
    then case when (isnull(p.cd_dun_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S') 
           then cast(p.cd_dun_barra_produto as varchar(14))            
           else case when (isnull(p.cd_codigo_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S')
                  then cast(p.cd_codigo_barra_produto as varchar(14))            
                  else cast('SEM GTIN' as   varchar(14))                                                                  
                end
         end
    else 

         case when (isnull(p.cd_codigo_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S')
           then cast(p.cd_codigo_barra_produto as varchar(14))            
           else cast('SEM GTIN' as   varchar(14))                                                                  
         end

  end                                                                                                 
  else
    case when isnull(nsi.cd_codigo_barra_produto,'')<>'' 
     then cast(nsi.cd_codigo_barra_produto  as varchar(14))          
     else cast('SEM GTIN' as   varchar(14)) end
  end                                                                                                 as 'cEan',  
 
 case when isnull(pc.ic_desc_produto_cliente,'N')='S' then 
   case when isnull(pc.nm_produto_cliente,'') <> '' then 
      isnull(pc.nm_produto_cliente,'') +
	  case when isnull(snf.ic_pcd_serie_nota_fiscal,'N') = 'S' and isnull(nsi.cd_pd_compra_item_nota,'')<>'' then    
        ' '+rtrim(ltrim(isnull(nsi.cd_pd_compra_item_nota,''))) +
	    ' Seq.: '+rtrim(ltrim(isnull(nsi.cd_it_ped_compra_cliente,''))) 	   
      else    
        ''    
      end
   else  
     ltrim(rtrim(nsi.nm_produto_item_nota)) +
	  case when isnull(snf.ic_pcd_serie_nota_fiscal,'N') = 'S' and isnull(nsi.cd_pd_compra_item_nota,'')<>'' then    
        ' '+rtrim(ltrim(isnull(nsi.cd_pd_compra_item_nota,''))) +
	    ' Seq.: '+rtrim(ltrim(isnull(nsi.cd_it_ped_compra_cliente,''))) 	   
      else    
        ''    
      end
   end            
 else            
        cast( ltrim(rtrim(nsi.nm_produto_item_nota ))            
        +            
        case when isnull(pc.ic_nf_produto_cliente,'N')='S' and isnull(pc.nm_fantasia_prod_cliente,'')<>''            
        then            
          ' ('+ltrim(rtrim(pc.nm_fantasia_prod_cliente))+')'            
        else            
           case when isnull(nsi.nm_kardex_item_nota_saida,'')<> '' then            
              ' ('+ltrim(rtrim(nsi.nm_kardex_item_nota_saida ))+')'            
           else            
              ''            
           end            
        end                                                      
   --Lote            
  +            
  case when isnull(ic_lote_serie_nota_fiscal, 'S' )='S'  and isnull(nsi.cd_lote_item_nota_saida,'')<>'' then            
    ' Lote: '+ltrim(rtrim(nsi.cd_lote_item_nota_saida))            
  else            
   ''            
  end            
  +            
  
  --Pedido Compra Cliente----
  case when isnull(ic_pcd_serie_nota_fiscal,'N') = 'S' and isnull(nsi.cd_pd_compra_item_nota,'')<>''            
  then            
    ' PC '+rtrim(ltrim(isnull(nsi.cd_pd_compra_item_nota,''))) +
	' Item.: '+rtrim(ltrim(isnull(nsi.cd_it_ped_compra_cliente,'')))            
  else            
    ''            
  end  as varchar(120))                
  +
            
  case when isnull(p.cd_certificado_produto,'')<>'' then            
    ' ('+ltrim(rtrim(p.cd_certificado_produto))+') '            
  else            
   ''            
  end                                                                                            
 end 
 +        
 case when isnull(snf.ic_medida_codigo,'N')='S' then        
 case when fam.nm_familia_produto <> 'LINHA DOMÉSTICA' then --Fagner        
       ' ' + cast(isnull(pvim.qt_largura,0) as varchar(10))  +' x '+                    
       cast(isnull(pvim.qt_espessura,0)as varchar(10))       +                    
       case when (isnull(fam.ic_comprimento,'N')= 'S' or isnull(pvim.qt_comprimento,0)>0) then                    
        ' x ' + cast(isnull(pvim.qt_comprimento,0)as varchar(10))                 
       else                    
        '' --+ '('   + cast(isnull(pvim.qt_volume,0) as varchar(10)) + ')'                  
       end        
      + '('   + cast(isnull(case when isnull(pvim.qt_volume_produzida,0)> 0 then pvim.qt_volume_produzida else pvim.qt_volume end,0) as varchar(10)) + ')'         
 else        
    '' + '('   + cast(isnull(case when isnull(pvim.qt_volume_produzida,0)> 0 then pvim.qt_volume_produzida else pvim.qt_volume end,0) as varchar(10)) + ')'        
 end        
 else        
    ''        
 end                                                                                     as 'xprod',             
  cast(            
  case when isnull(nsi.cd_servico,0)<>0 then            
    '99'            
  else            
    case when isnull(opf.ic_anulacao_frete,'N')='N' then            
      rtrim(ltrim(replace(cf.cd_mascara_classificacao,'.',''))) +               
      isnull(replicate('0',2 - len(rtrim(ltrim(replace(cf.cd_mascara_classificacao,'.',''))))),'')
    else            
      ''            
    end            
  end as varchar(8))                                                                                      as 'NCM',            
  rtrim(ltrim(cast(cf.cd_extipi as varchar(10))))                             as 'EXTIPI',            
  rtrim(ltrim(cast(cf.cd_genero_ncm_produto as varchar(10))))                                             as 'genero',            
  rtrim(ltrim(cast(replace(opf.cd_mascara_operacao,'.','') as varchar(10))))                              as 'CFOP',            
  rtrim(ltrim(cast(um.sg_unidade_medida as varchar(6))))                                                  as 'uCom',            
  isnull(CONVERT(varchar, convert(numeric(25,3),round(case when nsi.qt_item_nota_saida    > 0             
  then nsi.qt_item_nota_saida else null end,6,3)),103),'0.000')                                           as 'qCom',  
    
    isnull(CONVERT(varchar, convert(numeric(25,4),round(case when nsi.vl_unitario_item_nota > 0             
    then nsi.vl_unitario_item_nota else null end,25,4)),103),'0.0000')                                     as 'vUnCom',       
 --cast (round (      
 --    case when isnull(nsi.qt_item_nota_saida * nsi.vl_unitario_item_nota,0) > 0 then             
 --        isnull(CONVERT(varchar, convert(numeric(14,4),round(nsi.qt_item_nota_saida * nsi.vl_unitario_item_nota,6,4)),103),'0.00')            
 --    else             
 --      '0.00'            
 --    end , 6,4)  as varchar )                                                                                
    case when isnull(nsi.qt_item_nota_saida * nsi.vl_unitario_item_nota,0) > 0 then             
         isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_total_item,6,2)),103),'0.00')            
     else             
       '0.00'            
     end as 'vProd',  
          
  case when isnull(efat.ic_gtin_empresa,'N') = 'S'
  then        
  case when (isnull(cg.ic_tipo_ean_dun,'1') = '2') and (rtrim(ltrim(cast(um.sg_unidade_medida as varchar(6)))) = 'CX')
    then case when (isnull(p.cd_dun_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S') 
           then cast(p.cd_dun_barra_produto as varchar(14))            
           else case when (isnull(p.cd_codigo_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S')
                  then cast(p.cd_codigo_barra_produto as varchar(14))            
                  else cast('SEM GTIN' as   varchar(14))                                                                  
                end
         end
    else 

         case when (isnull(p.cd_codigo_barra_produto,'')<>'') and (isnull(pf.ic_gtin_nfe_produto,'N') = 'S')
           then cast(p.cd_codigo_barra_produto as varchar(14))            
           else cast('SEM GTIN' as   varchar(14))                                                                  
         end

  end                                                                                                 
  else
    case when isnull(nsi.cd_codigo_barra_produto,'')<>'' 
     then cast(nsi.cd_codigo_barra_produto  as varchar(14))          
     else cast('SEM GTIN' as   varchar(14)) end
  end                                                                                                 as 'cEanTrib',
             
  ltrim(rtrim(cast(case when isnull(opf.ic_exportacao_op_fiscal,'N')='N' Then            
  um.sg_unidade_medida else cfu.sg_unidade_medida end as varchar(6))))                                     as 'uTrib',                   
  
  isnull(CONVERT(varchar, convert(numeric(14,3),round(case when nsi.qt_item_nota_saida> 0                             
  then                             
     case when isnull(opf.ic_exportacao_op_fiscal,'N')='S' then                             
          case when cfu.sg_unidade_medida = 'KG' and cfu.sg_unidade_medida <> um.sg_unidade_medida then                            
             case when isnull(nsi.qt_liquido_item_nota,0)>0 then nsi.qt_liquido_item_nota     
       else     
           case when isnull(p.qt_peso_liquido,0)>0 then isnull(nsi.qt_item_nota_saida,0) * p.qt_peso_liquido else 1 end end    
          else nsi.qt_item_nota_saida                            
          end                            
     else nsi.qt_item_nota_saida                            
     end                            
  else null end,6,3)),103),'0.000')                                                                    as 'qTrib',                                                                      
                            
--nota_saida_item                            
                            
  --isnull(CONVERT(varchar, convert(numeric(25,6),round(case when nsi.vl_unitario_item_nota > 0                    
  -- then                            
  --   case when isnull(opf.ic_exportacao_op_fiscal,'N')='S' then                            
  --      case when cfu.sg_unidade_medida = 'KG' and cfu.sg_unidade_medida <> um.sg_unidade_medida then                            
  --       (isnull(nsi.vl_unitario_item_nota,0) / case when isnull(nsi.qt_liquido_item_nota,0)>0 then nsi.qt_liquido_item_nota else                  
  --                                               case when isnull(p.qt_peso_liquido,0)>0 then p.qt_peso_liquido else 1 end end)                            
  --      else nsi.vl_unitario_item_nota                            
  --      end                            
  --   else nsi.vl_unitario_item_nota                            
  --   end                             
  -- else null end,25,6)),103),'0.0000000')                          as 'vUnTrib',  
    
  
    
  isnull(CONVERT(varchar, convert(numeric(25,4),round(case when nsi.vl_unitario_item_nota > 0                    
   then                            
     case when isnull(opf.ic_exportacao_op_fiscal,'N')='S' then                            
        case when cfu.sg_unidade_medida = 'KG' and cfu.sg_unidade_medida <> um.sg_unidade_medida then                            
         (      cast(case when isnull(nsi.qt_item_nota_saida * nsi.vl_unitario_item_nota,0) > 0 then                             
         isnull(CONVERT(varchar, convert(numeric(14,2),round(nsi.vl_total_item,6,2)),103),'0.00')                            
     else                             
       '0.00'                            
     end as float) /   isnull(CONVERT(varchar, convert(numeric(14,3),round(case when nsi.qt_item_nota_saida> 0                             
  then                             
     case when isnull(opf.ic_exportacao_op_fiscal,'N')='S' then                             
          case when cfu.sg_unidade_medida = 'KG' and cfu.sg_unidade_medida <> um.sg_unidade_medida then                            
             case when isnull(nsi.qt_liquido_item_nota,0)>0 then nsi.qt_liquido_item_nota     
       else     
             case when isnull(p.qt_peso_liquido,0)>0 then isnull(nsi.qt_item_nota_saida,0) * p.qt_peso_liquido else 1 end end    
          else nsi.qt_item_nota_saida                            
          end                            
     else nsi.qt_item_nota_saida                            
     end                            
  else null end,6,3)),103),'0.000'))                            
        else nsi.vl_unitario_item_nota                            
        end                            
     else nsi.vl_unitario_item_nota                            
     end                             
   else null end,25,4)),103),'0.0000')                          as 'vUnTrib',                
            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsi.vl_frete_Item         > 0             
  then nsi.vl_frete_Item else null end,6,2)),103),'0.00')                                             as 'vFrete',            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsi.vl_seguro_item        > 0             
  then nsi.vl_seguro_item else null end ,6,2)),103),'0.00')                                           as 'vSeg',            
  cast(             
    case when isnull(nsi.pc_desconto_item,0) > 0 then            
     isnull(CONVERT(varchar,             
           convert(numeric(14,2),            
           round(  (    (nsi.qt_item_nota_saida * nsi.vl_unitario_item_nota) * ( isnull(nsi.pc_desconto_item,0)/100) ),2)),103),'0.00')              
    else 
      case when isnull(nsi.vl_item_desconto_nota,0) > 0 then
        isnull(nsi.vl_item_desconto_nota,0)
      else
        '0.00' 
      end
    end
  as varchar)                                    as 'vDesc',            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsi.vl_total_item > 0             
  then nsi.vl_total_item else null end,14,2)),103),'0.00')                                               as 'vBC_II',            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsi.vl_desp_aduaneira_item > 0             
  then nsi.vl_desp_aduaneira_item else null end,14,2)),103),'0.00')                                      as 'vDespAnu',            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsi.vl_II > 0             
  then nsi.vl_II else null end,14,2)),103),'0.00')                                                       as 'vII',            
  '0.00'                                                                                                 as 'vIOF',            
  isnull(replace(replace(isnull(nsi.nm_di,nimp.nm_di),'-',''),'/',''),'')                                                         as 'nDI',            
  ltrim(rtrim(replace(convert(char,isnull(di.dt_emissao_di,nimp.dt_emissao_di),102),'.','-')))                                    as 'dDi',            
  cast(isnull(pd.nm_porto,nimp.nm_porto_di) as varchar(60))                                                                       as 'xLocDesemb',            
  cast(isnull(ed.sg_estado,isnull(nimp.sg_estado_di,'SP')) as varchar(02))                                                        as 'UFDesemb',            
  ltrim(rtrim(replace(convert(char,case when isnull(di.dt_desembaraco,nimp.dt_desembaraco) > ns.dt_nota_saida then ns.dt_nota_saida else isnull(di.dt_desembaraco,nimp.dt_desembaraco) end,102),'.','-'))) as 'dDesemb',            
  cast(isnull(timp.cd_nfe_importacao,isnull(nimp.cd_tipo_transporte,'')) as varchar(2))                       as 'tpViaTransp',            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(di.vl_afrmm_di,isnull(nimp.vl_adicional_frete,0)) > 0            
  then isnull(di.vl_afrmm_di,isnull(nimp.vl_adicional_frete,0)) else null end,14,2)),103),'0.00')                                 as 'vAFRMM',            
  cast(isnull(fi.sg_forma_importacao,isnull(nimp.cd_forma_importacao,'')) as varchar(1))                                          as 'tpIntermedio',            
            
  cast(isnull(di.cd_fornecedor,ns.cd_cliente) as varchar(60))                                                                     as 'cExportador',            
  case when isnull(nsi.nm_di,'')<>'' or isnull(nimp.nm_di,'') <> '' then            
   cast(isnull( (select count(*) from nota_saida_item adi where adi.cd_nota_saida = nsi.cd_nota_saida and            
                                                                adi.cd_item_nota_saida = nsi.cd_item_nota_saida             
           group by adi.cd_classificacao_fiscal),0) as varchar)            
  else            
    '0'                                                                                                           
  end                                                                                                  as 'nAdicao',            
  case when isnull(nsi.nm_di,'')<>'' or isnull(nimp.nm_di,'')<>'' then            
   '1'            
  else            
    '0'            
  end                                                                                                  as 'nSeqAdic',            
  '.'     as 'cFabricante',            
  '0.00'                                                                                               as 'vDescDI',            
  --ICMS            
  'ICMS' + ti.cd_digito_tributacao_icms                                                               as 'ICMS',            
  rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))                                as 'orig',            
  rtrim(ltrim(cast(isnull(ti.cd_digito_tributacao_icms,00) as varchar(2))))                           as 'CST',            
  rtrim(ltrim(cast(isnull(mci.cd_digito_modalidade,0)  as varchar(1))))                               as 'modBC',            
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.vl_base_icms_item,0))                                    as 'vBC',            
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.pc_icms,0))                                              as 'pICMS',            
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.vl_icms_item,0))                                         as 'vICMS',            
  dbo.fn_mascara_valor_duas_casas(isnull(pf.pc_iva_icms_produto,0))                                   as 'pIVAICMS',            
  dbo.fn_mascara_valor_duas_casas(isnull(pf.vl_pauta_icms_produto,0))                                 as 'PautaICMS',            
  dbo.fn_mascara_valor_duas_casas(case when isnull(opf.ic_subst_tributaria,'N')='S'             
                                    then nsi.pc_subs_trib_item             
                                    else 0.00 end)                                                    as 'pICMSSUBST',            
  dbo.fn_mascara_valor_duas_casas(case when isnull(opf.ic_subst_tributaria,'N')='S' and              
                                    nsi.vl_bc_subst_icms_item>0             
                                    then isnull(nsi.vl_icms_subst_icms_item,0)            
                                    else 0.00 end)                               as 'vICMSSubst',            
  dbo.fn_mascara_valor_duas_casas(case when isnull(opf.ic_subst_tributaria,'N')='S'             
                                    then isnull(nsi.vl_bc_subst_icms_item,0)            
                                    else 0.00 end)                              as 'vBCICMSSubst',            
  ltrim(rtrim(cast(isnull(tpis.cd_digito_tributacao_pis,'01') as varchar(2))))  as 'CSTPis',            
            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(nsi.vl_total_item,0) > 0 and isnull(tpis.ic_incidencia_tributacao,'N') = 'S'             
  then case when isnull(opf.ic_importacao_op_fiscal,'N')='S' then isnull(nsi.vl_base_pis_item,0) else                
   --isnull(nsi.vl_total_item,0.00) - round(((nsi.qt_item_nota_saida * nsi.vl_unitario_item_nota) * ( isnull(nsi.pc_desconto_item,0)/100)),6,2)            
      isnull(nsi.vl_base_pis_item,0)            
   end else 0.00 end,6,2)),103),'0.00')             as 'vBCPis',            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(nsi.pc_pis,0) > 0 then             
                                                        nsi.pc_pis             
                                                      else            
                                                        case when isnull(nsi.vl_pis,0) > 0 then            
                                                          isnull(CONVERT(varchar, convert(numeric(14,2),round(((nsi.vl_pis * 100)/(nsi.vl_total_item)),6,2)),103),'0.00')               
                                                        end             
                                                      end,6,2)),103),'0.00')             as 'pPIS',            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(nsi.vl_pis,0) > 0 then nsi.vl_pis             
  else             
   case when isnull(tpis.ic_incidencia_tributacao,'N') = 'S'  then            
      isnull(nsi.vl_total_item,0) * ( 1.65/100)             
   else 0.00 end            
  end,6,2)),103),'')                                             as 'vPIS',            
  isnull(CONVERT(varchar, convert(numeric(14,4),round(case when nsi.qt_item_nota_saida > 0 then nsi.qt_item_nota_saida else 0.00 end,6,2)),103),'0.0000')                 
                                                                 as 'qBCProd',            
  '0.00'                                                         as 'vAliqProd',            
  rtrim(ltrim(cast(isnull(tci.cd_digito_tributacao_cofins,'01') as varchar(80))))             as 'CSTCOFINS',            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsi.vl_total_item > 0 and isnull(tci.ic_incidencia_tributacao,'N') = 'S'  then             
  case when isnull(opf.ic_importacao_op_fiscal,'N')='S' then isnull(nsi.vl_base_cofins_item,0) else                
   nsi.vl_base_cofins_item            
  end else 0.00 end,6,2)),103),'0.00')      as 'vBCCOFINS',            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsi.pc_cofins > 0 then             
                                   nsi.pc_cofins             
                                                      else            
                                                        case when isnull(nsi.vl_cofins,0) > 0 then            
                                                          isnull(CONVERT(varchar, convert(numeric(14,2),round(((nsi.vl_cofins * 100)/(nsi.vl_total_item)),6,2)),103),'0.00')               
            
                                                        end             
                                                      end,6,2)),103),'0.00')   as 'pCOFINS',            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsi.vl_cofins > 0 then nsi.vl_cofins             
  else             
   case when isnull(tci.ic_incidencia_tributacao,'N') = 'S' then              
      nsi.vl_total_item * (7.6/100)            
   else            
      0.00            
   end            
  end,6,2)),103),'')                                                                      as 'vCOFINS',               isnull(CONVERT(varchar, convert(numeric(14,4),round(0.00,6,2)),103),'')                 as 'qBCProdCOFINS',            
  '0.00'                                                                                  as 'vAliqProdCOFINS',            
  'IPI'  + isnull(tipi.cd_digito_tributacao_ipi,'00')                                     as 'IPI',            
  rtrim(ltrim(cast(isnull(tipi.cd_digito_tributacao_ipi,'00') as varchar(80))))           as 'CSTIPI',            
            
  case when isnull(nsi.vl_base_ipi_item,0)>0 and isnull(ns.cd_finalidade_nfe,1)= 4 and isnull(snf.ic_simples_empresa,'N') = 'S'             
  then             
    isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsi.vl_base_ipi_item > 0 then null  else nsi.vl_base_ipi_item end,6,2)),103),'0.00')            
  else            
    case when isnull(tipi.cd_digito_tributacao_ipi,'00') = '99' then            
      isnull(CONVERT(varchar, convert(numeric(14,2),0.00),103),'0.00')            
    else            
      isnull(CONVERT(varchar, convert(numeric(14,2),round(            
       case when isnull(nsi.vl_base_ipi_item,0)>0 then isnull(nsi.vl_base_ipi_item,0)            
       else            
        case when nsi.vl_total_item    > 0 then nsi.vl_total_item else null             
        end            
       end,6,2)),103),'0.00')            
    end            
  end                                                            as 'vBCIPI',            
              
  isnull(CONVERT(varchar, convert(numeric(14,4),round(case when isnull(nsi.qt_item_nota_saida,0)      > 0 then nsi.qt_item_nota_saida      else null end,6,2)),103),'0.0000')  as 'qUnid',            
  isnull(CONVERT(varchar, convert(numeric(14,4),round(case when isnull(nsi.vl_unitario_ipi_produto,0) > 0 then nsi.vl_unitario_ipi_produto else null end,6,2)),103),'0.0000')  as 'vUnid',            
            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(nsi.pc_ipi,0)>0 and isnull(ns.cd_finalidade_nfe,0)=4 and isnull(snf.ic_simples_empresa,'N')= 'S'            
  then null            else nsi.pc_ipi end,6,2)),103),'0.00')    as 'pIPI',            
            
  isnull(CONVERT(varchar, convert(numeric(14,2),round(case when isnull(nsi.vl_ipi,0)>0 and isnull(ns.cd_finalidade_nfe,0)=4 and isnull(snf.ic_simples_empresa,'N')= 'S'            
  then null            else nsi.vl_ipi end,6,2)),103),'0.00')    as 'vIPI',            
            
  isnull(nsi.vl_unitario_ipi_produto,0)                          as 'vl_unitario_ipi_produto',            
  'NA'  as 'cIEnq',            
  '00000000000000'  as 'CNPJProd',            
  'N'  as 'cSelo',            
  '0' as 'qSelo',            
  case when isnull(tipi.cd_cenq_ipi,'999')<>'' then            
    cast(tipi.cd_cenq_ipi as varchar(03))                                               
  else            
    cast('999' as varchar(03))                                               
  end            
  as 'cEnq',            
  case when isnull(cfe.ic_icms_pauta_classificacao,'N') = 'S' then            
     '0.00'            
  else            
  case when isnull(cfe.pc_icms_strib_clas_fiscal,0)>0 then            
        dbo.fn_mascara_valor_duas_casas(cfe.pc_icms_strib_clas_fiscal)                       
    else            
        case when isnull(nsi.pc_subs_trib_item,0) > 0 then                       
           dbo.fn_mascara_valor_duas_casas(nsi.pc_subs_trib_item)                           
        else            
           '0.00'            
        end            
    end            
  end                                                                                              as 'pMVAST',            
  case when isnull(nsi.vl_bc_subst_icms_item,0) > 0 then                       
    dbo.fn_mascara_valor_duas_casas(round(nsi.vl_bc_subst_icms_item * (nsi.pc_icms_interna_st/100),2))                       
  else                      
    '0.00'            
  end        as 'pRedBCST',                      
  case when ti.cd_digito_tributacao_icms = '10' then                       
      'ICMS10'                       
  else                      
     cast('ICMS10' as varchar(6))                      
  end                                                                                               as 'ICMS10',                             
  rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))                                                                                              as 'orig10',                                
  case when ti.cd_digito_tributacao_icms = '10' then                       
    rtrim(ltrim(cast(isnull(ti.cd_digito_tributacao_icms,'00') as varchar(2))))                                                        
  else                      
    cast('00' as varchar(2))                      
  end                                                                                                 as 'CST10',                                
  case when ti.cd_digito_tributacao_icms = '10' then                       
    rtrim(ltrim(cast(isnull(mci.cd_digito_modalidade,0)  as varchar(1))))                                                        
  else                      
    cast('0' as varchar(1))                      
  end                                                                                                 as 'modBC10',                        
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.vl_base_icms_item,0))                                    as 'vBC10',                    
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.pc_icms,0))                                              as 'pICMS10',                        
  dbo.fn_mascara_valor_duas_casas(isnull(nsi.vl_icms_item,0))                                         as 'vICMS10',            
  case when ti.cd_digito_tributacao_icms = '10' then                       
     case when isnull(nsi.cd_digito_modalidade_st,'')<>'' then            
         ltrim(rtrim(cast(isnull(nsi.cd_digito_modalidade_st,0) as varchar(10))))                                       
     else            
         ltrim(rtrim(cast(isnull(mct.cd_digito_modalidade_st,0) as varchar(10))))                                                     
     end            
  else                      
     cast('0' as varchar(10))                      
  end                                                                                               as 'modBCST10',                            
  case when ti.cd_digito_tributacao_icms = '10' then                       
    case when isnull(cfe.ic_icms_pauta_classificacao,'N') = 'S' then            
      '0.00'            
    else            
      case when isnull(cfe.pc_icms_strib_clas_fiscal,0)>0 then            
         dbo.fn_mascara_valor_duas_casas(cfe.pc_icms_strib_clas_fiscal)                       
      else            
          case when isnull(nsi.pc_subs_trib_item,0) > 0 then                       
             dbo.fn_mascara_valor_duas_casas(nsi.pc_subs_trib_item)                           
          else            
             '0.00'            
          end            
      end            
    end            
  else                      
    '0.00'            
  end                                                                                               as 'pMVAST10',                              
  case when ti.cd_digito_tributacao_icms = '10' and isnull(cfe.pc_red_icms_clas_fiscal,0) > 0 then                       
    dbo.fn_mascara_valor_duas_casas(cfe.pc_red_icms_clas_fiscal)                       
  else                      
    '0.00'            
  end                                                                                               as 'pRedBCST10',                        
  case when ti.cd_digito_tributacao_icms = '10' then                       
    dbo.fn_mascara_valor_duas_casas(case when isnull(opf.ic_subst_tributaria,'N')='S' and              
                                    nsi.vl_bc_subst_icms_item>0             
                                    then vl_bc_subst_icms_item            
                                    else 0.00 end)            
  else                      
    '0.00'                       
  end                                                                                               as 'vBCST10',                                
  case when isnull(cfe.pc_interna_icms_clas_fis,0)<>0 then            
     dbo.fn_mascara_valor_duas_casas(isnull(cfe.pc_interna_icms_clas_fis,0))                          
  else                    
     dbo.fn_mascara_valor_duas_casas(isnull(nsi.pc_icms,0))                                                         
  end                                                                                              as 'pICMSST10',            
  case when ti.cd_digito_tributacao_icms = '10' then                       
  dbo.fn_mascara_valor_duas_casas(case when isnull(opf.ic_subst_tributaria,'N')='S' and              
                                    nsi.vl_bc_subst_icms_item>0             
                                    then nsi.vl_icms_subst_icms_item            
                                    else 0.00 end)            
  else                      
    dbo.fn_mascara_valor_duas_casas(0.00)                       
  end                                                                                               as 'vICMSST10',                      
  '0.00'                                                                                            as 'ModVCST10',                                 
  case when ti.cd_digito_tributacao_icms = '20' then                       
      'ICMS20'                       
  else                      
      cast('ICMS20' as varchar(6))                      
  end                                                                                               as 'ICMS20',                                       
  
  rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))                      as 'orig20',                                
  case when ti.cd_digito_tributacao_icms = '20' then                       
 rtrim(ltrim(cast(ti.cd_digito_tributacao_icms as varchar(2))))                                                        
  else                      
    cast('20' as varchar(2))                      
  end                                                                                               as 'CST20',                                
  case when ti.cd_digito_tributacao_icms = '20' then                       
    rtrim(ltrim(cast(isnull(mci.cd_digito_modalidade,0)  as varchar(1))))                                                        
  else                      
    cast('0' as varchar(1))                      
  end                                                                                               as 'modBC20',                                        
  case when ti.cd_digito_tributacao_icms = '20' and isnull(nsi.vl_base_icms_item,0)>0 then                       
    dbo.fn_mascara_valor_duas_casas(case when isnull(nsi.pc_reducao_icms,0) > 0 then (isnull(nsi.pc_reducao_icms,0)) else (isnull(cfe.pc_redu_icms_class_fiscal,0)) end)                              
  else                      
    '0.00'            
  end                                                                                               as 'pREDBC20',                                
  case when ti.cd_digito_tributacao_icms = '20' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_base_icms_item)   
  else                      
    dbo.fn_mascara_valor_duas_casas(0.00)                              
  end                                                                                               as 'vBC20',                                
  case when ti.cd_digito_tributacao_icms = '20' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.pc_icms)                                    
  else                      
    '0.00'                                    
  end                                                                                               as 'pICMS20',                                  
  case when ti.cd_digito_tributacao_icms = '20' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_icms_item)                      
  else                      
    '0.00'                      
  end                                                                                               as 'vICMS20',                                        
  case when ti.cd_digito_tributacao_icms = '30' then                       
      'ICMS30'                       
  else                      
      cast('ICMS30' as varchar(6))                      
  end                                                                           as 'ICMS30',                                
  --case when ti.cd_digito_tributacao_icms = '30' then                       
  --  rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))                      
  --else                      
  --  cast('0' as varchar(1))                      
  --end                                                                                               
    rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))                      as 'orig30',                                
  case when ti.cd_digito_tributacao_icms = '30' then                       
    rtrim(ltrim(cast(isnull(ti.cd_digito_tributacao_icms,'30') as varchar(2))))                                                        
  else                      
    cast('30' as varchar(2))                      
  end                                                                                               as 'CST30',                                
  case when ti.cd_digito_tributacao_icms = '30' then            
     case when isnull(nsi.cd_digito_modalidade_st,'')<>'' then            
         ltrim(rtrim(cast(isnull(nsi.cd_digito_modalidade_st,0) as varchar(10))))                                                     
     else            
         ltrim(rtrim(cast(isnull(mct.cd_digito_modalidade_st,0) as varchar(10))))                                                     
     end            
  else            
     '0'            
  end                                                                                                as 'modBCST30',                   
  case when ti.cd_digito_tributacao_icms = '30' then                     
    case when isnull(cfe.ic_icms_pauta_classificacao,'N') = 'S' then            
      '0.00'            
  else            
      dbo.fn_mascara_valor_duas_casas(cfe.pc_icms_strib_clas_fiscal)                       
    end            
  else                      
    '0.00'            
  end                                                                                                as 'pMVAST30',                               
  case when ti.cd_digito_tributacao_icms = '30' then                       
    dbo.fn_mascara_valor_duas_casas(cfe.pc_red_icms_clas_fiscal)                       
 else                      
    '0.00'            
  end                                                                                                as 'pRedBCST30',                                
  case when ti.cd_digito_tributacao_icms = '30' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_bc_subst_icms_item)                           
  else                      
    '0.00'            
  end                                                                                               as 'vBCST30',                                

  case when isnull(cfe.pc_interna_icms_clas_fis,0)<>0 then            
     dbo.fn_mascara_valor_duas_casas(isnull(cfe.pc_interna_icms_clas_fis,0))                          
  else                    
     dbo.fn_mascara_valor_duas_casas(isnull(nsi.pc_icms,0))                                                         
  end                                                                                              as 'pICMSST30',                                

  case when ti.cd_digito_tributacao_icms = '30' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_icms_subst_icms_item)                      
  else                      
    '0.00'            
  end                                                                                               as 'vLCMSST30',                         
  case when ti.cd_digito_tributacao_icms = '40' then                       
      'ICMS40'                       
  else                      
      cast('ICMS40' as varchar(6))            
  end                                 as 'ICMS40',                               
  rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))                                                                                              as 'orig40',                               
  case when ti.cd_digito_tributacao_icms = '40' then                       
    case when   isnull(opf.ic_exportacao_op_fiscal,'N')='S' then            
      '41'            
    else            
      rtrim(ltrim(cast(isnull(ti.cd_digito_tributacao_icms,'40') as varchar(2))))                                                        
    end            
  else             
    case when   isnull(opf.ic_exportacao_op_fiscal,'N')='S' then             
      '41'            
    else            
--      cast('40' as varchar(2))                      
       rtrim(ltrim(cast(isnull(ti.cd_digito_tributacao_icms,'40') as varchar(2))))              
    end            
  end                                                                                               as 'CST40',                               
            
  case when ti.cd_digito_tributacao_icms = '50' then                       
      'ICMS50'                       
  else                      
      cast('ICMS50' as varchar(6))                      
  end                                                                                               as 'ICMS50',                      
                               
  rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1)))) as 'orig50',                      
  case when ti.cd_digito_tributacao_icms = '50' then                       
    rtrim(ltrim(cast(ti.cd_digito_tributacao_icms as varchar(2))))                                                        
  else                      
    cast('50' as varchar(2))                      
  end                                                                                               as 'CST50',                    
  case when ti.cd_digito_tributacao_icms = '51' then                       
      'ICMS51'                       
  else                      
      cast('ICMS51' as varchar(6))                      
  end                                                                                               as 'ICMS51',                                
  --case when ti.cd_digito_tributacao_icms = '51' then                       
  --  rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))                      
  --else                      
  --  cast('0' as varchar(1))                       
  --end
  rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))                              as 'orig51',                                
  case when ti.cd_digito_tributacao_icms = '51' then                       
    rtrim(ltrim(cast(isnull(ti.cd_digito_tributacao_icms,'51') as varchar(2))))                                                        
  else                      
    cast('51' as varchar(2))                      
  end                                                                                               as 'CST51',                                
  case when ti.cd_digito_tributacao_icms = '51' then                       
    rtrim(ltrim(cast(isnull(mci.cd_digito_modalidade,0)  as varchar(1))))                                                        
  else                      
    cast('0' as varchar(1))                      
  end                                                                                               as 'modBC51',                                       
  case when ti.cd_digito_tributacao_icms = '51' and isnull(nsi.vl_base_icms_item,0)>0 then                       
    dbo.fn_mascara_valor_duas_casas(isnull(nsi.pc_reducao_icms,0) )                              
  else                      
    '0.00'                              
  end                                                                                               as 'pREDBC51',               
  case when ti.cd_digito_tributacao_icms = '51' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_base_icms_item)                             
  else                      
    '0.00'                              
  end                                                                                               as 'vBC51',                                
  case when ti.cd_digito_tributacao_icms = '51' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.pc_icms)                                    
  else                      
    '0.00'            
  end                                                                                               as 'pICMS51',                                  
  case when ti.cd_digito_tributacao_icms = '51' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_icms_item)                     
  else                      
    '0.00'                       
  end                                                                                               as 'vICMS51',                                              
  case when ti.cd_digito_tributacao_icms = '60' then                       
      'ICMS60'                       
  else                      
      cast('ICMS60' as varchar(6))                      
  end                                                                                               as 'ICMS60',                                
  
  rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))                             as 'orig60',                                
  case when ti.cd_digito_tributacao_icms = '60' then                       
    rtrim(ltrim(cast(isnull(ti.cd_digito_tributacao_icms,'60') as varchar(2))))                                                        
  else                      
    cast('60' as varchar(2))                      
  end                                                                                               as 'CST60',                                
  case when ti.cd_digito_tributacao_icms = '60' then                      
    dbo.fn_mascara_valor_duas_casas(nsi.vl_bc_subst_icms_item)                           
  else                      
    '0.00'                       
  end                                                                                               as 'vBCST60',                                
  case when ti.cd_digito_tributacao_icms = '60' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_icms_subst_icms_item)                      
  else                      
    '0.00'                       
  end                                                                                               as 'vICMSST60',                      
  case when ti.cd_digito_tributacao_icms = '70' then                       
      'ICMS70'                       
  else                      
      cast('ICMS70' as varchar(5))                      
  end                                                                                               as 'ICMS70',                                
  
    rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))      as 'orig70',                                
  case when ti.cd_digito_tributacao_icms = '70' then                       
    rtrim(ltrim(cast(isnull(ti.cd_digito_tributacao_icms,'70') as varchar(2))))                                                        
  else                      
    cast('70' as varchar(2))                      
  end                                                                                               as 'CST70',                                
  case when ti.cd_digito_tributacao_icms = '70' then                       
    rtrim(ltrim(cast(isnull(mci.cd_digito_modalidade,0)  as varchar(1))))                                                        
  else                      
    cast('0' as varchar(1))                      
  end                                                                    as 'modBC70',                                
  case when ti.cd_digito_tributacao_icms = '70' and isnull(nsi.vl_base_icms_item,0)>0  then                       
    dbo.fn_mascara_valor_duas_casas(case when isnull(nsi.pc_reducao_icms,0) > 0 then (isnull(nsi.pc_reducao_icms,0)) else (isnull(cfe.pc_redu_icms_class_fiscal,0)) end)
  else                      
    '0.00'                              
  end                                                                                               as 'pREDBC70',                                
  case when ti.cd_digito_tributacao_icms = '70' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_base_icms_item)                             
  else                      
    '0.00'                              
  end                                                                                               as 'vBC70',                                
  case when ti.cd_digito_tributacao_icms = '70' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.pc_icms)                                    
  else                      
    '0.00'                                    
  end     as 'pICMS70',                                  
  case when ti.cd_digito_tributacao_icms = '70' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_icms_item)                      
  else                      
    '0.00'                      
  end                                                                                               as 'vICMS70',                               
  case when ti.cd_digito_tributacao_icms = '70' then                       
     case when isnull(nsi.cd_digito_modalidade_st,'')<>'' then            
         ltrim(rtrim(cast(isnull(nsi.cd_digito_modalidade_st,0) as varchar(10))))                                                     
     else            
         ltrim(rtrim(cast(isnull(mct.cd_digito_modalidade_st,0) as varchar(10))))                                                     
     end            
  else                      
     cast('' as varchar(10))                      
  end                                                                                               as 'modBCST70',            
  case when ti.cd_digito_tributacao_icms = '70' then            
    case when isnull(cfe.ic_icms_pauta_classificacao,'N') = 'S' then            
      '0.00'            
    else            
      case  when isnull(cfe.pc_icms_strib_clas_fiscal,0)>0 then                       
        dbo.fn_mascara_valor_duas_casas(cfe.pc_icms_strib_clas_fiscal)                       
      else                      
      '0.00'                       
     end            
    end            
  else                      
    '0.00'                       
  end                                                                                                as 'pMVAST70',                                
  case when ti.cd_digito_tributacao_icms = '70' and isnull(cfe.pc_red_icms_clas_fiscal,0)>0 then                       
    dbo.fn_mascara_valor_duas_casas(cfe.pc_red_icms_clas_fiscal)                       
  else                      
    '0.00'                       
  end                                                                                               as 'pRedBCST70',                                
  case when ti.cd_digito_tributacao_icms = '70' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_bc_subst_icms_item)                           
  else                      
    '0.00'                       
  end                                                                                               as 'vBCST70',                                
  case when ti.cd_digito_tributacao_icms = '70' and isnull(nsi.pc_subs_trib_item,0)>0 then                       
      case when isnull(cfe.ic_icms_pauta_classificacao,'N') = 'S' then              
        dbo.fn_mascara_valor_duas_casas(nsi.pc_icms)                           
      else            
        dbo.fn_mascara_valor_duas_casas(nsi.pc_subs_trib_item)                           
      end            
  else                      
    '0.00'                       
  end                                                                                               as 'pICMSST70',                               
  case when ti.cd_digito_tributacao_icms = '70' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_icms_subst_icms_item)                      
  else                      
    '0.00'                   
  end                                                                                               as 'vICMSST70',                            
  case when ti.cd_digito_tributacao_icms = '90' then                       
      'ICMS90'                       
  else                      
      cast('ICMS90' as varchar(6))                      
  end                                                          as 'ICMS90',                                
  
    rtrim(ltrim(cast(isnull(pp.cd_digito_procedencia,0) as varchar(1))))   as 'orig90',                                
  case when ti.cd_digito_tributacao_icms = '90' then                       
    rtrim(ltrim(cast(isnull(ti.cd_digito_tributacao_icms,'90') as varchar(2))))                                                        
  else                      
    cast('90' as varchar(2))                          
  end                                                                                               as 'CST90',                                
  case when ti.cd_digito_tributacao_icms = '90' then                       
    rtrim(ltrim(cast(isnull(mci.cd_digito_modalidade,0)  as varchar(1))))                                                        
  else                      
    cast('0' as varchar(1))                      
  end                                                                                               as 'modBC90',                                
  case when ti.cd_digito_tributacao_icms = '90' and isnull(nsi.vl_base_icms_item,0)>0 then                       
    dbo.fn_mascara_valor_duas_casas( isnull(nsi.pc_reducao_icms,0) )                              
  else                      
    '0.00'                              
  end                                                     as 'pREDBC90',                                
  case when ti.cd_digito_tributacao_icms = '90' then                       
    dbo.fn_mascara_valor_duas_casas(isnull(nsi.vl_base_icms_item,0.00) )                             
  else                      
    '0.00'                              
  end                                                                                               as 'vBC90',                                
  case when ti.cd_digito_tributacao_icms = '90' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.pc_icms)                                    
  else                      
    '0.00'                                    
  end                                                                                               as 'pICMS90',                                  
  case when ti.cd_digito_tributacao_icms = '90' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_icms_item)                      
  else                      
    '0.00'                      
  end                                                     as 'vICMS90',                                
  case when ti.cd_digito_tributacao_icms = '90' then                       
     case when isnull(nsi.cd_digito_modalidade_st,'')<>'' then            
         ltrim(rtrim(cast(isnull(nsi.cd_digito_modalidade_st,0) as varchar(10))))                                                     
     else            
         ltrim(rtrim(cast(isnull(mct.cd_digito_modalidade_st,0) as varchar(10))))                                                     
     end            
            
  else                      
     cast('0' as varchar(10))                      
  end                                                                                               as 'modBCST90',                        
  case when ti.cd_digito_tributacao_icms = '90' then                       
    case when isnull(cfe.ic_icms_pauta_classificacao,'N') = 'S' then            
      '0.00'            
    else            
      dbo.fn_mascara_valor_duas_casas(cfe.pc_icms_strib_clas_fiscal)                       
    end            
  else                      
    '0.00'                       
  end                                                                                               as 'pMVAST90',                      
  case when ti.cd_digito_tributacao_icms = '90' and isnull(cfe.pc_red_icms_clas_fiscal,0)>0 then                       
    dbo.fn_mascara_valor_duas_casas(cfe.pc_red_icms_clas_fiscal)                       
  else                      
    '0.00'                       
  end                                                                                               as 'pRedBCST90',                                
  case when ti.cd_digito_tributacao_icms = '90' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_bc_subst_icms_item)                           
  else                      
    '0.00'                       
  end                                                                                               as 'vBCST90',                               
  case when ti.cd_digito_tributacao_icms = '90' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.pc_subs_trib_item)                           
  else                      
    '0.00'                            
  end                                                                                               as 'pICMSST90',                            
  case when ti.cd_digito_tributacao_icms = '90' then                       
    dbo.fn_mascara_valor_duas_casas(nsi.vl_icms_subst_icms_item)                      
  else                      
    '0.00'                       
  end                                                  as 'vICMSST90',            
  isnull(p.ic_descritivo_nf_produto,'N')                                                             as 'ic_descritivo_nf_produto',   
         
  case when isnull(nsi.cd_lote_item_nota_saida,'')<>'' then            
    ltrim(rtrim(nsi.cd_lote_item_nota_saida))            
  else            
    case when isnull((select top 1 nsil.nm_lote from nota_saida_item_lote nsil with(nolock) where nsil.cd_nota_saida = nsi.cd_nota_saida and nsil.cd_item_nota_saida = nsi.cd_item_nota_saida),'') <> '' 
      then isnull((select top 1 nsil.nm_lote from nota_saida_item_lote nsil with(nolock) where nsil.cd_nota_saida = nsi.cd_nota_saida and nsil.cd_item_nota_saida = nsi.cd_item_nota_saida),'')
      else '' 
    end
  end                                                                                                as 'Lote',
              
  case when dbo.fn_empresa() = 21 and cli.cd_cliente = 63
    then
    case when isnull(nsi.cd_os_item_nota_saida,'') <> ''               
       then right(replicate('0',6) + left(cast(nsi.cd_os_item_nota_saida as varchar(15)),6),6)                  
       else right(replicate('0',6) + left(cast(nsi.cd_pd_compra_item_nota as varchar(15)),6),6) end
    else
    case when isnull(nsi.cd_os_item_nota_saida,'') <> ''               
       then cast(nsi.cd_os_item_nota_saida as varchar(15))                
       else cast(nsi.cd_pd_compra_item_nota as varchar(15)) end
    end                                                                                                as 'xPed',                  

  --case when isnull(nsi.cd_os_item_nota_saida,'') <> ''             
  --     then cast(nsi.cd_os_item_nota_saida as varchar(15))                
  --     else cast(nsi.cd_pd_compra_item_nota as varchar(15)) end                                      as 'xPed',                
    
  --cast(isnull(dbo.fn_strzero(nsi.cd_it_ped_compra_cliente,5),0) as varchar (15)) as 'nItemPed',    
  right(replicate('0',4) + left(cast(nsi.cd_it_ped_compra_cliente as varchar (15)),4),4) as 'nItemPed',      
  --cast(nsi.cd_it_ped_compra_cliente as varchar (15)) as 'nItemPed',    
--   case when isnull(cp.qt_zero_ped_item_nfe,0) = 0 then    
--     cast(isnull(nsi.cd_it_ped_compra_cliente,0) as varchar(15))    
--   else    
--     cast(isnull(dbo.fn_strzero(nsi.cd_it_ped_compra_cliente, cp.qt_zero_ped_item_nfe),0) as varchar(15)) as 'nItemPed',    
                
  cast(nsi.cd_pd_compra_item_nota as varchar(15))                                                        as 'xPedCompra',           
            
  dbo.fn_mascara_valor_duas_casas(cast(isnull(nsi.vl_desp_acess_item,0) + isnull(nsi.vl_desp_aduaneira_item,0) as decimal(25,2))) as 'vOutro',            
  case when isnull(nsi.cd_servico,0)<>0 then            
    isnull(CONVERT(varchar, convert(numeric(14,2),round(case when nsi.vl_total_item > 0             
    then nsi.vl_total_item else null end,6,2)),103),'0.00')                                                            
  else            
    '0.00'              
  end                                                                                               as 'vBC_U02',            
  '0.00'                                as 'vAliq_U03',            
  '0.00'                                as 'vISSQN_U04',              
  ''                                    as 'cMunFG_U05',            
  ''                                    as 'cListServ_U06',            
  'N'                                   as 'cSitTrib_U07',            
  '0.00'                                as 'vICMS_N17',            
  cast('' as varchar(1))                                                                          as 'motDesICMS_N28',                                               
  cast('1' as char(1))                                                                            as 'indTot',            
  isnull(nsi.cd_nota_entrada,0)                                                                   as cd_nota_entrada,            
  isnull(nsi.cd_item_nota_entrada,0)                                                              as cd_item_nota_entrada,            
  nsi.cd_operacao_Fiscal            
            
from            
  nota_saida ns                                     with (nolock)             
  inner join nota_saida_item nsi                    with (nolock) on nsi.cd_nota_saida             = ns.cd_nota_saida            
  left outer join vw_destinatario vw                with (nolock) on vw.cd_destinatario            = ns.cd_cliente and vw.cd_tipo_destinatario = ns.cd_tipo_destinatario            
  left outer join Nota_Saida_Importacao      nimp   with (nolock) on nimp.cd_nota_saida            = ns.cd_identificacao_nota_saida            
  left outer join classificacao_fiscal cf           with (nolock) on cf.cd_classificacao_fiscal    = nsi.cd_classificacao_fiscal            
  left outer join unidade_medida cfu                with (nolock) on cfu.cd_unidade_medida         = cf.cd_unidade_medida            
  left outer join operacao_fiscal opf               with (nolock) on opf.cd_operacao_fiscal        = nsi.cd_operacao_fiscal            
  left outer join tipo_movimento_estoque tme        with (nolock) on tme.cd_tipo_movimento_estoque = opf.cd_tipo_movimento_estoque            
  left outer join unidade_medida um                 with (nolock) on um.cd_unidade_medida          = nsi.cd_unidade_medida            
  left outer join di                                with (nolock) on di.cd_di                      = nsi.cd_di            
  left outer join tipo_importacao timp              with (nolock) on timp.cd_tipo_importacao       = case when isnull(di.cd_tipo_importacao,0)<>0 then            
                                                                                                       di.cd_tipo_importacao            
                                                                                                     else            
                                                                   nimp.cd_tipo_importacao            
                                                                                                     end            
  left outer join forma_importacao fi               with (nolock) on fi.cd_forma_importacao        = case when isnull(di.cd_forma_importacao,0)<>0 then            
                                                                                                        di.cd_forma_importacao            
                                                                                                     else            
                                                                                                        nimp.cd_forma_importacao            
                                                                                                     end            
  left outer join porto pd                          with (nolock) on pd.cd_porto                   = di.cd_porto_destino            
  left outer join estado ed                         with (nolock) on ed.cd_estado                  = pd.cd_estado            
  left outer join produto_fiscal pf                 with (nolock) on pf.cd_produto                 = nsi.cd_produto            
  left outer join procedencia_produto pp            with (nolock) on pp.cd_procedencia_produto     = nsi.cd_procedencia_produto            
  left outer join tributacao t                      with (nolock) on t.cd_tributacao               = nsi.cd_tributacao            
  left outer join tributacao_icms ti                with (nolock) on ti.cd_tributacao_icms         = t.cd_tributacao_icms            
  left outer join modalidade_calculo_icms mci       with (nolock) on mci.cd_modalidade_icms        = t.cd_modalidade_icms            
  left outer join modalidade_calculo_icms_sTrib mct with (nolock) on mct.cd_modalidade_icms_st     = t.cd_modalidade_icms_st            
  left outer join classificacao_fiscal_estado cfe   with (nolock) on cfe.cd_classificacao_fiscal   = nsi.cd_classificacao_fiscal and cfe.cd_estado = vw.cd_estado            
  left outer join tributacao_pis tpis               with (nolock) on tpis.cd_tributacao_pis        = t.cd_tributacao_pis            
  left outer join tributacao_cofins tci             with (nolock) on tci.cd_tributacao_cofins      = t.cd_tributacao_cofins             
  left outer join tributacao_ipi tipi               with (nolock) on tipi.cd_tributacao_ipi        = t.cd_tributacao_ipi             
  left outer join produto                       p   with (nolock) on p.cd_produto                  = nsi.cd_produto        
  left outer join familia_produto fam               with (nolock) on fam.cd_familia_produto        = p.cd_familia_produto        
  left outer join produto_cliente               pc  with (nolock) on pc.cd_produto                 = nsi.cd_produto 
                                                                 and pc.cd_cliente = ns.cd_cliente            
  left outer join Serie_Nota_Fiscal snf             with (nolock) on snf.cd_serie_nota_fiscal      = ns.cd_serie_nota            
  left outer join Cliente cli                       with (nolock) on cli.cd_cliente                = ns.cd_cliente  
  left outer join Cliente_Grupo cg                  with (nolock) on cg.cd_cliente_grupo           = cli.cd_cliente_grupo          
  left outer join pedido_venda pv                   with (nolock) on pv.cd_pedido_venda            = nsi.cd_pedido_venda            
  left outer join tipo_pedido tp                    with (nolock) on tp.cd_tipo_pedido             = pv.cd_tipo_pedido            
  left outer join Pedido_Venda_Item_Medida pvim     with (nolock) on pvim.cd_pedido_venda          = nsi.cd_pedido_venda and        
                                                                     pvim.cd_item_pedido_venda     = nsi.cd_item_pedido_venda 
  left outer join Cliente_Parametro cp              with (nolock) on cp.cd_cliente                 = cli.cd_cliente
  left outer join Empresa_Faturamento efat          with (nolock) on efat.cd_empresa               = snf.cd_empresa_selecao
  left outer join Versao_Nfe vf                     with (nolock) on vf.cd_empresa                 = dbo.fn_empresa()          

GO

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--select orig40, * from vw_nfe_produto_servico_nota_fiscal where cd_identificacao_nota_saida = 843
--select * from vw_nfe_produto_servico_nota_fiscal where cd_nota_saida = 9501477
--select xprod, utrib, qtrib, vuntrib, * from vw_nfe_produto_servico_nota_fiscal where cd_identificacao_nota_saida = 45385
--select max(cd_nota_saida) as cd_nota_saida from nota_saida
------------------------------------------------------------------------------------------------------------------------------------------------------------------------