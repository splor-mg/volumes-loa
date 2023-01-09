  # INICIO TABELA 
  options(warn = 1) 
   
  qual_anexo = "B" 
  codigo_funfip = 4711 
  dir_loa = gsub("(.+LOA).*", "\\1", getwd()) 
  dir_latex = paste0(dir_loa, "/volume2/Rnw") 
  dir_codigosR = paste0(dir_latex, "/CodigosR") 
  dir_utils = paste0(dir_loa, "/utils/") 
  dir_data = paste0(dir_loa, "/volume2/data") 
  dir_bancos = paste0(dir_loa, "/bancos") 
  ANO_DOC = as.numeric(readLines(paste(dir_utils, "/ano.txt", sep=""), warn = F)) 
  source(paste0(dir_utils, "funcoes.R"), encoding = "UTF-8") 
   
  sumario = data.table(read.table(paste(dir_data, "/sumario.txt", sep=""), header=T,  
                                  sep="\t", dec=",", stringsAsFactors = FALSE)) 
 
  metade = round(length(sumario$COD_UO) / 2, 0) 
  while(sumario$COD_ORGAO[metade]==sumario$COD_ORGAO[metade+1]){ 
    metade = metade +1 
  } 
 
  warning(paste("V2B A primeira UO considerada nesse relatório será ", sumario[(metade+1), COD_UO], 
                "--", sumario[(metade+1), UO], " que inicia o órgão ", sumario[(metade+1), ORGAO])) 
 
  # Necessário para a tabela 2 
  rodape = data.table(read.table(paste(dir_data, "/tabela2/rodape.txt",sep=""), header=T,  
                                 sep="\t", dec=",", stringsAsFactors = FALSE)) 
 
  registro_orgao =c() 
  registro_poder = c() 
 
  for(uo in sumario[(metade+1):nrow(sumario), COD_UO]){ 
 
    ## INICIO: Tabela 1 Programa de Trabalho 
 
    if(file.exists(paste(paste(dir_data, "/tabela1/",uo,".txt",sep="")))==F){ 
      warning(paste("V2B T1: Para a UO", uo, 
                    "NÃO existe o banco T2 PROGRAMA DE TRABALHO. Dado que todo o universo de UO's", 
                    "do volume 2 possuem a tabela 1, é um erro considerar essa UO\n")) 
      next 
      } 
   
    banco = data.table(read.table(paste(dir_data,"/tabela1/",uo,".txt",sep=""), header=T,  
                                  sep="\t", dec=",", stringsAsFactors = FALSE)) 
   
    if(!sumario[COD_UO==uo, PODER] %in% registro_poder){ 
      cat("\\phantomsection\n") 
      cat("\\addcontentsline{toc}{section}{\\underline{", sumario[COD_UO==uo, poder] ,"}}\n")   
      registro_poder = append(registro_poder, sumario[COD_UO==uo, PODER]) 
    } 
   
   if(!banco[1, nome_orgao] %in% registro_orgao){ 
     cat("\\phantomsection\n") 
     cat("\\addcontentsline{toc}{section}{", banco[1, nome_orgao], "}\n")   
     registro_orgao = append(registro_orgao, banco[1, nome_orgao]) 
    } 
   
  cat("\\ifthispageodd{ }{\\null\\thispagestyle{empty}\\newpage}\n") 
  cat("\\phantomsection\n") 
  cat("\\vspace*{10cm}\n") 
  cat("\\addcontentsline{toc}{subsection}{", banco[1, nome_uo] ,"}\n") 
   
  cat("\\begin{longtable}[c]{m{20cm}}\n \\multicolumn{1}{C{20cm}}{ \\LARGE", 
      gsub("\\d+\\.\\d+\\.\\d+ *- *(.+)", "\\1", banco[1, nome_uo]), "}\n \\end{longtable}\n" ) 
   
  cat("\\afterpage{\\null\\thispagestyle{empty}\\newpage}\n") 
   
  cat("\\newpage\n") # retirado, pois as paginas em branco nao são mais necessárias já que os volumes não são mais impressos. 
   
  
 
  # Tabela 1 PROGRAMA DE TRABALHO 
       
  source(paste0(dir_codigosR, "/T1_PROGRAMA_DE_TRABALHO.R"), encoding = "UTF-8") 
  cat("\\newpage\n") 
 
  # Tabela 2 RECURSOS FINANCEIROS FONTE RECURSOS GRUPOS DESPESA FISCAL 
 
  if(file.exists(paste(dir_data, "/tabela2/",uo,".txt",sep=""))){ 
     
    source(paste0(dir_codigosR, "/T2_RECURSOS_FINANCEIROS_FONTE_RECURSOS_GRUPOS_DESPESA_FISCAL.R"), encoding = "UTF-8") 
    cat("\\newpage\n")  
  } else{ 
      warning(paste("V2B T2: Para a UO", uo,  
                    "NÃO existe o banco T2 RECURSOS FINANCEIROS FONTE RECURSOS GRUPOS DESPESA FISCAL\n")) 
  } 
 
  # Tabela 3 RECURSOS ORCAMENTARIO CATEGORIA PESSOAL 
  
  if(file.exists(paste0(dir_data, "/tabela3/",uo,".txt")) | file.exists(paste0(dir_data, "/tabela3/",uo,".csv"))){ 
     
    if(uo==codigo_funfip){ 
      cat("\\end{landscape}\n") 
      cat("\\newgeometry{left=3pt, right=3pt, top=1cm}\n") 
      cat("\\pagestyle{plain}\n") 
       
      source(paste0(dir_codigosR, "/T3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL.R"), encoding = "UTF-8") 
       
      cat("\\newpage\n")  
      cat("\\newgeometry{bottom=0cm, top=0cm, left=2cm, right=2cm}\n") 
      cat("\\thispagestyle{lscape}\n") 
      cat("\\pagestyle{lscape}\n") 
      cat("\\begin{landscape}\n") 
   
    } else{ 
       
    source(paste(dir_codigosR, "/T3_DETALHAMENTO_DA_CATEGORIA_DE_PESSOAL.R", sep=""), encoding = "UTF-8") 
  
    cat("\\newpage\n")  
    } 
  } else{ 
    warning(paste("V2B T3: Para a UO", uo, "NÃO existe o banco T3 RECURSOS OCAMENTARIO CATEGORIA PESSOAL\n")) 
  } 
   
  # Tabela 4 DEMONSTRATIVO DOS RECURSOS FINANCEIROS 
 
  if(file.exists(paste(dir_data, "/tabela4/",uo,".txt",sep="")) & substr(uo,1,1)!="1"){ 
     
    source(paste0(dir_codigosR, "/T4_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS.R"), encoding = "UTF-8") 
    cat("\\newpage\n")  
  } else{  
    if(!file.exists(paste(dir_data, "/tabela4/",uo,".txt",sep=""))) { 
      warning(paste("V2B T4: Para a UO", uo, "NÃO existe o banco T4 DEMONSTRATIVO DOS RECURSOS FINANCEIROS\n")) 
    } 
  } 
   
  # Tabela 5 DEMONSTRATIVO DOS RECURSOS FINANCEIROS: DEMAIS RECURSOS 
   
  if(file.exists(paste(dir_data, "/tabela5/",uo,".txt",sep="")) & substr(uo,1,1)!="1"){ 
     
    source(paste0(dir_codigosR, "/T5_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS_TABELA_DEMAIS_RECURSOS.R"), encoding = "UTF-8") 
    cat("\\newpage\n") 
  } else{ 
    if(!file.exists(paste(dir_data, "/tabela5/",uo,".txt",sep=""))) { 
      warning(paste("V2B T5: Para a UO", uo, "NÃO existe o banco ", 
                  "T5 DEMONSTRATIVO DOS RECURSOS FINANCEIROS TABELA DEMAIS RECURSOS"))   
    } 
  } 
} 
 
 
 
 
 
  
 
  
 
 
 
 
 
 
 
 
 
 
 
 
 
  source(paste(dir_codigosR, "/ANEXO_codigos_descricoes_2A.R", sep=""), encoding = "UTF-8") 
   
  # FIM TABELA 
