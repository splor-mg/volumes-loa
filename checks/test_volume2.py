from .report import Report

def test_volume2():
    report = Report('Projeto_volume2', 'volume2')
    assert report.test_tex()
    assert report.test_pdf()
