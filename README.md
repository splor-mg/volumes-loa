# LOA

Este projeto tem por finalidade gerar uma versão em pdf dos volumes 2, 3, 4 e 5 bem como diversos demonstrativos do volume 1, referentes a [LEI ORÇAMENTÁRIA ANUAL](http://planejamento.mg.gov.br/planejamento-e-orcamento/orcamento-do-estado-de-minas-gerais). De forma detalhada, os volumes e tabelas geradas são:

- Volume I - Orçamento Fiscal e Orçamento de Investimento das Empresas Controladas
	- Tabela 4: Demonstrativo Despesa por Orgãos Entidades Segundo Grupos Despesa
	- Tabela 5: Demonstrativo Consolidado Categoria Pessoal
	- Tabela 7: Quadro Geral da Receita 
	- Tabela 9: Demonstrativo Receita Orcamentaria Corrente Ordinaria 
	- Tabela 14: Demonstrativo Despesa Funcao Subfuncao Programa Conforme Vinculo com Recursos 
	- Tabela 15: Programa Trabalho Governo 
	- Tabela 30: Investimentos segundo Funcoes 
	- Tabela 31: Investimentos segundo Funcoes Subfuncoes Programas por Projetos Atividades 
	- Tabela 32: Investimentos por Empresa segundo Fontes Recurso 
	- Tabela 33: Investimentos Empresa segundo Detalhamento Investimentos 
- Volume II - A: Orçamento Fiscal - Administração Direta e Administração Indireta
- Volume II - B: Orçamento Fiscal - Administração Direta e Administração Indireta
- Volume III: Orçamento de Investimento das Empresas Controladas pelo Estado
- Volume IV: Distribuição Territorial dos Investimentos
- Volume V: Quadro de Detalhamento da Despesa - QDD

## [Requerimentos](wiki/Requerimentos.md)

## [Tutoriais Latex](wiki/home_tutoriais.md)

## [Proposta enviada ao MG Inova, descrevendo o projeto e todas suas caracteristicas](wiki/mg_inova.md)

## Inicialização do Projeto

A criação dos volumes depende da atualização de uma série de informações. Os passos para a atualização dos volumes que são de perspectiva geral são:

1- Atualizar `utils/ano.txt`;


2- Atualizar as bases de dados no diretório `bancos/`:

- Em `bancos/SISOR` espera-se os seguintes bancos:
	- acoes_planejamento.txt (ou .xlsx);
	- BASE_CATEGORIA_PESSOAL.xls
	- BASE_DETALHAMENTO_OBRAS.xls
	- BASE_ORCAM_DESPESA_ITEM_FISCAL.xls (Apenas demonstrativos V1 da DCGF)
	- BASE_ORCAM_RECEITA_FISCAL.xls
	- BASE_QDD_FISCAL.xls
	- BASE_QDD_INVESTIMENTO.xls
	- BASE_REPASSE_RECURSOS.xls
	- exec_desp_realizada.xls (Apenas demonstrativos V1 da DCGF)
	- exec_rec.xls (Apenas demonstrativos V1 da DCGF)
		

- Em `bancos/manual` há arquivos que são atualizados manualmente. 
	- Os bancos com o prefixo `ANEXO` montam tabelas independentes que não há nenhum teste de consistência. Assim, devem ser analisados previamente e alterados caso necessário;
	- Renomear o arquivo `PESSOAL_INATIVO_AUSENTE_SISOR.xlsx` para este não ser considerado na execução do volume 2; 
	- Não há nenhum teste de validação para `correspondencia_mun_terr_desenvol.xlsx`. Assim, o que for informado será exibido no volume 4;
	- Para os demais arquivos caso não exista uma informação, os scripts lançarão avisos. Assim, inicialmente o projeto pode rodar com os valores iniciais e caso necessário alterar.
		

- Em `bancos/R` há arquivos auxiliares que são estruturados por scripts no R. Em especial, alimentam o volume 3. Caso falte informações nesses arquivos, avisos serão lançados.
	

3- Demandar o arquivo `.pdf` com as capas dos volumes. Renomear para `capaLOA.pdf` e inserir esse arquivo em todas as pastas `LOA\volume#\Rnw`. Ainda é necessário alterar as páginas de capa utilizadas nos arquivos `Projeto_volume#.Rnw`. Exemplo de alteração para `Projeto_volume5.Rnw`:



```
[...]
% Capa
\begin{titlepage}
\newgeometry{top=0cm, right=0cm, left=-6cm, bottom=0cm}
\includepdf[pages={6},scale=1.1]{capaLOA.pdf} % No arquivo capaLOA.pdf a capa do volume 5 está na página 6.
\end{titlepage}
% \capa
[...]
```

4- Converter os bancos `.xls` para `.xlsx` e tratar caracteres especiais possivelmente presentes nos arquivos `.txt`. Esse passo será realizado a partir do seguinte comando make
```
make format
```

5- Atualizar o pacote relatorios, necessário para montar os demonstrativos do volume 1 de responsabilidade da DCGF. No console do RStudio, rodar:

```
devtools::install_bitbucket("dcgf/relatorios", 
							 auth_user = "dcgf-admin", 
							 password = "demandar-senha-DCGF", 
							 dependencies=F)
```

[24-08-2020 - ANDREY] A nome de usuário que deve ser utilizado agora é dcgf.scppo@gmail.com

O pacote relatórios tem como dependência os pacotes reest e execucao. Instalar estes pacotes antes, caso necessário.

**Versão de relatórios utilizada na LOA 2018: 0.5.76**


6- Demandar a atualização das seguintes informações: 


- [Informações Específicas para o volume 5](wiki/volume5_info.md)
- [Informações Específicas para o volume 4](wiki/volume4_info.md)
- [Informações Específicas para o volume 3](wiki/volume3_info.md)
- [Informações Específicas para os volumes 2A e 2B](wiki/volume2_info.md)
- [Informações Específicas para os volume 1](wiki/volume1_info.md)



7- Remover todos os bancos `.txt` utilizados na estruturação dos volumes. Isso evitará a manutenção de arquivos para UO's que não existem mais. Os comandos para remover todos os arquivos de cada volume são:


```
make rm vol=2
make rm vol=3
make rm vol=4
make rm vol=5
make rm vol=logs
```


8- Atualizar todos os bancos `.txt` e gerar os arquivos dos volumes `.pdf`. Esse passo pode ser realizado pelos comandos make. Sugere-se montar volume por volume, do mais fácil para o mais dificil segundo a orgem abaixo:

```
make v5
make v4
make v3
make v2
make v1
```
