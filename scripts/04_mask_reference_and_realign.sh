#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config/config.sh"
IN_FASTA="${RESULTS_DIR}/01_basecalling/passed_all.fasta"
TRANSCRIPTOME_VCF="${RESULTS_DIR}/03_transcriptome_vcf/longshot.transcriptome.vcf"
OUT_DIR="${RESULTS_DIR}/04_mask_reference_and_realign"
mkdir -p "${OUT_DIR}"

Rscript utils/mask_ref.R \
  --vcf "${TRANSCRIPTOME_VCF}" \
  --ref "${TRANSCRIPTOME_FA}" \
  --out "${OUT_DIR}/masked_transcriptome.fa"

minimap2 -t "${THREADS}" -ax map-ont "${OUT_DIR}/masked_transcriptome.fa" "${IN_FASTA}" | \
  samtools view -F 0x900 -q 10 -h -Sb - | \
  samtools sort -@ "${THREADS}" -o "${OUT_DIR}/transcriptome_realign.sorted.bam"
samtools index "${OUT_DIR}/transcriptome_realign.sorted.bam"
