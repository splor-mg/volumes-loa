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

# ============================================================================================
# Teste com o banco de 2017, convertendo a receita antiga na nova classificação. Os valores
# batem com o publicado

# receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_2017.xlsx", F)
# loa_rec = geraLoa_rec(receita)
# loa_rec[, RECEITA_COD:=as.character(RECEITA_COD)]
# loa_rec = mergeDT(loa_rec, add_de_para_receita_tbl, by="RECEITA_COD", all.x=T)
# loa_rec[, unique(merge)]
# ============================================================================================

receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
loa_rec = geraLoa_rec(receita)
# loa_rec[, RECEITA_COD_2 := RECEITA_COD]
setnames(loa_rec, "VL_LOA_REC", "VL_REC")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
#qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL_2017.xlsx", F)
loa_desp = geraLoa_desp(qdd)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

loa_desp = mergeDT(loa_desp, sumario, by.x="UO_COD", by.y="COD_UO")

if(length(loa_desp[, unique(merge)])>1){
  
  stop("T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa: Há UO's que não possuem seu descritivo ",
       "em volume2/data/sumario.txt. É o caso de:",
       paste(loa_desp[merge!="Em ambos os bancos", unique(UO_COD)], collapse=", "), "\n")
  
}

# =============== A - Receita Orçamentária Corrente Ordinária - Base de Cálculo =========================
parteA_desc =  "A - Receita Orçamentária Corrente Ordinária - Base de Cálculo"

# parteA = data.table(cod=1, espec = parteA_desc, valor= loa_rec[is_fapemig_rec(loa_rec), sum(VL_REC)])
parteA = data.table(cod=1, espec = parteA_desc, valor= loa_rec[is_fapemig_rec(loa_rec), sum(VL_REC)])

# deducao30_Fapemig = loa_rec[is_fapemig_desvinc_rec(loa_rec), sum(VL_REC)*0.3]
# deducao30_Fapemig = loa_rec[is_fapemig_desvinc_rec_3(loa_rec), sum(VL_REC)*0.3]
deducao30_Fapemig = loa_rec[is_fapemig_rec(loa_rec), sum(VL_REC)*0.0]

#parteA = rbind(parteA, data.table(cod=2,
#                                  espec = "B - DESVINCULAÇÃO DE 30% DE IMPOSTOS, TAXAS E MULTAS", 
#                                  valor = deducao30_Fapemig))

#parteA = rbind(parteA, data.table(cod=3, 
#                                  espec = "C - BASE DE CÁLCULO FAPEMIG (A - B)", 
#                                  valor = parteA[cod==1, valor] - deducao30_Fapemig))

parteA = rbind(parteA, data.table(cod=4, 
                                  espec = "B - 1% SOBRE A BASE DE CÁLCULO", 
                                  valor = parteA[cod==1, valor]*0.01))

# =============== E - Aplicação de Recursos Ordinários Destinados ao Amparo e Fomento à Pesquisa ========

parteB_desc =  "C - APLICAÇÃO DE RECURSOS ORDINÁRIOS DESTINADOS AO AMPARO E FOMENTO À PESQUISA"

parteB = loa_desp[is_fapemig_desp(loa_desp), list(valor = sum(VL_DESP)), 
                  by=list(cod = UO_COD, espec = UO)]

parteB = rbind(data.table(cod=5, 
                          espec = parteB_desc, 
                          valor=NA), 
               parteB)


# ============== Agregando... ===========================================================================

demonstr = rbindlist(list(parteA, parteB), use.names = T)

teste = demonstr[cod==4, valor] - demonstr[cod >5, valor]

if(abs(teste)>2){
  warning(paste0("T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa Valor da despesa na fapemig ", 
       demonstr[cod >5, formatarNum(valor)], " diferente do valor de receita ",
       demonstr[cod==4, formatarNum(valor)], " seguindo a regra do 1%\n"))
} else{
  warning("T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa: 1% da base de ",
          "cálculo é diferente do valor da despesa em ", round(teste, 2),
          " Ajustando esse valor na despesa.\n")
  
    #demonstr[cod > 5, valor := valor + round(teste, 0)] #comentando, pois o arrendondamento estava trazendo erros para o demons.
  
}
demonstr[, cod:=as.character(cod)]
demonstr = demonstr[,lapply(.SD, formatarNum)]
demonstr[, espec:=correcaoCaracteresEspeciais(espec, caracteres)]

write.table(demonstr, "volume1/data/T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
