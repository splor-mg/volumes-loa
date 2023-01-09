# =============================================================
# Gera arquivo .Rnw do volume final. 
# Esse script não foi desenvolvido para rodar os Rnw de layouts
#
# Apresenta avisos no bash referente a presença de conteúdo em 
# logs/log.Rout e logs/warningsV\d{1}.Rout
# =============================================================


args = commandArgs(trailingOnly=TRUE)


source("utils/funcoes.R", encoding = "UTF-8")
options(readr.num_columns = 0)

dir_vol = make_vol_dir(args[1])
copia_load_bbt = file.copy(paste0("volume", dir_vol, "/Rnw/load_bibliotecas.tex"), ".")

if(file.exists(paste0("logs/logv",dir_vol,".Rout"))){
  avisosR = readLines(paste0("logs/logv",dir_vol,".Rout"))
  if(length(avisosR)>0)  cat("!-- Verificar logs/logv",dir_vol,".Rout ...\n", sep="")
}

if(dir_vol!="1"){
  # Verifica se no arquivo de warnings tem algo
  avisosRnw = readLines(paste0("logs/warningsV", args[1],".Rout"))

  if(length(avisosRnw)>0){
    cat("!-- Codigo R em volume", args[1], 
        ".Rnw apresenta warnings(). Verificar logs/warningsV", args[1],".Rout\n", sep = "")
  }
  
  copia_capa = file.copy(paste0("volume", dir_vol ,"/Rnw/capaLOA.pdf"), ".")
  cat("-- Iniciando volume", args[1], ".pdf ...\n", sep = "")
  
  gera_pdf = system(paste0("R CMD Sweave --encoding=utf-8 --pdf volume", dir_vol ,
                           "/Rnw/Projeto_volume", args[1] ,".Rnw"), show.output.on.console = T)
  
  remove_capa = file.remove("capaLOA.pdf")

}else{
  
  file_rnw = paste0(args[1], ".Rnw")
  
  #cat("-- Iniciando ", gsub("(.+)\\.Rnw", "\\1", file_rnw), ".pdf ...\n", sep = "")
  
  gera_pdf = system(paste0("R CMD Sweave --encoding=utf-8 --pdf volume", dir_vol ,"/Rnw/", file_rnw), 
                    show.output.on.console = T)

}
  
remove_load_bbt = file.remove("load_bibliotecas.tex")
limpadir = system(paste0("Rscript utils/limpaDir.R ", dir_vol, " 1"), show.output.on.console = T)
