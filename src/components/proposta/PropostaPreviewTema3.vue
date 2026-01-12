<template>
  <div class="p3-wrap">
    <div class="p3-topbar no-print">
      <div class="p3-pill">Proposta <b>#{{ cd_consultaLabel }}</b></div>
      <div class="p3-pill">{{ dtLabel }}</div>
      <div class="p3-pill"><b>Cliente:</b> {{ consulta.cd_cliente || "—" }}</div>
      <button class="p3-btn" @click="print">Salvar em PDF / Imprimir</button>
    </div>

    <div class="p3-sheet">
      <!-- SIDEBAR -->
      <aside class="p3-side">
        <div class="p3-sideStripe">
          <div class="p3-sideTitle">Proposta Comercial</div>
          <div class="p3-sideSub">Tema 3 • Executive Blueprint • 2026</div>
        </div>

        <div class="p3-sideBody">
          <div class="p3-kv">
            <div class="p3-k">cd_consulta</div>
            <div class="p3-v">{{ cd_consultaLabel }}</div>
          </div>
          <div class="p3-kv">
            <div class="p3-k">Data</div>
            <div class="p3-v">{{ dtLabel }}</div>
          </div>
          <div class="p3-kv">
            <div class="p3-k">Cliente</div>
            <div class="p3-v">{{ consulta.cd_cliente || "—" }}</div>
          </div>
          <div class="p3-kv">
            <div class="p3-k">Vendedor</div>
            <div class="p3-v">{{ consulta.cd_vendedor || "—" }}</div>
          </div>
          <div class="p3-kv">
            <div class="p3-k">Cond. Pagamento</div>
            <div class="p3-v">{{ consulta.cd_condicao_pagamento || "—" }}</div>
          </div>

          <div class="p3-kpiGrid">
            <div class="p3-kpi">
              <div class="p3-label">Produtos</div>
              <div class="p3-value p3-money">{{ brl(totalProdutos) }}</div>
              <div class="p3-hint">{{ countProdutos }} item(ns)</div>
            </div>
            <div class="p3-kpi">
              <div class="p3-label">Serviços</div>
              <div class="p3-value p3-money">{{ brl(totalServicos) }}</div>
              <div class="p3-hint">{{ countServicos }} item(ns)</div>
            </div>
            <div class="p3-kpi">
              <div class="p3-label">Total</div>
              <div class="p3-value p3-money">{{ brl(totalGeral) }}</div>
              <div class="p3-hint">Sem impostos</div>
            </div>
          </div>
        </div>
      </aside>

      <!-- CONTEÚDO -->
      <main class="p3-main">
        <div class="p3-mainHd">
          <h1>Proposta Comercial</h1>
          <p>
            Implantação e entrega com escopo, investimento, condições de pagamento,
            manutenção e SLA — pronto para gerar PDF e imprimir.
          </p>
        </div>

        <!-- PROJETO -->
        <section class="p3-section">
          <div class="p3-sectionTitle">
            <h2>Projeto</h2>
            <span class="p3-chip">Escopo: Gestão ERP</span>
          </div>

          <ul class="p3-list">
            <li class="p3-li"><div class="p3-dot"></div><div><b>Migração de Dados</b><span>Mapeamento e importação assistida</span></div></li>
            <li class="p3-li"><div class="p3-dot"></div><div><b>Financeiro</b><span>Pagar/Receber + Fluxo de Caixa</span></div></li>
            <li class="p3-li"><div class="p3-dot"></div><div><b>Faturamento</b><span>Emissão de documentos fiscais</span></div></li>
            <li class="p3-li"><div class="p3-dot"></div><div><b>BI / Dashboards</b><span>Indicadores e visão gerencial</span></div></li>
          </ul>
        </section>

        <!-- INVESTIMENTOS -->
        <section class="p3-section">
          <div class="p3-sectionTitle">
            <h2>Investimentos</h2>
            <span class="p3-chip">Valores sem impostos</span>
          </div>

          <div class="p3-twoCols">
            <div>
              <table class="p3-table">
                <thead>
                  <tr>
                    <th>Descrição</th>
                    <th class="right">Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Produtos</td>
                    <td class="right p3-money">{{ brl(totalProdutos) }}</td>
                  </tr>
                  <tr>
                    <td>Serviços</td>
                    <td class="right p3-money">{{ brl(totalServicos) }}</td>
                  </tr>
                  <tr>
                    <td><b>Total</b></td>
                    <td class="right p3-money"><b>{{ brl(totalGeral) }}</b></td>
                  </tr>
                </tbody>
              </table>

              <div class="p3-note">
                Obs.: descontos já considerados no total dos itens.
              </div>
            </div>

            <div class="p3-callout">
              <div class="p3-calloutHead">
                <b>Fluxo de pagamento</b>
                <span class="p3-pillSm">Sem juros</span>
              </div>

              <table class="p3-table">
                <tbody>
                  <tr>
                    <td><b>Entrada</b></td>
                    <td class="right p3-money">{{ brl(entrada) }}</td>
                  </tr>
                  <tr>
                    <td><b>Saldo</b> em {{ parcelasQtd }} parcela(s)</td>
                    <td class="right p3-money">{{ brl(parcelaValor) }}</td>
                  </tr>
                  <tr>
                    <td><b>Total líquido</b></td>
                    <td class="right p3-money"><b>{{ brl(totalGeral) }}</b></td>
                  </tr>
                </tbody>
              </table>

              <div class="p3-note">
                *Configuração padrão: 25% entrada + 10 parcelas (ajustável).
              </div>
            </div>
          </div>
        </section>

        <!-- MANUTENÇÃO (genérico) -->
        <section class="p3-section">
          <div class="p3-sectionTitle">
            <h2>Manutenção mensal</h2>
            <span class="p3-chip">Reajuste anual: IPC</span>
          </div>

          <div class="p3-twoCols">
            <div>
              <table class="p3-table">
                <thead>
                  <tr><th>Descrição</th><th class="right">Total</th></tr>
                </thead>
                <tbody>
                  <tr><td>Hospedagem + backups + atualizações</td><td class="right p3-money">{{ brl(mensalNuvem) }}</td></tr>
                  <tr><td>Suporte técnico (chat/telefone)</td><td class="right p3-money">{{ brl(mensalSuporte) }}</td></tr>
                  <tr><td><b>Total mensal</b></td><td class="right p3-money"><b>{{ brl(mensalTotal) }}</b></td></tr>
                </tbody>
              </table>

              <div class="p3-note">
                Valores ilustrativos (genérico). Você pode amarrar depois aos campos reais.
              </div>
            </div>

            <div class="p3-callout cyan">
              <div class="p3-calloutHead">
                <b>Inclui</b>
                <span class="p3-pillSm">Plataforma & App</span>
              </div>
              <div class="p3-note">
                ERP + App, hospedagem em nuvem, rotinas de backup e suporte.
              </div>
            </div>
          </div>
        </section>

        <!-- CRONOGRAMA -->
        <section class="p3-section">
          <div class="p3-sectionTitle">
            <h2>Prazo e cronograma</h2>
            <span class="p3-chip">90 dias • (ajustável)</span>
          </div>

          <div class="p3-timeline">
            <div class="p3-step"><div class="p3-t">T1</div><div><b>Mapeamento</b><span>Levantamento e requisitos</span></div></div>
            <div class="p3-step"><div class="p3-t">T2</div><div><b>Parametrização</b><span>Cadastros, treinamento e testes</span></div></div>
            <div class="p3-step"><div class="p3-t">T3</div><div><b>Go-live</b><span>Virada assistida</span></div></div>
            <div class="p3-step"><div class="p3-t">T4</div><div><b>Operação</b><span>Suporte e evolução</span></div></div>
          </div>
        </section>

        <!-- SLA -->
        <section class="p3-section">
          <div class="p3-sectionTitle">
            <h2>Atendimento e SLA</h2>
            <span class="p3-chip">08h–18h (2ª a 6ª)</span>
          </div>

          <div class="p3-twoCols">
            <div class="p3-callout">
              <div class="p3-calloutHead">
                <b>Canais</b>
                <span class="p3-pillSm">Implantação: 3 meses</span>
              </div>
              <div class="p3-note">Telefone, e-mail, chat e WhatsApp.</div>
            </div>

            <table class="p3-table">
              <thead><tr><th>Prioridade</th><th>Tempo</th></tr></thead>
              <tbody>
                <tr><td>Crítico (P1)</td><td class="p3-money">15 minutos</td></tr>
                <tr><td>Alto (P2)</td><td class="p3-money">30 minutos</td></tr>
                <tr><td>Médio (P3)</td><td class="p3-money">02 horas</td></tr>
                <tr><td>Baixo (P4)</td><td class="p3-money">04 horas</td></tr>
                <tr><td class="muted">Resolução típica</td><td class="muted p3-money">P1: 01–03h • P2: 04–08h • P3: 01–02 dias úteis • P4: 03–05 dias úteis</td></tr>
              </tbody>
            </table>
          </div>
        </section>

        <div class="p3-footer">
          <div>Gerado automaticamente • Tema 3 (Executive Blueprint)</div>
          <div>Documento comercial — sujeito a validação final</div>
        </div>
      </main>
    </div>
  </div>
