// src/providers/giss/mapper/giss.mapper.js
function onlyDigits(v) {
  return String(v ?? '').replace(/\D+/g, '');
}

function dateISO(v) {
  if (!v) return null;
  const d = v instanceof Date ? v : new Date(v);
  if (Number.isNaN(d.getTime())) return String(v);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(
    d.getDate(),
  ).padStart(2, '0')}`;
}

function money(v) {
  if (v === null || v === undefined || v === '') return null;
  let s = String(v).trim().replace(/\s+/g, '');

  // "7.300,00"
  if (s.includes(',')) s = s.replace(/\./g, '').replace(',', '.');
  else {
    // "7300.00" mantém; "1.234.567" remove milhar
    const m = s.match(/\.(\d{1,})$/);
    if (m && m[1].length !== 2) s = s.replace(/\./g, '');
  }

  let n = Number(s);
  if (!Number.isFinite(n)) return null;

  // se vier em centavos (730000) => 7300.00
  if (Number.isInteger(n) && Math.abs(n) >= 100000 && n % 100 === 0) n = n / 100;

  return n.toFixed(2);
}

function codTribMun(v) {
  const s = String(v ?? '').trim();
  if (!s) return null;
  return s.split('/')[0].trim(); // "14.01 / 331..." => "14.01"
}

function mapDbToGissModel({ headerRow, itemRows }) {
  if (!headerRow) throw new Error('headerRow ausente');

  const rpsId = headerRow.IdRps
    ? `RPS${headerRow.IdRps}`
    : `RPS${headerRow.NumeroRps}${headerRow.SerieRps}${headerRow.TipoRps}`;

  const prestCnpj = onlyDigits(headerRow.CnpjPrestador);
  const prestIM = String(headerRow.InscricaoMunicipalPrestador ?? '').trim();

  const tomCnpj = onlyDigits(headerRow.CnpjTomador);
  const tomCpf = onlyDigits(headerRow.CpfTomador);

  const codigoMunicipio = String(
    headerRow.CodigoCidadePrestacao || headerRow.CodigoMunicipio || '',
  ).trim();

  const discriminacao = String(
    headerRow.DiscriminacaoServico ||
      headerRow.DiscriminacaoServicoAux ||
      headerRow.DiscriminacaoServicoAutomatica ||
      '',
  ).trim();

  const rps = {
    id: rpsId,
    identificacao: {
      numero: headerRow.NumeroRps,
      serie: headerRow.SerieRps,
      tipo: headerRow.TipoRps,
    },

    dataEmissao: dateISO(headerRow.DataEmissao),
    status: headerRow.SituacaoNota ?? 1,

    naturezaOperacao: headerRow.NaturezaOperacao ?? 1,
    regimeEspecialTributacao: headerRow.RegimeEspecialTributacao ?? null,
    optanteSimplesNacional: headerRow.OptanteSimplesNacional ?? 2,
    incentivadorCultural: headerRow.IncentivadorCultural ?? 2,

    ic_calculo_imposto: headerRow.ic_calculo_imposto ?? 'N',

    servico: {
      issRetido: headerRow.IssRetido ?? 2,
      itemListaServico: String(headerRow.CodigoItemListaServico || '').trim(),
      codigoCnae: headerRow.CodigoCnae ? onlyDigits(headerRow.CodigoCnae) : null,
      CodigoTributacaoMunicipio: codTribMun(headerRow.CodigoTributacaoMunicipio),
      CodigoMunicipio: codigoMunicipio,
      ExigibilidadeISS: headerRow.ExigibilidadeISS ?? null,
      CodigoNbs: headerRow.CodigoNbs,
      discriminacao,

      valores: {
        valorServicos: money(headerRow.ValorServicos ?? headerRow.nValorServicos),
        valorDeducoes: money(headerRow.ValorDeducoes ?? headerRow.nValorDeducoes),
        valorPis: money(headerRow.ValorPis),
        valorCofins: money(headerRow.ValorCofins),
        valorInss: money(headerRow.ValorInss),
        valorIr: money(headerRow.ValorIr),
        valorCsll: money(headerRow.ValorCsll),
        outrasRetencoes: money(headerRow.ValorOutDeduc),
        descontoIncondicionado: money(headerRow.DescontoIncondicionado ?? headerRow.ValorDescInc),
        descontoCondicionado: money(headerRow.DescontoCondicionado),
        aliquota: String(headerRow.AliquotaISS ?? headerRow.Aliquota_Real_ISS ?? '0').replace(
          ',',
          '.',
        ),
        valorIss: money(headerRow.ValorIss ?? headerRow.nValorIss),

        // trib (para o builder GISS que você já conhece)
        pTotTribSN: headerRow.pTotTribSN ?? null,
        pTotTribFed: headerRow.pTotTribFed ?? null,
        pTotTribEst: headerRow.pTotTribEst ?? null,
        pTotTribMun: headerRow.pTotTribMun ?? null,
      },
    },

    prestador: {
      cnpj: prestCnpj,
      inscricaoMunicipal: prestIM,
    },

    tomador:
      tomCnpj.length === 14 || tomCpf.length === 11
        ? {
            cpfCnpj: tomCnpj.length === 14 ? { cnpj: tomCnpj } : { cpf: tomCpf },
            razaoSocial: headerRow.RazaoSocialTomador || headerRow.FantasiaTomador || '',
            endereco: {
              logradouro: headerRow.EnderecoTomador || '',
              numero: headerRow.NumeroTomador || '',
              complemento: headerRow.ComplementoTomador || '',
              bairro: headerRow.BairroTomador || '',
              codigoMunicipio: String(headerRow.CodigoCidadeTomador || '').trim(),
              uf: headerRow.UfTomador || '',
              cep: onlyDigits(headerRow.CepTomador || ''),
              codigoPais: headerRow.CodigoPaisTormador,
            },
          }
        : null,
  };

  //return { rpsList: [rps], itemRows: itemRows || [] };

  return { rps, rpsList: [rps], itemRows: itemRows || [] };


}

module.exports = { mapDbToGissModel };
