#!/bin/bash
READSIN="$1"
ASSEMBLYIN="$2"
base_name=$(basename $ASSEMBLYIN .fasta)

bin/minimap2 -t 56 $ASSEMBLYIN $READSIN >racon/$base_name.0.paf
bin/racon -t 56 $READSIN racon/$base_name.0.paf $ASSEMBLYIN >racon/$base_name.0.fasta
for i in $(seq 0 2)
do
    ii=$( echo "$i + 1" | bc )
    bin/minimap2 -t 56 racon/$base_name.$i.fasta $READSIN >racon/$base_name.$ii.paf
    bin/racon -t 56 $READSIN racon/$base_name.$ii.paf racon/$base_name.$i.fasta >racon/$base_name.$ii.fasta
done

#usage: racon [options ...] <sequences> <overlaps> <target sequences>
#
#    <sequences>
#        input file in FASTA/FASTQ format (can be compressed with gzip)
#        containing sequences used for correction
#    <overlaps>
#        input file in MHAP/PAF/SAM format (can be compressed with gzip)
#        containing overlaps between sequences and target sequences
#    <target sequences>
#        input file in FASTA/FASTQ format (can be compressed with gzip)
#        containing sequences which will be corrected
#
#    options:
#        -u, --include-unpolished
#            output unpolished target sequences (each sequence contains
#            a tag in its header (C:<float>) which represents the
#            percentage of polished windows)
#        -f, --fragment-correction
#            perform fragment correction instead of contig polishing
#            (overlaps file should not contain dual/self overlaps!)
#        -w, --window-length <int>
#            default: 500
#            size of window on which POA is performed
#        -q, --quality-threshold <float>
#            default: 10.0
#            threshold for average base quality of windows used in poa
#        -e, --error-threshold <float>
#            default: 0.3
#            maximum allowed error rate used for filtering overlaps
#        -m, --match <int>
#            default: 5
#            score for matching bases
#        -x, --mismatch <int>
#            default: -4
#            score for mismatching bases
#        -g, --gap <int>
#            default: -8
#            gap penalty (must be negative)
#        -t, --threads <int>
#            default: 1
#            number of threads
#        --version
#            prints the version number
#        -h, --help
#            prints the usage
