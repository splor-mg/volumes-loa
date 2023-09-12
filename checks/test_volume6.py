from .report import Report

def test_volume6():
    report = Report('Projeto_volume6', 'volume6')
    assert report.test_tex()
    assert report.test_pdf()
