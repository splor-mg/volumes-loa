# ========================================================================================================
# Organização de T19. Demonstrativo da Aplicação de Recursos no Amparo e Fomento à Pesquisa
options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

sumario = data.table(read.table("volume2/data/sumario.txt", header=T, sep="\t",stringsAsFactors =F))

receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
loa_rec = geraLoa_rec(receita)
setnames(loa_rec, "VL_LOA_REC", "VL_REC")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
loa_desp = geraLoa_desp(qdd)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

loa_desp = mergeDT(loa_desp, sumario, by.x="UO_COD", by.y="COD_UO")

if(length(loa_desp[, unique(merge)])>1){
  
  stop("T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa: Há UO's que não possuem seu descritivo ",
       "em volume2/data/sumario.txt. É o caso de:",
       paste(loa_desp[merge!="Em ambos os bancos", unique(UO_COD)], collapse=", "), "\n")
  
}

# =================== Receita Orçamentária Corrente Ordinária - Base de Cálculo =========================
parteA_desc =  "A - Receita Orçamentária Corrente Ordinária - Base de Cálculo"

parteA = data.table(cod=1, espec = parteA_desc, valor= loa_rec[is_fapemig_rec(loa_rec), sum(VL_REC)])

parteA = rbind(parteA, data.table(cod=4, 
                                  espec = "B - 1% SOBRE A BASE DE CÁLCULO", 
                                  valor = parteA[cod==1, valor]*0.01))

# ================== Aplicação de Recursos Ordinários Destinados ao Amparo e Fomento à Pesquisa ========

parteB_desc =  "C - APLICAÇÃO DE RECURSOS ORDINÁRIOS DESTINADOS AO AMPARO E FOMENTO À PESQUISA"

parteB = loa_desp[is_fapemig_desp(loa_desp), list(valor = sum(VL_DESP)), 
                  by=list(cod = UO_COD, espec = UO)]

parteB = rbind(data.table(cod=5, 
                          espec = parteB_desc, 
                          valor=NA), 
               parteB)
# ============== Agregando... ===========================================================================

demonstr = rbindlist(list(parteA, parteB), use.names = T)

demonstr[, cod:=as.character(cod)]
demonstr = demonstr[,lapply(.SD, formatarNum)]
demonstr[, espec:=correcaoCaracteresEspeciais(espec, caracteres)]

write.table(demonstr, "volume1/data/T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
