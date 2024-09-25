# Tabela de apoio indicando as correspondências entre os 4 níveis diferentes de fonte em especificação.
#
# Exemplo: TESOURO ORDINÁRIO - APLICAÇÃO LIVRE é o nível 4 e tem como nivel 1 AUMENTO DE CAPITAL e como nivel 2.....
#
# Classificação das Fontes de investimento (vide https://github.com/splor-mg/volumes-loa/issues/88):
#
# 1. AUMENTO DE CAPITAL
#     2. RECURSOS DO ESTADO (11)
#         3. TESOURO ORDINÁRIO (111)
#             4. APLICAÇÃO LIVRE (11101)
#         3. TESOURO VINCULADO (112)
#     2. OUTRAS ENTIDADES (12)
#         3. CEMIG (121)
#         3. MGI (122)
#         3. CODEMIG (123)
#         3. BDMG (124)
#         3. COPASA (125)
#         3. OUTRAS (129)
# 1. OUTROS
#     2. OPERAÇÃO DE CRÉDITO (2)
#         3. CONTRATADA (21)
#             4. CONTRATADA - INTERNA (211)
#             4. CONTRATADA - EXTERNA (212)
#         3. A CONTRATAR (22)
#             4. A CONTRATAR - INTERNA (221)
#             4. A CONTRATAR - EXTERNA (222)
#     2. ALIENAÇÃO DE BENS E DIREITOS (3)
#     2. CONVÊNIOS (4)
#     2. RECURSOS PRÓPRIOS (5)
#     2. OUTRAS ORIGENS (6)
# 
# Caso surja novas fontes, deve-se alterar o código abaixo.
library(relatorios)
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")

qdd = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")

ref_niveis = unique(qdd[, .(COD_FONTE, FONTE)])
setnames(ref_niveis, "FONTE", "n4_banco")

#================================================================
# Nível 1

ref_niveis[nat(COD_FONTE, 1), n1 := "AUMENTO DE CAPITAL"]
ref_niveis[nat(COD_FONTE, 2, 3, 4, 5, 6), n1 := "OUTROS"]
ref_niveis[is.na(n1), n1 := "nao classificado"]

if("nao classificado" %in% ref_niveis[, unique(n1)]){
  warning(paste("V3_T2_SUPORTE_CORRESPONDENCIA_DE_NIVEIS_E_SUA_ORDEM: Fonte sem correspondência para o nivel 1:", 
                 "Fonte apresentada no banco (nivel 4) <", paste(ref_niveis[n1=="nao classificado", n4_banco], collapse=", "),
                 "> Banco Referencias Niveis não salvo. Corrigir manualmente as pendências\n\n"))
}

#================================================================
# Nível 2

ref_niveis[nat(COD_FONTE, 11), n2 := "RECURSOS DO ESTADO"]
ref_niveis[nat(COD_FONTE, 12), n2 := "OUTRAS ENTIDADES"]
ref_niveis[nat(COD_FONTE, 2), n2 := "OPERAÇÃO DE CRÉDITO"]
ref_niveis[nat(COD_FONTE, 3), n2 := "ALIENAÇÃO DE BENS E DIREITOS"]
ref_niveis[nat(COD_FONTE, 4), n2 := "CONVÊNIOS"]
ref_niveis[nat(COD_FONTE, 5), n2 := "RECURSOS PRÓPRIOS"]
ref_niveis[nat(COD_FONTE, 6), n2 := "OUTRAS ORIGENS"]
ref_niveis[is.na(n2), n2 := "nao classificado"]

if("nao classificado" %in% ref_niveis[, unique(n2)]){
  warning(paste("V3_T2_SUPORTE_CORRESPONDENCIA_DE_NIVEIS_E_SUA_ORDEM: Fonte sem correspondência para o nivel 2:", 
                "Fonte apresentada no banco (nivel 4) <", paste(ref_niveis[n2=="nao classificado", n4_banco], collapse=", "),
                "> Banco Referencias Niveis não salvo. Corrigir manualmente as pendências\n\n"))
}

#================================================================
# Nível 3

