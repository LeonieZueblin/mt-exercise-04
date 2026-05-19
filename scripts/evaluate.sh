#! /bin/bash

scripts=$(dirname "$0")
base=$scripts/..

configs=$base/configs

translations=$base/translations

mkdir -p $translations

model_name=${1:-word_2k}
src=${2:-en}
trg=${3:-fr}

# BPE configs read from prep/ (pretokenized); word_2k reads from data/.
case "$model_name" in
    bpe_*) input_dir=$base/prep ;;
    *)     input_dir=$base/prep ;;
esac

# Reference for sacrebleu is always the raw target -- sacrebleu does its
# own tokenization. JoeyNMT detokenizes BPE markers automatically.
ref_dir=$base/data


num_threads=4
device=0

# measure time

SECONDS=0

echo "###############################################################################"
echo "model_name $model_name"
echo "input:     $input_dir/test.$src"
echo "reference: $ref_dir/test.$trg"

translations_sub=$translations/$model_name

mkdir -p $translations_sub

CUDA_VISIBLE_DEVICES=$device OMP_NUM_THREADS=$num_threads python -m joeynmt translate $configs/$model_name.yaml < $input_dir/test.$src > $translations_sub/test.$model_name.$trg

# compute case-sensitive BLEU

cat $translations_sub/test.$model_name.$trg | sacrebleu $ref_dir/test.$trg


echo "time taken:"
echo "$SECONDS seconds"
