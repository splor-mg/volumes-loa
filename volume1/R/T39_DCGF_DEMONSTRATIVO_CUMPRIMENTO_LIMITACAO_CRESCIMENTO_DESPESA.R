# Organização do banco INVESTIMENTOS SEGUNDO AS FUNÇÕES - TABELA 30
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
suppressMessages(require(relatorios))

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Elemento_Item.R", encoding = "UTF-8")

poder_desc = data.table(read_excel("bancos/manual/codigosPoder.xlsx"))

fator_correcao = c(4.28, 4.18)

qdd = trataQDD_Elemento_Item("bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx", T)
qdd[, ANO:=2019]
qdd = qdd[is_teto_gasto(qdd), list(credito_inicial = sum(VL_LOA_DESP)), list(ANO, UO_COD)]


qdd[, PODER := 3] # Executivo
qdd[is_legislativo(qdd), PODER := 1]
qdd[is_judiciario(qdd), PODER := 2]
qdd[is_pgj(qdd), PODER := 4]
qdd[is_tce(qdd), PODER := 5]
qdd[is_def_pub(qdd), PODER := 6]

qdd = qdd[, list(credito_inicial = sum(credito_inicial)), list(PODER)]

exec_desp = execucao::exec_desp[ANO == 2017]
exec_desp = exec_desp[is_teto_gasto(exec_desp), list(VL_EMP = sum(VL_EMP)), list(ANO, UO_COD)]

exec_desp[, PODER := 3] # Executivo
exec_desp[is_legislativo(exec_desp), PODER := 1] # Executivo
exec_desp[is_judiciario(exec_desp), PODER := 2]
exec_desp[is_pgj(exec_desp), PODER := 4]
exec_desp[is_tce(exec_desp), PODER := 5]
exec_desp[is_def_pub(exec_desp), PODER := 6]


exec_desp = exec_desp[, list(VL_EMP_2017 = sum(VL_EMP)), list(PODER)]
exec_desp[, VL_LIMITE := VL_EMP_2017]

for(fator in fator_correcao){
  exec_desp$VL_LIMITE =exec_desp$VL_LIMITE*(1+(fator/100))
}
        
result = mergeDT(exec_desp, qdd, by = "PODER", all=T)

result = mergeDT(result, poder_desc, by.x="PODER", by.y="cod_poder")
      
result[grepl("EXECUTIVO", poder), poder := paste0("A - ", poder)]
result[grepl("LEGISLATIVO", poder), poder := paste0("B - ", poder)]
result[grepl("CONTAS", poder), poder := paste0("C - ", poder)]
result[grepl("JUDI", poder), poder := paste0("D - ", poder)]
result[grepl("MINI", poder), poder := paste0("E - ", poder)]
result[grepl("DEFE", poder), poder := paste0("F - ", poder)]

result[, excedente := round(credito_inicial - VL_LIMITE, 0)]

result = result[, list(poder, VL_EMP_2017, VL_LIMITE, credito_inicial, excedente)][order(poder)]

result = rbind(result,
               result[, lapply(.SD, function(x) sum(x, na.rm=T)), .SDcols=2:ncol(result)], fill=T)

result[nrow(result), poder:="TOTAL"]


result[, poder := correcaoCaracteresEspeciais(poder, caracteres)]

result[, VL_EMP_2017 := formatarNum(VL_EMP_2017)]
result[, VL_LIMITE := formatarNum(VL_LIMITE)]
result[, credito_inicial := formatarNum(credito_inicial)]
result[, excedente := ifelse(excedente == 0, zero2traco(excedente), formatarNum(excedente))]


write.table(result, "volume1/data/T39_DCGF_DEMONSTRATIVO_CUMPRIMENTO_LIMITACAO_CRESCIMENTO_DESPESA.txt",
            quote = FALSE, sep = "\t", na = "", dec = ",", row.names = FALSE)

