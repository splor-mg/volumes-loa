# Projeto Volume 5

Até o presente momento criamos as três layouts de tabelas que compõem o volume 5 de forma separada. Os três layouts são:

[1- demonstrativo_consolidado_despesav1.Rnw](V5-P3-Tabela-demonstrativo-consolidado-da-despesa.md)

[2- QUADRO_DETALHAMENTO_DESPESA.Rnw](V5-P4-Tabela-QUADRO-DE-DETALHAMENTO-DA-DESPESA-FISCAL.md)

3- ANEXOS.Rnw


O objetivo agora é juntar todos esses layouts e gerar o volume 5 como um todo. Há duas formas de realizar essa tarefa:

1- Copiar o código de cada um dos três layouts em um arquivo em separado:

A primeira estratégia foi utilizada no inicio dos desenvolvimentos do volume 5 (2016) e esta descrita em `LOA\volume5\Rnw\volume5.Rnw`. **Uma vez implementada, essa estratégia se mostrou ineficaz**. O arquivo `volume5.Rnw` possui mais de 400 linhas, o que dificulta a manutenção do código. Ainda, alterações realizadas no `volume5.Rnw` não se manifestavam nos arquivos em separado `demonstrativo_consolidado_despesav1.Rnw`, `QUADRO_DETALHAMENTO_DESPESA.Rnw` ou `ANEXOS.Rnw`. Dessa forma, ao realizar várias atualizações em `volume5.Rnw` os arquivos em separado acabavam ficando muito diferentes dos separados.


2- Utilizar o código já escrito nesses três arquivos `.Rnw` e inseri-lo automaticamente em um arquivo em separado.

A segunda estratégia está presente em `LOA\volume5\Rnw\Projeto_volume5.Rnw`. Nessa estratégia, a parte do código referente a `demonstrativo_consolidado_despesav1.Rnw`, `QUADRO_DETALHAMENTO_DESPESA.Rnw` e `ANEXOS.Rnw` são extraídas diretamente desses arquivos. Assim, qualquer alteração sugerida no relatório final de volume 5, **primeiramente devem ser realizadas nos arquivos de layout separados** para depois essa mudança aparecer no relatório final (`Projeto_volume5.Rnw`). Dessa forma, o relatório consolidado do volume 5 e os arquivos de layout individuais sempre estão atualizados. No decorrer do arquivo iremos explicar como isso é feito.


## Inicio de projeto_volume5

O arquivo inicia na perspectiva padrão do latex:


```
#!latex

\documentclass{article} % Iniciamos o documento na classe article

\input{load_bibliotecas} % carrega as bibliotecas utilizadas (load_bibliotecas.tex está no mesmo diretório do presente arquivo)
\renewcommand{\contentsname}{Sumário}

\begin{document} % Inicia o documento
\SweaveOpts{concordance=TRUE}

.
.
.

```

`\renewcommand{\contentsname}{Sumário}` Renomeia o título da página de sumário para "Sumário". Sem essa implementação a página teria o nome de *Contents*. As bibliotecas carregadas são as mesmas utilizadas nos 3 arquivos de layout.

## Parâmetros iniciais e atualização dos códigos advindos dos arquivos de layout

Em seguida inserimos um chunk nomeado `ParametrosRecortes`. Esses códigos não devem aparecer no arquivo .tex gerado (`echo=FALSE`) e os resultados devem ser escondidos (`results = hide`).

```
#!R

<<ParametrosRecortes, echo=FALSE, results=hide>>=

  dir_loa = gsub("(.+LOA).*", "\\1", getwd()) # determina como diretorio root C:\Users\...\LOA
  dir_latex = paste0(dir_loa, "/volume5/Rnw")
  dir_codigosR = paste0(dir_latex, "/CodigosR")
  dir_utils = paste0(dir_loa, "/utils/")
  dir_data = paste0(dir_loa, "/volume5/data")
  dir_bancos = paste0(dir_loa, "/bancos")

  ANO_DOC = as.numeric(readLines(paste(dir_utils, "ano.txt", sep=""), warn = F))

  # Recortes dos arquivos Rnw para obter os códigos em R
  source(paste(dir_utils, "funcoes_LOA.R", sep="")) # carrega as funções em utils/funcoes_LOA.R

  # extração do código referente a tabela de DEMONSTRATIVO CONSOLIDADO DA DESPESA dentro do arquivo demonstrativo_consolidado_despesav1.Rnw
  
  ObterCodigoR(paste(dir_latex, "/demonstrativo_consolidado_despesav1.Rnw",sep=""), dir_codigosR) 

  # extração do código referente a tabela de QUADRO DE DETALHAMENTO DA DESPESA dentro do arquivo QUADRO_DETALHAMENTO_DESPESA.Rnw
  
  ObterCodigoR(paste(dir_latex, "/QUADRO_DETALHAMENTO_DESPESA.Rnw",sep=""), dir_codigosR)

  # extração do código referente a tabela de ANEXOS dentro do arquivo ANEXOS.Rnw
  
  ObterCodigoR(paste(dir_latex, "/ANEXOS.Rnw",sep=""), dir_codigosR)

@
```

