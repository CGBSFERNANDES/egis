const fs = require('fs');
const path = require('path');

const env = require('../src/config/env');
const { getNotaHeader, getNotaItens } = require('../src/repos/nfseRepo');
const { buildGerarNfseEnvioXml } = require('../src/abrasf/layout204/xmlBuilder');
const { signGerarNfseEnvio } = require('../src/abrasf/layout204/signer');
const { gerarNfse } = require('../src/soap/abrasfClient');
const { extractOutputXML } = require('../src/parse/parser');

(async () => {
  const cd = Number(process.argv[2]);
  if (!Number.isFinite(cd)) {
    console.log('Uso: node scripts/e2e_gerar_assinar_enviar.js <cd_nota_saida>');
    process.exit(2);
  }

  const header = await getNotaHeader(cd);
  if (!header) throw new Error(`Nota não encontrada: ${cd}`);
  const itens = await getNotaItens(cd);

  const model = {
    rps: {
      id: `RPS${header.NumeroRps}${header.SerieRps}${header.TipoRps}`,
      numero: header.NumeroRps,
      serie: header.SerieRps,
      tipo: header.TipoRps,
      dataEmissao: header.DataEmissao,
      prestador: {
        cnpj: header.CnpjPrestador,
        inscricaoMunicipal: header.InscricaoMunicipalPrestador,
      },
      tomador:
        header.CnpjTomador || header.CpfTomador
          ? {
              cnpj: header.CnpjTomador,
              cpf: header.CpfTomador,
              razaoSocial: header.RazaoSocialTomador,
            }
          : null,
      servico: {
        itemListaServico: header.CodigoItemListaServico,
        codigoTributacaoMunicipio: header.CodigoTributacaoMunicipio,
        codigoMunicipio: header.CodigoMunicipio,
        discriminacao:
          header.DiscriminacaoServico || (itens || []).map((i) => i.DiscriminacaoItem).join(' | '),
        aliquota: header.AliquotaISS,
        valorServicos: header.ValorServicos,
        valorIss: header.ValorIss,
      },
    },
  };

  const xml = buildGerarNfseEnvioXml(model);

  const outDir = path.join(process.cwd(), 'output');
  fs.mkdirSync(outDir, { recursive: true });

  const xmlPath = path.join(outDir, `01_xml_${cd}_${Date.now()}.xml`);
  fs.writeFileSync(xmlPath, xml, 'utf8');
  console.log('✅ 01 XML:', xmlPath);

  const signed = signGerarNfseEnvio(xml, env.cert.pfxPath, env.cert.pfxPassword);
  const signedPath = path.join(outDir, `02_xml_assinado_${cd}_${Date.now()}.xml`);
  fs.writeFileSync(signedPath, signed, 'utf8');
  console.log('✅ 02 Assinado:', signedPath);

  const r = await gerarNfse({
    endpointUrl: env.nfse.endpointUrl,
    pfxPath: env.cert.pfxPath,
    passphrase: env.cert.pfxPassword,
    xmlGerarNfseEnvio: signed,
    versaoDados: env.nfse.versao,
    outDir,
  });

  console.log('HTTP:', r.httpStatus);

  const { outputXML } = extractOutputXML(String(r.httpBody ?? ''));
  console.log('outputXML:', outputXML);
})();
