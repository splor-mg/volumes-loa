    # INICIO TABELA 
   
    banco = read.table(paste0(dir_data, "/tabela1/", uo, ".txt",sep=""),  
                       header=T, sep="\t", dec=",", stringsAsFactors = FALSE) 
 
    cat("\\renewcommand*{\\arraystretch}{1.7}\n") 
    cat("\\normalsize\n") 
 
    cat("\\noindent\\begin{longtable}[c]{m{8cm}|m{3cm}|m{3cm}}\n") 
             
    titulo1 = paste0("\\multicolumn{3}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\textbf{", 
                     "OBRAS POR UNIDADE ORÇAMENTÁRIA SEGUNDO}}} \\\\\n") 
     
    titulo2 = paste0("\\multicolumn{3}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\textbf{", 
                     "AS REGIÕES GEOGRÁFICAS INTERMEDIÁRIAS}}} \\\\\n") 
   
    titulo_orgao = paste("\\multicolumn{3}{L{15cm}}{\\textbf{ÓRGÃO:} ",banco$orgao[1],"} \\\\\n", sep="") 
    titulo_uo = paste("\\multicolumn{3}{L{15cm}}{\\textbf{UO:} \\hspace{19pt} ",banco$uo[1] ,"} \\\\\n", sep="") 
  
    subtitulo = paste("\\multicolumn{2}{l}{\\textbf{Exercício: \\textcolor{myblack}{", ANO_DOC, 
                      "}}} & \\multicolumn{1}{r}{R\\$1,00} \\\\\n")  
   
    cabecalho = paste0("\\multicolumn{1}{@{\\hspace{1em}}L{8cm}@{\\hspace{0.5em}}|}{\\textbf{ ", 
                    "REGIÕES GEOGRÁFICAS INTERMEDIÁRIAS}}  & \\multicolumn{1}{C{3cm}|}{\\textbf{ VALOR}} &  ", 
                    "\\multicolumn{1}{C{3cm}}{\\textbf{PORCENTAGEM}} \\\\\n") 
   
    cat(titulo1) 
    cat(titulo2) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat("\\hline\n") 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
    cat(cabecalho) 
    cat("\\hline\n") 
    cat("\\endfirsthead\n") 
 
    cat(titulo1) 
    cat(titulo2) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat("\\hline\n") 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
    cat(cabecalho) 
    cat("\\hline\n") 
    cat("\\endhead\n") 
    cat("\\endfoot\n") 
    cat("\\hline\n") 
    cat("\\hline\\hline\n")  
    cat("\\endlastfoot\n") 
   
      for(i in 1:nrow(banco)){ 
        if(toupper(banco$territorio[i])=="TOTAL"){ 
          
         cat("\\hline \\hline \n") 
          
          cat("\\multicolumn{1}{@{\\hspace{1em}}L{8cm}|}{ \\textbf{", banco$territorio[i],  
             "}} & \\multicolumn{1}{r|}{ \\textbf{", banco$valor[i],  
             "}} & \\multicolumn{1}{r}{ \\textbf{", gsub("\\.", ",", banco$porcentagem[i]), "}} \\\\\n") 
          
       } else { 
          
         cat("\\multicolumn{1}{@{\\hspace{1em}}L{8cm}|}{ ", banco$territorio[i],  
             "} & \\multicolumn{1}{r|}{ ", banco$valor[i],  
             "} & \\multicolumn{1}{r}{ ", gsub("\\.", ",", banco$porcentagem[i]), "} \\\\\n") 
       } 
      } 
   
  cat("\\end{longtable}\n") 
   
  # FIM TABELA 
