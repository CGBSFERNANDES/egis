use egisadmin
go

--select * from nfe_empresa


select
  e.cd_empresa,
       cast(replace(replace(replace(isnull(e.cd_cgc_empresa,''),'/',''),'.',''),'-','') as varchar(18)) as cd_cnpj_empresa,
    'N' as ic_ativo,
    113 as cd_usuario_inclusao,
    getdate() as dt_usuario_inclusao,
    113      as cd_usuario,
    getdate() as dt_usuario,
    1 as cd_modelo_danfe,
    'N' as ic_dfe_ativo,
    cast('' as varchar(30)) as nm_banco_empresa,
null as nm_certificado,
null as cd_senha_certificado,
1 as cd_regime_tributario,
2 as cd_ambiente_nfe,
null as cd_id_seguranca_nfc,
null as cd_seguranca_nfc,
null as cd_seguranca_nfc_hom,
'PL_009_V4' as nm_versao_esquema_nfc,
'N' as ic_imposto_cibs,
null as hr_dfe_servico,
null as cd_ult_nsu,
null as cd_max_NSU,
null as nm_pdf_local

into
  #NFE

from
  egisadmin.dbo.empresa e
where
  e.cd_empresa not in ( select n.cd_empresa from NFe_Empresa n where n.cd_empresa = e.cd_empresa )
  and
  ic_ativa_empresa = 'S'

  insert into NFe_Empresa
  select * from #NFE

  drop table #NFE

