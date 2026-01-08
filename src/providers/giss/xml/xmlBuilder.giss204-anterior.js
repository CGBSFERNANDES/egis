// src/providers/giss/xml/xmlBuilder.giss204.js
const { create } = require('xmlbuilder2');

function addIf(el, name, value) {
  if (value === null || value === undefined) return;
  const s = String(value).trim();
  if (!s) return;
  el.ele(name).txt(s).up();
}

function onlyDigits(v) {
  return String(v ?? '').replace(/\D+/g, '');
}


function cnae7(v) {
  const d = onlyDigits(v);
  return d.length === 7 ? d : null;
}

function nbs9(v) {
  const d = onlyDigits(v);
  return d.length === 9 && d !== '000000000' ? d : null; // evita zeros
}

function codTribMun(v) {
  // aqui é o ponto mais “prefeitura-dependente”.
  // Regra segura: remove espaços e NÃO inventa.
  const s = String(v ?? '').trim();
  if (!s) return null;

  // Se vier algo como "14.01 / 331390100", pegue só a parte do código antes do " / "
  // ou, mais seguro ainda: só aceita o que já vier "limpo".
  const cleaned = s.split('/')[0].trim(); // "14.01"
  return cleaned || null;
}

function money(v) {
  if (v === null || v === undefined || v === '') return null;
  const s = String(v).replace(',', '.');
  const n = Number(s);
  return Number.isFinite(n) ? n.toFixed(2) : null;
}

function buildGerarNfseEnvioXml(model) {
  const r = model.rps || model.rpsList?.[0];
  if (!r) throw new Error('Model sem rps');

  const NS_ENVIO = 'http://www.giss.com.br/gerar-nfse-envio-v2_04.xsd';
  const NS_TIPOS = 'http://www.giss.com.br/tipos-v2_04.xsd';

  const root = create({ version: '1.0', encoding: 'UTF-8' }).ele('GerarNfseEnvio', {
    xmlns: NS_ENVIO,
    'xmlns:tipos': NS_TIPOS,
    'xmlns:dsig': 'http://www.w3.org/2000/09/xmldsig#',
  });

  const rpsWrap = root.ele('Rps');

  // ✅ aqui precisa ser tipos:
  const inf = rpsWrap.ele('tipos:InfDeclaracaoPrestacaoServico', { Id: r.id });

  const rpsNode = inf.ele('tipos:Rps');
  const ide = rpsNode.ele('tipos:IdentificacaoRps');
  addIf(ide, 'tipos:Numero', r.identificacao.numero);
  addIf(ide, 'tipos:Serie', r.identificacao.serie);
  addIf(ide, 'tipos:Tipo', r.identificacao.tipo);
  ide.up();

  addIf(rpsNode, 'tipos:DataEmissao', r.dataEmissao);
  addIf(rpsNode, 'tipos:Status', r.status);
  rpsNode.up();

  addIf(inf, 'tipos:Competencia', r.competencia || r.dataEmissao);
  addIf(inf, 'tipos:NaturezaOperacao', r.naturezaOperacao);
  addIf(inf, 'tipos:RegimeEspecialTributacao', r.regimeEspecialTributacao);
  addIf(inf, 'tipos:OptanteSimplesNacional', r.optanteSimplesNacional);
  addIf(inf, 'tipos:IncentivadorCultural', r.incentivadorCultural);
  addIf(inf, 'tipos:IncentivoFiscal', r.incentivoFiscal ?? 2);

  // Serviço
  const serv = inf.ele('tipos:Servico');
  const valores = serv.ele('tipos:Valores');

  addIf(valores, 'tipos:ValorServicos', money(r.servico.valores.valorServicos));
  addIf(valores, 'tipos:ValorDeducoes', money(r.servico.valores.valorDeducoes));
  addIf(valores, 'tipos:ValorIss', money(r.servico.valores.valorIss));

  if (r.servico.valores.aliquota !== null && r.servico.valores.aliquota !== undefined) {
    const aliq = Number(String(r.servico.valores.aliquota).replace(',', '.'));
    if (Number.isFinite(aliq)) addIf(valores, 'tipos:Aliquota', aliq.toFixed(4));
  }
  valores.up();

  addIf(serv, 'tipos:IssRetido', r.servico.valores.issRetido ?? 2);
  addIf(serv, 'tipos:ItemListaServico', r.servico.itemListaServico);
  addIf(serv, 'tipos:CodigoCnae', r.servico.codigoCnae);

  // CodigoTributacaoMunicipio: NÃO inventa "0"
  const ctm = codTribMun(r.servico?.CodigoTributacaoMunicipio);
  if (ctm) {
    serv.ele('tipos:CodigoTributacaoMunicipio').txt(ctm).up();
  }

  // CodigoNbs: só se vier válido (9 dígitos e não tudo zero)
  const nbs = nbs9(r.servico?.CodigoNbs || r.servico?.codigoNBS);
  if (nbs) {
    //serv.ele('tipos:CodigoNbs').txt(nbs).up();
  }

  addIf(serv, 'tipos:Discriminacao', r.servico.discriminacao);
  addIf(serv, 'tipos:CodigoMunicipio', r.tomador.endereco.codigoMunicipio);
  addIf(serv, 'tipos:ExigibilidadeISS', r.servico.exigibilidadeISS ?? 1);

  //addIf(serv, 'tipos:CodigoTributacaoMunicipio', r.servico.codigoTributacaoMunicipio);
  // addIf(serv, 'tipos:CodigoMunicipio', r.servico.codigoMunicipio);

  serv.up();

  // Prestador
  const prest = inf.ele('tipos:Prestador');
  const prestCpfCnpj = prest.ele('tipos:CpfCnpj');
  prestCpfCnpj.ele('tipos:Cnpj').txt(String(r.prestador.cnpj)).up();
  prestCpfCnpj.up();
  addIf(prest, 'tipos:InscricaoMunicipal', r.prestador.inscricaoMunicipal);
  prest.up();

  // Tomador (opcional)
  if (r.tomador?.cpfCnpj?.cnpj || r.tomador?.cpfCnpj?.cpf) {
    const tom = inf.ele('tipos:TomadorServico');
    const idt = tom.ele('tipos:IdentificacaoTomador');
    const cpfCnpj = idt.ele('tipos:CpfCnpj');

    if (r.tomador.cpfCnpj.cnpj) cpfCnpj.ele('tipos:Cnpj').txt(r.tomador.cpfCnpj.cnpj).up();
    if (r.tomador.cpfCnpj.cpf) cpfCnpj.ele('tipos:Cpf').txt(r.tomador.cpfCnpj.cpf).up();
    cpfCnpj.up();
    idt.up();

    addIf(tom, 'tipos:RazaoSocial', r.tomador.razaoSocial);

    if (r.tomador.endereco) {
      const e = tom.ele('tipos:Endereco');
      addIf(e, 'tipos:Endereco', r.tomador.endereco.logradouro);
      addIf(e, 'tipos:Numero', r.tomador.endereco.numero || 'S/N');
      addIf(e, 'tipos:Complemento', r.tomador.endereco.complemento);
      addIf(e, 'tipos:Bairro', r.tomador.endereco.bairro);
      addIf(e, 'tipos:Uf', r.tomador.endereco.uf);
      addIf(e, 'tipos:Cep', r.tomador.endereco.cep);
      addIf(e, 'tipos:CodigoPais', r.tomador.endereco.codigoPais || '1058');
      e.up();
    }

    tom.up();

  }

  return root.end({ prettyPrint: true });

}

module.exports = { buildGerarNfseEnvioXml };
