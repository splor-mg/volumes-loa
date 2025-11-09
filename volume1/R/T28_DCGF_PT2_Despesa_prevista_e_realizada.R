# ====================================================================================
# Despesa prevista e realizada no exercício vigente

options(warn=1, scipen = 999)
suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R")

loa_desp = execucao::loa_desp[ANO==ano_exercicio,]
setnames(loa_desp, tolower(names(loa_desp)))
desp_real = data.table(read_excel("bancos/SISOR/exec_desp_realizada.xlsx", sheet=1))
setnames(desp_real, tolower(names(desp_real)))
# ==========================================
# exec_desp_realizada.xlsx
# No BO copiei um exec_desp e inseri a coluna de "Valor Despesa Realizada"
# ==========================================

loa_desp = loa_desp[fonte_cod %in% fontes_uniao, 
                    list(vl_loa_desp = sum(vl_loa_desp)), 
                    by=list(uo_cod, programa_cod, ano)]

# desp_real = desp_real[FONTE_COD %in% fontes_uniao & MES_COD <= mes, 
#                       list(VL_DESP_REALIZ = round(sum(`Valor Despesa Realizada`), 0)), 
#                       by=list(UO_COD, PROGRAMA_COD, ANO)]


#mudança de valor de despesa realizada, gerou erro na LOA 2023
desp_real = desp_real[fonte_cod %in% fontes_uniao & mes_cod <= mes, 
                      list(vl_desp_realiz = round(sum(vl_desp_realizada), 0)), 
                      by=list(uo_cod, programa_cod, ano)]


despesa = mergeDT(loa_desp, desp_real, by=c("ano", "uo_cod", "programa_cod"), all=T)
despesa[, merge:=NULL]
despesa[is.na(despesa)] = 0

despesa = adiciona_desc(despesa, columns = c("uo", "programa"))

despesa = rbind(despesa, despesa[, lapply(.SD, sum), .SDcols=6:7], fill=T)
despesa = despesa[nrow(despesa), c("UO_SIGLA", "PROGRAMA_DESC"):="TOTAL"]

despesa[, c("MES", "FONTE_EXEC") := NA_character_]
despesa[1,c("MES", "FONTE_EXEC") := list(mes_executado, FONTES_CONSIDERADAS)]

indice_vl = which(grepl("VL.+", names(despesa)))

despesa = despesa[, (indice_vl) := lapply(.SD, formatarNum), .SDcols=indice_vl]
despesa[, PROGRAMA_DESC := correcaoCaracteresEspeciais(PROGRAMA_DESC, caracteres)]

write.table(despesa, "volume1/data/T28_DCGF_PT2_Despesa_prevista_e_realizada.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE, fileEncoding = "UTF-8")
