// src/providers/giss/soap/gissClient.js
const fs = require('fs');
const path = require('path');
const https = require('https');
const axios = require('axios');

function stripXmlDeclaration(xml) {
  return String(xml)
    .replace(/^\s*<\?xml[^>]*\?>\s*/i, '')
    .trim();
}
function escapeXml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}
function ensureDir(p) {
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

function buildCabecMsgGiss({ versaoDados = '2.04' } = {}) {
  // ✅ importante: namespace GISS do cabeçalho (evita E183)
  return (
    `<cabecalho versao="${versaoDados}" xmlns="http://www.giss.com.br/cabecalho-v2_04.xsd">` +
    `<versaoDados>${versaoDados}</versaoDados>` +
    `</cabecalho>`
  );
}

function buildEnvelopeGerarNfse({ cabecMsgXml, dadosMsgXml }) {
  const cabecEsc = escapeXml(stripXmlDeclaration(cabecMsgXml));
  const dadosEsc = escapeXml(stripXmlDeclaration(dadosMsgXml));

  return (
    `<?xml version="1.0" encoding="utf-8"?>` +
    `<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://nfse.abrasf.org.br">` +
    `<soapenv:Body>` +
    `<ns1:GerarNfseRequest>` +
    `<nfseCabecMsg>${cabecEsc}</nfseCabecMsg>` +
    `<nfseDadosMsg>${dadosEsc}</nfseDadosMsg>` +
    `</ns1:GerarNfseRequest>` +
    `</soapenv:Body>` +
    `</soapenv:Envelope>`
  );
}

async function gerarNfseGiss({
  endpointUrl,
  pfxPath,
  passphrase,
  xmlGerarNfseEnvio,
  versaoDados = '2.04',
  outDir = path.join(process.cwd(), 'output_nfse'),
  timeoutMs = 60000,
}) {
  
  const cabec = buildCabecMsgGiss({ versaoDados });
  const env = buildEnvelopeGerarNfse({ cabecMsgXml: cabec, dadosMsgXml: xmlGerarNfseEnvio });

  ensureDir(outDir);
  const stamp = Date.now();
  fs.writeFileSync(path.join(outDir, `soap_req_${stamp}.xml`), env, 'utf8');

  const agent = new https.Agent({
    pfx: fs.readFileSync(pfxPath),
    passphrase,
    keepAlive: true,
    rejectUnauthorized: true,
  });

  const resp = await axios.post(endpointUrl, env, {
    httpsAgent: agent,
    timeout: timeoutMs,
    headers: {
      'Content-Type': 'text/xml; charset=utf-8',
      SOAPAction: '',
    },
    validateStatus: () => true,
  });

  fs.writeFileSync(path.join(outDir, `soap_resp_${stamp}.xml`), String(resp.data ?? ''), 'utf8');

  return { httpStatus: resp.status, httpBody: resp.data };
}

module.exports = { gerarNfseGiss };
