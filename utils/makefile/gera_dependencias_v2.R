# ===================================================
# Gera todas as dependências do volume 2

dependencias = c("volume2/Rnw/T1_PROGRAMA_DE_TRABALHO.Rnw",
                 "volume2/Rnw/T2_RECURSOS_FINANCEIROS_FONTE_RECURSOS_GRUPOS_DESPESA_FISCAL.Rnw",
                 "volume2/Rnw/T3_DETALHAMENTO_DA_CATEGORIA_DE_PESSOAL.Rnw",
                 "volume2/Rnw/T3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL.Rnw",
                 "volume2/Rnw/T4_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS.Rnw",
                 "volume2/Rnw/T5_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS_TABELA_DEMAIS_RECURSOS.Rnw",
                 "volume2/Rnw/ANEXO_codigos_descricoes_2A.Rnw",
                 "volume2/Rnw/Projeto_volume2A.Rnw",
                 "volume2/Rnw/Projeto_volume2B.Rnw",
                 "volume2/Rnw/CapaLOA.pdf",
                 "volume2/Rnw/load_bibliotecas.tex",
                 "volume2/data/sumario.txt",
                 "volume2/data/tabela1/*.txt",
                 "volume2/data/tabela2/*.txt",
                 "volume2/data/tabela3/*.txt",
                 "volume2/data/tabela3/4461.csv",
                 "volume2/data/tabela4/*.txt",
                 "volume2/data/tabela5/*.txt",
                 "bancos/manual/desc_grupos_de_despesa.xlsx",
                 "bancos/manual/desc_fontes_de_recursos.xlsx",
                 "bancos/manual/desc_IAG.xlsx",
                 "bancos/manual/desc_IPU.xlsx")

arquivos = paste0(dependencias)
write(arquivos, file = stdout())
