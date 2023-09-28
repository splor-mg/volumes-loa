# ========================================================
# Funções para formatar texto do Latex
suppressMessages(require(data.table))

correcaoCaracteresEspeciais = function(texto, caracteres, is_maiscula=TRUE){
  
  # =====================================================================
  # Identifica se o texto possui algum caracter especial realizando a 
  # respectiva correção. A lista de caracteres especiais e sua respectiva
  # correção estão em config/suporte/caracteresEspeciais.xlsx
  # =====================================================================
  
  
  ref = texto
  if(is_maiscula){
    texto = toupper(texto)
  } 
  na_inicial = which(is.na(ref))
  for(padrao in names(caracteres)){
    texto = gsub(padrao, caracteres[padrao], texto, perl=T, ignore.case = T)
  }
  
  if(length(setdiff(which(is.na(texto)), na_inicial))>0){
    stop(paste("Na correcao de caracteres especiais para o texto ", ref[setdiff(which(is.na(texto)), na_inicial)], 
               " o resultado da funcao eh NA, ou seja, perdemos o texto. Revisar a lista de caracteres repassada \n\n"))
  }
  return(texto)
}

TratamentoNA = function(valor){
  if(is.null(valor) || is.na(valor)){""} else{valor}
}

list_caracteres_especiais = function(){
  
  # =========================================================
  # Transforma o banco Caracteres Especiais.xlsx 
  # em uma lista com o padrão:
  # chave = caracter Especial, valor = Correção do caracter
  # =========================================================
  
  caracteres = readxl::read_excel("utils/suporte/CaracteresEspeciais.xlsx", sheet=1, 
                                  col_types = c("text", "text", "text"))
  
  caracteres_especiais = list()
  
  for(l in 1:nrow(caracteres)){
    caracteres_especiais[[caracteres$caracter[l]]] = TratamentoNA(caracteres$correcao[l])
  }
  return(caracteres_especiais)
}

caracteres = list_caracteres_especiais()



