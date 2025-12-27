// scripts/update-build.js
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const envPath = path.join(root, '.env');
const metaPath = path.join(root, 'build-meta.json');

// lê o .env atual
let env = '';
if (fs.existsSync(envPath)) {
  env = fs.readFileSync(envPath, 'utf8');
}

// helpers
const pad2 = (n) => String(n).padStart(2, '0');
const pad3 = (n) => String(n).padStart(3, '0');

// data/hora atual
const now = new Date();

// --------------------
// 1) Build original: YYYY.MM.DD.HHMM
// --------------------
const build =
  `${now.getFullYear()}.` +
  `${pad2(now.getMonth() + 1)}.` +
  `${pad2(now.getDate())}.` +
  `${pad2(now.getHours())}${pad2(now.getMinutes())}`;
// exemplo: 2025.12.03.1932

// --------------------
// 2) APP_VERSION no formato: 5.12.05.001
//    - ano: último dígito (2025 -> 5)
//    - mês: 2 dígitos
//    - dia: 2 dígitos
//    - contador diário: 3 dígitos
// --------------------
const yearDigit = String(now.getFullYear()).slice(-1);
const month = pad2(now.getMonth() + 1);
const day = pad2(now.getDate());

// ler/atualizar contador diário
let meta = { lastDate: null, counter: 0 };
if (fs.existsSync(metaPath)) {
  try {
    meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
  } catch (e) {
    meta = { lastDate: null, counter: 0 };
  }
}
const dateKey = `${yearDigit}.${month}.${day}`;
if (meta.lastDate === dateKey) {
  meta.counter += 1;
} else {
  meta.lastDate = dateKey;
  meta.counter = 1;
}
fs.writeFileSync(metaPath, JSON.stringify(meta, null, 2), 'utf8');

//const appVersion = `${yearDigit}.${month}.${day}.${pad3(meta.counter)}`; // ex.: 5.12.05.001
const appVersion = `${yearDigit}.${month}.${pad3(meta.counter)}`;
// --------------------
// 3) Atualizar .env
// --------------------
const upsertEnv = (text, key, val) => {
  const re = new RegExp(`^${key}=.*`, 'm');
  if (re.test(text)) return text.replace(re, `${key}=${val}`);
  return `${text}${text.endsWith('\n') ? '' : '\n'}${key}=${val}\n`;
};

env = upsertEnv(env, 'VUE_APP_VERSION', appVersion);
env = upsertEnv(env, 'VUE_APP_BUILD', build);

fs.writeFileSync(envPath, env, 'utf8');

console.log('VUE_APP_VERSION atualizado para', appVersion);
console.log('VUE_APP_BUILD atualizado para', build);
