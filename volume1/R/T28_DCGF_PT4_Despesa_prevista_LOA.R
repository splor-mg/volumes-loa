# ====================================================================================
# Despesa Prevista para LOA
options(warn=1, scipen = 999)
suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R", encoding = "UTF-8")

source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
desp = geraLoa_desp(qdd)

desp = desp[FONTE_COD %in% fontes_uniao, 
            list(VL_LOA_DESP = sum(VL_LOA_DESP)), 
            by=list(UO_COD, PROGRAMA_COD, ANO)]

desp = adiciona_desc_volumes(desp, column = "UO")
desp = adiciona_desc_volumes(desp, column = "PROGRAMA")
desp = desp[order(UO_COD, PROGRAMA_COD)]

desp = rbind(desp, desp[, lapply(.SD, sum), .SDcols=6], fill=T)
desp[nrow(desp), c("UO_SIGLA", "PROGRAMA_DESC"):="TOTAL"]

desp[, VL_LOA_DESP := formatarNum(VL_LOA_DESP)]
desp[, PROGRAMA_DESC := correcaoCaracteresEspeciais(PROGRAMA_DESC, caracteres)]

desp[, ANO:=NULL]

desp[, FONTE_EXEC := NA_character_]
desp[1, FONTE_EXEC := FONTES_CONSIDERADAS]

write.table(desp, "volume1/data/T28_DCGF_PT4_Despesa_prevista_LOA.txt", quote = F, 
            sep = "\t", na = "", dec = ",", row.names = FALSE)
