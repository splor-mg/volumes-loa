# ===================================================
# Gera todas as dependências do volume 4

dependencias = c("volume4/data/tabela1/*.txt", 
                 "volume4/data/tabela2/*.txt", 
                 "volume4/data/sumario_v4.txt",
                 "volume4/Rnw/T1_OBRAS_POR_UNIDADE_ORCAMENTARIA_SEGUNDO_TERRITORIOS_DE_PLANEJAMENTO.Rnw", 
                 "volume4/Rnw/T2_DETALHAMENTO_DOS_INVESTIMENTOS_TERRITORIOS_PLANEJAMENTO_MUNICIPIOS.Rnw",
                 "volume4/Rnw/Projeto_volume4.Rnw",
                 "volume4/Rnw/ANEXO_RelacaoTerritorio_X_Municipios.Rnw",
                 "volume4/Rnw/capaLOA.pdf",
                 "volume4/Rnw/load_bibliotecas.tex",
                 "bancos/manual/correspondencia_mun_terr_desenvol.xlsx")

arquivos = paste0(dependencias)
write(arquivos, file = stdout())
