//import { carregarFormularioSPA } from "./carregar-formulario-spa.js";
//import { saveAs } from "file-saver";

let gridInstanceGlobal = null;

export function getCdMenuAtual() {
  const cdMenuPai = sessionStorage.getItem("cd_menu");
  const cdMenuDetalhe = sessionStorage.getItem(`cd_menu_detalhe_${cdMenuPai}`);
  return parseInt(cdMenuDetalhe || cdMenuPai);
}

export function abrirPesquisaDinamica(nomeCampo, cd_menu_pesquisa) {

  setTimeout(() => {
    const url = `/form-especial/FormEspecial.html?modo=pesquisa&cd_menu=${cd_menu_pesquisa}&campo=${nomeCampo}`;
    const novaAba = window.open(url, "_blank");

    if (!novaAba) {
      alert("⚠️ Permita pop-ups para abrir a pesquisa.");
    }
  }, 100);
}


export function montarPayloadEnvio(cd_parametro_form) {

  const container = document.getElementById("formulario-dinamico") ||
    document.getElementById("conteudoModal") ||
    document.getElementById("camposDinamicosModal") ||
    document.getElementById("abasCadastroContent") ||
    document.getElementById("modalCadastro");
  //console.log(container);

  if (!container) {
    console.warn("❌ Container do modal não encontrado.");
    return {};
  }

  //console.log('Montando');
  const cd_menu = getCdMenuAtual();
  const inputs = container.querySelectorAll("input, select");

  //const registroOriginal = JSON.parse(sessionStorage.getItem("registro_original") || "{}");
  //const mapa = JSON.parse(sessionStorage.getItem("mapa_consulta_para_atributo") || "{}");
  const registroBruto = JSON.parse(sessionStorage.getItem("registro_original") || "{}");
  const mapa = JSON.parse(sessionStorage.getItem("mapa_consulta_para_atributo") || "{}");

  const registroOriginal = {};

  for (const [chaveConsulta, valor] of Object.entries(registroBruto)) {
    const chaveReal = mapa[chaveConsulta] || chaveConsulta;
    registroOriginal[chaveReal] = valor;
  }


  let payload = {
    cd_menu, //sessionStorage.getItem("cd_menu"),
    cd_form: sessionStorage.getItem("cd_form"),
    cd_parametro_form,
    cd_usuario: sessionStorage.getItem("cd_usuario"),
    cd_cliente_form: "0",
    cd_contato_form: "",
    dt_usuario: new Date().toISOString(),
    lookup_formEspecial: {},
    detalhe: [],
    lote: [],
    cd_modulo: "",
    cd_documento_form: "0"
  };

  // Inclusão

  if (cd_parametro_form === 1) {
    inputs.forEach(input => {
      if (input.name) {
        if (input.value === '*') {
          payload[input.name] = "0";
        } else {
          payload[input.name] = input.value;
        }
      }
    });

  } else {
    // Alteração ou exclusão
    const valores = {};
    inputs.forEach(input => {
      if (input.name) {
        valores[input.name] = input.value;
      }
    });

    // aplica alterações sobre o original
    const dadosAtualizados = { ...registroOriginal, ...valores };
    //


    // buscar qual é o campo-chave
    const payloadBase = JSON.parse(sessionStorage.getItem("payload_padrao_formulario") || "[]");
    const campoChave = payloadBase.find(c => c.ic_atributo_chave === "S");
    const chaveAtributo = campoChave?.nm_atributo;


    return {
      ...payload,
      ...dadosAtualizados,
      cd_documento_form: dadosAtualizados[chaveAtributo] || "0"


    };
  }

  return payload;

}
/*
payload = {
  ...payload,
  ...registroOriginal,
  cd_documento_form: sessionStorage.getItem("cd_controle_operacao") || 0       
};
*/

//console.log('1-',payload);
//console.log('2-',registroOriginal);

//return payload;



export function montarPayloadEnvioNovo(cd_parametro_form) {
  //console.log('EnvioNovo');
  return montarPayloadEnvio(cd_parametro_form);
}

