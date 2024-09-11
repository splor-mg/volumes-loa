# ===================================================
# Gera todas as dependências do volume 5

dependencias = c("volume7/data/*.txt",
                 "volume7/Rnw/ANEXOS.Rnw", 
                 "volume7/Rnw/demonstrativo_consolidado_despesav1.Rnw", 
                 "volume7/Rnw/load_bibliotecas.tex",
                 "volume7/Rnw/Projeto_volume7.Rnw", 
                 "volume7/Rnw/QUADRO_DETALHAMENTO_DESPESA.Rnw",
                 "bancos/manual/desc_grupos_de_despesa.xlsx",
                 "bancos/manual/desc_fontes_de_recursos.xlsx",
                 "bancos/manual/desc_IAG.xlsx",
                 "bancos/manual/desc_IPU.xlsx",
                 "bancos/SISOR/BASE_QDD_FISCAL.xlsx",
                 "bancos/SISOR/BASE_QDD_FISCAL_FONTE_95.xlsx")


arquivos = paste0(dependencias)
write(arquivos, file = stdout())
