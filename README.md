# LOA

Este projeto tem por finalidade gerar os pdfs dos volumes 2, 3, 4, 5, 6 e 7 bem como diversos demonstrativos do volume 1, referentes a [LEI ORÇAMENTÁRIA ANUAL](http://planejamento.mg.gov.br/planejamento-e-orcamento/orcamento-do-estado-de-minas-gerais).

Para se familiarizar com o projeto os seguintes documentos são úteis:

- [Requisitos](wiki/Requerimentos.md)
- [Tutoriais Latex](wiki/home_tutoriais.md)
- [Proposta enviada ao MG Inova, descrevendo o projeto e todas suas caracteristicas](wiki/mg_inova.md)

## Uso

### Atualização de informações e ambiente computacional

A criação dos volumes depende da atualização de uma série de informações. Em termos gerais, os passos para a atualização dos volumes são:

1. Solicitar à DCPPN: 
  - a atualização das tabelas de apoio armazenadas no conjunto de dados [dados-volumes-loa](https://github.com/splor-mg/dados-volumes-loa);
  
  - o arquivo `.pdf` com as capas dos volumes. Renomear para `capaLOA.pdf` e salvar esse arquivo na pasta `capas/`. Ainda é necessário confirmar se houve alteração das páginas da capa de cada volume, definidas nos arquivos `Projeto_volume#.Rnw`. Exemplo de alteração para `Projeto_volume5.Rnw`:

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

1. Alinhar com a DCAF quais versões do pacote `relatorios`, `reest` e `execucao` devem ser utilizados e verificar necessidade de atualizar as respectivas versões em [volumes-docker](https://github.com/splor-mg/volumes-docker/config.mk).

   **Importante:** O repositório `volumes-docker` é responsável por construir e publicar a imagem Docker `aidsplormg/volumes:ploaAAAA` no Docker Hub. O `volumes-loa` apenas utiliza essa imagem pronta.

Caso necessário, utilize o comando `make install-pacotes` para instalar versão específica de algum desses pacotes.


1. Demandar a atualização das seguintes informações: 

- [Informações Específicas para o volume 5](wiki/volume5_info.md)
- [Informações Específicas para o volume 4](wiki/volume4_info.md)
- [Informações Específicas para o volume 3](wiki/volume3_info.md)
- [Informações Específicas para os volumes 2A e 2B](wiki/volume2_info.md)
- [Informações Específicas para os volume 1](wiki/volume1_info.md)

### Geração dos pdfs

Essas etapas devem ser realizadas com a imagem docker atualizada. 

1. **Configure o ambiente** (primeira vez apenas):

   ```bash
   # Copie o arquivo de exemplo de configuração
   cp .env.example .env
   
   # Edite o arquivo .env com suas credenciais
   ```

2. Configure as informações centrais do projeto:

   ```bash
   make config
   ```
   
   **Nota:** O comando `make config` constrói interativamente o arquivo `config.mk` com as seguintes informações:
   
   **Parâmetros informados pelo usuário:**
      - `ANO_LOA` → Ano de vigência da (P)LOA (ex: 2026)
      - `ETAPA_ORCAMENTO` → Etapa do ciclo orçamentário:
      - 1 - PROJETO DE LEI ORÇAMENTÁRIA
      - 2 - SUBSTITUTIVO PLOA  
      - 3 - LEI ORÇAMENTÁRIA
      - `DOCKER_TAG` → Tag da imagem Docker (ex: ploa2026)
      - `DOCKER_USER` → Usuário do Docker Hub (ex: aidsplormg)
      - `DOCKER_IMAGE` → Nome da imagem Docker (ex: volumes)
   
   **Etapas interativas adicionais:**
      - Atualização de `utils/ano.txt` com o valor de `ANO_LOA` (make config-ano-loa)
      - Processamento de `data.toml` substituindo variáveis de ano (make config-data-toml)
      - Atualização de `utils/etapa_orcamento.txt` com a etapa selecionada (make config-etapa-orcamento)
      - Validação e atualização dos anos no `datapackage.yaml` conforme `ANO_LOA` (make config-datapackage)
      - Atualização das capas dos volumes (copia `capas/capaLOA.pdf` para `volume*/Rnw/`)
        - se preferir pular no wizard, execute depois: `make config-capa`
      - Normalização do ProjectId do RStudio (remove a linha `ProjectId` do `LOA.Rproj`)
        - útil ao iniciar um novo ciclo/ano para regenerar metadados no RStudio
        - pode ser executado separadamente: `make config-project-id`


3. Crie um container para geração dos PDFs:

   ```bash
   make docker
   ```
   
   **Nota:** O comando `make docker` automaticamente:
   - Baixa a imagem Docker conforme configurada no arquivo `config.mk`
   - Extrai as versões dos pacotes R e o ano da LOA das labels da imagem
   - Atualiza as configurações do projeto no `config.mk`
   
   
### Comandos Docker disponíveis

- `make config` - Configura interativamente as variáveis Docker (DOCKER_TAG, DOCKER_USER, DOCKER_IMAGE)
- `make docker` - Baixa a imagem Docker, extrai versões e cria container (comando principal)
- `make docker-pull` - Baixa apenas a imagem Docker do Docker Hub
- `make extract-info` - Extrai versões da imagem Docker e atualiza configurações e datapackage
- `make config-data-toml` - Processa data.toml e substitui variáveis baseadas no config.mk
- `make rstudio` - Inicia sessão do RStudio em http://localhost:8787/ (usuário: rstudio, senha: splor)


### Geração dos volumes

1. Faça download das dependências de dados especificadas em `data.toml`: 

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
   make v7
   make v6
   make v5
   make v4
   make v3
   make v2
   make v1
   ```

Se for necessário informação sobre qual script estava sendo executado para rastrear algum erro durante a geração dos volumes defina a variável de ambiente `VERBOSE="--verbose"` no arquivo `.env` e gere o volume novamente.


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

## Informações Complementares

### Estrutura do repositório

- pasta `volume1/` … `volume7/`
  - Conteúdo: scripts R (`R/`), templates (`Rnw/`), dados intermediários (`data/`).
  - Responsável por gerar: usuário via `make v1` … `make v7` (chamam scripts R).
  - Saída: PDFs em `pdf/` e artefatos auxiliares em `volume*/`.

- pasta `utils/`
  - Conteúdo: utilitários Python/R e scripts do wizard:
    - `config.py`: wizard interativo do `make config` (usuário conduz; script escreve `config.mk`, aciona subtarefas).
    - `config_ano_loa.py`, `config_data_toml.py`, `config_etapa_orcamento.py`, `config_datapackage.py`: tarefas chamadas pelo wizard ou via `make`.
    - `config_capa.py`: copia `capas/capaLOA.pdf` para `volume*/Rnw/capaLOA.pdf` (script; usuário decide quando).
    - `config_rstudio_id.py`: remove `ProjectId` do `LOA.Rproj` (script; usuário opta).
  - Responsável: scripts (acionados por usuário via `make`/`poetry`).

- arquivo `config.mk`
  - Conteúdo: parâmetros de execução (ANO_LOA, ETAPA_ORCAMENTO, tag Docker, etc.) e metadados extraídos da imagem.
  - Responsável: `make config` (script), `extract-info` (script). Usuário só confirma/edita via wizard.

- arquivo `data.toml`
  - Conteúdo: fontes de dados (URLs, datapackages) com placeholders de ano.
  - Atualização: `make config-data-toml` (script processa ano). Usuário decide rodar.

- arquivo `datapackage.yaml`
  - Conteúdo: manifesto tabular de dados.
  - Atualização/validação: `make config-datapackage` (script ajusta anos e valida). Usuário decide rodar.

- pasta `capas/`
  - Conteúdo: `capaLOA.pdf` fornecido pela DCPPN.
  - Responsável: usuário (prover arquivo). Cópia ocorre via `make config-capa` (script).

- pasta `pdf/`
  - Conteúdo: PDFs gerados dos volumes.
  - Responsável: usuário via `make v*` (scripts R fazem a composição).

- arquivo `README.md`
  - Conteúdo: documentação de uso.
  - Responsável: equipe (manutenção manual).

- arquivo `LOA.Rproj`
  - Conteúdo: preferências do RStudio.
  - Responsável: RStudio (gera/atualiza). Limpeza opcional via `make config-project-id`.

- `pyproject.toml` / `poetry.lock`
  - Conteúdo: CLI e dependências Python.
  - Responsável: equipe (manutenção), execução via `poetry run …` (scripts).

- `Makefile`
  - Conteúdo: orquestração (help, config, docker, tarefas por volume).
  - Responsável: usuário (dispara), scripts (executam).