export async function enviarPayloadParaAPI(payload) {
  try {
    const res = await fetch("/api/api-dados-form", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    const resultado = await res.json();
    //alert("✅ Operação realizada com sucesso!");
    return resultado;
  } catch (err) {
    console.error("❌ Erro ao enviar para API:", err);
    alert("Erro ao tentar salvar os dados.");
  }
}


function montarRegistroOriginal(registroBruto, payload) {
  const mapa = {};

  // Monta o mapa de atributos de consulta → atributos reais
  for (const campo of payload) {
    if (campo.nm_atributo_consulta && campo.nm_atributo) {
      mapa[campo.nm_atributo_consulta] = campo.nm_atributo;
    }
  }

  const registroOriginal = {};

  // Mapeia os valores do resultado para os nomes reais
  for (const [chaveConsulta, valor] of Object.entries(registroBruto)) {
    const chaveReal = mapa[chaveConsulta] || chaveConsulta;
    registroOriginal[chaveReal] = valor;
  }

  // ✅ Insere a chave estrangeira (id_pai) se for detalhe
  const cdMenu = sessionStorage.getItem("cd_menu");
  const idPai = sessionStorage.getItem(`id_pai_detalhe_${cdMenu}`);
  if (idPai) {
    const campoChave = payload.find(c => c.ic_chave_estrangeira === "S");
    if (campoChave) {
      registroOriginal[campoChave.nm_atributo] = idPai;
    }
  }

  return registroOriginal;
}

//Salvar Local os dados dos forms

// 💾 Salva um formulário completo localmente com base no cd_menu
export function salvarFormularioLocal(cd_menu, dadosPorAba) {
  if (!cd_menu || typeof dadosPorAba !== "object") {
    console.warn("❌ Dados inválidos para salvar local.");
    return;
  }

  const chave = `form_${cd_menu}`;
  localStorage.setItem(chave, JSON.stringify({
    cd_menu,
    ...dadosPorAba
  }));

}

// 📥 Carrega um formulário salvo anteriormente no localStorage

export function carregarFormularioLocal(cd_menu) {
  const chave = `form_${cd_menu}`;
  const data = localStorage.getItem(chave);

  // console.log('formulario',data);

  if (!data) return null;

  return JSON.parse(data);
}

export function coletarCamposDasAbasX(payload) {
  const resultado = {};
  const abas = payload.sqlTabs || [];

  abas.forEach(aba => {
    const abaId = `aba_${aba.cd_tabsheet}`;
    const abaDiv = document.getElementById(abaId);
    if (!abaDiv) return;

    const inputs = abaDiv.querySelectorAll("input, select, textarea");
    const dados = {};

    inputs.forEach(input => {
      if (input.name) {
        dados[input.name] = input.value;
      }
    });

    resultado[abaId] = dados;
  });

  return resultado;
}


export function coletarCamposDasAbas(payload) {
  const dados = {};

  if (!Array.isArray(payload.campos)) return dados;

  const abas = [...new Set(payload.campos.map(c => c.cd_tabsheet))];

  abas.forEach(cd_tabsheet => {
    const abaKey = `aba_${cd_tabsheet}`;
    dados[abaKey] = {};

    const camposDaAba = payload.campos.filter(c => c.cd_tabsheet === cd_tabsheet && c.ic_formulario === "S");

    camposDaAba.forEach(campo => {
      const el = document.getElementById(campo.nm_atributo);
      if (el) {
        dados[abaKey][campo.nm_atributo] = el.value;
      }
    });
  });

  return dados;
}

///


export function montarPayloadEnvioTabs(payloadOriginal) {
  const cd_menu = parseInt(sessionStorage.getItem("cd_menu"));
  const cd_usuario = parseInt(sessionStorage.getItem("cd_usuario") || 0);

  if (!payloadOriginal || !Array.isArray(payloadOriginal.campos)) {
    alert("❌ Campos inválidos no payload.");
    return {};
  }

  const dados = {};
  const campos = payloadOriginal.campos;

  const tabs = [...new Set(campos.map(c => c.cd_tabsheet))];

  tabs.forEach(cd_tabsheet => {
    const key = `aba_${cd_tabsheet}`;
    dados[key] = {};

    campos
      .filter(c => c.cd_tabsheet === cd_tabsheet && c.ic_formulario === "S")
      .forEach(campo => {
        const el = document.getElementById(campo.nm_atributo);
        if (el) {
          let valor = el.value;

          // ✅ Limpa valores com "| descrição"
          if (typeof valor === "string" && valor.includes("|")) {
            valor = valor.split("|")[0].trim();
          }

          dados[key][campo.nm_atributo] = valor;
        }
      });
  });

  // ✅ Inclui itens (aba2), se existir
  dados.aba2 = window.listaItens || [];

  return {
    cd_menu,
    cd_usuario,
    dados
  };
}

////

export async function validarCampoDinamico(input) {
  const valor = input.value.trim();
  const nomeCampo = input.name;

  const inputDescricao = document.querySelector(`[name='${nomeCampo}_descricao']`);
  const payload = JSON.parse(sessionStorage.getItem("payload_padrao_formulario") || "[]");
  const campo = payload.find(c => c.nm_atributo === nomeCampo);


  if (!campo || !campo.ds_atributo_validacao || !valor) {
    if (inputDescricao) inputDescricao.value = "";
    return;
  }

  // Monta o SQL de validação
  const sql = campo.ds_atributo_validacao.replace(
    new RegExp("@" + campo.nm_atributo, "g"),
    `'${valor}'`
  );

  try {
    const res = await fetch("/api/validar-script", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ script: sql })
    });

    const dados = await res.json();

    if (!Array.isArray(dados) || dados.length === 0) {
      alert(`⚠️ ${campo.ds_atributo || nomeCampo} não está cadastrado!`);
      input.value = "";
      if (inputDescricao) inputDescricao.value = "";
      input.focus();
      input.select();
      return;
    }

    // ✅ Campo código: mantém apenas o valor digitado
    input.value = valor;

    const linha = dados[0];

    // 🔍 Busca inteligente da descrição
    const chaveDescricao =
      campo.nm_atributo_consulta ||
      "descricao";

    const descricao =
      linha[chaveDescricao] ||
      linha.descricao ||
      linha.label ||
      Object.entries(linha).find(
        ([chave, val]) =>
          typeof val === "string" &&
          val !== valor &&
          chave.toLowerCase().includes("descricao")
      )?.[1] ||
      Object.values(linha).find(
        val => typeof val === "string" && val !== valor && val.length > 2
      ) || "";

    if (inputDescricao) {
      inputDescricao.value = descricao;
    }

    // ✅ Preenche outras descrições no mesmo container (se houver)
    const container = input.closest(".input-group")?.parentElement || input.parentElement;

    Object.entries(linha).forEach(([chave, val]) => {
      if (chave === nomeCampo) return;

      let inputDesc = document.getElementById(`desc_${chave}`) ||
        document.querySelector(`[name='${chave}_descricao']`);

      if (!inputDesc && chave === campo.nm_atributo_consulta) {
        inputDesc = document.createElement("input");
        inputDesc.type = "text";
        inputDesc.className = "form-control mt-2";
        inputDesc.name = `${nomeCampo}_descricao`;
        inputDesc.readOnly = true;
        inputDesc.placeholder = `Descrição`;
        container.appendChild(inputDesc);
      }

      if (inputDesc) {
        inputDesc.value = val || "";
      }

      // inputDesc.value = val || "";


    });

    console.log("✅ Retorno aplicado com sucesso (blur):", {

      campo: nomeCampo,
      valor,
      descricao,
      linha
    });

  } catch (err) {
    console.error("Erro ao validar:", err);
    alert("❌ Erro ao validar o campo.");
  }
}



///

export async function validarCampoDinamicoxxxx(input) {

  const valor = input.value.trim();
  const nomeCampo = input.name;
  const inputDescricao = document.querySelector(`[name='${nomeCampo}_descricao']`);
  const payload = JSON.parse(sessionStorage.getItem("payload_padrao_formulario") || "[]");
  const campo = payload.find(c => c.nm_atributo === nomeCampo);

  if (!campo || !campo.ds_atributo_validacao || !valor) {
    if (inputDescricao) inputDescricao.value = "";
    return;
  }

  const sql = campo.ds_atributo_validacao.replace(new RegExp("@" + campo.nm_atributo, "g"), `'${valor}'`);


  try {
    const res = await fetch("/api/validar-script", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ script: sql })
    });

    const dados = await res.json();

    if (!Array.isArray(dados) || dados.length === 0) {
      alert(`⚠️ ${campo.ds_atributo || nomeCampo} não está cadastrado!`);
      input.value = "";
      if (inputDescricao) inputDescricao.value = "";
      input.focus();
      input.select();
      return;
    }

    // Atualiza campo de código com "valor | descrição"


    if (input) {
      const tipo = input.type;
      const descricao = dados[0].descricao || dados[0].label || Object.values(dados[0]).find(v => typeof v === "string" && v.length > 2);
      input.value = valor; // ✅ Apenas o código puro

      // if (["text", "search", ""].includes(tipo)) {
      //input.value = descricao ? `${valor} | ${descricao}` : valor;
      //} else {
      //  input.value = valor;
      // }

    }

    // Atualiza campo de descrição (nome_cliente, etc)
    const container = input.closest(".input-group")?.parentElement || input.parentElement;

    Object.entries(dados[0]).forEach(([chave, val]) => {
      if (chave === nomeCampo) return;

      let inputDesc = document.getElementById(`desc_${chave}`) ||
        document.querySelector(`[name='${chave}_descricao']`);

      if (!inputDesc) {
        inputDesc = document.createElement("input");
        inputDesc.type = "text";
        inputDesc.className = "form-control mt-2";
        inputDesc.id = `desc_${chave}`;
        inputDesc.readOnly = true;
        inputDesc.placeholder = `Descrição de ${chave}`;
        container.appendChild(inputDesc);
      }

      inputDesc.value = val || "";

    });

  } catch (err) {
    console.error("Erro ao validar:", err);
    alert("❌ Erro ao validar o campo.");
  }
}



///

