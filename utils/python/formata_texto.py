"""
Correção de caracteres especiais para o LaTeX.
"""

CARACTERES_ESPECIAIS = str.maketrans({
    '\\': r'\textbackslash ',
    '$': r'\$',
    '#': r'\#',
    '%': r'\%',
    '&': r'\&',
    '_': r'\_',
    '{': r'\{',
    '}': r'\}',
    '^': '',
    'º': r'\degree',
    'ª': '$^a$',
    '~': '',
    '\x94': '"',
    '\x93': '',
    '\x96': '-',
})


def corrige_caracteres_especiais(textos):
    return textos.str.upper().str.translate(CARACTERES_ESPECIAIS)
