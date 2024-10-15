# Informações Específicas para o Volume 1

# Demonstrativos anteriormente desenvolvidos pela PRODEMGE

## Tabela 14 DEMONSTRATIVO DESPESA FUNCAO SUBFUNCAO PROGRAMA CONFORME VINCULO COM RECURSOS

Em `/LOA/volume1/R/T14_DEMONSTRATIVO_DESPESA_FUNCAO_SUBFUNCAO_PROGRAMA_CONFORME_VINCULO_COM_RECURSOS.R` atualizar:

1- Vetor `rec_ordinarios`, atualmente 10 e 12 (fontes que identificam recursos ordinários);

2- `rec_diretamente_arrec` atualmente 60, 61 (fontes que identificam recursos diretamente arrecadados)


## Tabela 8 RECEITA CORRENTE LÍQUIDA

Demonstrativo testa sua memória com `relatorios::is_rcl()`. Avaliar essa função para identificar possíveis mudanças.

Verificar com a DCAF se as linhas VII e VIII passaram a possuir critérios de identificação (fonte ou código de receita):
- 38.0.(-) Transf. da União relativas a remuneração dos agentes comunitários de saúde e de combate às endemias (CF, art. 198, § 11 (VII) 
- 39.0.(-) Outras Deduções Constitucionais ou Legais (VIII)

Se sim, deve ser solicitado à DCAF a criação de funções no pacote `relatorios` com a memória de cálculo adequada e essas serem incluídas no código, retirando a inserção temporária feita pelo dataframe `MDF14_lines`.


## Tabela 9 DEMONSTRATIVO RECEITA ORCAMENTARIA CORRENTE ORDINARIA

Em `/LOA/volume1/R/T9_DEMONSTRATIVO_RECEITA_ORCAMENTARIA_CORRENTE_ORDINARIA.R:` atualizar:

1- Atualizar vetor `rec_ordinarios`, atualmente 10 e 12 (fontes que identificam recursos ordinários)

# Demonstrativos anteriormente desenvolvidos pela DCGF

## Tabela 1 Demonstrativo Consolidado do Orçamento Fiscal

1- Implementei um teste que verifica se os valores gerados para a LOA atual são semelhantes aos apresentados na LOA do ano passado. Os agregados de receita e despesa que apresentarem valores muito discrepantes serão salvos em `logs/checar_valores_demonstrativo_consolidado_V1.csv`. Para a realização concisa deste teste é necessário:

- Renomear os arquivos `\utils\suporte\V1\painel_desp[ANO_LOA -1].csv` e `\utils\suporte\V1\painel_rec[ANO_LOA -1].csv` para `painel_desp.csv` e `painel_rec.csv`. Manter esses arquivos no mesmo diretório `\utils\suporte\V1\`. Estes arquivos correspodem aos paineis da receita e despesa para a LOA passada;

- Definir a variável `limiar` que indica o grau de semelhança entre os valores da LOA passada (VL_REF) em relação aos valores da LOA atual (VL_ATUAL). De forma direta, serão considerados anormais qualquer rubrica de despesa e receita onde: `VL_REF*(1-limiar) > VL_ATUAL` ou `VL_REF*(1+limiar) < VL_ATUAL`. **Atualmente a variável limiar tem como default o valor de 0.7**. Para alterar esse valor deve-se modificar um parâmetro limiar na função `checa_demonstrativo_consolidado(..., limiar = 0.7)` em `volume1\R\T1_DCGF_Demonstrativo_Consolidado_Orcamento_Fiscal.R`. Os valores discrepantes serão salvos em `logs`

- Analisar com cautela o arquivo `logs/checar_valores_demonstrativo_consolidado_V1.csv`, pois este tende a duplicar valores. Por exemplo, grandes alterações no ICMS principal na **receita ordinária** geralmente são replicadas no ICMS principal em **receita total**. Por sua vez, uma grande alteração em **Operações de Crédito** leva a alterações em **Receitas de Capital**. Assim, analisar o arquivo identificando sempre os menores níveis de detalhe.

2- Com base nos resultados do teste, revisar as regras de categorização da receita e despesa presentes em `utils\suporte\V1\demonstr_consolidado.R` (receita) e `volume1\R\T1_DCGF_Demonstrativo_Consolidado_Orcamento_Fiscal.R` (despesa)

3- O projeto não gera o pdf diretamente, apenas um arquivo em `volume1/data/T1_DEMONSTRATIVO_CONSOLIDADO_ORCAMENTO_FISCAL.csv`. Com base nos valores calculados, colar valores em `volume1/docs/T1_Demonstrativo_Consolidado_do_Orcamento_Fiscal2018.xlsx` e via excel gerar o pdf

Depende de `relatorios::is_outros_poderes()`.


## Tabela 6 Demonstrativo da Evolução da Receita por Categoria Econômica

Em `/LOA/volume1/R/T6_DCGF_Demonstrativo_Evolucao_Receita_por_Categoria_Economica.R` é necessário a tabela `add_de_para_receita_tbl` presente em `relatorios` atualizada. 

Receitas  de convênios, operações de crédito e outras receitas de capital não precisam de um de-para por detalhe.

## Tabela 16 Demonstrativo da Aplicação de Recursos na Manutenção e no Desenvolvimento do Ensino

Necessário revisão, devido a nova Codificação da receita, da distribuição das receitas do constitucional educação em:
A. Impostos livres e transferência Livre;
B. Imposto e transferência Federais;
C. Outras Receitas.

Demonstrativo testa sua memória com `relatorios::is_mde_rec()` e `relatorios::is_perda_fundeb()`. Avaliar essa função para identificar possíveis mudanças.


## Tabela 18 Demonstrativo da Aplicação de Recursos em Ações e Serviços Públicos de Saúde

Demonstrativo testa sua memória com `relatorios::is_asps_rec()`. Avaliar essa função para identificar possíveis mudanças.


## Tabela 19 Demonstrativo da Aplicação de Recursos no Amparo e Fomento à Pesquisa

Utiliza em seu cálculo `relatorios::is_fapemig_rec()` e `relatorios::is_fapemig_desp()`. Avaliar essa função para identificar possíveis mudanças.


## Tabela 20A Demonstrativo da Participação Percentual de Pessoal na Receita Corrente Líquida

Utiliza em seu cálculo as seguintes funções:
1- `relatorios::is_rcl()`
2- `relatorios::is_dtp()`
3- `relatorios::is_legislativo()`
4- `relatorios::is_tce()`
5- `relatorios::is_judiciario()`
6- `relatorios::is_pgj()`

## Tabela 23 Demonstrativo do Serviço da Dívida Pública

Em `LOA/volume1/R/T23_DCGF_Demonstrativo_do_Servico_da_divida_publica.R` atualizar:

1- Vetor que identifica as ações referentes a dívida interna:

```
7886 GESTÃO DA DÍVIDA FUNDADA CONTRATUAL INTERNA;
7030 ENCARGOS DEVIDOS POR FINANCIAMENTO JUNTO AO INSTITUTO NACIONAL DA SEGURIDADE SOCIAL - INSS;
7043 ENCARGOS DEVIDOS POR FINANCIAMENTO JUNTO AO PROGRAMA DE FORMAÇÃO DO PATRIMÔNIO DO SERVIDOR PÚBLICO - PASEP;
7658 ENCARGOS DEVIDOS POR FINANCIAMENTO JUNTO AOS INSTITUTOS DE PREVIDÊNCIA DOS SERVIDORES MILITARES DO ESTADO DE MINAS GERAIS - IPSM
```

2- Vetor que identifica as ações referentes a dívida externa:
```
7896 GESTÃO DA DÍVIDA FUNDADA CONTRATUAL EXTERNA
```
3- Dívida principal é identificada por GRUPO 6 e acessória por GRUPO 2.

## Tabela 25 Demonstrativo da Aplicação dos Recursos do Fundo de Desenvolvimento da Educação Básica e Valorização dos Profissionais da Educação

Confirmar com DCAF se a memória de cálculo da função [`relatorios::is_pessoal_fundeb`](https://bitbucket.org/dcgf/relatorios/src/master/R/is_pessoal_fundeb.R) está atualizada.


## Tabela 26 Demonstrativo de Recursos a serem aplicados Direta ou Indiretamente em Ações voltadas para a criança e o adolescente

Em `LOA/volume1/R/T26_DCGF_DEMONSTRATIVO_RECURSOS_APLICADOS_ACOES_PARA_CRIANCA_E_ADOLESCENTE.R` atualizar:

1- Verificar se as regras que identificam ações para criança e adolescente bem como as ações exclusivas necessitam de atualização.
2- Solictar o índice da população de criança e adolescente à DCPPN para substituí-lo no arquivo `utils/volume1/indice_crianca_adolescente.txt`. O indíce é um valor decimal, com separador `.` (padrão americano) e deve conter uma linha em branco ao seu final.


## Tabela 27 Demonstrativo  das  despesas  da  Unidade  de  Gestão Previdenciária  Integrada  -  UGEPREVI

Em `LOA/volume1/R/T27_DCGF_Demonst_Despesas_UGEPREVI.R` UGEPREVI deve ser igual as despesas previdenciárias presentes em `LOA/volume1/R/T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS.R`


## Tabela 28 Demonstrativo dos programas financiados com recursos provenientes da União

Dividido em 4 scripts. Todos estes dependem do vetor de fontes que identificam recursos provenientes da União denominado `fontes_uniao` em `LOA/volume1/R/T28_DCGF_Demonstrativo_programas_financiados_com_recursos_provenientes_Uniao.R`

```
22, 24, 36, 37, 38, 56, 57, 73, 84, 85, 86, 87, 92, 93
```

1- Em `LOA/volume1/R/T28_DCGF_PT1_Receita_prevista_e_realizada.R` há a dependência de `bancos/SISOR/exec_rec.xlsx` do ano do exercício para o mês de agosto fechado;
2- Em `LOA/volume1/R/T28_DCGF_PT2_Despesa_prevista_e_realizada.R` há a dependência de `bancos/SISOR/exec_desp_realizada.xlsx` do ano do exercício para o mês de agosto fechado. O banco exec_desp_realizada.xlsx consiste na consulta exec_desp.xlsx presente no BO da DCGF, adicionando o campo `Valor Despesa Realizada`.


## Tabela 37 Demonstrativos de Recursos a serem aplicados direta ou indiretamente na execução da Política Estadual de Segurança Alimentar e Nutricional Sustentável

1- Verificar se as regras que identificam as ações voltadas para Segurança alimentar e nutricional estão corretas.

