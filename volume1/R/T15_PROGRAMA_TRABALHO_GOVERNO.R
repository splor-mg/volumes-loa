# =================================================================================================
# Organização de T15_PROGRAMA_TRABALHO_GOVERNO
# DEMONSTRATIVO DA DESPESA POR FUNÇÕES, SUBFUNÇÕES E PROGRAMAS CONFORME OS GRUPOS DE DESPESA
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

grupo_despesa = data.table(read_excel("bancos/manual/desc_grupos_de_despesa.xlsx",sheet=1))[,list(CODIGO, ESPECIFICACAO)]
names(grupo_despesa) = tolower(names(grupo_despesa))
names(grupo_despesa)[2] = "nome_g_despesa"

funcao = data.table(read_excel("bancos/manual/desc_funcao.xlsx",sheet=1))
subfuncao = data.table(read_excel("bancos/manual/desc_subfuncao.xlsx",sheet=1))

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)

# ======= Banco por Função =================

qdd_funcao = qdd[,list(valor = sum(valor, na.rm=T)), by=list(FUNCAO, GRUPO_DESPESA)]
qdd_funcao[, c("SUB_FUNCAO", "PROGRAMA"):=0]
qdd_funcao = mergeDT(qdd_funcao, funcao, by.x="FUNCAO", by.y="codigo", all=T)

if("Apenas no Banco X" %in% qdd_funcao[, unique(merge)]){
  warning(paste("T15_PROGRAMA_TRABALHO_GOVERNO: Há códigos de FUNÇÃO em BASE_QDD_FISCAL", 
                "que não possuem uma correspondência em desc_funcao.xlsx. Os codigos são ", 
                paste(qdd_funcao[merge=="Apenas no Banco X", unique(FUNCAO)], collapse=", "),
                "\nCorreção: inserir esses códigos e sua descrição em banco_apoio na aba Função\n"))
}

setnames(qdd_funcao, "funcao", "especificacao")
qdd_funcao = qdd_funcao[merge=="Em ambos os bancos",]
qdd_funcao[, merge := NULL]

# ======= Banco por Sub-função =================

qdd_subfuncao = qdd[, list(valor = sum(valor, na.rm=T)), by=list(FUNCAO, SUB_FUNCAO, GRUPO_DESPESA)]
qdd_subfuncao[, PROGRAMA:=0]
qdd_subfuncao = mergeDT(qdd_subfuncao, subfuncao, by.x="SUB_FUNCAO", by.y="codigo", all=T)

setnames(qdd_subfuncao, "subfuncao", "especificacao")

if("Apenas no Banco X" %in% qdd_subfuncao[, unique(merge)]){
  warning(paste("T15_PROGRAMA_TRABALHO_GOVERNO: Há códigos de sub-função em BASE_QDD_FISCAL",
                "que não possuem uma correspondência em desc_subfuncao.xlsx. Os codigos são ", 
                paste(qdd_subfuncao[merge=="Apenas no Banco X", unique(SUB_FUNCAO)], collapse=", "),
                "\nCorreção: inserir esses códigos e sua descrição em banco_apoio na aba Subfunção\n"))
}

qdd_subfuncao = qdd_subfuncao[merge=="Em ambos os bancos",]
qdd_subfuncao[, merge := NULL]

# ======= Banco por Programa =================

qdd_prog = qdd[, list(valor = sum(valor, na.rm=T)), 
               by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, especificacao = NOME_PROGRAMA, GRUPO_DESPESA)]

# ======= União dos bancos =================

final = rbind(qdd_funcao, qdd_subfuncao)
final = rbind(final, qdd_prog)

final = mergeDT(final, grupo_despesa, by.x="GRUPO_DESPESA", by.y="codigo", all=T)
final[, nome_g_despesa := toupper(nome_g_despesa)]

final[GRUPO_DESPESA == 9 & is.na(especificacao), 
      especificacao := ""]

final <- dcast(final, FUNCAO + SUB_FUNCAO + PROGRAMA + especificacao ~ nome_g_despesa, 
               value.var = "valor", fill=0, fun.aggregate = sum)

setcolorder(final, c("FUNCAO", "SUB_FUNCAO", "PROGRAMA", "especificacao", "PESSOAL E ENCARGOS SOCIAIS",
                     "JUROS E ENCARGOS DA DÍVIDA", "OUTRAS DESPESAS CORRENTES", "INVESTIMENTOS",
                     "INVERSÕES FINANCEIRAS", "AMORTIZAÇÃO DA DÍVIDA", "RESERVA DE CONTINGÊNCIA"))

final$FUNCAO = as.numeric(final$FUNCAO)
final$SUB_FUNCAO = as.numeric(final$SUB_FUNCAO)

final$total = apply(final[, c(5:ncol(final)), with = F], 1 , sum)

final = rbind(final, final[SUB_FUNCAO==0 & PROGRAMA==0,lapply(.SD, sum), .SDcols=5:ncol(final)], fill=T)

final[nrow(final), especificacao:= "TOTAL"]
final[nrow(final), FUNCAO := 100]

final = final[order(FUNCAO, SUB_FUNCAO, PROGRAMA)]

final[SUB_FUNCAO==0, SUB_FUNCAO :=NA]
final[PROGRAMA==0, PROGRAMA :=NA]

final = final[,lapply(.SD, formatarNum)]

final[, especificacao := correcaoCaracteresEspeciais(especificacao, caracteres)]

names(final) = tolower(names(final))

setnames(final, c("sub_funcao", "pessoal e encargos sociais", "juros e encargos da dívida", 
                  "outras despesas correntes", "investimentos", "inversões financeiras", 
                  "amortização da dívida", "reserva de contingência"),
                c("subfuncao", "pessoal", "juros", 
                  "outras", "investimentos", "inversoes", 
                  "amort", "reserva"))

write.table(final, "volume1/data/T15_PROGRAMA_TRABALHO_GOVERNO.txt", quote = F, 
            sep = "\t", na = "", dec = ",", row.names = FALSE)
