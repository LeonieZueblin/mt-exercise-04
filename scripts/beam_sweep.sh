#! /bin/bash
# Translate the test set 10 times with different beam sizes for a given
# trained model, recording BLEU and wall-clock time.
#
# Usage:
#   ./scripts/beam_sweep.sh <model_name> [src] [trg]
#   e.g. ./scripts/beam_sweep.sh bpe_2k en fr
#
# Outputs:
#   beam_sweep/<model_name>/cfg_b<K>.yaml   # patched config per beam size
#   beam_sweep/<model_name>/test.b<K>.<trg> # translation per beam size
#   beam_sweep/<model_name>/results.csv     # beam_size,bleu,seconds

set -euo pipefail

scripts=$(dirname "$0")
base=$scripts/..

model_name=${1:?"Usage: $0 <model_name> [src] [trg]"}
src=${2:-en}
trg=${3:-fr}

# BPE configs read pretokenized input from prep/; word_2k from data/.
case "$model_name" in
    bpe_*) input_dir=$base/prep ;;
    *)     input_dir=$base/data ;;
esac
ref=$base/data/test.$trg
config=$base/configs/$model_name.yaml

if [ ! -f "$config" ]; then
    echo "Missing config: $config" >&2; exit 1
fi
if [ ! -f "$input_dir/test.$src" ]; then
    echo "Missing test input: $input_dir/test.$src" >&2; exit 1
fi
if [ ! -f "$ref" ]; then
    echo "Missing reference: $ref" >&2; exit 1
fi

out_dir=$base/beam_sweep/$model_name
mkdir -p "$out_dir"

# 10 beam sizes -- denser at the low end where most of the change happens.
beam_sizes=(1 2 3 4 5 7 10 15 20 30)

results_csv=$out_dir/results.csv
echo "beam_size,bleu,seconds" > "$results_csv"

num_threads=4

for bs in "${beam_sizes[@]}"; do
    cfg="$out_dir/cfg_b${bs}.yaml"
    out_file="$out_dir/test.b${bs}.${trg}"

    python "$scripts/_make_beam_config.py" \
        --base "$config" --beam-size "$bs" --out "$cfg"

    echo "### beam_size=$bs"
    start=$(date +%s)
    OMP_NUM_THREADS=$num_threads python -m joeynmt translate "$cfg" \
        < "$input_dir/test.$src" > "$out_file"
    end=$(date +%s)
    elapsed=$((end - start))

    # -b -> "score only" (just the number, no JSON / signature).
    bleu=$(sacrebleu -b "$ref" < "$out_file")
    printf "    bleu=%s  seconds=%s\n" "$bleu" "$elapsed"
    echo "${bs},${bleu},${elapsed}" >> "$results_csv"
done

echo
echo "Results written to: $results_csv"
column -s, -t < "$results_csv"
