suppressPackageStartupMessages({
  library(Biostrings)
  library(GenomicRanges)
  library(optparse)
  library(stringr)
})

option_list <- list(
  make_option('--vcf', type='character', default=NULL, help='Transcript-coordinate VCF file.'),
  make_option('--ref', type='character', default=NULL, help='Transcriptome FASTA file.'),
  make_option('--out', type='character', default=NULL, help='Output masked transcriptome FASTA file.')
)
opt <- parse_args(OptionParser(option_list=option_list))
if (is.null(opt$vcf) || is.null(opt$ref) || is.null(opt$out)) stop('Required arguments: --vcf, --ref, --out')

vcf <- read.table(opt$vcf, comment.char='#', stringsAsFactors=FALSE)
if (ncol(vcf) < 5) stop('VCF file must contain at least CHROM, POS, ID, REF, and ALT columns.')

snp_tr <- GRanges(seqnames=vcf$V1, ranges=IRanges(start=as.integer(vcf$V2), width=nchar(vcf$V4)), strand='*', ref=vcf$V4, alt=vcf$V5)
ref_seq <- readDNAStringSet(opt$ref)
names(ref_seq) <- str_extract(names(ref_seq), '^\\S+')
masked <- ref_seq
snp_tr <- snp_tr[as.character(seqnames(snp_tr)) %in% names(masked)]
snp_df <- as.data.frame(snp_tr)

for (i in seq_len(nrow(snp_df))) {
  tx <- as.character(snp_df$seqnames[i])
  pos <- as.integer(snp_df$start[i])
  ref_len <- nchar(as.character(snp_df$ref[i]))
  if (pos >= 1 && (pos + ref_len - 1) <= width(masked[[tx]])) {
    subseq(masked[[tx]], start=pos, end=pos + ref_len - 1) <- DNAString(strrep('N', ref_len))
  }
}
writeXStringSet(masked, opt$out)
