# Organização do banco INVESTIMENTOS SEGUNDO AS FUNÇÕES - TABELA 30
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")
source("utils/trataBancos/trataAcoesPlanejamento.R", encoding = "UTF-8")

qdd = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")
acoes = trataAcoesPlanejamento("bancos/SISOR/acoes_planejamento", ANO_ANALISE = "não precisa")

acoes = acoes[,.N, by=list(cod_funcao, nome_funcao)]

qdd = qdd[,list(valor = sum(valor, na.rm=T)), by=list(FUNCAO)]
qdd = mergeDT(qdd, acoes, by.x="FUNCAO", by.y="cod_funcao", all=T)

# Apenas no Banco Y: Ok. Pode existir FUnções que não tiveram investimentos

if("Apenas no Banco X" %in% qdd[, unique(merge)]){
  warning(paste("T30_INVESTIMENTOS_SEGUNDO_FUNCOES.R: O código da função ", 
                paste(qdd[merge=="Apenas no Banco X", unique(FUNCAO)], collapse=", "),
                "não existe no banco de apoio, ou seja, não é possível lhe atribuir um nome.\n"))
}

# Apenas no Banco X: Problema. Existência de funções sem o nome no banco de apoio.

qdd = qdd[merge=="Em ambos os bancos",]

qdd = qdd[order(FUNCAO)]

qdd = qdd[, list(nome_funcao, valor)]
qdd[, porcent := round((valor / sum(valor))*100, 3)]

setnames(qdd, "nome_funcao", "especificacao")

total = qdd[, lapply(.SD, sum), .SDcols=2:3]
total[, especificacao := "TOTAL"]

qdd = rbind(qdd, total)

qdd[, especificacao := correcaoCaracteresEspeciais(especificacao, caracteres)]

qdd[, valor := formatarNum(valor)]

qdd$porcent = format(round(qdd$porcent, 2), decimal.mark = ',', big.mark = '.')

write.table(qdd, "volume1/data/T30_INVESTIMENTOS_SEGUNDO_FUNCOES.txt", quote = FALSE, 
            sep = "\t", na = "", dec = ",", row.names = FALSE)

