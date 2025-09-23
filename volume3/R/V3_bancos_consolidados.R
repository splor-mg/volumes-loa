# Organização dos bancos consolidados volume 3
# 1. INVESTIMENTOS POR EMPRESA SEGUNDO FONTES DE RECURSO 
# 2. INVESTIMENTOS POR EMPRESA SEGUNDO O DETALHAMENTO DOS INVESTIMENTOS
# 3. INVESTIMENTOS SEGUNDO FUNÇÕES, SUBFUNÇÕES E PROGRAMAS POR PROJETOS E ATIVIDADES

options(warn = 1)
library(relatorios)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")
source("utils/trataBancos/trataAcoesPlanejamento.R", encoding = "UTF-8")

#==========================================================
# Inicio da Construção dos Bancos Consolidados
#==========================================================
ANO_ANALISE = as.numeric(readLines("utils/ano.txt", warn = F))

qdd = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")
acoes = trataAcoesPlanejamento("bancos/SISOR/acoes_planejamento", ANO_ANALISE)

#=========================================================================================
# 0. Construção do sumário
# Banco de apoio contendo todas as UO's e seus respectivos códigos em ordem alfabética
#=========================================================================================

sumario = data.table(unique(cbind(qdd$COD_UO, qdd$UO)))
setnames(sumario, c("V1", "V2"), c("cod_uo", "uo"))
sumario = sumario[order(cod_uo)]
write.table(sumario, "volume3/data/consolidado/sumario_v3.txt", quote = FALSE, sep = "\t", na = "", dec = ",", 
            row.names = FALSE)

#=========================================================================================
# 1. INVESTIMENTOS POR EMPRESA SEGUNDO FONTES DE RECURSO 
#=========================================================================================

t1 = qdd[,list(valor = sum(valor, na.rm=T)), by=list(UO, COD_FONTE)]

t1[nat(COD_FONTE, 111), fonte1 := "tesouro_ordinario"]
t1[nat(COD_FONTE, 112), fonte1 := "tesouro_vinculado"]
t1[nat(COD_FONTE, 12), fonte1 := "outras_entidades"]
t1[nat(COD_FONTE, 2), fonte1 := "operacao_credito"]
t1[nat(COD_FONTE, 3), fonte1 := "alienacao"]
t1[nat(COD_FONTE, 4), fonte1 := "convenios"]
t1[nat(COD_FONTE, 5), fonte1 := "recursos_proprios"]
t1[nat(COD_FONTE, 6), fonte1 := "outras_origens"]

fontes <- c(
  "tesouro_ordinario",
  "tesouro_vinculado",
  "outras_entidades",
  "operacao_credito",
  "alienacao",
  "convenios",
  "recursos_proprios",
  "outras_origens")

t1[, fonte1 := factor(fonte1, levels = fontes)]

if(anyNA(t1[["fonte1"]])) {
  warning(paste0("V3_bancos_consolidados.R: Em qual fonte de recurso para a Tabela 1 entra(m) a(s) fonte(s), ",
                    paste(t1[is.na(fonte1), unique(COD_FONTE)]), collapse=", "), "?")
}

t1 <- dcast(t1, UO ~ fonte1, value.var = "valor", fun.aggregate = sum, drop = FALSE)

t1[, total:= apply(.SD, 1, sum), .SDcols=2:ncol(t1)]
total = t1[, lapply(.SD, sum), .SDcols = 2:ncol(t1)]

total$UO = "TOTAL"
t1 = rbind(t1, total)

setnames(t1, c("UO"), c("orgaos"))

t1[, orgaos := correcaoCaracteresEspeciais(orgaos, caracteres)]
t1 = t1[, lapply(.SD, formatarNum)]

write.table(t1, "volume3/data/consolidado/T1_INVESTIMENTO_POR_EMPRESA.txt", append = FALSE, quote = FALSE, 
            sep = "\t", na = "", dec = ",", row.names = FALSE)

