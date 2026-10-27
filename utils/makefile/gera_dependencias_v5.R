# ===================================================
# Gera todas as dependências do volume 5

dependencias = c("volume5/data/*.txt",
                 "volume5/jinja2/Projeto_volume5.py",
                 "volume5/jinja2/anexos.tex.j2",
                 "volume5/jinja2/demonstrativo_consolidado_despesa.tex.j2",
                 "volume5/jinja2/load_bibliotecas.tex",
                 "volume5/jinja2/Projeto_volume5.tex.j2",
                 "volume5/jinja2/quadro_detalhamento_despesa.tex.j2",
                 "bancos/manual/desc_grupos_de_despesa.xlsx",
                 "bancos/manual/desc_fontes_de_recursos.xlsx",
                 "bancos/manual/desc_IAG.xlsx",
                 "bancos/manual/desc_IPU.xlsx")


arquivos = paste0(dependencias)
write(arquivos, file = stdout())
