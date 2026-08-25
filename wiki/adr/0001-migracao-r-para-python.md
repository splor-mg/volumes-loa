# ADR 0001: Migração da base R (Sweave) para Python mantendo LaTeX

- **Status**: Proposto
- **Data**: 2026-08-25
- **Autor**: Renata (SPLOR-MG), assistido por Claude
- **Escopo**: Discussão inicial de viabilidade. Nenhuma mudança de código foi feita no projeto a partir desta ADR.

## Contexto

O projeto `volumes-loa` gera os volumes em PDF da Lei Orçamentária Anual (LOA) a partir de um pipeline em R + LaTeX. Há interesse em migrar a base de R para Python, motivado por preferência/capacidade da equipe, mas com a restrição de que **os PDFs gerados devem permanecer exatamente iguais** aos produzidos hoje.

### Levantamento do pipeline atual

**Linguagem/motor de geração**: Sweave puro (`.Rnw`), não knitr nem rmarkdown. 78 templates `.Rnw` distribuídos em `volume1`...`volume7` e `capas/`.

**Pacotes R utilizados**:
- Genéricos: `data.table` (uso mais intenso), `tidyverse`, `dplyr`, `readr`, `stringr`, `readxl`, `conflicted`, `gmailr`.
- Internos (SPLOR-MG/DCAF), não publicados no CRAN, sem `DESCRIPTION`/`renv.lock`, versionados junto com a imagem Docker (`aidsplormg/volumes:loa2027.2`):
  - `relatorios` — pacote central de geração de relatório (25 `require` + 4 `library` no código).
  - `execucao`
  - `reest`
- Já existe um `requirements.txt` na raiz com dependências Python (`dpm`, `pandas`, `lxml`, `openpyxl`), usado apenas para uma etapa de *fetch* de dados (`dpm install`), não para geração do relatório em si.

**Interação R ↔ LaTeX**: R não gera gráficos nem usa `tikzDevice`/`ggplot` — o conteúdo é 100% tabular. O fluxo é:
1. Scripts em `volume*/R/` limpam/agregam dados de `bancos/` e gravam intermediários em texto plano (`volume*/data/*.txt`, `*.csv`).
2. Templates `.Rnw` em `volume*/Rnw/` leem esses intermediários (`read.table`/`read_delim`) dentro de chunks Sweave (`<<...>>=` ... `@`) e interpolam valores com `\Sexpr{}` em meio a LaTeX puro.
3. O `.Rnw` é tecido (weave) para `.tex` e compilado com `pdflatex`/`latexmk`.

**Estrutura por volume**: `R/` (preparo de dados), `Rnw/` (templates Sweave), `data/` (intermediários gerados), `pdf/` (saída + `aux_files/` de build), `docs/`. Total: 139 arquivos `.R`, 78 `.Rnw`, 144 `.tex` (majoritariamente preâmbulos `load_bibliotecas.tex` e artefatos gerados em `aux_files/`).

**Orquestração**: `Makefile` + `config.mk` na raiz. `config.mk` gera o grafo de dependências dinamicamente chamando scripts R (`utils/makefile/gera_dep_*.R`) no momento do parse do Make. Alvos: `volumes` (roda `v7`...`v1` em ordem), `v1`...`v7`, `format`, `clean`, `rm`/`rm-all`, `docker`, `rstudio`, `validate`, `check`, `snapshot`. Fluxo documentado: `make docker` → `dpm install` → `make format` → `make rm-all` → `make v7`...`v1`.

## Decisão

Recomenda-se **manter o LaTeX como motor de tipografia/layout do projeto** e substituir apenas o mecanismo que preenche o LaTeX dinamicamente: trocar Sweave (R) por **Jinja2 (Python)** como motor de templating.

