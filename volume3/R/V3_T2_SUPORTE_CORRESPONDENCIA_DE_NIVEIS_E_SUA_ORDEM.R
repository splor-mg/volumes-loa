### IMPORTANTE
#
# Preciso de uma tabela de apoio indicando as correspondências entre os 4 níveis diferentes de fonte em especificação.
#
# Exemplo: TESOURO ORDINÁRIO - APLICAÇÃO LIVRE é o nível 4 e tem como nivel 1 AUMENTO DE CAPITAL e como nivel 2.....
#
# Essa tabela, em 2016, foi montada com base nas fontes descritas abaixo. Caso surja novas fontes, deve-se
# ALTERAR O CÓDIGO ABAIXO ou simplemente alterar manualmente a tabela 
# ...LOA\Volume 3\Bancos\tabela2\apoio\V3_Niveis_de_Referencia_tabela2.txt
#
# FONTES EM 2016:
#
# OP CRÉD A CONTRATAR INTERNA - OUTRAS
# OP CRÉD CONTRAT EXTERNA - KFW
# OP CRÉD CONTRAT INTERNA - OUTRAS
# OUTRAS ENTIDADES - BDMG
# OUTRAS ENTIDADES - COPASA
# RECURSOS PRÓPRIOS
# TESOURO ORDINÁRIO - APLICAÇÃO LIVRE
# TESOURO VINCULADO - FUNDESE
#
###
options(warn = 1)
source("utils/funcoes.r", encoding = "UTF-8")
source("utils/formataTexto.R", encoding = "UTF-8")
source("utils/trataBancos/trataQDD_Investimento.R", encoding = "UTF-8")

qdd = trataQDD_Investimento("bancos/SISOR/BASE_QDD_INVESTIMENTO.xlsx")

ref_niveis = data.table(n4_banco=unique(qdd$FONTE))
# Nível 1
# Expectativa
#
# OPERAÇÃO DE CRÉDITO = OP CRÉD A CONTRATAR INTERNA - OUTRAS, OP CRÉD CONTRAT EXTERNA - KFW, OP CRÉD CONTRAT INTERNA - OUTRAS
# RECURSOS PRÓPRIOS = RECURSOS PRÓPRIOS
# AUMENTO DE CAPITAL = OUTRAS ENTIDADES - BDMG, TESOURO ORDINÁRIO - APLICAÇÃO LIVRE, TESOURO VINCULADO - FUNDESE, TESOURO VINCULADO - OUTROS

ref_niveis[, n1 := ifelse(grepl("OP * CR(E|é)D.+", n4_banco, ignore.case = T), "OPERAÇÃO DE CRÉDITO", 
                   ifelse(grepl("RECURSOS * PR.{1}PRIOS", n4_banco, ignore.case = T), "RECURSOS PRÓPRIOS",
                   ifelse(grepl("^(OUTRAS|TESOURO).+", n4_banco, ignore.case = T), "AUMENTO DE CAPITAL",
                          "nao classificado")))]

if("nao classificado" %in% ref_niveis[, unique(n1)]){
  warning(paste("V3_T2_SUPORTE_CORRESPONDENCIA_DE_NIVEIS_E_SUA_ORDEM: Fonte sem correspondência para o nivel 1:", 
                 "Fonte apresentada no banco (nivel 4) <", paste(ref_niveis[n1=="nao classificado", n4_banco], collapse=", "),
                 "> Banco Referencias Niveis não salvo. Corrigir manualmente as pendências\n\n"))
}


# Nível 2
# Expectativa
#
# CONTRATADA = OP CRÉD A CONTRATAR INTERNA - OUTRAS, OP CRÉD CONTRAT EXTERNA - KFW, OP CRÉD CONTRAT INTERNA - OUTRAS
# "" = RECURSOS PRÓPRIOS
# OUTRAS ENTIDADES = OUTRAS ENTIDADES - BDMG, OUTRAS ENTIDADES - COPASA
# RECURSOS DO ESTADO = TESOURO ORDINÁRIO - APLICAÇÃO LIVRE, TESOURO VINCULADO - FUNDESE, TESOURO VINCULADO - OUTROS

ref_niveis[, n2 := ifelse(grepl("OP * CR(E|é)D.+", n4_banco, ignore.case = T), "CONTRATADA", 
                  ifelse(grepl("RECURSOS * PR.{1}PRIOS", n4_banco, ignore.case = T), "",
                  ifelse(grepl("^(OUTRAS).+", n4_banco, ignore.case = T), "OUTRAS ENTIDADES",
                  ifelse(grepl("^(TESOURO).+", n4_banco, ignore.case = T), "RECURSOS DO ESTADO",
                         "nao classificado"))))]

if("nao classificado" %in% ref_niveis[, unique(n2)]){
  warning(paste("V3_T2_SUPORTE_CORRESPONDENCIA_DE_NIVEIS_E_SUA_ORDEM: Fonte sem correspondência para o nivel 2:", 
                "Fonte apresentada no banco (nivel 4) <", paste(ref_niveis[n2=="nao classificado", n4_banco], collapse=", "),
                "> Banco Referencias Niveis não salvo. Corrigir manualmente as pendências\n\n"))
}