</template>

<script>
export default {
  name: "PropostaPreviewTema3",
  props: {
    consulta: { type: Object, required: true },
    itens: { type: Array, default: () => [] }
  },
  computed: {
    cd_consultaLabel() {
      const v = Number(this.consulta.cd_consulta || 0);
      return v > 0 ? String(v) : "NOVO";
    },
    dtLabel() {
      return this.consulta.dt_consulta || new Date().toLocaleDateString("pt-BR");
    },

    produtos() {
      return (this.itens || []).filter(x => (x.tp_item || "").toUpperCase() === "PROD");
    },
    servicos() {
      return (this.itens || []).filter(x => (x.tp_item || "").toUpperCase() === "SERV");
    },
    totalProdutos() {
      return this.sumBy(this.produtos, "vl_total");
    },
    totalServicos() {
      return this.sumBy(this.servicos, "vl_total");
    },
    totalGeral() {
      return Number((this.totalProdutos + this.totalServicos).toFixed(2));
    },
    countProdutos() {
      return this.produtos.length;
    },
    countServicos() {
      return this.servicos.length;
    },

    // pagamento (genérico): 25% entrada + 10 parcelas do saldo
    entrada() {
      return Number((this.totalGeral * 0.25).toFixed(2));
    },
    parcelasQtd() {
      return 10;
    },
    parcelaValor() {
      const saldo = Math.max(this.totalGeral - this.entrada, 0);
      return Number((saldo / this.parcelasQtd).toFixed(2));
    },

    // mensalidade (genérico)
    mensalNuvem() { return 400; },
    mensalSuporte() { return 550; },
    mensalTotal() { return this.mensalNuvem + this.mensalSuporte; }
  },
  methods: {
    print() { window.print(); },
    brl(v) {
      const n = Number(v || 0);
      return new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(n);
    },
    sumBy(arr, key) {
      return Number((arr || []).reduce((acc, x) => acc + Number(x?.[key] || 0), 0).toFixed(2));
    }
  }
};
</script>

