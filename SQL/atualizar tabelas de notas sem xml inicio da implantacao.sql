select * from nota_validacao where cd_nota_saida = 3796
select * from nota_saida_recibo where cd_nota_saida = 3796
select * from nota_saida_documento where cd_nota_saida = 3796

update
  nota_validacao
  set
    cd_chave_acesso = substring(ns.cd_chave_acesso,4,44),
    ic_validada = 'S',
    ic_impresso = 'S',
    ds_xml_nota = n.ds_nota_xml_retorno
  from 
    nota_validacao v
    inner join nota_saida_documento n on n.cd_nota_saida = v.cd_nota_saida
    inner join nota_saida ns on ns.cd_nota_saida = n.cd_nota_saida
    where
      n.cd_nota_saida = 3796
      and
      cast(n.ds_nota_xml_retorno as nvarchar(max))<>''
      and
      cast(v.ds_xml_nota as nvarchar(max))=''

      select 
        v.*, 
        n.ds_nota_xml_retorno
        from 
    nota_validacao v
    inner join nota_saida_documento n on n.cd_nota_saida = v.cd_nota_saida
    where
      n.cd_nota_saida = 3796
      and
      cast(n.ds_nota_xml_retorno as nvarchar(max))<>''
      and
      cast(v.ds_xml_nota as nvarchar(max))=''