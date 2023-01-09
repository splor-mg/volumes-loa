  # INICIO TABELA 
   
  cat("\\noindent\\begin{longtable}[c]{m{5cm}|m{2.5cm}|m{2.5cm}|m{2.5cm}|m{2cm}|m{2cm}}\n") 
 
  titulo1 =  paste0("\\multicolumn{6}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                    "INVESTIMENTOS POR EMPRESA SEGUNDO}}} \\\\\n") 
   
  titulo2 = paste0("\\multicolumn{6}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                   "O DETALHAMENTO DOS INVESTIMENTOS}}} \\\\\n") 
   
  subtitulo = paste("\\multicolumn{3}{l}{\\textbf{Exercício: \\textcolor{myblack}{", ANO_DOC , 
                     "}}} & \\multicolumn{3}{r}{R\\$1,00} \\\\\n") 
  
  cabecalho = paste0("\\multicolumn{1}{C{5cm}|}{\\textbf{EMPRESAS CONTROLADAS PELO ESTADO}} & ", 
                    " \\valorHeader{\\centering \\textbf{PARTICIPAÇÃO SOCIETÁRIA}} &  ", 
                    "\\valorHeader{\\centering \\textbf{IMOBILIZAÇÕES}} & ", 
                    "\\valorHeader{\\centering \\textbf{AMORTIZAÇÃO DE DÍVIDAS}} & ", 
                    "\\valorHeader{\\centering \\textbf{OUTRAS APLICAÇÕES}} & ", 
                    "\\multicolumn{1}{c}{\\textbf{TOTAL}} \\\\\n ") 
    
  cat(titulo1) 
  cat(titulo2) 
  cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
  cat(subtitulo) 
  cat("\\specialrule{1pt}{0pt}{0pt}\n") 
  cat(cabecalho) 
  
  cat("\\hline\n") 
  cat("\\endfirsthead\n") 
  
  cat(titulo1) 
  cat(titulo2) 
  cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
  cat(subtitulo) 
  cat("\\specialrule{1pt}{0pt}{0pt}\n") 
  cat(cabecalho) 
   
  cat("\\hline\n") 
  cat("\\endhead\n") 
 
  cat("\\endfoot\n") 
  cat("\\hline\n") 
 
  cat("\\hline\\hline\n") 
  cat("\\endlastfoot\n") 
  
 
  t2_geral = data.table(read.table(paste0(dir_data, "/consolidado/T2_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO.txt"), 
                                   header=T, sep="\t", dec=",", stringsAsFactors = FALSE)) 
  
  for(i in 1:nrow(t2_geral)){ 
    
    if(toupper(t2_geral[i, empresas])=="TOTAL"){ 
       
      cat("\\hline\n") 
       
      cat("\\multicolumn{1}{L{5cm}|}{ \\textbf{", t2_geral[i, empresas],  
          "}} & \\multicolumn{1}{r|}{ \\textbf{", t2_geral[i, societaria],  
          "}} & \\multicolumn{1}{r|}{ \\textbf{", t2_geral[i, imob], 
          "}} & \\multicolumn{1}{r|}{ \\textbf{", t2_geral[i, amort], 
          "}} & \\multicolumn{1}{r|}{ \\textbf{", t2_geral[i, outras], 
          "}} & \\multicolumn{1}{r}{ \\textbf{", t2_geral[i, total],"}} \\\\\n", sep="") 
    
      } else{ 
         
        cat("\\multicolumn{1}{L{5cm}|}{", t2_geral[i, empresas], 
            "} & \\multicolumn{1}{r|}{", t2_geral[i, societaria],  
            "} & \\multicolumn{1}{r|}{", t2_geral[i, imob], 
            "} & \\multicolumn{1}{r|}{", t2_geral[i, amort], 
            "} & \\multicolumn{1}{r|}{", t2_geral[i, outras], 
            "} & \\multicolumn{1}{r}{ \\textbf{", t2_geral[i, total],"}} \\\\\n", sep="") 
  
      } 
    } 
  
  cat("\\end{longtable}\n") 
 
  # FIM TABELA 
