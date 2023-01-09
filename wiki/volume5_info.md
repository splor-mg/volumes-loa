# Informações Específicas para o Volume 5


A informação necessária para o volume 5 é de carater gerencial. Para a LOA de 2018, as UO's dos Outros Poderes fizeram uma proposta de despesa diferente da especificada pela SEPLAG, seguindo a Lei Complementar 156/16 e Decreto Federal nº 9.056/17. Essa diferença foi apresentada apenas no Quadro de Detalhamento da Despesa do Volume 5. Um exemplo desse novo template está presente em `LOA/volume5/pdf/1011.pdf`

Essa possibilidade foi incorporada no projeto para 2019, incorporando os seguintes passos:

1. Adicionar a base `bancos/SISOR/BASE_QDD_FISCAL_PROPOSTA.xlsx` que corresponde ao QDD_FISCAL com os novos valores de despesa, inseridos na coluna `VALOR FINAL (R$)`

2. Atualizar o vetor `uos_proposta` em `volume5/R/volume5.R` com os códigos de UO's que devem ser apresentadas as colunas `PROPOSTA DO ÓRGÃO` e `IMPORTÂNCIA` nesse demonstrativo. Atualmente esse vetor só possui UO's dos Outros Poderes.


**TODO: Para os testes realizados, ocorreu um problema na continuidade do traço da borda de algumas tabelas QDD**
