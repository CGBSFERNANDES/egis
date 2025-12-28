
IF EXISTS (SELECT name FROM sysobjects WHERE name = N'NE' AND type = 'U') DROP TABLE NE

select 
  identity(int,1,1) as cd_controle,
  n.cd_nota_entrada,
  n.cd_fornecedor,
  n.cd_tipo_destinatario,
  n.cd_operacao_fiscal,
  n.cd_serie_nota_fiscal, 
  isnull(nr.cd_rem,0) as cd_rem,
  td.nm_tipo_destinatario,
  n.nm_fantasia_destinatario,
  o.cd_mascara_operacao, o.nm_operacao_fiscal, 
  n.nm_especie_nota_entrada,  s.sg_serie_nota_fiscal,
  n.dt_receb_nota_entrada,
  n.dt_nota_entrada,
  n.vl_total_nota_entrada,
  n.vl_bicms_nota_entrada,
  n.vl_icms_nota_entrada,
  n.vl_ipi_nota_entrada,
  n.vl_bsticm_nota_entrada,
  n.vl_sticm_nota_entrada,
  n.vl_biss_nota_entrada,
  n.vl_iss_nota_entrada,
  n.pc_iss_nota_entrada,
  n.vl_irrf_nota_entrada,
  n.pc_irrf_nota_entrada,
  n.pc_pis_nota_entrada,
  n.vl_pis_retido_nota_entrada,
  n.pc_cofins_nota_entrada,
  n.vl_cofins_retido_nota_entrada,
  n.pc_csll_nota_entrada,
  n.vl_frete_nota_entrada,
  n.vl_seguro_nota_entrada,
  n.vl_despac_nota_entrada,
  n.vl_prod_nota_entrada,
  n.vl_servico_nota_entrada,
  n.vl_pis_nota_entrada,
  n.vl_cofins_nota_entrada,
  n.vl_csll_nota_entrada,
  n.vl_bcinss_nota_entrada,
  n.vl_inss_nota_entrada,
  n.vl_total_icms_desoneracao,
  ic_carta_cor_nota_entrada,
  ic_conf_nota_entrada,
  ic_sco,
  ic_slf,
  ic_sce,
  ic_scu,
  ic_scp,
  ic_pcp,
  ic_sep,
  ic_simp,
  ic_sct,
  ic_scp_retencao,
  ic_diverg_nota_entrega,
  u.nm_fantasia_usuario, n.cd_plano_financeiro, dep.nm_departamento,
  ef.nm_fantasia_empresa,
  isnull(n.ic_nfe_nota_entrada,'N') as ic_nfe_nota_entrada,
  nec.cd_chave_acesso,
  isnull(cc.nm_centro_custo,'') as nm_centro_custo,
  isnull(pf.nm_conta_plano_financeiro,'') as nm_plano_financeiro,
  ( select count(nei.cd_item_nota_entrada) from nota_entrada_item nei
    where
      nei.cd_fornecedor        = n.cd_fornecedor       and
     nei.cd_nota_entrada      = n.cd_nota_entrada     and
     nei.cd_operacao_fiscal   = n.cd_operacao_fiscal  and
     nei.cd_serie_nota_fiscal = n.cd_serie_nota_fiscal   ) as qtd_itens,
     vw.nm_razao_social,
     case when vw.cd_tipo_pessoa = 1 then
      dbo.fn_formata_cnpj(vw.cd_cnpj)
     else
      dbo.fn_formata_cpf(vw.cd_cnpj)
     end                                                   as 'CNPJ',

 vw.cd_inscestadual,
 vw.cd_conta,
 pc.cd_conta_reduzido, n.dt_usuario, ua.nm_fantasia_usuario as usuario_alteracao,
 cctb.nm_conta_contabil,
 isnull((select top 1 'S' from Laudo l
  where
    l.cd_nota_entrada         = n.cd_nota_entrada and 
    l.cd_serie_nota_fiscal    = n.cd_serie_nota_fiscal and
    isnull(l.cd_fornecedor,l.cd_cliente) = n.cd_fornecedor),'N') as ic_laudo,

  isnull(nee.ic_manifesto,'N') as ic_manifesto,
  nee.nm_situacao,
  nee.dt_manifesto,
  isnull(f.ic_exclusivo_financeiro,'N') as ic_exclusivo_financeiro,
  day(dt_receb_nota_entrada) as dia_receb_nota,
  month(dt_receb_nota_entrada) as mes_receb_nota,
  year(dt_receb_nota_entrada) as ano_receb_nota,
  cop.cd_identificacao_contrato,
  isnull((select top 1 fdc.cd_controle from Fechamento_Diario_Composicao fdc
  where fdc.cd_nota_entrada         = n.cd_nota_entrada and 
    fdc.cd_serie_nota_fiscal    = n.cd_serie_nota_fiscal and
    fdc.cd_destinatario         = n.cd_fornecedor),0) as cd_controle_fechamento,
