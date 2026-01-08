const { create } = require('xmlbuilder2');

function addIf(el, name, value) {
  if (value === null || value === undefined) return;
  const s = String(value).trim();
  if (!s) return;
  el.ele(name).txt(s).up();
}

function money(v) {
  if (v === null || v === undefined || v === '') return null;
  const s = String(v).replace(',', '.');
  const n = Number(s);
  return Number.isFinite(n) ? n.toFixed(2) : null;
}

/**
 * GerarNfseEnvio (ABRASF 2.04)
 * Observação: alguns municípios exigem mais campos.
 * Aqui é o “mínimo bem formado” para evoluir.
 */
function buildGerarNfseEnvioXmlAbrasf(model) {
  const r = model.rps;

  const root = create({ version: '1.0', encoding: 'UTF-8' }).ele('GerarNfseEnvio', {
    xmlns: 'http://www.abrasf.org.br/nfse.xsd',
  });

  const rps = root.ele('Rps');
  const inf = rps.ele('InfDeclaracaoPrestacaoServico', { Id: r.id });

  const rpsNode = inf.ele('Rps');
  const ide = rpsNode.ele('IdentificacaoRps');
  addIf(ide, 'Numero', r.identificacao.numero);
  addIf(ide, 'Serie', r.identificacao.serie);
  addIf(ide, 'Tipo', r.identificacao.tipo);
  ide.up();

  addIf(rpsNode, 'DataEmissao', r.dataEmissao);
  addIf(rpsNode, 'Status', r.status);
  rpsNode.up();

  addIf(inf, 'Competencia', r.competencia);
  addIf(inf, 'NaturezaOperacao', r.naturezaOperacao);
  addIf(inf, 'RegimeEspecialTributacao', r.regimeEspecialTributacao);
  addIf(inf, 'OptanteSimplesNacional', r.optanteSimplesNacional);
  addIf(inf, 'IncentivadorCultural', r.incentivadorCultural);
  addIf(inf, 'IncentivoFiscal', '2');

  // Serviço
  const serv = inf.ele('Servico');
  const valores = serv.ele('Valores');
  addIf(valores, 'ValorServicos', money(r.servico.valores.valorServicos));
  addIf(valores, 'ValorDeducoes', money(r.servico.valores.valorDeducoes));
  addIf(valores, 'ValorIss', money(r.servico.valores.valorIss));
  if (r.servico.valores.aliquota !== null && r.servico.valores.aliquota !== undefined) {
    const aliq = Number(String(r.servico.valores.aliquota).replace(',', '.'));
    if (Number.isFinite(aliq)) addIf(valores, 'Aliquota', aliq.toFixed(4));
  }
  valores.up();

  addIf(serv, 'IssRetido', r.servico.valores.issRetido ?? 2);
  addIf(serv, 'ItemListaServico', r.servico.itemListaServico);
  addIf(serv, 'CodigoCnae', r.servico.codigoCnae);
  addIf(serv, 'CodigoTributacaoMunicipio', r.servico.codigoTributacaoMunicipio);
  addIf(serv, 'Discriminacao', r.servico.discriminacao);
  addIf(serv, 'CodigoMunicipio', r.servico.codigoMunicipio);
  serv.up();

  // Prestador
  const prest = inf.ele('Prestador');
  const prestCpfCnpj = prest.ele('CpfCnpj');
  prestCpfCnpj.ele('Cnpj').txt(String(r.prestador.cnpj)).up();
  prestCpfCnpj.up();
  addIf(prest, 'InscricaoMunicipal', r.prestador.inscricaoMunicipal);
  prest.up();

  // Tomador (opcional)
  if (r.tomador?.cpfCnpj?.cnpj || r.tomador?.cpfCnpj?.cpf) {
    const tom = inf.ele('TomadorServico');
    const idt = tom.ele('IdentificacaoTomador');
    const cpfCnpj = idt.ele('CpfCnpj');

    if (r.tomador.cpfCnpj.cnpj) cpfCnpj.ele('Cnpj').txt(r.tomador.cpfCnpj.cnpj).up();
    if (r.tomador.cpfCnpj.cpf) cpfCnpj.ele('Cpf').txt(r.tomador.cpfCnpj.cpf).up();
    cpfCnpj.up();
    idt.up();

    addIf(tom, 'RazaoSocial', r.tomador.razaoSocial);

    if (r.tomador.endereco) {
      const e = tom.ele('Endereco');
      addIf(e, 'Endereco', r.tomador.endereco.logradouro);
      addIf(e, 'Numero', r.tomador.endereco.numero);
      addIf(e, 'Complemento', r.tomador.endereco.complemento);
      addIf(e, 'Bairro', r.tomador.endereco.bairro);
      addIf(e, 'CodigoMunicipio', r.tomador.endereco.codigoMunicipio);
      addIf(e, 'Uf', r.tomador.endereco.uf);
      addIf(e, 'Cep', r.tomador.endereco.cep);
      e.up();
    }

    tom.up();
  }

  return root.end({ prettyPrint: true });
}

module.exports = { buildGerarNfseEnvioXmlAbrasf };
