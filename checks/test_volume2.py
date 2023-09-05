from .report import Report

def test_volume2A():
    report = Report('Projeto_volume2A', 'volume2')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume2B():
    report = Report('Projeto_volume2B', 'volume2')
    assert report.test_tex()
    assert report.test_pdf()
