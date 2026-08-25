# Organização do banco DEMONSTRATIVO DOS RECURSOS FINANCEIROS - Volume 2

options(warn=1, scipen = 999)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataTransferencias.R", encoding = "UTF-8")

# ============================================================================
# Definir parâmetros

desconsiderarUO = c(9901)
# ============================================================================

receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_2017.xlsx", TRUE)
setnames(receita, "UO_COD", "COD_UO")

classificacao_receita = data.table(read_excel("bancos/manual/desc_classificacao_receita_antiga.xlsx", sheet=1))
                                   
classificacao_receita[, cod_texto := paste0(substr(cod, 1, 4), ".", substr(cod, 5, 6), ".", 
                                            substr(cod, 7, 8), ".", substr(cod, 9, 10))]

## Sumário

sumario = data.table(read.table("volume2/data/sumario.txt", header = T, sep = "\t", 
                                quote = "\"'",    dec = "@"))

## O Universo de Uo's considerada deve ser proveniente dos bancos de receita, transferência e repasse
### Transferências entre UO's####
transf = trataTransferencias("bancos/SISOR/BASE_REPASSE_RECURSOS.xlsx")
transf = transf[,grepl("cod", names(transf)), with=FALSE]


if(ncol(transf)!=2){ 
  warning(paste("V2_Tabela4_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS: Erro no tratamento de BASE_REPASSE_RECURSOS.xlsx.",
                "Expectativa era que tivesse apenas duas colunas: Codigo UO Financiadora ou Codigo UO Beneficiada.\n"))
  }

uo_transf = union(unlist(transf[,1, with=F],use.names = F), unlist(transf[,2, with=F],use.names = F))


UnidadesOrcamentarias = c()

subtotal1 = data.table(COD_UO=as.numeric(), subtotal1 = as.numeric()) # Necessário para a tabela 5, totais 4 e 5

