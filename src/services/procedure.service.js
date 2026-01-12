import api from "@/boot/axios";

let PROC = "";

export async function executarProcesso({
  cd_parametro,
  cd_usuario,
  cd_empresa,
  dados_modal = {},
  dados_registro = [],
  extra = {},
  procedure
}) {

  PROC = procedure ? "/exec/" + procedure : "";
  
  const payload = [
    {
      ic_json_parametro: "S",
      cd_parametro,
      cd_usuario: Number(cd_usuario ?? localStorage.cd_usuario ?? 0),
      cd_empresa: Number(cd_empresa ?? localStorage.cd_empresa ?? 0),
      dados_modal,
      dados_registro,
      ...extra,
    },
  ];

  console.log('proposta', PROC, payload)

  const resp = await api.post(PROC, payload);
  const data = resp?.data ?? resp;
  return Array.isArray(data) ? data : data?.recordset || data?.rows || [];
}
