import typer
from typing_extensions import Annotated
from report import Report
from typing import List
from typing import Optional
import subprocess

app = typer.Typer()

REPORTS = [
        Report('T2_DCGF_DEMONSTRATIVO_RECEITA_CORRENTE_FISCAL', 'volume1'),
        Report('T3_DCGF_Demonstrativo_Receita_Despesa_Segundo_Categorias_Economicas', 'volume1'),
        Report('T4_DEMONSTRATIVO_DESPESA_POR_ORGAOS_ENTIDADES_SEGUNDO_GRUPOS_DESPESA', 'volume1'),
        Report('T5_DEMONSTRATIVO_CONSOLIDADO_CATEGORIA_PESSOAL', 'volume1'),
        Report('T6_DCGF_Demonstrativo_Evolucao_Receita_por_Categoria_Economica', 'volume1'),
        Report('T7_QUADRO_GERAL_DA_RECEITA', 'volume1'),
        Report('T8_DCGF_RECEITA_CORRENTE_LIQUIDA', 'volume1'),
        Report('T9_DEMONSTRATIVO_RECEITA_ORCAMENTARIA_CORRENTE_ORDINARIA', 'volume1'),
        Report('T12_DCGF_Demonstrativo_Evolucao_Despesa_Categoria_Economica', 'volume1'),
        Report('T13_DCGF_Demonstrativo_Consolidado_Despesa', 'volume1'),
        Report('T14_DEMONSTRATIVO_DESPESA_FUNCAO_SUBFUNCAO_PROGRAMA_CONFORME_VINCULO_COM_RECURSOS', 'volume1'),
        Report('T15_PROGRAMA_TRABALHO_GOVERNO', 'volume1'),
        Report('T16_DCGF_Demons_Aplicacao_Recursos_Manut_Desenv_Ensino', 'volume1'),
        Report('T17_DCGF_Demonst_Aplicacao_Recursos_Progr_Saude_Investim', 'volume1'),
        Report('T18_DCGF_Demonst_Aplicacao_Recursos_Acoes_Servicos_Publicos_Saude', 'volume1'),
        Report('T19_DCGF_Demonstrativo_Aplicacao_Recursos_Amparo_Fomento_Pesquisa', 'volume1'),
        Report('T20A_DCGF_Demonstrativo_Partic_Percentual_Pessoal_RCL_LRF', 'volume1'),
        Report('T23_DCGF_Demonstrativo_do_Servico_da_divida_publica', 'volume1'),
        Report('T25_DCGF_Demonstrativo_Aplicacao_Recursos_FUNDEB', 'volume1'),
        Report('T26_DCGF_DEMONSTRATIVO_RECURSOS_APLICADOS_ACOES_PARA_CRIANCA_E_ADOLESCENTE', 'volume1'),
        Report('T27_DCGF_Demonst_Despesas_UGEPREVI', 'volume1'),
        Report('T28_DCGF_PT1_Receita_prevista_e_realizada', 'volume1'),
        Report('T28_DCGF_PT2_Despesa_prevista_e_realizada', 'volume1'),
        Report('T28_DCGF_PT3_Receita_prevista_LOA', 'volume1'),
        Report('T28_DCGF_PT4_Despesa_prevista_LOA', 'volume1'),
        Report('T30_INVESTIMENTOS_SEGUNDO_FUNCOES', 'volume1'),
        Report('T31_INVESTIMENTOS_SEGUNDO_FUNCOES_SUBFUNCOES_PROGRAMAS_POR_PROJETOS_ATIVIDADES', 'volume1'),
        Report('T32_INVESTIMENTOS_POR_EMPRESA_SEGUNDO_FONTES_RECURSO', 'volume1'),
        Report('T33_INVESTIMENTOS_EMPRESA_SEGUNDO_DETALHAMENTO_INVESTIMENTOS', 'volume1'),
        Report('T37_DCGF_DEMONSTRATIVOS_RECURSOS_APLICADOS_SEGURANCA_ALIMENTAR_NUTRICIONAL', 'volume1'),
        Report('T38_DCGF_DEMONSTRATIVO_RECEITAS_DESPESAS_PREVIDENCIARIAS_RPPS', 'volume1'),
        Report('T39_DCGF_DEMONSTRATIVO_CUMPRIMENTO_LIMITACAO_CRESCIMENTO_DESPESA', 'volume1'),
        Report('Projeto_volume2A', 'volume2'),
        Report('Projeto_volume2B', 'volume2'),
        Report('Projeto_volume3', 'volume3'),
        Report('Projeto_volume4', 'volume4'),
        Report('Projeto_volume5', 'volume5'),
    ]

def validate_report_name(report_names: str):
    all_report_names = [report.name for report in REPORTS]
    
    if isinstance(report_names, str):
        report_names = [report_names]  # Convert to a single-item list
    
    if report_names:
        for report_name in report_names:
            if report_name not in all_report_names:
                raise typer.BadParameter(f"{report_name} report does not exist.")
    return report_names

@app.callback()
def callback():
    """
    Utilities for testing report generation
    """

@app.command()
def diff(report_name: Annotated[str, typer.Argument(callback=validate_report_name)]):
    """
    Diff of tex and pdf files
    """
    subprocess.run(["checks/diff.sh", report_name[0],])


@app.command()
def snapshot(report_names: Annotated[Optional[List[str]], typer.Argument(callback=validate_report_name)] = None):
    """
    Save tex and pdf files of reports for golden test
    """
    if report_names:
        reports = [report for report in REPORTS if report.name in report_names]
    else:
        reports = REPORTS
    for report in reports:
        report.snapshot()

if __name__ == "__main__":
    app()
