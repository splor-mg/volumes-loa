    # INICIO TABELA 
 
    cat("\\renewcommand*{\\arraystretch}{1.7}\n") 
    cat("\\scriptsize\n") 
   
    tabela2_path <- paste0(dir_data,"/tabela2/", uo,".txt",sep="")
    bancoTodasAcoes = data.table(read.table(tabela2_path, 
                                 header=T, sep="\t", dec=",", stringsAsFactors = FALSE)) 
   
    cat("\\phantomsection\n")  
    if(!sumario[COD_UO==uo, poder][1] %in% registro_poder){  
      cat("\\addcontentsline{toc}{section}{\\underline{", sumario[COD_UO==uo, poder][1] ,"}}\n") 
      registro_poder = append(registro_poder, sumario[COD_UO==uo, poder][1])  
    }  
   
   
    if(!sumario[COD_UO==uo, COD_ORGAO][1] %in% registro_orgao){  
      cat("\\addcontentsline{toc}{section}{",paste0(substr(sumario[COD_UO==uo, COD_ORGAO][1],1,1),".", 
                                                    substr(sumario[COD_UO==uo, COD_ORGAO][1],2,3), ".",   
                                                    substr(sumario[COD_UO==uo, COD_ORGAO][1],4,4), " - ",  
                                                    sumario[COD_UO==uo, ORGAO][1]),"}\n") 
       
      registro_orgao = append(registro_orgao, sumario[COD_UO==uo, COD_ORGAO][1]) 
      }  
   
  
   
  cat("\\addcontentsline{toc}{subsection}{",paste0(substr(uo,1,1), ".", substr(uo,2,3), ".",   
                                                   substr(uo,4,4), " - ",  
                                                   sumario[COD_UO==uo, unique1(UO)]),"}\n")  
   
  for(acao in bancoTodasAcoes[, unique(especificacao)]){ 
     
    banco = bancoTodasAcoes[especificacao==acao, ] 
    banco[is.na(banco)] = '' 
 
    cat("\\noindent\\begin{longtable}[c]{L{8cm}|m{1pt}|m{2cm}|m{1pt}|m{1pt}|m{1pt}|m{1.5cm}|m{1.5cm}}\n") 
             
    titulo1 = paste0("\\multicolumn{8}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {", 
                   "\\normalsize \\textbf{DETALHAMENTO DOS INVESTIMENTOS}}} \\Tstrut \\\\\n") 
   
    titulo2 = paste0("\\multicolumn{8}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\normalsize \\textbf{", 
                   "POR REGIÕES GEOGRÁFICAS INTERMEDIÁRIAS E MUNICÍPIOS}}} \\\\[1ex] \n") 
   
    titulo_orgao = paste0("\\multicolumn{8}{L{18cm}}{\\textbf{ÓRGÃO:} ", banco[1, orgao] ,"} \\\\\n") 
    titulo_uo = paste0("\\multicolumn{8}{L{18cm}}{\\textbf{UO:} \\hspace{14pt} ",banco[1, nome_uo] ,"} \\\\\n") 
   
    especificacao = paste0("\\multicolumn{8}{L{18cm}}{\\textbf{ESPECIFICAÇÃO: \\textcolor{myblack}{ ", 
                           banco[1, especificacao], "}} ", banco[1, nome_acao],"} \\Tstrut \\\\\n") 
   
    cod_admin = paste0("\\multicolumn{8}{L{18cm}}{\\textbf{CÓDIGO ADMIN: \\textcolor{myblack}{ \\hspace{0.1cm} ", 
                       formatC(banco[1, cod_admin], width = 4, flag="0"), 
                    " }} \\hspace{1.2cm} ", banco[1, nome_acao], "} \\\\[3ex] \n", sep="") 
   
    subtitulo = paste("\\multicolumn{7}{l}{\\textbf{Exercício: \\textcolor{myblack}{", ANO_DOC, 
                    "}}} & \\multicolumn{1}{r}{R\\$1,00} \\\\ \n")  
   
    cabecalho1= paste0("\\multicolumn{1}{L{8cm}|}{\\textbf{ REGIÕES GEOGRÁFICAS INTERMEDIÁRIAS}} &", 
                       "\\multicolumn{2}{c|}{\\multirow{2}{*}{\\centering \\textbf{META FÍSICA}}} & ", 
                       "\\multicolumn{3}{c|}{\\multirow{2}{*}{\\parbox{1.5cm}{\\centering \\textbf{", 
                       "SITUAÇÃO ATUAL DA OBRA}}}} & \\multicolumn{2}{c}{\\multirow{2}{*}{ \\textbf{VALOR}}} \\\\\n") 
   
    cabecalho2= paste0("\\multicolumn{1}{L{8cm}|}{\\textbf{ \\hspace{1.5em} MUNICÍPIOS}} &", 
                       "\\multicolumn{2}{c|}{} &", "\\multicolumn{3}{c|}{} &", "\\multicolumn{2}{c}{} \\\\\n") 
 
    cabecalho3 = paste0("\\multicolumn{1}{L{8cm}|}{\\textbf{ \\hspace{3em} DISCRIMINAÇÃO DA OBRA}} & ", 
                       "\\multicolumn{1}{c|}{\\textbf{ QTDE.}} & ", 
                       "\\multicolumn{1}{L{2cm}|}{\\textbf{ UNID. MEDIDA}}  &  ", 
                       "\\multicolumn{1}{c|}{\\textbf{ I}} &   \\multicolumn{1}{c|}{\\textbf{ E}} & ", 
                       "\\multicolumn{1}{c|}{\\textbf{ P}} &   \\multicolumn{1}{c|}{\\textbf{ TESOURO}} &", 
                       "\\multicolumn{1}{c}{\\textbf{ OUTROS}} \\\\\n") 
   
      cat(titulo1);  cat(titulo2) 
      cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
      cat(subtitulo) 
      cat("\\hline\n") 
      cat(titulo_orgao); cat(titulo_uo) 
      cat("\\specialrule{1pt}{0pt}{0pt}\n") 
      cat(especificacao);  cat(cod_admin) 
      cat("\\specialrule{1pt}{0pt}{0pt}\n") 
      cat(cabecalho1); cat(cabecalho2) 
      cat("\\cline{2-8}\n") 
      cat(cabecalho3) 
      cat("\\hline\n") 
      cat("\\endfirsthead\n") 
   
      cat(titulo1);  cat(titulo2) 
      cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
      cat(subtitulo) 
      cat("\\hline\n") 
      cat(titulo_orgao); cat(titulo_uo) 
      cat("\\specialrule{1pt}{0pt}{0pt}\n") 
      cat(especificacao);  cat(cod_admin) 
      cat("\\specialrule{1pt}{0pt}{0pt}\n") 
      cat(cabecalho1);  cat(cabecalho2) 
      cat("\\cline{2-8}\n") 
      cat(cabecalho3) 
      cat("\\hline\n") 
      cat("\\endhead\n") 
   
      cat("\\endfoot\n") 
      cat("\\hline\n") 
      cat("\\hline\\hline\n")  
      cat("\\endlastfoot\n") 
   
      territorios = c("") 
      municipios = c("") 
   
      for(i in 1:nrow(banco)){ 
        if(!banco[i, territorio] %in% territorios){ 
          cat("\\hline\n") 
          cat("\\multicolumn{1}{L{8cm}|}{\\textbf{ ", banco[i, territorio], "}} & & & & & & & \\\\\n") 
          territorios = append(territorios, banco[i, territorio]) 
        } 
         
        if(!banco[i, municipio] %in% municipios){ 
           
          cat("\\multicolumn{1}{L{8cm}|}{\\textbf{ \\hspace{1em} ", banco[i, municipio], "}} & & & & & & & \\\\\n") 
          municipios = append(municipios, banco[i, municipio]) 
           
        } 
         
        if(grepl("TOTAL", banco[i, obra], ignore.case = T)){ 
           
          cat("\\hline \\hline \n") 
          cat("\\multicolumn{6}{@{\\hspace{3.5em}}L{8cm}|}{ \\textbf{", banco[i, obra],  
              "}} & \\multicolumn{1}{r|}{ \\textbf{", banco[i, tesouro],  
              "}} & \\multicolumn{1}{r}{ \\textbf{", banco[i, outros],  
              "}} \\\\\n") 
         
          } else{ 
         
          cat("\\multicolumn{1}{@{\\hspace{3.5em}}L{8cm}|}{ ", banco[i, obra],  
              "} & \\multicolumn{1}{c|}{",banco[i, qtde],  
              "} & \\multicolumn{1}{@{\\hspace{0.5em}}L{2cm}|}{", tratUnidadeMedida(banco[i, unidade]),  
              "} & \\multicolumn{1}{c|}{ ", preencherCelula(banco[i, iniciando]),  
              "} & \\multicolumn{1}{c|}{ ", preencherCelula(banco[i, execucao]),   
              "} & \\multicolumn{1}{c|}{ ",  preencherCelula(banco[i, paralisada]), 
              "} & \\multicolumn{1}{r|}{",TratamentoNA(banco[i, tesouro]),  
              "} & \\multicolumn{1}{r}{", TratamentoNA(banco[i, outros]), "} \\\\\n") 
 
          } 
      } 
 
  cat("\\end{longtable}\n") 
  cat("\\raggedright{\\textbf{SITUAÇÃO ATUAL DA OBRA: I – INICIANDO; E – EM EXECUÇÃO; P – PARALISADA}} \n") 
  cat("\\newpage\n") 
   
  } 
   
  # FIM TABELA 
