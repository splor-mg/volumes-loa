# ===================================================
# Gera todas as dependências do volume 4

dependencias = c("volume4/data/*.txt",
                 "volume4/jinja2/volume4.py",
                 "volume4/jinja2/anexo.tex.j2",
                 "volume4/jinja2/load_bibliotecas.tex",
                 "volume4/jinja2/tabela1.tex.j2",
                 "volume4/jinja2/tabela2.tex.j2",
                 "volume4/jinja2/volume4.tex.j2",
                 "bancos/manual/correspondencia_mun_terr_desenvol.xlsx")

arquivos = paste0(dependencias)
write(arquivos, file = stdout())