As variáveis com prefixo `dir_` são os caminhos dos arquivos necessários, que se servem de `dir_loa`. `dir_loa` é o diretório raiz `C:\Users\...\LOA`.

O grande destaque nessa parte é conferido a `ObterCodigoR(...)`, função criada em `/LOA/utils/funcoes_LOA.R`. Essa função tem como argumentos o arquivo do layout da tabela `.Rnw` e o diretório em que os resultados serão salvos. A função simplesmente faz uma cópia de todo o conteúdo do arquivo `.Rnw` dentro dos comentários `# INICIO TABELA` e `#FIM TABELA`. Assim, **a parte de `demonstrativo_consolidado_despesav1.Rnw`, por exemplo, que devemos copiar para o arquivo consolidado do volume 5 (`projeto_volume5.Rnw`) é separada e salva em `C:/Users/.../LOA/Volume5/Tex/CodigosR/demonstrativo_consolidado_despesav1.R`**. Essa parte do arquivo será posteriormente inserida em `projeto_volume5.Rnw`. Mais a frente nesse tutorial, será abordado mais detalhes sobre essa estratégia. Ao acessar `C:/Users/.../LOA/Volume5/Tex/CodigosR` vemos esses pedaços de `QUADRO_DETALHAMENTO_DESPESA.Rnw`, `ANEXOS.Rnw` e `demonstrativo_consolidado_despesav1.Rnw` como arquivos `.R`.


```
#!LAtex

% Capa
\begin{titlepage}
\newgeometry{top=0cm, right=0cm, left=-6cm, bottom=0cm}
\includepdf[pages={6},scale=1.1]{capaLOA.pdf}
\end{titlepage}
% \capa

```

A próxima informação definida é a página de capa. Definimos essa página como sendo do tipo título (`\begin{titlepage}` e `\end{titlepage}`) para que essa página não receba numeração e assim não seja considerada ao contar as páginas para o sumário. A estratégia adotada aqui foi realizar um **embedding** da capa do arquivo presente em `\LOA\volume5\Rnw\capaLOA.pdf` na página 6. Em termos práticos é como se recortássemos a página desse arquivo e logo em seguida colamos no nosso documento. Para ajustar essa colagem da página corretamente e não deixar nenhum espaço em branco definimos novas margens para essa página (`\newgeometry...`). `\includepdf` tem como parâmetros, respectivamente, a página que será embedada do (6), a escala (1.1) e o nome do documento (`capaLOA.pdf`). Esse arquivo `.pdf` deve estar no mesmo diretório de `projeto_volume5.Rnw`.


## Página de título

```
#!Latex

% Titulos
% Pagina com os titulos
\restoregeometry % retorna as margens originais da página

\newgeometry{top=1cm} % Define 1cm de margem superior

\thispagestyle{empty} % Faz com que a página não tenha numeração, mas é considerada na contagem de páginas do sumário

\begin{figure}[h] % inicio de uma figura no latex, orientada para ficar o topo da página [h]

\begin{center} % centralizar essa imagem
\includegraphics[width=2cm, height=2cm]{brasao_mg} % incluir a imagem brasao_mg.jpg que está dentro do diretório img na pasta em que se situa projeto_volume5.Rnw

\end{center} % parar de centralizar
\end{figure} % Fechamento da tag de figura

% espaçamento vertical negativo para aproximar mais o conteúdo *Governo do Estado de Minas* com o brasão
\vspace*{-2em} 

% Texto logo após o brasão de MG
\begin{center}
\large
Governo do Estado de Minas Gerais \\
Secretaria de Estado de Planejamento e Gestão \\
Subsecretaria de Planejamento, Orçamento e Qualidade do Gasto \\
Superintendência Central de Planejamento e Programação Orçamentária \\

% Espaçamento vertical de 10em
\vspace*{10em}

% Título
 \fontsize{50pt}{10pt}\selectfont {\textbf{LEI ORÇAMENTÁRIA \Sexpr{ANO_DOC }}}

% Espaçamento vertical de 10em
\vspace*{5em}

% Subtitulo
\large{QUADROS DE DETALHAMENTO DA DESPESA}

\end{center}
```

