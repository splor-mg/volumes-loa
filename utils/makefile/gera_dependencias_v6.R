# ===================================================
# Gera todas as dependências do volume 6

dependencias = c("volume6/data/*.txt",
                 "volume6/jinja2/volume6.py",
                 "volume6/jinja2/anexos.tex.j2",
                 "volume6/jinja2/receita.tex.j2",
                 "volume6/jinja2/load_bibliotecas.tex",
                 "volume6/jinja2/volume6.tex.j2",
                 "volume6/jinja2/qdd.tex.j2",
                 "bancos/manual/desc_grupos_de_despesa.xlsx",
                 "bancos/manual/desc_fontes_de_recursos_stn.xlsx",
                 "bancos/manual/desc_IAG.xlsx",
                 "bancos/manual/desc_IPU.xlsx")


arquivos = paste0(dependencias)
write(arquivos, file = stdout())
