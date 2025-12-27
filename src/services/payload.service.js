// src/services/payload.service.js
import { api } from './http'

/** POST /payload-tabela */
/*pr_egis_payload_tabela --> com o cd_menu mostra todos o mapa de atributos para CRUD ou
                             consultas dinamicas
*/
                             
export async function payloadTabela(payload, opt = {}) {
                                                         //console.log('payload tabela --> ', payload);

                                                         const { data } = await api.post(
                                                           '/payload-tabela',
                                                           payload,
                                                           opt,
                                                         );
                                                         return data;
                                                       }

/** POST /tabela-registro-dados (retorna 1 registro) */
export async function tabelaRegistroDados(payload, opt = {}) {
  const { data } = await api.post('/tabela-registro-dados', payload, opt)
  return data
}