#=========================================================================================
## 2. INVESTIMENTOS POR EMPRESA SEGUNDO O DETALHAMENTO DOS INVESTIMENTOS
#=========================================================================================

# Aplica expressões regulares para identificar e padronizar as categorias. Nos comentários há o
# alvo de cada expressão regular

t2 = qdd[, list(valor = sum(valor, na.rm=T)), by=list(UO, CATEGORIA)]

t2[, categoria1 := "sem correspondencia"]
t2[grepl(".+societ.+", CATEGORIA, ignore.case=T), categoria1 := "societaria"] # 4510 - PARTICIPAÇÃO SOCIETÁRIA
t2[grepl(".+imob.+", CATEGORIA, ignore.case=T), categoria1 := "imob"] # 4610 - IMOBILIZAÇÕES
t2[grepl(".+amort.+", CATEGORIA, ignore.case=T), categoria1 := "amort"] # 4710 - AMORTIZAÇÃO DE DÍVIDAS
t2[grepl(".+outras.+", CATEGORIA, ignore.case=T), categoria1 := "outras"] # 4810 - OUTRAS APLICAÇÕES


if("sem correspondencia" %in% t2[, unique(categoria1)]) {
  warning(paste0("V3_bancos_consolidados.R: Em qual fonte de recurso para a Tabela",
                 " 2. INVESTIMENTOS POR EMPRESA SEGUNDO O DETALHAMENTO DOS INVESTIMENTOS entra a fonte, ",
                 paste(t2[categoria1=="sem correspondencia", unique(CATEGORIA)] , collapse=", "), "?"))
}

t2[, CATEGORIA:=NULL]
t2 <- reshape(t2,   timevar = "categoria1", idvar = "UO",  direction = "wide")

total = t2[,lapply(.SD, function(x){sum(x, na.rm=T)}), .SDcols=2:ncol(t2)]
total$UO = "TOTAL"

t2[is.na(t2)] = 0
t2 = t2[order(UO)]
t2 = rbind(t2, total)

var_esperadas = c("valor.outras", "valor.societaria", "valor.imob", "valor.amort")

if(length(setdiff(var_esperadas, names(t2)))>0){
  # Cria a categoria caso não haja essa coluna em var_esperadas
  
  warning(paste0("V3_bancos_consolidados: A Tabela 2 INVESTIMENTOS POR EMPRESA SEGUNDO O DETALHAMENTO DOS INVESTIMENTOS ",
                  "não apresenta a categoria representada pelas variaveis, ",
                  paste(setdiff(var_esperadas, names(t2)), collapse=", "),
                  "O total dessa tabela será realizado sem essa var e essa variaveis serão zeradas."))
  
  t2[,setdiff(var_esperadas, names(t2)):=0 ]
}

t2[, total:= apply(.SD, 1, sum), .SDcols=2:ncol(t2)]
t2 = t2[, lapply(.SD, formatarNum)]

setnames(t2, c("UO", "valor.outras", "valor.societaria", "valor.imob", "valor.amort"),
             c("empresas", "outras", "societaria", "imob", "amort"))

t2[, empresas := correcaoCaracteresEspeciais(empresas, caracteres)]
write.table(t2, "volume3/data/consolidado/T2_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO.txt", 
            quote = FALSE, sep = "\t", na = "", dec = ",", row.names = FALSE)

#=========================================================================================
# 3. INVESTIMENTOS SEGUNDO FUNÇÕES, SUBFUNÇÕES E PROGRAMAS POR PROJETOS E ATIVIDADES
#=========================================================================================

# Considera apenas as ações que iniciam com 3 (Projeto) ou que iniciam com mais de 6 (Atividade)

t3_atividade = qdd[IDENT_PROJATIV>=6, 
                   list(atividade = sum(valor, na.rm=T)), 
                   by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, especificacao = NOME_PROGRAMA)]

t3_projeto = qdd[IDENT_PROJATIV==3, 
                 list(projeto = sum(valor, na.rm=T)), 
                 by=list(FUNCAO, SUB_FUNCAO, PROGRAMA, especificacao = NOME_PROGRAMA)]