Em `load_bibliotecas.tex` definimos `\graphicspath{ {img/} }`, ou seja, indicamos ao Latex que as imagens estão no diretório `img/` que está dentro do diretório em que se encontra `load_bibliotecas.tex`. Ainda o comando `\Sexpr{ANO_DOC }` nos possibilita trazer para o latex uma variável especificada dentro de um chunk do R. Assim, trazemos ao texto o valor da variável `ANO_DOC`.


```
#!Latex
\afterpage{\null\thispagestyle{empty}\newpage}
\newpage
```

Na perspectiva que os volumes serão impressos, é interessante que conteúdos importantes como o sumário comece em uma página ímpar. A página de títulos é a 1, inserimos uma página em branco e logo em seguida vem a página de sumário ocupando a posição 3 no documento. Essa página em branco não possui numeração, mas é considerada na contagem de páginas (`\null\thispagestyle{empty}`).

```
#!Latex
% Sumario
\restoregeometry
\small
\tableofcontents
\newpage
% \Sumario
```

A próxima página é o sumário, que, no latex é montado unicamente com o comando `\tableofcontents`. Todos os conteúdos a seguir que definirmos como seção ou subseção serão considerados na formação dessa página.


```
#!Latex

% Pagina iniciando DEMONSTRATIVO CONSOLIDADO DA DESPESA

\ifthispageodd{ }{\afterpage{\null\thispagestyle{empty}\newpage}}

\phantomsection
\addtocontents{toc}{\cftpagenumbersoff{section}}

\restoregeometry
\vspace*{9cm}
\addcontentsline{toc}{section}{ DEMONSTRATIVO CONSOLIDADO DA DESPESA}
\centering \Huge {\textbf{DEMONSTRATIVO CONSOLIDADO DA DESPESA}}

\afterpage{\null\thispagestyle{empty}\newpage}
\newpage
% \Pagina iniciando DEMONSTRATIVO CONSOLIDADO DA DESPESA

```

O próximo passo é definir a página com o título **DEMONSTRATIVO CONSOLIDADO DA DESPESA**, que antecede a tabela. Essa página deve estar em uma página ímpar. Contudo, não sabemos quantas páginas o sumário ocupa, dado que este é gerado automaticamente por `\tableofcontents`. Para sanar essa dificuldade utilizamos `\ifthispageodd{ }{\afterpage{\null\thispagestyle{empty}\newpage}}` um if-else que não faz nada se a página em questão for ímpar (`ifthispageodd{ }`) mas insere uma página em branco no documento se a página em questão for par (`{\afterpage{\null\thispagestyle{empty}\newpage}}`). Dessa forma, automaticamente sempre garantimos que esse conteúdo estará em uma página impar.

`\phantomsection` - hyper marker na próxima página para o sumário pular para a tabela correta;

`\addtocontents{toc}{\cftpagenumbersoff{section}}` - A partir daqui tudo que for definido como seção no sumário não deve apresentar o número da página no sumário

`\addcontentsline{toc}{section}{ DEMONSTRATIVO CONSOLIDADO DA DESPESA}` - Adiciona no sumário DEMONSTRATIVO CONSOLIDADO DA DESPESA como uma seção

`\centering \Huge {\textbf{DEMONSTRATIVO CONSOLIDADO DA DESPESA}}` - Adiciona o título DEMONSTRATIVO CONSOLIDADO DA DESPESA na página

`\afterpage{\null\thispagestyle{empty}\newpage}` -  A próxima página vem a tabela. Essa tabela precisa iniciar em uma página ímpar, ou seja, dado que estamos em uma página ímpar inserimos uma página em branco logo em seguida.


A próxima etapa é inserir a tabela de **DEMONSTRATIVO CONSOLIDADO DA DESPESA**:

```
#!Latex

\newgeometry{left=1cm,right=1cm, top=2cm} % Novas margens para a tabela

\renewcommand*{\arraystretch}{1.9} % Espaçamento entre as linhas de 1.9
 \scriptsize % tamanho da fonte
 \color{myblack} % cor da fonte
 \centering % centralizado
 
\newpage % nova página
```



## Mais Informações sobre ObterCodigoR(...) e a estratégia utilizada em projeto_volume5.Rnw

