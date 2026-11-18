## Receita prevista e realizada em 2016
options(warn=1, scipen = 999)

suppressMessages(require(relatorios))

source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("volume1/R/tabela28_comum.R")

# ====================================================================================
# Receita prevista e realizada no exercício vigente


loa_rec = execucao::loa_rec[ANO==ano_exercicio,]
exec_rec = fread(cmd = paste0("gzip -dc datapackages/siafi_", ano_exercicio, "/data/receita.csv.gz"),
                 colClasses = list(character = "receita_cod"))
exec_rec = exec_rec[vlr_efetivado_ajustado != 0, ]
classificacao = fread("datapackages/classificadores/data/receita.csv", encoding = "UTF-8",
                      colClasses = list(character = "receita_cod"))
classificacao = classificacao[ano == ano_exercicio, ]


loa_rec = loa_rec[FONTE_COD %in% fontes_uniao,
                  list(VL_LOA_REC = sum(VL_LOA_REC)),
                  by=list(RECEITA_COD, RECEITA_DESC)]

exec_rec = exec_rec[fonte_cod %in% fontes_uniao & mes_cod <= mes,
                    list(VL_EFET_AJUST = round(sum(vlr_efetivado_ajustado),0)),
                    by=list(RECEITA_COD = receita_cod)]

receita = mergeDT(loa_rec, exec_rec, by="RECEITA_COD", all=T)
receita[merge=="Apenas no Banco Y",
        RECEITA_DESC := classificacao$receita_desc[match(RECEITA_COD, classificacao$receita_cod)]]

receita = receita[, list(RECEITA_COD, RECEITA_DESC, previsto = VL_LOA_REC, efet_ajust = VL_EFET_AJUST)]
receita[is.na(receita)] = 0

receita = rbind(receita, receita[, lapply(.SD, sum), .SDcols = 3:4], fill=T)
receita[nrow(receita), RECEITA_DESC:="TOTAL"]

receita = receita[, lapply(.SD, formatarNum)]
receita[, RECEITA_DESC := correcaoCaracteresEspeciais(RECEITA_DESC, caracteres)]

receita[, c("ANO", "MES", "FONTE_EXEC") := NA_character_]
receita[1,c("ANO", "MES", "FONTE_EXEC") := list(as.character(ano_exercicio), mes_executado, FONTES_CONSIDERADAS)]

write.table(receita, "volume1/data/tabela28a.txt",
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
