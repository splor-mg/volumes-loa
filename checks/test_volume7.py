from .report import Report

def test_volume7():
    report = Report('volume7', 'volume7')
    assert report.test_tex()
    assert report.test_pdf()
