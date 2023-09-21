  # INICIO TABELA 
  library(readr) 
 
  banco=data.table(read.table(paste0(dir_data, "/receita_fonte_stn.txt"), 
                                header=T, sep="\t", dec="@", stringsAsFactors = FALSE)) 
 
  cat("\\renewcommand*{\\arraystretch}{1.7}\n") 
  cat("\\scriptsize\n") 
 
  cat("\\noindent\\begin{longtable}[c]{L{3cm}|m{1cm}|m{6cm}|m{2.5cm}|m{2cm}|m{2cm}}\n") 
             
  titulo1 = paste0("\\multicolumn{6}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                   "QUADRO GERAL DA RECEITA}}} \\\\\n") 
   
  titulo2 = paste0("\\multicolumn{6}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                   "(Art. 2$^o$, \\S 1$^o$, Inciso III da Lei 4.320/64)}}} \\\\\n") 
   
  subtitulo = paste("\\multicolumn{5}{l}{\\textbf{Exercício: \\textcolor{myblack}{", ANO_DOC, 
                    "}}} & \\multicolumn{1}{r}{R\\$1,00} \\\\[2ex] \n")  
   
  cabecalho = paste("\\multicolumn{1}{C{3cm}|}{\\textbf{ CÓDIGO}} & ", 
                    "\\multicolumn{1}{@{\\hspace{1em}}C{1cm}@{\\hspace{1em}}|}{\\textbf{ FONTE}} & ", 
                    "\\multicolumn{1}{@{\\hspace{1em}}L{6cm}@{\\hspace{0.5em}}|}{\\textbf{ ESPECIFICAÇÃO}}  &  ", 
                    "\\multicolumn{1}{C{2.5cm}|}{\\textbf{ DESDOBRAMENTO}} & ", 
                    "\\multicolumn{1}{C{2cm}|}{\\textbf{ ESPÉCIE}} & ", 
                    "\\multicolumn{1}{C{2cm}}{\\textbf{ CATEGORIA / ORIGEM}} \\\\\n") 
   
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
   
     for(i in 1:nrow(banco)){ 
       if(grepl("TOTAL", banco[i, descricao], ignore.case = T)){ 
          
         cat("\\hline \\hline \n") 
         cat("\\multicolumn{5}{@{\\hspace{1em}}L{8cm}@{\\hspace{0.5em}}|}{ \\textbf{", banco[i, descricao],  
             "}} & \\multicolumn{1}{r@{\\hspace{0.5em}}}{ \\textbf{", banco[i, valor_categoria],  
             "}} \\\\\n")  
          
       } else if(grepl("\\d{1}0{3}\\.0{2}\\.0\\.0\\.0{2}\\.0{3}", as.character(banco[i, cod_texto]))){ 
          
         cat("\\multicolumn{1}{L{3cm}|}{\\textbf{ ",TratamentoNA(banco[i, cod_texto]),  
             "}} & \\multicolumn{1}{c|}{ \\textbf{", TratamentoNA(banco[i, COD_FONTE]),  
             "}} & \\multicolumn{1}{@{\\hspace{1em}}J{6cm}@{\\hspace{0.5em}}|}{ \\textbf{", banco[i, descricao],  
             "}} & \\multicolumn{1}{r@{\\hspace{0.5em}}|}{ \\textbf{", banco[i, valor_desdobramento],  
             "}} & \\multicolumn{1}{r@{\\hspace{0.5em}}|}{ \\textbf{", banco[i, valor_especie], 
             "}} & \\multicolumn{1}{r@{\\hspace{1em}}}{ \\textbf{", banco[i, valor_categoria],  
             "}} \\\\\n") 
          
       } else if(grepl("\\d{1}[1-9]0{2}\\.0{2}\\.0\\.0\\.0{2}\\.0{3}", as.character(banco[i, cod_texto]))){ 
          
         cat("\\multicolumn{1}{L{3cm}|}{ \\hspace{1em}",TratamentoNA(banco[i, cod_texto]),  
             "} & \\multicolumn{1}{c|}{ ", TratamentoNA(banco[i, COD_FONTE]),  
             "} & \\multicolumn{1}{@{\\hspace{2em}}J{6cm}@{\\hspace{0.5em}}|}{ ", banco[i, descricao],  
             "} & \\multicolumn{1}{r@{\\hspace{0.5em}}|}{ ", banco[i, valor_desdobramento],  
             "} & \\multicolumn{1}{r@{\\hspace{0.5em}}|}{ ",   banco[i, valor_especie], 
             "} & \\multicolumn{1}{r@{\\hspace{1em}}}{ ", banco[i, valor_categoria],  
             "} \\\\\n") 
          
       } else{ 
          
         cat("\\multicolumn{1}{L{3cm}|}{ \\hspace{2em}",TratamentoNA(banco[i, cod_texto]),  
             "} & \\multicolumn{1}{c|}{ ", TratamentoNA(banco[i, COD_FONTE]),  
             "} & \\multicolumn{1}{@{\\hspace{3em}}J{6cm}@{\\hspace{0.5em}}|}{ ", banco[i, descricao],  
             "} & \\multicolumn{1}{r@{\\hspace{0.5em}}|}{ ", banco[i, valor_desdobramento],  
             "} & \\multicolumn{1}{r@{\\hspace{0.5em}}|}{ ", banco[i, valor_especie], 
             "} & \\multicolumn{1}{r@{\\hspace{1em}}}{ ", banco[i, valor_categoria],  
             "} \\\\\n") 
          
       } 
     } 
   
  cat("\\end{longtable}\n") 
   
  # FIM TABELA 
