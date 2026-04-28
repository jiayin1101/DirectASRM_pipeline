#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../config/config.sh"

IN_VCF="${RESULTS_DIR}/02_genome_alignment_and_variant_calling/longshot.genome.biallelic_snps.vcf"
OUT_DIR="${RESULTS_DIR}/03_transcriptome_vcf"

mkdir -p "${OUT_DIR}"

Rscript utils/vcf_g2t_human.R \
  --vcf "${IN_VCF}" \
  --gtf "${GTF_FILE}" \
  --out "${OUT_DIR}/longshot.transcriptome.vcf" \
  --tmp_dir "${OUT_DIR}"
