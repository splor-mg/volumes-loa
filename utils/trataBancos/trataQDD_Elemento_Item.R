
trataQDD_Elemento_Item = function(caminho, realizarTeste = TRUE){
  
  #==========================================================================================================
  # Função para abir o banco bancos/SISOR/BASE_ORCAM_DESPESA_ITEM_FISCAL.xlsx presente no volume 5 e volume 2
  #==========================================================================================================
  
  avisoNumAbas(caminho)
  
  qdd = data.table(read_excel(caminho, sheet=1))
  names(qdd) = removeAcentos(names(qdd))
  
  nomes_esperados = c("codigo do orgao", "codigo da uo", "funcao", "subfuncao", "programa", "acao", "subprojeto", 
                      "categoria", "grupo_despesa", "modalidade", "elemento_despesa", "item_despesa", 
                      "fonte", "ipu", "iag", "valor (r$)")
  
  novos_nomes = c("ORGAO_COD", "UO_COD", "FUNCAO_COD", "SUBFUNCAO_COD", "PROGRAMA_COD", "ACAO_COD", "SUBPROJETO_COD",
                  "CATEGORIA_COD", "GRUPO_COD", "MODALIDADE_COD", "ELEMENTO_COD", "ITEM_COD",
                  "FONTE_COD", "IPU_COD", "IAG_COD", "VL_LOA_DESP")
  
  nomes_diferentes = setdiff(nomes_esperados, names(qdd))
    
  if(length(nomes_diferentes)>0){
    warning(paste("trataQDD_Elemento_Item: Há nomes diferentes no banco. Os seguintes nomes de campos não estão ",
                  "no banco atual: {{", paste(nomes_diferentes, collapse=", ")," }}"))
  }
  
  setnames(qdd, nomes_esperados, novos_nomes)
  
  qdd = qdd[, novos_nomes, with=F]
  qdd[, ELEMENTO_ITEM_COD := as.numeric(paste0(ELEMENTO_COD, formatC(ITEM_COD, width = 2, flag="0")))]
  
  if(realizarTeste){
    
    if(TRUE %in% (qdd$VL_LOA_DESP<0)){
      warning(paste("trataQDD_Elemento_Item: Há valores negativos na linha ", 
                    paste0(which(qdd$VL_LOA_DESP<0)+1, collapse=", ")))
    } 
    
    if(TRUE %in% (qdd$VL_LOA_DESP==0)){
      warning(paste("trataQDD_Elemento_Item: Há valores iguais a zero na linha ", 
                    paste0(which(qdd$VL_LOA_DESP==0)+1, collapse=", ")))
    }
  
    source("utils/trataBancos/trataQDD_Fiscal.R")
    qdd_fiscal = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
    
    if(qdd_fiscal[, sum(valor)]!=qdd[, sum(VL_LOA_DESP)]){
      warning("trataQDD_Elemento_Item: o valor de BASE_QDD_FISCAL total (", formatarNum(qdd_fiscal[, sum(valor)]), 
              ") é diferente de BASE_ORCAM_DESPESA_ITEM_FISCAL (", formatarNum(qdd[, sum(VL_LOA_DESP)]), ") \n")
    }
  }
  
  return(qdd)
  
}


avisoNumAbas = function(caminho){
  if(length(excel_sheets(caminho))>1){
    return(message(paste("Aviso: o banco ", caminho,
                         " possui mais de 1 aba. A aba que será aberta é sempre a primeira nesse caso a aba",
                         excel_sheets(caminho)[1])))
  }
}