# Nível 3
# Expectativa
#
# INTERNA = OP CRÉD A CONTRATAR INTERNA - OUTRAS, OP CRÉD CONTRAT INTERNA - OUTRAS
# EXTERNA = OP CRÉD CONTRAT EXTERNA - KFW
# "" = RECURSOS PRÓPRIOS
# COPASA = OUTRAS ENTIDADES - COPASA
# BDMG = OUTRAS ENTIDADES - BDMG
# TESOURO ORDINÁRIO = TESOURO ORDINÁRIO - APLICAÇÃO LIVRE
# TESOURO VINCULADO = TESOURO VINCULADO - FUNDESE, TESOURO VINCULADO - OUTROS

ref_niveis[, n3 := ifelse(grepl("OP * CR(E|é)D.+IN.+", n4_banco, ignore.case = T), "INTERNA",
                   ifelse(grepl("OP * CR(E|é)D.+EX.+", n4_banco, ignore.case = T), "EXTERNA", 
                   ifelse(grepl("RECURSOS * PR.{1}PRIOS", n4_banco, ignore.case = T), "",
                   ifelse(grepl("COPASA", n4_banco, ignore.case = T), "COPASA",
                   ifelse(grepl("BDMG", n4_banco, ignore.case = T), "BDMG",
                   ifelse(grepl("ORDIN(Á|A)RIO", n4_banco, ignore.case = T), "TESOURO ORDINÁRIO",
                   ifelse(grepl("VINCULADO", n4_banco, ignore.case = T), "TESOURO VINCULADO",
                          "nao classificado")))))))]

if("nao classificado" %in% ref_niveis[, unique(n1)]){
  warning(paste("V3_T2_SUPORTE_CORRESPONDENCIA_DE_NIVEIS_E_SUA_ORDEM: Fonte sem correspondência para o nivel 3:", 
                "Fonte apresentada no banco (nivel 4) <", paste(ref_niveis[n3=="nao classificado", n4_banco], collapse=", "),
                "> Banco Referencias Niveis não salvo. Corrigir manualmente as pendências\n\n"))
}

# Nivel 4 - Label que deve aparecer no relatório
ref_niveis[, n4_label := gsub(".+ *- *(.+)", "\\1", n4_banco)] # Utiliza como label o nome depois de '-'
ref_niveis[, n4_label := ifelse(grepl("^(COPASA|BDMG)$", n4_label, ignore.case = T), "", n4_label)]

ref_niveis = as.data.table(ref_niveis)

write.table(ref_niveis, "bancos/R/V3_Niveis_de_Referencia_tabela2.txt",quote = FALSE, 
              sep = "\t",  na = "", dec = ",", row.names = FALSE)


## Parte 2: Determinar a ordem em que os niveis devem aparecer na tabela. Infelizmente, a ordem não segue o alfabeto,
# ou seja, preciso de um arquivo de suporte para auxiliar na ordenação que as fontes aparecem no relatório final

ref_ordem = rbindlist(list(ref_niveis[, list(fonte = unique(n1))], 
                           ref_niveis[, list(fonte = unique(n2))], 
                           ref_niveis[, list(fonte = unique(n3))], 
                           ref_niveis[, list(fonte = unique(n4_label))]), use.names = T)

ref_ordem = ref_ordem[fonte!="" & fonte!="RECURSOS PRÓPRIOS",]

ref_ordem[, ordem := ifelse(fonte=="APLICAÇÃO LIVRE", 4, 
                     ifelse(fonte=="AUMENTO DE CAPITAL",1,
                     
                     ifelse(fonte=="BDMG",10, 
                     ifelse(fonte=="CONTRATADA",12, 
                     ifelse(fonte=="COPASA",9, 
                     ifelse(fonte=="EXTERNA",16, 
                     ifelse(fonte=="FUNDESE",6, 
                     ifelse(fonte=="INTERNA",13, 
                     ifelse(fonte=="KFW",16, 
                     ifelse(fonte=="OPERAÇÃO DE CRÉDITO",11, 
                     ifelse(fonte=="OUTRAS",15, 
                     ifelse(fonte=="OUTRAS ENTIDADES",8, 
                     ifelse(fonte=="RECURSOS DO ESTADO",2, 
                     ifelse(fonte=="TESOURO ORDINÁRIO",3, 
                     ifelse(fonte=="TESOURO VINCULADO",5, 
                     ifelse(fonte=="BNDES",14,
                     ifelse(fonte=="OUTROS",7, 0)))))))))))))))))]

if(0 %in% ref_ordem[, ordem]){
  
  warning(paste("V3_T2_SUPORTE_CORRESPONDENCIA_DE_NIVEIS_E_SUA_ORDEM: Nova Fonte:", 
                ref_ordem[ordem==0, paste(fonte, collapse=", ")], 
                "\n Veja as tabelas 'ORIGENS DE RECURSOS PARA INVESTIMENTOS' no projeto-volume3.pdf gerado.",
                "As fontes não classificadas aparecem primeiro nesses demonstrativos. Para correção",
                " necessário atualizar manualmente, indicando a ordem em",
                "volume3/R/V3_T2_SUPORTE_CORRESPONDENCIA_DE_NIVEIS_E_SUA_ORDEM.R linhas ~ 115 a 134 \n\n"))  
  
}

write.table(ref_ordem, "bancos/R/V3_Niveis_Ref_Ordem_tabela2.txt", quote = FALSE, sep = "\t",  na = "", 
            dec = ",", row.names = FALSE)
