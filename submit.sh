#!/bin/bash
# =============================================================================
# submit.sh — SLURM submission wrapper for metaloops-toolkit scripts
#
# Reads SLURM resource settings from your config file and submits the
# requested script as an sbatch job, so you never have to hardcode
# --partition, --cpus-per-task, etc. inside the scripts themselves.
#
# Usage:
#   bash submit.sh <script> [path/to/local.env]
#
# Examples:
#   bash submit.sh scripts/bedpe2cool.sh
#   bash submit.sh scripts/cool2mcool.sh local.env
#   bash submit.sh scripts/run_metaloops.sh config/hpc.env
#
# The config file is forwarded to the script as its first argument.
# =============================================================================

set -euo pipefail

SCRIPT="${1:-}"
CONFIG="${2:-local.env}"

if [ -z "$SCRIPT" ]; then
    echo "Usage: bash submit.sh <script> [config]"
    exit 1
fi

if [ ! -f "$SCRIPT" ]; then
    echo "ERROR: Script not found: $SCRIPT"
    exit 1
fi

if [ ! -f "$CONFIG" ]; then
    echo "ERROR: Config file not found: $CONFIG"
    echo "       Copy config/example.env to local.env and fill in your values."
    exit 1
fi

# Load config to read SLURM_* variables
# shellcheck source=/dev/null
source "$CONFIG"

echo "Submitting : $SCRIPT"
echo "Config     : $CONFIG"
echo "Partition  : ${SLURM_PARTITION}"
echo "CPUs       : ${SLURM_CPUS}"
echo "Memory     : ${SLURM_MEM}"
echo "Time limit : ${SLURM_TIME}"

sbatch \
    --partition="${SLURM_PARTITION}" \
    --cpus-per-task="${SLURM_CPUS}" \
    --mem="${SLURM_MEM}" \
    --time="${SLURM_TIME}" \
    "$SCRIPT" "$CONFIG"