export function confirmarRetornoPesquisa() {
  const campo = new URLSearchParams(location.search).get("campo");
  const cd_menu_pesquisa = new URLSearchParams(location.search).get("cd_menu");

  const registroSelecionado = JSON.parse(sessionStorage.getItem(`registro_selecionado_${cd_menu_pesquisa}`) || "{}");
  const camposMeta = JSON.parse(sessionStorage.getItem("campos_grid_meta") || "[]");

  if (!campo || !registroSelecionado || Object.keys(registroSelecionado).length === 0) {
    console.warn("⚠️ Dados inválidos ou nenhum registro selecionado.");
    return;
  }

  // 🧠 Corrige valor do campo principal (ex: cd_cliente)
  //let valor = registroSelecionado[campo];

  // NOVO BLOCO mais robusto
  const chaveMeta = camposMeta.find(c => c.ic_atributo_chave === "S");
  const chaveConsulta = chaveMeta?.nm_titulo_menu_atributo;

  let valor = "";

  if (chaveConsulta && registroSelecionado[chaveConsulta] !== undefined) {
    valor = registroSelecionado[chaveConsulta];
  } else {
    const tentativa = Object.entries(registroSelecionado).find(([key]) =>
      key.toLowerCase().includes(campo.toLowerCase())
    );
    if (tentativa) valor = tentativa[1];
  }

  if (valor === undefined) {
    const tentativa = Object.entries(registroSelecionado).find(([key]) =>
      key.toLowerCase().includes(campo.toLowerCase())
    );
    if (tentativa) valor = tentativa[1];
  }

  // 🧠 Usa apenas campos com ic_retorno_atributo === "S"
  /*
  const descricao = camposMeta
    .filter(c => c.ic_retorno_atributo === "S")
    .map(c => {
      const nomeDescricao = c.nm_campo_mostra_combo_box || c.nm_atributo_consulta;
      return {
        campo: nomeDescricao,
        valor: registroSelecionado[nomeDescricao]
      };
    });

  */
  const descricao = camposMeta
    .filter(c => c.ic_retorno_atributo === "S")
    .map(c => {
      const nomeDescricao =
        c.nm_campo_mostra_combo_box?.trim() ||
        c.nm_atributo_consulta?.trim() ||
        c.nm_atributo?.trim();

      // 🚨 Aplica busca segura no registro selecionado
      let valorDescricao = registroSelecionado[nomeDescricao];

      // 🔁 Se não encontrar, faz uma busca esperta
      if (!valorDescricao) {
        const tentativa = Object.entries(registroSelecionado).find(
          ([k, v]) =>
            typeof v === "string" &&
            v.length > 1 &&
            (
              k.toLowerCase().includes("descricao") ||
              k.toLowerCase().includes("nome") ||
              k.toLowerCase().includes("cidade") ||
              k.toLowerCase().includes("label")
            )
        );
        valorDescricao = tentativa?.[1] || "";
      }

      return {
        campo: nomeDescricao,
        valor: valorDescricao
      };
    });




  const retorno = {
    campo,
    valor,
    descricao
  };

  // ✅ Envia direto se possível
  if (window.opener && typeof window.opener.aplicarRetornoPesquisaDireto === "function") {
    window.opener.aplicarRetornoPesquisaDireto(retorno);
    window.close();
  } else {
    localStorage.setItem("retornoPesquisa", JSON.stringify(retorno));
    window.close();
  }
}


///


export function salvarOrigemNavegacao(nome, dados = {}) {
  sessionStorage.setItem("origem_nome", nome);
  sessionStorage.setItem(`origem_dados_${nome}`, JSON.stringify(dados));
}

export function voltarParaOrigem() {

  const nome = sessionStorage.getItem("origem_nome");
  const origem = sessionStorage.getItem("origem_navegacao");

  if (!nome) return history.back();

  const dados = JSON.parse(sessionStorage.getItem(`origem_dados_${nome}`) || "{}");

  const kanbanView = document.getElementById("kanban-view");
  if (kanbanView) kanbanView.classList.remove("modo-fullscreen");


  // if (origem && origem.includes("modulo")) {
  //    voltarParaModuloStart();
  //// } else {
  // history.back(); // fallback SPA-safe
  //}

  if (origem?.startsWith("form:")) {
    const form = origem.split(":")[1];
    const titulo = sessionStorage.getItem("menu_titulo") || "Formulário";
    carregarFormularioSPA(form, titulo);
    return;
  }

  if (nome === "modulo") {
    sessionStorage.setItem("restaurar_modulo_apos_voltar", dados.cd_modulo);
    window.location.href = "/index.html";
    return;
  }

  if (nome === "dashboard") {
    // Customize se quiser abrir uma rota ou aba específica
    window.location.href = "/dashboard.html";
    return;
  }

  if (nome === "catalogo") {
    window.location.href = "/index.html";
    // Ou abrir diretamente a lógica de catálogo se estiver integrado
    return;
  }

  history.back(); // fallback

}


////
export async function validarCampoDinamicoForm(input) {
  const valor = input.value?.trim();
  const nomeCampo = input.name || input.id;

  const abaAtiva = document.querySelector(".tab-pane.active");
  const cd_menu = sessionStorage.getItem(`cd_menu_detalhe_${abaAtiva?.id}`) || sessionStorage.getItem("cd_menu");

  const payloadStr = sessionStorage.getItem(`payload_padrao_formulario_${cd_menu}`);
  const payload = JSON.parse(payloadStr || "[]");

  const campo = payload.find(c => c.nm_atributo === nomeCampo);
  if (!campo || !campo.ds_atributo_validacao || !valor) return;

  const sql = campo.ds_atributo_validacao.replaceAll(`@${campo.nm_atributo}`, `'${valor}'`);

  try {
    const res = await fetch("/api/validar-script", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ script: sql })
    });

    const dados = await res.json();
    const resultado = dados?.[0];

    // 🔴 Código inválido: limpa input + descrição
    if (!resultado) {
      alert(`⚠️ Código inválido para ${campo.ds_atributo || nomeCampo}`);
      input.value = "";
      const descInput = document.getElementById(`desc_${campo.nm_campo_mostra_combo_box}`);
      if (descInput) descInput.value = "";
      input.focus();
      return;
    }

    // ✅ Atualiza apenas o campo de descrição vinculado

    const campoDescricao = campo.nm_campo_mostra_combo_box;

    let valorDescricao = resultado[campoDescricao] ??
      resultado?.descricao ??
      resultado?.label ??
      Object.values(resultado).find(v => typeof v === "string" && v.length > 2);

    const inputDesc = document.getElementById(`desc_${campoDescricao}`) ||
      document.querySelector(`[name='${campoDescricao}_descricao']`);

    if (inputDesc && valorDescricao) {
      inputDesc.value = valorDescricao;
    }


  } catch (err) {
    console.error("Erro na validação:", err);
    alert("❌ Falha ao validar o código.");
  }
}


///
export function converterRegistroSelecionadoPadrao(registro, payload) {
  const convertido = {};

  payload.forEach(campo => {
    const nomeCampo = campo.nm_atributo?.trim();
    const label = campo.nm_titulo_menu_atributo?.trim();
    const nomeDescricao = campo.nm_campo_mostra_combo_box?.trim();
    const lookup = campo.nm_atributo_lookup?.trim();

    if (!nomeCampo) return;

    let valor = null;

    // Tenta pegar pelo lookup
    if (lookup && registro[lookup] != null) {
      valor = registro[lookup];
    }

    // Tenta pegar pelo label
    if (valor == null && label && registro[label] != null) {
      valor = registro[label];
    }

    // Tenta pegar pelo nome do campo diretamente (caso venha mapeado como está no backend)
    if (valor == null && registro[nomeCampo] != null) {
      valor = registro[nomeCampo];
    }

    if (valor != null) {
      convertido[nomeCampo] = valor;
    }

    // Preenche a descrição se estiver disponível
    if (nomeDescricao && registro[label]) {
      convertido[nomeDescricao] = registro[label];
    }
  });

  // 🧩 Fallback: insere os campos que não foram mapeados mas estão no registro original
  for (const chave in registro) {
    if (!convertido.hasOwnProperty(chave)) {
      convertido[chave] = registro[chave];
    }
  }

  return convertido;

}



///

window.aplicarRetornoPesquisaDireto = aplicarRetornoPesquisaDireto;

///

