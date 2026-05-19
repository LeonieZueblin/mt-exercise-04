# MT Exercise 4: Byte Pair Encoding, Beam Search

This repository is a starting point for the 4th and final exercise. As before, fork this repo to your own account and then clone it into your preferred directory.

---

## Requirements

- Python 3.10 must be installed. The command `python3` (or `python` on Windows) should be available from your terminal or command prompt.
- `virtualenv` must be installed. Install it with:

  ```bash
  pip install virtualenv

macOS/Linux users: No special setup needed; shell scripts should run normally.

Windows users: Either use Windows Subsystem for Linux (WSL) or a Unix-compatible shell like Git Bash.
If you're using PowerShell or Command Prompt, manual setup is required.

### Setup Instructions

## For macOS / Linux / WSL / Git Bash users

Clone my fork of the repository + Create a virtual environment:
   ```
   git clone https://github.com/LeonieZueblin/mt-exercise-4
   cd mt-exercise-4 

   ```
    ./scripts/make_virtualenv.sh

Important: Then activate the env by executing the source command that is output by the shell script above.

Install required dependencies - Follow the instructions provided in the exercise PDF.

Download data:

       python ./scripts/download_huggingface_data.py --src en --trg nl --out data

## Prepare the data for the word model training:

Pretokenize data:

```bash
# Tokenize raw parallel data with sacremoses.
# Reads:  data/{train,dev,test}.{SRC,TRG}
# Writes: prep/{train,dev,test}.{SRC,TRG}
./scripts/preprocess.sh en fr
```

To generate a byte-pair encoding, use learn_bpe.sh [vocab size] [source language] [target language]

```bash
./scripts/learn_bpe.sh 2000 en fr # writes bpe/2000/{codes.bpe, vocab.txt, ...}
```

Then train a model using ./scripts/train.sh [model name]. Model name must correspond to model yaml definition in /configs/
```bash
./scripts/train.sh word_2k 
```

To evaluate, use ./scripts/evaluate.sh [Model name] [source language] [target language]

```bash
./scripts/evaluate.sh word_2k en fr
```

Once models have been trained, evaluate them using ./scripts/beam_sweep.sh [Model name] [source language] [target language]
and scripts/plot_beam_sweep.py [csv file]


```bash
./scripts/beam_sweep.sh bpe_2k en fr # Writes results to /beam_sweep/[model name]
python scripts/plot_beam_sweep.py beam_sweep/bpe_2k/results.csv # pip install matplotlib if needed
```

--- 
The below instructions are untested by me and provided as-is from the original exercise.
## For Windows (Command Prompt / PowerShell users) (Untested by me)
Manually create and activate a virtual environment:

        python -m venv mt_env
        mt_env\Scripts\activate

Note: The make_virtualenv.sh script will not work in native Windows shells.

Manually download the dataset

Use the Python downloader script directly, for example:

       python scripts/download_huggingface_data.py --src en --trg nl --out data

If you want a different language pair, replace `--src` and `--trg` with one of the supported directions listed above.

Modify, train, and evaluate
Once setup is complete, use the instructions in the exercise PDF to run training and evaluation (either by adapting the .sh scripts manually, or by using Git Bash/WSL).

#### Notes for Windows Users

  Using Git Bash or WSL is highly recommended for compatibility.

  If using native PowerShell or Command Prompt:

  Manual recreation of shell script steps will be necessary.

  Always activate your virtual environment before running any training or evaluation steps.

