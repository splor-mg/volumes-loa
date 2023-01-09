# Organização do banco RECURSOS FINANCEIROS FONTE DE RECURSOS E APLICAÇÃO - INVESTIMENTO por UO - Volume 3 
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")

qdd = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")

for(codigo_uo in qdd[, unique(COD_UO)]){
  # codigo_uo = 5401
  uo = qdd[COD_UO==codigo_uo,]
browser
  uo_final = uo[,list(v=sum(valor, na.rm=T)), by=list(NATUREZA, FONTE)]

  uo_final = uo_final[order(NATUREZA)]

  if(length(uo_final[, unique(NATUREZA)]) > 7){
    
    warning(paste0("V3_T3_RECURSOS_FINANCEIROS_FONTE_RECURSOS_APLICACAO_INVESTIMENTO: Há ", 
                   length(uo_final[, unique(NATUREZA)]), " diferentes naturezas, o que significa que a tabela 3", 
                   " para a UO ", uo[1, COD_UO], " terá ",  (length(uo_final[, unique(NATUREZA)])+2), 
                   " colunas. O código em volume3.Rnw foi testado na perspectiva da tabela ter no máximo 9 colunas. ",
                   "Verificar para essa UO se houve quebra no layout!"))
                      
    }
  
  # Padroniza nomes de Natureza substituindo espaços e vírgulas
  uo_final[, NATUREZA := gsub(" ", "-", NATUREZA)]
  uo_final[, NATUREZA := gsub(",", "\\.", NATUREZA)]

  uo_final[, NATUREZA := correcaoCaracteresEspeciais(NATUREZA, caracteres)]
  uo_final[, FONTE := correcaoCaracteresEspeciais(FONTE, caracteres)]
  
  uo_final <- reshape(uo_final, timevar = "NATUREZA", idvar = "FONTE",  direction = "wide")
  uo_final = uo_final[order(FONTE)]

  total = uo_final[,lapply(.SD, function(x){sum(x, na.rm=T)}), .SDcols=2:ncol(uo_final)]
  total[, FONTE := "TOTAL"]

  uo_final = rbind(uo_final, total)

  uo_final = uo_final[,lapply(.SD, na2zero)]
  uo_final$TOTAL = uo_final[,apply(.SD,1, sum), .SDcols=2:ncol(uo_final)]

  uo_final = uo_final[,lapply(.SD, formatarNum)]

  # uo_final_temp: A primeira linha do banco deve ser o nome das variáveis.
  uo_final_temp = uo_final[is.na(FONTE),]
  uo_final_temp = as.data.frame(uo_final_temp)
  uo_final_temp[1,] = gsub("v\\.(.+)", "\\1", names(uo_final_temp))
  uo_final_temp[1,] = gsub("-", " ", uo_final_temp[1,])

  # uo_final será a junção de uma linha com o nome das colunas e as demais linhas com conteúdo
  # descritas em uo_final anteriormente
  uo_final = rbind(uo_final_temp, uo_final[1:nrow(uo_final), ])
  
  #browser()
  #[ANDREY][24/08/2020] conversão para resolver erro Error in `:=`(c("uo", "orgao"), NA) : Check that is.data.table(DT) == TRUE. Otherwise, := and `:=`(...) are defined for use in j, once only and in particular ways. See help(":=").  
  uo_final <- as.data.table(uo_final)
  
  uo_final$FONTE[1] = "FONTE DE RECURSO / DETALHAMENTO DE INVESTIMENTO"
  
  # uo_final_temp cria um banco com nome da uo e nome do órgão. O motivo da criação desse banco
  # é que preciso que uo e orgao sejam as duas primeiras colunas do banco
  
  uo_final$uo = paste0(substr(uo$COD_UO[1],1,1), ".", substr(uo$COD_UO[1],2,3), ".", 
                       substr(uo$COD_UO[1],4,4), " - ",  toupper(uo$UO[1]))
  
  uo_final$orgao = paste0(substr(uo$COD_ORGAO[1],1,1), ".", substr(uo$COD_ORGAO[1],2,3), ".", 
                          substr(uo$COD_ORGAO[1],4,4), " - ",  toupper(uo$ORGAO[1]))
  
  browser
  uo_final[2:nrow(uo_final), c("uo", "orgao"):=NA]
  
  setcolorder(uo_final, c("uo", "orgao", names(uo_final)[!grepl("^(uo|orgao)$", names(uo_final))]))
  
  uo_final[, uo := correcaoCaracteresEspeciais(uo, caracteres)]
  uo_final[, orgao := correcaoCaracteresEspeciais(orgao, caracteres)]

  write.table(uo_final, paste0("volume3/data/tabela3/", codigo_uo,".txt"), quote = FALSE, 
              sep = "\t", na = "", dec = ",", row.names = FALSE, col.names = F)

}
