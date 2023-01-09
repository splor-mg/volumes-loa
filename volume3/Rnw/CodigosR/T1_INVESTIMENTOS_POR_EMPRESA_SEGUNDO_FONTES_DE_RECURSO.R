  # INICIO TABELA 
 
  titulo= paste0("\\multicolumn{7}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                 "INVESTIMENTOS POR EMPRESA SEGUNDO FONTES DE RECURSO}}}\\TBstrut  \\\\[2ex]\n") 
  
  subtitulo = paste("\\multicolumn{3}{l}{\\textbf{Exercício: \\textcolor{myblack}{", ANO_DOC,  
                    "}}} & \\multicolumn{4}{r}{R\\$1,00} \\\\\n") 
 
  cabecalho1= paste0("\\multirow{2}{*}{\\parbox{3cm}{\\centering \\textbf{EMPRESAS CONTROLADAS PELO ESTADO}}} & ", 
                     "\\multicolumn{3}{|c|}{\\textbf{AUMENTO DE CAPITAL}} & ", 
                     "\\multicolumn{2}{c|}{\\textbf{OUTROS}} &  ", 
                     "\\multicolumn{1}{c}{\\multirow{2}{*}{\\textbf{TOTAL}}} \\\\\n") 
 
  cabecalho2= paste0(" & \\valorHeader{\\centering TESOURO ORDINÁRIO} &  ", 
                     "\\valorHeader{\\centering TESOURO VINCULADO} & ", 
                    "\\valorHeader{\\centering OUTRAS ENTIDADES} & ", 
                    "\\valorHeader{\\centering OPERAÇÃO DE CRÉDITO} & ", 
                    "\\valorHeader{\\centering RECURSOS PRÓPRIOS} & \\\\\n") 
 
  cat("\\noindent\\begin{longtable}[c]{m{3cm}|m{2cm}|m{2cm}|m{2cm}|m{2cm}|m{2cm}|m{2cm}}\n") 
 
  cat(titulo) 
  cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
  cat(subtitulo) 
  cat("\\specialrule{1pt}{0pt}{0pt}\n") 
  cat(cabecalho1) 
  cat("\\cline{2-6}\n") 
  cat(cabecalho2) 
  
  cat("\\hline\n") 
  cat("\\endfirsthead\n") 
  
  cat(titulo) 
  cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
  cat(subtitulo) 
  cat("\\specialrule{1pt}{0pt}{0pt}\n") 
  cat(cabecalho1) 
  cat("\\cline{2-6}\n") 
  cat(cabecalho2) 
  
  cat("\\hline\n") 
  cat("\\endhead\n") 
 
  cat("\\endfoot\n") 
  cat("\\hline\n") 
 
  cat("\\hline\\hline\n") 
  cat("\\endlastfoot\n") 
 
  t1_geral = data.table(read.table(paste(dir_data, "/consolidado/T1_INVESTIMENTO_POR_EMPRESA.txt", sep=""), 
                        header=T, sep="\t", dec=",", stringsAsFactors = FALSE)) 
 
  t1_geral[is.na(t1_geral)] = "" 
   
  for(i in 1:nrow(t1_geral)){ 
   
    if(toupper(t1_geral[i, orgaos])=="TOTAL"){ 
     
      cat("\\hline\n") 
     
      cat("\\multicolumn{1}{L{4cm}|}{ \\textbf{", t1_geral[i, orgaos],  
          "}} & \\multicolumn{1}{r|}{ \\textbf{", t1_geral[i, ordinario],  
          "}} & \\multicolumn{1}{r|}{ \\textbf{", t1_geral[i, vinculado], 
          "}} & \\multicolumn{1}{r|}{ \\textbf{", t1_geral[i, outras],  
          "}} & \\multicolumn{1}{r|}{ \\textbf{", t1_geral[i, operacoes], 
          "}} & \\multicolumn{1}{r|}{ \\textbf{", t1_geral[i, recursos],  
          "}} & \\multicolumn{1}{r}{ \\textbf{", t1_geral[i, total], 
          "}} \\\\\n", sep="") 
   
      } else{ 
         
        cat("\\multicolumn{1}{L{4cm}|}{", t1_geral[i, orgaos], 
            "} & \\multicolumn{1}{r|}{", t1_geral[i, ordinario],  
            "} & \\multicolumn{1}{r|}{", t1_geral[i, vinculado], 
            "} & \\multicolumn{1}{r|}{", t1_geral[i, outras],  
            "} & \\multicolumn{1}{r|}{", t1_geral[i, operacoes], 
            "} & \\multicolumn{1}{r|}{", t1_geral[i, recursos],  
            "} & \\multicolumn{1}{r}{ \\textbf{", t1_geral[i, total], 
            "}} \\\\\n", sep="") 
      } 
    } 
 
  cat("\\end{longtable}\n") 
 
# FIM TABELA 
