# Tabela 2: DEMONSTRATIVO DA RECEITA CORRENTE FISCAL
options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
receita = geraLoa_rec(receita)

receita_corrente = receita[nat(RECEITA_COD,1), sum(VL_LOA_REC)]
deducao = receita[nat(RECEITA_COD, 9), sum(VL_LOA_REC)]

demonst = data.table(espec = c("RECEITAS CORRENTES", 
                               "DEDUÇÃO DA RECEITA CORRENTE - FORMAÇÃO DO FUNDEB E TRANSFERÊNCIA MUNICÍPIOS",
                               "RECEITA CORRENTE FISCAL"),
                     valor = c(receita_corrente,
                               deducao,
                               receita_corrente + deducao))

demonst = demonst[, lapply(.SD, formatarNum)]

write.table(demonst, "volume1/data/T2_DCGF_DEMONSTRATIVO_RECEITA_CORRENTE_FISCAL.txt", quote = F, 
            sep = "\t", na = "", dec = ",", row.names = FALSE)