(select sum(isnull(i.qt_pesbru_nota_entrada,0)) from nota_entrada_item i 
			where i.cd_fornecedor = n.cd_fornecedor              and 
				i.cd_nota_entrada = n.cd_nota_entrada          and 
				i.cd_operacao_fiscal   = n.cd_operacao_fiscal  and
                i.cd_serie_nota_fiscal = n.cd_serie_nota_fiscal) as 'Peso',
  isnull(o.ic_comercial_operacao,'S')                            as ic_comercial_operacao
into NE   
from 
  Nota_Entrada n with (nolock)
  left outer join Nota_Entrada_Registro nr on n.cd_nota_entrada    = nr.cd_nota_entrada    and
                                              n.cd_fornecedor      = nr.cd_fornecedor      and
                                              n.cd_operacao_fiscal = nr.cd_operacao_fiscal and
                                              n.cd_serie_nota_fiscal = nr.cd_serie_nota_fiscal
  left outer join Nota_Entrada_Empresa  ne on n.cd_nota_entrada    = ne.cd_nota_entrada    and
                                              n.cd_fornecedor      = ne.cd_fornecedor      and
                                              n.cd_operacao_fiscal = ne.cd_operacao_fiscal and
                                              n.cd_serie_nota_fiscal = ne.cd_serie_nota_fiscal
  left outer join Empresa_Faturamento ef   on ef.cd_empresa          = ne.cd_empresa
  left outer join Operacao_Fiscal o        on n.cd_operacao_fiscal   = o.cd_operacao_fiscal
  left outer join Serie_Nota_Fiscal s      on n.cd_serie_nota_fiscal = s.cd_serie_nota_fiscal
  left outer join Tipo_Destinatario td     on n.cd_tipo_destinatario = td.cd_tipo_destinatario
  left outer join EGISADMIN.dbo.Usuario u  on u.cd_usuario = isnull(n.cd_usuario_inclusao,n.cd_usuario)
  left outer join Departamento dep on dep.cd_departamento = u.cd_departamento
  left outer join Nota_entrada_complemento nec on n.cd_nota_entrada    = nec.cd_nota_entrada    and
                                              n.cd_fornecedor        = nec.cd_fornecedor      and
                                              n.cd_operacao_fiscal   = nec.cd_operacao_fiscal and
                                              n.cd_serie_nota_fiscal = nec.cd_serie_nota_fiscal

  left outer join Centro_Custo cc on cc.cd_centro_custo = n.cd_centro_custo
  left outer join Plano_Financeiro pf on pf.cd_plano_financeiro = n.cd_plano_financeiro
  left outer join vw_destinatario vw  on vw.cd_tipo_destinatario = n.cd_tipo_destinatario and
                                         vw.cd_destinatario      = n.cd_fornecedor
  left outer join plano_conta pc      on pc.cd_conta             = case when isnull(n.cd_conta,0)=0 then vw.cd_conta else n.cd_conta end
  left outer join egisadmin.dbo.usuario ua on ua.cd_usuario = n.cd_usuario
  left outer join conta_contabil cctb on cctb.cd_conta_contabil = n.cd_conta_contabil
  left outer join vw_nota_entrada_situacao_manifesto nee on nee.cd_nota_entrada      = n.cd_nota_entrada and
                                                            nee.cd_serie_nota_fiscal = n.cd_serie_nota_fiscal and
                                                            nee.cd_fornecedor        = n.cd_fornecedor
  left outer join fornecedor f       on f.cd_fornecedor = n.cd_fornecedor
  left outer join contrato_pagar cop on cop.cd_contrato_pagar = n.cd_contrato_pagar

where
  #Filtro


order by #Ordem

select * from NE
drop table NE