args = commandArgs(trailingOnly=TRUE)

del_arquivos = function(arquivo, caminho){
  # Deleta arquivos
  
  if(!file.remove(paste(caminho, arquivo, sep="/"))){
    warning(paste0("Arquivo ", caminho, "/", arquivo, " não deletado!"))
    
  }
}

dir_tabela = function(tabela, caminho){
  # Deleta todos os arquivos dentro de um diretorio que inicia com tabela
  
  arquivos = dir(paste(caminho, tabela, sep="/"))
  
  del = lapply(arquivos, function(x) del_arquivos(x, paste(caminho, tabela, sep="/")))
  
}

removeArquivos = function(diretorio){
  # Remove todos os arquivos processados de determinado diretorio
  
  pasta = dir(diretorio)
  
  arquivos = pasta[grepl(".+\\.(txt|csv|Rout|html|Rmd)$", pasta)]
  if(length(arquivos)>0) del = lapply(arquivos, function(x) del_arquivos(x, diretorio))
  
  tabelas = pasta[grepl("^(consolidado|tabela).*", pasta)]
  if(length(tabelas)>0) del = lapply(tabelas, function(x) dir_tabela(x, diretorio))
}
  
  
if(args[1] %in% c("2","3","4","5","6")){
  removeArquivos(paste0("volume", args[1], "/data"))

} else if(args[1]=="logs"){
  removeArquivos(args[1])
  
} else if(args[1]=="1"){
  arquivos = dir("volume1/data")[grepl("^T.+\\.(txt|csv)$", dir("volume1/data"))]
  del = lapply(arquivos, function(x) del_arquivos(x, "volume1/data"))
  
}else{
  cat("Diretório não identificado. Espera-se argumento de 1 a 6 ou logs\n")
}
