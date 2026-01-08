// scripts/gerar_xml_db.js
require('dotenv').config();
const fs = require('fs');
const path = require('path');

const { getNotaByCdNotaSaida } = require('../src/repos/nfseRepo');
const { mapDbToGissModel } = require('../giss.mapper'); // seu mapper :contentReference[oaicite:1]{index=1}
const { buildGerarNfseEnvioXml } = require('../xmlBuilder'); // seu builder :contentReference[oaicite:2]{index=2}

(async () => {
  const cd = Number(process.argv[2]);
  if (!Number.isFinite(cd)) {
    console.log('Uso: node scripts/gerar_xml_db.js <cd_nota_saida>');
    process.exit(2);
  }

  const { headerRow, itemRows } = await getNotaByCdNotaSaida(cd);

  const model = mapDbToGissModel({ headerRow, itemRows });
  const xml = buildGerarNfseEnvioXml(model);

  const outDir = path.join(process.cwd(), 'output_nfse');
  fs.mkdirSync(outDir, { recursive: true });

  const outPath = path.join(outDir, `gerar_nfse_envio_${cd}_${Date.now()}.xml`);
  fs.writeFileSync(outPath, xml, 'utf8');

  console.log('✅ XML gerado:', outPath);
})();
