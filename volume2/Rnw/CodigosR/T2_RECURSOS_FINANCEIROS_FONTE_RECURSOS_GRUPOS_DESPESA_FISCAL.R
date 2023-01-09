    # INICIO TABELA 
   
    banco = data.table(read.table(paste(dir_data, "/tabela2/",uo,".txt",sep=""),  
                                  header=F, sep="\t", dec=",", stringsAsFactors = FALSE)) 
 
    nColunas = ncol(banco)-4 
   
    if (nColunas==5){ 
      larguras_demais_colunas = round((2 / (nColunas -4)),0)  # Variáveis Fixas: 4(FONTE, IAG, IPU e TOTAL) 
    } else{ 
      larguras_demais_colunas = round((10 / (nColunas -4)),1) 
    } 
   
    col = paste("|m{",larguras_demais_colunas,"cm}", sep="") # Pirmeira coluna tem 5cm. A soma das demais deve ser 9cm. 
   
    cat("\\scriptsize\n") 
 
    cat(paste0("\\noindent\\begin{longtable}[c]{m{7cm}|m{4.5pt}@{\\hspace{1em}}|m{2.5pt}@{\\hspace{1em}}|",  
              paste(rep(col, ncol(banco)-7), collapse=""),"}\n")) 
   
    titulo = paste0("\\multicolumn{", nColunas, 
                   "}{c}{\\cellcolor{gray!50} {\\normalsize \\textbf{", 
                   "FONTE DE RECURSOS E GRUPOS DE DESPESA - FISCAL}}} \\TBstrut \\\\[2ex] \n") 
   
    subtitulo = paste0("\\multicolumn{",(nColunas-1), 
                      "}{l}{\\textbf{Exercício: ", ANO_DOC,  
                      "}} & \\multicolumn{1}{r}{R\\$1,00} \\\\\n") 
   
    titulo_orgao = paste0("\\multicolumn{", nColunas, "}{l}{\\textbf{ÓRGÃO:} ",banco[2,V1],"} \\\\\n") # V1: nome_orgao 
    titulo_uo = paste0("\\multicolumn{", nColunas, "}{l}{\\textbf{UO:} \\hspace{13pt} ",banco[2, V2],"} \\\\\n") #V2:nome_uo 
   
    cat(titulo) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
   
 
    cabecalho = "" 
    for(i in 1:nColunas){ 
      if(i==1){ 
        cabecalho = paste0(cabecalho,"\\multicolumn{1}{C{7cm}|}{ \\textbf{ ", banco[1,(i+4), with=F], "}} & ") # Nome Fonte 
      }else if(i<4){ 
        cabecalho = paste0(cabecalho,"\\multicolumn{1}{@{\\hspace{1em}}c@{\\hspace{1em}}|}{ \\textbf{ ",  
                           banco[1,(i+4), with=F], "}} & ") # Condição para o cabeçalho de IAG e IPU 
      }else if(i<nColunas){ 
        cabecalho = paste0(cabecalho,"\\multicolumn{1}{C{",larguras_demais_colunas,"cm}|}{ \\textbf{ ",  
                           banco[1,(i+4), with=F], "}} & ") # Condição para as demais colunas variáveis por UO 
      }else{ 
        cabecalho = paste0(cabecalho, "\\multicolumn{1}{C{2cm}}{\\textbf{ ", toupper(banco[1,(i+4), with=F]), "}} \\\\\n") 
        # Condição para a variável Total 
      } 
    } 
   
    cat(cabecalho) 
 
    cat("\\hline\n") 
    cat("\\endfirsthead\n") 
 
    cat(titulo) 
    cat("\\specialrule{1.5pt}{2pt}{0pt}\n") 
    cat(subtitulo) 
    cat(titulo_orgao) 
    cat(titulo_uo) 
    cat("\\specialrule{1pt}{0pt}{0pt}\n") 
    cat(cabecalho) 
   
    cat("\\hline\n") 
    cat("\\endhead\n") 
   
    cat("\\endfoot\n") 
   
    #cat("\\hline\n") 
   
    #cat("\\hline\\hline\n") 
    cat("\\endlastfoot\n") 
   
    for(j in 2:nrow(banco)){  
       
      colocarNegrito=0 
       
      linha = "" 
      if(toupper(banco[j, V5])!="TOTAL"){ # CONDIÇÃO GERAL 1: Para o caso que a Fonte NÃO seja referente ao TOTAL 
        
       # Subcondições: 
        
       colocarNegrito=0 
        
       if(banco[j, V3]!=""){  
         # Para o caso que o valor em FONTE deve mesclar linhas, ou seja, celula_mesclar_linhas é um número 
          
         linha = paste0(linha,"\\multirow{", banco[j, V3] ,"}{*}{\\parbox{7cm}{\\raggedright ", banco[j, V5], "}} & ") 
         # V3 - Número de linhas que fonte deve mesclar. V5: valor da fonte 
          
        } else{ # Para o caso que não é necessário mesclar linhas. Ou seja, o conteudo é "" (Vázio) 
          linha = paste0(linha, banco[j, V5], " & ") 
         
          # Dessa forma garantimos o seguinte padrão: 
          # \\multirow{ #n linhas mescladas }{*}{\\parbox{7cm}{\\raggedright VALOR de FONTE}} & ..." \\ 
          # "Vazio" & ... \\ Esse conteúdo vazio se repete n vezes o que garante que o conteúdo VALOR de FONTE  
          # será mesclado nas n linhas 
        } 
        
        if (banco[j, V4]!="" & toupper(banco[j, V6])!="TOTAL"){  
         
        # Para o caso em que é necessário mesclar as linhas de IAG (V4 é um número) e V6 (IPU) é diferente de Total 
       
          linha = paste0(linha,"\\multicolumn{1}{c|}{\\multirow{",  
                         banco[j, V4],"}{*}{", banco[j, V6], "}} & ", 
                         "\\multicolumn{1}{c|}{", banco[j, V7], "} & ") 
           
        # V4: Número de linhas que o valor de IAG deve mesclar; V6: Valor de IAG; V7: valor de IPU 
           
        } else if(toupper(banco[j, V6])=="TOTAL"){ 
           
           colocarNegrito=1 
           
           linha = paste0(linha,"\\multicolumn{2}{c|}{ \\textbf{ ", banco[j, V6], " }} & ") 
         
          # Caso V6, IPU="Total" devemos mesclar as células de IPU com IAG 
         
        } else{  
          # Trata da condição que V4 (celulas_mesclar_ipu) é vazio. Nesse caso apenas apresentamos V6, IPU e V7 IAG 
          # Abrange o caso em que IPU é vazio, garantindo o padrao que o valor vazio se repita n vezes sendo n o número 
          # de células que IPU deve mesclar. 
         
          linha = paste0(linha,"\\multicolumn{1}{c|}{", banco[j, V6],  
                         "} & ", "\\multicolumn{1}{c|}{", banco[j, V7], "} & ") 
     } 
      } else{ # CONDIÇÃO GERAL 2: Estamos na linha que Fonte é igual a Total 
         
        colocarNegrito=1 
         
        linha = paste0(linha,"\\multicolumn{3}{l|}{ ", aplicaNegrito(toupper(banco[j, V5]), colocarNegrito), "} & ") 
        # Mesclamos as colunas de Fonte, IAG e IPU. V5, fonte é igual a Total 
       
      } 
      # A CONDIÇÃO GERAL 1 e CONDIÇÃO GERAL 2, bem como suas subcondições dizem respeito apenas a parte de Fonte, IAG e IPU 
      # para cada linha da tabela. A parte que diz respeito aos valores inicia abaixo 
      
      for(col in 4:nColunas){ # Para as demais colunas que variam na tabela 
        
        if(col<nColunas){ # Se não for a coluna final (Total) 
          
        linha = paste0(linha,"\\multicolumn{1}{R{", larguras_demais_colunas, "cm}@{\\hspace{1em}}|}{ ",  
                       aplicaNegrito(banco[j,(col+4), with=F], colocarNegrito), "} & ") 
       
        # larguras_demais_colunas varia com o número de colunas variáveis no banco. Essa linha inicia na coluna 8, 
        # que geralmente é a primeira coluna variável. O parâmetro colocarNegrito é determinado nas CONDIÇÕES GERAIS 1 e 2 
        # dependendo se a linha trata do Total. 
       
        } else{ # Para o caso em que estamos na linha do Total 
           
         linha = paste0(linha, "\\multicolumn{1}{C{2cm}}{",  
                        aplicaNegrito(banco[j,(col+4), with=F], colocarNegrito), "} \\\\\n")  
       
        } 
      } 
    
     # Próximo passo é definir qual será o padrão da linha horizontal que corta cada linha da tabela. Em especial, 
     # Essa linha deve respeitar as células mescladas em FOnte e IAG. Como o número de linhas mescladas é variável 
     # então é necessário inserir um padrão de identificação no loop for 
      
    if(toupper(banco[j, V6])!="TOTAL" & toupper(banco[j+1, V6])!="TOTAL" & j<nrow(banco)){ 
     
    # Para o caso em que IPU tanto na linha analisada (j), quanto na LINHA SUBSEQUENTE (j+1) do banco é diferente de Total, e 
    # essa linha j é menor que a última linha do banco [j<nrow(banco) garante que j+1 sempre existe.] 
    # 
    # Essa condição é para duas situações distintas: 1: tanto Fonte quanto IAG estão mescladas e a  
    # linha horizontal deve partir de IPU e 2: Fonte está mesclada mas IAG não mais, ou seja, a linha  
    # horizontal deve partir de IAG 
     
    if(toupper(banco[j, V6])=="" & toupper(banco[j+1, V6])!=""){ 
       
      # Subcondição 2: Fonte está mesclada mas IAG não mais, ou seja, a linha horizontal deve partir de IAG 
      # É necessário destacar um caso especial. Onde a linha j de IAG está vazia mas a próxima linha não. Nesse caso 
      # devemos inserir uma linha horizontal, partindo de IAG 
           
      linha_horizontal = paste("\\cline{2-", nColunas, "}\n", sep="") 
           
        } else{ 
          # Subcondição 1: Tanto Fonte quanto IAG estão mescladas e a linha horizontal deve partir de IPU 
          linha_horizontal = paste("\\cline{3-", nColunas, "}\n", sep="") 
          } 
    # Criar uma linha horizontal que não atravesse Fonte e IAG, ou seja, a linha inicia em IPU e vai até a coluna Total 
     
    } else if (toupper(banco[j, V6])=="TOTAL" & toupper(banco[j+1, V5])!="TOTAL"){ 
     
    # Para o caso em que V6 IAG é igual ao Total e V5 Fonte é diferente de Total 
    # Essa condição caracteriza o momento em que termina a mesclagem de células em Fonte e IAG 
     
    linha_horizontal = paste("\\hline\n", sep="") 
     
  } else if((toupper(banco[j, V6])=="TOTAL" & toupper(banco[j+1, V5])=="TOTAL") || toupper(banco[j, V5])=="TOTAL" ){ 
     
    # Para o caso que V6 IAG é igual a Total e OU a LINHA SUBSEQUENTE (j+1) ou a LINHA ATUAL (j) é igual ao total, aplicar 
    # uma linha horizontal mais espessa. 
    # Essa condição garante que haverá uma linha mais espessa antes e depois da Linha TOTAL na tabela 
     
    linha_horizontal = paste("\\hline \\hline \\hline\n", sep="") 
   
  } else{ 
    # Não satisfazendo nenhuma das condições acima, é o caso que IAG não deve ser mesclado, mas Fonte sim. 
    # ou seja, a linha horizontal não deve passar por FONte mas pode passar por IAG 
     
    linha_horizontal = paste("\\cline{2-", nColunas, "}\n", sep="") 
  } 
    cat(linha)             # imprimir a linha com os valores por UO 
    cat(linha_horizontal)  # imprimir a linha horizontal para formatar a tabela 
   
   } 
  cat("\\end{longtable}\n") 
   
  cat("\\tiny\n") 
  cat("\\begin{tabular}{L{5cm}L{8cm}}\n") 
   
  cat("\\textbf{ IAG - IDENTIFICADOR DE AÇÃO GOVERNAMENTAL} & \\textbf{IPU - IDENTIFICADOR DE PROCEDÊNCIA E USO:} \\\\\n") 
     
  for(j in 1:nrow(rodape)){ 
       
      cat(rodape[j, iag], " & ", rodape[j, ipu],"\\\\\n")    
  } 
   
  cat("\\end{tabular}\n") 
  
   
  # FIM TABELA 
