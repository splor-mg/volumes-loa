from pathlib import Path
from frictionless import Package, formats

package = Package('datapackages/sisor/datapackage.json')

resource_names = [
                  "base_categoria_pessoal",
                  "base_detalhamento_obras",
                  "base_orcam_despesa_item_fiscal",
                  "base_orcam_receita_fiscal",
                  "base_qdd_fiscal",
                  "base_qdd_investimento",
                  "base_qdd_plurianual_invest",
                  "base_repasse_recursos",
                 ]

for resource_name in resource_names:
  print("Formata recurso", resource_name)
  resource = package.get_resource(resource_name)
  excel_control = formats.ExcelControl(sheet=resource_name.upper())
  output_path = str(Path('bancos/SISOR/') / f'{resource_name.upper()}.xlsx')
  resource.write(output_path, control = excel_control)
  print(f"Arquivo salvo em {output_path}")

def main():
    """Função principal para execução via Poetry"""
    # O código principal já está executando no nível do módulo
    pass

if __name__ == "__main__":
    main()
