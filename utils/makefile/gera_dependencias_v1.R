# ===================================================
# Gera as listas de dependências do volume 1
# Uso: Rscript utils/makefile/gera_dependencias_v1.R <lista>

dependencias = list(
  # PDF das tabelas com dados gerados em R (volume1/R)
  pdf_r = c(
    "pdf/tabela1.pdf",
    "pdf/tabela6.pdf",
    "pdf/tabela8.pdf",
    "pdf/tabela12.pdf",
    "pdf/tabela16.pdf",
    "pdf/tabela19.pdf",
    "pdf/tabela20a.pdf",
    "pdf/tabela27.pdf",
    "pdf/tabela28a.pdf",
    "pdf/tabela28b.pdf",
    "pdf/tabela38.pdf"),

  # TXT das tabelas em R que dependem do BASE_QDD_FISCAL
  txt_qdd = c(
    "volume1/data/tabela12.txt",
    "volume1/data/tabela27.txt"),

  # TXT das tabelas em R que dependem do BASE_ORCAM_RECEITA
  txt_receita = c(
    "volume1/data/tabela6.txt"),

  # TXT das tabelas em R que dependem do BASE_ORCAM_RECEITA e do BASE_QDD_FISCAL
  txt_receita_qdd = c(
    "volume1/data/tabela16.txt",
    "volume1/data/tabela19.txt"),

  # PDF das tabelas em Python com os dados em volume1/data
  pdf_python = c(
    "pdf/tabela2.pdf",
    "pdf/tabela4.pdf",
    "pdf/tabela5.pdf",
    "pdf/tabela7.pdf",
    "pdf/tabela9.pdf",
    "pdf/tabela13.pdf",
    "pdf/tabela14.pdf",
    "pdf/tabela15.pdf",
    "pdf/tabela17.pdf",
    "pdf/tabela18.pdf",
    "pdf/tabela23.pdf",
    "pdf/tabela26.pdf",
    "pdf/tabela28c.pdf",
    "pdf/tabela28d.pdf",
    "pdf/tabela30.pdf",
    "pdf/tabela37.pdf",
    "pdf/tabela39.pdf",
    "pdf/tabela40.pdf"),

  # TXT gerados por volume1/python/volume1.py
  txt_python = c(
    "volume1/data/tabela2.txt",
    "volume1/data/tabela3a.txt",
    "volume1/data/tabela3b.txt",
    "volume1/data/tabela4.txt",
    "volume1/data/tabela5.txt",
    "volume1/data/tabela7.txt",
    "volume1/data/tabela9.txt",
    "volume1/data/tabela13.txt",
    "volume1/data/tabela14.txt",
    "volume1/data/tabela15.txt",
    "volume1/data/tabela17.txt",
    "volume1/data/tabela18.txt",
    "volume1/data/tabela23.txt",
    "volume1/data/tabela26.txt",
    "volume1/data/tabela28c.txt",
    "volume1/data/tabela28d.txt",
    "volume1/data/tabela30.txt",
    "volume1/data/tabela37.txt",
    "volume1/data/tabela39.txt"),

  # Dependências comuns dos PDF das tabelas em Python
  jinja2 = c(
    "volume1/jinja2/volume1.py",
    "volume1/jinja2/load_bibliotecas.tex",
    "bancos/manual/desc_base_legal_demonstrativos.xlsx")
)

args = commandArgs(trailingOnly = TRUE)
write(dependencias[[args[1]]], file = stdout())
