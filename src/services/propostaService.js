import api from "@/boot/axios";

const PROC = "/exec/pr_egis_proposta_processo_modulo";

export async function executarParametro({
  cd_parametro,
  dados_modal = {},
  dados_registro = [],
  extra = {},
}) {
  const payload = [
    {
      ic_json_parametro: 'S',
      cd_parametro,
      cd_usuario: Number(localStorage.cd_usuario || 0),
      cd_empresa: Number(localStorage.cd_empresa || 0),
      dados_modal,
      dados_registro,
      ...extra,
    },
  ];

  //console.log('proposta', PROC, payload)

  const resp = await api.post(PROC, payload);
  const data = resp?.data ?? resp;
  return Array.isArray(data) ? data : data?.recordset || data?.rows || [];
}
