curl -X POST "http://localhost:3000/api/egis/export" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "nm_modelo": "Nota Fiscal Eletrônica",
      "cd_parametro": 0,
      "modelo": "NFE_COMPLETA",
      "dt_inicial": "2025-10-01",
      "dt_final":   "2025-10-31"
    }
  ]'

  curl -X POST "http://localhost:3000/api/egis/export" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "cd_modelo": 2,                      // Nota Fiscal do Consumidor
      "cd_parametro": 15,
      "modelo": "NFCe_Sintetico",
      "dt_inicial": "2025-10-01",
      "dt_final":   "2025-10-31",
      "filtros": { "uf": "SP" }
    }
  ]'

