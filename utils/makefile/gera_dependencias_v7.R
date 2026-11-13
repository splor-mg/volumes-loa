# ===================================================
# Gera todas as dependências do volume 7

dependencias = c("volume7/data/*.txt",
                 "volume7/jinja2/volume7.py",
                 "volume7/jinja2/anexos.tex.j2",
                 "volume7/jinja2/consolidado.tex.j2",
                 "volume7/jinja2/load_bibliotecas.tex",
                 "volume7/jinja2/volume7.tex.j2",
                 "volume7/jinja2/qdd.tex.j2",
                 "bancos/PPO/classificacao_despesa.csv",
                 "bancos/PPO/classificacao_fonte.csv",
                 "bancos/PPO/classificacao_ipu.csv",
                 "bancos/PPO/classificacao_iag.csv",
                 "volume7/checks/check_orcamento_despesa_fonte_80_95.py",
                 "bancos/PPO/orcamento_despesa.csv",
                 "bancos/PPO/orcamento_despesa_fonte_80_95.csv")


arquivos = paste0(dependencias)
write(arquivos, file = stdout())
