  # INICIO TABELA 
   
  dir_loa = gsub("(.+LOA).*", "\\1", getwd()) 
  dir_latex = paste0(dir_loa, "/volume3/Rnw") 
  dir_codigosR = paste0(dir_latex, "/CodigosR") 
  dir_utils = paste0(dir_loa, "/utils/") 
  dir_data = paste0(dir_loa, "/volume3/data") 
  dir_bancos = paste0(dir_loa, "/bancos") 
   
  ANO_DOC = as.numeric(readLines(paste(dir_utils, "/ano.txt", sep=""), warn = F)) 
  source(paste0(dir_utils, "funcoes.R"), encoding = "UTF-8") 
  source(paste0(dir_utils, "formataTexto.R"), encoding = "UTF-8") 
   
  source(paste0(dir_codigosR, "/T1_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_DE_RECURSO.R"), encoding = "UTF-8") 
 
 
 
 
 
 
 
 
  source(paste0(dir_codigosR, "/T2_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS.R"), encoding = "UTF-8") 
 
 
 
 
 
 
 
 
  source(paste0(dir_codigosR,"/T3_INVESTIMENTOS_SEGUNDO_FUNCOES_SUB_PROGRAMAS_PROJETOS_ATIVIDADES.R"), encoding="UTF-8") 
 
  
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  sumario = data.table(read.table(paste(dir_data, "/consolidado/sumario_v3.txt", sep=""), header=T, sep="\t", 
                                  dec=",", stringsAsFactors = FALSE)) 
 
 
  for(uo in sumario$cod_uo){ 
    #uo = 5201 
    # Capa com o nome de cada UO 
    cat("\\ifthispageodd{ }{\\afterpage{\\null\\thispagestyle{empty}\\newpage}}\n") 
    cat("\\newpage\n") 
    cat("\\restoregeometry\n") 
    cat("\\vspace*{1cm}\n") 
    cat("\\phantomsection\n") 
    cat("\\vspace*{8cm}\n") 
     
    cat("\\addcontentsline{toc}{subsection}{", paste(substr(uo,1,1), ".", substr(uo,2,3), ".", substr(uo,4,4),  
                                                     " - ", sumario$uo[sumario$cod_uo==uo] , sep=""),"}\n", sep="") 
     
    cat("\\centering \\Huge {\\textbf{",sumario$uo[sumario$cod_uo==uo] ,"}}\n", sep="") 
    cat("\\afterpage{\\null\\thispagestyle{empty}\\newpage}\n") 
    cat("\\newpage\n") 
 
    cat("\\newgeometry{left=3pt,right=3pt, top=1cm}\n") 
 
    ## Tabela 1: PROGRAMA DE INVESTIMENTO 
     
    source(paste0(dir_codigosR,"/T1_relatorio_por_empresa.R"), encoding="UTF-8") 
    cat("\\newpage\n") 
 
    ## Tabela 2 - Origem de Recursos para Investimento 
    source(paste0(dir_codigosR,"/T2_ORIGENS_RECURSOS_INVESTIMENTOS.R"), encoding="UTF-8") 
    cat("\\newpage\n") 
  
    ## Tabela 3 - RECURSOS FINANCEIROS FONTE DE RECURSOS E APLICAÇÃO - INVESTIMENTO  
    source(paste0(dir_codigosR,"/T3_RECURSOS_FINANCEIROS_FONTE_RECURSOS_APLICACAO_INVESTIMENTO.R"), encoding="UTF-8") 
    cat("\\newpage\n") 
   
    ## Tabela 4 - Detalhamento de Investimentos  
    source(paste0(dir_codigosR,"/T4_DETALHAMENTO_INVESTIMENTOS.R"), encoding="UTF-8") 
    cat("\\newpage\n")  
 
    ## Tabela 5 - QUADRO DE DETALHAMENTO DE INVESTIMENTO 
    source(paste0(dir_codigosR,"/T5_QUADRO_DETALHAMENTO_INVESTIMENTO.R"), encoding="UTF-8") 
    cat("\\newpage\n")  
   
    }  
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  
 
 
 
 
  source(paste0(dir_codigosR,"/ANEXO_ORIGEM_DE_RECURSOS_PARA_INVESTIMENTO.R"), encoding="UTF-8") 
 
 
 
 
 
 
 
  source(paste0(dir_codigosR,"/ANEXO_DETALHAMENTO_INVESTIMENTOS.R"), encoding="UTF-8") 
   
  # FIM TABELA 
