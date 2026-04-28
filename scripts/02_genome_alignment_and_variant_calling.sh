#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config/config.sh"
IN_FASTA="${RESULTS_DIR}/01_basecalling/passed_all.fasta"
OUT_DIR="${RESULTS_DIR}/02_genome_alignment_and_variant_calling"
mkdir -p "${OUT_DIR}"

minimap2 -t "${THREADS}" -ax map-ont "${GENOME_FA}" "${IN_FASTA}" | \
  samtools view -F 0x900 -q 10 -h -Sb - | \
  samtools sort -@ "${THREADS}" -o "${OUT_DIR}/genome_aligned.sorted.bam"
samtools index "${OUT_DIR}/genome_aligned.sorted.bam"

longshot \
  --bam "${OUT_DIR}/genome_aligned.sorted.bam" \
  --ref "${GENOME_FA}" \
  --out "${OUT_DIR}/longshot.genome.vcf"

echo "[INFO] Filtering biallelic SNPs..."

bcftools view \
  -m2 -M2 -v snps -g het \
  "${OUT_DIR}/longshot.genome.vcf" \
  -o "${OUT_DIR}/longshot.genome.biallelic_snps.vcf"
