#!/usr/bin/env bash
set -euo pipefail
bash scripts/01_basecalling.sh
bash scripts/02_genome_alignment_and_variant_calling.sh
bash scripts/03_vcf_genome_to_transcriptome.sh
bash scripts/04_mask_reference_and_realign.sh
bash scripts/05_allele_assignment.sh
bash scripts/06_nanopolish_eventalign_and_m6anet.sh
bash scripts/07_xpore_diffmod.sh
