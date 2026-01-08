// scripts/gerar-api-key.js
const crypto = require('crypto');

function gerarApiKey() {
  // base64url é curta e segura (~43 chars)
  return crypto.randomBytes(32).toString('base64url');
}

function hashApiKey(apiKey) {
  // SHA-256 em HEX MAIÚSCULO — mesmo formato que usamos no DB
  return crypto.createHash('sha256').update(apiKey).digest('hex').toUpperCase();
}

const apiKey = gerarApiKey();
const apiKeyHash = hashApiKey(apiKey);

console.log('API_KEY_PURA=', apiKey);
console.log('API_KEY_HASH=', apiKeyHash);
