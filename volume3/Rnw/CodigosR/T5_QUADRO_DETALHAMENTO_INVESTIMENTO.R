  # INICIO TABELA 
  t5 = data.table( 
      readr::read_delim( 
      file = paste(dir_data, "/tabela5/", uo,".txt", sep=""),  
      delim = "\t",  
      locale = readr::locale('pt', decimal_mark = ',', encoding = 'Latin1'), 
      col_types = readr::cols(.default = 'c') 
      ) 
    )   
 
  t5[is.na(t5)] = "" 
   
  cat("\\newgeometry{left=3pt,right=3pt, top=1cm}\n") 
 
  cat("\\noindent\\begin{longtable}[c]{", 
      "m{2pt}m{2pt}m{2pt}m{1pt}m{2pt}|m{0.5cm}|m{3.5cm}|m{2.5cm}|m{2.5cm}|m{2cm}|m{2cm}}\n", sep="") 
 
 
  titulo=  paste0("\\multicolumn{11}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                  "QUADRO DE DETALHAMENTO DE INVESTIMENTO}}}\\TBstrut  \\\\[2ex]") 
   
  subtitulo = paste0("\\multicolumn{10}{l}{\\textbf{Exercício: \\textcolor{myblack}{", ANO_DOC , 
                   "}}} & \\multicolumn{1}{r}{R\\$1,00} \\\\\n") 
   
  titulo_orgao = paste0("\\multicolumn{11}{L{18cm}}{\\textbf{ÓRGÃO:} ", t5[1, orgao],"} \\\\\n") 
  titulo_uo = paste0("\\multicolumn{11}{L{18cm}}{\\textbf{UO:} \\hspace{12.5pt} ", t5[1, uo],"} \\\\\n") 
  
  cat(titulo) 
  cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
  cat(subtitulo) 
  cat(titulo_orgao) 
  cat(titulo_uo) 
  cat("\\specialrule{1pt}{0pt}{0pt}\n") 
  
  variaveis1 = paste0("\\multicolumn{5}{C{2.7cm}|}{\\multirow{2}{*}{\\textbf{CÓDIGO}}} & ", 
                      "\\multirow{2}{*}{\\textbf{IAG}} & ", 
                      "\\multicolumn{1}{c|}{\\multirow{2}{*}{\\textbf{ESPECIFICAÇÃO}}} & ", 
                      "\\multicolumn{1}{c|}{\\multirow{2}{*}{\\textbf{DETALHAMENTO}}} & ", 
                      "\\multicolumn{2}{c|}{\\textbf{RECURSOS}} & ", 
                      "\\multicolumn{1}{c}{\\multirow{2}{*}{\\textbf{TOTAL}}} \\\\\n") 
  
  variaveis2 = paste0("\\multicolumn{5}{c|}{} & & & & \\multicolumn{1}{c|}{\\textbf{FONTES}} & ", 
                      "\\multicolumn{1}{c|}{\\textbf{VALOR}} & \\\\\n") 
  
 cat(variaveis1) 
 cat("\\cline{9-10}\n") 
 cat(variaveis2) 
  
 cat("\\hline\n") 
 cat("\\endfirsthead\n") 
  
  # Inicio cabeçalho 
  cat(titulo) 
  cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
  cat(subtitulo) 
  cat(titulo_orgao) 
  cat(titulo_uo) 
  cat("\\specialrule{1pt}{0pt}{0pt}\n") 
   
  cat(variaveis1) 
  cat("\\cline{9-10}\n") 
  cat(variaveis2) 
  
  cat("\\hline\n") 
  cat("\\endhead\n") 
  cat("\\endfoot\n") 
  cat("\\hline\n") 
  cat("\\hline \\hline\n") 
  cat("\\endlastfoot\n") 
 
  for(i in 1:nrow(t5)){ 
    if(toupper(t5[i, especificacao])=="TOTAL"){ 
       
      cat("\\hline \\hline\n") 
      cat("\\multicolumn{10}{l}{\\textbf{",t5[i, especificacao], 
          "}} & \\multicolumn{1}{r}{\\textbf{",t5[i, total], 
          "}}\n") 
     
  } else if(t5[i, detalhamento]=="" & t5[i, fontes]==""){ 
     
    cat("\\multicolumn{1}{c@{\\hspace{-0.2em}}}{ \\textbf{", formatC(TratamentoNA(t5[i, funcao]), width = 2, flag = "0"), 
        "}} & \\multicolumn{1}{c@{\\hspace{-0.2em}}}{ \\textbf{", formatC(TratamentoNA(t5[i, subfuncao]),  
                                                                          width = 3, flag = "0"),  
        "}} & \\multicolumn{1}{c@{\\hspace{-0.2em}}}{ \\textbf{", formatC(TratamentoNA(t5[i, prog]), width = 3, flag = "0"),  
        "}} & \\multicolumn{1}{c@{\\hspace{-0.2em}}}{ \\textbf{", TratamentoNA(t5[i, id]),  
        "}} & \\multicolumn{1}{c|}{ \\textbf{",   formatC(TratamentoNA(t5[i, proj]), width = 3, flag = "0"), 
        "}} & \\multicolumn{1}{c|}{ {\\bf ", TratamentoNA(t5[i, iag]),  
        "}} & \\multicolumn{1}{@{\\hspace{0.5em}}L{3.5cm}|}{\\novaFonte {\\bf ", t5[i, especificacao], 
        "}} &  &  &  & \\multicolumn{1}{r}{ \\textbf{",t5[i, total], "}} \\\\\n") 
     
  }else{ 
     
   cat("\\multicolumn{1}{c@{\\hspace{-0.2em}}}{ \\textbf{", formatC(TratamentoNA(t5[i, funcao]), width = 2, flag = "0"), 
       "}} & \\multicolumn{1}{c@{\\hspace{-0.2em}}}{ \\textbf{", formatC(TratamentoNA(t5[i, subfuncao]),  
                                                                         width = 3, flag = "0"),  
       "}} & \\multicolumn{1}{c@{\\hspace{-0.2em}}}{ \\textbf{", formatC(TratamentoNA(t5[i, prog]), width = 3, flag = "0"),  
       "}} & \\multicolumn{1}{c@{\\hspace{-0.2em}}}{ \\textbf{", TratamentoNA(t5[i, id]),  
       "}} & \\multicolumn{1}{c|}{ \\textbf{",   formatC(TratamentoNA(t5[i, proj]), width = 3, flag = "0"), 
       "}} & \\multicolumn{1}{c|}{", TratamentoNA(t5[i, iag]),  
       "} & \\multicolumn{1}{@{\\hspace{0.5em}}L{3.5cm}|}{\\novaFonte ", t5[i, especificacao], 
       "} & \\multicolumn{1}{@{\\hspace{0.5em}}L{2.5cm}|}{\\novaFonte ", t5[i, detalhamento],   
       "} & \\multicolumn{1}{@{\\hspace{0.5em}}L{2.5cm}|}{\\novaFonte ", t5[i, fontes],  
       "} & \\multicolumn{1}{r|}{", t5[i, valor],  
       "} & \\multicolumn{1}{r}{",t5[i, total], "} \\\\\n") 
    } 
  } 
 
  cat("\\end{longtable}\n") 
  
 # FIM TABELA 
