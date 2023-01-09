# Requerimentos

Segue abaixo a lista de programas e suas respectivas bibliotecas. O projeto foi executado corretamente nos anos de 2016 e 2017 utilizando as versões abaixo. **É possível que na utilização de versões mais atuais desses programas e bibliotecas, os relatórios sejam montados da mesma forma**. Contudo não há garantias disso. Assim, a necessidade de apresentar as versões específicas utilizadas.

### Instalação do Ambiente de Desenvolvimento R

Instalar os seguintes programas:

1. [R](https://www.r-project.org/) versão 3.6.3
- No processo de instalação indicar como diretório para instalação do programa **Meus Documentos**. Ex.: *C:\Users\m1312932\Documents\R-3.3.2*
2. [Rstudio](https://www.rstudio.com/) versão 1.3.1073
- Esse programa pode ser instalados em *C:\Program Files\RStudio*, conforme o padrão
3. [Rtools](https://cran.r-project.org/bin/windows/Rtools/) versão 3.5.0.4
- Esse programa pode ser instalados em *C:\Rtools*, conforme o padrão

As bibliotecas utilizadas pelo R e suas respectivas versões são (relação completa de pacotes do ambinente utlizado no final deste arquivo):

- data.table 	1.11.2
- readxl 		1.3.1 
- knitr 		1.30 
- markdown		0.7.7 
- devtools		1.13.4
- dplyr			1.0.2
 -readr			1.3.1
- tidyverse		1.3.0
- conflicted	1.0.4

Para instalar uma biblioteca no R basta utilizar a função `install.packages`. Ex.:
```
#!R
> install.packages("data.table")

```

Para instalar uma versão específica de um pacote pode-se utilizar o pacote `versions` função `install.versions()`  ou baixar o pacote no [CRAN](https://cran.r-project.org/src/contrib/Archive/).

### Instalação do Miktex

1. [Miktex](https://miktex.org/) versão 2.9.6100. Dado a dificuldade de encontrar um repositório com as versões antigas do Miktex, mantive o instalador em `LOA\utils\packages_latex\basic-miktex-2.9.6161-x64.exe`

2. No processo de instalação do Miktex, instalar o programa em **Meus Documentos**. Ex.: `C:\Users\m1312932\Documents\MiKTeX 2.9`

3. Bibliotecas Necessárias
Ao compilar um arquivo `.Rnw` no Rstudio, automaticamente aparecem janelas para instalar cada biblioteca necessária. Contudo a instalação dessas bibliotecas será realizada segundo a versão mais atualizada, o que não necessariamente manterá a compilação e formatação dos volumes correta.

Não encontrei um repositório online que mantem as versões antigas dessas bibliotecas. Assim, mantive essas bibliotecas em `LOA\utils\packages_latex\bibliotecas.rar` e sua localização dentro da instalação local do miktex em `LOA\utils\packages_latex\instalados.xlsx`. Criei uma função para copiar automaticamente esses arquivos nos destinos corretos. As funções estão presentes em `LOA\utils\packages_latex\instala_bibliotecas.R`. Para instalar essas bibliotecas rodar a função 

```
instalar_bbts(path_miktex, dir_pack_latex)
```

Onde `path_miktex` é o caminho absoluto para a instalação do miktex (Ex.: *C:/Users/m1312932/Documents/MiKTeX 2.9*) e `dir_pack_latex` é o caminho absoluto para `LOA\utils\packages_latex` (Ex.: *C:/Users/m1312932/SEPLAG/LOA/utils/packages_latex*). Se o procedimento rodar sem problemas, aparecerá a mensagem *Instalacao das bibliotecas concluida na pasta C:\Users\m1312932\Documents\MiKTeX 2.9*

Caso seja necessário, para remover esses arquivos rodar o seguinte comando:

```
desinstalar_bbts(path_miktex, dir_pack_latex)
```

4. Atualizar o Miktex com as novas bibliotecas. Simplesmente copiar esses arquivos para os diretórios corretos não garante que a instalação esteja completa. Para isso ir no *Menu Iniciar* e pesquisar por *MikTeX Settings*. Na aba *General* clicar em *Refresh FNDB*. Ao terminar o processo, o Miktex reconhecerá os arquivos copiados como bibliotecas instaladas.


### Variáveis de Ambiente

Uma vez instalados todos os programas, editar a variável de ambiente `Path` do sistema, ou usuário, dependendo dos privilégios. É necessário indicar no `Path` a localização dos binários desses programas. Para alterar esses parâmetros pesquisar no menu `iniciar` por **Editar variáveis de ambiente do sistema** ou **Editar variáveis de ambiente da sua conta**, dependendo dos privilégios dos usuários.

Processo de edição consiste em:

1. Clicar na variável Path e clicar em *Editar...*;
2. AS INFORMAÇÕES JÁ CONTIDAS EM PATH DE MANEIRA NENHUMA DEVEM SER ALTERADAS. O que vc fará é incluir novos caminhos, sem alterar o que já está presente;
3. Ao final do valor da variável inserir ; e colocar as variáveis de ambiente para o R, Rtools e Miktex, conforme exemplo abaixo:

```
<vários caminhos separados por ; que você não quer alterar>;c:\Rtools\bin;c:\Rtools\mingw_32\bin;C:\Program Files\R\R-3.3.2\bin;C:\Program Files\MiKTeX 2.9\miktex\bin\x64\
```

Os caminhos dependem de onde esses programas foram instalados. Um bom exemplo de edição do path foi realizado nos [tutoriais da DCAF](https://dcgf.gitlab.io/config-ambiente.html#variaveis-de-ambiente)

Ao editar o Path, será possível executar `R`, `RScript` e `make` via prompt de comando.


## [Bug na Compilação do RSweave](Bug_na_compilacao_de_Rsweave.md)

Ao compilar o pdf utilizando o Rsweave, palavras com acentos aparecem sem erros. Entretanto, se o usuário copiar esse conteúdo para um editor de textos, os caracteres apresentam erros. Resolver esse problema após o processo de instalação dos ambientes.

## Relação completa de pacotes R utlizados na LOA 2021

Package				Version
askpass				1.1
assertthat			0.2.1
backports			1.1.7
base64enc			0.1-3
bdsmatrix			1.3-4
BH					1.72.0-3
bibtex				0.4.2.2
bit					4.0.4
bit64				4.0.2
bitops				1.0-6
blob				1.2.1
broom				0.7.0
callr				3.4.3
caret				6.0-86
cellranger			1.1.0
chron				2.3-56
cli					2.0.2
clipr				0.7.0
colorspace			1.4-1
commonmark			1.7
conflicted			1.0.4
covr				3.5.0
cpp11				0.2.1
crayon				1.3.4
crosstalk			1.1.0.1
curl				4.3
data.table			1.11.2
DBI					1.1.0
dbplyr				1.4.4
desc				1.2.0
devtools			1.13.4
digest				0.6.24
dplyr				1.0.2
ellipsis			0.3.1
evaluate			0.14
execucao			0.5.7
fansi				0.4.1
farver				2.0.3
fastmap				1.0.1
fastmatch			1.1-0
filehash			2.4-2
forcats				0.5.0
foreach				1.5.0
formatR				1.7
Formula				1.2-3
fs					1.5.0
gbRd				0.4-11
gdata				2.18.0
generics			0.0.2
ggplot2				3.3.2
git2r				0.27.1
glue				1.4.1
gmailr				0.7.1
gower				0.2.2
gtable				0.3.0
gtools				3.8.2
haven				2.3.1
hexbin				1.28.1
highr				0.8
hms					0.5.3
htmltools			0.5.0
htmlwidgets			1.5.1
httpuv				1.5.4
httr				1.4.2
hunspell			3.0
ipred				0.9-9
isoband				0.2.2
iterators			1.0.12
jpeg				0.1-8.1
jsonlite			1.6
knitr				1.30
labeling			0.3
later				1.1.0.1
lava				1.6.7
lazyeval			0.2.2
lifecycle			0.2.0
lmtest				0.9-37
lubridate			1.7.9
magrittr			1.5
manipulateWidget	0.10.1
markdown			0.7.7
maxLik				1.4-0
memoise				1.0.0
mime				0.9
miniUI				0.1.1.1
miscTools			0.6-26
ModelMetrics		1.2.2.2
modelr				0.1.8
munsell				0.5.0
NLP					0.2-0
numDeriv			2016.8-1.1
openssl				1.4.2
pillar				1.4.6
pkgbuild			1.1.0
pkgconfig			2.0.3
pkgload				1.1.0
plm					2.2-3
plogr				0.2.0
plyr				1.8.6
png					0.1-7
praise				1.0.0
prettyunits			1.1.1
pROC				1.16.2
processx			3.4.3
prodlim				2019.11.13
progress			1.2.2
promises			1.1.1
ps					1.3.4
purrr				0.3.4
R6					2.4.1
RColorBrewer		1.1-2
Rcpp				1.0.5
RCurl				1.98-1.2
Rdpack				1.0.0
readr				1.3.1
readxl				1.3.1
recipes				0.1.13
reest				0.2.5
relatorios			0.6.39
rematch				1.0.1
reprex				0.3.0
reshape				0.8.8
reshape2			1.4.4
rex					1.2.0
rgl					0.100.54
rlang				0.4.7
rmarkdown			2.5
rprojroot			1.3-2
RSQLite				2.2.0
rstudioapi			0.11
rvest				0.3.6
sandwich			2.5-1
scales				1.1.1
selectr				0.4-2
shiny				1.5.0
slam				0.1-47
sourcetools			0.1.7
spelling			2.1
SQUAREM				2020.3
stringi				1.4.6
stringr				1.4.0
sys					3.4
testit				0.11
testthat			2.3.2
tibble				3.0.3
tidyr				1.1.1
tidyselect			1.1.0
tidyverse			1.3.0
tikzDevice			0.12.3.1
timeDate			3043102
tinytex				0.25
tm					0.7-7
translations		3.6.3
utf8				1.1.4
vctrs				0.3.2
viridisLite			0.3.0
webshot				0.5.2
whisker				0.3-2
withr				2.2.0
wordcloud			2.6
xfun				0.16
XML					3.99-0.3
xml2				1.3.2
xtable				1.8-4
xts					0.12-0
yaml				2.2.1
zoo					1.8-8

