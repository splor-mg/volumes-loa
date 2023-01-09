# Correções para fonte 10

if(length(f_c_rec_ord[!f_c_rec_ord %in% 10])>0){ # Há mais que 10
  
  registroLog(paste("A correção para recurso ordinário que aparece tanto em qdd_ajustado quanto em Receita considera",
                    "apenas o caso da fonte 10. Existe fonte 12 também. A correção mesmo assim será executada, mas pode",
                    "incorrer em erro. Favor verificar"), "aviso")
  
}

# =================================================================================================
# Proceder com correção para a fonte 10, mesmo que haja fonte 12 na fonte com receita do conjunto
# de recursos ordinários (f_c_rec_ord)
# =================================================================================================
    
descricao_receitas = receita[COD_UO==codigo_uo & COD_FONTE %in% f_c_rec_ord, unique(RECEITA)]
    
valor_rec_subtrair = matching_fontes[FONTE %in% f_c_rec_ord, sum(valor_rec, na.rm=T)]

for(desc in descricao_receitas){
  registroLog(desc, "aviso")
  }
    
r_tesouro_f10 = qdd_ajustado[COD_UO==codigo_uo & FONTE %in% f_c_rec_ord, 
                             list(valor_qdd = sum(valor, na.rm=T)), 
                             by=list(COD_UO, FONTE, FUNCAO, CATEGORIA)]

padrao_rec_saude = "Fundo Estadual de Sa.de|141/2012"    

if(sum(as.numeric(grepl(padrao_rec_saude, descricao_receitas, ignore.case = T))) == length(descricao_receitas)){
  
  # =================================================================================================
  # Se todas as descrições de receita forem relacionadas ao FES, podemos realizar a dedução do valor
  # em função 10
  # =================================================================================================
  
  registroLog(paste("Como todas as receitas são provenientes do FES realizar a correção reduzindo o valor",
                    formatarNum(valor_rec_subtrair), "de BASE_QDD_FISCAL a partir do filtro da função 10"), "aviso")

  registroLog(paste("O filtro de função 10 em BASE_QDD_FISCAL é igual ao valor restante de",
                    formatarNum(valor_rec_subtrair), " em 1.RECEITA PRÓPRIA?"), "aviso")


    if(r_tesouro_f10[FUNCAO==10, sum(valor_qdd)]==valor_rec_subtrair){
      
      registroLog(paste("Sim! Podemos proceder com a correção de retirar os valores de função 10 e ",
                        "incorporar o valor restante no demonstrativo 2 REPASSE DO TESOURO ESTADUAL"), "aviso")
      
      } else{
        
        registroLog(paste("Não! O valor da função 10 em BASE_QDD_FISCAL é de",
                          formatarNum(r_tesouro_f10[FUNCAO==10, sum(valor_qdd)]),
                          "diferente de", formatarNum(valor_rec_subtrair), ". Contudo, como é recurso",
                          " do FES a correção proposta a partir da exclusão da função 10",
                          " será realizada\n"), "erro")
        }
      
      receita_uo = receita_fonte[COD_UO==codigo_uo & COD_FONTE %in% f_c_rec_ord,]
      receita_uo[, FUNCAO := 10]
      
      
      if(nrow(r_tesouro_f10[FONTE==10 & FUNCAO==10, ])>1){
        
        # =======================================================================================================
        #
        # Ao agregar qdd_ajustado por COD_UO, FONTE, FUNCAO, CATEGORIA, podemos incorrer na situação que 
        # para a função 10 existam valores para as CATEGORIAS 3 e 4. Nesse caso, NÃO SABEMOS de qual
        # categoria deduzir o valor de receita_uo na fonte 10. Para esse caso queremos realizar a dedução
        # do valor e apresentar apenas o valor total no demonstrativo 2, ou seja, tornamos a UO em questão
        # na situação de uo_caso_especial (demonstrativo 2 sem a discriminação de despesa corrente e de capital)
        #
        # =======================================================================================================
        r_tesouro_f10[FONTE==10 & CATEGORIA==3, FUNCAO:=0]
        
        uo_caso_especial = append(uo_caso_especial, codigo_uo)
        
      }

      r_tesouro_f10 = mergeDT(r_tesouro_f10, receita_uo, by.x=c("COD_UO", "FUNCAO"), by.y=c("COD_UO", "FUNCAO"), all=T)
      
      r_tesouro_f10[is.na(valor), valor :=0]
      r_tesouro_f10[, valor_qdd := valor_qdd - valor]
      
      
  } else{
    
     # ============================================================================================
     # No caso da descrição da receita ser diferente de FES, ou inserimos essa UO no caso especial
     # ou devemos codificar uma nova solução.
     # ============================================================================================
      
     registroLog(paste("As receitas possuem fontes distintas da FES. Estamos em um caso especial? Ex. 1091?"), "aviso")

  if(codigo_uo %in% uo_caso_especial){

    registroLog(paste("Sim! Proceder com a construção do demonstrativo 2 sem o detalhamento de",
                      " despesa corrente ou de capital"), "nota")

    r_tesouro_f10 = rbind(r_tesouro_f10, 
                          data.table(COD_UO=codigo_uo, FONTE=10, FUNCAO=NA, 
                                     CATEGORIA=NA, valor_qdd = valor_rec_subtrair*(-1)))
    
    } else{
      registroLog(paste("Não! Reportar e codificar nova solução."), "erro")
    }
   }
 