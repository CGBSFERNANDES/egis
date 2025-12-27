// scripts/update-build.js
const fs = require('fs')
const path = require('path')

const envPath = path.join(__dirname, '..', '.env')

// lê o .env atual
let env = fs.readFileSync(envPath, 'utf8')

// gera um código de build baseado na data/hora
const now = new Date()

const pad2 = n => String(n).padStart(2, '0')

const build =
  `${now.getFullYear()}.` +
  `${pad2(now.getMonth() + 1)}.` +
  `${pad2(now.getDate())}.` +
  `${pad2(now.getHours())}${pad2(now.getMinutes())}`
// exemplo: 2025.12.02.1435

// atualiza (ou cria) a linha VUE_APP_BUILD
if (/^VUE_APP_BUILD=.*/m.test(env)) {
  env = env.replace(/^VUE_APP_BUILD=.*/m, `VUE_APP_BUILD=${build}`)
} else {
  env += `\nVUE_APP_BUILD=${build}`
}

// grava de volta o .env
fs.writeFileSync(envPath, env, 'utf8')

console.log('VUE_APP_BUILD atualizado para', build)
