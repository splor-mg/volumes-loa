# INICIO TABELA 
 
  anexo_det = read.table(paste(dir_bancos, "/manual/ANEXO_detalhamento_investimentos.txt", sep=""),  
                       header=T, sep="\t", stringsAsFactors = FALSE) 
 
  cat("\\noindent\\begin{longtable}[c]{m{1cm}m{1cm}m{1cm}m{8cm}}\n") 
 
  titulo = paste0("\\multicolumn{4}{C{14cm}}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                "DETALHAMENTO DOS INVESTIMENTOS}}}\\TBstrut  \\\\[2ex]\n") 
  cat(titulo) 
  cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
  
  cat("\\hline\n") 
  cat("\\endfirsthead\n") 
  
  cat(titulo) 
  cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
  
  cat("\\hline\n") 
  cat("\\endhead\n") 
  cat("\\endfoot\n") 
  cat("\\hline\n") 
 
  cat("\\hline\\hline\n") 
  cat("\\endlastfoot\n") 
 
 
  for(i in 1:nrow(anexo_det)){ 
    if(anexo_det$cod[i]==1){ 
      cat("\\multicolumn{4}{L{10cm}}{\\textbf{",anexo_det$descricao[i], "}} \\\\\n", sep="") 
    }else { 
      cat("& \\multicolumn{3}{L{7cm}}{",anexo_det$descricao[i], "} \\\\\n", sep="") 
    } 
  } 
  cat("\\end{longtable}\n") 
# FIM TABELA 
