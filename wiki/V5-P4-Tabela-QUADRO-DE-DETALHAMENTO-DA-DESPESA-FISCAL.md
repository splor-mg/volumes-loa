# Quadro de Detalhamento da Despesa

Agora partimos para o segundo tipo de tabela no volume 5, o QUADRO DE DETALHAMENTO DA DESPESA - FISCAL. O padrão inicial dessa tabela segue a tabela de demonstrativos consolidados da despesa, apresentado na parte 3 dos tutoriais.

## Parâmetros iniciais do arquivo latex e bibliotecas

```
#!latex

\documentclass{article} % inicia o documento do modo article

\input{load_bibliotecas} % carrega todas as bibliotecas e comandos apresentados na parte 3

\begin{document} % inicia o documento
\SweaveOpts{concordance=TRUE} % cria o arquivo concordance

\newgeometry{left=3pt,right=3pt, top=1cm} % redefine as margens das páginas

\setlength{\tabcolsep}{2.5pt} % distância de 2.5pt entre colunas

\renewcommand*{\arraystretch}{1.9} % distância entre linhas
 \scriptsize % tamanho de fonte
 \color{myblack} % cor do texto
 \centering % centralização do conteúdo
```

Em seguida abrimos o chunk do R e definimos os parâmetros básicos do ano do documento ANO_DOC e o diretório dos arquivos. Existe uma divergência entre qual é o diretório raiz para o Rsweave e Rproj. De forma direta o Rsweave entende que o diretório raiz é onde reside o arquivo `.Rnw` a ser compilado, enquanto para o Rproj, é o diretório onde está `LOA.Rproj`. `dir_loa` consegue determinar que o diretório raiz será `C:\Users\m1312932\SEPLAG\LOA` independentemente de como ele esta sendo executado.


```
#!R
<<echo=FALSE, results=tex>>=

dir_loa = gsub("(.+LOA).*", "\\1", getwd())

ANO_DOC = as.numeric(readLines(paste(dir_loa, "/utils/ano.txt", sep=""), warn = F))

dir_data = paste(dir_loa,"/volume5/data", sep="")


banco = read.table(paste(dir_data, "/QUADRO_DETALHAMENTO_DESPESA_porUO.txt", sep=""), header = T, 
                   sep = "\t", quote = NULL,   dec = ",", stringsAsFactors = FALSE)

# Códigos R abaixo
```

`banco` é um dataframe com a mesma estrutura do QUADRO DE DETALHAMENTO DA DESPESA - FISCAL repetido para todas as UO's presentes em `QDD_FISCAL.xlsx`. Ou seja, em `banco`, há o quadro de detalhamento da despesa empilhado para todas as UO's. Cada quadro apresentado segue a ordem do número da UO ordenadas do menor para o maior número. Assim, a ideia é realizar um loop por cada Uo e com base nesse quadro para determinada Uo, imprimir o QUADRO DE DETALHAMENTO DA DESPESA.

## Definição do Sumário

```
#!R
registro_orgao =c()
registro_poder = c()

for(codigo_uo in unique(banco$COD_UO)){

  uo = banco[banco$COD_UO==codigo_uo,] # realizar recorte em loop
                          .
                          .
                          .

```

Iniciamos dois vetores. A base `uo` é um recorte de banco, que contém dados para apenas uma UO. Ao realizar o `for codigo_uo in unique(banco$COD_UO)` garantimos que `codigo_uo` assumirá cada um dos possíveis valores de `banco$COD_UO`, na ordem em que aparecem, ou seja, em ordem crescente.

