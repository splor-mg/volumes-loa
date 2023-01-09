  # INICIO TABELA 
   
  dir_loa = gsub("(.+LOA).*", "\\1", getwd()) 
  dir_latex = paste0(dir_loa, "/volume4/Rnw") 
  dir_codigosR = paste0(dir_latex, "/CodigosR") 
  dir_utils = paste0(dir_loa, "/utils/") 
  dir_data = paste0(dir_loa, "/volume4/data") 
  dir_bancos = paste0(dir_loa, "/bancos") 
 
  ANO_DOC = as.numeric(readLines(paste(dir_utils, "/ano.txt", sep=""), warn = F)) 
   
  source(paste0(dir_utils, "funcoes.R"), encoding = "UTF-8") 
   
  sumario = data.table(read.table(paste(dir_data, "/sumario_v4.txt", sep=""), header = T, sep = "\t",  
                                  quote = "\"'", dec = "@", stringsAsFactors = FALSE)) 
   
  cat("\\newgeometry{bottom=2cm, top=2cm,left=1.5cm,right=1.5cm}\n") 
 
  for(uo in sumario[, COD_UO]){ 
     
    source(paste0(dir_codigosR, "/T1_OBRAS_POR_UNIDADE_ORCAMENTARIA_SEGUNDO_TERRITORIOS_DE_PLANEJAMENTO.R"), 
           encoding = "UTF-8") 
     
    cat("\\newpage\n") 
  } 
 
 
 
 
 
 
 
 
 
 
 
 
   
  cat("\\newgeometry{bottom=2cm,top=1cm,left=1.5cm,right=1.5cm}\n") 
  # Parâmetros importantes para a tabela 2 
  registro_poder = c() 
  registro_orgao = c() 
 
  for(uo in sumario$COD_UO){ 
   
    source(paste0(dir_codigosR, "/T2_DETALHAMENTO_DOS_INVESTIMENTOS_TERRITORIOS_PLANEJAMENTO_MUNICIPIOS.R"),  
          encoding = "UTF-8") 
  } 
 
 
 
 
 
 
 
 
 
 
 
 
 
  cat("\\newgeometry{bottom=2cm,top=1cm,left=1.5cm,right=1.5cm}\n") 
  source(paste0(dir_codigosR, "/ANEXO_RelacaoTerritorio_X_Municipios.R"), encoding = "UTF-8") 
 
  # FIM TABELA 
