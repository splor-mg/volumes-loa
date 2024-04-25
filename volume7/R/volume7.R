# =================================================================================
# Organização do volume 7 LOA
# Objetivos:
# P1 - Montar um dataframe com o "DEMONSTRATIVO CONSOLIDADO DA DESPESA"
# P2 - Montar QUADRO DE DETALHAMENTO DA DESPESA - FISCAL
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

# so utilizado se existir uma base em "bancos/SISOR/BASE_QDD_FISCAL_PROPOSTA.xlsx"
uos_proposta = c(1011, 1021, 1031, 1051, 1091, 1441, 2361, 4031, 4121, 4441, 4451, 4611)

classificacao_despesa = data.table(read_excel("bancos/manual/desc_classificacao_economica_despesa.xlsx", sheet=1))

classificacao_despesa = classificacao_despesa[!is.na(codigo),]

classificacao_despesa[, codigo:= format(as.numeric(gsub(" |\u00A0", "", codigo)), scientific = F)]

classificacao_despesa[, codigo_texto := paste(substr(codigo,1,1), substr(codigo,2,2), 
                                              substr(codigo,3,4), substr(codigo,5,6), sep=".")]

banco = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL_FONTE_95.xlsx")

poderes = read_excel("bancos/manual/codigosPoder.xlsx", sheet=1)

banco[, codigo_numerico := as.numeric(paste0(CATEGORIA, 
                                             GRUPO_DESPESA, 
                                             MODALIDADE, 
                                             formatC(ELEMENTO_DESPESA, width = 2, flag = "0")))]

banco[, codigo_texto := paste(CATEGORIA, 
                              GRUPO_DESPESA, 
                              MODALIDADE, 
                              formatC(ELEMENTO_DESPESA, width = 2, flag = "0"), sep=".")]

# 1. DEMONSTRATIVO CONSOLIDADO DA DESPESA

consolidado = banco[FONTE %in% c(10,11,12,15), list(recurso_tesouro = sum(valor, na.rm=T)), by=list(codigo_numerico, codigo_texto)]
outras_fontes = banco[!FONTE %in% c(10,11,12,15), list(outras_fontes = sum(valor, na.rm=T)), by=list(codigo_numerico, codigo_texto)]

consolidado = mergeDT(consolidado, outras_fontes, by=c("codigo_numerico", "codigo_texto"), all=T)
                      
consolidado = consolidado[order(codigo_numerico)]

consolidado[is.na(recurso_tesouro), recurso_tesouro :=0]
consolidado[is.na(outras_fontes), outras_fontes :=0]

consolidado[, total := recurso_tesouro + outras_fontes]
consolidado[, merge:=NULL]

## modalidade0: Gera os valores agregados para as despesas que irão compor o quadro DEMONSTRATIVO CONSOLIDADO DA DESPESA
# Gera os valores 3.1.00.00 PESSOAL E ENCARGOS SOCIAIS, por exemplo

modalidade0 = consolidado[, list(outras_fontes = sum(outras_fontes, na.rm=T), 
                                 recurso_tesouro = sum(recurso_tesouro, na.rm=T)),
                          by=list(codigo_numerico = substr(codigo_numerico,1,2))]

# Gera o código numérico 91 que representa a linha total do quadro
total =  data.table(codigo_numerico=91, 
                    outras_fontes = modalidade0[, sum(outras_fontes)],
                    recurso_tesouro = modalidade0[, sum(recurso_tesouro)])

total[, total := outras_fontes + recurso_tesouro]
total[, codigo_texto := "TOTAL"]

# Gera o valor para 3.0.00.00 DESPESAS CORRENTES, primeiramente representado pelo código 30
modalidade0 = rbind(modalidade0, data.table(codigo_numerico=30, 
                                            outras_fontes = modalidade0[codigo_numerico<40, sum(outras_fontes)],
                                            recurso_tesouro = modalidade0[codigo_numerico<40, sum(recurso_tesouro)]))

