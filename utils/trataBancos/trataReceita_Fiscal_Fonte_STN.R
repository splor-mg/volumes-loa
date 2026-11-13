library(data.table)

df <- fread("bancos/PPO/orcamento_receita.csv", encoding = "UTF-8", colClasses = list(character = "receita_cod"))

base <- copy(df)
names(base) <- toupper(names(base))
base[, RECEITA_COD := as.numeric(RECEITA_COD)]
df$fonte_cod <- relatorios::is_fonte_stn_rec(base)

fonte_stn_desc <- as.data.table(readxl::read_excel("bancos/manual/desc_fontes_de_recursos_stn.xlsx"))
df[, fonte_desc := fonte_stn_desc$CLASSIFICACAO[match(fonte_cod, fonte_stn_desc$CODIGO)]]

fwrite(df, "bancos/PPO/orcamento_receita_fonte_stn.csv")
