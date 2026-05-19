#! /bin/bash
# Learn joint BPE on the pre-tokenized training data, apply it to the
# training files (just to materialize tokens), and build a single joint
# JoeyNMT vocab file.
#
# Usage:
#   ./scripts/learn_bpe.sh <vocab_size> [src] [trg]
#   e.g. ./scripts/learn_bpe.sh 2000 en fr
#
# Outputs:
#   bpe/<vocab_size>/codes.bpe         # joint BPE codes
#   bpe/<vocab_size>/vocab.<src>       # per-side BPE vocab (from subword-nmt)
#   bpe/<vocab_size>/vocab.<trg>
#   bpe/<vocab_size>/train.bpe.<src>   # BPE-segmented train data
#   bpe/<vocab_size>/train.bpe.<trg>
#   bpe/<vocab_size>/vocab.txt         # JOINT JoeyNMT vocab (this is what
#                                      # the config's voc_file should point to)

set -euo pipefail

scripts=$(dirname "$0")
base=$scripts/..

vocab_size=${1:?"Usage: $0 <vocab_size> [src] [trg]"}
src=${2:-en}
trg=${3:-fr}

prep=$base/prep
out=$base/bpe/$vocab_size

mkdir -p "$out"

if [ ! -f "$prep/train.$src" ] || [ ! -f "$prep/train.$trg" ]; then
    echo "Missing $prep/train.$src or $prep/train.$trg -- run scripts/preprocess.sh first." >&2
    exit 1
fi

echo "Learning joint BPE (vocab size = $vocab_size) ..."
subword-nmt learn-joint-bpe-and-vocab \
    --input "$prep/train.$src" "$prep/train.$trg" \
    -s "$vocab_size" \
    --total-symbols \
    -o "$out/codes.bpe" \
    --write-vocabulary "$out/vocab.$src" "$out/vocab.$trg"

echo "Applying BPE to training files for joint vocab construction ..."
for lang in "$src" "$trg"; do
    subword-nmt apply-bpe \
        -c "$out/codes.bpe" \
        --vocabulary "$out/vocab.$lang" \
        --vocabulary-threshold 1 \
        < "$prep/train.$lang" \
        > "$out/train.bpe.$lang"
done

echo "Building JoeyNMT-format joint vocab ..."
python "$scripts/build_joint_vocab.py" \
    --inputs "$out/train.bpe.$src" "$out/train.bpe.$trg" \
    --output "$out/vocab.txt"

echo
echo "Sanity check (head of BPE-segmented train.$src):"
head -3 "$out/train.bpe.$src"
echo
echo "BPE codes:    $out/codes.bpe"
echo "Joint vocab:  $out/vocab.txt"
