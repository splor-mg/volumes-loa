import pandas as pd
import numpy as np

df = pd.read_csv('utils/invalids_chars.csv', header=0)
char_to_find = df.values
char_to_find = np.vectorize(lambda x: int(x, 16))(char_to_find)

filenames = [
    'bancos/SISOR/acoes_planejamento.txt',
]
for file_path in filenames:

    print(f"Buscando caracters inválidos no arquivo: {file_path}")
    for row in char_to_find:

        try:
            with open(file_path, 'rb') as file:
                data = file.read()

            # Replace the character
            modified_data = data.replace(chr(row[0]).encode('utf-8'), chr(row[1]).encode('utf-8'))

            # Write the modified data back to the file
            with open(file_path, 'wb') as file:
                file.write(modified_data)

            if data != modified_data:
                print(f"Caractere unicode {row[0]} substituído pelo unicode {row[1]} no arquivo {file_path}.")

        except FileNotFoundError:
            print(f"File not found: {file_path}")

        except Exception as e:
            print(f"An error occurred: {str(e)}")