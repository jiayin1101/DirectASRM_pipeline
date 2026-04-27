#!/usr/bin/env python3
import argparse
from collections import OrderedDict
import os
import numpy as np
import pysam


def get_parameters():
    parser = argparse.ArgumentParser(description='Assign transcriptome-aligned direct RNA reads to allele groups.')
    parser.add_argument('--bam', required=True, help='Transcriptome-aligned BAM file.')
    parser.add_argument('--vcf', required=True, help='Transcript-coordinate VCF file.')
    parser.add_argument('--outdir', required=True, help='Output directory.')
    parser.add_argument('--threshold_ratio', type=float, default=0.7, help='Minimum allele fraction for assignment.')
    parser.add_argument('--threshold_snp', type=int, default=2, help='Minimum informative SNPs required per read.')
    return parser.parse_args()


def read_vcf(vcf_file):
    contents = OrderedDict()
    with open(vcf_file, 'r', encoding='utf-8') as handle:
        for line in handle:
            if not line.strip() or line.startswith('#'):
                continue
            fields = line.rstrip('\n').split('\t')
            if len(fields) < 5:
                continue
            transcript_id = fields[0]
            position = int(fields[1])
            ref = fields[3].upper()
            alt = fields[4].split(',')[0].upper()
            if len(ref) != 1 or len(alt) != 1:
                continue
            contents.setdefault(transcript_id, OrderedDict())[position] = {'REF': ref, 'ALT': alt}
    return contents


def map_snp_to_read(cigar, read_start_1based, snp_pos_1based, read_length):
    relative_pos = snp_pos_1based - read_start_1based
    matched = inserted = deleted = clipped = 0
    for op, length in cigar:
        if op in (4, 5):
            if length >= read_length:
                return -2
            clipped += length
        elif op == 0:
            matched += length
            if matched + deleted >= relative_pos:
                read_pos = clipped + (relative_pos - deleted) + inserted
                return read_pos if 0 <= read_pos < read_length else -2
        elif op == 1:
            inserted += length
        elif op == 2:
            deleted += length
            if matched + deleted >= relative_pos:
                return -1
        else:
            return -3
    return -10


def assign_reads(vcf_contents, bam_file, outdir, threshold_ratio, threshold_snp):
    os.makedirs(outdir, exist_ok=True)
    threshold_ref = 1 - threshold_ratio
    samfile = pysam.AlignmentFile(bam_file, 'rb')
    reference_bam = pysam.AlignmentFile(os.path.join(outdir, 'reference.bam'), 'wb', template=samfile)
    alternative_bam = pysam.AlignmentFile(os.path.join(outdir, 'alternative.bam'), 'wb', template=samfile)
    undefined_bam = pysam.AlignmentFile(os.path.join(outdir, 'undefined.bam'), 'wb', template=samfile)

    with open(os.path.join(outdir, 'allele_assignment_summary.tsv'), 'w', encoding='utf-8') as summary:
        summary.write('read_id\ttranscript_id\tref_count\talt_count\tother_count\tskipped_snp_count\tallele_fraction_alt\tassignment\n')
        for transcript_id, pos_dict in vcf_contents.items():
            sorted_positions = sorted(pos_dict.keys())
            try:
                alignments = samfile.fetch(contig=transcript_id)
            except ValueError:
                continue
            for alignment in alignments:
                if alignment.is_unmapped or alignment.query_sequence is None:
                    undefined_bam.write(alignment)
                    continue
                read_start = alignment.reference_start + 1
                read_end = alignment.reference_end + 1
                snp_start = np.searchsorted(sorted_positions, read_start)
                snp_stop = np.searchsorted(sorted_positions, read_end)
                ref_count = alt_count = other_count = skipped_count = 0
                for i in range(snp_start, snp_stop):
                    snp_pos = sorted_positions[i]
                    read_pos = map_snp_to_read(alignment.cigartuples, read_start, snp_pos, alignment.query_alignment_length)
                    if read_pos >= 0:
                        base = alignment.query_sequence[read_pos].upper()
                        ref_base = pos_dict[snp_pos]['REF']
                        alt_base = pos_dict[snp_pos]['ALT']
                        if base == ref_base:
                            ref_count += 1
                        elif base == alt_base:
                            alt_count += 1
                        else:
                            other_count += 1
                    else:
                        skipped_count += 1
                informative = ref_count + alt_count
                if informative > threshold_snp:
                    alt_fraction = alt_count / informative
                    if alt_fraction >= threshold_ratio:
                        assignment = 'alternative'
                        alternative_bam.write(alignment)
                    elif alt_fraction <= threshold_ref:
                        assignment = 'reference'
                        reference_bam.write(alignment)
                    else:
                        assignment = 'undefined'
                        undefined_bam.write(alignment)
                else:
                    alt_fraction = 'NA'
                    assignment = 'undefined'
                    undefined_bam.write(alignment)
                summary.write(f'{alignment.query_name}\t{transcript_id}\t{ref_count}\t{alt_count}\t{other_count}\t{skipped_count}\t{alt_fraction}\t{assignment}\n')
    reference_bam.close(); alternative_bam.close(); undefined_bam.close(); samfile.close()


def main():
    args = get_parameters()
    assign_reads(read_vcf(args.vcf), args.bam, args.outdir, args.threshold_ratio, args.threshold_snp)


if __name__ == '__main__':
    main()
