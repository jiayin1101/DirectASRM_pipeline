#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config/config.sh"
IN_BAM="${RESULTS_DIR}/04_mask_reference_and_realign/transcriptome_realign.sorted.bam"
TRANSCRIPTOME_VCF="${RESULTS_DIR}/03_transcriptome_vcf/longshot.transcriptome.vcf"
OUT_DIR="${RESULTS_DIR}/05_allele_assignment"
mkdir -p "${OUT_DIR}"

python utils/allele_assignment.py \
  --threshold_ratio "${ALLELE_RATIO}" \
  --threshold_snp "${ALLELE_SNP_MIN}" \
  --bam "${IN_BAM}" \
  --vcf "${TRANSCRIPTOME_VCF}" \
  --outdir "${OUT_DIR}"

samtools index "${OUT_DIR}/reference.bam"
samtools index "${OUT_DIR}/alternative.bam"
samtools index "${OUT_DIR}/undefined.bam"
