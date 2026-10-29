# ===================================================
# Gera todas as dependências do volume 3

dependencias = c("volume3/data/*.txt",
                 "volume3/jinja2/volume3.py",
                 "volume3/jinja2/consolidado1.tex.j2",
                 "volume3/jinja2/consolidado2.tex.j2",
                 "volume3/jinja2/consolidado3.tex.j2",
                 "volume3/jinja2/detalhamento.tex.j2",
                 "volume3/jinja2/load_bibliotecas.tex",
                 "volume3/jinja2/origem.tex.j2",
                 "volume3/jinja2/tabela1.tex.j2",
                 "volume3/jinja2/tabela2.tex.j2",
                 "volume3/jinja2/tabela3.tex.j2",
                 "volume3/jinja2/tabela4.tex.j2",
                 "volume3/jinja2/tabela5.tex.j2",
                 "volume3/jinja2/volume3.tex.j2",
                 "bancos/manual/ANEXO_origens_de_recursos.txt",
                 "bancos/manual/ANEXO_detalhamento_investimentos.txt")

arquivos = paste0(dependencias)
write(arquivos, file = stdout())