Nessa parte do arquivo consolidado `projeto_volume5.Rnw`, devemos inserir a tabela que montamos em `demonstrativo_consolidado_despesav1.Rnw`. Recordando esse arquivo `.Rnw`, temos que:


```
#!R

# INICIO TABELA

	consolidado = read.table(paste(dir_bancos, "/consolidado.txt", sep=""), header = T, sep = "\t", 
                         	quote = NULL,   dec = ",", stringsAsFactors = FALSE)

 	cat("\\noindent\\begin{longtable}[c]{m{0.1cm}m{0.1cm}m{0.8cm}|m{8cm}|m{2cm}|m{2cm}|m{2cm}}\n")

 	titulo="\\multicolumn{7}{c}{\\cellcolor{gray!50} \\textcolor{vermelhoTitulo} {\\normalsize \\textbf{DEMONSTRATIVO CONSOLIDADO DA DESPESA}}}\\TBstrut  \\\\[2ex]\n"
 
 	subtitulo = paste("\\multicolumn{3}{l}{\\textbf{Exercício: \\textcolor{vermelhoTitulo}{", ANO_DOC, 
                   	  "}}} & \\multicolumn{3}{c}{RECURSOS DE TODAS AS FONTES}& \\multicolumn{1}{r}{R\\$1,00} \\\\\n")
 
 	subtitulo1 = "\\multicolumn{7}{l}{ORÇAMENTO FISCAL} \\\\\n"
 
 	cabecalho = paste("\\multicolumn{3}{l|}{\\textbf{ CÓDIGO}} & ",
 					  "\\multicolumn{1}{l|}{\\textbf{ESPECIFICAÇÃO}} & ",
                   	  "\\valorHeader{\\centering \\textbf{RECURSOS DO TESOURO}} &",
                      "\\valorHeader{\\centering \\textbf{RECURSOS DE OUTRAS FONTES}} & ",
                      "\\multicolumn{1}{c}{\\textbf{TOTAL}}\\\\")


                                                    . 
                                                    . 
                                                    . 

	cat("\\end{longtable}\n")

# FIM TABELA

```

Ou seja, abrimos o banco `LOA/Volume 5/Bancos/consolidado.txt`, iniciamos a longtable com 7 colunas (`cat("\\noindent\\begin{longtable}[c]{m{0.1cm}m{0.1cm}m{0.8cm}|m{8cm}|m{2cm}|m{2cm}|m{2cm}}\n")`) e assim por diante (e conforme foi explicado em [V5 - P3 - Tabela demonstrativo consolidado da despesa](V5-P3-Tabela-demonstrativo-consolidado-da-despesa.md)). 

Observe que o código que monta a tabela está entre os comentários `# INICIO TABELA` e `# FIM TABELA`, e esse código **foi extraído automaticamente** com `ObterCodigoR(...LOA/Volume5/Tex/QUADRO_DETALHAMENTO_DESPESA.Rnw, dir_codigosR)` e foi salvo em `C:/Users/.../LOA/Volume5/Tex/CodigosR/demonstrativo_consolidado_despesav1.R`. Assim, ao invés de manualmente copiar todo o código referente essa tabela, basta chamar esse código a partir do comando source como se segue:


```
#!R
<<demonstrativo_consolidado, results=tex, echo=F>>=
	source(paste(dir_codigosR, "/demonstrativo_consolidado_despesav1.R", sep=""), encoding = "UTF-8")
@
```

Quando o RSweave rodar, ele fará o recorte de `demonstrativo_consolidado_despesav1.Rnw` para `/LOA/Volume5/Tex/CodigosR/demonstrativo_consolidado_despesav1.R` e esse recorte será carregado em `projeto_volume5.Rnw` como um script R via `source(...)`. Todos esses comandos estão dentro da chunk `demonstrativo_consolidado`, em que o `results=tex`. Assim, todo os resultados desses comandos em R devem ser considerados no final como comandos em `.tex`. É importante novamente salientar que `LOA/Volume5/Tex/CodigosR/demonstrativo_consolidado_despesav1.R` é gerado toda vez que o script `projeto_volume5.Rnw` é executado.

## Demonstrativos por Órgão e Entidade

```
#!Latex

	\newpage
	\ifthispageodd{ }{\afterpage{\null\thispagestyle{empty}\newpage}}

	% Pagina iniciando DEMONSTRATIVOS POR ORGAO E ENTIDADE
	\phantomsection
	\restoregeometry
	\vspace*{9cm}
	\addcontentsline{toc}{section}{ DEMONSTRATIVOS POR ÓRGÃO E ENTIDADE}
	\centering \Huge {\textbf{DEMONSTRATIVOS POR ÓRGÃO E ENTIDADE}}
	\afterpage{\null\thispagestyle{empty}\newpage}
	\newpage
	\phantomsection
	% \Pagina iniciando DEMONSTRATIVOS POR ÓRGÃO E ENTIDADE
```

