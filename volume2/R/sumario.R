options(warn = 1)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", TRUE)

sumario = qdd[,.N, by=list(COD_UO, UO, COD_ORGAO, ORGAO, PODER)]
sumario$N = NULL

poderes = read_excel("bancos/manual/codigosPoder.xlsx", sheet=1)

sumario = mergeDT(sumario, poderes, by.x="PODER", by.y="cod_poder", all=T)

if("Apenas no Banco X" %in% sumario[, unique(merge)]){
  warning(paste("sumario_v2: O codigo de poder ",
                paste(sumario[merge=="Apenas no Banco X", unique(PODER)], collapse=", "),
                " não possuem uma correspodência no banco codigosPoder.xlsx. ",
                "Alterar esse banco de codigosPoder.xlsx"))
}

if("Apenas no Banco Y" %in% sumario[, unique(merge)]){
  warning(paste("sumario_v2: O poder ",
                paste(sumario[merge=="Apenas no Banco Y", unique(poder)], collapse=", "),
                " não possui uma UO no QDD Fiscal. Desconsiderar esse poder do banco."))
}

sumario = sumario[merge!="Apenas no Banco Y",]
sumario = sumario[order(PODER, COD_ORGAO, COD_UO)]

write.table(sumario[,merge:=NULL], "volume2/data/sumario.txt", quote = T, sep = "\t",
            na = "", dec = "@", row.names = FALSE)
