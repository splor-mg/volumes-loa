from .report import Report

def test_volume4():
    report = Report('volume4', 'volume4')
    assert report.test_tex()
    assert report.test_pdf()
