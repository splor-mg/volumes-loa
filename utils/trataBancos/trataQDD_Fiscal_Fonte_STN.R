library(data.table)

df <- fread("bancos/PPO/orcamento_despesa.csv", encoding = "UTF-8")

base <- copy(df)
names(base) <- toupper(names(base))
df$fonte_cod <- relatorios::is_fonte_stn_desp(base)

fwrite(df, "bancos/PPO/orcamento_despesa_fonte_stn.csv")