```
#!R
if((uo$poder[1] %in% registro_poder)==FALSE){
  cat("\\addcontentsline{toc}{section}{\\underline{",uo$poder[1] ,"}}\n")  
}

registro_poder = append(registro_poder, uo$poder[1])
 
if((uo$COD_ORGAO[1] %in% registro_orgao)==FALSE){
 
 cat("\\addcontentsline{toc}{section}{",
     paste(substr(uo$COD_ORGAO[1],1,1), ".", 
           substr(uo$COD_ORGAO[1],2,3), ".",
           substr(uo$COD_ORGAO[1],4,4), " - ",
           uo$ORGAO[1], sep=""),
      "}\n")

 }
 
 registro_orgao = append(registro_orgao, uo$COD_ORGAO[1])
 
 cat("\\addcontentsline{toc}{subsection}{",
        paste(substr(uo$COD_UO[1],1,1), ".", 
              substr(uo$COD_UO[1],2,3), ".", 
              substr(uo$COD_UO[1],4,4), " - ", 
              uo$UO[1], sep=""),
      "} \n")

```

No sumário é necessário apresentar PODER LEGISLATIVO, por exemplo, apenas uma vez, de maneira sublinhado. Ainda, é necessário apresentar o nome do órgão também apenas uma vez no sumário. A forma encontrada para satisfazer essas condições são apresentadas nas fórmulas acima. Se o primeiro registro da variável PODER não está em `registro_poder`, ou seja,  `if((uo$poder[1] %in% registro_poder)==FALSE)` então significa que Poder ainda não foi inserido no sumário. Assim, inserimos o Poder no sumário utilizando `cat("\\addcontentsline{toc}{section}{\\underline{",uo$poder[1] ,"}}\n")`, e logo em seguida, inserimos o valor de PODER no array para que não seja necessário considerá-lo novamente (`registro_poder = append(registro_poder, uo$poder[1])`). A mesma estratégia é implementada para o nome do órgão no sumário. Por fim, `cat("\\addcontentsline{toc}{subsection}{...` adiciona o nome da UO no sumário como uma subseção. Apenas PODER e ORGAO entram como seções no sumário.

## Inicio de longtable com as definições das colunas

Em seguida iniciamos o objeto longtable com todas as colunas necessárias:

```
#!R
cat("\\noindent\\begin{longtable}[c]{",
    "m{5.5cm}|",      # Coluna para ESPECIFICAÇÃO 
    "m{1pt}",         # Coluna para FUN
    "m{1pt}",         # Coluna para SUBF
    "m{1pt}",         # Coluna para PRG
    "m{1pt}",         # Coluna para ID
    "m{1pt}",         # Coluna para P/A
    "m{1pt}|",        # Coluna para C/A
    "m{1pt}",         # Coluna para C
    "m{1pt}",         # Coluna para GD
    "m{0.5pt}",       # Coluna para M
    "m{1pt}|",        # Coluna para ED
    "m{1pt}|",        # Coluna para IAG
    "m{1pt}",         # Coluna para F/
    "m{1pt}|",        # Coluna para IPU
    "m{1pt}|",        # Coluna para DETALHADA
    "m{2pt}",         # Coluna para TOTAL
    "}\n")
```

Uma tabela não possui identação (`\\noident`) centralizada (`\\begin{longtable}[c]`) com 16 colunas, todas com conteúdo alinhado verticalmente no meio (`m{VALOR}`). Essas colunas seguem a ordem da tabela, ou seja, a primeira coluna (`m{5.5cm}`) representa ESPECIFICAÇÃO e assim por diante (a ordem é FUNÇÃO, SUBFUNÇÃO, PROGRAMA, IDENTIFICADOR DA AÇÃO, PROJETO ATIVIDADE, SUBPROJETO, CATEGORIA, GRUPO DE DESPESA, MODALIDADE, ELEMENTO DESPESA, IAG, FONTE, IPU, VALOR DETALHADO e TOTAL). Cada largura reflete o espaço que essas informações tem na tabela.


## Variáveis do cabeçalho

