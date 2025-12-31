#!/usr/bin/env node
/**
 * Gera wrappers my_<id>.vue a partir de um template.
 *
 * Uso:
 *   node scripts/gen-menus.js --manifest src/menus/manifest.json --template src/menus/_template_my.vue --out src/menus
 *
 * Manifest (JSON) esperado:
 * [
 *   { "id": 9999, "name": "Meu menu 9999", "pageSize": 200 }
 * ]
 *
 * Campos aceitos:
 * - id (obrigatório)
 * - name (opcional) -> substitui MENU_TITLE
 * - pageSize (opcional) -> substitui gridPageSize no template (se detectar)
 *
 * Observação:
 * - não sobrescreve arquivo existente por padrão. Use --force para sobrescrever.
 */

const fs = require("fs");
const path = require("path");

function argValue(flag, def = null) {
  const idx = process.argv.indexOf(flag);
  if (idx >= 0 && process.argv[idx + 1]) return process.argv[idx + 1];
  return def;
}

const manifestPath = argValue("--manifest", "src/menus/manifest.json");
const templatePath = argValue("--template", "src/menus/_template_my.vue");
const outDir = argValue("--out", "src/menus");
const force = process.argv.includes("--force");

function die(msg) {
  console.error("[gen-menus] " + msg);
  process.exit(1);
}

function readJson(file) {
  const txt = fs.readFileSync(file, "utf8");
  return JSON.parse(txt);
}

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function safeFileName(id) {
  return `my_${id}.vue`;
}

function applyPageSize(vueText, pageSize) {
  if (!pageSize) return vueText;
  // troca a primeira ocorrência de "gridPageSize: <numero>"
  return vueText.replace(/gridPageSize:\s*\d+/m, `gridPageSize: ${pageSize}`);
}

function main() {
  if (!fs.existsSync(manifestPath)) die(`Manifest não encontrado: ${manifestPath}`);
  if (!fs.existsSync(templatePath)) die(`Template não encontrado: ${templatePath}`);

  const manifest = readJson(manifestPath);
  if (!Array.isArray(manifest)) die("Manifest deve ser um array JSON.");

  const template = fs.readFileSync(templatePath, "utf8");
  ensureDir(outDir);

  let created = 0;
  let skipped = 0;
  let overwritten = 0;

  for (const item of manifest) {
    const id = item.id ?? item.cd_menu ?? item.menu ?? null;
    if (!id) {
      console.warn("[gen-menus] Item sem id, pulando:", item);
      skipped++;
      continue;
    }

    const title = item.name || item.title || `Menu ${id}`;
    let content = template
      .replace(/MENU_ID/g, String(id))
      .replace(/MENU_TITLE/g, String(title).replace(/"/g, '\\"'));

    content = applyPageSize(content, item.pageSize);

    const filename = safeFileName(id);
    const filepath = path.join(outDir, filename);

    if (fs.existsSync(filepath) && !force) {
      console.log(`[gen-menus] EXISTS (skip): ${filepath}`);
      skipped++;
      continue;
    }

    if (fs.existsSync(filepath) && force) overwritten++;

    fs.writeFileSync(filepath, content, "utf8");
    created++;
    console.log(`[gen-menus] OK: ${filepath}`);
  }

  console.log(`\n[gen-menus] Finalizado. created=${created} skipped=${skipped} overwritten=${overwritten}`);
}

main();