export function aplicarRetornoPesquisaDireto(retorno) {
  if (!retorno || !retorno.campo || retorno.valor == null) {
    console.warn("⚠️ Retorno inválido:", retorno);
    return;
  }

  const nomeCampo = retorno.campo;
  const valor = retorno.valor;

  const abaAtiva = document.querySelector(".tab-pane.active");
  const cd_menu = sessionStorage.getItem(`cd_menu_detalhe_${abaAtiva?.id}`) || sessionStorage.getItem("cd_menu");

  const payloadStr = sessionStorage.getItem(`payload_padrao_formulario_${cd_menu}`) ||
    sessionStorage.getItem("payload_padrao_formulario");

  const payload = JSON.parse(payloadStr || "[]");
  const campo = payload.find(c => c.nm_atributo === nomeCampo);
  if (!campo) return;

  // ✅ Atualiza o campo principal
  //const input = document.querySelector(`[name='${nomeCampo}']`);
  //if (input) {
  //  input.value = valor;
  //  input.focus();
  // }
  // 👉 1. Atualiza o campo de código
  const inputCodigo = document.querySelector(`input[name='${nomeCampo}']`);
  if (inputCodigo) {
    inputCodigo.value = valor;
  }

  // ✅ Atualiza campo de descrição
  const campoDescricao =
    campo.nm_campo_mostra_combo_box ||
    campo.nm_atributo_consulta ||
    `${nomeCampo}_descricao`;

  const descricaoObj = retorno.descricao?.find(d => {
    return (
      d.campo === campoDescricao ||
      d.campo === `${nomeCampo}_descricao` ||
      d.campo === campo.nm_atributo_consulta ||
      d.campo?.toLowerCase().includes("descricao") ||
      d.campo?.toLowerCase().includes("nome") ||
      d.campo?.startsWith("ds_")
    );
  });


  if (descricaoObj) {

    let inputDesc = document.querySelector(`[name='${nomeCampo}_descricao']`) ||
      document.querySelector(`[name='${campoDescricao}_descricao']`);

    if (!inputDesc) {
      const wrapper = input.closest(".input-group")?.parentElement || input.parentElement;
      inputDesc = document.createElement("input");
      inputDesc.type = "text";
      inputDesc.className = "form-control mt-2";
      inputDesc.name = `${nomeCampo}_descricao`;
      inputDesc.readOnly = true;
      inputDesc.placeholder = "Descrição";
      wrapper.appendChild(inputDesc);
    }

    if (inputDesc) {
      inputDesc.value = descricaoObj?.valor || "";
    }



  }

  // ✅ Atualiza sessionStorage
  const regKey = `registro_selecionado_${cd_menu}`;
  const registroAtual = JSON.parse(sessionStorage.getItem(regKey) || "{}");

  registroAtual[nomeCampo] = valor;
  if (descricaoObj) {
    registroAtual[`${nomeCampo}_descricao`] = descricaoObj.valor;
  }

  sessionStorage.setItem(regKey, JSON.stringify(registroAtual));

  console.log("✅ Retorno aplicado com sucesso (campo + descrição):", {
    campo: nomeCampo,
    valor,
    descricao: descricaoObj?.valor
  });
}


///

export async function montarAbaDinamicaComDados(cd_menu, cd_tabsheet, nomeAba = "") {
  console.log(`⚙️ Iniciando montagem da aba dinâmica ${nomeAba} para menu ${cd_menu}...`);

  // 🔁 Se necessário, carrega o payload e tabs
  let payloadStr = sessionStorage.getItem(`payload_padrao_formulario_${cd_menu}`);
  let tabsStr = sessionStorage.getItem(`tabs_padrao_formulario_${cd_menu}`);

  if (!payloadStr || !tabsStr) {
    console.log("📥 Payload ou Tabs não encontrados. Carregando...");
    await carregarPayloadTabela(cd_menu);
    payloadStr = sessionStorage.getItem(`payload_padrao_formulario_${cd_menu}`);
    tabsStr = sessionStorage.getItem(`tabs_padrao_formulario_${cd_menu}`);
  }

  const payload = JSON.parse(payloadStr || "[]");
  const sqlTabs = JSON.parse(tabsStr || "[]");
  const aba = sqlTabs.find(t => t.cd_tabsheet == cd_tabsheet);

  if (!aba) {
    console.warn(`❌ Aba ${cd_tabsheet} não encontrada no menu ${cd_menu}`);
    return;
  }

  // 🔎 Busca o registro salvo (caso tenha)
  const registroSelecionado = JSON.parse(sessionStorage.getItem(`registro_selecionado_${cd_menu}`) || "{}");

  // 🧩 Converte o registro para .valores se existir
  const valores = {};
  if (Object.keys(registroSelecionado).length > 0) {
    valores[`aba_${cd_tabsheet}`] = converterRegistroSelecionadoPadrao(registroSelecionado, payload);
  }

  console.log("🧠 Gerando campos da aba dinâmica com os dados:", valores);
  gerarCamposDaAba({ campos: payload, sqlTabs, valores }, cd_tabsheet, nomeAba);
}

////


// Consulta especial para qualquer menu (ex: aba ITENS)

