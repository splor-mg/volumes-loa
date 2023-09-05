from .report import Report

def test_volume3():
    report = Report('Projeto_volume3', 'volume3')
    assert report.test_tex()
    assert report.test_pdf()
