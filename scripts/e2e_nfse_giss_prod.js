// scripts/e2e_nfse_giss_prod.js
require('dotenv').config();
const fs = require('fs');
const path = require('path');

const { getNotaByCdNotaSaida } = require('../src/repos/nfseRepo');
const { mapDbToGissModel } = require('../src/providers/giss/mapper/giss.mapper');
const { buildGerarNfseEnvioXml } = require('../src/providers/giss/xml/xmlBuilder.giss204-anterior');
const { signGerarNfseEnvio } = require('../src/providers/giss/signer/giss.signer-anterior');
const { gerarNfseGiss } = require('../src/providers/giss/soap/gissClient');
const { extractOutputXML } = require('../src/parse/parser');

function mustEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`.env faltando: ${name}`);
  return v;
}

function ensureDir(p) {
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

function parseArgs(argv) {
  const args = { env: 'hom' }; // default
  for (const a of argv) {
    if (a.startsWith('--env=')) args.env = a.split('=')[1].trim();
  }
  if (!['hom', 'prod'].includes(args.env)) {
    throw new Error(`--env inválido: ${args.env} (use hom ou prod)`);
  }
  return args;
}

function pickEndpoint(envKey) {
  // prioriza ENDPOINT_URL; se só tiver WSDL_URL, remove querystring
  const endpoint = process.env[`NFSE_${envKey}_ENDPOINT_URL`];
  const wsdl = process.env[`NFSE_${envKey}_WSDL_URL`];

  if (endpoint) return endpoint.split('?')[0];
  if (wsdl) return wsdl.split('?')[0];

  throw new Error(`.env faltando: NFSE_${envKey}_ENDPOINT_URL (ou NFSE_${envKey}_WSDL_URL)`);
}

function summarizeOutput(outputXML) {
  if (!outputXML) return null;

  const str = String(outputXML);
  // tenta pegar <Codigo> e <Mensagem> mesmo com namespaces
  const code = (str.match(/<[^:>]*:?Codigo>([^<]+)<\/[^:>]*:?Codigo>/) || [])[1];
  const msg = (str.match(/<[^:>]*:?Mensagem>([^<]+)<\/[^:>]*:?Mensagem>/) || [])[1];
  const corr = (str.match(/<[^:>]*:?Correcao>([^<]+)<\/[^:>]*:?Correcao>/) || [])[1];

  return { code, msg, corr };
}

(async () => {
  const cd = Number(process.argv[2]);
  if (!Number.isFinite(cd)) {
    console.log('Uso: node scripts/e2e_nfse_giss_prod.js <cd_nota_saida> [--env=hom|prod]');
    process.exit(2);
  }

  const args = parseArgs(process.argv.slice(3));
  const envKey = args.env.toUpperCase();

  const pfxPath = mustEnv('PFX_PATH');
  const pass = mustEnv('PFX_PASSWORD');
  const versaoDados = process.env.NFSE_VERSAO_DADOS || '2.04';

  const endpointUrl = pickEndpoint(envKey);

  const outDir = path.join(process.cwd(), 'output_nfse', String(cd), args.env);
  ensureDir(outDir);

  console.log(`[ENV] ${args.env.toUpperCase()} endpoint: ${endpointUrl}`);

  console.log('[1] DB...');
  const { headerRow, itemRows } = await getNotaByCdNotaSaida(cd);

  console.log('[2] Mapper GISS...');
  const model = mapDbToGissModel({ headerRow, itemRows });

  console.log('[3] XML GISS...');
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

  const sum = summarizeOutput(outputXML);

  console.log('HTTP:', resp.httpStatus);
  if (sum?.code || sum?.msg) {
    console.log('Retorno:', {
      codigo: sum.code,
      mensagem: sum.msg,
      correcao: sum.corr,
    });
  } else {
    console.log('Retorno: (sem Codigo/Mensagem detectáveis no outputXML)');
  }

  console.log('✅ OK. Pasta:', outDir);
  
})().catch((e) => {
  console.error('❌ ERRO:', e?.message || e);
  process.exit(1);
});