# Gera o valor para 4.0.00.00 DESPESAS DE CAPITAL, primeiramente representado pelo código 40
modalidade0 = rbind(modalidade0, 
                    data.table(codigo_numerico=40,
                               outras_fontes = modalidade0[codigo_numerico>40 & codigo_numerico<50, sum(outras_fontes)],
                               recurso_tesouro = modalidade0[codigo_numerico>40 & codigo_numerico<50, sum(recurso_tesouro)]))

# Cria codigo_numerico com o padrao CATEGORIA, GRUPO_DESPESA, MODALIDADE e ELEMENTO_DESPESA
modalidade0[, codigo_numerico := format(as.numeric(codigo_numerico)*10000, scientific = FALSE)]

modalidade0[, codigo_texto := paste0(substr(codigo_numerico,1,1), ".", substr(codigo_numerico,2,2), ".",
                                     substr(codigo_numerico,3,4), ".", substr(codigo_numerico,5,6))]


modalidade0[codigo_texto=="9.1.00.00", codigo_texto:="Total"]
modalidade0[codigo_texto=="Total", codigo_numerico :=9990000] # Preciso que esse código seja o maior de todos.


modalidade0[, total := outras_fontes + recurso_tesouro]

# Não é necessário apresentar um agregado para Reserva de Contigência
modalidade0 = modalidade0[modalidade0$codigo_numerico!="990000",] 

consolidado = rbind(consolidado, modalidade0)
consolidado = consolidado[order(as.numeric(codigo_numerico))]

consolidado = mergeDT(consolidado, classificacao_despesa, by="codigo_texto", all=T)

if("Apenas no Banco X" %in% consolidado[, unique(merge)]){
  warning(paste("volume7.R banco consolidado: Há códigos de despesa em BASE_QDD_FISCAL.xlsx que não possuem",
                "uma correspondência em desc_classificacao_economica_despesa.xslx. Os codigos são ", 
                paste(consolidado[merge=="Apenas no Banco X", unique(codigo_texto)], collapse=", "),
                "\nCorreção: inserir esses códigos e sua descrição na tabela.\n"))
}

consolidado = consolidado[merge!="Apenas no Banco Y",]

consolidado = consolidado[order(codigo_texto)]
consolidado = rbind(consolidado, total, fill=T)
consolidado = consolidado[, list(codigo_texto, especificacao, recurso_tesouro, outras_fontes, total)]

consolidado[, recurso_tesouro := formatarNum(recurso_tesouro)]
consolidado[, outras_fontes := formatarNum(outras_fontes)]
consolidado[, total := formatarNum(total)]

consolidado[, especificacao := correcaoCaracteresEspeciais(especificacao, caracteres)]

write.table(consolidado, "volume7/data/consolidado.txt", quote = FALSE, sep = "\t", 
            na = "", dec = ",", row.names = FALSE)


# Inicio do QUADRO DE DETALHAMENTO DA DESPESA - FISCAL

banco[, cod_detalhe := paste0(`Instrumento de entrada`,
                              formatC(FUNCAO, width = 2, flag = "0"), 
                              formatC(SUB_FUNCAO, width = 3, flag = "0"),
                              PROGRAMA, 
                              IDENT_PROJATIV, 
                              formatC(PROJ_ATIV, width = 3, flag = "0"), 
                              formatC(SUB_PROJETO, width = 4, flag = "0"), 
                              CATEGORIA, 
                              GRUPO_DESPESA, 
                              MODALIDADE,  
                              formatC(ELEMENTO_DESPESA, width = 2, flag = "0"), 
                              IAG, 
                              FONTE, 
                              IPU)]

if(!"valor_proposto" %in% names(banco)) banco[, valor_proposto:=0]
                          
