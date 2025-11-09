library(data.table)

df <- as.data.table(readxl::read_excel("bancos/SISOR/BASE_QDD_FISCAL.xlsx"))

column_mapping <- c(COD_UO = "UO_COD", 
                    GRUPO_DESPESA = "GRUPO_COD", 
                    FONTE = "FONTE_COD",
                    FUNCAO = "FUNCAO_COD",
                    `AÇÃO` = "ACAO_COD", 
                    IPU = "IPU_COD")



column_mapping <- tolower(column_mapping)

# Mapeia para nomes utilizados no pacote relatorios e com lowercase
setnames(df, names(column_mapping), unname(column_mapping))
setnames(df, tolower(names(df)))

fonte_stn <- relatorios::is_fonte_stn_desp(df)

# retorna para nomes de colunas padrão da LOA e com uppercase
setnames(df, unname(column_mapping), names(column_mapping))
setnames(df, toupper(names(df)))


df[, FONTE := fonte_stn]

writexl::write_xlsx(list(BASE_QDD_FISCAL = df), "bancos/SISOR/BASE_QDD_FISCAL_FONTE_STN.xlsx")
