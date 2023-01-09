
trataReceita_Fiscal = function(caminho, realizarTeste = TRUE){
  
  #==============================================================================
  # Função para abir o banco BASE_ORCAM_RECEITA_FISCAL.xlsx presente no volume 2
  #==============================================================================
  
  avisoNumAbas(caminho)
  
  receita = read_excel(caminho, sheet=1)
  names(receita) = toupper(removeAcentos(names(receita)))
  
  receita = data.table(receita)
  
  setnames(receita, c("TIPO DE RECEITA", "VALOR FINAL (R$)"), c("TIPO", "valor"))
  
  if(realizarTeste){
    
    
    nomes_esperados = c("UO_COD", "NOME_UO","SIGLA_UO", "COD_FONTE", "FONTE", #"INTERPRETACAO", 
                        "CATEGORIA","ORIGEM", "ESPECIE", "RUBRICA", "ALINEA","SUBALINEA", "TIPO",
                        "ITEM", "SUBITEM", "COD_RECEITA", "RECEITA", "INTERP_RECEITA" , "valor", 
                        "ANO", "BASE LEGAL")

    nomes_diferentes = setdiff(nomes_esperados, names(receita))
    
    

    if(length(nomes_diferentes)>0){
      warning(paste("trataReceita_Fiscal(): Há nomes diferentes no banco. Os seguintes nomes de ",
                    "campos não estão no banco atual: {{", paste(nomes_diferentes, collapse=", ")," }}\n"))
    }
    
    if(nrow(receita[valor<0 & substr(COD_RECEITA,1,1)!="9"])>0){
      warning(paste("trataReceita_Fiscal(): Há valores negativos na linha ", 
                    paste0(which(receita$valor<0)+1, collapse=", "), "\n"))
    }
    
    # if(TRUE %in% (receita$valor==0)){
    #   warning(paste("trataReceita_Fiscal(): Há valores iguais a zero na linha ", 
    #                     paste0(which(receita$valor==0)+1, collapse=", "), "\n"))
    # }
    
  }
    
  return(data.table(receita))
  
  }


avisoNumAbas = function(caminho){
  if(length(excel_sheets(caminho))>1){
    return(message(paste("trataReceita_Fiscal(): Aviso: o banco ", caminho,
                         " possui mais de 1 aba. A aba que será aberta é sempre a primeira nesse caso a aba",
                         excel_sheets(caminho)[1])))
  }
}


geraLoa_rec = function(receitaSISOR){
  
  #=========================================================================================
  # Transforma o banco BASE_ORCAM_RECEITA_FISCAL.xlsx no formato loa_rec do pacote execucao
  #=========================================================================================
  
  nomes_antigos = c("ANO","UO_COD", "COD_RECEITA", "RECEITA", "COD_FONTE", "valor")
  nomes_novos = c("ANO","UO_COD", "RECEITA_COD", "RECEITA_DESC", "FONTE_COD", "VL_LOA_REC")
  
  if(length(setdiff(nomes_antigos, names(receitaSISOR))) >0){
    stop("Erro em geraLoa_rec: Espera-se encontrar as seguintes variáveis no banco BASE_ORCAM_RECEITA_FISCAL.xlsx:",
         paste(setdiff(nomes_antigos, names(receitaSISOR)), collapse=", "), "\n")
  }
  
  setnames(receitaSISOR, nomes_antigos, nomes_novos)
  
  receitaSISOR$RECEITA_COD = as.numeric(as.character(receitaSISOR$RECEITA_COD))
  
  return(receitaSISOR[, nomes_novos, with=F])
  
}


ler_novaReceita_antigo = function(caminho){
  
  classificacao = data.table(read_excel(caminho, sheet=1))
  
  ind_cod_rec = which(as.vector(nchar(classificacao[2, ]))==13)
  ind_desc_rec = which(grepl("corrent", as.vector(classificacao[2, ]), ignore.case = T)) # Reavaliar
  
  classificacao = classificacao[, c(ind_cod_rec, ind_desc_rec), with=F]
  classificacao = classificacao[2:nrow(classificacao),]
  
  names(classificacao) = c("RECEITA_COD", "RECEITA_DESC")
  
  classificacao$RECEITA_COD = as.numeric(as.character(classificacao$RECEITA_COD))
  
  return(classificacao[!is.na(RECEITA_COD), ])
  
}
  
trataReceita_Fiscal_antigo = function(caminho, realizarTeste = TRUE){
  
  #==============================================================================
  # Função para abir o banco BASE_ORCAM_RECEITA_FISCAL.xlsx presente no volume 2
  #==============================================================================
  
  avisoNumAbas(caminho)
  
  receita = read_excel(caminho, sheet=1)
  names(receita) = gsub(".*VALOR *FINAL.+", "valor", names(receita), ignore.case = FALSE)
  receita = data.table(receita)
  
  
  if(realizarTeste){
    
    nomes_esperados = c("UO_COD", "NOME_UO","SIGLA_UO", "COD_FONTE", "FONTE", "INTERPRETACAO", 
                        "CATEGORIA", "SUBCATEGORIA" ,"FONTE_CLAS", "RUBRICA", "ALINEA","SUBALINEA", 
                        "ITEM","COD_RECEITA", "RECEITA", "INTERP_RECEITA" , "valor", "ANO", "BASE LEGAL")
    
    nomes_diferentes = setdiff(nomes_esperados, names(receita))
    
    
    
    if(length(nomes_diferentes)>0){
      warning(paste("trataReceita_Fiscal(): Há nomes diferentes no banco. Os seguintes nomes de ",
                    "campos não estão no banco atual: {{", paste(nomes_diferentes, collapse=", ")," }}\n"))
    }
    
    if(nrow(receita[valor<0 & substr(COD_RECEITA,1,1)!="9"])>0){
      warning(paste("trataReceita_Fiscal(): Há valores negativos na linha ", 
                    paste0(which(receita$valor<0)+1, collapse=", "), "\n"))
    }
    
    # if(TRUE %in% (receita$valor==0)){
    #   warning(paste("trataReceita_Fiscal(): Há valores iguais a zero na linha ", 
    #                     paste0(which(receita$valor==0)+1, collapse=", "), "\n"))
    # }
    
  }
  
  return(data.table(receita))
  
}

ler_novaReceita = function(caminho){
  
  classificacao = data.table(read_excel(caminho, sheet=1))
  classificacao = classificacao[, list(RECEITA_COD = RECEITA_COD_2, RECEITA_DESC = RECEITA_DESC_2)]
  
  classificacao$RECEITA_COD = as.numeric(as.character(classificacao$RECEITA_COD))
  
  return(classificacao[!is.na(RECEITA_COD), ])
  
}
