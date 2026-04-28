#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAST5_DIR="${PROJECT_DIR}/data/demo_fast5/sample_fast5_files"
REFERENCE_DIR="${PROJECT_DIR}/data/reference"
GENOME_FA="${REFERENCE_DIR}/hg38.fa"
TRANSCRIPTOME_FA="${REFERENCE_DIR}/Homo_sapiens.GRCh38.cdna.all.fa"
GTF_FILE="${REFERENCE_DIR}/Homo_sapiens.GRCh38.109.gtf"
RESULTS_DIR="${PROJECT_DIR}/results"
FASTQ_DIR="${RESULTS_DIR}/01_basecalling/fastq"
THREADS=4
ALLELE_RATIO=0.6
ALLELE_SNP_MIN=2
FLOWCELL="FLO-MIN106"
KIT="SQK-RNA002"
GUPPY_DEVICE="cuda:0"
