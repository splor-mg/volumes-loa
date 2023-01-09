# Organização do banco T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL - Volume 1
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataPessoal.R", encoding = "UTF-8")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", FALSE)
qdd = qdd[, list(x=1), by=list(COD_UO, orgao = UO)]

## CATEGORIA PESSOAL
pessoal = trataPessoal("bancos/SISOR/BASE_CATEGORIA_PESSOAL.xlsx", F)
pessoal = pessoal[, list(quantidade = sum(quantidade, na.rm = T)), by=list(cod_uo, classificacao)]

pessoal <- dcast(pessoal, cod_uo ~ classificacao, value.var = "quantidade", fill=0)

#====================================Condicional para quando não houver terceirizado em BASE_QDD_FISCAL.xlsx=======================
#
#  Verificação adicionada em 22/09/2021 pelo fato de que neste ano os terceirizados não precisariam mais ser discriminados no SISOR.
#  Caso a coluna não exista ela é criada, caso ela já exista nada muda, mantendo o código funcional em futuros exercícios quando essa 
#  discriminação de quantidades voltar a ser necessária. (Andrey)
#  
#==================================================================================================================================
if( !("terceirizado" %in% colnames(pessoal)) ){
  pessoal[,Terceirizado:=0];
}

pessoal[, cod_uo := as.numeric(cod_uo)]

pessoal = mergeDT(pessoal, qdd, by.x="cod_uo", by.y="COD_UO", all=T)
pessoal = pessoal[merge=="Em ambos os bancos",]


## Adiciona condicional para substituir FES por SES no demonstrativo. Fundos não tem despesa de pessoal.
if(4291 %in% pessoal[, unique(cod_uo)]){
  warning(paste("V1_Tabela5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL: 4291 FUNDO ESTADUAL DE SAÚDE",
                "(UO) será considerado como 1.32.0 - SECRETARIA DE ESTADO DE SAÚDE - SES (Órgão)\n"))
  
  pessoal[cod_uo==4291, c("cod_uo", "orgao") := list(1320, "SECRETARIA DE ESTADO DE SAÚDE - SES")]
  
  
}




pessoal[, c("x", "merge", "cod_uo"):=NULL]
setcolorder(pessoal, c("orgao", "Ativo", "Inativo", "Terceirizado"))

pessoal = pessoal[order(orgao)]

pessoal$total = apply(pessoal[, c(2:4), with = F],1,sum)
pessoal = rbind(pessoal, pessoal[,lapply(.SD, sum), .SDcols=2:5], fill=T)
pessoal[nrow(pessoal), orgao:= "TOTAL"]
names(pessoal) = tolower(names(pessoal))

pessoal = pessoal[,lapply(.SD, formatarNum)]

pessoal[, orgao := correcaoCaracteresEspeciais(orgao, caracteres)]




write.table(pessoal, "volume1/data/T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
