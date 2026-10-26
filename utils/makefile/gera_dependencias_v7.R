# ===================================================
# Gera todas as dependências do volume 7

dependencias = c("volume7/data/*.txt",
                 "volume7/jinja2/Projeto_volume7.py",
                 "volume7/jinja2/anexos.tex.j2",
                 "volume7/jinja2/demonstrativo_consolidado_despesa.tex.j2",
                 "volume7/jinja2/load_bibliotecas.tex",
                 "volume7/jinja2/Projeto_volume7.tex.j2",
                 "volume7/jinja2/quadro_detalhamento_despesa.tex.j2",
                 "volume7/checks/check_qdd_fonte_95.py",
                 "bancos/manual/desc_grupos_de_despesa.xlsx",
                 "bancos/manual/desc_fontes_de_recursos.xlsx",
                 "bancos/manual/desc_IAG.xlsx",
                 "bancos/manual/desc_IPU.xlsx",
                 "bancos/SISOR/BASE_QDD_FISCAL.xlsx",
                 "bancos/SISOR/BASE_QDD_FISCAL_FONTE_95.xlsx")

arquivos = paste0(dependencias)
write(arquivos, file = stdout())
