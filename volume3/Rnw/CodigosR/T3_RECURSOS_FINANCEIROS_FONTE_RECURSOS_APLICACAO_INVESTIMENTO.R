    # INICIO TABELA 
    banco = data.table(read.table(paste(dir_data, "/tabela3/", uo,".txt", sep=""), header=F,  
                                  sep="\t", dec=",", stringsAsFactors = FALSE)) 
 
    nColunas = ncol(banco)-2 
   
    #print(paste(uo, " : ", nColunas)) 
 
    if(nColunas<=3){ 
      largura_tabela = 5 
    } else if (nColunas<=6){ 
      largura_tabela = 10 
    } else{ 
      largura_tabela = 12 
      } 
     
    # Pirmeira coluna tem 5cm. A soma das demais deve ser 9cm. 
    col = paste("|m{",round((largura_tabela/(ncol(banco)-3)),0),"cm}", sep="")  
 
    cat(paste("\\noindent\\begin{longtable}[c]{m{5cm}", paste(rep(col, ncol(banco)-3), collapse=""),"}\n", sep="")) 
   
    titulo1 = paste0("\\multicolumn{", nColunas , "}{c}{\\cellcolor{gray!50} \\textcolor{myblack} ", 
                     "{\\normalsize \\textbf{RECURSOS FINANCEIROS}}}\\\\\n") 
    titulo2 = paste0("\\multicolumn{",nColunas,"}{c}{\\cellcolor{gray!50} \\textcolor{myblack} ", 
                    "{\\normalsize \\textbf{FONTE DE RECURSOS E APLICAÇÃO - INVESTIMENTO}}}\\\\\n") 
   
    subtitulo = paste0("\\multicolumn{",(nColunas-1), 
                      "}{l}{\\textbf{Exercício: \\textcolor{myblack}{",  
                      ANO_DOC ,"}}} & \\multicolumn{1}{r}{R\\$1,00} \\\\\n") 
   
    titulo_orgao = paste0("\\multicolumn{", nColunas,  
                         "}{L{",(5+largura_tabela) ,  
                         "cm}}{\\textbf{ÓRGÃO:} ", 
                         banco$V2[1],"} \\\\\n") 
     
    titulo_uo = paste0("\\multicolumn{",nColunas, "}{L{",(5+largura_tabela) ,  
                      "cm}}{\\textbf{UO:} \\hspace{12pt} ",banco[1, V1],"} \\\\\n") 
   
    cat(titulo1) 
    cat(titulo2) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
   
    if(nColunas<=3){ 
      larguras_demais_colunas = round((4 / (nColunas -2)),0)   
    } else if (nColunas<=6){ 
      larguras_demais_colunas = round((10 / (nColunas -2)),1)   
    } else{ 
      larguras_demais_colunas = round((12 / (nColunas -2)),1) 
    } 
   
    cabecalho = "" 
     
    for(i in 1:nColunas){ 
     
      if(i==1){ 
        cabecalho = paste0(cabecalho,"\\multicolumn{1}{C{3cm}}{ \\textbf{ ", banco[1,(i+2), with=F], "}} & ") 
         
      }else if(i < nColunas){ 
        cabecalho = paste0(cabecalho, "\\multicolumn{1}{R{", larguras_demais_colunas,  
                           "cm}}{ \\textbf{ ", banco[1, (i+2), with=F], "}} & ") 
      }else{ 
        cabecalho = paste0(cabecalho, "\\multicolumn{1}{R{1.7cm}}{\\textbf{ ", banco[1,(i+2), with=F], "}} \\\\\n") 
      } 
  } 
   
    cat(cabecalho) 
    cat("\\hline\n") 
    cat("\\endfirsthead\n") 
 
    cat(titulo1) 
    cat(titulo2) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
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
   
   for(j in 2:nrow(banco)){ 
      
     linha = "" 
     if(toupper(as.character(banco[j, V3]))!="TOTAL"){ 
       for(col in 1:nColunas){ 
         if(col==1){ 
            
           linha = paste0(linha,"\\multicolumn{1}{L{3cm}}{  ", banco[j, (col+2), with=F], "} & ") 
            
          }else if(col<nColunas){ 
             
            linha = paste0(linha,"\\multicolumn{1}{R{", larguras_demais_colunas, 
                           "cm}}{ ", banco[j,(col+2), with=F], "} & ") 
          }else{ 
             
            linha = paste0(linha, "\\multicolumn{1}{R{1.7cm}}{ ", banco[j,(col+2),with=F], "} \\\\\n") 
            } 
      } 
     
        cat(linha)  
    } 
   
     if(toupper(as.character(banco[j, V3]))=="TOTAL"){ 
       for(col in 1:nColunas){ 
         if(col==1){ 
            
           linha = paste0(linha,"\\multicolumn{1}{L{3cm}}{ \\textbf{", banco[j,(col+2), with=F], "}} & ") 
           
          }else if(col<nColunas){ 
             
            linha = paste0(linha,"\\multicolumn{1}{R{", larguras_demais_colunas, 
                          "cm}}{ \\textbf{", banco[j,(col+2), with=F], "}} & ") 
           
          }else{ 
             
            linha = paste0(linha, "\\multicolumn{1}{R{1.7cm}}{ \\textbf{", banco[j,(col+2), with=F], "}} \\\\\n") 
          } 
        
        } 
        
       cat("\\hline \\hline\n") 
       cat(linha) 
     }     
 
} 
   
    cat("\\end{longtable}\n") 
 
     
    # FIM TABELA 
