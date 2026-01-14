IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'vw_nfe_medicamento_nota_fiscal' 
	   AND 	  type = 'V')
    DROP VIEW vw_nfe_medicamento_nota_fiscal
GO

CREATE VIEW vw_nfe_medicamento_nota_fiscal
------------------------------------------------------------------------------------
--sp_helptext vw_nfe_medicamento_nota_fiscal
------------------------------------------------------------------------------------
--GBS - Global Business Solution	                                       2004
------------------------------------------------------------------------------------
--Stored Procedure	: Microsoft SQL Server 2000
--Autor(es)             : Carlos Cardoso Fernandes
--Banco de Dados	: EGISSQL 
--
--Objetivo	        : Identificação do Local da Retirada da Nota Fiscal 
--                        para o sistema de emissão da Nota Fiscal Eletrônica
--
--Data                  : 05.11.2008
--Atualização           : 27.09.2010 - Ajuste para novo lay-out v2.00 - Carlos Fernandes
--------------------------------------------------------------------------------------------
as


select
  'K'                                                            as 'med',
  
  ns.dt_nota_saida,
  nsi.cd_nota_saida,
  nsi.cd_item_nota_saida,

  case when isnull(nsil.qt_item_lote,0) <> 0
    then isnull(CONVERT(varchar, convert(numeric(11,3),round(nsil.qt_item_lote,6,3)),103),'0.000')
    else isnull(CONVERT(varchar, convert(numeric(11,3),round(nsi.qt_item_nota_saida,6,3)),103),'0.000')
  end                                                                         as qt_item_nota_saida,

  --nsi.qt_item_nota_saida,
  nsi.cd_lote_item_nota_saida,

  case when isnull(nsil.nm_lote,'') <> ''
    then ltrim(rtrim(nsil.nm_lote))
    else case when isnull(dil.cd_lote_di_item,'')<>'' and isnull(nsi.cd_di,0)<>0 then
            dil.cd_lote_di_item
         else
           case when isnull(nsi.cd_lote_item_nota_saida,'')<>'' then
             ltrim(rtrim(nsi.cd_lote_item_nota_saida))
           else
            ''
           end
         end 
  end                                                                        as 'Lote',

  lp.dt_entrada_lote_produto,
  lp.dt_inicial_lote_produto,
  lp.dt_final_lote_produto,

  case when isnull(ltrim(rtrim(replace(convert(char,nsil.dt_fabricacao_lote,102),'.','-'))),'') <> ''
    then ltrim(rtrim(replace(convert(char,nsil.dt_fabricacao_lote,102),'.','-'))) 
    else case when isnull(dil.cd_lote_di_item,'')<>'' and isnull(nsi.cd_di,0)<>0 then
           --dil.dt_fab_lote_di_item
           ltrim(rtrim(replace(convert(char,dil.dt_fab_lote_di_item,102),'.','-'))) 
         else
           ltrim(rtrim(replace(convert(char,lp.dt_entrada_lote_produto,102),'.','-'))) 
         end
  end                                                                           as Fabricacao,


  case when isnull(ltrim(rtrim(replace(convert(char,nsil.dt_validade_lote,102),'.','-'))),'') <> ''
    then ltrim(rtrim(replace(convert(char,nsil.dt_validade_lote,102),'.','-'))) 
    else case when isnull(dil.cd_lote_di_item,'')<>'' and isnull(nsi.cd_di,0)<>0 then
           --dil.dt_val_lote_di_item
           ltrim(rtrim(replace(convert(char, dil.dt_val_lote_di_item,102),'.','-'))) 
         else
           ltrim(rtrim(replace(convert(char,lp.dt_final_lote_produto,102),'.','-'))) 
         end
  end                                                                           as Validade,

  ltrim(rtrim(nsil.nm_codigo_agregacao))                                        as Cod_Agregacao, 

  --0.00                                                                        as preco_maximo
  isnull(CONVERT(varchar, convert(numeric(14,2),round(0.00,6,2)),103),'0.00')   as preco_maximo
  

from
  nota_saida ns                                     with (nolock) 

  inner join nota_saida_item nsi                    with (nolock) on nsi.cd_nota_saida             = ns.cd_nota_saida

  left outer join nota_saida_item_lote nsil         with (nolock) on nsil.cd_nota_saida            = nsi.cd_nota_saida
                                                                 and nsil.cd_item_nota_saida       = nsi.cd_item_nota_saida

  left outer join lote_produto lp                   with (nolock) on lp.nm_ref_lote_produto        = nsi.cd_lote_item_nota_saida

  left outer join di_item_lote dil                  with (nolock) on dil.cd_di                     = nsi.cd_di      and
                                                                     dil.cd_di_item                = nsi.cd_di_item


--select * from lote_produto
--select cd_lote_produto,cd_lote_item_nota_saida,* from nota_saida_item

go

------------------------------------------------------------------------------------
-- Testando a View
------------------------------------------------------------------------------------
--select top 1000 * from vw_nfe_medicamento_nota_fiscal where cd_nota_saida = 127903
------------------------------------------------------------------------------------

go