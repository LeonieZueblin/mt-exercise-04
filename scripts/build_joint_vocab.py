#!/usr/bin/env python3
"""
Build a single joint vocabulary file in JoeyNMT format from one or more
BPE-segmented text files.

JoeyNMT expects:
  - One token per line
  - Special tokens at the top: <unk>, <pad>, <s>, </s>
  - No counts

Usage:
    python scripts/build_joint_vocab.py \\
        --inputs bpe/2000/train.bpe.en bpe/2000/train.bpe.fr \\
        --output bpe/2000/vocab.txt
"""

import argparse
from pathlib import Path

SPECIALS = ["<unk>", "<pad>", "<s>", "</s>"]


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--inputs", nargs="+", required=True,
                   help="BPE-segmented text files to read tokens from.")
    p.add_argument("--output", required=True,
                   help="Path to write the joint vocab file.")
    args = p.parse_args()

    counts = {}
    for path in args.inputs:
        with open(path, encoding="utf-8") as f:
            for line in f:
                for tok in line.split():
                    counts[tok] = counts.get(tok, 0) + 1

    # Sort by frequency (desc), break ties alphabetically for determinism.
    tokens = sorted(counts.keys(), key=lambda t: (-counts[t], t))

    # Strip any token that happens to collide with a special.
    tokens = [t for t in tokens if t not in SPECIALS]

    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8") as f:
        for tok in SPECIALS:
            f.write(tok + "\n")
        for tok in tokens:
            f.write(tok + "\n")

    print(f"Wrote {len(SPECIALS) + len(tokens)} tokens "
          f"({len(SPECIALS)} specials + {len(tokens)} BPE) to {out}")


if __name__ == "__main__":
    main()
