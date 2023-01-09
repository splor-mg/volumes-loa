# ===============================
# Script inicial para o Makefile


dir_loa = gsub("(.+LOA).*", "\\1", getwd())

vols = c("2A", "2B", 3, 4,5)

# Recortes dos arquivos Rnw para obter os códigos em R
source(paste0(dir_loa, "/utils/funcoes.R"), encoding = "UTF-8")

lapply(vols, function(x){
  getCodigoR(paste0(dir_loa, "/volume", make_vol_dir(x) ,"/Rnw/Projeto_volume", x ,".Rnw"), 
             paste0(dir_loa, "/volume", make_vol_dir(x) ,"/Rnw/CodigosR"))  
})

diretorio = dir(paste0(dir_loa, "/logs/"))

for(arquivo in diretorio[!grepl("(.+_\\d{4}.+|.+\\.html$)", diretorio)]){
  if(file.size(paste0("logs/", arquivo))>0){
    
    prefixo = gsub("(.+)\\.(.+)", "\\1", arquivo)
    extensao = gsub("(.+)\\.(.+)", "\\2", arquivo)
    
    bckp_logs = file.copy(from = paste0("logs/", arquivo), 
                          to = paste0("logs/", prefixo, "_", format(Sys.time(), "%Y-%m-%d-%Hh%Mm"),".", extensao))
    
    if(!file.remove(paste0(dir_loa, "/logs/", arquivo))) warning("Arquivo ", arquivo, " em logs/ não excluído!")  
  }
}


