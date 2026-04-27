suppressPackageStartupMessages({
  library(GenomicRanges)
  library(GenomicFeatures)
  library(TxDb.Hsapiens.UCSC.hg38.knownGene)
  library(optparse)
})

option_list <- list(
  make_option('--vcf', type='character', default=NULL, help='Genome-coordinate VCF file generated from human hg38 alignment.'),
  make_option('--out', type='character', default=NULL, help='Output transcript-coordinate VCF file.'),
  make_option('--tmp_dir', type='character', default=tempdir(), help='Temporary directory.')
)
opt <- parse_args(OptionParser(option_list=option_list))
if (is.null(opt$vcf) || is.null(opt$out)) stop('Required arguments: --vcf and --out')

# Human-only coordinate conversion using UCSC hg38 TxDb annotation.
txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
tx_exons <- exonsBy(txdb, by='tx', use.names=TRUE)
tx_exons <- tx_exons[!is.na(names(tx_exons))]

vcf <- read.table(opt$vcf, comment.char='#', stringsAsFactors=FALSE)
if (ncol(vcf) < 10) stop('Input VCF must contain at least 10 standard VCF columns.')
colnames(vcf)[1:10] <- c('chrom','pos','id','ref','alt','qual','filter','info','format','sample')

tx_chr <- unique(as.character(seqnames(unlist(tx_exons))))
vcf <- vcf[vcf$chrom %in% tx_chr, ]

plus_gr <- GRanges(seqnames=vcf$chrom, ranges=IRanges(start=as.integer(vcf$pos), width=1), strand='+', id=vcf$id, ref=vcf$ref, alt=vcf$alt, qual=vcf$qual, filter=vcf$filter, info=vcf$info, format=vcf$format, sample=vcf$sample)
minus_gr <- plus_gr
strand(minus_gr) <- '-'
snp_gr <- c(plus_gr, minus_gr)
tr_coords <- mapToTranscripts(snp_gr, tx_exons)

snp_tr <- GRanges(seqnames=seqnames(tr_coords), ranges=IRanges(start=start(tr_coords), width=1), strand=strand(tr_coords), id=snp_gr$id[tr_coords$xHits], ref=snp_gr$ref[tr_coords$xHits], alt=snp_gr$alt[tr_coords$xHits], qual=snp_gr$qual[tr_coords$xHits], filter=snp_gr$filter[tr_coords$xHits], info=snp_gr$info[tr_coords$xHits], format=snp_gr$format[tr_coords$xHits], sample=snp_gr$sample[tr_coords$xHits])

header <- c('##fileformat=VCFv4.2', '##reference=GRCh38-transcriptome', '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tSample1')
body <- paste(as.character(seqnames(snp_tr)), start(snp_tr), snp_tr$id, snp_tr$ref, snp_tr$alt, snp_tr$qual, snp_tr$filter, snp_tr$info, snp_tr$format, substr(snp_tr$sample, 1, 3), sep='\t')
writeLines(c(header, body), opt$out)
message('Number of transcript-coordinate SNP records: ', length(snp_tr))