# Banco representa as linhas que possuem informação até IPU. Com o comando abaixo garanto que não há linhas duplicadas
banco = banco[, list(valor = sum(valor, na.rm=T), valor_proposto = sum(valor_proposto, na.rm = T)), 
              by=list(ANO, COD_ORGAO, ORGAO, COD_UO, UO, NOME_ACAO, FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, 
                      PROJ_ATIV, SUB_PROJETO, CATEGORIA, GRUPO_DESPESA, MODALIDADE, ELEMENTO_DESPESA, IAG, FONTE, 
                      IPU, cod_detalhe,  PODER)]

# Valor total por UO
bancoTotal = banco[, list(valor = sum(valor, na.rm=T), valor_proposto = sum(valor_proposto, na.rm = T)), 
                   by=list(ANO, COD_ORGAO, ORGAO, COD_UO, UO, PODER)]

bancoTotal[,cod_detalhe := paste0("9999999999999999", "0000000000")]
bancoTotal[,NOME_ACAO := "Total"]

# agregado representa as linhas que possuem informação até C/A na tabela, com valores apenas na coluna Total
# Ex. UO=1011 - Primeira Linha:
# ELABORAÇÃO LEGISLATIVA E ACOMPANHAMENTO DAS POLÍITICAS PÚBLICAS 01 031 729 4 239 0001 total=471.866.919

agregado = banco[, list(valor = sum(valor, na.rm=T), valor_proposto = sum(valor_proposto, na.rm = T)), 
                 by=list(ANO, COD_ORGAO, ORGAO, COD_UO, UO, FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, 
                         PROJ_ATIV, SUB_PROJETO, NOME_ACAO, PODER)]

agregado[, cod_detalhe := paste0(formatC(FUNCAO, width = 2, flag = "0"),
                                formatC(SUB_FUNCAO, width = 3, flag = "0"), 
                                PROGRAMA, 
                                IDENT_PROJATIV, 
                                formatC(PROJ_ATIV, width = 3, flag = "0"), 
                                formatC(SUB_PROJETO, width = 4, flag = "0"), "0000000000")]

banco = banco[, (6:12):=NA] #Tornar NA as colunas NOME_ACAO, FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, SUB_PROJETO

banco = rbind(banco, agregado, fill=TRUE)
banco = rbind(banco, bancoTotal, fill=TRUE)

banco = mergeDT(banco, poderes, by.x="PODER", by.y="cod_poder", all=T)

if("Apenas no Banco X" %in% banco[, unique(merge)]){
  warning(paste("Há um código de Poder que aparece no banco, que não está presente no banco de apoio codigosPoder.xlsx.",
                "Trata-se de", paste(banco[merge=="Apenas no Banco X", unique(PODER)], collapse="\n"), 
                ". Alterar em codigosPoder.xlsx \n"))
  }

banco = banco[order(PODER, COD_ORGAO, COD_UO, cod_detalhe)]

banco[, c("cod_detalhe", "PODER") := NULL]

if(TRUE %in% (banco$valor<0)){
  warning(paste("QUADRO DETALHAMENTO DESPESA: Há valores negativos na linha ", 
                paste0(which(banco$valor<0)+1, collapse=", ")))
} 

banco = banco[valor>0,] # Não incluir valores iguais a zero ou negativos

banco[, valor := formatarNum(valor)]

if(banco[, sum(valor_proposto, na.rm = T)] == 0){
  banco[, valor_proposto:=NULL]
} else{
  banco[, valor_proposto := formatarNum(valor_proposto)]
}


banco[,NOME_ACAO := correcaoCaracteresEspeciais(NOME_ACAO, caracteres)]
banco[,ORGAO := correcaoCaracteresEspeciais(ORGAO, caracteres)]
banco[,UO := correcaoCaracteresEspeciais(UO, caracteres)]
banco[,poder := correcaoCaracteresEspeciais(poder, caracteres)]

write.table(banco, "volume7/data/QUADRO_DETALHAMENTO_DESPESA_porUO.txt",
            quote = FALSE, sep = "\t",  na = "", dec = ",", row.names = FALSE)

