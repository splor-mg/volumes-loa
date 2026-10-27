# ===================================================
# Gera todas as dependências do volume 5

dependencias = c("volume5/data/*.txt",
                 "volume5/jinja2/volume5.py",
                 "volume5/jinja2/anexos.tex.j2",
                 "volume5/jinja2/consolidado.tex.j2",
                 "volume5/jinja2/load_bibliotecas.tex",
                 "volume5/jinja2/volume5.tex.j2",
                 "volume5/jinja2/qdd.tex.j2",
                 "bancos/manual/desc_grupos_de_despesa.xlsx",
                 "bancos/manual/desc_fontes_de_recursos.xlsx",
                 "bancos/manual/desc_IAG.xlsx",
                 "bancos/manual/desc_IPU.xlsx")


arquivos = paste0(dependencias)
write(arquivos, file = stdout())
