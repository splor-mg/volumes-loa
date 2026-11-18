library(data.table)

df <- fread("datapackages/ppo/data/orcamento_receita.csv", encoding = "UTF-8", colClasses = list(character = "receita_cod"))

base <- copy(df)
names(base) <- toupper(names(base))
base[, RECEITA_COD := as.numeric(RECEITA_COD)]
df$fonte_cod <- relatorios::is_fonte_stn_rec(base)

ANO_DOC = readLines(here::here("utils", "ano.txt"))
periodo_vigencia_ref <- paste0(ANO_DOC, "-01-01")

fonte_stn_desc <- fread("datapackages/fonte_stn/data/fonte_stn.csv")
fonte_stn_desc <- fonte_stn_desc[periodo_vigencia_ref >= DT_INICIO_VIGENCIA & periodo_vigencia_ref < DT_FIM_VIGENCIA]
df[, fonte_desc := fonte_stn_desc$FONTE_STN_DESCRICAO[match(fonte_cod, fonte_stn_desc$FONTE_STN_COD)]]

fwrite(df, "volume6/data/orcamento_receita_fonte_stn.csv")
