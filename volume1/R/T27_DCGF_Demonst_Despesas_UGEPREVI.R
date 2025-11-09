# ==================================================================================================================
# Organização de T27. demonstrativo  das  despesas  da  Unidade  de  Gestão Previdenciária  Integrada  -  UGEPREVI
options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Elemento_Item.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

sumario = data.table(read.table("volume2/data/sumario.txt", header=T, sep="\t",stringsAsFactors =F))


loa_desp = trataQDD_Elemento_Item("bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx", T)
setnames(loa_desp, tolower(names(loa_desp)))
qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
qdd = qdd[, list(x=1), by=list(ACAO_COD = ACAO, ACAO_DESC = NOME_ACAO)]

setnames(qdd, tolower(names(qdd)))

loa_desp = mergeDT(loa_desp, qdd, by="acao_cod", all.x=T)

if("Apenas no Banco X" %in% loa_desp[, unique(merge)]){
  warning(paste0("T27_DCGF_Demonst_Despesas_UGEPREVI.R: ACAO_COD presente em BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx ",
                 "mas AUSENTE em BASE_QDD_FISCAL.xlsx: ", 
                 paste(loa_desp[merge=="Apenas no Banco X", unique(ACAO_COD)], collapse=", ")))
}
#loa_desp = geraLoa_desp(qdd)
#setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

loa_desp = loa_desp[is_prev_loa_desp(loa_desp),
                    list(valor = sum(vl_loa_desp)), by=list(uo_cod, acao_cod, acao_desc)]

#loa_desp = loa_desp[UGEPREVI==T, ]
loa_desp = mergeDT(loa_desp, sumario, by.x="uo_cod", by.y="COD_UO", all.x=T)
loa_desp[!grepl("^(PODER|DEFENSORIA).+", poder), poder := paste("PODER", poder)]

total_poder = loa_desp[, list(valor_poder = sum(valor)), by=list(poder)]

loa_desp = mergeDT(loa_desp, total_poder, by="poder")
loa_desp[1, total:=total_poder[, sum(valor_poder)]]

final = data.table(tipo = as.character(), espec = as.character(), valor = as.numeric())

for(p in sort(loa_desp[, unique(poder)])){
  
  final = rbind(final, data.table(tipo = "Poder", espec = p, valor=NA))
  UO_final = data.table(tipo = as.character(), espec = as.character(), valor=as.numeric())
  for(u in sort(loa_desp[poder==p, unique(uo_cod)])){
    
    UO = data.table(tipo = "UO", espec = paste0(u, " - ", unique(loa_desp[uo_cod==u, UO])), valor=NA)
    acoes = loa_desp[uo_cod==u, .(tipo = "Acao", espec = acao_desc, valor, acao_cod)][order(acao_cod)]
    acoes[, acao_cod:=NULL]
    
    UO_final = rbindlist(list(UO_final, UO, acoes), use.names = T)
    
  }
  total = data.table(tipo = "Subtotal", espec = paste0("SUBTOTAL - ", p), valor = total_poder[poder==p, valor_poder])
  final = rbindlist(list(final, UO_final, total), use.names = T)
}

final = rbind(final, data.table(tipo = NA, espec = "TOTAL", valor=sum(total_poder[, valor_poder])))

final = final[,lapply(.SD, formatarNum)]
final[, espec := correcaoCaracteresEspeciais(espec, caracteres)]

write.table(final, "volume1/data/T27_DCGF_Demonst_Despesas_UGEPREVI.txt", quote = F, 
            sep = "\t", na = "", dec = ",", row.names = FALSE)

