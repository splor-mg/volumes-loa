# Informações Específicas para o Volume 2


## Tabela 3 DETALHAMENTO DA CATEGORIA DE PESSOAL

Em `/LOA/volume2/R/V2_Tabela3_DETALHAMENTO_DA_CATEGORIA_DE_PESSOAL.R` atualizar:

1- Vetor `codigos_inativos` atualmente:

```
7006 - PROVENTOS DE INATIVOS CIVIS E PENSIONISTAS e
7007 - PROVENTOS DE INATIVOS MILITARES; 
```

2- Vetor `desconsiderarUO` que são UO's extintas ou que simplesmente não devem ser consideradas:

```
1111 ERBR;
2391 IO/MG;
2401 IGA;
1461 SEDE;
2451 HIDROEX;
2401 IGTEC;
9207 SEPLAG-LEITOR-SISOR
```

## Tabela 3 FUNFIP DETALHAMENTO DE PESSOAL INATIVO CIVIL

Em `/LOA/volume2/R/V2_Tabela3_FUNFIP_DETALHAMENTO_DE_PESSOAL_INATIVO_CIVIL.R` atualizar:

1- O vetor `codigo_desconsiderar` que serve para desconsiderar essas ações no cálculo do valor para inativos do FUNFIP:

```
7008 - BENEFÍCIO PREVIDENCIÁRIO DE PENSÃO;
7016 - COMPENSAÇÃO PREVIDENCIÁRIA FINANCEIRA ENTRE REGIMES DE PREVIDÊNCIA; e 
7023 - PROVENTOS DE APOSENTADORIA E PENSÃO DE EXTINTOS CONVÊNIOS) 
```

2- O vetor `codigo_inativos` para não considerar nesse demonstrativo as UO's que possuem essas ações:

```
7006 - PROVENTOS DE INATIVOS CIVIS E PENSIONISTAS e
7007 - PROVENTOS DE INATIVOS MILITARES; 
```

3- O vetor `desconsiderar_uo` de UO's extintas ou que simplesmente não devem ser consideradas:

```
1111 ERBR;
2391 IO/MG;
2401 IGA;
1461 SEDE;
2451 HIDROEX;
2401 IGTEC;
9207 SEPLAG-LEITOR-SISOR
```

4- Renomear `bancos/manual/PESSOAL_INATIVO_AUSENTE_SISOR.xlsx`. Esse banco deve ser atualizado no caso em que há valores para inativos no banco `SISOR/BASE_QDD_FISCAL.xlsx` mas não foi inserido um quantitativo de inativos em `SISOR/BASE_CATEGORIA_PESSOAL.xlsx`. Daí esse quantitativo será informado manualmente nesse banco. Para que este seja considerado no código renomear para `bancos/manual/PESSOAL_INATIVO_AUSENTE_SISOR.xlsx`

## Tabela 4 DEMONSTRATIVO DOS RECURSOS FINANCEIROS

Em `/LOA/volume2/R/V2_Tabela4_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS.R` atualizar:

1- O vetor `desconsiderarUO`, atualmente apenas 9901 - RECEITA GERAL DO ESTADO.

## [Tabela5 DEMONSTRATIVO DOS RECURSOS FINANCEIROS](V2_T5_Wiki.md)

Em `/LOA/volume2/R/V2_Tabela5_DEMONSTRATIVO_DOS_RECURSOS_FINANCEIROS.R` atualizar:

1- Vetor `desconsiderarUO` atualmente apenas 9901;

2- `lista_recurso_ordinario` atualmente 10 e 12;

3- Vetor `uo_caso_especial` que remete ao caso em que parte 2 de Recursos Repassados pelo Tesouro Estadual não há uma divisão entre Despesa Corrente e de Capital **Desconsiderar dado que esse demonstrativo está sendo realizado apenas para a administração indireta**. atualmente 1091.

**ESSE DEMONSTRATIVO POSSUI UMA SÉRIE DE REGRAS COMPLEXAS PARA SEU DESENVOLVIMENTO. Ao clicar no título é possível ver como este demonstrativo é gerado.**