A próxima página do documento deve ser a página que apresenta o título DEMONSTRATIVOS POR ÓRGÃO E ENTIDADE. Essa página deve ocupar uma página ímpar, por isso iniciamos com o comando `\ifthispageodd{ }{\afterpage{\null\thispagestyle{empty}\newpage}}`. Em termos de formatação, segue o mesmo padrão da página título de DEMONSTRATIVO CONSOLIDADO DA DESPESA. Essa página antecede as tabelas por UO de Quadro de Detalhamento da Despesa. A tabela da primeira UO deve aparecer em uma página ímpar.


```
#!Latex

\newgeometry{left=3pt,right=3pt, top=1cm} % Definimos novas margens para as páginas da tabela

\setlength{\tabcolsep}{2.5pt} % Distância do conteúdo para a borda da coluna de 2.5pt

```


```
#!R
<<quadro_detalhamento_despesa, results=tex, echo=F>>=
	source(paste(dir_codigosR, "/QUADRO_DETALHAMENTO_DESPESA.R", sep=""), encoding = "UTF-8")
@
```

Em `/LOA/Volume5/Tex/CodigosR/QUADRO_DETALHAMENTO_DESPESA.R` abrimos o banco `/QUADRO_DETALHAMENTO_DESPESA_porUO.txt` e realizamos um `for` (loop) para cada UO que aparece nesse banco, montando uma tabela para cada UO (detalhes sobre a montagem das tabelas em [V5 - P4 - Tabela QUADRO DE DETALHAMENTO DA DESPESA - FISCAL](V5-P4-Tabela-QUADRO-DE-DETALHAMENTO-DA-DESPESA-FISCAL.md)). 

Novamente, todo o código presente entre `# INICIO TABELA` e `# FIM TABELA` foi salvo em `LOA/Volume5/Tex/CodigosR/QUADRO_DETALHAMENTO_DESPESA.R` e automaticamente disponibilizado a partir do comando `source(...)`. `/LOA/Volume5/Tex/CodigosR/QUADRO_DETALHAMENTO_DESPESA.R` é gerado toda vez que o script `projeto_volume5.Rnw` é executado.


## Anexos

```
#!Latex
	\ifthispageodd{ }{\afterpage{\null\thispagestyle{empty}\newpage}}
	\phantomsection
	\restoregeometry
	\vspace*{9cm}
	\addtocontents{toc}{\cftpagenumberson{section}}
	\addcontentsline{toc}{section}{GRUPOS DE DESPESA, FONTES DE RECURSO, IDENTIFICADORES DE PROCEDÊNCIA E USO E IDENTIFICADOR DE AÇÃO GOVERNAMENTAL}
	\centering \Huge {\textbf{GRUPOS DE DESPESA, FONTES DE RECURSO, IDENTIFICADORES DE PROCEDÊNCIA E USO E IDENTIFICADOR DE AÇÃO GOVERNAMENTAL}}
	\afterpage{\null\thispagestyle{empty}\newpage}
	\newpage
```

A parte de anexos possui uma página de título, assim como as seções anteriores. A única diferença está em `\addtocontents{toc}{\cftpagenumberson{section}}`, que insere o número da página da seção no sumário. Essa modificação passa a valer a partir de agora.


```
#!latex

\newgeometry{left=3pt,right=3pt, top=1cm}
\renewcommand*{\arraystretch}{1.5}

<<anexos, results=tex, echo=F>>=
	source(paste(dir_codigosR, "/ANEXOS.R", sep=""), encoding = "UTF-8")
@
```

Em seguida redefinimos as margens da página e a distância das linhas na tabela. `LOA/Volume5/Tex/CodigosR/ANEXOS.R` contém os códigos das tabelas em `ANEXOS.Rnw`.


```
#!Latex

% Contra capa
\newgeometry{top=0cm, right=0cm, left=-6cm, bottom=0cm}
\includepdf[pages={177},scale=1.1]{06_LOA_Volume_V.pdf}
% \Contra capa

\end{document}
```

Por fim inserimos a contra capa do documento, incluindo a última página de `06_LOA_Volume_V.pdf`. Por fim encerramos o documento em `\end{document}`.
