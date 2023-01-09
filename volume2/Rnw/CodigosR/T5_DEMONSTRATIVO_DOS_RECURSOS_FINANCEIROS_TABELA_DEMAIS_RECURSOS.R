  # INICIO TABELA 
   
    banco = data.table(read.table(paste(dir_data, "/tabela5/",uo,".txt",sep=""), header=T, sep="\t",  
                                  dec=",", stringsAsFactors = FALSE)) 
 
    cat("\\renewcommand*{\\arraystretch}{1.7}\n") 
    cat("\\small\n") 
 
    cat("\\noindent\\begin{longtable}[c]{m{12cm}m{3cm}m{3cm}m{3cm}}\n") 
             
    titulo1 = paste("\\multicolumn{4}{C{23cm}}{\\cellcolor{gray!50} {\\normalsize \\textbf{", 
                    "DEMONSTRATIVO DOS RECURSOS FINANCEIROS}}} \\TBstrut   \\\\[2ex] \n") 
   
    subtitulo = paste("\\multicolumn{3}{l}{\\textbf{Exercício: ", ANO_DOC, 
                      "}} & \\multicolumn{1}{r}{R\\$1,00} \\\\\n")  
   
    titulo_orgao = paste0("\\multicolumn{4}{l}{\\textbf{ÓRGÃO:} ", banco[1, nome_orgao],"} \\\\\n") 
    titulo_uo = paste0("\\multicolumn{4}{L{23cm}}{\\textbf{UO:} \\hspace{18pt} ", banco[1, nome_uo],"} \\\\\n") 
   
    cabecalho = paste0("\\multicolumn{1}{L{12cm}}{ \\textbf{ 2. RECURSOS REPASSADOS PELO TESOURO ESTADUAL", 
                       "}} & \\multicolumn{1}{R{3cm}}{ \\textbf{ORDINÁRIO }} & ", 
                      "\\multicolumn{1}{R{3cm}}{ \\textbf{ VINCULADO }} & ", 
                      "\\multicolumn{1}{R{3cm}}{ \\textbf{TOTAL}} \\\\\n") 
   
    cat(titulo1) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
    cat(cabecalho) 
    cat("\\hline\n") 
    cat("\\endfirsthead\n") 
 
    cat(titulo1) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
   
    cat("\\hline\n") 
    cat("\\endhead\n") 
    cat("\\endfoot\n") 
   
    cat("\\hline\n") 
    cat("\\hline\\hline\n")  
    cat("\\endlastfoot\n") 
   
    for(i in 2:nrow(banco)){ 
       
      if(grepl("^(\\d{1})\\..+", banco[i, especificacao])){ 
         
        cat("\\multicolumn{2}{l}{ \\textbf{ ", banco[i, especificacao],  
            "}} & & \\multicolumn{1}{R{3cm}}{ \\textbf{", banco[i, total], "}} \\\\\n", sep="")   
        cat("\\hline \\hline \n") 
         
       } else if(grepl("^subtotal.*", banco[i, especificacao], ignore.case = TRUE)){ 
          
         cat("\\hline \n") 
          
         cat("\\multicolumn{1}{L{12cm}}{ \\textbf{",  banco[i, especificacao],  
             "}} & \\multicolumn{1}{R{3cm}}{ \\textbf{", TratamentoNA(banco[i, ordinario]),  
             "}} & \\multicolumn{1}{R{3cm}}{ \\textbf{", TratamentoNA(banco[i, vinculado]),  
             "}} & \\multicolumn{1}{R{3cm}}{ \\textbf{", TratamentoNA(banco[i, total]),"}} \\\\\n") 
         
          cat("\\hline \\hline \n") 
          
         } else{ 
         
           cat("\\multicolumn{1}{@{\\hspace{3em}}L{12cm}}{ ",  banco[i, especificacao],  
               "} & \\multicolumn{1}{R{3cm}}{ ", TratamentoNA(banco[i, ordinario]),  
               "} & \\multicolumn{1}{R{3cm}}{ ", TratamentoNA(banco[i, vinculado]),  
               "} & \\multicolumn{1}{R{3cm}}{ ", TratamentoNA(banco[i, total]),"} \\\\\n")   
       } 
     } 
 
    cat("\\end{longtable}\n") 
   
     
    # FIM TABELA 
