# DEMONSTRATIVO DOS RECURSOS FINANCEIROS

O Demonstrativo dos Recursos Financeiros apresenta os recursos que a Unidade Orçamentária dispõe para o exercício. Em suma esse demonstrativon apresenta:

## Receita Própria

Receita arrecadada pela UO. Informação obtida pelo banco `SISOR/BASE_ORCAM_RECEITA_FISCAL.xlsx`.

## Recursos Repassados pelo Tesouro Estadual

Recursos repassados pelo RGE. Há várias fontes que apenas o RGE arrecada (10, 12, 51, 71 dentre outras), mas a execução da despesa é realizada pelas Unidades Orçamentárias. Os valores dessa seção são obtidos via o banco `SISOR/BASE_QDD_FISCAL`. 

O QDD_FISCAL já considera os repasses de recursos efetuados pelos órgãos. Ou seja, os recursos transferidos pelas UO's **já foram deduzidos dessas UO's credoras**, bem como os recursos recebidos pelas UO's **já foram creditados a essas UO's beneficiadas**. 

Contudo o que foi recebido por cada UO é contabilizado no demonstrativo **Recursos Recebidos de Órgãos e Entidades do Orçamento Fiscal**, bem como o que é transferido é apresentado em **Recursos Repassados de Órgãos e Entidades do Orçamento Fiscal**. Para evitar dupla contagem em ambos os casos, é necessário modificar a BASE_QDD_FISCAL, gerando o que foi denominado QDD Ajustado.


### QDD Ajustado

O objetivo deste banco é retornar os recursos as UO's que financiam ações de outras UO's e deduzir esses recursos das UO's financiadas. Entende-se que esse banco mostra a quantidade de recursos que cada UO dispõe, salvo os processos de transfências de recursos. O ganho desse procedimento é não somar duas vezes os recursos no caso em que a UO é financiada, bem como não deduzir duplamente os recursos no caso em que a UO é financiadora.

Os repasses de recursos entre UO's está descrito no banco `SISOR/BASE_REPASSE_RECURSOS.xlsx`. As UO's que repassam recursos para outras são consideradas na coluna `UO Financiadora`. Espera-se que todo esse repasse seja realizado no IPU 2 e IPU 5 no caso do FUNFIP. Já as UO's que recebem recursos estão consideradas na coluna `UO Beneficiada`. A partir desse banco, estrura-se os recursos que devem ser creditados as UO's financiadoras (objeto `uo_financiadora em trataQDD_Ajustado()`):

```
uo_financiadora = transf[ipu==2 | (ipu==5 & cod_uo_financ==funfip),
                           list(valor=sum(valor, na.rm=T)), 
                           by= list(COD_UO = cod_uo_financ, 
                                    UO = uo_financ, 
                                    CATEGORIA, 
                                    GRUPO_DESPESA=grupo_de_despesa, 
                                    FONTE = fonte, 
                                    IPU = ipu, 
                                    IAG = iag)]
```


Uma vez estruturado o banco dos recursos das UO's financiadoras, deve-se deduzir do QDD os recursos creditados as UO's beneficiadas. Para o caso do IPU 5 financiado pelo FUNFIP, são deduzidos apenas recursos no IPU 5 creditados às UO's que o FUNFIP beneficiou. Isso é descrito pelos seguintes códigos em `trataQDD_Ajustado()`:

```
  funfip_uo_beneficiadas = transf[ipu==5 & cod_uo_financ==funfip, 
                                  list(valor=sum(valor, na.rm=T)), 
                                  by= list(COD_UO = cod_uo_benef, 
                                           CATEGORIA, 
                                           GRUPO_DESPESA=grupo_de_despesa,
                                           FONTE = fonte, 
                                           IPU = ipu, 
                                           IAG = iag)]

  for(j in 1:nrow(funfip_uo_beneficiadas)){
  
    COD_UO1 = funfip_uo_beneficiadas$COD_UO[j]
    GRUPO_DESPESA1 = funfip_uo_beneficiadas$GRUPO_DESPESA[j]
    FONTE1 = funfip_uo_beneficiadas$FONTE[j]
    IPU1 = funfip_uo_beneficiadas$IPU[j]
    
    linhas = which(qdd_ajustado$COD_UO == COD_UO1 & 
                   qdd_ajustado$GRUPO_DESPESA == GRUPO_DESPESA1 & 
                   qdd_ajustado$FONTE == FONTE1 & 
                   qdd_ajustado$IPU == IPU1 )
  
    qdd_ajustado = qdd_ajustado[!(linhas),]
    
  }
```

