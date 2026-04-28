# DirectASRM human demonstration pipeline

This repository provides a publication-ready demonstration of the computational pipeline used in **DirectASRM: Uncovering allele-specific post-transcriptional RNA modifications through direct RNA sequencing**.

The scripts document the main analysis steps used to construct the DirectASRM resource. They are written as clear step-by-step shell scripts rather than as a fully automated workflow. This repository focuses on the **human pipeline**. The DirectASRM database contains multiple species; adapting this workflow to other species or genome builds may require minor changes to the reference genome, transcriptome FASTA, GTF/GFF annotation, coordinate-conversion step, and species-specific genome resources.

## Repository structure

```text
DirectASRM/
├── README.md
├── LICENSE
├── environment.yml
├── config/
│   ├── config.sh
│   └── xpore_config.yml
├── scripts/
│   ├── 01_basecalling.sh
│   ├── 02_genome_alignment_and_variant_calling.sh
│   ├── 03_vcf_genome_to_transcriptome.sh
│   ├── 04_mask_reference_and_realign.sh
│   ├── 05_allele_assignment.sh
│   ├── 06_nanopolish_eventalign_and_m6anet.sh
│   ├── 07_xpore_diffmod.sh
│   └── run_human_demo.sh
├── utils/
│   ├── allele_assignment.py
│   ├── mask_ref.R
│   └── vcf_g2t_human.R
├── data/
│   ├── demo_fast5/
│   └── reference/
├── docs/
└── results/
```

## Input files

For a small human demonstration run, place files as follows:

```text
data/demo_fast5/sample_fast5_files/
data/reference/hg38.fa
data/reference/Homo_sapiens.GRCh38.cdna.all.fa
data/reference/Homo_sapiens.GRCh38.gtf
```

A small FAST5 demo set is included only to illustrate the expected input structure and to allow users to test individual commands on a minimal example. It is not intended to reproduce the full DirectASRM database construction or to represent a complete direct RNA sequencing sample. For real analyses, users should run the pipeline on their own complete direct RNA FAST5 datasets on an appropriate server or HPC system. A full sample-level FAST5 dataset can be hundreds of gigabytes, so the demo data should be treated only as a lightweight test input.

## Configure paths

Edit:

```bash
config/config.sh
```

Tool names are called directly as `minimap2`, `samtools`, `longshot`, `nanopolish`, `m6anet`, and `xpore`, assuming they are available in the active environment.

## Run the human demonstration pipeline

```bash
bash scripts/run_human_demo.sh
```

Or run each step manually:

```bash
bash scripts/01_basecalling.sh
bash scripts/02_genome_alignment_and_variant_calling.sh
bash scripts/03_vcf_genome_to_transcriptome.sh
bash scripts/04_mask_reference_and_realign.sh
bash scripts/05_allele_assignment.sh
bash scripts/06_nanopolish_eventalign_and_m6anet.sh
bash scripts/07_xpore_diffmod.sh
```

## Notes

- This repository provides a transparent implementation of the human DirectASRM analysis pipeline for publication and review.
- The scripts are not cluster-specific and contain no SLURM/SBATCH directives.
- The scripts do not contain local absolute paths.
- The human coordinate conversion script uses `BSgenome.Hsapiens.UCSC.hg38` and `TxDb.Hsapiens.UCSC.hg38.knownGene` by default.
- For other species or genome builds, users should modify the reference genome, transcriptome reference, annotation, and coordinate-conversion logic accordingly.

## Archival DOI

For manuscript submission, the GitHub repository should be accompanied by an archived snapshot with a DOI, for example through Zenodo or Figshare.

Example availability statement:

> The DirectASRM pipeline is available at `https://github.com/<user>/<repo>`. A snapshot of the version used in this study has been archived at Zenodo under DOI: `10.5281/zenodo.xxxxxxx`.
