  # INICIO TABELA 
 
    banco = data.table(read.table(paste(dir_data, "/tabela3/", uo ,".txt", sep=""), header=T,  
                                  sep="\t", dec=",", stringsAsFactors = FALSE)) 
 
    cat("\\small\n") 
 
    cat("\\noindent\\begin{longtable}[c]{m{7cm}|m{2.5cm}|m{2.5cm}|m{2.5cm}|m{3.5cm}}\n") 
 
    titulo =  paste("\\multicolumn{5}{c}{\\cellcolor{gray!50} \\normalsize \\textbf{", 
                    "DETALHAMENTO DA CATEGORIA DE PESSOAL}} \\TBstrut   \\\\[2ex] \n") 
  
    subtitulo = paste("\\multicolumn{5}{l}{\\textbf{Exercício: ", ANO_DOC , "}} \\\\\n") 
  
    cabecalho = paste0("\\multicolumn{1}{C{7cm}|}{\\textbf{ESPECIFICAÇÃO}} & ", 
                       " \\multicolumn{1}{c|}{\\textbf{QUANTIDADE}} &  ", 
                      "\\multicolumn{1}{c|}{\\textbf{VALOR}} & ", 
                      "\\multicolumn{1}{C{2.5cm}|}{\\textbf{\\% DO TOTAL DE PESSOAL}} & ", 
                      "\\multicolumn{1}{C{3.5cm}}{\\textbf{\\% DE PARTICIPAÇÃO ORÇAMENTÁRIA}} \\\\\n ") 
    
    titulo_orgao = paste0("\\multicolumn{5}{L{16cm}}{\\textbf{ÓRGÃO:} ", banco[1, nome_orgao] , "} \\\\\n") 
    titulo_uo = paste0("\\multicolumn{5}{L{16cm}}{\\textbf{UO:} \\hspace{17pt} ", banco[1,nome_uo] ,"} \\\\\n") 
    
    cat(titulo) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\hline \n") 
    cat(cabecalho) 
    cat("\\hline\n") 
    cat("\\endfirsthead\n") 
    
    cat(titulo) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\hline \n") 
    cat(cabecalho) 
    cat("\\hline\n") 
    cat("\\endhead\n") 
     
    cat("\\endfoot\n") 
    cat("\\hline\n") 
 
    cat("\\hline\\hline\n") 
    cat("\\endlastfoot\n") 
  
    for(i in 1:nrow(banco)){ 
      if(banco[i, classificacao]!=""){ 
       
      if(toupper(banco[i, classificacao])=="TOTAL"){ 
        cat("\\hline \\hline \n") 
      } 
       
      cat("\\multicolumn{1}{L{7cm}|}{ \\textbf{", banco[i, classificacao], 
          "}} & \\multicolumn{1}{r|}{ \\textbf{", TratamentoNA(banco[i, total]),  
          "}} & \\multicolumn{1}{r|}{ \\textbf{", TratamentoNA(banco[i, valor]), 
          "}} & \\multicolumn{1}{r|}{ \\textbf{",  
          ifelse(TratamentoNA(banco[i, perc_total_pessoal])!="", paste0(gsub("\\.",",", banco[i, perc_total_pessoal]),  
                                                              "\\%"),""), 
          "}} & \\multicolumn{1}{r}{ \\textbf{",  
          ifelse(TratamentoNA(banco[i, participacao])!="", paste0(gsub("\\.",",", banco[i, participacao]),  
                                                              "\\%"),""), "}} \\\\\n", sep="") 
    }  
     
      if(toupper(banco[i, classificacao])!="TOTAL"){ 
         
        cat("\\multicolumn{1}{L{7cm}|}{ \\hspace{3em} ", banco[i, categoria],  
            "} & \\multicolumn{1}{r|}{ ", TratamentoNA(banco[i, quantidade]),  
            "} &  & \\multicolumn{1}{r|}{ ", 
            ifelse(TratamentoNA(banco[i, perc_categoria_pessoal])!="", paste0(gsub("\\.",",", banco[i, perc_categoria_pessoal]),  
                                                                "\\%"),""), 
            "} & \\\\\n", sep="") 
   
      } 
    } 
  
  cat("\\end{longtable}\n") 
   
  # FIM TABELA 