export async function consultarDadosDaAba(cd_menu, filtrosOrigem = {}, filtrosExtras = []) {
  console.log(`🔍 Consultando dados da aba dinâmica (menu ${cd_menu})`);

  const cd_menu_origem = sessionStorage.getItem('cd_menu_origem');

  const filtros = [];

  for (const chave in filtrosOrigem) {
    if (filtrosOrigem[chave] != null && filtrosOrigem[chave] !== "") {
      filtros.push({
        campo: chave,
        operador: "=",
        valor: filtrosOrigem[chave]
      });
    }
  }

  if (Array.isArray(filtrosExtras)) {
    filtros.push(...filtrosExtras);
  }

  console.log('origem/destino->', cd_menu_origem, cd_menu);

  const filtrosChaves = gerarFiltrosChaveDoPai(cd_menu_origem, cd_menu);

  console.log('filtros chaves:', filtrosChaves);


  const payload = [{
    cd_parametro: 1,
    cd_menu,
    cd_usuario: sessionStorage.getItem("cd_usuario"),
    filtros,
    ...filtrosChaves
  }];

  console.log('payload de dados para Api Menu ->', payload);

  let dados;

  const res = await fetch("/api/menu-pesquisa", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  if (!res.ok) {
    const erro = await res.text();
    console.error("❌ Erro HTTP:", erro);
    alert("Erro ao consultar dados.");
    return;
  }

  dados = await res.json();

  console.log('retorno da api de dados: ', dados);

  if (!Array.isArray(dados) || dados.length === 0) {
    console.warn("📭 Nenhum dado encontrado para a aba dinâmica (menu:", cd_menu);
    return [];
  }

  // 🔁 Converte campos com base no mapa

  const mapa = JSON.parse(sessionStorage.getItem("mapa_consulta_para_atributo") || "{}");

  console.log('mapa: ', mapa);

  const convertidos = dados.map(item => {
    const novo = {};
    for (const [k, v] of Object.entries(item)) {
      novo[mapa[k] || k] = v;
    }
    return novo;
  });

  // ✅ Grava o primeiro item como o registro selecionado da origem da aba
  sessionStorage.setItem(`registro_selecionado_origem_${cd_menu}`, JSON.stringify(convertidos[0]));
  console.log(`💾 registro_selecionado_origem_${cd_menu} salvo:`, convertidos[0]);

  // 🔁 Salva todos os itens também, se quiser usar para grid
  sessionStorage.setItem(`itens_dinamicos_${cd_menu}`, JSON.stringify(convertidos));

  //
  dados = dados.map(item => {
    const convertido = {};
    for (const [chave, valor] of Object.entries(item)) {
      const chaveConvertida = mapa[chave] || chave;
      convertido[chaveConvertida] = valor;
    }
    return convertido;
  });

  // 🔧 Garantir campo `id` para a grid
  dados = dados.map((item, index) => {
    if (!item.hasOwnProperty("id")) {
      return { id: index + 1, ...item };
    }
    return item;
  });

  //Isto gera problema quando existe grande número de registros.....

  ///////////////////////////// 
  sessionStorage.setItem(`dados_resultado_consulta_${cd_menu}`, dados);
  ////////////////////////////


  return convertidos;

}

export function gerarFiltrosChaveDoPai(cd_menu_origem, cd_menu_destino) {
  const registroPai = JSON.parse(sessionStorage.getItem(`registro_selecionado_${cd_menu_origem}`) || "{}");
  const payloadPaiStr = sessionStorage.getItem(`payload_padrao_formulario_${cd_menu_origem}`);
  const payloadFilhoStr = sessionStorage.getItem(`payload_padrao_formulario_${cd_menu_destino}`);

  // console.log('origem', payloadPaiStr);
  // console.log('destino', payloadFilhoStr);


  if (!payloadPaiStr || !payloadFilhoStr) {
    console.warn("⚠️ Payload do menu pai ou filho ausente.");
    return [];
  }

  const payloadPai = JSON.parse(payloadPaiStr);
  const payloadFilho = JSON.parse(payloadFilhoStr);

  // Pega todos os campos chave do menu pai
  const camposChave = payloadPai.filter(c => c.ic_atributo_chave === "S");

  const filtros = {};

  camposChave.forEach(campoPai => {
    const nomeCampo = campoPai.nm_atributo;
    const nomeAtributo = campoPai.nm_atributo_consulta;
    const valorCampo = registroPai[nomeAtributo];

    //console.log('campos:', nomeCampo, valorCampo);

    if (valorCampo !== undefined && valorCampo !== "") {
      filtros[nomeCampo] = valorCampo;
    }


    //objeto/array
    /*
    if (valorCampo !== undefined && valorCampo !== "") {
      filtros.push({
        campo: nomeCampo,
        operador: "=",
        valor: valorCampo
      });
    }
    */


  });

  //console.log('filtros gerados -->', filtros);

  return filtros;

}

//

let gridInstance = null;

export function mostrarGridItensComDevExtreme(data, payload, mostrarAcoes = 1, targetId = 'devextreme-grid-itens') {
  console.log("📊 Montado a grid DevExtreme:");

  const gridId = targetId || 'devextreme-grid-itens';
  const $el = $(`#${gridId}`);

  if (!$el.length) {
    console.warn(`⚠️ Elemento com ID #${gridId} não encontrado. Grid não será montada.`);
    return;
  }

  if (!Array.isArray(data) || data.length === 0) {
    console.warn("⚠️ Nenhum dado para exibir na grid.");
    return;
  }

  //const gridContainer = document.querySelector("#devextreme-grid-itens");
  const gridContainer = document.querySelector(`#${targetId}`);

  if (!gridContainer) {
    console.warn("⚠️ Container da grid não encontrado.");
    return;
  }
  //
  const cd_menu = sessionStorage.getItem('cd_menu_tela');

  console.log('menu da grid :', cd_menu);

  const camposMeta = JSON.parse(sessionStorage.getItem(`campos_grid_meta_${cd_menu}`)) || [];

  // 🔁 Aplica o mapa de conversão
  const mapa = {};
  for (const campo of camposMeta) {
    if (campo.nm_atributo_consulta && campo.nm_atributo) {
      mapa[campo.nm_atributo_consulta] = campo.nm_atributo;
    }
  }

  data = data.map(item => {
    const convertido = {};
    for (const [k, v] of Object.entries(item)) {
      const chaveConvertida = mapa[k] || k;
      convertido[chaveConvertida] = v;
    }
    return convertido;
  });

  //console.log(camposMeta);

  let chavePrimaria = camposMeta.find(c => c.ic_atributo_chave === "S")?.nm_atributo_consulta || "id";

  // ✅ Verifica se a chavePrimaria é válida e existe nos dados
  //let chaveFinal = chavePrimaria;

  if (!chavePrimaria || !data.some(d => Object.prototype.hasOwnProperty.call(d, chavePrimaria))) {
    // Gera id incremental se chavePrimaria for inválida
    data = data.map((item, index) => ({ id: index + 1, ...item }));
    chavePrimaria = "id";
  }

  //console.log('colunas ', data);

  //Colunas com Agrupamento Inicial

  const agrupamentos = camposMeta
    .filter(c => c.ic_grid_agrupado_atributo === "S")
    .map(c => c.nm_atributo_consulta);

  const totaisGroupFooter = camposMeta
    .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
    .map(c => ({
      column: c.nm_atributo,
      summaryType: c.ic_total_grid === "S" ? "sum" : "count",
      displayFormat: c.ic_total_grid === "S" ? "Subtotal: {0}" : "{0} registros",
      showInGroupFooter: true,
      alignByColumn: true
    }));

  const totaisRodape = camposMeta
    .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
    .map(c => ({
      column: c.nm_atributo,
      summaryType: c.ic_total_grid === "S" ? "sum" : "count",
      displayFormat: c.ic_total_grid === "S" ? "Total: {0}" : "{0} registros",
      customizeText: function (e) {
        if (c.formato_coluna === "currency") {
          return `Total: ${e.value.toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL"
          })}`;
        }
        if (c.formato_coluna === "percent") {
          return `Total: ${(e.value * 100).toFixed(0)}%`;
        }
        return `Total: ${e.value}`;
      }
    }));

  const colunas = camposMeta
    .filter(c => c.ic_mostra_grid === "S")
    .sort((a, b) => (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0))
    .map(c => {
      const alinhamento = ["currency", "percent", "fixedPoint"].includes(c.formato_coluna) ? "right" : "left";

      return {
        dataField: c.nm_atributo_consulta,
        caption: c.nm_titulo_menu_atributo || c.nm_atributo_consulta,
        visible: true,
        width: c.largura || undefined,
        format: c.formato_coluna || undefined,
        alignment: alinhamento,
        allowFiltering: true,
        allowSorting: true
      };
    });

  const totais = camposMeta
    .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")

    .map(c => {
      return {
        column: c.nm_atributo,
        summaryType: c.ic_total_grid === "S" ? "sum" : "count",
        displayFormat: c.ic_total_grid === "S" ? "Total: {0}" : "{0} registros",
        showInGroupFooter: true,
        alignByColumn: true,
        customizeText: function (e) {
          if (c.formato_coluna === "currency") {
            return `Total: ${e.value.toLocaleString("pt-BR", { style: "currency", currency: "BRL" })}`;
          }
          if (c.formato_coluna === "percent") {
            return `Total: ${(e.value * 100).toFixed(0)}%`;
          }
          return `Total: ${e.value}`;
        }
      };
    });


  //console('grid');


  // console.log('campos totais e contador ', JSON.parse(sessionStorage.getItem("campos_grid_meta"))
  // .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
  // .map(c => c.nm_atributo));
  const icCrudProcesso = sessionStorage.getItem("ic_crud_processo") || "S";

  const acoes =
    [
      {
        hint: "Visualizar",
        icon: "search",
        onClick: function (e) {
          //sessionStorage.setItem("registro_selecionado", JSON.stringify(e.data));
          abrirModalVisualizacao(e.row.data);
        }
      }
    ];


  //Crud

  if (icCrudProcesso === "S") {
    acoes.push(
      {
        hint: "Editar",
        icon: "edit",
        onClick: function (e) {
          //sessionStorage.setItem("registro_selecionado", JSON.stringify(e.row.data));
          abrirModalAlteracao(e.row.data);
        }
      },
      {
        hint: "Excluir",
        icon: "trash",
        onClick: function (e) {
          //sessionStorage.setItem("registro_selecionado", JSON.stringify(e.data));
          abrirModalExclusao(e.row.data);
        }
      }
    );
  }

  let colunasAcoes = [];

  if (mostrarAcoes === 0) {
    colunasAcoes = [{
      caption: "Ações",
      type: "buttons",
      buttons: [
        ...acoes
      ]
    }];
  }

  /*
  {
            hint: "Visualizar",
            icon: "search",
            onClick(e) {
              console.log("🔍 Visualizar", e.row.data);
            }
          },
          {
            hint: "Editar",
            icon: "edit",
            onClick(e) {
              console.log("✏️ Editar", e.row.data);
            }
          },
          {
            hint: "Excluir",
            icon: "trash",
            onClick(e) {
              console.log("🗑️ Excluir", e.row.data);
            }
          }
  */


  //
  // 💥 Destroi grid anterior (caso exista) — ESSENCIAL para rerender
  if (gridInstance) {
    gridInstance.dispose();
    gridInstance = null;
  }

  //console.log('gerando.......');
  console.log('data --> ', data);

  // 🧩 Renderiza nova grid com DevExtreme
  //gridInstance = $("#devextreme-grid-itens").dxDataGrid({

  gridInstance = $(`#${targetId}`).dxDataGrid({
    //
    dataSource: data,
    keyExpr: chavePrimaria,
    columns: [
      // Ações...
      ...colunasAcoes,

      /* {
         type: "buttons",
         caption: "Ações",
         width: 100,
         buttons: acoes
       },
       */
      // Colunas da Grid <--------
      ...colunas
      //--------------------------

    ],
    columnAutoWidth: true,
    showBorders: true,
    allowColumnResizing: true,
    rowAlternationEnabled: true,
    hoverStateEnabled: true,
    focusedRowEnabled: true,
    focusedRowIndex: 0,
    selection: {
      mode: "single"
    },
    searchPanel: {
      visible: true,
      placeholder: "🔍 Procurar...",
      width: 240
    },
    headerFilter: {
      visible: true
    },
    grouping: { autoExpandAll: false },
    groupPanel: {
      visible: true,
      allowColumnDragging: true,
      emptyPanelText: "📌 Arraste um cabeçalho aqui para agrupar"
    },
    showColumnLines: true,
    showRowLines: true,
    showColumnHeaders: true,
    showRowAlternation: true,
    showColumnChooser: true,
    paging: { pageSize: 20 },
    pager: {
      showPageSizeSelector: true,
      allowedPageSizes: [10, 20, 50],
      showInfo: true,
      showNavigationButtons: true,
      displayMode: "full"
    },
    export: {
      enabled: false,
      allowExportSelectedData: true,
      fileName: "dados_especiais"
    },
    onContentReady: function (e) {
      controlarVisibilidadeExportacao(e.component);
    },
    onSummaryPreparing: function (e) {
      if (e.name === "totalSummary") {
        if (e.summaryProcess === "finalize" && typeof e.totalValue === "number") {
          e.totalValue = Number(e.totalValue.toFixed(2));
        }
      }
    },

    //summary: {
    //totalItems: totaisRodape,
    //groupItems: totaisGroupFooter,

    //texts: {
    //  sum: "Total: {0}",
    //  count: "Registros: {0}"
    //}

    //},

    summary: {
      totalItems: camposMeta
        .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
        .map(c => ({
          column: c.nm_atributo_consulta,
          summaryType: c.ic_total_grid === "S" ? "sum" : "count",
          alignByColumn: true,
          displayFormat: c.ic_total_grid === "S" ? "Total: {0}" : "{0} registros",
          customizeText: function (e) {
            if (c.formato_coluna === "currency") {
              return `Total: ${e.value.toLocaleString("pt-BR", {
                style: "currency",
                currency: "BRL"
              })}`;
            }
            if (c.formato_coluna === "percent") {
              return `Total: ${(e.value * 100).toFixed(2)}%`;
            }
            return `Total: ${e.value}`;
          }
        })),

      groupItems: camposMeta
        .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
        .map(c => ({
          column: c.nm_atributo_consulta,
          summaryType: c.ic_total_grid === "S" ? "sum" : "count",
          showInGroupFooter: true,
          alignByColumn: true,
          displayFormat: c.ic_total_grid === "S" ? "Subtotal: {0}" : "{0} registros",
          customizeText: function (e) {
            if (c.formato_coluna === "currency") {
              return `Subtotal: ${e.value.toLocaleString("pt-BR", {
                style: "currency",
                currency: "BRL"
              })}`;
            }
            if (c.formato_coluna === "percent") {
              return `Subtotal: ${(e.value * 100).toFixed(2)}%`;
            }
            return `Subtotal: ${e.value}`;
          }
        })),
      texts: {
        sum: "Total: {0}",
        count: "Registros: {0}"
      }
    },

    masterDetail: {
      enabled: false,
      template: function (container, options) {
        const item = options.data;
        const campos = Object.entries(item)
          .map(([chave, valor]) => `<tr><td><strong>${chave}</strong></td><td>${valor}</td></tr>`)
          .join('');

        container.append(`
              <div style="padding: 12px;">
                <table class="dx-detail-table">${campos}</table>
              </div>
            `);
      }
    },

    onRowDblClick: function (e) {
      // sessionStorage.setItem("registro_selecionado", JSON.stringify(e.data));
      const cd_menu = sessionStorage.getItem("cd_menu");
      sessionStorage.setItem(`registro_selecionado_${cd_menu}`, JSON.stringify(e.data));
      sessionStorage.setItem("registro_selecionado", JSON.stringify(e.data));

      if (!isPesquisa) {
        abrirProcessos();
        return;
      }
      //Seleciona o Registro e volta a tela anterior 
      confirmarRetornoPesquisa();
      //

    },

    onRowClick: function (e) {
      if (e.rowType !== "data") return;
      //Chave Primária///
      sessionStorage.setItem('cd_documento_relatorio', e.key);
      console.log('chave primária:', e.key);

      //
      const cd_menu = sessionStorage.getItem("cd_menu");
      console.log('cd_menu no click da grid: ', cd_menu);
      sessionStorage.setItem(`registro_selecionado_${cd_menu}`, JSON.stringify(e.data));
      sessionStorage.setItem("registro_selecionado", JSON.stringify(e.data));

      //registroSelecionado = e.data;


      // 🧩 1. Pega a chave primária da linha clicada
      const camposMeta = JSON.parse(sessionStorage.getItem("campos_grid_meta") || "[]");
      //const chavePrimaria = camposMeta.find(c => c.ic_atributo_chave === "S")?.nm_atributo || "id";
      const chavePrimaria = camposMeta.find(c => c.ic_atributo_chave === "S")?.nm_atributo_consulta || "id";
      const idPai = e.data[chavePrimaria];

      // ⬇️ Fluxo normal da consulta com abas:

      // 🧩 2. Salva os dados do registro no session
      //sessionStorage.setItem("registro_selecionado", JSON.stringify(e.data));

      sessionStorage.setItem("id_pai", idPai);

      if (isPesquisa) {
        const btnSelecionar = document.getElementById("btnSelecionar");
        if (btnSelecionar) {
          btnSelecionar.style.display = "inline-block";
        }

        return;

      }


      // 🧩 3. Habilita todas as abas de menu detalhe e define o ID pai
      document.querySelectorAll('[data-cd-menu-detalhe]').forEach(tab => {
        tab.classList.remove("disabled");
        tab.removeAttribute("aria-disabled");
        tab.tabIndex = 0;
        tab.dataset.idPai = idPai;
      });

      // ✅ 4. Ativa automaticamente a primeira aba de detalhe (ex: Itens)
      //ccf aqui ver ic_menu_detalhe = 'S'

      const primeiraAba = document.querySelector('.nav-link[data-cd-menu-detalhe]:not(.disabled)');

      if (primeiraAba) {
        new bootstrap.Tab(primeiraAba).show();
      }

      /////

    },
    onExporting: function (e) {
      console.log("📤 Exportação iniciada...");
    },
    onInitialized: function (e) {
      // Agrupa por padrão
      agrupamentos.forEach(field => {
        e.component.columnOption(field, "groupIndex", 0);
      });
    }
    //
  }).dxDataGrid("instance");
}


//
export function montarGridResultadosDevExtreme(containerId, dados, onClickLinha = null) {
//

  const cd_menu = sessionStorage.getItem("cd_menu");

  if (!window.DevExpress || !DevExpress.ui?.dxDataGrid) {
    console.warn("⚠️ DevExtreme não está disponível.");
    return;
  }

  if (!Array.isArray(dados)) {
    console.warn("⚠️ Dados inválidos para montar grid.");
    return;
  }

  const container = document.querySelector(containerId);
  if (!container) {
    console.warn("⚠️ Container não encontrado:", containerId);
    return;
  }

  container.innerHTML = "";
  container.classList.remove("hidden");

  // ✅ Adiciona título com menu_titulo da sessão

  const wrapper = container.parentElement || container;
  const titulo = sessionStorage.getItem("menu_titulo") || "Título";

  if (!wrapper.querySelector("h2.titulo-grid")) {
    const h2 = document.createElement("h2");
    h2.textContent = titulo;
    h2.classList.add("mb-3", "titulo-grid");
    wrapper.insertBefore(h2, container);
  }

  const gridId = container.id;

  // Cria botões de exportação
  //const htmlBotoes = criarBotoesExportacaoExcelPdf(gridId);
  //container.insertAdjacentHTML("beforebegin", htmlBotoes);

  //const camposMeta = JSON.parse(sessionStorage.getItem("campos_grid_meta")) || [];

  let camposMeta = [];

  try {
    const rawMeta = sessionStorage.getItem(`campos_grid_meta_${cd_menu}`);
    camposMeta = rawMeta ? JSON.parse(rawMeta) : [];
  } catch (e) {
    console.warn("⚠️ campos_grid_meta inválido ou ausente no sessionStorage.");
  }

  const chavePrimaria =
    camposMeta.find(c => c.ic_atributo_chave === "S")?.nm_atributo_consulta ||
    (dados[0] && Object.keys(dados[0])[0]) || "id";


  const colunas = camposMeta
    .filter(c => c.ic_mostra_grid === "S")
    .sort((a, b) => (a.qt_ordem_coluna || 0) - (b.qt_ordem_coluna || 0))
    .map(c => {
      const alinhamento = ["currency", "percent", "fixedPoint"].includes(c.nm_datatype) ? "right" : "left";
      const coluna = {
        dataField: c.nm_atributo,
        caption: c.nm_edit_label || c.nm_atributo_consulta,
        visible: true,
        width: c.largura || undefined,
        format: c.formato_coluna || undefined,
        alignment: alinhamento,
        allowFiltering: true,
        allowSorting: true
      };

      // Se for campo data, formata para DD/MM/AAAA
      if (c.nm_datatype === "date" || c.nm_datatype === "shortDate") {
        coluna.customizeText = function (e) {
          if (!e.value) return "";
          const d = new Date(e.value);
          return d.toLocaleDateString("pt-BR");
        };
      }

      if (c.nm_datatype === "currency") {
        coluna.customizeText = function (e) {
          return e.value?.toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL"
          }) || "";
        };
      }


      return coluna;

    });



  const agrupamentos = camposMeta
    .filter(c => c.ic_grid_agrupado_atributo === "S")
    .map(c => c.nm_atributo_consulta);

  const totaisGroup = camposMeta
    .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
    .map(c => ({
      column: c.nm_atributo_consulta,
      summaryType: c.ic_total_grid === "S" ? "sum" : "count",
      displayFormat: c.ic_total_grid === "S" ? "Subtotal: {0}" : "{0} registros",
      showInGroupFooter: true,
      alignByColumn: true
    }));

  const totaisRodape = camposMeta
    .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
    .map(c => ({
      column: c.nm_atributo_consulta,
      summaryType: c.ic_total_grid === "S" ? "sum" : "count",
      displayFormat: c.ic_total_grid === "S" ? "Total: {0}" : "{0} registros",
      customizeText: function (e) {
        if (c.nm_datatype === "currency") {
          return `Total: ${e.value.toLocaleString("pt-BR", {
            style: "currency",
            currency: "BRL"
          })}`;
        }
        if (c.formato_coluna === "percent") {
          return `Total: ${(e.value * 100).toFixed(2)}%`;
        }
        return `Total: ${e.value}`;
      }
    }));


  container.classList.remove("hidden");

  //
  let gridInstance = null;
  //

  if (gridInstance) {
    gridInstance.dispose();
    gridInstance = null;
  }
  //

  gridInstance = $(containerId).dxDataGrid({
    menuId: cd_menu,
    dataSource: dados,
    keyExpr: chavePrimaria,
    columns: colunas,
    columnAutoWidth: true,
    showBorders: true,
    focusedRowEnabled: true,
    focusedRowIndex: 0,
    hoverStateEnabled: true,
    rowAlternationEnabled: true,
    searchPanel: {
      visible: true,
      width: 250,
      placeholder: "🔍 Procurar..."
    },
    grouping: { autoExpandAll: false },
    groupPanel: {
      visible: true,
      allowColumnDragging: true,
      emptyPanelText: "📌 Arraste um cabeçalho aqui para agrupar"
    },
    paging: {
      pageSize: 10
    },
    pager: {
      showPageSizeSelector: true,
      allowedPageSizes: [10, 20, 50],
      showInfo: true
    },
    scrolling: {
      mode: "standard"
    },

    export: {
      enabled: false,
      allowExportSelectedData: true,
      fileName: "dados_especiais"
    },
    toolbar: {
      items: [
        "groupPanel",
        "searchPanel", // mantém a busca à esquerda

        {
          location: "after",
          widget: "dxButton",
          options: {
            icon: "exportxlsx",
            text: "Excel",
            type: "default",
            stylingMode: "contained",
            onClick: () => exportarGridExcel(gridId)
          }
        },
        {
          location: "after",
          widget: "dxButton",
          options: {
            icon: "exportpdf",
            text: "PDF",
            type: "default",
            stylingMode: "contained",
            onClick: () => exportarGridPDF(gridId)
          }
        },
        {
          location: "after",
          widget: "dxButton",
          options: {
            icon: "paste",
            text: "RELATÓRIO",
            type: "default",
            stylingMode: "contained",

            //
            onClick: () => {
              const instance = $(`#${gridId}`).dxDataGrid("instance");
              if (!instance) return;

              //const dados = instance.option("dataSource") || [];

              //if (!dados || dados.length === 0) {
              //  alert("⚠️ Nenhum dado para o relatório.");
              //  return;
              //}

               // 1) Pegar LINHAS que realmente estão na tela (respeita filtros/paging/grouping).
      const rows = instance.getVisibleRows().map(r => r.data);
      if (!rows.length) {
        alert("⚠️ Nenhum dado para o relatório.");
        return;
      }

              const cd_menu = instance.option("menuId") || sessionStorage.getItem("cd_menu")
                              || localStorage.cd_menu || '';

              //Dados da Meta
                  // 3) Tentar obter a META (se você já salvou antes)
      let meta;
      try {
        meta = JSON.parse(
          sessionStorage.getItem(`campos_grid_meta_${cd_menu}`)
          || sessionStorage.getItem('campos_grid_meta')
          || localStorage.getItem(`campos_grid_meta_${cd_menu}`)
          || localStorage.getItem('campos_grid_meta')
          || '[]'
        );
      } catch (_) { meta = []; }

       // fallback: se não veio meta, derive das colunas atuais da grid
      if (!Array.isArray(meta) || meta.length === 0) {
        const cols = inst.option('columns') || [];
        meta = cols
          .filter(c => c && c.dataField)
          .map((c, i) => ({
            nm_atributo_consulta: c.dataField,
            nm_titulo_menu_atributo: c.caption || c.dataField,
            formato_coluna: (typeof c.format === 'string' ? c.format : ''),
            ic_total_grid: (c.summaryType ? 'S' : 'N'),
            qt_ordem_coluna: i
          }));
      }

      // 4) Funções utilitárias para gravar em AMBOS os storages
      const setStore = (k, v) => {
        const s = (typeof v === 'string') ? v : JSON.stringify(v);
        try { sessionStorage.setItem(k, s); } catch {}
        try { localStorage.setItem(k, s); }  catch {}
      };

      setStore('dados_resultado_consulta', rows);
      setStore(`campos_grid_meta_${cd_menu}`, meta);
      setStore('campos_grid_meta', meta);               // backup genérico
      setStore('cd_menu_relatorio', String(cd_menu));

      // cabeçalho do relatório (opcional)
      setStore('nm_fantasia_empresa', localStorage.nm_fantasia_empresa || 'Empresa');
      setStore('nm_usuario',          localStorage.nm_usuario          || '-');
      setStore('logo_empresa',        localStorage.logo_empresa        || '/img/logo.png');


      
      sessionStorage.setItem("dados_resultado_consulta", JSON.stringify(dados));
             // sessionStorage.setItem(`campos_grid_meta_${cd_menu}`, JSON.stringify(meta));
              sessionStorage.setItem("cd_menu_relatorio", cd_menu);
              

                  // 5) Abra o relatorio (se ele roda em outro domínio, use URL absoluta desse domínio)
                   window.open('/relatorio.html', '_blank');
                 //
                    // exemplo: window.open('https://egiserp.com.br/relatorio.html', '_blank');
                  //
              //window.open("/relatorio.html", "_blank");
              //

            }


            //

          }
        }


      ]
    },

    onContentReady: function (e) {
      controlarVisibilidadeExportacao(e.component);
    },

    onSummaryPreparing: function (e) {
      if (e.name === "totalSummary") {
        if (e.summaryProcess === "finalize" && typeof e.totalValue === "number") {
          e.totalValue = Number(e.totalValue.toFixed(2));
        }
      }
    },

    summary: {
      totalItems: camposMeta
        .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
        .map(c => ({
          column: c.nm_atributo_consulta,
          summaryType: c.ic_total_grid === "S" ? "sum" : "count",
          alignByColumn: true,
          displayFormat: c.ic_total_grid === "S" ? "Total: {0}" : "{0} registros",
          customizeText: function (e) {
            if (c.nm_datatype === "currency") {
              return `Total: ${e.value.toLocaleString("pt-BR", {
                style: "currency",
                currency: "BRL"
              })}`;
            }
            if (c.formato_coluna === "percent") {
              return `Total: ${(e.value * 100).toFixed(2)}%`;
            }
            return `Total: ${e.value}`;
          }
        })),

      groupItems: camposMeta
        .filter(c => c.ic_total_grid === "S" || c.ic_contador_grid === "S")
        .map(c => ({
          column: c.nm_atributo_consulta,
          summaryType: c.ic_total_grid === "S" ? "sum" : "count",
          showInGroupFooter: true,
          alignByColumn: true,
          displayFormat: c.ic_total_grid === "S" ? "Subtotal: {0}" : "{0} registros",
          customizeText: function (e) {
            if (c.nm_datatype === "currency") {
              return `Subtotal: ${e.value.toLocaleString("pt-BR", {
                style: "currency",
                currency: "BRL"
              })}`;
            }
            if (c.formato_coluna === "percent") {
              return `Subtotal: ${(e.value * 100).toFixed(2)}%`;
            }
            return `Subtotal: ${e.value}`;
          }
        })),
      texts: {
        sum: "Total: {0}",
        count: "Registros: {0}"
      }
    },
    onInitialized: function (e) {
      // Agrupa por padrão
      agrupamentos.forEach(field => {
        e.component.columnOption(field, "groupIndex", 0);
      });
    },
    onExporting: function (e) {
      console.log("📤 Exportação iniciada...");
    }

  }).dxDataGrid("instance");

}

