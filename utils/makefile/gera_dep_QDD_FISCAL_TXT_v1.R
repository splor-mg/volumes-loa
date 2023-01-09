# ===================================================
# Gera os targets dos TXT das tabelas do volume 1 que dependem do QDD_FISCAL

dependencias = c("volume1/data/T4_DEMONSTRATIVO_DESPESA_POR_ORGAOS_ENTIDADES_SEGUNDO_GRUPOS_DESPESA.txt",
                 "volume1/data/T12_DCGF_Demonstrativo_Evolucao_Despesa_Categoria_Economica.txt",
                 "volume1/data/T13_DCGF_Demonstrativo_Consolidado_Despesa.txt",
                 "volume1/data/T14_DEMONSTRATIVO_DESPESA_FUNCAO_SUBFUNCAO_PROGRAMA_CONFORME_VINCULO_COM_RECURSOS.txt",
                 "volume1/data/T15_PROGRAMA_TRABALHO_GOVERNO.txt",
                 "volume1/data/T17_DCGF_Demonst_Aplicacao_Recursos_Progr_Saude_Investim.txt",
                 "volume1/data/T23_DCGF_Demonstrativo_do_Servico_da_divida_publica.txt",
                 "volume1/data/T26_DCGF_DEMONSTRATIVO_RECURSOS_APLICADOS_ACOES_PARA_CRIANCA_E_ADOLESCENTE.txt",
                 "volume1/data/T27_DCGF_Demonst_Despesas_UGEPREVI.txt",
                 "volume1/data/T37_DCGF_DEMONSTRATIVOS_RECURSOS_APLICADOS_SEGURANCA_ALIMENTAR_NUTRICIONAL.txt")

arquivos = paste0(dependencias)

write(arquivos, file = stdout())