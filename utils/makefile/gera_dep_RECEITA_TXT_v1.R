# ===================================================
# Gera os targets dos TXT das tabelas do volume 1 que dependem do BASE_ORCAM_RECEITA

dependencias = c("volume1/data/T2_DCGF_DEMONSTRATIVO_RECEITA_CORRENTE_FISCAL.txt",
                 "volume1/data/T6_DCGF_Demonstrativo_Evolucao_Receita_por_Categoria_Economica.txt",
                 "volume1/data/T7_Quadro_Geral_da_Receita.txt",
                 "volume1/data/T9_DEMONSTRATIVO_RECEITA_ORCAMENTARIA_CORRENTE_ORDINARIA.txt")

arquivos = paste0(dependencias)

write(arquivos, file = stdout())