//


//import { monitorarTrocaDeAbas } from "./form-utils.js";

export function inicializarAbasDinamicas(tabs, fullPayload) {
  if (!tabs || !Array.isArray(tabs) || tabs.length === 0) {
    console.warn("⚠️ Nenhuma aba informada para inicialização.");
    return;
  }

  if (!fullPayload || !fullPayload.sqlTabs) {
    console.warn("⚠️ Payload completo ausente ou inválido.");
    return;
  }

  console.log("🚀 Inicializando monitoramento das abas dinâmicas...");
  monitorarTrocaDeAbas(tabs, fullPayload);
}

function controlarVisibilidadeExportacao(gridInstance) {
  const temDados = gridInstance.getVisibleRows().length > 0;
  const btnExportar = document.getElementById("btnExportarExcel");
  const btnExportarPDF = document.getElementById("btnExportarPDF");

  if (btnExportar) {
    btnExportar.style.display = temDados ? "inline-block" : "none";
  }

  if (btnExportarPDF) {
    btnExportarPDF.style.display = temDados ? "inline-block" : "none";
  }

}




export function adicionarExportacaoExcel(gridInstance, nomeArquivo = "relatorio") {
  gridInstance.option("export", {
    enabled: true,
    allowExportSelectedData: false,
    fileName: nomeArquivo,
    texts: {
      exportTo: "Exportar",
      exportAll: "Exportar tudo",
      exportSelectedRows: "Exportar selecionados",
      exportSelectedData: "Exportar dados"
    }
  });
}