Os demais recursos repassados no IPU 2 são retirados do QDD simplesmente com `qdd_ajustado[IPU!=2,]`. 
Há testes que garantem que o valor deduzido é igual ao valor somado.


### Procedimentos para gerar o Repasse de Recursos do Tesouro

O Repasse de Recursos do Tesouro depende do QDD ajustado e da Receita Própria da UO. Se a UO não possui receita própria, os valores no qdd ajustado são integralmente considerados como sendo repasse do tesouro. Se não, o valor da receita própria deve ser deduzido do valor apresentado no QDD, o que envolve uma série de condicionais.

1- Se o valor no qdd ajustado para fontes em recursos vinculados (diferente de Fonte 10) for **maior** que o valor da receita nessas fontes, constitui-se uma situação não esperada. Para a maioria das fontes, espera-se que receita seja igual a despesa. Para LOA 2019 houve a excessão da Fonte 51 para o DEER-MG, que arrecadou R$1 milhão mas tinha despesas (expressos no qdd ajustado) da ordem de R$118 milhões. A diferença deve ser atribuida a um Repasse do Tesouro (representado pelo RGE).

2- Se o valor no qdd ajustado para fontes em recursos ordinários for **maior** que o valor da receita nessas fontes, procede-se com correção.
  
  2.1- Se a Receita arrecadada pela UO for fonte 10 e a descrição tiver **Fudo Estadual de Saúde|141/2012**, subtrair esse valor da receita no qdd ajustado para o UO em questão, fonte 10 e função 10;
  
  2.2- Se forem **mais receitas que apenas FES 141 2012** pode se tratar de um caso especial. No caso especial, simplesmente é deduzido esse recurso de fonte 10 do qdd ajustado, sem fazer distinção se o recurso está sendo retirado de uma despesa corrente ou de capital. Assim, no demonstrativo não há esse detalhamento. Se a UO não estiver no caso especial, necessita-se codificar uma nova solução.

#### Caso Especial

O `caso especial` surgiu no orçamento de 2016. O Ministério Público (1091) orçou receitas na fonte 10 que nada tinham a ver com Constitucional Saúde. Em especial, o órgão orçou Remuneração de Depósitos Bancários, Outras Indenizações, Outras Restituições e Outras Receitas. O total de receitas orçados em fonte 10 foi em torno de R$4,8 milhões, enquanto sua despesa orçada foi de R$1,5 bilhão. 

A diferença entre a despesa e receita deve ser incluída na parte de Repasse do Tesouro. Entretanto, no momento de subtrair a receita da despesa, não foi possível identificar o quanto deveria ser retirado de cada categoria de despesa, dado que as receitas não possuem correspondência com a função da despesa. Assim, para esse caso o quadro de Repasse do Tesouro Estadual não vinha discrminado entre corrente/capital.


## Recursos Recebidos de Órgãos e Entidades do Orçamento Fiscal

Recursos recebidos pela UO provenientes de outras UO's pertencentes ao Governo Estadual. Esses valores são obtidos pelo banco `/SISOR/BASE_REPASSE_RECURSOS.xlsx` considerando a UO em questão como uma UO beneficiada.

## Recursos Repassados de Órgãos e Entidades do Orçamento Fiscal

Recursos transferidos pela UO a outras UO's pertencentes ao Governo Estadual. Esses valores são obtidos pelo banco `SISOR/BASE_REPASSE_RECURSOS.xlsx` considerando a UO em questão como uma UO financiadora.
