# =================================================================================================
# Organização de T14 DEMONSTRATIVO DESPESA FUNCAO SUBFUNCAO PROGRAMA CONFORME VINCULO COM RECURSOS
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

# ============================================================================
# Definir parâmetros
rec_ordinarios = c(10, 11, 12, 15, 19)
rec_diretamente_arrec = c(60, 61) 
# ============================================================================

funcao = data.table(read_excel("bancos/manual/desc_funcao.xlsx",sheet=1))
subfuncao = data.table(read_excel("bancos/manual/desc_subfuncao.xlsx",sheet=1))

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)

qdd[FONTE %in% rec_ordinarios, recurso_tipo:= "ordinarios"]
qdd[FONTE %in% rec_diretamente_arrec, recurso_tipo:= "arrecadados"]
qdd[!FONTE %in% union(rec_diretamente_arrec, rec_ordinarios), recurso_tipo:= "vinculados"]

# ======= Banco por Função =================

qdd_funcao = qdd[, list(valor = sum(valor, na.rm=T)), by=list(FUNCAO, recurso_tipo)]
qdd_funcao[, c("SUB_FUNCAO", "PROGRAMA"):=0]
qdd_funcao = mergeDT(qdd_funcao, funcao, by.x="FUNCAO", by.y="codigo", all=T)

if("Apenas no Banco X" %in% qdd_funcao[, unique(merge)]){
  warning(paste("T14_DESPESA_FUNCAO_SUBFUNCAO_PROGRAMA_VINCULO_COM_RECURSOS: Há códigos de FUNÇÃO em ", 
                "BASE_QDD_FISCAL que não possuem uma correspondência em banco_apoio.",
                "Os codigos são ", paste(qdd_funcao[merge=="Apenas no Banco X", unique(FUNCAO)], collapse=", "),
                "\nCorreção: inserir esses códigos e sua descrição em banco_apoio na aba Função\n"))
}

setnames(qdd_funcao, "funcao", "especificacao")
qdd_funcao = qdd_funcao[merge=="Em ambos os bancos",]
qdd_funcao[, merge := NULL]

# ======= Banco por Sub-função =================

qdd_subfuncao = qdd[, list(valor = sum(valor, na.rm=T)), by=list(FUNCAO, SUB_FUNCAO, recurso_tipo)]
qdd_subfuncao[, PROGRAMA:=0]
qdd_subfuncao = mergeDT(qdd_subfuncao, subfuncao, by.x="SUB_FUNCAO", by.y="codigo", all=T)

setnames(qdd_subfuncao, "subfuncao", "especificacao")

if("Apenas no Banco X" %in% qdd_subfuncao[, unique(merge)]){
  warning(paste("T14_DESPESA_FUNCAO_SUBFUNCAO_PROGRAMA_VINCULO_COM_RECURSOS: Há códigos de sub-função em ", 
                "BASE_QDD_FISCAL que não possuem uma correspondência em banco apoio. Os codigos são ", 
                 paste(qdd_subfuncao[merge=="Apenas no Banco X", unique(SUB_FUNCAO)], collapse=", "),
                 "\nCorreção: inserir esses códigos e sua descrição em banco apoio na aba Subfunção\n"))
}

qdd_subfuncao = qdd_subfuncao[merge=="Em ambos os bancos",]
qdd_subfuncao[, merge := NULL]

# ======= Banco por Programa =================
qdd_prog= qdd[, list(valor = sum(valor, na.rm=T)), 
               by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, especificacao = NOME_PROGRAMA, recurso_tipo)]

# ======= União dos bancos =================
final = rbind(qdd_funcao, qdd_subfuncao)
final = rbind(final, qdd_prog)

final <- dcast(final, FUNCAO + SUB_FUNCAO + PROGRAMA + especificacao ~ recurso_tipo, value.var = "valor", fill=0)

setcolorder(final, c("FUNCAO", "SUB_FUNCAO", "PROGRAMA", "especificacao", "ordinarios", "vinculados", "arrecadados"))

final$FUNCAO = as.numeric(final$FUNCAO)
final$SUB_FUNCAO = as.numeric(final$SUB_FUNCAO)

final$total = apply(final[, c(5:7), with = F], 1 , sum)

final = rbind(final, final[SUB_FUNCAO==0 & PROGRAMA==0,lapply(.SD, sum), .SDcols=5:8], fill=T)

final[nrow(final), especificacao:= "TOTAL"]
final[nrow(final), FUNCAO := 100]

final = final[order(FUNCAO, SUB_FUNCAO, PROGRAMA)]

final[SUB_FUNCAO==0, SUB_FUNCAO :=NA]
final[PROGRAMA==0, PROGRAMA :=NA]

final = final[,lapply(.SD, formatarNum)]

final[, especificacao := correcaoCaracteresEspeciais(especificacao, caracteres)]

names(final) = tolower(names(final))
setnames(final, "sub_funcao", "subfuncao")

write.table(final, 
            "volume1/data/T14_DEMONSTRATIVO_DESPESA_FUNCAO_SUBFUNCAO_PROGRAMA_CONFORME_VINCULO_COM_RECURSOS.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
