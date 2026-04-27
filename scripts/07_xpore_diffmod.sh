#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config/config.sh"
EVENTALIGN_DIR="${RESULTS_DIR}/06_nanopolish_eventalign_and_m6anet"
OUT_DIR="${RESULTS_DIR}/07_xpore"
mkdir -p "${OUT_DIR}/reference/xpore_outdir" "${OUT_DIR}/alternative/xpore_outdir" "${OUT_DIR}/diffmod_out"

xpore dataprep --eventalign "${EVENTALIGN_DIR}/reference.eventalign.txt" --out_dir "${OUT_DIR}/reference/xpore_outdir" --n_processes "${THREADS}"
xpore dataprep --eventalign "${EVENTALIGN_DIR}/alternative.eventalign.txt" --out_dir "${OUT_DIR}/alternative/xpore_outdir" --n_processes "${THREADS}"
xpore diffmod --config config/xpore_config.yml
