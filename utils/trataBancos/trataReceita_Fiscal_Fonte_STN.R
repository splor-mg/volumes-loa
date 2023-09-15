library(data.table)

df <- as.data.table(readxl::read_excel("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx"))
column_order <- names(df)

column_mapping <- c(COD_RECEITA = "RECEITA_COD",
                    COD_FONTE = "FONTE_COD")

setnames(df, names(column_mapping), unname(column_mapping))
fonte_stn <- relatorios::is_fonte_stn_rec(df)
setnames(df, unname(column_mapping), names(column_mapping))
df[, COD_FONTE := fonte_stn]
df$FONTE <- NULL
df$INTERPRETACAO <- NULL

ANO_DOC = readLines(here::here("utils", "ano.txt"))
periodo_vigencia_ref <- paste0(ANO_DOC, "-01-01")

fonte_stn_desc <- as.data.table(readxl::read_excel("bancos/manual/desc_fontes_de_recursos_stn.xlsx"))
names(fonte_stn_desc) <- c("COD_FONTE", "FONTE", "INTERPRETACAO")

result <- fonte_stn_desc[df, on = "COD_FONTE"]
setcolorder(result, column_order)

writexl::write_xlsx(list("BASE_ORCAM_RECEITA_FISCAL" = result), "bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_FONTE_STN.xlsx")
