from .report import Report

def test_volume5():
    report = Report('volume5', 'volume5')
    assert report.test_tex()
    assert report.test_pdf()
