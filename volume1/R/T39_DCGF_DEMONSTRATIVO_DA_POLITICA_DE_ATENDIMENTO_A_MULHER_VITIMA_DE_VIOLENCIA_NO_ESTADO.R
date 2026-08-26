# =================================================================================================
# Organização de T39. DEMONSTRATIVO DA POLÍTICA DE ATENDIMENTO A MULHER VÍTIMA DE VIOLÊNCIA NO ESTADO
options(warn=1, scipen = 999)
suppressMessages(require(relatorios))

source("utils/funcoes.R", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")


qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
loa_desp = geraLoa_desp(qdd)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

qdd_inv = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")

novas_vars_inv = c("ANO","UO_COD", "FUNCAO_COD", "SUBFUNCAO_COD", "PROGRAMA_COD", "ACAO_COD", "ACAO_DESC")

setnames(qdd_inv, c(c("ANO","COD_UO", "FUNCAO", "SUB_FUNCAO", "PROGRAMA", "ACAO", "NOME_ACAO"), "valor"), 
         c(novas_vars_inv, "VL_DESP"))

loa_desp = rbind(loa_desp, qdd_inv, fill=T)


### ===== Load base acoes_monitoramento para obter memoria de calculo ===========

source('utils/helper_ler_bancos.R', encoding = 'utf-8')

acoes_planejamento = load_acoes('bancos/SISOR/acoes_planejamento.txt')
names(acoes_planejamento) = removeAcentos(make.names(names(acoes_planejamento)))
acoes_planejamento = acoes_planejamento[exclusao.logica.do.programa=='Não',]
acoes_planejamento = acoes_planejamento[exclusao.logica.da.acao=='Não',]

nomes_esperados = c("codigo.do.programa", "nome.do.programa", "codigo.da.unidade.orcamentaria.responsavel.pela.acao",
                    "codigo.da.funcao", "funcao",  "codigo.da.subfuncao",  "subfuncao",
                    "codigo.do.tipo.de.acao",  "tipo.de.acao",  "codigo.da.acao",  "titulo.da.acao",
                    "codigo.do.identificador.de.acao.governamental..iag.",  "exclusao.logica.da.acao",  "finalidade.da.acao",  
                    "codigo.do.produto",
                    "produto",  "unidade.de.medida.do.produto", "politica.para.mulheres")

novos_nomes = c("cod_prog", "nome_prog", "cod_uo", 
                "FUNCAO_COD", "nome_funcao", "SUBFUNCAO_COD", "nome_subfuncao",
                "cod_tipo_acao", "tipo_acao", "cod_acao", "titulo_acao",
                "cod_iag", "exc_acao", "final_acao", "prod_acao",
                "Produto", "unid_med_prod", "DR/IR")

# VERIFICAR SE É NECESSÁRIO
#if(class(ANO_ANALISE)=="numeric"){
#  nomes_esperados = c(nomes_esperados, paste0("previsao.fisica.", ANO_ANALISE))
#  novos_nomes = c(novos_nomes, "valor_prod")
#}

varEsperadas_naoIndentificadas = setdiff(nomes_esperados, names(acoes_planejamento))

if(length(varEsperadas_naoIndentificadas) > 0){
  stop("Em ler_acoes_planejamento(): Variável(is) ", 
       paste(varEsperadas_naoIndentificadas, collapse=" "), "não encontrada(s) no banco")
}

setnames(acoes_planejamento, nomes_esperados, novos_nomes)

acoes_planejamento = acoes_planejamento[, novos_nomes, with=F]

verificaTipoVariaveis(acoes_planejamento, c("nome_prog", "nome_funcao", "nome_subfuncao", 
                                            "tipo_acao", "titulo_acao", "exc_acao", 
                                            "final_acao", "prod_acao","Produto", "unid_med_prod", "DR/IR"))


memoria =  dplyr::select(acoes_planejamento, cod_uo, cod_acao, FUNCAO_COD, SUBFUNCAO_COD, `DR/IR`)
memoria <- dplyr::distinct(memoria, cod_uo, cod_acao, FUNCAO_COD, SUBFUNCAO_COD, .keep_all = TRUE)
memoria =  dplyr::rename(memoria, EXCLUSIVA = `DR/IR`, ACAO_COD = cod_acao, UO_COD = cod_uo)


### ------------------------------------------------------------------------------

loa_desp = dplyr::left_join(loa_desp, memoria, by = c("UO_COD", "ACAO_COD", "FUNCAO_COD", "SUBFUNCAO_COD"))
loa_desp = as.data.table(loa_desp)

loa_desp[, ACOES_MULHER := FALSE]
loa_desp[EXCLUSIVA %in% c("Indiretamente relacionada", "Diretamente relacionada") , ACOES_MULHER := TRUE]
loa_desp[EXCLUSIVA == "Indiretamente relacionada", EXCLUSIVA := "IR"]
loa_desp[EXCLUSIVA == "Diretamente relacionada", EXCLUSIVA := "DR"]

loa_desp = loa_desp[ACOES_MULHER==T, list(VL_DESP = sum(VL_DESP)), 
                    by=list(UO_COD, FUNCAO_COD, SUBFUNCAO_COD, PROGRAMA_COD, ACAO_COD, ACAO_DESC, EXCLUSIVA)]


loa_desp[, FUNCIONAL:= paste(FUNCAO_COD, formatC(SUBFUNCAO_COD, width = 3, flag="0"),
                             formatC(PROGRAMA_COD, width = 3, flag="0"),
                             substr(ACAO_COD, 1,1),
                             substr(ACAO_COD, 2,4), sep=".")]

setorderv(loa_desp, cols = c('EXCLUSIVA', 'UO_COD', 'FUNCAO_COD',
                             'SUBFUNCAO_COD', 'PROGRAMA_COD', 'ACAO_COD'))

loa_desp = loa_desp[, list(UO_COD, FUNCIONAL, ACAO_DESC, VL_DESP, EXCLUSIVA)]

loa_desp = rbind(loa_desp, data.table(UO_COD="TOTAL", VL_DESP = loa_desp[, sum(VL_DESP)]), fill=T)

# Número das linhas finais com IR e DR e soma de cada grupo
last_dr_id <- max(which(loa_desp$EXCLUSIVA == "DR"))
last_ir_id <- max(which(loa_desp$EXCLUSIVA == "IR"))
total_dr <- round(sum(loa_desp[EXCLUSIVA == "DR", VL_DESP]), 0)
total_ir <- round(sum(loa_desp[EXCLUSIVA == "IR", VL_DESP]), 0)


if (last_dr_id < last_ir_id) {

  total_dr_row <- data.table(UO_COD = "TOTAL DR", FUNCIONAL = NA_character_, 
                             ACAO_DESC = NA_character_, VL_DESP = total_dr, EXCLUSIVA = NA_character_)
  total_ir_row <- data.table(UO_COD = "TOTAL IR", FUNCIONAL = NA_character_, 
                             ACAO_DESC = NA_character_, VL_DESP = total_ir, EXCLUSIVA = NA_character_)
  
  # insere linhas de totais DR e IR após cada grupo.
  loa_desp <- rbind(loa_desp[1:last_dr_id], total_dr_row, loa_desp[(last_dr_id + 1):last_ir_id], total_ir_row, loa_desp[(last_ir_id + 1):.N], fill = TRUE)
}


loa_desp[, VL_DESP:=formatarNum(round(VL_DESP, 0))]
loa_desp[, ACAO_DESC := correcaoCaracteresEspeciais(ACAO_DESC, caracteres)]

write.table(loa_desp, "volume1/data/T39_DCGF_DEMONSTRATIVO_DA_POLITICA_DE_ATENDIMENTO_A_MULHER_VITIMA_DE_VIOLENCIA_NO_ESTADO.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)
