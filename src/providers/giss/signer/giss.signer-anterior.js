// src/modules/NFSe/providers/giss/signer.js
const fs = require('fs');
const forge = require('node-forge');
const { DOMParser, XMLSerializer } = require('@xmldom/xmldom');
const xpath = require('xpath');
const { SignedXml } = require('xml-crypto');

/**
 * Lê um PFX e retorna:
 * - privateKeyPem: chave privada em PEM
 * - certBase64: certificado X509 (conteúdo base64 SEM header/footer e sem quebras)
 */
function loadPfx(pfxPath, passphrase) {
  const pfxBuffer = fs.readFileSync(pfxPath);

  // node-forge trabalha com "binary string"
  const p12Der = forge.util.createBuffer(pfxBuffer.toString('binary'));
  const p12Asn1 = forge.asn1.fromDer(p12Der);
  const p12 = forge.pkcs12.pkcs12FromAsn1(p12Asn1, passphrase);

  // chave privada (pode estar em pkcs8ShroudedKeyBag ou keyBag)
  const keyBagsPkcs8 = p12.getBags({ bagType: forge.pki.oids.pkcs8ShroudedKeyBag })[
    forge.pki.oids.pkcs8ShroudedKeyBag
  ];

  const keyBagsKeyBag = p12.getBags({ bagType: forge.pki.oids.keyBag })[forge.pki.oids.keyBag];

  const keyBag = (keyBagsPkcs8 && keyBagsPkcs8[0]) || (keyBagsKeyBag && keyBagsKeyBag[0]);
  if (!keyBag || !keyBag.key) {
    throw new Error('Não foi possível extrair a chave privada do PFX.');
  }

  // certificado
  const certBags = p12.getBags({ bagType: forge.pki.oids.certBag })[forge.pki.oids.certBag];
  if (!certBags || !certBags[0] || !certBags[0].cert) {
    throw new Error('Não foi possível extrair o certificado do PFX.');
  }

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
 * Assina um XML do GerarNfseEnvio (GISS 2.04) assinando o nó:
 * //tipos:InfDeclaracaoPrestacaoServico[@Id]
 *
 * @param {string} xmlString XML original
 * @param {string} pfxPath caminho do .pfx
 * @param {string} passphrase senha do .pfx
 * @returns {string} XML assinado
 */

function signGerarNfseEnvio(xmlString, pfxPath, passphrase) {
  const { privateKeyPem, certBase64 } = loadPfx(pfxPath, passphrase);

  const doc = new DOMParser().parseFromString(xmlString, 'text/xml');

  // pega o Id automaticamente do primeiro nó que tiver atributo Id
  const anyIdNode = xpath.select1(`//*[@Id]`, doc);
  if (!anyIdNode) {
    throw new Error('Não encontrei nenhum nó com atributo Id para assinar.');
  }
  const idValue = anyIdNode.getAttribute('Id');

  // namespaces do layout GISS 2.04 (os mesmos do seu XML)
  const select = xpath.useNamespaces({
    nfse: 'http://www.giss.com.br/gerar-nfse-envio-v2_04.xsd',
    tipos: 'http://www.giss.com.br/tipos-v2_04.xsd',
    dsig: 'http://www.w3.org/2000/09/xmldsig#',
  });

  // nó a assinar

  // const inf = select('//tipos:InfDeclaracaoPrestacaoServico', doc)[0];
  //if (!inf) {
  //  throw new Error('Não encontrei o nó tipos:InfDeclaracaoPrestacaoServico para assinar.');
  // }

  const nodeToSign = xpath.select1(`//*[@Id='${idValue}']`, doc);
  if (!nodeToSign) {
    throw new Error(`Não encontrei o nó com Id='${idValue}' para assinar.`);
  }

  // const id = inf.getAttribute('Id');
  // if (!id) {
  //   throw new Error('O nó tipos:InfDeclaracaoPrestacaoServico não possui atributo Id.');
  // }

  // Se já houver assinatura anterior, remova (opcional)
  // Se já houver assinatura anterior dentro do nó assinado, remova (opcional)

  //const existingSig = select('.//dsig:Signature', nodeToSign)[0];
  //if (existingSig && existingSig.parentNode) {
  //  existingSig.parentNode.removeChild(existingSig);
  // }

  const sig = new SignedXml({
    privateKey: privateKeyPem,
    // Diz ao xml-crypto que o atributo que identifica o nó é "Id"
    idAttribute: 'Id',
  });

  // Muitos provedores NFSe ainda exigem SHA1
  sig.signatureAlgorithm = 'http://www.w3.org/2000/09/xmldsig#rsa-sha1';

  // O erro que você pegou: isso precisa estar definido
  sig.canonicalizationAlgorithm = 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315';

  // Reference ao nó pelo atributo Id (bem compatível)

  sig.addReference({
    xpath: `//*[@Id='${idValue}']`,
    transforms: [
      'http://www.w3.org/2000/09/xmldsig#enveloped-signature',
      'http://www.w3.org/TR/2001/REC-xml-c14n-20010315',
    ],
    digestAlgorithm: 'http://www.w3.org/2000/09/xmldsig#sha1',
  });

  // KeyInfo com certificado

  sig.getKeyInfoContent = () =>
    `<X509Data><X509Certificate>${certBase64}</X509Certificate></X509Data>`;

  // Serializa doc atual para assinar
  const xmlToSign = new XMLSerializer().serializeToString(doc);

  // força prefixo dsig:Signature (em vez de <Signature xmlns="...">)
  sig.signatureNamespacePrefix = 'dsig';

  sig.computeSignature(xmlToSign, {
    // insere a assinatura como "irmã" do nó assinado (depois dele)
    location: { reference: `//*[@Id='${idValue}']`, action: 'after' },
  });

   let signedXml = sig.getSignedXml();

   // 1) Garante prefixo dsig no nó Signature
   signedXml = signedXml
     // abertura: <Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
     .replace(
       /<Signature xmlns="http:\/\/www\.w3\.org\/2000\/09\/xmldsig#">/g,
       '<dsig:Signature xmlns:dsig="http://www.w3.org/2000/09/xmldsig#">',
     )
     // fechamento: </Signature>
     .replace(/<\/Signature>/g, '</dsig:Signature>');

   // 2) Prefixa os filhos mais comuns (pra não ficar misturado)
   // (isso evita o schema reclamar do conteúdo do Signature)
   signedXml = signedXml
     .replace(/<SignedInfo>/g, '<dsig:SignedInfo>')
     .replace(/<\/SignedInfo>/g, '</dsig:SignedInfo>')
     .replace(/<CanonicalizationMethod /g, '<dsig:CanonicalizationMethod ')
     .replace(/<\/CanonicalizationMethod>/g, '</dsig:CanonicalizationMethod>')
     .replace(/<SignatureMethod /g, '<dsig:SignatureMethod ')
     .replace(/<\/SignatureMethod>/g, '</dsig:SignatureMethod>')
     .replace(/<Reference /g, '<dsig:Reference ')
     .replace(/<\/Reference>/g, '</dsig:Reference>')
     .replace(/<Transforms>/g, '<dsig:Transforms>')
     .replace(/<\/Transforms>/g, '</dsig:Transforms>')
     .replace(/<Transform /g, '<dsig:Transform ')
     .replace(/<\/Transform>/g, '</dsig:Transform>')
     .replace(/<DigestMethod /g, '<dsig:DigestMethod ')
     .replace(/<\/DigestMethod>/g, '</dsig:DigestMethod>')
     .replace(/<DigestValue>/g, '<dsig:DigestValue>')
     .replace(/<\/DigestValue>/g, '</dsig:DigestValue>')
     .replace(/<SignatureValue>/g, '<dsig:SignatureValue>')
     .replace(/<\/SignatureValue>/g, '</dsig:SignatureValue>')
     .replace(/<KeyInfo>/g, '<dsig:KeyInfo>')
     .replace(/<\/KeyInfo>/g, '</dsig:KeyInfo>')
     .replace(/<X509Data>/g, '<dsig:X509Data>')
     .replace(/<\/X509Data>/g, '</dsig:X509Data>')
     .replace(/<X509Certificate>/g, '<dsig:X509Certificate>')
     .replace(/<\/X509Certificate>/g, '</dsig:X509Certificate>');

   // 3) (Opcional) remove o xmlns default antigo se sobrar em algum lugar
   // signedXml = signedXml.replace(/xmlns="http:\/\/www\.w3\.org\/2000\/09\/xmldsig#"/g, '');

   return signedXml;


  //return sig.getSignedXml();

}

module.exports = { signGerarNfseEnvio };
