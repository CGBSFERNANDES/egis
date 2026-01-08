// src/soap/abrasfClient.js
const fs = require('fs');
const path = require('path');
const { soapPost } = require('./httpSoapClient');

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

function buildCabecMsg({ versaoDados = '2.04' } = {}) {
  // Cabeçalho no padrão GISS 2.04 (muito comum no giss.com.br)
  return (
    `<cabecalho versao="${versaoDados}" xmlns="http://www.giss.com.br/cabecalho-v2_04.xsd">` +
    `<versaoDados>${versaoDados}</versaoDados>` +
    `</cabecalho>`
  );
}

function buildCabecMsgOld({ versaoDados = '2.04' } = {}) {
  return (
    `<cabecalho versao="${versaoDados}" xmlns="http://www.abrasf.org.br/nfse.xsd">` +
    `<versaoDados>${versaoDados}</versaoDados>` +
    `</cabecalho>`
  );
}

// namespace padrão ABRASF
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

async function gerarNfse({
  endpointUrl,
  pfxPath,
  passphrase,
  xmlGerarNfseEnvio,
  versaoDados = '2.04',
  outDir = path.join(process.cwd(), 'output_nfse'),
}) {
  const cabec = buildCabecMsg({ versaoDados });
  const dados = stripXmlDeclaration(xmlGerarNfseEnvio);

  const envelope = buildEnvelopeGerarNfse({
    cabecMsgXml: cabec,
    dadosMsgXml: dados,
  });

  ensureDir(outDir);
  const stamp = Date.now();
  fs.writeFileSync(path.join(outDir, `soap_req_${stamp}.xml`), envelope, 'utf8');

  const resp = await soapPost({
    url: endpointUrl,
    xmlEnvelope: envelope,
    pfxPath,
    passphrase,
  });

  fs.writeFileSync(path.join(outDir, `soap_resp_${stamp}.xml`), String(resp.data ?? ''), 'utf8');

  return {
    httpStatus: resp.status,
    httpBody: resp.data,
    requestXml: envelope,
  };
}

module.exports = { gerarNfse };