t3_n3 = mergeDT(t3_atividade, t3_projeto, by=c("FUNCAO", "SUB_FUNCAO", "PROGRAMA", "especificacao"), all=T)

t3_n3$merge=NULL
t3_n3[is.na(t3_n3)] = 0

# Obter os nomes das Funções e Subfunções
acoes = acoes[, .N, by=.(FUNCAO = cod_funcao, nome_funcao, SUB_FUNCAO = cod_subfuncao, nome_subfuncao)]

# Valores totais por função Ex. 04.000.00 ADMINISTRAÇÃO

t3_n1 = t3_n3[, list(atividade = sum(atividade, na.rm=T), projeto = sum(projeto, na.rm=T)), 
              by=list(FUNCAO)]

# Merge "manual", linha a linha, inserindo para cada código de função sua respectiva descrição
#browser()
t3_n1 = mergeDT(t3_n1, acoes[, list(x=1), by=list(FUNCAO, especificacao = nome_funcao)], by="FUNCAO", all.x=T)
#browser()
if("Apenas no Banco X" %in% t3_n1[, unique(merge)]) {
  warning(paste("V3_bancos_consolidados.R: Código da função",
                paste(t3_n1[merge=="Apenas no Banco X", FUNCAO],collapse=", "), 
                "não encontrado na variável cod_funcao no banco de acoes. Verificar o problema!"))
}

t3_n1[, c("x", "merge") := NULL]
t3_n1[, c("SUB_FUNCAO", "PROGRAMA") := 0]

# Valores totais por subfunção Ex. 04.122.00 ADMINISTRAÇÃO GERAL

t3_n2 = t3_n3[, list(atividade = sum(atividade, na.rm=T), 
                     projeto = sum(projeto, na.rm=T)), by=list(FUNCAO, SUB_FUNCAO)]

t3_n2 = mergeDT(t3_n2, acoes[, list(FUNCAO, SUB_FUNCAO, especificacao = nome_subfuncao)], 
                by=c("FUNCAO", "SUB_FUNCAO"), all.x=T)

if("Apenas no Banco X" %in% t3_n2[, unique(merge)]) {
  warning(paste("V3_bancos_consolidados.R: Código da subfunção",
                paste(t3_n2[merge=="Apenas no Banco X", SUB_FUNCAO],collapse=", "), 
                "não encontrado na variável cod_subfuncao no banco de acoes. Verificar o problema!"))
}

t3_n2[, merge := NULL]

t3_n2[, PROGRAMA := 0]
total = t3_n3[,lapply(.SD, function(x){sum(x, na.rm=T)}), .SDcols=(1:6)[-4]] # Desconsiderar 4 significa desconsiderar NOME_PROGRAMA
total[,c("SUB_FUNCAO","PROGRAMA","especificacao") := list(999, 999,"TOTAL")]

t3 = rbindlist(list(t3_n1, t3_n2, t3_n3, total), use.names = T)

t3[, codigo := paste(formatC(FUNCAO, width = 2, flag = "0"),
                     formatC(SUB_FUNCAO, width = 3, flag = "0"),
                     formatC(PROGRAMA, width = 3, flag = "0"), sep=".")]

t3[, codigo_numerico := as.numeric(gsub("\\.", "", codigo))]
t3 = t3[order(codigo_numerico)]

t3[, total := atividade + projeto]

t3 = t3[,list(codigo, especificacao,  projeto, atividade, total)]
t3 = t3[, lapply(.SD, formatarNum)]
t3[, especificacao := correcaoCaracteresEspeciais(especificacao, caracteres)]

write.table(t3, "volume3/data/consolidado/T3_INVESTIMENTOS_SEGUNDO_FUNCOES_SUB_PROGRAMAS_PROJETOS_ATIVIDADES.txt", 
            quote = FALSE, sep = "\t", na = "", dec = ",", row.names = FALSE)