export function criarBotoesExportacaoExcelPdf(gridId) {
  return `
    <div class="d-flex justify-content-end gap-2 mb-2">
      <button class="btn btn-outline-primary btn-sm btn-exportar" onclick="exportarGridExcel('${gridId}')">
        <i class="dx-icon-exportxlsx"></i> Excel
      </button>
      <button class="btn btn-outline-danger btn-sm btn-exportar" onclick="exportarGridPDF('${gridId}')">
        <i class="dx-icon-exportpdf"></i> PDF
      </button>
    </div>
  `;
}

export async function exportarGridExcel(gridId) {
  const instance = $(`#${gridId}`).dxDataGrid("instance");
  //instance.exportToExcel(false);
  //const titulo = sessionStorage.getItem("menu_titulo") || "relatorio";
  const titulo = document
    .querySelector(`#${gridId}`)
    ?.closest(".painel-grid")
    ?.querySelector("h2.titulo-grid")
    ?.innerText || "relatorio";

  const nomeArquivo = titulo.replace(/\s+/g, "_").toLowerCase();

  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet("Planilha");

  await DevExpress.excelExporter.exportDataGrid({
    component: instance,
    worksheet: worksheet,
    autoFilterEnabled: true
  });

  const buffer = await workbook.xlsx.writeBuffer();
  const blob = new Blob([buffer], { type: "application/octet-stream" });
  saveAs(blob, `${nomeArquivo}.xlsx`);


}

