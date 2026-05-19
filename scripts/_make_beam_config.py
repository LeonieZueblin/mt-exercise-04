#!/usr/bin/env python3
"""
Clone a JoeyNMT config and override testing.beam_size.

Used by scripts/beam_sweep.sh to translate the same model 10 times at
different beam sizes without editing the canonical config in-place.
"""
import argparse
from pathlib import Path

import yaml


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--base", required=True, help="Path to the source config.")
    p.add_argument("--beam-size", type=int, required=True)
    p.add_argument("--alpha", type=float, default=None,
                   help="Optional override for length-penalty alpha.")
    p.add_argument("--out", required=True, help="Path to write the patched config.")
    args = p.parse_args()

    with open(args.base, encoding="utf-8") as f:
        cfg = yaml.safe_load(f)

    cfg.setdefault("testing", {})
    cfg["testing"]["beam_size"] = args.beam_size
    if args.alpha is not None:
        cfg["testing"]["alpha"] = args.alpha

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8") as f:
        yaml.safe_dump(cfg, f, sort_keys=False)


if __name__ == "__main__":
    main()
