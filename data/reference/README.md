# Human reference files

The DirectASRM human pipeline requires the following reference files:

hg38.fa  
Homo_sapiens.GRCh38.cdna.all.fa  
Homo_sapiens.GRCh38.109.gtf  

These files are not included in this repository due to their large size.  
To ensure reproducibility, users should download the exact versions listed below.

---

## Reference file sources

### 1. Genome reference (hg38)

Source: UCSC Genome Browser  
Download:  
https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz

---

### 2. Transcriptome reference (cDNA)

Source: Ensembl (GRCh38)  
Release: 109  
Download:  
https://ftp.ensembl.org/pub/release-109/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz

---

### 3. Gene annotation (GTF)

Source: Ensembl (GRCh38)  
Release: 109  
Download:  
https://ftp.ensembl.org/pub/release-109/gtf/homo_sapiens/Homo_sapiens.GRCh38.109.gtf.gz

---

## Version consistency

All reference files must be compatible:

- Genome build: GRCh38 / hg38  
- Annotation: Ensembl release 109  
- Transcriptome: matched to the same Ensembl release  

Using inconsistent versions may lead to:

- incorrect SNP-to-transcript coordinate mapping  
- loss of SNPs during conversion  
- inconsistent transcript identifiers  

---

## Setup instructions

Download and decompress all files:

wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz  
wget https://ftp.ensembl.org/pub/release-109/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz  
wget https://ftp.ensembl.org/pub/release-109/gtf/homo_sapiens/Homo_sapiens.GRCh38.109.gtf.gz  

gunzip *.gz  

---

## Expected directory structure

data/reference/  
├── hg38.fa  
├── Homo_sapiens.GRCh38.cdna.all.fa  
└── Homo_sapiens.GRCh38.109.gtf  

---

## Notes

- Large reference files are excluded to keep the repository lightweight.
- Users may use mirror sites if needed, but must ensure version consistency.
- For long-term reproducibility, users are encouraged to archive reference files (e.g., Zenodo or institutional storage).