```
#!R
titulo = "\\multicolumn{16}{c}{\\cellcolor{gray!50} \\textcolor{vermelhoTitulo} {\\footnotesize \\textbf{QUADRO DE DETALHAMENTO DA DESPESA - FISCAL}}}\\TBstrut  \\\\[2ex]\n"
   
 subtitulo = paste("\\multicolumn{15}{l}{\\textbf{Exercício:} \\textcolor{vermelhoTitulo}{", uo$ANO[1] ,"}} & \\multicolumn{1}{r}{ R\\$1,00} \\\\\n")
 
 titulo_orgao = paste("\\multicolumn{16}{L{15cm}}{\\textbf{ÓRGÃO:}", 
                      paste(substr(uo$COD_ORGAO[1],1,1), ".", 
                            substr(uo$COD_ORGAO[1],2,3), ".",  
                            substr(uo$COD_ORGAO[1],4,4), " - ", 
                            uo$ORGAO[1], sep=""), 
                      "} \\\\\n")
 
 titulo_uo = paste("\\multicolumn{16}{L{15cm}}{\\textbf{UO:} \\hspace{13pt} ", 
                   paste(substr(uo$COD_UO[1],1,1), ".",
                         substr(uo$COD_UO[1],2,3), ".",
                         substr(uo$COD_UO[1],4,4), " - ", 
                         uo$UO[1], sep=""), 
                    "} \\\\\n")


```

Definimos em seguida algumas variáveis. Titulo e subtitulo, seguem um padrão semelhante ao realizado na Parte 3 deste tutorial. `Titulo_orgao` e `titulo_uo` possuem padrões diferentes. `substr(valor, inicio, termino)` corta um valor segundo o número de caracteres. Ao cortar o código UO, conseguimos sair do padrão 1011 para 1.01.1. Posteriormente, aplicamos a função concatenar (`paste`) dos três pedaços de `COD_UO` com pontos (.). No final, conseguimos o padrão *1.01.1 - ASSEMBLEIA LEGISLATIVA DO ESTADO DE MINAS GERAIS - ALEMG* na tabela. Esse padrão também é aplicado para o caso de órgão.


```
#!R

cabecalho1 = paste("\\multirow{2}{3pt}{ESPECIFICAÇÃO} & ",
                   "\\multicolumn{13}{|c|}{CLASSIFICAÇÃO ORÇAMENTÁRIA} & ",
                    "\\multicolumn{2}{c}{IMPORTÂNCIA} \\\\\n")
 
 cabecalho2 = paste("& \\multicolumn{1}{|c}{\\fonteSeis FUN} & ", 
                    "\\multicolumn{1}{c}{\\fonteSeis SUBF} & ",
                    "\\multicolumn{1}{c}{\\fonteSeis PRG} & ",
                    "\\multicolumn{1}{c}{\\fonteSeis ID} & ",
                    "\\multicolumn{1}{c}{\\fonteSeis P/A} & ",
                    "\\multicolumn{1}{c|}{\\fonteSeis C/A} & ",
                    "\\multicolumn{1}{c}{\\fonteSeis C} & ",
                    "\\multicolumn{1}{c}{\\fonteSeis GD} & ",
                    "\\multicolumn{1}{c}{\\fonteSeis M} & ",
                    "\\multicolumn{1}{c|}{\\fonteSeis ED} & ",
                    "\\multicolumn{1}{c|}{\\fonteSeis IAG} & ",
                    "\\multicolumn{1}{c}{\\fonteSeis F/} & ",
                    "\\multicolumn{1}{c|}{\\fonteSeis IPU} & ",
                    "\\multicolumn{1}{c|}{\\fonteSeis DETALHADA} & ",
                    "\\multicolumn{1}{c}{\\fonteSeis TOTAL} ",
                    "\\\\\n")
```

