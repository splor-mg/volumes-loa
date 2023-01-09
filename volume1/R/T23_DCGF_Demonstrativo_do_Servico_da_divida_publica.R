# =================================================================================================
# Organização de T23. Demonstrativo do Serviço da dívida Pública
options(warn=1, scipen = 999)
suppressMessages(require(relatorios))

source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")

# ====== LOAD das funções para abertura dos bancos necessários ===================
source("utils/trataBancos/trataQDD_Fiscal.R", encoding = "UTF-8")

qdd = trataQDD_Fiscal("bancos/SISOR/BASE_QDD_FISCAL.xlsx", F)
loa_desp = geraLoa_desp(qdd)
setnames(loa_desp, "VL_LOA_DESP", "VL_DESP")

acoes_divida_interna = c(7007, 7886, 7030, 7043, 7658, 7003)
acoes_divida_externa = 7896


interna_principal = loa_desp[GRUPO_COD==6 & ACAO_COD %in% acoes_divida_interna, sum(VL_DESP)]
externa_principal = loa_desp[GRUPO_COD==6 & ACAO_COD==acoes_divida_externa, sum(VL_DESP)]

interna_acessorio = loa_desp[GRUPO_COD==2 & ACAO_COD %in% acoes_divida_interna, sum(VL_DESP)]
externa_acessorio = loa_desp[GRUPO_COD==2 & ACAO_COD==acoes_divida_externa, sum(VL_DESP)]


relatorio = data.table(espec = "Interna", 
                       principal = interna_principal,
                       acessorio = interna_acessorio, 
                       total = interna_principal + interna_acessorio)
                
relatorio = rbind(relatorio, 
                  data.table(espec = "Externa", 
                             principal = externa_principal,
                             acessorio = externa_acessorio, 
                             total = externa_principal + externa_acessorio))
                  
relatorio = rbind(relatorio, 
                  data.table(espec = "Total", 
                             principal = externa_principal + interna_principal, 
                             acessorio = externa_acessorio + interna_acessorio, 
                             total = externa_principal + externa_acessorio + interna_principal + interna_acessorio))

relatorio[, espec := correcaoCaracteresEspeciais(espec, caracteres)]
relatorio = relatorio[,lapply(.SD, formatarNum)]

write.table(relatorio, "volume1/data/T23_DCGF_Demonstrativo_do_Servico_da_divida_publica.txt", 
            quote = F, sep = "\t", na = "", dec = ",", row.names = FALSE)

