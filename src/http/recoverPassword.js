import { http } from "./api";

export default {
  solicitar(payload) {
    // POST é obrigatório (não usar GET com identificador em URL)
    return http.post("/password/recover", payload);
  },
};