ref_niveis[nat(COD_FONTE, 111), n3 := "TESOURO ORDINÁRIO"]
ref_niveis[nat(COD_FONTE, 112), n3 := "TESOURO VINCULADO"]
ref_niveis[nat(COD_FONTE, 121), n3 := "CEMIG"]
ref_niveis[nat(COD_FONTE, 122), n3 := "MGI"]
ref_niveis[nat(COD_FONTE, 123), n3 := "CODEMIG"]
ref_niveis[nat(COD_FONTE, 124), n3 := "BDMG"]
ref_niveis[nat(COD_FONTE, 125), n3 := "COPASA"]
ref_niveis[nat(COD_FONTE, 129), n3 := "OUTRAS"]
ref_niveis[nat(COD_FONTE, 129), n3 := "OUTRAS"]
ref_niveis[nat(COD_FONTE, 21), n3 := "CONTRATADA"]
ref_niveis[nat(COD_FONTE, 22), n3 := "A CONTRATAR"]
ref_niveis[nat(COD_FONTE, 3, 4, 5, 6), n3 := ""]
ref_niveis[is.na(n3), n3 := "nao classificado"]

if("nao classificado" %in% ref_niveis[, unique(n3)]){
  warning(paste("V3_T2_SUPORTE_CORRESPONDENCIA_DE_NIVEIS_E_SUA_ORDEM: Fonte sem correspondência para o nivel 3:", 
                "Fonte apresentada no banco (nivel 4) <", paste(ref_niveis[n3=="nao classificado", n4_banco], collapse=", "),
                "> Banco Referencias Niveis não salvo. Corrigir manualmente as pendências\n\n"))
}

# Nivel 4 - Label que deve aparecer no relatório

ref_niveis[nat(COD_FONTE, 11101), n4_label := "APLICAÇÃO LIVRE"]
ref_niveis[nat(COD_FONTE, 211), n4_label := "CONTRATADA - INTERNA"]
ref_niveis[nat(COD_FONTE, 212), n4_label := "CONTRATADA - EXTERNA"]
ref_niveis[nat(COD_FONTE, 221), n4_label := "A CONTRATAR - INTERNA"]
ref_niveis[nat(COD_FONTE, 222), n4_label := "A CONTRATAR - EXTERNA"]
ref_niveis[is.na(n4_label), n4_label := ""]

ref_niveis$COD_FONTE <- NULL

write.table(ref_niveis, "bancos/R/V3_Niveis_de_Referencia_tabela2.txt",quote = FALSE, 
              sep = "\t",  na = "", dec = ",", row.names = FALSE)


## Parte 2: Determinar a ordem em que os niveis devem aparecer na tabela. Infelizmente, a ordem não segue o alfabeto,
# ou seja, preciso de um arquivo de suporte para auxiliar na ordenação que as fontes aparecem no relatório final

ref_ordem <- tibble::tribble(
  ~fonte, ~ordem,
  "AUMENTO DE CAPITAL", 1,
  "RECURSOS DO ESTADO", 2,
  "TESOURO ORDINÁRIO", 3,
  "APLICAÇÃO LIVRE", 4,
  "TESOURO VINCULADO", 5,
  "OUTRAS ENTIDADES", 6,
  "CEMIG", 7,
  "MGI", 8,
  "CODEMIG", 9,
  "BDMG", 10,
  "COPASA", 11,
  "OUTRAS", 12,
  "OUTROS", 13,
  "OPERAÇÃO DE CRÉDITO", 14,
  "CONTRATADA", 15,
  "CONTRATADA - INTERNA", 16,
  "CONTRATADA - EXTERNA", 17,
  "A CONTRATAR", 18,
  "A CONTRATAR - INTERNA", 19,
  "A CONTRATAR - EXTERNA", 20,
  "ALIENAÇÃO DE BENS E DIREITOS", 21,
  "CONVÊNIOS", 22,
  "RECURSOS PRÓPRIOS", 23,
  "OUTRAS ORIGENS", 24)

write.table(ref_ordem, "bancos/R/V3_Niveis_Ref_Ordem_tabela2.txt", quote = FALSE, sep = "\t",  na = "", 
            dec = ",", row.names = FALSE)
