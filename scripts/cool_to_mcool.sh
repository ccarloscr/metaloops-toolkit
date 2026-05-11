#!/bin/bash
# =============================================================================
# cool_to_mcool.sh — Merge single-resolution .cool files into multi-resolution
#                 .mcool files using cooler zoomify
#
# Usage (local):
#   bash scripts/cool_to_mcool.sh [path/to/local.env]
#
# Usage (SLURM):
#   sbatch scripts/cool_to_mcool.sh [path/to/local.env]
#
# If no config path is given, defaults to ./local.env
# =============================================================================

#SBATCH --job-name=cool_to_mcool
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=logs/cool_to_mcool_%j.out
#SBATCH --error=logs/cool_to_mcool_%j.err

set -euo pipefail

# ── Load config ───────────────────────────────────────────────────────────────
CONFIG="${1:-local.env}"
if [ ! -f "$CONFIG" ]; then
    echo "ERROR: Config file not found: $CONFIG"
    echo "       Edit local.env and fill in your values."
    exit 1
fi
# shellcheck source=/dev/null
source "$CONFIG"

# ── Environment Setup ─────────────────────────────────────────────────────────
# Try to find conda via PATH first, then fall back to common install locations
if ! command -v conda &>/dev/null; then
    for _candidate in \
        "$HOME/miniconda3/bin/conda" \
        "$HOME/miniforge3/bin/conda" \
        "$HOME/mambaforge/bin/conda" \
        "/opt/conda/bin/conda"; do
        if [ -x "$_candidate" ]; then
            export PATH="$(dirname "$_candidate"):$PATH"
            break
        fi
    done
fi

if ! command -v conda &>/dev/null; then
    echo "ERROR: conda not found. Install Miniconda/Miniforge or add conda to PATH."
    exit 1
fi

CONDA_BASE=$(conda info --base)
# shellcheck source=/dev/null
source "$CONDA_BASE/etc/profile.d/conda.sh"

if ! conda activate "$CONDA_ENV" 2>/dev/null; then
    echo "ERROR: Could not activate conda environment '$CONDA_ENV'."
    echo "       Available environments:"
    conda env list
    exit 1
fi

echo "Conda env  : $CONDA_DEFAULT_ENV"

# ── Validate inputs ───────────────────────────────────────────────────────────
[ ! -d "$COOL_DIR" ] && echo "ERROR: COOL_DIR not found: $COOL_DIR" && exit 1
command -v cooler >/dev/null || { echo "ERROR: cooler not found. Install with: pip install cooler"; exit 1; }

mkdir -p "$MCOOL_DIR" logs

# ── Process each .cool file ───────────────────────────────────────────────────
shopt -s nullglob
cool_files=("$COOL_DIR"/*.cool)
if [ ${#cool_files[@]} -eq 0 ]; then
    echo "ERROR: No .cool files found in $COOL_DIR"
    exit 1
fi

for cool_file in "${cool_files[@]}"; do
    filename=$(basename "$cool_file")
    output_name="${filename%.cool}.mcool"
    output_path="$MCOOL_DIR/$output_name"

    echo "──────────────────────────────────────────"
    echo "Processing : $filename"
    echo "Output     : $output_path"
    echo "Resolutions: $MCOOL_RESOLUTIONS"

    cooler zoomify \
        --resolutions "$MCOOL_RESOLUTIONS" \
        --balance \
        --out "$output_path" \
        "$cool_file"

    echo "Done       : $output_path"
done

echo "══════════════════════════════════════════"
echo "cool_to_mcool complete. Files written to: $MCOOL_DIR"