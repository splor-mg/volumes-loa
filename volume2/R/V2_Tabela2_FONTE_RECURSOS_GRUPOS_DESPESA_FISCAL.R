# Organização do banco FONTE DE RECURSOS DE GRUPOS DE DESPESA – FISCAL - Volume 2 
options(warn=1)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)

grupo_despesa = data.table(read_excel("bancos/manual/desc_grupos_de_despesa.xlsx", sheet=1))
grupo_despesa = grupo_despesa[, list(CODIGO, ESPECIFICACAO)]

fonte_recursos = data.table(read_excel("bancos/manual/desc_fontes_de_recursos.xlsx",sheet=1))
fonte_recursos = fonte_recursos[!is.na(CLASSIFICACAO), c("CODIGO", "CLASSIFICACAO")]

for(codigo_uo in qdd[, unique(COD_UO)]){

  #codigo_uo =  1451

  uo = qdd[COD_UO==codigo_uo, ]
  
  fonte = uo[,list(valor = sum(valor, na.rm=T)), by=list(FONTE, IAG, IPU, GRUPO_DESPESA)]

  fonte <- reshape(fonte, timevar = "GRUPO_DESPESA", idvar = c("FONTE", "IAG", "IPU"),  direction = "wide")
  
  setcolorder(fonte, sort(sort(names(fonte))))
  
  col_final = ncol(fonte)

  fonte$Total = fonte[,apply(.SD, 1, function(x) sum(x, na.rm=T)), .SDcols=4:col_final]
  
  total = fonte[, lapply(.SD, function(x) sum(x, na.rm=T))]
  total[, FONTE := "Total"]
  
  total_por_fonte = fonte[, lapply(.SD, function(x) sum(x, na.rm=T)), by=.(FONTE)]
  total_por_fonte[, IAG := 99]
  
  fonte = rbind(fonte, total_por_fonte, fill=T)
  
  fonte = mergeDT(fonte, fonte_recursos, by.x="FONTE", by.y="CODIGO", all=T)
  
  if("Apenas no Banco X" %in% fonte[, unique(merge)]){
    warning(paste0("V2_Tabela2_FONTE_RECURSOS_GRUPOS_DESPESA_FISCAL: Há um codigo de FONTE em BASE_QDD_FISCAL ",
                  "que não possui correspondência em desc_fontes_de_recursos.xlsx. Trata-se do valor ", 
                   paste(fonte[merge=="Apenas no Banco X", unique(FONTE)], collapse=", "),
                   ". Alterar os valores nessa aba e rodar novamente o código.\n"))
    }
  
  fonte = fonte[merge=="Em ambos os bancos",]
  
  fonte[, FONTE := toupper(paste0(FONTE, " - ", CLASSIFICACAO))]
  
  fonte[, c("CLASSIFICACAO", "merge") := NULL]
  
  fonte = fonte[, lapply(.SD, na2zero)]
  fonte = fonte[order(FONTE, IAG, IPU)]
  
  frequencia_fontes = fonte[,list(celulas_mesclar_fonte=.N), by=list(FONTE)]
  frequencia_iag = fonte[,list(celulas_mesclar_iag=.N), by=list(FONTE, IAG)]
  
  fonte = mergeDT(fonte, frequencia_fontes, by.x="FONTE", by.y="FONTE", all=T)
  fonte = mergeDT(fonte, frequencia_iag, by.x=c("FONTE", "IAG"), by.y=c("FONTE", "IAG"), all=T)
  fonte$merge = NULL
  
  linhas_fonte_na = c()
  linhas_iag_na = c()
  
  for(i in 2:nrow(fonte)){
    if(fonte$FONTE[i]==fonte$FONTE[i-1]){ 
        linhas_fonte_na = append(linhas_fonte_na, i)
      }
    if(fonte$IAG[i]==fonte$IAG[i-1]){ 
        linhas_iag_na = append(linhas_iag_na, i)
    }
  }
  
  if(length(linhas_fonte_na)>0){
    fonte = fonte[linhas_fonte_na, c("FONTE", "celulas_mesclar_fonte"):=NA]
  }
  if(length(linhas_iag_na)>0){
    fonte = fonte[linhas_iag_na, c("IAG", "celulas_mesclar_iag"):=NA]
  }
  
  fonte = rbind(fonte, total, fill=T)
  fonte = fonte[celulas_mesclar_iag==1, celulas_mesclar_iag:=NA]

  fonte[, c("nome_uo", "nome_orgao"):=NA]
  
  fonte$nome_uo[1] = paste0(substr(uo$COD_UO[1],1,1), ".", substr(uo$COD_UO[1],2,3), ".", 
                            substr(uo$COD_UO[1],4,4), " - ",  toupper(uo$UO[1]))

  
  fonte$nome_orgao[1] = paste0(substr(uo$COD_ORGAO[1],1,1), ".", substr(uo$COD_ORGAO[1],2,3), ".", 
                              substr(uo$COD_ORGAO[1],4,4), " - ", toupper(uo$ORGAO[1]))
  
  setcolorder(fonte, 
                append(union(
                  c("nome_orgao", "nome_uo", "celulas_mesclar_fonte", "celulas_mesclar_iag", "FONTE","IAG", "IPU"), 
                  grep("valor\\.(.+)", names(fonte), value = T)), "Total"))
  
  variaveis_valores = grep("valor\\.(.+)", names(fonte), value = T)
  
  if(length(variaveis_valores)==1 & variaveis_valores[1]=="valor.9"){
   
    novos_nomes = "RESERVA DE CONTINGÊNCIA" 
    
  } else{
  
  cod_despesa_para_uo = gsub("valor\\.(.+)", "\\1", variaveis_valores)
  
  novos_nomes = unlist(lapply(cod_despesa_para_uo, function(x) grupo_despesa[CODIGO==x, ESPECIFICACAO]))
  
  if(length(novos_nomes)<length(cod_despesa_para_uo)){
    
    warning(paste0("V2_Tabela2_FONTE_RECURSOS_GRUPOS_DESPESA_FISCAL: Há um codigo de GRUPO DE DESPESA em ",
                 "BASE_QDD_FISCAL que não possui correspondência em desc_grupos_de_despesa.xlsx.",
                 "Trata-se do valor ", 
                 paste(setdiff(cod_despesa_para_uo, grupo_despesa[, unique(CODIGO)]), collapse=", "),
                 ". Alterar os valores nessa aba e rodar novamente o código.\n\n"))
    }
  }
  
  setnames(fonte, variaveis_valores, toupper(novos_nomes))
  
  fonte = fonte[,lapply(.SD, formatarNum)]

  fonte[, nome_orgao := correcaoCaracteresEspeciais(nome_orgao, caracteres)]
  fonte[, nome_uo := correcaoCaracteresEspeciais(nome_uo, caracteres)]
  fonte[, FONTE := correcaoCaracteresEspeciais(FONTE, caracteres)]
  
  setnames(fonte, "FONTE",  "FONTE / GRUPO DE DESPESA")
  
  fonte = fonte[IAG==99, IAG:="Total"]
  
  
  write.table(fonte, paste0("volume2/data/tabela2/", codigo_uo,".txt"), quote = TRUE, sep = "\t",
              na = "", dec = ",", row.names = FALSE)

}
  
## Banco para IPU e IAG
  
iag = data.table(read_excel("bancos/manual/desc_IAG.xlsx",sheet=1))
ipu = data.table(read_excel("bancos/manual/desc_IPU.xlsx",sheet=1))
  
rodape = data.frame(ipu = paste(ipu$CODIGO, " - ", ipu$ESPECIFICACAO, sep=""))
  
rodape$iag = NA
rodape$iag[1:nrow(iag)] = paste(iag$CODIGO, " - ", iag$INTERPRETACAO, sep="")
  
write.table(rodape, "volume2/data/tabela2/rodape.txt", quote = TRUE, sep = "\t",
            na = "", dec = ",", row.names = FALSE)
