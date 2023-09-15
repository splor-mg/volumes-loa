formata_txt = function(caminho){
  
  # ======================================================================================
  # O banco acoes_planejamento.txt está vindo com caracteres do tipo HTML Entity (decimal) 
  # (Ex. &#9642). O read.table não reconhece esses caracteres, e uma vez que o identifica 
  # em uma linha, exclui todo o conteúdo posterior a esse caracter. O objetivo dessa função 
  # é retirar esse tipo de caracter previamente do banco
  # =====================================================
  
  base = readLines(caminho)
  tamanho_db = length(base)
  
  problemas_solucao = c("\\t" = " ", "&#\\d+" = " ")
  
  for(n in names(problemas_solucao)){
    base = lapply(base, function(texto) gsub(n, problemas_solucao[n], texto))
  }
  
  if(length(base)!=tamanho_db){
    stop(paste0("Erro em formata_txt(", caminho, "): banco tratado possui um número de linhas (", 
                length(base), ") diferente em relação ao banco bruto (", tamanho_db, ")"))
  }
  
  base = paste0(base, collapse = "\n")
  write(base, caminho, sep="")
}


formata_xls <- function(arquivo, dir = "bancos/SISOR") {
  #===============================================
  # Retira formato e salva em .xlsx arquivos xls
  #===============================================
  
  prefixo_arquivo = gsub("(.+)\\.xls$", "\\1", arquivo)
  
  from = paste0(dir, "\\", arquivo)
  to = paste0(dir, "\\", prefixo_arquivo)
  
  vbscript <- paste("cscript //nologo utils/vbs/transfere_arquivos.vbs", from, to)
  
  shell(vbscript, mustWork = TRUE)
  # Realizar mais testes antes de deletar
  if(from != to) {
    invisible(file.remove(file.path(dir, arquivo)))
  }
}

for(arquivo in dir("bancos/SISOR")){
  if(grepl(".+txt$", arquivo)){
    
    cat("- Formata arquivo ", arquivo, "\n")
    formata_txt(paste0("bancos/SISOR/", arquivo))
    
  } else if(grepl(".+xls$", arquivo)){
    
    cat("- Formata arquivo ", arquivo, "\n")
    formata_xls(arquivo)
    
  }
}
