    # INICIO TABELA 
    t4 = data.table( 
      readr::read_delim( 
      file = paste(dir_data, "/tabela4/", uo,".txt", sep=""),  
      delim = "\t",  
      locale = readr::locale('pt', decimal_mark = ',', encoding = 'Latin1'), 
      col_types = readr::cols(.default = 'c', nivel = 'i') 
      ) 
    ) 
     
    t4[is.na(t4)] = "" 
     
    t4$nivel = ifelse(t4$nivel!=1, t4$nivel*1.5, t4$nivel) 
     
    cat("\\noindent\\begin{longtable}[c]{m{8cm}|m{3cm}|m{3cm}}\n") 
 
    titulo=  paste0("\\multicolumn{3}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                    "DETALHAMENTO DOS INVESTIMENTOS}}}\\TBstrut  \\\\[2ex]\n") 
  
    subtitulo= paste0("\\multicolumn{2}{l}{\\textbf{Exercício: \\textcolor{myblack}{", ANO_DOC , 
                      "}}} & \\multicolumn{1}{r}{R\\$1,00} \\\\\n") 
     
    titulo_orgao = paste0("\\multicolumn{3}{L{14cm}}{\\textbf{ÓRGÃO:} ",t4[1,orgao],"} \\\\\n") 
     
    titulo_uo = paste0("\\multicolumn{3}{L{14cm}}{\\textbf{UO:} \\hspace{12.5pt} ",t4[1,uo] ,"} \\\\\n") 
  
    cat(titulo) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
 
    variaveis = paste0("\\valorHeader{\\centering \\textbf{ESPECIFICAÇÃO}} & ", 
                       "\\valorHeader{\\centering \\textbf{VALOR}} &  ", 
                       "\\multicolumn{1}{c}{\\textbf{TOTAL}} \\\\\n") 
  
    cat(variaveis) 
  
    cat("\\hline\n") 
    cat("\\endfirsthead\n") 
  
    cat(titulo) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
  
    cat(variaveis) 
  
    cat("\\hline\n") 
    cat("\\endhead\n") 
    cat("\\endfoot\n") 
    cat("\\hline\n") 
 
    cat("\\hline \\hline\n") 
    cat("\\endlastfoot\n") 
 
    for(i in 1:nrow(t4)){ 
      if(toupper(t4[i, especificacao])=="TOTAL"){ 
        cat("\\hline \\hline\n") 
         
        cat("\\multicolumn{2}{l}{\\textbf{", t4[i, especificacao], 
            "}} &  \\multicolumn{1}{r@{\\hspace{0.5em}}}{\\textbf{", t4[i, total],  
            "}} \\\\\n") 
       
      } else if(t4$nivel[i]==1){ 
         
        cat("\\multicolumn{1}{@{\\hspace{", (t4[i, nivel]-0.5) ,"em}}L{8cm}|}{ \\textbf{", t4[i, especificacao], 
            "}} & \\multicolumn{1}{r@{\\hspace{0.5em}}|}{ \\textbf{", t4[i, valor],  
            "}} & \\multicolumn{1}{r@{\\hspace{0.5em}}}{ \\textbf{",t4[i, total], 
            "}} \\\\\n", sep="")  
       
      } else{ 
         
        cat("\\multicolumn{1}{@{\\hspace{", (t4[i, nivel]-0.5) ,"em}}L{8cm}|}{", t4[i, especificacao], 
            "} & \\multicolumn{1}{r@{\\hspace{0.5em}}|}{", t4[i, valor],  
            "} & \\multicolumn{1}{r@{\\hspace{0.5em}}}{",t4[i, total], 
            "} \\\\\n", sep="") 
      } 
    } 
 
    cat("\\end{longtable}\n") 
  
    # FIM TABELA 
