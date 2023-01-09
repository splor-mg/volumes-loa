limpa_painel_rec_desp = function(banco, referencia, tipo){
  
  # =================================================================
  # Realiza um reshape do tipo long nos paineis de receita e despesa
  # e normaliza nomes de colunas e tipos
  # =================================================================
  
  if(class(banco)[1] == "character"){
    painel = data.table(read.csv2(banco)) 
  } else{
    painel = copy(banco)
  }
  
  painel[, grep("part", names(painel), value=T):= NULL]  
  
  if(tipo == "R"){
    setnames(painel, c("receita", "ordinaria_rec", "vinculada_rec", "total_rec"),
             c("receita_atual", "rec ordinaria", "rec vinculada", "rec total"))  
    var_ordem = "ordem_rec"
    descritivo = "receita_atual"
  } else{
    setnames(painel, c("despesa", "ordinaria", "vinculada", "total"),
             c("despesa_atual", "desp ordinaria", "desp vinculada", "desp total"))  
    var_ordem = "ordem_desp"
    descritivo = "despesa_atual"
  }
  
  painel = melt(painel, id.vars = c(var_ordem, descritivo), 
                variable.name = "tipo", value.name = "VL_ATUAL",  variable.factor = F)
  
  painel = painel[get(descritivo) != ""]
  
  painel[, VL_ATUAL := as.numeric(gsub("\\.", "", VL_ATUAL))]
  
  painel[] = lapply(painel, function(x){if(is.factor(x)) as.character(x) else x})
  
  
  if(referencia & tipo=="R") setnames(painel, c("receita_atual", "VL_ATUAL"), c("receita_ref", "VL_REF"))
  if(referencia & tipo=="D") setnames(painel, c("despesa_atual", "VL_ATUAL"), c("despesa_ref", "VL_REF"))
  
  return(painel)
}

valores_checar = function(base_teste, limiar){
  
  # =================================================================
  # No banco de teste para despesa e receita verifica quais linhas
  # VL_ATUAL está abaixo de (1 - limiar)*VL_REF e quais 
  # valores estão acima de (1 + limiar). Esses valores devem ser
  # checados com mais detalhes.
  # =================================================================
  
  
  base_teste[is.na(VL_ATUAL), VL_ATUAL:=0]
  base_teste[is.na(VL_REF), VL_REF:=0]
  base_teste[, CHECAR_Nvl_erro := FALSE]
  base_teste[abs(VL_REF)*(1 - limiar) > abs(VL_ATUAL) | abs(VL_REF)*(1 + limiar) < abs(VL_ATUAL), CHECAR_Nvl_erro:=TRUE]
  base_teste = base_teste[CHECAR_Nvl_erro==T]
  base_teste[, DIFF_ATUAL_REF := VL_ATUAL - VL_REF]
  return(base_teste[, CHECAR_Nvl_erro := NULL])
}

