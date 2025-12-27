<template>
  <div class="sobre-page">
    <div class="sobre-hero">
      <div class="sobre-hero__inner">
        <div class="hero-title">
          <div class="hero-title__top">Sobre o</div>
          <div class="hero-title__main">Egis</div>
          <div class="hero-title__line"></div>
        </div>

        <div class="hero-badges">
          <span class="chip chip--purple">Web</span>
          <span class="chip chip--purple">Mobile</span>
          <span class="chip chip--purple">Desktop</span>
          <span class="chip chip--orange">Versão oficial</span>
        </div>
      </div>
    </div>

    <div class="sobre-wrap" style="margin-top: 50px">
      <div class="sobre-card dx-card responsive-paddings">
        <div class="sobre-card__top">
          <div class="logo-box" />
          <div class="sobre-card__meta">
            <div class="sobre-subtitle">Global Business Solution</div>
            <div class="sobre-version">
              <span class="chip chip--orange">2.0.0001.23</span>
              <span class="chip chip--ghost">64 bits</span>
            </div>
          </div>
        </div>

        <div class="sobre-divider"></div>

        <p class="sobre-texto">
          O <strong>Egis</strong> é uma suíte de soluções
          <strong>Web, Mobile e Desktop</strong> desenvolvida pela
          <strong>GBS Tecnologia</strong> para apoiar a gestão do seu negócio
          com segurança, performance e confiabilidade.
        </p>

        <div class="sobre-grid">
          <div class="sobre-item">
            <span class="dot dot--orange"></span>
            <div>
              <div class="sobre-item__title">Ambiente integrado</div>
              <div class="sobre-item__desc">
                Continuidade e consistência das informações entre plataformas.
              </div>
            </div>
          </div>

          <div class="sobre-item">
            <span class="dot dot--orange"></span>
            <div>
              <div class="sobre-item__title">Arquitetura 64 bits</div>
              <div class="sobre-item__desc">
                Mais desempenho no processamento e melhor uso do hardware.
              </div>
            </div>
          </div>

          <div class="sobre-item">
            <span class="dot dot--orange"></span>
            <div>
              <div class="sobre-item__title">Módulos e ferramentas</div>
              <div class="sobre-item__desc">
                Rotinas operacionais, análise gerencial e tomada de decisão.
              </div>
            </div>
          </div>

          <div class="sobre-item">
            <span class="dot dot--orange"></span>
            <div>
              <div class="sobre-item__title">Atualizações constantes</div>
              <div class="sobre-item__desc">
                Acompanhamento das exigências fiscais, legais e de mercado.
              </div>
            </div>
          </div>
        </div>

        <div class="sobre-footer">
          <div class="suporte">
            <div class="suporte__title">Suporte</div>
            <div class="suporte__desc">
              Dúvidas ou necessidade de suporte?
              <a class="suporte__link" href="mailto:suporte@gbsnet.com.br">
                suporte@gbsnet.com.br
              </a>
            </div>
          </div>

          <div class="sobre-watermark">GBS • Egis</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "EgisSobre",
};
</script>

<style lang="scss">
.sobre-page {
  min-height: 100%;
  background: #f6f7fb;
}

/* HERO topo */
.sobre-hero {
  padding: 18px 16px 0;
  background: linear-gradient(135deg, #2A2A2A 0%, #353536 40%, #ff7043 250%);
  margin: 5px;
  border-radius: 10px;
}

.sobre-hero__inner {
  max-width: 980px;
  margin: 0 auto;
  padding: 18px 12px 24px;
}

.hero-title {
  color: #fff;
  text-align: center;
}

.hero-title__top {
  font-size: 14px;
  opacity: 0.9;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.hero-title__main {
  font-size: 34px;
  font-weight: 800;
  margin-top: 4px;
}

.hero-title__line {
  width: 90px;
  height: 3px;
  margin: 12px auto 0;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.85);
}

.hero-badges {
  margin-top: 14px;
  display: flex;
  justify-content: center;
  gap: 8px;
  flex-wrap: wrap;
}

/* CARD */
.sobre-wrap {
  padding: 14px 16px 28px;
}

.sobre-card {
  max-width: 980px;
  margin: -14px auto 0; /* sobe card por cima do hero */
  background: #fff;
  border-radius: 16px;
  border: 1px solid rgba(20, 20, 20, 0.08);
  box-shadow: 0 10px 30px rgba(30, 18, 70, 0.12);
  padding: 18px 18px 16px;
  position: relative;
  overflow: hidden;
}

/* detalhe lateral */
.sobre-card::before {
  content: "";
  position: absolute;
  left: 0;
  top: 0;
  width: 6px;
  height: 100%;
  background: linear-gradient(180deg, #ff7043, #5e35b1);
}

.sobre-card__top {
  display: flex;
  gap: 14px;
  align-items: center;
  padding-left: 8px;
}

.logo-box {
  height: 56px;
  width: 170px;
  background-image: url("http://www.egisnet.com.br/img/logo_gbstec_sistema.png");
  background-size: contain;
  background-repeat: no-repeat;
  background-position: left center;
}

.sobre-card__meta {
  flex: 1;
  min-width: 180px;
}

.sobre-subtitle {
  font-weight: 700;
  color: #5e35b1;
  line-height: 1.1;
}

.sobre-version {
  margin-top: 8px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.sobre-divider {
  height: 1px;
  background: rgba(0, 0, 0, 0.08);
  margin: 14px 0 14px;
}

.sobre-texto {
  padding-left: 8px;
  color: #2b2b2b;
  line-height: 1.55;
  font-size: 15px;
}

.sobre-texto strong {
  color: #5e35b1;
}

.sobre-grid {
  margin-top: 14px;
  padding-left: 8px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.sobre-item {
  display: flex;
  gap: 10px;
  padding: 12px 12px;
  border-radius: 12px;
  background: #fbfbff;
  border: 1px solid rgba(94, 53, 177, 0.08);
}

.sobre-item__title {
  font-weight: 800;
  color: #2b2b2b;
  margin-bottom: 2px;
}

.sobre-item__desc {
  color: #444;
  font-size: 13px;
  line-height: 1.45;
}

.dot {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  margin-top: 6px;
  flex: 0 0 auto;
}

.dot--orange {
  background: #ff7043;
}

.sobre-footer {
  margin-top: 16px;
  padding-left: 8px;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 12px;
  flex-wrap: wrap;
}

.suporte__title {
  font-weight: 800;
  color: #5e35b1;
  margin-bottom: 2px;
}

.suporte__desc {
  color: #333;
  font-size: 13px;
}

.suporte__link {
  color: #ff7043;
  font-weight: 800;
  text-decoration: none;
}

.suporte__link:hover {
  text-decoration: underline;
}

.sobre-watermark {
  color: rgba(0, 0, 0, 0.35);
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  font-size: 11px;
}

/* CHIPS */
.chip {
  display: inline-flex;
  align-items: center;
  padding: 6px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.02em;
}

.chip--purple {
  background: rgba(255, 255, 255, 0.16);
  color: #fff;
  border: 1px solid rgba(255, 255, 255, 0.22);
}

.chip--orange {
  background: rgba(255, 112, 67, 0.14);
  color: #ff7043;
  border: 1px solid rgba(255, 112, 67, 0.25);
}

.chip--ghost {
  background: rgba(94, 53, 177, 0.10);
  color: #5e35b1;
  border: 1px solid rgba(94, 53, 177, 0.18);
}

/* Responsivo */
@media (max-width: 860px) {
  .sobre-grid {
    grid-template-columns: 1fr;
  }
  .logo-box {
    width: 150px;
  }
}
</style>
