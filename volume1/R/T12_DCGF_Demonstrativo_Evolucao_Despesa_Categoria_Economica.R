# =================================================================================================
# Organização de T12. Demonstrativo da Evolução da Despesa por Categoria Econômica
options(warn = 1, scipen = 999)

suppressMessages(require(relatorios))
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
loa_desp = geraLoa_desp(qdd)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

ano_estimado = loa_desp[, unique(ANO)]
ano_orcado = ano_estimado-1
ano_exec = ano_orcado-1

exec_desp = execucao::exec_desp[ANO==ano_exec,]
setnames(exec_desp, "VL_EMP", "VL_DESP")

loa = execucao::loa_desp[ANO==ano_orcado,]
setnames(loa, "VL_LOA_DESP", "VL_DESP")

desp = rbind(loa_desp, exec_desp, fill=T)
desp = rbind(desp, loa, fill=T)

# existe um de-para no pacote relatórios que pode nao ser atualizado ano a ano, 
# manter um valor de ano que esteja no de-para ou pedir para atualizar pacote relatórios (andrey 09-2022)
desp[, ANO_TEMP:= ANO]; desp[, ANO:=2022]
desp = adiciona_desc(desp, columns = "GRUPO")
desp[, ANO:= ANO_TEMP]; desp[, ANO_TEMP:=NULL]

desp[, CATEGORIA_DESC := ifelse(CATEGORIA_COD==3, "Despesas Correntes", 
                         ifelse(CATEGORIA_COD==4, "Despesas de Capital",
                         ifelse(CATEGORIA_COD==9, "Reserva de Contigência", "ign")))]

desp_n1 = desp[MODALIDADE_COD!=91, list(VL_DESP = sum(VL_DESP)), 
               by=list(ordem = CATEGORIA_COD*10, espec = CATEGORIA_DESC, ANO)]

total = desp_n1[,list(VL_DESP = sum(VL_DESP), espec = "TOTAL", ordem = 100), by=list(ANO)]

desp_n2 = desp[MODALIDADE_COD!=91, list(VL_DESP = sum(VL_DESP)), 
               by=list(ordem = as.numeric(paste0(CATEGORIA_COD,GRUPO_COD)), espec = GRUPO_DESC, ANO)]

evol = rbindlist(list(desp_n1, desp_n2, total), use.names = T)

evol <- dcast(evol, ordem + espec ~ paste0("VL_DESP_", ANO), value.var = "VL_DESP", fill=0)

evol = evol[ordem!=99,]

index = which(names(evol) %in% paste0("VL_DESP_", ano_exec:ano_estimado))
  
novos_nomes = c("ordem", "espec")

for(l in index){
  ano = substr(names(evol)[l], 9,12)
  total_ano = as.numeric(evol[nrow(evol),l, with=F])
    
  evol[,paste0("perc_",ano):= round(evol[,l, with=F]*100 /  total_ano, 2)]
  novos_nomes = union(novos_nomes, c(paste0("VL_DESP_", ano), paste0("perc_", ano)))
}

setcolorder(evol, novos_nomes)

evol[, espec:=correcaoCaracteresEspeciais(espec, caracteres)]
evol = evol[,lapply(.SD, formatarNum)]

write.table(evol, "volume1/data/T12_DCGF_Demonstrativo_Evolucao_Despesa_Categoria_Economica.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