normaliza_descritivo_desp = function(base_desp){
  
  # =================================================================
  # Normaliza o descritivo das despesas, para conter
  # qual a categoria, grupo, poder e tipo de UO
  # determinado valor faz referência
  # =================================================================
  
  base_desp[grepl("^3\\-.+", ordem_desp), despesa_ref := "Corrente"]
  base_desp[grepl("^4\\-.+", ordem_desp), despesa_ref := "Capital"]
  base_desp[grepl("^9\\-.+", ordem_desp), despesa_ref := "Contigencia"]
  
  base_desp[grepl("^3\\-1.+", ordem_desp), despesa_ref := paste(despesa_ref, "Pessoal", sep=" -- ")]
  base_desp[grepl("^3\\-2.+", ordem_desp), despesa_ref := paste(despesa_ref, "Juros", sep=" -- ")]
  base_desp[grepl("^3\\-3.+", ordem_desp), despesa_ref := paste(despesa_ref, "Custeio", sep=" -- ")]
  
  base_desp[grepl("^4\\-4.+", ordem_desp), despesa_ref := paste(despesa_ref, "Investimento", sep=" -- ")]
  base_desp[grepl("^4\\-5.+", ordem_desp), despesa_ref := paste(despesa_ref, "Inversoes", sep=" -- ")]
  base_desp[grepl("^4\\-6.+", ordem_desp), despesa_ref := paste(despesa_ref, "Amortizacao", sep=" -- ")]
  
  base_desp[grepl("^\\d\\-.\\-1.+", ordem_desp), despesa_ref := paste(despesa_ref, "Executivo", sep=" -- ")]
  base_desp[grepl("^\\d\\-.\\-2.+", ordem_desp), despesa_ref := paste(despesa_ref, "Outros Poderes", sep=" -- ")]
  
  base_desp[grepl("^\\d\\-.\\-.\\-1.+", ordem_desp), despesa_ref := paste(despesa_ref, "Adm Direta", sep=" -- ")]
  base_desp[grepl("^\\d\\-.\\-.\\-2.+", ordem_desp), despesa_ref := paste(despesa_ref, "Adm Indireta", sep=" -- ")]
  
  base_desp[grepl("^\\d\\-.\\-.\\-.\\-1", ordem_desp), despesa_ref := paste(despesa_ref, "Autarquia e Fund", sep=" -- ")]
  base_desp[grepl("^\\d\\-.\\-.\\-.\\-2", ordem_desp), despesa_ref := paste(despesa_ref, "Empresas", sep=" -- ")]
  base_desp[grepl("^\\d\\-.\\-.\\-.\\-3", ordem_desp), despesa_ref := paste(despesa_ref, "Fundos", sep=" -- ")]
  
  return(base_desp)
}

checa_demonstrativo_consolidado = function(caminho_rec_ref, caminho_desp_ref, 
                                                    rec_atual = painel_rec_para_teste, 
                                                    desp_atual = painel_desp_para_teste, 
                                                    limiar){
  
  # =================================================================
  # Compara os paineis de receita e despesa gerados com os bancos de
  # referência. Retorna o banco com as principais alterações em 
  # logs/checar_valores_demonstrativo_consolidado_V1.csv
  # =================================================================
  
  
  # Receita
  painel_rec_ref = limpa_painel_rec_desp(caminho_rec_ref, referencia = T, tipo="R")
  painel_rec_atual = limpa_painel_rec_desp(rec_atual, referencia = F, tipo="R")
  painel_rec_atual[, ordem_rec := as.character(ordem_rec)]
  
  painel_rec_teste = merge(painel_rec_ref, painel_rec_atual, by=c("ordem_rec", "tipo"), all=T)
  painel_rec_teste = valores_checar(painel_rec_teste, limiar = limiar)
  setcolorder(painel_rec_teste, c("ordem_rec", "tipo", "receita_ref", "receita_atual", 
                                  "VL_REF", "VL_ATUAL", "DIFF_ATUAL_REF"))
  
  # Despesa
  painel_desp_ref = limpa_painel_rec_desp(caminho_desp_ref, referencia = T, tipo="D")
  painel_desp_atual = limpa_painel_rec_desp(desp_atual, referencia = F, tipo="D")
  
  painel_desp_teste = merge(painel_desp_ref, painel_desp_atual, by=c("ordem_desp", "tipo"), all=T)
  painel_desp_teste = valores_checar(painel_desp_teste, limiar = limiar)
  painel_desp_teste[is.na(despesa_ref), despesa_ref:=despesa_atual]
  painel_desp_teste[, despesa_atual := NULL]
  
  painel_desp_teste = normaliza_descritivo_desp(painel_desp_teste)
  
  setnames(painel_desp_teste, c("ordem_desp", "despesa_ref"), c("ordem", "desp_rec_referencia"))
  setnames(painel_rec_teste, c("ordem_rec", "receita_ref"), c("ordem", "desp_rec_referencia"))
  
  painel_teste = rbind(painel_rec_teste, painel_desp_teste, fill=T)
  
  cat("\nV1 T1: Principais diferencas na receita e despesa salvo em",
  "logs/checar_valores_demonstrativo_consolidado_V1.csv. limiar considerado", limiar, "\n")
  
  write.csv2(painel_teste, "logs/checar_valores_demonstrativo_consolidado_V1.csv", row.names = F)  
}


