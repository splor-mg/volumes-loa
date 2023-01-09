# Uma Tabela Simples no Latex utilizando Objetos do R

O R é um software de programação em estatística, que possui inúmeros recursos no tratamento, organização, extração e visualização dos mais diversos tipos de bancos de dados. Nessa perspectiva que a utilização do Rsweave é interessante: ele combina a flexibilidade na criação de documentos customizados proveniente do Latex, com a interatividade e facilidade na manipulação de bancos de dados a partir do R. No presente exemplo, mostraremos como utilizar comandos do R dentro do latex.

O interesse agora é montar a tabela FONTES DE RECURSOS do volume 5. Essa tabela possui 61 linhas diferentes, apresentando o código e descrição de cada fonte. Escrever cada linha no código latex é uma possibilidade, porém muito demorada e de difícil manutenção. O interesse é **criar um banco de dados externo que possua o código e descrição de cada fonte, extrair esse banco dentro do R e automaticamente inserir cada linha desse arquivo na tabela construída**. Inicialmente somos capazes de gerar a seguinte estrutura:


```
#!Latex

\documentclass{article}
\usepackage{longtable} % carrega o recurso de longtable
\usepackage[utf8]{inputenc} % para manter os caracteres especiais e encoding
\usepackage{array} % possibilita alguns recursos da tabela como o parâmetro m{cm}
\usepackage[table]{xcolor} % possibilita mudar a cor das células

\newcommand\Tstrut{\rule{0pt}{2em}}       % pading top para o titulo
\newcommand\Bstrut{\rule[-0.9ex]{0pt}{0pt}} % padding bottom para o titulo
\newcommand{\TBstrut}{\Tstrut\Bstrut} % Combina os dois comandos acima

\begin{document} % Tag que marca o inicio do documento
% Códigos do relatórios
\begin{longtable}[c]{m{1cm}|m{11cm}} % tag de inicio da tabela longa, centralizada na página, com duas colunas com conteúdo centralizado verticalmente no meio, a primeira coluna com 1cm de largura e a segunda com 11cm, e uma barra vertical separando as duas colunas

\multicolumn{2}{c}{\cellcolor{gray!50} \textcolor{red} {\normalsize \textbf{FONTE DE RECURSOS}}}\Tstrut  \\[2ex] % Título da tabela, realiza-se uma mesclagem das duas colunas, preenchimento cinza e cor de fonte vermelha com tamanho normalsize

\hline\hline % linha horizontal serarando o título do cabeçalho
 
 \multicolumn{1}{c|}{\textbf{ COD }} & \multicolumn{1}{c}{\textbf{ ESPECIFICAÇÃO }} \\ % cabeçalho com os nomes das colunas da tabela. Os nomes são em negrito

\hline % linha horizontal

\endfirsthead % indica o fim do primeiro cabeçalho e início do próximo

% Código do cabeçalho para as n páginas da tabela, sendo n difente de 1

 \endhead % indica o fim dos cabeçalhos e início do primeiro rodapé

% Código do primeiro rodapé

 \endfoot % indica o fim do primeiro rodapé do rodapé para as n páginas

 \hline\hline\hline % coloquei simplesmente uma linha mais espessa para fechar o documento

 \endlastfoot % indica o fim dos rodapés

% INSERIR CONTEÚDO DA TABELA. Linhas com o código númerico da fonte e sua respectiva descrição.


\end{longtable}
\end{document}
```


Na parte referente a **%% INSERIR CONTEÚDO DA TABELA** é o momento de inserir as 61 linhas referente a cada fonte de recursos. Vamos inserir essas 61 linhas de forma automatizada. Para indicar para o RSweave que os códigos digitados a seguir devem ser entendidos como códigos do R, nós precisamos abrir uma *chunk*. Para abrir a chunk é necessário a seguinte sintaxe:


```
#!R
<<>>=

# Inserir Códigos do R

@

```

### Muito Importante

