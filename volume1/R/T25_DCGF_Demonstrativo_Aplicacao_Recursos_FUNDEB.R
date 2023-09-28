# =================================================================================================
# Organização de T25. Demonstrativo da Aplicação dos Recursos do Fundo de Desenvolvimento da 
# Educação Básica e Valorização dos Profissionais da Educação
options(warn=1, scipen = 999)
suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataReceita_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

class_receita = ler_novaReceita("bancos/manual/desc_classificacao_receita.xlsx")
subfuncao_desc = data.table(read_excel("bancos/manual/desc_subfuncao.xlsx", sheet=1))

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
loa_desp = geraLoa_desp(qdd)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

# receita = trataReceita_Fiscal_antigo("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL_2017.xlsx", F)
receita = trataReceita_Fiscal("bancos/SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx", F)
loa_rec = geraLoa_rec(receita)
setnames(loa_rec, "VL_LOA_REC", "VL_REC")

geraPerc = function(x) return(gsub("\\.", ",", round(x,2)))

# =============== RECEITA ================================================================
# Recorte para a FONTE 23
#	Fundo de Manutenção e Desenvolvimento da Educação Básica - Fundeb	
#
# Recursos vinculados ao Fundo de Manutenção E Desenvolvimento da Educação Básica e de 
# Valorização dos Profissionais da Educação - Fundeb resultante da parcela do ICMS, IPVA, 
# ITCD, com as respectivas multas e dívida ativa e transferência de impostos federais. 
# ========================================================================================

parteA_desc =  "RECEITA"

rec_A = c(1321001, 1758, 19) # Padrão nova codificação da receita

parteA = loa_rec[UO_COD == 1261 & ( FONTE_COD==23 | FONTE_COD==13), ]
#parteA = mergeDT(parteA, class_receita, by="RECEITA_COD", all.x=T)
#parteA = adiciona_desc(parteA, "RECEITA")
parteA = parteA[, list(valor = sum(VL_REC)), by=list(cod = RECEITA_COD, espec = RECEITA_DESC)][order(cod)]

parteA = rbind(data.table(cod=NA, 
                          espec = parteA_desc, 
                          valor = sum(parteA[,valor])), 
               parteA)


# =============== DESPESA =======================
parteB_desc =  "DESPESA"
loa_desp = loa_desp[ (FONTE_COD==23 |  FONTE_COD==13) , ]

loa_desp = mergeDT(loa_desp, subfuncao_desc, by.x="SUBFUNCAO_COD", by.y="codigo", all.x=T)
setnames(loa_desp, "subfuncao", "espec")
loa_desp[, merge:=NULL]

subf_esperadas = c(361, 363, 362, 366, 367, 368) # Códigos de subfunção que apareceram em 2023

if(length(intersect(loa_desp[, unique(SUBFUNCAO_COD)], subf_esperadas)) != length(loa_desp[, unique(SUBFUNCAO_COD)])){
  warning(paste0("T25_DCGF_Demonstrativo_Aplicacao_Recursos_FUNDEB: ",
                 "setdiff(loa_desp[, unique(SUBFUNCAO_COD)], subfun_esperadas): ",
                 setdiff(loa_desp[, unique(SUBFUNCAO_COD)], subf_esperadas),
                 "\n setdiff(subfun_esperadas, loa_desp[, unique(SUBFUNCAO_COD)]): ",
                 setdiff(subf_esperadas, loa_desp[, unique(SUBFUNCAO_COD)])))
}


parteB = loa_desp[, list(valor = sum(VL_DESP)), by=list(cod = paste(UO_COD, SUBFUNCAO_COD), 
                                                        espec)]

parteB = rbind(data.table(cod=NA, 
                          espec = parteB_desc, 
                          valor = sum(parteB[,valor])),
               parteB)

demonst1 = rbind(parteA, parteB)

total_receita = demonst1[espec==parteA_desc, valor]
total_despesa = demonst1[espec==parteB_desc, valor]

if(total_despesa!=total_receita){
  warning("T25_DCGF_Demonstrativo_Aplicacao_Recursos_FUNDEB: Valor total da receita (", formatarNum(total_receita),
          ") é diferente do valor total da despesa (", formatarNum(total_despesa), "). Verificar!")
}

demonst1[, espec := correcaoCaracteresEspeciais(espec, caracteres)]
demonst1 = demonst1[, lapply(.SD, formatarNum)]

write.table(demonst1, "volume1/data/T25_DCGF_Demonstrativo_Aplicacao_Recursos_FUNDEB.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)


acoes_magisterio = c(2080, 2081, 2082, 2083, 2085, 2086, 2088, 2089, 2090, 2093, 2094, 2096, 2097) 
loa_desp_magisterio = loa_desp[ACAO_COD %in% acoes_magisterio & GRUPO_COD==1,]

loa_desp_magisterio[, cod := paste0(UO_COD, " ", FUNCAO_COD, ".", SUBFUNCAO_COD, ".", 
                                    PROGRAMA_COD, ".", substr(ACAO_COD,1,1), ".", 
                                    substr(ACAO_COD,2,4))]

loa_desp_magisterio = loa_desp_magisterio[, list(valor = sum(VL_DESP)), 
                                          by=list(cod, espec)]

total_desp_magisterio = loa_desp_magisterio[, sum(valor)]
loa_desp_magisterio = loa_desp_magisterio[, lapply(.SD, formatarNum)]

demonst2 = rbind(data.table(cod=NA, espec = "DESPESA COM PESSOAL", valor = formatarNum(total_desp_magisterio)),
                loa_desp_magisterio,
                data.table(cod=NA, espec = "PERCENTUAL DE APLICAÇÃO EM RELAÇÃO A RECEITA DO FUNDEB",
                           valor = paste0(formatarNum(geraPerc(total_desp_magisterio*100 / total_receita)), "\\%"))
               )

demonst2[, espec := correcaoCaracteresEspeciais(espec, caracteres)]

write.table(demonst2, "volume1/data/T25_DCGF_PT2_PESSOAL_MAGISTERIO_RELATIVO_RECEITA_FUNDEB.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

