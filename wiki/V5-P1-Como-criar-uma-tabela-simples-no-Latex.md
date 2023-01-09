# Como criar uma tabela simples no Latex

Os volumes da LOA são caracterizados por vários layouts diferentes de tabelas. Esse tutorial, parte inicial dos tutoriais referentes ao volume 5 apresenta uma forma simples de gerar uma tabela via latex. O código gerado abaixo deve ser compilado no Rsweave (RStudio: File > New File > R Sweave). Ao salvar o código no R clicar em File, *Save with Encoding* e escolher UTF-8. Em próximos passos, apresentarei a mesma tabela desenvolvida no ambiente R.

## Considerações Iniciais

Um documento latex sempre estará entre as seguintes tags:

```
#!Latex

\documentclass{article}

\begin{document}

% Códigos do relatórios

\end{document}
```

Para montar essa tabela, preciso importar uma biblioteca chamada `longtable`, que é um tipo especial de tabela. Isso é feito pelo comando `\usepackage{longtable}` antes de `\begin{document}`.

```
#!Latex

\documentclass{article}
\usepackage{longtable}

\begin{document}
% Códigos do relatórios

\end{document}
```

## Especificação das características da tabela

Agora adicionamos uma nova tag, referente ao longtable, que inicia com `\begin{longtable}[c]{m{1cm}|m{11cm}}` e termina com a tag `\end{longtable}`. Ao iniciar essa tag, especificamos basicamente 3 coisas: o número de colunas, o alinhamento de cada coluna, e se desejamos que haja barras (margens) que dividem as colunas. Uma opção tradicional em textos dessa natureza é: colunas de texto, alinhe à esquerda; colunas com números, à direita.

Vamos criar a tabela de IDENTIFICADORES DE AÇÃO GOVERNAMENTAL, com duas colunas: o código do IAG e a Descrição. O código deve ser alinhado verticalmente centralizado (**m**{1cm}) e ter uma largura de 1cm (m**{1cm}**). A descrição deve ser alinhado verticalmente centralizado (**m**{11cm}) e ter uma largura de 11cm (m**{11cm}**). Ainda, essa tabela longa (*longtable*) precisa estar centralizada na página (**[c]**). O parâmetro m está contido na biblioteca `array` e deve ser chamado a partir de `\usepackage{array}`. O simbolo `%` indica que a frase a seguir é um comentário, que não compila com o código. Assim, o código fica:

```
#!Latex

\documentclass{article}
\usepackage{longtable}

\begin{document}
% Códigos do relatórios
\begin{longtable}[c]{m{1cm}|m{11cm}}

% Conteúdo da tabela fica aqui

\end{longtable}
\end{document}
```

## Definição do Cabeçalho


Dentro da tag `longtable`, a primeira coisa que devemos definir é como será o cabeçalho e o rodapé da tabela. Inicialmente queremos, na primeira linha: 

1- Mescle as duas colunas: `\multicolumn{2}{c}{... }`
2- Realize um preenchimento dessa célula mesclada com a cor cinza: `\cellcolor{gray!50}`
3- O título deve ser preenchido com a cor vermelha `\textcolor{red}{... }`
4- Linha cabeçalho deve ter uma altura maior que uma linha convencional ` ao final da linha [2ex] `


O Título da tabela é IDENTIFICADORES DE AÇÃO GOVERNAMENTAL. Tudo junto no código fica:

```
#!Latex

\documentclass{article}
\usepackage{longtable}
\usepackage{array}
\usepackage[table]{xcolor} % necessário para chamar \cellcolor

\newcommand\Tstrut{\rule{0pt}{2em}}       % pading top para o titulo. 
\newcommand\Bstrut{\rule[-0.9ex]{0pt}{0pt}} % padding bottom para o titulo.
\newcommand{\TBstrut}{\Tstrut\Bstrut} % Será abordado em outro tutorial

\begin{document}
% Códigos do relatórios
\begin{longtable}[c]{m{1cm}|m{11cm}}

\multicolumn{2}{c}{\cellcolor{gray!50} \textcolor{red} {\normalsize \textbf{IDENTIFICADORES DE AÇÃO GOVERNAMENTAL}}}\Tstrut  \\[2ex]

% \Tstrut garante o alinhamento centralizado verticalmente do conteúdo

% Conteúdo da tabela fica aqui

\end{longtable}
\end{document}
```

Ainda no cabeçalho, logo após o título queremos **uma linha horizontal mais espessa para separar o título do nome das variáveis na tabela. Logo em seguida, apresentar os nomes das variáveis da tabela e uma linha horizontal para separar esses nomes dos valores da tabela a seguir**. O comando `\hline`, gera uma linha horizontal. Repeti-lo a torna mais espessa. Para preencher as colunas na tabela o simbolo "&" indica que a informação a seguir pertence a uma nova coluna e "\\" indica nova linha na coluna. Assim o código fica:

