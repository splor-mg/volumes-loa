  # INICIO TABELA 
   
  dir_loa = gsub("(.+LOA).*", "\\1", getwd()) 
  dir_codigosR = paste0(dir_loa, "/volume5/Rnw/CodigosR") 
  dir_utils = paste0(dir_loa, "/utils/") 
  dir_data = paste0(dir_loa, "/volume5/data") 
  dir_bancos = paste0(dir_loa, "/bancos") 
  source(paste(dir_utils, "funcoes.R", sep="")) 
  ANO_DOC = as.numeric(readLines(paste(dir_utils, "ano.txt", sep=""), warn = F)) 
   
  source(paste(dir_codigosR, "/demonstrativo_consolidado_despesav1.R", sep=""), encoding = "UTF-8") 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
   
  banco = read.table(paste(dir_data, "/QUADRO_DETALHAMENTO_DESPESA_porUO.txt", sep=""), header = T,  
                   sep = "\t", quote = NULL,   dec = ",", stringsAsFactors = FALSE) 
 
  registro_orgao =c() 
  registro_poder = c() 
 
  for(codigo_uo in unique(banco$COD_UO)){ 
  #codigo_uo = 4121 
    uo = banco[banco$COD_UO==codigo_uo,] # realizar recorte em loop 
     
    if("valor_proposto" %in% names(uo)){ 
      if(as.numeric(gsub("\\.", "", uo$valor_proposto[1])) > 0){ 
        source(paste(dir_codigosR, "/QUADRO_DETALHAMENTO_DESPESA_PROPOSTA_OUTROS_PODERES.R", sep=""), encoding = "UTF-8") 
      } else{ 
        source(paste(dir_codigosR, "/QUADRO_DETALHAMENTO_DESPESA.R", sep=""), encoding = "UTF-8") 
      } 
    } else{ 
      source(paste(dir_codigosR, "/QUADRO_DETALHAMENTO_DESPESA.R", sep=""), encoding = "UTF-8") 
    } 
   
  } 
   
   
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  source(paste(dir_codigosR, "/ANEXOS.R", sep=""), encoding = "UTF-8") 
   
  # FIM TABELA 