Isso significa:
- Os arquivos `.Rnw` são convertidos para templates `.tex.j2`: todo o LaTeX puro que já existe hoje (tabelas, `\multicolumn`, comandos customizados, preâmbulos como `load_bibliotecas.tex`) é preservado sem alteração de conteúdo.
- Os chunks R (`<<...>>= ... @`) saem do template e viram scripts Python separados, que preparam os dados.
- As interpolações inline `\Sexpr{variavel}` viram `\VAR{ variavel }` (sintaxe Jinja2, com delimitadores customizados para não colidir com `{}` do LaTeX).
- A compilação final continua sendo `pdflatex`/`latexmk`, sem mudança.

### Por que não Markdown → PDF

Markdown foi cogitado como alternativa por analogia ("R usa algo parecido com Markdown?"), mas **não é o caso**: o R hoje já usa LaTeX puro via Sweave, não Markdown. Converter para Markdown (via pandoc, por exemplo) introduziria uma camada de conversão que decide layout por conta própria, arriscando exatamente a fidelidade visual que é requisito deste projeto (tabelas orçamentárias complexas, cabeçalhos institucionais, quebras de página específicas). Jinja2 evita esse problema por ser apenas um mecanismo de substituição de texto sobre o LaTeX existente — não uma linguagem de marcação concorrente.

## Equivalências de ferramentas propostas

| Função | R (atual) | Python (proposto) |
|---|---|---|
| Manipulação de dados | `data.table`, `dplyr`, `tidyverse` | `pandas` (ou `polars`) |
| Leitura de planilhas | `readxl` | `pandas.read_excel` / `openpyxl` |
| Leitura de texto/CSV | `readr` | `pandas.read_csv` |
| Templating LaTeX (substitui Sweave) | `.Rnw` (`<<>>=`, `\Sexpr{}`) | Jinja2 (`.tex.j2`, `\VAR{}`, `\BLOCK{}`) |
| Regras de negócio orçamentário | pacotes internos `relatorios`, `execucao`, `reest` | reescrita manual em Python — sem atalho automatizado |
| Orquestração | `make` + `config.mk` (grafo dinâmico via R) | manter `make`, ou avaliar `snakemake`/`luigi`/`prefect` |
| Ambiente de build | imagem Docker com R | imagem Docker com Python + TeX Live (inalterado) |

## Riscos e principal fonte de esforço

O maior custo da migração **não é a troca de motor de templating** (Sweave → Jinja2 é uma tradução relativamente mecânica), e sim a **reescrita das regras de negócio** hoje encapsuladas nos pacotes internos `relatorios`, `execucao` e `reest` — que provavelmente contêm lógica específica de cálculo orçamentário, agregação por natureza de despesa, formatação de valores em português, etc., sem documentação formal fora do próprio código-fonte.

## Estratégia recomendada

1. Migração incremental por volume, não big-bang — começar pelo volume mais simples (`volume7`, com apenas 6-7 scripts R) antes de avançar para os demais.
2. Para cada `.Rnw` migrado: preservar o LaTeX puro integralmente, extrair a lógica dos chunks R para Python equivalente.
3. Validação de fidelidade: comparar a saída `.tex` intermediária (mais confiável que diff binário de PDF, que pode variar por timestamps/metadados) entre a versão R e a versão Python, para o mesmo volume e mesmo período de dados.
4. Somente após validar um volume completo, avançar para o próximo.

## Consequências

- **Positivo**: elimina a dependência de pacotes R internos não publicados e sem versionamento formal; unifica a stack em Python (que já é usada para o `dpm`); separa mais claramente lógica (Python) de apresentação (LaTeX) do que o Sweave atual permite.
- **Negativo**: esforço concentrado na reescrita de regras de negócio dos pacotes internos, não na troca de ferramenta de template; risco de divergências sutis de formatação/arredondamento se a lógica de negócio não for replicada com fidelidade; período de convivência entre pipeline R e Python durante a migração incremental.
- **Em aberto**: se a orquestração via Make é mantida como está ou migrada para uma ferramenta Python-native; documentação completa do que os pacotes `relatorios`/`execucao`/`reest` fazem ainda precisa ser levantada função a função antes de iniciar a reescrita.
