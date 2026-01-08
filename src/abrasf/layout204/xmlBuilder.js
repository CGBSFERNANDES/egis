const { create } = require('xmlbuilder2');

function onlyDigits(v) {
  return String(v ?? '').replace(/\D+/g, '');
}
function money(v) {
  if (v === null || v === undefined || v === '') return null;
  let s = String(v).trim().replace(/\s+/g, '');
  if (s.includes(',')) s = s.replace(/\./g, '').replace(',', '.');
  const n = Number(s);
  if (!Number.isFinite(n)) return null;
  return n.toFixed(2);
}
function dateISO(v) {
  if (!v) return null;
  const d = v instanceof Date ? v : new Date(v);
  if (Number.isNaN(d.getTime())) return String(v);
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}
function addIf(el, name, value) {
  if (value === null || value === undefined) return;
  const s = String(value).trim();
  if (!s) return;
  el.ele(name).txt(s).up();
}

/**
 * Modelo de entrada (mínimo):
 * {
 *   rps: {
 *     id: "RPS123",
 *     numero, serie, tipo,
 *     dataEmissao,
 *     prestador: { cnpj, inscricaoMunicipal },
 *     tomador: { cnpj|cpf, razaoSocial } (opcional),
 *     servico: { itemListaServico, codigoTributacaoMunicipio, codigoMunicipio, discriminacao, aliquota, valorServicos, valorIss }
 *   }
 * }
 */
function buildGerarNfseEnvioXml(model, opts = {}) {
  // Por padrão deixo namespaces “genéricos”.
  // Se o provedor exigir namespaces próprios, isso vira config do adapter.
  const NS_ENVIO = opts.nsEnvio || 'http://www.abrasf.org.br/nfse.xsd';
  const NS_TIPOS = opts.nsTipos || 'http://www.abrasf.org.br/nfse.xsd';

  const r = model.rps;

  const root = create({ version: '1.0', encoding: 'UTF-8' }).ele('GerarNfseEnvio', {
    xmlns: NS_ENVIO,
    'xmlns:tipos': NS_TIPOS,
    'xmlns:dsig': 'http://www.w3.org/2000/09/xmldsig#',
  });

  const rps = root.ele('Rps');
  const inf = rps.ele('tipos:InfDeclaracaoPrestacaoServico', { Id: r.id });

  const rpsNode = inf.ele('tipos:Rps');
  const ide = rpsNode.ele('tipos:IdentificacaoRps');
  addIf(ide, 'tipos:Numero', r.numero);
  addIf(ide, 'tipos:Serie', r.serie);
  addIf(ide, 'tipos:Tipo', r.tipo);
  ide.up();

  addIf(rpsNode, 'tipos:DataEmissao', dateISO(r.dataEmissao));
  addIf(rpsNode, 'tipos:Status', '1');
  rpsNode.up();

  addIf(inf, 'tipos:Competencia', dateISO(r.dataEmissao));

  // Prestador
  const prest = inf.ele('tipos:Prestador');
  const prestCpfCnpj = prest.ele('tipos:CpfCnpj');
  prestCpfCnpj.ele('tipos:Cnpj').txt(onlyDigits(r.prestador?.cnpj)).up();
  prestCpfCnpj.up();
  addIf(prest, 'tipos:InscricaoMunicipal', String(r.prestador?.inscricaoMunicipal || '').trim());
  prest.up();

  // Tomador (opcional)
  if (r.tomador?.cnpj || r.tomador?.cpf) {
    const tom = inf.ele('tipos:Tomador');
    const tomIde = tom.ele('tipos:IdentificacaoTomador');
    const tomCpfCnpj = tomIde.ele('tipos:CpfCnpj');
    if (r.tomador.cnpj) tomCpfCnpj.ele('tipos:Cnpj').txt(onlyDigits(r.tomador.cnpj)).up();
    if (r.tomador.cpf) tomCpfCnpj.ele('tipos:Cpf').txt(onlyDigits(r.tomador.cpf)).up();
    tomCpfCnpj.up();
    tomIde.up();
    addIf(tom, 'tipos:RazaoSocial', r.tomador.razaoSocial);
    tom.up();
  }

  // Serviço
  const serv = inf.ele('tipos:Servico');
  const valores = serv.ele('tipos:Valores');
  addIf(valores, 'tipos:ValorServicos', money(r.servico?.valorServicos));
  addIf(valores, 'tipos:ValorIss', money(r.servico?.valorIss));
  if (r.servico?.aliquota !== null && r.servico?.aliquota !== undefined) {
    const aliq = Number(String(r.servico.aliquota).replace(',', '.'));
    if (Number.isFinite(aliq)) addIf(valores, 'tipos:Aliquota', aliq.toFixed(4));
  }
  valores.up();

  addIf(serv, 'tipos:ItemListaServico', r.servico?.itemListaServico);
  addIf(serv, 'tipos:CodigoTributacaoMunicipio', r.servico?.codigoTributacaoMunicipio);
  addIf(serv, 'tipos:CodigoMunicipio', r.servico?.codigoMunicipio);
  addIf(serv, 'tipos:Discriminacao', r.servico?.discriminacao);
  serv.up();

  return root.end({ prettyPrint: true });
}

module.exports = { buildGerarNfseEnvioXml };
