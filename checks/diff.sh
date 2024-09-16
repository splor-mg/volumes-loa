#!/bin/bash

if [ $# -ne 1 ]; then
  echo 1>&2 "$0: please pass one argument naming the document to test"
  exit 2
elif [ $1 == "Projeto_volume2A" ]
then vol="volume2"
elif [ $1 == "Projeto_volume2B" ]
then vol="volume2"
elif [ $1 == "Projeto_volume3" ]
then vol="volume3"
elif [ $1 == "Projeto_volume4" ]
then vol="volume4"
elif [ $1 == "Projeto_volume5" ]
then vol="volume5"
elif [ $1 == "Projeto_volume6A" ]
then vol="volume6"
elif [ $1 == "Projeto_volume6B" ]
then vol="volume6"
elif [ $1 == "Projeto_volume7" ]
then vol="volume7"
elif [ $1 == "T2_DCGF_DEMONSTRATIVO_RECEITA_CORRENTE_FISCAL" ]
then vol="volume1"
elif [ $1 == "T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas" ]
then vol="volume1"
elif [ $1 == "T4_DEMONSTRATIVO_DESPESA_POR_ORGAOS_ENTIDADES_SEGUNDO_GRUPOS_DESPESA" ]
then vol="volume1"
elif [ $1 == "T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL" ]
then vol="volume1"
elif [ $1 == "T6_DCGF_Demonstrativo_Evolucao_Receita_por_Categoria_Economica" ]
then vol="volume1"
elif [ $1 == "T7_QUADRO_GERAL_DA_RECEITA" ]
then vol="volume1"
elif [ $1 == "T8_DCGF_RECEITA_CORRENTE_LIQUIDA" ]
then vol="volume1"
elif [ $1 == "T9_DEMONSTRATIVO_RECEITA_ORCAMENTARIA_CORRENTE_ORDINARIA" ]
then vol="volume1"
elif [ $1 == "T12_DCGF_Demonstrativo_Evolucao_Despesa_Categoria_Economica" ]
then vol="volume1"
elif [ $1 == "T13_DCGF_Demonstrativo_Consolidado_Despesa" ]
then vol="volume1"
elif [ $1 == "T14_DEMONSTRATIVO_DESPESA_FUNCAO_SUBFUNCAO_PROGRAMA_CONFORME_VINCULO_COM_RECURSOS" ]
then vol="volume1"
elif [ $1 == "T15_PROGRAMA_TRABALHO_GOVERNO" ]
then vol="volume1"
elif [ $1 == "T16_DCGF_Demons_Aplicacao_Recursos_Manut_Desenv_Ensino" ]
then vol="volume1"
elif [ $1 == "T17_DCGF_Demonst_Aplicacao_Recursos_Progr_Saude_Investim" ]
then vol="volume1"
elif [ $1 == "T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude" ]
then vol="volume1"
elif [ $1 == "T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa" ]
then vol="volume1"
elif [ $1 == "T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF" ]
then vol="volume1"
elif [ $1 == "T23_DCGF_Demonstrativo_do_Servico_da_divida_publica" ]
then vol="volume1"
elif [ $1 == "T25_DCGF_Demonstrativo_Aplicacao_Recursos_FUNDEB" ]
then vol="volume1"
elif [ $1 == "T26_DCGF_DEMONSTRATIVO_RECURSOS_APLICADOS_ACOES_PARA_CRIANCA_E_ADOLESCENTE" ]
then vol="volume1"
elif [ $1 == "T27_DCGF_Demonst_Despesas_UGEPREVI" ]
then vol="volume1"
elif [ $1 == "T28_DCGF_PT1_Receita_prevista_e_realizada" ]
then vol="volume1"
elif [ $1 == "T28_DCGF_PT2_Despesa_prevista_e_realizada" ]
then vol="volume1"
elif [ $1 == "T28_DCGF_PT3_Receita_prevista_LOA" ]
then vol="volume1"
elif [ $1 == "T28_DCGF_PT4_Despesa_prevista_LOA" ]
then vol="volume1"
elif [ $1 == "T30_INVESTIMENTOS_SEGUNDO_FUNCOES" ]
then vol="volume1"
elif [ $1 == "T31_INVESTIMENTOS_SEGUNDO_FUNCOES_SUBFUNCOES_PROGRAMAS_POR_PROJETOS_ATIVIDADES" ]
then vol="volume1"
elif [ $1 == "T32_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_RECURSO" ]
then vol="volume1"
elif [ $1 == "T33_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS" ]
then vol="volume1"
elif [ $1 == "T37_DCGF_DEMONSTRATIVOS_RECURSOS_APLICADOS_SEGURANCA_ALIMENTAR_NUTRICIONAL" ]
then vol="volume1"
elif [ $1 == "T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS" ]
then vol="volume1"
elif [ $1 == "T39_DCGF_DEMONSTRATIVO_DA_POLITICA_DE_ATENDIMENTO_A_MULHER_VITIMA_DE_VIOLENCIA_NO_ESTADO" ]
then vol="volume1"
else
   echo "$1 is not a valid document"
   exit 2
fi

diff "$vol"/pdf/aux_files/"$1".tex checks/assets/tex/"$1".tex > /dev/null 2>&1
diff_tex=$?

printf "Results:"

if [ $diff_tex -eq 0 ]
then
   printf "."
elif [ $diff_tex -eq 1 ]
then
   printf "F"
fi

diff-pdf pdf/"$1".pdf checks/assets/pdf/"$1".pdf > /dev/null 2>&1
diff_pdf=$?

if [ $diff_pdf -eq 0 ]
then
   printf "."
elif [ $diff_pdf -eq 1 ]
then
   printf "F"
fi

printf "\n"

if [ $diff_tex -eq 1 ]
then
   echo "Failure testing $1.tex"
   diff -u checks/assets/tex/"$1".tex "$vol"/pdf/aux_files/"$1".tex | diff-so-fancy
   echo "==================================="
fi

if [ $diff_pdf -eq 1 ]
then
   echo "Failure testing $1.pdf"
   diff-pdf -vsm --output-diff="$1"-diff.pdf pdf/"$1".pdf checks/assets/pdf/"$1".pdf
   echo "pdf diff saved at $1-diff.pdf"
fi
