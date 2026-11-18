library(data.table)

df <- fread("datapackages/ppo/data/orcamento_despesa.csv", encoding = "UTF-8")

base <- copy(df)
names(base) <- toupper(names(base))
df$fonte_cod <- relatorios::is_fonte_stn_desp(base)

fwrite(df, "volume6/data/orcamento_despesa_fonte_stn.csv")
