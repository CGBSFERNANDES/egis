// src/providers/giss/xml/xmlBuilder.giss204.js
const { create } = require('xmlbuilder2');

function n2(v) {
  if (v === null || v === undefined || v === '') return undefined;
  const num = Number(v);
  return Number.isFinite(num) ? num.toFixed(2) : undefined;
}

function buildGerarNfseEnvioXml({ rpsList }) {
  if (!Array.isArray(rpsList) || !rpsList.length) {
    throw new Error('buildGerarNfseEnvioXml: rpsList vazio.');
  }

  const NS_ENVIO = 'http://www.giss.com.br/gerar-nfse-envio-v2_04.xsd';
  const NS_TIPOS = 'http://www.giss.com.br/tipos-v2_04.xsd';
  const NS_DSIG = 'http://www.w3.org/2000/09/xmldsig#';

  const doc = create({ version: '1.0', encoding: 'UTF-8' });

  const root = doc.ele('GerarNfseEnvio', {
    xmlns: NS_ENVIO,
    'xmlns:tipos': NS_TIPOS,
    'xmlns:dsig': NS_DSIG,
  });

  // Em GISS 2.04 normalmente é <Rps> contendo <tipos:InfDeclaracaoPrestacaoServico>
  const rpsWrap = root.ele('Rps');

  const r = rpsList[0];

  const inf = rpsWrap.ele('tipos:InfDeclaracaoPrestacaoServico', { Id: r.id });

  // Rps
  const rps = inf.ele('tipos:Rps');
  const idRps = rps.ele('tipos:IdentificacaoRps');
  idRps.ele('tipos:Numero').txt(String(r.identificacao.numero));
  idRps.ele('tipos:Serie').txt(String(r.identificacao.serie));
  idRps.ele('tipos:Tipo').txt(String(r.identificacao.tipo));

  rps.ele('tipos:DataEmissao').txt(r.dataEmissao);
  rps.ele('tipos:Status').txt(String(r.status));

  // Raiz da declaração
  if (r.competencia) inf.ele('tipos:Competencia').txt(r.competencia);
  if (r.naturezaOperacao) inf.ele('tipos:NaturezaOperacao').txt(String(r.naturezaOperacao));
  if (r.regimeEspecialTributacao)
    inf.ele('tipos:RegimeEspecialTributacao').txt(String(r.regimeEspecialTributacao));
  if (r.optanteSimplesNacional)
    inf.ele('tipos:OptanteSimplesNacional').txt(String(r.optanteSimplesNacional));
  if (r.incentivadorCultural)
    inf.ele('tipos:IncentivadorCultural').txt(String(r.incentivadorCultural));
  if (r.incentivoFiscal) inf.ele('tipos:IncentivoFiscal').txt(String(r.incentivoFiscal));

  // Prestador
  const prest = inf.ele('tipos:Prestador');
  const pc = prest.ele('tipos:CpfCnpj');
  pc.ele('tipos:Cnpj').txt(String(r.prestador.cnpj));
  prest.ele('tipos:InscricaoMunicipal').txt(String(r.prestador.inscricaoMunicipal));

  // Tomador
  if (r.tomador?.cnpj || r.tomador?.cpf) {
    const tom = inf.ele('tipos:TomadorServico');
    const it = tom.ele('tipos:IdentificacaoTomador');
    const tc = it.ele('tipos:CpfCnpj');
    if (r.tomador.cnpj) tc.ele('tipos:Cnpj').txt(String(r.tomador.cnpj));
    else tc.ele('tipos:Cpf').txt(String(r.tomador.cpf));

    if (r.tomador.razaoSocial) tom.ele('tipos:RazaoSocial').txt(r.tomador.razaoSocial);

    if (r.tomador.endereco) {
      const e = tom.ele('tipos:Endereco');
      if (r.tomador.endereco.endereco) e.ele('tipos:Endereco').txt(r.tomador.endereco.endereco);
      if (r.tomador.endereco.numero) e.ele('tipos:Numero').txt(r.tomador.endereco.numero);
      if (r.tomador.endereco.complemento)
        e.ele('tipos:Complemento').txt(r.tomador.endereco.complemento);
      if (r.tomador.endereco.bairro) e.ele('tipos:Bairro').txt(r.tomador.endereco.bairro);
      if (r.tomador.endereco.codigoMunicipio)
        e.ele('tipos:CodigoMunicipio').txt(String(r.tomador.endereco.codigoMunicipio));
      if (r.tomador.endereco.uf) e.ele('tipos:Uf').txt(r.tomador.endereco.uf);
      if (r.tomador.endereco.cep)
        e.ele('tipos:Cep').txt(String(r.tomador.endereco.cep).replace(/\D/g, ''));
      if (r.tomador.endereco.codigoPais)
        e.ele('tipos:CodigoPais').txt(String(r.tomador.endereco.codigoPais));
    }
  }

  // Serviço
  const srv = inf.ele('tipos:Servico');
  const vals = srv.ele('tipos:Valores');
  vals.ele('tipos:ValorServicos').txt(n2(r.servico.valorServicos) ?? '0.00');
  if (n2(r.servico.valorDeducoes)) vals.ele('tipos:ValorDeducoes').txt(n2(r.servico.valorDeducoes));
  if (n2(r.servico.valorIss)) vals.ele('tipos:ValorIss').txt(n2(r.servico.valorIss));
  if (r.servico.aliquota !== undefined && r.servico.aliquota !== null)
    vals.ele('tipos:Aliquota').txt(String(r.servico.aliquota));

  if (r.servico.issRetido) srv.ele('tipos:IssRetido').txt(String(r.servico.issRetido));
  if (r.servico.itemListaServico)
    srv.ele('tipos:ItemListaServico').txt(String(r.servico.itemListaServico));
  if (r.servico.codigoCnae) srv.ele('tipos:CodigoCnae').txt(String(r.servico.codigoCnae));
  if (r.servico.codigoTributacaoMunicipio)
    srv.ele('tipos:CodigoTributacaoMunicipio').txt(String(r.servico.codigoTributacaoMunicipio));
  if (r.servico.discriminacao) srv.ele('tipos:Discriminacao').txt(String(r.servico.discriminacao));
  if (r.servico.codigoMunicipio)
    srv.ele('tipos:CodigoMunicipio').txt(String(r.servico.codigoMunicipio));
  if (r.servico.exigibilidadeISS)
    srv.ele('tipos:ExigibilidadeISS').txt(String(r.servico.exigibilidadeISS));

  return root.end({ prettyPrint: true });
}

module.exports = { buildGerarNfseEnvioXml };
