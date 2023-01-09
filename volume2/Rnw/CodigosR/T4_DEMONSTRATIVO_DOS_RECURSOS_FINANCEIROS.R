    # INICIO TABELA 
   
    banco = data.table(read.table(paste(dir_data, "/tabela4/",uo,".txt",sep=""),  
                                  header=T, sep="\t", dec=",", stringsAsFactors = FALSE)) 
 
    cat("\\renewcommand*{\\arraystretch}{1.5}\n") 
    cat("\\small\n") 
 
    cat("\\noindent\\begin{longtable}[c]{L{3cm}|m{1.5cm}|m{8cm}|m{3cm}|m{3cm}|m{3cm}}\n") 
             
    titulo1 = paste0("\\multicolumn{6}{c}{\\cellcolor{gray!50} \\normalsize \\textbf{ ", 
                     "DEMONSTRATIVO DOS RECURSOS FINANCEIROS}} \\TBstrut   \\\\[2ex] \n") 
   
    subtitulo = paste("\\multicolumn{5}{l}{\\textbf{Exercício: ", ANO_DOC, 
                      "}} & \\multicolumn{1}{r}{R\\$1,00} \\\\\n") 
   
    titulo_orgao = paste0("\\multicolumn{6}{l}{\\textbf{ÓRGÃO:} ", banco[1, nome_orgao],"} \\\\\n") 
    titulo_uo = paste0("\\multicolumn{6}{l}{\\textbf{UO:} \\hspace{21pt}", banco[1, nome_uo],"} \\\\\n") 
   
    receita = "\\multicolumn{6}{l}{\\textbf{1.RECEITA PRÓPRIA}} \\\\\n" 
   
    cabecalho = paste("\\multicolumn{1}{C{3cm}|}{\\textbf{ CÓDIGO}} & ", 
                      "\\multicolumn{1}{@{\\hspace{1em}}C{1.5cm}@{\\hspace{1em}}|}{\\textbf{ FONTE}} & ", 
                      "\\multicolumn{1}{@{\\hspace{1em}}L{8cm}@{\\hspace{0.5em}}|}{\\textbf{ ESPECIFICAÇÃO}}  &  ", 
                      "\\multicolumn{1}{C{3.5cm}|}{\\textbf{ DESDOBRAMENTO}} &  ", 
                      "\\multicolumn{1}{C{3cm}|}{\\textbf{ ESPÉCIE}} & ", 
                      "\\multicolumn{1}{C{3cm}}{\\textbf{ CATEGORIA ECONÔMICA/\nORIGEM}} \\\\\n") 
   
    cat(titulo1) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
    cat(receita) 
    cat("\\hline \n") 
    cat(cabecalho) 
 
    cat("\\hline\n") 
    cat("\\endfirsthead\n") 
 
    cat(titulo1) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
    cat(receita) 
    cat("\\hline \n") 
    cat(cabecalho) 
   
    cat("\\hline\n") 
    cat("\\endhead\n") 
   
    cat("\\endfoot\n") 
    cat("\\hline\n") 
   
    cat("\\hline\\hline\n")  
    cat("\\endlastfoot\n") 
   
    for(i in 1:nrow(banco)){ 
       if(grepl("^SUBTOTAL.*", banco[i, descricao], ignore.case = T)){ 
          
         cat("\\hline \\hline \n") 
         cat("\\multicolumn{5}{@{\\hspace{1em}}L{8cm}@{\\hspace{0.5em}}|}{ \\textbf{", banco[i, descricao],  
             "}} & \\multicolumn{1}{r@{\\hspace{0.5em}}}{ \\textbf{", banco[i, valor_categoria], "}} \\\\\n")  
          
       } else{ 
          
          cat("\\multicolumn{1}{C{3cm}|}{",TratamentoNA(banco[i, cod_texto]),  
              "} & \\multicolumn{1}{c|}{", TratamentoNA(banco[i, COD_FONTE]),  
              "} & \\multicolumn{1}{@{\\hspace{1em}}L{8cm}@{\\hspace{0.5em}}|}{",TratamentoNA(banco[i, descricao]), 
              "} & \\multicolumn{1}{r@{\\hspace{0.5em}}|}{", TratamentoNA(banco[i, valor_desdobramento]),  
              "} & \\multicolumn{1}{r@{\\hspace{0.5em}}|}{",   TratamentoNA(banco[i, valor_especie]), 
              "} & \\multicolumn{1}{r@{\\hspace{1em}}}{", TratamentoNA(banco[i, valor_categoria]), "} \\\\\n") 
          
       } 
     } 
 
  cat("\\end{longtable}\n") 
   
  # FIM TABELA 
