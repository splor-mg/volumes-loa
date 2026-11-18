# ===================================================
# Gera todas as dependências do volume 5

dependencias = c("volume5/data/*.txt",
                 "volume5/jinja2/volume5.py",
                 "volume5/jinja2/anexos.tex.j2",
                 "volume5/jinja2/consolidado.tex.j2",
                 "volume5/jinja2/load_bibliotecas.tex",
                 "volume5/jinja2/volume5.tex.j2",
                 "volume5/jinja2/qdd.tex.j2",
                 "datapackages/ppo/data/classificacao_despesa.csv",
                 "datapackages/ppo/data/classificacao_fonte.csv",
                 "datapackages/ppo/data/classificacao_ipu.csv",
                 "datapackages/ppo/data/classificacao_iag.csv")


arquivos = paste0(dependencias)
write(arquivos, file = stdout())
