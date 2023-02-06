#!/usr/bin/env bash

# Find all git tracked files with .txt or .c extensions
files=$(git ls-files '*.txt' '*.tex' '*.R' '*.sty' '*.Rnw' '*.csv')

# Iterate over the files and convert them to UTF-8
for file in $files; do
  # Skip directories
  if [[ ! -f "$file" ]]; then
    continue
  fi
  # Determine the encoding of the file
  encoding=$(file --mime "$file" | awk '{print $3}' | sed 's/charset=//')
  # If the encoding is not UTF-8, convert the file to UTF-8
  if [[ $encoding != "utf-8" ]] && [[ $encoding != "us-ascii" ]]; then
    echo "Converting $file..."
    # Convert the file to UTF-8
    iconv -f windows-1252 -t UTF-8 "$file" > "$file.utf8"
    # Replace the original file with the converted file
    mv "$file.utf8" "$file"
  fi
done
