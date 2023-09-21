# =================================================================================================
# Organização de 13. Demonstrativo Consolidado da Despesa
options(warn = 1, scipen = 999)

suppressMessages(require(relatorios))
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
desp = geraLoa_desp(qdd)
setnames(desp, "VL_LOA_DESP", "VL_DESP")

#================================================================================
# existe um de-para no pacote relatórios que podem esquecer de atualizar ano a 
# ano, Solucao atual: manter um valor setado de ano (abaixo)  que esteja no 
# de-para ou pedir para atualizar pacote relatórios (Andrey 09-2022)
#==============================================================================
desp[, ANO:=2022]
desp = adiciona_desc_volumes(desp, "GRUPO")

desp[, CATEGORIA_DESC := ifelse(CATEGORIA_COD==3, "Despesas Correntes", 
                         ifelse(CATEGORIA_COD==4, "Despesas de Capital",
                         ifelse(CATEGORIA_COD==9, "Reserva de Contigência", "ign")))]

desp[, recurso := "outras"]
desp[FONTE_COD==10 | FONTE_COD==11 | FONTE_COD==12 | FONTE_COD==15 , recurso := "tesouro"]

desp_n1 = desp[MODALIDADE_COD!=91, list(VL_DESP = sum(VL_DESP)), 
               by=list(ordem = CATEGORIA_COD*10, espec = CATEGORIA_DESC, recurso)]

total = desp_n1[, list(VL_DESP = sum(VL_DESP), espec = "TOTAL", ordem = 100), by=list(recurso)]

desp_n2 = desp[MODALIDADE_COD!=91, list(VL_DESP = sum(VL_DESP)), 
               by=list(ordem = as.numeric(paste0(CATEGORIA_COD,GRUPO_COD)),  espec = GRUPO_DESC, recurso)]

evol = rbindlist(list(desp_n1, desp_n2, total), use.names = T)

evol <- dcast(evol, ordem + espec ~ recurso, value.var = "VL_DESP", fill=0)

evol = evol[ordem!=99,]
evol[, total := outras + tesouro]

setcolorder(evol, c("ordem", "espec", "tesouro", "outras", "total"))

evol[, espec := correcaoCaracteresEspeciais(espec, caracteres)]
evol = evol[,lapply(.SD, formatarNum)]

write.table(evol, "volume1/data/T13_DCGF_Demonstrativo_Consolidado_Despesa.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

