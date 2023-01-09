# ===================================================================================================
# Organização do banco DETALHAMENTO DOS INVESTIMENTOS POR TERRITÓRIOS DE PLANEJAMENTO E MUNICÍPIOS 
#
# Constroi bancos para cada UO. Apresenta os valores a nível de obra.
# Para cada obra, destaca qual ação esta faz referência, bem como território e município realizado
# Apresenta valores totais por ação, dado que no volume4 há uma tabela por UO e Ação
# ===================================================================================================

options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataAcoesPlanejamento.R", encoding = "UTF-8")
source("utils/trataBancos/trataDetalhe_Obras.R", encoding = "UTF-8")

acoes = trataAcoesPlanejamento("bancos/SISOR/acoes_planejamento", ANO_ANALISE="Sem necessidade da valor_prod")
sumario = data.table(read.table("volume4/data/sumario_v4.txt", sep="\t", header=T, dec="@"))

obras = trataDetalhe_Obras("bancos/SISOR/BASE_DETALHAMENTO_OBRAS.xlsx", acoes, realizarTeste = F)

for(cod_uo in obras[, unique(UO)]){
  # cod_uo = 1301 # SETOP
  uo = obras[UO==cod_uo,]
  uo[, DESCRICAO_DA_OBRA := paste0(NUMERO_DA_OBRA_SISOR, " - ", DESCRICAO_DA_OBRA)]
  
  # Especificação deve trazer o código até a ação e o descritivo da ação
  uo[, especificacao := paste0(formatC(FUNCAO,width = 2, flag="0"),"  " ,
                               formatC(SUBFUNCAO, width = 3, flag="0"), " ",
                               formatC(PROGRAMA, width = 3, flag="0"), " ",
                               substr(ACAO,1,1), " ", 
                               substr(ACAO, 2, 4))]

  uo[, cod_admin := SUBPROJETO]
  
  # Descritivo da ação apresentado ao lado de especificação na tabela
  uo[, nome_acao := ""]
  for(acao in uo[, unique(ACAO)]){
    if(acao %in% acoes[, unique(cod_acao)]){
      
      acao_titulo = acoes[cod_acao==acao, unique(titulo_acao)][1]
      uo[ACAO==acao, nome_acao := acao_titulo]
      
      } else{
        warning(paste("T2_DETALHAMENTO_INVESTIMENTOS_POR_TERRITORIOS_PLANEJAMENTO_MUNICIPIOS: ",
                      "O codigo da Ação ", acao, " nao foi encontrado em SISOR/acoes_planejamento.xlsx"))
      }
    }
  # ==== Indicação se a obra está iniciando, em execucao ou paralisada
  uo[, iniciando := ifelse(STATUS_DA_OBRA=="INICIANDO", 1, 0)]
  uo[, execucao := ifelse(STATUS_DA_OBRA=="EXECUÇÃO", 1, 0)]
  uo[, paralisada := ifelse(STATUS_DA_OBRA=="PARALISADO", 1, 0)]
  
  # =====================================================================
  
  # Realiza a agregação dos VALOR_TESOURO e OUTROS pelo nível de detalhamento das características da 
  # obra (DESCRICAO_DA_OBRA, "status" etc)
  uo = uo[, list(VALOR_TESOURO = sum(VALOR_TESOURO, na.rm=T), VALOR_OUTROS = sum(VALOR_OUTROS, na.rm=T)),
          by= list(REGIAO_GEOGRAFICA_INTERMEDIARIA, MUNICIPIO, DESCRICAO_DA_OBRA, QUANTIDADE, 
                   UNIDADE_DE_MEDIDA_DA_OBRA, iniciando, execucao, 
                   paralisada, especificacao, cod_admin, nome_acao)]
  
  # total agrega o valor por ação e subprojeto
  total = uo[, list(VALOR_TESOURO = sum(VALOR_TESOURO, na.rm=T), 
                    VALOR_OUTROS = sum(VALOR_OUTROS, na.rm=T)), 
             by=list(especificacao, cod_admin)]

  total[, cod_admin := cod_admin + 0.5] # Mantem a linha de total no final
  total[, DESCRICAO_DA_OBRA := "TOTAL"]

  uo = rbind(uo, total, fill=T)
  uo = uo[order(especificacao, cod_admin, REGIAO_GEOGRAFICA_INTERMEDIARIA, MUNICIPIO, DESCRICAO_DA_OBRA)]
  
  # Insere nome de órgão e UO
  if(cod_uo %in% sumario[, COD_UO]){
    COD_ORGAO = sumario[COD_UO==cod_uo, unique1(COD_ORGAO)]
    ORGAO = sumario[COD_UO==cod_uo, unique1(ORGAO)]
    NOME_UO = sumario[COD_UO==cod_uo, unique1(UO)]
    
    uo[, orgao := paste0(substr(COD_ORGAO,1,1), ".", 
                         substr(COD_ORGAO,2,3), ".", 
                         substr(COD_ORGAO,4,4), " - ",  toupper(ORGAO))]

    uo[, nome_uo := paste0(substr(cod_uo,1,1), ".", 
                          substr(cod_uo,2,3), ".", 
                          substr(cod_uo,4,4), " - ",  toupper(NOME_UO))]
  } else{
    uo[, c("orgao", "nome_uo") := NA]
    warning(paste("T2_DETALHAMENTO_INVESTIMENTOS_POR_TERRITORIOS_PLANEJAMENTO_MUNICIPIOS: O codigo UO ",
                  cod_uo, " não achou correspondência no sumário. Alterar em volume4/data/sumario_v4.txt"))
  }
  
  colsDelete = which(names(uo) %in% c("nome_uo", "orgao", "cod_admin", "nome_acao"))

  # Quero tornar NA todas as linhas que não sejam as linhas logo após a DESCRIÇÃO DA OBRA igual a TOTAL.
  # Assim, por ação haverá apenas uma linha dos descritivos "nome_uo", "orgao", "cod_admin" e "nome_acao"
  # Medida realizada unicamente com o objetivo computacional de não gravar bancos com excesso de informação

  uo = uo[setdiff(1:nrow(uo), append(c(1) ,(which(DESCRICAO_DA_OBRA=="TOTAL") + 1))), (colsDelete):=NA]

  uo = uo[,lapply(.SD, formatarNum)]
  
  uo[, DESCRICAO_DA_OBRA := correcaoCaracteresEspeciais(DESCRICAO_DA_OBRA, caracteres)]
  uo[, REGIAO_GEOGRAFICA_INTERMEDIARIA := correcaoCaracteresEspeciais(REGIAO_GEOGRAFICA_INTERMEDIARIA, caracteres)]
  uo[, MUNICIPIO := correcaoCaracteresEspeciais(MUNICIPIO, caracteres)]
  uo[, UNIDADE_DE_MEDIDA_DA_OBRA := correcaoCaracteresEspeciais(UNIDADE_DE_MEDIDA_DA_OBRA, caracteres)]
  uo[, nome_acao := correcaoCaracteresEspeciais(nome_acao, caracteres)]
  uo[, orgao := correcaoCaracteresEspeciais(orgao, caracteres)]
  uo[, nome_uo := correcaoCaracteresEspeciais(nome_uo, caracteres)]
  
  
  setnames(uo, c("REGIAO_GEOGRAFICA_INTERMEDIARIA", "MUNICIPIO", "DESCRICAO_DA_OBRA", "UNIDADE_DE_MEDIDA_DA_OBRA", 
                 "QUANTIDADE", "VALOR_TESOURO", "VALOR_OUTROS"),
               c("territorio", "municipio", "obra", "unidade", 
                 "qtde", "tesouro", "outros"))

  write.table(uo, paste0("volume4/data/tabela2/", cod_uo,".txt"), append = FALSE, 
              quote = FALSE, sep = "\t", na = "", dec = ",", row.names = FALSE)

}
