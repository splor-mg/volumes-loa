from .report import Report

def test_volume6A():
    report = Report('Projeto_volume6A', 'volume6')
    assert report.test_tex()
    assert report.test_pdf()

def test_volume6B():
    report = Report('Projeto_volume6B', 'volume6')
    assert report.test_tex()
    assert report.test_pdf()