Sobre o cabeçalho da tabela, este é formado por duas linhas. A palavra ESPECIFICAÇÃO mescla essas duas linhas, por isso utilizamos `\\multirow{2}{3pt}{ESPECIFICAÇÃO}` na primeira linha (`cabecalho1`), e deixamos o valor em branco para a primeira coluna na segunda linha (`cabecalho2`). Classificação Orçamentária só está na primeira linha, mas mescla 13 colunas de FUN a IPU, (`\\multicolumn{13}{|c|}{CLASSIFICAÇÃO ORÇAMENTÁRIA}`) e IMPORTÂNCIA também na primeira linha, mescla detalhada e total, ou seja, `\\multicolumn{2}{c}{IMPORTÂNCIA}`.

Em `cabecalho2`, a primeira coluna está em branco, dado que ESPECIFICAÇÃO mescla as duas linhas. As demais 15 colunas, estão preenchidas com os nomes dos campos, a saber *FUN, SUBF, ID, P/A, C/A, C, GD, M, ED, IAG, F/, IPU, DETALHADA e TOTAL*. Ao aplicar `\\fonteSeis` aplicamos a fonte de 6px nesses textos do cabeçalho.


## Imprimir no arquivo latex os 2 cabeçalhos e os 2 rodapés

```
#!R
  # Primeiro cabeçalho

  cat(titulo)
  cat("\\specialrule{1.5pt}{2pt}{0pt}\n")
  cat(subtitulo)
  cat(titulo_orgao)
  cat(titulo_uo)
  cat("\\specialrule{1pt}{0pt}{0pt}\n")
  cat(cabecalho1)
  cat("\\cline{2-16}\n") # cria uma linha vertical que vai da coluna 2 até a 16
  cat(cabecalho2)
  cat("\\hline\n")
  cat("\\endfirsthead\n")
 
  # n cabeçalhos posteriores

  cat(titulo)
  cat("\\specialrule{1.5pt}{2pt}{0pt}\n")
  cat(subtitulo)
  cat(titulo_orgao)
  cat(titulo_uo)
  cat("\\specialrule{1pt}{0pt}{0pt}\n")
  cat(cabecalho1)
  cat("\\cline{2-16}\n")
  cat(cabecalho2)
  cat("\\hline\n")
  cat("\\endhead\n")

  # Espaço para o primeiro rodapé (deixado em branco)
  
  cat("\\endfoot\n")

  # Espaço para os n rodapés posteriores (deixado em branco)

  cat("\\hline\n")
  cat("\\hline\\hline\n")
  cat("\\endlastfoot\n")
```

## Imprimir as Linhas da Tabela

Logo em seguida aplicamos o método `cat(...)` para imprimir essas variáveis texto geradas no documento `.tex` gerado. O código acima segue o mesmo padrão apresentado [V5 - P3 - Tabela demonstrativo consolidado da despesa](V5-P3-Tabela-demonstrativo-consolidado-da-despesa.md), ou seja, são definidos os padrões para dois cabeçalhos e dois rodapés de longtable.

O próximo passo é imprimir cada linha do banco `uo` como um linha da tabela. Essa tabela apresenta três possibilidades de registro:

**Caso 1**: Linha referente a função, subfunção até o programa, com descritivo para Especificação (nome da ação);
**Caso 2**: Linha referente a categoria até IPU, sem descritivo para Especificação (nome da ação);
**Caso 3**: Linha Total


