  # INICIO TABELA 
  
 if((uo$poder[1] %in% registro_poder)==FALSE){ 
    
   cat("\\addcontentsline{toc}{section}{\\underline{",uo$poder[1] ,"}}\n")   
    
 } 
  
 registro_poder = append(registro_poder, uo$poder[1]) 
  
 if((uo$COD_ORGAO[1] %in% registro_orgao)==FALSE){ 
    
   cat("\\addcontentsline{toc}{section}{",paste(substr(uo$COD_ORGAO[1],1,1),".", substr(uo$COD_ORGAO[1],2,3), ".",  
                                                   substr(uo$COD_ORGAO[1],4,4), " - ", uo$ORGAO[1], sep=""),"}\n")   
 } 
  
 registro_orgao = append(registro_orgao, uo$COD_ORGAO[1]) 
  
 cat("\\addcontentsline{toc}{subsection}{",paste(substr(uo$COD_UO[1],1,1),".", substr(uo$COD_UO[1],2,3), ".",  
                                                   substr(uo$COD_UO[1],4,4), " - ", uo$UO[1], sep=""),"}\n") 
  
 # if(codigo_uo %in% c(1011, 1021, 1031, 1051, 1091, 1441, 2361, 4031, 4121, 4441, 4451, 4611)){ 
 #   #uo$poder[1]!="PODER EXECUTIVO"){ 
 #   cat("\\includepdf[pages=-, scale=1.0]{",codigo_uo,".pdf}\n", sep="") 
 # } else{ 
  
  
 cat("\\renewcommand*{\\arraystretch}{1.9}\n") 
 cat("\\scriptsize\n") 
 cat("\\color{myblack}\n") 
 cat("\\centering\n") 
  
 cat("\\noindent\\begin{longtable}[c]{m{4.8cm}|m{1pt}m{1pt}m{1pt}m{1pt}m{1pt}m{1pt}", 
     "|m{1pt}m{1pt}m{0.5pt}m{1pt}|m{1pt}|m{1pt}m{1pt}|m{1pt}|m{2pt}|m{1pt}|m{2pt}|}\n", sep="") 
 
 titulo = "\\multicolumn{18}{c}{\\cellcolor{gray!50} \\textcolor{myblack} {\\footnotesize \\textbf{QUADRO DE DETALHAMENTO DA DESPESA - FISCAL}}}\\TBstrut  \\\\[2ex]\n" 
    
 subtitulo = paste("\\multicolumn{17}{l}{\\textbf{Exercício:} \\textcolor{myblack}{", uo$ANO[1] , 
                   "}} & \\multicolumn{1}{r}{ R\\$1,00} \\\\\n") 
  
 titulo_orgao = paste("\\multicolumn{18}{L{15cm}}{\\textbf{ÓRGÃO:}", paste(substr(uo$COD_ORGAO[1],1,1),".",  
                                                                           substr(uo$COD_ORGAO[1],2,3), ".",   
                                                                           substr(uo$COD_ORGAO[1],4,4), " - ",  
                                                                           uo$ORGAO[1], sep=""), "} \\\\\n") 
  
 titulo_uo = paste("\\multicolumn{18}{L{15cm}}{\\textbf{UO:} \\hspace{13pt} ", paste(substr(uo$COD_UO[1],1,1),".",  
                                                                       substr(uo$COD_UO[1],2,3), ".",  
                                                                       substr(uo$COD_UO[1],4,4), " - ",  
                                                                       uo$UO[1], sep="") ,"} \\\\\n") 
  
 cabecalho1 = paste("\\multirow{2}{3pt}{ESPECIFICAÇÃO} & \\multicolumn{13}{|c|}{CLASSIFICAÇÃO ORÇAMENTÁRIA} &", 
                    "\\multicolumn{2}{c|}{PROPOSTA DO PODER\\textsuperscript{(1)}} ", 
                    "& \\multicolumn{2}{c}{IMPORTÂNCIA\\textsuperscript{(2)}} \\\\\n") 
  
 cabecalho2 = paste("& \\multicolumn{1}{|c}{\\fonteSeis FUN} & \\multicolumn{1}{c}{\\fonteSeis SUBF} & ", 
                    "\\multicolumn{1}{c}{\\fonteSeis PRG} & \\multicolumn{1}{c}{\\fonteSeis ID} & ", 
                    "\\multicolumn{1}{c}{\\fonteSeis P/A} & \\multicolumn{1}{c|}{\\fonteSeis C/A} & ", 
                    "\\multicolumn{1}{c}{\\fonteSeis C} & \\multicolumn{1}{c}{\\fonteSeis GD} & ", 
                    "\\multicolumn{1}{c}{\\fonteSeis M} & \\multicolumn{1}{c|}{\\fonteSeis ED} & ", 
                    "\\multicolumn{1}{c|}{\\fonteSeis IAG} & \\multicolumn{1}{c}{\\fonteSeis F/} & ", 
                    "\\multicolumn{1}{c|}{\\fonteSeis IPU} & \\multicolumn{1}{c|}{\\fonteSeis DETALHADA} & ", 
                    "\\multicolumn{1}{c|}{\\fonteSeis TOTAL} &", 
                    "\\multicolumn{1}{c|}{\\fonteSeis DETALHADA} & \\multicolumn{1}{c}{\\fonteSeis TOTAL} \\\\\n" 
                    ) 
  
 cat(titulo) 
 cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
 cat(subtitulo) 
 cat(titulo_orgao) 
 cat(titulo_uo) 
 cat("\\specialrule{1pt}{0pt}{0pt}\n") 
 cat(cabecalho1) 
 cat("\\cline{2-18}\n") 
 cat(cabecalho2) 
 cat("\\hline\n") 
 cat("\\endfirsthead\n") 
  
 cat(titulo) 
 cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
 cat(subtitulo) 
 cat(titulo_orgao) 
 cat(titulo_uo) 
 cat("\\specialrule{1pt}{0pt}{0pt}\n") 
 cat(cabecalho1) 
 cat("\\cline{2-18}\n") 
 cat(cabecalho2) 
 cat("\\hline\n") 
 cat("\\endhead\n") 
 cat("\\endfoot\n") 
 cat("\\hline\n") 
 cat("\\hline\\hline\n") 
 cat("\\endlastfoot\n") 
  
 for(i in 1:nrow(uo)){ 
   if(toupper(uo$NOME_ACAO[i])!="TOTAL" & uo$NOME_ACAO[i]!=""){ 
 
     cat("\\multicolumn{1}{L{4.8cm}|}{",uo$NOME_ACAO[i], 
         "} & \\multicolumn{1}{c}{", formatC(uo$FUNCAO[i], width = 2, flag = "0"), 
         "} & \\multicolumn{1}{c}{", formatC(uo$SUB_FUNCAO[i], width = 3, flag = "0"), 
         "} & \\multicolumn{1}{c}{", uo$PROGRAMA[i], 
         "} & \\multicolumn{1}{l}{", uo$IDENT_PROJATIV[i], 
         "} & \\multicolumn{1}{c}{", formatC(uo$PROJ_ATIV[i], width = 3, flag = "0"), 
         "} & \\multicolumn{1}{l|}{", formatC(uo$SUB_PROJETO[i], width = 4, flag = "0"), 
         "} & & & & & & & & & \\multicolumn{1}{r|}{", uo$valor_proposto[i],  
         "} & & \\multicolumn{1}{r}{", uo$valor[i], "} \\\\\n") 
 
   } 
 
   if(toupper(uo$NOME_ACAO[i])!="TOTAL" & uo$NOME_ACAO[i]==""){ 
 
     cat("& & & & & & & \\multicolumn{1}{c}{", uo$CATEGORIA[i], 
         "} & \\multicolumn{1}{c}{", uo$GRUPO_DESPESA[i], 
         "} & \\multicolumn{1}{c}{", uo$MODALIDADE[i], 
         "} & \\multicolumn{1}{c|}{", formatC(uo$ELEMENTO_DESPESA[i], width = 2, flag = "0"), 
         "} & \\multicolumn{1}{c|}{", uo$IAG[i], 
         "} & \\multicolumn{1}{l}{", uo$FONTE[i], 
         "} & \\multicolumn{1}{c|}{", uo$IPU[i], 
         "} & \\multicolumn{1}{r|}{", uo$valor_proposto[i],  
         "} & & \\multicolumn{1}{r|}{", uo$valor[i],  
         "} & \\multicolumn{1}{r}{ } \\\\\n") 
   } 
 
   if(toupper(uo$NOME_ACAO[i])=="TOTAL"){ 
 
     cat("\\hline\n") 
     cat("\\multicolumn{15}{C{6cm}|}{\\textbf{",toupper(uo$NOME_ACAO[i]), 
         "}} & \\multicolumn{1}{r|}{\\textbf{", uo$valor_proposto[i],  
         "}} & & \\multicolumn{1}{r}{\\textbf{", uo$valor[i], " }} \\\\\n") 
   } 
 } 
  
cat("\\end{longtable}\n") 
#} 
 
cat("\\begin{addmargin}[5em]{6em}\n") 
cat("\\fontsize{7pt}{10pt}\\selectfont {\\textbf{Notas:}}\\\\\n") 
 
cat("\\fontsize{7pt}{10pt}\\selectfont {(1) Proposta orçamentária encaminhada pelo",  
    gsub("(.+) *- * (.+)", "\\2", uo$UO[1]),"}\\\\\n") 
 
cat("\\fontsize{7pt}{10pt}\\selectfont {(2) Proposta orçamentária com os valores para atender a limitação do crescimento anual das despesas primárias correntes estabelecida pela Lei Complementar 156/16 e Decreto Federal n\\degree 9.056/17 e que estão sendo considerados neste e demais volumes deste Projeto de Lei Orçamentária, bem como no Projeto de Lei de Revisão do PPPA 2016 - 2019 e seus volumes.}\\\\\n") 
cat("\\end{addmargin}\n") 
 
 
cat("\\newpage\n") 
cat("\\phantomsection\n") 
 
# FIM TABELA 
