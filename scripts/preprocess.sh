#! /bin/bash
# Tokenize raw parallel data with sacremoses.
# Reads:  data/{train,dev,test}.{SRC,TRG}
# Writes: prep/{train,dev,test}.{SRC,TRG}

set -euo pipefail

scripts=$(dirname "$0")
base=$scripts/..

src=${1:-en}
trg=${2:-fr}

data=$base/data
prep=$base/prep

mkdir -p "$prep"

for split in train dev test; do
    for lang in "$src" "$trg"; do
        in="$data/$split.$lang"
        out="$prep/$split.$lang"
        if [ ! -f "$in" ]; then
            echo "Missing $in -- run scripts/download_huggingface_data.py first." >&2
            exit 1
        fi
        echo "Tokenizing $in -> $out"
        sacremoses -l "$lang" -j 4 tokenize -x < "$in" > "$out"
    done
done

echo "Done. Tokenized files are in $prep/"
