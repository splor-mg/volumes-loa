# =======================================================================================================
# Organização do banco OBRAS POR UNIDADE ORCAMENTARIA SEGUNDO TERRITORIOS DE PLANEJAMENTO - TABELA 1 
# Para cada UO apresenta o rateio dos valores de obras por territótio
# =======================================================================================================
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataDetalhe_Obras.R", encoding = "UTF-8")

obras = trataDetalhe_Obras("bancos/SISOR/BASE_DETALHAMENTO_OBRAS.xlsx", acoes="Não precisa do banco de ações")

sumario = data.table(read.table("volume4/data/sumario_v4.txt", header = T, sep = "\t", 
                                quote = "\"'", dec = "@", stringsAsFactors = FALSE))

for(cod_uo in obras[, unique(UO)]){
  
  uo = obras[UO==cod_uo,]

  uo = uo[, list(valor=sum((VALOR_TESOURO + VALOR_OUTROS), na.rm=T)), by=list(REGIAO_GEOGRAFICA_INTERMEDIARIA)]
  setnames(uo, "REGIAO_GEOGRAFICA_INTERMEDIARIA", "territorio")

  uo = uo[order(removeAcentos(as.character(territorio)))] 
  # Caracteres com acentos estão sendo considerados por último na ordenação

  
  if(uo[, sum(valor)] > 0){
    uo[, porcentagem := round((valor*100 / sum(valor)), 2)]
    } else{
    uo[, porcentagem := "-"]
    }
  
  uo = rbind(uo, data.table(territorio = "TOTAL", valor=uo[, sum(valor)], porcentagem = 100))

  uo$orgao = NA
  uo$uo = NA

  if(cod_uo %in% sumario[, COD_UO]){
    
    COD_ORGAO = sumario[COD_UO==cod_uo, unique1(COD_ORGAO)]
    ORGAO = sumario[COD_UO==cod_uo, unique1(ORGAO)]
    NOME_UO = sumario[COD_UO==cod_uo, unique1(UO)]
    
    uo$orgao[1] = paste0(substr(COD_ORGAO,1,1), ".", substr(COD_ORGAO,2,3), ".", 
                         substr(COD_ORGAO,4,4), " - ",  toupper(ORGAO))
    
    uo$uo[1] = paste0(substr(cod_uo,1,1), ".", substr(cod_uo,2,3), ".", 
                      substr(cod_uo,4,4), " - ",  toupper(NOME_UO))
  } else{
    warning(paste("T1_OBRAS_POR_UNIDADE_ORCAMENTARIA: O codigo UO ",cod_uo, 
                  " não achou correspondência no sumário. Alterar em volume4/data/sumario.txt"))
  }

  uo = uo[,lapply(.SD, formatarNum)]
  
  uo[, territorio := correcaoCaracteresEspeciais(territorio, caracteres)]
  uo[, uo := correcaoCaracteresEspeciais(uo, caracteres)]
  uo[, orgao := correcaoCaracteresEspeciais(orgao, caracteres)]
  
  write.table(uo, paste0("volume4/data/tabela1/", cod_uo,".txt"), append = FALSE, quote = FALSE, 
              sep = "\t",  na = "", dec = ",", row.names = FALSE)

}

