# ==========================================================================
# Utiliza os nomes de ORGAO, UO e PODER para presentes em QDD_FISCAL e 
# QDD_INVESTIMENTO para montar o sumário. Este manterá apenas os nomes das 
# UO's que aparecem no banco BASE_DETALHAMENTO_OBRAS.xlsx
# ==========================================================================

options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataDetalhe_Obras.R", encoding = "UTF-8")

QDD_INVESTIMENTO = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")
QDD_INVESTIMENTO = QDD_INVESTIMENTO[,.(COD_UO, UO, COD_ORGAO, ORGAO, PODER)]

QDD_FISCAL = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx")
QDD_FISCAL = QDD_FISCAL[,.(COD_UO, UO, COD_ORGAO, ORGAO, PODER)]

sumario = data.table(rbind(QDD_INVESTIMENTO, QDD_FISCAL))

sumario = sumario[,.N, by=.(COD_UO, UO, COD_ORGAO, ORGAO, PODER)]
sumario$N = NULL

poderes = read_excel("bancos/manual/codigosPoder.xlsx", sheet=1)
sumario = mergeDT(sumario, poderes, by.x="PODER", by.y="cod_poder", all.x=T)

sumario = sumario[order(PODER, COD_ORGAO, COD_UO)]

# compara o sumario obtido com o banco de obras
obras = trataDetalhe_Obras("bancos/SISOR/BASE_DETALHAMENTO_OBRAS.xlsx", acoes="Não utilizar", realizarTeste = F)

if(length(setdiff(obras[, unique(UO)], sumario[, unique(COD_UO)]))>0){
  
  warning(paste("Há códigos de UO que estão presentes no banco BASE_DETALHAMENTO_OBRAS.xlsx",
                "mas não estão presentes nos bancos do volume 3 BASE_QDD_INVESTIMENTO.xlsx",
                "e do volume 5 BASE_QDD_FISCAL. Verificar as UO's ", 
                setdiff(obras[, unique(UO)], sumario[, unique(COD_UO)]),
                "e realizar a inclusão dessas UO's em volume4/data/sumario.txt"))
}

sumario = sumario[COD_UO %in% unique(obras$UO),]

write.table(sumario[,merge:=NULL], "volume4/data/sumario_v4.txt", append = FALSE, quote = T, 
            sep = "\t",  na = "", dec = "@", row.names = FALSE)
