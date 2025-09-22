# =================================================================================
# Organização de T4_DEMONSTRATIVO_DESPESA_POR_ORGAOS_ENTIDADES_SEGUNDO_GRUPOS_DESPESA
options(warn = 1)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

grupo_despesa = data.table(read_excel("bancos/manual/desc_grupos_de_despesa.xlsx",sheet=1))[,list(CODIGO, ESPECIFICACAO)]

names(grupo_despesa) = tolower(names(grupo_despesa))

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
qdd = qdd[, list(valor = sum(valor, na.rm=T)), by=list(COD_UO, UO, GRUPO_DESPESA)]

qdd = mergeDT(qdd, grupo_despesa, by.x="GRUPO_DESPESA", by.y="codigo", all=T)

if("Apenas no Banco X" %in% qdd[, unique(merge)]){
  
  warning(paste("T4_DEMONSTRATIVO_DESPESA_POR_ORGAOS_ENTIDADES_SEGUNDO_GRUPOS_DESPESA: Há códigos",
                "de grupo de despesa em BASE_QDD_FISCAL que não possuem uma correspondência em ", 
                "desc_grupos_de_despesa.xlsx. Os codigos são ", 
                paste(qdd[merge=="Apenas no Banco X", unique(GRUPO_DESPESA)], collapse=", "),
                "\nCorreção: inserir esses códigos e sua descrição em banco apoio", 
                "na aba Grupos de despesa\n"))
}

qdd[, especificacao := toupper(especificacao)]

qdd <- dcast(qdd, COD_UO + UO ~ especificacao, value.var = "valor", fill=0, fun.aggregate = sum)

qdd = qdd[order(UO)]

setcolorder(qdd , c("COD_UO", "UO", "PESSOAL E ENCARGOS SOCIAIS", "JUROS E ENCARGOS DA DÍVIDA", 
                    "OUTRAS DESPESAS CORRENTES", "INVESTIMENTOS", "INVERSÕES FINANCEIRAS", 
                    "AMORTIZAÇÃO DA DÍVIDA", "RESERVA DE CONTINGÊNCIA"))

qdd$total = apply(qdd[, c(3:9), with = F],1,sum)

qdd = rbind(qdd, qdd[,lapply(.SD, sum), .SDcols=3:10], fill=T)

qdd[nrow(qdd), UO:= "TOTAL"]

qdd = qdd[,lapply(.SD, formatarNum)]

qdd[, UO := correcaoCaracteresEspeciais(UO, caracteres)]

setnames(qdd, c("UO", "PESSOAL E ENCARGOS SOCIAIS", "JUROS E ENCARGOS DA DÍVIDA", "OUTRAS DESPESAS CORRENTES",
                "INVESTIMENTOS", "INVERSÕES FINANCEIRAS", "AMORTIZAÇÃO DA DÍVIDA", "RESERVA DE CONTINGÊNCIA"),
              c("orgaos", "pessoal", "juros", "outras", 
                "investimentos", "inversoes", "amort", "reserva"))

qdd[, COD_UO := NULL]

write.table(qdd, "volume1/data/T4_DEMONSTRATIVO_DESPESA_POR_ORGAOS_ENTIDADES_SEGUNDO_GRUPOS_DESPESA.txt", quote = F, 
            sep = "\t", na = "", dec = ",", row.names = FALSE)

