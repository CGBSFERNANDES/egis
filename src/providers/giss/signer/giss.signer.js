// src/providers/giss/signer/giss.signer.js
const fs = require('fs');
const forge = require('node-forge');
const { DOMParser, XMLSerializer } = require('@xmldom/xmldom');
const xpath = require('xpath');
const { SignedXml } = require('xml-crypto');

function loadPfx(pfxPath, passphrase) {
  const pfxBuffer = fs.readFileSync(pfxPath);
  const p12Der = forge.util.createBuffer(pfxBuffer.toString('binary'));
  const p12Asn1 = forge.asn1.fromDer(p12Der);
  const p12 = forge.pkcs12.pkcs12FromAsn1(p12Asn1, passphrase);

  const keyBagsPkcs8 = p12.getBags({ bagType: forge.pki.oids.pkcs8ShroudedKeyBag })[
    forge.pki.oids.pkcs8ShroudedKeyBag
  ];
  const keyBagsKeyBag = p12.getBags({ bagType: forge.pki.oids.keyBag })[forge.pki.oids.keyBag];
  const keyBag = (keyBagsPkcs8 && keyBagsPkcs8[0]) || (keyBagsKeyBag && keyBagsKeyBag[0]);
  if (!keyBag || !keyBag.key) throw new Error('Não foi possível extrair a chave privada do PFX.');

  const certBags = p12.getBags({ bagType: forge.pki.oids.certBag })[forge.pki.oids.certBag];
  if (!certBags || !certBags[0] || !certBags[0].cert)
    throw new Error('Não foi possível extrair o certificado do PFX.');

  const privateKeyPem = forge.pki.privateKeyToPem(keyBag.key);
  const certPem = forge.pki.certificateToPem(certBags[0].cert);
  const certBase64 = certPem
    .replace('-----BEGIN CERTIFICATE-----', '')
    .replace('-----END CERTIFICATE-----', '')
    .replace(/\r?\n|\r/g, '')
    .trim();

  return { privateKeyPem, certBase64 };
}

// força <dsig:Signature xmlns:dsig="..." xmlns="..."> ... </dsig:Signature>
function forceDsigPrefix(xmlString) {
  // troca a abertura
  xmlString = xmlString.replace(
    /<Signature xmlns="http:\/\/www\.w3\.org\/2000\/09\/xmldsig#">/g,
    '<dsig:Signature xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns="http://www.w3.org/2000/09/xmldsig#">',
  );
  // troca fechamento
  xmlString = xmlString.replace(/<\/Signature>/g, '</dsig:Signature>');
  return xmlString;
}

function signGerarNfseEnvio(xmlString, pfxPath, passphrase) {
  const { privateKeyPem, certBase64 } = loadPfx(pfxPath, passphrase);

  const doc = new DOMParser().parseFromString(xmlString, 'text/xml');

  // pega o primeiro nó com Id (deve ser o InfDeclaracaoPrestacaoServico)
  const anyIdNode = xpath.select1(`//*[@Id]`, doc);
  if (!anyIdNode) throw new Error('Não encontrei nenhum nó com atributo Id para assinar.');
  const idValue = anyIdNode.getAttribute('Id');

  const select = xpath.useNamespaces({
    dsig: 'http://www.w3.org/2000/09/xmldsig#',
  });

  // remove assinatura anterior (se existir) no documento todo
  const existingSig = select(`//dsig:Signature`, doc)[0];
  if (existingSig && existingSig.parentNode) existingSig.parentNode.removeChild(existingSig);

  const sig = new SignedXml({
    privateKey: privateKeyPem,
    idAttribute: 'Id',
  });

  sig.signatureAlgorithm = 'http://www.w3.org/2000/09/xmldsig#rsa-sha1';
  sig.canonicalizationAlgorithm = 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315';

  sig.addReference({
    xpath: `//*[@Id='${idValue}']`,
    transforms: [
      'http://www.w3.org/2000/09/xmldsig#enveloped-signature',
      'http://www.w3.org/TR/2001/REC-xml-c14n-20010315',
    ],
    digestAlgorithm: 'http://www.w3.org/2000/09/xmldsig#sha1',
  });

  sig.getKeyInfoContent = () =>
    `<X509Data><X509Certificate>${certBase64}</X509Certificate></X509Data>`;

  const xmlToSign = new XMLSerializer().serializeToString(doc);

  // ✅ INSERE a assinatura como IRMÃ (after) do nó Id=RPS1
  sig.computeSignature(xmlToSign, {
    location: { reference: `//*[@Id='${idValue}']`, action: 'after' },
  });

  // força prefixo dsig e default ns conforme costuma vir nos exemplos GISS
  return forceDsigPrefix(sig.getSignedXml());
}

module.exports = { signGerarNfseEnvio };
