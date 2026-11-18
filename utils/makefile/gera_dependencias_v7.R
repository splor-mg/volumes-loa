# ===================================================
# Gera todas as dependências do volume 7

dependencias = c("volume7/data/*.txt",
                 "volume7/jinja2/volume7.py",
                 "volume7/jinja2/anexos.tex.j2",
                 "volume7/jinja2/consolidado.tex.j2",
                 "volume7/jinja2/load_bibliotecas.tex",
                 "volume7/jinja2/volume7.tex.j2",
                 "volume7/jinja2/qdd.tex.j2",
                 "datapackages/ppo/data/classificacao_despesa.csv",
                 "datapackages/ppo/data/classificacao_fonte.csv",
                 "datapackages/ppo/data/classificacao_ipu.csv",
                 "datapackages/ppo/data/classificacao_iag.csv",
                 "volume7/checks/check_orcamento_despesa_fonte_80_95.py",
                 "datapackages/ppo/data/orcamento_despesa.csv",
                 "datapackages/fonte_80_95/data/orcamento_despesa_fonte_80_95.csv")


arquivos = paste0(dependencias)
write(arquivos, file = stdout())