for(codigo_uo in sumario[!COD_UO %in% desconsiderarUO, COD_UO]){

  #codigo_uo =  3151

  uo = receita[COD_UO==codigo_uo, ]
  
  if(nrow(uo)>0){
  
  uo_fonte = uo[, list(valor = sum(valor, na.rm=T)), 
                by=list(CATEGORIA, SUBCATEGORIA, FONTE_CLAS, RUBRICA, 
                        ALINEA, SUBALINEA, ITEM, COD_FONTE)]

  uo_subalinea = uo[,  list(valor = sum(valor, na.rm=T)), 
                    by=list(CATEGORIA, SUBCATEGORIA, FONTE_CLAS, RUBRICA, ALINEA, SUBALINEA)]
  
  uo_alinea = uo[,list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA, SUBCATEGORIA, FONTE_CLAS, RUBRICA, ALINEA)]
  uo_rubrica = uo[,list(valor = sum(valor, na.rm=T)), by=list(CATEGORIA, SUBCATEGORIA, FONTE_CLAS, RUBRICA)]
  uo_fonteclas = uo[, list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA, SUBCATEGORIA, FONTE_CLAS)]
  uo_subcategoria = uo[,list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA, SUBCATEGORIA)]
  uo_categoria = uo[,list(valor=sum(valor, na.rm=T)), by=list(CATEGORIA)]
  
  total = uo_categoria[,lapply(.SD, function(x) sum(x, na.rm=T))]
  total[, CATEGORIA := NULL]
  total[, descricao := "SUBTOTAL 1"]
  setnames(total, "valor", "valor_categoria")
  
  if(class(total[1, valor_categoria])=="numeric"){
    
    subtotal1 = rbind(subtotal1, 
                      data.table(COD_UO=codigo_uo, subtotal1 = total[1, valor_categoria]))
    
  } else{
    warning(paste("V2_Tabela4_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS: Erro no cálculo do valor",
                  "de subtotal1. Para a UO ", codigo_uo,". Valor obtido: ", 
                  total[1, valor_categoria], "\n"))
  }
  
  uo_final = rbind(uo_categoria, uo_subcategoria, fill=T)
  uo_final = rbind(uo_final, uo_fonteclas, fill=T)
  uo_final = rbind(uo_final, uo_rubrica, fill=T)
  uo_final = rbind(uo_final, uo_alinea, fill=T)
  uo_final = rbind(uo_final, uo_subalinea, fill=T)
  uo_final = rbind(uo_final, uo_fonte, fill=T)
  
  setcolorder(uo_final, union(grep("^(?!^valor).*", names(uo_final), perl=T, value = T),
                              grep("^valor.*", names(uo_final), perl=T, value = T)))
  
  uo_final = uo_final[, (1:7):=lapply(.SD, na2zero), .SDcols=1:7]
  
  uo_final[, cod_texto := paste0(CATEGORIA, SUBCATEGORIA, FONTE_CLAS, RUBRICA, ".", 
                                 formatC(ALINEA, width = 2, flag = "0"), ".", 
                                 formatC(SUBALINEA, width = 2, flag = "0"), ".", 
                                 formatC(ITEM, width = 2, flag = "0"))]
  
  uo_final = uo_final[order(cod_texto, COD_FONTE, na.last = T)]
  
  uo_final[, repetido := 0]
  
  for(j in 2:nrow(uo_final)){
    if(uo_final[j, cod_texto] == uo_final[j-1, cod_texto]){
      uo_final[j, repetido := 1]
    } else {
      uo_final[j, repetido:= 0]
      }
  }
  
  uo_final = uo_final[!(repetido==1 & is.na(COD_FONTE)), list(cod_texto, COD_FONTE, valor)]
  
  uo_final[, tipo := ifelse(grepl("\\d{1,2}0{2,3}\\.00\\.00\\.00", cod_texto), "valor_categoria",
                     ifelse(grepl("\\d{3}0\\.00\\.00\\.00", cod_texto), "valor_especie",  
                     "valor_desdobramento"))]
  
  uo_final = uo_final[order(cod_texto, COD_FONTE, na.last = F)]
  
  uo_final = dcast(uo_final, cod_texto + COD_FONTE ~ tipo, fun.aggregate= function(x){sum(x, na.rm=T)}, 
               value.var = "valor")
  
  uo_final = mergeDT(uo_final, classificacao_receita, by.x="cod_texto", by.y="cod_texto", all=T)
  
  if("Apenas no Banco X" %in% uo_final[, unique(merge)]){
    
   warning(paste("V2_Tabela4_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS: Há um código de receita para a UO ", 
                     codigo_uo, " que não está disponível no banco de apoio", 
                     "na aba de classificação da receita. Trata-se do codigo ", 
                     paste(uo_final[merge=="Apenas no Banco X", cod_texto], collapse=", " ),
                     ". Alimentar o banco de apoio com esse código. \n"))
    
    uo_final = uo_final[merge!="Apenas no Banco X",]
    
  }
  
  uo_final = uo_final[merge!="Apenas no Banco Y",]
  
  if(length(setdiff(c("valor_desdobramento", "valor_especie", "valor_categoria"), names(uo_final)))>0){
    
    uo_final[,setdiff(c("valor_desdobramento", "valor_especie", "valor_categoria"), names(uo_final)):= 0]
    
  }
  
  uo_final = uo_final[, list(cod_texto, COD_FONTE, descricao, valor_desdobramento, valor_especie, valor_categoria)]
  
  uo_final = uo_final[,(4:6):= lapply(.SD, function(x) ifelse(x==0, NA, x)), .SDcols=4:6]
  
  # Caso em que para a UO a tabela 4 possui valores.
  
  } else{
    
    uo_final = data.table(cod_texto = "", 
                          COD_FONTE = "", 
                          descricao = "", 
                          valor_desdobramento = 0, valor_especie = 0, valor_categoria = 0)
    
    total = data.table(cod_texto = "", 
                       COD_FONTE = "", 
                       descricao="SUBTOTAL 1", 
                       valor_desdobramento=0, valor_especie=0, valor_categoria=0)
    
    # Caso em que para a UO a tabela 4 está zerada. Foi necessário fazê-la pq existe a tabela 5
    
  }
                                                                                                
  if(!codigo_uo %in% sumario[, unique(COD_UO)]){
    
    warning(paste("V2_Tabela4_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS: Código ", 
                      codigo_uo, " não encontrado no sumário. \n"))
    
  } else{
    
    uo_final[, c("nome_uo", "nome_orgao") := NA]
    uo_final$nome_uo[1] = paste0(substr(codigo_uo, 1, 1), ".", substr(codigo_uo, 2, 3), ".", 
                                 substr(codigo_uo, 4, 4)," - ", sumario[COD_UO==codigo_uo, UO])
    
    cod_orgao = sumario[COD_UO==codigo_uo, COD_ORGAO]
    
    uo_final$nome_orgao[1] = paste0(substr(cod_orgao, 1, 1), ".", substr(cod_orgao, 2, 3), ".", 
                                    substr(cod_orgao, 4, 4), " - ", sumario[COD_UO==codigo_uo, ORGAO])
    }
    
  frequencia = as.data.table(table(paste0(uo_final$cod_texto, ":", uo_final$COD_FONTE, " --> ", uo_final$descricao)))
  
  if(max(frequencia$N)>1){
    warning(paste("V2_Tabela4_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS: Para a UO ", codigo_uo, 
                  " há um código que aparece mais de uma vez, o que gera o erro da especificação",
                  "aparecer duplicada na tabela. Verificar o seguinte caso: ", 
                  paste(frequencia[N>1, V1], collapse=", "), ". Talvez seja necessário corrigir o código.\n"))
  }
  
  uo_final = rbind(uo_final, total, fill=T) 
  
  uo_final = uo_final[,lapply(.SD, formatarNum)]
  
  uo_final[, nome_orgao := correcaoCaracteresEspeciais(nome_orgao, caracteres)]
  uo_final[, nome_uo := correcaoCaracteresEspeciais(nome_uo, caracteres)]
  uo_final[, descricao := correcaoCaracteresEspeciais(descricao, caracteres)]
  
  write.table(uo_final, paste0("volume2/data/tabela4/", codigo_uo,".txt"), quote = TRUE, sep = "\t",
              na = "", dec = ",", row.names = FALSE)

  UnidadesOrcamentarias = append(UnidadesOrcamentarias, codigo_uo)
  
}

write.table(subtotal1, "volume2/data/tabela4/subtotal1.txt", quote = TRUE, sep = "\t",
            na = "", dec = ",", row.names = FALSE)
