  # INICIO TABELA 
  cat("\\renewcommand*{\\arraystretch}{1.9}\n") 
  cat("\\scriptsize\n") 
 # cat("\\color{myblack}\n") 
 # cat("\\centering\n") 
 
  banco = data.table(read.csv2(paste(dir_data, "/tabela3/", uo,".csv", sep=""), stringsAsFactors = F)) 
 
  cat("\\noindent\\begin{longtable}[c]{m{12cm}m{2.5cm}m{2.5cm}}\n") 
 
  titulo =  paste0("\\multicolumn{3}{c}{\\cellcolor{gray!50} \\normalsize \\textbf{", 
                   "DETALHAMENTO DE PESSOAL INATIVO CIVIL}} \\TBstrut   \\\\[2ex] \n") 
  
  subtitulo = paste("\\multicolumn{3}{l}{\\textbf{Exercício: ", ANO_DOC , "}} \\\\\n") 
  
  cabecalho = paste0("\\multicolumn{1}{C{12cm}}{\\textbf{ÓRGÃO / ENTIDADE}} & ", 
                     " \\multicolumn{1}{c}{\\textbf{QUANTIDADE}} &  ", 
                     "\\multicolumn{1}{c}{\\textbf{VALOR}}  \\\\\n ") 
    
  titulo_orgao = paste0("\\multicolumn{3}{l}{\\textbf{ÓRGÃO:} ", banco[1, nome_orgao] , "} \\\\\n") 
  titulo_uo = paste0("\\multicolumn{3}{l}{\\textbf{UO:} \\hspace{14pt} ", banco[1, uo_funfip] ,"} \\\\\n") 
    
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
     
     if(banco[i, poder]!=""){ 
        
       cat("\\hline \n") 
        
       cat("\\multicolumn{1}{L{12cm}}{ \\textbf{ ", banco[i, poder], 
           "}} & \\multicolumn{1}{c}{ \\textbf{ ", TratamentoNA(banco[i, qtdePoder]),  
           "}} & \\multicolumn{1}{r}{ \\textbf{ ", TratamentoNA(banco[i, valorPoder]),  
           "}} \\\\\n", sep="") 
        
      cat("\\hline \n") 
    } 
    if(banco[i, poder]!="TOTAL"){ 
       
      if(grepl("^ADMIN.+", banco[i, nome_uo], perl=T)){ 
         
        cat("\\multicolumn{1}{@{ \\hspace{2em}}L{12cm}}{ \\textbf{ ", banco[i, nome_uo],  
            "}} & \\multicolumn{1}{c}{ \\textbf{ ", TratamentoNA(banco[i, quantidade]),  
            "}} & \\multicolumn{1}{r}{ \\textbf{ ", TratamentoNA(banco[i, valor]),  
            "}} \\\\\n", sep="") 
         
    } else{ 
   
      cat("\\multicolumn{1}{@{ \\hspace{4em}}L{12cm}}{", banco[i, nome_uo],  
        "} & \\multicolumn{1}{c}{ ", TratamentoNA(banco[i, quantidade]),  
        "} & \\multicolumn{1}{r}{ ", TratamentoNA(banco[i, valor]), "} \\\\\n", sep="") 
       
    } 
    } 
   } 
  
  cat("\\end{longtable}\n") 
 
  # FIM TABELA 
