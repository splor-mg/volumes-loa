from dataclasses import dataclass
import shutil
import subprocess

@dataclass
class Report:
    name: str
    volume: str

    @property
    def tex(self):
        return f'{self.volume}/pdf/aux_files/{self.name}.tex'

    @property
    def tex_snapshot(self):
        return f'tests/assets/tex/{self.name}.tex'

    @property
    def pdf(self):
        return f'pdf/{self.name}.pdf'
    
    @property
    def pdf_snapshot(self):
        return f'tests/assets/pdf/{self.name}.pdf'

    def snapshot(self):
        shutil.copy(self.tex, self.tex_snapshot)
        shutil.copy(self.pdf, self.pdf_snapshot)
        return True
    
    def test_pdf(self):
        try:
            subprocess.run(["diff-pdf", self.pdf, self.pdf_snapshot,], check=True, stdout=subprocess.DEVNULL)
            return True
        except subprocess.CalledProcessError:
            print(f"Failure testing {self.name}.pdf")
            return False

    def test_tex(self):
        try:
            subprocess.run(["diff", "-u", self.tex, self.tex_snapshot], check=True, stdout=subprocess.DEVNULL)
            return True
        except subprocess.CalledProcessError:
            print(f"Failure testing {self.name}.tex")
            return False
