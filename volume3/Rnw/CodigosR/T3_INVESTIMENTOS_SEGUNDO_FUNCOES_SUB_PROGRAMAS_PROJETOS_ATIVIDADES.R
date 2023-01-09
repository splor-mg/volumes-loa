  # INICIO TABELA 
   
  cat("\\noindent\\begin{longtable}[c]{m{1pt}m{3cm}|m{1pt}m{5.5cm}|m{1pt}m{2.5cm}|m{1pt}m{2.5cm}|m{1pt}m{2cm}}\n") 
 
  
  titulo1 = paste0("\\multicolumn{10}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                   "INVESTIMENTOS SEGUNDO FUNÇÕES, SUBFUNÇÕES E PROGRAMAS}}} \\\\\n") 
   
  titulo2 = paste0("\\multicolumn{10}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                   "POR PROJETOS E ATIVIDADES}}} \\\\\n") 
   
  subtitulo = paste("\\multicolumn{6}{l}{\\textbf{Exercício: \\textcolor{myblack}{", ANO_DOC ,  
                     "}}} & \\multicolumn{4}{r}{R\\$1,00} \\\\\n") 
    
  cabecalho = paste0("\\multicolumn{2}{C{3cm}|}{ \\textbf{CÓDIGO}} & ", 
                     "\\multicolumn{2}{C{5.5cm}|}{\\textbf{ESPECIFICAÇÃO}} &  ", 
                     "\\multicolumn{2}{C{2.5cm}|}{\\textbf{PROJETO}} &  ", 
                     "\\multicolumn{2}{C{2.5cm}|}{\\textbf{ATIVIDADE}} & ", 
                     "\\multicolumn{2}{C{2cm}}{\\textbf{TOTAL}} \\\\\n") 
    
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
 
  nome_file = "/consolidado/T3_INVESTIMENTOS_SEGUNDO_FUNCOES_SUB_PROGRAMAS_PROJETOS_ATIVIDADES.txt" 
   
  t3_geral = data.table( 
    readr::read_delim( 
    file = paste0(dir_data, nome_file),  
    delim = "\t",  
    locale = readr::locale('pt', decimal_mark = ',', encoding = 'Latin1'), 
    col_types = readr::cols(.default = 'c') 
    ) 
  ) 
   
  t3_geral[is.na(t3_geral)] = "" 
   
  for(i in 1:nrow(t3_geral)){ 
     
    if(gsub("\\d+\\.(\\d+)\\.(\\d+)", "\\1", t3_geral[i, codigo])=="000"){ 
       
      cat("\\multicolumn{2}{l|}{\\textbf{", t3_geral[i, codigo], 
          "}} & \\multicolumn{2}{L{5.5cm}|}{\\textbf{", t3_geral[i, especificacao], 
          "}} & \\multicolumn{2}{r|}{\\textbf{",t3_geral[i, projeto], 
          "}} & \\multicolumn{2}{r|}{\\textbf{", t3_geral[i, atividade], 
          "}} & \\multicolumn{2}{r}{\\textbf{",t3_geral[i, total],"}} \\\\\n", sep="") 
       
    } else if (gsub("\\d+\\.(\\d+)\\.(\\d+)", "\\2", t3_geral[i, codigo])=="000"){ 
       
      cat("\\multicolumn{2}{@{\\hspace{2em}}l|}{\\textbf{", t3_geral[i, codigo], 
          "}} & \\multicolumn{2}{@{\\hspace{2em}}L{5.5cm}|}{\\textbf{", t3_geral[i, especificacao], 
          "}} &  \\multicolumn{2}{r|}{\\textbf{", t3_geral[i, projeto], 
          "}} &  \\multicolumn{2}{r|}{\\textbf{", t3_geral[i, atividade], 
          "}} & \\multicolumn{2}{r}{\\textbf{" , t3_geral[i, total],"}} \\\\\n", sep="") 
  } else{ 
     
    if(toupper(t3_geral[i, especificacao])=="TOTAL"){ 
       
      cat("\\hline \\hline \n") 
       
      cat(" \\multicolumn{4}{@{\\hspace{2em}}C{5.5cm}|}{ \\textbf{", t3_geral[i, especificacao], 
          "}}  & \\multicolumn{2}{r|}{ \\textbf{" ,t3_geral[i, projeto], 
          "}}  & \\multicolumn{2}{r|}{ \\textbf{" , t3_geral[i, atividade], 
          "}} & \\multicolumn{2}{r}{ \\textbf{" ,t3_geral[i, total],"}} \\\\\n", sep="") 
       
      } else { 
         
      cat("\\multicolumn{2}{@{\\hspace{4em}}l|}{", t3_geral[i, codigo], 
          "}  & \\multicolumn{2}{@{\\hspace{4em}}L{5.5cm}|}{", t3_geral[i, especificacao], 
          "}  & \\multicolumn{2}{r|}{" ,t3_geral[i, projeto], 
          "}  & \\multicolumn{2}{r|}{" , t3_geral[i, atividade], 
          "} & \\multicolumn{2}{r}{ \\textbf{" ,t3_geral[i, total],"}} \\\\\n", sep="") 
      } 
  } 
     
} 
 
cat("\\end{longtable}\n") 
 
# FIM TABELA 
