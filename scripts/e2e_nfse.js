/**
 * scripts/e2e_nfse.js
 * Uso: node scripts/e2e_nfse.js 355
 */
require('dotenv').config();

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const { getNotaByCdNotaSaida } = require('../src/repos/nfseRepo');

const { mapDbToGissModel } = require('../giss.mapper');
const { buildGerarNfseEnvioXml } = require('../xmlBuilder');
const { signGerarNfseEnvio } = require('../signer');
const { gerarNfse } = require('../giss.service');
const { extractOutputXML } = require('../parser');

function mustEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`.env: variável obrigatória ausente: ${name}`);
  return v;
}

function ensureDir(p) {
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

function runJavaXsdValidator({ xmlPath, xsdPath }) {
  return new Promise((resolve, reject) => {
    const javaCp = path.join(process.cwd(), 'tools', 'xsd');

    const javaArgs = ['-cp', javaCp, 'XsdValidator', xmlPath, xsdPath];

    console.log('[XSD] java', javaArgs.join(' '));

    const child = spawn('java', javaArgs, { stdio: ['ignore', 'pipe', 'pipe'] });

    let out = '';
    let err = '';

    const timer = setTimeout(() => {
      child.kill('SIGKILL');
      reject(new Error('[XSD] TIMEOUT na validação (20s)'));
    }, 20000);

    child.stdout.on('data', (d) => (out += d.toString()));
    child.stderr.on('data', (d) => (err += d.toString()));

    child.on('close', (code) => {
      clearTimeout(timer);
      if (code === 0) return resolve(out.trim() || 'OK');
      reject(new Error((err || out || '').trim() || `[XSD] Falhou code=${code}`));
    });
  });
}

(async () => {
  try {
    const cd = Number(process.argv[2]);
    if (!Number.isFinite(cd)) {
      console.log('Uso: node scripts/e2e_nfse.js <cd_nota_saida>');
      process.exit(2);
    }

    console.log('=== E2E NFSe ABRASF ===');
    console.log('cd_nota_saida:', cd);

    // ENV
    const PFX_PATH = mustEnv('PFX_PATH');
    const PFX_PASSWORD = mustEnv('PFX_PASSWORD');

    // Você pode usar NFSE_WSDL_URL ou NFSE_ENDPOINT_URL, aceito ambos:
    const wsdlOrEndpoint = process.env.NFSE_WSDL_URL || process.env.NFSE_ENDPOINT_URL;

    if (!wsdlOrEndpoint) {
      throw new Error('.env: defina NFSE_WSDL_URL (ou NFSE_ENDPOINT_URL)');
    }

    const endpointUrl = wsdlOrEndpoint.split('?')[0];
    const NFSE_VERSAO_DADOS = process.env.NFSE_VERSAO_DADOS || '2.04';

    console.log('[ENV] endpointUrl:', endpointUrl);
    console.log('[ENV] versaoDados:', NFSE_VERSAO_DADOS);
    console.log('[ENV] pfx:', PFX_PATH);

    // XSD path:
    // Você enviou "schema nfse v2-04.xsd" e também pode estar usando outros.
    // Vamos tentar 2 caminhos e escolher o primeiro que existir.
    const candidates = [
      path.join(process.cwd(), 'schemas', 'schema-nfse-v2-04.xsd'),
      path.join(process.cwd(), 'schemas', 'schema nfse v2-04.xsd'),
      path.join(process.cwd(), 'schemas', 'nfse', 'schema-nfse-v2-04.xsd'),
    ];
    const xsdPath = candidates.find(fs.existsSync);

    if (!xsdPath) {
      console.log('[XSD] Não encontrei XSD em:');
      candidates.forEach((p) => console.log(' -', p));
      throw new Error('XSD não encontrado. Coloque o XSD em ./schemas/');
    }

    console.log('[XSD] usando:', xsdPath);

    // OUTPUT
    const outDir = path.join(process.cwd(), 'output_nfse', String(cd));
    ensureDir(outDir);
    console.log('[OUT] pasta:', outDir);

    // 1) DB
    console.log('[1] Buscando nota no DB...');
    const { headerRow, itemRows } = await getNotaByCdNotaSaida(cd);
    console.log('[1] OK. Itens:', itemRows.length);

    // 2) mapper
    console.log('[2] Mapeando model...');
    const model = mapDbToGissModel({ headerRow, itemRows });
    console.log('[2] OK. rpsList:', model?.rpsList?.length);

    // 3) gerar XML
    console.log('[3] Gerando XML...');
    const xml = buildGerarNfseEnvioXml(model);
    const xmlPath = path.join(outDir, `01_xml_${Date.now()}.xml`);
    fs.writeFileSync(xmlPath, xml, 'utf8');
    console.log('[3] OK. xml:', xmlPath);

    // 4) validar XSD (antes de assinar)
    console.log('[4] Validando XSD...');
    const ok = await runJavaXsdValidator({ xmlPath, xsdPath });
    fs.writeFileSync(path.join(outDir, `02_xsd_ok_${Date.now()}.txt`), ok + '\n', 'utf8');
    console.log('[4] ✅ XSD OK');

    // 5) assinar
    console.log('[5] Assinando XML...');
    const signed = signGerarNfseEnvio(xml, PFX_PATH, PFX_PASSWORD);
    const signedPath = path.join(outDir, `03_assinado_${Date.now()}.xml`);
    fs.writeFileSync(signedPath, signed, 'utf8');
    console.log('[5] OK. assinado:', signedPath);

    // 6) enviar
    console.log('[6] Enviando homologação (SOAP)...');
    const resp = await gerarNfse({
      endpointUrl,
      pfxPath: PFX_PATH,
      passphrase: PFX_PASSWORD,
      xmlGerarNfseEnvio: signed,
      versaoDados: NFSE_VERSAO_DADOS,
    });
    fs.writeFileSync(
      path.join(outDir, `04_http_${Date.now()}.txt`),
      String(resp.httpStatus),
      'utf8',
    );
    fs.writeFileSync(
      path.join(outDir, `05_soap_resp_${Date.now()}.xml`),
      String(resp.httpBody ?? ''),
      'utf8',
    );
    console.log('[6] OK. HTTP:', resp.httpStatus);

    // 7) outputXML
    console.log('[7] Extraindo outputXML...');
    const { outputXML } = extractOutputXML(String(resp.httpBody ?? ''));
    fs.writeFileSync(
      path.join(outDir, `06_outputXML_${Date.now()}.xml`),
      String(outputXML ?? ''),
      'utf8',
    );
    console.log('[7] OK. outputXML salvo.');

    console.log('✅ E2E concluído!');
  } catch (e) {
    console.error('❌ E2E falhou:', e?.message || e);
    process.exit(1);
  }
})();
