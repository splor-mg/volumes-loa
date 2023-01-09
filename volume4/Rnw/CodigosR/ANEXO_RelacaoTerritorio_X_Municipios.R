  # INICIO TABELA 
   
  anexo = readxl::read_excel(paste0(dir_bancos,"/manual/correspondencia_mun_terr_desenvol.xlsx"), sheet=1) 
   
  names(anexo) = gsub(" ", "_", names(anexo), ignore.case = FALSE) 
  names(anexo) = iconv(names(anexo), from="UTF-8", to = "ASCII//TRANSLIT") 
  names(anexo) = tolower(names(anexo)) 
   
  anexo = anexo[order(anexo$cod_sigplan),] 
   
 
  cat("\\renewcommand*{\\arraystretch}{1.5}\n") 
  cat("\\normalsize\n") 
 
  for(cod_territorio in sort(unique(anexo$codigo_regiao_geografica_intermediaria))){ 
     
    anexo_territorio = anexo[anexo$codigo_regiao_geografica_intermediaria==cod_territorio,] 
   
    cat("\\noindent\\begin{longtable}[c]{m{18cm}}\n") 
             
    titulo = paste0("\\multicolumn{1}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\textbf{ \\Large ", 
                    "REGIÕES GEOGRÁFICAS INTERMEDIÁRIAS E MUNICÍPIOS}}} \\Tstrut \\\\ [2ex] \n") 
   
    cabecalho = paste("\\multicolumn{1}{l}{\\textbf{ \\large", paste0(formatC(cod_territorio, width = 2, flag="0") , 
                                                                     "  ", toupper(anexo_territorio$regiao_geografica_intermediaria[1])) ,   
                      " }} \\\\\n") 
   
    cat(titulo) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(cabecalho) 
    cat("\\endfirsthead\n") 
 
    cat(titulo) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(cabecalho) 
    cat("\\endhead\n") 
    cat("\\endfoot\n") 
    cat("\\hline\n") 
    cat("\\hline\\hline\n")  
    cat("\\endlastfoot\n") 
   
    for(i in 1:nrow(anexo_territorio)){ 
     
      cat("\\multicolumn{1}{l}{ \\hspace{2em}", anexo_territorio$cod_sigplan[i],  
          anexo_territorio$municipios[i], "} \\\\\n") 
     
      } 
     
    cat("\\end{longtable}\n") 
    cat("\\newpage\n") 
    } 
   
  # FIM TABELA 
