# ===================================================
# Gera todas as dependências do volume 2

dependencias = c("volume2/data/*.txt",
                 "volume2/jinja2/volume2.py",
                 "volume2/jinja2/anexos.tex.j2",
                 "volume2/jinja2/funfip.tex.j2",
                 "volume2/jinja2/load_bibliotecas.tex",
                 "volume2/jinja2/tabela1.tex.j2",
                 "volume2/jinja2/tabela2.tex.j2",
                 "volume2/jinja2/tabela3.tex.j2",
                 "volume2/jinja2/tabela4.tex.j2",
                 "volume2/jinja2/tabela5.tex.j2",
                 "volume2/jinja2/volume2.tex.j2",
                 "bancos/manual/desc_grupos_de_despesa.xlsx",
                 "bancos/manual/desc_fontes_de_recursos.xlsx",
                 "bancos/manual/desc_IAG.xlsx",
                 "bancos/manual/desc_IPU.xlsx")

arquivos = paste0(dependencias)
write(arquivos, file = stdout())
