# =================================================================================
# Organização do volume 5 LOA
# Objetivos:
# P1 - Montar um dataframe com o "DEMONSTRATIVO CONSOLIDADO DA DESPESA"
# P2 - Montar QUADRO DE DETALHAMENTO DA DESPESA - FISCAL
options(warn = 1)
source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

# so utilizado se existir uma base em "bancos/SISOR/BASE_QDD_FISCAL_PROPOSTA.xlsx"
uos_proposta <- c(1011, 1021, 1031, 1051, 1091, 1441, 2361, 4031, 4121, 4441, 4451, 4611)

classificacao_despesa <- data.table(read_excel("bancos/manual/desc_classificacao_economica_despesa.xlsx", sheet = 1))

classificacao_despesa <- classificacao_despesa[!is.na(codigo), ]

classificacao_despesa[, codigo:= format(as.numeric(gsub(" |\u00A0", "", codigo)), scientific = F)]

classificacao_despesa[, codigo_texto := paste(substr(codigo, 1, 1), substr(codigo, 2, 2),
  substr(codigo, 3, 4), substr(codigo, 5, 6),
  sep = "."
)]

banco <- trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL_FONTE_STN.xlsx")

poderes <- read_excel("bancos/manual/codigosPoder.xlsx", sheet = 1)

# banco[, cod_funcao := paste0(FUNCAO,
#                              formatC(SUB_FUNCAO, width = 3, flag = "0"),
#                              PROGRAMA,
#                              IDENT_PROJATIV,
#                              formatC(PROJ_ATIV,width = 3, flag = "0"),
#                              SUB_PROJETO)]

banco[, codigo_numerico := as.numeric(paste0(
  CATEGORIA,
  GRUPO_DESPESA,
  MODALIDADE,
  formatC(ELEMENTO_DESPESA, width = 2, flag = "0")
))]

banco[, codigo_texto := paste(CATEGORIA,
  GRUPO_DESPESA,
  MODALIDADE,
  formatC(ELEMENTO_DESPESA, width = 2, flag = "0"),
  sep = "."
)]

# Inicio do QUADRO DE DETALHAMENTO DA DESPESA - FISCAL

banco[, cod_detalhe := paste0(
  formatC(FUNCAO, width = 2, flag = "0"),
  formatC(SUB_FUNCAO, width = 3, flag = "0"),
  PROGRAMA,
  IDENT_PROJATIV,
  formatC(PROJ_ATIV, width = 3, flag = "0"),
  formatC(SUB_PROJETO, width = 4, flag = "0"),
  CATEGORIA,
  GRUPO_DESPESA,
  MODALIDADE,
  formatC(ELEMENTO_DESPESA, width = 2, flag = "0"),
  IAG,
  FONTE,
  IPU
)]

if (!"valor_proposto" %in% names(banco)) banco[, valor_proposto := 0]

# Banco representa as linhas que possuem informação até IPU. Com o comando abaixo garanto que não há linhas duplicadas
banco <- banco[, list(valor = sum(valor, na.rm = T), valor_proposto = sum(valor_proposto, na.rm = T)),
  by = list(
    ANO, COD_ORGAO, ORGAO, COD_UO, UO, NOME_ACAO, FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV,
    PROJ_ATIV, SUB_PROJETO, CATEGORIA, GRUPO_DESPESA, MODALIDADE, ELEMENTO_DESPESA, IAG, FONTE,
    IPU, cod_detalhe, PODER
  )
]

# Valor total por UO
bancoTotal <- banco[, list(valor = sum(valor, na.rm = T), valor_proposto = sum(valor_proposto, na.rm = T)),
  by = list(ANO, COD_ORGAO, ORGAO, COD_UO, UO, PODER)
]

bancoTotal[, cod_detalhe := paste0("9999999999999999", "0000000000")]
bancoTotal[, NOME_ACAO := "Total"]

# agregado representa as linhas que possuem informação até C/A na tabela, com valores apenas na coluna Total
# Ex. UO=1011 - Primeira Linha:
# ELABORAÇÃO LEGISLATIVA E ACOMPANHAMENTO DAS POLÍITICAS PÚBLICAS 01 031 729 4 239 0001 total=471.866.919

agregado <- banco[, list(valor = sum(valor, na.rm = T), valor_proposto = sum(valor_proposto, na.rm = T)),
  by = list(
    ANO, COD_ORGAO, ORGAO, COD_UO, UO, FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV,
    PROJ_ATIV, SUB_PROJETO, NOME_ACAO, PODER
  )
]

agregado[, cod_detalhe := paste0(
  formatC(FUNCAO, width = 2, flag = "0"),
  formatC(SUB_FUNCAO, width = 3, flag = "0"),
  PROGRAMA,
  IDENT_PROJATIV,
  formatC(PROJ_ATIV, width = 3, flag = "0"),
  formatC(SUB_PROJETO, width = 4, flag = "0"), "0000000000"
)]

banco <- banco[, (6:12) := NA] # Tornar NA as colunas NOME_ACAO, FUNCAO, SUB_FUNCAO, PROGRAMA, IDENT_PROJATIV, PROJ_ATIV, SUB_PROJETO

banco <- rbind(banco, agregado, fill = TRUE)
banco <- rbind(banco, bancoTotal, fill = TRUE)

banco <- mergeDT(banco, poderes, by.x = "PODER", by.y = "cod_poder", all = T)

if ("Apenas no Banco X" %in% banco[, unique(merge)]) {
  warning(paste(
    "Há um código de Poder que aparece no banco, que não está presente no banco de apoio codigosPoder.xlsx.",
    "Trata-se de", paste(banco[merge == "Apenas no Banco X", unique(PODER)], collapse = "\n"),
    ". Alterar em codigosPoder.xlsx \n"
  ))
}

banco <- banco[order(PODER, COD_ORGAO, COD_UO, cod_detalhe)]

banco[, c("cod_detalhe", "PODER") := NULL]

if (TRUE %in% (banco$valor < 0)) {
  warning(paste(
    "QUADRO DETALHAMENTO DESPESA: Há valores negativos na linha ",
    paste0(which(banco$valor < 0) + 1, collapse = ", ")
  ))
}

banco <- banco[valor > 0, ] # Não incluir valores iguais a zero ou negativos

banco[, valor := formatarNum(valor)]

if (banco[, sum(valor_proposto, na.rm = T)] == 0) {
  banco[, valor_proposto := NULL]
} else {
  banco[, valor_proposto := formatarNum(valor_proposto)]
}


banco[, NOME_ACAO := correcaoCaracteresEspeciais(NOME_ACAO, caracteres)]
banco[, ORGAO := correcaoCaracteresEspeciais(ORGAO, caracteres)]
banco[, UO := correcaoCaracteresEspeciais(UO, caracteres)]
banco[, poder := correcaoCaracteresEspeciais(poder, caracteres)]

write.table(banco, "volume6/data/QUADRO_DETALHAMENTO_DESPESA_porUO.txt",
  quote = FALSE, sep = "\t", na = "", dec = ",", row.names = FALSE
)
