args = commandArgs(trailingOnly=TRUE)

limpaDir = function(){
  
  # =====================================================================================
  # Limpa o diretorio Rnw do projeto.
  # Arquivos .pdf que não sejam o volume vão para pdf/layouts. Os volumes vão para pdf/
  # Os demais arquivos auxiliares do latex vão para pdf/aux_files. Destes, apenas 
  # .tex e .logs são mantidos no git
  # =====================================================================================
  if(is.na(args[2])) origem = paste0("volume", args[1], "/Rnw/")
  if(!is.na(args[2])) origem = "./"
  
  destino_layout_pdf = paste0("volume", args[1], "/pdf/")
  destino_volume = paste0("pdf/")
  
  Rnw_dir = dir(origem)
  
  if(args[1]==1){
    arquivo_volume_pdf = Rnw_dir[grepl("^T.+\\.pdf", Rnw_dir)]
    arquivos_layout_pdf = Rnw_dir[grepl("^(?!T).+\\.pdf", Rnw_dir, perl = T)]
  } else{
    arquivo_volume_pdf = Rnw_dir[grepl("^Projeto.+\\.pdf", Rnw_dir)]
    arquivos_layout_pdf = Rnw_dir[grepl("^(?!Projeto).+\\.pdf", Rnw_dir, perl = T)]
    arquivos_layout_pdf = arquivos_layout_pdf[!grepl("^(capa|graficos).*", arquivos_layout_pdf)]
  }
  
  recorta_layouts = lapply(arquivos_layout_pdf, function(x) recortarFile(paste0(origem, x), destino_layout_pdf))
  recorta_volumes = lapply(arquivo_volume_pdf, function(x) recortarFile(paste0(origem, x), destino_volume))
  
  arquivos_aux = Rnw_dir[grepl(".+\\.(log|gz|tex|aux|out|toc|sty)", Rnw_dir)]
  arquivos_aux = arquivos_aux[!grepl("load_bibliotecas", arquivos_aux)]
  
  recorta_aux = lapply(arquivos_aux, function(x) recortarFile(paste0(origem, x), paste0(destino_layout_pdf, "aux_files/")))
}


recortarFile = function(origem, destino){
  
  # =============================================
  # Utiliza a função copiar a remover arquiivos 
  # para criar uma função de recorte
  # =============================================
  
  if(file.copy(from = origem, to = destino, overwrite = T)){
    if(file.remove(origem)==F){
      stop("Erro ao remover ", gsub(".+/(.+\\..+)", "\\1", origem))
    }
  } else{
    stop("Erro ao copiar ", gsub(".+/(.+\\..+)", "\\1", origem))
  }
}


limpaDir()

