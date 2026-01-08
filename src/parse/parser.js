const { XMLParser } = require('fast-xml-parser');

const parser = new XMLParser({
  ignoreAttributes: false,
  attributeNamePrefix: '@_',
  removeNSPrefix: true,
  trimValues: true,
});

function extractOutputXML(soapXml) {
  const obj = parser.parse(soapXml);
  const body = obj?.Envelope?.Body || obj?.envelope?.body || obj?.Body;
  if (!body) return { parsedSoap: obj, outputXML: null };
  const respKey = Object.keys(body).find((k) => /Response$/i.test(k));
  const respNode = respKey ? body[respKey] : null;
  const outputXML = respNode?.outputXML ?? respNode?.OutputXML ?? null;
  return { parsedSoap: obj, outputXML };
}

module.exports = { extractOutputXML };
