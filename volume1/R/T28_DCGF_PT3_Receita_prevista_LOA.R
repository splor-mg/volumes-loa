# ====================================================================================
# Receita Prevista para LOA

options(warn=1, scipen = 999)
suppressMessages(require(relatorios))

source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R", encoding = "UTF-8")

source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")

receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
rec = geraLoa_rec(receita)

rec = rec[!nat(RECEITA_COD, 999) & FONTE_COD %in% fontes_uniao, 
          list(VL_LOA_REC = sum(VL_LOA_REC)), 
          by=list(RECEITA_COD, RECEITA_DESC)][order(RECEITA_COD)]

rec = rbind(rec, rec[, lapply(.SD, sum), .SDcols=3], fill=T)
rec[nrow(rec), RECEITA_DESC:="TOTAL"]

rec[, VL_LOA_REC := formatarNum(VL_LOA_REC)]
rec[, RECEITA_DESC := correcaoCaracteresEspeciais(RECEITA_DESC, caracteres)]

rec[, FONTE_EXEC := NA_character_]
rec[1, FONTE_EXEC := FONTES_CONSIDERADAS]

write.table(rec, "volume1/data/T28_DCGF_PT3_Receita_prevista_LOA.txt", quote = F, 
            sep = "\t", na = "", dec = ",", row.names = FALSE)
