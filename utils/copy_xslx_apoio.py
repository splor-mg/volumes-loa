from pathlib import Path
import shutil

datapackages_dir = Path('datapackages/apoio/data-raw/')
sisor_dir = Path('bancos/SISOR/')
manual_dir = Path('bancos/manual/')

items = [
 (datapackages_dir / 'exec_desp_realizada.xlsx', sisor_dir / 'exec_desp_realizada.xlsx'), 
 (datapackages_dir / 'exec_rec.xlsx', sisor_dir / 'exec_rec.xlsx'), 
 (datapackages_dir / 'FFP_acoes.xlsx', manual_dir / 'FFP_acoes.xlsx'), 
 (datapackages_dir / 'Nome_UO_antigas.xlsx', manual_dir / 'Nome_UO_antigas.xlsx'), 
 (datapackages_dir / 'codigosPoder.xlsx', manual_dir / 'codigosPoder.xlsx'), 
 (datapackages_dir / 'correspondencia_mun_terr_desenvol.xlsx', manual_dir / 'correspondencia_mun_terr_desenvol.xlsx'), 
 (datapackages_dir / 'desc_IAG.xlsx', manual_dir / 'desc_IAG.xlsx'), 
 (datapackages_dir / 'desc_IPU.xlsx', manual_dir / 'desc_IPU.xlsx'), 
 (datapackages_dir / 'desc_classificacao_economica_despesa.xlsx', manual_dir / 'desc_classificacao_economica_despesa.xlsx'), 
 (datapackages_dir / 'desc_classificacao_receita.xlsx', manual_dir / 'desc_classificacao_receita.xlsx'), 
 (datapackages_dir / 'desc_fontes_de_recursos.xlsx', manual_dir / 'desc_fontes_de_recursos.xlsx'), 
 (datapackages_dir / 'desc_funcao.xlsx', manual_dir / 'desc_funcao.xlsx'), 
 (datapackages_dir / 'desc_grupos_de_despesa.xlsx', manual_dir / 'desc_grupos_de_despesa.xlsx'), 
 (datapackages_dir / 'desc_subfuncao.xlsx', manual_dir / 'desc_subfuncao.xlsx'), 
 (datapackages_dir / 'memoria_calculo.xlsx', manual_dir / 'memoria_calculo.xlsx' ),
 (datapackages_dir / 'desc_base_legal_demonstrativos.xlsx', manual_dir / 'desc_base_legal_demonstrativos.xlsx' ),
 (Path('datapackages/fonte_stn/data/fonte_stn.csv'), manual_dir / 'fonte_stn.csv' ),
 (Path('datapackages/qdd_fiscal_fonte_95/data/base_qdd_fiscal_fonte_95.xlsx'), sisor_dir / 'BASE_QDD_FISCAL_FONTE_95.xlsx'),
 ]

for item in items:
    shutil.copy(item[0], item[1])

def main():
    """Função principal para execução via Poetry"""
    # O código principal já está executando no nível do módulo
    pass

if __name__ == "__main__":
    main()