<style scoped>

  @media print {
  .no-print { display: none !important; }
}


/* Tema 3 (Executive Blueprint) - completo */
/* REMOVIDO: :root{} (estava vazio e pode dar conflito dependendo do setup) */

.p3-wrap{ font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Arial; color:#0f172a; }
.p3-topbar{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-bottom:12px; }
.p3-pill{ padding:9px 12px; border:1px solid #e2e8f0; border-radius:999px; background:#fff; font-size:12px; color:#475569; }
.p3-pill b{ color:#0f172a; font-weight:800; }
.p3-btn{ margin-left:auto; border:0; cursor:pointer; padding:10px 14px; border-radius:999px; color:#fff; background: linear-gradient(135deg,#4527a0,#0097a7); box-shadow: 0 10px 22px rgba(69,39,160,.18); }

.p3-sheet{ display:grid; grid-template-columns: 280px 1fr; gap:14px; align-items:start; }
@media (max-width:980px){ .p3-sheet{ grid-template-columns:1fr; } }

.p3-side{ border:1px solid #e2e8f0; border-radius:22px; overflow:hidden; background:#fff; box-shadow: 0 12px 28px rgba(2,6,23,.08); }
.p3-sideStripe{ padding:18px 16px; color:#fff; background: linear-gradient(135deg,#4527a0,#0097a7); position:relative; overflow:hidden; }
.p3-sideStripe:before{
  content:""; position:absolute; inset:-40px;
  background:
    radial-gradient(220px 180px at 20% 20%, rgba(244,81,30,.55), transparent 60%),
    radial-gradient(220px 180px at 80% 10%, rgba(255,255,255,.18), transparent 60%),
    radial-gradient(260px 200px at 70% 90%, rgba(0,151,167,.40), transparent 60%);
  filter: blur(2px); opacity:.75;
}
.p3-sideStripe > *{ position:relative; }
.p3-sideTitle{ margin:0; font-size:18px; font-weight:900; letter-spacing:-.01em; }
.p3-sideSub{ margin-top:6px; font-size:12px; opacity:.92; }
.p3-sideBody{ padding:14px; display:grid; gap:10px; }
.p3-kv{ border:1px solid #e2e8f0; border-radius:14px; padding:10px; background: linear-gradient(180deg,#fff,#f8fafc); }
.p3-k{ font-size:11px; letter-spacing:.10em; text-transform:uppercase; color:#475569; }
.p3-v{ margin-top:5px; font-size:13px; font-weight:800; color:#0f172a; }
.p3-money{ font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono","Courier New", monospace; white-space:nowrap; }

.p3-kpiGrid{ display:grid; gap:10px; }
.p3-kpi{ border:1px solid #e2e8f0; border-radius:16px; padding:12px; background:#fff; }
.p3-label{ font-size:11px; letter-spacing:.10em; text-transform:uppercase; color:#475569; }
.p3-value{ margin-top:6px; font-size:18px; font-weight:900; color:#0f172a; }
.p3-hint{ margin-top:6px; font-size:12px; color:#475569; }

.p3-main{ border:1px solid #e2e8f0; border-radius:22px; overflow:hidden; background:#fff; box-shadow: 0 12px 28px rgba(2,6,23,.08); }
.p3-mainHd{ padding:18px; border-bottom:1px solid #e2e8f0; background: linear-gradient(90deg, rgba(244,81,30,.06), rgba(69,39,160,.06), rgba(0,151,167,.06)); }
.p3-mainHd h1{ margin:0; font-size:30px; letter-spacing:-.02em; color:#4527a0; }
.p3-mainHd p{ margin:6px 0 0; font-size:13px; color:#475569; max-width: 85ch; }

.p3-section{ padding:16px 18px; border-bottom:1px solid #e2e8f0; }
.p3-section:last-child{ border-bottom:none; }
.p3-sectionTitle{ display:flex; justify-content:space-between; align-items:flex-end; gap:10px; margin-bottom:10px; }
.p3-sectionTitle h2{ margin:0; font-size:12px; letter-spacing:.12em; text-transform:uppercase; color:#0f172a; }
.p3-chip{ font-size:12px; color:#475569; border:1px solid #e2e8f0; border-radius:999px; padding:7px 10px; background:#fff; }

.p3-twoCols{ display:grid; grid-template-columns: 1fr 1fr; gap:12px; align-items:start; }
@media (max-width:980px){ .p3-twoCols{ grid-template-columns: 1fr; } }

.p3-list{ display:grid; grid-template-columns: repeat(2, 1fr); gap:10px; margin:0; padding:0; list-style:none; }
@media (max-width:760px){ .p3-list{ grid-template-columns:1fr; } }
.p3-li{ display:flex; gap:10px; align-items:flex-start; padding:10px 12px; border:1px solid #e2e8f0; border-radius:16px; background: linear-gradient(180deg,#fff,#f8fafc); }
.p3-dot{ width:10px; height:10px; border-radius:50%; margin-top:4px; background: linear-gradient(135deg,#0097a7,#4527a0); }
.p3-li b{ display:block; font-size:13px; }
.p3-li span{ display:block; margin-top:2px; font-size:12px; color:#475569; }

.p3-table{ width:100%; border-collapse:separate; border-spacing:0; border:1px solid #e2e8f0; border-radius:16px; overflow:hidden; background:#fff; }
.p3-table th, .p3-table td{ padding:12px; text-align:left; }
.p3-table th{
  font-size:12px; letter-spacing:.08em; text-transform:uppercase; color:#23314c;
  background: linear-gradient(90deg, rgba(69,39,160,.08), rgba(0,151,167,.08));
  border-bottom:1px solid #e2e8f0;
}
.p3-table td{ font-size:13px; border-bottom:1px solid #e2e8f0; }
.p3-table tr:last-child td{ border-bottom:none; }
.right{ text-align:right; }
.muted{ color:#475569; }

.p3-callout{ border:1px solid rgba(244,81,30,.25); background: rgba(244,81,30,.06); border-radius:16px; padding:12px; }
.p3-callout.cyan{ border-color: rgba(0,151,167,.25); background: rgba(0,151,167,.06); }
.p3-calloutHead{ display:flex; justify-content:space-between; align-items:flex-start; gap:10px; margin-bottom:10px; }
.p3-calloutHead b{ color:#f4511e; letter-spacing:.08em; text-transform:uppercase; font-size:12px; }
.p3-callout.cyan .p3-calloutHead b{ color:#0097a7; }
.p3-pillSm{ font-size:12px; color:#475569; border:1px solid #e2e8f0; border-radius:999px; padding:7px 10px; background:#fff; }
.p3-note{ margin-top:10px; font-size:12px; color:#475569; }

.p3-timeline{ display:grid; gap:10px; }
.p3-step{
  display:grid; grid-template-columns: 110px 1fr;
  gap:10px; padding:12px; border-radius:16px;
  border:1px solid #e2e8f0; background: linear-gradient(180deg,#fff,#f8fafc);
}
.p3-t{
  display:inline-flex; justify-content:center; align-items:center;
  padding:8px 10px; border-radius:14px;
  color:#fff; background: linear-gradient(135deg,#4527a0,#0097a7);
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono","Courier New", monospace;
  font-size:12px; width:fit-content; height:fit-content;
}
.p3-step b{ display:block; font-size:13px; }
.p3-step span{ display:block; margin-top:4px; color:#475569; font-size:12px; }

.p3-footer{
  margin-top: 6px;
  display:flex; flex-wrap:wrap; gap:10px;
  justify-content:space-between; align-items:center;
  color:#475569; font-size:12px;
}
</style>
