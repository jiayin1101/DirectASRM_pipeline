#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../config/config.sh"
mkdir -p "${FASTQ_DIR}"

guppy_basecaller \
  -i "${FAST5_DIR}" \
  -s "${FASTQ_DIR}" \
  --flowcell "${FLOWCELL}" \
  --kit "${KIT}" \
  --recursive \
  --device "${GUPPY_DEVICE}" \
  --num_callers 6 \
  --cpu_threads_per_caller 2 \
  --calib_detect \
  --compress_fastq \
  --reverse_sequence \
  --u_substitution

cat "${FASTQ_DIR}"/pass/*.fastq.gz > "${RESULTS_DIR}/01_basecalling/passed_all.fastq.gz"
zcat "${RESULTS_DIR}/01_basecalling/passed_all.fastq.gz" | sed -n '1~4s/^@/>/p;2~4p' > "${RESULTS_DIR}/01_basecalling/passed_all.fasta"
