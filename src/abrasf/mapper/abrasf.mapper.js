// src/abrsaf/mapper/abrasf.mapper.js

function onlyDigits(v) {
  return String(v ?? '').replace(/\D+/g, '');
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

function money2(v) {
  if (v === null || v === undefined || v === '') return null;

  let s = String(v).trim().replace(/\s+/g, '');

  // Se vier "7.300,00" (pt-BR)
  if (s.includes(',')) {
    s = s.replace(/\./g, '').replace(',', '.');
  } else {
    // Se vier "7300.00" (padrão) deixa como está
    // Se vier "1.234.567" (milhar) remove os pontos
    const m = s.match(/\.(\d{1,})$/);
    if (m) {
      const decimals = m[1].length;
      if (decimals !== 2) {
        s = s.replace(/\./g, '');
      }
    }
  }

  let n = Number(s);
  if (!Number.isFinite(n)) return null;

  // Heurística: se veio inteiro grande múltiplo de 100, pode estar em centavos
  if (Number.isInteger(n) && Math.abs(n) >= 100000 && n % 100 === 0) n = n / 100;

  return n.toFixed(2);
}

/**
 * Entrada:
 * { headerRow, itemRows } vindo de vw_nfs_dados_nfseV2_item
 *
 * Saída:
 * model ABRASF “GerarNfseEnvio”
 */
function mapDbToAbrasfGerarNfseModel({ headerRow, itemRows }) {
  if (!headerRow) throw new Error('headerRow ausente');

  const id = headerRow.IdRps
    ? `RPS${headerRow.IdRps}`
    : `RPS${headerRow.NumeroRps}${headerRow.SerieRps}${headerRow.TipoRps}`;

  const prestadorCnpj = onlyDigits(headerRow.CnpjPrestador || headerRow.CNPJPrestador);
  const prestadorIM = String(headerRow.InscricaoMunicipalPrestador || '').trim();

  const tomadorCnpj = onlyDigits(headerRow.CnpjTomador);
  const tomadorCpf = onlyDigits(headerRow.CpfTomador);

  const discriminacao = (
    headerRow.DiscriminacaoServico ||
    headerRow.DiscriminacaoServicoAux ||
    ''
  ).trim();

  const codigoMunicipioPrestacao =
    headerRow.CodigoCidadePrestacao || headerRow.CodigoMunicipio || headerRow.CodigoCidadePrestador;

  const ctmRaw = String(headerRow.CodigoTributacaoMunicipio || '').trim();
  const codigoTributacaoMunicipio = ctmRaw ? ctmRaw.split('/')[0].trim() : null;
  
  return {
    rps: {
      id,
      identificacao: {
        numero: headerRow.NumeroRps,
        serie: headerRow.SerieRps,
        tipo: headerRow.TipoRps,
      },
      dataEmissao: dateISO(headerRow.DataEmissao),
      competencia: dateISO(headerRow.DataEmissao),
      naturezaOperacao: headerRow.NaturezaOperacao ?? 1,
      optanteSimplesNacional: headerRow.OptanteSimplesNacional ?? 2,
      regimeEspecialTributacao: headerRow.RegimeEspecialTributacao ?? null,
      incentivadorCultural: headerRow.IncentivadorCultural ?? 2,
      status: headerRow.SituacaoNota ?? 1,

      prestador: {
        cnpj: prestadorCnpj,
        inscricaoMunicipal: prestadorIM,
      },

      tomador:
        tomadorCnpj.length === 14 || tomadorCpf.length === 11
          ? {
              cpfCnpj: tomadorCnpj.length === 14 ? { cnpj: tomadorCnpj } : { cpf: tomadorCpf },
              razaoSocial: headerRow.RazaoSocialTomador || headerRow.FantasiaTomador || '',
              endereco: {
                logradouro: headerRow.EnderecoTomador || '',
                numero: headerRow.NumeroTomador || '',
                complemento: headerRow.ComplementoTomador || '',
                bairro: headerRow.BairroTomador || '',
                codigoMunicipio: headerRow.CodigoCidadeTomador || '',
                uf: headerRow.UfTomador || '',
                cep: onlyDigits(headerRow.CepTomador || ''),
              },
              contato: {
                email: headerRow.EmailTomador || '',
                telefone: onlyDigits(headerRow.TelefoneTomador || ''),
              },
            }
          : null,

      servico: {
        valores: {
          valorServicos: money2(headerRow.ValorServicos ?? headerRow.nValorServicos),
          valorDeducoes: money2(headerRow.ValorDeducoes ?? headerRow.nValorDeducoes),
          valorIss: money2(headerRow.ValorIss ?? headerRow.nValorIss),
          aliquota: headerRow.AliquotaISS ?? headerRow.Aliquota_Real_ISS ?? null,
          issRetido: headerRow.IssRetido ?? 2,
        },
        itemListaServico: (headerRow.CodigoItemListaServico || '').toString().trim(),
        codigoCnae: headerRow.CodigoCnae ? onlyDigits(headerRow.CodigoCnae) : null,
        codigoTributacaoMunicipio: (codigoTributacaoMunicipio || '').toString().trim(),
        discriminacao,
        codigoMunicipio: String(codigoMunicipioPrestacao || '').trim(),
      },

      // se quiser usar itens, pode compor aqui depois.
      itens: itemRows || [],
    },
  };
}

module.exports = { mapDbToAbrasfGerarNfseModel };