O Rsweave é muito sensível no padrão de caracteres para abrir o chunk. Os caracteres para abrir o chunk são `<<>>=` e para fechar `@`. **Não pode existir nenhum espaço antecedendo esses caracteres**. Qualquer coisa do tipo:

```
#!R
 <<>>=
# Inserir Códigos do R
@

```
ou

```
#!R
<<>>=
# Inserir Códigos do R
 @

```

**Não funcionará!**

Continuando, ao abrir um chunk há uma série de opções que podemos definir. Geralmente, as opções estabelecidas nos relatórios gerados são:

`results=tex`: para considerar os resultados apresentados pelo R como texto em formato latex;
`echo=FALSE`: para não mostrar os comandos R no documento gerado. Se `echo=TRUE`, o documento primeiro apresentará todos os códigos em R e depois seus resultados em latex.

Mais opções para o chunk podem ser encontrados [aqui](http://gosset.wharton.upenn.edu/teaching/471/EPFL-Sweave-powerdot.pdf) e [aqui](http://rmarkdown.rstudio.com/authoring_rcodechunks.html)

O banco que contém as fontes e seus respectivos códigos está em ANEXO_FONTES_RECURSOS.txt. Assim:

```
#!R
<<results=tex, echo=FALSE>>=
require(data.table); require(readxl) # Importa bibliotecas R necessárias

dir_bancos = "C:/Users/m1312932/SEPLAG/LOA/bancos/manual" # diretório em que está o arquivo

fontes = data.table(read_excel(paste0(dir_bancos, "/desc_fontes_de_recursos.xlsx")))[order(CODIGO)]

# data.table(...) = Resultado obtido por read_excel(...) deve ser considerado um data.table
# read_excel(...) = função para abrir arquivos excel. Demanda como argumento o caminho do banco
# paste0(...) = concatena duas strings. Nesse caso concatenamos o caminho para o arquivo com as descrições das fontes
# [order(CODIGO)] = ordena o resultado final de maneira crescente em relação ao código da fonte

@

```

Uma vez aberto o banco e o nomeando no R como anexo, o que queremos agora é ler cada linha desse banco e indicar o que é o código da fonte e sua descrição. Se digitarmos no R o seguinte código:

```
#!R
require(data.table); require(readxl) # Importa bibliotecas R necessárias

dir_bancos = "C:/Users/m1312932/SEPLAG/LOA/bancos/manual" # diretório em que está o arquivo

fontes = data.table(read_excel(paste0(dir_bancos, "/desc_fontes_de_recursos.xlsx")))[order(CODIGO)]

# Linhas da tabela

  for(i in 1:nrow(fontes)){
    cat("\\multicolumn{1}{c|}{",fontes[i, CODIGO], "} &", toupper(fontes[i, CLASSIFICACAO]), "\\\\\n")
  }

```

O resultado desse código R, é imprimir cada linha do banco anexo. Devemos ter cuidado de ordenar corretamente as linhas ao realizar esse procedimento, o que foi realizado pelo comando acima `...[order(CODIGO)]`.


```
#!R

\multicolumn{1}{c|}{ 10 } & toupper( RECURSOS ORDINÁRIOS ) \\
\multicolumn{1}{c|}{ 12 } & toupper( OPERAÇÕES DE CRÉDITO CONTRATUAIS - SWAP ) \\
\multicolumn{1}{c|}{ 20 } & toupper( RECURSOS CONSTITUCIONALMENTE VINCULADOS AOS MUNICÍPIOS ) \\
\multicolumn{1}{c|}{ 21 } & toupper( COTA ESTADUAL DO SALÁRIO EDUCAÇÃO – QESE ) \\
\multicolumn{1}{c|}{ 22 } & toupper( RECURSOS DO SISTEMA ÚNICO DE SAÚDE – SUS ) \\
\multicolumn{1}{c|}{ 23 } & toupper( FUNDO DE MANUTENÇÃO E DESENVOLVIMENTO DA EDUCAÇÃO BÁSICA - FUNDEB ) \\
\multicolumn{1}{c|}{ 24 } & toupper( CONVÊNIOS COM A UNIÃO E SUAS ENTIDADES ) \\
\multicolumn{1}{c|}{ 25 } & toupper( OPERAÇÕES DE CRÉDITO CONTRATUAIS ) \\
\multicolumn{1}{c|}{ 26 } & toupper( TAXA FLORESTAL ) \\
\multicolumn{1}{c|}{ 27 } & toupper( TAXA DE SEGURANÇA PÚBLICA ) \\
\multicolumn{1}{c|}{ 28 } & toupper( TAXA DE FISCALIZAÇÃO JUDICIÁRIA ) \\
						.
						.
						.

```

O que é exatamente a sintaxe utilizada pelo Latex na inserção de cada linha em uma tabela. Como no início do chunk `results=tex`, esse resultado é entendido como latex e alimenta a tabela. Detalhando os comandos acima, temos que:

```
#!R

for(i in 1:nrow(fontes)){ # para cada linha i em que i varia de 1 até o máximo de linhas do banco anexo
    
    cat("\\multicolumn{1}{c|}{",fontes[i, CODIGO], "} &", toupper(fontes[i, CLASSIFICACAO]), "\\\\\n")

    # Imprima na tela cada linha que realiza a concatenação entre "\\multicolumn{1}{c|}{,fontes[i, CODIGO]" e  "} &, toupper(fontes[i, CLASSIFICACAO]) \\\\\n". Como \ é um caracter especial precisa vir antecedido de \. \n indica quebra de linha
  
  }


```


Tudo junto fica:

```
#!Latex

\documentclass{article}
\usepackage{longtable} % carrega o recurso de longtable
\usepackage[utf8]{inputenc} % para manter os caracteres especiais
\usepackage{array} % possibilita alguns recursos da tabela como o parâmetro m{cm}
\usepackage[table]{xcolor} % possibilita mudar a cor das células

\newcommand\Tstrut{\rule{0pt}{2em}}       % pading top para o titulo. Será abordado em outro tutorial
\newcommand\Bstrut{\rule[-0.9ex]{0pt}{0pt}} % padding bottom para o titulo. Será abordado em outro tutorial
\newcommand{\TBstrut}{\Tstrut\Bstrut} % Será abordado em outro tutorial

\begin{document} % ínicio do documento
% Códigos do relatórios
\begin{longtable}[c]{m{1cm}|m{11cm}} % ínicio da tabela longa, centralizada na página, com duas colunas com conteúdo centralizado verticalmente no meio, a primeira coluna com 1cm de largura e a segunda com 11cm, e uma barra vertical separando as duas colunas

\multicolumn{2}{c}{\cellcolor{gray!50} \textcolor{red} {\normalsize \textbf{FONTE DE RECURSOS}}}\Tstrut  \\[2ex] % Título da tabela

\hline\hline % linha serarando o título do cabeçalho
 \multicolumn{1}{c|}{\textbf{ COD }} & \multicolumn{1}{c}{\textbf{ ESPECIFICAÇÃO }} \\ % cabeçalho da tabela
\hline
\endfirsthead % indica o fim do primeiro cabeçalho e início do próximo

% Código do cabeçalho para as n páginas da tabela, sendo n difente de 1

 \endhead % indica o fim dos cabeçalhos e início do primeiro rodapé

% Código do primeiro rodapé

 \endfoot % indica o fim do primeiro rodapé do rodapé para as n páginas

 \hline\hline\hline % coloquei simplesmente uma linha mais espessa para fechar o documento

 \endlastfoot % indica o fim dos rodapés
% Conteúdo da tabela fica aqui

<<results=tex, echo=FALSE>>=
require(data.table); require(readxl) # Importa bibliotecas R necessárias

dir_bancos = "C:/Users/m1312932/SEPLAG/LOA/bancos/manual" # diretório em que está o arquivo

fontes = data.table(read_excel(paste0(dir_bancos, "/desc_fontes_de_recursos.xlsx")))[order(CODIGO)]

  # Linhas da tabela

  for(i in 1:nrow(fontes)){
    cat("\\multicolumn{1}{c|}{",fontes[i, CODIGO], "} &", toupper(fontes[i, CLASSIFICACAO]), "\\\\\n")
  }


@

\end{longtable}
\end{document}
```


##Tabela inteira dentro do Chunk##

Outra abordagem, muito utilizada no desenvolvimentos dos relatórios é, **trazer toda a tabela para dentro do chunk** e não apenas a parte referente as linhas. Para realizar isso, utilizar o recurso de imprimir do R (comando cat()), tomando as precauções de dobrar os caracteres \ e indicar quebra de linha pelo parâmetro \n. Dessa forma fica:


```
#!Latex

\documentclass{article}
\usepackage{longtable} % carrega o recurso de longtable
\usepackage[utf8]{inputenc} % para manter os caracteres especiais
\usepackage{array} % possibilita alguns recursos da tabela como o parâmetro m{cm}
\usepackage[table]{xcolor} % possibilita mudar a cor das células

\newcommand\Tstrut{\rule{0pt}{2em}}       % pading top para o titulo. Será abordado em outro tutorial
\newcommand\Bstrut{\rule[-0.9ex]{0pt}{0pt}} % padding bottom para o titulo. Será abordado em outro tutorial
\newcommand{\TBstrut}{\Tstrut\Bstrut} % Será abordado em outro tutorial

\begin{document} % ínicio do documento


%% CHUNK ABERTO ANTES DA DEFINIÇÃO DA TABELA

<<results=tex, echo=FALSE>>=

cat("\\begin{longtable}[c]{m{1cm}|m{11cm}}\n") # Inicia-se a tabela
# Titulo

titulo= "\\multicolumn{2}{c}{\\cellcolor{gray!50} \\textcolor{red} {\\normalsize \\textbf{FONTES DE RECURSOS}}}\\Tstrut  \\\\[2ex]\n" # variável titulo com o conteúdo do título

cat(titulo)
cat("\\hline\\hline\n")

# Cabeçalho de variáveis
cabecalho = "\\multicolumn{1}{c|}{\\textbf{COD}} & \\multicolumn{1}{c}{\\textbf{ESPECIFICAÇÃO}} \\\\\n" # variável cabecalho com o conteúdo do cabeçalho

cat(cabecalho)
cat("\\hline\n")
cat("\\endfirsthead\n") # Indica o fim do primeiro header da tabela (presente no ínicio da tabela)
 
# titulo
cat(titulo)
cat("\\hline\\hline\n")
# Cabeçalho de variáveis
cat(cabecalho)
cat("\\hline\n")
cat("\\endhead\n") # Fim do header que acompanha as n páginas que a tabela ocupa, sendo n diferente de 1
cat("\\endfoot\n") # Fim do notapé do ínicio da tabela

cat("\\hline\\hline\\hline\n")
cat("\\endlastfoot\n") # Fim do notapé das n páginas que a tabela ocupa, sendo n diferente de 1

require(data.table); require(readxl) # Importa bibliotecas R necessárias

dir_bancos = "C:/Users/m1312932/SEPLAG/LOA/bancos/manual" # diretório em que está o arquivo

fontes = data.table(read_excel(paste0(dir_bancos, "/desc_fontes_de_recursos.xlsx")))[order(CODIGO)]

  # Linhas da tabela

  for(i in 1:nrow(fontes)){
    cat("\\multicolumn{1}{c|}{",fontes[i, CODIGO], "} &", toupper(fontes[i, CLASSIFICACAO]), "\\\\\n")
  }


cat("\\end{longtable}\n") # Fim da tabela

@

\end{document}
```

O arquivo `\LOA\volume5\Rnw\ANEXOS.Rnw` que compõe o arquivo final do volume 5 é construído dessa maneira.

