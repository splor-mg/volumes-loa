"""
Gera pdf/Projeto_volume7.pdf a partir dos templates Jinja em volume7/jinja2.
Substitui, para o volume 7, o Projeto_volume7.Rnw, o utils/Rnw2Tex.R e o utils/limpaDir.R.
Executar na raiz do projeto com: python3 -m volume7.jinja2.Projeto_volume7
"""
import csv
import os
import shutil
import subprocess
from pathlib import Path

import jinja2
import pandas as pd

from utils.python.funcoes import texto_r
from utils.python.trata_bancos import le_planilha

NOME = "Projeto_volume7"
DADOS = Path("volume7/data")
JINJA2 = Path("volume7/jinja2")
AUX_FILES = Path("volume7/pdf/aux_files")


def ler_codigos(arquivo, coluna):
    planilha = le_planilha(Path("bancos/manual") / arquivo).sort_values("CODIGO", kind="stable")
    return [(texto_r(codigo), texto_r(descricao).upper()) for codigo, descricao in zip(planilha["CODIGO"], planilha[coluna])]


def prepara_consolidado():
    consolidado = pd.read_csv(DADOS / "consolidado.txt", sep="\t", dtype=str, keep_default_na=False, quoting=csv.QUOTE_NONE)
    codigo = consolidado["codigo_texto"]
    consolidado["nivel"] = 3
    consolidado.loc[codigo.str[4:6] == "00", "nivel"] = 2
    consolidado.loc[codigo.str[2].isin(["0", "9"]), "nivel"] = 1

    # A última linha é o TOTAL
    return consolidado.iloc[:-1].to_dict("records"), consolidado.iloc[-1].to_dict()


def prepara_quadro():
    banco = pd.read_csv(DADOS / "QUADRO_DETALHAMENTO_DESPESA_porUO.txt", sep="\t", dtype=str, keep_default_na=False, quoting=csv.QUOTE_NONE)
    for coluna, largura in [("FUNCAO", 2), ("SUB_FUNCAO", 3), ("PROJ_ATIV", 3), ("SUB_PROJETO", 4), ("ELEMENTO_DESPESA", 2)]:
        banco[coluna] = banco[coluna].str.zfill(largura)

    banco["tipo"] = "acao"
    banco.loc[banco["NOME_ACAO"] == "", "tipo"] = "elemento"
    banco.loc[banco["NOME_ACAO"] == "TOTAL", "tipo"] = "total"

    poderes = set()
    orgaos = set()
    uos = []
    for _, uo in banco.groupby("COD_UO", sort=False):
        primeira = uo.iloc[0]
        poder = primeira["poder"]
        orgao = primeira["COD_ORGAO"]
        unidade = primeira["COD_UO"]
        uos.append({
            "novo_poder": poder not in poderes,
            "poder": poder,
            "novo_orgao": orgao not in orgaos,
            "orgao": f"{orgao[0:1]}.{orgao[1:3]}.{orgao[3:4]} - {primeira['ORGAO']}",
            "unidade": f"{unidade[0:1]}.{unidade[1:3]}.{unidade[3:4]} - {primeira['UO']}",
            "ano": primeira["ANO"],
            "linhas": uo.to_dict("records"),
        })
        poderes.add(poder)
        orgaos.add(orgao)
    return uos


def renderiza():
    ambiente = jinja2.Environment(
        loader=jinja2.FileSystemLoader(JINJA2),
        block_start_string=r"\BLOCK{",
        block_end_string="}",
        variable_start_string=r"\VAR{",
        variable_end_string="}",
        comment_start_string=r"\#{",
        comment_end_string="}",
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
        undefined=jinja2.StrictUndefined,
    )
    consolidado, total = prepara_consolidado()
    return ambiente.get_template(f"{NOME}.tex.j2").render(
        ano_doc=int(Path("utils/ano.txt").read_text()),
        etapa_orcamento=Path("utils/etapa_orcamento.txt").read_text(encoding="utf-8").splitlines()[0],
        consolidado=consolidado,
        total=total,
        uos=prepara_quadro(),
        grupos_despesa=ler_codigos("desc_grupos_de_despesa.xlsx", "ESPECIFICACAO"),
        fontes=ler_codigos("desc_fontes_de_recursos.xlsx", "CLASSIFICACAO"),
        ipu=ler_codigos("desc_IPU.xlsx", "ESPECIFICACAO"),
        iag=ler_codigos("desc_IAG.xlsx", "INTERPRETACAO"),
    )


def compila():
    # Roda o pdflatex até o sumário e as referências estabilizarem, como o R CMD Sweave --pdf
    shutil.copy(JINJA2 / "load_bibliotecas.tex", ".")
    shutil.copy("capas/capaLOA.pdf", ".")
    anteriores = []
    for _ in range(10):
        subprocess.run(["pdflatex", "-interaction=batchmode", f"{NOME}.tex"], check=True, stdout=subprocess.DEVNULL)
        auxiliares = [Path(f"{NOME}.{extensao}").read_bytes() for extensao in ("aux", "toc", "out")]
        if auxiliares == anteriores:
            break
        anteriores = auxiliares
    else:
        raise RuntimeError(f"{NOME}.tex não estabilizou após 10 execuções do pdflatex")
    os.remove("load_bibliotecas.tex")
    os.remove("capaLOA.pdf")

    Path("pdf").mkdir(exist_ok=True)
    AUX_FILES.mkdir(parents=True, exist_ok=True)
    os.replace(f"{NOME}.pdf", f"pdf/{NOME}.pdf")
    for extensao in ("tex", "aux", "log", "out", "toc"):
        os.replace(f"{NOME}.{extensao}", AUX_FILES / f"{NOME}.{extensao}")


log = Path("logs/logv7.Rout")
if log.exists() and log.stat().st_size > 0:
    print("!-- Verificar logs/logv7.Rout ...")

print("-- Iniciando volume7.pdf ...")
Path(f"{NOME}.tex").write_text(renderiza(), encoding="utf-8")
compila()
