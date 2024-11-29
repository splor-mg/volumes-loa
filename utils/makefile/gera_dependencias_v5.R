# ===================================================
# Gera todas as dependências do volume 5

dependencias = c("volume5/data/*.txt",
                 "volume5/Rnw/ANEXOS.Rnw",
                 "volume5/Rnw/CapaLOA.pdf",
                 "volume5/Rnw/demonstrativo_consolidado_despesav1.Rnw",
                 "volume5/Rnw/load_bibliotecas.tex",
                 "volume5/Rnw/Projeto_volume5.Rnw",
                 "volume5/Rnw/QUADRO_DETALHAMENTO_DESPESA.Rnw",
                 "bancos/manual/desc_grupos_de_despesa.xlsx",
                 "bancos/manual/desc_fontes_de_recursos.xlsx",
                 "bancos/manual/desc_IAG.xlsx",
                 "bancos/manual/desc_IPU.xlsx")


arquivos = paste0(dependencias)
write(arquivos, file = stdout())
