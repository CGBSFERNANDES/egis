// ./src/utils.js
export const isDef = v => v !== undefined && v !== null
export const isObject = v => Object.prototype.toString.call(v) === '[object Object]'
export const toArray = v => Array.isArray(v) ? v : (isDef(v) ? [v] : [])
export const ensureString = v => v == null ? '' : String(v)
export function downloadBlob (blob, filename) {
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename || 'download'
  document.body.appendChild(a)
  a.click()
  a.remove()
  URL.revokeObjectURL(url)
}
