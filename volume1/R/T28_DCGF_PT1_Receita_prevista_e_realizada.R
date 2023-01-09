## Receita prevista e realizada em 2016
options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R")

# ====================================================================================
# Receita prevista e realizada no exercício vigente


loa_rec = execucao::loa_rec[ANO==ano_exercicio,]
exec_rec = reest::ler_exec_rec("bancos/SISOR/exec_rec.xlsx")
exec_rec = exec_rec[VL_EFET_AJUST != 0, ]


loa_rec = loa_rec[FONTE_COD %in% fontes_uniao, 
                  list(VL_LOA_REC = sum(VL_LOA_REC)), 
                  by=list(RECEITA_COD, RECEITA_DESC)]

exec_rec = exec_rec[FONTE_COD %in% fontes_uniao & MES_COD <= mes, 
                    list(VL_EFET_AJUST = round(sum(VL_EFET_AJUST),0)), 
                    by=list(RECEITA_COD, RECEITA_DESC)]

receita = mergeDT(loa_rec, exec_rec, by="RECEITA_COD", all=T)
receita[, RECEITA_DESC := RECEITA_DESC.x]
receita[merge=="Apenas no Banco Y", RECEITA_DESC := RECEITA_DESC.y]

receita = receita[, list(RECEITA_COD, RECEITA_DESC, previsto = VL_LOA_REC, efet_ajust = VL_EFET_AJUST)]
receita[is.na(receita)] = 0

receita = rbind(receita, receita[, lapply(.SD, sum), .SDcols = 3:4], fill=T)
receita[nrow(receita), RECEITA_DESC:="TOTAL"]

receita = receita[, lapply(.SD, formatarNum)]
receita[, RECEITA_DESC := correcaoCaracteresEspeciais(RECEITA_DESC, caracteres)]

receita[, c("ANO", "MES", "FONTE_EXEC") := NA_character_]
receita[1,c("ANO", "MES", "FONTE_EXEC") := list(as.character(ano_exercicio), mes_executado, FONTES_CONSIDERADAS)]

write.table(receita, "volume1/data/T28_DCGF_PT1_Receita_prevista_e_realizada.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

