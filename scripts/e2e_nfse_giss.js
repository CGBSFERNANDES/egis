require('dotenv').config();
const fs = require('fs');
const path = require('path');

const { getNotaByCdNotaSaida } = require('../src/repos/nfseRepo');
const { mapDbToGissModel } = require('../src/providers/giss/mapper/giss.mapper');
const { buildGerarNfseEnvioXml } = require('../src/providers/giss/xml/xmlBuilder.giss204');
const { signGerarNfseEnvio } = require('../src/providers/giss/signer/giss.signer');
const { gerarNfseGiss } = require('../src/providers/giss/soap/gissClient');
const { extractOutputXML } = require('../src/parse/parser');

function must(name) {
  const v = process.env[name];
  if (!v) throw new Error(`.env faltando: ${name}`);
  return v;
}
function ensureDir(p) {
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

(async () => {
  const cd = Number(process.argv[2]);
  if (!Number.isFinite(cd)) {
    console.log('Uso: node scripts/e2e_nfse_giss.js <cd_nota_saida>');
    process.exit(2);
  }

  const pfxPath = must('PFX_PATH');
  const pass = must('PFX_PASSWORD');

  const wsdlOrEndpoint = process.env.NFSE_ENDPOINT_URL || process.env.NFSE_WSDL_URL;
  if (!wsdlOrEndpoint) throw new Error('.env faltando: NFSE_ENDPOINT_URL (ou NFSE_WSDL_URL)');
  const endpointUrl = wsdlOrEndpoint.split('?')[0];

  const versaoDados = process.env.NFSE_VERSAO_DADOS || '2.04';

  const outDir = path.join(process.cwd(), 'output_nfse', String(cd));
  ensureDir(outDir);

  console.log('[1] DB...');
  const { headerRow, itemRows } = await getNotaByCdNotaSaida(cd);

  console.log('[2] Mapper GISS...');
  const model = mapDbToGissModel({ headerRow, itemRows });

  console.log('[3] XML GISS...');
  
  //const xml = buildGerarNfseEnvioXml(model);

  //const rps0 = model.rpsList?.[0];

  //if (!rps0) throw new Error('Mapper não gerou rpsList[0]. Verifique dados/mapper.');
  //const xml = buildGerarNfseEnvioXml({
  //  rps: rps0,
  //  rpsList: model.rpsList,
  //  itemRows: model.itemRows,
  //});

  const xml = buildGerarNfseEnvioXml({ rpsList: model.rpsList, itemRows: model.itemRows });


  fs.writeFileSync(path.join(outDir, `01_xml_${Date.now()}.xml`), xml, 'utf8');

  console.log('[4] Assinando...');
  const signed = signGerarNfseEnvio(xml, pfxPath, pass);
  fs.writeFileSync(path.join(outDir, `02_assinado_${Date.now()}.xml`), signed, 'utf8');

  console.log('[5] Enviando SOAP...');
  const resp = await gerarNfseGiss({
    endpointUrl,
    pfxPath,
    passphrase: pass,
    xmlGerarNfseEnvio: signed,
    versaoDados,
    outDir,
  });

  fs.writeFileSync(path.join(outDir, `03_http_${Date.now()}.txt`), String(resp.httpStatus), 'utf8');
  fs.writeFileSync(
    path.join(outDir, `04_soapResp_${Date.now()}.xml`),
    String(resp.httpBody ?? ''),
    'utf8',
  );

  const { outputXML } = extractOutputXML(String(resp.httpBody ?? ''));
  fs.writeFileSync(
    path.join(outDir, `05_outputXML_${Date.now()}.xml`),
    String(outputXML ?? ''),
    'utf8',
  );

  console.log('HTTP:', resp.httpStatus);
  console.log('✅ OK. Pasta:', outDir);
})();
