// src/services/biService.js
import api from "@/boot/axios";
import { yyyymmdd } from "@/utils/date"; // supondo que você já tem

export async function loadBi(
  procName,
  { cd_empresa, cd_segmento, dtIni, dtFim },
  cfg
) {
  const body = [
    {
      ic_json_parametro: "S",
      cd_empresa: cd_empresa || localStorage.cd_empresa || 0,
      cd_segmento: cd_segmento || null,
      dt_inicial: yyyymmdd(dtIni),
      dt_final: yyyymmdd(dtFim),
    },
  ];

  console.log("parametro bi", body, cfg, procName);
  
  const resp = await api.post(`/exec/${procName}`, body, cfg);
  return Array.isArray(resp?.data) ? resp.data : resp?.data?.rows || [];
}
