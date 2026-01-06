// src/utils/date.js

/**
 * Converte uma data para string no formato YYYYMMDD.
 * Aceita Date, "YYYY-MM-DD" (input date), "YYYY/MM/DD" e retorna null se inválido.
 */
export function yyyymmdd(value) {
  if (!value) return null;

  // Se vier Date
  if (value instanceof Date) {
    if (isNaN(value.getTime())) return null;
    const y = value.getFullYear();
    const m = String(value.getMonth() + 1).padStart(2, "0");
    const d = String(value.getDate()).padStart(2, "0");
    return `${y}${m}${d}`;
  }

  // Se vier string (ex: "2026-01-05" ou "2026/01/05")
  if (typeof value === "string") {
    const s = value.trim();
    if (!s) return null;

    // Normaliza separadores
    const norm = s.replace(/\//g, "-");

    // Espera "YYYY-MM-DD"
    const m = norm.match(/^(\d{4})-(\d{2})-(\d{2})$/);
    if (!m) return null;

    const yyyy = m[1];
    const mm = m[2];
    const dd = m[3];
    return `${yyyy}${mm}${dd}`;
  }

  return null;
}

/**
 * Retorna "YYYY-MM-DD" (bom para v-model em input type=date)
 */
export function toIsoDateInput(value) {
  if (!value) return null;
  const d = value instanceof Date ? value : new Date(value);
  if (isNaN(d.getTime())) return null;
  return d.toISOString().slice(0, 10);
}
