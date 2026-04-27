#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config/config.sh"
READS_FASTA="${RESULTS_DIR}/01_basecalling/passed_all.fasta"
ALLELE_DIR="${RESULTS_DIR}/05_allele_assignment"
OUT_DIR="${RESULTS_DIR}/06_nanopolish_eventalign_and_m6anet"
mkdir -p "${OUT_DIR}"

nanopolish index -d "${FAST5_DIR}" "${READS_FASTA}"

nanopolish eventalign \
  --reads "${READS_FASTA}" \
  --bam "${ALLELE_DIR}/reference.bam" \
  --genome "${TRANSCRIPTOME_FA}" \
  --scale-events \
  --signal-index \
  --summary "${OUT_DIR}/reference.summary.txt" \
  -t "${THREADS}" \
  > "${OUT_DIR}/reference.eventalign.txt"

nanopolish eventalign \
  --reads "${READS_FASTA}" \
  --bam "${ALLELE_DIR}/alternative.bam" \
  --genome "${TRANSCRIPTOME_FA}" \
  --scale-events \
  --signal-index \
  --summary "${OUT_DIR}/alternative.summary.txt" \
  -t "${THREADS}" \
  > "${OUT_DIR}/alternative.eventalign.txt"

m6anet dataprep --eventalign "${OUT_DIR}/reference.eventalign.txt" --out_dir "${OUT_DIR}/reference_dataprep" --n_processes "${THREADS}"
m6anet inference --input_dir "${OUT_DIR}/reference_dataprep" --out_dir "${OUT_DIR}/reference_inference" --n_processes "${THREADS}"
m6anet dataprep --eventalign "${OUT_DIR}/alternative.eventalign.txt" --out_dir "${OUT_DIR}/alternative_dataprep" --n_processes "${THREADS}"
m6anet inference --input_dir "${OUT_DIR}/alternative_dataprep" --out_dir "${OUT_DIR}/alternative_inference" --n_processes "${THREADS}"
