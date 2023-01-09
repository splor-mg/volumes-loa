# ===================================================
# Gera os targets dos TXT das tabelas do volume 1 que dependem do BASE_ORCAM_RECEITA e BASE_QDD

dependencias = c("volume1/data/T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas.txt",
                 "volume1/data/T16_DCGF_Demons_Aplicacao_Recursos_Manut_Desenv_Ensino.txt",
                 "volume1/data/T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude.txt",
                 "volume1/data/T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa.txt",
                 "volume1/data/T25_DCGF_Demonstrativo_Aplicacao_Recursos_FUNDEB.txt")

arquivos = paste0(dependencias)

write(arquivos, file = stdout())