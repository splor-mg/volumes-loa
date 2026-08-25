# =================================================================================================
# Organização de T6. Demonstrativo da Evolução da Receita por Categoria Econômica
options(warn = 1, scipen = 999)

suppressMessages(require(relatorios))
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")


# ====== LOAD das funções para abertura dos bancos necessários ===================

class_receita = ler_novaReceita("bancos/manual/desc_classificacao_receita.xlsx")

receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
loa_rec = geraLoa_rec(receita)
setnames(loa_rec, "VL_LOA_REC", "VL_REC")

ano_estimado = loa_rec[, unique(ANO)]
ano_orcado = ano_estimado-1
ano_exec = (ano_orcado-3):(ano_orcado-1)

exec_rec = execucao::exec_rec[ANO %in% ano_exec,]
setnames(exec_rec, "VL_EFET_AJUST", "VL_REC")

loa = execucao::loa_rec[ANO==ano_orcado,]
setnames(loa, "VL_LOA_REC", "VL_REC")

rec = rbind(loa_rec, exec_rec, fill=T)
rec = rbind(rec, loa, fill=T)

rec = rec[!nat(RECEITA_COD, 7),]

rec_antigo = rec[nchar(RECEITA_COD)==10, ]
rec_novo = rec[nchar(RECEITA_COD)>10, ]

rec_antigo = mergeDT(rec_antigo, add_de_para_receita_tbl, by="RECEITA_COD", all=T)
rec_antigo = rec_antigo[!merge=="Apenas no Banco Y",]

receitas_sem_correspondencia = rec_antigo[merge=="Apenas no Banco X" & !nat(RECEITA_COD, 176, 21, 247, 25),
                                          unique(paste(RECEITA_COD, RECEITA_DESC, sep=" - "))]

if(length(receitas_sem_correspondencia)>0){
  stop("Há receitas antigas que não encontraram correspondência no banco da nova classificação ",
       "(relatorios::add_de_para_receita_tbl). Tratar as seguintes receitas\n",
       paste(receitas_sem_correspondencia, collapse="\n"),
       ". \n Ao proceder a correção, só preciso dos dois primeiros dígitos de RECEITA_COD_2")
}

# =========================================================================================
# Para o caso em que RECEITA_COD está sem correspondência com RECEITA_COD_2,
# uma possível solução é simplesmente indicar os dois primeiros dígitos da
# RECEITA_COD_2 relativos a RECEITA_COD

rec_antigo[merge=="Apenas no Banco X" & nat(RECEITA_COD, 176), RECEITA_COD_2:= "17"]
rec_antigo[merge=="Apenas no Banco X" & nat(RECEITA_COD, 21),  RECEITA_COD_2:= "21"]
rec_antigo[merge=="Apenas no Banco X" & nat(RECEITA_COD, 247), RECEITA_COD_2:= "24"]
rec_antigo[merge=="Apenas no Banco X" & nat(RECEITA_COD, 25),  RECEITA_COD_2:= "29"]

rec_antigo = rec_antigo[, list(ANO, RECEITA_COD = RECEITA_COD_2, VL_REC)]

rec = rbind(rec_antigo, rec_novo, fill=T)

#rec = rec[!nat(RECEITA_COD, 999), ]

painel_rec = rbind(rec[, list(VL_REC = sum(VL_REC, na.rm = T)), 
                       by=list(RECEITA_COD = substr(RECEITA_COD,1,1), ANO)],
                   rec[!nat(RECEITA_COD, 9), list(VL_REC = sum(VL_REC, na.rm = T)), 
                       by=list(RECEITA_COD = substr(RECEITA_COD,1,2), ANO)])

painel_rec[, RECEITA_COD:=ifelse(nchar(RECEITA_COD)==1, 
                                 as.numeric(paste0(RECEITA_COD, paste0(rep(0,12), collapse=""))),
                                 as.numeric(paste0(RECEITA_COD, paste0(rep(0,11), collapse=""))))]

painel_rec = painel_rec[order(RECEITA_COD)]
painel_rec[, ANO := paste0("VL_", ANO)]

painel_rec = dcast(painel_rec, "RECEITA_COD ~ ANO", value.var = "VL_REC", 
                   fun.aggregate = function(x) round(sum(x)), fill=0)

painel_rec = mergeDT(painel_rec, class_receita, by="RECEITA_COD", all.x=T)

painel_rec = painel_rec[, c("RECEITA_COD", "RECEITA_DESC", paste0("VL_", min(ano_exec):ano_estimado)), with=F]

indices_ano = which(names(painel_rec) %in% paste0("VL_", min(ano_exec):ano_estimado))

painel_rec = rbind(painel_rec, 
                   painel_rec[grepl("^\\d{1}0{12}", RECEITA_COD), lapply(.SD, sum), .SDcols=indices_ano], fill=T)

painel_rec[nrow(painel_rec), RECEITA_DESC:="TOTAL"]

novos_nomes = c("RECEITA_COD", "RECEITA_DESC")

for(l in indices_ano){
  ano = substr(names(painel_rec)[l], 4,7)
  
  total_ano = as.numeric(painel_rec[nrow(painel_rec),l, with=F])
  
  painel_rec[, paste0("perc_",ano):= round(painel_rec[,l, with=F]*100 / total_ano, 2)]
  novos_nomes = union(novos_nomes, c(names(painel_rec)[l], paste0("perc_", ano)))
}

setcolorder(painel_rec, novos_nomes)

painel_rec[, RECEITA_DESC:=correcaoCaracteresEspeciais(RECEITA_DESC, caracteres)]
painel_rec = painel_rec[, lapply(.SD, formatarNum)]

write.table(painel_rec, "volume1/data/T6_DCGF_Demonstrativo_Evolucao_Receita_por_Categoria_Economica.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

