
trataQDD_Elemento_Item = function(caminho, realizarTeste = TRUE){
  
  #==========================================================================================================
  # Função para abir o banco datapackages/ppo/data/orcamento_despesa.csv por item de despesa
  #==========================================================================================================
  
  qdd = fread(caminho, encoding = "UTF-8")
  names(qdd) = toupper(names(qdd))
  setnames(qdd, "VLR_LOA_DESP", "VL_LOA_DESP")
  
  novos_nomes = c("ORGAO_COD", "UO_COD", "FUNCAO_COD", "SUBFUNCAO_COD", "PROGRAMA_COD", "ACAO_COD", "SUBPROJETO_COD",
                  "CATEGORIA_COD", "GRUPO_COD", "MODALIDADE_COD", "ELEMENTO_COD", "ELEMENTO_ITEM_COD",
                  "FONTE_COD", "IPU_COD", "IAG_COD", "VL_LOA_DESP")
  
  qdd = qdd[, novos_nomes, with=F]
  
  if(realizarTeste){
    
    if(TRUE %in% (qdd$VL_LOA_DESP<0)){
      warning(paste("trataQDD_Elemento_Item: Há valores negativos na linha ", 
                    paste0(which(qdd$VL_LOA_DESP<0)+1, collapse=", ")))
    } 
    
    if(TRUE %in% (qdd$VL_LOA_DESP==0)){
      warning(paste("trataQDD_Elemento_Item: Há valores iguais a zero na linha ", 
                    paste0(which(qdd$VL_LOA_DESP==0)+1, collapse=", ")))
    }
  }

  ano_exercicio = as.numeric(readLines("utils/ano.txt", warn = F))
  qdd$ANO <- ano_exercicio
  
  return(qdd)
  
}


avisoNumAbas = function(caminho){
  if(length(excel_sheets(caminho))>1){
    return(message(paste("Aviso: o banco ", caminho,
                         " possui mais de 1 aba. A aba que será aberta é sempre a primeira nesse caso a aba",
                         excel_sheets(caminho)[1])))
  }
}

