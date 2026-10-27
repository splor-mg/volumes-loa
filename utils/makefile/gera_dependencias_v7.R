# ===================================================
# Gera todas as dependências do volume 7

dependencias = c("volume7/data/*.txt",
                 "volume7/jinja2/volume7.py",
                 "volume7/jinja2/anexos.tex.j2",
                 "volume7/jinja2/consolidado.tex.j2",
                 "volume7/jinja2/load_bibliotecas.tex",
                 "volume7/jinja2/volume7.tex.j2",
                 "volume7/jinja2/qdd.tex.j2",
                 "bancos/manual/desc_grupos_de_despesa.xlsx",
                 "bancos/manual/desc_fontes_de_recursos.xlsx",
                 "bancos/manual/desc_IAG.xlsx",
                 "bancos/manual/desc_IPU.xlsx",
                 "volume7/checks/check_orcamento_despesa_fonte_80_95.py",
                 "bancos/PPO/orcamento_despesa.csv",
                 "bancos/PPO/orcamento_despesa_fonte_80_95.csv")


arquivos = paste0(dependencias)
write(arquivos, file = stdout())
