
trataPessoal = function(caminho, realizarTeste = TRUE){
  
  #==============================================================================
  # Função para abir o banco BASE_CATEGORIA_PESSOAL.xlsx presente no volume 2
  #==============================================================================
  
  avisoNumAbas(caminho)
  
  pessoal = read_excel(caminho, sheet=1)
  names(pessoal) = iconv(names(pessoal), from="UTF-8", to="ASCII//TRANSLIT")
  names(pessoal) = tolower(gsub(" ", "_", names(pessoal)))
  pessoal$cod_uo = gsub("(\\d{4}).+", "\\1", pessoal$uo)
  
  pessoal = data.table(pessoal)
  
  if(realizarTeste){
    
    nomes_esperados = c("ano_de_exercicio", "uo", "classificacao", "categoria", "quantidade", "cod_uo")

    nomes_diferentes = setdiff(nomes_esperados, names(pessoal))
    
    if(length(nomes_diferentes)>0){
      warning(paste("trataPessoal( ): Há nomes diferentes no banco. Os seguintes nomes de campos não ",
                    "estão no banco atual:", paste(nomes_diferentes, collapse=", "),"\n\n"))
    } 
    
    if(FALSE %in% grepl("\\d{4}", pessoal[,cod_uo])){
      warning(paste("trataPessoal( ): Erro na var cod_uo... linhas com padrão distinto de 4 digitos (\\d{4}) ", 
                        paste0(which(!grepl("\\d{4}", pessoal[,cod_uo]))+1,collapse=", "), "\n"))
    } 
    
    if(TRUE %in% (pessoal$quantidade <0)){
       warning(paste("trataPessoal( ): Há valores negativos na linha ", 
                         paste0(which(pessoal$quantidade<0)+1, collapse=", "), "\n"))
    } 
    
    if(TRUE %in% (pessoal$quantidade==0)){
      warning(paste("trataPessoal( ): Há valores iguais a zero na linha ", 
                    paste0(which(pessoal$quantidade==0)+1, collapse=", "), "\n"))
    }
  }
  
  return(data.table(pessoal))
  
}


avisoNumAbas = function(caminho){
  if(length(excel_sheets(caminho))>1){
    return(message(paste("trataPessoal( ): Aviso: o banco ", caminho,
                         " possui mais de 1 aba. A aba que será aberta é sempre a primeira nesse caso a aba",
                         excel_sheets(caminho)[1])))
  }
}
