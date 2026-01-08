// src/soap/httpSoapClient.js
const https = require('https');
const fs = require('fs');
const axios = require('axios');

function makeAgentPfx(pfxPath, passphrase) {
  return new https.Agent({
    pfx: fs.readFileSync(pfxPath),
    passphrase,
    keepAlive: true,
    rejectUnauthorized: true,
  });
}

async function soapPost({ url, xmlEnvelope, pfxPath, passphrase, timeoutMs = 60000 }) {
  const httpsAgent = makeAgentPfx(pfxPath, passphrase);

  const resp = await axios.post(url, xmlEnvelope, {
    httpsAgent,
    timeout: timeoutMs,
    headers: {
      'Content-Type': 'text/xml; charset=utf-8',
      SOAPAction: '',
    },
    validateStatus: () => true,
  });

  return resp;
}

module.exports = { soapPost };
