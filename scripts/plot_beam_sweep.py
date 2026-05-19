#!/usr/bin/env python3
"""
Plot the results of scripts/beam_sweep.sh.

Reads a CSV with columns: beam_size,bleu,seconds
Writes two PNG plots next to it:
    beam_vs_bleu.png       beam_size on x, BLEU on y
    beam_vs_seconds.png    beam_size on x, wall-clock seconds on y

Usage:
    python scripts/plot_beam_sweep.py beam_sweep/<model>/results.csv

Requires matplotlib:
    pip install matplotlib
"""
import argparse
import csv
from pathlib import Path

import matplotlib

matplotlib.use("Agg")  # headless: don't try to open a window
import matplotlib.pyplot as plt


def load(csv_path):
    beams, bleus, seconds = [], [], []
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            beams.append(int(row["beam_size"]))
            bleus.append(float(row["bleu"]))
            seconds.append(float(row["seconds"]))
    # Make sure x is sorted ascending so the line plot makes sense.
    order = sorted(range(len(beams)), key=lambda i: beams[i])
    return ([beams[i] for i in order],
            [bleus[i] for i in order],
            [seconds[i] for i in order])


def plot(x, y, *, title, ylabel, out_path, annotate=True):
    fig, ax = plt.subplots(figsize=(7, 4.5))
    ax.plot(x, y, marker="o", linewidth=2)
    ax.set_xlabel("Beam size (K)")
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.grid(True, linestyle="--", alpha=0.4)
    # Use the actual beam sizes as x-ticks so the spacing is honest.
    ax.set_xticks(x)
    if annotate:
        for xi, yi in zip(x, y):
            ax.annotate(f"{yi:.2f}", (xi, yi),
                        textcoords="offset points", xytext=(0, 8),
                        ha="center", fontsize=8)
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)
    print(f"  wrote {out_path}")


def main():
    p = argparse.ArgumentParser()
    p.add_argument("csv", help="Path to results.csv from beam_sweep.sh")
    p.add_argument("--model-name", default=None,
                   help="Used in the plot titles. Inferred from the CSV path otherwise.")
    args = p.parse_args()

    csv_path = Path(args.csv)
    out_dir = csv_path.parent
    model_name = args.model_name or out_dir.name

    beams, bleus, seconds = load(csv_path)
    print(f"Loaded {len(beams)} rows from {csv_path}")

    plot(beams, bleus,
         title=f"Impact of beam size on BLEU ({model_name})",
         ylabel="case-sensitive BLEU",
         out_path=out_dir / "beam_vs_bleu.png")

    plot(beams, seconds,
         title=f"Impact of beam size on translation time ({model_name})",
         ylabel="wall-clock seconds (test set)",
         out_path=out_dir / "beam_vs_seconds.png",
         annotate=False)


if __name__ == "__main__":
    main()
