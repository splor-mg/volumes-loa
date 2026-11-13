# ===================================================
# Gera todas as dependências do volume 6

dependencias = c("volume6/data/QUADRO_DETALHAMENTO_DESPESA_porUO.txt",
                 "volume6/data/receita_fonte_stn.txt",
                 "volume6/jinja2/volume6.py",
                 "volume6/jinja2/anexos.tex.j2",
                 "volume6/jinja2/receita.tex.j2",
                 "volume6/jinja2/load_bibliotecas.tex",
                 "volume6/jinja2/volume6.tex.j2",
                 "volume6/jinja2/qdd.tex.j2",
                 "bancos/PPO/classificacao_despesa.csv",
                 "bancos/PPO/classificacao_ipu.csv",
                 "bancos/PPO/classificacao_iag.csv",
                 "bancos/manual/desc_fontes_de_recursos_stn.xlsx")


arquivos = paste0(dependencias)
write(arquivos, file = stdout())
