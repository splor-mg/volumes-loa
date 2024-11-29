# Organização do banco T9 DEMONSTRATIVO RECEITA ORCAMENTARIA CORRENTE ORDINARIA - Volume 1
options(warn = 1, scipen = 999)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")

# ============================================================================
# Definir parâmetros

rec_ordinario = c(10, 15, 19) #São considerados somente fonte 10 e 15 para obtenção de base de cálculo da FAPEMIG
# ============================================================================

receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", TRUE)
receita = receita[CATEGORIA==1 & COD_FONTE %in% rec_ordinario,]

classificacao_receita = ler_novaReceita("bancos/manual/desc_classificacao_receita.xlsx")

classificacao_receita[, cod_texto := paste0(substr(RECEITA_COD, 1, 4), ".", substr(RECEITA_COD, 5, 6), ".",
                                            substr(RECEITA_COD, 7, 7), ".", substr(RECEITA_COD, 8, 8), ".",
                                            substr(RECEITA_COD, 9, 10), ".", substr(RECEITA_COD, 11, 13))]

por_fonte = receita[, list(valor = sum(valor, na.rm=T)),
                    by=list(CATEGORIA, ORIGEM, ESPECIE, RUBRICA, ALINEA, SUBALINEA, TIPO, ITEM, SUBITEM, COD_FONTE)]

por_item = receita[, list(valor=sum(valor, na.rm=T)),
                   by=list(CATEGORIA, ORIGEM, ESPECIE, RUBRICA, ALINEA, SUBALINEA, TIPO, ITEM)]

por_tipo = receita[, list(valor = sum(valor, na.rm=T)),
                   by=list(CATEGORIA, ORIGEM, ESPECIE, RUBRICA, ALINEA, SUBALINEA, TIPO)]

por_subalinea = receita[, list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA, ORIGEM, ESPECIE, RUBRICA, ALINEA, SUBALINEA)]
por_alinea = receita[,list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA, ORIGEM, ESPECIE, RUBRICA, ALINEA)]
por_rubrica = receita[,list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA, ORIGEM, ESPECIE, RUBRICA)]
por_especie = receita[,list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA, ORIGEM, ESPECIE)]
por_origem = receita[,list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA, ORIGEM)]
por_categoria = receita[,list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA)]

total = por_categoria[,lapply(.SD, function(x) sum(x, na.rm=T))]
total[, CATEGORIA := NULL]
total[, descricao := "TOTAL"]
setnames(total, "valor", "valor_categoria")

final = rbindlist(list(por_categoria, por_origem, por_especie, por_rubrica, por_alinea,
                       por_subalinea, por_tipo, por_item, por_fonte), fill=T)

setcolorder(final, union(grep("^(?!^valor).*", names(final), perl=T, value = T),
                         grep("^valor.*", names(final), perl=T, value = T)))

indice_cat = which(names(final)=="CATEGORIA")
indice_subitem = which(names(final)=="SUBITEM")

final = final[, (indice_cat:indice_subitem):=lapply(.SD, na2zero), .SDcols=indice_cat:indice_subitem]

final[, cod_texto := paste0(CATEGORIA, ORIGEM, ESPECIE, RUBRICA, ".",
                            formatC(ALINEA, width = 2, flag = "0"), ".",
                            SUBALINEA, ".", TIPO, ".",
                            formatC(ITEM, width = 2, flag = "0"), ".",
                            formatC(SUBITEM, width = 3, flag = "0"))]

final = final[order(cod_texto, COD_FONTE, na.last = T)]

final[, repetido := 0]

for(j in 2:nrow(final)){
  if(final[j, cod_texto] == final[j-1, cod_texto]){
    final[j, repetido := 1]
  } else {
      final[j, repetido := 0]
      }
  }

final = final[!(repetido==1 & is.na(COD_FONTE)), list(cod_texto, COD_FONTE, valor)]

final[, tipo := ifelse(grepl("\\d{1,2}0{2,3}\\.00\\.0\\.0\\.00\\.000", cod_texto), "valor_categoria",
                       ifelse(grepl("\\d{3}0\\.00\\.0\\.0\\.00\\.000", cod_texto), "valor_especie",
                              "valor_desdobramento"))]

final = final[order(cod_texto, COD_FONTE, na.last = F)]

final = dcast(final, cod_texto + COD_FONTE ~ tipo,
              fun.aggregate= function(x){sum(x, na.rm=T)},
              value.var = "valor")

final = mergeDT(final, classificacao_receita, by.x="cod_texto", by.y="cod_texto", all=T)

if(nrow(final[merge=="Apenas no Banco X" & !is.na(COD_FONTE), ]) > 0){

  detalhes = final[merge=="Apenas no Banco X" & !is.na(COD_FONTE), unique(cod_texto)]

  warning(paste("T9_DEMONSTRATIVO_RECEITA_ORCAMENTARIA_CORRENTE_ORDINARIA.R: Há um código de receita que não está disponível",
                "\n DETALHES: (não pode desconsiderar) \n", paste0(detalhes, collapse = "\n")))

}


final = final[merge!="Apenas no Banco X",]
final = final[merge!="Apenas no Banco Y",]

if(length(setdiff(c("valor_desdobramento", "valor_especie", "valor_categoria"), names(final)))>0){

  final[,setdiff(c("valor_desdobramento", "valor_especie", "valor_categoria"), names(final)):= 0]

}

final = final[, list(cod_texto, COD_FONTE, descricao=RECEITA_DESC, valor_desdobramento, valor_especie, valor_categoria)]

final = final[,(4:6):= lapply(.SD, function(x) ifelse(x==0, NA, x)), .SDcols=4:6]

frequencia = as.data.frame(table(paste(final$cod_texto, ":", final$COD_FONTE, " --> ", final$descricao, sep="")))

if(max(frequencia$Freq)>1){
  warning(paste("T9_DEMONSTRATIVO_RECEITA_ORCAMENTARIA_CORRENTE_ORDINARIA: Há um código que aparece",
                "mais de uma vez, o que gera o erro da especificação aparecer duplicada na tabela.",
                "Verificar o seguinte caso: ", frequencia$Var1[frequencia$Freq>1],
                ". Talvez seja necessário corrigir o código.\n", sep=""))
}

final = rbind(final, total, fill=T)
final = final[,lapply(.SD, formatarNum)]

final[grepl(" *-.+", valor_desdobramento) & is.na(valor_desdobramento)==F,
      valor_desdobramento:= paste0("(",gsub(" *-(.+)", "\\1", valor_desdobramento),")")]

final[grepl(" *-.+", valor_especie) & is.na(valor_especie)==F,
      valor_especie:= paste0("(",gsub(" *-(.+)", "\\1", valor_especie),")")]

final[grepl(" *-.+", valor_categoria) & is.na(valor_categoria)==F,
      valor_categoria:= paste0("(",gsub(" *-(.+)", "\\1", valor_categoria),")")]

final[, descricao := correcaoCaracteresEspeciais(descricao, caracteres)]

write.table(final, "volume1/data/T9_DEMONSTRATIVO_RECEITA_ORCAMENTARIA_CORRENTE_ORDINARIA.txt",quote = F,
            sep = "\t", na = "", dec = ",", row.names = FALSE)
