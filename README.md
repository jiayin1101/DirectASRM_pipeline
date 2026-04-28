# DirectASRM human demonstration pipeline

This repository provides a publication-ready demonstration of the computational pipeline used in **DirectASRM: Uncovering allele-specific post-transcriptional RNA modifications through direct RNA sequencing**.

The scripts document the main analysis steps used to construct the DirectASRM resource. They are written as clear step-by-step shell scripts rather than as a fully automated workflow. This repository focuses on the **human pipeline**. The DirectASRM database contains multiple species; adapting this workflow to other species or genome builds may require minor changes to the reference genome, transcriptome FASTA, GTF/GFF annotation, coordinate-conversion step, and species-specific genome resources.

---

## Repository structure

```text
DirectASRM/
├── README.md
├── LICENSE
├── config/
│   ├── config.sh
│   └── xpore_config.yml
├── envs/
│   ├── 02_alignment_variant.yml
│   ├── 03_04_r_coordinate_masking.yml
│   ├── 05_allele_assignment.yml
│   ├── 06_nanopolish_m6anet.yml
│   └── 07_xpore.yml
├── scripts/
│   ├── 01_basecalling.sh
│   ├── 02_genome_alignment_and_variant_calling.sh
│   ├── 03_vcf_genome_to_transcriptome.sh
│   ├── 04_mask_reference_and_realign.sh
│   ├── 05_allele_assignment.sh
│   ├── 06_nanopolish_eventalign_and_m6anet.sh
│   └── 07_xpore_diffmod.sh
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

---

## Input files

For a small human demonstration run, place files as follows:

```text
data/demo_fast5/sample_fast5_files/
data/reference/hg38.fa
data/reference/Homo_sapiens.GRCh38.cdna.all.fa
data/reference/Homo_sapiens.GRCh38.109.gtf
```

A small FAST5 demo set is included only to illustrate the expected input structure and to allow users to test individual commands on a minimal example. It is not intended to reproduce the full DirectASRM database construction or to represent a complete direct RNA sequencing sample. For real analyses, users should run the pipeline on their own complete direct RNA FAST5 datasets on an appropriate server or HPC system. A full sample-level FAST5 dataset can be hundreds of gigabytes, so the demo data should be treated only as a lightweight test input.

---

## Configure paths

Edit:

```bash
config/config.sh
```

Tool names are called directly as `minimap2`, `samtools`, `longshot`, `bcftools`, `nanopolish`, `m6anet`, and `xpore`, assuming they are available in the active environment.

---

## Environment setup (step-specific)

This pipeline uses **separate conda environments for different steps** to avoid dependency conflicts between tools.

Create environments as needed:

```bash
conda env create -f envs/02_alignment_variant.yml
conda env create -f envs/03_04_r_coordinate_masking.yml
conda env create -f envs/05_allele_assignment.yml
conda env create -f envs/06_nanopolish_m6anet.yml
conda env create -f envs/07_xpore.yml
```

Activate the corresponding environment before running each step.

---

## Run the pipeline (step-by-step)

### Step 01: Basecalling (external dependency)

Basecalling is performed using Oxford Nanopore Technologies (ONT) software such as Guppy or Dorado.

This step is **not managed within a conda environment**, as ONT basecallers are distributed as platform-specific binaries and often require GPU/CUDA support.

Users should install and configure the basecaller separately according to their system. Please refer to:

- Guppy: https://community.nanoporetech.com  
- Dorado: https://github.com/nanoporetech/dorado  

The downstream steps of this pipeline start from basecalled FASTQ files.

---

### Step 02–07

Run each step manually in the appropriate environment:

```bash
conda activate directasrm-step02-align-variant
bash scripts/02_genome_alignment_and_variant_calling.sh

conda activate directasrm-step03-04-r
bash scripts/03_vcf_genome_to_transcriptome.sh
bash scripts/04_mask_reference_and_realign.sh

conda activate directasrm-step05-allele
bash scripts/05_allele_assignment.sh

conda activate directasrm-step06-m6anet
bash scripts/06_nanopolish_eventalign_and_m6anet.sh

conda activate directasrm-step07-xpore
bash scripts/07_xpore_diffmod.sh
```

---

## Notes

- This repository provides a transparent implementation of the human DirectASRM analysis pipeline for publication and review.
- The scripts are not cluster-specific and contain no SLURM/SBATCH directives.
- The scripts do not contain local absolute paths.
- The pipeline is designed to be executed step-by-step rather than as a single automated workflow.
- The human coordinate conversion script uses the user-provided Ensembl GTF annotation file to map genome-coordinate variants to transcript coordinates.
- When using a UCSC-style genome reference such as `hg38.fa` together with Ensembl GTF/cDNA references, chromosome names are harmonized during coordinate conversion.
- For other species or genome builds, users should modify the reference genome, transcriptome reference, annotation, and coordinate-conversion logic accordingly.

---

## Code availability

The DirectASRM pipeline is publicly available at:
https://github.com/jiayin1101/DirectASRM_pipeline

A snapshot of the version used in this study has been archived on Zenodo:
https://doi.org/10.5281/zenodo.19851111
