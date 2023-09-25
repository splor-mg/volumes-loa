import pandas as pd
import numpy as np
import unicodedata
import typer
from typing_extensions import Annotated
import textwrap

def format_integer_list(integers):
    formatted_ranges = []
    
    if not integers:
        return ""

    start = end = integers[0]

    for i in range(1, len(integers)):
        if integers[i] == end + 1:
            end = integers[i]
        else:
            if start == end:
                formatted_ranges.append(str(start))
            else:
                formatted_ranges.append(f"{start}-{end}")
            start = end = integers[i]

    if start == end:
        formatted_ranges.append(str(start))
    else:
        formatted_ranges.append(f"{start}-{end}")

    return ", ".join(formatted_ranges)

def main(dry_run: Annotated[bool, typer.Option(help="Show which characters would be replaced without actually replacing them.")] = False):
    df = pd.read_csv('utils/invalids_chars.csv', header=0)
    char_to_find = df.values
    char_to_find = np.vectorize(lambda x: int(x, 16))(char_to_find)

    filenames = [
        'bancos/SISOR/acoes_planejamento.txt',
    ]

    for file_path in filenames:
        print(f"Buscando caracteres inválidos no arquivo: {file_path}")
        
        # Create a dictionary to store character replacements and line numbers
        replacement_dict = {}

        with open(file_path, 'rb') as file:
            modified_lines = []  # A list to store modified lines

            for line_number, line in enumerate(file, start=1):
                modified_line = line  # Initialize modified_line with the original line

                for row in char_to_find:
                    # Replace the character in the line
                    modified_line = modified_line.replace(chr(row[0]).encode('utf-8'), chr(row[1]).encode('utf-8'))
                    
                    # Check if the line was modified and record the line number
                    if line != modified_line:
                        from_char = f"{hex(row[0])}"
                        to_char = f"{hex(row[1])}"
                        from_url = f"https://symbl.cc/en/{from_char[2:].zfill(4)}/"
                        to_url = f"https://symbl.cc/en/{to_char[2:].zfill(4)}/"
                        unicode_pair_info = textwrap.dedent(f"""
                                             De: {from_char} ({unicodedata.name(chr(row[0]), 'Unknown')}) - {from_url}
                                             Para: {to_char} ({unicodedata.name(chr(row[1]), 'Unknown')}) - {to_url}
                                             """)
                        if unicode_pair_info not in replacement_dict:
                            replacement_dict[unicode_pair_info] = [line_number]
                        else:
                            replacement_dict[unicode_pair_info].append(line_number)

                # Append the modified line to the list
                modified_lines.append(modified_line)

        # Print character replacements and corresponding line numbers
        for unicode_pair_info, line_numbers in replacement_dict.items():
            formatted_line_numbers = format_integer_list(line_numbers)
            print(f"{unicode_pair_info}Linhas: {formatted_line_numbers}\n")

        if not dry_run:
            with open(file_path, 'wb') as file:
                file.writelines(modified_lines)

if __name__ == "__main__":
    typer.run(main)
