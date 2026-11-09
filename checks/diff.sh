#!/bin/bash

if [ $# -ne 1 ]; then
  echo 1>&2 "$0: please pass one argument naming the document to test"
  exit 2
elif [ $1 == "volume2" ]
then vol="volume2"
elif [ $1 == "volume3" ]
then vol="volume3"
elif [ $1 == "volume4" ]
then vol="volume4"
elif [ $1 == "volume5" ]
then vol="volume5"
elif [ $1 == "Projeto_volume6A" ]
then vol="volume6"
elif [ $1 == "volume7" ]
then vol="volume7"
elif [ $1 == "tabela1" ]
then vol="volume1"
elif [ $1 == "tabela2" ]
then vol="volume1"
elif [ $1 == "tabela3" ]
then vol="volume1"
elif [ $1 == "tabela4" ]
then vol="volume1"
elif [ $1 == "tabela5" ]
then vol="volume1"
elif [ $1 == "tabela6" ]
then vol="volume1"
elif [ $1 == "tabela7" ]
then vol="volume1"
elif [ $1 == "tabela8" ]
then vol="volume1"
elif [ $1 == "tabela9" ]
then vol="volume1"
elif [ $1 == "tabela12" ]
then vol="volume1"
elif [ $1 == "tabela13" ]
then vol="volume1"
elif [ $1 == "tabela14" ]
then vol="volume1"
elif [ $1 == "tabela15" ]
then vol="volume1"
elif [ $1 == "tabela16" ]
then vol="volume1"
elif [ $1 == "tabela17" ]
then vol="volume1"
elif [ $1 == "tabela18" ]
then vol="volume1"
elif [ $1 == "tabela19" ]
then vol="volume1"
elif [ $1 == "tabela20a" ]
then vol="volume1"
elif [ $1 == "tabela23" ]
then vol="volume1"
elif [ $1 == "tabela25" ]
then vol="volume1"
elif [ $1 == "tabela26" ]
then vol="volume1"
elif [ $1 == "tabela27" ]
then vol="volume1"
elif [ $1 == "tabela28a" ]
then vol="volume1"
elif [ $1 == "tabela28b" ]
then vol="volume1"
elif [ $1 == "tabela28c" ]
then vol="volume1"
elif [ $1 == "tabela28d" ]
then vol="volume1"
elif [ $1 == "tabela30" ]
then vol="volume1"
elif [ $1 == "tabela31" ]
then vol="volume1"
elif [ $1 == "tabela32" ]
then vol="volume1"
elif [ $1 == "tabela33" ]
then vol="volume1"
elif [ $1 == "tabela37" ]
then vol="volume1"
elif [ $1 == "tabela38" ]
then vol="volume1"
elif [ $1 == "tabela39" ]
then vol="volume1"
elif [ $1 == "tabela40" ]
then vol="volume1"
else
   echo "$1 is not a valid document"
   exit 2
fi

diff -w "$vol"/pdf/aux_files/"$1".tex checks/assets/tex/"$1".tex > /dev/null 2>&1
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
   diff -u -w checks/assets/tex/"$1".tex "$vol"/pdf/aux_files/"$1".tex | diff-so-fancy
   echo "==================================="
fi

if [ $diff_pdf -eq 1 ]
then
   echo "Failure testing $1.pdf"
   mkdir -p pdf/diff
   diff-pdf -vsm --output-diff=pdf/diff/"$1"-diff.pdf pdf/"$1".pdf checks/assets/pdf/"$1".pdf
   echo "pdf diff saved at pdf/diff/$1-diff.pdf"
fi
