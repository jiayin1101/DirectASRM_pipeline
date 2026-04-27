# DirectASRM human pipeline overview

This repository documents the human DirectASRM analysis pipeline used for allele-specific post-transcriptional RNA modification analysis from direct RNA sequencing.

Workflow:

1. Guppy basecalling
2. FASTQ-to-FASTA conversion
3. Human genome alignment
4. SNP calling with Longshot
5. Genome-to-transcriptome SNP coordinate conversion
6. SNP-masked transcriptome generation
7. Realignment to masked transcriptome
8. Allele-specific read assignment
9. Nanopolish eventalign
10. m6Anet modification inference
11. xPore allele-specific differential modification testing
