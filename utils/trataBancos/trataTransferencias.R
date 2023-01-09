source("utils/funcoes.R", encoding = "UTF-8")

trataTransferencias = function(caminho, realizarTeste = TRUE){
  
  #==============================================================================
  # Função para abir o banco BASE_REPASSE_RECURSOS.xlsx presente no volume 2
  #==============================================================================
  
  avisoNumAbas(caminho)
  
  transf = read_excel(caminho, sheet=1)
  names(transf) = gsub(".*Valor.+", "valor", names(transf), ignore.case = FALSE)
  names(transf) = gsub(" ", "_", names(transf))
  names(transf) = gsub("\\.", "", names(transf))
  
  names(transf) = removeAcentos(names(transf))
  
  names(transf) = gsub("(.+)finan.+", "\\1financ", names(transf))
  names(transf) = gsub("(.+)benef.+", "\\1benef", names(transf))
  
  transf = data.table(transf)

  if(realizarTeste){
    
    nomes_esperados = c("cod_uo_financ", "uo_financ", "cod_uo_benef", "uo_benef", 
                        "grupo_de_despesa", "fonte", "ipu", "iag", "valor")

    nomes_diferentes = setdiff(nomes_esperados, names(transf))
    

    if(length(nomes_diferentes)>0){
      warning(paste("trataTransferencias(): Há nomes diferentes no banco. Os seguintes nomes de ",
                    "campos não estão no banco atual: {{", paste(nomes_diferentes, collapse=", ")," }}\n"))
    }
    
    if(TRUE %in% (transf$valor<0)){
      warning(paste("trataTransferencias(): Há valores negativos na linha ",
                    paste0(which(transf$valor<0)+1, collapse=", "), "\n"))
    }
    
    if(TRUE %in% (transf$valor==0)){
      warning(paste("trataTransferencias(): Há valores iguais a zero na linha ",
                    paste0(which(transf$valor==0)+1, collapse=", "), "\n"))
    }
    
    if(mean(nchar(transf$cod_uo_financ))!=4){
      warning(paste("trataTransferencias(): Erro no tratamento de cod_uo_financ. Há valores de uo's com ",
                    "mais de 4 digitos. Verificar a(s) linha(s)", 
                    paste0(which(nchar(transf$cod_uo_financ)!=4)+1, collapse=", "), 
                    "caso(s)", paste0(transf[nchar(cod_uo_financ)!=4, unique(cod_uo_financ)], collapse = ", "),"\n"))
    }
    
    if(mean(nchar(transf$cod_uo_benef))!=4){
      warning(paste("trataTransferencias(): Erro no tratamento de cod_uo_benef. Há valores de uo's com",
                    "mais de 4 digitos. Verificar a(s) linha(s)", 
                    paste0(which(nchar(transf$cod_uo_benef)!=4)+1, collapse=", "), 
                    "caso(s)", paste0(transf[nchar(cod_uo_benef)!=4, unique(cod_uo_benef)], collapse = ", "), "\n"))
    }
  }
    
  return(transf)
  
  }


avisoNumAbas = function(caminho){
  if(length(excel_sheets(caminho))>1){
    return(message(paste("trataTransferencias(): Aviso: o banco ", caminho,
                         " possui mais de 1 aba. A aba que será aberta é sempre a primeira nesse caso a aba",
                         excel_sheets(caminho)[1])))
  }
}