```
#!Latex

\documentclass{article}
\usepackage{longtable}
\usepackage{array}
\usepackage[table]{xcolor}

\newcommand\Tstrut{\rule{0pt}{2em}}       % pading top para o titulo.
\newcommand\Bstrut{\rule[-0.9ex]{0pt}{0pt}} % padding bottom para o titulo.
\newcommand{\TBstrut}{\Tstrut\Bstrut} % Será abordado em outro tutorial

\begin{document}
% Códigos do relatórios
\begin{longtable}[c]{m{1cm}|m{11cm}}

\multicolumn{2}{c}{\cellcolor{gray!50} \textcolor{red} {\normalsize \textbf{IDENTIFICADORES DE AÇÃO GOVERNAMENTAL}}}\Tstrut  \\[2ex]

\hline\hline
 \multicolumn{1}{c|}{\textbf{ COD }} & \multicolumn{1}{c}{\textbf{ ESPECIFICAÇÃO }} \\ % nomes das colunas
\hline

% Conteúdo da tabela fica aqui

\end{longtable}
\end{document}
```

Ao trazer `\multicolumn` novamente ao código, conseguimos centralizar horizontalmente o conteúdo da célula.
A indicação `{c|}` diz que deve ter uma barra vertical logo após o nome "COD" na tabela

A tag longtable pode possuir 2 tipos de cabeçalho e notapé diferentes: o primeiro fica na primeira página que aparece a tabela e o segundo fica nas demais páginas q a tabela aparece. Ou seja, se a tabela é longa o suficiente para ocupar 10 páginas, a primeira página tem um cabeçalho e as demais páginas podem ter um cabeçalho totalmente diferente. No presente caso, como a tabela é pequena (2 linhas) definiremos o cabeçalho da página 1 apenas e nada de notapé. Assim, o código fica:


```
#!Latex

\documentclass{article}
\usepackage{longtable}
\usepackage{array}
\usepackage[table]{xcolor}

\newcommand\Tstrut{\rule{0pt}{2em}}       % pading top para o titulo. Será abordado em outro tutorial
\newcommand\Bstrut{\rule[-0.9ex]{0pt}{0pt}} % padding bottom para o titulo. Será abordado em outro tutorial
\newcommand{\TBstrut}{\Tstrut\Bstrut} % Será abordado em outro tutorial

\begin{document}
% Códigos do relatórios
\begin{longtable}[c]{m{1cm}|m{11cm}}

\multicolumn{2}{c}{\cellcolor{gray!50} \textcolor{red} {\normalsize \textbf{IDENTIFICADORES DE AÇÃO GOVERNAMENTAL}}}\Tstrut  \\[2ex]

\hline\hline
 \multicolumn{1}{c|}{\textbf{ COD }} & \multicolumn{1}{c}{\textbf{ ESPECIFICAÇÃO }} \\
\hline
\endfirsthead % indica o fim do primeiro cabeçalho e início do próximo

% Código do cabeçalho para as n páginas da tabela, sendo n difente de 1

 \endhead % indica o fim dos cabeçalhos e início do primeiro rodapé

% Código do primeiro rodapé

 \endfoot % indica o fim do primeiro rodapé do rodapé para as n páginas

 \hline\hline\hline % coloquei simplesmente uma linha mais espessa para fechar o documento

 \endlastfoot % indica o fim dos rodapés
% Conteúdo da tabela fica aqui

\end{longtable}
\end{document}
```


## Inserir as linhas da tabela


O último passo agora é inserir as linhas da tabela com os dados de interesse. O caracter `&` quebra a informação por coluna e `\\` quebra a informação por linha. Como o conteúdo da tabela possui caracteres especiais, com acentos, inserimos no código a biblioteca que consegue apresentar esse dados `\usepackage[utf8]{inputenc}`.


```
#!Latex

\documentclass{article}
\usepackage{longtable}
\usepackage[utf8]{inputenc}
\usepackage{array}
\usepackage[table]{xcolor}

\newcommand\Tstrut{\rule{0pt}{2em}}       % pading top para o titulo.
\newcommand\Bstrut{\rule[-0.9ex]{0pt}{0pt}} % padding bottom para o titulo.
\newcommand{\TBstrut}{\Tstrut\Bstrut} % Será abordado em outro tutorial

\begin{document}
% Códigos do relatórios
\begin{longtable}[c]{m{1cm}|m{11cm}}

% Cabeçalho
\multicolumn{2}{c}{\cellcolor{gray!50} \textcolor{red} {\normalsize \textbf{IDENTIFICADORES DE AÇÃO GOVERNAMENTAL}}}\Tstrut  \\[2ex]

\hline\hline
 \multicolumn{1}{c|}{\textbf{ COD }} & \multicolumn{1}{c}{\textbf{ ESPECIFICAÇÃO }} \\ % Nomes das colunas
\hline
\endfirsthead % indica o fim do primeiro cabeçalho e início do próximo

% Código do cabeçalho para as n páginas da tabela, sendo n difente de 1

 \endhead % indica o fim dos cabeçalhos e início do primeiro rodapé

% Código do primeiro rodapé

 \endfoot % indica o fim do primeiro rodapé do rodapé para as n páginas

 \hline\hline\hline % coloquei simplesmente uma linha mais espessa para fechar o documento

 \endlastfoot % indica o fim dos rodapés
% Conteúdo da tabela fica aqui

0 & AÇÃO DE ACOMPANHAMENTO GERAL\\
1 & AÇÃO DE ACOMPANHAMENTO INTENSIVO\\

\end{longtable}
\end{document}
```

Esse código foi puramente escrito em Latex. A título de teste, pode ser compilado no Rsweave ou no Texmaker.

## Referências

https://pt.sharelatex.com/learn/Tables

http://posgraduando.com/como-fazer-tabelas-em-latex/

