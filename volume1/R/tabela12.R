# =================================================================================================
# Organização de T12. Demonstrativo da Evolução da Despesa por Categoria Econômica
options(warn = 1, scipen = 999)

suppressMessages(require(relatorios))
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

qdd = trataQDD_Fiscal("datapackages/ppo/data/orcamento_despesa.csv", F)
loa_desp = geraLoa_desp(qdd)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

ano_estimado = loa_desp[, unique(ANO)]
ano_orcado = ano_estimado-1
ano_exec = ano_orcado-1

exec_desp = fread(cmd = paste0("gzip -dc datapackages/siafi_", ano_exec, "/data/execucao.csv.gz"),
                  select = c("ano", "grupo_cod", "modalidade_cod", "vlr_empenhado"))
exec_desp = exec_desp[, list(ANO = ano,
                             CATEGORIA_COD = ifelse(grupo_cod %in% 1:3, 3,
                                             ifelse(grupo_cod %in% 4:6, 4, 9)),
                             GRUPO_COD = grupo_cod,
                             MODALIDADE_COD = modalidade_cod,
                             VL_DESP = vlr_empenhado)]

loa = execucao::loa_desp[ANO==ano_orcado,]
setnames(loa, "VL_LOA_DESP", "VL_DESP")

desp = rbind(loa_desp, exec_desp, fill=T)
desp = rbind(desp, loa, fill=T)

desp = adiciona_desc_volumes(desp, column = "GRUPO")

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

write.table(evol, "volume1/data/tabela12.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

