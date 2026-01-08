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
  if (!keyBag || !keyBag.key) throw new Error('Não foi possível extrair a chave do PFX.');

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

/**
 * Assina o nó que tiver atributo Id = <idValue>
 * Ex.: Id="RPS315"
 */
function signById(xmlString, pfxPath, passphrase, idValue) {
  const { privateKeyPem, certBase64 } = loadPfx(pfxPath, passphrase);
  const doc = new DOMParser().parseFromString(xmlString, 'text/xml');

  const node = xpath.select1(`//*[@Id='${idValue}']`, doc);
  if (!node) throw new Error(`Não encontrei nó com Id='${idValue}' para assinar.`);

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
  sig.computeSignature(xmlToSign, {
    location: { reference: `//*[@Id='${idValue}']`, action: 'append' },
  });

  return sig.getSignedXml();
}

module.exports = { signById };
