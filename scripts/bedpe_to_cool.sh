#!/bin/bash
# =============================================================================
# bedpe_to_cool.sh — Convert BEDPE contact files to balanced .cool format
#
# Usage (local):
#   bash scripts/bedpe_to_cool.sh [path/to/local.env]
#
# Usage (SLURM):
#   sbatch scripts/bedpe_to_cool.sh [path/to/local.env]
#
# If no config path is given, defaults to ./local.env
# =============================================================================

#SBATCH --job-name=bedpe_to_cool
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=logs/bedpe_to_cool%j.out
#SBATCH --error=logs/bedpe_to_cool%j.err
# SLURM_PARTITION, SLURM_CPUS, SLURM_MEM, and SLURM_TIME are read from the
# config file below and exported before submission — see submit.sh.

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
[ ! -d "$BEDPE_DIR" ]   && echo "ERROR: BEDPE_DIR not found: $BEDPE_DIR"     && exit 1
[ ! -f "$CHROM_SIZES" ] && echo "ERROR: CHROM_SIZES not found: $CHROM_SIZES" && exit 1
command -v cooler >/dev/null || { echo "ERROR: cooler not found. Install with: pip install cooler"; exit 1; }

mkdir -p "$COOL_DIR" logs

# ── Process each BEDPE file ───────────────────────────────────────────────────
shopt -s nullglob
bedpe_files=("$BEDPE_DIR"/*.bedpe)
if [ ${#bedpe_files[@]} -eq 0 ]; then
    echo "ERROR: No .bedpe files found in $BEDPE_DIR"
    exit 1
fi

for bedpe_file in "${bedpe_files[@]}"; do
    filename=$(basename "$bedpe_file")
    output_name="${filename%.bedpe}.cool"
    output_path="$COOL_DIR/$output_name"

    echo "──────────────────────────────────────────"
    echo "Processing : $filename"
    echo "Output     : $output_path"

    # Step 1: Filter blacklisted chromosomes and compute bin midpoints,
    #         then load into a .cool file via cooler cload pairs
    grep -Ev "$BLACKLIST_CHR" "$bedpe_file" | \
    awk -F '\t' -v res="$RESOLUTION" '
        BEGIN { OFS="\t" }
        {
            mid1 = int(($2 + $3) / 2)
            mid2 = int(($5 + $6) / 2)
            print $1, mid1, $4, mid2, $7   # chr1, pos1, chr2, pos2, count
        }' | \
    cooler cload pairs \
        --assembly  "$ASSEMBLY" \
        --chrom1 1 --pos1 2 \
        --chrom2 3 --pos2 4 \
        "$CHROM_SIZES:$RESOLUTION" \
        - \
        "$output_path"

    # Step 2: ICE-balance the .cool file (cis contacts only)
    if [ -f "$output_path" ]; then
        echo "Balancing  : $output_path"
        cooler balance --force --cis-only "$output_path"
    else
        echo "ERROR: Expected output not created: $output_path"
        exit 1
    fi

    echo "Done       : $output_path"
done

echo "══════════════════════════════════════════"
echo "bedpe_to_cool complete. Files written to: $COOL_DIR"