```
#!R

for(i in 1:nrow(uo)){ # Para a linha i que vai da primeira até a última linha do banco uo

   if(uo$NOME_ACAO[i]!="Total" & uo$NOME_ACAO[i]!=""){ # Se a linha i satisfazer a CASO 1, faça:

     cat("\\multicolumn{1}{L{5.5cm}|}{",uo$NOME_ACAO[i],
         "} & \\multicolumn{1}{c}{", formatC(uo$FUNCAO[i], width = 2, flag = "0"),
         "} & \\multicolumn{1}{c}{", formatC(uo$SUB_FUNCAO[i], width = 3, flag = "0"), 
         "} & \\multicolumn{1}{c}{", uo$PROGRAMA[i],
         "} & \\multicolumn{1}{l}{", uo$IDENT_PROJATIV[i],
         "} & \\multicolumn{1}{c}{", formatC(uo$PROJ_ATIV[i], width = 3, flag = "0"),
         "} & \\multicolumn{1}{l|}{", formatC(uo$SUB_PROJETO[i], width = 4, flag = "0"), 
         "} & & & & & & & & & \\multicolumn{1}{r}{", uo$valor_final[i], "} \\\\\n")
   
  }
   if(uo$NOME_ACAO[i]!="Total" & uo$NOME_ACAO[i]==""){ # Se a linha i satisfazer o CASO 2, faça:


     cat("& & & & & & & \\multicolumn{1}{c}{", uo$CATEGORIA[i], 
         "} & \\multicolumn{1}{c}{",  uo$GRUPO_DESPESA[i],
         "} & \\multicolumn{1}{c}{",  uo$MODALIDADE[i], 
         "} & \\multicolumn{1}{c|}{", formatC(uo$ELEMENTO_DESPESA[i], width = 2, flag = "0"), 
         "} & \\multicolumn{1}{c|}{", uo$IAG[i],
         "} & \\multicolumn{1}{l}{",  uo$FONTE[i],
         "} & \\multicolumn{1}{c|}{", uo$IPU[i], 
         "} & \\multicolumn{1}{r|}{", uo$valor_final[i], "} & \\\\\n")
   }
   if(uo$NOME_ACAO[i]=="Total"){ # Se a linha i satisfazer o CASO 3, faça:

     cat("\\hline\n")
     cat("\\multicolumn{15}{C{6cm}|}{\\textbf{",toupper(uo$NOME_ACAO[i]),
         "}} & \\multicolumn{1}{r}{\\textbf{", uo$valor_final[i], "}} \\\\\n")

   }
 }

```

O caso 1 possui valores para ESPECIFICAÇÃO, FUN, SUBF, PRG, ID, P/A, C/A e TOTAL. As demais colunas são consideradas vazias, **no próprio código**. O problema dessa implementação é que, caso seja desejável preencher uma nova coluna vazia com algum valor, não basta inserir esse valor no banco de dados. Será necessário alterar o código acima, inserindo as variável de referência. Por exemplo, suponhamos que agora, para essa linha seja desejável insirir o código da categoria. Assim, devemos alterar o código acima da forma:

```
          ... Código do caso 1

         "} & \\multicolumn{1}{l}{", uo$IDENT_PROJATIV[i],
         "} & \\multicolumn{1}{c}{", formatC(uo$PROJ_ATIV[i], width = 3, flag = "0"),
         "} & \\multicolumn{1}{l|}{", formatC(uo$SUB_PROJETO[i], width = 4, flag = "0"), 
         "} & \\multicolumn{1}{c}{", uo$CATEGORIA[i],
         } & & & & & & & & \\multicolumn ... "

          ...
```

Ou seja, alteramos o código para o latex imprimir para essa linha os dados do código da categoria.

O CASO 2 possui valores para C, GD, M, ED, IAG, F/, IPU e DETALHADA. Todas as demais colunas são consideradas vazias, sendo que essa condição também está presente diretamente no código. Caso alguma dessas colunas precise apresentar valor, precisamos alterar no código dessa tabela e no script `LOA\volume5\R\volume5.R`.

O CASO 3 apresenta a linha do TOTAL, que mescla as 15 primeiras colunas com o nome TOTAL e apresenta o valor total na coluna TOTAL.


```
#!R

cat("\\end{longtable}\n") # Fechar a longtable
cat("\\newpage\n") # quebra página
cat("\\phantomsection\n") # hyper marker na próxima página para o sumário pular para a tabela correta.
}

# FIM TABELA # Tag importante para montar o projeto_volume5.Rnw

@  # Fecha o chunk R
```

Como `\begin{longtable}` e `\end{longtable}` está dentro do `for` (loop), geramos uma tabela longa para cada UO. 
E por fim, encerramos o documento.


```
#!Latex


\end{document}
```
