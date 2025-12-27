// services/agent.js
const AGENT = 'http://127.0.0.1:3030';

export async function isAgentAlive() {
  try {
    const r = await fetch(`${AGENT}/health`, { cache: 'no-store' });
    return r.ok;
  } catch { return false; }
}

export async function printDanfe(chave, banco) {
  // silencioso (POST 204)
  await fetch(`${AGENT}/print/nfce`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ chave, banco }),
    keepalive: true
  });
}
