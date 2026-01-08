require('dotenv').config();

const fs = require('fs');
const path = require('path');

const { getNotaByCdNotaSaida } = require('../src/repos/nfseRepo');
const { mapDbToAbrasfGerarNfseModel } = require('../src/abrasf/mapper/abrasf.mapper');
const { buildGerarNfseEnvioXmlAbrasf } = require('../src/abrasf/xml/xmlBuilder.abrasf204');
const { signById } = require('../src/abrasf/signer/xmlSigner');

// Reaproveita seu envio SOAP (se quiser “ABRASF puro” depois, eu também separo):
//const { gerarNfse } = require('../giss.service');
const { gerarNfse } = require('../src/soap/abrasfClient');
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
    console.log('Uso: node scripts/e2e_nfse_abrasf.js <cd_nota_saida>');
    process.exit(2);
  }

  const pfxPath = must('PFX_PATH');
  const pass = must('PFX_PASSWORD');
  //const wsdlOrEndpoint = must('NFSE_WSDL_URL'); // ou NFSE_ENDPOINT_URL
const wsdlOrEndpoint = process.env.NFSE_ENDPOINT_URL || process.env.NFSE_WSDL_URL;
if (!wsdlOrEndpoint) throw new Error('.env faltando: NFSE_ENDPOINT_URL (ou NFSE_WSDL_URL)');



  const endpointUrl = wsdlOrEndpoint.split('?')[0];
  const versaoDados = process.env.NFSE_VERSAO_DADOS || '2.04';

  const outDir = path.join(process.cwd(), 'output_nfse', String(cd));
  ensureDir(outDir);

  console.log('[1] DB...');
  const { headerRow, itemRows } = await getNotaByCdNotaSaida(cd);

  console.log('[2] Mapper ABRASF...');
  const model = mapDbToAbrasfGerarNfseModel({ headerRow, itemRows });

  console.log('[3] Builder ABRASF...');
  
  const xml = buildGerarNfseEnvioXmlAbrasf(model);
  const xmlPath = path.join(outDir, `01_xml_${Date.now()}.xml`);
  fs.writeFileSync(xmlPath, xml, 'utf8');

  console.log('[4] Assinando ABRASF...');
  const signed = signById(xml, pfxPath, pass, model.rps.id);
  const signedPath = path.join(outDir, `02_assinado_${Date.now()}.xml`);
  fs.writeFileSync(signedPath, signed, 'utf8');

  console.log('[5] Enviando SOAP homolog...');
  const resp = await gerarNfse({
    endpointUrl,
    pfxPath,
    passphrase: pass,
    xmlGerarNfseEnvio: signed,
    versaoDados,
  });

  fs.writeFileSync(path.join(outDir, `03_http_${Date.now()}.txt`), String(resp.httpStatus), 'utf8');
  fs.writeFileSync(
    path.join(outDir, `04_soapResp_${Date.now()}.xml`),
    String(resp.httpBody ?? ''),
    'utf8',
  );

  console.log('[6] outputXML...');
  const { outputXML } = extractOutputXML(String(resp.httpBody ?? ''));
  fs.writeFileSync(
    path.join(outDir, `05_outputXML_${Date.now()}.xml`),
    String(outputXML ?? ''),
    'utf8',
  );

  console.log('✅ OK. Pasta:', outDir);
})();
