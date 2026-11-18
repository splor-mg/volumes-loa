library(data.table)

ANO_DOC = readLines(here::here("utils", "ano.txt"))
periodo_vigencia_ref <- paste0(ANO_DOC, "-01-01")

fonte_stn_desc <- fread("datapackages/fonte_stn/data/fonte_stn.csv")
result <- fonte_stn_desc[
  periodo_vigencia_ref >= DT_INICIO_VIGENCIA & periodo_vigencia_ref < DT_FIM_VIGENCIA,
  .(CODIGO = FONTE_STN_COD, CLASSIFICACAO = FONTE_STN_DESCRICAO, INTERPRETACAO)
]

writexl::write_xlsx(list(Plan1 = result), "volume6/data/desc_fontes_de_recursos_stn.xlsx")
