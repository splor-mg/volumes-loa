# ===================================================
# Gera todas as dependências do volume 3


dependencias = c("volume3/Rnw/T1_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_DE_RECURSO.Rnw",
                 "volume3/Rnw/CodigosR/Projeto_volume3.R",
                 "volume3/Rnw/T2_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS.Rnw",
                 "volume3/Rnw/T3_INVESTIMENTOS_SEGUNDO_FUNCOES_SUB_PROGRAMAS_PROJETOS_ATIVIDADES.Rnw",
                 "volume3/Rnw/T1_relatorio_por_empresa.Rnw",
                 "volume3/Rnw/T2_ORIGENS_RECURSOS_INVESTIMENTOS.Rnw",
                 "volume3/Rnw/T3_RECURSOS_FINANCEIROS_FONTE_RECURSOS_APLICACAO_INVESTIMENTO.Rnw",
                 "volume3/Rnw/T4_DETALHAMENTO_INVESTIMENTOS.Rnw",
                 "volume3/Rnw/T5_QUADRO_DETALHAMENTO_INVESTIMENTO.Rnw",
                 "volume3/Rnw/ANEXO_ORIGEM_DE_RECURSOS_PARA_INVESTIMENTO.Rnw",
                 "volume3/Rnw/ANEXO_DETALHAMENTO_INVESTIMENTOS.Rnw",
                 "volume3/Rnw/capaLOA.pdf", 
                 "volume3/Rnw/load_bibliotecas.tex",
                 "volume3/Rnw/Projeto_volume3.Rnw", 
                 "volume3/data/consolidado/*.txt", 
                 "volume3/data/tabela1/*.txt", 
                 "volume3/data/tabela2/*.txt", 
                 "bancos/R/V3*.txt", 
                 "volume3/data/tabela3/*.txt", 
                 "volume3/data/tabela4/*.txt", 
                 "volume3/data/tabela5/*.txt",
                 "bancos/manual/ANEXO_origens_de_recursos.txt", 
                 "bancos/manual/ANEXO_detalhamento_investimentos.txt"
                 )

arquivos = paste0(dependencias)
write(arquivos, file = stdout())
