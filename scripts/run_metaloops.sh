#!/bin/bash
# =============================================================================
# run_metaloops.sh — Run meta_loops.R on all .mcool files
#
# Usage (local):
#   bash scripts/run_metaloops.sh [path/to/local.env]
#
# Usage (SLURM):
#   bash submit.sh scripts/run_metaloops.sh [path/to/local.env]
#
# If no config path is given, defaults to ./local.env
# =============================================================================

#SBATCH --job-name=run_metaloops
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=logs/run_metaloops_%j.out
#SBATCH --error=logs/run_metaloops_%j.err
# Resource flags (--partition, --cpus-per-task, --mem, --time) are injected
# dynamically by submit.sh from your config file.

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

mkdir -p logs

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

# ── Locate meta_loops.R ───────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
R_SCRIPT="${SCRIPT_DIR}/../third_party/meta-loops-2022/meta_loops.R"

if [ ! -f "$R_SCRIPT" ]; then
    echo "ERROR: meta_loops.R not found at $R_SCRIPT"
    exit 1
fi

# ── Validate inputs ───────────────────────────────────────────────────────────
[ ! -d "$MCOOL_DIR" ] && echo "ERROR: MCOOL_DIR not found: $MCOOL_DIR" && exit 1
command -v Rscript >/dev/null || { echo "ERROR: Rscript not found. Is R installed in $CONDA_ENV?"; exit 1; }

mkdir -p "$RESULTS_DIR"

# ── Process each .mcool file ──────────────────────────────────────────────────
echo "──────────────────────────────────────────"
echo "Input dir  : $MCOOL_DIR"
echo "Output dir : $RESULTS_DIR"
echo "Resolution : $RESOLUTION"
echo "Chromosomes: $METALOOPS_CHROMOSOMES"
echo "──────────────────────────────────────────"

shopt -s nullglob
mapfile -t mcool_files < <(find "$MCOOL_DIR" -type f -name "*.mcool" | sort)

if [ ${#mcool_files[@]} -eq 0 ]; then
    echo "ERROR: No .mcool files found in $MCOOL_DIR"
    exit 1
fi

failed=()

for mcool_file in "${mcool_files[@]}"; do
    base_name=$(basename "$mcool_file" .mcool)
    output_file="$RESULTS_DIR/${base_name}-meta-loops.tsv"

    echo "Processing : $mcool_file"

    if [ -f "$output_file" ]; then
        echo "  Skipping  : $output_file already exists"
        continue
    fi

    if Rscript "$R_SCRIPT" \
        --output="$output_file" \
        --resolution="$RESOLUTION" \
        --chrs="$METALOOPS_CHROMOSOMES" \
        "$mcool_file"; then
        echo "  Done      : $output_file"
    else
        echo "  ERROR     : Failed to process $mcool_file" >&2
        failed+=("$mcool_file")
    fi
done

echo "══════════════════════════════════════════"
if [ ${#failed[@]} -gt 0 ]; then
    echo "Completed with ${#failed[@]} error(s):"
    for f in "${failed[@]}"; do
        echo "  - $f"
    done
    exit 1
else
    echo "run_metaloops complete. Results written to: $RESULTS_DIR"
fi