export async function exportarGridPDF(gridId) {
  const instance = $(`#${gridId}`).dxDataGrid("instance");
  if (!instance) return;

  const doc = new window.jspdf.jsPDF({
    orientation: "landscape",
    unit: "pt",
    format: "a4"
  });

  await DevExpress.pdfExporter.exportDataGrid({
    component: instance,
    jsPDFDocument: doc,
    customizeCell(options) {
      if (options?.pdfCell?.styles) {
        options.pdfCell.styles.fontSize = 8;
      }
    }
  });

  // const titulo = sessionStorage.getItem("menu_titulo") || "relatorio";

  const titulo = document
    .querySelector(`#${gridId}`)
    ?.closest(".painel-grid")
    ?.querySelector("h2.titulo-grid")
    ?.innerText || "relatorio";


  const nomeArquivo = titulo.replace(/\s+/g, "_").toLowerCase();

  doc.save(`${nomeArquivo}.pdf`);
  console.log("📄 PDF gerado com sucesso.");
}

function gerarRelatorioGrid(gridId) {
  const cd_menu = sessionStorage.getItem("cd_menu");
  const dados = sessionStorage.getItem(`dados_resultado_consulta_${cd_menu}`);
  if (!dados) {
    alert("⚠️ Nenhum dado encontrado para o relatório.");
    return;
  }
  sessionStorage.setItem("dados_resultado_consulta", dados);
  sessionStorage.setItem("cd_menu_relatorio", cd_menu);
  //
  window.open("/relatorio.html", "_blank");
  //
}


// Expõe as funções globalmente para os botões HTML
window.exportarGridExcel = exportarGridExcel;
window.exportarGridPDF = exportarGridPDF;
window.gerarRelatorio = gerarRelatorioGrid;
//
