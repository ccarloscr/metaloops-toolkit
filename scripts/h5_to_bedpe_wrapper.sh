#!/bin/bash
# =============================================================================
# h5_to_bedpe_wrapper.sh — Run h5_to_bedpe.py to convert .h5 Hi-C files to BEDPE format
#
# Usage (local):
#   bash scripts/h5_to_bedpe_wrapper.sh [path/to/local.env]
#
# Usage (SLURM):
#   bash submit.sh scripts/h5_to_bedpe_wrapper.sh [path/to/local.env]
#
# If no config path is given, defaults to ./local.env
# =============================================================================

#SBATCH --job-name=h5_to_bedpe_wrapper
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=logs/h5_to_bedpe_wrapper_%j.out
#SBATCH --error=logs/h5_to_bedpe_wrapper_%j.err
# Resource flags (--partition, --cpus-per-task, --mem, --time) are injected
# dynamically by submit.sh from the config file.

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

# ── Activate conda environment ────────────────────────────────────────────────
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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY_SCRIPT="$SCRIPT_DIR/h5_to_bedpe.py"

[ ! -f "$PY_SCRIPT" ] && echo "ERROR: h5_to_bedpe.py not found at $PY_SCRIPT" && exit 1
[ ! -d "$H5_DIR" ]    && echo "ERROR: H5_DIR not found: $H5_DIR"            && exit 1

# ── Run conversion ────────────────────────────────────────────────────────────
echo "──────────────────────────────────────────"
echo "Input dir  : $H5_DIR"
echo "Output dir : $BEDPE_DIR"
echo "Min count  : ${MIN_COUNT:-0}"
echo "──────────────────────────────────────────"

python "$PY_SCRIPT" \
    --input-dir  "$H5_DIR" \
    --output-dir "$BEDPE_DIR" \
    --min-count  "${MIN_COUNT:-0}"