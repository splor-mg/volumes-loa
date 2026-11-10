import typer
from typing_extensions import Annotated
from report import Report
from typing import List
from typing import Optional
import subprocess

app = typer.Typer()

REPORTS = [
        Report('tabela1', 'volume1'),
        Report('tabela2', 'volume1'),
        Report('tabela3', 'volume1'),
        Report('tabela4', 'volume1'),
        Report('tabela5', 'volume1'),
        Report('tabela6', 'volume1'),
        Report('tabela7', 'volume1'),
        Report('tabela8', 'volume1'),
        Report('tabela9', 'volume1'),
        Report('tabela12', 'volume1'),
        Report('tabela13', 'volume1'),
        Report('tabela14', 'volume1'),
        Report('tabela15', 'volume1'),
        Report('tabela16', 'volume1'),
        Report('tabela17', 'volume1'),
        Report('tabela18', 'volume1'),
        Report('tabela19', 'volume1'),
        Report('tabela20a', 'volume1'),
        Report('tabela23', 'volume1'),
        Report('tabela25', 'volume1'),
        Report('tabela26', 'volume1'),
        Report('tabela27', 'volume1'),
        Report('tabela28a', 'volume1'),
        Report('tabela28b', 'volume1'),
        Report('tabela28c', 'volume1'),
        Report('tabela28d', 'volume1'),
        Report('tabela30', 'volume1'),
        Report('tabela31', 'volume1'),
        Report('tabela32', 'volume1'),
        Report('tabela33', 'volume1'),
        Report('tabela37', 'volume1'),
        Report('tabela38', 'volume1'),
        Report('tabela39', 'volume1'),
        Report('tabela40', 'volume1'),
        Report('volume2', 'volume2'),
        Report('volume3', 'volume3'),
        Report('volume4', 'volume4'),
        Report('volume5', 'volume5'),
        Report('volume6', 'volume6'),
        Report('volume7', 'volume7'),
    ]

def validate_report_name(report_names: str):
    all_report_names = [report.name for report in REPORTS] + [report.volume for report in REPORTS]

    if isinstance(report_names, str):
        report_names = [report_names]  # Convert to a single-item list

    if report_names:
        for report_name in report_names:
            if report_name not in all_report_names:
                raise typer.BadParameter(f"{report_name} report or volume does not exist.")
    return report_names

@app.callback()
def callback():
    """
    Utilities for testing report generation
    """

@app.command()
def diff(report_names: Annotated[Optional[List[str]], typer.Argument(callback=validate_report_name)] = None):
    """
    Diff of tex and pdf files
    """
    if report_names:
        reports = [report for report in REPORTS
                   if report.name in report_names or report.volume in report_names]
    else:
        reports = REPORTS
    for report in reports:
        subprocess.run(["checks/diff.sh", report.name])


@app.command()
def snapshot(report_names: Annotated[Optional[List[str]], typer.Argument()] = None):
    """
    Save tex and pdf files of reports for golden test
    """
    if report_names:
        reports = [report for report in REPORTS
                   if report.name in report_names or report.volume in report_names]
    else:
        reports = REPORTS
    for report in reports:
        report.snapshot()

if __name__ == "__main__":
    app()
