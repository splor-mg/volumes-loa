# Script Utilizado para a codificação da receita vigente em 2016/2017
options(warn = 1)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")

# ============================================================================
# Definir parâmetros

desconsiderarUO = c(9901)
# ============================================================================

# Receita Orçamentária
receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", TRUE)

classificacao_receita = data.table(read_excel("bancos/manual/desc_classificacao_receita_2017.xlsx", sheet=1))

names(classificacao_receita) = c("cod", "descricao", "tipo")

classificacao_receita[, cod_texto := paste0(substr(cod, 1, 4), ".", substr(cod, 5, 6), ".", 
                                            substr(cod, 7, 8), ".", substr(cod, 9, 10))]

por_fonte = receita[, list(valor = sum(valor, na.rm=T)), 
                    by=list(CATEGORIA, SUBCATEGORIA, FONTE_CLAS, RUBRICA, 
                            ALINEA, SUBALINEA, ITEM, COD_FONTE)]

por_subalinea = receita[, list(valor = sum(valor, na.rm=T)), 
                        by=list(CATEGORIA, SUBCATEGORIA, FONTE_CLAS, RUBRICA, 
                                ALINEA, SUBALINEA)]

por_alinea = receita[, list(valor=sum(valor, na.rm=T)), 
                     by=list(CATEGORIA, SUBCATEGORIA, FONTE_CLAS, RUBRICA, ALINEA)]

por_rubrica = receita[, list(valor = sum(valor, na.rm=T)), 
                      by=list(CATEGORIA, SUBCATEGORIA, FONTE_CLAS, RUBRICA)]

por_fonteclas = receita[, list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA, SUBCATEGORIA, FONTE_CLAS)]

por_subcategoria = receita[,list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA, SUBCATEGORIA)]

por_categoria = receita[,list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA)]

total = por_categoria[,lapply(.SD, function(x) sum(x, na.rm=T))]
total[, CATEGORIA := NULL]
total[, descricao := "TOTAL"]
setnames(total, "valor", "valor_categoria")

final = rbindlist(list(por_categoria, por_subcategoria, por_fonteclas,
                       por_rubrica, por_alinea, por_subalinea, 
                       por_fonte), fill=T)

setcolorder(final, union(grep("^(?!^valor).*", names(final), perl=T, value = T),
                         grep("^valor.*", names(final), perl=T, value = T)))

final = final[, (1:7):=lapply(.SD, na2zero), .SDcols=1:7]

final[, cod_texto := paste0(CATEGORIA, SUBCATEGORIA, FONTE_CLAS, RUBRICA, ".", 
                            formatC(ALINEA, width = 2, flag = "0"), ".", 
                            formatC(SUBALINEA, width = 2, flag = "0"), ".", 
                            formatC(ITEM, width = 2, flag = "0"))]

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

final[, tipo := ifelse(grepl("\\d{1,2}0{2,3}\\.00\\.00\\.00", cod_texto), "valor_categoria",
                       ifelse(grepl("\\d{3}0\\.00\\.00\\.00", cod_texto), "valor_especie",  "valor_desdobramento"))]

final = final[order(cod_texto, COD_FONTE, na.last = F)]

final = dcast(final, cod_texto + COD_FONTE ~ tipo, 
              fun.aggregate= function(x){sum(x, na.rm=T)},
              value.var = "valor")

final = mergeDT(final, classificacao_receita, by.x="cod_texto", by.y="cod_texto", all=T)

if("Apenas no Banco X" %in% final[, unique(merge)]){
  
  warning(paste("T7_QUADRO_GERAL_DA_RECEITA.R: Há um código de receita que não está disponível",
                "no banco de apoio banco_apoio, na aba de classificação da receita. Trata(m)-se do(s)",
                "codigo(s):\n ", paste0(final[merge=="Apenas no Banco X", unique(cod_texto)], collapse="\n"),
                "\nAlimentar o banco de apoio com esse(s) código(s). \n"))
}

final = final[merge!="Apenas no Banco X",]
final = final[merge!="Apenas no Banco Y",]

if(length(setdiff(c("valor_desdobramento", "valor_especie", "valor_categoria"), names(final)))>0){
  final[,setdiff(c("valor_desdobramento", "valor_especie", "valor_categoria"), names(final)):= 0]
}

final = final[, list(cod_texto, COD_FONTE, descricao, valor_desdobramento, valor_especie, valor_categoria)]

final = final[,(4:6):= lapply(.SD, function(x) ifelse(x==0, NA, x)), .SDcols=4:6]

frequencia = as.data.frame(table(paste(final$cod_texto, ":", final$COD_FONTE, " --> ", final$descricao, sep="")))

if(max(frequencia$Freq)>1){
  warning(paste("T7_QUADRO_GERAL_DA_RECEITA.R: Há um código que aparece mais de uma vez, ",
                "o que gera o erro da especificação aparecer duplicada na tabela. Verificar o seguinte caso: ",
                frequencia$Var1[frequencia$Freq>1], ". Talvez seja necessário corrigir o código.\n"))
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

write.table(final, "volume1/data/T7_QUADRO_GERAL_DA_RECEITA.txt", quote = F, 
            sep = "\t", na = "", dec = ",", row.names = FALSE)

