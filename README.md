# LOA

Este projeto tem por finalidade gerar os pdfs dos volumes 2, 3, 4, 5 e 6 bem como diversos demonstrativos do volume 1, referentes a [LEI ORÇAMENTÁRIA ANUAL](http://planejamento.mg.gov.br/planejamento-e-orcamento/orcamento-do-estado-de-minas-gerais).

Para se familiarizar com o projeto os seguintes documentos são úteis:

- [Requisitos](wiki/Requerimentos.md)
- [Tutoriais Latex](wiki/home_tutoriais.md)
- [Proposta enviada ao MG Inova, descrevendo o projeto e todas suas caracteristicas](wiki/mg_inova.md)

## Uso

### Atualização de informações e ambiente computacional

A criação dos volumes depende da atualização de uma série de informações. Os passos para a atualização dos volumes que são de perspectiva geral são:

1. Solicitar para a DCPPN a atualização das tabelas de apoio armazenadas no conjunto de dados [volumes-loa-dados](https://github.com/splor-mg/volumes-loa-dados) e atualizar o mesmo no Github;
1. Atualizar `utils/ano.txt` com o ano de referência da LOA;
1. Atualizar `utils/etapa_orcamento.txt` com o etapa do ciclo orçamentário (ie. `PROJETO DE LEI ORÇAMENTÁRIA` ou `LEI ORÇAMENTÁRIA`)
1. Demandar o arquivo `.pdf` com as capas dos volumes. Renomear para `capaLOA.pdf` e inserir esse arquivo em todas as pastas `LOA\volume#\Rnw`. Ainda é necessário alterar as páginas de capa utilizadas nos arquivos `Projeto_volume#.Rnw`. Exemplo de alteração para `Projeto_volume5.Rnw`:

   ```latex
   [...]
   % Capa
   \begin{titlepage}
   \newgeometry{top=0cm, right=0cm, left=-6cm, bottom=0cm}
   \includepdf[pages={6},scale=1.1]{capaLOA.pdf} % No arquivo capaLOA.pdf a capa do volume 5 está na página 6.
   \end{titlepage}
   % \capa
   [...]
   ```

1. Alinhar com a DCAF quais versões do pacote `relatorios`, `reest` e `execucao` devem ser utilizados e atualizar as [volumes-docker](https://github.com/splor-mg/volumes-docker).

1. Demandar a atualização das seguintes informações: 

- [Informações Específicas para o volume 5](wiki/volume5_info.md)
- [Informações Específicas para o volume 4](wiki/volume4_info.md)
- [Informações Específicas para o volume 3](wiki/volume3_info.md)
- [Informações Específicas para os volumes 2A e 2B](wiki/volume2_info.md)
- [Informações Específicas para os volume 1](wiki/volume1_info.md)

### Geração dos pdfs

Essas etapas devem ser realizadas com a imagem docker atualizada. 

1. Crie um container para geração dos PDFs:

   ```bash
   make docker
   ```

1. Faça download das dependências de dados especificadas em `data.yaml`: 

   ```bash
   dpm install
   ```

1. Converter os bancos `.xls` para `.xlsx` e tratar caracteres especiais possivelmente presentes nos arquivos `.txt`:

   ```bash
   make format
   ```

1. Remover todos os bancos `.txt` utilizados na estruturação dos volumes. Isso evitará a manutenção de arquivos para UO's que não existem mais. Os comandos para remover todos os arquivos de cada volume são:


   ```bash
   make rm-all
   ```

   É possível remover os arquivos de um único volume com o comando `make rm vol=2`.


1. Atualizar todos os bancos `.txt` e gerar os arquivos dos volumes `.pdf`. Esse passo pode ser realizado pelos comandos make. Sugere-se montar volume por volume, do mais fácil para o mais dificil segundo a orgem abaixo:

   ```
   make v6
   make v5
   make v4
   make v3
   make v2
   make v1
   ```
**IMPORTANTE:** Se for necessário informação **sobre qual script estava sendo executado para rastrear algum erro** durante a geração dos volumes defina a variável de ambiente `VERBOSE="--verbose"` no arquivo `.env` e gere o volume novamente.

1. Após todos os volumes gerados e conferidos. Para atualizar todos os assets do testes de pdf execute:
   ```
   make snapshot
   ```
   Os arquivos das pastas `checks/assets/pdf` e `checks/assets/tex` serão atualizados para os dos pdf atuais.

1. Com a LOA validada e entregue, criar um commit com o nome checkpoint <etapa_da_loa> para marcar o ponto de referência para os testes de snapshot em futuras atualizações da LOA.
Etapas atuais: `"checkpoint ploa2026"`, `"checkpoint substitutivo2026"`, `"checkpoint loa2026"`


## Golden Tests

Esses testes são utilizados para conferência que não houve introdução de alterações não desejadas nos arquivos `.tex` e `pdf` após a geração de novos volumes ou durante refatorações do projeto.

A [estratégia](https://en.wikipedia.org/wiki/Characterization_test) consiste em armazenar nas pastas `tests/assets/` versões validadas dos arquivos (_golden master_), e, depois da geração de novos volumes, comparar se houve alguma alteração nos arquivos. Se houve apenas alterações esperadas, os arquivos armazenados em `tests/assets/` devem ser atualizados.

### Exemplos

Para realizar todas as conferências execute

```bash
make check
```

A avaliação das diferenças é feita para cada cada demonstrativo.
Caso não exista diferença o output vai ser simplesmente

```bash
python3 checks/utils.py diff T2_DCGF_DEMONSTRATIVO_RECEITA_CORRENTE_FISCAL

Results:..
```
Nota: importante rodar o comando acima com `python3`, versões 2.x do Python não aceitam padrões utilizados nos testes deste projeto.


Caso exista diferenças além de mostrar a diferença no terminal do arquivo `.tex` vai ser gerado um arquivo pdf de diferença salvo na raiz do projeto:

```bash
python3 checks/utils.py diff T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas

Results:FF
Failure testing T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas.tex
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
renamed: volume1/pdf/aux_files/T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas.tex to checks/assets/tex/T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas.tex
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
@ checks/assets/tex/T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas.tex:11 @
\pagestyle{empty}
\newgeometry{bottom=1cm,top=1cm,left=1.5cm,right=1.5cm}

\renewcommand*{\arraystretch}{1.9}\scriptsize\color{myblack}\centering\noindent\begin{longtable}[c]{m{4cm}|m{1.8cm}|m{1.8cm}|m{4cm}|m{1.8cm}|m{1.8cm}}\multicolumn{6}{c}{\cellcolor{gray!50} \textcolor{myblack} {\small \textbf{DEMONSTRATIVO DA RECEITA E DESPESA SEGUNDO AS CATEGORIAS ECONÔMICAS}}} \TBstrut \\[2ex]\multicolumn{6}{c}{\cellcolor{gray!50} \textcolor{myblack} {\small \textbf{(Art. 2$\mathbf{^o}$, \S 1$\mathbf{^o}$, Inciso II da Lei 4.320/64)}}}  \\\specialrule{1.5pt}{0pt}{0pt}\multicolumn{6}{l}{\textbf{ORÇAMENTO FISCAL}} \\\multicolumn{1}{l}{\textbf{Exercício: \textcolor{myblack}{  2023 }}} & \multicolumn{5}{r}{\textbf{R\$1,00}} \\\specialrule{1pt}{0pt}{0pt}\multicolumn{1}{L{4cm}|}{ \textbf{RECEITA}} & \multicolumn{2}{C{3cm}|}{ \textbf{VALOR}} & \multicolumn{1}{C{4cm}|}{ \textbf{DESPESA}} & \multicolumn{2}{C{3cm}}{ \textbf{VALOR}} \\\hline\multicolumn{1}{L{4.5cm}|}{ \textbf{RECEITAS CORRENTES}} & \multicolumn{1}{R{1.8cm}|}{ \textbf{}} & \multicolumn{1}{R{1.8cm}|}{ \textbf{128.444.356.599}} & \multicolumn{1}{L{4.5cm}|}{ \textbf{ DESPESAS CORRENTES}} & \multicolumn{1}{R{1.8cm}|}{ \textbf{}} & \multicolumn{1}{R{1.8cm}}{ \textbf{87.707.567.449}} \\
\multicolumn{1}{@{\hspace{2em}}L{4.5cm}|}{IMPOSTOS, TAXAS E CONTRIBUIÇÕES DE MELHORIA} & \multicolumn{1}{R{1.8cm}|}{91.839.383.883} & \multicolumn{1}{R{1.8cm}|}{} & \multicolumn{1}{@{\hspace{2em}}L{4.5cm}|}{ PESSOAL E ENCARGOS SOCIAIS} & \multicolumn{1}{R{1.8cm}|}{61.948.072.092} & \multicolumn{1}{R{1.8cm}}{} \\
\renewcommand*{\arraystretch}{1.9}\scriptsize\color{myblack}\centering\noindent\begin{longtable}[c]{m{4cm}|m{1.8cm}|m{1.8cm}|m{4cm}|m{1.8cm}|m{1.8cm}}\multicolumn{6}{c}{\cellcolor{gray!50} \textcolor{myblack} {\small \textbf{DEMONSTRATIVO DA RECEITA E DESPESA SEGUNDO AS CATEGORIAS ECONÔMICAS}}} \TBstrut \\[2ex]\multicolumn{6}{c}{\cellcolor{gray!50} \textcolor{myblack} {\small \textbf{(Art. 2$\mathbf{^o}$, \S 1$\mathbf{^o}$, Inciso II da Lei 4.320/64)}}}  \\\specialrule{1.5pt}{0pt}{0pt}\multicolumn{6}{l}{\textbf{ORÇAMENTO FISCAL}} \\\multicolumn{1}{l}{\textbf{Exercício: \textcolor{myblack}{  2023 }}} & \multicolumn{5}{r}{\textbf{R\$1,00}} \\\specialrule{1pt}{0pt}{0pt}\multicolumn{1}{L{4cm}|}{ \textbf{RECEITA}} & \multicolumn{2}{C{3cm}|}{ \textbf{VALOR}} & \multicolumn{1}{C{4cm}|}{ \textbf{DESPESA}} & \multicolumn{2}{C{3cm}}{ \textbf{VALOR}} \\\hline\multicolumn{1}{L{4.5cm}|}{ \textbf{RECEITAS CORRENTES}} & \multicolumn{1}{R{1.8cm}|}{ \textbf{}} & \multicolumn{1}{R{1.8cm}|}{ \textbf{128.444.356.599}} & \multicolumn{1}{L{4.5cm}|}{ \textbf{ DESPESAS CORRENTES}} & \multicolumn{1}{R{1.8cm}|}{ \textbf{}} & \multicolumn{1}{R{1.8cm}}{ \textbf{87.655.240.721}} \\
\multicolumn{1}{@{\hspace{2em}}L{4.5cm}|}{IMPOSTOS, TAXAS E CONTRIBUIÇÕES DE MELHORIA} & \multicolumn{1}{R{1.8cm}|}{91.839.383.883} & \multicolumn{1}{R{1.8cm}|}{} & \multicolumn{1}{@{\hspace{2em}}L{4.5cm}|}{ PESSOAL E ENCARGOS SOCIAIS} & \multicolumn{1}{R{1.8cm}|}{61.912.157.897} & \multicolumn{1}{R{1.8cm}}{} \\
===================================
Failure testing T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas.pdf
page 0 has 67676 pixels that differ
page 0 differs
1 of 1 pages differ.
pdf diff saved at T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas-diff.pdf
```

Depois de avaliar as diferenças, se houve apenas alterações esperadas, os arquivos armazenados em tests/assets/ devem ser atualizados. Isso pode ser feito com:

```bash
python3 checks/utils.py snapshot Projeto_volume5
python3 checks/utils.py snapshot Projeto_volume2A Projeto_volume2B # snapshot de um ou mais demonstrativos
python3 checks/utils.py snapshot # snapshot de todos os demonstrativos
```


